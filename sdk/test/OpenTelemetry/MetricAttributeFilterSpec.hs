{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.MetricAttributeFilterSpec (spec) where

import Control.Concurrent (newEmptyMVar, readMVar, tryPutMVar, yield)
import Control.Concurrent.Async (concurrently, forConcurrently_)
import Control.Exception (bracket)
import Control.Monad (forM_, replicateM, void)
import Data.List (sort)
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Vector as V
import Data.Word (Word64)
import OpenTelemetry.Attributes
import OpenTelemetry.Environment (MetricsExemplarFilter (..))
import OpenTelemetry.Exporter.Metric
import OpenTelemetry.MeterProvider
import OpenTelemetry.Metric.Core
import OpenTelemetry.Metric.View
import OpenTelemetry.Resource (emptyMaterializedResources)
import System.Environment (lookupEnv, setEnv, unsetEnv)
import Test.Hspec


data FilterMode = ViaView | ViaAdvisory
  deriving (Show)


spec :: Spec
spec = around_ withExemplars $ describe "metric attribute filtering" $ do
  forM_ [ViaView, ViaAdvisory] $ \mode -> describe (show mode) $ do
    forM_ [AggregationCumulative, AggregationDelta] $ \temp ->
      it ("aggregates retained series before cardinality admission (" <> show temp <> ")") $ do
        (meter, env, advisory) <- setup mode ["method"] temp
        counter <- meterCreateCounterInt64 meter "filtered.counter" Nothing Nothing advisory
        doubleCounter <- meterCreateCounterDouble meter "filtered.double" Nothing Nothing advisory
        updown <- meterCreateUpDownCounterInt64 meter "filtered.updown" Nothing Nothing advisory
        doubleUpdown <- meterCreateUpDownCounterDouble meter "filtered.double.updown" Nothing Nothing advisory
        histogram <- meterCreateHistogram meter "filtered.histogram" Nothing Nothing advisory
        exponential <-
          meterCreateHistogram
            meter
            "filtered.exponential"
            Nothing
            Nothing
            advisory {advisoryHistogramAggregation = Just (HistogramAggregationExponential 2)}
        gauge <- meterCreateGaugeInt64 meter "filtered.gauge" Nothing Nothing advisory
        doubleGauge <- meterCreateGaugeDouble meter "filtered.double.gauge" Nothing Nothing advisory
        let record n attrs = do
              counterAdd counter (round n) attrs
              counterAdd doubleCounter n attrs
              upDownCounterAdd updown (negate (round n)) attrs
              upDownCounterAdd doubleUpdown (-n) attrs
              histogramRecord histogram n attrs
              histogramRecord exponential n attrs
              gaugeRecord gauge (round n) attrs
              gaugeRecord doubleGauge n attrs
        record 5 (attributes "GET" "/orders")
        record 7 (attributes "GET" "/users")
        first <- collect env
        length first `shouldBe` 8
        forM_ first $ \metric -> do
          (attrs, exemplars) <- single (V.fromList (points metric))
          lookupAttribute attrs "method" `shouldBe` Just (toAttribute ("GET" :: Text))
          lookupAttribute attrs "route" `shouldBe` Nothing
          lookupAttribute attrs "otel.metric.overflow" `shouldBe` Nothing
          routes exemplars `shouldBe` ["/orders", "/users"]
          map (\e -> lookupAttribute (metricExemplarFilteredAttributes e) "method") exemplars
            `shouldBe` [Nothing, Nothing]
        expectSum "filtered.counter" (IntNumber 12) first
        expectSum "filtered.double" (DoubleNumber 12) first
        expectSum "filtered.updown" (IntNumber (-12)) first
        expectSum "filtered.double.updown" (DoubleNumber (-12)) first
        expectHistogram 2 12 first
        expectGauge "filtered.gauge" (IntNumber 7) first
        expectGauge "filtered.double.gauge" (DoubleNumber 7) first
        record 3 (attributes "GET" "/third")
        second <- collect env
        let cumulative = temp == AggregationCumulative
        expectSum "filtered.counter" (IntNumber (if cumulative then 15 else 3)) second
        expectHistogram (if cumulative then 3 else 1) (if cumulative then 15 else 3) second

    it "merges all measurements when the allow-list is empty" $ do
      (meter, env, advisory) <- setup mode [] AggregationCumulative
      counter <- meterCreateCounterInt64 meter "filtered.empty" Nothing Nothing advisory
      counterAdd counter 5 (attributes "GET" "/orders")
      counterAdd counter 7 (attributes "POST" "/users")
      result <- collect env
      expectSum "filtered.empty" (IntNumber 12) result
      [(attrs, exemplars)] <- pure (concatMap points result)
      getCount attrs `shouldBe` 0
      routes exemplars `shouldBe` ["/orders", "/users"]
      sort [method | e <- exemplars, Just (AttributeValue (TextAttribute method)) <- [lookupAttribute (metricExemplarFilteredAttributes e) "method"]]
        `shouldBe` ["GET", "POST"]

    it "retains all original measurement attributes on overflow exemplars" $ do
      (meter, env, advisory) <- setup mode ["method"] AggregationCumulative
      counter <- meterCreateCounterInt64 meter "filtered.overflow" Nothing Nothing advisory
      counterAdd counter 5 (attributes "GET" "/orders")
      counterAdd counter 7 (attributes "POST" "/users")
      result <- collect env
      let overflow =
            [ (attrs, es)
            | (attrs, es) <- concatMap points result
            , lookupAttribute attrs "otel.metric.overflow" == Just (toAttribute True)
            ]
      (attrs, exemplars) <- single (V.fromList overflow)
      getCount attrs `shouldBe` 1
      lookupAttribute attrs "method" `shouldBe` Nothing
      [exemplar] <- pure exemplars
      metricExemplarValue exemplar `shouldBe` Just (IntNumber 7)
      lookupAttribute (metricExemplarFilteredAttributes exemplar) "method" `shouldBe` Just (toAttribute ("POST" :: Text))
      lookupAttribute (metricExemplarFilteredAttributes exemplar) "route" `shouldBe` Just (toAttribute ("/users" :: Text))
      lookupAttribute (metricExemplarFilteredAttributes exemplar) "otel.metric.overflow" `shouldBe` Nothing

    it "applies filtering to observable instruments and their exemplars" $ do
      (meter, env, advisory) <- setup mode ["method"] AggregationCumulative
      let integers result = observe result 5 (attributes "GET" "/orders") >> observe result 7 (attributes "GET" "/users")
          doubles result = observe result 5 (attributes "GET" "/orders") >> observe result 7 (attributes "GET" "/users")
      void $ meterCreateObservableCounterInt64 meter "filtered.async.counter" Nothing Nothing advisory [integers]
      void $ meterCreateObservableCounterDouble meter "filtered.async.double" Nothing Nothing advisory [doubles]
      void $ meterCreateObservableUpDownCounterInt64 meter "filtered.async.updown" Nothing Nothing advisory [integers]
      void $ meterCreateObservableUpDownCounterDouble meter "filtered.async.double.updown" Nothing Nothing advisory [doubles]
      void $ meterCreateObservableGaugeInt64 meter "filtered.async.gauge" Nothing Nothing advisory [integers]
      void $ meterCreateObservableGaugeDouble meter "filtered.async.double.gauge" Nothing Nothing advisory [doubles]
      result <- collect env
      length result `shouldBe` 6
      forM_ result $ \metric -> do
        (attrs, exemplars) <- single (V.fromList (points metric))
        lookupAttribute attrs "method" `shouldBe` Just (toAttribute ("GET" :: Text))
        lookupAttribute attrs "otel.metric.overflow" `shouldBe` Nothing
        routes exemplars `shouldBe` ["/orders", "/users"]
      expectSum "filtered.async.counter" (IntNumber 12) result
      expectSum "filtered.async.double" (DoubleNumber 12) result
      expectSum "filtered.async.updown" (IntNumber 12) result
      expectSum "filtered.async.double.updown" (DoubleNumber 12) result
      expectGauge "filtered.async.gauge" (IntNumber 7) result
      expectGauge "filtered.async.double.gauge" (DoubleNumber 7) result

    it "conserves filtered counter and histogram records during delta collection" $ do
      (meter, env, advisory) <- setup mode ["method"] AggregationDelta
      counter <- meterCreateCounterInt64 meter "filtered.concurrent" Nothing Nothing advisory
      histogram <- meterCreateHistogram meter "filtered.concurrent.histogram" Nothing Nothing advisory
      started <- newEmptyMVar
      let record worker n = do
            let attrs = attributes "GET" (T.pack (show (worker, n)))
            counterAdd counter 1 attrs
            histogramRecord histogram 1 attrs
          workers = forConcurrently_ [0 .. 3 :: Int] $ \worker -> do
            record worker (0 :: Int)
            void $ tryPutMVar started ()
            forM_ [1 .. 999 :: Int] (record worker)
          collector = readMVar started >> replicateM 100 (yield >> collect env)
      (_, snapshots) <- concurrently workers collector
      final <- collect env
      let metrics = concat snapshots <> final
          sums = [n | MetricExportSum {mesSumPoints = ps} <- metrics, p <- V.toList ps, IntNumber n <- [sumDataPointValue p]]
          histograms = [p | MetricExportHistogram {mehPoints = ps} <- metrics, p <- V.toList ps]
      sum sums `shouldBe` 4000
      sum (map histogramDataPointCount histograms) `shouldBe` 4000
      sum (map histogramDataPointSum histograms) `shouldBe` 4000
      forM_ (concatMap points metrics) $ \(attrs, _) -> do
        lookupAttribute attrs "method" `shouldBe` Just (toAttribute ("GET" :: Text))
        lookupAttribute attrs "route" `shouldBe` Nothing
        lookupAttribute attrs "otel.metric.overflow" `shouldBe` Nothing

  it "leaves exemplar filtered attributes empty when every attribute is retained" $ do
    (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
    meter <- getMeter provider "attribute-filter-tests"
    counter <- meterCreateCounterInt64 meter "unfiltered" Nothing Nothing defaultAdvisoryParameters
    counterAdd counter 5 (attributes "GET" "/orders")
    result <- collect env
    [(attrs, [exemplar])] <- pure (concatMap points result)
    getCount attrs `shouldBe` 2
    getCount (metricExemplarFilteredAttributes exemplar) `shouldBe` 0


setup :: FilterMode -> [Text] -> AggregationTemporality -> IO (Meter, SdkMeterEnv, AdvisoryParameters)
setup mode keys temp = do
  let view =
        View
          (ViewSelector "filtered.*" Nothing Nothing Nothing Nothing Nothing)
          ViewAggregationDefault
          (Just keys)
          Nothing
          Nothing
      options =
        defaultSdkMeterProviderOptions
          { views = case mode of ViaView -> [view]; ViaAdvisory -> []
          , cardinalityLimit = 1
          , aggregationTemporality = temp
          , exemplarOptions =
              defaultSdkMeterExemplarOptions
                { exemplarFilter = MetricsExemplarFilterAlwaysOn
                , exemplarReservoirLimit = 2
                }
          }
      -- A View's keys must override the conflicting advisory keys.
      advisory =
        defaultAdvisoryParameters
          { advisoryAttributeKeys = Just (case mode of ViaView -> ["route"]; ViaAdvisory -> keys)
          }
  (provider, env) <- createMeterProvider emptyMaterializedResources options
  meter <- getMeter provider "attribute-filter-tests"
  pure (meter, env, advisory)


attributes :: Text -> Text -> Attributes
attributes method route =
  addAttribute
    defaultAttributeLimits
    (addAttribute defaultAttributeLimits emptyAttributes "method" method)
    "route"
    route


collect :: SdkMeterEnv -> IO [MetricExport]
collect env = do
  batches <- collectResourceMetrics env
  pure [metric | batch <- batches, scope <- V.toList (resourceMetricsScopes batch), metric <- V.toList (scopeMetricsExports scope)]


points :: MetricExport -> [(Attributes, [MetricExemplar])]
points metric = case metric of
  MetricExportSum {mesSumPoints = ps} -> [(sumDataPointAttributes p, V.toList (sumDataPointExemplars p)) | p <- V.toList ps]
  MetricExportHistogram {mehPoints = ps} -> [(histogramDataPointAttributes p, V.toList (histogramDataPointExemplars p)) | p <- V.toList ps]
  MetricExportExponentialHistogram {meehPoints = ps} -> [(exponentialHistogramDataPointAttributes p, V.toList (exponentialHistogramDataPointExemplars p)) | p <- V.toList ps]
  MetricExportGauge {megGaugePoints = ps} -> [(gaugeDataPointAttributes p, V.toList (gaugeDataPointExemplars p)) | p <- V.toList ps]


routes :: [MetricExemplar] -> [Text]
routes exemplars = sort [route | e <- exemplars, Just (AttributeValue (TextAttribute route)) <- [lookupAttribute (metricExemplarFilteredAttributes e) "route"]]


single :: V.Vector a -> IO a
single ps = case V.toList ps of
  [p] -> pure p
  _ -> fail ("expected one point, got " <> show (V.length ps))


named :: Text -> [MetricExport] -> IO MetricExport
named name metrics = case filter ((== name) . metricName) metrics of
  [metric] -> pure metric
  _ -> fail ("expected one metric named " <> T.unpack name)
  where
    metricName MetricExportSum {mesName = n} = n
    metricName MetricExportHistogram {mehName = n} = n
    metricName MetricExportExponentialHistogram {meehName = n} = n
    metricName MetricExportGauge {megName = n} = n


expectSum :: Text -> NumberValue -> [MetricExport] -> Expectation
expectSum name expected metrics = do
  MetricExportSum {mesSumPoints = ps} <- named name metrics
  p <- single ps
  sumDataPointValue p `shouldBe` expected


expectGauge :: Text -> NumberValue -> [MetricExport] -> Expectation
expectGauge name expected metrics = do
  MetricExportGauge {megGaugePoints = ps} <- named name metrics
  p <- single ps
  gaugeDataPointValue p `shouldBe` expected


expectHistogram :: Word64 -> Double -> [MetricExport] -> Expectation
expectHistogram count total metrics = do
  MetricExportHistogram {mehPoints = ps} <- named "filtered.histogram" metrics
  p <- single ps
  histogramDataPointCount p `shouldBe` count
  histogramDataPointSum p `shouldBe` total
  V.sum (histogramDataPointBucketCounts p) `shouldBe` count
  MetricExportExponentialHistogram {meehPoints = es} <- named "filtered.exponential" metrics
  e <- single es
  exponentialHistogramDataPointCount e `shouldBe` count
  exponentialHistogramDataPointSum e `shouldBe` Just total
  V.sum (exponentialHistogramDataPointPositiveBucketCounts e) `shouldBe` count


withExemplars :: IO () -> IO ()
withExemplars action =
  bracket (lookupEnv "OTEL_METRICS_EXEMPLAR_FILTER") restore $ \_ ->
    setEnv "OTEL_METRICS_EXEMPLAR_FILTER" "always_on" >> action
  where
    restore Nothing = unsetEnv "OTEL_METRICS_EXEMPLAR_FILTER"
    restore (Just value) = setEnv "OTEL_METRICS_EXEMPLAR_FILTER" value
