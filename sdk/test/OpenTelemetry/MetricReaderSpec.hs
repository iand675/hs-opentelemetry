{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.MetricReaderSpec (spec) where

import Control.Concurrent (newEmptyMVar, putMVar, readMVar, threadDelay, tryPutMVar)
import Control.Concurrent.Async (async, concurrently, wait)
import Control.Exception (finally)
import Control.Monad (void)
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
import qualified OpenTelemetry.Metric.Core as M
import OpenTelemetry.MetricReader
import OpenTelemetry.Resource (emptyMaterializedResources)
import System.Timeout (timeout)
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

    it "connects provider flush to the registered periodic exporter" $ do
      exports <- newIORef (0 :: Int)
      started <- newEmptyMVar
      let ex = MetricExporter (\_ -> modifyIORef' exports (+ 1) >> void (tryPutMVar started ()) >> pure Success) (pure ShutdownSuccess) (pure FlushSuccess)
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      handle <- forkPeriodicMetricReader env ex (PeriodicMetricReaderOptions 600000000)
      readMVar started
      before <- readIORef exports
      M.forceFlushMeterProvider provider Nothing `shouldReturn` FlushSuccess
      readIORef exports `shouldReturn` (before + 1)
      stopPeriodicMetricReader handle

    it "reports an export failure even when exporter flush succeeds" $ do
      let ex = MetricExporter (\_ -> pure (Failure Nothing)) (pure ShutdownSuccess) (pure FlushSuccess)
      (provider, _) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions {metricExporter = Just ex}
      M.forceFlushMeterProvider provider Nothing `shouldReturn` FlushError
      M.shutdownMeterProvider provider Nothing `shouldReturn` ShutdownFailure

    it "flushes before shutdown and shuts the exporter down only once" $ do
      calls <- newIORef ([] :: [String])
      let record x = modifyIORef' calls (<> [x])
          ex = MetricExporter (\_ -> record "export" >> pure Success) (record "shutdown" >> pure ShutdownSuccess) (record "flush" >> pure FlushSuccess)
      (provider, _) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions {metricExporter = Just ex}
      concurrently (M.shutdownMeterProvider provider Nothing) (M.shutdownMeterProvider provider Nothing) `shouldReturn` (ShutdownSuccess, ShutdownSuccess)
      M.shutdownMeterProvider provider Nothing `shouldReturn` ShutdownSuccess
      readIORef calls `shouldReturn` ["export", "flush", "shutdown"]
      M.forceFlushMeterProvider provider Nothing `shouldReturn` FlushError

    it "does not overlap periodic and manual exports" $ do
      active <- newIORef (0 :: Int)
      peak <- newIORef (0 :: Int)
      first <- newEmptyMVar
      overlap <- newEmptyMVar
      release <- newEmptyMVar
      let ex =
            MetricExporter
              ( \_ -> do
                  n <- atomicModifyIORef' active (\x -> (x + 1, x + 1))
                  atomicModifyIORef' peak (\x -> (max x n, ()))
                  void $ tryPutMVar (if n == 1 then first else overlap) ()
                  readMVar release
                  atomicModifyIORef' active (\x -> (x - 1, ()))
                  pure Success
              )
              (pure ShutdownSuccess)
              (pure FlushSuccess)
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions {metricExporter = Just ex}
      handle <- forkPeriodicMetricReader env ex (PeriodicMetricReaderOptions 600000000)
      readMVar first
      flushing <- async (M.forceFlushMeterProvider provider Nothing)
      observed <- timeout 50000 (readMVar overlap)
      putMVar release ()
      wait flushing `shouldReturn` FlushSuccess
      stopPeriodicMetricReader handle
      observed `shouldBe` Nothing
      readIORef peak `shouldReturn` 1

    it "honors provider flush timeout and releases the export lock" $ do
      let ex = MetricExporter (\_ -> threadDelay 200000 >> pure Success) (pure ShutdownSuccess) (pure FlushSuccess)
      (provider, _) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions {metricExporter = Just ex}
      timeout 100000 (M.forceFlushMeterProvider provider (Just 10000)) `shouldReturn` Just FlushTimeout
      M.forceFlushMeterProvider provider (Just 500000) `shouldReturn` FlushSuccess

    it "bounds shutdown, caches its result, and does not repeat cleanup" $ do
      calls <- newIORef (0 :: Int)
      let ex = MetricExporter (\_ -> modifyIORef' calls (+ 1) >> threadDelay 200000 >> pure Success) (pure ShutdownSuccess) (pure FlushSuccess)
      (provider, _) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions {metricExporter = Just ex}
      timeout 100000 (M.shutdownMeterProvider provider (Just 10000)) `shouldReturn` Just ShutdownTimeout
      threadDelay 20000
      M.shutdownMeterProvider provider Nothing `shouldReturn` ShutdownTimeout
      readIORef calls `shouldReturn` 1

    it "uses the explicit periodic export timeout" $ do
      started <- newEmptyMVar
      cancelled <- newEmptyMVar
      let ex = MetricExporter (\_ -> void (tryPutMVar started ()) >> (threadDelay 1000000 >> pure Success) `finally` void (tryPutMVar cancelled ())) (pure ShutdownSuccess) (pure FlushSuccess)
      (_, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      handle <- forkPeriodicMetricReaderWithTimeout env ex (PeriodicMetricReaderOptions 600000000) 10000
      readMVar started
      timeout 100000 (readMVar cancelled) `shouldReturn` Just ()
      stopPeriodicMetricReader handle
