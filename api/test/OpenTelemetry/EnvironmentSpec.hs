{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.EnvironmentSpec (spec) where

import OpenTelemetry.Environment
import System.Environment (setEnv, unsetEnv)
import Test.Hspec


spec :: Spec
spec = sequential $
  describe "Environment" $ do
    describe "lookupBooleanEnv" $ do
      it "returns False when env var is unset" $ do
        unsetEnv "OTEL_TEST_BOOL"
        result <- lookupBooleanEnv "OTEL_TEST_BOOL"
        result `shouldBe` False

      it "returns True for 'true'" $ do
        setEnv "OTEL_TEST_BOOL" "true"
        result <- lookupBooleanEnv "OTEL_TEST_BOOL"
        result `shouldBe` True
        unsetEnv "OTEL_TEST_BOOL"

      it "returns True for 'TRUE' (case-insensitive)" $ do
        setEnv "OTEL_TEST_BOOL" "TRUE"
        result <- lookupBooleanEnv "OTEL_TEST_BOOL"
        result `shouldBe` True
        unsetEnv "OTEL_TEST_BOOL"

      it "returns True for 'True'" $ do
        setEnv "OTEL_TEST_BOOL" "True"
        result <- lookupBooleanEnv "OTEL_TEST_BOOL"
        result `shouldBe` True
        unsetEnv "OTEL_TEST_BOOL"

      it "returns False for 'false'" $ do
        setEnv "OTEL_TEST_BOOL" "false"
        result <- lookupBooleanEnv "OTEL_TEST_BOOL"
        result `shouldBe` False
        unsetEnv "OTEL_TEST_BOOL"

      it "returns False for arbitrary string" $ do
        setEnv "OTEL_TEST_BOOL" "banana"
        result <- lookupBooleanEnv "OTEL_TEST_BOOL"
        result `shouldBe` False
        unsetEnv "OTEL_TEST_BOOL"

    describe "lookupMetricsExporterSelection" $ do
      it "returns Nothing when unset" $ do
        unsetEnv "OTEL_METRICS_EXPORTER"
        result <- lookupMetricsExporterSelection
        result `shouldBe` Nothing

      it "returns MetricsExporterOtlp for 'otlp'" $ do
        setEnv "OTEL_METRICS_EXPORTER" "otlp"
        result <- lookupMetricsExporterSelection
        result `shouldBe` Just MetricsExporterOtlp
        unsetEnv "OTEL_METRICS_EXPORTER"

      it "returns MetricsExporterPrometheus for 'prometheus'" $ do
        setEnv "OTEL_METRICS_EXPORTER" "prometheus"
        result <- lookupMetricsExporterSelection
        result `shouldBe` Just MetricsExporterPrometheus
        unsetEnv "OTEL_METRICS_EXPORTER"

      it "returns MetricsExporterConsole for 'console'" $ do
        setEnv "OTEL_METRICS_EXPORTER" "console"
        result <- lookupMetricsExporterSelection
        result `shouldBe` Just MetricsExporterConsole
        unsetEnv "OTEL_METRICS_EXPORTER"

      it "returns MetricsExporterNone for 'none'" $ do
        setEnv "OTEL_METRICS_EXPORTER" "none"
        result <- lookupMetricsExporterSelection
        result `shouldBe` Just MetricsExporterNone
        unsetEnv "OTEL_METRICS_EXPORTER"

      it "is case-insensitive" $ do
        setEnv "OTEL_METRICS_EXPORTER" "OTLP"
        result <- lookupMetricsExporterSelection
        result `shouldBe` Just MetricsExporterOtlp
        unsetEnv "OTEL_METRICS_EXPORTER"

      it "takes first comma-separated segment" $ do
        setEnv "OTEL_METRICS_EXPORTER" "otlp,prometheus"
        result <- lookupMetricsExporterSelection
        result `shouldBe` Just MetricsExporterOtlp
        unsetEnv "OTEL_METRICS_EXPORTER"

      it "returns Nothing for unknown value" $ do
        setEnv "OTEL_METRICS_EXPORTER" "zipkin"
        result <- lookupMetricsExporterSelection
        result `shouldBe` Nothing
        unsetEnv "OTEL_METRICS_EXPORTER"

      it "returns Nothing for empty string" $ do
        setEnv "OTEL_METRICS_EXPORTER" ""
        result <- lookupMetricsExporterSelection
        result `shouldBe` Nothing
        unsetEnv "OTEL_METRICS_EXPORTER"

      it "trims whitespace" $ do
        setEnv "OTEL_METRICS_EXPORTER" "  otlp  "
        result <- lookupMetricsExporterSelection
        result `shouldBe` Just MetricsExporterOtlp
        unsetEnv "OTEL_METRICS_EXPORTER"

    describe "lookupMetricExportIntervalMillis" $ do
      it "returns Nothing when unset" $ do
        unsetEnv "OTEL_METRIC_EXPORT_INTERVAL"
        result <- lookupMetricExportIntervalMillis
        result `shouldBe` Nothing

      it "parses valid positive integer" $ do
        setEnv "OTEL_METRIC_EXPORT_INTERVAL" "5000"
        result <- lookupMetricExportIntervalMillis
        result `shouldBe` Just 5000
        unsetEnv "OTEL_METRIC_EXPORT_INTERVAL"

      it "returns Nothing for zero" $ do
        setEnv "OTEL_METRIC_EXPORT_INTERVAL" "0"
        result <- lookupMetricExportIntervalMillis
        result `shouldBe` Nothing
        unsetEnv "OTEL_METRIC_EXPORT_INTERVAL"

      it "returns Nothing for negative" $ do
        setEnv "OTEL_METRIC_EXPORT_INTERVAL" "-100"
        result <- lookupMetricExportIntervalMillis
        result `shouldBe` Nothing
        unsetEnv "OTEL_METRIC_EXPORT_INTERVAL"

      it "returns Nothing for non-numeric" $ do
        setEnv "OTEL_METRIC_EXPORT_INTERVAL" "abc"
        result <- lookupMetricExportIntervalMillis
        result `shouldBe` Nothing
        unsetEnv "OTEL_METRIC_EXPORT_INTERVAL"

      it "trims whitespace" $ do
        setEnv "OTEL_METRIC_EXPORT_INTERVAL" "  1000  "
        result <- lookupMetricExportIntervalMillis
        result `shouldBe` Just 1000
        unsetEnv "OTEL_METRIC_EXPORT_INTERVAL"

    describe "lookupMetricsExemplarFilter" $ do
      it "returns Nothing when unset" $ do
        unsetEnv "OTEL_METRICS_EXEMPLAR_FILTER"
        result <- lookupMetricsExemplarFilter
        result `shouldBe` Nothing

      it "returns TraceBased for 'trace_based'" $ do
        setEnv "OTEL_METRICS_EXEMPLAR_FILTER" "trace_based"
        result <- lookupMetricsExemplarFilter
        result `shouldBe` Just MetricsExemplarFilterTraceBased
        unsetEnv "OTEL_METRICS_EXEMPLAR_FILTER"

      it "returns AlwaysOn for 'always_on'" $ do
        setEnv "OTEL_METRICS_EXEMPLAR_FILTER" "always_on"
        result <- lookupMetricsExemplarFilter
        result `shouldBe` Just MetricsExemplarFilterAlwaysOn
        unsetEnv "OTEL_METRICS_EXEMPLAR_FILTER"

      it "returns AlwaysOff for 'always_off'" $ do
        setEnv "OTEL_METRICS_EXEMPLAR_FILTER" "always_off"
        result <- lookupMetricsExemplarFilter
        result `shouldBe` Just MetricsExemplarFilterAlwaysOff
        unsetEnv "OTEL_METRICS_EXEMPLAR_FILTER"

      it "is case-insensitive" $ do
        setEnv "OTEL_METRICS_EXEMPLAR_FILTER" "TRACE_BASED"
        result <- lookupMetricsExemplarFilter
        result `shouldBe` Just MetricsExemplarFilterTraceBased
        unsetEnv "OTEL_METRICS_EXEMPLAR_FILTER"

      it "returns Nothing for unknown value" $ do
        setEnv "OTEL_METRICS_EXEMPLAR_FILTER" "foo"
        result <- lookupMetricsExemplarFilter
        result `shouldBe` Nothing
        unsetEnv "OTEL_METRICS_EXEMPLAR_FILTER"

    describe "lookupLogsExporterSelection" $ do
      it "returns Nothing when unset" $ do
        unsetEnv "OTEL_LOGS_EXPORTER"
        result <- lookupLogsExporterSelection
        result `shouldBe` Nothing

      it "returns LogsExporterOtlp for 'otlp'" $ do
        setEnv "OTEL_LOGS_EXPORTER" "otlp"
        result <- lookupLogsExporterSelection
        result `shouldBe` Just LogsExporterOtlp
        unsetEnv "OTEL_LOGS_EXPORTER"

      it "returns LogsExporterConsole for 'console'" $ do
        setEnv "OTEL_LOGS_EXPORTER" "console"
        result <- lookupLogsExporterSelection
        result `shouldBe` Just LogsExporterConsole
        unsetEnv "OTEL_LOGS_EXPORTER"

      it "returns LogsExporterNone for 'none'" $ do
        setEnv "OTEL_LOGS_EXPORTER" "none"
        result <- lookupLogsExporterSelection
        result `shouldBe` Just LogsExporterNone
        unsetEnv "OTEL_LOGS_EXPORTER"

      it "is case-insensitive" $ do
        setEnv "OTEL_LOGS_EXPORTER" "OTLP"
        result <- lookupLogsExporterSelection
        result `shouldBe` Just LogsExporterOtlp
        unsetEnv "OTEL_LOGS_EXPORTER"

      it "takes first comma-separated segment" $ do
        setEnv "OTEL_LOGS_EXPORTER" "otlp,console"
        result <- lookupLogsExporterSelection
        result `shouldBe` Just LogsExporterOtlp
        unsetEnv "OTEL_LOGS_EXPORTER"

      it "returns Nothing for unknown value" $ do
        setEnv "OTEL_LOGS_EXPORTER" "zipkin"
        result <- lookupLogsExporterSelection
        result `shouldBe` Nothing
        unsetEnv "OTEL_LOGS_EXPORTER"

      it "returns Nothing for empty string" $ do
        setEnv "OTEL_LOGS_EXPORTER" ""
        result <- lookupLogsExporterSelection
        result `shouldBe` Nothing
        unsetEnv "OTEL_LOGS_EXPORTER"

      it "trims whitespace" $ do
        setEnv "OTEL_LOGS_EXPORTER" "  console  "
        result <- lookupLogsExporterSelection
        result `shouldBe` Just LogsExporterConsole
        unsetEnv "OTEL_LOGS_EXPORTER"
