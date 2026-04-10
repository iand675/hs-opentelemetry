{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE StrictData #-}

{- |
Module      : OpenTelemetry.Internal.Metric.Types
Copyright   : (c) Ian Duncan, 2024-2026
License     : BSD-3
Description : Internal types for the OpenTelemetry Metrics API.
Stability   : experimental

Core metric types: instrument kinds, counters, histograms, gauges (sync and
async), meters, and meter providers. Not intended for direct import; use
"OpenTelemetry.Metric.Core" instead.

Spec: <https://opentelemetry.io/docs/specs/otel/metrics/api/>
-}
module OpenTelemetry.Internal.Metric.Types (
  InstrumentKind (..),
  HistogramAggregation (..),
  AdvisoryParameters (..),
  defaultAdvisoryParameters,
  Counter (..),
  UpDownCounter (..),
  Histogram (..),
  Gauge (..),
  ObservableResult (..),
  ObservableCallbackHandle (..),
  ObservableCounter (..),
  ObservableUpDownCounter (..),
  ObservableGauge (..),
  Meter (..),
  MeterProvider (..),
) where

import Data.Hashable (Hashable (hashWithSalt))
import Data.Int (Int32, Int64)
import Data.Text (Text)
import Data.Vector (Vector)
import qualified Data.Vector as V
import GHC.Generics (Generic)
import OpenTelemetry.Attributes (Attributes)
import OpenTelemetry.Internal.Common.Types (FlushResult, InstrumentationLibrary, ShutdownResult)


{- | Instrument kinds from the metrics API specification.

@since 0.0.1.0
-}
data InstrumentKind
  = KindCounter
  | KindAsyncCounter
  | KindUpDownCounter
  | KindAsyncUpDownCounter
  | KindHistogram
  | KindGauge
  | KindAsyncGauge
  deriving stock (Eq, Show, Ord, Generic)
  deriving anyclass (Hashable)


{- | Histogram aggregation chosen for an instrument (explicit bounds vs exponential).

@since 0.0.1.0
-}
data HistogramAggregation
  = HistogramAggregationExplicit !(Vector Double)
  | -- | Exponential histogram scale (OTel mapping index uses @2^scale@).
    HistogramAggregationExponential !Int32
  deriving stock (Eq, Show, Generic)


instance Hashable HistogramAggregation where
  hashWithSalt s (HistogramAggregationExplicit v) =
    V.foldl' hashWithSalt (s `hashWithSalt` (0 :: Int) `hashWithSalt` V.length v) v
  hashWithSalt s (HistogramAggregationExponential sc) =
    s `hashWithSalt` (1 :: Int) `hashWithSalt` sc


{- | Advisory parameters (spec: implementations MAY ignore; SDK SHOULD honor where defined).

@since 0.0.1.0
-}
data AdvisoryParameters = AdvisoryParameters
  { advisoryExplicitBucketBoundaries :: !(Maybe [Double])
  -- ^ Histogram explicit bucket boundaries (sorted ascending in SDK when applied).
  , advisoryAttributeKeys :: !(Maybe [Text])
  -- ^ Recommended attribute keys for the resulting metric stream (development in spec).
  , advisoryHistogramAggregation :: !(Maybe HistogramAggregation)
  -- ^ Prefer explicit buckets or exponential histogram when set; views may override.
  }
  deriving stock (Eq, Show, Generic)


-- | @since 0.0.1.0
defaultAdvisoryParameters :: AdvisoryParameters
defaultAdvisoryParameters =
  AdvisoryParameters
    { advisoryExplicitBucketBoundaries = Nothing
    , advisoryAttributeKeys = Nothing
    , advisoryHistogramAggregation = Nothing
    }


{- | Synchronous counter (non-negative increments). @a@ is 'Int64' or 'Double'.

@since 0.0.1.0
-}
data Counter a = Counter
  { counterAdd :: !(a -> Attributes -> IO ())
  -- ^ Record an increment. Negative values are silently dropped for monotonic counters.
  , counterEnabled :: !(IO Bool)
  -- ^ Whether this instrument is active. Noop instruments return @False@.
  }


{- | Synchronous additive instrument that may increase or decrease.

@since 0.0.1.0
-}
data UpDownCounter a = UpDownCounter
  { upDownCounterAdd :: !(a -> Attributes -> IO ())
  -- ^ Record an increment (positive) or decrement (negative).
  , upDownCounterEnabled :: !(IO Bool)
  -- ^ Whether this instrument is active.
  }


{- | Synchronous histogram (records 'Double' measurements).

@since 0.0.1.0
-}
data Histogram = Histogram
  { histogramRecord :: !(Double -> Attributes -> IO ())
  -- ^ Record a measurement. NaN and Infinity are silently dropped.
  , histogramEnabled :: !(IO Bool)
  -- ^ Whether this instrument is active.
  }


{- | Synchronous gauge (last value wins per collect cycle semantics in SDK).

@since 0.0.1.0
-}
data Gauge a = Gauge
  { gaugeRecord :: !(a -> Attributes -> IO ())
  -- ^ Record a value. The last value per attribute set wins at collection time.
  , gaugeEnabled :: !(IO Bool)
  -- ^ Whether this instrument is active.
  }


{- | Result handle passed to observable callbacks (spec: observe measurements at one logical instant).

@since 0.0.1.0
-}
newtype ObservableResult a = ObservableResult
  { observe :: a -> Attributes -> IO ()
  -- ^ Report a measurement for the given attribute set.
  }


{- | Handle to unregister a callback registered after instrument creation.

@since 0.0.1.0
-}
newtype ObservableCallbackHandle = ObservableCallbackHandle
  { unregisterObservableCallback :: IO ()
  -- ^ Remove this callback so it is no longer invoked during collection.
  }


{- | Asynchronous counter: monotonic cumulative values observed per collection.

@since 0.0.1.0
-}
data ObservableCounter a = ObservableCounter
  { observableCounterRegisterCallback :: !((ObservableResult a -> IO ()) -> IO ObservableCallbackHandle)
  -- ^ Register an additional callback after creation; returns a handle to unregister it.
  , observableCounterInstrumentScope :: !InstrumentationLibrary
  -- ^ The instrumentation scope that created this instrument.
  , observableCounterInstrumentName :: !Text
  -- ^ The instrument name (case-insensitive for matching in the SDK).
  , observableCounterEnabled :: !(IO Bool)
  -- ^ Whether this instrument is active.
  }


{- | Asynchronous up-down counter.

@since 0.0.1.0
-}
data ObservableUpDownCounter a = ObservableUpDownCounter
  { observableUpDownCounterRegisterCallback :: !((ObservableResult a -> IO ()) -> IO ObservableCallbackHandle)
  -- ^ Register an additional callback after creation.
  , observableUpDownCounterInstrumentScope :: !InstrumentationLibrary
  -- ^ The instrumentation scope that created this instrument.
  , observableUpDownCounterInstrumentName :: !Text
  -- ^ The instrument name.
  , observableUpDownCounterEnabled :: !(IO Bool)
  -- ^ Whether this instrument is active.
  }


{- | Asynchronous gauge.

@since 0.0.1.0
-}
data ObservableGauge a = ObservableGauge
  { observableGaugeRegisterCallback :: !((ObservableResult a -> IO ()) -> IO ObservableCallbackHandle)
  -- ^ Register an additional callback after creation.
  , observableGaugeInstrumentScope :: !InstrumentationLibrary
  -- ^ The instrumentation scope that created this instrument.
  , observableGaugeInstrumentName :: !Text
  -- ^ The instrument name.
  , observableGaugeEnabled :: !(IO Bool)
  -- ^ Whether this instrument is active.
  }


{- | Creates instruments for a single instrumentation scope.

@since 0.0.1.0
| All instrument factory functions take: name, optional unit, optional description, advisory parameters.
Observable factories additionally take initial callbacks.
-}
data Meter = Meter
  { meterInstrumentationScope :: !InstrumentationLibrary
  -- ^ The scope that owns instruments created by this meter.
  , meterCreateCounterInt64 :: !(Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> IO (Counter Int64))
  -- ^ Create a synchronous monotonic Int64 counter.
  , meterCreateCounterDouble :: !(Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> IO (Counter Double))
  -- ^ Create a synchronous monotonic Double counter.
  , meterCreateUpDownCounterInt64 :: !(Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> IO (UpDownCounter Int64))
  -- ^ Create a synchronous Int64 up-down counter.
  , meterCreateUpDownCounterDouble :: !(Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> IO (UpDownCounter Double))
  -- ^ Create a synchronous Double up-down counter.
  , meterCreateHistogram :: !(Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> IO Histogram)
  -- ^ Create a synchronous histogram.
  , meterCreateGaugeInt64 :: !(Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> IO (Gauge Int64))
  -- ^ Create a synchronous Int64 gauge.
  , meterCreateGaugeDouble :: !(Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> IO (Gauge Double))
  -- ^ Create a synchronous Double gauge.
  , meterCreateObservableCounterInt64 :: !(Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> [ObservableResult Int64 -> IO ()] -> IO (ObservableCounter Int64))
  -- ^ Create an asynchronous Int64 counter with initial callbacks.
  , meterCreateObservableCounterDouble :: !(Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> [ObservableResult Double -> IO ()] -> IO (ObservableCounter Double))
  -- ^ Create an asynchronous Double counter with initial callbacks.
  , meterCreateObservableUpDownCounterInt64 :: !(Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> [ObservableResult Int64 -> IO ()] -> IO (ObservableUpDownCounter Int64))
  -- ^ Create an asynchronous Int64 up-down counter with initial callbacks.
  , meterCreateObservableUpDownCounterDouble :: !(Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> [ObservableResult Double -> IO ()] -> IO (ObservableUpDownCounter Double))
  -- ^ Create an asynchronous Double up-down counter with initial callbacks.
  , meterCreateObservableGaugeInt64 :: !(Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> [ObservableResult Int64 -> IO ()] -> IO (ObservableGauge Int64))
  -- ^ Create an asynchronous Int64 gauge with initial callbacks.
  , meterCreateObservableGaugeDouble :: !(Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> [ObservableResult Double -> IO ()] -> IO (ObservableGauge Double))
  -- ^ Create an asynchronous Double gauge with initial callbacks.
  }


{- | Entry point for metrics API (spec: global default SHOULD exist).

@since 0.0.1.0
-}
data MeterProvider = MeterProvider
  { meterProviderGetMeter :: !(InstrumentationLibrary -> IO Meter)
  -- ^ Get or create a Meter for the given instrumentation scope.
  , meterProviderShutdown :: !(IO ShutdownResult)
  -- ^ Shut down the provider, flushing and releasing resources.
  , meterProviderForceFlush :: !(Maybe Int -> IO FlushResult)
  {- ^ Force a collection and export cycle. Optional timeout in microseconds;
  @Nothing@ uses the SDK default (5s).
  -}
  }
