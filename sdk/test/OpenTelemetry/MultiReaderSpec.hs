{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.MultiReaderSpec (spec) where

import Control.Exception (bracket)
import Control.Monad (void)
import Data.IORef
import qualified Data.Text as T
import qualified Data.Vector as V
import Network.HTTP.Types (status200)
import qualified Network.Wai as W
import Network.Wai.Handler.Warp (testWithApplication)
import OpenTelemetry.Attributes (emptyAttributes)
import OpenTelemetry.Configuration.Create (OTelSignals (..), createFromConfig)
import OpenTelemetry.Configuration.Parse (parseConfigBytes)
import OpenTelemetry.Exporter.Metric
import OpenTelemetry.Internal.Common.Types
import OpenTelemetry.MeterProvider
import OpenTelemetry.Metric.Core
import OpenTelemetry.Metric.MultiReader
import OpenTelemetry.Resource (emptyMaterializedResources)
import Test.Hspec


spec :: Spec
spec = describe "independent metric readers" $ do
  it "rejects a shared exporter instance across readers" $ do
    ex <- exporter
    createMeterProviderWithReaders
      emptyMaterializedResources
      defaultSdkMeterProviderOptions
      [MetricReader ex cumulativeTemporality, MetricReader ex deltaTemporality]
      `shouldThrow` anyIOException

  it "keeps cumulative and delta counter/histogram state independent" $ do
    a <- exporter
    b <- exporter
    (provider, [cumulative, delta]) <-
      createMeterProviderWithReaders
        emptyMaterializedResources
        defaultSdkMeterProviderOptions
        [MetricReader a cumulativeTemporality, MetricReader b deltaTemporality]
    meter <- getMeter provider "readers"
    counter <- meterCreateCounterInt64 meter "counter" Nothing Nothing defaultAdvisoryParameters
    histogram <- meterCreateHistogram meter "histogram" Nothing Nothing defaultAdvisoryParameters
    counterAdd counter 5 emptyAttributes
    histogramRecord histogram 5 emptyAttributes
    firstDelta <- collect delta
    firstCumulative <- collect cumulative
    sumValues firstDelta `shouldBe` [IntNumber 5]
    sumValues firstCumulative `shouldBe` [IntNumber 5]
    counterAdd counter 7 emptyAttributes
    histogramRecord histogram 7 emptyAttributes
    secondCumulative <- collect cumulative
    secondDelta <- collect delta
    sumValues secondCumulative `shouldBe` [IntNumber 12]
    sumValues secondDelta `shouldBe` [IntNumber 7]
    histCounts secondCumulative `shouldBe` [2]
    histCounts secondDelta `shouldBe` [1]
    let [firstPoint] = sumPoints firstDelta
        [secondPoint] = sumPoints secondDelta
    sumDataPointStartTimeUnixNano secondPoint `shouldBe` sumDataPointTimeUnixNano firstPoint
    shutdownMeterProvider provider Nothing `shouldReturn` ShutdownSuccess

  it "honors the reader's temporality selector for each instrument kind" $ do
    ex <- exporter
    let choose KindHistogram = AggregationCumulative
        choose _ = AggregationDelta
    (provider, [env]) <- createMeterProviderWithReaders emptyMaterializedResources defaultSdkMeterProviderOptions [MetricReader ex choose]
    meter <- getMeter provider "mixed"
    counter <- meterCreateCounterInt64 meter "counter" Nothing Nothing defaultAdvisoryParameters
    histogram <- meterCreateHistogram meter "histogram" Nothing Nothing defaultAdvisoryParameters
    counterAdd counter 5 emptyAttributes
    histogramRecord histogram 5 emptyAttributes
    void $ collect env
    counterAdd counter 7 emptyAttributes
    histogramRecord histogram 7 emptyAttributes
    result <- collect env
    sumValues result `shouldBe` [IntNumber 7]
    histCounts result `shouldBe` [2]
    shutdownMeterProvider provider Nothing `shouldReturn` ShutdownSuccess

  it "runs observable callbacks only for the reader being collected" $ do
    a <- exporter
    b <- exporter
    calls <- newIORef (0 :: Int)
    (provider, [first, second]) <-
      createMeterProviderWithReaders
        emptyMaterializedResources
        defaultSdkMeterProviderOptions
        [MetricReader a cumulativeTemporality, MetricReader b cumulativeTemporality]
    meter <- getMeter provider "callbacks"
    void $
      meterCreateObservableGaugeInt64
        meter
        "gauge"
        Nothing
        Nothing
        defaultAdvisoryParameters
        [\result -> modifyIORef' calls (+ 1) >> observe result 9 emptyAttributes]
    void $ collect first
    readIORef calls `shouldReturn` 1
    void $ collect second
    readIORef calls `shouldReturn` 2
    shutdownMeterProvider provider Nothing `shouldReturn` ShutdownSuccess

  it "flushes and shuts down every reader exactly once" $ do
    first <- newIORef ([] :: [String])
    second <- newIORef ([] :: [String])
    let ex ref =
          MetricExporter
            (\_ -> modifyIORef' ref (<> ["export"]) >> pure Success)
            (modifyIORef' ref (<> ["shutdown"]) >> pure ShutdownSuccess)
            (modifyIORef' ref (<> ["flush"]) >> pure FlushSuccess)
    (provider, _) <-
      createMeterProviderWithReaders
        emptyMaterializedResources
        defaultSdkMeterProviderOptions
        [MetricReader (ex first) cumulativeTemporality, MetricReader (ex second) deltaTemporality]
    forceFlushMeterProvider provider Nothing `shouldReturn` FlushSuccess
    shutdownMeterProvider provider Nothing `shouldReturn` ShutdownSuccess
    shutdownMeterProvider provider Nothing `shouldReturn` ShutdownSuccess
    readIORef first `shouldReturn` ["export", "flush", "export", "flush", "shutdown"]
    readIORef second `shouldReturn` ["export", "flush", "export", "flush", "shutdown"]

  it "does not silently ignore the second declarative periodic reader" $ do
    first <- newIORef (0 :: Int)
    second <- newIORef (0 :: Int)
    let app ref _ respond = modifyIORef' ref (+ 1) >> respond (W.responseLBS status200 [] "")
    testWithApplication (pure (app first)) $ \portA ->
      testWithApplication (pure (app second)) $ \portB -> do
        let reader port =
              T.unlines
                ["    - periodic:", "        interval: 600000", "        exporter:", "          otlp_http:", "            endpoint: http://127.0.0.1:" <> T.pack (show port)]
            yaml = "file_format: '1.0'\nmeter_provider:\n  readers:\n" <> reader portA <> reader portB
        parsed <- parseConfigBytes yaml
        cfg <- either (fail . show) pure parsed
        bracket (createFromConfig cfg) otelShutdown $ \components -> do
          meter <- getMeter (otelMeterProvider components) "configured"
          counter <- meterCreateCounterInt64 meter "requests" Nothing Nothing defaultAdvisoryParameters
          counterAdd counter 1 emptyAttributes
          forceFlushMeterProvider (otelMeterProvider components) Nothing `shouldReturn` FlushSuccess
          readIORef first >>= (`shouldSatisfy` (> 0))
          readIORef second >>= (`shouldSatisfy` (> 0))


exporter :: IO MetricExporter
exporter = do
  -- Each reader deliberately receives a distinct exporter instance.
  calls <- newIORef (0 :: Int)
  pure $ MetricExporter (\_ -> modifyIORef' calls (+ 1) >> pure Success) (pure ShutdownSuccess) (pure FlushSuccess)


collect :: SdkMeterEnv -> IO [MetricExport]
collect env = do
  batches <- collectResourceMetrics env
  pure [metric | batch <- batches, scope <- V.toList (resourceMetricsScopes batch), metric <- V.toList (scopeMetricsExports scope)]


sumPoints :: [MetricExport] -> [SumDataPoint]
sumPoints metrics = [p | MetricExportSum {mesSumPoints = points} <- metrics, p <- V.toList points]


sumValues :: [MetricExport] -> [NumberValue]
sumValues = map sumDataPointValue . sumPoints


histCounts metrics = [histogramDataPointCount p | MetricExportHistogram {mehPoints = points} <- metrics, p <- V.toList points]
