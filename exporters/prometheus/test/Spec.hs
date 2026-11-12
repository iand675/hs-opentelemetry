{-# LANGUAGE OverloadedStrings #-}

import qualified Data.Text as T
import qualified Data.Vector as V
import OpenTelemetry.Attributes (addAttribute, defaultAttributeLimits, emptyAttributes)
import OpenTelemetry.Exporter.Metric (
  AggregationTemporality (..),
  GaugeDataPoint (..),
  HistogramDataPoint (..),
  MetricExport (..),
  NumberValue (..),
  ResourceMetricsExport (..),
  ScopeMetricsExport (..),
  SumDataPoint (..),
 )
import OpenTelemetry.Exporter.Prometheus (renderPrometheusText)
import OpenTelemetry.Internal.Common.Types (InstrumentationLibrary (..))
import OpenTelemetry.Resource (emptyMaterializedResources)
import Test.Hspec


main :: IO ()
main = hspec $ do
  describe "OpenTelemetry.Exporter.Prometheus" $ do
    it "renders empty input as empty text" $ do
      renderPrometheusText V.empty `shouldBe` ""

    it "includes TYPE and HELP for a gauge (startTimeUnixNano on points)" $ do
      let lib = "test-lib" :: InstrumentationLibrary
          pt =
            GaugeDataPoint
              { gaugeDataPointStartTimeUnixNano = 0
              , gaugeDataPointTimeUnixNano = 1
              , gaugeDataPointValue = DoubleNumber 2.5
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
          out = renderPrometheusText (V.singleton rm)
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
              , sumDataPointValue = DoubleNumber 42
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
          out = renderPrometheusText (V.singleton rm)
      out `shouldSatisfy` T.isInfixOf "# TYPE http_requests counter"
      out `shouldSatisfy` T.isInfixOf "http_requests{job=\"test-lib\",otel_scope_name=\"test-lib\",otel_scope_schema_url=\"\",otel_scope_version=\"\"} 42.0"

    it "renders a non-monotonic sum as Prometheus gauge type" $ do
      let lib = "test-lib" :: InstrumentationLibrary
          pt =
            SumDataPoint
              { sumDataPointStartTimeUnixNano = 0
              , sumDataPointTimeUnixNano = 5
              , sumDataPointValue = IntNumber (-3)
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
          out = renderPrometheusText (V.singleton rm)
      out `shouldSatisfy` T.isInfixOf "# TYPE queue_delta gauge"
      out `shouldSatisfy` T.isInfixOf "queue_delta{job=\"test-lib\",otel_scope_name=\"test-lib\",otel_scope_schema_url=\"\",otel_scope_version=\"\"} -3"

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
          out = renderPrometheusText (V.singleton rm)
      out `shouldSatisfy` T.isInfixOf "# TYPE latency histogram"
      out `shouldSatisfy` T.isInfixOf "latency_bucket{job=\"test-lib\",le=\"0.5\",otel_scope_name=\"test-lib\",otel_scope_schema_url=\"\",otel_scope_version=\"\"} 1"
      out `shouldSatisfy` T.isInfixOf "latency_bucket{job=\"test-lib\",le=\"1.0\",otel_scope_name=\"test-lib\",otel_scope_schema_url=\"\",otel_scope_version=\"\"} 3"
      out `shouldSatisfy` T.isInfixOf "latency_bucket{job=\"test-lib\",le=\"+Inf\",otel_scope_name=\"test-lib\",otel_scope_schema_url=\"\",otel_scope_version=\"\"} 6"
      out `shouldSatisfy` T.isInfixOf "latency_sum{job=\"test-lib\",otel_scope_name=\"test-lib\",otel_scope_schema_url=\"\",otel_scope_version=\"\"} 21.5"
      out `shouldSatisfy` T.isInfixOf "latency_count{job=\"test-lib\",otel_scope_name=\"test-lib\",otel_scope_schema_url=\"\",otel_scope_version=\"\"} 6"

    it "sanitizes metric names (dots become underscores)" $ do
      let lib = "test-lib" :: InstrumentationLibrary
          pt =
            GaugeDataPoint
              { gaugeDataPointStartTimeUnixNano = 0
              , gaugeDataPointTimeUnixNano = 1
              , gaugeDataPointValue = DoubleNumber 1
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
          out = renderPrometheusText (V.singleton rm)
      out `shouldSatisfy` T.isInfixOf "# TYPE com_service_metric gauge"
      out `shouldSatisfy` T.isInfixOf "# HELP com_service_metric"
      out `shouldSatisfy` T.isInfixOf "com_service_metric{job=\"test-lib\",otel_scope_name=\"test-lib\",otel_scope_schema_url=\"\",otel_scope_version=\"\"} 1.0"

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
              , gaugeDataPointValue = DoubleNumber 0
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
          out = renderPrometheusText (V.singleton rm)
      out `shouldSatisfy` T.isInfixOf "{apple=\"a\",job=\"test-lib\",otel_scope_name=\"test-lib\",otel_scope_schema_url=\"\",otel_scope_version=\"\",zebra=\"z\"}"

    it "escapes backslashes and double quotes in label values" $ do
      let lib = "test-lib" :: InstrumentationLibrary
          attrsEsc =
            addAttribute defaultAttributeLimits emptyAttributes "k" ("say \"hi\"\\" :: T.Text)
          ptEsc =
            GaugeDataPoint
              { gaugeDataPointStartTimeUnixNano = 0
              , gaugeDataPointTimeUnixNano = 1
              , gaugeDataPointValue = DoubleNumber 0
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
          outEsc = renderPrometheusText (V.singleton rmEsc)
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
              , gaugeDataPointValue = DoubleNumber 1
              , gaugeDataPointAttributes = a1
              , gaugeDataPointExemplars = V.empty
              }
          pt2 =
            GaugeDataPoint
              { gaugeDataPointStartTimeUnixNano = 0
              , gaugeDataPointTimeUnixNano = 2
              , gaugeDataPointValue = DoubleNumber 2
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
          out = renderPrometheusText (V.singleton rm)
      out `shouldSatisfy` T.isInfixOf "routes_active{job=\"test-lib\",otel_scope_name=\"test-lib\",otel_scope_schema_url=\"\",otel_scope_version=\"\",route=\"/a\"} 1.0"
      out `shouldSatisfy` T.isInfixOf "routes_active{job=\"test-lib\",otel_scope_name=\"test-lib\",otel_scope_schema_url=\"\",otel_scope_version=\"\",route=\"/b\"} 2.0"

    describe "metric families across a scrape" $ do
      let scope version = InstrumentationLibrary "db.client" version "/schema" emptyAttributes
          batch library metrics =
            ResourceMetricsExport emptyMaterializedResources (V.singleton (ScopeMetricsExport library (V.fromList metrics)))
          gauge library name description attrs time value =
            MetricExportGauge name description "1" library True $
              V.singleton (GaugeDataPoint 0 time (IntNumber value) attrs V.empty)
          sampleLines = filter (T.isPrefixOf "db_test{") . T.lines

      it "groups compatible exports and distinguishes instrumentation scope versions" $ do
        let v1 = scope "1"
            v2 = scope "2"
            result =
              renderPrometheusText $
                V.fromList
                  [ batch
                      v1
                      [ gauge v1 "db.test" "first help" emptyAttributes 1 1
                      , gauge v1 "other" "another family" emptyAttributes 1 3
                      ]
                  , batch v2 [gauge v2 "db_test" "second help" emptyAttributes 1 2]
                  ]
        take 4 (T.lines result)
          `shouldBe` [ "# HELP db_test first help"
                     , "# TYPE db_test gauge"
                     , "db_test{job=\"db.client\",otel_scope_name=\"db.client\",otel_scope_schema_url=\"/schema\",otel_scope_version=\"1\"} 1"
                     , "db_test{job=\"db.client\",otel_scope_name=\"db.client\",otel_scope_schema_url=\"/schema\",otel_scope_version=\"2\"} 2"
                     ]
        filter (T.isPrefixOf "# TYPE db_test ") (T.lines result) `shouldBe` ["# TYPE db_test gauge"]
        filter (T.isPrefixOf "# HELP db_test ") (T.lines result) `shouldBe` ["# HELP db_test first help"]

      it "omits a conflicting metric type and keeps compatible points" $ do
        let v1 = scope "1"
            v2 = scope "2"
            counter =
              MetricExportSum "db_test" "counter help" "1" v1 True True AggregationCumulative $
                V.singleton (SumDataPoint 0 2 (IntNumber 99) emptyAttributes V.empty)
            result =
              renderPrometheusText $
                V.fromList
                  [ batch v1 [gauge v1 "db.test" "gauge help" emptyAttributes 1 1, counter]
                  , batch v2 [gauge v2 "db.test" "gauge help" emptyAttributes 1 2]
                  ]
        filter (T.isPrefixOf "# TYPE db_test ") (T.lines result) `shouldBe` ["# TYPE db_test gauge"]
        map (T.takeEnd 2) (sampleLines result) `shouldBe` [" 1", " 2"]

      it "keeps the newest point when normalized series identities match" $ do
        let library = scope "1"
            labels key = addAttribute defaultAttributeLimits emptyAttributes key ("same" :: T.Text)
            result =
              renderPrometheusText $
                V.fromList
                  [ batch library [gauge library "db.test" "test" (labels "db.table") 10 1]
                  , batch library [gauge library "db_test" "test" (labels "db_table") 20 2]
                  , batch library [gauge library "db.test" "test" (labels "db.table") 15 3]
                  ]
        map (T.takeEnd 2) (sampleLines result) `shouldBe` [" 2"]

      it "exports scope attributes and concatenates colliding label names in key order" $ do
        let label attrs key value = addAttribute defaultAttributeLimits attrs key (value :: T.Text)
            scopeAttrs = label (label (label emptyAttributes "schema.url" "ignored") "tenant.id" "scope") "tenant_id" "alias"
            pointAttrs = label (label emptyAttributes "otel_scope_tenant_id" "point") "otel_scope.name" "point-name"
            library = (scope "1") {libraryAttributes = scopeAttrs}
            result =
              renderPrometheusText $
                V.singleton $
                  batch library [gauge library "db.test" "test" pointAttrs 1 1]
        sampleLines result
          `shouldBe` [ "db_test{job=\"db.client\",otel_scope_name=\"point-name;db.client\",otel_scope_schema_url=\"/schema\",otel_scope_tenant_id=\"scope;alias;point\",otel_scope_version=\"1\"} 1"
                     ]
