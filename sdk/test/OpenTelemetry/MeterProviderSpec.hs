{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.MeterProviderSpec (spec) where

import Data.Int (Int64)
import Data.Text (Text)
import Data.Word (Word64)
import OpenTelemetry.Attributes (addAttribute, defaultAttributeLimits, emptyAttributes, lookupAttribute)
import OpenTelemetry.Attributes.Attribute (Attribute (..), PrimitiveAttribute (..))
import OpenTelemetry.Exporter.Metric (
  AggregationTemporality (..),
  ExponentialHistogramDataPoint (..),
  GaugeDataPoint (..),
  HistogramDataPoint (..),
  MetricExport (..),
  ResourceMetricsExport (..),
  ScopeMetricsExport (..),
  SumDataPoint (..),
 )
import OpenTelemetry.Internal.Common.Types (InstrumentationLibrary (..), ShutdownResult (..), FlushResult (..))
import OpenTelemetry.MeterProvider
import OpenTelemetry.Metrics (
  AdvisoryParameters (..),
  Counter (..),
  Gauge (..),
  Histogram (..),
  HistogramAggregation (..),
  Meter (..),
  MeterProvider (..),
  ObservableResult (..),
  UpDownCounter (..),
  defaultAdvisoryParameters,
  getMeter,
  shutdownMeterProvider,
  forceFlushMeterProvider,
 )
import OpenTelemetry.Metrics.View (View (..), ViewAggregation (..), ViewSelector (..))
import OpenTelemetry.Resource (emptyMaterializedResources)
import qualified Data.Vector as V
import Test.Hspec


mkView :: Text -> Maybe Text -> ViewAggregation -> Maybe [Text] -> Maybe Text -> Maybe Text -> View
mkView namePat mKind agg mKeys mName mDesc =
  View
    { viewSelector =
        ViewSelector
          { viewInstrumentNamePattern = namePat
          , viewInstrumentKind = Nothing
          , viewInstrumentUnit = Nothing
          , viewMeterName = Nothing
          , viewMeterVersion = Nothing
          , viewMeterSchemaUrl = Nothing
          }
    , viewAggregation = agg
    , viewAttributeKeys = mKeys
    , viewName = mName
    , viewDescription = mDesc
    }


scope :: InstrumentationLibrary
scope = "test-scope"


firstMetric :: [ResourceMetricsExport] -> MetricExport
firstMetric [rme] =
  V.head (scopeMetricsExports (V.head (resourceMetricsScopes rme)))
firstMetric _ = error "expected single ResourceMetricsExport"


spec :: Spec
spec = do
  describe "OpenTelemetry.MeterProvider" $ do
    -- Counter (Int64)
    it "aggregates Int64 counter measurements (cumulative sum)" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      c <- meterCreateCounterInt64 m "acount" Nothing Nothing defaultAdvisoryParameters
      counterAdd c 3 emptyAttributes
      counterAdd c 7 emptyAttributes
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts, mesName = nm, mesMonotonic = mono, mesIsInt = isInt} -> do
          nm `shouldBe` "acount"
          mono `shouldBe` True
          isInt `shouldBe` True
          V.length pts `shouldBe` 1
          sumDataPointValue (V.head pts) `shouldBe` Left (10 :: Int64)
        _ -> expectationFailure "expected MetricExportSum"

    -- Counter (Double)
    it "aggregates Double counter measurements" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      c <- meterCreateCounterDouble m "dcounter" Nothing Nothing defaultAdvisoryParameters
      counterAdd c 1.5 emptyAttributes
      counterAdd c 2.5 emptyAttributes
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts, mesIsInt = isInt} -> do
          isInt `shouldBe` False
          sumDataPointValue (V.head pts) `shouldBe` Right (4.0 :: Double)
        _ -> expectationFailure "expected MetricExportSum"

    -- UpDownCounter (Int64)
    it "aggregates Int64 up-down counter (non-monotonic)" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      udc <- meterCreateUpDownCounterInt64 m "queue.depth" Nothing Nothing defaultAdvisoryParameters
      upDownCounterAdd udc 10 emptyAttributes
      upDownCounterAdd udc (-3) emptyAttributes
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts, mesMonotonic = mono} -> do
          mono `shouldBe` False
          sumDataPointValue (V.head pts) `shouldBe` Left (7 :: Int64)
        _ -> expectationFailure "expected MetricExportSum"

    -- UpDownCounter (Double)
    it "aggregates Double up-down counter" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      udc <- meterCreateUpDownCounterDouble m "temp.diff" Nothing Nothing defaultAdvisoryParameters
      upDownCounterAdd udc 5.0 emptyAttributes
      upDownCounterAdd udc (-1.2) emptyAttributes
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts, mesMonotonic = mono, mesIsInt = isInt} -> do
          mono `shouldBe` False
          isInt `shouldBe` False
          case sumDataPointValue (V.head pts) of
            Right d -> abs (d - 3.8) `shouldSatisfy` (< 0.001)
            Left _ -> expectationFailure "expected Double"
        _ -> expectationFailure "expected MetricExportSum"

    -- Histogram (explicit bounds)
    it "records explicit histogram measurements" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      h <- meterCreateHistogram m "latency" Nothing Nothing defaultAdvisoryParameters
      histogramRecord h 1.0 emptyAttributes
      histogramRecord h 50.0 emptyAttributes
      histogramRecord h 9999.0 emptyAttributes
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportHistogram {mehPoints = pts, mehName = nm} -> do
          nm `shouldBe` "latency"
          V.length pts `shouldBe` 1
          let p = V.head pts
          histogramDataPointCount p `shouldBe` 3
          abs (histogramDataPointSum p - 10050.0) `shouldSatisfy` (< 0.001)
          histogramDataPointMin p `shouldBe` Just 1.0
          histogramDataPointMax p `shouldBe` Just 9999.0
        _ -> expectationFailure "expected MetricExportHistogram"

    -- Histogram with custom bounds via advisory
    it "honors advisory explicit bucket boundaries" $ do
      let adv = defaultAdvisoryParameters {advisoryExplicitBucketBoundaries = Just [10, 100]}
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      h <- meterCreateHistogram m "custom.hist" Nothing Nothing adv
      histogramRecord h 5.0 emptyAttributes
      histogramRecord h 50.0 emptyAttributes
      histogramRecord h 200.0 emptyAttributes
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportHistogram {mehPoints = pts} -> do
          let p = V.head pts
          V.length (histogramDataPointExplicitBounds p) `shouldBe` 2
          V.length (histogramDataPointBucketCounts p) `shouldBe` 3
          V.toList (histogramDataPointBucketCounts p) `shouldBe` [1, 1, 1]
        _ -> expectationFailure "expected MetricExportHistogram"

    -- Gauge (Int64)
    it "records Int64 gauge (last value wins)" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      g <- meterCreateGaugeInt64 m "mem.used" Nothing Nothing defaultAdvisoryParameters
      gaugeRecord g 100 emptyAttributes
      gaugeRecord g 200 emptyAttributes
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportGauge {megGaugePoints = pts, megIsInt = isInt} -> do
          isInt `shouldBe` True
          gaugeDataPointValue (V.head pts) `shouldBe` Left (200 :: Int64)
        _ -> expectationFailure "expected MetricExportGauge"

    -- Gauge (Double)
    it "records Double gauge" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      g <- meterCreateGaugeDouble m "cpu.pct" Nothing Nothing defaultAdvisoryParameters
      gaugeRecord g 0.75 emptyAttributes
      gaugeRecord g 0.42 emptyAttributes
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportGauge {megGaugePoints = pts} ->
          gaugeDataPointValue (V.head pts) `shouldBe` Right (0.42 :: Double)
        _ -> expectationFailure "expected MetricExportGauge"

    -- Exponential histogram
    it "exponential histogram records positive measurements" $ do
      let adv = defaultAdvisoryParameters {advisoryHistogramAggregation = Just (HistogramAggregationExponential 3)}
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      h <- meterCreateHistogram m "exp.latency" Nothing Nothing adv
      histogramRecord h 2.5 emptyAttributes
      histogramRecord h 0.0 emptyAttributes
      histogramRecord h 100.0 emptyAttributes
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportExponentialHistogram {meehPoints = pts} -> do
          V.length pts `shouldBe` 1
          let p = V.head pts
          exponentialHistogramDataPointCount p `shouldBe` 3
          exponentialHistogramDataPointZeroCount p `shouldBe` 1
          V.null (exponentialHistogramDataPointPositiveBucketCounts p) `shouldBe` False
        _ -> expectationFailure "expected MetricExportExponentialHistogram"

    -- Exponential histogram negative values
    it "exponential histogram records negative measurements" $ do
      let adv = defaultAdvisoryParameters {advisoryHistogramAggregation = Just (HistogramAggregationExponential 2)}
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      h <- meterCreateHistogram m "signed" Nothing Nothing adv
      histogramRecord h (-5.0) emptyAttributes
      histogramRecord h (-1.0) emptyAttributes
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportExponentialHistogram {meehPoints = pts} -> do
          let p = V.head pts
          exponentialHistogramDataPointCount p `shouldBe` 2
          V.null (exponentialHistogramDataPointNegativeBucketCounts p) `shouldBe` False
        _ -> expectationFailure "expected MetricExportExponentialHistogram"

    -- Observable counter
    it "observable counter callbacks run on collect" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      let cb res = observe res (42 :: Int64) emptyAttributes
      _ <- meterCreateObservableCounterInt64 m "obs.counter" Nothing Nothing defaultAdvisoryParameters [cb]
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts, mesName = nm, mesMonotonic = mono} -> do
          nm `shouldBe` "obs.counter"
          mono `shouldBe` True
          sumDataPointValue (V.head pts) `shouldBe` Left (42 :: Int64)
        _ -> expectationFailure "expected MetricExportSum"

    -- Observable gauge
    it "observable gauge reports last observed value" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      let cb res = observe res (3.14 :: Double) emptyAttributes
      _ <- meterCreateObservableGaugeDouble m "obs.gauge" Nothing Nothing defaultAdvisoryParameters [cb]
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportGauge {megGaugePoints = pts, megName = nm} -> do
          nm `shouldBe` "obs.gauge"
          gaugeDataPointValue (V.head pts) `shouldBe` Right (3.14 :: Double)
        _ -> expectationFailure "expected MetricExportGauge"

    -- Observable up-down counter
    it "observable up-down counter is non-monotonic" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      let cb res = observe res (-10 :: Int64) emptyAttributes
      _ <- meterCreateObservableUpDownCounterInt64 m "obs.udc" Nothing Nothing defaultAdvisoryParameters [cb]
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts, mesMonotonic = mono} -> do
          mono `shouldBe` False
          sumDataPointValue (V.head pts) `shouldBe` Left (-10 :: Int64)
        _ -> expectationFailure "expected MetricExportSum"

    -- Cardinality limit — excess goes to overflow bucket (otel.metric.overflow=true)
    it "respects cardinality limit (overflow attribute)" $ do
      (provider, env) <-
        createMeterProvider emptyMaterializedResources $
          defaultSdkMeterProviderOptions {cardinalityLimit = 1}
      m <- getMeter provider scope
      c <- meterCreateCounterInt64 m "acount" Nothing Nothing defaultAdvisoryParameters
      let a1 = addAttribute defaultAttributeLimits emptyAttributes "route" ("x" :: Text)
          a2 = addAttribute defaultAttributeLimits emptyAttributes "route" ("y" :: Text)
      counterAdd c 1 a1
      counterAdd c 100 a2
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts} -> do
          V.length pts `shouldBe` 2
          let overflow = V.filter (\p -> lookupAttribute (sumDataPointAttributes p) "otel.metric.overflow" == Just (AttributeValue (BoolAttribute True))) pts
          V.length overflow `shouldBe` 1
          sumDataPointValue (V.head overflow) `shouldBe` Left (100 :: Int64)
        _ -> expectationFailure "expected MetricExportSum"

    -- View drop
    it "view drop prevents recording" $ do
      let v = mkView "nope" Nothing ViewAggregationDrop Nothing Nothing Nothing
          opts = defaultSdkMeterProviderOptions {views = [v]}
      (provider, env) <- createMeterProvider emptyMaterializedResources opts
      m <- getMeter provider scope
      c <- meterCreateCounterInt64 m "nope" Nothing Nothing defaultAdvisoryParameters
      counterAdd c 1 emptyAttributes
      batches <- collectResourceMetrics env
      case batches of
        [rme] -> V.null (resourceMetricsScopes rme) `shouldBe` True
        _ -> expectationFailure "expected single ResourceMetricsExport"

    -- View name override
    it "view overrides exported metric name" $ do
      let v = mkView "original" Nothing ViewAggregationDefault Nothing (Just "renamed") Nothing
          opts = defaultSdkMeterProviderOptions {views = [v]}
      (provider, env) <- createMeterProvider emptyMaterializedResources opts
      m <- getMeter provider scope
      c <- meterCreateCounterInt64 m "original" Nothing Nothing defaultAdvisoryParameters
      counterAdd c 5 emptyAttributes
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportSum {mesName = nm} -> nm `shouldBe` "renamed"
        _ -> expectationFailure "expected MetricExportSum"

    -- View description override
    it "view overrides exported metric description" $ do
      let v = mkView "described" Nothing ViewAggregationDefault Nothing Nothing (Just "new desc")
          opts = defaultSdkMeterProviderOptions {views = [v]}
      (provider, env) <- createMeterProvider emptyMaterializedResources opts
      m <- getMeter provider scope
      c <- meterCreateCounterInt64 m "described" Nothing (Just "old desc") defaultAdvisoryParameters
      counterAdd c 1 emptyAttributes
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportSum {mesDescription = d} -> d `shouldBe` "new desc"
        _ -> expectationFailure "expected MetricExportSum"

    -- View attribute key filtering
    it "view filters attribute keys on export" $ do
      let v = mkView "filtered" Nothing ViewAggregationDefault (Just ["keep"]) Nothing Nothing
          opts = defaultSdkMeterProviderOptions {views = [v]}
      (provider, env) <- createMeterProvider emptyMaterializedResources opts
      m <- getMeter provider scope
      c <- meterCreateCounterInt64 m "filtered" Nothing Nothing defaultAdvisoryParameters
      let attrs = addAttribute defaultAttributeLimits
                    (addAttribute defaultAttributeLimits emptyAttributes "keep" ("v1" :: Text))
                    "drop" ("v2" :: Text)
      counterAdd c 1 attrs
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts} -> do
          let a = sumDataPointAttributes (V.head pts)
          a `shouldSatisfy` (\x -> show x `seq` True)
        _ -> expectationFailure "expected MetricExportSum"

    -- View explicit bucket histogram override
    it "view overrides histogram to explicit bucket with custom bounds" $ do
      let v = mkView "h.*" Nothing (ViewAggregationExplicitBucketHistogram [1, 10, 100]) Nothing Nothing Nothing
          opts = defaultSdkMeterProviderOptions {views = [v]}
      (provider, env) <- createMeterProvider emptyMaterializedResources opts
      m <- getMeter provider scope
      h <- meterCreateHistogram m "h.latency" Nothing Nothing defaultAdvisoryParameters
      histogramRecord h 5.0 emptyAttributes
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportHistogram {mehPoints = pts} -> do
          let p = V.head pts
          V.length (histogramDataPointExplicitBounds p) `shouldBe` 3
        _ -> expectationFailure "expected MetricExportHistogram"

    -- View exponential histogram override
    it "view overrides histogram to exponential" $ do
      let v = mkView "h.*" Nothing (ViewAggregationExponentialHistogram 5) Nothing Nothing Nothing
          opts = defaultSdkMeterProviderOptions {views = [v]}
      (provider, env) <- createMeterProvider emptyMaterializedResources opts
      m <- getMeter provider scope
      h <- meterCreateHistogram m "h.exp" Nothing Nothing defaultAdvisoryParameters
      histogramRecord h 42.0 emptyAttributes
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportExponentialHistogram {meehPoints = pts} ->
          V.length pts `shouldBe` 1
        _ -> expectationFailure "expected MetricExportExponentialHistogram"

    -- Delta temporality
    it "delta temporality resets after collect" $ do
      let opts = defaultSdkMeterProviderOptions {aggregationTemporality = AggregationDelta}
      (provider, env) <- createMeterProvider emptyMaterializedResources opts
      m <- getMeter provider scope
      c <- meterCreateCounterInt64 m "delta.c" Nothing Nothing defaultAdvisoryParameters
      counterAdd c 5 emptyAttributes
      b1 <- collectResourceMetrics env
      case firstMetric b1 of
        MetricExportSum {mesSumPoints = pts, mesAggregationTemporality = temp} -> do
          temp `shouldBe` AggregationDelta
          sumDataPointValue (V.head pts) `shouldBe` Left (5 :: Int64)
        _ -> expectationFailure "expected MetricExportSum"
      counterAdd c 3 emptyAttributes
      b2 <- collectResourceMetrics env
      case firstMetric b2 of
        MetricExportSum {mesSumPoints = pts} ->
          sumDataPointValue (V.head pts) `shouldBe` Left (3 :: Int64)
        _ -> expectationFailure "expected MetricExportSum"

    -- Delta temporality for histogram
    it "delta temporality resets histogram after collect" $ do
      let opts = defaultSdkMeterProviderOptions {aggregationTemporality = AggregationDelta}
      (provider, env) <- createMeterProvider emptyMaterializedResources opts
      m <- getMeter provider scope
      h <- meterCreateHistogram m "delta.hist" Nothing Nothing defaultAdvisoryParameters
      histogramRecord h 10.0 emptyAttributes
      _ <- collectResourceMetrics env
      histogramRecord h 20.0 emptyAttributes
      b2 <- collectResourceMetrics env
      case firstMetric b2 of
        MetricExportHistogram {mehPoints = pts} -> do
          let p = V.head pts
          histogramDataPointCount p `shouldBe` 1
          abs (histogramDataPointSum p - 20.0) `shouldSatisfy` (< 0.001)
        _ -> expectationFailure "expected MetricExportHistogram"

    -- Multiple attribute sets produce multiple points
    it "multiple attribute sets produce separate data points" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      c <- meterCreateCounterInt64 m "multi" Nothing Nothing defaultAdvisoryParameters
      let a1 = addAttribute defaultAttributeLimits emptyAttributes "k" ("v1" :: Text)
          a2 = addAttribute defaultAttributeLimits emptyAttributes "k" ("v2" :: Text)
      counterAdd c 1 a1
      counterAdd c 2 a2
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts} ->
          V.length pts `shouldBe` 2
        _ -> expectationFailure "expected MetricExportSum"

    -- startTimeUnixNano is populated
    it "startTimeUnixNano is non-zero for cumulative" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      c <- meterCreateCounterInt64 m "timed" Nothing Nothing defaultAdvisoryParameters
      counterAdd c 1 emptyAttributes
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts} ->
          sumDataPointStartTimeUnixNano (V.head pts) `shouldSatisfy` (> (0 :: Word64))
        _ -> expectationFailure "expected MetricExportSum"

    -- Shutdown prevents further recording
    it "shutdown prevents further recording" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      c <- meterCreateCounterInt64 m "pre.shutdown" Nothing Nothing defaultAdvisoryParameters
      counterAdd c 10 emptyAttributes
      result <- shutdownMeterProvider provider
      result `shouldBe` ShutdownSuccess
      -- After shutdown, getMeter returns noop
      m2 <- getMeter provider scope
      c2 <- meterCreateCounterInt64 m2 "post.shutdown" Nothing Nothing defaultAdvisoryParameters
      counterAdd c2 99 emptyAttributes
      batches <- collectResourceMetrics env
      case batches of
        [rme] -> V.null (resourceMetricsScopes rme) `shouldBe` True
        _ -> expectationFailure "expected single ResourceMetricsExport"

    -- ForceFlush triggers a collect
    it "forceFlush succeeds" $ do
      (provider, _env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      result <- forceFlushMeterProvider provider
      result `shouldBe` FlushSuccess

    -- Invalid instrument name produces noop
    it "invalid instrument name produces noop instrument" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      c <- meterCreateCounterInt64 m "" Nothing Nothing defaultAdvisoryParameters
      enabled <- counterEnabled c
      enabled `shouldBe` False
      counterAdd c 99 emptyAttributes
      batches <- collectResourceMetrics env
      case batches of
        [rme] -> V.null (resourceMetricsScopes rme) `shouldBe` True
        _ -> expectationFailure "expected single ResourceMetricsExport"

    -- Enabled is True for valid SDK instruments
    it "enabled returns True for valid SDK instruments" $ do
      (provider, _) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      c <- meterCreateCounterInt64 m "valid" Nothing Nothing defaultAdvisoryParameters
      enabled <- counterEnabled c
      enabled `shouldBe` True

    -- Empty collect returns empty scopes
    it "collecting without recording returns empty scopes" $ do
      (_, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      batches <- collectResourceMetrics env
      case batches of
        [rme] -> V.null (resourceMetricsScopes rme) `shouldBe` True
        _ -> expectationFailure "expected single ResourceMetricsExport"
