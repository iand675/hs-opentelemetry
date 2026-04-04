{-# LANGUAGE OverloadedStrings #-}

import Control.Exception (bracket)
import qualified Data.ByteString as BS
import qualified Data.HashMap.Strict as H
import Data.IORef (newIORef)
import Data.Int (Int64)
import Data.ProtoLens (decodeMessage, encodeMessage)
import Data.Text (Text)
import qualified Data.Vector as V
import qualified Data.Vector.Unboxed as U
import Data.Word (Word64)
import Lens.Micro ((^.))
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
import OpenTelemetry.Exporter.OTLP.LogRecord (immutableLogRecordToProto)
import OpenTelemetry.Exporter.OTLP.Metric (resourceMetricsToExportRequest)
import OpenTelemetry.Exporter.OTLP.Span (
  CompressionFormat (..),
  OTLPExporterConfig (..),
  Protocol (..),
  immutableSpansToProtobuf,
  loadExporterEnvironmentVariables,
 )
import OpenTelemetry.Internal.Common.Types (InstrumentationLibrary (..))
import qualified OpenTelemetry.Internal.Logs.Types as IL
import OpenTelemetry.LogAttributes (AnyValue (..), unsafeLogAttributesFromListIgnoringLimits)
import OpenTelemetry.Resource (emptyMaterializedResources)
import OpenTelemetry.Trace.Core (
  Event (..),
  ImmutableSpan (..),
  Link (..),
  SpanHot (..),
  SpanContext (..),
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
import Proto.Opentelemetry.Proto.Collector.Metrics.V1.MetricsService (ExportMetricsServiceRequest)
import qualified Proto.Opentelemetry.Proto.Collector.Metrics.V1.MetricsService_Fields as MSF
import Proto.Opentelemetry.Proto.Collector.Trace.V1.TraceService (ExportTraceServiceRequest)
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
decodeExport rms = decodeMessage (encodeMessage (resourceMetricsToExportRequest rms))


main :: IO ()
main = hspec $ sequential $ do
  describe "resourceMetricsToExportRequest" $ do
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

    it "encodes severity number" $ do
      let lr =
            IL.ImmutableLogRecord
              { IL.logRecordTimestamp = Nothing
              , IL.logRecordObservedTimestamp = obsTs
              , IL.logRecordTracingDetails = Nothing
              , IL.logRecordSeverityText = Nothing
              , IL.logRecordSeverityNumber = Just IL.Info
              , IL.logRecordBody = NullValue
              , IL.logRecordAttributes = emptyLogAttrs
              , IL.logRecordEventName = Nothing
              }
          proto = immutableLogRecordToProto lr
      proto ^. LF.severityNumber `shouldBe` PL.SEVERITY_NUMBER_INFO

    it "encodes severity text" $ do
      let lr =
            IL.ImmutableLogRecord
              { IL.logRecordTimestamp = Nothing
              , IL.logRecordObservedTimestamp = obsTs
              , IL.logRecordTracingDetails = Nothing
              , IL.logRecordSeverityText = Just "INFO"
              , IL.logRecordSeverityNumber = Nothing
              , IL.logRecordBody = NullValue
              , IL.logRecordAttributes = emptyLogAttrs
              , IL.logRecordEventName = Nothing
              }
          proto = immutableLogRecordToProto lr
      proto ^. LF.severityText `shouldBe` "INFO"

    it "encodes body text value" $ do
      let lr =
            IL.ImmutableLogRecord
              { IL.logRecordTimestamp = Nothing
              , IL.logRecordObservedTimestamp = obsTs
              , IL.logRecordTracingDetails = Nothing
              , IL.logRecordSeverityText = Nothing
              , IL.logRecordSeverityNumber = Nothing
              , IL.logRecordBody = TextValue "hello"
              , IL.logRecordAttributes = emptyLogAttrs
              , IL.logRecordEventName = Nothing
              }
          proto = immutableLogRecordToProto lr
      case proto ^. LF.maybe'body of
        Nothing -> expectationFailure "body"
        Just b -> b ^. CF.stringValue `shouldBe` "hello"

    it "encodes trace context" $ do
      tid <- either (fail . show) pure $ bytesToTraceId $ BS.replicate 16 9
      sid <- either (fail . show) pure $ bytesToSpanId $ BS.replicate 8 8
      let flags :: TraceFlags
          flags = setSampled defaultTraceFlags
          lr =
            IL.ImmutableLogRecord
              { IL.logRecordTimestamp = Nothing
              , IL.logRecordObservedTimestamp = obsTs
              , IL.logRecordTracingDetails = Just (tid, sid, flags)
              , IL.logRecordSeverityText = Nothing
              , IL.logRecordSeverityNumber = Nothing
              , IL.logRecordBody = NullValue
              , IL.logRecordAttributes = emptyLogAttrs
              , IL.logRecordEventName = Nothing
              }
          proto = immutableLogRecordToProto lr
      proto ^. LF.traceId `shouldBe` traceIdBytes tid
      proto ^. LF.spanId `shouldBe` spanIdBytes sid
      proto ^. LF.flags `shouldBe` fromIntegral (traceFlagsValue flags)

    it "encodes event name" $ do
      let lr =
            IL.ImmutableLogRecord
              { IL.logRecordTimestamp = Nothing
              , IL.logRecordObservedTimestamp = obsTs
              , IL.logRecordTracingDetails = Nothing
              , IL.logRecordSeverityText = Nothing
              , IL.logRecordSeverityNumber = Nothing
              , IL.logRecordBody = NullValue
              , IL.logRecordAttributes = emptyLogAttrs
              , IL.logRecordEventName = Just "my.event"
              }
          proto = immutableLogRecordToProto lr
      proto ^. LF.eventName `shouldBe` "my.event"

    it "encodes attributes" $ do
      let lr =
            IL.ImmutableLogRecord
              { IL.logRecordTimestamp = Nothing
              , IL.logRecordObservedTimestamp = obsTs
              , IL.logRecordTracingDetails = Nothing
              , IL.logRecordSeverityText = Nothing
              , IL.logRecordSeverityNumber = Nothing
              , IL.logRecordBody = NullValue
              , IL.logRecordAttributes = attrs
              , IL.logRecordEventName = Nothing
              }
          proto = immutableLogRecordToProto lr
      V.length (proto ^. LF.vec'attributes) `shouldNotBe` 0

    it "handles Unknown severity gracefully" $ do
      let lr =
            IL.ImmutableLogRecord
              { IL.logRecordTimestamp = Nothing
              , IL.logRecordObservedTimestamp = obsTs
              , IL.logRecordTracingDetails = Nothing
              , IL.logRecordSeverityText = Nothing
              , IL.logRecordSeverityNumber = Just (IL.Unknown 99)
              , IL.logRecordBody = NullValue
              , IL.logRecordAttributes = emptyLogAttrs
              , IL.logRecordEventName = Nothing
              }
          proto = immutableLogRecordToProto lr
      proto ^. LF.severityNumber `shouldBe` PL.SEVERITY_NUMBER_UNSPECIFIED

    it "round-trips through protobuf encode/decode" $ do
      let lr =
            IL.ImmutableLogRecord
              { IL.logRecordTimestamp = Just (mkTimestamp 1 2)
              , IL.logRecordObservedTimestamp = obsTs
              , IL.logRecordTracingDetails = Nothing
              , IL.logRecordSeverityText = Just "WARN"
              , IL.logRecordSeverityNumber = Just IL.Warn
              , IL.logRecordBody = TextValue "round"
              , IL.logRecordAttributes = attrs
              , IL.logRecordEventName = Just "e"
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

    it "encodes array body value" $ do
      let lr =
            IL.ImmutableLogRecord
              { IL.logRecordTimestamp = Nothing
              , IL.logRecordObservedTimestamp = obsTs
              , IL.logRecordTracingDetails = Nothing
              , IL.logRecordSeverityText = Nothing
              , IL.logRecordSeverityNumber = Nothing
              , IL.logRecordBody = ArrayValue [TextValue "a", TextValue "b"]
              , IL.logRecordAttributes = emptyLogAttrs
              , IL.logRecordEventName = Nothing
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

    it "encodes map body value" $ do
      let lr =
            IL.ImmutableLogRecord
              { IL.logRecordTimestamp = Nothing
              , IL.logRecordObservedTimestamp = obsTs
              , IL.logRecordTracingDetails = Nothing
              , IL.logRecordSeverityText = Nothing
              , IL.logRecordSeverityNumber = Nothing
              , IL.logRecordBody = HashMapValue (H.singleton "k1" (TextValue "v1"))
              , IL.logRecordAttributes = emptyLogAttrs
              , IL.logRecordEventName = Nothing
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
            { IL.logRecordTimestamp = Nothing
            , IL.logRecordObservedTimestamp = obsTs
            , IL.logRecordTracingDetails = Nothing
            , IL.logRecordSeverityText = Nothing
            , IL.logRecordSeverityNumber = Just sev
            , IL.logRecordBody = NullValue
            , IL.logRecordAttributes = emptyLogAttrs
            , IL.logRecordEventName = Nothing
            }

    it "maps Trace severity" $ do
      let proto = immutableLogRecordToProto (mkLr IL.Trace)
      proto ^. LF.severityNumber `shouldBe` PL.SEVERITY_NUMBER_TRACE

    it "maps Debug severity" $ do
      let proto = immutableLogRecordToProto (mkLr IL.Debug)
      proto ^. LF.severityNumber `shouldBe` PL.SEVERITY_NUMBER_DEBUG

    it "maps Warn severity" $ do
      let proto = immutableLogRecordToProto (mkLr IL.Warn)
      proto ^. LF.severityNumber `shouldBe` PL.SEVERITY_NUMBER_WARN

    it "maps Error severity" $ do
      let proto = immutableLogRecordToProto (mkLr IL.Error)
      proto ^. LF.severityNumber `shouldBe` PL.SEVERITY_NUMBER_ERROR

    it "maps Fatal severity" $ do
      let proto = immutableLogRecordToProto (mkLr IL.Fatal)
      proto ^. LF.severityNumber `shouldBe` PL.SEVERITY_NUMBER_FATAL

  describe "immutableSpansToProtobuf" $ do
    describe "immutableSpansToProtobuf edge cases" $ do
      it "empty span map produces valid empty request" $ do
        exportReq <- immutableSpansToProtobuf H.empty
        case decodeMessage (encodeMessage exportReq) :: Either String ExportTraceServiceRequest of
          Left err -> expectationFailure err
          Right r -> case (r ^. TSF.vec'resourceSpans) V.!? 0 of
            Nothing -> expectationFailure "expected resourceSpans"
            Just rs -> rs ^. Trace_Fields.vec'scopeSpans `shouldSatisfy` V.null

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
        hotRef <- newIORef $ SpanHot
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
        hotRef <- newIORef $ SpanHot
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
      hotRef <- newIORef $ SpanHot
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
      hotRef <- newIORef $ SpanHot
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
      hotRef <- newIORef $ SpanHot
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

    it "sets link flags to sampled (1) when frozenLinkContext uses setSampled defaultTraceFlags" $ do
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
      hotRef <- newIORef $ SpanHot
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
              Just lk -> lk ^. Trace_Fields.flags `shouldBe` 1

  describe "loadExporterEnvironmentVariables" $ do
    it "reads OTEL_EXPORTER_OTLP_ENDPOINT" $
      bracketUnset otlpEnvKeys $ \_ -> do
        setEnv "OTEL_EXPORTER_OTLP_ENDPOINT" "http://collector:4318"
        cfg <- loadExporterEnvironmentVariables
        otlpEndpoint cfg `shouldBe` Just "http://collector:4318"

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

    it "reads OTEL_EXPORTER_OTLP_COMPRESSION=gzip as GZip" $
      bracketUnset otlpEnvKeys $ \_ -> do
        setEnv "OTEL_EXPORTER_OTLP_COMPRESSION" "gzip"
        cfg <- loadExporterEnvironmentVariables
        case otlpCompression cfg of
          Just GZip -> pure ()
          _ -> expectationFailure "expected Just GZip"

    it "reads OTEL_EXPORTER_OTLP_TIMEOUT" $
      bracketUnset otlpEnvKeys $ \_ -> do
        setEnv "OTEL_EXPORTER_OTLP_TIMEOUT" "5000"
        cfg <- loadExporterEnvironmentVariables
        otlpTimeout cfg `shouldBe` Just 5000

    it "reads OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf" $
      bracketUnset otlpEnvKeys $ \_ -> do
        setEnv "OTEL_EXPORTER_OTLP_PROTOCOL" "http/protobuf"
        cfg <- loadExporterEnvironmentVariables
        case otlpProtocol cfg of
          Just HttpProtobuf -> pure ()
          _ -> expectationFailure "expected Just HttpProtobuf"

    it "reads OTEL_EXPORTER_OTLP_LOGS_ENDPOINT" $
      bracketUnset otlpEnvKeys $ \_ -> do
        setEnv "OTEL_EXPORTER_OTLP_LOGS_ENDPOINT" "http://logs-collector:4318/v1/logs"
        cfg <- loadExporterEnvironmentVariables
        otlpLogsEndpoint cfg `shouldBe` Just "http://logs-collector:4318/v1/logs"

    it "reads OTEL_EXPORTER_OTLP_LOGS_TIMEOUT" $
      bracketUnset otlpEnvKeys $ \_ -> do
        setEnv "OTEL_EXPORTER_OTLP_LOGS_TIMEOUT" "8000"
        cfg <- loadExporterEnvironmentVariables
        otlpLogsTimeout cfg `shouldBe` Just 8000

    it "reads OTEL_EXPORTER_OTLP_LOGS_COMPRESSION=gzip" $
      bracketUnset otlpEnvKeys $ \_ -> do
        setEnv "OTEL_EXPORTER_OTLP_LOGS_COMPRESSION" "gzip"
        cfg <- loadExporterEnvironmentVariables
        case otlpLogsCompression cfg of
          Just GZip -> pure ()
          _ -> expectationFailure "expected Just GZip"

    it "reads OTEL_EXPORTER_OTLP_TRACES_INSECURE (standard name)" $
      bracketUnset otlpEnvKeys $ \_ -> do
        setEnv "OTEL_EXPORTER_OTLP_TRACES_INSECURE" "true"
        cfg <- loadExporterEnvironmentVariables
        otlpTracesInsecure cfg `shouldBe` True

    it "falls back to OTEL_EXPORTER_OTLP_SPAN_INSECURE (legacy name)" $
      bracketUnset otlpEnvKeys $ \_ -> do
        setEnv "OTEL_EXPORTER_OTLP_SPAN_INSECURE" "true"
        cfg <- loadExporterEnvironmentVariables
        otlpTracesInsecure cfg `shouldBe` True

    it "defaults logs fields to Nothing/False when unset" $
      bracketUnset otlpEnvKeys $ \_ -> do
        cfg <- loadExporterEnvironmentVariables
        otlpLogsEndpoint cfg `shouldBe` Nothing
        otlpLogsInsecure cfg `shouldBe` False
        otlpLogsCertificate cfg `shouldBe` Nothing
        otlpLogsHeaders cfg `shouldBe` Nothing
        otlpLogsTimeout cfg `shouldBe` Nothing


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
