{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE StrictData #-}

{- | SDK 'OpenTelemetry.Metric.MeterProvider' with in-process aggregation (specification/metrics/sdk.md).

 Synchronous: cumulative or delta sums, explicit or exponential histograms, last-value gauges;
 exemplars (optional trace context); cardinality limits; views (drop, aggregation, attribute keys).
 Observable callbacks run in registration order. Periodic export: "OpenTelemetry.MetricReader".
-}
module OpenTelemetry.MeterProvider (
  -- * MetricReader
  MetricReader (..),
  cumulativeTemporality,
  deltaTemporality,

  -- * Provider options
  SdkMeterProviderOptions (..),
  defaultSdkMeterProviderOptions,
  SdkMeterExemplarOptions (..),
  defaultSdkMeterExemplarOptions,
  MetricProducer,

  -- * Provider lifecycle
  SdkMeterEnv (..),
  createMeterProvider,
  collectResourceMetrics,
) where

import Control.Concurrent.MVar (MVar, newMVar, withMVar)
import Control.Exception (SomeException, catch)
import Control.Monad (unless, when)
import Control.Monad.IO.Class (MonadIO, liftIO)
import Data.Bits (unsafeShiftR)
import qualified Data.HashMap.Strict as H
import qualified Data.HashSet as HS
import Data.Hashable (Hashable)
import Data.IORef (IORef, atomicModifyIORef', atomicWriteIORef, newIORef, readIORef)
import Data.Int (Int32, Int64)
import qualified Data.IntMap.Strict as IM
import qualified Data.List as L
import Data.Maybe (fromMaybe)
import Data.Text (Text, pack, toLower)
import qualified Data.Text as T
import Data.Vector (Vector)
import qualified Data.Vector as V
import qualified Data.Vector.Unboxed as U
import Data.Word (Word64)
import GHC.Generics (Generic)
import OpenTelemetry.Attributes (Attributes, addAttribute, defaultAttributeLimits, emptyAttributes)
import OpenTelemetry.Common (Timestamp (..))
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
import OpenTelemetry.Internal.AtomicBucketArray (AtomicBucketArray, atomicAddBucket, newAtomicBucketArray, readAndResetBucketArray, readBucketArray)
import OpenTelemetry.Internal.AtomicCounter
import OpenTelemetry.Internal.Common.Types (ExportResult (..), FlushResult (..), InstrumentationLibrary (..), ShutdownResult (..), worstFlush)
import OpenTelemetry.Internal.Logging (otelLogWarning)
import OpenTelemetry.Metric.Core (
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
import qualified OpenTelemetry.Metric.InstrumentName as VName
import OpenTelemetry.Metric.View (MeterScope, View (..), ViewAggregation (..), findAllMatchingViews)
import OpenTelemetry.Resource (MaterializedResources)
import OpenTelemetry.Trace.Core (SpanContext (..), getSpanContext, isSampled, isValid)
import OpenTelemetry.Trace.Id (spanIdBytes, traceIdBytes)
import System.Timeout (timeout)


-- | @since 0.0.1.0
data SdkMeterExemplarOptions = SdkMeterExemplarOptions
  { exemplarFilter :: !MetricsExemplarFilter
  -- ^ Spec default is TraceBased. Configured via OTEL_METRICS_EXEMPLAR_FILTER or explicit option.
  , exemplarReservoirLimit :: !Int
  }


-- | @since 0.0.1.0
defaultSdkMeterExemplarOptions :: SdkMeterExemplarOptions
defaultSdkMeterExemplarOptions =
  SdkMeterExemplarOptions
    { exemplarFilter = MetricsExemplarFilterTraceBased
    , exemplarReservoirLimit = 1
    }


{- | Spec-level metric reader: pairs an exporter with a temporality preference.

Each reader independently collects metrics from the provider.  The temporality
function maps instrument kind to the preferred 'AggregationTemporality'
for that reader's export stream.

@since 0.0.1.0
-}
data MetricReader = MetricReader
  { metricReaderExporter :: !MetricExporter
  , metricReaderTemporalityFor :: !(InstrumentKind -> AggregationTemporality)
  }


{- | All instrument kinds use cumulative temporality.

@since 0.0.1.0
-}
cumulativeTemporality :: InstrumentKind -> AggregationTemporality
cumulativeTemporality _ = AggregationCumulative


{- | Counters and histograms use delta; gauges and UpDownCounters stay cumulative.

UpDownCounter (sync and async) MUST use cumulative temporality per the OTel spec,
since delta values for bidirectional counters lose information about the absolute level.

@since 0.0.1.0
-}
deltaTemporality :: InstrumentKind -> AggregationTemporality
deltaTemporality KindGauge = AggregationCumulative
deltaTemporality KindAsyncGauge = AggregationCumulative
deltaTemporality KindUpDownCounter = AggregationCumulative
deltaTemporality KindAsyncUpDownCounter = AggregationCumulative
deltaTemporality _ = AggregationDelta


{- | External metric source that the provider collects alongside its own
instruments.  Registered producers are invoked during every 'collectResourceMetrics'
call, and their results are appended to the export batch.

Spec: @specification/metrics/sdk.md#metricproducer@

@since 0.0.1.0
-}
type MetricProducer = IO (Vector ResourceMetricsExport)


-- | @since 0.0.1.0
data SdkMeterProviderOptions = SdkMeterProviderOptions
  { cardinalityLimit :: !Int
  , views :: ![View]
  , exemplarOptions :: !SdkMeterExemplarOptions
  , readers :: ![MetricReader]
  , metricProducers :: ![MetricProducer]
  -- ^ External metric sources collected alongside the provider's own instruments.
  }


-- | @since 0.0.1.0
defaultSdkMeterProviderOptions :: SdkMeterProviderOptions
defaultSdkMeterProviderOptions =
  SdkMeterProviderOptions
    { cardinalityLimit = 2000
    , views = []
    , exemplarOptions = defaultSdkMeterExemplarOptions
    , readers = []
    , metricProducers = []
    }


{- | HashMap paired with a cached entry count so cardinality checks are O(1)
instead of O(n) via 'H.size' on every recording.
Each cell is behind its own IORef so recording threads with different
attribute sets never contend on the same CAS.
-}
data CellMap = CellMap
  { cmMap :: !(H.HashMap Attributes (IORef Cell))
  , cmSize :: {-# UNPACK #-} !Int
  }


emptyCellMap :: CellMap
emptyCellMap = CellMap H.empty 0
{-# INLINE emptyCellMap #-}


cmLookup :: Attributes -> CellMap -> Maybe (IORef Cell)
cmLookup k = H.lookup k . cmMap
{-# INLINE cmLookup #-}


-- | Insert a key known to be absent. Avoids the redundant 'H.member' check.
cmInsertNew :: Attributes -> IORef Cell -> CellMap -> CellMap
cmInsertNew k v (CellMap m sz) = CellMap (H.insert k v m) (sz + 1)
{-# INLINE cmInsertNew #-}


{- | Find or create a per-cell IORef for the given attributes.

Hot path (existing key): 'readIORef' + 'H.lookup'. No CAS, no contention
with other attribute sets.

Cold path (new key): allocates an IORef and CAS-inserts into the outer map.
If cardinality exceeds the limit, redirects to the overflow cell.
-}
acquireCell :: IORef CellMap -> Attributes -> Int -> IO Cell -> IO (IORef Cell)
acquireCell outerRef !attrs lim mkInitCell = do
  cm <- readIORef outerRef
  case cmLookup attrs cm of
    Just cellRef -> pure cellRef
    Nothing -> acquireCellCold outerRef attrs lim mkInitCell
{-# INLINE acquireCell #-}


acquireCellCold :: IORef CellMap -> Attributes -> Int -> IO Cell -> IO (IORef Cell)
acquireCellCold outerRef !attrs lim mkInitCell = do
  initCell <- mkInitCell
  cellRef <- newIORef initCell
  atomicModifyIORef' outerRef $ \cm ->
    case cmLookup attrs cm of
      Just existingRef -> (cm, existingRef)
      Nothing
        | lim > 0 && cmSize cm >= lim ->
            case cmLookup overflowAttributes cm of
              Just overflowRef -> (cm, overflowRef)
              Nothing -> (cmInsertNew overflowAttributes cellRef cm, cellRef)
        | otherwise ->
            (cmInsertNew attrs cellRef cm, cellRef)
{-# NOINLINE acquireCellCold #-}


{- | Per-instrument aggregation storage. Each registered instrument owns its own
IORef, eliminating cross-instrument contention on the recording hot path.
-}
data InstrumentStorage = InstrumentStorage
  { instrDims :: !InstrumentDims
  , instrCells :: !(IORef CellMap)
  }


-- | @since 0.0.1.0
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
  , sdkMeterReaders :: ![MetricReader]
  -- ^ Registered readers; used during shutdown and forceFlush.
  , sdkMeterProducers :: ![MetricProducer]
  -- ^ External metric sources invoked during collection.
  , sdkMeterViews :: ![View]
  , sdkMeterExemplarOptions :: !SdkMeterExemplarOptions
  , sdkMeterStartTimeNanos :: !Word64
  , sdkMeterLastCollectTime :: !(IORef Word64)
  -- ^ Tracks the end timestamp of the previous collection cycle.
  -- Used as the start time for delta-temporality data points.
  }


data InstrumentDims = InstrumentDims
  { dimScope :: !InstrumentationLibrary
  , dimName :: !Text
  , dimKind :: !InstrumentKind
  , dimUnit :: !Text
  , dimDescription :: !Text
  , dimHistogramAggregation :: !(Maybe HistogramAggregation)
  , dimExportAttributeKeys :: !(Maybe (HS.HashSet Text))
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (Hashable)


data SumCell
  = SumIntCell
      { siValue :: {-# UNPACK #-} !Int64
      , siMonotonic :: !Bool
      , siExemplars :: !(Vector MetricExemplar)
      , siPrevDelta :: {-# UNPACK #-} !Int64
      -- ^ Last delta-exported value. Used only for async instruments during
      -- delta collection: delta = siValue - siPrevDelta.
      }
  | SumDblCell
      { sdValue :: {-# UNPACK #-} !Double
      , sdMonotonic :: !Bool
      , sdExemplars :: !(Vector MetricExemplar)
      , sdPrevDelta :: {-# UNPACK #-} !Double
      }


data HistCell = HistCell
  { hcBucketArr :: !AtomicBucketArray
  -- ^ Mutable atomic bucket counters; incremented in-place via hardware
  -- fetch-and-add, avoiding the O(n) vector copy that U.modify requires.
  , hcFrozenBuckets :: !(U.Vector Word64)
  -- ^ Immutable snapshot populated during collection for export.
  -- U.empty during recording (never read on the hot path).
  , hcBounds :: !(U.Vector Double)
  , hcSum :: {-# UNPACK #-} !Double
  , hcCount :: {-# UNPACK #-} !Word64
  , hcMin :: !OptionalDouble
  , hcMax :: !OptionalDouble
  , hcBucketExemplars :: !(Vector (Maybe MetricExemplar))
  -- ^ Aligned histogram bucket reservoir: one exemplar slot per bucket.
  -- Indexed by bucket number (same as hcBucketArr).
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
  , ehcPositiveExemplars :: !(IM.IntMap MetricExemplar)
  -- ^ Per-bucket exemplar reservoir for positive buckets.
  , ehcNegativeExemplars :: !(IM.IntMap MetricExemplar)
  -- ^ Per-bucket exemplar reservoir for negative buckets.
  , ehcZeroExemplar :: !(Maybe MetricExemplar)
  -- ^ Exemplar for the zero bucket.
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
{-# INLINE nowNanos #-}


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


emptyHistIO :: U.Vector Double -> IO HistCell
emptyHistIO bounds = do
  let !nBuckets = U.length bounds + 1
  arr <- newAtomicBucketArray nBuckets
  pure
    HistCell
      { hcBucketArr = arr
      , hcFrozenBuckets = U.empty
      , hcBounds = bounds
      , hcSum = 0
      , hcCount = 0
      , hcMin = NoDouble
      , hcMax = NoDouble
      , hcBucketExemplars = V.replicate nBuckets Nothing
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
    , ehcPositiveExemplars = IM.empty
    , ehcNegativeExemplars = IM.empty
    , ehcZeroExemplar = Nothing
    }


-- 1 / ln(2), precomputed to turn logBase into a single multiply per sample.
log2Recip :: Double
log2Recip = 1.4426950408889634
{-# INLINE log2Recip #-}


positiveBucketIndex :: Double -> Int32 -> Int
positiveBucketIndex x sc =
  let !scaleFactor = encodeFloat 1 (fromIntegral sc) :: Double
  in floor (log x * log2Recip * scaleFactor)
{-# INLINE positiveBucketIndex #-}


mergeExpHist :: ExpHistCell -> Double -> ExpHistCell
mergeExpHist ehc v =
  let !sc = ehcScale ehc
      !sm = ehcSum ehc + v
      !ct = ehcCount ehc + 1
      !mn = minOptDouble (ehcMin ehc) v
      !mx = maxOptDouble (ehcMax ehc) v
  in if v == 0
      then
        ehc
          { ehcZeroCount = ehcZeroCount ehc + 1
          , ehcSum = sm
          , ehcCount = ct
          , ehcMin = mn
          , ehcMax = mx
          }
      else
        let !absV = abs v
            !idx = positiveBucketIndex absV sc
        in if v > 0
            then
              ehc
                { ehcPositive = IM.insertWith (+) idx 1 (ehcPositive ehc)
                , ehcSum = sm
                , ehcCount = ct
                , ehcMin = mn
                , ehcMax = mx
                }
            else
              ehc
                { ehcNegative = IM.insertWith (+) idx 1 (ehcNegative ehc)
                , ehcSum = sm
                , ehcCount = ct
                , ehcMin = mn
                , ehcMax = mx
                }
{-# INLINE mergeExpHist #-}


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
      , exponentialHistogramDataPointExemplars =
          V.fromList $
            IM.elems (ehcPositiveExemplars ehc)
              <> IM.elems (ehcNegativeExemplars ehc)
              <> maybe [] (: []) (ehcZeroExemplar ehc)
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


-- | True when a NumberValue holds a non-finite Double (NaN or Inf).
-- Int values are always finite.
isNonFiniteDouble :: NumberValue -> Bool
isNonFiniteDouble (DoubleNumber d) = isNaN d || isInfinite d
isNonFiniteDouble (IntNumber _) = False
{-# INLINE isNonFiniteDouble #-}


validateOrNoop :: Text -> Maybe Text -> IO Bool
validateOrNoop name mUnit =
  case VName.validateInstrumentName name of
    Just err -> do
      otelLogWarning ("Invalid instrument name " <> show name <> ": " <> show err <> "; instrument will be a no-op")
      pure False
    Nothing -> case mUnit of
      Nothing -> pure True
      Just u -> case VName.validateInstrumentUnit u of
        Just err -> do
          otelLogWarning ("Invalid instrument unit " <> show u <> " for " <> show name <> ": " <> show err <> "; instrument will be a no-op")
          pure False
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
    , dimName = toLower name
    , dimKind = kind
    , dimUnit = fromMaybe mempty mUnit
    , dimDescription = fromMaybe mempty mDesc
    , dimHistogramAggregation = mh
    , dimExportAttributeKeys = fmap HS.fromList mKeys
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
  , stExportKeys :: !(Maybe (HS.HashSet Text))
  , stExemplarOpts :: !SdkMeterExemplarOptions
  -- ^ Effective exemplar options for this stream (may differ from the global
  -- provider default when the matching view carries a filter override).
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
      globalExOpts = sdkMeterExemplarOptions env
  case matched of
    [] -> do
      let mEk = advisoryAttributeKeys adv
          dims = dimsFrom sc name kind mUnit mDesc mHistAgg mEk
      ref <- getOrCreateInstrumentStorage env dims
      pure [StreamTarget ref (dimExportAttributeKeys dims) globalExOpts]
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
  vName <- case viewName v of
    Just n -> case VName.validateInstrumentName n of
      Just err -> do
        otelLogWarning ("View name override " <> show n <> " is invalid: " <> show err <> "; using original name " <> show name)
        pure name
      Nothing -> pure n
    Nothing -> pure name
  let vDesc = case viewDescription v of
        Just d -> Just d
        Nothing -> mDesc
      mEk = case viewAttributeKeys v of
        Just ks -> Just ks
        Nothing -> advisoryAttributeKeys adv
      dims = dimsFrom sc vName kind mUnit vDesc mHistAgg mEk
      globalExOpts = sdkMeterExemplarOptions env
      effectiveExOpts = case viewExemplarFilter v of
        Just f -> globalExOpts {exemplarFilter = f}
        Nothing -> globalExOpts
  ref <- getOrCreateInstrumentStorage env dims
  pure (StreamTarget ref (dimExportAttributeKeys dims) effectiveExOpts)


fromAdvisoryHistogram :: AdvisoryParameters -> HistogramAggregation
fromAdvisoryHistogram a = case advisoryHistogramAggregation a of
  Just h -> h
  Nothing -> case advisoryExplicitBucketBoundaries a of
    Just bs -> HistogramAggregationExplicit (V.fromList (L.sort bs))
    Nothing -> HistogramAggregationExplicit (V.convert defaultHistogramBounds)


pushExemplar :: Int -> MetricExemplar -> Vector MetricExemplar -> Vector MetricExemplar
pushExemplar cap e v
  | cap <= 0 = V.empty
  | cap == 1 = V.singleton e
  | V.length v < cap = V.snoc v e
  | otherwise = V.generate cap (\i -> if i < cap - 1 then V.unsafeIndex v (i + 1) else e)
{-# INLINE pushExemplar #-}


captureMetricExemplar
  :: SdkMeterExemplarOptions
  -> Maybe NumberValue
  -> Attributes
  -- ^ Full measurement attributes (used to compute filtered attributes)
  -> Maybe (HS.HashSet Text)
  -- ^ Export attribute keys from view; attributes NOT in this set are carried as filtered
  -> IO (Maybe MetricExemplar)
captureMetricExemplar !opts mVal !measureAttrs mExportKeys
  | exemplarReservoirLimit opts <= 0 = pure Nothing
  | otherwise = case exemplarFilter opts of
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
      let !tid = traceIdBytes (traceId scx)
          !sid = spanIdBytes (spanId scx)
      pure $!
        Just $!
          MetricExemplar
            { metricExemplarTraceId = tid
            , metricExemplarSpanId = sid
            , metricExemplarTimeUnixNano = t
            , metricExemplarFilteredAttributes = filteredAttrs
            , metricExemplarValue = mVal
            }
    makeExemplarNoTrace = do
      t <- nowNanos
      pure $!
        Just $!
          MetricExemplar
            { metricExemplarTraceId = mempty
            , metricExemplarSpanId = mempty
            , metricExemplarTimeUnixNano = t
            , metricExemplarFilteredAttributes = filteredAttrs
            , metricExemplarValue = mVal
            }
{-# INLINE captureMetricExemplar #-}


addSumI64
  :: Int64
  -> Bool
  -> Maybe NumberValue
  -> Attributes
  -> IORef CellMap
  -> Int
  -> SdkMeterExemplarOptions
  -> Maybe (HS.HashSet Text)
  -> IO ()
addSumI64 !delta !isMonotonic mExVal !attrs ref lim exOpts mExportKeys =
  unless (isMonotonic && delta < 0) $ do
    mex <- captureMetricExemplar exOpts mExVal attrs mExportKeys
    let !cap = exemplarReservoirLimit exOpts
    cellRef <- acquireCell ref attrs lim (pure $! CsSum $! SumIntCell 0 isMonotonic V.empty 0)
    atomicModifyIORef' cellRef $ \cell ->
      let !cell' = case cell of
            CsSum (SumIntCell v mon exs prev) ->
              CsSum $!
                SumIntCell
                  { siValue = v + delta
                  , siMonotonic = mon
                  , siExemplars = case mex of
                      Nothing -> exs
                      Just e -> pushExemplar cap e exs
                  , siPrevDelta = prev
                  }
            _ ->
              CsSum $!
                SumIntCell delta isMonotonic (maybe V.empty (\e -> pushExemplar cap e V.empty) mex) 0
      in (cell', ())
{-# INLINE addSumI64 #-}


addSumDbl
  :: Double
  -> Bool
  -> Maybe NumberValue
  -> Attributes
  -> IORef CellMap
  -> Int
  -> SdkMeterExemplarOptions
  -> Maybe (HS.HashSet Text)
  -> IO ()
addSumDbl !delta !isMonotonic mExVal !attrs ref lim exOpts mExportKeys =
  -- Spec: NaN and Inf measurements MUST be silently dropped.
  -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/
  unless (isNaN delta || isInfinite delta || (isMonotonic && delta < 0)) $ do
    mex <- captureMetricExemplar exOpts mExVal attrs mExportKeys
    let !cap = exemplarReservoirLimit exOpts
    cellRef <- acquireCell ref attrs lim (pure $! CsSum $! SumDblCell 0 isMonotonic V.empty 0)
    atomicModifyIORef' cellRef $ \cell ->
      let !cell' = case cell of
            CsSum (SumDblCell v mon exs prev) ->
              CsSum $!
                SumDblCell
                  { sdValue = v + delta
                  , sdMonotonic = mon
                  , sdExemplars = case mex of
                      Nothing -> exs
                      Just e -> pushExemplar cap e exs
                  , sdPrevDelta = prev
                  }
            _ ->
              CsSum $!
                SumDblCell delta isMonotonic (maybe V.empty (\e -> pushExemplar cap e V.empty) mex) 0
      in (cell', ())
{-# INLINE addSumDbl #-}


{- | Set (replace) the cumulative value for an async counter/updowncounter.
Unlike 'addSumI64' which accumulates, this stores the absolute total
reported by the observable callback.
-}
setSumI64
  :: Int64
  -> Bool
  -> Maybe NumberValue
  -> Attributes
  -> IORef CellMap
  -> Int
  -> SdkMeterExemplarOptions
  -> Maybe (HS.HashSet Text)
  -> IO ()
setSumI64 !val !isMonotonic mExVal !attrs ref lim exOpts mExportKeys = do
  mex <- captureMetricExemplar exOpts mExVal attrs mExportKeys
  let !cap = exemplarReservoirLimit exOpts
  cellRef <- acquireCell ref attrs lim (pure $! CsSum $! SumIntCell val isMonotonic V.empty 0)
  atomicModifyIORef' cellRef $ \cell ->
    let !cell' = case cell of
          CsSum (SumIntCell _ mon exs prev) ->
            CsSum $!
              SumIntCell val mon (case mex of Nothing -> exs; Just e -> pushExemplar cap e exs) prev
          _ ->
            CsSum $!
              SumIntCell val isMonotonic (maybe V.empty (\e -> pushExemplar cap e V.empty) mex) 0
    in (cell', ())
{-# INLINE setSumI64 #-}


setSumDbl
  :: Double
  -> Bool
  -> Maybe NumberValue
  -> Attributes
  -> IORef CellMap
  -> Int
  -> SdkMeterExemplarOptions
  -> Maybe (HS.HashSet Text)
  -> IO ()
setSumDbl !val !isMonotonic mExVal !attrs ref lim exOpts mExportKeys =
  -- Spec: NaN and Inf measurements MUST be silently dropped.
  -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/
  unless (isNaN val || isInfinite val) $ do
  mex <- captureMetricExemplar exOpts mExVal attrs mExportKeys
  let !cap = exemplarReservoirLimit exOpts
  cellRef <- acquireCell ref attrs lim (pure $! CsSum $! SumDblCell val isMonotonic V.empty 0)
  atomicModifyIORef' cellRef $ \cell ->
    let !cell' = case cell of
          CsSum (SumDblCell _ mon exs prev) ->
            CsSum $!
              SumDblCell val mon (case mex of Nothing -> exs; Just e -> pushExemplar cap e exs) prev
          _ ->
            CsSum $!
              SumDblCell val isMonotonic (maybe V.empty (\e -> pushExemplar cap e V.empty) mex) 0
    in (cell', ())
{-# INLINE setSumDbl #-}


recordHist
  :: U.Vector Double
  -> Double
  -> Maybe Double
  -> Attributes
  -> IORef CellMap
  -> Int
  -> SdkMeterExemplarOptions
  -> Maybe (HS.HashSet Text)
  -> IO ()
recordHist !bounds !v mExVal !attrs ref lim exOpts mExportKeys = do
  unless (isNaN v || isInfinite v || v < 0) $ do
    mex <- captureMetricExemplar exOpts (DoubleNumber <$> mExVal) attrs mExportKeys
    let !idx = bucketIndex bounds v
    cellRef <- acquireCell ref attrs lim (CsHist <$> emptyHistIO bounds)
    -- Atomic in-place bucket increment: single ldadd/lock-xadd, zero allocation
    cell <- readIORef cellRef
    case cell of
      CsHist hc -> atomicAddBucket (hcBucketArr hc) idx
      _ -> pure ()
    -- CAS update scalars + aligned bucket exemplar (no bucket vector copy)
    atomicModifyIORef' cellRef $ \cell' ->
      let !cell'' = case cell' of
            CsHist hc ->
              CsHist $!
                ( case mex of
                    Nothing -> hc
                    Just e -> hc {hcBucketExemplars = hcBucketExemplars hc V.// [(idx, Just e)]}
                )
                  { hcSum = hcSum hc + v
                  , hcCount = hcCount hc + 1
                  , hcMin = minOptDouble (hcMin hc) v
                  , hcMax = maxOptDouble (hcMax hc) v
                  }
            _ -> cell'
      in (cell'', ())
{-# INLINE recordHist #-}


recordExpHist
  :: Int32
  -> Double
  -> Maybe Double
  -> Attributes
  -> IORef CellMap
  -> Int
  -> SdkMeterExemplarOptions
  -> Maybe (HS.HashSet Text)
  -> IO ()
recordExpHist !sc !v mExVal !attrs ref lim exOpts mExportKeys =
  unless (isNaN v || isInfinite v || v < 0) $ do
    mex <- captureMetricExemplar exOpts (fmap DoubleNumber mExVal) attrs mExportKeys
    cellRef <- acquireCell ref attrs lim (pure $! CsExpHist (emptyExpHist sc))
    atomicModifyIORef' cellRef $ \cell ->
      let placeExemplar ehc = case mex of
            Nothing -> ehc
            Just e
              | v == 0 -> ehc {ehcZeroExemplar = Just e}
              | v > 0 ->
                  let !idx = positiveBucketIndex v (ehcScale ehc)
                  in ehc {ehcPositiveExemplars = IM.insert idx e (ehcPositiveExemplars ehc)}
              | otherwise -> ehc
          !cell' = case cell of
            CsExpHist ehc -> CsExpHist $! placeExemplar (mergeExpHist ehc v)
            _ -> CsExpHist $! placeExemplar (mergeExpHist (emptyExpHist sc) v)
      in (cell', ())


recordGauge
  :: NumberValue
  -> Word64
  -> Maybe NumberValue
  -> Attributes
  -> IORef CellMap
  -> Int
  -> SdkMeterExemplarOptions
  -> Maybe (HS.HashSet Text)
  -> IO ()
recordGauge !val !t mExVal !attrs ref lim exOpts mExportKeys =
  -- Spec: NaN and Inf double measurements MUST be silently dropped.
  -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/
  unless (isNonFiniteDouble val) $ do
  mex <- captureMetricExemplar exOpts mExVal attrs mExportKeys
  let !cap = exemplarReservoirLimit exOpts
      initGauge =
        pure $!
          CsGauge
            GaugeCell
              { gcValue = val
              , gcTimeUnixNano = t
              , gcExemplars = V.empty
              }
  cellRef <- acquireCell ref attrs lim initGauge
  atomicModifyIORef' cellRef $ \cell ->
    let !cell' = case cell of
          CsGauge gc ->
            CsGauge $! case mex of
              Nothing -> gc {gcValue = val, gcTimeUnixNano = t}
              Just e ->
                gc
                  { gcValue = val
                  , gcTimeUnixNano = t
                  , gcExemplars = pushExemplar cap e (gcExemplars gc)
                  }
          _ ->
            CsGauge
              GaugeCell
                { gcValue = val
                , gcTimeUnixNano = t
                , gcExemplars = maybe V.empty (\e -> pushExemplar cap e V.empty) mex
                }
    in (cell', ())


{- | Compute delta for an async instrument's cell.

Returns (updated cell with new prev, export cell with delta value).
The stored cell retains the cumulative value (never reset) with prev advanced.
The export cell has the delta (current - prev) as its value.
-}
snapshotAsyncForDelta :: Cell -> (Cell, Cell)
snapshotAsyncForDelta = \case
  CsSum (SumIntCell v mon exs prev) ->
    let !d = v - prev
    in (CsSum (SumIntCell v mon V.empty v), CsSum (SumIntCell d mon exs prev))
  CsSum (SumDblCell v mon exs prev) ->
    let !d = v - prev
    in (CsSum (SumDblCell v mon V.empty v), CsSum (SumDblCell d mon exs prev))
  other ->
    (resetCellForDelta other, other)


{- | Reset a sync instrument's cell for delta export.
Zeros the value and clears exemplars; prev is unused for sync cells.
-}
resetCellForDelta :: Cell -> Cell
resetCellForDelta = \case
  CsSum (SumIntCell _ mon _ _) ->
    CsSum (SumIntCell 0 mon V.empty 0)
  CsSum (SumDblCell _ mon _ _) ->
    CsSum (SumDblCell 0 mon V.empty 0)
  CsHist hc ->
    CsHist $!
      hc
        { hcFrozenBuckets = U.empty
        , hcSum = 0
        , hcCount = 0
        , hcMin = NoDouble
        , hcMax = NoDouble
        , hcBucketExemplars = V.replicate (V.length (hcBucketExemplars hc)) Nothing
        }
  CsExpHist ehc ->
    CsExpHist (emptyExpHist (ehcScale ehc))
  CsGauge gc ->
    CsGauge gc


{- | Read mutable histogram bucket array into the frozen snapshot field.
For delta, also atomically resets each bucket to zero.
Non-histogram cells pass through unchanged.
-}
freezeHistBuckets :: Bool -> Cell -> IO Cell
freezeHistBuckets isDelta (CsHist hc) = do
  buckets <-
    if isDelta
      then readAndResetBucketArray (hcBucketArr hc)
      else readBucketArray (hcBucketArr hc)
  pure $! CsHist $! hc {hcFrozenBuckets = buckets}
freezeHistBuckets _ c = pure c
{-# INLINE freezeHistBuckets #-}


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
      case findConflict dims xs of
        Just existing ->
          otelLogWarning $
            "Instrument '"
              <> T.unpack (dimName dims)
              <> "' registered with conflicting metadata"
              <> " (existing: kind="
              <> show (dimKind existing)
              <> " unit="
              <> T.unpack (dimUnit existing)
              <> " desc="
              <> T.unpack (dimDescription existing)
              <> ", new: kind="
              <> show (dimKind dims)
              <> " unit="
              <> T.unpack (dimUnit dims)
              <> " desc="
              <> T.unpack (dimDescription dims)
              <> ")"
        Nothing -> pure ()
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

    findConflict d = go
      where
        go [] = Nothing
        go (s : rest)
          | let sd = instrDims s
          , dimName sd == dimName d
          , dimScope sd == dimScope d
          , sd /= d =
              Just sd
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
                      mapM_ (\st -> addSumI64 n mono (Just (IntNumber n)) attrs (stRef st) lim (stExemplarOpts st) (stExportKeys st)) streams
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
                      mapM_ (\st -> addSumDbl v mono (Just (DoubleNumber v)) attrs (stRef st) lim (stExemplarOpts st) (stExportKeys st)) streams
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
                      mapM_ (\st -> addSumI64 n False (Just (IntNumber n)) attrs (stRef st) lim (stExemplarOpts st) (stExportKeys st)) streams
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
                      mapM_ (\st -> addSumDbl v False (Just (DoubleNumber v)) attrs (stRef st) lim (stExemplarOpts st) (stExportKeys st)) streams
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
                  pure [mkHistRecorder agg ref lim exOpts (dimExportAttributeKeys dims)]
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

    mkHistRecorder :: HistogramAggregation -> IORef CellMap -> Int -> SdkMeterExemplarOptions -> Maybe (HS.HashSet Text) -> (Double -> Attributes -> IO ())
    mkHistRecorder (HistogramAggregationExplicit bounds) ref lim' eOpts mEk =
      let !ubounds = U.convert bounds
      in \v attrs -> recordHist ubounds v (Just v) attrs ref lim' eOpts mEk
    mkHistRecorder (HistogramAggregationExponential scale) ref lim' eOpts mEk =
      \v attrs -> recordExpHist scale v (Just v) attrs ref lim' eOpts mEk

    mkHistRecorderForView
      :: SdkMeterEnv -> InstrumentationLibrary -> Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> MeterScope -> Int -> View -> IO [Double -> Attributes -> IO ()]
    mkHistRecorderForView e sc name mUnit mDesc adv _mScope lim' v = do
      let vAgg = viewAggregation v
          agg = case vAgg of
            ViewAggregationExplicitBucketHistogram bs -> Right (HistogramAggregationExplicit (V.fromList (L.sort bs)))
            ViewAggregationExponentialHistogram sc' -> Right (HistogramAggregationExponential sc')
            ViewAggregationDefault -> Right (fromAdvisoryHistogram adv)
            ViewAggregationSum -> Right (fromAdvisoryHistogram adv)
            ViewAggregationLastValue -> Right (fromAdvisoryHistogram adv)
            ViewAggregationDrop -> Left ()
          effectiveExOpts = case viewExemplarFilter v of
            Just f -> exOpts {exemplarFilter = f}
            Nothing -> exOpts
      case agg of
        Left () -> pure []
        Right a -> do
          vName <- case viewName v of
            Just n -> case VName.validateInstrumentName n of
              Just err -> do
                otelLogWarning ("View name override " <> show n <> " is invalid: " <> show err <> "; using original name " <> show name)
                pure name
              Nothing -> pure n
            Nothing -> pure name
          let mEk = case viewAttributeKeys v of
                Just ks -> Just ks
                Nothing -> advisoryAttributeKeys adv
              vDesc = case viewDescription v of
                Just d -> Just d
                Nothing -> mDesc
              dims = dimsFrom sc vName KindHistogram mUnit vDesc (Just a) mEk
          ref <- getOrCreateInstrumentStorage e dims
          pure [mkHistRecorder a ref lim' effectiveExOpts (dimExportAttributeKeys dims)]

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
                      !t <- nowNanos
                      let !nv = IntNumber n
                      mapM_ (\st -> recordGauge nv t (Just nv) attrs (stRef st) lim (stExemplarOpts st) (stExportKeys st)) streams
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
                      !t <- nowNanos
                      let !nv = DoubleNumber v
                      mapM_ (\st -> recordGauge nv t (Just nv) attrs (stRef st) lim (stExemplarOpts st) (stExportKeys st)) streams
                  , gaugeEnabled = pure True
                  }
            else pure $ Gauge (\_ _ -> pure ()) (pure False)

    ignoreCallbackException :: IO () -> IO ()
    ignoreCallbackException a = a `catch` handler
      where
        handler :: SomeException -> IO ()
        handler ex = otelLogWarning ("Observable callback failed: " <> show ex)

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
          let mkRes _ = ObservableResult $ \n attrs ->
                unless (n < 0) $
                  mapM_ (\st -> setSumI64 n True (Just (IntNumber n)) attrs (stRef st) lim (stExemplarOpts st) (stExportKeys st)) streams
              run = do
                t <- nowNanos
                let res = mkRes t
                mapM_ (\cb -> ignoreCallbackException (cb res)) cbs
          _ <- registerCollect run
          en <- obsEnabled KindAsyncCounter name mUnit mScope
          pure $
            ObservableCounter
              { observableCounterRegisterCallback = \cb -> do
                  unregister <- registerCollect $ do
                    t <- nowNanos
                    cb (mkRes t)
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
          let mkRes _ = ObservableResult $ \v attrs ->
                unless (v < 0) $
                  mapM_ (\st -> setSumDbl v True (Just (DoubleNumber v)) attrs (stRef st) lim (stExemplarOpts st) (stExportKeys st)) streams
              run = do
                t <- nowNanos
                let res = mkRes t
                mapM_ (\cb -> ignoreCallbackException (cb res)) cbs
          _ <- registerCollect run
          en <- obsEnabled KindAsyncCounter name mUnit mScope
          pure $
            ObservableCounter
              { observableCounterRegisterCallback = \cb -> do
                  unregister <- registerCollect $ do
                    t <- nowNanos
                    cb (mkRes t)
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
          let mkRes _ = ObservableResult $ \n attrs ->
                mapM_ (\st -> setSumI64 n False (Just (IntNumber n)) attrs (stRef st) lim (stExemplarOpts st) (stExportKeys st)) streams
              run = do
                t <- nowNanos
                let res = mkRes t
                mapM_ (\cb -> ignoreCallbackException (cb res)) cbs
          _ <- registerCollect run
          en <- obsEnabled KindAsyncUpDownCounter name mUnit mScope
          pure $
            ObservableUpDownCounter
              { observableUpDownCounterRegisterCallback = \cb -> do
                  unregister <- registerCollect $ do
                    t <- nowNanos
                    cb (mkRes t)
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
          let mkRes _ = ObservableResult $ \v attrs ->
                mapM_ (\st -> setSumDbl v False (Just (DoubleNumber v)) attrs (stRef st) lim (stExemplarOpts st) (stExportKeys st)) streams
              run = do
                t <- nowNanos
                let res = mkRes t
                mapM_ (\cb -> ignoreCallbackException (cb res)) cbs
          _ <- registerCollect run
          en <- obsEnabled KindAsyncUpDownCounter name mUnit mScope
          pure $
            ObservableUpDownCounter
              { observableUpDownCounterRegisterCallback = \cb -> do
                  unregister <- registerCollect $ do
                    t <- nowNanos
                    cb (mkRes t)
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
          let mkRes t = ObservableResult $ \n attrs ->
                mapM_ (\st -> recordGauge (IntNumber n) t (Just (IntNumber n)) attrs (stRef st) lim (stExemplarOpts st) (stExportKeys st)) streams
              run = do
                t <- nowNanos
                let res = mkRes t
                mapM_ (\cb -> ignoreCallbackException (cb res)) cbs
          _ <- registerCollect run
          en <- obsEnabled KindAsyncGauge name mUnit mScope
          pure $
            ObservableGauge
              { observableGaugeRegisterCallback = \cb -> do
                  unregister <- registerCollect $ do
                    t <- nowNanos
                    cb (mkRes t)
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
          let mkRes t = ObservableResult $ \v attrs ->
                mapM_ (\st -> recordGauge (DoubleNumber v) t (Just (DoubleNumber v)) attrs (stRef st) lim (stExemplarOpts st) (stExportKeys st)) streams
              run = do
                t <- nowNanos
                let res = mkRes t
                mapM_ (\cb -> ignoreCallbackException (cb res)) cbs
          _ <- registerCollect run
          en <- obsEnabled KindAsyncGauge name mUnit mScope
          pure $
            ObservableGauge
              { observableGaugeRegisterCallback = \cb -> do
                  unregister <- registerCollect $ do
                    t <- nowNanos
                    cb (mkRes t)
                  pure (ObservableCallbackHandle unregister)
              , observableGaugeInstrumentScope = sc
              , observableGaugeInstrumentName = name
              , observableGaugeEnabled = pure en
              }


{- | Build export batches from current in-memory aggregates (invoke observable callbacks first).

Each batch has exactly the resource given at 'createMeterProvider'. If you run multiple
meter providers, do not merge their exports into one 'ResourceMetricsExport'; keep one
top-level entry per resource when forwarding to an exporter.

Collection is serialized via an internal lock so that concurrent callers (e.g. a periodic
reader and a manual 'forceFlushMeterProvider') do not run observable callbacks twice in
parallel, which would double-count data under delta temporality.
-}

{- | Collect metrics using the given temporality preference.

For backward compatibility and single-reader use, call with @const AggregationCumulative@
or @const AggregationDelta@.  For multi-reader setups, each reader passes its own
'metricReaderTemporalityFor'.

@since 0.0.1.0
-}
collectResourceMetrics :: (MonadIO m) => SdkMeterEnv -> (InstrumentKind -> AggregationTemporality) -> m (Vector ResourceMetricsExport)
collectResourceMetrics env tempFor = liftIO $ withMVar (sdkMeterCollectLock env) $ \_ -> do
  shut <- readIORef (sdkMeterShutdown env)
  if shut
    then pure (V.singleton (ResourceMetricsExport (sdkMeterResource env) V.empty))
    else do
      cbs <- readIORef (sdkMeterCollectCallbacks env)
      IM.foldr' (\cb rest -> cb >> rest) (pure ()) cbs
      instruments <- readIORef (sdkMeterInstruments env)
      t <- nowNanos
      prevCollect <- readIORef (sdkMeterLastCollectTime env)
      atomicWriteIORef (sdkMeterLastCollectTime env) t
      let processStart = sdkMeterStartTimeNanos env
      snapshots <- mapM (snapshotInstrument tempFor) instruments
      let rme = buildResourceExport (sdkMeterResource env) processStart prevCollect t tempFor snapshots
      producerVecs <- mapM (\p -> p `catch` (\(ex :: SomeException) -> otelLogWarning ("MetricProducer failed: " <> show ex) >> pure V.empty)) (sdkMeterProducers env)
      pure (V.cons rme (V.concat producerVecs))
  where
    snapshotInstrument tf s = do
      let kind = dimKind (instrDims s)
          isDelta = tf kind == AggregationDelta
          isAsync = case kind of
            KindAsyncCounter -> True
            KindAsyncUpDownCounter -> True
            KindAsyncGauge -> True
            _ -> False
      cm <- readIORef (instrCells s)
      rawSnap <-
        if isDelta
          then
            if isAsync
              then traverse (\cellRef -> atomicModifyIORef' cellRef snapshotAsyncForDelta) (cmMap cm)
              else traverse (\cellRef -> atomicModifyIORef' cellRef $ \c -> (resetCellForDelta c, c)) (cmMap cm)
          else traverse readIORef (cmMap cm)
      snapped <- traverse (freezeHistBuckets isDelta) rawSnap
      pure (instrDims s, snapped)


buildResourceExport
  :: MaterializedResources
  -> Word64
  -- ^ Process start time (for cumulative)
  -> Word64
  -- ^ Previous collection time (for delta start)
  -> Word64
  -- ^ Current collection time
  -> (InstrumentKind -> AggregationTemporality)
  -> [(InstrumentDims, H.HashMap Attributes Cell)]
  -> ResourceMetricsExport
buildResourceExport res processStart deltaStart t tempFor snapshots =
  let scopeGroups :: H.HashMap InstrumentationLibrary (Vector (InstrumentDims, H.HashMap Attributes Cell))
      scopeGroups =
        fmap V.fromList $
          foldl'
            ( \acc (dims, cells) ->
                H.insertWith (++) (dimScope dims) [(dims, cells)] acc
            )
            H.empty
            snapshots
      scopes =
        V.fromListN (H.size scopeGroups) $
          fmap (buildScopeExport processStart deltaStart t tempFor) $
            H.toList scopeGroups
  in ResourceMetricsExport res scopes


buildScopeExport :: Word64 -> Word64 -> Word64 -> (InstrumentKind -> AggregationTemporality) -> (InstrumentationLibrary, Vector (InstrumentDims, H.HashMap Attributes Cell)) -> ScopeMetricsExport
buildScopeExport processStart deltaStart t tempFor (scope, instruments) =
  let exports =
        V.map
          ( \(dims, cells) ->
              let temp = tempFor (dimKind dims)
                  startT = if temp == AggregationDelta then deltaStart else processStart
              in buildMetricExport startT t temp dims cells
          )
          instruments
  in ScopeMetricsExport scope exports


applyDimAttrs :: InstrumentDims -> Attributes -> Attributes
applyDimAttrs dims attrs = filterAttributesByKeys (dimExportAttributeKeys dims) attrs


buildMetricExport
  :: Word64
  -> Word64
  -> AggregationTemporality
  -> InstrumentDims
  -> H.HashMap Attributes Cell
  -> MetricExport
buildMetricExport startT t temp dims cells =
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
    !n = H.size cells

    sumExport mon =
      let (isInt, points) =
            H.foldlWithKey'
              ( \(!iI, !acc) attrs cell -> case cell of
                  CsSum (SumIntCell v _ exs _) ->
                    ( True
                    , SumDataPoint
                        { sumDataPointStartTimeUnixNano = startT
                        , sumDataPointTimeUnixNano = t
                        , sumDataPointValue = IntNumber v
                        , sumDataPointAttributes = applyDimAttrs dims attrs
                        , sumDataPointExemplars = exs
                        }
                        : acc
                    )
                  CsSum (SumDblCell v _ exs _) ->
                    ( iI
                    , SumDataPoint
                        { sumDataPointStartTimeUnixNano = startT
                        , sumDataPointTimeUnixNano = t
                        , sumDataPointValue = DoubleNumber v
                        , sumDataPointAttributes = applyDimAttrs dims attrs
                        , sumDataPointExemplars = exs
                        }
                        : acc
                    )
                  _ -> (iI, acc)
              )
              (False, [])
              cells
      in MetricExportSum (dimName dims) (dimDescription dims) (dimUnit dims) (dimScope dims) mon isInt temp (V.fromListN n points)

    histExport =
      let points =
            H.foldlWithKey'
              ( \acc attrs cell -> case cell of
                  CsHist hc ->
                    HistogramDataPoint
                      { histogramDataPointStartTimeUnixNano = startT
                      , histogramDataPointTimeUnixNano = t
                      , histogramDataPointCount = hcCount hc
                      , histogramDataPointSum = hcSum hc
                      , histogramDataPointBucketCounts = V.convert (hcFrozenBuckets hc)
                      , histogramDataPointExplicitBounds = V.convert (hcBounds hc)
                      , histogramDataPointAttributes = applyDimAttrs dims attrs
                      , histogramDataPointMin = toMaybeDouble (hcMin hc)
                      , histogramDataPointMax = toMaybeDouble (hcMax hc)
                      , histogramDataPointExemplars = V.mapMaybe id (hcBucketExemplars hc)
                      }
                      : acc
                  _ -> acc
              )
              []
              cells
      in MetricExportHistogram (dimName dims) (dimDescription dims) (dimUnit dims) (dimScope dims) temp (V.fromListN n points)

    expHistExport =
      let points =
            H.foldlWithKey'
              ( \acc attrs cell -> case cell of
                  CsExpHist ehc ->
                    expHistToDataPoint startT t (applyDimAttrs dims attrs) ehc : acc
                  _ -> acc
              )
              []
              cells
      in MetricExportExponentialHistogram (dimName dims) (dimDescription dims) (dimUnit dims) (dimScope dims) temp (V.fromListN n points)

    gaugeExport _isAsync =
      let (isInt, points) =
            H.foldlWithKey'
              ( \(!iI, !acc) attrs cell -> case cell of
                  CsGauge gc ->
                    let intCheck = case gcValue gc of
                          IntNumber _ -> True
                          DoubleNumber _ -> iI
                    in ( intCheck
                       , GaugeDataPoint
                          { gaugeDataPointStartTimeUnixNano = startT
                          , gaugeDataPointTimeUnixNano = gcTimeUnixNano gc
                          , gaugeDataPointValue = gcValue gc
                          , gaugeDataPointAttributes = applyDimAttrs dims attrs
                          , gaugeDataPointExemplars = gcExemplars gc
                          }
                          : acc
                       )
                  _ -> (iI, acc)
              )
              (False, [])
              cells
      in MetricExportGauge (dimName dims) (dimDescription dims) (dimUnit dims) (dimScope dims) isInt (V.fromListN n points)


{- | Create an SDK-backed 'MeterProvider' and handle for collection.

@since 0.0.1.0
-}
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
  lastCollect <- newIORef startT
  meterCache <- newIORef (H.empty :: H.HashMap InstrumentationLibrary Meter)
  envFilter <- lookupMetricsExemplarFilter
  let lim = cardinalityLimit opts
      rdrs = readers opts
      prods = metricProducers opts
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
          , sdkMeterReaders = rdrs
          , sdkMeterProducers = prods
          , sdkMeterViews = viewsList
          , sdkMeterExemplarOptions = exOpts
          , sdkMeterStartTimeNanos = startT
          , sdkMeterLastCollectTime = lastCollect
          }
      provider =
        MeterProvider
          { meterProviderGetMeter = \scope -> do
              shut <- readIORef sd
              if shut
                then pure (noopMeter scope)
                else do
                  cache <- readIORef meterCache
                  case H.lookup scope cache of
                    Just m -> pure m
                    Nothing -> do
                      when (T.null (libraryName scope)) $
                        otelLogWarning "Meter created with empty name; returning working Meter with empty name per spec"
                      let !m = mkMeter env scope
                      atomicModifyIORef' meterCache $ \c ->
                        case H.lookup scope c of
                          Just existing -> (c, existing)
                          Nothing -> (H.insert scope m c, m)
          , meterProviderShutdown = do
              alreadyShut <- atomicModifyIORef' sd $ \s -> (True, s)
              if alreadyShut
                then pure ShutdownFailure
                else do
                  results <-
                    withMVar collectLk $ \_ -> do
                      cbs' <- readIORef cbs
                      mapM_ id (IM.elems cbs')
                      instruments <- readIORef instrReg
                      t <- nowNanos
                      prevCollect <- readIORef lastCollect
                      rs <- mapM (shutdownReader startT prevCollect instruments t) rdrs
                      atomicWriteIORef instrReg []
                      atomicWriteIORef cbs IM.empty
                      pure rs
                  pure (foldl worstShutdown ShutdownSuccess results)
          , meterProviderForceFlush = \mtimeout -> do
              shut <- readIORef sd
              if shut
                then pure FlushSuccess
                else do
                  let timeoutUs = maybe 5000000 id mtimeout
                  mResult <-
                    timeout timeoutUs $ do
                      frs <- mapM (flushReader env) rdrs
                      pure (foldl worstFlush FlushSuccess frs)
                  case mResult of
                    Nothing -> pure FlushTimeout
                    Just fr -> pure fr
          }
  pure (provider, env)
  where
    worstShutdown :: ShutdownResult -> ShutdownResult -> ShutdownResult
    worstShutdown ShutdownFailure _ = ShutdownFailure
    worstShutdown _ ShutdownFailure = ShutdownFailure
    worstShutdown ShutdownTimeout _ = ShutdownTimeout
    worstShutdown _ ShutdownTimeout = ShutdownTimeout
    worstShutdown ShutdownSuccess ShutdownSuccess = ShutdownSuccess

    exportResultToShutdown :: ExportResult -> ShutdownResult
    exportResultToShutdown Success = ShutdownSuccess
    exportResultToShutdown (Failure _) = ShutdownFailure

    exportResultToFlush :: ExportResult -> FlushResult
    exportResultToFlush Success = FlushSuccess
    exportResultToFlush (Failure _) = FlushError

    shutdownReader sT prevCollect instruments t rdr = do
      let tempFor = metricReaderTemporalityFor rdr
      snapshots <- mapM (snapshotForShutdown tempFor) instruments
      let rme = buildResourceExport res sT prevCollect t tempFor snapshots
      exportRes <- metricExporterExport (metricReaderExporter rdr) (V.singleton rme)
      shutRes <- metricExporterShutdown (metricReaderExporter rdr)
      pure (worstShutdown (exportResultToShutdown exportRes) shutRes)

    snapshotForShutdown tempFor s = do
      let kind = dimKind (instrDims s)
          isDelta = tempFor kind == AggregationDelta
          isAsync = case kind of
            KindAsyncCounter -> True
            KindAsyncUpDownCounter -> True
            KindAsyncGauge -> True
            _ -> False
      cm <- readIORef (instrCells s)
      rawSnap <-
        if isDelta
          then
            if isAsync
              then traverse (\cellRef -> atomicModifyIORef' cellRef snapshotAsyncForDelta) (cmMap cm)
              else traverse (\cellRef -> atomicModifyIORef' cellRef $ \c -> (resetCellForDelta c, c)) (cmMap cm)
          else traverse readIORef (cmMap cm)
      snapped <- traverse (freezeHistBuckets isDelta) rawSnap
      pure (instrDims s, snapped)

    flushReader env' rdr = do
      batches <- collectResourceMetrics env' (metricReaderTemporalityFor rdr)
      exportRes <- metricExporterExport (metricReaderExporter rdr) batches
      flushRes <- metricExporterForceFlush (metricReaderExporter rdr)
      pure (worstFlush (exportResultToFlush exportRes) flushRes)
