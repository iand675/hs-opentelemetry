{-# LANGUAGE OverloadedStrings #-}

import qualified Data.Text as T
import qualified Data.Vector as V
import OpenTelemetry.Attributes (addAttribute, defaultAttributeLimits, emptyAttributes)
import OpenTelemetry.Exporter.Metric (
  AggregationTemporality (..),
  GaugeDataPoint (..),
  HistogramDataPoint (..),
  MetricExport (..),
  ResourceMetricsExport (..),
  ScopeMetricsExport (..),
  SumDataPoint (..),
 )
import OpenTelemetry.Exporter.Prometheus (renderPrometheusText)
import OpenTelemetry.Internal.Common.Types (InstrumentationLibrary)
import OpenTelemetry.Resource (emptyMaterializedResources)
import Test.Hspec


main :: IO ()
main = hspec $ do
  describe "OpenTelemetry.Exporter.Prometheus" $ do
    it "renders empty input as empty text" $ do
      renderPrometheusText [] `shouldBe` ""

    it "includes TYPE and HELP for a gauge (startTimeUnixNano on points)" $ do
      let lib = "test-lib" :: InstrumentationLibrary
          pt =
            GaugeDataPoint
              { gaugeDataPointStartTimeUnixNano = 0
              , gaugeDataPointTimeUnixNano = 1
              , gaugeDataPointValue = Right 2.5
              , gaugeDataPointAttributes = emptyAttributes
              , gaugeDataPointExemplars = V.empty
              }
          exp =
            MetricExportGauge "my.gauge" "help text" "1" lib True $
              V.singleton pt
          rm =
            ResourceMetricsExport emptyMaterializedResources $
              V.singleton $
                ScopeMetricsExport lib (V.singleton exp)
          out = renderPrometheusText [rm]
      T.lines out `shouldSatisfy` \ls ->
        any (T.isPrefixOf "# TYPE my_gauge gauge") ls
          && any (T.isPrefixOf "# HELP my_gauge") ls
          && any (T.isInfixOf "my_gauge") ls

    it "renders a monotonic sum as Prometheus counter type" $ do
      let lib = "test-lib" :: InstrumentationLibrary
          pt =
            SumDataPoint
              { sumDataPointStartTimeUnixNano = 0
              , sumDataPointTimeUnixNano = 10
              , sumDataPointValue = Right 42
              , sumDataPointAttributes = emptyAttributes
              , sumDataPointExemplars = V.empty
              }
          exp =
            MetricExportSum "http.requests" "total requests" "1" lib True False AggregationCumulative $
              V.singleton pt
          rm =
            ResourceMetricsExport emptyMaterializedResources $
              V.singleton $
                ScopeMetricsExport lib (V.singleton exp)
          out = renderPrometheusText [rm]
      out `shouldSatisfy` T.isInfixOf "# TYPE http_requests counter"
      out `shouldSatisfy` T.isInfixOf "http_requests{job=\"test-lib\"} 42.0"

    it "renders a non-monotonic sum as Prometheus gauge type" $ do
      let lib = "test-lib" :: InstrumentationLibrary
          pt =
            SumDataPoint
              { sumDataPointStartTimeUnixNano = 0
              , sumDataPointTimeUnixNano = 5
              , sumDataPointValue = Left (-3)
              , sumDataPointAttributes = emptyAttributes
              , sumDataPointExemplars = V.empty
              }
          exp =
            MetricExportSum "queue.delta" "up/down" "1" lib False False AggregationDelta $
              V.singleton pt
          rm =
            ResourceMetricsExport emptyMaterializedResources $
              V.singleton $
                ScopeMetricsExport lib (V.singleton exp)
          out = renderPrometheusText [rm]
      out `shouldSatisfy` T.isInfixOf "# TYPE queue_delta gauge"
      out `shouldSatisfy` T.isInfixOf "queue_delta{job=\"test-lib\"} -3"

    it "renders histogram buckets, _sum, _count, and +Inf" $ do
      let lib = "test-lib" :: InstrumentationLibrary
          pt =
            HistogramDataPoint
              { histogramDataPointStartTimeUnixNano = 0
              , histogramDataPointTimeUnixNano = 99
              , histogramDataPointCount = 6
              , histogramDataPointSum = 21.5
              , histogramDataPointBucketCounts = V.fromList [1, 2, 3]
              , histogramDataPointExplicitBounds = V.fromList [0.5, 1.0]
              , histogramDataPointAttributes = emptyAttributes
              , histogramDataPointMin = Nothing
              , histogramDataPointMax = Nothing
              , histogramDataPointExemplars = V.empty
              }
          exp =
            MetricExportHistogram "latency" "request latency" "ms" lib AggregationCumulative $
              V.singleton pt
          rm =
            ResourceMetricsExport emptyMaterializedResources $
              V.singleton $
                ScopeMetricsExport lib (V.singleton exp)
          out = renderPrometheusText [rm]
      out `shouldSatisfy` T.isInfixOf "# TYPE latency histogram"
      out `shouldSatisfy` T.isInfixOf "latency_bucket{job=\"test-lib\",le=\"0.5\"} 1"
      out `shouldSatisfy` T.isInfixOf "latency_bucket{job=\"test-lib\",le=\"1.0\"} 3"
      out `shouldSatisfy` T.isInfixOf "latency_bucket{job=\"test-lib\",le=\"+Inf\"} 6"
      out `shouldSatisfy` T.isInfixOf "latency_sum{job=\"test-lib\"} 21.5"
      out `shouldSatisfy` T.isInfixOf "latency_count{job=\"test-lib\"} 6"

    it "sanitizes metric names (dots become underscores)" $ do
      let lib = "test-lib" :: InstrumentationLibrary
          pt =
            GaugeDataPoint
              { gaugeDataPointStartTimeUnixNano = 0
              , gaugeDataPointTimeUnixNano = 1
              , gaugeDataPointValue = Right 1
              , gaugeDataPointAttributes = emptyAttributes
              , gaugeDataPointExemplars = V.empty
              }
          exp =
            MetricExportGauge "com.service.metric" "dotted name" "1" lib False $
              V.singleton pt
          rm =
            ResourceMetricsExport emptyMaterializedResources $
              V.singleton $
                ScopeMetricsExport lib (V.singleton exp)
          out = renderPrometheusText [rm]
      out `shouldSatisfy` T.isInfixOf "# TYPE com_service_metric gauge"
      out `shouldSatisfy` T.isInfixOf "# HELP com_service_metric"
      out `shouldSatisfy` T.isInfixOf "com_service_metric{job=\"test-lib\"} 1.0"

    it "orders merged label keys lexicographically (including job)" $ do
      let lib = "test-lib" :: InstrumentationLibrary
          attrs' =
            addAttribute
              defaultAttributeLimits
              (addAttribute defaultAttributeLimits emptyAttributes "zebra" ("z" :: T.Text))
              "apple"
              ("a" :: T.Text)
          pt =
            GaugeDataPoint
              { gaugeDataPointStartTimeUnixNano = 0
              , gaugeDataPointTimeUnixNano = 1
              , gaugeDataPointValue = Right 0
              , gaugeDataPointAttributes = attrs'
              , gaugeDataPointExemplars = V.empty
              }
          exp =
            MetricExportGauge "labels.order" "ord" "1" lib False $
              V.singleton pt
          rm =
            ResourceMetricsExport emptyMaterializedResources $
              V.singleton $
                ScopeMetricsExport lib (V.singleton exp)
          out = renderPrometheusText [rm]
      out `shouldSatisfy` T.isInfixOf "{apple=\"a\",job=\"test-lib\",zebra=\"z\"}"

    it "escapes backslashes and double quotes in label values" $ do
      let lib = "test-lib" :: InstrumentationLibrary
          attrsEsc =
            addAttribute defaultAttributeLimits emptyAttributes "k" ("say \"hi\"\\" :: T.Text)
          ptEsc =
            GaugeDataPoint
              { gaugeDataPointStartTimeUnixNano = 0
              , gaugeDataPointTimeUnixNano = 1
              , gaugeDataPointValue = Right 0
              , gaugeDataPointAttributes = attrsEsc
              , gaugeDataPointExemplars = V.empty
              }
          expEsc =
            MetricExportGauge "esc" "e" "1" lib False $
              V.singleton ptEsc
          rmEsc =
            ResourceMetricsExport emptyMaterializedResources $
              V.singleton $
                ScopeMetricsExport lib (V.singleton expEsc)
          outEsc = renderPrometheusText [rmEsc]
      outEsc `shouldSatisfy` T.isInfixOf "k=\"say \\\"hi\\\"\\\\\""

    it "renders multiple gauge points with different attributes" $ do
      let lib = "test-lib" :: InstrumentationLibrary
          a1 =
            addAttribute defaultAttributeLimits emptyAttributes "route" ("/a" :: T.Text)
          a2 =
            addAttribute defaultAttributeLimits emptyAttributes "route" ("/b" :: T.Text)
          pt1 =
            GaugeDataPoint
              { gaugeDataPointStartTimeUnixNano = 0
              , gaugeDataPointTimeUnixNano = 1
              , gaugeDataPointValue = Right 1
              , gaugeDataPointAttributes = a1
              , gaugeDataPointExemplars = V.empty
              }
          pt2 =
            GaugeDataPoint
              { gaugeDataPointStartTimeUnixNano = 0
              , gaugeDataPointTimeUnixNano = 2
              , gaugeDataPointValue = Right 2
              , gaugeDataPointAttributes = a2
              , gaugeDataPointExemplars = V.empty
              }
          exp =
            MetricExportGauge "routes.active" "active routes" "1" lib False $
              V.fromList [pt1, pt2]
          rm =
            ResourceMetricsExport emptyMaterializedResources $
              V.singleton $
                ScopeMetricsExport lib (V.singleton exp)
          out = renderPrometheusText [rm]
      out `shouldSatisfy` T.isInfixOf "routes_active{job=\"test-lib\",route=\"/a\"} 1.0"
      out `shouldSatisfy` T.isInfixOf "routes_active{job=\"test-lib\",route=\"/b\"} 2.0"
