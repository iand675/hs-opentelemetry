{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

{- | Console \/ handle metric exporter (@OTEL_METRICS_EXPORTER=console@).

Renders each export batch using 'OpenTelemetry.Debug.MetricExport.renderResourceMetricsExportDebug'
and writes the text to the given 'Handle'.
-}
module OpenTelemetry.Exporter.Handle.Metric (
  makeHandleMetricExporter,
  stdoutMetricExporter,
  stderrMetricExporter,
) where

import Control.Monad.IO.Class (MonadIO, liftIO)
import qualified Data.Text.IO as TIO
import OpenTelemetry.Debug.MetricExport (renderResourceMetricsExportDebug)
import OpenTelemetry.Exporter.Metric (
  MetricExporter (..),
 )
import OpenTelemetry.Internal.Common.Types (ExportResult (..), FlushResult (..), ShutdownResult (..))
import System.IO (Handle, hFlush, hPutChar, stderr, stdout)


makeHandleMetricExporter :: Handle -> MetricExporter
makeHandleMetricExporter h =
  MetricExporter
    { metricExporterExport = \batches -> do
        TIO.hPutStr h (renderResourceMetricsExportDebug batches)
        hPutChar h '\n'
        hFlush h
        pure Success
    , metricExporterShutdown = do
        hFlush h
        pure ShutdownSuccess
    , metricExporterForceFlush = do
        hFlush h
        pure FlushSuccess
    }


stdoutMetricExporter :: (MonadIO m) => m MetricExporter
stdoutMetricExporter = pure (makeHandleMetricExporter stdout)


stderrMetricExporter :: (MonadIO m) => m MetricExporter
stderrMetricExporter = pure (makeHandleMetricExporter stderr)
