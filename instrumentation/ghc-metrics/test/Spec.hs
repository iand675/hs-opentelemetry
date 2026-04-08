{-# LANGUAGE CPP #-}
{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import qualified Data.Text as T
import qualified Data.Vector as V
import OpenTelemetry.Exporter.Metric (
  MetricExport (..),
  ResourceMetricsExport (..),
  ScopeMetricsExport (..),
 )
import OpenTelemetry.Instrumentation.GHCMetrics (registerGHCMetrics)
import OpenTelemetry.Instrumentation.ProcessMetrics (registerProcessMetrics)
import OpenTelemetry.Internal.Common.Types (instrumentationLibrary)
import OpenTelemetry.MeterProvider (
  collectResourceMetrics,
  createMeterProvider,
  cumulativeTemporality,
  defaultSdkMeterProviderOptions,
 )
import OpenTelemetry.Metric.Core (getMeter)
import OpenTelemetry.Resource (emptyMaterializedResources)
import Test.Hspec


expectedBaseCount :: Int
#if MIN_VERSION_base(4,18,0)
expectedBaseCount = 43
#else
expectedBaseCount = 42
#endif


-- process.cpu.time, process.memory.usage, process.uptime,
-- process.paging.faults, process.context_switches,
-- process.runtime.ghc.capability.count = 6 callbacks
-- On Linux: +1 process.memory.virtual, +1 process.thread.count,
-- +1 process.unix.file_descriptor.count, +1 process.disk.io = 10
expectedProcessCount :: Int
#if defined(linux_HOST_OS)
expectedProcessCount = 10
#else
expectedProcessCount = 6
#endif


main :: IO ()
main = hspec spec


spec :: Spec
spec = do
  describe "GHCMetrics" $ do
    it "registers all observable instruments" $ do
      (provider, _env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider (instrumentationLibrary "test.ghc-metrics" "0.1.0")
      handles <- registerGHCMetrics m
      length handles `shouldBe` expectedBaseCount

    it "produces metrics with process.runtime.ghc. prefix" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider (instrumentationLibrary "test.ghc-metrics" "0.1.0")
      _ <- registerGHCMetrics m
      batches <- collectResourceMetrics env cumulativeTemporality
      let names = concatMap extractMetricNames (V.toList batches)
      names `shouldSatisfy` all (T.isPrefixOf "process.runtime.ghc.")
      length names `shouldBe` expectedBaseCount

    it "reports allocated_bytes > 0" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider (instrumentationLibrary "test.ghc-metrics" "0.1.0")
      _ <- registerGHCMetrics m
      batches <- collectResourceMetrics env cumulativeTemporality
      let names = concatMap extractMetricNames (V.toList batches)
      names `shouldSatisfy` elem "process.runtime.ghc.allocated_bytes"

    it "reports expected counter and gauge names" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider (instrumentationLibrary "test.ghc-metrics" "0.1.0")
      _ <- registerGHCMetrics m
      batches <- collectResourceMetrics env cumulativeTemporality
      let names = concatMap extractMetricNames (V.toList batches)

      names `shouldSatisfy` elem "process.runtime.ghc.gc.count"
      names `shouldSatisfy` elem "process.runtime.ghc.gc.cpu_time"
      names `shouldSatisfy` elem "process.runtime.ghc.gc.par_copied_bytes"
      names `shouldSatisfy` elem "process.runtime.ghc.gc.cumulative_live_bytes"
      names `shouldSatisfy` elem "process.runtime.ghc.mutator.cpu_time"
      names `shouldSatisfy` elem "process.runtime.ghc.init.cpu_time"
      names `shouldSatisfy` elem "process.runtime.ghc.cpu_time"
      names `shouldSatisfy` elem "process.runtime.ghc.elapsed_time"
      names `shouldSatisfy` elem "process.runtime.ghc.nonmoving_gc.sync.cpu_time"
      names `shouldSatisfy` elem "process.runtime.ghc.nonmoving_gc.cpu_time"

      names `shouldSatisfy` elem "process.runtime.ghc.memory.max_live_bytes"
      names `shouldSatisfy` elem "process.runtime.ghc.memory.max_large_objects_bytes"
      names `shouldSatisfy` elem "process.runtime.ghc.memory.max_compact_bytes"
      names `shouldSatisfy` elem "process.runtime.ghc.memory.max_slop_bytes"

      names `shouldSatisfy` elem "process.runtime.ghc.memory.live_bytes"
      names `shouldSatisfy` elem "process.runtime.ghc.memory.heap_size"
      names `shouldSatisfy` elem "process.runtime.ghc.gc.last.gen"
      names `shouldSatisfy` elem "process.runtime.ghc.gc.last.threads"
      names `shouldSatisfy` elem "process.runtime.ghc.gc.last.allocated_bytes"
      names `shouldSatisfy` elem "process.runtime.ghc.gc.last.slop_bytes"
      names `shouldSatisfy` elem "process.runtime.ghc.gc.last.cpu_time"
      names `shouldSatisfy` elem "process.runtime.ghc.gc.last.nonmoving_gc_sync_cpu_time"

  describe "ProcessMetrics" $ do
    it "registers expected number of callbacks" $ do
      (provider, _env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider (instrumentationLibrary "test.process-metrics" "0.1.0")
      handles <- registerProcessMetrics m
      length handles `shouldBe` expectedProcessCount

    it "produces process.cpu.time metric" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider (instrumentationLibrary "test.process-metrics" "0.1.0")
      _ <- registerProcessMetrics m
      batches <- collectResourceMetrics env cumulativeTemporality
      let names = concatMap extractMetricNames (V.toList batches)
      names `shouldSatisfy` elem "process.cpu.time"

    it "produces process.memory.usage metric" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider (instrumentationLibrary "test.process-metrics" "0.1.0")
      _ <- registerProcessMetrics m
      batches <- collectResourceMetrics env cumulativeTemporality
      let names = concatMap extractMetricNames (V.toList batches)
      names `shouldSatisfy` elem "process.memory.usage"

    it "produces process.uptime metric" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider (instrumentationLibrary "test.process-metrics" "0.1.0")
      _ <- registerProcessMetrics m
      batches <- collectResourceMetrics env cumulativeTemporality
      let names = concatMap extractMetricNames (V.toList batches)
      names `shouldSatisfy` elem "process.uptime"

    it "produces process.paging.faults metric" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider (instrumentationLibrary "test.process-metrics" "0.1.0")
      _ <- registerProcessMetrics m
      batches <- collectResourceMetrics env cumulativeTemporality
      let names = concatMap extractMetricNames (V.toList batches)
      names `shouldSatisfy` elem "process.paging.faults"

    it "produces process.context_switches metric" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider (instrumentationLibrary "test.process-metrics" "0.1.0")
      _ <- registerProcessMetrics m
      batches <- collectResourceMetrics env cumulativeTemporality
      let names = concatMap extractMetricNames (V.toList batches)
      names `shouldSatisfy` elem "process.context_switches"

    it "produces process.runtime.ghc.capability.count metric" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider (instrumentationLibrary "test.process-metrics" "0.1.0")
      _ <- registerProcessMetrics m
      batches <- collectResourceMetrics env cumulativeTemporality
      let names = concatMap extractMetricNames (V.toList batches)
      names `shouldSatisfy` elem "process.runtime.ghc.capability.count"

#if defined(linux_HOST_OS)
    it "produces process.thread.count metric on Linux" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider (instrumentationLibrary "test.process-metrics" "0.1.0")
      _ <- registerProcessMetrics m
      batches <- collectResourceMetrics env cumulativeTemporality
      let names = concatMap extractMetricNames (V.toList batches)
      names `shouldSatisfy` elem "process.thread.count"

    it "produces process.unix.file_descriptor.count metric on Linux" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider (instrumentationLibrary "test.process-metrics" "0.1.0")
      _ <- registerProcessMetrics m
      batches <- collectResourceMetrics env cumulativeTemporality
      let names = concatMap extractMetricNames (V.toList batches)
      names `shouldSatisfy` elem "process.unix.file_descriptor.count"

    it "produces process.disk.io metric on Linux" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider (instrumentationLibrary "test.process-metrics" "0.1.0")
      _ <- registerProcessMetrics m
      batches <- collectResourceMetrics env cumulativeTemporality
      let names = concatMap extractMetricNames (V.toList batches)
      names `shouldSatisfy` elem "process.disk.io"
#endif

    it "reports non-negative uptime" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider (instrumentationLibrary "test.process-metrics" "0.1.0")
      _ <- registerProcessMetrics m
      batches <- collectResourceMetrics env cumulativeTemporality
      let names = concatMap extractMetricNames (V.toList batches)
      names `shouldSatisfy` elem "process.uptime"


extractMetricNames :: ResourceMetricsExport -> [T.Text]
extractMetricNames rme =
  concatMap scopeNames (V.toList (resourceMetricsScopes rme))
  where
    scopeNames sme = fmap metricExportName (V.toList (scopeMetricsExports sme))
    metricExportName (MetricExportSum {mesName = n}) = n
    metricExportName (MetricExportGauge {megName = n}) = n
    metricExportName (MetricExportHistogram {mehName = n}) = n
    metricExportName (MetricExportExponentialHistogram {meehName = n}) = n
