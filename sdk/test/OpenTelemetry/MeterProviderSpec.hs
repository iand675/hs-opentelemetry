{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module OpenTelemetry.MeterProviderSpec (spec) where

import Control.Concurrent (forkIO)
import Control.Concurrent.Async (async, mapConcurrently, mapConcurrently_, poll, replicateConcurrently_, wait)
import Control.Concurrent.MVar (newEmptyMVar, putMVar, takeMVar)
import Control.Exception (throwIO)
import Control.Monad (forM_, replicateM_, void)
import Data.IORef (modifyIORef', newIORef, readIORef)
import Data.Int (Int64)
import Data.Maybe (isJust)
import qualified Data.Set as Set
import Data.Text (Text, pack)
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
  MetricReader (..),
  SdkMeterEnv (..),
  SdkMeterExemplarOptions (..),
  SdkMeterProviderOptions (..),
  collectResourceMetrics,
  createMeterProvider,
  cumulativeTemporality,
  defaultSdkMeterExemplarOptions,
  defaultSdkMeterProviderOptions,
  deltaTemporality,
 )
import OpenTelemetry.Metric.Core (
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
import OpenTelemetry.Metric.View (View (..), ViewAggregation (..), ViewSelector (..))
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
    , viewExemplarFilter = Nothing
    }


scope :: InstrumentationLibrary
scope = "test-scope"


mkProvider :: SdkMeterProviderOptions -> IO (MeterProvider, SdkMeterEnv)
mkProvider = createMeterProvider emptyMaterializedResources


defaultScope :: InstrumentationLibrary
defaultScope = instrumentationLibrary "test" "1.0"


-- | Sum all Int64 sum data points across every metric in a collect batch.
sumInt64SumPointsInBatches :: V.Vector ResourceMetricsExport -> Int64
sumInt64SumPointsInBatches batches =
  V.sum $ V.map sumResource batches
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


sumDblSumPointsInBatches :: V.Vector ResourceMetricsExport -> Double
sumDblSumPointsInBatches batches =
  V.sum $ V.map sumResource batches
  where
    sumResource rme = V.sum $ V.map sumScope (resourceMetricsScopes rme)
    sumScope sme = V.sum $ V.map sumExport (scopeMetricsExports sme)
    sumExport me = case me of
      MetricExportSum {mesSumPoints = pts, mesIsInt = False} ->
        V.sum $ V.map dblFromSumPoint pts
      _ -> 0
    dblFromSumPoint p = case sumDataPointValue p of
      DoubleNumber d -> d
      IntNumber _ -> 0


extractGaugePoints :: ResourceMetricsExport -> [GaugeDataPoint]
extractGaugePoints rme =
  concatMap extractScope (V.toList (resourceMetricsScopes rme))
  where
    extractScope sme = concatMap extractExport (V.toList (scopeMetricsExports sme))
    extractExport me = case me of
      MetricExportGauge {megPoints = pts} -> V.toList pts
      _ -> []


-- | Total observation count across all explicit histogram data points in a batch.
histogramObservationCountInBatches :: V.Vector ResourceMetricsExport -> Word64
histogramObservationCountInBatches batches =
  V.sum $ V.map sumResource batches
  where
    sumResource rme = V.sum $ V.map sumScope (resourceMetricsScopes rme)
    sumScope sme = V.sum $ V.map sumExport (scopeMetricsExports sme)
    sumExport me = case me of
      MetricExportHistogram {mehPoints = pts} ->
        V.sum $ V.map histogramDataPointCount pts
      _ -> 0


firstMetric :: V.Vector ResourceMetricsExport -> MetricExport
firstMetric batches =
  case V.toList batches of
    [rme] ->
      V.head (scopeMetricsExports (V.head (resourceMetricsScopes rme)))
    _ -> error "expected single ResourceMetricsExport"


spec :: Spec
spec = do
  describe "OpenTelemetry.MeterProvider" $ do
    -- Metrics SDK: MeterProvider, instruments, collect/export
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/
    -- Metrics SDK §Counter (synchronous, monotonic)
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#counter
    it "aggregates Int64 counter measurements (cumulative sum)" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      c <- meterCreateCounterInt64 m "acount" Nothing Nothing defaultAdvisoryParameters
      counterAdd c 3 emptyAttributes
      counterAdd c 7 emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts, mesName = nm, mesMonotonic = mono, mesIsInt = isInt} -> do
          nm `shouldBe` "acount"
          mono `shouldBe` True
          isInt `shouldBe` True
          V.length pts `shouldBe` 1
          sumDataPointValue (V.head pts) `shouldBe` IntNumber (10 :: Int64)
        _ -> expectationFailure "expected MetricExportSum"

    -- Metrics SDK §Counter (floating-point)
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#counter
    it "aggregates Double counter measurements" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      c <- meterCreateCounterDouble m "dcounter" Nothing Nothing defaultAdvisoryParameters
      counterAdd c 1.5 emptyAttributes
      counterAdd c 2.5 emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts, mesIsInt = isInt} -> do
          isInt `shouldBe` False
          sumDataPointValue (V.head pts) `shouldBe` DoubleNumber (4.0 :: Double)
        _ -> expectationFailure "expected MetricExportSum"

    -- Metrics SDK §UpDownCounter
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#updowncounter
    it "aggregates Int64 up-down counter (non-monotonic)" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      udc <- meterCreateUpDownCounterInt64 m "queue.depth" Nothing Nothing defaultAdvisoryParameters
      upDownCounterAdd udc 10 emptyAttributes
      upDownCounterAdd udc (-3) emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts, mesMonotonic = mono} -> do
          mono `shouldBe` False
          sumDataPointValue (V.head pts) `shouldBe` IntNumber (7 :: Int64)
        _ -> expectationFailure "expected MetricExportSum"

    -- Metrics SDK §UpDownCounter (Double)
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#updowncounter
    it "aggregates Double up-down counter" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      udc <- meterCreateUpDownCounterDouble m "temp.diff" Nothing Nothing defaultAdvisoryParameters
      upDownCounterAdd udc 5.0 emptyAttributes
      upDownCounterAdd udc (-1.2) emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts, mesMonotonic = mono, mesIsInt = isInt} -> do
          mono `shouldBe` False
          isInt `shouldBe` False
          case sumDataPointValue (V.head pts) of
            DoubleNumber d -> abs (d - 3.8) `shouldSatisfy` (< 0.001)
            IntNumber _ -> expectationFailure "expected Double"
        _ -> expectationFailure "expected MetricExportSum"

    -- Metrics SDK §Counter: negative measurements are invalid / dropped
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#counter
    it "counter drops negative values (monotonic)" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      c <- meterCreateCounterInt64 m "no.neg" Nothing Nothing defaultAdvisoryParameters
      counterAdd c 10 emptyAttributes
      counterAdd c (-5) emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts, mesMonotonic = mono} -> do
          mono `shouldBe` True
          sumDataPointValue (V.head pts) `shouldBe` IntNumber (10 :: Int64)
        _ -> expectationFailure "expected MetricExportSum"

    -- Metrics SDK §Counter: negative Double measurements dropped
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#counter
    it "counter drops negative Double values" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      c <- meterCreateCounterDouble m "no.neg.dbl" Nothing Nothing defaultAdvisoryParameters
      counterAdd c 5.0 emptyAttributes
      counterAdd c (-2.0) emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts} ->
          sumDataPointValue (V.head pts) `shouldBe` DoubleNumber (5.0 :: Double)
        _ -> expectationFailure "expected MetricExportSum"

    -- Metrics SDK §Histogram (explicit bucket boundaries)
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#histogram
    it "records explicit histogram measurements" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      h <- meterCreateHistogram m "latency" Nothing Nothing defaultAdvisoryParameters
      histogramRecord h 1.0 emptyAttributes
      histogramRecord h 50.0 emptyAttributes
      histogramRecord h 9999.0 emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
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

    -- Metrics SDK §Histogram: advisory/view bucket boundaries
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#histogram
    it "honors advisory explicit bucket boundaries" $ do
      let adv = defaultAdvisoryParameters {advisoryExplicitBucketBoundaries = Just [10, 100]}
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      h <- meterCreateHistogram m "custom.hist" Nothing Nothing adv
      histogramRecord h 5.0 emptyAttributes
      histogramRecord h 50.0 emptyAttributes
      histogramRecord h 200.0 emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportHistogram {mehPoints = pts} -> do
          let p = V.head pts
          V.length (histogramDataPointExplicitBounds p) `shouldBe` 2
          V.length (histogramDataPointBucketCounts p) `shouldBe` 3
          V.toList (histogramDataPointBucketCounts p) `shouldBe` [1, 1, 1]
        _ -> expectationFailure "expected MetricExportHistogram"

    -- Metrics SDK §Gauge (synchronous, last value)
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#gauge
    it "records Int64 gauge (last value wins)" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      g <- meterCreateGaugeInt64 m "mem.used" Nothing Nothing defaultAdvisoryParameters
      gaugeRecord g 100 emptyAttributes
      gaugeRecord g 200 emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportGauge {megGaugePoints = pts, megIsInt = isInt} -> do
          isInt `shouldBe` True
          gaugeDataPointValue (V.head pts) `shouldBe` IntNumber (200 :: Int64)
        _ -> expectationFailure "expected MetricExportGauge"

    -- Metrics SDK §Gauge (Double)
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#gauge
    it "records Double gauge" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      g <- meterCreateGaugeDouble m "cpu.pct" Nothing Nothing defaultAdvisoryParameters
      gaugeRecord g 0.75 emptyAttributes
      gaugeRecord g 0.42 emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportGauge {megGaugePoints = pts} ->
          gaugeDataPointValue (V.head pts) `shouldBe` DoubleNumber (0.42 :: Double)
        _ -> expectationFailure "expected MetricExportGauge"

    -- Metrics SDK §Base2 Exponential Histogram Aggregation
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#base2-exponential-bucket-histogram-aggregation
    it "exponential histogram records positive measurements" $ do
      let adv = defaultAdvisoryParameters {advisoryHistogramAggregation = Just (HistogramAggregationExponential 3)}
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      h <- meterCreateHistogram m "exp.latency" Nothing Nothing adv
      histogramRecord h 2.5 emptyAttributes
      histogramRecord h 0.0 emptyAttributes
      histogramRecord h 100.0 emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportExponentialHistogram {meehPoints = pts} -> do
          V.length pts `shouldBe` 1
          let p = V.head pts
          exponentialHistogramDataPointCount p `shouldBe` 3
          exponentialHistogramDataPointZeroCount p `shouldBe` 1
          V.null (exponentialHistogramDataPointPositiveBucketCounts p) `shouldBe` False
        _ -> expectationFailure "expected MetricExportExponentialHistogram"

    -- Metrics SDK §Histogram: negative values invalid for histogram recordings
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#histogram
    it "exponential histogram drops negative measurements" $ do
      let adv = defaultAdvisoryParameters {advisoryHistogramAggregation = Just (HistogramAggregationExponential 2)}
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      h <- meterCreateHistogram m "signed" Nothing Nothing adv
      histogramRecord h (-5.0) emptyAttributes
      histogramRecord h (-1.0) emptyAttributes
      histogramRecord h 3.0 emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportExponentialHistogram {meehPoints = pts} -> do
          let p = V.head pts
          exponentialHistogramDataPointCount p `shouldBe` 1
          exponentialHistogramDataPointSum p `shouldBe` Just 3.0
        _ -> expectationFailure "expected MetricExportExponentialHistogram"

    -- Metrics SDK §Asynchronous Counter (ObservableCounter)
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#asynchronous-counter
    it "observable counter callbacks run on collect" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      let cb res = observe res (42 :: Int64) emptyAttributes
      _ <- meterCreateObservableCounterInt64 m "obs.counter" Nothing Nothing defaultAdvisoryParameters [cb]
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts, mesName = nm, mesMonotonic = mono} -> do
          nm `shouldBe` "obs.counter"
          mono `shouldBe` True
          sumDataPointValue (V.head pts) `shouldBe` IntNumber (42 :: Int64)
        _ -> expectationFailure "expected MetricExportSum"

    -- Metrics SDK §Asynchronous Gauge
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#asynchronous-gauge
    it "observable gauge reports last observed value" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      let cb res = observe res (3.14 :: Double) emptyAttributes
      _ <- meterCreateObservableGaugeDouble m "obs.gauge" Nothing Nothing defaultAdvisoryParameters [cb]
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportGauge {megGaugePoints = pts, megName = nm} -> do
          nm `shouldBe` "obs.gauge"
          gaugeDataPointValue (V.head pts) `shouldBe` DoubleNumber (3.14 :: Double)
        _ -> expectationFailure "expected MetricExportGauge"

    -- Metrics SDK §Asynchronous UpDownCounter
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#asynchronous-updowncounter
    it "observable up-down counter is non-monotonic" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      let cb res = observe res (-10 :: Int64) emptyAttributes
      _ <- meterCreateObservableUpDownCounterInt64 m "obs.udc" Nothing Nothing defaultAdvisoryParameters [cb]
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts, mesMonotonic = mono} -> do
          mono `shouldBe` False
          sumDataPointValue (V.head pts) `shouldBe` IntNumber (-10 :: Int64)
        _ -> expectationFailure "expected MetricExportSum"

    -- Metrics SDK §Observable instrument API (callback registration)
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#observable-instruments
    it "unregisterObservableCallback removes the callback" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      -- Callbacks observe distinct attribute sets so we can verify both fire
      let a1 = addAttribute defaultAttributeLimits emptyAttributes "cb" ("one" :: Text)
          a2 = addAttribute defaultAttributeLimits emptyAttributes "cb" ("two" :: Text)
      let cb1 res = observe res (100 :: Int64) a1
      oc <- meterCreateObservableCounterInt64 m "unreg.counter" Nothing Nothing defaultAdvisoryParameters [cb1]

      handle <- observableCounterRegisterCallback oc (\res -> observe res (200 :: Int64) a2)
      batches1 <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches1 of
        MetricExportSum {mesSumPoints = pts} ->
          V.length pts `shouldBe` 2
        _ -> expectationFailure "expected MetricExportSum with both callbacks"

      unregisterObservableCallback handle
      batches2 <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches2 of
        MetricExportSum {mesSumPoints = pts} -> do
          V.length pts `shouldBe` 2
          -- cb1 still fires: its series has value 100
          let cb1Pts = V.filter (\p -> lookupAttribute (sumDataPointAttributes p) "cb" == Just (AttributeValue (TextAttribute "one"))) pts
          sumDataPointValue (V.head cb1Pts) `shouldBe` IntNumber (100 :: Int64)
        _ -> expectationFailure "expected MetricExportSum after unregister"

    -- Metrics SDK §Cardinality limits (overflow attribute)
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#cardinality-limits
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
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts} -> do
          V.length pts `shouldBe` 2
          let overflow = V.filter (\p -> lookupAttribute (sumDataPointAttributes p) "otel.metric.overflow" == Just (AttributeValue (BoolAttribute True))) pts
          V.length overflow `shouldBe` 1
          sumDataPointValue (V.head overflow) `shouldBe` IntNumber (100 :: Int64)
        _ -> expectationFailure "expected MetricExportSum"

    -- Metrics SDK §View: drop aggregation
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#view
    it "view drop prevents recording" $ do
      let v = mkView "nope" Nothing ViewAggregationDrop Nothing Nothing Nothing
          opts = defaultSdkMeterProviderOptions {views = [v]}
      (provider, env) <- createMeterProvider emptyMaterializedResources opts
      m <- getMeter provider scope
      c <- meterCreateCounterInt64 m "nope" Nothing Nothing defaultAdvisoryParameters
      counterAdd c 1 emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      case V.toList batches of
        [rme] -> V.null (resourceMetricsScopes rme) `shouldBe` True
        _ -> expectationFailure "expected single ResourceMetricsExport"

    -- Metrics SDK §View: name override
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#view
    it "view overrides exported metric name" $ do
      let v = mkView "original" Nothing ViewAggregationDefault Nothing (Just "renamed") Nothing
          opts = defaultSdkMeterProviderOptions {views = [v]}
      (provider, env) <- createMeterProvider emptyMaterializedResources opts
      m <- getMeter provider scope
      c <- meterCreateCounterInt64 m "original" Nothing Nothing defaultAdvisoryParameters
      counterAdd c 5 emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportSum {mesName = nm} -> nm `shouldBe` "renamed"
        _ -> expectationFailure "expected MetricExportSum"

    -- Metrics SDK §View: description override
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#view
    it "view overrides exported metric description" $ do
      let v = mkView "described" Nothing ViewAggregationDefault Nothing Nothing (Just "new desc")
          opts = defaultSdkMeterProviderOptions {views = [v]}
      (provider, env) <- createMeterProvider emptyMaterializedResources opts
      m <- getMeter provider scope
      c <- meterCreateCounterInt64 m "described" Nothing (Just "old desc") defaultAdvisoryParameters
      counterAdd c 1 emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportSum {mesDescription = d} -> d `shouldBe` "new desc"
        _ -> expectationFailure "expected MetricExportSum"

    -- Metrics SDK §View: attribute key filter
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#view
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
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts} -> do
          let a = sumDataPointAttributes (V.head pts)
          lookupAttribute a "keep" `shouldSatisfy` isJust
          lookupAttribute a "drop" `shouldBe` Nothing
        _ -> expectationFailure "expected MetricExportSum"

    -- Metrics SDK §View: explicit bucket histogram aggregation
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#view
    it "view overrides histogram to explicit bucket with custom bounds" $ do
      let v = mkView "h.*" Nothing (ViewAggregationExplicitBucketHistogram [1, 10, 100]) Nothing Nothing Nothing
          opts = defaultSdkMeterProviderOptions {views = [v]}
      (provider, env) <- createMeterProvider emptyMaterializedResources opts
      m <- getMeter provider scope
      h <- meterCreateHistogram m "h.latency" Nothing Nothing defaultAdvisoryParameters
      histogramRecord h 5.0 emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportHistogram {mehPoints = pts} -> do
          let p = V.head pts
          V.length (histogramDataPointExplicitBounds p) `shouldBe` 3
        _ -> expectationFailure "expected MetricExportHistogram"

    -- Metrics SDK §View: exponential histogram aggregation
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#view
    it "view overrides histogram to exponential" $ do
      let v = mkView "h.*" Nothing (ViewAggregationExponentialHistogram 5) Nothing Nothing Nothing
          opts = defaultSdkMeterProviderOptions {views = [v]}
      (provider, env) <- createMeterProvider emptyMaterializedResources opts
      m <- getMeter provider scope
      h <- meterCreateHistogram m "h.exp" Nothing Nothing defaultAdvisoryParameters
      histogramRecord h 42.0 emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportExponentialHistogram {meehPoints = pts} ->
          V.length pts `shouldBe` 1
        _ -> expectationFailure "expected MetricExportExponentialHistogram"

    -- Metrics SDK §Aggregation temporality (delta vs cumulative)
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#aggregation-temporality
    it "delta temporality resets after collect" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      c <- meterCreateCounterInt64 m "delta.c" Nothing Nothing defaultAdvisoryParameters
      counterAdd c 5 emptyAttributes
      b1 <- collectResourceMetrics env deltaTemporality
      case firstMetric b1 of
        MetricExportSum {mesSumPoints = pts, mesAggregationTemporality = temp} -> do
          temp `shouldBe` AggregationDelta
          sumDataPointValue (V.head pts) `shouldBe` IntNumber (5 :: Int64)
        _ -> expectationFailure "expected MetricExportSum"
      counterAdd c 3 emptyAttributes
      b2 <- collectResourceMetrics env deltaTemporality
      case firstMetric b2 of
        MetricExportSum {mesSumPoints = pts} ->
          sumDataPointValue (V.head pts) `shouldBe` IntNumber (3 :: Int64)
        _ -> expectationFailure "expected MetricExportSum"

    -- Metrics SDK §Aggregation temporality: histogram delta export
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#aggregation-temporality
    it "delta temporality resets histogram after collect" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      h <- meterCreateHistogram m "delta.hist" Nothing Nothing defaultAdvisoryParameters
      histogramRecord h 10.0 emptyAttributes
      _ <- collectResourceMetrics env deltaTemporality
      histogramRecord h 20.0 emptyAttributes
      b2 <- collectResourceMetrics env deltaTemporality
      case firstMetric b2 of
        MetricExportHistogram {mehPoints = pts} -> do
          let p = V.head pts
          histogramDataPointCount p `shouldBe` 1
          abs (histogramDataPointSum p - 20.0) `shouldSatisfy` (< 0.001)
        _ -> expectationFailure "expected MetricExportHistogram"

    -- Metrics SDK: distinct attribute sets → distinct metric points
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#instrument
    it "multiple attribute sets produce separate data points" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      c <- meterCreateCounterInt64 m "multi" Nothing Nothing defaultAdvisoryParameters
      let a1 = addAttribute defaultAttributeLimits emptyAttributes "k" ("v1" :: Text)
          a2 = addAttribute defaultAttributeLimits emptyAttributes "k" ("v2" :: Text)
      counterAdd c 1 a1
      counterAdd c 2 a2
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts} ->
          V.length pts `shouldBe` 2
        _ -> expectationFailure "expected MetricExportSum"

    -- Metrics data model: start time for cumulative temporality
    -- https://opentelemetry.io/docs/specs/otel/metrics/data-model/#sums
    it "startTimeUnixNano is non-zero for cumulative" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      c <- meterCreateCounterInt64 m "timed" Nothing Nothing defaultAdvisoryParameters
      counterAdd c 1 emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts} ->
          sumDataPointStartTimeUnixNano (V.head pts) `shouldSatisfy` (> (0 :: Word64))
        _ -> expectationFailure "expected MetricExportSum"

    -- Metrics SDK §Shutdown MeterProvider: recording stops after shutdown
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#shutdown
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
      batches <- collectResourceMetrics env cumulativeTemporality
      case V.toList batches of
        [rme] -> V.null (resourceMetricsScopes rme) `shouldBe` True
        _ -> expectationFailure "expected single ResourceMetricsExport"

    -- Metrics SDK §Shutdown: repeated shutdown behavior
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#shutdown
    it "shutdown is idempotent (second call returns failure)" $ do
      (provider, _env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      r1 <- shutdownMeterProvider provider
      r1 `shouldBe` ShutdownSuccess
      r2 <- shutdownMeterProvider provider
      r2 `shouldBe` ShutdownFailure

    -- Metrics SDK §ForceFlush MeterProvider
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#forceflush
    it "forceFlush succeeds" $ do
      (provider, _env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      result <- forceFlushMeterProvider provider Nothing
      result `shouldBe` FlushSuccess

    -- Metrics SDK §Instrument naming rules (invalid name → no-op)
    -- https://opentelemetry.io/docs/specs/otel/metrics/api/#instrument-name-syntax
    it "invalid instrument name produces noop instrument" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      c <- meterCreateCounterInt64 m "" Nothing Nothing defaultAdvisoryParameters
      enabled <- counterEnabled c
      enabled `shouldBe` False
      counterAdd c 99 emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      case V.toList batches of
        [rme] -> V.null (resourceMetricsScopes rme) `shouldBe` True
        _ -> expectationFailure "expected single ResourceMetricsExport"

    -- Metrics SDK §Instrument name case insensitivity (same instrument identity)
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#instrument
    it "instrument names are case-insensitive for dedup" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      c1 <- meterCreateCounterInt64 m "My.Counter" Nothing Nothing defaultAdvisoryParameters
      c2 <- meterCreateCounterInt64 m "my.counter" Nothing Nothing defaultAdvisoryParameters
      counterAdd c1 10 emptyAttributes
      counterAdd c2 20 emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts} ->
          sumDataPointValue (V.head pts) `shouldBe` IntNumber (30 :: Int64)
        _ -> expectationFailure "expected a single MetricExportSum (deduped)"

    -- Metrics API §Instrument enabled state
    -- https://opentelemetry.io/docs/specs/otel/metrics/api/#enabled
    it "enabled returns True for valid SDK instruments" $ do
      (provider, _) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      c <- meterCreateCounterInt64 m "valid" Nothing Nothing defaultAdvisoryParameters
      enabled <- counterEnabled c
      enabled `shouldBe` True

    -- Metrics SDK §Collect: no recordings → empty export
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#collect
    it "collecting without recording returns empty scopes" $ do
      (_, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      batches <- collectResourceMetrics env cumulativeTemporality
      case V.toList batches of
        [rme] -> V.null (resourceMetricsScopes rme) `shouldBe` True
        _ -> expectationFailure "expected single ResourceMetricsExport"

    -- Metrics SDK §Aggregation temporality: cumulative Counter
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#aggregation-temporality
    it "cumulative temporality keeps counter sum across collects" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      c <- meterCreateCounterInt64 m "cum.across" Nothing Nothing defaultAdvisoryParameters
      counterAdd c 5 emptyAttributes
      b1 <- collectResourceMetrics env cumulativeTemporality
      case firstMetric b1 of
        MetricExportSum {mesSumPoints = pts, mesAggregationTemporality = temp} -> do
          temp `shouldBe` AggregationCumulative
          sumDataPointValue (V.head pts) `shouldBe` IntNumber (5 :: Int64)
        _ -> expectationFailure "expected MetricExportSum"
      counterAdd c 3 emptyAttributes
      b2 <- collectResourceMetrics env cumulativeTemporality
      case firstMetric b2 of
        MetricExportSum {mesSumPoints = pts} ->
          sumDataPointValue (V.head pts) `shouldBe` IntNumber (8 :: Int64)
        _ -> expectationFailure "expected MetricExportSum"

    -- Metrics SDK §Explicit bucket histogram advice (default boundaries)
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#explicit-bucket-histogram-aggregation
    it "default explicit histogram uses spec bucket boundaries" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      h <- meterCreateHistogram m "default.bounds" Nothing Nothing defaultAdvisoryParameters
      histogramRecord h 1.0 emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportHistogram {mehPoints = pts} -> do
          let expected =
                V.fromList [0, 5, 10, 25, 50, 75, 100, 250, 500, 750, 1000, 2500, 5000, 7500, 10000]
          histogramDataPointExplicitBounds (V.head pts) `shouldBe` expected
        _ -> expectationFailure "expected MetricExportHistogram"

    -- Metrics SDK §Histogram: non-finite values invalid
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#histogram
    it "histogram drops NaN and Infinity measurements" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      h <- meterCreateHistogram m "nan.inf" Nothing Nothing defaultAdvisoryParameters
      let nan = 0 / 0 :: Double
          inf = 1 / 0 :: Double
      histogramRecord h nan emptyAttributes
      histogramRecord h inf emptyAttributes
      histogramRecord h 5.0 emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportHistogram {mehPoints = pts} -> do
          let p = V.head pts
          histogramDataPointCount p `shouldBe` 1
          abs (histogramDataPointSum p - 5.0) `shouldSatisfy` (< 0.001)
        _ -> expectationFailure "expected MetricExportHistogram"

    -- Metrics SDK §Instrument: case-insensitive name identity
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#instrument
    it "instrument names differing only by case are deduplicated (spec: case-insensitive)" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      c1 <- meterCreateCounterInt64 m "MyCounter" Nothing Nothing defaultAdvisoryParameters
      c2 <- meterCreateCounterInt64 m "mycounter" Nothing Nothing defaultAdvisoryParameters
      counterAdd c1 1 emptyAttributes
      counterAdd c2 2 emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportSum {mesName = n, mesSumPoints = pts} -> do
          n `shouldBe` "mycounter"
          sumDataPointValue (V.head pts) `shouldBe` IntNumber (3 :: Int64)
        _ -> expectationFailure "expected single deduplicated MetricExportSum"

    -- Metrics SDK §Meter: instrumentation scope isolation
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#meter
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
      batches <- collectResourceMetrics env cumulativeTemporality
      case V.toList batches of
        [rme] -> do
          let scopes = resourceMetricsScopes rme
          V.length scopes `shouldBe` 2
          let sn0 = libraryName (scopeMetricsScope (scopes V.! 0))
              sn1 = libraryName (scopeMetricsScope (scopes V.! 1))
          sn0 == sn1 `shouldBe` False
        _ -> expectationFailure "expected single ResourceMetricsExport"

    -- Metrics SDK §Instrument metadata (unit, description) on export
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#instrument
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
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportSum {mesUnit = u, mesDescription = d} -> do
          u `shouldBe` "ms"
          d `shouldBe` "Request latency"
        _ -> expectationFailure "expected MetricExportSum"

    -- Metrics SDK §Observable instruments: multiple callbacks
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#observable-instruments
    it "observable counter runs every registered callback" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      let a1 = addAttribute defaultAttributeLimits emptyAttributes "cb" ("one" :: Text)
          a2 = addAttribute defaultAttributeLimits emptyAttributes "cb" ("two" :: Text)
      let cb1 res = observe res (10 :: Int64) a1
          cb2 res = observe res (32 :: Int64) a2
      _ <- meterCreateObservableCounterInt64 m "obs.twocb" Nothing Nothing defaultAdvisoryParameters [cb1, cb2]
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts} -> do
          V.length pts `shouldBe` 2
          let p1 = V.filter (\p -> lookupAttribute (sumDataPointAttributes p) "cb" == Just (AttributeValue (TextAttribute "one"))) pts
              p2 = V.filter (\p -> lookupAttribute (sumDataPointAttributes p) "cb" == Just (AttributeValue (TextAttribute "two"))) pts
          sumDataPointValue (V.head p1) `shouldBe` IntNumber (10 :: Int64)
          sumDataPointValue (V.head p2) `shouldBe` IntNumber (32 :: Int64)
        _ -> expectationFailure "expected MetricExportSum"

    -- Metrics API §Enabled: view drop disables instrument
    -- https://opentelemetry.io/docs/specs/otel/metrics/api/#enabled
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

    -- Metrics SDK §View selector (wildcard) + drop aggregation
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#view
    it "view with wildcard name drops all instruments" $ do
      let v = mkView "*" Nothing ViewAggregationDrop Nothing Nothing Nothing
          opts = defaultSdkMeterProviderOptions {views = [v]}
      (provider, env) <- createMeterProvider emptyMaterializedResources opts
      m <- getMeter provider scope
      c <- meterCreateCounterInt64 m "any.counter" Nothing Nothing defaultAdvisoryParameters
      h <- meterCreateHistogram m "any.hist" Nothing Nothing defaultAdvisoryParameters
      counterAdd c 5 emptyAttributes
      histogramRecord h 1.0 emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      case V.toList batches of
        [rme] -> V.null (resourceMetricsScopes rme) `shouldBe` True
        _ -> expectationFailure "expected single ResourceMetricsExport"

    -- Metrics SDK §Gauge + delta temporality export semantics
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#aggregation-temporality
    it "delta temporality gauge reports last value per collect" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      g <- meterCreateGaugeDouble m "delta.gauge.v" Nothing Nothing defaultAdvisoryParameters
      gaugeRecord g 10.0 emptyAttributes
      b1 <- collectResourceMetrics env deltaTemporality
      case firstMetric b1 of
        MetricExportGauge {megGaugePoints = pts} ->
          gaugeDataPointValue (V.head pts) `shouldBe` DoubleNumber (10.0 :: Double)
        _ -> expectationFailure "expected MetricExportGauge"
      gaugeRecord g 20.0 emptyAttributes
      b2 <- collectResourceMetrics env deltaTemporality
      case firstMetric b2 of
        MetricExportGauge {megGaugePoints = pts} ->
          gaugeDataPointValue (V.head pts) `shouldBe` DoubleNumber (20.0 :: Double)
        _ -> expectationFailure "expected MetricExportGauge"

    -- Metrics SDK §Get a Meter / instrument identity (same name → same instrument)
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#instrument
    it "re-registering a counter by name shares one stream" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      c1 <- meterCreateCounterInt64 m "reuse.name" Nothing Nothing defaultAdvisoryParameters
      c2 <- meterCreateCounterInt64 m "reuse.name" Nothing Nothing defaultAdvisoryParameters
      counterAdd c1 3 emptyAttributes
      counterAdd c2 7 emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts} -> do
          V.length pts `shouldBe` 1
          sumDataPointValue (V.head pts) `shouldBe` IntNumber (10 :: Int64)
        _ -> expectationFailure "expected MetricExportSum"

    -- Metrics SDK §Histogram cumulative temporality
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#aggregation-temporality
    it "cumulative histogram accumulates count and sum across collects" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      h <- meterCreateHistogram m "hist.cumulative" Nothing Nothing defaultAdvisoryParameters
      histogramRecord h 10.0 emptyAttributes
      b1 <- collectResourceMetrics env cumulativeTemporality
      case firstMetric b1 of
        MetricExportHistogram {mehPoints = pts, mehAggregationTemporality = temp} -> do
          temp `shouldBe` AggregationCumulative
          let p1 = V.head pts
          histogramDataPointCount p1 `shouldBe` 1
          abs (histogramDataPointSum p1 - 10.0) `shouldSatisfy` (< 0.001)
        _ -> expectationFailure "expected MetricExportHistogram"
      histogramRecord h 20.0 emptyAttributes
      b2 <- collectResourceMetrics env cumulativeTemporality
      case firstMetric b2 of
        MetricExportHistogram {mehPoints = pts} -> do
          let p2 = V.head pts
          histogramDataPointCount p2 `shouldBe` 2
          abs (histogramDataPointSum p2 - 30.0) `shouldSatisfy` (< 0.001)
        _ -> expectationFailure "expected MetricExportHistogram"

    -- Metrics SDK §Exemplar (trace context from active span)
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#exemplar
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
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts} -> do
          let exs = sumDataPointExemplars (V.head pts)
          V.length exs `shouldSatisfy` (>= 1)
          let ex = V.head exs
          metricExemplarTraceId ex `shouldBe` traceIdBytes tid
          metricExemplarSpanId ex `shouldBe` spanIdBytes sid
        _ -> expectationFailure "expected MetricExportSum"

    -- Metrics SDK §Exemplar on histogram data points
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#exemplar
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
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportHistogram {mehPoints = pts} -> do
          let exs = histogramDataPointExemplars (V.head pts)
          V.length exs `shouldSatisfy` (>= 1)
          let ex = V.head exs
          metricExemplarTraceId ex `shouldBe` traceIdBytes tid
          metricExemplarSpanId ex `shouldBe` spanIdBytes sid
        _ -> expectationFailure "expected MetricExportHistogram"

    -- Metrics SDK §Exemplar filter: AlwaysOff
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#exemplar-filter
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
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts} ->
          V.null (sumDataPointExemplars (V.head pts)) `shouldBe` True
        _ -> expectationFailure "expected MetricExportSum"

    -- Metrics SDK §Exemplar filter: AlwaysOn
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#exemplar-filter
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
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts} -> do
          let exs = sumDataPointExemplars (V.head pts)
          V.length exs `shouldSatisfy` (>= 1)
          metricExemplarTraceId (V.head exs) `shouldBe` traceIdBytes tid
        _ -> expectationFailure "expected MetricExportSum"

    -- Metrics SDK §Exemplar filter: TraceBased (unsampled span)
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#exemplar-filter
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
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts} ->
          V.null (sumDataPointExemplars (V.head pts)) `shouldBe` True
        _ -> expectationFailure "expected MetricExportSum"

  describe "Concurrency" $ do
    -- Implementation-specific: thread-safety of synchronous Counter recording
    it "concurrent counter increments produce correct total" $ do
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      c <- meterCreateCounterInt64 m "stress.counter" Nothing Nothing defaultAdvisoryParameters
      mapConcurrently_
        (\_ -> replicateM_ 100 $ counterAdd c 1 emptyAttributes)
        [(1 :: Int) .. 100]
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts, mesIsInt = True} -> do
          V.length pts `shouldBe` 1
          sumDataPointValue (V.head pts) `shouldBe` IntNumber (10000 :: Int64)
        _ -> expectationFailure "expected MetricExportSum"

    -- Implementation-specific: concurrent Histogram.Record safety
    it "concurrent histogram records produce correct count" $ do
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      h <- meterCreateHistogram m "stress.hist" Nothing Nothing defaultAdvisoryParameters
      mapConcurrently_
        (\_ -> replicateM_ 50 $ histogramRecord h 1.0 emptyAttributes)
        [(1 :: Int) .. 50]
      batches <- collectResourceMetrics env cumulativeTemporality
      histogramObservationCountInBatches batches `shouldBe` 2500

    -- Implementation-specific: concurrent UpDownCounter updates
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
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts, mesIsInt = True} -> do
          V.length pts `shouldBe` 1
          sumDataPointValue (V.head pts) `shouldBe` IntNumber (0 :: Int64)
        _ -> expectationFailure "expected MetricExportSum"

    -- Implementation-specific: collect vs record races (delta export)
    it "concurrent collect during recording does not lose data" $ do
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      c <- meterCreateCounterInt64 m "delta.concurrent" Nothing Nothing defaultAdvisoryParameters
      totalRef <- newIORef (0 :: Int64)
      worker <-
        async $
          mapConcurrently_
            (\_ -> replicateM_ 10 $ counterAdd c 1 emptyAttributes)
            [(1 :: Int) .. 100]
      let drain = do
            batches <- collectResourceMetrics env deltaTemporality
            let s = sumInt64SumPointsInBatches batches
            if s == 0
              then return ()
              else do
                modifyIORef' totalRef (+ s)
                drain
          go = do
            batches <- collectResourceMetrics env deltaTemporality
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

    -- Implementation-specific: instrument registry under concurrent creation
    it "concurrent creation of same-named counters shares storage" $ do
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      mapConcurrently_
        ( \_ -> do
            counter <- meterCreateCounterInt64 m "shared" Nothing Nothing defaultAdvisoryParameters
            replicateM_ 100 $ counterAdd counter 1 emptyAttributes
        )
        [(1 :: Int) .. 10]
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts, mesIsInt = True} -> do
          V.length pts `shouldBe` 1
          sumDataPointValue (V.head pts) `shouldBe` IntNumber (1000 :: Int64)
        _ -> expectationFailure "expected MetricExportSum"

    -- Implementation-specific: last-value Gauge under concurrent writers
    it "concurrent gauge records converge to some valid value" $ do
      let validValues = Set.fromList [(1 :: Int64) .. 20]
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      g <- meterCreateGaugeInt64 m "stress.gauge" Nothing Nothing defaultAdvisoryParameters
      mapConcurrently_
        (\tid -> replicateM_ 1000 $ gaugeRecord g tid emptyAttributes)
        [1 .. 20]
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportGauge {megGaugePoints = pts, megIsInt = True} -> do
          V.length pts `shouldBe` 1
          case gaugeDataPointValue (V.head pts) of
            IntNumber v -> v `shouldSatisfy` (`Set.member` validValues)
            DoubleNumber _ -> expectationFailure "expected Int64 gauge"
        _ -> expectationFailure "expected MetricExportGauge"

    -- Metrics SDK §Asynchronous instrument: delta temporality with concurrent collect
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#asynchronous-instrument-api
    it "concurrent delta collections do not double-count observable callbacks" $ do
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      -- Observable counter reports a fixed cumulative total of 100.
      -- Under delta export, the sum of all deltas across N serialised
      -- collections must equal exactly 100 (the total), not 100*N.
      let cb res = observe res (100 :: Int64) emptyAttributes
      _ <- meterCreateObservableCounterInt64 m "obs.serial" Nothing Nothing defaultAdvisoryParameters [cb]
      results <- mapConcurrently (\_ -> collectResourceMetrics env deltaTemporality) [(1 :: Int) .. 20]
      let totals = map sumInt64SumPointsInBatches results
      sum totals `shouldBe` 100

    -- Implementation-specific: concurrent Collect on cumulative instruments
    it "concurrent collections under cumulative are safe" $ do
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      c <- meterCreateCounterInt64 m "cum.parallel" Nothing Nothing defaultAdvisoryParameters
      counterAdd c 100 emptyAttributes
      results <- mapConcurrently (\_ -> collectResourceMetrics env cumulativeTemporality) [(1 :: Int) .. 10]
      let totals = map sumInt64SumPointsInBatches results
      all (== 100) totals `shouldBe` True

    -- Implementation-specific: shutdown vs recording race safety
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

    -- Metrics SDK §Shutdown: collect yields no telemetry
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#shutdown
    it "collectResourceMetrics after shutdown returns empty" $ do
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      c <- meterCreateCounterInt64 m "pre.shut" Nothing Nothing defaultAdvisoryParameters
      counterAdd c 42 emptyAttributes
      _ <- shutdownMeterProvider provider
      batches <- collectResourceMetrics env cumulativeTemporality
      case V.toList batches of
        [rme] -> V.null (resourceMetricsScopes rme) `shouldBe` True
        _ -> expectationFailure "expected single empty ResourceMetricsExport"

    -- Implementation-specific: stress test (record, collect, shutdown)
    it "concurrent recording + collection + shutdown does not crash" $ do
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      c <- meterCreateCounterInt64 m "chaos" Nothing Nothing defaultAdvisoryParameters
      h <- meterCreateHistogram m "chaos.hist" Nothing Nothing defaultAdvisoryParameters
      replicateConcurrently_ 4 $ do
        replicateM_ 500 $ do
          counterAdd c 1 emptyAttributes
          histogramRecord h 1.0 emptyAttributes
          _ <- collectResourceMetrics env deltaTemporality
          pure ()
      _ <- shutdownMeterProvider provider
      pure ()

  describe "Observable callback resilience" $ do
    -- Implementation-specific: isolate observable callback failures
    it "one failing callback does not prevent other callbacks from running" $ do
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      let goodCb res = observe res (42 :: Int64) emptyAttributes
          badCb _res = error "callback explosion"
      _ <- meterCreateObservableCounterInt64 m "resilient" Nothing Nothing defaultAdvisoryParameters [badCb, goodCb]
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts} ->
          sumDataPointValue (V.head pts) `shouldBe` IntNumber (42 :: Int64)
        _ -> expectationFailure "expected MetricExportSum from surviving callback"

    -- Metrics SDK §Base2 Exponential Histogram: wide dynamic range
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#base2-exponential-bucket-histogram-aggregation
    it "exponential histogram handles values spanning many orders of magnitude" $ do
      let adv = defaultAdvisoryParameters {advisoryHistogramAggregation = Just (HistogramAggregationExponential 20)}
      (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      m <- getMeter provider scope
      h <- meterCreateHistogram m "wide.range" Nothing Nothing adv
      histogramRecord h 0.001 emptyAttributes
      histogramRecord h 1.0 emptyAttributes
      histogramRecord h 1000.0 emptyAttributes
      histogramRecord h 1000000.0 emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportExponentialHistogram {meehPoints = pts} -> do
          let p = V.head pts
          exponentialHistogramDataPointCount p `shouldBe` 4
          exponentialHistogramDataPointScale p `shouldSatisfy` (<= 20)
          V.all (>= 0) (exponentialHistogramDataPointPositiveBucketCounts p) `shouldBe` True
        _ -> expectationFailure "expected MetricExportExponentialHistogram"

  -- ---------------------------------------------------------------------------
  -- Metric algorithm correctness: exhaustive numeric invariant tests
  -- ---------------------------------------------------------------------------
  describe "Metric algorithm correctness" $ do
    -- Metrics SDK: temporality and aggregation invariants (focused regression tests)
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/
    -- -----------------------------------------------------------------------
    -- Synchronous Counter: multi-cycle delta & cumulative
    -- -----------------------------------------------------------------------
    it "sync Int64 counter: delta resets between collections" $ do
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      c <- meterCreateCounterInt64 m "dc.i64" Nothing Nothing defaultAdvisoryParameters
      counterAdd c 10 emptyAttributes
      counterAdd c 20 emptyAttributes
      b1 <- collectResourceMetrics env deltaTemporality
      counterAdd c 5 emptyAttributes
      b2 <- collectResourceMetrics env deltaTemporality
      b3 <- collectResourceMetrics env deltaTemporality
      sumInt64SumPointsInBatches b1 `shouldBe` 30
      sumInt64SumPointsInBatches b2 `shouldBe` 5
      sumInt64SumPointsInBatches b3 `shouldBe` 0

    it "sync Double counter: delta resets between collections" $ do
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      c <- meterCreateCounterDouble m "dc.dbl" Nothing Nothing defaultAdvisoryParameters
      counterAdd c 1.5 emptyAttributes
      counterAdd c 2.5 emptyAttributes
      b1 <- collectResourceMetrics env deltaTemporality
      counterAdd c 0.5 emptyAttributes
      b2 <- collectResourceMetrics env deltaTemporality
      case firstMetric b1 of
        MetricExportSum {mesSumPoints = pts} ->
          sumDataPointValue (V.head pts) `shouldBe` DoubleNumber 4.0
        _ -> expectationFailure "expected MetricExportSum"
      case firstMetric b2 of
        MetricExportSum {mesSumPoints = pts} ->
          sumDataPointValue (V.head pts) `shouldBe` DoubleNumber 0.5
        _ -> expectationFailure "expected MetricExportSum"

    it "sync Int64 counter: cumulative accumulates across collections" $ do
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      c <- meterCreateCounterInt64 m "cc.i64" Nothing Nothing defaultAdvisoryParameters
      counterAdd c 10 emptyAttributes
      b1 <- collectResourceMetrics env cumulativeTemporality
      counterAdd c 7 emptyAttributes
      b2 <- collectResourceMetrics env cumulativeTemporality
      b3 <- collectResourceMetrics env cumulativeTemporality
      sumInt64SumPointsInBatches b1 `shouldBe` 10
      sumInt64SumPointsInBatches b2 `shouldBe` 17
      sumInt64SumPointsInBatches b3 `shouldBe` 17

    -- -----------------------------------------------------------------------
    -- UpDownCounter: negative deltas, delta & cumulative
    -- -----------------------------------------------------------------------
    it "sync UpDownCounter Int64: always cumulative even with deltaTemporality" $ do
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      udc <- meterCreateUpDownCounterInt64 m "udc.delta" Nothing Nothing defaultAdvisoryParameters
      upDownCounterAdd udc 50 emptyAttributes
      upDownCounterAdd udc (-20) emptyAttributes
      b1 <- collectResourceMetrics env deltaTemporality
      upDownCounterAdd udc (-15) emptyAttributes
      b2 <- collectResourceMetrics env deltaTemporality
      sumInt64SumPointsInBatches b1 `shouldBe` 30
      sumInt64SumPointsInBatches b2 `shouldBe` 15

    it "sync UpDownCounter: cumulative with negative result" $ do
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      udc <- meterCreateUpDownCounterInt64 m "udc.cum" Nothing Nothing defaultAdvisoryParameters
      upDownCounterAdd udc 10 emptyAttributes
      upDownCounterAdd udc (-30) emptyAttributes
      b1 <- collectResourceMetrics env cumulativeTemporality
      sumInt64SumPointsInBatches b1 `shouldBe` (-20)

    -- -----------------------------------------------------------------------
    -- Observable Counter: set semantics, delta = diff, cumulative = raw
    -- -----------------------------------------------------------------------
    it "observable Int64 counter: cumulative returns raw callback value" $ do
      callCount <- newIORef (0 :: Int64)
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      let cb res = do
            modifyIORef' callCount (+ 100)
            v <- readIORef callCount
            observe res v emptyAttributes
      _ <- meterCreateObservableCounterInt64 m "oc.cum" Nothing Nothing defaultAdvisoryParameters [cb]
      b1 <- collectResourceMetrics env cumulativeTemporality
      b2 <- collectResourceMetrics env cumulativeTemporality
      b3 <- collectResourceMetrics env cumulativeTemporality
      sumInt64SumPointsInBatches b1 `shouldBe` 100
      sumInt64SumPointsInBatches b2 `shouldBe` 200
      sumInt64SumPointsInBatches b3 `shouldBe` 300

    it "observable Int64 counter: delta = current - previous" $ do
      callCount <- newIORef (0 :: Int64)
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      let cb res = do
            modifyIORef' callCount (+ 100)
            v <- readIORef callCount
            observe res v emptyAttributes
      _ <- meterCreateObservableCounterInt64 m "oc.delta" Nothing Nothing defaultAdvisoryParameters [cb]
      b1 <- collectResourceMetrics env deltaTemporality
      b2 <- collectResourceMetrics env deltaTemporality
      b3 <- collectResourceMetrics env deltaTemporality
      sumInt64SumPointsInBatches b1 `shouldBe` 100
      sumInt64SumPointsInBatches b2 `shouldBe` 100
      sumInt64SumPointsInBatches b3 `shouldBe` 100

    it "observable Double counter: delta computes correct diff" $ do
      callCount <- newIORef (0.0 :: Double)
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      let cb res = do
            modifyIORef' callCount (+ 25.5)
            v <- readIORef callCount
            observe res v emptyAttributes
      _ <- meterCreateObservableCounterDouble m "oc.dbl.delta" Nothing Nothing defaultAdvisoryParameters [cb]
      b1 <- collectResourceMetrics env deltaTemporality
      b2 <- collectResourceMetrics env deltaTemporality
      case firstMetric b1 of
        MetricExportSum {mesSumPoints = pts} ->
          sumDataPointValue (V.head pts) `shouldBe` DoubleNumber 25.5
        _ -> expectationFailure "expected MetricExportSum"
      case firstMetric b2 of
        MetricExportSum {mesSumPoints = pts} ->
          sumDataPointValue (V.head pts) `shouldBe` DoubleNumber 25.5
        _ -> expectationFailure "expected MetricExportSum"

    it "observable counter rejects negative Int64 values" $ do
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      let cb res = do
            observe res (-5 :: Int64) emptyAttributes
            observe res (10 :: Int64) (addAttribute defaultAttributeLimits emptyAttributes "key" ("b" :: Text))
      _ <- meterCreateObservableCounterInt64 m "oc.neg" Nothing Nothing defaultAdvisoryParameters [cb]
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts} -> do
          V.length pts `shouldBe` 1
          sumDataPointValue (V.head pts) `shouldBe` IntNumber 10
        _ -> expectationFailure "expected MetricExportSum"

    it "observable counter rejects negative Double values" $ do
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      let cb res = do
            observe res (-1.0 :: Double) emptyAttributes
            observe res (5.0 :: Double) (addAttribute defaultAttributeLimits emptyAttributes "k" ("ok" :: Text))
      _ <- meterCreateObservableCounterDouble m "oc.neg.d" Nothing Nothing defaultAdvisoryParameters [cb]
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts} -> do
          V.length pts `shouldBe` 1
          sumDataPointValue (V.head pts) `shouldBe` DoubleNumber 5.0
        _ -> expectationFailure "expected MetricExportSum"

    -- -----------------------------------------------------------------------
    -- Observable UpDownCounter: allows negatives, delta & cumulative
    -- -----------------------------------------------------------------------
    it "observable UpDownCounter Int64: always cumulative even with deltaTemporality" $ do
      callIdx <- newIORef (0 :: Int)
      let values = [10, -5, 20, 3]
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      let cb res = do
            i <- readIORef callIdx
            modifyIORef' callIdx (+ 1)
            let v = values !! min i (length values - 1)
            observe res (v :: Int64) emptyAttributes
      _ <- meterCreateObservableUpDownCounterInt64 m "oudc.delta" Nothing Nothing defaultAdvisoryParameters [cb]
      b1 <- collectResourceMetrics env deltaTemporality
      b2 <- collectResourceMetrics env deltaTemporality
      b3 <- collectResourceMetrics env deltaTemporality
      sumInt64SumPointsInBatches b1 `shouldBe` 10
      sumInt64SumPointsInBatches b2 `shouldBe` (-5)
      sumInt64SumPointsInBatches b3 `shouldBe` 20

    -- -----------------------------------------------------------------------
    -- Observable Gauge: last-value semantics
    -- -----------------------------------------------------------------------
    it "observable gauge Double: returns latest value each collection" $ do
      callIdx <- newIORef (0 :: Int)
      let values = [42.0, 99.5, 0.1]
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      let cb res = do
            i <- readIORef callIdx
            modifyIORef' callIdx (+ 1)
            let v = values !! min i (length values - 1)
            observe res (v :: Double) emptyAttributes
      _ <- meterCreateObservableGaugeDouble m "og.double" Nothing Nothing defaultAdvisoryParameters [cb]
      b1 <- collectResourceMetrics env cumulativeTemporality
      b2 <- collectResourceMetrics env cumulativeTemporality
      b3 <- collectResourceMetrics env cumulativeTemporality
      let gaugeVal batches = case firstMetric batches of
            MetricExportGauge {megGaugePoints = pts} -> gaugeDataPointValue (V.head pts)
            _ -> error "expected MetricExportGauge"
      gaugeVal b1 `shouldBe` DoubleNumber 42.0
      gaugeVal b2 `shouldBe` DoubleNumber 99.5
      gaugeVal b3 `shouldBe` DoubleNumber 0.1

    it "observable gauge Int64: delta collection still returns latest value" $ do
      callIdx <- newIORef (0 :: Int)
      let values = [100 :: Int64, 200, 50]
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      let cb res = do
            i <- readIORef callIdx
            modifyIORef' callIdx (+ 1)
            observe res (values !! min i (length values - 1)) emptyAttributes
      _ <- meterCreateObservableGaugeInt64 m "og.int.delta" Nothing Nothing defaultAdvisoryParameters [cb]
      b1 <- collectResourceMetrics env deltaTemporality
      b2 <- collectResourceMetrics env deltaTemporality
      b3 <- collectResourceMetrics env deltaTemporality
      let gaugeVal batches = case firstMetric batches of
            MetricExportGauge {megGaugePoints = pts} -> gaugeDataPointValue (V.head pts)
            _ -> error "expected MetricExportGauge"
      gaugeVal b1 `shouldBe` IntNumber 100
      gaugeVal b2 `shouldBe` IntNumber 200
      gaugeVal b3 `shouldBe` IntNumber 50

    it "sync gauge: last write wins, cumulative and delta agree" $ do
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      g <- meterCreateGaugeDouble m "sg.lw" Nothing Nothing defaultAdvisoryParameters
      gaugeRecord g 10.0 emptyAttributes
      gaugeRecord g 20.0 emptyAttributes
      gaugeRecord g 15.0 emptyAttributes
      b1 <- collectResourceMetrics env cumulativeTemporality
      gaugeRecord g 99.0 emptyAttributes
      b2 <- collectResourceMetrics env deltaTemporality
      let gaugeVal batches = case firstMetric batches of
            MetricExportGauge {megGaugePoints = pts} -> gaugeDataPointValue (V.head pts)
            _ -> error "expected MetricExportGauge"
      gaugeVal b1 `shouldBe` DoubleNumber 15.0
      gaugeVal b2 `shouldBe` DoubleNumber 99.0

    -- -----------------------------------------------------------------------
    -- Histogram: exact bucket counts, sum, count, min, max
    -- -----------------------------------------------------------------------
    it "histogram: exact bucket distribution with default boundaries" $ do
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      h <- meterCreateHistogram m "h.buckets" Nothing Nothing defaultAdvisoryParameters
      -- Default boundaries: [0,5,10,25,50,75,100,250,500,750,1000,2500,5000,7500,10000]
      -- Record values at specific positions
      histogramRecord h 3.0 emptyAttributes -- bucket 1: (0, 5]
      histogramRecord h 3.0 emptyAttributes -- bucket 1: (0, 5]
      histogramRecord h 7.0 emptyAttributes -- bucket 2: (5, 10]
      histogramRecord h 50.0 emptyAttributes -- bucket 4: (25, 50] — bounds[4]=50, 50.0<=50
      histogramRecord h 15000.0 emptyAttributes -- bucket 15 (overflow): (10000, +inf)
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportHistogram {mehPoints = pts} -> do
          let p = V.head pts
          histogramDataPointCount p `shouldBe` 5
          histogramDataPointSum p `shouldBe` (3.0 + 3.0 + 7.0 + 50.0 + 15000.0)
          histogramDataPointMin p `shouldBe` Just 3.0
          histogramDataPointMax p `shouldBe` Just 15000.0
          let counts = histogramDataPointBucketCounts p
          -- 16 buckets for 15 boundaries
          V.length counts `shouldBe` 16
          -- bucket 0: v <= 0 => 0
          V.head counts `shouldBe` 0
          -- bucket 1: 0 < v <= 5 => 2 values (3.0, 3.0)
          counts V.! 1 `shouldBe` 2
          -- bucket 2: 5 < v <= 10 => 1 value (7.0)
          counts V.! 2 `shouldBe` 1
          -- bucket 4: 25 < v <= 50 => 1 value (50.0)
          counts V.! 4 `shouldBe` 1
          -- bucket 15: 10000 < v => 1 value (15000.0)
          counts V.! 15 `shouldBe` 1
          -- total bucket counts = count
          V.sum counts `shouldBe` histogramDataPointCount p
        _ -> expectationFailure "expected MetricExportHistogram"

    it "histogram: custom advisory boundaries produce correct buckets" $ do
      let adv = defaultAdvisoryParameters {advisoryExplicitBucketBoundaries = Just [10.0, 20.0, 30.0]}
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      h <- meterCreateHistogram m "h.custom" Nothing Nothing adv
      histogramRecord h 5.0 emptyAttributes -- bucket 0: (-inf, 10]
      histogramRecord h 10.0 emptyAttributes -- bucket 0: (-inf, 10] (boundary inclusive)
      histogramRecord h 15.0 emptyAttributes -- bucket 1: (10, 20]
      histogramRecord h 25.0 emptyAttributes -- bucket 2: (20, 30]
      histogramRecord h 35.0 emptyAttributes -- bucket 3: (30, +inf)
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportHistogram {mehPoints = pts} -> do
          let p = V.head pts
          histogramDataPointCount p `shouldBe` 5
          histogramDataPointSum p `shouldBe` 90.0
          let counts = histogramDataPointBucketCounts p
          V.length counts `shouldBe` 4
          counts V.! 0 `shouldBe` 2
          counts V.! 1 `shouldBe` 1
          counts V.! 2 `shouldBe` 1
          counts V.! 3 `shouldBe` 1
          V.sum counts `shouldBe` 5
        _ -> expectationFailure "expected MetricExportHistogram"

    it "histogram: delta resets count, sum, min, max, buckets" $ do
      let adv = defaultAdvisoryParameters {advisoryExplicitBucketBoundaries = Just [10.0]}
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      h <- meterCreateHistogram m "h.delta" Nothing Nothing adv
      histogramRecord h 5.0 emptyAttributes
      histogramRecord h 15.0 emptyAttributes
      b1 <- collectResourceMetrics env deltaTemporality
      histogramRecord h 7.0 emptyAttributes
      b2 <- collectResourceMetrics env deltaTemporality
      b3 <- collectResourceMetrics env deltaTemporality
      let getHist batches = case firstMetric batches of
            MetricExportHistogram {mehPoints = pts} -> V.head pts
            _ -> error "expected MetricExportHistogram"
      let p1 = getHist b1
      histogramDataPointCount p1 `shouldBe` 2
      histogramDataPointSum p1 `shouldBe` 20.0
      histogramDataPointMin p1 `shouldBe` Just 5.0
      histogramDataPointMax p1 `shouldBe` Just 15.0
      let c1 = histogramDataPointBucketCounts p1
      c1 V.! 0 `shouldBe` 1
      c1 V.! 1 `shouldBe` 1
      let p2 = getHist b2
      histogramDataPointCount p2 `shouldBe` 1
      histogramDataPointSum p2 `shouldBe` 7.0
      histogramDataPointMin p2 `shouldBe` Just 7.0
      histogramDataPointMax p2 `shouldBe` Just 7.0
      let c2 = histogramDataPointBucketCounts p2
      c2 V.! 0 `shouldBe` 1
      c2 V.! 1 `shouldBe` 0
      -- Third collect with no recordings
      histogramObservationCountInBatches b3 `shouldBe` 0

    it "histogram: cumulative accumulates across collections" $ do
      let adv = defaultAdvisoryParameters {advisoryExplicitBucketBoundaries = Just [100.0]}
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      h <- meterCreateHistogram m "h.cum" Nothing Nothing adv
      histogramRecord h 50.0 emptyAttributes
      _ <- collectResourceMetrics env cumulativeTemporality
      histogramRecord h 150.0 emptyAttributes
      b2 <- collectResourceMetrics env cumulativeTemporality
      case firstMetric b2 of
        MetricExportHistogram {mehPoints = pts} -> do
          let p = V.head pts
          histogramDataPointCount p `shouldBe` 2
          histogramDataPointSum p `shouldBe` 200.0
          let counts = histogramDataPointBucketCounts p
          counts V.! 0 `shouldBe` 1
          counts V.! 1 `shouldBe` 1
        _ -> expectationFailure "expected MetricExportHistogram"

    -- -----------------------------------------------------------------------
    -- Exponential Histogram: positive, negative, zero partitioning
    -- -----------------------------------------------------------------------
    it "exponential histogram: zero and positive values accepted, negatives dropped" $ do
      let adv = defaultAdvisoryParameters {advisoryHistogramAggregation = Just (HistogramAggregationExponential 5)}
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      h <- meterCreateHistogram m "eh.partition" Nothing Nothing adv
      histogramRecord h 0.0 emptyAttributes
      histogramRecord h 0.0 emptyAttributes
      histogramRecord h 1.0 emptyAttributes
      histogramRecord h 2.0 emptyAttributes
      histogramRecord h (-1.0) emptyAttributes
      histogramRecord h (-3.0) emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportExponentialHistogram {meehPoints = pts} -> do
          let p = V.head pts
          exponentialHistogramDataPointCount p `shouldBe` 4
          exponentialHistogramDataPointZeroCount p `shouldBe` 2
          exponentialHistogramDataPointSum p `shouldBe` Just 3.0
          exponentialHistogramDataPointMin p `shouldBe` Just 0.0
          exponentialHistogramDataPointMax p `shouldBe` Just 2.0
          V.sum (exponentialHistogramDataPointPositiveBucketCounts p) `shouldBe` 2
          V.sum (exponentialHistogramDataPointNegativeBucketCounts p) `shouldBe` 0
        _ -> expectationFailure "expected MetricExportExponentialHistogram"

    -- -----------------------------------------------------------------------
    -- Multi-attribute isolation
    -- -----------------------------------------------------------------------
    it "counter: distinct attribute sets produce independent data points" $ do
      let a1 = addAttribute defaultAttributeLimits emptyAttributes "route" ("/a" :: Text)
          a2 = addAttribute defaultAttributeLimits emptyAttributes "route" ("/b" :: Text)
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      c <- meterCreateCounterInt64 m "c.multi" Nothing Nothing defaultAdvisoryParameters
      counterAdd c 10 a1
      counterAdd c 20 a1
      counterAdd c 5 a2
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts} -> do
          V.length pts `shouldBe` 2
          let vals = V.toList $ V.map sumDataPointValue pts
          IntNumber 30 `elem` vals `shouldBe` True
          IntNumber 5 `elem` vals `shouldBe` True
        _ -> expectationFailure "expected MetricExportSum"

    it "histogram: distinct attribute sets produce independent data points" $ do
      let a1 = addAttribute defaultAttributeLimits emptyAttributes "op" ("read" :: Text)
          a2 = addAttribute defaultAttributeLimits emptyAttributes "op" ("write" :: Text)
          adv = defaultAdvisoryParameters {advisoryExplicitBucketBoundaries = Just [100.0]}
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      h <- meterCreateHistogram m "h.multi" Nothing Nothing adv
      histogramRecord h 50.0 a1
      histogramRecord h 150.0 a1
      histogramRecord h 200.0 a2
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportHistogram {mehPoints = pts} -> do
          V.length pts `shouldBe` 2
          let counts = Set.fromList $ V.toList $ V.map histogramDataPointCount pts
          Set.member 2 counts `shouldBe` True
          Set.member 1 counts `shouldBe` True
        _ -> expectationFailure "expected MetricExportHistogram"

    -- -----------------------------------------------------------------------
    -- Observable with multiple attribute sets
    -- -----------------------------------------------------------------------
    it "observable counter: multiple attribute sets in one callback" $ do
      let a1 = addAttribute defaultAttributeLimits emptyAttributes "host" ("h1" :: Text)
          a2 = addAttribute defaultAttributeLimits emptyAttributes "host" ("h2" :: Text)
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      let cb res = do
            observe res (100 :: Int64) a1
            observe res (200 :: Int64) a2
      _ <- meterCreateObservableCounterInt64 m "oc.multi" Nothing Nothing defaultAdvisoryParameters [cb]
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts} -> do
          V.length pts `shouldBe` 2
          let vals = V.toList $ V.map sumDataPointValue pts
          IntNumber 100 `elem` vals `shouldBe` True
          IntNumber 200 `elem` vals `shouldBe` True
        _ -> expectationFailure "expected MetricExportSum"

    it "observable counter: multi-attr delta computes per-key diffs" $ do
      callIdx <- newIORef (0 :: Int)
      let a1 = addAttribute defaultAttributeLimits emptyAttributes "k" ("x" :: Text)
          a2 = addAttribute defaultAttributeLimits emptyAttributes "k" ("y" :: Text)
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      let cb res = do
            i <- readIORef callIdx
            modifyIORef' callIdx (+ 1)
            observe res (fromIntegral (i + 1) * 10 :: Int64) a1
            observe res (fromIntegral (i + 1) * 100 :: Int64) a2
      _ <- meterCreateObservableCounterInt64 m "oc.multi.d" Nothing Nothing defaultAdvisoryParameters [cb]
      b1 <- collectResourceMetrics env deltaTemporality
      b2 <- collectResourceMetrics env deltaTemporality
      -- First collect: a1=10, a2=100 (prev=0 for both)
      sumInt64SumPointsInBatches b1 `shouldBe` 110
      -- Second collect: a1=20-10=10, a2=200-100=100
      sumInt64SumPointsInBatches b2 `shouldBe` 110

    -- -----------------------------------------------------------------------
    -- View attribute filtering: aggregation across filtered keys
    -- -----------------------------------------------------------------------
    it "view attribute filter strips non-selected keys from exported data points" $ do
      let v = mkView "vf.counter" Nothing ViewAggregationDefault (Just ["method"]) Nothing Nothing
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions {views = [v]}
      m <- getMeter provider defaultScope
      c <- meterCreateCounterInt64 m "vf.counter" Nothing Nothing defaultAdvisoryParameters
      let mkAttrs meth (path :: Text) =
            addAttribute
              defaultAttributeLimits
              (addAttribute defaultAttributeLimits emptyAttributes "method" (meth :: Text))
              "path"
              path
      counterAdd c 10 (mkAttrs "GET" "/a")
      counterAdd c 20 (mkAttrs "GET" "/b")
      counterAdd c 5 (mkAttrs "POST" "/a")
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts} -> do
          -- Each original attribute set is a separate cell; filter only strips "path" at export
          V.length pts `shouldBe` 3
          let vals = V.toList $ V.map sumDataPointValue pts
          -- All three original values are present as separate data points
          IntNumber 10 `elem` vals `shouldBe` True
          IntNumber 20 `elem` vals `shouldBe` True
          IntNumber 5 `elem` vals `shouldBe` True
          -- Exported attributes only contain "method" (path is stripped)
          let allAttrs = V.toList $ V.map sumDataPointAttributes pts
          all (\a -> isJust (lookupAttribute a "method")) allAttrs `shouldBe` True
        _ -> expectationFailure "expected MetricExportSum"

    -- -----------------------------------------------------------------------
    -- Cardinality overflow: exact semantics
    -- -----------------------------------------------------------------------
    it "cardinality overflow: excess attribute sets merge into overflow bucket" $ do
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions {cardinalityLimit = 3}
      m <- getMeter provider defaultScope
      c <- meterCreateCounterInt64 m "card.test" Nothing Nothing defaultAdvisoryParameters
      let mkA (i :: Int) = addAttribute defaultAttributeLimits emptyAttributes "k" (pack (show i))
      -- cardinalityLimit=3: first 3 distinct attr sets get their own cells,
      -- then the 4th and 5th spill into the overflow cell
      counterAdd c 10 (mkA 1)
      counterAdd c 20 (mkA 2)
      counterAdd c 30 (mkA 3)
      counterAdd c 40 (mkA 4)
      counterAdd c 50 (mkA 5)
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts} -> do
          let hasOverflow p = isJust (lookupAttribute (sumDataPointAttributes p) "otel.metric.overflow")
              overflowPts = V.filter hasOverflow pts
              normalPts = V.filter (not . hasOverflow) pts
          V.length overflowPts `shouldSatisfy` (>= 1)
          let total = V.sum $ V.map (\p -> case sumDataPointValue p of IntNumber i -> i; _ -> 0) pts
          total `shouldBe` 150
          -- 3 normal slots + 1 overflow = 4 total
          V.length normalPts `shouldBe` 3
          V.length pts `shouldBe` 4
        _ -> expectationFailure "expected MetricExportSum"

    -- -----------------------------------------------------------------------
    -- NaN and Infinity handling
    -- -----------------------------------------------------------------------
    it "histogram: NaN and Infinity are silently dropped" $ do
      let adv = defaultAdvisoryParameters {advisoryExplicitBucketBoundaries = Just [10.0]}
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      h <- meterCreateHistogram m "h.nan" Nothing Nothing adv
      histogramRecord h 5.0 emptyAttributes
      histogramRecord h (0 / 0) emptyAttributes -- NaN
      histogramRecord h (1 / 0) emptyAttributes -- +Infinity
      histogramRecord h (-(1 / 0)) emptyAttributes -- -Infinity
      histogramRecord h 15.0 emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportHistogram {mehPoints = pts} -> do
          let p = V.head pts
          histogramDataPointCount p `shouldBe` 2
          histogramDataPointSum p `shouldBe` 20.0
          histogramDataPointMin p `shouldBe` Just 5.0
          histogramDataPointMax p `shouldBe` Just 15.0
        _ -> expectationFailure "expected MetricExportHistogram"

    -- -----------------------------------------------------------------------
    -- Observable callback registration after instrument creation
    -- -----------------------------------------------------------------------
    it "observable counter: registerCallback lifecycle" $ do
      cb2Count <- newIORef (0 :: Int)
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      let cb1 res = observe res (10 :: Int64) emptyAttributes
      oc <- meterCreateObservableCounterInt64 m "oc.reg" Nothing Nothing defaultAdvisoryParameters [cb1]
      b1 <- collectResourceMetrics env cumulativeTemporality
      sumInt64SumPointsInBatches b1 `shouldBe` 10
      let cb2 res = do
            modifyIORef' cb2Count (+ 1)
            observe res (20 :: Int64) (addAttribute defaultAttributeLimits emptyAttributes "src" ("cb2" :: Text))
      handle <- observableCounterRegisterCallback oc cb2
      b2 <- collectResourceMetrics env cumulativeTemporality
      -- cb1(10) + cb2(20) = 30
      sumInt64SumPointsInBatches b2 `shouldBe` 30
      readIORef cb2Count >>= (`shouldBe` 1)
      -- Unregister cb2 and verify it no longer runs
      unregisterObservableCallback handle
      _ <- collectResourceMetrics env cumulativeTemporality
      readIORef cb2Count >>= (`shouldBe` 1)

    -- -----------------------------------------------------------------------
    -- Sync monotonic counter: negative add is no-op
    -- -----------------------------------------------------------------------
    it "sync Int64 counter: negative add is silently dropped" $ do
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      c <- meterCreateCounterInt64 m "c.noneg" Nothing Nothing defaultAdvisoryParameters
      counterAdd c 10 emptyAttributes
      counterAdd c (-5) emptyAttributes
      counterAdd c 3 emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      sumInt64SumPointsInBatches batches `shouldBe` 13

    it "sync Double counter: negative add is silently dropped" $ do
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      c <- meterCreateCounterDouble m "cd.noneg" Nothing Nothing defaultAdvisoryParameters
      counterAdd c 10.0 emptyAttributes
      counterAdd c (-5.0) emptyAttributes
      counterAdd c 3.0 emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportSum {mesSumPoints = pts} ->
          sumDataPointValue (V.head pts) `shouldBe` DoubleNumber 13.0
        _ -> expectationFailure "expected MetricExportSum"

    -- -----------------------------------------------------------------------
    -- Stress: many recordings then exact verify
    -- -----------------------------------------------------------------------
    it "counter: 10000 increments produce exact sum" $ do
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      c <- meterCreateCounterInt64 m "c.stress" Nothing Nothing defaultAdvisoryParameters
      forM_ [1 .. 10000 :: Int64] $ \i -> counterAdd c i emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      sumInt64SumPointsInBatches batches `shouldBe` (10000 * 10001 `div` 2)

    it "histogram: 1000 recordings produce correct count and sum" $ do
      let adv = defaultAdvisoryParameters {advisoryExplicitBucketBoundaries = Just [500.0]}
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      h <- meterCreateHistogram m "h.stress" Nothing Nothing adv
      forM_ [1.0 .. 1000.0 :: Double] $ \v -> histogramRecord h v emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      case firstMetric batches of
        MetricExportHistogram {mehPoints = pts} -> do
          let p = V.head pts
          histogramDataPointCount p `shouldBe` 1000
          histogramDataPointSum p `shouldBe` sum [1.0 .. 1000.0 :: Double]
          histogramDataPointMin p `shouldBe` Just 1.0
          histogramDataPointMax p `shouldBe` Just 1000.0
          let counts = histogramDataPointBucketCounts p
          -- bucket 0: [1..500], bucket 1: [501..1000]
          counts V.! 0 `shouldBe` 500
          counts V.! 1 `shouldBe` 500
        _ -> expectationFailure "expected MetricExportHistogram"

  describe "Duplicate instrument name detection" $ do
    -- Metrics SDK §Duplicate instrument registration (conflict handling)
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#duplicate-instrument-registration
    it "registers instruments with same name but different units without crashing" $ do
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      c1 <- meterCreateCounterInt64 m "dup.counter" (Just "bytes") Nothing defaultAdvisoryParameters
      c2 <- meterCreateCounterInt64 m "dup.counter" (Just "requests") Nothing defaultAdvisoryParameters
      counterAdd c1 10 emptyAttributes
      counterAdd c2 20 emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      V.length batches `shouldSatisfy` (> 0)

    -- Metrics SDK §Duplicate instrument registration: description mismatch
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#duplicate-instrument-registration
    it "registers instruments with same name but different descriptions without crashing" $ do
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      c1 <- meterCreateCounterInt64 m "dup.desc" Nothing (Just "Total bytes sent") defaultAdvisoryParameters
      c2 <- meterCreateCounterInt64 m "dup.desc" Nothing (Just "Number of requests") defaultAdvisoryParameters
      counterAdd c1 5 emptyAttributes
      counterAdd c2 15 emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      V.length batches `shouldSatisfy` (> 0)

    -- Metrics SDK §Instrument identity: same name+metadata → same instrument
    -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/#instrument
    it "same name same metadata returns shared storage" $ do
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      c1 <- meterCreateCounterInt64 m "shared.counter" (Just "1") Nothing defaultAdvisoryParameters
      c2 <- meterCreateCounterInt64 m "shared.counter" (Just "1") Nothing defaultAdvisoryParameters
      counterAdd c1 10 emptyAttributes
      counterAdd c2 20 emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      sumInt64SumPointsInBatches batches `shouldBe` 30

  -- Metrics SDK: NaN and Inf measurements MUST be silently dropped.
  -- https://opentelemetry.io/docs/specs/otel/metrics/sdk/
  describe "NaN/Inf filtering" $ do
    it "silently drops NaN values from double counters" $ do
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      c <- meterCreateCounterDouble m "nan.counter" Nothing Nothing defaultAdvisoryParameters
      counterAdd c (0 / 0) emptyAttributes
      counterAdd c 5.0 emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      sumDblSumPointsInBatches batches `shouldBe` 5.0

    it "silently drops Infinity values from double counters" $ do
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      c <- meterCreateCounterDouble m "inf.counter" Nothing Nothing defaultAdvisoryParameters
      counterAdd c (1 / 0) emptyAttributes
      counterAdd c 3.0 emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      sumDblSumPointsInBatches batches `shouldBe` 3.0

    it "silently drops NaN values from double gauges" $ do
      (provider, env) <- mkProvider defaultSdkMeterProviderOptions
      m <- getMeter provider defaultScope
      g <- meterCreateGaugeDouble m "nan.gauge" Nothing Nothing defaultAdvisoryParameters
      gaugeRecord g 42.0 emptyAttributes
      gaugeRecord g (0 / 0) emptyAttributes
      batches <- collectResourceMetrics env cumulativeTemporality
      let points = concatMap extractGaugePoints (V.toList batches)
      any (\gdp -> gaugeDataPointValue gdp == DoubleNumber 42.0) points `shouldBe` True
