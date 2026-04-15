{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

{- |
Module      :  OpenTelemetry.Metric
Copyright   :  (c) Ian Duncan, 2021-2026
License     :  BSD-3
Description :  OpenTelemetry Metrics SDK — batteries-included setup
Stability   :  experimental

= Overview

This is the main entry point for adding metrics to your Haskell application.
It re-exports the Metrics API types from "OpenTelemetry.Metric.Core" and
adds SDK-level initialization, periodic export, and views.

= Quick example

@
{\-# LANGUAGE OverloadedStrings #-\}
module Main where

import OpenTelemetry.Metric

main :: IO ()
main = withMeterProvider $ \\mp -> do
  meter <- getMeter mp "my-service"
  counter <- meterCreateCounterInt64 meter "http.requests" "" Nothing defaultAdvisoryParameters
  counterAdd counter 1 emptyAttributes
@

'withMeterProvider' reads configuration from @OTEL_*@ environment variables,
starts a periodic export thread, and ensures shutdown on exit. If you also
use 'OpenTelemetry.Trace.withTracerProvider', it already sets up a
'MeterProvider' for you via YAML config — use this module when you need
metrics without traces, or want explicit control.

= Configuration

| Variable | Default | Description |
|---|---|---|
| @OTEL_SDK_DISABLED@ | @false@ | Disable all telemetry |
| @OTEL_METRICS_EXPORTER@ | @otlp@ | @otlp@, @console@, @prometheus@, @none@ |
| @OTEL_METRIC_EXPORT_INTERVAL@ | @60000@ | Export interval in ms |
| @OTEL_METRIC_EXPORT_TIMEOUT@ | @30000@ | Export timeout in ms |
| @OTEL_METRICS_EXEMPLAR_FILTER@ | @trace_based@ | Exemplar filter: @always_on@, @always_off@, @trace_based@ |

= Spec reference

<https://opentelemetry.io/docs/specs/otel/metrics/sdk/>
-}
module OpenTelemetry.Metric (
  -- * Provider lifecycle
  withMeterProvider,
  initializeGlobalMeterProvider,
  MeterProviderHandle (..),
  shutdownMeterProviderHandle,

  -- * Metric API types (re-exported from "OpenTelemetry.Metric.Core")

  -- ** Provider
  MeterProvider (..),
  getMeter,
  noopMeterProvider,
  noopMeter,
  shutdownMeterProvider,
  forceFlushMeterProvider,
  getGlobalMeterProvider,
  setGlobalMeterProvider,

  -- ** Meter
  Meter (..),

  -- ** Instruments
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

  -- * SDK configuration

  -- ** Provider options
  SdkMeterProviderOptions (..),
  defaultSdkMeterProviderOptions,
  SdkMeterExemplarOptions (..),
  defaultSdkMeterExemplarOptions,
  createMeterProvider,
  SdkMeterEnv (..),

  -- ** Metric readers
  MetricReader (..),
  cumulativeTemporality,
  deltaTemporality,
  PeriodicMetricReaderOptions (..),
  defaultPeriodicMetricReaderOptions,
  periodicMetricReaderOptionsFromEnv,
  forkPeriodicMetricReader,
  exportMetricsOnce,
  PeriodicMetricReaderHandle (..),

  -- ** Views
  View (..),
  ViewSelector (..),
  ViewAggregation (..),
  MetricsExemplarFilter (..),

  -- ** Exporter selection
  resolveMetricExporter,

  -- * Common types
  InstrumentationLibrary (..),
  ShutdownResult (..),
  FlushResult (..),
  Attributes,
  emptyAttributes,
  ToAttribute (..),
  Attribute (..),
) where

import Control.Concurrent.MVar (newMVar)
import Control.Exception (bracket)
import Data.IORef (newIORef)
import qualified Data.IntMap.Strict as IM
import OpenTelemetry.Attributes (Attributes, emptyAttributes)
import OpenTelemetry.Attributes.Attribute (Attribute (..), ToAttribute (..))
import OpenTelemetry.Environment (lookupBooleanEnv)
import OpenTelemetry.Internal.AtomicCounter (newAtomicCounter)
import OpenTelemetry.Internal.Common.Types (FlushResult (..), InstrumentationLibrary (..), ShutdownResult (..))
import OpenTelemetry.Internal.Logging (otelLogDebug)
import OpenTelemetry.MeterProvider (
  MetricReader (..),
  SdkMeterEnv (..),
  SdkMeterExemplarOptions (..),
  SdkMeterProviderOptions (..),
  createMeterProvider,
  cumulativeTemporality,
  defaultSdkMeterExemplarOptions,
  defaultSdkMeterProviderOptions,
  deltaTemporality,
 )
import OpenTelemetry.Metric.Core
import OpenTelemetry.Metric.ExporterSelection (resolveMetricExporter)
import OpenTelemetry.Metric.View (
  MetricsExemplarFilter (..),
  View (..),
  ViewAggregation (..),
  ViewSelector (..),
 )
import OpenTelemetry.MetricReader (
  PeriodicMetricReaderHandle (..),
  PeriodicMetricReaderOptions (..),
  defaultPeriodicMetricReaderOptions,
  exportMetricsOnce,
  forkPeriodicMetricReader,
  periodicMetricReaderOptionsFromEnv,
 )
import OpenTelemetry.Resource (emptyMaterializedResources, materializeResources, mergeResources, mkResource)
import OpenTelemetry.Resource.Detect (detectBuiltInResources, detectResourceAttributes)


{- | Opaque handle for an initialized SDK 'MeterProvider' and its background
periodic reader. Use 'shutdownMeterProviderHandle' or the bracket in
'withMeterProvider' to tear it down.
-}
data MeterProviderHandle = MeterProviderHandle
  { meterProviderHandleProvider :: !MeterProvider
  , meterProviderHandleEnv :: !SdkMeterEnv
  , meterProviderHandleReaderHandle :: !(Maybe PeriodicMetricReaderHandle)
  }


{- | Build an inert 'SdkMeterEnv' for the disabled-SDK case. All mutable
fields are properly allocated (not bottom) so shutdown and flush never crash.
-}
noopSdkMeterEnv :: IO SdkMeterEnv
noopSdkMeterEnv = do
  instrRef <- newIORef []
  cbRef <- newIORef IM.empty
  cbId <- newAtomicCounter 0
  sdRef <- newIORef True
  lk <- newMVar ()
  lcRef <- newIORef 0
  pure
    SdkMeterEnv
      { sdkMeterInstruments = instrRef
      , sdkMeterCollectCallbacks = cbRef
      , sdkMeterNextCallbackId = cbId
      , sdkMeterResource = emptyMaterializedResources
      , sdkMeterShutdown = sdRef
      , sdkMeterCollectLock = lk
      , sdkMeterCardinalityLimit = 0
      , sdkMeterReaders = []
      , sdkMeterProducers = []
      , sdkMeterViews = []
      , sdkMeterExemplarOptions = defaultSdkMeterExemplarOptions
      , sdkMeterStartTimeNanos = 0
      , sdkMeterLastCollectTime = lcRef
      }


-- | Shut down the meter provider and stop the periodic reader.
shutdownMeterProviderHandle :: MeterProviderHandle -> IO ()
shutdownMeterProviderHandle MeterProviderHandle {..} = do
  case meterProviderHandleReaderHandle of
    Just h -> stopPeriodicMetricReader h
    Nothing -> pure ()
  _ <- shutdownMeterProvider meterProviderHandleProvider
  pure ()


{- | Initialize a 'MeterProvider' from environment variables, set it as the
global meter provider, and run an action. The provider is shut down on exit
(including exceptions).

@
main :: IO ()
main = withMeterProvider $ \\mp -> do
  meter <- getMeter mp "my-service"
  counter <- meterCreateCounterInt64 meter "requests" "" Nothing defaultAdvisoryParameters
  counterAdd counter 1 emptyAttributes
  -- ... application code ...
@

@since 0.0.1.0
-}
withMeterProvider :: (MeterProvider -> IO a) -> IO a
withMeterProvider body =
  bracket
    initializeGlobalMeterProvider
    shutdownMeterProviderHandle
    (\h -> body (meterProviderHandleProvider h))


{- | Create a 'MeterProvider' from @OTEL_*@ environment variables and install
it as the global provider via 'setGlobalMeterProvider'.

Returns a 'MeterProviderHandle' that the caller must shut down (via
'shutdownMeterProviderHandle') when the application exits.

Reads:

* @OTEL_SDK_DISABLED@ — if @true@, returns the no-op provider
* @OTEL_METRICS_EXPORTER@ — selects the exporter (default: @otlp@)
* @OTEL_METRIC_EXPORT_INTERVAL@, @OTEL_METRIC_EXPORT_TIMEOUT@ — periodic reader timing
* @OTEL_METRICS_EXEMPLAR_FILTER@ — exemplar filter strategy (default: @trace_based@)

@since 0.0.1.0
-}
initializeGlobalMeterProvider :: IO MeterProviderHandle
initializeGlobalMeterProvider = do
  disabled <- lookupBooleanEnv "OTEL_SDK_DISABLED"
  if disabled
    then do
      otelLogDebug "OTEL_SDK_DISABLED=true, using no-op MeterProvider"
      setGlobalMeterProvider noopMeterProvider
      noopEnv <- noopSdkMeterEnv
      pure
        MeterProviderHandle
          { meterProviderHandleProvider = noopMeterProvider
          , meterProviderHandleEnv = noopEnv
          , meterProviderHandleReaderHandle = Nothing
          }
    else do
      exporter <- resolveMetricExporter
      readerOpts <- periodicMetricReaderOptionsFromEnv
      let reader =
            MetricReader
              { metricReaderExporter = exporter
              , metricReaderTemporalityFor = cumulativeTemporality
              }
          opts =
            defaultSdkMeterProviderOptions
              { readers = [reader]
              }
      builtInRs <- detectBuiltInResources
      envVarRs <- mkResource . map Just <$> detectResourceAttributes
      let rs = materializeResources (mergeResources envVarRs builtInRs)
      (provider, env) <- createMeterProvider rs opts
      setGlobalMeterProvider provider
      readerHandle <- forkPeriodicMetricReader env reader readerOpts
      otelLogDebug "MeterProvider initialized from environment"
      pure
        MeterProviderHandle
          { meterProviderHandleProvider = provider
          , meterProviderHandleEnv = env
          , meterProviderHandleReaderHandle = Just readerHandle
          }
