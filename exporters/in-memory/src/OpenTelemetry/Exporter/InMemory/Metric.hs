{-# LANGUAGE OverloadedStrings #-}

{- | In-memory metric exporter for tests.

Exports are collected into an 'IORef' list; use 'readIORef' to inspect after
calling 'metricExporterExport' (directly or via the SDK's collect+export cycle).
-}
module OpenTelemetry.Exporter.InMemory.Metric (
  inMemoryMetricExporter,
) where

import Control.Monad.IO.Class (MonadIO, liftIO)
import Data.IORef (IORef, atomicModifyIORef', newIORef)
import OpenTelemetry.Exporter.Metric (
  MetricExporter (..),
  ResourceMetricsExport,
 )
import OpenTelemetry.Internal.Common.Types (ExportResult (..), FlushResult (..), ShutdownResult (..))


-- | Create a 'MetricExporter' backed by an 'IORef' that appends each batch.
inMemoryMetricExporter :: (MonadIO m) => m (MetricExporter, IORef [ResourceMetricsExport])
inMemoryMetricExporter = liftIO $ do
  ref <- newIORef []
  let ex =
        MetricExporter
          { metricExporterExport = \batches -> do
              atomicModifyIORef' ref (\acc -> (acc ++ batches, ()))
              pure Success
          , metricExporterShutdown = pure ShutdownSuccess
          , metricExporterForceFlush = pure FlushSuccess
          }
  pure (ex, ref)
