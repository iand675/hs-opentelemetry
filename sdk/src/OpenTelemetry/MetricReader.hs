{-# LANGUAGE NumericUnderscores #-}

{- | Periodic metric export (spec-style periodic reader) built on 'collectResourceMetrics'.

Stop the reader before 'meterProviderShutdown' on the associated 'MeterProvider'.

Applications that scrape metrics on demand (\"pull\") can skip a periodic reader and instead
call 'exportMetricsOnce' (or 'collectResourceMetrics' plus a text\/OTLP encoder) from their HTTP handler.
-}
module OpenTelemetry.MetricReader (
  -- * Re-exports from MeterProvider
  MetricReader (..),
  cumulativeTemporality,
  deltaTemporality,

  -- * Periodic reader
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
import OpenTelemetry.Environment (lookupMetricExportIntervalMillis, lookupMetricExportTimeoutMillis)
import OpenTelemetry.Exporter.Metric (
  MetricExporter (metricExporterExport, metricExporterForceFlush, metricExporterShutdown),
 )
import OpenTelemetry.Internal.Common.Types (ExportResult (..))
import OpenTelemetry.Internal.Logging (otelLogWarning)
import OpenTelemetry.MeterProvider (MetricReader (..), SdkMeterEnv, collectResourceMetrics, cumulativeTemporality, deltaTemporality)
import System.Timeout (timeout)


-- | @since 0.0.1.0
data PeriodicMetricReaderOptions = PeriodicMetricReaderOptions
  { periodicIntervalMicros :: !Int
  -- ^ Interval between automatic export cycles (microseconds).
  , periodicExportTimeoutMicros :: !Int
  -- ^ Maximum time allowed for a single export call (microseconds).
  }


{- | Default: 60s between exports, 30s export timeout.

@since 0.0.1.0
-}
defaultPeriodicMetricReaderOptions :: PeriodicMetricReaderOptions
defaultPeriodicMetricReaderOptions =
  PeriodicMetricReaderOptions
    { periodicIntervalMicros = 60_000_000
    , periodicExportTimeoutMicros = 30_000_000
    }


{- | Read @OTEL_METRIC_EXPORT_INTERVAL@ and @OTEL_METRIC_EXPORT_TIMEOUT@
(both in milliseconds) when set and positive; otherwise fall back to defaults.

@since 0.0.1.0
-}
periodicMetricReaderOptionsFromEnv :: IO PeriodicMetricReaderOptions
periodicMetricReaderOptionsFromEnv = do
  mi <- lookupMetricExportIntervalMillis
  mt <- lookupMetricExportTimeoutMillis
  pure $
    PeriodicMetricReaderOptions
      { periodicIntervalMicros = case mi of
          Just ms | ms > 0 -> ms * 1000
          _ -> periodicIntervalMicros defaultPeriodicMetricReaderOptions
      , periodicExportTimeoutMicros = case mt of
          Just ms | ms > 0 -> ms * 1000
          _ -> periodicExportTimeoutMicros defaultPeriodicMetricReaderOptions
      }


{- | Handle for a background thread that exports on an interval.

@since 0.0.1.0
-}
data PeriodicMetricReaderHandle = PeriodicMetricReaderHandle
  { periodicMetricReaderAsync :: !(Async ())
  , stopPeriodicMetricReader :: !(IO ())
  }


{- | One collect + export using the reader's temporality preference, with a timeout.

@since 0.0.1.0
-}
exportMetricsOnce :: SdkMeterEnv -> MetricReader -> PeriodicMetricReaderOptions -> IO ExportResult
exportMetricsOnce env rdr opts = do
  batches <- collectResourceMetrics env (metricReaderTemporalityFor rdr)
  mresult <-
    timeout (periodicExportTimeoutMicros opts) $ do
      exportRes <- metricExporterExport (metricReaderExporter rdr) batches
      case exportRes of
        Success -> do
          _ <- metricExporterForceFlush (metricReaderExporter rdr)
          pure Success
        failure -> pure failure
  case mresult of
    Nothing -> do
      otelLogWarning "Periodic metric export timed out"
      pure (Failure Nothing)
    Just r -> pure r


{- | Spawn an async loop: export on each interval until stopped.

@since 0.0.1.0
-}
forkPeriodicMetricReader
  :: SdkMeterEnv
  -> MetricReader
  -> PeriodicMetricReaderOptions
  -> IO PeriodicMetricReaderHandle
forkPeriodicMetricReader env rdr opts = do
  a <-
    async $
      forever $ do
        _ <- exportMetricsOnce env rdr opts
        threadDelay (periodicIntervalMicros opts)
  let stop = do
        cancel a
        _ <- waitCatch a
        _ <- exportMetricsOnce env rdr opts
        _ <- metricExporterShutdown (metricReaderExporter rdr)
        pure ()
  pure $
    PeriodicMetricReaderHandle
      { periodicMetricReaderAsync = a
      , stopPeriodicMetricReader = stop
      }
