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

import Control.Concurrent.MVar (MVar, newMVar, withMVar)
import Control.Exception (SomeException, catch)
import Control.Monad (unless)
import Control.Monad.IO.Class (MonadIO, liftIO)
import Data.Bits (unsafeShiftR)
import Data.ByteString (ByteString)
import qualified Data.HashMap.Strict as H
import Data.Hashable (Hashable)
import Data.IORef (IORef, atomicModifyIORef', atomicWriteIORef, newIORef, readIORef)
import Data.Int (Int32, Int64)
import qualified Data.IntMap.Strict as IM
import qualified Data.List as L
import Data.Maybe (fromMaybe)
import Data.Text (Text, pack)
import Data.Vector (Vector)
import qualified Data.Vector as V
import qualified Data.Vector.Unboxed as U
import qualified Data.Vector.Unboxed.Mutable as UM
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
  MetricExporter (..),
  NumberValue (..),
  OptionalDouble (..),
  ResourceMetricsExport (..),
  ScopeMetricsExport (..),
  SumDataPoint (..),
  complementAttributesByKeys,
  filterAttributesByKeys,
  toMaybeDouble,
 )
import OpenTelemetry.Internal.AtomicCounter
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
import OpenTelemetry.Metrics.View (MeterScope, View (..), ViewAggregation (..), findAllMatchingViews)
import OpenTelemetry.Resource (MaterializedResources)
import OpenTelemetry.Trace.Core (SpanContext (..), getSpanContext, isSampled, isValid)
import OpenTelemetry.Trace.Id (spanIdBytes, traceIdBytes)
import OpenTelemetry.Common (Timestamp (..))
import System.Timeout (timeout)


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
  , metricExporter :: !(Maybe MetricExporter)
  }


defaultSdkMeterProviderOptions :: SdkMeterProviderOptions
defaultSdkMeterProviderOptions =
  SdkMeterProviderOptions
    { cardinalityLimit = 2000
    , aggregationTemporality = AggregationCumulative
    , views = []
    , exemplarOptions = defaultSdkMeterExemplarOptions
    , metricExporter = Nothing
    }


