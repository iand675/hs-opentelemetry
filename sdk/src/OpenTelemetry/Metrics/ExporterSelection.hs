{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

{- | Wire @OTEL_METRICS_EXPORTER@ to a concrete 'MetricExporter' (and optional periodic reader).

When the environment variable is unset the default is @otlp@.
-}
module OpenTelemetry.Metrics.ExporterSelection (
  resolveMetricExporter,
) where

import OpenTelemetry.Environment (MetricsExporterSelection (..), lookupMetricsExporterSelection)
import OpenTelemetry.Exporter.Handle.Metric (stdoutMetricExporter)
import OpenTelemetry.Exporter.Metric (MetricExporter (..))
import OpenTelemetry.Exporter.OTLP.Metric (otlpMetricExporter)
import OpenTelemetry.Exporter.OTLP.Span (loadExporterEnvironmentVariables)
import OpenTelemetry.Internal.Common.Types (ExportResult (..), FlushResult (..), ShutdownResult (..))


-- | Select a 'MetricExporter' based on @OTEL_METRICS_EXPORTER@.
--
-- * @otlp@ (default) — OTLP HTTP\/Protobuf
-- * @console@ — human-readable text to stdout
-- * @prometheus@ — returns a no-op push exporter; Prometheus is pull-based,
--   so the caller should expose an HTTP endpoint using 'OpenTelemetry.Exporter.Prometheus.renderPrometheusText'.
-- * @none@ — disabled (export calls succeed but discard data)
resolveMetricExporter :: IO MetricExporter
resolveMetricExporter = do
  sel <- lookupMetricsExporterSelection
  case sel of
    Just MetricsExporterNone -> pure noopExporter
    Just MetricsExporterConsole -> stdoutMetricExporter
    Just MetricsExporterPrometheus -> pure noopExporter
    Just MetricsExporterOtlp -> mkOtlp
    Nothing -> mkOtlp
  where
    mkOtlp = do
      conf <- loadExporterEnvironmentVariables
      otlpMetricExporter conf


noopExporter :: MetricExporter
noopExporter =
  MetricExporter
    { metricExporterExport = \_ -> pure Success
    , metricExporterShutdown = pure ShutdownSuccess
    , metricExporterForceFlush = pure FlushSuccess
    }
