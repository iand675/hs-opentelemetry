{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Control.Exception (bracket)
import Control.Monad (void)
import Data.IORef (modifyIORef', newIORef, readIORef)
import Data.Text (Text)
import qualified Data.Vector as V
import OpenTelemetry.Attributes (emptyAttributes)
import OpenTelemetry.Exporter.Metric
import OpenTelemetry.MeterProvider (collectResourceMetrics, createMeterProvider, defaultSdkMeterProviderOptions)
import OpenTelemetry.Metric.Core
import OpenTelemetry.Resource (emptyMaterializedResources)
import qualified OpenTelemetry.SemanticConventions.Metrics as SC
import Test.Hspec


main :: IO ()
main = hspec $ do
  describe "generated metric constructors" $ do
    it "uses the duration histogram name, seconds and upstream description" $ do
      (meter, calls) <- captureMeter
      void $ SC.create_http_server_request_duration meter advisory
      calls `shouldReturn` [Call "histogram" "http.server.request.duration" (Just "s") (Just "Duration of HTTP server requests.") advisory]

    it "creates an integer up/down counter with its count unit" $ do
      (meter, calls) <- captureMeter
      void $ SC.create_http_server_activeRequests_int64 meter advisory
      calls `shouldReturn` [Call "updown/int64" "http.server.active_requests" (Just "{request}") (Just "Number of active HTTP server requests.") advisory]

    it "uses the floating-point counter factory for CPU time" $ do
      (meter, calls) <- captureMeter
      void $ SC.create_system_cpu_time_double meter advisory
      calls `shouldReturn` [Call "counter/double" "system.cpu.time" (Just "s") (Just "Seconds each logical CPU spent on each mode.") advisory]

    it "keeps underscore and dot-separated metric names distinct" $ do
      (meter, calls) <- captureMeter
      void $ SC.create_k8s_container_cpu_requestUtilization_double meter advisory
      void $ SC.create_k8s_container_cpu_request_utilization_double meter advisory
      names <- map callName <$> calls
      names `shouldBe` ["k8s.container.cpu.request_utilization", "k8s.container.cpu.request.utilization"]

    it "offers both numeric counter variants for an unspecified registry type" $ do
      (meter, calls) <- captureMeter
      void $ SC.create_nfs_client_rpc_count_int64 meter advisory
      void $ SC.create_nfs_client_rpc_count_double meter advisory
      result <- calls
      map callFactory result `shouldBe` ["counter/int64", "counter/double"]
      map callName result `shouldBe` replicate 2 "nfs.client.rpc.count"
      map callDescription result `shouldBe` replicate 2 (Just "Reports the count of kernel NFS client RPCs sent, regardless of whether they're accepted/rejected by the server.")

    it "uses the histogram API for integer-valued size metrics" $ do
      (meter, calls) <- captureMeter
      void $ SC.create_http_server_request_body_size meter advisory
      result <- calls
      map callFactory result `shouldBe` ["histogram"]
      map callUnit result `shouldBe` [Just "By"]

    it "selects integer and floating-point gauge factories" $ do
      (meter, calls) <- captureMeter
      void $ SC.create_cpu_frequency_int64 meter advisory
      void $ SC.create_system_cpu_utilization_double meter advisory
      result <- calls
      map callFactory result `shouldBe` ["gauge/int64", "gauge/double"]
      map callUnit result `shouldBe` [Just "{Hz}", Just "1"]

    it "creates floating-point up/down counters" $ do
      (meter, calls) <- captureMeter
      void $ SC.create_go_config_gogc_double meter advisory
      result <- calls
      map callFactory result `shouldBe` ["updown/double"]
      map callUnit result `shouldBe` [Just "%"]

    it "selects all observable factories and passes advisory settings" $ do
      (meter, calls) <- captureMeter
      void $ SC.create_observable_nfs_client_rpc_count_int64 meter advisory []
      void $ SC.create_observable_system_cpu_time_double meter advisory []
      void $ SC.create_observable_jvm_memory_used_int64 meter advisory []
      void $ SC.create_observable_go_config_gogc_double meter advisory []
      void $ SC.create_observable_cpu_frequency_int64 meter advisory []
      void $ SC.create_observable_system_cpu_utilization_double meter advisory []
      result <- calls
      map callFactory result
        `shouldBe` [ "observable-counter/int64"
                   , "observable-counter/double"
                   , "observable-updown/int64"
                   , "observable-updown/double"
                   , "observable-gauge/int64"
                   , "observable-gauge/double"
                   ]
      map callAdvisory result `shouldBe` replicate 6 advisory

  describe "SDK collection" $ do
    it "collects names, units, values, callbacks and explicit buckets"
      $ bracket
        (createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions)
        (\(provider, _) -> void $ shutdownMeterProvider provider Nothing)
      $ \(provider, env) -> do
        meter <- getMeter provider "generated-metric-tests"
        histogram <- SC.create_http_server_request_duration meter advisory
        counter <- SC.create_nfs_client_rpc_count_int64 meter defaultAdvisoryParameters
        callbackCount <- newIORef (0 :: Int)
        void $
          SC.create_observable_system_cpu_utilization_double
            meter
            defaultAdvisoryParameters
            [\result -> modifyIORef' callbackCount (+ 1) >> observe result 0.75 emptyAttributes]
        histogramRecord histogram 0.125 emptyAttributes
        counterAdd counter 5 emptyAttributes
        batches <- collectResourceMetrics env
        let metrics = concatMap (concatMap (V.toList . scopeMetricsExports) . V.toList . resourceMetricsScopes) batches
        length metrics `shouldBe` 3
        readIORef callbackCount `shouldReturn` 1
        case [metric | metric@MetricExportHistogram {} <- metrics] of
          [MetricExportHistogram {mehName = name, mehDescription = description, mehUnit = unit, mehPoints = points}] -> do
            name `shouldBe` "http.server.request.duration"
            description `shouldBe` "Duration of HTTP server requests."
            unit `shouldBe` "s"
            map histogramDataPointCount (V.toList points) `shouldBe` [1]
            map (V.toList . histogramDataPointExplicitBounds) (V.toList points) `shouldBe` [[0.1, 0.25]]
            map (V.toList . histogramDataPointBucketCounts) (V.toList points) `shouldBe` [[0, 1, 0]]
          _ -> expectationFailure "expected one duration histogram"
        case [metric | metric@MetricExportSum {} <- metrics] of
          [MetricExportSum {mesName = name, mesUnit = unit, mesIsInt = isInt, mesMonotonic = monotonic, mesSumPoints = points}] -> do
            name `shouldBe` "nfs.client.rpc.count"
            unit `shouldBe` "{request}"
            isInt `shouldBe` True
            monotonic `shouldBe` True
            map sumDataPointValue (V.toList points) `shouldBe` [IntNumber 5]
          _ -> expectationFailure "expected one integer counter"
        case [metric | metric@MetricExportGauge {} <- metrics] of
          [MetricExportGauge {megName = name, megUnit = unit, megIsInt = isInt, megGaugePoints = points}] -> do
            name `shouldBe` "system.cpu.utilization"
            unit `shouldBe` "1"
            isInt `shouldBe` False
            map gaugeDataPointValue (V.toList points) `shouldBe` [DoubleNumber 0.75]
          _ -> expectationFailure "expected one observable floating-point gauge"


advisory :: AdvisoryParameters
advisory = defaultAdvisoryParameters {advisoryExplicitBucketBoundaries = Just [0.1, 0.25]}


data Call = Call
  { callFactory :: Text
  , callName :: Text
  , callUnit :: Maybe Text
  , callDescription :: Maybe Text
  , callAdvisory :: AdvisoryParameters
  }
  deriving (Eq, Show)


captureMeter :: IO (Meter, IO [Call])
captureMeter = do
  calls <- newIORef []
  let base = noopMeter "generated-metric-tests"
      capture factory make name unit description parameters = do
        modifyIORef' calls (<> [Call factory name unit description parameters])
        make name unit description parameters
      captureObservable factory make name unit description parameters callbacks = do
        modifyIORef' calls (<> [Call factory name unit description parameters])
        make name unit description parameters callbacks
      meter =
        base
          { meterCreateHistogram = capture "histogram" (meterCreateHistogram base)
          , meterCreateCounterInt64 = capture "counter/int64" (meterCreateCounterInt64 base)
          , meterCreateCounterDouble = capture "counter/double" (meterCreateCounterDouble base)
          , meterCreateUpDownCounterInt64 = capture "updown/int64" (meterCreateUpDownCounterInt64 base)
          , meterCreateUpDownCounterDouble = capture "updown/double" (meterCreateUpDownCounterDouble base)
          , meterCreateGaugeInt64 = capture "gauge/int64" (meterCreateGaugeInt64 base)
          , meterCreateGaugeDouble = capture "gauge/double" (meterCreateGaugeDouble base)
          , meterCreateObservableCounterInt64 = captureObservable "observable-counter/int64" (meterCreateObservableCounterInt64 base)
          , meterCreateObservableCounterDouble = captureObservable "observable-counter/double" (meterCreateObservableCounterDouble base)
          , meterCreateObservableUpDownCounterInt64 = captureObservable "observable-updown/int64" (meterCreateObservableUpDownCounterInt64 base)
          , meterCreateObservableUpDownCounterDouble = captureObservable "observable-updown/double" (meterCreateObservableUpDownCounterDouble base)
          , meterCreateObservableGaugeInt64 = captureObservable "observable-gauge/int64" (meterCreateObservableGaugeInt64 base)
          , meterCreateObservableGaugeDouble = captureObservable "observable-gauge/double" (meterCreateObservableGaugeDouble base)
          }
  pure (meter, readIORef calls)
