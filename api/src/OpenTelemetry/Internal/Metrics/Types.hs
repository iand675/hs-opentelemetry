{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE ExistentialQuantification #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE StrictData #-}

module OpenTelemetry.Internal.Metrics.Types where

import Control.Concurrent.Async (Async)
import Control.Monad.IO.Class
import Data.HashMap.Strict (HashMap)
import Data.IORef (IORef)
import Data.Text (Text)
import Data.Vector (Vector)
import GHC.Generics (Generic)
import OpenTelemetry.Attributes
import OpenTelemetry.Common
import OpenTelemetry.Internal.Common.Types
import OpenTelemetry.Resource


{- | MetricExporter defines the interface that protocol-specific exporters must
 implement so that they can be plugged into OpenTelemetry SDK and support sending
 of metric data.
-}
data MetricExporter = MetricExporter
  { metricExporterExport :: HashMap InstrumentationLibrary (Vector MetricData) -> IO ExportResult
  -- ^ Export a batch of metrics. Will only be called if there are metrics to export.
  , metricExporterShutdown :: IO ()
  -- ^ Called when the exporter is being shutdown. Should clean up any resources.
  , metricExporterTemporality :: InstrumentKind -> AggregationTemporality
  -- ^ Returns the preferred aggregation temporality for the given instrument kind.
  }


{- | MetricReader is an interface for reading aggregated metric data.

 MetricReaders are responsible for collecting metrics from the SDK and
 exporting them. The SDK uses MetricReaders to determine when to collect
 and export metrics.
-}
data MetricReader = MetricReader
  { metricReaderCollect :: IO [ScopeMetrics]
  -- ^ Collect metrics from all registered metric producers.
  , metricReaderForceFlush :: IO ()
  -- ^ Flush any buffered metrics to the exporter.
  , metricReaderShutdown :: IO (Async ShutdownResult)
  -- ^ Shutdown the reader and any associated exporters.
  }


{- | MeterProvider is the entry point of the OpenTelemetry Metrics API.
 It provides access to Meters.
-}
data MeterProvider = MeterProvider
  { meterProviderMetricReaders :: !(Vector MetricReader)
  , meterProviderResources :: !MaterializedResources
  , meterProviderAttributeLimits :: !AttributeLimits
  }


{- | A Meter is the entry point for creating instruments.

 Meters are identified by their instrumentation library, which should be
 the same as the library being instrumented.
-}
data Meter = Meter
  { meterName :: {-# UNPACK #-} !InstrumentationLibrary
  -- ^ The instrumentation library associated with this meter
  , meterProvider :: !MeterProvider
  -- ^ The MeterProvider that created this meter
  }


instance Show Meter where
  showsPrec d Meter {meterName = name} = showParen (d > 10) $ showString "Meter {meterName = " . shows name . showString "}"


{- | Represents the kind of instrument being created.
 Different instrument kinds may have different aggregation and temporality defaults.
-}
data InstrumentKind
  = -- | A monotonic counter that only increases
    CounterKind
  | -- | A counter that can increase or decrease
    UpDownCounterKind
  | -- | Records a distribution of values
    HistogramKind
  | -- | Records the current value
    GaugeKind
  | -- | An asynchronous monotonic counter
    ObservableCounterKind
  | -- | An asynchronous up-down counter
    ObservableUpDownCounterKind
  | -- | An asynchronous gauge
    ObservableGaugeKind
  deriving (Show, Eq, Ord, Generic)


{- | Aggregation temporality indicates whether reported values incorporate
 previous measurements, or represent the delta since the last reporting interval.
-}
data AggregationTemporality
  = -- | Values are reset to zero after each collection
    DeltaTemporality
  | -- | Values accumulate over the lifetime of the instrument
    CumulativeTemporality
  deriving (Show, Eq, Ord, Generic)


{- | A Counter is a synchronous instrument that supports non-negative increments.

 Counters are monotonic - they can only increase. Use UpDownCounter for values
 that can increase or decrease.
-}
data Counter a = Counter
  { counterName :: !Text
  , counterDescription :: !Text
  , counterUnit :: !Text
  , counterMeter :: !Meter
  , counterAdd :: !a -> AttributeMap -> IO ()
  -- ^ Add a value to the counter with the given attributes
  }


{- | An UpDownCounter is a synchronous instrument that supports increments and decrements.

 Unlike Counter, UpDownCounter can both increase and decrease.
-}
data UpDownCounter a = UpDownCounter
  { upDownCounterName :: !Text
  , upDownCounterDescription :: !Text
  , upDownCounterUnit :: !Text
  , upDownCounterMeter :: !Meter
  , upDownCounterAdd :: !a -> AttributeMap -> IO ()
  -- ^ Add a value (positive or negative) to the counter with the given attributes
  }


{- | A Histogram is a synchronous instrument that records a distribution of values.

 Histograms are useful for measuring request durations, response sizes, etc.
-}
data Histogram a = Histogram
  { histogramName :: !Text
  , histogramDescription :: !Text
  , histogramUnit :: !Text
  , histogramMeter :: !Meter
  , histogramRecord :: !a -> AttributeMap -> IO ()
  -- ^ Record a value in the histogram with the given attributes
  }


{- | A Gauge is an asynchronous instrument that reports the current value.

 Gauges are useful for measuring values like memory usage, queue depth, etc.
-}
data Gauge a = Gauge
  { gaugeName :: !Text
  , gaugeDescription :: !Text
  , gaugeUnit :: !Text
  , gaugeMeter :: !Meter
  , gaugeCallback :: !(AttributeMap -> IO a)
  -- ^ Callback to retrieve the current gauge value
  }


{- | An ObservableCounter is an asynchronous monotonic counter.

 The callback is invoked during metric collection to retrieve the current value.
-}
data ObservableCounter a = ObservableCounter
  { observableCounterName :: !Text
  , observableCounterDescription :: !Text
  , observableCounterUnit :: !Text
  , observableCounterMeter :: !Meter
  , observableCounterCallback :: !(AttributeMap -> IO a)
  -- ^ Callback to retrieve the current counter value
  }


{- | An ObservableUpDownCounter is an asynchronous up-down counter.

 The callback is invoked during metric collection to retrieve the current value.
-}
data ObservableUpDownCounter a = ObservableUpDownCounter
  { observableUpDownCounterName :: !Text
  , observableUpDownCounterDescription :: !Text
  , observableUpDownCounterUnit :: !Text
  , observableUpDownCounterMeter :: !Meter
  , observableUpDownCounterCallback :: !(AttributeMap -> IO a)
  -- ^ Callback to retrieve the current counter value
  }


{- | Represents a single metric data point with its attributes and value.
-}
data DataPoint a = DataPoint
  { dataPointAttributes :: !Attributes
  , dataPointTimestamp :: !Timestamp
  , dataPointValue :: !a
  }
  deriving (Show, Eq, Generic)


{- | Aggregated metric data for a single instrument.
-}
data MetricData
  = SumData
      { sumName :: !Text
      , sumDescription :: !Text
      , sumUnit :: !Text
      , sumTemporality :: !AggregationTemporality
      , sumIsMonotonic :: !Bool
      , sumDataPoints :: !(Vector (DataPoint Double))
      }
  | GaugeData
      { gaugeName :: !Text
      , gaugeDescription :: !Text
      , gaugeUnit :: !Text
      , gaugeDataPoints :: !(Vector (DataPoint Double))
      }
  | HistogramData
      { histogramName :: !Text
      , histogramDescription :: !Text
      , histogramUnit :: !Text
      , histogramTemporality :: !AggregationTemporality
      , histogramDataPoints :: !(Vector HistogramDataPoint)
      }
  deriving (Show, Eq, Generic)


{- | A histogram data point with bucket counts.
-}
data HistogramDataPoint = HistogramDataPoint
  { histogramDataPointAttributes :: !Attributes
  , histogramDataPointTimestamp :: !Timestamp
  , histogramDataPointCount :: !Int
  , histogramDataPointSum :: !Double
  , histogramDataPointMin :: !(Maybe Double)
  , histogramDataPointMax :: !(Maybe Double)
  , histogramDataPointBucketCounts :: !(Vector Int)
  , histogramDataPointExplicitBounds :: !(Vector Double)
  }
  deriving (Show, Eq, Generic)


{- | Metrics grouped by instrumentation scope (library).
-}
data ScopeMetrics = ScopeMetrics
  { scopeMetricsScope :: !InstrumentationLibrary
  , scopeMetricsMetrics :: !(Vector MetricData)
  }
  deriving (Show, Eq, Generic)
