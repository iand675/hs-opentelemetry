{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE StrictData #-}

{- | Internal types for the OpenTelemetry Metrics API (see specification/metrics/api.md).
-}
module OpenTelemetry.Internal.Metrics.Types (
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


-- | Instrument kinds from the metrics API specification.
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


-- | Histogram aggregation chosen for an instrument (explicit bounds vs exponential).
data HistogramAggregation
  = HistogramAggregationExplicit !(Vector Double)
  | HistogramAggregationExponential !Int32
  -- ^ Exponential histogram scale (OTel mapping index uses @2^scale@).
  deriving stock (Eq, Show, Generic)


instance Hashable HistogramAggregation where
  hashWithSalt s (HistogramAggregationExplicit v) =
    s `hashWithSalt` (0 :: Int) `hashWithSalt` V.toList v
  hashWithSalt s (HistogramAggregationExponential sc) =
    s `hashWithSalt` (1 :: Int) `hashWithSalt` sc


-- | Advisory parameters (spec: implementations MAY ignore; SDK SHOULD honor where defined).
data AdvisoryParameters = AdvisoryParameters
  { advisoryExplicitBucketBoundaries :: !(Maybe [Double])
  -- ^ Histogram explicit bucket boundaries (sorted ascending in SDK when applied).
  , advisoryAttributeKeys :: !(Maybe [Text])
  -- ^ Recommended attribute keys for the resulting metric stream (development in spec).
  , advisoryHistogramAggregation :: !(Maybe HistogramAggregation)
  -- ^ Prefer explicit buckets or exponential histogram when set; views may override.
  }
  deriving stock (Eq, Show, Generic)


defaultAdvisoryParameters :: AdvisoryParameters
defaultAdvisoryParameters =
  AdvisoryParameters
    { advisoryExplicitBucketBoundaries = Nothing
    , advisoryAttributeKeys = Nothing
    , advisoryHistogramAggregation = Nothing
    }


-- | Synchronous counter (non-negative increments). @a@ is 'Int64' or 'Double'.
data Counter a = Counter
  { counterAdd :: !(a -> Attributes -> IO ())
  , counterEnabled :: !(IO Bool)
  }


-- | Synchronous additive instrument that may increase or decrease.
data UpDownCounter a = UpDownCounter
  { upDownCounterAdd :: !(a -> Attributes -> IO ())
  , upDownCounterEnabled :: !(IO Bool)
  }


-- | Synchronous histogram (records 'Double' measurements).
data Histogram = Histogram
  { histogramRecord :: !(Double -> Attributes -> IO ())
  , histogramEnabled :: !(IO Bool)
  }


-- | Synchronous gauge (last value wins per collect cycle semantics in SDK).
data Gauge a = Gauge
  { gaugeRecord :: !(a -> Attributes -> IO ())
  , gaugeEnabled :: !(IO Bool)
  }


-- | Result handle passed to observable callbacks (spec: observe measurements at one logical instant).
newtype ObservableResult a = ObservableResult
  { observe :: a -> Attributes -> IO ()
  }


-- | Handle to unregister a callback registered after instrument creation.
newtype ObservableCallbackHandle = ObservableCallbackHandle
  { unregisterObservableCallback :: IO ()
  }


-- | Asynchronous counter: monotonic cumulative values observed per collection.
data ObservableCounter a = ObservableCounter
  { observableCounterRegisterCallback :: !( (ObservableResult a -> IO ()) -> IO ObservableCallbackHandle)
  , observableCounterInstrumentScope :: !InstrumentationLibrary
  , observableCounterInstrumentName :: !Text
  , observableCounterEnabled :: !(IO Bool)
  }


-- | Asynchronous up-down counter.
data ObservableUpDownCounter a = ObservableUpDownCounter
  { observableUpDownCounterRegisterCallback :: !( (ObservableResult a -> IO ()) -> IO ObservableCallbackHandle)
  , observableUpDownCounterInstrumentScope :: !InstrumentationLibrary
  , observableUpDownCounterInstrumentName :: !Text
  , observableUpDownCounterEnabled :: !(IO Bool)
  }


-- | Asynchronous gauge.
data ObservableGauge a = ObservableGauge
  { observableGaugeRegisterCallback :: !( (ObservableResult a -> IO ()) -> IO ObservableCallbackHandle)
  , observableGaugeInstrumentScope :: !InstrumentationLibrary
  , observableGaugeInstrumentName :: !Text
  , observableGaugeEnabled :: !(IO Bool)
  }


-- | Creates instruments for a single instrumentation scope.
data Meter = Meter
  { meterInstrumentationScope :: !InstrumentationLibrary
  , meterCreateCounterInt64 :: !(Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> IO (Counter Int64))
  , meterCreateCounterDouble :: !(Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> IO (Counter Double))
  , meterCreateUpDownCounterInt64 :: !(Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> IO (UpDownCounter Int64))
  , meterCreateUpDownCounterDouble :: !(Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> IO (UpDownCounter Double))
  , meterCreateHistogram :: !(Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> IO Histogram)
  , meterCreateGaugeInt64 :: !(Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> IO (Gauge Int64))
  , meterCreateGaugeDouble :: !(Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> IO (Gauge Double))
  , meterCreateObservableCounterInt64 :: !(Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> [ObservableResult Int64 -> IO ()] -> IO (ObservableCounter Int64))
  , meterCreateObservableCounterDouble :: !(Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> [ObservableResult Double -> IO ()] -> IO (ObservableCounter Double))
  , meterCreateObservableUpDownCounterInt64 :: !(Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> [ObservableResult Int64 -> IO ()] -> IO (ObservableUpDownCounter Int64))
  , meterCreateObservableUpDownCounterDouble :: !(Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> [ObservableResult Double -> IO ()] -> IO (ObservableUpDownCounter Double))
  , meterCreateObservableGaugeInt64 :: !(Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> [ObservableResult Int64 -> IO ()] -> IO (ObservableGauge Int64))
  , meterCreateObservableGaugeDouble :: !(Text -> Maybe Text -> Maybe Text -> AdvisoryParameters -> [ObservableResult Double -> IO ()] -> IO (ObservableGauge Double))
  }


-- | Entry point for metrics API (spec: global default SHOULD exist).
data MeterProvider = MeterProvider
  { meterProviderGetMeter :: !(InstrumentationLibrary -> IO Meter)
  , meterProviderShutdown :: !(IO ShutdownResult)
  , meterProviderForceFlush :: !(IO FlushResult)
  }
