{-# LANGUAGE RecordWildCards #-}

-----------------------------------------------------------------------------

-----------------------------------------------------------------------------

{- |
 Module      :  OpenTelemetry.Metrics.MetricReader
 Copyright   :  (c) Ian Duncan, 2024
 License     :  BSD-3
 Description :  Metric reading and export strategies
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)

 MetricReaders are responsible for collecting metrics from the SDK and
 exporting them to backends. This module provides a periodic metric reader
 that collects and exports metrics at regular intervals.
-}
module OpenTelemetry.Metrics.MetricReader (
  -- * Periodic metric reader
  PeriodicReaderConfig (..),
  defaultPeriodicReaderConfig,
  periodicReader,

  -- * Manual metric reader
  manualReader,
) where

import Control.Concurrent (threadDelay)
import Control.Concurrent.Async
import Control.Monad (forever, when)
import Data.HashMap.Strict (HashMap)
import qualified Data.HashMap.Strict as H
import Data.IORef
import qualified Data.Vector as V
import OpenTelemetry.Internal.Common.Types
import OpenTelemetry.Internal.Metrics.Types


{- | Configuration for the periodic metric reader.

 @since 0.1.0.0
-}
data PeriodicReaderConfig = PeriodicReaderConfig
  { periodicReaderInterval :: Int
  -- ^ The interval in milliseconds between metric collections.
  -- Default is 60000 (60 seconds).
  , periodicReaderTimeout :: Int
  -- ^ The timeout in milliseconds for exporting metrics.
  -- Default is 30000 (30 seconds).
  }
  deriving (Show, Eq)


{- | Default periodic reader configuration.

 - Interval: 60000 milliseconds (60 seconds)
 - Timeout: 30000 milliseconds (30 seconds)

 @since 0.1.0.0
-}
defaultPeriodicReaderConfig :: PeriodicReaderConfig
defaultPeriodicReaderConfig =
  PeriodicReaderConfig
    { periodicReaderInterval = 60000
    , periodicReaderTimeout = 30000
    }


{- | Create a periodic metric reader that exports metrics at regular intervals.

 The reader will spawn a background thread that collects metrics at the
 specified interval and exports them using the provided exporter.

 @since 0.1.0.0
-}
periodicReader
  :: PeriodicReaderConfig
  -- ^ Reader configuration
  -> MetricExporter
  -- ^ Exporter to send metrics to
  -> IO (MetricReader, IO ())
  -- ^ Returns the reader and a shutdown action
periodicReader PeriodicReaderConfig {..} exporter = do
  -- Storage for registered metric producers
  producersRef <- newIORef []

  -- Shutdown signal
  shutdownRef <- newIORef False

  let
    collectMetrics :: IO [ScopeMetrics]
    collectMetrics = do
      producers <- readIORef producersRef
      concat <$> mapM ($ ()) producers

    exportLoop :: IO ()
    exportLoop = forever $ do
      threadDelay (periodicReaderInterval * 1000) -- Convert ms to microseconds
      shouldShutdown <- readIORef shutdownRef
      when (not shouldShutdown) $ do
        metrics <- collectMetrics
        let grouped = groupByLibrary metrics
        _ <- metricExporterExport exporter grouped
        pure ()

  -- Start background export thread
  exportThread <- async exportLoop

  let
    reader =
      MetricReader
        { metricReaderCollect = collectMetrics
        , metricReaderForceFlush = do
            metrics <- collectMetrics
            let grouped = groupByLibrary metrics
            _ <- metricExporterExport exporter grouped
            pure ()
        , metricReaderShutdown = async $ do
            atomicWriteIORef shutdownRef True
            cancel exportThread
            metricExporterShutdown exporter
            pure ShutdownSuccess
        }

    shutdown = do
      atomicWriteIORef shutdownRef True
      cancel exportThread
      metricExporterShutdown exporter

  pure (reader, shutdown)


{- | Create a manual metric reader that only exports when explicitly flushed.

 This is useful for testing or scenarios where you want full control over
 when metrics are exported.

 @since 0.1.0.0
-}
manualReader
  :: MetricExporter
  -- ^ Exporter to send metrics to
  -> IO (MetricReader, IO ())
  -- ^ Returns the reader and a shutdown action
manualReader exporter = do
  producersRef <- newIORef []

  let
    collectMetrics :: IO [ScopeMetrics]
    collectMetrics = do
      producers <- readIORef producersRef
      concat <$> mapM ($ ()) producers

    reader =
      MetricReader
        { metricReaderCollect = collectMetrics
        , metricReaderForceFlush = do
            metrics <- collectMetrics
            let grouped = groupByLibrary metrics
            _ <- metricExporterExport exporter grouped
            pure ()
        , metricReaderShutdown = async $ do
            metricExporterShutdown exporter
            pure ShutdownSuccess
        }

    shutdown = metricExporterShutdown exporter

  pure (reader, shutdown)


{- | Group metrics by instrumentation library.

 This is required by the MetricExporter interface which expects metrics
 grouped by library.
-}
groupByLibrary :: [ScopeMetrics] -> HashMap InstrumentationLibrary (Vector MetricData)
groupByLibrary scopeMetrics =
  foldl
    ( \acc ScopeMetrics {..} ->
        H.insertWith (V.++) scopeMetricsScope scopeMetricsMetrics acc
    )
    H.empty
    scopeMetrics
