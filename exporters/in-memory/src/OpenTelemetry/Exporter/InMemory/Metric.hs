{-# LANGUAGE OverloadedStrings #-}

{- |
Module      :  OpenTelemetry.Exporter.InMemory.Metric
Copyright   :  (c) Ian Duncan, 2024-2026
License     :  BSD-3
Description :  In-memory metric exporter for tests.
Stability   :  experimental

Exports are collected into an 'IORef' list; use 'readIORef' to inspect after
calling 'metricExporterExport' (directly or via the SDK's collect+export cycle).
-}
module OpenTelemetry.Exporter.InMemory.Metric (
  inMemoryMetricExporter,
) where

import Control.Monad.IO.Class (MonadIO, liftIO)
import Data.IORef (IORef, atomicModifyIORef', newIORef)
import qualified Data.Vector as V
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
              atomicModifyIORef' ref (\acc -> (acc ++ V.toList batches, ()))
              pure Success
          , metricExporterShutdown = pure ShutdownSuccess
          , metricExporterForceFlush = pure FlushSuccess
          }
  pure (ex, ref)
