{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

{- |
Module      :  OpenTelemetry.Metric.ExporterSelection
Copyright   :  (c) Ian Duncan, 2024-2026
License     :  BSD-3
Description :  Wire @OTEL_METRICS_EXPORTER@ to a concrete 'MetricExporter' via the registry.
Stability   :  experimental

Resolves the metric exporter from @OTEL_METRICS_EXPORTER@ using the global
exporter registry. Built-in exporters (otlp, console, prometheus) are
registered automatically. Custom exporters can be registered before
SDK initialization via 'OpenTelemetry.Registry.registerMetricExporterFactory'.
-}
module OpenTelemetry.Metric.ExporterSelection (
  resolveMetricExporter,
) where

import qualified Data.HashMap.Strict as H
import qualified Data.Text as T
import OpenTelemetry.Environment (MetricsExporterSelection (..), lookupMetricsExporterSelection)
import OpenTelemetry.Exporter.Handle.Metric (stdoutMetricExporter)
import OpenTelemetry.Exporter.Metric (MetricExporter (..))
import OpenTelemetry.Exporter.OTLP.Metric (otlpMetricExporter)
import OpenTelemetry.Exporter.OTLP.Span (loadExporterEnvironmentVariables)
import OpenTelemetry.Internal.Common.Types (ExportResult (..), FlushResult (..), ShutdownResult (..))
import OpenTelemetry.Internal.Logging (otelLogWarning)
import qualified OpenTelemetry.Registry as Registry


{- | Select a 'MetricExporter' based on @OTEL_METRICS_EXPORTER@.

Built-in values:

* @otlp@ (default): OTLP HTTP\/Protobuf
* @console@: human-readable text to stdout
* @prometheus@: returns a no-op push exporter (Prometheus is pull-based)
* @none@: disabled

Any other value is looked up in the metric exporter registry. Register
custom exporters with 'OpenTelemetry.Registry.registerMetricExporterFactory'
before calling this.

@since 0.0.1.0
-}
resolveMetricExporter :: IO MetricExporter
resolveMetricExporter = do
  registerBuiltinMetricExporters
  sel <- lookupMetricsExporterSelection
  case sel of
    Just MetricsExporterNone -> pure noopExporter
    Just MetricsExporterConsole -> stdoutMetricExporter
    Just MetricsExporterPrometheus -> pure noopExporter
    Just (MetricsExporterCustom name) -> lookupByName (T.pack name)
    Just MetricsExporterOtlp -> lookupByName "otlp"
    Nothing -> lookupByName "otlp"
  where
    lookupByName name = do
      allExporters <- Registry.registeredMetricExporterFactories
      case H.lookup name allExporters of
        Just factory -> factory
        Nothing -> do
          otelLogWarning ("No metric exporter registered for '" <> T.unpack name <> "', using console")
          stdoutMetricExporter


registerBuiltinMetricExporters :: IO ()
registerBuiltinMetricExporters = do
  _ <-
    Registry.registerMetricExporterFactoryIfAbsent "otlp" $ do
      conf <- loadExporterEnvironmentVariables
      otlpMetricExporter conf
  _ <-
    Registry.registerMetricExporterFactoryIfAbsent "console" stdoutMetricExporter
  pure ()


noopExporter :: MetricExporter
noopExporter =
  MetricExporter
    { metricExporterExport = \_ -> pure Success
    , metricExporterShutdown = pure ShutdownSuccess
    , metricExporterForceFlush = pure FlushSuccess
    }
