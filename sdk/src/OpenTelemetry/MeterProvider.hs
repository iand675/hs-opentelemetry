{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE StrictData #-}

{- | SDK 'OpenTelemetry.Metrics.MeterProvider' with in-process aggregation (specification/metrics/sdk.md).

 Synchronous: cumulative or delta sums, explicit or exponential histograms, last-value gauges;
 exemplars (optional trace context); cardinality limits; views (drop, aggregation, attribute keys).
 Observable callbacks run in registration order. Periodic export: "OpenTelemetry.MetricReader".
-}
module OpenTelemetry.MeterProvider (
  SdkMeterProviderOptions (..),
  defaultSdkMeterProviderOptions,
  SdkMeterExemplarOptions (..),
  defaultSdkMeterExemplarOptions,
  SdkMeterEnv (..),
  createMeterProvider,
  collectResourceMetrics,
) where

import Control.Monad.IO.Class (MonadIO, liftIO)
import Data.ByteString (ByteString)
import Data.Foldable (toList)
import qualified Data.HashMap.Strict as H
import Data.Hashable (Hashable)
import Data.IORef (IORef, atomicModifyIORef', newIORef, readIORef, writeIORef)
import Data.Int (Int32, Int64)
import qualified Data.IntMap.Strict as IM
import Data.Maybe (fromMaybe)
import Data.Sequence (Seq)
import qualified Data.Sequence as Seq
import Data.Text (Text, pack)
import Data.Vector (Vector)
import qualified Data.Vector as V
import Data.Word (Word64)
import GHC.Generics (Generic)
import OpenTelemetry.Attributes (Attributes, addAttribute, defaultAttributeLimits, emptyAttributes)
import OpenTelemetry.Context (lookupSpan)
import OpenTelemetry.Context.ThreadLocal (getContext)
import OpenTelemetry.Environment (MetricsExemplarFilter (..), lookupMetricsExemplarFilter)
import OpenTelemetry.Exporter.Metric (
  AggregationTemporality (..),
  ExponentialHistogramDataPoint (..),
  GaugeDataPoint (..),
  HistogramDataPoint (..),
  MetricExemplar (..),
  MetricExport (..),
  ResourceMetricsExport (..),
  ScopeMetricsExport (..),
  SumDataPoint (..),
  filterAttributesByKeys,
 )
import OpenTelemetry.Internal.Common.Types (FlushResult (..), InstrumentationLibrary (..), ShutdownResult (..))
import OpenTelemetry.Metrics (
  AdvisoryParameters (..),
  Counter (..),
  Gauge (..),
  Histogram (..),
  HistogramAggregation (..),
  InstrumentKind (..),
  Meter (..),
  MeterProvider (..),
  ObservableCallbackHandle (..),
  ObservableCounter (..),
  ObservableGauge (..),
  ObservableResult (..),
  ObservableUpDownCounter (..),
  UpDownCounter (..),
  noopMeter,
 )
import qualified OpenTelemetry.Metrics.InstrumentName as VName
import OpenTelemetry.Metrics.View (View (..), ViewAggregation (..), findMatchingView, viewOverrideDescription, viewOverrideName)
import OpenTelemetry.Resource (MaterializedResources)
import OpenTelemetry.Trace.Core (SpanContext (..), getSpanContext, isValid)
import OpenTelemetry.Trace.Id (spanIdBytes, traceIdBytes)
import System.Clock (Clock (Realtime), getTime, toNanoSecs)


data SdkMeterExemplarOptions = SdkMeterExemplarOptions
  { exemplarFilter :: !MetricsExemplarFilter
  -- ^ Spec default is TraceBased. Configured via OTEL_METRICS_EXEMPLAR_FILTER or explicit option.
  , exemplarReservoirLimit :: !Int
  }


defaultSdkMeterExemplarOptions :: SdkMeterExemplarOptions
defaultSdkMeterExemplarOptions =
  SdkMeterExemplarOptions
    { exemplarFilter = MetricsExemplarFilterTraceBased
    , exemplarReservoirLimit = 1
    }


data SdkMeterProviderOptions = SdkMeterProviderOptions
  { cardinalityLimit :: !Int
  , aggregationTemporality :: !AggregationTemporality
  , views :: ![View]
  , exemplarOptions :: !SdkMeterExemplarOptions
  }


defaultSdkMeterProviderOptions :: SdkMeterProviderOptions
defaultSdkMeterProviderOptions =
  SdkMeterProviderOptions
    { cardinalityLimit = 2000
    , aggregationTemporality = AggregationCumulative
    , views = []
    , exemplarOptions = defaultSdkMeterExemplarOptions
    }


data SdkMeterStorageState = SdkMeterStorageState
  { storageCells :: !(H.HashMap DimKey Cell)
  , seriesCountByDims :: !(H.HashMap InstrumentDims Int)
  }


emptyStorageState :: SdkMeterStorageState
emptyStorageState =
  SdkMeterStorageState
    { storageCells = H.empty
    , seriesCountByDims = H.empty
    }


data SdkMeterEnv = SdkMeterEnv
  { sdkMeterStorage :: !(IORef SdkMeterStorageState)
  , sdkMeterCollectCallbacks :: !(IORef (Seq (IO ())))
  , sdkMeterResource :: !MaterializedResources
  , sdkMeterShutdown :: !(IORef Bool)
  , sdkMeterCardinalityLimit :: !Int
  , sdkMeterAggregationTemporality :: !AggregationTemporality
  , sdkMeterViews :: ![View]
  , sdkMeterExemplarOptions :: !SdkMeterExemplarOptions
  , sdkMeterStartTimeNanos :: !Word64
  }


data InstrumentDims = InstrumentDims
  { dimScope :: !InstrumentationLibrary
  , dimName :: !Text
  , dimKind :: !InstrumentKind
  , dimUnit :: !Text
  , dimDescription :: !Text
  , dimHistogramAggregation :: !(Maybe HistogramAggregation)
  , dimExportAttributeKeys :: !(Maybe [Text])
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (Hashable)


type DimKey = (InstrumentDims, Attributes)


data SumCell = SumCell
  { scValue :: !Double
  , scMonotonic :: !Bool
  , scIsInt :: !Bool
  , scExemplars :: !(Vector MetricExemplar)
  }


data HistCell = HistCell
  { hcBuckets :: !(Vector Word64)
  , hcBounds :: !(Vector Double)
  , hcSum :: !Double
  , hcCount :: !Word64
  , hcMin :: !(Maybe Double)
  , hcMax :: !(Maybe Double)
  , hcExemplars :: !(Vector MetricExemplar)
  }


data ExpHistCell = ExpHistCell
  { ehcScale :: !Int32
  , ehcPositive :: !(IM.IntMap Word64)
  , ehcNegative :: !(IM.IntMap Word64)
  , ehcZeroCount :: !Word64
  , ehcSum :: !Double
  , ehcCount :: !Word64
  , ehcMin :: !(Maybe Double)
  , ehcMax :: !(Maybe Double)
  , ehcExemplars :: !(Vector MetricExemplar)
  }


data GaugeCell = GaugeCell
  { gcValue :: !(Either Int64 Double)
  , gcTimeUnixNano :: !Word64
  , gcExemplars :: !(Vector MetricExemplar)
  }


data Cell
  = CsSum !SumCell
  | CsHist !HistCell
  | CsExpHist !ExpHistCell
  | CsGauge !GaugeCell


nowNanos :: IO Word64
nowNanos = do
  t <- getTime Realtime
  pure $ fromIntegral (toNanoSecs t)


defaultHistogramBounds :: Vector Double
defaultHistogramBounds =
  V.fromList [0, 5, 10, 25, 50, 75, 100, 250, 500, 750, 1000, 2500, 5000, 7500, 10000]


canAcceptNewSeries :: Int -> DimKey -> SdkMeterStorageState -> Bool
canAcceptNewSeries lim k@(dims, _) st
  | H.member k (storageCells st) = True
  | lim <= 0 = True
  | otherwise = H.lookupDefault 0 dims (seriesCountByDims st) < lim


overflowAttributes :: Attributes
overflowAttributes =
  addAttribute defaultAttributeLimits emptyAttributes (pack "otel.metric.overflow") True


overflowKey :: InstrumentDims -> DimKey
overflowKey dims = (dims, overflowAttributes)


bumpSeriesCount :: InstrumentDims -> H.HashMap InstrumentDims Int -> H.HashMap InstrumentDims Int
bumpSeriesCount dims sc =
  let n = H.lookupDefault 0 dims sc
  in H.insert dims (n + 1) sc


bucketIndex :: Vector Double -> Double -> Int
bucketIndex bounds v =
  let n = V.length bounds
  in case V.findIndex (\b -> v <= b) bounds of
      Just i -> i
      Nothing -> n


emptyHist :: Vector Double -> HistCell
emptyHist bounds =
  HistCell
    { hcBuckets = V.replicate (V.length bounds + 1) 0
    , hcBounds = bounds
    , hcSum = 0
    , hcCount = 0
    , hcMin = Nothing
    , hcMax = Nothing
    , hcExemplars = V.empty
    }


emptyExpHist :: Int32 -> ExpHistCell
emptyExpHist sc =
  ExpHistCell
    { ehcScale = sc
    , ehcPositive = IM.empty
    , ehcNegative = IM.empty
    , ehcZeroCount = 0
    , ehcSum = 0
    , ehcCount = 0
    , ehcMin = Nothing
    , ehcMax = Nothing
    , ehcExemplars = V.empty
    }


positiveBucketIndex :: Double -> Int32 -> Int
positiveBucketIndex x sc =
  floor (logBase 2 x * (2 ** (fromIntegral sc :: Double)) :: Double)


mergeExpHist :: ExpHistCell -> Double -> ExpHistCell
mergeExpHist ehc v =
  let sc = ehcScale ehc
      upd =
        if v == 0
          then ehc {ehcZeroCount = ehcZeroCount ehc + 1}
          else
            if v > 0
              then
                let idx = positiveBucketIndex v sc
                in ehc {ehcPositive = IM.insertWith (+) idx 1 (ehcPositive ehc)}
              else
                let idx = positiveBucketIndex (abs v) sc
                in ehc {ehcNegative = IM.insertWith (+) idx 1 (ehcNegative ehc)}
      sm = ehcSum ehc + v
      ct = ehcCount ehc + 1
  in upd
      { ehcSum = sm
      , ehcCount = ct
      , ehcMin = minMaybe (ehcMin ehc) v
      , ehcMax = maxMaybe (ehcMax ehc) v
      }


intMapToOffsetCounts :: IM.IntMap Word64 -> (Int32, Vector Word64)
intMapToOffsetCounts mp =
  if IM.null mp
    then (0, V.empty)
    else
      let (minK, _) = IM.findMin mp
          (maxK, _) = IM.findMax mp
          width = maxK - minK + 1
          vec =
            V.generate width $ \i ->
              IM.findWithDefault 0 (minK + i) mp
      in (fromIntegral minK, vec)


expHistToDataPoint
  :: Word64
  -> Word64
  -> Attributes
  -> ExpHistCell
  -> ExponentialHistogramDataPoint
expHistToDataPoint startT t attrs ehc =
  let (posOff, posVec) = intMapToOffsetCounts (ehcPositive ehc)
      (negOff, negVec) = intMapToOffsetCounts (ehcNegative ehc)
  in ExponentialHistogramDataPoint
      { exponentialHistogramDataPointStartTimeUnixNano = startT
      , exponentialHistogramDataPointTimeUnixNano = t
      , exponentialHistogramDataPointCount = ehcCount ehc
      , exponentialHistogramDataPointSum = Just (ehcSum ehc)
      , exponentialHistogramDataPointScale = ehcScale ehc
      , exponentialHistogramDataPointZeroCount = ehcZeroCount ehc
      , exponentialHistogramDataPointPositiveOffset = posOff
      , exponentialHistogramDataPointPositiveBucketCounts = posVec
      , exponentialHistogramDataPointNegativeOffset = negOff
      , exponentialHistogramDataPointNegativeBucketCounts = negVec
      , exponentialHistogramDataPointAttributes = attrs
      , exponentialHistogramDataPointMin = ehcMin ehc
      , exponentialHistogramDataPointMax = ehcMax ehc
      , exponentialHistogramDataPointExemplars = ehcExemplars ehc
      , exponentialHistogramDataPointZeroThreshold = 0
      }


minMaybe :: Maybe Double -> Double -> Maybe Double
minMaybe Nothing v = Just v
minMaybe (Just a) v = Just (min a v)


maxMaybe :: Maybe Double -> Double -> Maybe Double
maxMaybe Nothing v = Just v
maxMaybe (Just a) v = Just (max a v)


validateOrNoop :: Text -> Maybe Text -> IO Bool
validateOrNoop name mUnit =
  case VName.validateInstrumentName name of
    Just _ -> pure False
    Nothing -> case mUnit of
      Nothing -> pure True
      Just u -> case VName.validateInstrumentUnit u of
        Just _ -> pure False
        Nothing -> pure True


dimsFrom
  :: InstrumentationLibrary
  -> Text
  -> InstrumentKind
  -> Maybe Text
  -> Maybe Text
  -> Maybe HistogramAggregation
  -> Maybe [Text]
  -> InstrumentDims
dimsFrom scope name kind mUnit mDesc mh mKeys =
  InstrumentDims
    { dimScope = scope
    , dimName = name
    , dimKind = kind
    , dimUnit = fromMaybe mempty mUnit
    , dimDescription = fromMaybe mempty mDesc
    , dimHistogramAggregation = mh
    , dimExportAttributeKeys = mKeys
    }


shouldDropInstrument :: [View] -> InstrumentKind -> Text -> Bool
shouldDropInstrument views kind name =
  case findMatchingView views kind name of
    Just v | viewAggregation v == ViewAggregationDrop -> True
    _ -> False


{- | Resolve attribute key filtering. Spec: view attribute_keys take precedence;
if absent, fall back to advisory Attributes parameter; if absent, keep all.
-}
exportKeysFor :: [View] -> InstrumentKind -> Text -> AdvisoryParameters -> Maybe [Text]
exportKeysFor views kind name adv =
  case findMatchingView views kind name of
    Nothing -> advisoryAttributeKeys adv
    Just v -> case viewAttributeKeys v of
      Just ks -> Just ks
      Nothing -> advisoryAttributeKeys adv


fromAdvisoryHistogram :: AdvisoryParameters -> HistogramAggregation
fromAdvisoryHistogram a = case advisoryHistogramAggregation a of
  Just h -> h
  Nothing -> case advisoryExplicitBucketBoundaries a of
    Just bs -> HistogramAggregationExplicit (V.fromList bs)
    Nothing -> HistogramAggregationExplicit defaultHistogramBounds


resolveHistogramAggregation :: [View] -> Text -> AdvisoryParameters -> Either () HistogramAggregation
resolveHistogramAggregation views name adv =
  case findMatchingView views KindHistogram name of
    Just v -> case viewAggregation v of
      ViewAggregationDrop -> Left ()
      ViewAggregationExplicitBucketHistogram bs -> Right (HistogramAggregationExplicit (V.fromList bs))
      ViewAggregationExponentialHistogram sc -> Right (HistogramAggregationExponential sc)
      ViewAggregationDefault -> Right (fromAdvisoryHistogram adv)
    Nothing -> Right (fromAdvisoryHistogram adv)


pushExemplar :: Int -> MetricExemplar -> Vector MetricExemplar -> Vector MetricExemplar
pushExemplar cap e v
  | cap <= 0 = V.empty
  | V.length v < cap = V.snoc v e
  | otherwise = V.snoc (V.tail v) e


captureMetricExemplar
  :: SdkMeterExemplarOptions
  -> Maybe (Either Int64 Double)
  -> IO (Maybe MetricExemplar)
captureMetricExemplar opts mVal =
  case exemplarFilter opts of
    MetricsExemplarFilterAlwaysOff -> pure Nothing
    MetricsExemplarFilterAlwaysOn -> do
      ctx <- getContext
      case lookupSpan ctx of
        Nothing -> makeExemplarNoTrace
        Just sp -> do
          scx <- getSpanContext sp
          makeExemplarWithContext scx
    MetricsExemplarFilterTraceBased -> do
      ctx <- getContext
      case lookupSpan ctx of
        Nothing -> pure Nothing
        Just sp -> do
          scx <- getSpanContext sp
          if not (isValid scx)
            then pure Nothing
            else makeExemplarWithContext scx
  where
    makeExemplarWithContext scx = do
      t <- nowNanos
      let tid :: ByteString
          tid = traceIdBytes (traceId scx)
          sid :: ByteString
          sid = spanIdBytes (spanId scx)
      pure $
        Just $
          MetricExemplar
            { metricExemplarTraceId = tid
            , metricExemplarSpanId = sid
            , metricExemplarTimeUnixNano = t
            , metricExemplarFilteredAttributes = emptyAttributes
            , metricExemplarValue = mVal
            }
    makeExemplarNoTrace = do
      t <- nowNanos
      pure $
        Just $
          MetricExemplar
            { metricExemplarTraceId = mempty
            , metricExemplarSpanId = mempty
            , metricExemplarTimeUnixNano = t
            , metricExemplarFilteredAttributes = emptyAttributes
            , metricExemplarValue = mVal
            }


addSum
  :: Double
  -> Bool
  -> Bool
  -> Maybe (Either Int64 Double)
  -> DimKey
  -> IORef SdkMeterStorageState
  -> Int
  -> SdkMeterExemplarOptions
  -> IO ()
addSum delta isMonotonic isInt mExVal k ref lim exOpts = do
  mex <- captureMetricExemplar exOpts mExVal
  let cap = exemplarReservoirLimit exOpts
  atomicModifyIORef' ref $ \st ->
    let effectiveK = if canAcceptNewSeries lim k st then k else overflowKey (fst k)
    in let m = storageCells st
           scount = seriesCountByDims st
           newCell = case H.lookup effectiveK m of
            Nothing ->
              CsSum $
                SumCell
                  { scValue = delta
                  , scMonotonic = isMonotonic
                  , scIsInt = isInt
                  , scExemplars = maybe V.empty (\e -> pushExemplar cap e V.empty) mex
                  }
            Just (CsSum sc) ->
              CsSum $
                sc
                  { scValue = scValue sc + delta
                  , scExemplars = case mex of
                      Nothing -> scExemplars sc
                      Just e -> pushExemplar cap e (scExemplars sc)
                  }
            Just _ ->
              CsSum $
                SumCell delta isMonotonic isInt (maybe V.empty (\e -> pushExemplar cap e V.empty) mex)
           isNew = not (H.member effectiveK m)
           m' = H.insert effectiveK newCell m
           sc' = if isNew then bumpSeriesCount (fst effectiveK) scount else scount
       in (SdkMeterStorageState m' sc', ())


mergeHist :: HistCell -> Double -> HistCell
mergeHist hc v =
  let idx = bucketIndex (hcBounds hc) v
      b' = V.accum (+) (hcBuckets hc) [(idx, 1)]
      sm = hcSum hc + v
      ct = hcCount hc + 1
  in hc
      { hcBuckets = b'
      , hcSum = sm
      , hcCount = ct
      , hcMin = minMaybe (hcMin hc) v
      , hcMax = maxMaybe (hcMax hc) v
      }


recordHist
  :: Vector Double
  -> Double
  -> Maybe Double
  -> DimKey
  -> IORef SdkMeterStorageState
  -> Int
  -> SdkMeterExemplarOptions
  -> IO ()
recordHist bounds v mExVal k ref lim exOpts = do
  if isNaN v || isInfinite v
    then pure ()
    else do
      mex <- captureMetricExemplar exOpts (fmap Right mExVal)
      let cap = exemplarReservoirLimit exOpts
      atomicModifyIORef' ref $ \st ->
        let effectiveK = if canAcceptNewSeries lim k st then k else overflowKey (fst k)
        in let m = storageCells st
               scount = seriesCountByDims st
               mergeE hc = case mex of
                Nothing -> hc
                Just e -> hc {hcExemplars = pushExemplar cap e (hcExemplars hc)}
               newCell = case H.lookup effectiveK m of
                Nothing -> CsHist (mergeE (mergeHist (emptyHist bounds) v))
                Just (CsHist hc) -> CsHist (mergeE (mergeHist hc v))
                Just _ -> CsHist (mergeE (mergeHist (emptyHist bounds) v))
               isNew = not (H.member effectiveK m)
               m' = H.insert effectiveK newCell m
               sc' = if isNew then bumpSeriesCount (fst effectiveK) scount else scount
           in (SdkMeterStorageState m' sc', ())


recordExpHist
  :: Int32
  -> Double
  -> Maybe Double
  -> DimKey
  -> IORef SdkMeterStorageState
  -> Int
  -> SdkMeterExemplarOptions
  -> IO ()
recordExpHist sc v mExVal k ref lim exOpts = do
  if isNaN v || isInfinite v
    then pure ()
    else do
      mex <- captureMetricExemplar exOpts (fmap Right mExVal)
      let cap = exemplarReservoirLimit exOpts
      atomicModifyIORef' ref $ \st ->
        let effectiveK = if canAcceptNewSeries lim k st then k else overflowKey (fst k)
        in let m = storageCells st
               scount = seriesCountByDims st
               mergeE ehc = case mex of
                Nothing -> ehc
                Just e -> ehc {ehcExemplars = pushExemplar cap e (ehcExemplars ehc)}
               newCell = case H.lookup effectiveK m of
                Nothing -> CsExpHist (mergeE (mergeExpHist (emptyExpHist sc) v))
                Just (CsExpHist ehc) -> CsExpHist (mergeE (mergeExpHist ehc v))
                Just _ -> CsExpHist (mergeE (mergeExpHist (emptyExpHist sc) v))
               isNew = not (H.member effectiveK m)
               m' = H.insert effectiveK newCell m
               sc' = if isNew then bumpSeriesCount (fst effectiveK) scount else scount
           in (SdkMeterStorageState m' sc', ())


recordGauge
  :: Either Int64 Double
  -> Word64
  -> Maybe (Either Int64 Double)
  -> DimKey
  -> IORef SdkMeterStorageState
  -> Int
  -> SdkMeterExemplarOptions
  -> IO ()
recordGauge val t mExVal k ref lim exOpts = do
  mex <- captureMetricExemplar exOpts mExVal
  let cap = exemplarReservoirLimit exOpts
  atomicModifyIORef' ref $ \st ->
    let effectiveK = if canAcceptNewSeries lim k st then k else overflowKey (fst k)
    in let m = storageCells st
           scount = seriesCountByDims st
           newGauge gc =
            case mex of
              Nothing -> gc {gcValue = val, gcTimeUnixNano = t}
              Just e ->
                gc
                  { gcValue = val
                  , gcTimeUnixNano = t
                  , gcExemplars = pushExemplar cap e (gcExemplars gc)
                  }
           newCell = case H.lookup effectiveK m of
            Nothing ->
              CsGauge
                GaugeCell
                  { gcValue = val
                  , gcTimeUnixNano = t
                  , gcExemplars = maybe V.empty (\e -> pushExemplar cap e V.empty) mex
                  }
            Just (CsGauge gc) -> CsGauge (newGauge gc)
            Just _ ->
              CsGauge
                GaugeCell
                  { gcValue = val
                  , gcTimeUnixNano = t
                  , gcExemplars = maybe V.empty (\e -> pushExemplar cap e V.empty) mex
                  }
           isNew = not (H.member effectiveK m)
           m' = H.insert effectiveK newCell m
           sc' = if isNew then bumpSeriesCount (fst effectiveK) scount else scount
       in (SdkMeterStorageState m' sc', ())


resetCellForDelta :: Cell -> Cell
resetCellForDelta = \case
  CsSum sc ->
    CsSum sc {scValue = 0, scExemplars = V.empty}
  CsHist hc ->
    CsHist (emptyHist (hcBounds hc))
  CsExpHist ehc ->
    CsExpHist (emptyExpHist (ehcScale ehc))
  CsGauge gc ->
    CsGauge gc


applyDeltaReset :: SdkMeterStorageState -> SdkMeterStorageState
applyDeltaReset st =
  SdkMeterStorageState
    { storageCells = H.map resetCellForDelta (storageCells st)
    , seriesCountByDims = seriesCountByDims st
    }


mkMeter :: SdkMeterEnv -> InstrumentationLibrary -> Meter
mkMeter env scope =
  Meter
    { meterInstrumentationScope = scope
    , meterCreateCounterInt64 = mkCounterI64 env scope KindCounter True True
    , meterCreateCounterDouble = mkCounterDbl env scope KindCounter True False
    , meterCreateUpDownCounterInt64 = mkUpDownI64 env scope
    , meterCreateUpDownCounterDouble = mkUpDownDbl env scope
    , meterCreateHistogram = mkHistogram env scope
    , meterCreateGaugeInt64 = mkGaugeI64 env scope
    , meterCreateGaugeDouble = mkGaugeDbl env scope
    , meterCreateObservableCounterInt64 = mkObsCounterI64 env scope
    , meterCreateObservableCounterDouble = mkObsCounterDbl env scope
    , meterCreateObservableUpDownCounterInt64 = mkObsUDCI64 env scope
    , meterCreateObservableUpDownCounterDouble = mkObsUDCDbl env scope
    , meterCreateObservableGaugeInt64 = mkObsGaugeI64 env scope
    , meterCreateObservableGaugeDouble = mkObsGaugeDbl env scope
    }
  where
    views = sdkMeterViews env
    exOpts = sdkMeterExemplarOptions env

    mkCounterI64 :: SdkMeterEnv -> InstrumentationLibrary -> InstrumentKind -> Bool -> Bool -> Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> IO (Counter Int64)
    mkCounterI64 e sc k mono isInt name mUnit mDesc adv = do
      if shouldDropInstrument views k name
        then pure $ Counter (\_ _ -> pure ()) (pure False)
        else do
          ok <- validateOrNoop name mUnit
          if ok
            then do
              let vName = viewOverrideName views k name
                  vDesc = viewOverrideDescription views k name mDesc
                  dims =
                    dimsFrom sc vName k mUnit vDesc Nothing (exportKeysFor views k name adv)
                  ref = sdkMeterStorage e
                  lim = sdkMeterCardinalityLimit e
              pure $
                Counter
                  { counterAdd = \n attrs ->
                      addSum (fromIntegral n) mono isInt (Just (Left n)) (dims, attrs) ref lim exOpts
                  , counterEnabled = pure True
                  }
            else pure $ Counter (\_ _ -> pure ()) (pure False)

    mkCounterDbl :: SdkMeterEnv -> InstrumentationLibrary -> InstrumentKind -> Bool -> Bool -> Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> IO (Counter Double)
    mkCounterDbl e sc k mono isInt name mUnit mDesc adv = do
      if shouldDropInstrument views k name
        then pure $ Counter (\_ _ -> pure ()) (pure False)
        else do
          ok <- validateOrNoop name mUnit
          if ok
            then do
              let vName = viewOverrideName views k name
                  vDesc = viewOverrideDescription views k name mDesc
                  dims =
                    dimsFrom sc vName k mUnit vDesc Nothing (exportKeysFor views k name adv)
                  ref = sdkMeterStorage e
                  lim = sdkMeterCardinalityLimit e
              pure $
                Counter
                  { counterAdd = \v attrs ->
                      addSum v mono isInt (Just (Right v)) (dims, attrs) ref lim exOpts
                  , counterEnabled = pure True
                  }
            else pure $ Counter (\_ _ -> pure ()) (pure False)

    mkUpDownI64 :: SdkMeterEnv -> InstrumentationLibrary -> Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> IO (UpDownCounter Int64)
    mkUpDownI64 e sc name mUnit mDesc adv = do
      if shouldDropInstrument views KindUpDownCounter name
        then pure $ UpDownCounter (\_ _ -> pure ()) (pure False)
        else do
          ok <- validateOrNoop name mUnit
          if ok
            then do
              let vName = viewOverrideName views KindUpDownCounter name
                  vDesc = viewOverrideDescription views KindUpDownCounter name mDesc
                  dims =
                    dimsFrom sc vName KindUpDownCounter mUnit vDesc Nothing (exportKeysFor views KindUpDownCounter name adv)
                  ref = sdkMeterStorage e
                  lim = sdkMeterCardinalityLimit e
              pure $
                UpDownCounter
                  { upDownCounterAdd = \n attrs ->
                      addSum (fromIntegral n) False True (Just (Left n)) (dims, attrs) ref lim exOpts
                  , upDownCounterEnabled = pure True
                  }
            else pure $ UpDownCounter (\_ _ -> pure ()) (pure False)

    mkUpDownDbl :: SdkMeterEnv -> InstrumentationLibrary -> Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> IO (UpDownCounter Double)
    mkUpDownDbl e sc name mUnit mDesc adv = do
      if shouldDropInstrument views KindUpDownCounter name
        then pure $ UpDownCounter (\_ _ -> pure ()) (pure False)
        else do
          ok <- validateOrNoop name mUnit
          if ok
            then do
              let vName = viewOverrideName views KindUpDownCounter name
                  vDesc = viewOverrideDescription views KindUpDownCounter name mDesc
                  dims =
                    dimsFrom sc vName KindUpDownCounter mUnit vDesc Nothing (exportKeysFor views KindUpDownCounter name adv)
                  ref = sdkMeterStorage e
                  lim = sdkMeterCardinalityLimit e
              pure $
                UpDownCounter
                  { upDownCounterAdd = \v attrs ->
                      addSum v False False (Just (Right v)) (dims, attrs) ref lim exOpts
                  , upDownCounterEnabled = pure True
                  }
            else pure $ UpDownCounter (\_ _ -> pure ()) (pure False)

    mkHistogram :: SdkMeterEnv -> InstrumentationLibrary -> Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> IO Histogram
    mkHistogram e sc name mUnit mDesc adv = do
      if shouldDropInstrument views KindHistogram name
        then pure $ Histogram (\_ _ -> pure ()) (pure False)
        else do
          ok <- validateOrNoop name mUnit
          if not ok
            then pure $ Histogram (\_ _ -> pure ()) (pure False)
            else case resolveHistogramAggregation views name adv of
              Left () -> pure $ Histogram (\_ _ -> pure ()) (pure False)
              Right agg -> do
                let vName = viewOverrideName views KindHistogram name
                    vDesc = viewOverrideDescription views KindHistogram name mDesc
                    dimsBase =
                      dimsFrom sc vName KindHistogram mUnit vDesc (Just agg) (exportKeysFor views KindHistogram name adv)
                    ref = sdkMeterStorage e
                    lim = sdkMeterCardinalityLimit e
                case agg of
                  HistogramAggregationExplicit bounds ->
                    pure $
                      Histogram
                        { histogramRecord = \v attrs ->
                            recordHist bounds v (Just v) (dimsBase, attrs) ref lim exOpts
                        , histogramEnabled = pure True
                        }
                  HistogramAggregationExponential scale ->
                    pure $
                      Histogram
                        { histogramRecord = \v attrs ->
                            recordExpHist scale v (Just v) (dimsBase, attrs) ref lim exOpts
                        , histogramEnabled = pure True
                        }

    mkGaugeI64 :: SdkMeterEnv -> InstrumentationLibrary -> Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> IO (Gauge Int64)
    mkGaugeI64 e sc name mUnit mDesc adv = do
      if shouldDropInstrument views KindGauge name
        then pure $ Gauge (\_ _ -> pure ()) (pure False)
        else do
          ok <- validateOrNoop name mUnit
          if ok
            then do
              let vName = viewOverrideName views KindGauge name
                  vDesc = viewOverrideDescription views KindGauge name mDesc
                  dims =
                    dimsFrom sc vName KindGauge mUnit vDesc Nothing (exportKeysFor views KindGauge name adv)
                  ref = sdkMeterStorage e
                  lim = sdkMeterCardinalityLimit e
              pure $
                Gauge
                  { gaugeRecord = \n attrs -> do
                      t <- nowNanos
                      recordGauge (Left n) t (Just (Left n)) (dims, attrs) ref lim exOpts
                  , gaugeEnabled = pure True
                  }
            else pure $ Gauge (\_ _ -> pure ()) (pure False)

    mkGaugeDbl :: SdkMeterEnv -> InstrumentationLibrary -> Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> IO (Gauge Double)
    mkGaugeDbl e sc name mUnit mDesc adv = do
      if shouldDropInstrument views KindGauge name
        then pure $ Gauge (\_ _ -> pure ()) (pure False)
        else do
          ok <- validateOrNoop name mUnit
          if ok
            then do
              let vName = viewOverrideName views KindGauge name
                  vDesc = viewOverrideDescription views KindGauge name mDesc
                  dims =
                    dimsFrom sc vName KindGauge mUnit vDesc Nothing (exportKeysFor views KindGauge name adv)
                  ref = sdkMeterStorage e
                  lim = sdkMeterCardinalityLimit e
              pure $
                Gauge
                  { gaugeRecord = \v attrs -> do
                      t <- nowNanos
                      recordGauge (Right v) t (Just (Right v)) (dims, attrs) ref lim exOpts
                  , gaugeEnabled = pure True
                  }
            else pure $ Gauge (\_ _ -> pure ()) (pure False)

    registerCollect :: IO () -> IO ()
    registerCollect act =
      atomicModifyIORef' (sdkMeterCollectCallbacks env) $ \s -> (s Seq.|> act, ())

    obsEnabled :: InstrumentKind -> Text -> IO Bool
    obsEnabled k name = pure $ not (shouldDropInstrument views k name)

    mkObsCounterI64 :: SdkMeterEnv -> InstrumentationLibrary -> Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> [ObservableResult Int64 -> IO ()] -> IO (ObservableCounter Int64)
    mkObsCounterI64 e sc name mUnit mDesc adv cbs = do
      ok <- validateOrNoop name mUnit
      if not ok
        then pure $ ObservableCounter (\_ -> pure (ObservableCallbackHandle (pure ()))) sc name (pure False)
        else do
          let vName = viewOverrideName views KindAsyncCounter name
              vDesc = viewOverrideDescription views KindAsyncCounter name mDesc
              dims =
                dimsFrom sc vName KindAsyncCounter mUnit vDesc Nothing (exportKeysFor views KindAsyncCounter name adv)
              ref = sdkMeterStorage e
              lim = sdkMeterCardinalityLimit e
              res = ObservableResult $ \n attrs ->
                addSum (fromIntegral n) True True (Just (Left n)) (dims, attrs) ref lim exOpts
              run = mapM_ ($ res) cbs
          registerCollect run
          en <- obsEnabled KindAsyncCounter name
          pure $
            ObservableCounter
              { observableCounterRegisterCallback = \cb -> do
                  registerCollect (cb res)
                  pure (ObservableCallbackHandle (pure ()))
              , observableCounterInstrumentScope = sc
              , observableCounterInstrumentName = name
              , observableCounterEnabled = pure en
              }

    mkObsCounterDbl :: SdkMeterEnv -> InstrumentationLibrary -> Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> [ObservableResult Double -> IO ()] -> IO (ObservableCounter Double)
    mkObsCounterDbl e sc name mUnit mDesc adv cbs = do
      ok <- validateOrNoop name mUnit
      if not ok
        then pure $ ObservableCounter (\_ -> pure (ObservableCallbackHandle (pure ()))) sc name (pure False)
        else do
          let vName = viewOverrideName views KindAsyncCounter name
              vDesc = viewOverrideDescription views KindAsyncCounter name mDesc
              dims =
                dimsFrom sc vName KindAsyncCounter mUnit vDesc Nothing (exportKeysFor views KindAsyncCounter name adv)
              ref = sdkMeterStorage e
              lim = sdkMeterCardinalityLimit e
              res = ObservableResult $ \v attrs ->
                addSum v True False (Just (Right v)) (dims, attrs) ref lim exOpts
              run = mapM_ ($ res) cbs
          registerCollect run
          en <- obsEnabled KindAsyncCounter name
          pure $
            ObservableCounter
              { observableCounterRegisterCallback = \cb -> do
                  registerCollect (cb res)
                  pure (ObservableCallbackHandle (pure ()))
              , observableCounterInstrumentScope = sc
              , observableCounterInstrumentName = name
              , observableCounterEnabled = pure en
              }

    mkObsUDCI64 :: SdkMeterEnv -> InstrumentationLibrary -> Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> [ObservableResult Int64 -> IO ()] -> IO (ObservableUpDownCounter Int64)
    mkObsUDCI64 e sc name mUnit mDesc adv cbs = do
      ok <- validateOrNoop name mUnit
      if not ok
        then pure $ ObservableUpDownCounter (\_ -> pure (ObservableCallbackHandle (pure ()))) sc name (pure False)
        else do
          let vName = viewOverrideName views KindAsyncUpDownCounter name
              vDesc = viewOverrideDescription views KindAsyncUpDownCounter name mDesc
              dims =
                dimsFrom sc vName KindAsyncUpDownCounter mUnit vDesc Nothing (exportKeysFor views KindAsyncUpDownCounter name adv)
              ref = sdkMeterStorage e
              lim = sdkMeterCardinalityLimit e
              res = ObservableResult $ \n attrs ->
                addSum (fromIntegral n) False True (Just (Left n)) (dims, attrs) ref lim exOpts
              run = mapM_ ($ res) cbs
          registerCollect run
          en <- obsEnabled KindAsyncUpDownCounter name
          pure $
            ObservableUpDownCounter
              { observableUpDownCounterRegisterCallback = \cb -> do
                  registerCollect (cb res)
                  pure (ObservableCallbackHandle (pure ()))
              , observableUpDownCounterInstrumentScope = sc
              , observableUpDownCounterInstrumentName = name
              , observableUpDownCounterEnabled = pure en
              }

    mkObsUDCDbl :: SdkMeterEnv -> InstrumentationLibrary -> Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> [ObservableResult Double -> IO ()] -> IO (ObservableUpDownCounter Double)
    mkObsUDCDbl e sc name mUnit mDesc adv cbs = do
      ok <- validateOrNoop name mUnit
      if not ok
        then pure $ ObservableUpDownCounter (\_ -> pure (ObservableCallbackHandle (pure ()))) sc name (pure False)
        else do
          let vName = viewOverrideName views KindAsyncUpDownCounter name
              vDesc = viewOverrideDescription views KindAsyncUpDownCounter name mDesc
              dims =
                dimsFrom sc vName KindAsyncUpDownCounter mUnit vDesc Nothing (exportKeysFor views KindAsyncUpDownCounter name adv)
              ref = sdkMeterStorage e
              lim = sdkMeterCardinalityLimit e
              res = ObservableResult $ \v attrs ->
                addSum v False False (Just (Right v)) (dims, attrs) ref lim exOpts
              run = mapM_ ($ res) cbs
          registerCollect run
          en <- obsEnabled KindAsyncUpDownCounter name
          pure $
            ObservableUpDownCounter
              { observableUpDownCounterRegisterCallback = \cb -> do
                  registerCollect (cb res)
                  pure (ObservableCallbackHandle (pure ()))
              , observableUpDownCounterInstrumentScope = sc
              , observableUpDownCounterInstrumentName = name
              , observableUpDownCounterEnabled = pure en
              }

    mkObsGaugeI64 :: SdkMeterEnv -> InstrumentationLibrary -> Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> [ObservableResult Int64 -> IO ()] -> IO (ObservableGauge Int64)
    mkObsGaugeI64 e sc name mUnit mDesc adv cbs = do
      ok <- validateOrNoop name mUnit
      if not ok
        then pure $ ObservableGauge (\_ -> pure (ObservableCallbackHandle (pure ()))) sc name (pure False)
        else do
          let vName = viewOverrideName views KindAsyncGauge name
              vDesc = viewOverrideDescription views KindAsyncGauge name mDesc
              dims =
                dimsFrom sc vName KindAsyncGauge mUnit vDesc Nothing (exportKeysFor views KindAsyncGauge name adv)
              ref = sdkMeterStorage e
              lim = sdkMeterCardinalityLimit e
              res = ObservableResult $ \n attrs -> do
                t <- nowNanos
                recordGauge (Left n) t (Just (Left n)) (dims, attrs) ref lim exOpts
              run = mapM_ ($ res) cbs
          registerCollect run
          en <- obsEnabled KindAsyncGauge name
          pure $
            ObservableGauge
              { observableGaugeRegisterCallback = \cb -> do
                  registerCollect (cb res)
                  pure (ObservableCallbackHandle (pure ()))
              , observableGaugeInstrumentScope = sc
              , observableGaugeInstrumentName = name
              , observableGaugeEnabled = pure en
              }

    mkObsGaugeDbl :: SdkMeterEnv -> InstrumentationLibrary -> Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> [ObservableResult Double -> IO ()] -> IO (ObservableGauge Double)
    mkObsGaugeDbl e sc name mUnit mDesc adv cbs = do
      ok <- validateOrNoop name mUnit
      if not ok
        then pure $ ObservableGauge (\_ -> pure (ObservableCallbackHandle (pure ()))) sc name (pure False)
        else do
          let vName = viewOverrideName views KindAsyncGauge name
              vDesc = viewOverrideDescription views KindAsyncGauge name mDesc
              dims =
                dimsFrom sc vName KindAsyncGauge mUnit vDesc Nothing (exportKeysFor views KindAsyncGauge name adv)
              ref = sdkMeterStorage e
              lim = sdkMeterCardinalityLimit e
              res = ObservableResult $ \v attrs -> do
                t <- nowNanos
                recordGauge (Right v) t (Just (Right v)) (dims, attrs) ref lim exOpts
              run = mapM_ ($ res) cbs
          registerCollect run
          en <- obsEnabled KindAsyncGauge name
          pure $
            ObservableGauge
              { observableGaugeRegisterCallback = \cb -> do
                  registerCollect (cb res)
                  pure (ObservableCallbackHandle (pure ()))
              , observableGaugeInstrumentScope = sc
              , observableGaugeInstrumentName = name
              , observableGaugeEnabled = pure en
              }


{- | Build export batches from current in-memory aggregates (invoke observable callbacks first).

Each batch has exactly the resource given at 'createMeterProvider'. If you run multiple
meter providers, do not merge their exports into one 'ResourceMetricsExport' — keep one
top-level entry per resource when forwarding to an exporter.
-}
collectResourceMetrics :: (MonadIO m) => SdkMeterEnv -> m [ResourceMetricsExport]
collectResourceMetrics env = liftIO $ do
  cbs <- readIORef (sdkMeterCollectCallbacks env)
  mapM_ id (toList cbs)
  st <- readIORef (sdkMeterStorage env)
  t <- nowNanos
  let temp = sdkMeterAggregationTemporality env
      snap = storageCells st
      startT = sdkMeterStartTimeNanos env
      rme = buildResourceExport (sdkMeterResource env) startT t temp snap
  _ <-
    if temp == AggregationDelta
      then atomicModifyIORef' (sdkMeterStorage env) $ \s -> (applyDeltaReset s, ())
      else pure ()
  pure [rme]


buildResourceExport
  :: MaterializedResources
  -> Word64
  -> Word64
  -> AggregationTemporality
  -> H.HashMap DimKey Cell
  -> ResourceMetricsExport
buildResourceExport res startT t temp m =
  let groups :: H.HashMap (InstrumentationLibrary, Text, InstrumentKind, Text, Text) [(Attributes, Cell, InstrumentDims)]
      groups =
        H.foldrWithKey
          ( \(dims, attrs) cell acc ->
              let k = (dimScope dims, dimName dims, dimKind dims, dimUnit dims, dimDescription dims)
              in H.insertWith (++) k [(attrs, cell, dims)] acc
          )
          H.empty
          m
      scopes = V.fromList $ fmap (toScope startT t temp) $ H.elems groups
  in ResourceMetricsExport res scopes


toScope :: Word64 -> Word64 -> AggregationTemporality -> [(Attributes, Cell, InstrumentDims)] -> ScopeMetricsExport
toScope startT t temp series =
  let dims = case series of
        (_, _, d) : _ -> d
        [] -> error "MeterProvider.toScope: empty"
      exports = buildMetricExports startT t temp dims series
  in ScopeMetricsExport (dimScope dims) (V.fromList exports)


applyDimAttrs :: InstrumentDims -> Attributes -> Attributes
applyDimAttrs dims attrs = filterAttributesByKeys (dimExportAttributeKeys dims) attrs


buildMetricExports
  :: Word64
  -> Word64
  -> AggregationTemporality
  -> InstrumentDims
  -> [(Attributes, Cell, InstrumentDims)]
  -> [MetricExport]
buildMetricExports startT t temp dims series =
  case dimKind dims of
    KindCounter -> sumExport True
    KindAsyncCounter -> sumExport True
    KindUpDownCounter -> sumExport False
    KindAsyncUpDownCounter -> sumExport False
    KindHistogram -> case dimHistogramAggregation dims of
      Just (HistogramAggregationExplicit _) -> histExport
      Just (HistogramAggregationExponential _) -> expHistExport
      Nothing -> histExport
    KindGauge -> gaugeExport False
    KindAsyncGauge -> gaugeExport True
  where
    sumExport mon =
      let points =
            V.fromList $
              foldr
                ( \(attrs, cell, d) acc -> case cell of
                    CsSum sc ->
                      SumDataPoint
                        { sumDataPointStartTimeUnixNano = startT
                        , sumDataPointTimeUnixNano = t
                        , sumDataPointValue = if scIsInt sc then Left (round (scValue sc)) else Right (scValue sc)
                        , sumDataPointAttributes = applyDimAttrs d attrs
                        , sumDataPointExemplars = scExemplars sc
                        }
                        : acc
                    _ -> acc
                )
                []
                series
          isInt =
            any
              ( \(_, cell, _) ->
                  case cell of
                    CsSum sc -> scIsInt sc
                    _ -> False
              )
              series
      in [ MetricExportSum (dimName dims) (dimDescription dims) (dimUnit dims) (dimScope dims) mon isInt temp points
         ]

    histExport =
      let points =
            V.fromList $
              foldr
                ( \(attrs, cell, d) acc -> case cell of
                    CsHist hc ->
                      HistogramDataPoint
                        { histogramDataPointStartTimeUnixNano = startT
                        , histogramDataPointTimeUnixNano = t
                        , histogramDataPointCount = hcCount hc
                        , histogramDataPointSum = hcSum hc
                        , histogramDataPointBucketCounts = hcBuckets hc
                        , histogramDataPointExplicitBounds = hcBounds hc
                        , histogramDataPointAttributes = applyDimAttrs d attrs
                        , histogramDataPointMin = hcMin hc
                        , histogramDataPointMax = hcMax hc
                        , histogramDataPointExemplars = hcExemplars hc
                        }
                        : acc
                    _ -> acc
                )
                []
                series
      in [ MetricExportHistogram (dimName dims) (dimDescription dims) (dimUnit dims) (dimScope dims) temp points
         ]

    expHistExport =
      let points =
            V.fromList $
              foldr
                ( \(attrs, cell, d) acc -> case cell of
                    CsExpHist ehc ->
                      expHistToDataPoint startT t (applyDimAttrs d attrs) ehc : acc
                    _ -> acc
                )
                []
                series
      in [ MetricExportExponentialHistogram (dimName dims) (dimDescription dims) (dimUnit dims) (dimScope dims) temp points
         ]

    gaugeExport _isAsync =
      let points =
            V.fromList $
              foldr
                ( \(attrs, cell, d) acc -> case cell of
                    CsGauge gc ->
                      GaugeDataPoint
                        { gaugeDataPointStartTimeUnixNano = startT
                        , gaugeDataPointTimeUnixNano = gcTimeUnixNano gc
                        , gaugeDataPointValue = gcValue gc
                        , gaugeDataPointAttributes = applyDimAttrs d attrs
                        , gaugeDataPointExemplars = gcExemplars gc
                        }
                        : acc
                    _ -> acc
                )
                []
                series
          isInt = case series of
            (_, CsGauge gc, _) : _ -> case gcValue gc of
              Left _ -> True
              Right _ -> False
            _ -> False
      in [ MetricExportGauge (dimName dims) (dimDescription dims) (dimUnit dims) (dimScope dims) isInt points
         ]


-- | Create an SDK-backed 'MeterProvider' and handle for collection.
createMeterProvider
  :: MaterializedResources
  -> SdkMeterProviderOptions
  -> IO (MeterProvider, SdkMeterEnv)
createMeterProvider res opts = do
  st <- newIORef emptyStorageState
  cbs <- newIORef Seq.empty
  sd <- newIORef False
  startT <- nowNanos
  envFilter <- lookupMetricsExemplarFilter
  let lim = cardinalityLimit opts
      temp = aggregationTemporality opts
      viewsList = views opts
      baseExOpts = exemplarOptions opts
      exOpts = case envFilter of
        Just f -> baseExOpts {exemplarFilter = f}
        Nothing -> baseExOpts
      env =
        SdkMeterEnv
          { sdkMeterStorage = st
          , sdkMeterCollectCallbacks = cbs
          , sdkMeterResource = res
          , sdkMeterShutdown = sd
          , sdkMeterCardinalityLimit = lim
          , sdkMeterAggregationTemporality = temp
          , sdkMeterViews = viewsList
          , sdkMeterExemplarOptions = exOpts
          , sdkMeterStartTimeNanos = startT
          }
      provider =
        MeterProvider
          { meterProviderGetMeter = \scope -> do
              shut <- readIORef sd
              if shut then pure (noopMeter scope) else pure (mkMeter env scope)
          , meterProviderShutdown = do
              writeIORef sd True
              writeIORef st emptyStorageState
              writeIORef cbs Seq.empty
              pure ShutdownSuccess
          , meterProviderForceFlush = do
              _ <- collectResourceMetrics env
              pure FlushSuccess
          }
  pure (provider, env)
