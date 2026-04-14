{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.MetricReaderSpec (spec) where

import Data.IORef
import OpenTelemetry.Exporter.Metric (
  MetricExporter (..),
 )
import OpenTelemetry.Internal.Common.Types (ExportResult (..), FlushResult (..), ShutdownResult (..))
import OpenTelemetry.MeterProvider (
  SdkMeterProviderOptions (..),
  createMeterProvider,
  defaultSdkMeterProviderOptions,
 )
import OpenTelemetry.MetricReader
import OpenTelemetry.Resource (emptyMaterializedResources)
import Test.Hspec


spec :: Spec
spec = describe "MetricReader" $ do
  describe "defaultPeriodicMetricReaderOptions" $ do
    it "has 60s interval" $ do
      periodicIntervalMicros defaultPeriodicMetricReaderOptions `shouldBe` 60_000_000

  describe "exportMetricsOnce" $ do
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
      (_mp, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions {metricExporter = Just exporter}
      result <- exportMetricsOnce env exporter
      case result of
        Success -> pure ()
        _ -> expectationFailure "expected Success"
      count <- readIORef exportCountRef
      count `shouldBe` 1

  describe "forkPeriodicMetricReader" $ do
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
          opts =
            PeriodicMetricReaderOptions
              { periodicIntervalMicros = 100_000
              }
      (_mp, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions {metricExporter = Just exporter}
      handle <- forkPeriodicMetricReader env exporter opts
      stopPeriodicMetricReader handle
      count <- readIORef exportCountRef
      count `shouldSatisfy` (>= 1)
