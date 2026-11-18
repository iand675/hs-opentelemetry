{-# LANGUAGE ScopedTypeVariables #-}

-- Coordination for one reader. Recording never takes this lock.
module OpenTelemetry.Internal.MetricExport (
  MetricExportState,
  newMetricExportState,
  installMetricExporter,
  exportMetricBatch,
  flushMetricExport,
  shutdownMetricExport,
) where

import Control.Concurrent.Async (Async, async, waitCatch)
import Control.Concurrent.MVar
import Control.Exception
import Data.IORef
import Data.Maybe (fromMaybe)
import Data.Vector (Vector)
import OpenTelemetry.Exporter.Metric (MetricExporter (..), ResourceMetricsExport)
import OpenTelemetry.Internal.Common.Types
import System.Timeout (timeout)


data MetricExportState = MetricExportState
  { exportLock :: MVar ()
  , exportConfiguration :: IORef (Maybe MetricExporter, IO ())
  , exportClosed :: IORef Bool
  , exportShutdown :: MVar (Maybe (Async ShutdownResult))
  }


newMetricExportState :: IO MetricExportState
newMetricExportState = MetricExportState <$> newMVar () <*> newIORef (Nothing, pure ()) <*> newIORef False <*> newMVar Nothing


installMetricExporter :: MetricExportState -> MetricExporter -> IO () -> IO ()
installMetricExporter state ex stop = withMVar (exportLock state) $ \_ -> do
  closed <- readIORef (exportClosed state)
  if closed
    then throwIO (userError "Cannot install a metric reader after shutdown")
    else writeIORef (exportConfiguration state) (Just ex, stop)


-- Catch exporter failures, but preserve caller cancellation and timeout exceptions.
safe :: a -> IO a -> IO a
safe failure action =
  action `catch` \(err :: SomeException) ->
    case fromException err :: Maybe SomeAsyncException of
      Just _ -> throwIO err
      Nothing -> pure failure


bounded :: Int -> a -> IO a -> IO a
bounded micros failure action = fromMaybe failure <$> timeout (max 0 micros) action


exportMetricBatch :: MetricExportState -> IO (Vector ResourceMetricsExport) -> MetricExporter -> Maybe Int -> IO ExportResult
exportMetricBatch state collect ex limit =
  bounded (fromMaybe 30000000 limit) (Failure Nothing) $
    safe (Failure Nothing) $
      withMVar (exportLock state) $ \_ -> do
        closed <- readIORef (exportClosed state)
        if closed then pure (Failure Nothing) else collect >>= metricExporterExport ex


flushCycle :: IO (Vector ResourceMetricsExport) -> MetricExporter -> IO FlushResult
flushCycle collect ex = do
  exported <- safe (Failure Nothing) (collect >>= metricExporterExport ex)
  flushed <- safe FlushError (metricExporterForceFlush ex)
  pure $ case exported of
    Success -> flushed
    Failure _ -> worstFlush FlushError flushed


flushMetricExport :: MetricExportState -> IO (Vector ResourceMetricsExport) -> Maybe Int -> IO FlushResult
flushMetricExport state collect limit =
  bounded (fromMaybe 30000000 limit) FlushTimeout $
    safe FlushError $
      withMVar (exportLock state) $ \_ -> do
        closed <- readIORef (exportClosed state)
        (exporter, _) <- readIORef (exportConfiguration state)
        if closed then pure FlushError else maybe (pure FlushSuccess) (flushCycle collect) exporter


-- One bounded shutdown task owns cleanup. Concurrent/repeated callers join it;
-- cancelling a caller does not abandon cleanup or repeat exporter shutdown.
shutdownMetricExport :: MetricExportState -> IO (Vector ResourceMetricsExport) -> IO () -> Maybe Int -> IO ShutdownResult
shutdownMetricExport state collect cleanup limit = do
  let micros = fromMaybe 5000000 limit
  job <- modifyMVar (exportShutdown state) $ \existing -> case existing of
    Just running -> pure (existing, running)
    Nothing -> do
      writeIORef (exportClosed state) True
      running <-
        async $
          ( bounded micros ShutdownTimeout $ safe ShutdownFailure $ do
              -- Stop the scheduler before taking the export lock: it may be waiting
              -- for that lock itself, or currently exporting under it.
              (_, stop) <- readIORef (exportConfiguration state)
              stop
              withMVar (exportLock state) $ \_ -> do
                (exporter, _) <- readIORef (exportConfiguration state)
                case exporter of
                  Nothing -> pure ShutdownSuccess
                  Just ex -> do
                    flushed <- flushCycle collect ex
                    shut <- safe ShutdownFailure (metricExporterShutdown ex)
                    pure $ case flushed of
                      FlushSuccess -> shut
                      FlushTimeout -> worstShutdown ShutdownTimeout shut
                      FlushError -> worstShutdown ShutdownFailure shut
          )
            `finally` cleanup
      pure (Just running, running)
  bounded micros ShutdownTimeout $ do
    result <- waitCatch job
    pure $ either (const ShutdownFailure) id result
