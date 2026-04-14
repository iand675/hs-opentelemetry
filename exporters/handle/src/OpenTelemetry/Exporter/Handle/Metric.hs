{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

{- |
Module      :  OpenTelemetry.Exporter.Handle.Metric
Copyright   :  (c) Ian Duncan, 2024-2026
License     :  BSD-3
Description :  Console \/ handle metric exporter (@OTEL_METRICS_EXPORTER=console@).
Stability   :  experimental

Renders each export batch using 'OpenTelemetry.Debug.MetricExport.renderResourceMetricsExportDebug'
and writes the text to the given 'Handle'.
-}
module OpenTelemetry.Exporter.Handle.Metric (
  makeHandleMetricExporter,
  stdoutMetricExporter,
  stderrMetricExporter,
) where

import Control.Monad.IO.Class (MonadIO)
import qualified Data.Text.IO as TIO
import qualified Data.Vector as V
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
        TIO.hPutStr h (renderResourceMetricsExportDebug (V.toList batches))
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
