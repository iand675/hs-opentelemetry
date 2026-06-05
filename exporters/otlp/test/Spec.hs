{-# LANGUAGE OverloadedStrings #-}

import Data.Text (Text)
import qualified Data.Vector as V
import qualified Data.Vector.Unboxed as U
import Data.Word (Word64)
import OpenTelemetry.Attributes (emptyAttributes)
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
import OpenTelemetry.Exporter.OTLP.Metric (resourceMetricsToExportRequest)
import OpenTelemetry.Internal.Common.Types (InstrumentationLibrary (..))
import OpenTelemetry.Resource (emptyMaterializedResources)
import Proto.Decode (decodeMessage)
import Proto.Encode (encodeMessage)
import Proto.OpenTelemetry.Proto.Collector.Metrics.V1.MetricsService (ExportMetricsServiceRequest, exportMetricsServiceRequestResourceMetrics)
import qualified Proto.OpenTelemetry.Proto.Metrics.V1.Metrics as PM
import Test.Hspec


decodeExport :: [ResourceMetricsExport] -> Either String ExportMetricsServiceRequest
decodeExport rms =
  either (Left . show) Right $
    decodeMessage (encodeMessage (resourceMetricsToExportRequest (V.fromList rms)))


main :: IO ()
main = hspec $ do
  describe "resourceMetricsToExportRequest" $ do
    it "round-trips SumDataPoint through protobuf decode" $ do
      let lib = "lib" :: InstrumentationLibrary
          pt =
            SumDataPoint
              { sumDataPointStartTimeUnixNano = 0
              , sumDataPointTimeUnixNano = 1
              , sumDataPointValue = DoubleNumber 3
              , sumDataPointAttributes = emptyAttributes
              , sumDataPointExemplars = V.empty
              }
          exp =
            MetricExportSum "c" "d" "By" lib True False AggregationCumulative $
              V.singleton pt
          rm =
            ResourceMetricsExport emptyMaterializedResources $
              V.singleton $
                ScopeMetricsExport lib (V.singleton exp)
          decoded = decodeExport [rm]
      case decoded of
        Left e -> expectationFailure e
        Right r -> do
          exportMetricsServiceRequestResourceMetrics r `shouldNotSatisfy` V.null
          case firstNumberDataPoint r of
            Nothing -> expectationFailure "expected a NumberDataPoint"
            Just ndp -> do
              PM.numberDataPointStartTimeUnixNano ndp `shouldBe` 0
              PM.numberDataPointTimeUnixNano ndp `shouldBe` 1
              PM.numberDataPointValue ndp `shouldBe` Just (PM.NumberDataPoint'Value'AsDouble 3)

    it "round-trips HistogramDataPoint with non-empty buckets" $ do
      let lib = "lib" :: InstrumentationLibrary
          bounds = V.fromList [0, 5, 10] :: V.Vector Double
          counts = V.fromList [1, 2, 3, 4] :: V.Vector Word64
          hdp =
            HistogramDataPoint
              100
              200
              10
              99.5
              counts
              bounds
              emptyAttributes
              (Just 0.25)
              (Just 98.0)
              V.empty
          exp =
            MetricExportHistogram "hist" "desc" "1" lib AggregationCumulative $
              V.singleton hdp
          rm =
            ResourceMetricsExport emptyMaterializedResources $
              V.singleton $
                ScopeMetricsExport lib (V.singleton exp)
      case decodeExport [rm] of
        Left e -> expectationFailure e
        Right r -> case firstHistogramDataPoint r of
          Nothing -> expectationFailure "expected a HistogramDataPoint"
          Just dp -> do
            PM.histogramDataPointStartTimeUnixNano dp `shouldBe` 100
            PM.histogramDataPointTimeUnixNano dp `shouldBe` 200
            PM.histogramDataPointCount dp `shouldBe` 10
            PM.histogramDataPointSum dp `shouldBe` Just 99.5
            U.toList (PM.histogramDataPointBucketCounts dp) `shouldBe` [1, 2, 3, 4]
            U.toList (PM.histogramDataPointExplicitBounds dp) `shouldBe` [0, 5, 10]
            PM.histogramDataPointMin dp `shouldBe` Just 0.25
            PM.histogramDataPointMax dp `shouldBe` Just 98.0

    it "round-trips GaugeDataPoint (Int)" $ do
      let lib = "lib" :: InstrumentationLibrary
          gdp =
            GaugeDataPoint
              { gaugeDataPointStartTimeUnixNano = 5
              , gaugeDataPointTimeUnixNano = 6
              , gaugeDataPointValue = IntNumber 42
              , gaugeDataPointAttributes = emptyAttributes
              , gaugeDataPointExemplars = V.empty
              }
          exp = MetricExportGauge "g" "" "" lib True $ V.singleton gdp
          rm =
            ResourceMetricsExport emptyMaterializedResources $
              V.singleton $
                ScopeMetricsExport lib (V.singleton exp)
      case decodeExport [rm] of
        Left e -> expectationFailure e
        Right r -> case firstNumberDataPoint r of
          Nothing -> expectationFailure "expected a NumberDataPoint"
          Just ndp -> do
            PM.numberDataPointStartTimeUnixNano ndp `shouldBe` 5
            PM.numberDataPointTimeUnixNano ndp `shouldBe` 6
            PM.numberDataPointValue ndp `shouldBe` Just (PM.NumberDataPoint'Value'AsInt 42)

    it "round-trips GaugeDataPoint (Double)" $ do
      let lib = "lib" :: InstrumentationLibrary
          gdp =
            GaugeDataPoint
              { gaugeDataPointStartTimeUnixNano = 7
              , gaugeDataPointTimeUnixNano = 8
              , gaugeDataPointValue = DoubleNumber 2.718
              , gaugeDataPointAttributes = emptyAttributes
              , gaugeDataPointExemplars = V.empty
              }
          exp = MetricExportGauge "g2" "" "" lib False $ V.singleton gdp
          rm =
            ResourceMetricsExport emptyMaterializedResources $
              V.singleton $
                ScopeMetricsExport lib (V.singleton exp)
      case decodeExport [rm] of
        Left e -> expectationFailure e
        Right r -> case firstNumberDataPoint r of
          Nothing -> expectationFailure "expected a NumberDataPoint"
          Just ndp -> do
            PM.numberDataPointStartTimeUnixNano ndp `shouldBe` 7
            PM.numberDataPointTimeUnixNano ndp `shouldBe` 8
            PM.numberDataPointValue ndp `shouldBe` Just (PM.NumberDataPoint'Value'AsDouble 2.718)

    it "round-trips ExponentialHistogramDataPoint" $ do
      let lib = "lib" :: InstrumentationLibrary
          edp =
            ExponentialHistogramDataPoint
              1000
              2000
              50
              (Just 123.4)
              3
              7
              2
              (V.fromList [5, 6])
              (-1)
              (V.fromList [1, 2])
              emptyAttributes
              (Just 0.1)
              (Just 99.9)
              V.empty
              0.5
          exp =
            MetricExportExponentialHistogram "eh" "" "" lib AggregationDelta $
              V.singleton edp
          rm =
            ResourceMetricsExport emptyMaterializedResources $
              V.singleton $
                ScopeMetricsExport lib (V.singleton exp)
      case decodeExport [rm] of
        Left e -> expectationFailure e
        Right r -> case firstExponentialHistogramDataPoint r of
          Nothing -> expectationFailure "expected an ExponentialHistogramDataPoint"
          Just dp -> do
            PM.exponentialHistogramDataPointStartTimeUnixNano dp `shouldBe` 1000
            PM.exponentialHistogramDataPointTimeUnixNano dp `shouldBe` 2000
            PM.exponentialHistogramDataPointCount dp `shouldBe` 50
            PM.exponentialHistogramDataPointSum dp `shouldBe` Just 123.4
            PM.exponentialHistogramDataPointScale dp `shouldBe` 3
            PM.exponentialHistogramDataPointZeroCount dp `shouldBe` 7
            PM.exponentialHistogramDataPointZeroThreshold dp `shouldBe` 0.5
            PM.exponentialHistogramDataPointMin dp `shouldBe` Just 0.1
            PM.exponentialHistogramDataPointMax dp `shouldBe` Just 99.9
            case PM.exponentialHistogramDataPointPositive dp of
              Nothing -> expectationFailure "expected positive buckets"
              Just pos -> do
                PM.exponentialHistogramDataPointBucketsOffset pos `shouldBe` 2
                U.toList (PM.exponentialHistogramDataPointBucketsBucketCounts pos) `shouldBe` [5, 6]
            case PM.exponentialHistogramDataPointNegative dp of
              Nothing -> expectationFailure "expected negative buckets"
              Just neg -> do
                PM.exponentialHistogramDataPointBucketsOffset neg `shouldBe` (-1)
                U.toList (PM.exponentialHistogramDataPointBucketsBucketCounts neg) `shouldBe` [1, 2]

    it "serializes AggregationDelta on Sum" $ do
      let lib = "lib" :: InstrumentationLibrary
          pt =
            SumDataPoint
              { sumDataPointStartTimeUnixNano = 0
              , sumDataPointTimeUnixNano = 0
              , sumDataPointValue = IntNumber 0
              , sumDataPointAttributes = emptyAttributes
              , sumDataPointExemplars = V.empty
              }
          exp =
            MetricExportSum "s" "" "" lib False False AggregationDelta $
              V.singleton pt
          rm =
            ResourceMetricsExport emptyMaterializedResources $
              V.singleton $
                ScopeMetricsExport lib (V.singleton exp)
      case decodeExport [rm] of
        Left e -> expectationFailure e
        Right r -> case firstSum r of
          Nothing -> expectationFailure "expected Sum"
          Just s ->
            PM.sumAggregationTemporality s `shouldBe` PM.AggregationTemporality'AggregationTemporalityDelta

    it "serializes AggregationCumulative on Histogram" $ do
      let lib = "lib" :: InstrumentationLibrary
          hdp =
            HistogramDataPoint
              0
              0
              0
              0
              V.empty
              V.empty
              emptyAttributes
              Nothing
              Nothing
              V.empty
          exp =
            MetricExportHistogram "h" "" "" lib AggregationCumulative $
              V.singleton hdp
          rm =
            ResourceMetricsExport emptyMaterializedResources $
              V.singleton $
                ScopeMetricsExport lib (V.singleton exp)
      case decodeExport [rm] of
        Left e -> expectationFailure e
        Right r -> case firstHistogram r of
          Nothing -> expectationFailure "expected Histogram"
          Just h ->
            PM.histogramAggregationTemporality h `shouldBe` PM.AggregationTemporality'AggregationTemporalityCumulative

    it "produces valid empty protobuf for an empty batch" $ do
      case decodeExport [] of
        Left e -> expectationFailure e
        Right r -> exportMetricsServiceRequestResourceMetrics r `shouldSatisfy` V.null

    it "encodes multiple ResourceMetricsExport batches" $ do
      let lib = "lib" :: InstrumentationLibrary
          mkRm name =
            ResourceMetricsExport emptyMaterializedResources $
              V.singleton $
                ScopeMetricsExport lib $
                  V.singleton $
                    MetricExportSum name "" "" lib True False AggregationCumulative $
                      V.singleton
                        SumDataPoint
                          { sumDataPointStartTimeUnixNano = 0
                          , sumDataPointTimeUnixNano = 0
                          , sumDataPointValue = DoubleNumber 0
                          , sumDataPointAttributes = emptyAttributes
                          , sumDataPointExemplars = V.empty
                          }
          rmA = mkRm "metric-a"
          rmB = mkRm "metric-b"
      case decodeExport [rmA, rmB] of
        Left e -> expectationFailure e
        Right r -> do
          let v = exportMetricsServiceRequestResourceMetrics r
          V.length v `shouldBe` 2
          metricNameAt v 0 `shouldBe` Just "metric-a"
          metricNameAt v 1 `shouldBe` Just "metric-b"


firstMetric :: ExportMetricsServiceRequest -> Maybe PM.Metric
firstMetric r = do
  rm <- exportMetricsServiceRequestResourceMetrics r V.!? 0
  sm <- PM.resourceMetricsScopeMetrics rm V.!? 0
  PM.scopeMetricsMetrics sm V.!? 0


metricNameAt :: V.Vector PM.ResourceMetrics -> Int -> Maybe Text
metricNameAt v i = do
  rm <- v V.!? i
  sm <- PM.resourceMetricsScopeMetrics rm V.!? 0
  m <- PM.scopeMetricsMetrics sm V.!? 0
  pure (PM.metricName m)


firstNumberDataPoint :: ExportMetricsServiceRequest -> Maybe PM.NumberDataPoint
firstNumberDataPoint r = do
  m <- firstMetric r
  case PM.metricData m of
    Just (PM.Metric'Data'Sum s) -> PM.sumDataPoints s V.!? 0
    Just (PM.Metric'Data'Gauge g) -> PM.gaugeDataPoints g V.!? 0
    _ -> Nothing


firstSum :: ExportMetricsServiceRequest -> Maybe PM.Sum
firstSum r = do
  m <- firstMetric r
  case PM.metricData m of
    Just (PM.Metric'Data'Sum s) -> Just s
    _ -> Nothing


firstHistogram :: ExportMetricsServiceRequest -> Maybe PM.Histogram
firstHistogram r = do
  m <- firstMetric r
  case PM.metricData m of
    Just (PM.Metric'Data'Histogram h) -> Just h
    _ -> Nothing


firstHistogramDataPoint :: ExportMetricsServiceRequest -> Maybe PM.HistogramDataPoint
firstHistogramDataPoint r = do
  h <- firstHistogram r
  PM.histogramDataPoints h V.!? 0


firstExponentialHistogram :: ExportMetricsServiceRequest -> Maybe PM.ExponentialHistogram
firstExponentialHistogram r = do
  m <- firstMetric r
  case PM.metricData m of
    Just (PM.Metric'Data'ExponentialHistogram eh) -> Just eh
    _ -> Nothing


firstExponentialHistogramDataPoint :: ExportMetricsServiceRequest -> Maybe PM.ExponentialHistogramDataPoint
firstExponentialHistogramDataPoint r = do
  eh <- firstExponentialHistogram r
  PM.exponentialHistogramDataPoints eh V.!? 0
