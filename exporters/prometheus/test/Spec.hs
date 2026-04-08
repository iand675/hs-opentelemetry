{-# LANGUAGE OverloadedStrings #-}

import qualified Data.ByteString.Lazy as LBS
import Data.Int (Int32, Int64)
import qualified Data.Text as T
import qualified Data.Vector as V
import Data.Word (Word64)
import Network.HTTP.Types (status200)
import Network.Wai (defaultRequest, pathInfo, responseLBS)
import Network.Wai.Test (request, runSession, simpleBody, simpleHeaders, simpleStatus)
import OpenTelemetry.Attributes (addAttribute, defaultAttributeLimits, emptyAttributes)
import OpenTelemetry.Attributes.Key (unkey)
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
import OpenTelemetry.Exporter.Prometheus (renderPrometheusText)
import OpenTelemetry.Exporter.Prometheus.WAI
import OpenTelemetry.Internal.Common.Types (InstrumentationLibrary (..))
import OpenTelemetry.Resource (emptyMaterializedResources, materializeResourcesWithSchema, mkResource, (.=))
import qualified OpenTelemetry.SemanticConventions as SC
import Test.Hspec


main :: IO ()
main = hspec $ do
  -- OpenTelemetry Prometheus and OpenMetrics compatibility
  -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
  let lib = "test-lib" :: InstrumentationLibrary
      mkGaugePt :: NumberValue -> GaugeDataPoint
      mkGaugePt v =
        GaugeDataPoint
          { gaugeDataPointStartTimeUnixNano = 0
          , gaugeDataPointTimeUnixNano = 1
          , gaugeDataPointValue = v
          , gaugeDataPointAttributes = emptyAttributes
          , gaugeDataPointExemplars = V.empty
          }
      mkSumPt :: NumberValue -> SumDataPoint
      mkSumPt v =
        SumDataPoint
          { sumDataPointStartTimeUnixNano = 0
          , sumDataPointTimeUnixNano = 10
          , sumDataPointValue = v
          , sumDataPointAttributes = emptyAttributes
          , sumDataPointExemplars = V.empty
          }
      wrap :: InstrumentationLibrary -> MetricExport -> ResourceMetricsExport
      wrap l ex =
        ResourceMetricsExport emptyMaterializedResources $
          V.singleton $
            ScopeMetricsExport l (V.singleton ex)
      rpt :: [ResourceMetricsExport] -> T.Text
      rpt = renderPrometheusText . V.fromList

  describe "renderPrometheusText" $ do
    -- Prometheus text exposition (TYPE, HELP, samples)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    -- Basic rendering
    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "renders empty input as empty text" $
      rpt [] `shouldBe` ""

    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "includes HELP and TYPE for a gauge" $ do
      let out = rpt [wrap lib $ MetricExportGauge "cpu" "cpu usage" "1" lib True $ V.singleton (mkGaugePt (DoubleNumber 0.5))]
      out `shouldSatisfy` T.isInfixOf "# HELP cpu cpu usage\n"
      out `shouldSatisfy` T.isInfixOf "# TYPE cpu gauge\n"
      out `shouldSatisfy` T.isInfixOf "cpu{job=\"test-lib\"} 0.5\n"

    -- Counter rendering
    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "renders monotonic sum as counter with correct value" $ do
      let out = rpt [wrap lib $ MetricExportSum "http_requests" "total" "1" lib True False AggregationCumulative $ V.singleton (mkSumPt (DoubleNumber 42.0))]
      out `shouldSatisfy` T.isInfixOf "# TYPE http_requests counter\n"
      out `shouldSatisfy` T.isInfixOf "http_requests{job=\"test-lib\"} 42.0\n"

    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "renders non-monotonic sum as gauge" $ do
      let out = rpt [wrap lib $ MetricExportSum "queue" "depth" "1" lib False False AggregationDelta $ V.singleton (mkSumPt (IntNumber (-3)))]
      out `shouldSatisfy` T.isInfixOf "# TYPE queue gauge\n"
      out `shouldSatisfy` T.isInfixOf "queue{job=\"test-lib\"} -3\n"

    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "renders Int64 counter as integer string" $ do
      let out = rpt [wrap lib $ MetricExportSum "ops" "" "1" lib True True AggregationCumulative $ V.singleton (mkSumPt (IntNumber 99))]
      out `shouldSatisfy` T.isInfixOf "ops{job=\"test-lib\"} 99\n"

    -- Name sanitization
    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "sanitizes dots to underscores in metric names" $ do
      let out = rpt [wrap lib $ MetricExportGauge "http.server.duration" "" "ms" lib True $ V.singleton (mkGaugePt (DoubleNumber 1.0))]
      out `shouldSatisfy` T.isInfixOf "# TYPE http_server_duration gauge\n"
      out `shouldSatisfy` T.isInfixOf "http_server_duration{job=\"test-lib\"} 1.0\n"

    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "sanitizes hyphens and slashes in metric names" $ do
      let out = rpt [wrap lib $ MetricExportGauge "my-metric/rate" "" "1" lib True $ V.singleton (mkGaugePt (DoubleNumber 0.0))]
      out `shouldSatisfy` T.isInfixOf "# TYPE my_metric_rate gauge\n"

    -- Label name sanitization
    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "sanitizes leading digit in label name to underscore prefix" $ do
      let attrs = addAttribute defaultAttributeLimits emptyAttributes "0bad" ("val" :: T.Text)
          pt = (mkGaugePt (DoubleNumber 1.0)) {gaugeDataPointAttributes = attrs}
          out = rpt [wrap lib $ MetricExportGauge "m" "" "1" lib True $ V.singleton pt]
      out `shouldSatisfy` T.isInfixOf "_bad=\"val\""

    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "sanitizes Unicode in label names to underscores" $ do
      let attrs = addAttribute defaultAttributeLimits emptyAttributes "café" ("latte" :: T.Text)
          pt = (mkGaugePt (DoubleNumber 1.0)) {gaugeDataPointAttributes = attrs}
          out = rpt [wrap lib $ MetricExportGauge "m" "" "1" lib True $ V.singleton pt]
      out `shouldSatisfy` T.isInfixOf "caf_=\"latte\""

    -- Label value escaping
    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "escapes backslashes in label values" $ do
      let attrs = addAttribute defaultAttributeLimits emptyAttributes "path" ("C:\\Users\\foo" :: T.Text)
          pt = (mkGaugePt (DoubleNumber 1.0)) {gaugeDataPointAttributes = attrs}
          out = rpt [wrap lib $ MetricExportGauge "m" "" "1" lib True $ V.singleton pt]
      out `shouldSatisfy` T.isInfixOf "path=\"C:\\\\Users\\\\foo\""

    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "escapes double quotes in label values" $ do
      let attrs = addAttribute defaultAttributeLimits emptyAttributes "msg" ("say \"hi\"" :: T.Text)
          pt = (mkGaugePt (DoubleNumber 1.0)) {gaugeDataPointAttributes = attrs}
          out = rpt [wrap lib $ MetricExportGauge "m" "" "1" lib True $ V.singleton pt]
      out `shouldSatisfy` T.isInfixOf "msg=\"say \\\"hi\\\"\""

    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "escapes newlines in label values" $ do
      let attrs = addAttribute defaultAttributeLimits emptyAttributes "msg" ("line1\nline2" :: T.Text)
          pt = (mkGaugePt (DoubleNumber 1.0)) {gaugeDataPointAttributes = attrs}
          out = rpt [wrap lib $ MetricExportGauge "m" "" "1" lib True $ V.singleton pt]
      out `shouldSatisfy` T.isInfixOf "msg=\"line1\\nline2\""

    -- Label ordering
    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "orders label keys lexicographically including job" $ do
      let attrs =
            addAttribute
              defaultAttributeLimits
              (addAttribute defaultAttributeLimits emptyAttributes "zebra" ("z" :: T.Text))
              "apple"
              ("a" :: T.Text)
          pt = (mkGaugePt (DoubleNumber 0.0)) {gaugeDataPointAttributes = attrs}
          out = rpt [wrap lib $ MetricExportGauge "m" "" "1" lib True $ V.singleton pt]
      out `shouldSatisfy` T.isInfixOf "{apple=\"a\",job=\"test-lib\",zebra=\"z\"}"

    -- HELP text escaping
    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "escapes backslash in HELP text" $ do
      let out = rpt [wrap lib $ MetricExportGauge "m" "path is C:\\foo" "1" lib True $ V.singleton (mkGaugePt (DoubleNumber 1.0))]
      out `shouldSatisfy` T.isInfixOf "# HELP m path is C:\\\\foo\n"

    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "escapes newline in HELP text" $ do
      let out = rpt [wrap lib $ MetricExportGauge "m" "line1\nline2" "1" lib True $ V.singleton (mkGaugePt (DoubleNumber 1.0))]
      out `shouldSatisfy` T.isInfixOf "# HELP m line1\\nline2\n"

    -- Special float values
    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "renders +Inf gauge value as +Inf" $ do
      let out = rpt [wrap lib $ MetricExportGauge "m" "" "1" lib True $ V.singleton (mkGaugePt (DoubleNumber (1 / 0)))]
      out `shouldSatisfy` T.isInfixOf "m{job=\"test-lib\"} +Inf\n"

    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "renders -Inf gauge value as -Inf" $ do
      let out = rpt [wrap lib $ MetricExportGauge "m" "" "1" lib True $ V.singleton (mkGaugePt (DoubleNumber (-1 / 0)))]
      out `shouldSatisfy` T.isInfixOf "m{job=\"test-lib\"} -Inf\n"

    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "renders NaN gauge value as NaN" $ do
      let out = rpt [wrap lib $ MetricExportGauge "m" "" "1" lib True $ V.singleton (mkGaugePt (DoubleNumber (0 / 0)))]
      out `shouldSatisfy` T.isInfixOf "m{job=\"test-lib\"} NaN\n"

    -- Histogram: cumulative buckets
    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "renders histogram with correct cumulative bucket counts" $ do
      let pt =
            HistogramDataPoint
              { histogramDataPointStartTimeUnixNano = 0
              , histogramDataPointTimeUnixNano = 99
              , histogramDataPointCount = 10
              , histogramDataPointSum = 55.0
              , histogramDataPointBucketCounts = V.fromList [2, 3, 5]
              , histogramDataPointExplicitBounds = V.fromList [10.0, 50.0]
              , histogramDataPointAttributes = emptyAttributes
              , histogramDataPointMin = Nothing
              , histogramDataPointMax = Nothing
              , histogramDataPointExemplars = V.empty
              }
          out = rpt [wrap lib $ MetricExportHistogram "lat" "latency" "ms" lib AggregationCumulative $ V.singleton pt]
      out `shouldSatisfy` T.isInfixOf "# TYPE lat histogram\n"
      out `shouldSatisfy` T.isInfixOf "lat_bucket{job=\"test-lib\",le=\"10.0\"} 2\n"
      out `shouldSatisfy` T.isInfixOf "lat_bucket{job=\"test-lib\",le=\"50.0\"} 5\n"
      out `shouldSatisfy` T.isInfixOf "lat_bucket{job=\"test-lib\",le=\"+Inf\"} 10\n"
      out `shouldSatisfy` T.isInfixOf "lat_sum{job=\"test-lib\"} 55.0\n"
      out `shouldSatisfy` T.isInfixOf "lat_count{job=\"test-lib\"} 10\n"

    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "histogram renders all line families in correct order" $ do
      let pt =
            HistogramDataPoint
              { histogramDataPointStartTimeUnixNano = 0
              , histogramDataPointTimeUnixNano = 1
              , histogramDataPointCount = 3
              , histogramDataPointSum = 6.0
              , histogramDataPointBucketCounts = V.fromList [1, 2]
              , histogramDataPointExplicitBounds = V.fromList [5.0]
              , histogramDataPointAttributes = emptyAttributes
              , histogramDataPointMin = Nothing
              , histogramDataPointMax = Nothing
              , histogramDataPointExemplars = V.empty
              }
          out = rpt [wrap lib $ MetricExportHistogram "h" "" "1" lib AggregationCumulative $ V.singleton pt]
          ls = T.lines out
          findIdx needle = case filter (\(_, l) -> needle `T.isInfixOf` l) (zip [0 :: Int ..] ls) of
            ((i, _) : _) -> Just i
            [] -> Nothing
      findIdx "# TYPE h histogram" `shouldBe` Just 1
      case (findIdx "h_bucket{", findIdx "h_sum{", findIdx "h_count{") of
        (Just bIdx, Just sIdx, Just cIdx) -> do
          bIdx `shouldSatisfy` (< sIdx)
          sIdx `shouldSatisfy` (< cIdx)
        _ -> expectationFailure "missing histogram lines"

    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "histogram with attributes on data point" $ do
      let attrs = addAttribute defaultAttributeLimits emptyAttributes "method" ("GET" :: T.Text)
          pt =
            HistogramDataPoint
              { histogramDataPointStartTimeUnixNano = 0
              , histogramDataPointTimeUnixNano = 1
              , histogramDataPointCount = 1
              , histogramDataPointSum = 5.0
              , histogramDataPointBucketCounts = V.fromList [0, 1]
              , histogramDataPointExplicitBounds = V.fromList [1.0]
              , histogramDataPointAttributes = attrs
              , histogramDataPointMin = Nothing
              , histogramDataPointMax = Nothing
              , histogramDataPointExemplars = V.empty
              }
          out = rpt [wrap lib $ MetricExportHistogram "h" "" "1" lib AggregationCumulative $ V.singleton pt]
      out `shouldSatisfy` T.isInfixOf "h_bucket{job=\"test-lib\",le=\"1.0\",method=\"GET\"} 0\n"
      out `shouldSatisfy` T.isInfixOf "h_bucket{job=\"test-lib\",le=\"+Inf\",method=\"GET\"} 1\n"
      out `shouldSatisfy` T.isInfixOf "h_sum{job=\"test-lib\",method=\"GET\"} 5.0\n"
      out `shouldSatisfy` T.isInfixOf "h_count{job=\"test-lib\",method=\"GET\"} 1\n"

    -- Exponential histogram
    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "renders exponential histogram with positive buckets" $ do
      let pt =
            ExponentialHistogramDataPoint
              { exponentialHistogramDataPointStartTimeUnixNano = 0
              , exponentialHistogramDataPointTimeUnixNano = 1
              , exponentialHistogramDataPointCount = 5
              , exponentialHistogramDataPointSum = Just 42.0
              , exponentialHistogramDataPointScale = 0
              , exponentialHistogramDataPointZeroCount = 1
              , exponentialHistogramDataPointPositiveOffset = 0
              , exponentialHistogramDataPointPositiveBucketCounts = V.fromList [2, 2]
              , exponentialHistogramDataPointNegativeOffset = 0
              , exponentialHistogramDataPointNegativeBucketCounts = V.empty
              , exponentialHistogramDataPointAttributes = emptyAttributes
              , exponentialHistogramDataPointMin = Nothing
              , exponentialHistogramDataPointMax = Nothing
              , exponentialHistogramDataPointExemplars = V.empty
              , exponentialHistogramDataPointZeroThreshold = 0
              }
          out = rpt [wrap lib $ MetricExportExponentialHistogram "eh" "" "1" lib AggregationCumulative $ V.singleton pt]
      out `shouldSatisfy` T.isInfixOf "# TYPE eh histogram\n"
      out `shouldSatisfy` T.isInfixOf "eh_bucket{job=\"test-lib\",le=\"0\"} 1\n"
      out `shouldSatisfy` T.isInfixOf "eh_bucket{job=\"test-lib\",le=\"+Inf\"} 5\n"
      out `shouldSatisfy` T.isInfixOf "eh_sum{job=\"test-lib\"} 42.0\n"
      out `shouldSatisfy` T.isInfixOf "eh_count{job=\"test-lib\"} 5\n"

    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "renders exponential histogram with negative buckets" $ do
      let pt =
            ExponentialHistogramDataPoint
              { exponentialHistogramDataPointStartTimeUnixNano = 0
              , exponentialHistogramDataPointTimeUnixNano = 1
              , exponentialHistogramDataPointCount = 3
              , exponentialHistogramDataPointSum = Just (-10.0)
              , exponentialHistogramDataPointScale = 0
              , exponentialHistogramDataPointZeroCount = 0
              , exponentialHistogramDataPointPositiveOffset = 0
              , exponentialHistogramDataPointPositiveBucketCounts = V.empty
              , exponentialHistogramDataPointNegativeOffset = 0
              , exponentialHistogramDataPointNegativeBucketCounts = V.fromList [1, 2]
              , exponentialHistogramDataPointAttributes = emptyAttributes
              , exponentialHistogramDataPointMin = Nothing
              , exponentialHistogramDataPointMax = Nothing
              , exponentialHistogramDataPointExemplars = V.empty
              , exponentialHistogramDataPointZeroThreshold = 0
              }
          out = rpt [wrap lib $ MetricExportExponentialHistogram "eh" "" "1" lib AggregationCumulative $ V.singleton pt]
      out `shouldSatisfy` T.isInfixOf "# TYPE eh histogram\n"
      out `shouldSatisfy` T.isInfixOf "eh_bucket{job=\"test-lib\",le=\"+Inf\"} 3\n"
      out `shouldSatisfy` T.isInfixOf "eh_count{job=\"test-lib\"} 3\n"

    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "exponential histogram with zero sum renders 0.0" $ do
      let pt =
            ExponentialHistogramDataPoint
              { exponentialHistogramDataPointStartTimeUnixNano = 0
              , exponentialHistogramDataPointTimeUnixNano = 1
              , exponentialHistogramDataPointCount = 0
              , exponentialHistogramDataPointSum = Nothing
              , exponentialHistogramDataPointScale = 0
              , exponentialHistogramDataPointZeroCount = 0
              , exponentialHistogramDataPointPositiveOffset = 0
              , exponentialHistogramDataPointPositiveBucketCounts = V.empty
              , exponentialHistogramDataPointNegativeOffset = 0
              , exponentialHistogramDataPointNegativeBucketCounts = V.empty
              , exponentialHistogramDataPointAttributes = emptyAttributes
              , exponentialHistogramDataPointMin = Nothing
              , exponentialHistogramDataPointMax = Nothing
              , exponentialHistogramDataPointExemplars = V.empty
              , exponentialHistogramDataPointZeroThreshold = 0
              }
          out = rpt [wrap lib $ MetricExportExponentialHistogram "eh" "" "1" lib AggregationCumulative $ V.singleton pt]
      out `shouldSatisfy` T.isInfixOf "eh_sum{job=\"test-lib\"} 0.0\n"
      out `shouldSatisfy` T.isInfixOf "eh_count{job=\"test-lib\"} 0\n"

    -- Resource attributes as labels
    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "resource attributes appear as labels on metric lines" $ do
      let res = materializeResourcesWithSchema Nothing (mkResource [unkey SC.cloud_region .= ("us-east-1" :: T.Text)])
          pt = mkGaugePt (DoubleNumber 1.0)
          rm =
            ResourceMetricsExport res $
              V.singleton $
                ScopeMetricsExport lib (V.singleton $ MetricExportGauge "m" "" "1" lib True $ V.singleton pt)
          out = rpt [rm]
      out `shouldSatisfy` T.isInfixOf "cloud_region=\"us-east-1\""
      out `shouldSatisfy` T.isInfixOf "job=\"test-lib\""

    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "point attributes override resource attributes on key collision" $ do
      let res = materializeResourcesWithSchema Nothing (mkResource ["env" .= ("staging" :: T.Text)])
          attrs = addAttribute defaultAttributeLimits emptyAttributes "env" ("prod" :: T.Text)
          pt = (mkGaugePt (DoubleNumber 1.0)) {gaugeDataPointAttributes = attrs}
          rm =
            ResourceMetricsExport res $
              V.singleton $
                ScopeMetricsExport lib (V.singleton $ MetricExportGauge "m" "" "1" lib True $ V.singleton pt)
          out = rpt [rm]
      out `shouldSatisfy` T.isInfixOf "env=\"prod\""
      out `shouldSatisfy` (not . T.isInfixOf "env=\"staging\"")

    -- Multiple metrics / scopes
    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "renders multiple metrics in one scope" $ do
      let g = MetricExportGauge "gauge1" "" "1" lib True $ V.singleton (mkGaugePt (DoubleNumber 1.0))
          c = MetricExportSum "counter1" "" "1" lib True False AggregationCumulative $ V.singleton (mkSumPt (IntNumber 5))
          rm =
            ResourceMetricsExport emptyMaterializedResources $
              V.singleton $
                ScopeMetricsExport lib (V.fromList [g, c])
          out = rpt [rm]
      out `shouldSatisfy` T.isInfixOf "# TYPE gauge1 gauge\n"
      out `shouldSatisfy` T.isInfixOf "# TYPE counter1 counter\n"
      out `shouldSatisfy` T.isInfixOf "gauge1{job=\"test-lib\"} 1.0\n"
      out `shouldSatisfy` T.isInfixOf "counter1{job=\"test-lib\"} 5\n"

    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "renders multiple scopes with different job labels" $ do
      let libA = InstrumentationLibrary "svc-a" "" "" emptyAttributes
          libB = InstrumentationLibrary "svc-b" "" "" emptyAttributes
          gA = MetricExportGauge "m" "" "1" libA True $ V.singleton (mkGaugePt (DoubleNumber 1.0))
          gB = MetricExportGauge "m" "" "1" libB True $ V.singleton (mkGaugePt (DoubleNumber 2.0))
          rm =
            ResourceMetricsExport emptyMaterializedResources $
              V.fromList
                [ ScopeMetricsExport libA (V.singleton gA)
                , ScopeMetricsExport libB (V.singleton gB)
                ]
          out = rpt [rm]
      out `shouldSatisfy` T.isInfixOf "m{job=\"svc-a\"} 1.0"
      out `shouldSatisfy` T.isInfixOf "m{job=\"svc-b\"} 2.0"

    -- Multiple data points with different attribute sets
    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "renders multiple data points per metric" $ do
      let a1 = addAttribute defaultAttributeLimits emptyAttributes "route" ("/a" :: T.Text)
          a2 = addAttribute defaultAttributeLimits emptyAttributes "route" ("/b" :: T.Text)
          pt1 = (mkGaugePt (DoubleNumber 10.0)) {gaugeDataPointAttributes = a1}
          pt2 = (mkGaugePt (DoubleNumber 20.0)) {gaugeDataPointAttributes = a2}
          out = rpt [wrap lib $ MetricExportGauge "rps" "" "1" lib True $ V.fromList [pt1, pt2]]
      out `shouldSatisfy` T.isInfixOf "rps{job=\"test-lib\",route=\"/a\"} 10.0\n"
      out `shouldSatisfy` T.isInfixOf "rps{job=\"test-lib\",route=\"/b\"} 20.0\n"

    -- Scope with empty library name omits job label
    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "omits job label when scope name is empty" $ do
      let emptyLib = InstrumentationLibrary "" "" "" emptyAttributes
          out = rpt [wrap emptyLib $ MetricExportGauge "m" "" "1" emptyLib True $ V.singleton (mkGaugePt (DoubleNumber 1.0))]
      out `shouldSatisfy` (not . T.isInfixOf "job=")
      out `shouldSatisfy` T.isInfixOf "m 1.0\n"

    -- Exemplar rendering
    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "renders exemplar comment on counter line" $ do
      let ex =
            MetricExemplar
              { metricExemplarTraceId = "\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10"
              , metricExemplarSpanId = "\xaa\xbb\xcc\xdd\xee\xff\x11\x22"
              , metricExemplarTimeUnixNano = 100
              , metricExemplarFilteredAttributes = emptyAttributes
              , metricExemplarValue = Just (IntNumber 42)
              }
          pt = (mkSumPt (IntNumber 42)) {sumDataPointExemplars = V.singleton ex}
          out = rpt [wrap lib $ MetricExportSum "c" "" "1" lib True True AggregationCumulative $ V.singleton pt]
      out `shouldSatisfy` T.isInfixOf "# {trace_id=\"0102030405060708090a0b0c0d0e0f10\",span_id=\"aabbccddeeff1122\"} 42"

    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "renders exemplar comment on histogram +Inf bucket" $ do
      let ex =
            MetricExemplar
              { metricExemplarTraceId = "\xde\xad\xbe\xef\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01"
              , metricExemplarSpanId = "\x01\x02\x03\x04\x05\x06\x07\x08"
              , metricExemplarTimeUnixNano = 200
              , metricExemplarFilteredAttributes = emptyAttributes
              , metricExemplarValue = Just (DoubleNumber 99.5)
              }
          pt =
            HistogramDataPoint
              { histogramDataPointStartTimeUnixNano = 0
              , histogramDataPointTimeUnixNano = 1
              , histogramDataPointCount = 1
              , histogramDataPointSum = 99.5
              , histogramDataPointBucketCounts = V.fromList [0, 1]
              , histogramDataPointExplicitBounds = V.fromList [50.0]
              , histogramDataPointAttributes = emptyAttributes
              , histogramDataPointMin = Nothing
              , histogramDataPointMax = Nothing
              , histogramDataPointExemplars = V.singleton ex
              }
          out = rpt [wrap lib $ MetricExportHistogram "h" "" "1" lib AggregationCumulative $ V.singleton pt]
      out `shouldSatisfy` T.isInfixOf "le=\"+Inf\"} 1 # {trace_id=\"deadbeef000000000000000000000001\",span_id=\"0102030405060708\"} 99.5"

    -- Edge cases
    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "zero value renders correctly" $ do
      let out = rpt [wrap lib $ MetricExportGauge "m" "" "1" lib True $ V.singleton (mkGaugePt (DoubleNumber 0.0))]
      out `shouldSatisfy` T.isInfixOf "m{job=\"test-lib\"} 0.0\n"

    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "Int64 gauge renders without decimal" $ do
      let out = rpt [wrap lib $ MetricExportGauge "m" "" "1" lib True $ V.singleton (mkGaugePt (IntNumber 42))]
      out `shouldSatisfy` T.isInfixOf "m{job=\"test-lib\"} 42\n"

    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "large Int64 renders without scientific notation" $ do
      let out = rpt [wrap lib $ MetricExportSum "big" "" "1" lib True True AggregationCumulative $ V.singleton (mkSumPt (IntNumber 9999999999))]
      out `shouldSatisfy` T.isInfixOf "big{job=\"test-lib\"} 9999999999\n"

    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "negative gauge renders correctly" $ do
      let out = rpt [wrap lib $ MetricExportGauge "m" "" "1" lib True $ V.singleton (mkGaugePt (IntNumber (-7)))]
      out `shouldSatisfy` T.isInfixOf "m{job=\"test-lib\"} -7\n"

    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "empty description produces HELP line with no text after name" $ do
      let out = rpt [wrap lib $ MetricExportGauge "m" "" "1" lib True $ V.singleton (mkGaugePt (DoubleNumber 1.0))]
      out `shouldSatisfy` T.isInfixOf "# HELP m \n"

    -- Boolean attribute as label value
    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "boolean attribute renders as true/false" $ do
      let attrs = addAttribute defaultAttributeLimits emptyAttributes "active" True
          pt = (mkGaugePt (DoubleNumber 1.0)) {gaugeDataPointAttributes = attrs}
          out = rpt [wrap lib $ MetricExportGauge "m" "" "1" lib True $ V.singleton pt]
      out `shouldSatisfy` T.isInfixOf "active=\"true\""

    -- Int attribute as label value
    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "int attribute renders as integer string in label" $ do
      let attrs = addAttribute defaultAttributeLimits emptyAttributes "code" (200 :: Int64)
          pt = (mkGaugePt (DoubleNumber 1.0)) {gaugeDataPointAttributes = attrs}
          out = rpt [wrap lib $ MetricExportGauge "m" "" "1" lib True $ V.singleton pt]
      out `shouldSatisfy` T.isInfixOf "code=\"200\""

  describe "Prometheus WAI" $ do
    -- HTTP metrics scrape endpoint (implementation; text format per compatibility spec)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    let metricsData =
          [ wrap lib $ MetricExportGauge "test_metric" "a test" "1" lib True $ V.singleton (mkGaugePt (DoubleNumber 42.0))
          ]
        collect = pure (V.fromList metricsData)
        metricsReq = defaultRequest {pathInfo = ["metrics"]}
        otherReq = defaultRequest {pathInfo = ["other"]}
        innerApp _req respond = respond $ responseLBS status200 [] "inner"

    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "prometheusApplication returns 200 with metrics content" $ do
      let app = prometheusApplication collect
      resp <- runSession (request metricsReq) app
      simpleStatus resp `shouldBe` status200
      let body = LBS.toStrict (simpleBody resp)
      T.isInfixOf "test_metric" (T.pack (show body)) `shouldBe` True

    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "prometheusMiddleware intercepts /metrics path" $ do
      let app = prometheusMiddleware collect innerApp
      resp <- runSession (request metricsReq) app
      simpleStatus resp `shouldBe` status200
      let body = LBS.toStrict (simpleBody resp)
      body `shouldSatisfy` (\b -> "inner" /= b)

    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "prometheusMiddleware passes non-metrics requests to inner app" $ do
      let app = prometheusMiddleware collect innerApp
      resp <- runSession (request otherReq) app
      simpleBody resp `shouldBe` "inner"

    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "prometheusMiddleware' respects custom path" $ do
      let config = defaultPrometheusExporterConfig {prometheusMetricsPath = ["custom", "prom"]}
          app = prometheusMiddleware' config collect innerApp
          customReq = defaultRequest {pathInfo = ["custom", "prom"]}
      resp <- runSession (request customReq) app
      simpleStatus resp `shouldBe` status200
      let body = LBS.toStrict (simpleBody resp)
      body `shouldSatisfy` (\b -> "inner" /= b)

    -- OpenTelemetry Prometheus/OpenMetrics compatibility (metric exposition)
    -- https://opentelemetry.io/docs/specs/otel/compatibility/prometheus_and_openmetrics/
    it "returns correct Content-Type header" $ do
      let app = prometheusApplication collect
      resp <- runSession (request metricsReq) app
      lookup "Content-Type" (simpleHeaders resp)
        `shouldBe` Just "text/plain; version=0.0.4; charset=utf-8"
