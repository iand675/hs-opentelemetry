{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.MetricReaderSpec (spec) where

import Data.IORef
import qualified Data.Vector as V
import OpenTelemetry.Exporter.Metric (
  MetricExporter (..),
 )
import OpenTelemetry.Internal.Common.Types (ExportResult (..), FlushResult (..), ShutdownResult (..), instrumentationLibrary)
import OpenTelemetry.MeterProvider (
  MetricReader (..),
  SdkMeterEnv (..),
  SdkMeterProviderOptions (..),
  createMeterProvider,
  cumulativeTemporality,
  defaultSdkMeterProviderOptions,
 )
import OpenTelemetry.Metric.Core (Counter (..), getMeter)
import OpenTelemetry.MetricReader
import OpenTelemetry.Resource (emptyMaterializedResources)
import System.Environment (setEnv, unsetEnv)
import Test.Hspec


spec :: Spec
spec = describe "MetricReader" $ do
  -- Metrics SDK §MetricReader (periodic reader defaults)
  -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#metricreader
  describe "defaultPeriodicMetricReaderOptions" $ do
    -- Metrics SDK §Periodic exporting MetricReader: default export interval
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#periodic-exporting-metricreader
    it "has 60s interval" $ do
      periodicIntervalMicros defaultPeriodicMetricReaderOptions `shouldBe` 60_000_000

    -- Metrics SDK §Periodic exporting MetricReader: export timeout
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#periodic-exporting-metricreader
    it "has 30s timeout" $ do
      periodicExportTimeoutMicros defaultPeriodicMetricReaderOptions `shouldBe` 30_000_000

  describe "periodicMetricReaderOptionsFromEnv" $ do
    -- Configuration env: OTEL_METRIC_EXPORT_INTERVAL / OTEL_METRIC_EXPORT_TIMEOUT
    -- https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/
    it "reads OTEL_METRIC_EXPORT_INTERVAL" $ do
      setEnv "OTEL_METRIC_EXPORT_INTERVAL" "5000"
      setEnv "OTEL_METRIC_EXPORT_TIMEOUT" "2000"
      opts <- periodicMetricReaderOptionsFromEnv
      periodicIntervalMicros opts `shouldBe` 5_000_000
      periodicExportTimeoutMicros opts `shouldBe` 2_000_000
      unsetEnv "OTEL_METRIC_EXPORT_INTERVAL"
      unsetEnv "OTEL_METRIC_EXPORT_TIMEOUT"

    -- Implementation-specific: env reader falls back to defaultPeriodicMetricReaderOptions
    it "falls back to defaults when env not set" $ do
      unsetEnv "OTEL_METRIC_EXPORT_INTERVAL"
      unsetEnv "OTEL_METRIC_EXPORT_TIMEOUT"
      opts <- periodicMetricReaderOptionsFromEnv
      periodicIntervalMicros opts `shouldBe` periodicIntervalMicros defaultPeriodicMetricReaderOptions
      periodicExportTimeoutMicros opts `shouldBe` periodicExportTimeoutMicros defaultPeriodicMetricReaderOptions

  describe "exportMetricsOnce" $ do
    -- Metrics SDK §MetricReader.Collect + export pipeline (single collect)
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#collect
    it "collects and exports a single batch" $ do
      exportCountRef <- newIORef (0 :: Int)
      let exporter =
            MetricExporter
              { metricExporterExport = \_ -> do
                  modifyIORef' exportCountRef (+ 1)
                  pure Success
              , metricExporterShutdown = pure ShutdownSuccess
              , metricExporterForceFlush = pure FlushSuccess
              }
          reader =
            MetricReader
              { metricReaderExporter = exporter
              , metricReaderTemporalityFor = cumulativeTemporality
              }
      (mp, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions {readers = [reader]}
      let opts = defaultPeriodicMetricReaderOptions {periodicExportTimeoutMicros = 5_000_000}
      result <- exportMetricsOnce env reader opts
      case result of
        Success -> pure ()
        _ -> expectationFailure "expected Success"
      count <- readIORef exportCountRef
      count `shouldBe` 1

  describe "forkPeriodicMetricReader" $ do
    -- Implementation-specific: background periodic reader thread lifecycle
    it "can be started and stopped" $ do
      exportCountRef <- newIORef (0 :: Int)
      let exporter =
            MetricExporter
              { metricExporterExport = \_ -> do
                  modifyIORef' exportCountRef (+ 1)
                  pure Success
              , metricExporterShutdown = pure ShutdownSuccess
              , metricExporterForceFlush = pure FlushSuccess
              }
          reader =
            MetricReader
              { metricReaderExporter = exporter
              , metricReaderTemporalityFor = cumulativeTemporality
              }
          opts =
            PeriodicMetricReaderOptions
              { periodicIntervalMicros = 100_000
              , periodicExportTimeoutMicros = 5_000_000
              }
      (mp, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions {readers = [reader]}
      handle <- forkPeriodicMetricReader env reader opts
      stopPeriodicMetricReader handle
      count <- readIORef exportCountRef
      count `shouldSatisfy` (>= 1)
