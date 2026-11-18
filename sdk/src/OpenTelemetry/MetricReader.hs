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
  forkPeriodicMetricReaderWithTimeout,
  exportMetricsOnce,
) where

import Control.Concurrent (newEmptyMVar, putMVar, readMVar)
import Control.Concurrent.Async (Async, async, cancel, waitCatch)
import Control.Concurrent.STM (atomically, check, newTVarIO, readTVar, registerDelay, writeTVar)
import Control.Exception (onException)
import Control.Monad (unless, void)
import OpenTelemetry.Environment (lookupMetricExportIntervalMillis, lookupMetricExportTimeoutMillis)
import OpenTelemetry.Exporter.Metric (MetricExporter (..))
import OpenTelemetry.Internal.Common.Types (ExportResult)
import OpenTelemetry.MeterProvider (SdkMeterEnv, exportMetricReader, registerMetricExporter, shutdownMetricReader)


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
          Just ms | ms > 0 -> millisToMicros ms
          _ -> periodicIntervalMicros defaultPeriodicMetricReaderOptions
      }


-- | Handle for a background thread that exports on an interval.
data PeriodicMetricReaderHandle = PeriodicMetricReaderHandle
  { periodicMetricReaderAsync :: !(Async ())
  , stopPeriodicMetricReader :: !(IO ())
  }


-- | One collect + export (for tests and custom schedulers).
exportMetricsOnce :: SdkMeterEnv -> MetricExporter -> IO ExportResult
exportMetricsOnce env ex = exportMetricReader env ex Nothing


-- | Start a reader using OTEL_METRIC_EXPORT_TIMEOUT (default 30 seconds).
forkPeriodicMetricReader :: SdkMeterEnv -> MetricExporter -> PeriodicMetricReaderOptions -> IO PeriodicMetricReaderHandle
forkPeriodicMetricReader env ex opts = do
  limit <- lookupMetricExportTimeoutMillis
  forkPeriodicMetricReaderWithTimeout env ex opts (maybe 30000000 millisToMicros limit)


{- | Explicit export timeout in microseconds. Keeps the original options and
handle constructors source-compatible.
-}
forkPeriodicMetricReaderWithTimeout :: SdkMeterEnv -> MetricExporter -> PeriodicMetricReaderOptions -> Int -> IO PeriodicMetricReaderHandle
forkPeriodicMetricReaderWithTimeout env ex opts limit = do
  ready <- newEmptyMVar
  stopping <- newTVarIO False
  let loop = do
        stopped <- atomically (readTVar stopping)
        unless stopped $ do
          _ <- exportMetricReader env ex (Just limit)
          timer <- registerDelay (max 1 (periodicIntervalMicros opts))
          atomically $ do
            stop <- readTVar stopping
            elapsed <- readTVar timer
            check (stop || elapsed)
          loop
  worker <- async (readMVar ready >> loop)
  let stop = do
        atomically (writeTVar stopping True)
        void (waitCatch worker) `onException` cancel worker
  registerMetricExporter env ex stop `onException` cancel worker
  putMVar ready ()
  pure $ PeriodicMetricReaderHandle worker (void $ shutdownMetricReader env Nothing)


millisToMicros :: Int -> Int
millisToMicros n = fromInteger (min (toInteger (maxBound :: Int)) (max 0 (toInteger n) * 1000))
