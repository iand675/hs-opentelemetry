{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.MeterProviderSpec (spec) where

import Control.Concurrent (forkIO)
import Control.Concurrent.Async (async, mapConcurrently, mapConcurrently_, poll, replicateConcurrently_, wait)
import Control.Concurrent.MVar (newEmptyMVar, putMVar, takeMVar)
import Control.Exception (throwIO)
import Control.Monad (replicateM_, void)
import Data.IORef (modifyIORef', newIORef, readIORef)
import Data.Int (Int64)
import Data.Maybe (isJust)
import qualified Data.Set as Set
import Data.Text (Text)
import qualified Data.Vector as V
import Data.Word (Word64)
import OpenTelemetry.Attributes (addAttribute, defaultAttributeLimits, emptyAttributes, lookupAttribute)
import OpenTelemetry.Attributes.Attribute (Attribute (..), PrimitiveAttribute (..))
import OpenTelemetry.Context (insertSpan)
import OpenTelemetry.Context.ThreadLocal (adjustContext)
import OpenTelemetry.Environment (MetricsExemplarFilter (..))
import OpenTelemetry.Exporter.Metric (
  AggregationTemporality (..),
  ExponentialHistogramDataPoint (..),
  GaugeDataPoint (..),
  HistogramDataPoint (..),
  MetricExemplar (..),
  MetricExport (..),
  NumberValue (..),
  ResourceMetricsExport (..),
  ScopeMetricsExport (..),
  SumDataPoint (..),
 )
import OpenTelemetry.Internal.Common.Types (FlushResult (..), InstrumentationLibrary (..), ShutdownResult (..), instrumentationLibrary)
import OpenTelemetry.MeterProvider (
  SdkMeterEnv (..),
  SdkMeterExemplarOptions (..),
  SdkMeterProviderOptions (..),
  collectResourceMetrics,
  createMeterProvider,
  defaultSdkMeterExemplarOptions,
  defaultSdkMeterProviderOptions,
 )
import OpenTelemetry.Metrics (
  AdvisoryParameters (..),
  Counter (..),
  Gauge (..),
  Histogram (..),
  HistogramAggregation (..),
  Meter (..),
  MeterProvider (..),
  ObservableCallbackHandle (..),
  ObservableCounter (..),
  ObservableResult (..),
  UpDownCounter (..),
  defaultAdvisoryParameters,
  forceFlushMeterProvider,
  getMeter,
  shutdownMeterProvider,
 )
import OpenTelemetry.Metrics.View (View (..), ViewAggregation (..), ViewSelector (..))
import OpenTelemetry.Resource (emptyMaterializedResources)
import OpenTelemetry.Trace.Core (SpanContext (..), defaultTraceFlags, setSampled, wrapSpanContext)
import OpenTelemetry.Trace.Id (bytesToSpanId, bytesToTraceId, spanIdBytes, traceIdBytes)
import qualified OpenTelemetry.Trace.TraceState as TraceState
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


mkProvider :: SdkMeterProviderOptions -> IO (MeterProvider, SdkMeterEnv)
mkProvider = createMeterProvider emptyMaterializedResources


defaultScope :: InstrumentationLibrary
defaultScope = instrumentationLibrary "test" "1.0"


-- | Sum all Int64 sum data points across every metric in a collect batch.
sumInt64SumPointsInBatches :: [ResourceMetricsExport] -> Int64
sumInt64SumPointsInBatches batches =
  sum $ map sumResource batches
  where
    sumResource rme = V.sum $ V.map sumScope (resourceMetricsScopes rme)
    sumScope sme = V.sum $ V.map sumExport (scopeMetricsExports sme)
    sumExport me = case me of
      MetricExportSum {mesSumPoints = pts, mesIsInt = True} ->
        V.sum $ V.map int64FromSumPoint pts
      _ -> 0
    int64FromSumPoint p = case sumDataPointValue p of
      IntNumber i -> i
      DoubleNumber _ -> 0


-- | Total observation count across all explicit histogram data points in a batch.
histogramObservationCountInBatches :: [ResourceMetricsExport] -> Word64
histogramObservationCountInBatches batches =
  sum $ map sumResource batches
  where
    sumResource rme = V.sum $ V.map sumScope (resourceMetricsScopes rme)
    sumScope sme = V.sum $ V.map sumExport (scopeMetricsExports sme)
    sumExport me = case me of
      MetricExportHistogram {mehPoints = pts} ->
        V.sum $ V.map histogramDataPointCount pts
      _ -> 0


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
          sumDataPointValue (V.head pts) `shouldBe` IntNumber (10 :: Int64)
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
          sumDataPointValue (V.head pts) `shouldBe` DoubleNumber (4.0 :: Double)
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
          sumDataPointValue (V.head pts) `shouldBe` IntNumber (7 :: Int64)
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
            DoubleNumber d -> abs (d - 3.8) `shouldSatisfy` (< 0.001)
            IntNumber _ -> expectationFailure "expected Double"
        _ -> expectationFailure "expected MetricExportSum"

    it "counter drops negative values (monotonic)" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      c <- meterCreateCounterInt64 m "no.neg" Nothing Nothing defaultAdvisoryParameters
      counterAdd c 10 emptyAttributes
      counterAdd c (-5) emptyAttributes
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts, mesMonotonic = mono} -> do
          mono `shouldBe` True
          sumDataPointValue (V.head pts) `shouldBe` IntNumber (10 :: Int64)
        _ -> expectationFailure "expected MetricExportSum"

    it "counter drops negative Double values" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      c <- meterCreateCounterDouble m "no.neg.dbl" Nothing Nothing defaultAdvisoryParameters
      counterAdd c 5.0 emptyAttributes
      counterAdd c (-2.0) emptyAttributes
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts} ->
          sumDataPointValue (V.head pts) `shouldBe` DoubleNumber (5.0 :: Double)
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
          gaugeDataPointValue (V.head pts) `shouldBe` IntNumber (200 :: Int64)
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
          gaugeDataPointValue (V.head pts) `shouldBe` DoubleNumber (0.42 :: Double)
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
          sumDataPointValue (V.head pts) `shouldBe` IntNumber (42 :: Int64)
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
          gaugeDataPointValue (V.head pts) `shouldBe` DoubleNumber (3.14 :: Double)
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
          sumDataPointValue (V.head pts) `shouldBe` IntNumber (-10 :: Int64)
        _ -> expectationFailure "expected MetricExportSum"

    it "unregisterObservableCallback removes the callback" $ do
      let opts = defaultSdkMeterProviderOptions {aggregationTemporality = AggregationDelta}
      (provider, env) <- createMeterProvider emptyMaterializedResources opts
      m <- getMeter provider scope
      let cb1 res = observe res (100 :: Int64) emptyAttributes
      oc <- meterCreateObservableCounterInt64 m "unreg.counter" Nothing Nothing defaultAdvisoryParameters [cb1]

      handle <- observableCounterRegisterCallback oc (\res -> observe res (200 :: Int64) emptyAttributes)
      batches1 <- collectResourceMetrics env
      case firstMetric batches1 of
        MetricExportSum {mesSumPoints = pts} ->
          sumDataPointValue (V.head pts) `shouldBe` IntNumber (300 :: Int64)
        _ -> expectationFailure "expected MetricExportSum with both callbacks"

      unregisterObservableCallback handle
      batches2 <- collectResourceMetrics env
      case firstMetric batches2 of
        MetricExportSum {mesSumPoints = pts} ->
          sumDataPointValue (V.head pts) `shouldBe` IntNumber (100 :: Int64)
        _ -> expectationFailure "expected MetricExportSum after unregister"

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
          sumDataPointValue (V.head overflow) `shouldBe` IntNumber (100 :: Int64)
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
      let attrs =
            addAttribute
              defaultAttributeLimits
              (addAttribute defaultAttributeLimits emptyAttributes "keep" ("v1" :: Text))
              "drop"
              ("v2" :: Text)
      counterAdd c 1 attrs
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts} -> do
          let a = sumDataPointAttributes (V.head pts)
          lookupAttribute a "keep" `shouldSatisfy` isJust
          lookupAttribute a "drop" `shouldBe` Nothing
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
          sumDataPointValue (V.head pts) `shouldBe` IntNumber (5 :: Int64)
        _ -> expectationFailure "expected MetricExportSum"
      counterAdd c 3 emptyAttributes
      b2 <- collectResourceMetrics env
      case firstMetric b2 of
        MetricExportSum {mesSumPoints = pts} ->
          sumDataPointValue (V.head pts) `shouldBe` IntNumber (3 :: Int64)
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

    it "shutdown is idempotent (second call succeeds without error)" $ do
      (provider, _env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      r1 <- shutdownMeterProvider provider
      r1 `shouldBe` ShutdownSuccess
      r2 <- shutdownMeterProvider provider
      r2 `shouldBe` ShutdownSuccess

    -- ForceFlush triggers a collect
    it "forceFlush succeeds" $ do
      (provider, _env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      result <- forceFlushMeterProvider provider Nothing
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

    it "cumulative temporality keeps counter sum across collects" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      c <- meterCreateCounterInt64 m "cum.across" Nothing Nothing defaultAdvisoryParameters
      counterAdd c 5 emptyAttributes
      b1 <- collectResourceMetrics env
      case firstMetric b1 of
        MetricExportSum {mesSumPoints = pts, mesAggregationTemporality = temp} -> do
          temp `shouldBe` AggregationCumulative
          sumDataPointValue (V.head pts) `shouldBe` IntNumber (5 :: Int64)
        _ -> expectationFailure "expected MetricExportSum"
      counterAdd c 3 emptyAttributes
      b2 <- collectResourceMetrics env
      case firstMetric b2 of
        MetricExportSum {mesSumPoints = pts} ->
          sumDataPointValue (V.head pts) `shouldBe` IntNumber (8 :: Int64)
        _ -> expectationFailure "expected MetricExportSum"

    it "default explicit histogram uses spec bucket boundaries" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      h <- meterCreateHistogram m "default.bounds" Nothing Nothing defaultAdvisoryParameters
      histogramRecord h 1.0 emptyAttributes
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportHistogram {mehPoints = pts} -> do
          let expected =
                V.fromList [0, 5, 10, 25, 50, 75, 100, 250, 500, 750, 1000, 2500, 5000, 7500, 10000]
          histogramDataPointExplicitBounds (V.head pts) `shouldBe` expected
        _ -> expectationFailure "expected MetricExportHistogram"

    it "histogram drops NaN and Infinity measurements" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      h <- meterCreateHistogram m "nan.inf" Nothing Nothing defaultAdvisoryParameters
      let nan = 0 / 0 :: Double
          inf = 1 / 0 :: Double
      histogramRecord h nan emptyAttributes
      histogramRecord h inf emptyAttributes
      histogramRecord h 5.0 emptyAttributes
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportHistogram {mehPoints = pts} -> do
          let p = V.head pts
          histogramDataPointCount p `shouldBe` 1
          abs (histogramDataPointSum p - 5.0) `shouldSatisfy` (< 0.001)
        _ -> expectationFailure "expected MetricExportHistogram"

    it "instrument names differing only by case are separate streams (per-name export groups)" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      c1 <- meterCreateCounterInt64 m "MyCounter" Nothing Nothing defaultAdvisoryParameters
      c2 <- meterCreateCounterInt64 m "mycounter" Nothing Nothing defaultAdvisoryParameters
      counterAdd c1 1 emptyAttributes
      counterAdd c2 2 emptyAttributes
      batches <- collectResourceMetrics env
      case batches of
        [rme] -> do
          let scopesVec = resourceMetricsScopes rme
          V.length scopesVec `shouldBe` 1
          let exports = scopeMetricsExports (V.head scopesVec)
          V.length exports `shouldBe` 2
          case (exports V.! 0, exports V.! 1) of
            (MetricExportSum {mesName = n0}, MetricExportSum {mesName = n1}) ->
              (n0 /= n1) `shouldBe` True
            _ -> expectationFailure "expected two sum exports"
        _ -> expectationFailure "expected single ResourceMetricsExport"

    it "same instrument name in different meters yields isolated scopes" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      let scopeA = instrumentationLibrary "scope-a" "1"
          scopeB = instrumentationLibrary "scope-b" "1"
      ma <- getMeter provider scopeA
      mb <- getMeter provider scopeB
      ca <- meterCreateCounterInt64 ma "shared.counter" Nothing Nothing defaultAdvisoryParameters
      cb <- meterCreateCounterInt64 mb "shared.counter" Nothing Nothing defaultAdvisoryParameters
      counterAdd ca 11 emptyAttributes
      counterAdd cb 22 emptyAttributes
      batches <- collectResourceMetrics env
      case batches of
        [rme] -> do
          let scopes = resourceMetricsScopes rme
          V.length scopes `shouldBe` 2
          let sn0 = libraryName (scopeMetricsScope (scopes V.! 0))
              sn1 = libraryName (scopeMetricsScope (scopes V.! 1))
          sn0 == sn1 `shouldBe` False
        _ -> expectationFailure "expected single ResourceMetricsExport"

    it "exports counter unit and description" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      c <-
        meterCreateCounterInt64
          m
          "with.meta"
          (Just "ms")
          (Just "Request latency")
          defaultAdvisoryParameters
      counterAdd c 1 emptyAttributes
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportSum {mesUnit = u, mesDescription = d} -> do
          u `shouldBe` "ms"
          d `shouldBe` "Request latency"
        _ -> expectationFailure "expected MetricExportSum"

    it "observable counter runs every registered callback" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      let cb1 res = observe res (10 :: Int64) emptyAttributes
          cb2 res = observe res (32 :: Int64) emptyAttributes
      _ <- meterCreateObservableCounterInt64 m "obs.twocb" Nothing Nothing defaultAdvisoryParameters [cb1, cb2]
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts} ->
          sumDataPointValue (V.head pts) `shouldBe` IntNumber (42 :: Int64)
        _ -> expectationFailure "expected MetricExportSum"

    it "observable counter enabled reflects view drop" $ do
      (providerOk, _) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      mOk <- getMeter providerOk scope
      ocOk <- meterCreateObservableCounterInt64 mOk "obs.enabled.chk" Nothing Nothing defaultAdvisoryParameters []
      enOk <- observableCounterEnabled ocOk
      enOk `shouldBe` True
      let v = mkView "obs.enabled.chk" Nothing ViewAggregationDrop Nothing Nothing Nothing
          opts = defaultSdkMeterProviderOptions {views = [v]}
      (providerDrop, _) <- createMeterProvider emptyMaterializedResources opts
      mDrop <- getMeter providerDrop scope
      ocDrop <- meterCreateObservableCounterInt64 mDrop "obs.enabled.chk" Nothing Nothing defaultAdvisoryParameters []
      enDrop <- observableCounterEnabled ocDrop
      enDrop `shouldBe` False

    it "view with wildcard name drops all instruments" $ do
      let v = mkView "*" Nothing ViewAggregationDrop Nothing Nothing Nothing
          opts = defaultSdkMeterProviderOptions {views = [v]}
      (provider, env) <- createMeterProvider emptyMaterializedResources opts
      m <- getMeter provider scope
      c <- meterCreateCounterInt64 m "any.counter" Nothing Nothing defaultAdvisoryParameters
      h <- meterCreateHistogram m "any.hist" Nothing Nothing defaultAdvisoryParameters
      counterAdd c 5 emptyAttributes
      histogramRecord h 1.0 emptyAttributes
      batches <- collectResourceMetrics env
      case batches of
        [rme] -> V.null (resourceMetricsScopes rme) `shouldBe` True
        _ -> expectationFailure "expected single ResourceMetricsExport"

    it "delta temporality gauge reports last value per collect" $ do
      let opts = defaultSdkMeterProviderOptions {aggregationTemporality = AggregationDelta}
      (provider, env) <- createMeterProvider emptyMaterializedResources opts
      m <- getMeter provider scope
      g <- meterCreateGaugeDouble m "delta.gauge.v" Nothing Nothing defaultAdvisoryParameters
      gaugeRecord g 10.0 emptyAttributes
      b1 <- collectResourceMetrics env
      case firstMetric b1 of
        MetricExportGauge {megGaugePoints = pts} ->
          gaugeDataPointValue (V.head pts) `shouldBe` DoubleNumber (10.0 :: Double)
        _ -> expectationFailure "expected MetricExportGauge"
      gaugeRecord g 20.0 emptyAttributes
      b2 <- collectResourceMetrics env
      case firstMetric b2 of
        MetricExportGauge {megGaugePoints = pts} ->
          gaugeDataPointValue (V.head pts) `shouldBe` DoubleNumber (20.0 :: Double)
        _ -> expectationFailure "expected MetricExportGauge"

    it "re-registering a counter by name shares one stream" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      c1 <- meterCreateCounterInt64 m "reuse.name" Nothing Nothing defaultAdvisoryParameters
      c2 <- meterCreateCounterInt64 m "reuse.name" Nothing Nothing defaultAdvisoryParameters
      counterAdd c1 3 emptyAttributes
      counterAdd c2 7 emptyAttributes
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts} -> do
          V.length pts `shouldBe` 1
          sumDataPointValue (V.head pts) `shouldBe` IntNumber (10 :: Int64)
        _ -> expectationFailure "expected MetricExportSum"

    it "cumulative histogram accumulates count and sum across collects" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      h <- meterCreateHistogram m "hist.cumulative" Nothing Nothing defaultAdvisoryParameters
      histogramRecord h 10.0 emptyAttributes
      b1 <- collectResourceMetrics env
      case firstMetric b1 of
        MetricExportHistogram {mehPoints = pts, mehAggregationTemporality = temp} -> do
          temp `shouldBe` AggregationCumulative
          let p1 = V.head pts
          histogramDataPointCount p1 `shouldBe` 1
          abs (histogramDataPointSum p1 - 10.0) `shouldSatisfy` (< 0.001)
        _ -> expectationFailure "expected MetricExportHistogram"
      histogramRecord h 20.0 emptyAttributes
      b2 <- collectResourceMetrics env
      case firstMetric b2 of
        MetricExportHistogram {mehPoints = pts} -> do
          let p2 = V.head pts
          histogramDataPointCount p2 `shouldBe` 2
          abs (histogramDataPointSum p2 - 30.0) `shouldSatisfy` (< 0.001)
        _ -> expectationFailure "expected MetricExportHistogram"

    it "trace-based exemplar captures span context on counter" $ do
      let Right tid = bytesToTraceId "\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10"
          Right sid = bytesToSpanId "\xaa\xbb\xcc\xdd\xee\xff\x11\x22"
          sc =
            SpanContext
              { traceFlags = setSampled defaultTraceFlags
              , isRemote = False
              , traceId = tid
              , spanId = sid
              , traceState = TraceState.empty
              }
      adjustContext (insertSpan (wrapSpanContext sc))
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      c <- meterCreateCounterInt64 m "exemplar.counter" Nothing Nothing defaultAdvisoryParameters
      counterAdd c 42 emptyAttributes
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts} -> do
          let exs = sumDataPointExemplars (V.head pts)
          V.length exs `shouldSatisfy` (>= 1)
          let ex = V.head exs
          metricExemplarTraceId ex `shouldBe` traceIdBytes tid
          metricExemplarSpanId ex `shouldBe` spanIdBytes sid
        _ -> expectationFailure "expected MetricExportSum"

    it "trace-based exemplar captures span context on histogram" $ do
      let Right tid = bytesToTraceId "\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10"
          Right sid = bytesToSpanId "\xaa\xbb\xcc\xdd\xee\xff\x11\x22"
          sc =
            SpanContext
              { traceFlags = setSampled defaultTraceFlags
              , isRemote = False
              , traceId = tid
              , spanId = sid
              , traceState = TraceState.empty
              }
      adjustContext (insertSpan (wrapSpanContext sc))
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      h <- meterCreateHistogram m "exemplar.hist" Nothing Nothing defaultAdvisoryParameters
      histogramRecord h 99.0 emptyAttributes
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportHistogram {mehPoints = pts} -> do
          let exs = histogramDataPointExemplars (V.head pts)
          V.length exs `shouldSatisfy` (>= 1)
          let ex = V.head exs
          metricExemplarTraceId ex `shouldBe` traceIdBytes tid
          metricExemplarSpanId ex `shouldBe` spanIdBytes sid
        _ -> expectationFailure "expected MetricExportHistogram"

    it "exemplar filter AlwaysOff suppresses exemplar capture" $ do
      let Right tid = bytesToTraceId "\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10"
          Right sid = bytesToSpanId "\xaa\xbb\xcc\xdd\xee\xff\x11\x22"
          sc =
            SpanContext
              { traceFlags = setSampled defaultTraceFlags
              , isRemote = False
              , traceId = tid
              , spanId = sid
              , traceState = TraceState.empty
              }
          opts =
            defaultSdkMeterProviderOptions
              { exemplarOptions = defaultSdkMeterExemplarOptions {exemplarFilter = MetricsExemplarFilterAlwaysOff}
              }
      adjustContext (insertSpan (wrapSpanContext sc))
      (provider, env) <- createMeterProvider emptyMaterializedResources opts
      m <- getMeter provider scope
      c <- meterCreateCounterInt64 m "no.exemplar" Nothing Nothing defaultAdvisoryParameters
      counterAdd c 1 emptyAttributes
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts} ->
          V.null (sumDataPointExemplars (V.head pts)) `shouldBe` True
        _ -> expectationFailure "expected MetricExportSum"

    it "exemplar filter AlwaysOn captures exemplar even without sampled flag" $ do
      let Right tid = bytesToTraceId "\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10"
          Right sid = bytesToSpanId "\xaa\xbb\xcc\xdd\xee\xff\x11\x22"
          sc =
            SpanContext
              { traceFlags = defaultTraceFlags
              , isRemote = False
              , traceId = tid
              , spanId = sid
              , traceState = TraceState.empty
              }
          opts =
            defaultSdkMeterProviderOptions
              { exemplarOptions = defaultSdkMeterExemplarOptions {exemplarFilter = MetricsExemplarFilterAlwaysOn}
              }
      adjustContext (insertSpan (wrapSpanContext sc))
      (provider, env) <- createMeterProvider emptyMaterializedResources opts
      m <- getMeter provider scope
      c <- meterCreateCounterInt64 m "always.exemplar" Nothing Nothing defaultAdvisoryParameters
      counterAdd c 7 emptyAttributes
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts} -> do
          let exs = sumDataPointExemplars (V.head pts)
          V.length exs `shouldSatisfy` (>= 1)
          metricExemplarTraceId (V.head exs) `shouldBe` traceIdBytes tid
        _ -> expectationFailure "expected MetricExportSum"

    it "trace-based exemplar skips capture when span is not sampled" $ do
      let Right tid = bytesToTraceId "\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10"
          Right sid = bytesToSpanId "\xaa\xbb\xcc\xdd\xee\xff\x11\x22"
          sc =
            SpanContext
              { traceFlags = defaultTraceFlags
              , isRemote = False
              , traceId = tid
              , spanId = sid
              , traceState = TraceState.empty
              }
      adjustContext (insertSpan (wrapSpanContext sc))
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      c <- meterCreateCounterInt64 m "unsampled.exemplar" Nothing Nothing defaultAdvisoryParameters
      counterAdd c 1 emptyAttributes
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts} ->
          V.null (sumDataPointExemplars (V.head pts)) `shouldBe` True
        _ -> expectationFailure "expected MetricExportSum"

  describe "Concurrency" $ do
    it "concurrent counter increments produce correct total" $ do
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      c <- meterCreateCounterInt64 m "stress.counter" Nothing Nothing defaultAdvisoryParameters
      mapConcurrently_
        (\_ -> replicateM_ 100 $ counterAdd c 1 emptyAttributes)
        [(1 :: Int) .. 100]
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts, mesIsInt = True} -> do
          V.length pts `shouldBe` 1
          sumDataPointValue (V.head pts) `shouldBe` IntNumber (10000 :: Int64)
        _ -> expectationFailure "expected MetricExportSum"

    it "concurrent histogram records produce correct count" $ do
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      h <- meterCreateHistogram m "stress.hist" Nothing Nothing defaultAdvisoryParameters
      mapConcurrently_
        (\_ -> replicateM_ 50 $ histogramRecord h 1.0 emptyAttributes)
        [(1 :: Int) .. 50]
      batches <- collectResourceMetrics env
      histogramObservationCountInBatches batches `shouldBe` 2500

    it "concurrent up-down counter cancels to zero" $ do
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      udc <- meterCreateUpDownCounterInt64 m "stress.udc" Nothing Nothing defaultAdvisoryParameters
      let adds = mapConcurrently_ (\_ -> replicateM_ 100 $ upDownCounterAdd udc 1 emptyAttributes) [(1 :: Int) .. 50]
          subs = mapConcurrently_ (\_ -> replicateM_ 100 $ upDownCounterAdd udc (-1) emptyAttributes) [(1 :: Int) .. 50]
      a1 <- async adds
      a2 <- async subs
      wait a1
      wait a2
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts, mesIsInt = True} -> do
          V.length pts `shouldBe` 1
          sumDataPointValue (V.head pts) `shouldBe` IntNumber (0 :: Int64)
        _ -> expectationFailure "expected MetricExportSum"

    it "concurrent collect during recording does not lose data" $ do
      let opts = defaultSdkMeterProviderOptions {aggregationTemporality = AggregationDelta}
      (provider, env) <- mkProvider opts
      m <- getMeter provider defaultScope
      c <- meterCreateCounterInt64 m "delta.concurrent" Nothing Nothing defaultAdvisoryParameters
      totalRef <- newIORef (0 :: Int64)
      worker <-
        async $
          mapConcurrently_
            (\_ -> replicateM_ 10 $ counterAdd c 1 emptyAttributes)
            [(1 :: Int) .. 100]
      let drain = do
            batches <- collectResourceMetrics env
            let s = sumInt64SumPointsInBatches batches
            if s == 0
              then return ()
              else do
                modifyIORef' totalRef (+ s)
                drain
          go = do
            batches <- collectResourceMetrics env
            modifyIORef' totalRef (+ sumInt64SumPointsInBatches batches)
            r <- poll worker
            case r of
              Nothing -> go
              Just (Right ()) -> drain
              Just (Left e) -> throwIO e
      go
      _ <- wait worker
      total <- readIORef totalRef
      total `shouldBe` 1000

    it "concurrent creation of same-named counters shares storage" $ do
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      mapConcurrently_
        ( \_ -> do
            counter <- meterCreateCounterInt64 m "shared" Nothing Nothing defaultAdvisoryParameters
            replicateM_ 100 $ counterAdd counter 1 emptyAttributes
        )
        [(1 :: Int) .. 10]
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts, mesIsInt = True} -> do
          V.length pts `shouldBe` 1
          sumDataPointValue (V.head pts) `shouldBe` IntNumber (1000 :: Int64)
        _ -> expectationFailure "expected MetricExportSum"

    it "concurrent gauge records converge to some valid value" $ do
      let validValues = Set.fromList [(1 :: Int64) .. 20]
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      g <- meterCreateGaugeInt64 m "stress.gauge" Nothing Nothing defaultAdvisoryParameters
      mapConcurrently_
        (\tid -> replicateM_ 1000 $ gaugeRecord g tid emptyAttributes)
        [1 .. 20]
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportGauge {megGaugePoints = pts, megIsInt = True} -> do
          V.length pts `shouldBe` 1
          case gaugeDataPointValue (V.head pts) of
            IntNumber v -> v `shouldSatisfy` (`Set.member` validValues)
            DoubleNumber _ -> expectationFailure "expected Int64 gauge"
        _ -> expectationFailure "expected MetricExportGauge"

    it "concurrent delta collections do not double-count observable callbacks" $ do
      let opts = defaultSdkMeterProviderOptions {aggregationTemporality = AggregationDelta}
      (provider, env) <- mkProvider opts
      m <- getMeter provider defaultScope
      let cb res = observe res (1 :: Int64) emptyAttributes
      _ <- meterCreateObservableCounterInt64 m "obs.serial" Nothing Nothing defaultAdvisoryParameters [cb]
      results <- mapConcurrently (\_ -> collectResourceMetrics env) [(1 :: Int) .. 20]
      let totals = map sumInt64SumPointsInBatches results
      sum totals `shouldBe` 20

    it "concurrent collections under cumulative are safe" $ do
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      c <- meterCreateCounterInt64 m "cum.parallel" Nothing Nothing defaultAdvisoryParameters
      counterAdd c 100 emptyAttributes
      results <- mapConcurrently (\_ -> collectResourceMetrics env) [(1 :: Int) .. 10]
      let totals = map sumInt64SumPointsInBatches results
      all (== 100) totals `shouldBe` True

    it "shutdown during active recording is safe" $ do
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      c <- meterCreateCounterInt64 m "shutdown.race" Nothing Nothing defaultAdvisoryParameters
      gate <- newEmptyMVar
      void $ forkIO $ do
        replicateM_ 5000 $ counterAdd c 1 emptyAttributes
        putMVar gate ()
      replicateM_ 1000 $ counterAdd c 1 emptyAttributes
      _ <- shutdownMeterProvider provider
      takeMVar gate
      m2 <- getMeter provider defaultScope
      c2 <- meterCreateCounterInt64 m2 "post.shutdown" Nothing Nothing defaultAdvisoryParameters
      en <- counterEnabled c2
      en `shouldBe` False

    it "collectResourceMetrics after shutdown returns empty" $ do
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      c <- meterCreateCounterInt64 m "pre.shut" Nothing Nothing defaultAdvisoryParameters
      counterAdd c 42 emptyAttributes
      _ <- shutdownMeterProvider provider
      batches <- collectResourceMetrics env
      case batches of
        [rme] -> V.null (resourceMetricsScopes rme) `shouldBe` True
        _ -> expectationFailure "expected single empty ResourceMetricsExport"

    it "concurrent recording + collection + shutdown does not crash" $ do
      let opts = defaultSdkMeterProviderOptions {aggregationTemporality = AggregationDelta}
      (provider, env) <- mkProvider opts
      m <- getMeter provider defaultScope
      c <- meterCreateCounterInt64 m "chaos" Nothing Nothing defaultAdvisoryParameters
      h <- meterCreateHistogram m "chaos.hist" Nothing Nothing defaultAdvisoryParameters
      replicateConcurrently_ 4 $ do
        replicateM_ 500 $ do
          counterAdd c 1 emptyAttributes
          histogramRecord h 1.0 emptyAttributes
          _ <- collectResourceMetrics env
          pure ()
      _ <- shutdownMeterProvider provider
      pure ()

  describe "Observable callback resilience" $ do
    it "one failing callback does not prevent other callbacks from running" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      let goodCb res = observe res (42 :: Int64) emptyAttributes
          badCb _res = error "callback explosion"
      _ <- meterCreateObservableCounterInt64 m "resilient" Nothing Nothing defaultAdvisoryParameters [badCb, goodCb]
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts} ->
          sumDataPointValue (V.head pts) `shouldBe` IntNumber (42 :: Int64)
        _ -> expectationFailure "expected MetricExportSum from surviving callback"

    it "exponential histogram handles values spanning many orders of magnitude" $ do
      let adv = defaultAdvisoryParameters {advisoryHistogramAggregation = Just (HistogramAggregationExponential 20)}
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      h <- meterCreateHistogram m "wide.range" Nothing Nothing adv
      histogramRecord h 0.001 emptyAttributes
      histogramRecord h 1.0 emptyAttributes
      histogramRecord h 1000.0 emptyAttributes
      histogramRecord h 1000000.0 emptyAttributes
      batches <- collectResourceMetrics env
      case firstMetric batches of
        MetricExportExponentialHistogram {meehPoints = pts} -> do
          let p = V.head pts
          exponentialHistogramDataPointCount p `shouldBe` 4
          exponentialHistogramDataPointScale p `shouldSatisfy` (<= 20)
          V.all (>= 0) (exponentialHistogramDataPointPositiveBucketCounts p) `shouldBe` True
        _ -> expectationFailure "expected MetricExportExponentialHistogram"
