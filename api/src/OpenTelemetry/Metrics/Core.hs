{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE ScopedTypeVariables #-}

-----------------------------------------------------------------------------

-----------------------------------------------------------------------------

{- |
 Module      :  OpenTelemetry.Metrics.Core
 Copyright   :  (c) Ian Duncan, 2024
 License     :  BSD-3
 Description :  Low-level metrics API
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)

 The Metrics API in OpenTelemetry provides a way to capture measurements about the
 execution of applications. Metrics are used to monitor application behavior and
 performance over time.

 The Metrics API consists of:

 * MeterProvider - Entry point of the API. Provides access to Meters.
 * Meter - Used to create Instruments.
 * Instruments - Used to report measurements.

 There are several types of instruments:

 * Counter - A synchronous instrument that supports non-negative increments
 * UpDownCounter - A synchronous instrument that supports positive and negative increments
 * Histogram - A synchronous instrument that records a distribution of values
 * Gauge - An asynchronous instrument that reports the current value
 * ObservableCounter - An asynchronous monotonic counter
 * ObservableUpDownCounter - An asynchronous up-down counter

 Synchronous instruments are called inline with application code (e.g., counting requests).
 Asynchronous instruments provide a callback that is invoked during metric collection
 (e.g., reporting current memory usage).

 This module implements everything required to conform to the metrics public interface
 described by the OpenTelemetry specification.
-}
module OpenTelemetry.Metrics.Core (
  -- * @MeterProvider@ operations
  MeterProvider,
  createMeterProvider,
  shutdownMeterProvider,
  forceFlushMeterProvider,
  getGlobalMeterProvider,
  setGlobalMeterProvider,
  emptyMeterProviderOptions,
  MeterProviderOptions (..),
  getMeterProviderResources,

  -- * @Meter@ operations
  Meter,
  meterName,
  HasMeter (..),
  makeMeter,
  getMeter,
  getMeterMeterProvider,
  InstrumentationLibrary (..),
  detectInstrumentationLibrary,
  MeterOptions (..),
  meterOptions,

  -- * Synchronous Instruments

  -- ** Counter
  Counter (..),
  createCounter,
  counterAdd,

  -- ** UpDownCounter
  UpDownCounter (..),
  createUpDownCounter,
  upDownCounterAdd,

  -- ** Histogram
  Histogram (..),
  createHistogram,
  histogramRecord,

  -- * Asynchronous Instruments

  -- ** Gauge
  Gauge (..),
  createGauge,

  -- ** ObservableCounter
  ObservableCounter (..),
  createObservableCounter,

  -- ** ObservableUpDownCounter
  ObservableUpDownCounter (..),
  createObservableUpDownCounter,

  -- * Metric Data Types
  InstrumentKind (..),
  AggregationTemporality (..),
  MetricData (..),
  DataPoint (..),
  HistogramDataPoint (..),
  ScopeMetrics (..),

  -- * Utilities
  Timestamp,
  getTimestamp,
) where

import Control.Monad.IO.Class
import Data.HashMap.Strict (HashMap)
import qualified Data.HashMap.Strict as H
import Data.IORef
import Data.Maybe (fromMaybe)
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Vector as V
import OpenTelemetry.Attributes
import OpenTelemetry.Common
import OpenTelemetry.Internal.Common.Types
import OpenTelemetry.Internal.Metrics.Types
import OpenTelemetry.Resource
import OpenTelemetry.Util
import System.Clock
import System.IO.Unsafe


{- | Options for creating a 'MeterProvider'.
-}
data MeterProviderOptions = MeterProviderOptions
  { meterProviderOptionsResources :: MaterializedResources
  , meterProviderOptionsAttributeLimits :: AttributeLimits
  }


{- | Default options for creating a 'MeterProvider' with no resources and default limits.

 In effect, metrics collection is a no-op when using this configuration until
 readers are registered.

 @since 0.3.0.0
-}
emptyMeterProviderOptions :: MeterProviderOptions
emptyMeterProviderOptions =
  MeterProviderOptions
    { meterProviderOptionsResources = emptyMaterializedResources
    , meterProviderOptionsAttributeLimits = defaultAttributeLimits
    }


{- | Initialize a new meter provider.

 You should generally use 'getGlobalMeterProvider' for most applications.

 @since 0.3.0.0
-}
createMeterProvider :: (MonadIO m) => [MetricReader] -> MeterProviderOptions -> m MeterProvider
createMeterProvider readers opts = liftIO $ do
  pure $
    MeterProvider
      { meterProviderMetricReaders = V.fromList readers
      , meterProviderResources = meterProviderOptionsResources opts
      , meterProviderAttributeLimits = meterProviderOptionsAttributeLimits opts
      }


