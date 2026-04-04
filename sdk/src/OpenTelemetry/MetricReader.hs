{-# LANGUAGE NumericUnderscores #-}

{- | Periodic metric export (spec-style periodic reader) built on 'collectResourceMetrics'.

Stop the reader before 'meterProviderShutdown' on the associated 'MeterProvider'.

Applications that scrape metrics on demand (\"pull\") can skip a periodic reader and instead
call 'exportMetricsOnce' (or 'collectResourceMetrics' plus a text\/OTLP encoder) from their HTTP handler.
-}
module OpenTelemetry.MetricReader (
  PeriodicMetricReaderOptions (..),
  defaultPeriodicMetricReaderOptions,
  periodicMetricReaderOptionsFromEnv,
  PeriodicMetricReaderHandle (..),
  forkPeriodicMetricReader,
  exportMetricsOnce,
) where

import Control.Concurrent (threadDelay)
import Control.Concurrent.Async (Async, async, cancel, waitCatch)
import Control.Monad (forever)
import OpenTelemetry.Environment (lookupMetricExportIntervalMillis)
import OpenTelemetry.Exporter.Metric (MetricExporter (..))
import OpenTelemetry.Internal.Common.Types (ExportResult)
import OpenTelemetry.MeterProvider (SdkMeterEnv, collectResourceMetrics)


-- | Interval between automatic export cycles (microseconds).
newtype PeriodicMetricReaderOptions = PeriodicMetricReaderOptions
  { periodicIntervalMicros :: Int
  }


-- | Default: 60 seconds between exports (overridden by 'periodicMetricReaderOptionsFromEnv' when @OTEL_METRIC_EXPORT_INTERVAL@ is set).
defaultPeriodicMetricReaderOptions :: PeriodicMetricReaderOptions
defaultPeriodicMetricReaderOptions =
  PeriodicMetricReaderOptions
    { periodicIntervalMicros = 60_000_000
    }


-- | Use @OTEL_METRIC_EXPORT_INTERVAL@ (milliseconds) when set and positive; otherwise same as 'defaultPeriodicMetricReaderOptions'.
periodicMetricReaderOptionsFromEnv :: IO PeriodicMetricReaderOptions
periodicMetricReaderOptionsFromEnv = do
  mi <- lookupMetricExportIntervalMillis
  pure $
    PeriodicMetricReaderOptions
      { periodicIntervalMicros = case mi of
          Just ms | ms > 0 -> ms * 1000
          _ -> periodicIntervalMicros defaultPeriodicMetricReaderOptions
      }


-- | Handle for a background thread that exports on an interval.
data PeriodicMetricReaderHandle = PeriodicMetricReaderHandle
  { periodicMetricReaderAsync :: !(Async ())
  , stopPeriodicMetricReader :: !(IO ())
  }


-- | One collect + export (for tests and custom schedulers).
exportMetricsOnce :: SdkMeterEnv -> MetricExporter -> IO ExportResult
exportMetricsOnce env ex = do
  batches <- collectResourceMetrics env
  metricExporterExport ex batches


-- | Spawn an async loop: export on each interval until stopped.
forkPeriodicMetricReader ::
  SdkMeterEnv ->
  MetricExporter ->
  PeriodicMetricReaderOptions ->
  IO PeriodicMetricReaderHandle
forkPeriodicMetricReader env ex opts = do
  a <-
    async $
      forever $ do
        _ <- exportMetricsOnce env ex
        threadDelay (periodicIntervalMicros opts)
  let stop = do
        cancel a
        _ <- waitCatch a
        _ <- exportMetricsOnce env ex
        pure ()
  pure $
    PeriodicMetricReaderHandle
      { periodicMetricReaderAsync = a
      , stopPeriodicMetricReader = stop
      }

