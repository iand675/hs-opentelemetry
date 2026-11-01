{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.MeterProviderSpec (spec) where

import Control.Concurrent (newEmptyMVar, putMVar, readMVar, tryPutMVar, yield)
import Control.Concurrent.Async (concurrently, forConcurrently_, withAsync)
import Control.Monad (forM, forM_, forever, replicateM, replicateM_)
import Data.IORef (newIORef, writeIORef)
import Data.Int (Int64)
import Data.Text (Text)
import qualified Data.Vector as V
import Data.Word (Word64)
import OpenTelemetry.Attributes (addAttribute, defaultAttributeLimits, emptyAttributes, lookupAttribute)
import OpenTelemetry.Attributes.Attribute (Attribute (..), PrimitiveAttribute (..))
import OpenTelemetry.Exporter.Metric (
  AggregationTemporality (..),
  ExponentialHistogramDataPoint (..),
  GaugeDataPoint (..),
  HistogramDataPoint (..),
  MetricExport (..),
  NumberValue (..),
  ResourceMetricsExport (..),
  ScopeMetricsExport (..),
  SumDataPoint (..),
 )
import OpenTelemetry.Internal.Common.Types (FlushResult (..), InstrumentationLibrary (..), ShutdownResult (..))
import OpenTelemetry.MeterProvider
import OpenTelemetry.Metric.Core (
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
  forceFlushMeterProvider,
  getMeter,
  shutdownMeterProvider,
 )
import OpenTelemetry.Metric.View (View (..), ViewAggregation (..), ViewSelector (..))
import OpenTelemetry.Resource (emptyMaterializedResources)
import System.Timeout (timeout)
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
    describe "concurrent recording" $ do
      it "initializes legacy empty storage once when first measurements race" $ do
        (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
        -- Preserve the public newIORef emptyStorageState initialization pattern.
        legacyStorage <- newIORef emptyStorageState
        collectResourceMetrics env {sdkMeterStorage = legacyStorage} >>= (`shouldSatisfy` (null . allMetrics))
        writeIORef (sdkMeterStorage env) emptyStorageState
        meter <- getMeter provider scope
        counter <- meterCreateCounterInt64 meter "first.use" Nothing Nothing defaultAdvisoryParameters
        forConcurrently_ [1 .. 16 :: Int] $ \_ ->
          replicateM_ 1000 (counterAdd counter 1 emptyAttributes)
        batches <- collectResourceMetrics env
        intSums batches `shouldBe` [16000]
        collectResourceMetrics env {sdkMeterStorage = legacyStorage} >>= (`shouldSatisfy` (null . allMetrics))

      it "enforces cardinality while new series race" $ do
        (provider, env) <-
          createMeterProvider
            emptyMaterializedResources
            defaultSdkMeterProviderOptions {cardinalityLimit = 2}
        meter <- getMeter provider scope
        counter <- meterCreateCounterInt64 meter "bounded" Nothing Nothing defaultAdvisoryParameters
        forConcurrently_ [1 .. 16 :: Int] $ \n ->
          replicateM_ 100 (counterAdd counter 1 (addAttribute defaultAttributeLimits emptyAttributes "worker" n))
        batches <- collectResourceMetrics env
        sum (intSums batches) `shouldBe` 1600
        length (intSums batches) `shouldSatisfy` (<= 3)
        case firstMetric batches of
          MetricExportSum {mesSumPoints = points} ->
            V.any (\point -> lookupAttribute (sumDataPointAttributes point) "otel.metric.overflow" == Just (AttributeValue (BoolAttribute True))) points
              `shouldBe` True
          _ -> expectationFailure "expected MetricExportSum"

      it "does not lose records during concurrent delta collection" $ do
        (provider, env) <-
          createMeterProvider
            emptyMaterializedResources
            defaultSdkMeterProviderOptions {aggregationTemporality = AggregationDelta}
        meter <- getMeter provider scope
        counter <- meterCreateCounterInt64 meter "delta.counter" Nothing Nothing defaultAdvisoryParameters
        histogram <- meterCreateHistogram meter "delta.histogram" Nothing Nothing defaultAdvisoryParameters
        started <- newEmptyMVar
        let record = counterAdd counter 1 emptyAttributes >> histogramRecord histogram 2 emptyAttributes
            workers = forConcurrently_ [1 .. 4 :: Int] $ \_ -> do
              record
              _ <- tryPutMVar started ()
              replicateM_ 1999 record
        (_, snapshots) <- concurrently workers (readMVar started >> replicateM 100 (yield >> collectResourceMetrics env))
        final <- collectResourceMetrics env
        let batches = concat snapshots <> final
            histogramPoints = [point | MetricExportHistogram {mehPoints = points} <- allMetrics batches, point <- V.toList points]
        sum (intSums batches) `shouldBe` 8000
        sum (map histogramDataPointCount histogramPoints) `shouldBe` 8000
        sum (map histogramDataPointSum histogramPoints) `shouldBe` 16000
        sum (map (V.sum . histogramDataPointBucketCounts) histogramPoints) `shouldBe` 8000

      it "conserves new and overflow series across two concurrent delta collectors" $ do
        (provider, env) <-
          createMeterProvider
            emptyMaterializedResources
            defaultSdkMeterProviderOptions {aggregationTemporality = AggregationDelta, cardinalityLimit = 64}
        meter <- getMeter provider scope
        counter <- meterCreateCounterInt64 meter "many.counter" Nothing Nothing defaultAdvisoryParameters
        doubleCounter <- meterCreateCounterDouble meter "many.double" Nothing Nothing defaultAdvisoryParameters
        histogram <- meterCreateHistogram meter "many.histogram" Nothing Nothing defaultAdvisoryParameters
        exponential <-
          meterCreateHistogram meter "many.exponential" Nothing Nothing $
            defaultAdvisoryParameters {advisoryHistogramAggregation = Just (HistogramAggregationExponential 2)}
        gauge <- meterCreateGaugeInt64 meter "many.gauge" Nothing Nothing defaultAdvisoryParameters
        started <- newEmptyMVar
        let attrs n = addAttribute defaultAttributeLimits emptyAttributes "series" n
            record attributes = do
              counterAdd counter 1 attributes
              counterAdd doubleCounter 0.5 attributes
              histogramRecord histogram 2 attributes
              histogramRecord exponential 2 attributes
              gaugeRecord gauge 3 attributes
            workers = forConcurrently_ [0 .. 3 :: Int] $ \worker -> do
              record (attrs (worker * 256))
              _ <- tryPutMVar started ()
              forM_ [0 .. 255 :: Int] $ \series ->
                replicateM_ 4 (record (attrs (worker * 256 + series)))
            collector = readMVar started >> replicateM 50 (yield >> collectResourceMetrics env)
        result <- timeout 30000000 (concurrently workers (concurrently collector collector))
        case result of
          Nothing -> expectationFailure "recording and delta collection did not finish"
          Just (_, (left, right)) -> do
            final <- collectResourceMetrics env
            let batches = concat (left <> right) <> final
                histogramPoints = [point | MetricExportHistogram {mehPoints = points} <- allMetrics batches, point <- V.toList points]
                exponentialPoints = [point | MetricExportExponentialHistogram {meehPoints = points} <- allMetrics batches, point <- V.toList points]
                gaugePoints = [point | MetricExportGauge {megGaugePoints = points} <- allMetrics batches, point <- V.toList points]
                doubles = [n | MetricExportSum {mesSumPoints = points} <- allMetrics batches, SumDataPoint {sumDataPointValue = DoubleNumber n} <- V.toList points]
                sumExports = [points | MetricExportSum {mesSumPoints = points} <- allMetrics batches]
            sum (intSums batches) `shouldBe` 4100
            sum doubles `shouldBe` 2050
            sum (map histogramDataPointCount histogramPoints) `shouldBe` 4100
            sum (map histogramDataPointSum histogramPoints) `shouldBe` 8200
            sum (map (V.sum . histogramDataPointBucketCounts) histogramPoints) `shouldBe` 4100
            sum (map exponentialHistogramDataPointCount exponentialPoints) `shouldBe` 4100
            sum [value | Just value <- map exponentialHistogramDataPointSum exponentialPoints] `shouldBe` 8200
            sum (map (V.sum . exponentialHistogramDataPointPositiveBucketCounts) exponentialPoints) `shouldBe` 4100
            gaugePoints `shouldSatisfy` (not . null)
            map gaugeDataPointValue gaugePoints `shouldSatisfy` all (== IntNumber 3)
            map V.length sumExports `shouldSatisfy` all (<= 65)

      it "keeps collected cumulative snapshots independent of later cell updates" $ do
        (provider, env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
        meter <- getMeter provider scope
        counter <- meterCreateCounterInt64 meter "snapshot" Nothing Nothing defaultAdvisoryParameters
        counterAdd counter 10 emptyAttributes
        first <- collectResourceMetrics env
        counterAdd counter 20 emptyAttributes
        second <- collectResourceMetrics env
        -- Force the first export only after the mutable cell has changed.
        intSums first `shouldBe` [10]
        intSums second `shouldBe` [30]

      it "finishes a large delta collection while writers continue recording" $ do
        (provider, env) <-
          createMeterProvider
            emptyMaterializedResources
            defaultSdkMeterProviderOptions {aggregationTemporality = AggregationDelta, cardinalityLimit = 0}
        meter <- getMeter provider scope
        counter <- meterCreateCounterInt64 meter "busy.counter" Nothing Nothing defaultAdvisoryParameters
        writers <- forM [0 .. 3 :: Int] $ \worker -> do
          started <- newEmptyMVar
          let attributes = [addAttribute defaultAttributeLimits emptyAttributes "series" (worker * 1024 + series) | series <- [0 .. 1023 :: Int]]
          forM_ attributes (counterAdd counter 0)
          pure (started, attributes)
        withAsync
          ( forConcurrently_ writers $ \(started, attributes) -> do
              forM_ attributes (counterAdd counter 1)
              putMVar started ()
              forever (forM_ attributes (counterAdd counter 1))
          )
          $ \_ -> do
            mapM_ (readMVar . fst) writers
            result <- timeout 5000000 (collectResourceMetrics env)
            fmap (sum . intSums) result `shouldSatisfy` maybe False (> 0)

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
          sumDataPointValue (V.head pts) `shouldBe` IntNumber 10
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
          sumDataPointValue (V.head pts) `shouldBe` DoubleNumber 4.0
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
          sumDataPointValue (V.head pts) `shouldBe` IntNumber 7
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
            _ -> expectationFailure "expected Double"
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
          gaugeDataPointValue (V.head pts) `shouldBe` IntNumber 200
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
          gaugeDataPointValue (V.head pts) `shouldBe` DoubleNumber 0.42
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
          sumDataPointValue (V.head pts) `shouldBe` IntNumber 42
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
          gaugeDataPointValue (V.head pts) `shouldBe` DoubleNumber 3.14
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
          sumDataPointValue (V.head pts) `shouldBe` IntNumber (-10)
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
          sumDataPointValue (V.head overflow) `shouldBe` IntNumber 100
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
          sumDataPointValue (V.head pts) `shouldBe` IntNumber 5
        _ -> expectationFailure "expected MetricExportSum"
      counterAdd c 3 emptyAttributes
      b2 <- collectResourceMetrics env
      case firstMetric b2 of
        MetricExportSum {mesSumPoints = pts} ->
          sumDataPointValue (V.head pts) `shouldBe` IntNumber 3
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
      result <- shutdownMeterProvider provider Nothing
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


allMetrics :: [ResourceMetricsExport] -> [MetricExport]
allMetrics batches =
  [ metric
  | resource <- batches
  , scopeMetrics <- V.toList (resourceMetricsScopes resource)
  , metric <- V.toList (scopeMetricsExports scopeMetrics)
  ]


intSums :: [ResourceMetricsExport] -> [Int64]
intSums batches =
  [ n
  | MetricExportSum {mesSumPoints = points} <- allMetrics batches
  , SumDataPoint {sumDataPointValue = IntNumber n} <- V.toList points
  ]