globalMeterProvider :: IORef MeterProvider
globalMeterProvider = unsafePerformIO $ do
  p <- createMeterProvider [] emptyMeterProviderOptions
  newIORef p
{-# NOINLINE globalMeterProvider #-}


{- | Access the globally configured 'MeterProvider'.

 Once the global meter provider is initialized via the OpenTelemetry SDK,
 'Meter's created from this 'MeterProvider' will export metrics to their
 configured exporters. Prior to that, any 'Meter's acquired from the
 uninitialized 'MeterProvider' will be no-ops.

 @since 0.3.0.0
-}
getGlobalMeterProvider :: (MonadIO m) => m MeterProvider
getGlobalMeterProvider = liftIO $ readIORef globalMeterProvider


{- | Overwrite the globally configured 'MeterProvider'.

 'Meter's acquired from the previously installed 'MeterProvider'
 will continue to use that 'MeterProvider's configured metric readers
 and other settings.

 @since 0.3.0.0
-}
setGlobalMeterProvider :: (MonadIO m) => MeterProvider -> m ()
setGlobalMeterProvider = liftIO . writeIORef globalMeterProvider


{- | Get the resources associated with a 'MeterProvider'.

 @since 0.3.0.0
-}
getMeterProviderResources :: MeterProvider -> MaterializedResources
getMeterProviderResources = meterProviderResources


{- | Meter configuration options.

 @since 0.3.0.0
-}
newtype MeterOptions = MeterOptions
  { meterSchema :: Maybe Text
  -- ^ OpenTelemetry schema URL for this meter
  }


{- | Default Meter options with no schema.

 @since 0.3.0.0
-}
meterOptions :: MeterOptions
meterOptions = MeterOptions Nothing


{- | A small utility lens for extracting a 'Meter' from a larger data type.

 This will generally be most useful as a means of implementing metric collection
 in your application.

 @since 0.3.0.0
-}
class HasMeter s where
  meterL :: Lens' s Meter


{- | Create a 'Meter' from a 'MeterProvider'.

 @since 0.3.0.0
-}
makeMeter :: MeterProvider -> InstrumentationLibrary -> MeterOptions -> Meter
makeMeter mp lib MeterOptions {} = Meter lib mp


{- | Get a 'Meter' from a 'MeterProvider'.

 @since 0.3.0.0
-}
getMeter :: (MonadIO m) => MeterProvider -> InstrumentationLibrary -> MeterOptions -> m Meter
getMeter mp lib opts = liftIO $ pure $ makeMeter mp lib opts


{- | Get the 'MeterProvider' that created a 'Meter'.

 @since 0.3.0.0
-}
getMeterMeterProvider :: Meter -> MeterProvider
getMeterMeterProvider = meterProvider


{- | Create a Counter instrument.

 A Counter is a synchronous instrument that supports non-negative increments.
 Counters are monotonic - they can only increase.

 Example use cases:
 - Number of requests received
 - Number of items processed
 - Number of errors

 @since 0.3.0.0
-}
createCounter
  :: (MonadIO m)
  => Meter
  -- ^ The meter to create the counter from
  -> Text
  -- ^ Instrument name
  -> Text
  -- ^ Description (may be empty)
  -> Text
  -- ^ Unit of measurement (e.g., "1", "ms", "bytes")
  -> m (Counter Double)
createCounter m name desc unit = liftIO $ do
  pure $
    Counter
      { counterName = name
      , counterDescription = desc
      , counterUnit = unit
      , counterMeter = m
      , counterAdd = \_ _ -> pure () -- No-op implementation for API
      }


{- | Add a value to a Counter.

 The value must be non-negative. If a negative value is provided, the
 implementation may ignore it or record an error.

 @since 0.3.0.0
-}
counterAdd
  :: (MonadIO m)
  => Counter Double
  -> Double
  -- ^ The non-negative value to add
  -> AttributeMap
  -- ^ Attributes to associate with this measurement
  -> m ()
counterAdd c value attrs = liftIO $ counterAdd c value attrs


{- | Create an UpDownCounter instrument.

 An UpDownCounter is a synchronous instrument that supports increments and decrements.

 Example use cases:
 - Number of active requests
 - Queue size
 - Number of items in a collection

 @since 0.3.0.0
-}
createUpDownCounter
  :: (MonadIO m)
  => Meter
  -- ^ The meter to create the counter from
  -> Text
  -- ^ Instrument name
  -> Text
  -- ^ Description (may be empty)
  -> Text
  -- ^ Unit of measurement
  -> m (UpDownCounter Double)
createUpDownCounter m name desc unit = liftIO $ do
  pure $
    UpDownCounter
      { upDownCounterName = name
      , upDownCounterDescription = desc
      , upDownCounterUnit = unit
      , upDownCounterMeter = m
      , upDownCounterAdd = \_ _ -> pure () -- No-op implementation for API
      }


{- | Add a value to an UpDownCounter.

 The value can be positive or negative.

 @since 0.3.0.0
-}
upDownCounterAdd
  :: (MonadIO m)
  => UpDownCounter Double
  -> Double
  -- ^ The value to add (can be negative)
  -> AttributeMap
  -- ^ Attributes to associate with this measurement
  -> m ()
upDownCounterAdd c value attrs = liftIO $ OpenTelemetry.Internal.Metrics.Types.upDownCounterAdd c value attrs


{- | Create a Histogram instrument.

 A Histogram is a synchronous instrument that records a distribution of values.

 Example use cases:
 - Request duration
 - Response size
 - Database query time

 @since 0.3.0.0
-}
createHistogram
  :: (MonadIO m)
  => Meter
  -- ^ The meter to create the histogram from
  -> Text
  -- ^ Instrument name
  -> Text
  -- ^ Description (may be empty)
  -> Text
  -- ^ Unit of measurement
  -> m (Histogram Double)
createHistogram m name desc unit = liftIO $ do
  pure $
    Histogram
      { histogramName = name
      , histogramDescription = desc
      , histogramUnit = unit
      , histogramMeter = m
      , histogramRecord = \_ _ -> pure () -- No-op implementation for API
      }


{- | Record a value in a Histogram.

 @since 0.3.0.0
-}
histogramRecord
  :: (MonadIO m)
  => Histogram Double
  -> Double
  -- ^ The value to record
  -> AttributeMap
  -- ^ Attributes to associate with this measurement
  -> m ()
histogramRecord h value attrs = liftIO $ OpenTelemetry.Internal.Metrics.Types.histogramRecord h value attrs


{- | Create a Gauge instrument.

 A Gauge is an asynchronous instrument that reports the current value.
 The callback is invoked during metric collection.

 Example use cases:
 - Current memory usage
 - CPU utilization
 - Current temperature

 @since 0.3.0.0
-}
createGauge
  :: (MonadIO m)
  => Meter
  -- ^ The meter to create the gauge from
  -> Text
  -- ^ Instrument name
  -> Text
  -- ^ Description (may be empty)
  -> Text
  -- ^ Unit of measurement
  -> (AttributeMap -> IO Double)
  -- ^ Callback to retrieve the current value
  -> m (Gauge Double)
createGauge m name desc unit callback = liftIO $ do
  pure $
    Gauge
      { gaugeName = name
      , gaugeDescription = desc
      , gaugeUnit = unit
      , gaugeMeter = m
      , gaugeCallback = callback
      }


{- | Create an ObservableCounter instrument.

 An ObservableCounter is an asynchronous monotonic counter.
 The callback is invoked during metric collection to retrieve the current value.

 Example use cases:
 - Total CPU time consumed
 - Total bytes processed

 @since 0.3.0.0
-}
createObservableCounter
  :: (MonadIO m)
  => Meter
  -- ^ The meter to create the counter from
  -> Text
  -- ^ Instrument name
  -> Text
  -- ^ Description (may be empty)
  -> Text
  -- ^ Unit of measurement
  -> (AttributeMap -> IO Double)
  -- ^ Callback to retrieve the current value
  -> m (ObservableCounter Double)
createObservableCounter m name desc unit callback = liftIO $ do
  pure $
    ObservableCounter
      { observableCounterName = name
      , observableCounterDescription = desc
      , observableCounterUnit = unit
      , observableCounterMeter = m
      , observableCounterCallback = callback
      }


{- | Create an ObservableUpDownCounter instrument.

 An ObservableUpDownCounter is an asynchronous up-down counter.
 The callback is invoked during metric collection to retrieve the current value.

 Example use cases:
 - Current number of open connections
 - Current queue depth

 @since 0.3.0.0
-}
createObservableUpDownCounter
  :: (MonadIO m)
  => Meter
  -- ^ The meter to create the counter from
  -> Text
  -- ^ Instrument name
  -> Text
  -- ^ Description (may be empty)
  -> Text
  -- ^ Unit of measurement
  -> (AttributeMap -> IO Double)
  -- ^ Callback to retrieve the current value
  -> m (ObservableUpDownCounter Double)
createObservableUpDownCounter m name desc unit callback = liftIO $ do
  pure $
    ObservableUpDownCounter
      { observableUpDownCounterName = name
      , observableUpDownCounterDescription = desc
      , observableUpDownCounterUnit = unit
      , observableUpDownCounterMeter = m
      , observableUpDownCounterCallback = callback
      }


{- | Shutdown the meter provider, flushing any remaining metrics.

 @since 0.3.0.0
-}
shutdownMeterProvider :: (MonadIO m) => MeterProvider -> m ()
shutdownMeterProvider MeterProvider {..} = liftIO $ do
  mapM_ (metricReaderShutdown) meterProviderMetricReaders
  pure ()


{- | Force flush any buffered metrics.

 @since 0.3.0.0
-}
forceFlushMeterProvider :: (MonadIO m) => MeterProvider -> m ()
forceFlushMeterProvider MeterProvider {..} = liftIO $ do
  mapM_ metricReaderForceFlush meterProviderMetricReaders


{- | Get the current timestamp for metric collection.

 @since 0.3.0.0
-}
getTimestamp :: (MonadIO m) => m Timestamp
getTimestamp = liftIO $ Timestamp <$> getTime Realtime


type Lens s t a b = forall f. (Functor f) => (a -> f b) -> s -> f t


type Lens' s a = Lens s s a a
