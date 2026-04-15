{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE OverloadedStrings #-}

import Control.Exception (bracket)
import qualified Data.ByteString as BS
import qualified Data.HashMap.Strict as H
import Data.IORef (newIORef)
import Data.Int (Int64)
import Data.ProtoLens (decodeMessage, defMessage, encodeMessage)
import Data.Text (Text)
import qualified Data.Vector as V
import qualified Data.Vector.Unboxed as U
import Data.Word (Word64)
import Lens.Micro ((&), (.~), (^.))
import Network.HTTP.Types.Status (
  mkStatus,
  status200,
  status400,
  status401,
  status429,
  status500,
  status501,
  status502,
  status503,
  status504,
 )
import OpenTelemetry.Attributes (addAttribute, defaultAttributeLimits, emptyAttributes)
import OpenTelemetry.Common (OptionalTimestamp (..), Timestamp (..), mkTimestamp)
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
import OpenTelemetry.Exporter.OTLP.Internal.Config (
  CompressionFormat (..),
  OTLPExporterConfig (..),
  Protocol (..),
  defaultExporterTimeout,
  grpcLogsEndpoint,
  grpcMetricsEndpoint,
  grpcTracesEndpoint,
  httpSignalEndpointUrl,
  isRetryableHttpStatus,
  readCompressionFormat,
  readProtocol,
  readTimeout,
 )
import OpenTelemetry.Exporter.OTLP.LogRecord (immutableLogRecordToProto)
import OpenTelemetry.Exporter.OTLP.Metric (resourceMetricsToExportRequest)
import OpenTelemetry.Exporter.OTLP.Span (
  immutableSpansToProtobuf,
  loadExporterEnvironmentVariables,
 )
import OpenTelemetry.Internal.Common.Types (InstrumentationLibrary (..))
import qualified OpenTelemetry.Internal.Log.Types as IL
import OpenTelemetry.LogAttributes (AnyValue (..), unsafeLogAttributesFromListIgnoringLimits)
import OpenTelemetry.Resource (emptyMaterializedResources)
import OpenTelemetry.Trace.Core (
  Event (..),
  ImmutableSpan (..),
  Link (..),
  SpanContext (..),
  SpanHot (..),
  SpanKind (..),
  SpanStatus (..),
  TraceFlags,
  createTracerProvider,
  defaultTraceFlags,
  emptyTracerProviderOptions,
  instrumentationLibrary,
  makeTracer,
  setSampled,
  traceFlagsValue,
  tracerOptions,
 )
import OpenTelemetry.Trace.Id (bytesToSpanId, bytesToTraceId, spanIdBytes, traceIdBytes)
import OpenTelemetry.Trace.TraceState as TS
import OpenTelemetry.Util (appendToBoundedCollection, emptyAppendOnlyBoundedCollection)
import Proto.Opentelemetry.Proto.Collector.Metrics.V1.MetricsService (
  ExportMetricsServiceRequest,
  ExportMetricsServiceResponse,
 )
import qualified Proto.Opentelemetry.Proto.Collector.Metrics.V1.MetricsService_Fields as MSF
import Proto.Opentelemetry.Proto.Collector.Trace.V1.TraceService (
  ExportTraceServiceRequest,
  ExportTraceServiceResponse,
 )
import qualified Proto.Opentelemetry.Proto.Collector.Trace.V1.TraceService_Fields as TSF
import qualified Proto.Opentelemetry.Proto.Common.V1.Common_Fields as CF
import qualified Proto.Opentelemetry.Proto.Logs.V1.Logs as PL
import qualified Proto.Opentelemetry.Proto.Logs.V1.Logs_Fields as LF
import qualified Proto.Opentelemetry.Proto.Metrics.V1.Metrics as PM
import qualified Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields as Mf
import Proto.Opentelemetry.Proto.Trace.V1.Trace (Span)
import qualified Proto.Opentelemetry.Proto.Trace.V1.Trace as PT
import qualified Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields as Trace_Fields
import System.Environment (lookupEnv, setEnv, unsetEnv)
import Test.Hspec


decodeExport :: [ResourceMetricsExport] -> Either String ExportMetricsServiceRequest
decodeExport rms = decodeMessage (encodeMessage (resourceMetricsToExportRequest (V.fromList rms)))


main :: IO ()
main = hspec $ sequential $ do
  -- OpenTelemetry Protocol (OTLP) and OTLP exporter
  -- https://opentelemetry.io/docs/specs/otlp/
  -- https://opentelemetry.io/docs/specs/otel/protocol/exporter/
  describe "resourceMetricsToExportRequest" $ do
    -- OTLP Metrics (ExportMetricsServiceRequest / protobuf)
    -- https://opentelemetry.io/docs/specs/otlp/#metrics
    it "round-trips SumDataPoint through protobuf decode" $ do
      let lib = "lib" :: InstrumentationLibrary
          pt = SumDataPoint 0 1 (DoubleNumber 3) emptyAttributes V.empty
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

    -- OTLP Metrics (ExportMetricsServiceRequest / protobuf)
    -- https://opentelemetry.io/docs/specs/otlp/#metrics
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

    -- OTLP Metrics (ExportMetricsServiceRequest / protobuf)
    -- https://opentelemetry.io/docs/specs/otlp/#metrics
    it "round-trips GaugeDataPoint (Int)" $ do
      let lib = "lib" :: InstrumentationLibrary
          gdp = GaugeDataPoint 5 6 (IntNumber (42 :: Int64)) emptyAttributes V.empty
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

    -- OTLP Metrics (ExportMetricsServiceRequest / protobuf)
    -- https://opentelemetry.io/docs/specs/otlp/#metrics
    it "round-trips GaugeDataPoint (Double)" $ do
      let lib = "lib" :: InstrumentationLibrary
          gdp = GaugeDataPoint 7 8 (DoubleNumber 2.718) emptyAttributes V.empty
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

    -- OTLP Metrics (ExportMetricsServiceRequest / protobuf)
    -- https://opentelemetry.io/docs/specs/otlp/#metrics
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

    -- OTLP Metrics (ExportMetricsServiceRequest / protobuf)
    -- https://opentelemetry.io/docs/specs/otlp/#metrics
    it "serializes AggregationDelta on Sum" $ do
      let lib = "lib" :: InstrumentationLibrary
          pt = SumDataPoint 0 0 (IntNumber 0) emptyAttributes V.empty
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

    -- OTLP Metrics (ExportMetricsServiceRequest / protobuf)
    -- https://opentelemetry.io/docs/specs/otlp/#metrics
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

    -- OTLP Metrics (ExportMetricsServiceRequest / protobuf)
    -- https://opentelemetry.io/docs/specs/otlp/#metrics
    it "produces valid empty protobuf for an empty batch" $ do
      case decodeExport [] of
        Left e -> expectationFailure e
        Right r -> r ^. MSF.vec'resourceMetrics `shouldSatisfy` V.null

    -- OTLP Metrics (ExportMetricsServiceRequest / protobuf)
    -- https://opentelemetry.io/docs/specs/otlp/#metrics
    it "encodes multiple ResourceMetricsExport batches" $ do
      let lib = "lib" :: InstrumentationLibrary
          mkRm name =
            ResourceMetricsExport emptyMaterializedResources $
              V.singleton $
                ScopeMetricsExport lib $
                  V.singleton $
                    MetricExportSum name "" "" lib True False AggregationCumulative $
                      V.singleton (SumDataPoint 0 0 (DoubleNumber 0) emptyAttributes V.empty)
          rmA = mkRm "metric-a"
          rmB = mkRm "metric-b"
      case decodeExport [rmA, rmB] of
        Left e -> expectationFailure e
        Right r -> do
          let v = r ^. MSF.vec'resourceMetrics
          V.length v `shouldBe` 2
          metricNameAt v 0 `shouldBe` Just "metric-a"
          metricNameAt v 1 `shouldBe` Just "metric-b"

    -- OTLP Metrics (ExportMetricsServiceRequest / protobuf)
    -- https://opentelemetry.io/docs/specs/otlp/#metrics
    it "round-trips SumDataPoint with non-empty exemplars" $ do
      let lib = "lib" :: InstrumentationLibrary
          tid = either error id $ bytesToTraceId $ BS.replicate 16 3
          sid = either error id $ bytesToSpanId $ BS.replicate 8 7
          ex =
            MetricExemplar
              { metricExemplarTraceId = traceIdBytes tid
              , metricExemplarSpanId = spanIdBytes sid
              , metricExemplarTimeUnixNano = 999
              , metricExemplarFilteredAttributes = emptyAttributes
              , metricExemplarValue = Just (DoubleNumber 1.25)
              }
          pt = SumDataPoint 1 2 (DoubleNumber 42) emptyAttributes (V.singleton ex)
          exp =
            MetricExportSum "with-ex" "" "" lib True False AggregationCumulative $
              V.singleton pt
          rm =
            ResourceMetricsExport emptyMaterializedResources $
              V.singleton $
                ScopeMetricsExport lib (V.singleton exp)
      case decodeExport [rm] of
        Left e -> expectationFailure e
        Right r -> case firstNumberDataPoint r of
          Nothing -> expectationFailure "expected a NumberDataPoint"
          Just ndp -> do
            let exs = ndp ^. Mf.vec'exemplars
            V.length exs `shouldBe` 1
            case exs V.!? 0 of
              Nothing -> expectationFailure "exemplar"
              Just ep -> do
                ep ^. Mf.traceId `shouldBe` traceIdBytes tid
                ep ^. Mf.spanId `shouldBe` spanIdBytes sid
                ep ^. Mf.timeUnixNano `shouldBe` 999
                ep ^. Mf.maybe'value `shouldBe` Just (PM.Exemplar'AsDouble 1.25)

  describe "immutableLogRecordToProto" $ do
    let emptyLogAttrs = unsafeLogAttributesFromListIgnoringLimits []
        obsTs = mkTimestamp 10 20
        attrs =
          unsafeLogAttributesFromListIgnoringLimits
            [("k", TextValue "v")]

    -- OTLP Logs (LogRecord protobuf)
    -- https://opentelemetry.io/docs/specs/otlp/#logs
    it "encodes severity number" $ do
      let lr =
            IL.ImmutableLogRecord
              { IL.logRecordTimestamp = IL.UNothing
              , IL.logRecordObservedTimestamp = obsTs
              , IL.logRecordTracingDetails = IL.UNothing
              , IL.logRecordSeverityText = IL.UNothing
              , IL.logRecordSeverityNumber = IL.UJust IL.Info
              , IL.logRecordBody = NullValue
              , IL.logRecordAttributes = emptyLogAttrs
              , IL.logRecordEventName = IL.UNothing
              }
          proto = immutableLogRecordToProto lr
      proto ^. LF.severityNumber `shouldBe` PL.SEVERITY_NUMBER_INFO

    -- OTLP Logs (LogRecord protobuf)
    -- https://opentelemetry.io/docs/specs/otlp/#logs
    it "encodes severity text" $ do
      let lr =
            IL.ImmutableLogRecord
              { IL.logRecordTimestamp = IL.UNothing
              , IL.logRecordObservedTimestamp = obsTs
              , IL.logRecordTracingDetails = IL.UNothing
              , IL.logRecordSeverityText = IL.UJust "INFO"
              , IL.logRecordSeverityNumber = IL.UNothing
              , IL.logRecordBody = NullValue
              , IL.logRecordAttributes = emptyLogAttrs
              , IL.logRecordEventName = IL.UNothing
              }
          proto = immutableLogRecordToProto lr
      proto ^. LF.severityText `shouldBe` "INFO"

    -- OTLP Logs (LogRecord protobuf)
    -- https://opentelemetry.io/docs/specs/otlp/#logs
    it "encodes body text value" $ do
      let lr =
            IL.ImmutableLogRecord
              { IL.logRecordTimestamp = IL.UNothing
              , IL.logRecordObservedTimestamp = obsTs
              , IL.logRecordTracingDetails = IL.UNothing
              , IL.logRecordSeverityText = IL.UNothing
              , IL.logRecordSeverityNumber = IL.UNothing
              , IL.logRecordBody = TextValue "hello"
              , IL.logRecordAttributes = emptyLogAttrs
              , IL.logRecordEventName = IL.UNothing
              }
          proto = immutableLogRecordToProto lr
      case proto ^. LF.maybe'body of
        Nothing -> expectationFailure "body"
        Just b -> b ^. CF.stringValue `shouldBe` "hello"

    -- OTLP Logs (LogRecord protobuf)
    -- https://opentelemetry.io/docs/specs/otlp/#logs
    it "encodes trace context" $ do
      tid <- either (fail . show) pure $ bytesToTraceId $ BS.replicate 16 9
      sid <- either (fail . show) pure $ bytesToSpanId $ BS.replicate 8 8
      let flags :: TraceFlags
          flags = setSampled defaultTraceFlags
          lr =
            IL.ImmutableLogRecord
              { IL.logRecordTimestamp = IL.UNothing
              , IL.logRecordObservedTimestamp = obsTs
              , IL.logRecordTracingDetails = IL.UJust (tid, sid, flags)
              , IL.logRecordSeverityText = IL.UNothing
              , IL.logRecordSeverityNumber = IL.UNothing
              , IL.logRecordBody = NullValue
              , IL.logRecordAttributes = emptyLogAttrs
              , IL.logRecordEventName = IL.UNothing
              }
          proto = immutableLogRecordToProto lr
      proto ^. LF.traceId `shouldBe` traceIdBytes tid
      proto ^. LF.spanId `shouldBe` spanIdBytes sid
      proto ^. LF.flags `shouldBe` fromIntegral (traceFlagsValue flags)

    -- OTLP Logs (LogRecord protobuf)
    -- https://opentelemetry.io/docs/specs/otlp/#logs
    it "encodes event name" $ do
      let lr =
            IL.ImmutableLogRecord
              { IL.logRecordTimestamp = IL.UNothing
              , IL.logRecordObservedTimestamp = obsTs
              , IL.logRecordTracingDetails = IL.UNothing
              , IL.logRecordSeverityText = IL.UNothing
              , IL.logRecordSeverityNumber = IL.UNothing
              , IL.logRecordBody = NullValue
              , IL.logRecordAttributes = emptyLogAttrs
              , IL.logRecordEventName = IL.UJust "my.event"
              }
          proto = immutableLogRecordToProto lr
      proto ^. LF.eventName `shouldBe` "my.event"

    -- OTLP Logs (LogRecord protobuf)
    -- https://opentelemetry.io/docs/specs/otlp/#logs
    it "encodes attributes" $ do
      let lr =
            IL.ImmutableLogRecord
              { IL.logRecordTimestamp = IL.UNothing
              , IL.logRecordObservedTimestamp = obsTs
              , IL.logRecordTracingDetails = IL.UNothing
              , IL.logRecordSeverityText = IL.UNothing
              , IL.logRecordSeverityNumber = IL.UNothing
              , IL.logRecordBody = NullValue
              , IL.logRecordAttributes = attrs
              , IL.logRecordEventName = IL.UNothing
              }
          proto = immutableLogRecordToProto lr
      V.length (proto ^. LF.vec'attributes) `shouldNotBe` 0

    -- OTLP Logs (LogRecord protobuf)
    -- https://opentelemetry.io/docs/specs/otlp/#logs
    it "handles Unknown severity gracefully" $ do
      let lr =
            IL.ImmutableLogRecord
              { IL.logRecordTimestamp = IL.UNothing
              , IL.logRecordObservedTimestamp = obsTs
              , IL.logRecordTracingDetails = IL.UNothing
              , IL.logRecordSeverityText = IL.UNothing
              , IL.logRecordSeverityNumber = IL.UJust (IL.Unknown 99)
              , IL.logRecordBody = NullValue
              , IL.logRecordAttributes = emptyLogAttrs
              , IL.logRecordEventName = IL.UNothing
              }
          proto = immutableLogRecordToProto lr
      proto ^. LF.severityNumber `shouldBe` PL.SEVERITY_NUMBER_UNSPECIFIED

    -- OTLP Logs (LogRecord protobuf)
    -- https://opentelemetry.io/docs/specs/otlp/#logs
    it "round-trips through protobuf encode/decode" $ do
      let lr =
            IL.ImmutableLogRecord
              { IL.logRecordTimestamp = IL.UJust (mkTimestamp 1 2)
              , IL.logRecordObservedTimestamp = obsTs
              , IL.logRecordTracingDetails = IL.UNothing
              , IL.logRecordSeverityText = IL.UJust "WARN"
              , IL.logRecordSeverityNumber = IL.UJust IL.Warn
              , IL.logRecordBody = TextValue "round"
              , IL.logRecordAttributes = attrs
              , IL.logRecordEventName = IL.UJust "e"
              }
          enc = encodeMessage (immutableLogRecordToProto lr)
      case decodeMessage enc :: Either String PL.LogRecord of
        Left err -> expectationFailure err
        Right out -> do
          out ^. LF.severityText `shouldBe` "WARN"
          out ^. LF.eventName `shouldBe` "e"

  describe "immutableLogRecordToProto structured bodies" $ do
    let obsTs = mkTimestamp 10 20
        emptyLogAttrs = unsafeLogAttributesFromListIgnoringLimits []

    -- OTLP Logs LogRecord body (AnyValue)
    -- https://opentelemetry.io/docs/specs/otlp/#logs
    it "encodes array body value" $ do
      let lr =
            IL.ImmutableLogRecord
              { IL.logRecordTimestamp = IL.UNothing
              , IL.logRecordObservedTimestamp = obsTs
              , IL.logRecordTracingDetails = IL.UNothing
              , IL.logRecordSeverityText = IL.UNothing
              , IL.logRecordSeverityNumber = IL.UNothing
              , IL.logRecordBody = ArrayValue [TextValue "a", TextValue "b"]
              , IL.logRecordAttributes = emptyLogAttrs
              , IL.logRecordEventName = IL.UNothing
              }
          enc = encodeMessage (immutableLogRecordToProto lr)
      case decodeMessage enc :: Either String PL.LogRecord of
        Left err -> expectationFailure err
        Right out -> do
          case out ^. LF.maybe'body of
            Nothing -> expectationFailure "expected body"
            Just b -> do
              let arrVals = b ^. CF.arrayValue . CF.vec'values
              V.length arrVals `shouldBe` 2

    -- OTLP Logs LogRecord body (AnyValue)
    -- https://opentelemetry.io/docs/specs/otlp/#logs
    it "encodes map body value" $ do
      let lr =
            IL.ImmutableLogRecord
              { IL.logRecordTimestamp = IL.UNothing
              , IL.logRecordObservedTimestamp = obsTs
              , IL.logRecordTracingDetails = IL.UNothing
              , IL.logRecordSeverityText = IL.UNothing
              , IL.logRecordSeverityNumber = IL.UNothing
              , IL.logRecordBody = HashMapValue (H.singleton "k1" (TextValue "v1"))
              , IL.logRecordAttributes = emptyLogAttrs
              , IL.logRecordEventName = IL.UNothing
              }
          enc = encodeMessage (immutableLogRecordToProto lr)
      case decodeMessage enc :: Either String PL.LogRecord of
        Left err -> expectationFailure err
        Right out -> do
          case out ^. LF.maybe'body of
            Nothing -> expectationFailure "expected body"
            Just b -> do
              let kvs = b ^. CF.kvlistValue . CF.vec'values
              V.length kvs `shouldSatisfy` (> 0)

  describe "immutableLogRecordToProto severity mapping" $ do
    let obsTs = mkTimestamp 10 20
        emptyLogAttrs = unsafeLogAttributesFromListIgnoringLimits []
        mkLr sev =
          IL.ImmutableLogRecord
            { IL.logRecordTimestamp = IL.UNothing
            , IL.logRecordObservedTimestamp = obsTs
            , IL.logRecordTracingDetails = IL.UNothing
            , IL.logRecordSeverityText = IL.UNothing
            , IL.logRecordSeverityNumber = IL.UJust sev
            , IL.logRecordBody = NullValue
            , IL.logRecordAttributes = emptyLogAttrs
            , IL.logRecordEventName = IL.UNothing
            }

    -- OTLP Logs severity number
    -- https://opentelemetry.io/docs/specs/otlp/#logs
    it "maps Trace severity" $ do
      let proto = immutableLogRecordToProto (mkLr IL.Trace)
      proto ^. LF.severityNumber `shouldBe` PL.SEVERITY_NUMBER_TRACE

    -- OTLP Logs severity number
    -- https://opentelemetry.io/docs/specs/otlp/#logs
    it "maps Debug severity" $ do
      let proto = immutableLogRecordToProto (mkLr IL.Debug)
      proto ^. LF.severityNumber `shouldBe` PL.SEVERITY_NUMBER_DEBUG

    -- OTLP Logs severity number
    -- https://opentelemetry.io/docs/specs/otlp/#logs
    it "maps Warn severity" $ do
      let proto = immutableLogRecordToProto (mkLr IL.Warn)
      proto ^. LF.severityNumber `shouldBe` PL.SEVERITY_NUMBER_WARN

    -- OTLP Logs severity number
    -- https://opentelemetry.io/docs/specs/otlp/#logs
    it "maps Error severity" $ do
      let proto = immutableLogRecordToProto (mkLr IL.Error)
      proto ^. LF.severityNumber `shouldBe` PL.SEVERITY_NUMBER_ERROR

    -- OTLP Logs severity number
    -- https://opentelemetry.io/docs/specs/otlp/#logs
    it "maps Fatal severity" $ do
      let proto = immutableLogRecordToProto (mkLr IL.Fatal)
      proto ^. LF.severityNumber `shouldBe` PL.SEVERITY_NUMBER_FATAL

  describe "immutableSpansToProtobuf" $ do
    describe "immutableSpansToProtobuf edge cases" $ do
      -- OTLP Traces Span (links, empty export)
      -- https://opentelemetry.io/docs/specs/otlp/#traces
      it "empty span map produces valid empty request" $ do
        exportReq <- immutableSpansToProtobuf H.empty
        case decodeMessage (encodeMessage exportReq) :: Either String ExportTraceServiceRequest of
          Left err -> expectationFailure err
          Right r -> case (r ^. TSF.vec'resourceSpans) V.!? 0 of
            Nothing -> expectationFailure "expected resourceSpans"
            Just rs -> rs ^. Trace_Fields.vec'scopeSpans `shouldSatisfy` V.null

      -- OTLP Traces Span (links, empty export)
      -- https://opentelemetry.io/docs/specs/otlp/#traces
      it "link attributes are preserved through encoding" $ do
        trProv <- createTracerProvider [] emptyTracerProviderOptions
        let lib = instrumentationLibrary "link-attrs-test" "1"
            tr = makeTracer trProv lib tracerOptions
        spanTid <- either (fail . show) pure $ bytesToTraceId $ BS.replicate 16 1
        spanSid <- either (fail . show) pure $ bytesToSpanId $ BS.replicate 8 2
        linkTid <- either (fail . show) pure $ bytesToTraceId $ BS.replicate 16 3
        linkSid <- either (fail . show) pure $ bytesToSpanId $ BS.replicate 8 4
        let spanCtx =
              SpanContext
                { traceFlags = defaultTraceFlags
                , isRemote = False
                , traceId = spanTid
                , spanId = spanSid
                , traceState = TS.empty
                }
            linkCtx =
              SpanContext
                { traceFlags = defaultTraceFlags
                , isRemote = False
                , traceId = linkTid
                , spanId = linkSid
                , traceState = TS.empty
                }
            lnk = Link {frozenLinkContext = linkCtx, frozenLinkAttributes = addAttribute defaultAttributeLimits emptyAttributes "link.key" ("link.val" :: Text)}
            links = appendToBoundedCollection (emptyAppendOnlyBoundedCollection 8) lnk
        hotRef <-
          newIORef $
            SpanHot
              { hotName = "with-link-attrs"
              , hotEnd = NoTimestamp
              , hotAttributes = emptyAttributes
              , hotLinks = links
              , hotEvents = emptyAppendOnlyBoundedCollection 16
              , hotStatus = Unset
              }
        let imm =
              ImmutableSpan
                { spanContext = spanCtx
                , spanKind = Internal
                , spanStart = mkTimestamp 0 0
                , spanParent = Nothing
                , spanTracer = tr
                , spanHot = hotRef
                }
        exportReq <- immutableSpansToProtobuf $ H.singleton lib (V.singleton imm)
        case decodeMessage (encodeMessage exportReq) :: Either String ExportTraceServiceRequest of
          Left err -> expectationFailure err
          Right roundTrip -> case firstOtlpSpan roundTrip of
            Nothing -> expectationFailure "expected span"
            Just sp -> do
              let ls = sp ^. Trace_Fields.vec'links
              V.length ls `shouldBe` 1
              case ls V.!? 0 of
                Nothing -> expectationFailure "expected link"
                Just lk -> do
                  let attrs = lk ^. Trace_Fields.vec'attributes
                  V.length attrs `shouldSatisfy` (> 0)

    describe "UTF-8 attribute handling" $ do
      -- OTLP Traces Span attributes (string values)
      -- https://opentelemetry.io/docs/specs/otlp/#traces
      it "multi-byte UTF-8 attribute values survive protobuf round-trip" $ do
        trProv <- createTracerProvider [] emptyTracerProviderOptions
        let lib = instrumentationLibrary "utf8-test" "1"
            tr = makeTracer trProv lib tracerOptions
        tid <- either (fail . show) pure $ bytesToTraceId $ BS.replicate 16 1
        sid <- either (fail . show) pure $ bytesToSpanId $ BS.replicate 8 2
        let ctx =
              SpanContext
                { traceFlags = defaultTraceFlags
                , isRemote = False
                , traceId = tid
                , spanId = sid
                , traceState = TS.empty
                }
            attrs = addAttribute defaultAttributeLimits emptyAttributes "emoji" ("Hello 🌍🎉" :: Text)
        hotRef <-
          newIORef $
            SpanHot
              { hotName = "utf8"
              , hotEnd = NoTimestamp
              , hotAttributes = attrs
              , hotLinks = emptyAppendOnlyBoundedCollection 8
              , hotEvents = emptyAppendOnlyBoundedCollection 16
              , hotStatus = Unset
              }
        let imm =
              ImmutableSpan
                { spanContext = ctx
                , spanKind = Internal
                , spanStart = mkTimestamp 0 0
                , spanParent = Nothing
                , spanTracer = tr
                , spanHot = hotRef
                }
        exportReq <- immutableSpansToProtobuf $ H.singleton lib (V.singleton imm)
        case decodeMessage (encodeMessage exportReq) :: Either String ExportTraceServiceRequest of
          Left err -> expectationFailure err
          Right roundTrip -> case firstOtlpSpan roundTrip of
            Nothing -> expectationFailure "expected span"
            Just sp -> do
              let spanAttrs = sp ^. Trace_Fields.vec'attributes
              V.length spanAttrs `shouldSatisfy` (> 0)

    -- OTLP Traces Span (name, kind, trace/span id, status, events)
    -- https://opentelemetry.io/docs/specs/otlp/#traces
    it "encodes span name, kind, ids, status, and events" $ do
      trProv <- createTracerProvider [] emptyTracerProviderOptions
      let lib = instrumentationLibrary "otel-span-test" "1"
          tr = makeTracer trProv lib tracerOptions
      tid <- either (fail . show) pure $ bytesToTraceId $ BS.replicate 16 1
      sid <- either (fail . show) pure $ bytesToSpanId $ BS.replicate 8 2
      let ctx =
            SpanContext
              { traceFlags = setSampled defaultTraceFlags
              , isRemote = False
              , traceId = tid
              , spanId = sid
              , traceState = TS.empty
              }
          t0 = mkTimestamp 100 0
          ev = Event "user.evt" emptyAttributes (mkTimestamp 101 0)
          events = appendToBoundedCollection (emptyAppendOnlyBoundedCollection 16) ev
      hotRef <-
        newIORef $
          SpanHot
            { hotName = "op.name"
            , hotEnd = SomeTimestamp (102 * 1_000_000_000)
            , hotAttributes = emptyAttributes
            , hotLinks = emptyAppendOnlyBoundedCollection 8
            , hotEvents = events
            , hotStatus = Error "boom"
            }
      let imm =
            ImmutableSpan
              { spanContext = ctx
              , spanKind = Server
              , spanStart = t0
              , spanParent = Nothing
              , spanTracer = tr
              , spanHot = hotRef
              }
      exportReq <- immutableSpansToProtobuf $ H.singleton lib (V.singleton imm)
      case decodeMessage (encodeMessage exportReq) :: Either String ExportTraceServiceRequest of
        Left err -> expectationFailure err
        Right roundTrip -> case firstOtlpSpan roundTrip of
          Nothing -> expectationFailure "expected span"
          Just sp -> do
            sp ^. Trace_Fields.name `shouldBe` "op.name"
            sp ^. Trace_Fields.kind `shouldBe` PT.Span'SPAN_KIND_SERVER
            sp ^. Trace_Fields.traceId `shouldBe` traceIdBytes tid
            sp ^. Trace_Fields.spanId `shouldBe` spanIdBytes sid
            sp ^. Trace_Fields.status . Trace_Fields.code `shouldBe` PT.Status'STATUS_CODE_ERROR
            sp ^. Trace_Fields.status . Trace_Fields.message `shouldBe` "boom"
            let evs = sp ^. Trace_Fields.vec'events
            V.length evs `shouldBe` 1
            case evs V.!? 0 of
              Nothing -> expectationFailure "event"
              Just e -> e ^. Trace_Fields.name `shouldBe` "user.evt"

    -- OTLP Traces SpanKind
    -- https://opentelemetry.io/docs/specs/otlp/#traces
    it "maps Client span kind" $ do
      trProv <- createTracerProvider [] emptyTracerProviderOptions
      let lib = instrumentationLibrary "otel-span-test" "1"
          tr = makeTracer trProv lib tracerOptions
      tid <- either (fail . show) pure $ bytesToTraceId $ BS.replicate 16 4
      sid <- either (fail . show) pure $ bytesToSpanId $ BS.replicate 8 5
      let ctx =
            SpanContext
              { traceFlags = defaultTraceFlags
              , isRemote = False
              , traceId = tid
              , spanId = sid
              , traceState = TS.empty
              }
      hotRef <-
        newIORef $
          SpanHot
            { hotName = "c"
            , hotEnd = NoTimestamp
            , hotAttributes = emptyAttributes
            , hotLinks = emptyAppendOnlyBoundedCollection 8
            , hotEvents = emptyAppendOnlyBoundedCollection 16
            , hotStatus = Unset
            }
      let imm =
            ImmutableSpan
              { spanContext = ctx
              , spanKind = Client
              , spanStart = mkTimestamp 0 0
              , spanParent = Nothing
              , spanTracer = tr
              , spanHot = hotRef
              }
      exportReq <- immutableSpansToProtobuf $ H.singleton lib (V.singleton imm)
      case firstOtlpSpan exportReq of
        Nothing -> expectationFailure "span"
        Just sp -> sp ^. Trace_Fields.kind `shouldBe` PT.Span'SPAN_KIND_CLIENT

    -- OTLP Traces Span flags (sampled)
    -- https://opentelemetry.io/docs/specs/otlp/#traces
    it "sets span flags to sampled (1) when spanContext uses setSampled defaultTraceFlags" $ do
      trProv <- createTracerProvider [] emptyTracerProviderOptions
      let lib = instrumentationLibrary "otel-span-flags" "1"
          tr = makeTracer trProv lib tracerOptions
      tid <- either (fail . show) pure $ bytesToTraceId $ BS.replicate 16 6
      sid <- either (fail . show) pure $ bytesToSpanId $ BS.replicate 8 7
      let flags :: TraceFlags
          flags = setSampled defaultTraceFlags
          ctx =
            SpanContext
              { traceFlags = flags
              , isRemote = False
              , traceId = tid
              , spanId = sid
              , traceState = TS.empty
              }
      hotRef <-
        newIORef $
          SpanHot
            { hotName = "with-flags"
            , hotEnd = NoTimestamp
            , hotAttributes = emptyAttributes
            , hotLinks = emptyAppendOnlyBoundedCollection 8
            , hotEvents = emptyAppendOnlyBoundedCollection 16
            , hotStatus = Unset
            }
      let imm =
            ImmutableSpan
              { spanContext = ctx
              , spanKind = Internal
              , spanStart = mkTimestamp 0 0
              , spanParent = Nothing
              , spanTracer = tr
              , spanHot = hotRef
              }
      exportReq <- immutableSpansToProtobuf $ H.singleton lib (V.singleton imm)
      case decodeMessage (encodeMessage exportReq) :: Either String ExportTraceServiceRequest of
        Left err -> expectationFailure err
        Right roundTrip -> case firstOtlpSpan roundTrip of
          Nothing -> expectationFailure "expected span"
          Just sp -> sp ^. Trace_Fields.flags `shouldBe` 1

    -- OTLP Traces Span Link flags
    -- https://opentelemetry.io/docs/specs/otlp/#traces
    it "sets link flags to sampled + HAS_IS_REMOTE (0x101) when frozenLinkContext uses setSampled, isRemote=False" $ do
      trProv <- createTracerProvider [] emptyTracerProviderOptions
      let lib = instrumentationLibrary "otel-link-flags" "1"
          tr = makeTracer trProv lib tracerOptions
      spanTid <- either (fail . show) pure $ bytesToTraceId $ BS.replicate 16 8
      spanSid <- either (fail . show) pure $ bytesToSpanId $ BS.replicate 8 9
      linkTid <- either (fail . show) pure $ bytesToTraceId $ BS.replicate 16 10
      linkSid <- either (fail . show) pure $ bytesToSpanId $ BS.replicate 8 11
      let spanCtx =
            SpanContext
              { traceFlags = defaultTraceFlags
              , isRemote = False
              , traceId = spanTid
              , spanId = spanSid
              , traceState = TS.empty
              }
          linkCtx =
            SpanContext
              { traceFlags = setSampled defaultTraceFlags
              , isRemote = False
              , traceId = linkTid
              , spanId = linkSid
              , traceState = TS.empty
              }
          lnk = Link {frozenLinkContext = linkCtx, frozenLinkAttributes = emptyAttributes}
          links = appendToBoundedCollection (emptyAppendOnlyBoundedCollection 8) lnk
      hotRef <-
        newIORef $
          SpanHot
            { hotName = "with-link-flags"
            , hotEnd = NoTimestamp
            , hotAttributes = emptyAttributes
            , hotLinks = links
            , hotEvents = emptyAppendOnlyBoundedCollection 16
            , hotStatus = Unset
            }
      let imm =
            ImmutableSpan
              { spanContext = spanCtx
              , spanKind = Internal
              , spanStart = mkTimestamp 0 0
              , spanParent = Nothing
              , spanTracer = tr
              , spanHot = hotRef
              }
      exportReq <- immutableSpansToProtobuf $ H.singleton lib (V.singleton imm)
      case decodeMessage (encodeMessage exportReq) :: Either String ExportTraceServiceRequest of
        Left err -> expectationFailure err
        Right roundTrip -> case firstOtlpSpan roundTrip of
          Nothing -> expectationFailure "expected span"
          Just sp -> do
            let ls = sp ^. Trace_Fields.vec'links
            V.length ls `shouldBe` 1
            case ls V.!? 0 of
              Nothing -> expectationFailure "expected link"
              Just lk -> lk ^. Trace_Fields.flags `shouldBe` 0x101

  describe "loadExporterEnvironmentVariables" $ do
    -- OTLP exporter configuration (environment variables)
    -- https://opentelemetry.io/docs/specs/otel/protocol/exporter/#configuration-options
    it "reads OTEL_EXPORTER_OTLP_ENDPOINT" $
      bracketUnset otlpEnvKeys $ \_ -> do
        setEnv "OTEL_EXPORTER_OTLP_ENDPOINT" "http://collector:4318"
        cfg <- loadExporterEnvironmentVariables
        otlpEndpoint cfg `shouldBe` Just "http://collector:4318"

    -- OTLP exporter configuration (environment variables)
    -- https://opentelemetry.io/docs/specs/otel/protocol/exporter/#configuration-options
    it "defaults Maybe fields to Nothing when OTLP env vars are unset" $
      bracketUnset otlpEnvKeys $ \_ -> do
        cfg <- loadExporterEnvironmentVariables
        otlpEndpoint cfg `shouldBe` Nothing
        otlpTracesEndpoint cfg `shouldBe` Nothing
        otlpMetricsEndpoint cfg `shouldBe` Nothing
        otlpCertificate cfg `shouldBe` Nothing
        case otlpCompression cfg of
          Nothing -> pure ()
          Just _ -> expectationFailure "expected otlpCompression Nothing"
        otlpTimeout cfg `shouldBe` Nothing
        case otlpProtocol cfg of
          Nothing -> pure ()
          Just _ -> expectationFailure "expected otlpProtocol Nothing"

    -- OTLP exporter configuration (environment variables)
    -- https://opentelemetry.io/docs/specs/otel/protocol/exporter/#configuration-options
    it "reads OTEL_EXPORTER_OTLP_COMPRESSION=gzip as GZip" $
      bracketUnset otlpEnvKeys $ \_ -> do
        setEnv "OTEL_EXPORTER_OTLP_COMPRESSION" "gzip"
        cfg <- loadExporterEnvironmentVariables
        case otlpCompression cfg of
          Just GZip -> pure ()
          _ -> expectationFailure "expected Just GZip"

    -- OTLP exporter configuration (environment variables)
    -- https://opentelemetry.io/docs/specs/otel/protocol/exporter/#configuration-options
    it "reads OTEL_EXPORTER_OTLP_TIMEOUT" $
      bracketUnset otlpEnvKeys $ \_ -> do
        setEnv "OTEL_EXPORTER_OTLP_TIMEOUT" "5000"
        cfg <- loadExporterEnvironmentVariables
        otlpTimeout cfg `shouldBe` Just 5000

    -- OTLP exporter configuration (environment variables)
    -- https://opentelemetry.io/docs/specs/otel/protocol/exporter/#configuration-options
    it "reads OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf" $
      bracketUnset otlpEnvKeys $ \_ -> do
        setEnv "OTEL_EXPORTER_OTLP_PROTOCOL" "http/protobuf"
        cfg <- loadExporterEnvironmentVariables
        case otlpProtocol cfg of
          Just HttpProtobuf -> pure ()
          _ -> expectationFailure "expected Just HttpProtobuf"

    -- OTLP exporter configuration (environment variables)
    -- https://opentelemetry.io/docs/specs/otel/protocol/exporter/#configuration-options
    it "reads OTEL_EXPORTER_OTLP_LOGS_ENDPOINT" $
      bracketUnset otlpEnvKeys $ \_ -> do
        setEnv "OTEL_EXPORTER_OTLP_LOGS_ENDPOINT" "http://logs-collector:4318/v1/logs"
        cfg <- loadExporterEnvironmentVariables
        otlpLogsEndpoint cfg `shouldBe` Just "http://logs-collector:4318/v1/logs"

    -- OTLP exporter configuration (environment variables)
    -- https://opentelemetry.io/docs/specs/otel/protocol/exporter/#configuration-options
    it "reads OTEL_EXPORTER_OTLP_LOGS_TIMEOUT" $
      bracketUnset otlpEnvKeys $ \_ -> do
        setEnv "OTEL_EXPORTER_OTLP_LOGS_TIMEOUT" "8000"
        cfg <- loadExporterEnvironmentVariables
        otlpLogsTimeout cfg `shouldBe` Just 8000

    -- OTLP exporter configuration (environment variables)
    -- https://opentelemetry.io/docs/specs/otel/protocol/exporter/#configuration-options
    it "reads OTEL_EXPORTER_OTLP_LOGS_COMPRESSION=gzip" $
      bracketUnset otlpEnvKeys $ \_ -> do
        setEnv "OTEL_EXPORTER_OTLP_LOGS_COMPRESSION" "gzip"
        cfg <- loadExporterEnvironmentVariables
        case otlpLogsCompression cfg of
          Just GZip -> pure ()
          _ -> expectationFailure "expected Just GZip"

    -- OTLP exporter configuration (environment variables)
    -- https://opentelemetry.io/docs/specs/otel/protocol/exporter/#configuration-options
    it "reads OTEL_EXPORTER_OTLP_TRACES_INSECURE (standard name)" $
      bracketUnset otlpEnvKeys $ \_ -> do
        setEnv "OTEL_EXPORTER_OTLP_TRACES_INSECURE" "true"
        cfg <- loadExporterEnvironmentVariables
        otlpTracesInsecure cfg `shouldBe` True

    -- OTLP exporter configuration (environment variables)
    -- https://opentelemetry.io/docs/specs/otel/protocol/exporter/#configuration-options
    it "falls back to OTEL_EXPORTER_OTLP_SPAN_INSECURE (legacy name)" $
      bracketUnset otlpEnvKeys $ \_ -> do
        setEnv "OTEL_EXPORTER_OTLP_SPAN_INSECURE" "true"
        cfg <- loadExporterEnvironmentVariables
        otlpTracesInsecure cfg `shouldBe` True

    -- OTLP exporter configuration (environment variables)
    -- https://opentelemetry.io/docs/specs/otel/protocol/exporter/#configuration-options
    it "defaults logs fields to Nothing/False when unset" $
      bracketUnset otlpEnvKeys $ \_ -> do
        cfg <- loadExporterEnvironmentVariables
        otlpLogsEndpoint cfg `shouldBe` Nothing
        otlpLogsInsecure cfg `shouldBe` False
        otlpLogsCertificate cfg `shouldBe` Nothing
        otlpLogsHeaders cfg `shouldBe` Nothing
        otlpLogsTimeout cfg `shouldBe` Nothing

  describe "isRetryableHttpStatus" $ do
    -- OTLP exporter transient errors / retry
    -- https://opentelemetry.io/docs/specs/otel/protocol/exporter/#retry
    it "returns True for 429, 502, 503, and 504" $ do
      isRetryableHttpStatus status429 `shouldBe` True
      isRetryableHttpStatus status502 `shouldBe` True
      isRetryableHttpStatus status503 `shouldBe` True
      isRetryableHttpStatus status504 `shouldBe` True

    -- OTLP exporter transient errors / retry
    -- https://opentelemetry.io/docs/specs/otel/protocol/exporter/#retry
    it "returns False for 200, 400, 401, 500, and 501" $ do
      isRetryableHttpStatus status200 `shouldBe` False
      isRetryableHttpStatus status400 `shouldBe` False
      isRetryableHttpStatus status401 `shouldBe` False
      isRetryableHttpStatus status500 `shouldBe` False
      isRetryableHttpStatus status501 `shouldBe` False

    -- OTLP Exporter §Retry: "The following are retryable: 429, 502, 503, 504."
    -- 408 (Request Timeout) is NOT in the retryable list.
    -- https://opentelemetry.io/docs/specs/otel/protocol/exporter/#retry
    it "returns False for 408 (not in OTLP retryable list)" $ do
      isRetryableHttpStatus (mkStatus 408 "Request Timeout") `shouldBe` False

  describe "httpSignalEndpointUrl" $ do
    -- OTLP exporter endpoint URL resolution
    -- https://opentelemetry.io/docs/specs/otel/protocol/exporter/#endpoint-urls
    it "uses per-signal endpoint verbatim when set" $ do
      let url = "http://custom-collector:4318/v1/traces"
      httpSignalEndpointUrl (Just url) emptyOtlpExporterConfig "/v1/traces"
        `shouldBe` url

    -- OTLP exporter endpoint URL resolution
    -- https://opentelemetry.io/docs/specs/otel/protocol/exporter/#endpoint-urls
    it "defaults base to http://localhost:4318 when endpoint is unset" $ do
      httpSignalEndpointUrl Nothing emptyOtlpExporterConfig "/v1/traces"
        `shouldBe` "http://localhost:4318/v1/traces"

    -- OTLP exporter endpoint URL resolution
    -- https://opentelemetry.io/docs/specs/otel/protocol/exporter/#endpoint-urls
    it "appends signal path to configured base without a trailing slash" $ do
      let conf = emptyOtlpExporterConfig {otlpEndpoint = Just "http://example.com:4318"}
      httpSignalEndpointUrl Nothing conf "/v1/traces"
        `shouldBe` "http://example.com:4318/v1/traces"

    -- OTLP exporter endpoint URL resolution
    -- https://opentelemetry.io/docs/specs/otel/protocol/exporter/#endpoint-urls
    it "normalizes a trailing slash on the base before appending the signal path" $ do
      let conf = emptyOtlpExporterConfig {otlpEndpoint = Just "http://example.com:4318/"}
      httpSignalEndpointUrl Nothing conf "/v1/traces"
        `shouldBe` "http://example.com:4318/v1/traces"

    -- OTLP Exporter configuration: per-signal endpoint overrides generic endpoint
    -- for all transports including gRPC (same resolution as
    -- "OpenTelemetry.Exporter.OTLP.GRPC", which re-exports these helpers from
    -- "OpenTelemetry.Exporter.OTLP.Internal.Config" when the grpc package flag is on).
    -- https://opentelemetry.io/docs/specs/otel/protocol/exporter/#endpoint-urls
    it "gRPC traces endpoint uses per-signal override" $ do
      let conf =
            emptyOtlpExporterConfig
              { otlpTracesEndpoint = Just "http://traces-collector:4317"
              }
      grpcTracesEndpoint conf `shouldBe` "http://traces-collector:4317"

    -- OTLP exporter endpoint URL resolution
    -- https://opentelemetry.io/docs/specs/otel/protocol/exporter/#endpoint-urls
    it "gRPC traces endpoint falls back to generic" $ do
      let conf =
            emptyOtlpExporterConfig
              { otlpEndpoint = Just "http://generic-collector:4317"
              }
      grpcTracesEndpoint conf `shouldBe` "http://generic-collector:4317"

    -- OTLP exporter endpoint URL resolution
    -- https://opentelemetry.io/docs/specs/otel/protocol/exporter/#endpoint-urls
    it "gRPC traces endpoint defaults to localhost:4317" $ do
      grpcTracesEndpoint emptyOtlpExporterConfig `shouldBe` "http://localhost:4317"

    -- OTLP exporter endpoint URL resolution
    -- https://opentelemetry.io/docs/specs/otel/protocol/exporter/#endpoint-urls
    it "gRPC metrics endpoint uses per-signal override" $ do
      let conf =
            emptyOtlpExporterConfig
              { otlpMetricsEndpoint = Just "http://metrics-collector:4317"
              }
      grpcMetricsEndpoint conf `shouldBe` "http://metrics-collector:4317"

    -- OTLP exporter endpoint URL resolution
    -- https://opentelemetry.io/docs/specs/otel/protocol/exporter/#endpoint-urls
    it "gRPC logs endpoint uses per-signal override" $ do
      let conf =
            emptyOtlpExporterConfig
              { otlpLogsEndpoint = Just "http://logs-collector:4317"
              }
      grpcLogsEndpoint conf `shouldBe` "http://logs-collector:4317"

  describe "readCompressionFormat" $ do
    -- OTLP exporter compression configuration
    -- https://opentelemetry.io/docs/specs/otel/protocol/exporter/
    it "parses gzip as GZip" $ do
      x <- readCompressionFormat "gzip" :: IO CompressionFormat
      case x of
        GZip -> pure ()
        None -> expectationFailure "expected GZip"

    -- OTLP exporter compression configuration
    -- https://opentelemetry.io/docs/specs/otel/protocol/exporter/
    it "parses none as None" $ do
      x <- readCompressionFormat "none" :: IO CompressionFormat
      case x of
        None -> pure ()
        GZip -> expectationFailure "expected None"

    -- OTLP exporter compression configuration
    -- https://opentelemetry.io/docs/specs/otel/protocol/exporter/
    it "parses GZIP case-insensitively as GZip" $ do
      x <- readCompressionFormat "GZIP" :: IO CompressionFormat
      case x of
        GZip -> pure ()
        None -> expectationFailure "expected GZip"

    -- OTLP exporter compression configuration
    -- https://opentelemetry.io/docs/specs/otel/protocol/exporter/
    it "maps unknown values to None" $ do
      x <- readCompressionFormat "unknown" :: IO CompressionFormat
      case x of
        None -> pure ()
        GZip -> expectationFailure "expected None"

  describe "readProtocol" $ do
    -- OTLP exporter protocol configuration
    -- https://opentelemetry.io/docs/specs/otel/protocol/exporter/
    it "parses http/protobuf as HttpProtobuf" $ do
      p <- readProtocol "http/protobuf" :: IO Protocol
      case p of
        HttpProtobuf -> pure ()
        _ -> expectationFailure "expected HttpProtobuf"

    -- OTLP exporter protocol configuration
    -- https://opentelemetry.io/docs/specs/otel/protocol/exporter/
    it "parses HTTP/PROTOBUF case-insensitively as HttpProtobuf" $ do
      p <- readProtocol "HTTP/PROTOBUF" :: IO Protocol
      case p of
        HttpProtobuf -> pure ()
        _ -> expectationFailure "expected HttpProtobuf"

    -- OTLP exporter protocol configuration
    -- https://opentelemetry.io/docs/specs/otel/protocol/exporter/
    it "defaults unknown values to HttpProtobuf" $ do
      p <- readProtocol "unknown" :: IO Protocol
      case p of
        HttpProtobuf -> pure ()
        _ -> expectationFailure "expected HttpProtobuf"

  describe "readTimeout" $ do
    -- OTLP exporter timeout configuration
    -- https://opentelemetry.io/docs/specs/otel/protocol/exporter/#otlp-exporter-timeout
    it "parses a non-negative integer" $ do
      t <- readTimeout "5000" :: IO Int
      t `shouldBe` 5000

    -- OTLP exporter timeout configuration
    -- https://opentelemetry.io/docs/specs/otel/protocol/exporter/#otlp-exporter-timeout
    it "uses defaultExporterTimeout for negative values" $ do
      t <- readTimeout "-1" :: IO Int
      t `shouldBe` defaultExporterTimeout

    -- OTLP exporter timeout configuration
    -- https://opentelemetry.io/docs/specs/otel/protocol/exporter/#otlp-exporter-timeout
    it "uses defaultExporterTimeout for non-numeric input" $ do
      t <- readTimeout "abc" :: IO Int
      t `shouldBe` defaultExporterTimeout

    -- OTLP exporter timeout configuration
    -- https://opentelemetry.io/docs/specs/otel/protocol/exporter/#otlp-exporter-timeout
    it "allows zero" $ do
      t <- readTimeout "0" :: IO Int
      t `shouldBe` 0

  describe "Partial success response decoding" $ do
    -- OTLP Export[Traces|Metrics]Response partial success
    -- https://opentelemetry.io/docs/specs/otlp/#full-success-1
    it "ExportTraceServiceResponse round-trips partial_success with rejected spans" $ do
      let ps =
            defMessage
              & TSF.rejectedSpans .~ 5
              & TSF.errorMessage .~ "quota exceeded"
          resp = defMessage & TSF.partialSuccess .~ ps :: ExportTraceServiceResponse
          encoded = encodeMessage resp
      case decodeMessage encoded :: Either String ExportTraceServiceResponse of
        Left e -> expectationFailure e
        Right decoded -> do
          let dps = decoded ^. TSF.partialSuccess
          dps ^. TSF.rejectedSpans `shouldBe` 5
          dps ^. TSF.errorMessage `shouldBe` "quota exceeded"

    -- OTLP Export[Traces|Metrics]Response partial success
    -- https://opentelemetry.io/docs/specs/otlp/#full-success-1
    it "ExportTraceServiceResponse with no partial_success has zero rejected spans" $ do
      let resp = defMessage :: ExportTraceServiceResponse
          encoded = encodeMessage resp
      case decodeMessage encoded :: Either String ExportTraceServiceResponse of
        Left e -> expectationFailure e
        Right decoded -> do
          let dps = decoded ^. TSF.partialSuccess
          dps ^. TSF.rejectedSpans `shouldBe` 0
          dps ^. TSF.errorMessage `shouldBe` ""

    -- OTLP Export[Traces|Metrics]Response partial success
    -- https://opentelemetry.io/docs/specs/otlp/#full-success-1
    it "ExportMetricsServiceResponse round-trips partial_success with rejected data points" $ do
      let ps =
            defMessage
              & MSF.rejectedDataPoints .~ 42
              & MSF.errorMessage .~ "rate limited"
          resp = defMessage & MSF.partialSuccess .~ ps :: ExportMetricsServiceResponse
          encoded = encodeMessage resp
      case decodeMessage encoded :: Either String ExportMetricsServiceResponse of
        Left e -> expectationFailure e
        Right decoded -> do
          let dps = decoded ^. MSF.partialSuccess
          dps ^. MSF.rejectedDataPoints `shouldBe` 42
          dps ^. MSF.errorMessage `shouldBe` "rate limited"


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


firstOtlpSpan :: ExportTraceServiceRequest -> Maybe Span
firstOtlpSpan req = do
  rs <- (req ^. TSF.vec'resourceSpans) V.!? 0
  ss <- (rs ^. Trace_Fields.vec'scopeSpans) V.!? 0
  (ss ^. Trace_Fields.vec'spans) V.!? 0


emptyOtlpExporterConfig :: OTLPExporterConfig
emptyOtlpExporterConfig =
  OTLPExporterConfig
    { otlpEndpoint = Nothing
    , otlpTracesEndpoint = Nothing
    , otlpMetricsEndpoint = Nothing
    , otlpLogsEndpoint = Nothing
    , otlpInsecure = False
    , otlpTracesInsecure = False
    , otlpMetricsInsecure = False
    , otlpLogsInsecure = False
    , otlpCertificate = Nothing
    , otlpTracesCertificate = Nothing
    , otlpMetricsCertificate = Nothing
    , otlpLogsCertificate = Nothing
    , otlpHeaders = Nothing
    , otlpTracesHeaders = Nothing
    , otlpMetricsHeaders = Nothing
    , otlpLogsHeaders = Nothing
    , otlpCompression = Nothing
    , otlpTracesCompression = Nothing
    , otlpMetricsCompression = Nothing
    , otlpLogsCompression = Nothing
    , otlpTimeout = Nothing
    , otlpTracesTimeout = Nothing
    , otlpMetricsTimeout = Nothing
    , otlpLogsTimeout = Nothing
    , otlpProtocol = Nothing
    , otlpTracesProtocol = Nothing
    , otlpMetricsProtocol = Nothing
    , otlpLogsProtocol = Nothing
    , otlpConcurrentExports = 1
    }


otlpEnvKeys :: [String]
otlpEnvKeys =
  [ "OTEL_EXPORTER_OTLP_ENDPOINT"
  , "OTEL_EXPORTER_OTLP_TRACES_ENDPOINT"
  , "OTEL_EXPORTER_OTLP_METRICS_ENDPOINT"
  , "OTEL_EXPORTER_OTLP_LOGS_ENDPOINT"
  , "OTEL_EXPORTER_OTLP_INSECURE"
  , "OTEL_EXPORTER_OTLP_TRACES_INSECURE"
  , "OTEL_EXPORTER_OTLP_SPAN_INSECURE"
  , "OTEL_EXPORTER_OTLP_METRICS_INSECURE"
  , "OTEL_EXPORTER_OTLP_METRIC_INSECURE"
  , "OTEL_EXPORTER_OTLP_LOGS_INSECURE"
  , "OTEL_EXPORTER_OTLP_CERTIFICATE"
  , "OTEL_EXPORTER_OTLP_TRACES_CERTIFICATE"
  , "OTEL_EXPORTER_OTLP_METRICS_CERTIFICATE"
  , "OTEL_EXPORTER_OTLP_LOGS_CERTIFICATE"
  , "OTEL_EXPORTER_OTLP_HEADERS"
  , "OTEL_EXPORTER_OTLP_TRACES_HEADERS"
  , "OTEL_EXPORTER_OTLP_METRICS_HEADERS"
  , "OTEL_EXPORTER_OTLP_LOGS_HEADERS"
  , "OTEL_EXPORTER_OTLP_COMPRESSION"
  , "OTEL_EXPORTER_OTLP_TRACES_COMPRESSION"
  , "OTEL_EXPORTER_OTLP_METRICS_COMPRESSION"
  , "OTEL_EXPORTER_OTLP_LOGS_COMPRESSION"
  , "OTEL_EXPORTER_OTLP_TIMEOUT"
  , "OTEL_EXPORTER_OTLP_TRACES_TIMEOUT"
  , "OTEL_EXPORTER_OTLP_METRICS_TIMEOUT"
  , "OTEL_EXPORTER_OTLP_LOGS_TIMEOUT"
  , "OTEL_EXPORTER_OTLP_PROTOCOL"
  , "OTEL_EXPORTER_OTLP_TRACES_PROTOCOL"
  , "OTEL_EXPORTER_OTLP_METRICS_PROTOCOL"
  , "OTEL_EXPORTER_OTLP_LOGS_PROTOCOL"
  ]


bracketUnset :: [String] -> ([(String, Maybe String)] -> IO a) -> IO a
bracketUnset keys act =
  bracket
    ( do
        saved <- mapM (\k -> (,) k <$> lookupEnv k) keys
        mapM_ unsetEnv keys
        pure saved
    )
    (mapM_ restore)
    act
  where
    restore (k, Nothing) = unsetEnv k
    restore (k, Just v) = setEnv k v
