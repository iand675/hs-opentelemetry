{-# LANGUAGE OverloadedStrings #-}

import Data.Int (Int64)
import Data.ProtoLens (decodeMessage, encodeMessage)
import Data.Text (Text)
import qualified Data.Vector as V
import qualified Data.Vector.Unboxed as U
import Data.Word (Word64)
import Lens.Micro ((^.))
import OpenTelemetry.Attributes (emptyAttributes)
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
import OpenTelemetry.Exporter.OTLP.Metric (resourceMetricsToExportRequest)
import OpenTelemetry.Internal.Common.Types (InstrumentationLibrary (..))
import OpenTelemetry.Resource (emptyMaterializedResources)
import Proto.Opentelemetry.Proto.Collector.Metrics.V1.MetricsService (ExportMetricsServiceRequest)
import qualified Proto.Opentelemetry.Proto.Collector.Metrics.V1.MetricsService_Fields as MSF
import qualified Proto.Opentelemetry.Proto.Metrics.V1.Metrics as PM
import qualified Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields as Mf
import Test.Hspec


decodeExport :: [ResourceMetricsExport] -> Either String ExportMetricsServiceRequest
decodeExport rms = decodeMessage (encodeMessage (resourceMetricsToExportRequest rms))


main :: IO ()
main = hspec $ do
  describe "resourceMetricsToExportRequest" $ do
    it "round-trips SumDataPoint through protobuf decode" $ do
      let lib = "lib" :: InstrumentationLibrary
          pt = SumDataPoint 0 1 (Right 3) emptyAttributes V.empty
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
          (r ^. MSF.vec'resourceMetrics) `shouldNotSatisfy` V.null
          case firstNumberDataPoint r of
            Nothing -> expectationFailure "expected a NumberDataPoint"
            Just ndp -> do
              ndp ^. Mf.startTimeUnixNano `shouldBe` 0
              ndp ^. Mf.timeUnixNano `shouldBe` 1
              ndp ^. Mf.asDouble `shouldBe` 3

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
            dp ^. Mf.startTimeUnixNano `shouldBe` 100
            dp ^. Mf.timeUnixNano `shouldBe` 200
            dp ^. Mf.count `shouldBe` 10
            dp ^. Mf.maybe'sum `shouldBe` Just 99.5
            U.toList (dp ^. Mf.vec'bucketCounts) `shouldBe` [1, 2, 3, 4]
            U.toList (dp ^. Mf.vec'explicitBounds) `shouldBe` [0, 5, 10]
            dp ^. Mf.maybe'min `shouldBe` Just 0.25
            dp ^. Mf.maybe'max `shouldBe` Just 98.0

    it "round-trips GaugeDataPoint (Int)" $ do
      let lib = "lib" :: InstrumentationLibrary
          gdp = GaugeDataPoint 5 6 (Left (42 :: Int64)) emptyAttributes V.empty
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
            ndp ^. Mf.startTimeUnixNano `shouldBe` 5
            ndp ^. Mf.timeUnixNano `shouldBe` 6
            ndp ^. Mf.asInt `shouldBe` 42

    it "round-trips GaugeDataPoint (Double)" $ do
      let lib = "lib" :: InstrumentationLibrary
          gdp = GaugeDataPoint 7 8 (Right 2.718) emptyAttributes V.empty
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
            ndp ^. Mf.startTimeUnixNano `shouldBe` 7
            ndp ^. Mf.timeUnixNano `shouldBe` 8
            ndp ^. Mf.asDouble `shouldBe` 2.718

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
            dp ^. Mf.startTimeUnixNano `shouldBe` 1000
            dp ^. Mf.timeUnixNano `shouldBe` 2000
            dp ^. Mf.count `shouldBe` 50
            dp ^. Mf.maybe'sum `shouldBe` Just 123.4
            dp ^. Mf.scale `shouldBe` 3
            dp ^. Mf.zeroCount `shouldBe` 7
            dp ^. Mf.zeroThreshold `shouldBe` 0.5
            dp ^. Mf.maybe'min `shouldBe` Just 0.1
            dp ^. Mf.maybe'max `shouldBe` Just 99.9
            case dp ^. Mf.maybe'positive of
              Nothing -> expectationFailure "expected positive buckets"
              Just pos -> do
                pos ^. Mf.offset `shouldBe` 2
                U.toList (pos ^. Mf.vec'bucketCounts) `shouldBe` [5, 6]
            case dp ^. Mf.maybe'negative of
              Nothing -> expectationFailure "expected negative buckets"
              Just neg -> do
                neg ^. Mf.offset `shouldBe` (-1)
                U.toList (neg ^. Mf.vec'bucketCounts) `shouldBe` [1, 2]

    it "serializes AggregationDelta on Sum" $ do
      let lib = "lib" :: InstrumentationLibrary
          pt = SumDataPoint 0 0 (Left 0) emptyAttributes V.empty
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
            s ^. Mf.aggregationTemporality `shouldBe` PM.AGGREGATION_TEMPORALITY_DELTA

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
            h ^. Mf.aggregationTemporality `shouldBe` PM.AGGREGATION_TEMPORALITY_CUMULATIVE

    it "produces valid empty protobuf for an empty batch" $ do
      case decodeExport [] of
        Left e -> expectationFailure e
        Right r -> r ^. MSF.vec'resourceMetrics `shouldSatisfy` V.null

    it "encodes multiple ResourceMetricsExport batches" $ do
      let lib = "lib" :: InstrumentationLibrary
          mkRm name =
            ResourceMetricsExport emptyMaterializedResources $
              V.singleton $
                ScopeMetricsExport lib $
                  V.singleton $
                    MetricExportSum name "" "" lib True False AggregationCumulative $
                      V.singleton (SumDataPoint 0 0 (Right 0) emptyAttributes V.empty)
          rmA = mkRm "metric-a"
          rmB = mkRm "metric-b"
      case decodeExport [rmA, rmB] of
        Left e -> expectationFailure e
        Right r -> do
          let v = r ^. MSF.vec'resourceMetrics
          V.length v `shouldBe` 2
          metricNameAt v 0 `shouldBe` Just "metric-a"
          metricNameAt v 1 `shouldBe` Just "metric-b"


firstMetric :: ExportMetricsServiceRequest -> Maybe PM.Metric
firstMetric r = do
  rm <- (r ^. MSF.vec'resourceMetrics) V.!? 0
  sm <- (rm ^. Mf.vec'scopeMetrics) V.!? 0
  (sm ^. Mf.vec'metrics) V.!? 0


metricNameAt :: V.Vector PM.ResourceMetrics -> Int -> Maybe Text
metricNameAt v i = do
  rm <- v V.!? i
  sm <- (rm ^. Mf.vec'scopeMetrics) V.!? 0
  m <- (sm ^. Mf.vec'metrics) V.!? 0
  pure (m ^. Mf.name)


firstNumberDataPoint :: ExportMetricsServiceRequest -> Maybe PM.NumberDataPoint
firstNumberDataPoint r = do
  m <- firstMetric r
  case m ^. Mf.maybe'data' of
    Just (PM.Metric'Sum s) -> (s ^. Mf.vec'dataPoints) V.!? 0
    Just (PM.Metric'Gauge g) -> (g ^. Mf.vec'dataPoints) V.!? 0
    _ -> Nothing


firstSum :: ExportMetricsServiceRequest -> Maybe PM.Sum
firstSum r = do
  m <- firstMetric r
  case m ^. Mf.maybe'data' of
    Just (PM.Metric'Sum s) -> Just s
    _ -> Nothing


firstHistogram :: ExportMetricsServiceRequest -> Maybe PM.Histogram
firstHistogram r = do
  m <- firstMetric r
  case m ^. Mf.maybe'data' of
    Just (PM.Metric'Histogram h) -> Just h
    _ -> Nothing


firstHistogramDataPoint :: ExportMetricsServiceRequest -> Maybe PM.HistogramDataPoint
firstHistogramDataPoint r = do
  h <- firstHistogram r
  (h ^. Mf.vec'dataPoints) V.!? 0


firstExponentialHistogram :: ExportMetricsServiceRequest -> Maybe PM.ExponentialHistogram
firstExponentialHistogram r = do
  m <- firstMetric r
  case m ^. Mf.maybe'data' of
    Just (PM.Metric'ExponentialHistogram eh) -> Just eh
    _ -> Nothing


firstExponentialHistogramDataPoint :: ExportMetricsServiceRequest -> Maybe PM.ExponentialHistogramDataPoint
firstExponentialHistogramDataPoint r = do
  eh <- firstExponentialHistogram r
  (eh ^. Mf.vec'dataPoints) V.!? 0