-- | HashMap paired with a cached entry count so cardinality checks are O(1)
-- instead of O(n) via 'H.size' on every recording.
data CellMap = CellMap
  { cmMap :: !(H.HashMap Attributes Cell)
  , cmSize :: {-# UNPACK #-} !Int
  }


emptyCellMap :: CellMap
emptyCellMap = CellMap H.empty 0
{-# INLINE emptyCellMap #-}


cmLookup :: Attributes -> CellMap -> Maybe Cell
cmLookup k = H.lookup k . cmMap
{-# INLINE cmLookup #-}


cmInsert :: Attributes -> Cell -> CellMap -> CellMap
cmInsert k v (CellMap m sz) =
  let !isNew = not (H.member k m)
      !m' = H.insert k v m
  in CellMap m' (if isNew then sz + 1 else sz)
{-# INLINE cmInsert #-}


-- | Insert without checking for existing key (caller knows it's an update).
cmReplace :: Attributes -> Cell -> CellMap -> CellMap
cmReplace k v (CellMap m sz) = CellMap (H.insert k v m) sz
{-# INLINE cmReplace #-}


{- | Per-instrument aggregation storage. Each registered instrument owns its own
IORef, eliminating cross-instrument contention on the recording hot path.
-}
data InstrumentStorage = InstrumentStorage
  { instrDims :: !InstrumentDims
  , instrCells :: !(IORef CellMap)
  }


data SdkMeterEnv = SdkMeterEnv
  { sdkMeterInstruments :: !(IORef [InstrumentStorage])
  , sdkMeterCollectCallbacks :: !(IORef (IM.IntMap (IO ())))
  , sdkMeterNextCallbackId :: !AtomicCounter
  , sdkMeterResource :: !MaterializedResources
  , sdkMeterShutdown :: !(IORef Bool)
  , sdkMeterCollectLock :: !(MVar ())
  -- ^ Serializes collection so observable callbacks don't double-fire
  -- when a periodic reader and manual flush overlap.
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


data SumCell
  = SumIntCell
      { siValue :: {-# UNPACK #-} !Int64
      , siMonotonic :: !Bool
      , siExemplars :: !(Vector MetricExemplar)
      }
  | SumDblCell
      { sdValue :: !Double
      , sdMonotonic :: !Bool
      , sdExemplars :: !(Vector MetricExemplar)
      }


data HistCell = HistCell
  { hcBuckets :: !(U.Vector Word64)
  , hcBounds :: !(U.Vector Double)
  , hcSum :: {-# UNPACK #-} !Double
  , hcCount :: {-# UNPACK #-} !Word64
  , hcMin :: !OptionalDouble
  , hcMax :: !OptionalDouble
  , hcExemplars :: !(Vector MetricExemplar)
  }


data ExpHistCell = ExpHistCell
  { ehcScale :: {-# UNPACK #-} !Int32
  , ehcPositive :: !(IM.IntMap Word64)
  , ehcNegative :: !(IM.IntMap Word64)
  , ehcZeroCount :: {-# UNPACK #-} !Word64
  , ehcSum :: {-# UNPACK #-} !Double
  , ehcCount :: {-# UNPACK #-} !Word64
  , ehcMin :: !OptionalDouble
  , ehcMax :: !OptionalDouble
  , ehcExemplars :: !(Vector MetricExemplar)
  }


data GaugeCell = GaugeCell
  { gcValue :: !NumberValue
  , gcTimeUnixNano :: {-# UNPACK #-} !Word64
  , gcExemplars :: !(Vector MetricExemplar)
  }


data Cell
  = CsSum !SumCell
  | CsHist !HistCell
  | CsExpHist !ExpHistCell
  | CsGauge !GaugeCell


nowNanos :: IO Word64
nowNanos = do
  Timestamp ns <- getTimestampIO
  pure ns


foreign import ccall unsafe "hs_otel_gettime_ns"
  getTimestampIO :: IO Timestamp


defaultHistogramBounds :: U.Vector Double
defaultHistogramBounds =
  U.fromList [0, 5, 10, 25, 50, 75, 100, 250, 500, 750, 1000, 2500, 5000, 7500, 10000]


overflowAttributes :: Attributes
overflowAttributes =
  addAttribute defaultAttributeLimits emptyAttributes (pack "otel.metric.overflow") True


bucketIndex :: U.Vector Double -> Double -> Int
bucketIndex bounds v = go 0 (U.length bounds)
  where
    go !lo !hi
      | lo >= hi = lo
      | otherwise =
          let !mid = lo + ((hi - lo) `unsafeShiftR` 1)
          in if v <= U.unsafeIndex bounds mid
              then go lo mid
              else go (mid + 1) hi
{-# INLINE bucketIndex #-}


emptyHist :: U.Vector Double -> HistCell
emptyHist bounds =
  HistCell
    { hcBuckets = U.replicate (U.length bounds + 1) 0
    , hcBounds = bounds
    , hcSum = 0
    , hcCount = 0
    , hcMin = NoDouble
    , hcMax = NoDouble
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
    , ehcMin = NoDouble
    , ehcMax = NoDouble
    , ehcExemplars = V.empty
    }


-- 1 / ln(2), precomputed to turn logBase into a single multiply per sample.
log2Recip :: Double
log2Recip = 1.4426950408889634
{-# INLINE log2Recip #-}


positiveBucketIndex :: Double -> Int32 -> Int
positiveBucketIndex x sc =
  let !scaleFactor = 2 ** fromIntegral sc :: Double
  in floor (log x * log2Recip * scaleFactor)
{-# INLINE positiveBucketIndex #-}


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
      , ehcMin = minOptDouble (ehcMin ehc) v
      , ehcMax = maxOptDouble (ehcMax ehc) v
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
      , exponentialHistogramDataPointMin = toMaybeDouble (ehcMin ehc)
      , exponentialHistogramDataPointMax = toMaybeDouble (ehcMax ehc)
      , exponentialHistogramDataPointExemplars = ehcExemplars ehc
      , exponentialHistogramDataPointZeroThreshold = 0
      }


minOptDouble :: OptionalDouble -> Double -> OptionalDouble
minOptDouble NoDouble v = SomeDouble v
minOptDouble (SomeDouble a) v = SomeDouble (min a v)
{-# INLINE minOptDouble #-}


maxOptDouble :: OptionalDouble -> Double -> OptionalDouble
maxOptDouble NoDouble v = SomeDouble v
maxOptDouble (SomeDouble a) v = SomeDouble (max a v)
{-# INLINE maxOptDouble #-}


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


toMeterScope :: InstrumentationLibrary -> MeterScope
toMeterScope il = (libraryName il, libraryVersion il, librarySchemaUrl il)


shouldDropInstrument :: [View] -> InstrumentKind -> Text -> Maybe Text -> MeterScope -> Bool
shouldDropInstrument vs kind name mUnit scope =
  case findAllMatchingViews vs kind name mUnit scope of
    [] -> False
    matched -> all (\v -> viewAggregation v == ViewAggregationDrop) matched


-- | Per-view stream target for multi-view fan-out on the recording path.
data StreamTarget = StreamTarget
  { stRef :: !(IORef CellMap)
  , stExportKeys :: !(Maybe [Text])
  }


{- | Resolve all matching views for an instrument and produce one 'StreamTarget'
per non-Drop view. If no views match, a single default stream is produced.
Spec: "If multiple Views match, multiple streams are produced."
-}
resolveStreamTargets
  :: SdkMeterEnv
  -> InstrumentationLibrary
  -> InstrumentKind
  -> Text
  -> Maybe Text
  -> Maybe Text
  -> AdvisoryParameters
  -> Maybe HistogramAggregation
  -> IO [StreamTarget]
resolveStreamTargets env sc kind name mUnit mDesc adv mHistAgg = do
  let vs = sdkMeterViews env
      mScope = toMeterScope sc
      matched = findAllMatchingViews vs kind name mUnit mScope
      nonDrop = Prelude.filter (\v -> viewAggregation v /= ViewAggregationDrop) matched
  case matched of
    [] -> do
      let mEk = advisoryAttributeKeys adv
          dims = dimsFrom sc name kind mUnit mDesc mHistAgg mEk
      ref <- getOrCreateInstrumentStorage env dims
      pure [StreamTarget ref mEk]
    _ -> mapM (mkStreamForView env sc kind name mUnit mDesc adv mHistAgg mScope) nonDrop


mkStreamForView
  :: SdkMeterEnv
  -> InstrumentationLibrary
  -> InstrumentKind
  -> Text
  -> Maybe Text
  -> Maybe Text
  -> AdvisoryParameters
  -> Maybe HistogramAggregation
  -> MeterScope
  -> View
  -> IO StreamTarget
mkStreamForView env sc kind name mUnit mDesc adv mHistAgg _mScope v = do
  let vName = case viewName v of
        Just n -> n
        Nothing -> name
      vDesc = case viewDescription v of
        Just d -> Just d
        Nothing -> mDesc
      mEk = case viewAttributeKeys v of
        Just ks -> Just ks
        Nothing -> advisoryAttributeKeys adv
      dims = dimsFrom sc vName kind mUnit vDesc mHistAgg mEk
  ref <- getOrCreateInstrumentStorage env dims
  pure (StreamTarget ref mEk)


fromAdvisoryHistogram :: AdvisoryParameters -> HistogramAggregation
fromAdvisoryHistogram a = case advisoryHistogramAggregation a of
  Just h -> h
  Nothing -> case advisoryExplicitBucketBoundaries a of
    Just bs -> HistogramAggregationExplicit (V.fromList (L.sort bs))
    Nothing -> HistogramAggregationExplicit (V.convert defaultHistogramBounds)


pushExemplar :: Int -> MetricExemplar -> Vector MetricExemplar -> Vector MetricExemplar
pushExemplar cap e v
  | cap <= 0 = V.empty
  | V.length v < cap = V.snoc v e
  | otherwise = V.snoc (V.tail v) e


captureMetricExemplar
  :: SdkMeterExemplarOptions
  -> Maybe NumberValue
  -> Attributes
  -- ^ Full measurement attributes (used to compute filtered attributes)
  -> Maybe [Text]
  -- ^ Export attribute keys from view; attributes NOT in this set are carried as filtered
  -> IO (Maybe MetricExemplar)
captureMetricExemplar !opts mVal !measureAttrs mExportKeys =
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
          if isValid scx && isSampled (traceFlags scx)
            then makeExemplarWithContext scx
            else pure Nothing
  where
    filteredAttrs = complementAttributesByKeys mExportKeys measureAttrs
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
            , metricExemplarFilteredAttributes = filteredAttrs
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
            , metricExemplarFilteredAttributes = filteredAttrs
            , metricExemplarValue = mVal
            }


addSumI64
  :: Int64
  -> Bool
  -> Maybe NumberValue
  -> Attributes
  -> IORef CellMap
  -> Int
  -> SdkMeterExemplarOptions
  -> Maybe [Text]
  -> IO ()
addSumI64 !delta isMonotonic mExVal !attrs ref lim exOpts mExportKeys =
  unless (isMonotonic && delta < 0) $ do
    mex <- captureMetricExemplar exOpts mExVal attrs mExportKeys
    let !cap = exemplarReservoirLimit exOpts
    atomicModifyIORef' ref $ \cm ->
      let !mExisting = cmLookup attrs cm
          !redirected = case mExisting of
            Just _ -> False
            Nothing -> lim > 0 && cmSize cm >= lim
          !effectiveK = if redirected then overflowAttributes else attrs
          !existing = if redirected then cmLookup effectiveK cm else mExisting
          !newCell = case existing of
            Nothing ->
              CsSum $!
                SumIntCell
                  { siValue = delta
                  , siMonotonic = isMonotonic
                  , siExemplars = maybe V.empty (\e -> pushExemplar cap e V.empty) mex
                  }
            Just (CsSum (SumIntCell v mon exs)) ->
              let !v' = v + delta
              in CsSum $!
                  SumIntCell
                    { siValue = v'
                    , siMonotonic = mon
                    , siExemplars = case mex of
                        Nothing -> exs
                        Just e -> pushExemplar cap e exs
                    }
            Just _ ->
              CsSum $!
                SumIntCell delta isMonotonic (maybe V.empty (\e -> pushExemplar cap e V.empty) mex)
          !cm' = cmInsert effectiveK newCell cm
      in (cm', ())
{-# INLINE addSumI64 #-}


addSumDbl
  :: Double
  -> Bool
  -> Maybe NumberValue
  -> Attributes
  -> IORef CellMap
  -> Int
  -> SdkMeterExemplarOptions
  -> Maybe [Text]
  -> IO ()
addSumDbl !delta isMonotonic mExVal !attrs ref lim exOpts mExportKeys =
  unless (isMonotonic && delta < 0) $ do
    mex <- captureMetricExemplar exOpts mExVal attrs mExportKeys
    let !cap = exemplarReservoirLimit exOpts
    atomicModifyIORef' ref $ \cm ->
      let !mExisting = cmLookup attrs cm
          !redirected = case mExisting of
            Just _ -> False
            Nothing -> lim > 0 && cmSize cm >= lim
          !effectiveK = if redirected then overflowAttributes else attrs
          !existing = if redirected then cmLookup effectiveK cm else mExisting
          !newCell = case existing of
            Nothing ->
              CsSum $!
                SumDblCell
                  { sdValue = delta
                  , sdMonotonic = isMonotonic
                  , sdExemplars = maybe V.empty (\e -> pushExemplar cap e V.empty) mex
                  }
            Just (CsSum (SumDblCell v mon exs)) ->
              let !v' = v + delta
              in CsSum $!
                  SumDblCell
                    { sdValue = v'
                    , sdMonotonic = mon
                    , sdExemplars = case mex of
                        Nothing -> exs
                        Just e -> pushExemplar cap e exs
                    }
            Just _ ->
              CsSum $!
                SumDblCell delta isMonotonic (maybe V.empty (\e -> pushExemplar cap e V.empty) mex)
          !cm' = cmInsert effectiveK newCell cm
      in (cm', ())
{-# INLINE addSumDbl #-}


mergeHist :: HistCell -> Double -> HistCell
mergeHist hc v =
  let !idx = bucketIndex (hcBounds hc) v
      !b' = U.modify (\mv -> UM.unsafeModify mv (+ 1) idx) (hcBuckets hc)
      !sm = hcSum hc + v
      !ct = hcCount hc + 1
  in hc
      { hcBuckets = b'
      , hcSum = sm
      , hcCount = ct
      , hcMin = minOptDouble (hcMin hc) v
      , hcMax = maxOptDouble (hcMax hc) v
      }
{-# INLINE mergeHist #-}


recordHist
  :: U.Vector Double
  -> Double
  -> Maybe Double
  -> Attributes
  -> IORef CellMap
  -> Int
  -> SdkMeterExemplarOptions
  -> Maybe [Text]
  -> IO ()
recordHist !bounds !v mExVal !attrs ref lim exOpts mExportKeys = do
  unless (isNaN v || isInfinite v) $ do
    mex <- captureMetricExemplar exOpts (DoubleNumber <$> mExVal) attrs mExportKeys
    let !cap = exemplarReservoirLimit exOpts
    atomicModifyIORef' ref $ \cm ->
      let !mExisting = cmLookup attrs cm
          !redirected = case mExisting of
            Just _ -> False
            Nothing -> lim > 0 && cmSize cm >= lim
          !effectiveK = if redirected then overflowAttributes else attrs
          !existing = if redirected then cmLookup effectiveK cm else mExisting
          mergeE hc = case mex of
            Nothing -> hc
            Just e -> hc {hcExemplars = pushExemplar cap e (hcExemplars hc)}
          !newCell = case existing of
            Nothing -> CsHist $! mergeE (mergeHist (emptyHist bounds) v)
            Just (CsHist hc) -> CsHist $! mergeE (mergeHist hc v)
            Just _ -> CsHist $! mergeE (mergeHist (emptyHist bounds) v)
          !cm' = cmInsert effectiveK newCell cm
      in (cm', ())
{-# INLINE recordHist #-}


recordExpHist
  :: Int32
  -> Double
  -> Maybe Double
  -> Attributes
  -> IORef CellMap
  -> Int
  -> SdkMeterExemplarOptions
  -> Maybe [Text]
  -> IO ()
recordExpHist sc v mExVal attrs ref lim exOpts mExportKeys = do
  if isNaN v || isInfinite v
    then pure ()
    else do
      mex <- captureMetricExemplar exOpts (fmap DoubleNumber mExVal) attrs mExportKeys
      let cap = exemplarReservoirLimit exOpts
      atomicModifyIORef' ref $ \cm ->
        let mExisting = cmLookup attrs cm
            redirected = case mExisting of
              Just _ -> False
              Nothing -> lim > 0 && cmSize cm >= lim
            effectiveK = if redirected then overflowAttributes else attrs
            existing = if redirected then cmLookup effectiveK cm else mExisting
            mergeE ehc = case mex of
              Nothing -> ehc
              Just e -> ehc {ehcExemplars = pushExemplar cap e (ehcExemplars ehc)}
            newCell = case existing of
              Nothing -> CsExpHist (mergeE (mergeExpHist (emptyExpHist sc) v))
              Just (CsExpHist ehc) -> CsExpHist (mergeE (mergeExpHist ehc v))
              Just _ -> CsExpHist (mergeE (mergeExpHist (emptyExpHist sc) v))
            cm' = cmInsert effectiveK newCell cm
        in (cm', ())


recordGauge
  :: NumberValue
  -> Word64
  -> Maybe NumberValue
  -> Attributes
  -> IORef CellMap
  -> Int
  -> SdkMeterExemplarOptions
  -> Maybe [Text]
  -> IO ()
recordGauge val t mExVal attrs ref lim exOpts mExportKeys = do
  mex <- captureMetricExemplar exOpts mExVal attrs mExportKeys
  let cap = exemplarReservoirLimit exOpts
  atomicModifyIORef' ref $ \cm ->
    let mExisting = cmLookup attrs cm
        redirected = case mExisting of
          Just _ -> False
          Nothing -> lim > 0 && cmSize cm >= lim
        effectiveK = if redirected then overflowAttributes else attrs
        existing = if redirected then cmLookup effectiveK cm else mExisting
        newGauge gc =
          case mex of
            Nothing -> gc {gcValue = val, gcTimeUnixNano = t}
            Just e ->
              gc
                { gcValue = val
                , gcTimeUnixNano = t
                , gcExemplars = pushExemplar cap e (gcExemplars gc)
                }
        newCell = case existing of
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
        cm' = cmInsert effectiveK newCell cm
    in (cm', ())


resetCellForDelta :: Cell -> Cell
resetCellForDelta = \case
  CsSum (SumIntCell _ mon _) ->
    CsSum (SumIntCell 0 mon V.empty)
  CsSum (SumDblCell _ mon _) ->
    CsSum (SumDblCell 0 mon V.empty)
  CsHist hc ->
    CsHist (emptyHist (hcBounds hc))
  CsExpHist ehc ->
    CsExpHist (emptyExpHist (ehcScale ehc))
  CsGauge gc ->
    CsGauge gc


{- | Look up existing storage for the given InstrumentDims, or create a new one.
This ensures same-name re-registration shares one stream (spec requirement).
The lookup and insert are performed inside a single atomicModifyIORef' to
prevent TOCTOU races where two threads both create storage for the same dims.
-}
getOrCreateInstrumentStorage :: SdkMeterEnv -> InstrumentDims -> IO (IORef CellMap)
getOrCreateInstrumentStorage env dims = do
  xs <- readIORef (sdkMeterInstruments env)
  case findByDims dims xs of
    Just s -> pure (instrCells s)
    Nothing -> do
      ref <- newIORef emptyCellMap
      let storage = InstrumentStorage {instrDims = dims, instrCells = ref}
      atomicModifyIORef' (sdkMeterInstruments env) $ \xs' ->
        case findByDims dims xs' of
          Just s -> (xs', instrCells s)
          Nothing -> (storage : xs', ref)
  where
    findByDims d = go
      where
        go [] = Nothing
        go (s : rest)
          | instrDims s == d = Just s
          | otherwise = go rest


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
    mkCounterI64 e sc k mono _isInt name mUnit mDesc adv = do
      let mScope = toMeterScope sc
      if shouldDropInstrument views k name mUnit mScope
        then pure $ Counter (\_ _ -> pure ()) (pure False)
        else do
          ok <- validateOrNoop name mUnit
          if ok
            then do
              let lim = sdkMeterCardinalityLimit e
              streams <- resolveStreamTargets e sc k name mUnit mDesc adv Nothing
              pure $
                Counter
                  { counterAdd = \n attrs ->
                      mapM_ (\st -> addSumI64 n mono (Just (IntNumber n)) attrs (stRef st) lim exOpts (stExportKeys st)) streams
                  , counterEnabled = pure True
                  }
            else pure $ Counter (\_ _ -> pure ()) (pure False)

    mkCounterDbl :: SdkMeterEnv -> InstrumentationLibrary -> InstrumentKind -> Bool -> Bool -> Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> IO (Counter Double)
    mkCounterDbl e sc k mono _isInt name mUnit mDesc adv = do
      let mScope = toMeterScope sc
      if shouldDropInstrument views k name mUnit mScope
        then pure $ Counter (\_ _ -> pure ()) (pure False)
        else do
          ok <- validateOrNoop name mUnit
          if ok
            then do
              let lim = sdkMeterCardinalityLimit e
              streams <- resolveStreamTargets e sc k name mUnit mDesc adv Nothing
              pure $
                Counter
                  { counterAdd = \v attrs ->
                      mapM_ (\st -> addSumDbl v mono (Just (DoubleNumber v)) attrs (stRef st) lim exOpts (stExportKeys st)) streams
                  , counterEnabled = pure True
                  }
            else pure $ Counter (\_ _ -> pure ()) (pure False)

    mkUpDownI64 :: SdkMeterEnv -> InstrumentationLibrary -> Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> IO (UpDownCounter Int64)
    mkUpDownI64 e sc name mUnit mDesc adv = do
      let mScope = toMeterScope sc
      if shouldDropInstrument views KindUpDownCounter name mUnit mScope
        then pure $ UpDownCounter (\_ _ -> pure ()) (pure False)
        else do
          ok <- validateOrNoop name mUnit
          if ok
            then do
              let lim = sdkMeterCardinalityLimit e
              streams <- resolveStreamTargets e sc KindUpDownCounter name mUnit mDesc adv Nothing
              pure $
                UpDownCounter
                  { upDownCounterAdd = \n attrs ->
                      mapM_ (\st -> addSumI64 n False (Just (IntNumber n)) attrs (stRef st) lim exOpts (stExportKeys st)) streams
                  , upDownCounterEnabled = pure True
                  }
            else pure $ UpDownCounter (\_ _ -> pure ()) (pure False)

    mkUpDownDbl :: SdkMeterEnv -> InstrumentationLibrary -> Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> IO (UpDownCounter Double)
    mkUpDownDbl e sc name mUnit mDesc adv = do
      let mScope = toMeterScope sc
      if shouldDropInstrument views KindUpDownCounter name mUnit mScope
        then pure $ UpDownCounter (\_ _ -> pure ()) (pure False)
        else do
          ok <- validateOrNoop name mUnit
          if ok
            then do
              let lim = sdkMeterCardinalityLimit e
              streams <- resolveStreamTargets e sc KindUpDownCounter name mUnit mDesc adv Nothing
              pure $
                UpDownCounter
                  { upDownCounterAdd = \v attrs ->
                      mapM_ (\st -> addSumDbl v False (Just (DoubleNumber v)) attrs (stRef st) lim exOpts (stExportKeys st)) streams
                  , upDownCounterEnabled = pure True
                  }
            else pure $ UpDownCounter (\_ _ -> pure ()) (pure False)

    mkHistogram :: SdkMeterEnv -> InstrumentationLibrary -> Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> IO Histogram
    mkHistogram e sc name mUnit mDesc adv = do
      let mScope = toMeterScope sc
          lim = sdkMeterCardinalityLimit e
      if shouldDropInstrument views KindHistogram name mUnit mScope
        then pure $ Histogram (\_ _ -> pure ()) (pure False)
        else do
          ok <- validateOrNoop name mUnit
          if not ok
            then pure $ Histogram (\_ _ -> pure ()) (pure False)
            else do
              let matched = findAllMatchingViews views KindHistogram name mUnit mScope
                  nonDrop = Prelude.filter (\v -> viewAggregation v /= ViewAggregationDrop) matched
              recorders <- case matched of
                [] -> do
                  let agg = fromAdvisoryHistogram adv
                      mEk = advisoryAttributeKeys adv
                      dims = dimsFrom sc name KindHistogram mUnit mDesc (Just agg) mEk
                  ref <- getOrCreateInstrumentStorage e dims
                  pure [mkHistRecorder agg ref lim mEk]
                _ -> fmap concat $ mapM (mkHistRecorderForView e sc name mUnit mDesc adv mScope lim) nonDrop
              case recorders of
                [] -> pure $ Histogram (\_ _ -> pure ()) (pure False)
                _ ->
                  pure $
                    Histogram
                      { histogramRecord = \v attrs ->
                          mapM_ (\rec -> rec v attrs) recorders
                      , histogramEnabled = pure True
                      }

    mkHistRecorder :: HistogramAggregation -> IORef CellMap -> Int -> Maybe [Text] -> (Double -> Attributes -> IO ())
    mkHistRecorder (HistogramAggregationExplicit bounds) ref lim mEk =
      let !ubounds = U.convert bounds
      in \v attrs -> recordHist ubounds v (Just v) attrs ref lim exOpts mEk
    mkHistRecorder (HistogramAggregationExponential scale) ref lim mEk =
      \v attrs -> recordExpHist scale v (Just v) attrs ref lim exOpts mEk

    mkHistRecorderForView
      :: SdkMeterEnv -> InstrumentationLibrary -> Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> MeterScope -> Int -> View -> IO [Double -> Attributes -> IO ()]
    mkHistRecorderForView e sc name mUnit mDesc adv _mScope lim v = do
      let vAgg = viewAggregation v
          agg = case vAgg of
            ViewAggregationExplicitBucketHistogram bs -> Right (HistogramAggregationExplicit (V.fromList (L.sort bs)))
            ViewAggregationExponentialHistogram sc' -> Right (HistogramAggregationExponential sc')
            ViewAggregationDefault -> Right (fromAdvisoryHistogram adv)
            ViewAggregationDrop -> Left ()
      case agg of
        Left () -> pure []
        Right a -> do
          let mEk = case viewAttributeKeys v of
                Just ks -> Just ks
                Nothing -> advisoryAttributeKeys adv
              vName = case viewName v of
                Just n -> n
                Nothing -> name
              vDesc = case viewDescription v of
                Just d -> Just d
                Nothing -> mDesc
              dims = dimsFrom sc vName KindHistogram mUnit vDesc (Just a) mEk
          ref <- getOrCreateInstrumentStorage e dims
          pure [mkHistRecorder a ref lim mEk]

    mkGaugeI64 :: SdkMeterEnv -> InstrumentationLibrary -> Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> IO (Gauge Int64)
    mkGaugeI64 e sc name mUnit mDesc adv = do
      let mScope = toMeterScope sc
      if shouldDropInstrument views KindGauge name mUnit mScope
        then pure $ Gauge (\_ _ -> pure ()) (pure False)
        else do
          ok <- validateOrNoop name mUnit
          if ok
            then do
              let lim = sdkMeterCardinalityLimit e
              streams <- resolveStreamTargets e sc KindGauge name mUnit mDesc adv Nothing
              pure $
                Gauge
                  { gaugeRecord = \n attrs -> do
                      t <- nowNanos
                      mapM_ (\st -> recordGauge (IntNumber n) t (Just (IntNumber n)) attrs (stRef st) lim exOpts (stExportKeys st)) streams
                  , gaugeEnabled = pure True
                  }
            else pure $ Gauge (\_ _ -> pure ()) (pure False)

    mkGaugeDbl :: SdkMeterEnv -> InstrumentationLibrary -> Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> IO (Gauge Double)
    mkGaugeDbl e sc name mUnit mDesc adv = do
      let mScope = toMeterScope sc
      if shouldDropInstrument views KindGauge name mUnit mScope
        then pure $ Gauge (\_ _ -> pure ()) (pure False)
        else do
          ok <- validateOrNoop name mUnit
          if ok
            then do
              let lim = sdkMeterCardinalityLimit e
              streams <- resolveStreamTargets e sc KindGauge name mUnit mDesc adv Nothing
              pure $
                Gauge
                  { gaugeRecord = \v attrs -> do
                      t <- nowNanos
                      mapM_ (\st -> recordGauge (DoubleNumber v) t (Just (DoubleNumber v)) attrs (stRef st) lim exOpts (stExportKeys st)) streams
                  , gaugeEnabled = pure True
                  }
            else pure $ Gauge (\_ _ -> pure ()) (pure False)

    ignoreCallbackException :: IO () -> IO ()
    ignoreCallbackException a = a `catch` handler
      where
        handler :: SomeException -> IO ()
        handler _ = pure ()

    registerCollect :: IO () -> IO (IO ())
    registerCollect act = do
      callbackId <- fetchAddAtomicCounter 1 (sdkMeterNextCallbackId env)
      atomicModifyIORef' (sdkMeterCollectCallbacks env) $ \m -> (IM.insert callbackId (ignoreCallbackException act) m, ())
      pure $ atomicModifyIORef' (sdkMeterCollectCallbacks env) $ \m -> (IM.delete callbackId m, ())

    obsEnabled :: InstrumentKind -> Text -> Maybe Text -> MeterScope -> IO Bool
    obsEnabled k name mUnit mScope = pure $ not (shouldDropInstrument views k name mUnit mScope)

    mkObsCounterI64 :: SdkMeterEnv -> InstrumentationLibrary -> Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> [ObservableResult Int64 -> IO ()] -> IO (ObservableCounter Int64)
    mkObsCounterI64 e sc name mUnit mDesc adv cbs = do
      ok <- validateOrNoop name mUnit
      if not ok
        then pure $ ObservableCounter (\_ -> pure (ObservableCallbackHandle (pure ()))) sc name (pure False)
        else do
          let mScope = toMeterScope sc
              lim = sdkMeterCardinalityLimit e
          streams <- resolveStreamTargets e sc KindAsyncCounter name mUnit mDesc adv Nothing
          let res = ObservableResult $ \n attrs ->
                mapM_ (\st -> addSumI64 n True (Just (IntNumber n)) attrs (stRef st) lim exOpts (stExportKeys st)) streams
              run = mapM_ (\cb -> ignoreCallbackException (cb res)) cbs
          _ <- registerCollect run
          en <- obsEnabled KindAsyncCounter name mUnit mScope
          pure $
            ObservableCounter
              { observableCounterRegisterCallback = \cb -> do
                  unregister <- registerCollect (cb res)
                  pure (ObservableCallbackHandle unregister)
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
          let mScope = toMeterScope sc
              lim = sdkMeterCardinalityLimit e
          streams <- resolveStreamTargets e sc KindAsyncCounter name mUnit mDesc adv Nothing
          let res = ObservableResult $ \v attrs ->
                mapM_ (\st -> addSumDbl v True (Just (DoubleNumber v)) attrs (stRef st) lim exOpts (stExportKeys st)) streams
              run = mapM_ (\cb -> ignoreCallbackException (cb res)) cbs
          _ <- registerCollect run
          en <- obsEnabled KindAsyncCounter name mUnit mScope
          pure $
            ObservableCounter
              { observableCounterRegisterCallback = \cb -> do
                  unregister <- registerCollect (cb res)
                  pure (ObservableCallbackHandle unregister)
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
          let mScope = toMeterScope sc
              lim = sdkMeterCardinalityLimit e
          streams <- resolveStreamTargets e sc KindAsyncUpDownCounter name mUnit mDesc adv Nothing
          let res = ObservableResult $ \n attrs ->
                mapM_ (\st -> addSumI64 n False (Just (IntNumber n)) attrs (stRef st) lim exOpts (stExportKeys st)) streams
              run = mapM_ (\cb -> ignoreCallbackException (cb res)) cbs
          _ <- registerCollect run
          en <- obsEnabled KindAsyncUpDownCounter name mUnit mScope
          pure $
            ObservableUpDownCounter
              { observableUpDownCounterRegisterCallback = \cb -> do
                  unregister <- registerCollect (cb res)
                  pure (ObservableCallbackHandle unregister)
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
          let mScope = toMeterScope sc
              lim = sdkMeterCardinalityLimit e
          streams <- resolveStreamTargets e sc KindAsyncUpDownCounter name mUnit mDesc adv Nothing
          let res = ObservableResult $ \v attrs ->
                mapM_ (\st -> addSumDbl v False (Just (DoubleNumber v)) attrs (stRef st) lim exOpts (stExportKeys st)) streams
              run = mapM_ (\cb -> ignoreCallbackException (cb res)) cbs
          _ <- registerCollect run
          en <- obsEnabled KindAsyncUpDownCounter name mUnit mScope
          pure $
            ObservableUpDownCounter
              { observableUpDownCounterRegisterCallback = \cb -> do
                  unregister <- registerCollect (cb res)
                  pure (ObservableCallbackHandle unregister)
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
          let mScope = toMeterScope sc
              lim = sdkMeterCardinalityLimit e
          streams <- resolveStreamTargets e sc KindAsyncGauge name mUnit mDesc adv Nothing
          let res = ObservableResult $ \n attrs -> do
                t <- nowNanos
                mapM_ (\st -> recordGauge (IntNumber n) t (Just (IntNumber n)) attrs (stRef st) lim exOpts (stExportKeys st)) streams
              run = mapM_ (\cb -> ignoreCallbackException (cb res)) cbs
          _ <- registerCollect run
          en <- obsEnabled KindAsyncGauge name mUnit mScope
          pure $
            ObservableGauge
              { observableGaugeRegisterCallback = \cb -> do
                  unregister <- registerCollect (cb res)
                  pure (ObservableCallbackHandle unregister)
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
          let mScope = toMeterScope sc
              lim = sdkMeterCardinalityLimit e
          streams <- resolveStreamTargets e sc KindAsyncGauge name mUnit mDesc adv Nothing
          let res = ObservableResult $ \v attrs -> do
                t <- nowNanos
                mapM_ (\st -> recordGauge (DoubleNumber v) t (Just (DoubleNumber v)) attrs (stRef st) lim exOpts (stExportKeys st)) streams
              run = mapM_ (\cb -> ignoreCallbackException (cb res)) cbs
          _ <- registerCollect run
          en <- obsEnabled KindAsyncGauge name mUnit mScope
          pure $
            ObservableGauge
              { observableGaugeRegisterCallback = \cb -> do
                  unregister <- registerCollect (cb res)
                  pure (ObservableCallbackHandle unregister)
              , observableGaugeInstrumentScope = sc
              , observableGaugeInstrumentName = name
              , observableGaugeEnabled = pure en
              }


{- | Build export batches from current in-memory aggregates (invoke observable callbacks first).

Each batch has exactly the resource given at 'createMeterProvider'. If you run multiple
meter providers, do not merge their exports into one 'ResourceMetricsExport' — keep one
top-level entry per resource when forwarding to an exporter.

Collection is serialized via an internal lock so that concurrent callers (e.g. a periodic
reader and a manual 'forceFlushMeterProvider') do not run observable callbacks twice in
parallel, which would double-count data under delta temporality.
-}
collectResourceMetrics :: (MonadIO m) => SdkMeterEnv -> m [ResourceMetricsExport]
collectResourceMetrics env = liftIO $ withMVar (sdkMeterCollectLock env) $ \_ -> do
  shut <- readIORef (sdkMeterShutdown env)
  if shut
    then pure [ResourceMetricsExport (sdkMeterResource env) V.empty]
    else do
      cbs <- readIORef (sdkMeterCollectCallbacks env)
      mapM_ id (IM.elems cbs)
      instruments <- readIORef (sdkMeterInstruments env)
      t <- nowNanos
      let temp = sdkMeterAggregationTemporality env
          startT = sdkMeterStartTimeNanos env
          isDelta = temp == AggregationDelta
      snapshots <- mapM (snapshotInstrument isDelta) instruments
      let rme = buildResourceExport (sdkMeterResource env) startT t temp snapshots
      pure [rme]
  where
    snapshotInstrument isDelta s
      | isDelta =
          atomicModifyIORef' (instrCells s) $ \cm ->
            let m = cmMap cm
                cm' = CellMap (H.map resetCellForDelta m) (cmSize cm)
            in (cm', (instrDims s, m))
      | otherwise = do
          cells <- readIORef (instrCells s)
          pure (instrDims s, cmMap cells)


buildResourceExport
  :: MaterializedResources
  -> Word64
  -> Word64
  -> AggregationTemporality
  -> [(InstrumentDims, H.HashMap Attributes Cell)]
  -> ResourceMetricsExport
buildResourceExport res startT t temp snapshots =
  let scopeGroups :: H.HashMap InstrumentationLibrary [(InstrumentDims, H.HashMap Attributes Cell)]
      scopeGroups =
        foldl'
          ( \acc (dims, cells) ->
              H.insertWith (++) (dimScope dims) [(dims, cells)] acc
          )
          H.empty
          snapshots
      scopes = V.fromList $ fmap (buildScopeExport startT t temp) $ H.toList scopeGroups
  in ResourceMetricsExport res scopes


buildScopeExport :: Word64 -> Word64 -> AggregationTemporality -> (InstrumentationLibrary, [(InstrumentDims, H.HashMap Attributes Cell)]) -> ScopeMetricsExport
buildScopeExport startT t temp (scope, instruments) =
  let exports = concatMap buildOne instruments
      buildOne (dims, cells) =
        let series = H.foldrWithKey' (\attrs cell acc -> (attrs, cell, dims) : acc) [] cells
        in buildMetricExports startT t temp dims series
  in ScopeMetricsExport scope (V.fromList exports)


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
                    CsSum (SumIntCell v _ exs) ->
                      SumDataPoint
                        { sumDataPointStartTimeUnixNano = startT
                        , sumDataPointTimeUnixNano = t
                        , sumDataPointValue = IntNumber v
                        , sumDataPointAttributes = applyDimAttrs d attrs
                        , sumDataPointExemplars = exs
                        }
                        : acc
                    CsSum (SumDblCell v _ exs) ->
                      SumDataPoint
                        { sumDataPointStartTimeUnixNano = startT
                        , sumDataPointTimeUnixNano = t
                        , sumDataPointValue = DoubleNumber v
                        , sumDataPointAttributes = applyDimAttrs d attrs
                        , sumDataPointExemplars = exs
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
                    CsSum SumIntCell {} -> True
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
                        , histogramDataPointBucketCounts = V.convert (hcBuckets hc)
                        , histogramDataPointExplicitBounds = V.convert (hcBounds hc)
                        , histogramDataPointAttributes = applyDimAttrs d attrs
                        , histogramDataPointMin = toMaybeDouble (hcMin hc)
                        , histogramDataPointMax = toMaybeDouble (hcMax hc)
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
              IntNumber _ -> True
              DoubleNumber _ -> False
            _ -> False
      in [ MetricExportGauge (dimName dims) (dimDescription dims) (dimUnit dims) (dimScope dims) isInt points
         ]


-- | Create an SDK-backed 'MeterProvider' and handle for collection.
createMeterProvider
  :: MaterializedResources
  -> SdkMeterProviderOptions
  -> IO (MeterProvider, SdkMeterEnv)
createMeterProvider res opts = do
  instrReg <- newIORef []
  cbs <- newIORef IM.empty
  nextCbId <- newAtomicCounter 0
  sd <- newIORef False
  collectLk <- newMVar ()
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
          { sdkMeterInstruments = instrReg
          , sdkMeterCollectCallbacks = cbs
          , sdkMeterNextCallbackId = nextCbId
          , sdkMeterResource = res
          , sdkMeterShutdown = sd
          , sdkMeterCollectLock = collectLk
          , sdkMeterCardinalityLimit = lim
          , sdkMeterAggregationTemporality = temp
          , sdkMeterViews = viewsList
          , sdkMeterExemplarOptions = exOpts
          , sdkMeterStartTimeNanos = startT
          }
      mExporter = metricExporter opts
      provider =
        MeterProvider
          { meterProviderGetMeter = \scope -> do
              shut <- readIORef sd
              if shut then pure (noopMeter scope) else pure (mkMeter env scope)
          , meterProviderShutdown = do
              alreadyShut <- atomicModifyIORef' sd $ \s -> (True, s)
              if alreadyShut
                then pure ShutdownSuccess
                else do
                  -- Final collection + export under the lock so no concurrent
                  -- collect can interleave between the last export and the
                  -- clearing of instruments/callbacks.
                  withMVar collectLk $ \_ -> do
                    cbs' <- readIORef cbs
                    mapM_ id (IM.elems cbs')
                    instruments <- readIORef instrReg
                    t <- nowNanos
                    let isDelta = temp == AggregationDelta
                    snapshots <- mapM (snapshotForShutdown isDelta) instruments
                    let rme = buildResourceExport res startT t temp snapshots
                    case mExporter of
                      Just ex -> do
                        _ <- metricExporterExport ex [rme]
                        _ <- metricExporterShutdown ex
                        pure ()
                      Nothing -> pure ()
                    atomicWriteIORef instrReg []
                    atomicWriteIORef cbs IM.empty
                  pure ShutdownSuccess
          , meterProviderForceFlush = \mtimeout -> do
              let timeoutUs = maybe 5000000 id mtimeout
              mResult <- timeout timeoutUs $ do
                batches <- collectResourceMetrics env
                case mExporter of
                  Just ex -> do
                    _ <- metricExporterExport ex batches
                    _ <- metricExporterForceFlush ex
                    pure ()
                  Nothing -> pure ()
              case mResult of
                Nothing -> pure FlushTimeout
                Just () -> pure FlushSuccess
          }
  pure (provider, env)
  where
    snapshotForShutdown isDelta s
      | isDelta =
          atomicModifyIORef' (instrCells s) $ \cm ->
            let m = cmMap cm
                cm' = CellMap (H.map resetCellForDelta m) (cmSize cm)
            in (cm', (instrDims s, m))
      | otherwise = do
          cells <- readIORef (instrCells s)
          pure (instrDims s, cmMap cells)
