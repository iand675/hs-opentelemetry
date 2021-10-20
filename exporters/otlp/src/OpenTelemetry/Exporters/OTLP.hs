{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE RecordWildCards #-}
module OpenTelemetry.Exporters.OTLP where

import Data.ByteString.Char8
import Data.Text (Text)
import Data.ProtoLens.Encoding
import Data.ProtoLens.Message
import qualified OpenTelemetry.Trace.SpanExporter
import System.Environment
import qualified OpenTelemetry.Trace as OT
import Proto.Opentelemetry.Proto.Trace.V1.Trace (InstrumentationLibrarySpans, ResourceSpans, Span'SpanKind (Span'SPAN_KIND_SERVER, Span'SPAN_KIND_CLIENT, Span'SPAN_KIND_PRODUCER, Span'SPAN_KIND_CONSUMER, Span'SPAN_KIND_INTERNAL), Status'StatusCode (Status'STATUS_CODE_OK, Status'STATUS_CODE_ERROR, Status'STATUS_CODE_UNSET))
import Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields
import Network.HTTP.Client
import Network.HTTP.Simple (httpBS)
import Network.HTTP.Types.Header
import OpenTelemetry.Trace.SpanExporter
import Control.Monad.IO.Class
import Data.Vector (Vector)
import Data.Maybe
import Lens.Micro
import Proto.Opentelemetry.Proto.Collector.Trace.V1.TraceService (ExportTraceServiceRequest)
import qualified Data.Vector as Vector
import OpenTelemetry.Trace.Id (traceIdBytes, spanIdBytes)
import OpenTelemetry.Resource
import Proto.Opentelemetry.Proto.Common.V1.Common
import Proto.Opentelemetry.Proto.Common.V1.Common_Fields
import System.Clock
import Data.Word
import GHC.IO (unsafeDupablePerformIO)
import Data.HashMap.Strict (HashMap)
import qualified Data.HashMap.Strict as H

data CompressionFormat = None | GZip
data Protocol = {- GRpc | HttpJson | -} HttpProtobuf
  -- ^ Note: grpc and http/json will likely be supported eventually,
  -- but not yet.

otlpExporterHttpEndpoint :: ByteString
otlpExporterHttpEndpoint = "http://localhost:4318"

otlpExporterGRpcEndpoint :: ByteString
otlpExporterGRpcEndpoint = "http://localhost:4317"


data OTLPExporterConfig = OTLPExporterConfig
  { otlpEndpoint :: Maybe String
  , otlpTracesEndpoint :: Maybe String
  , otlpMetricsEndpoint :: Maybe String
  , otlpInsecure :: Maybe Bool
  , otlpSpanInsecure :: Maybe Bool
  , otlpMetricInsecure :: Maybe Bool
  , otlpCertificate :: Maybe FilePath
  , otlpTracesCertificate :: Maybe FilePath
  , otlpMetricCertificate :: Maybe FilePath
  , otlpHeaders :: Maybe [Header]
  , otlpTracesHeaders :: Maybe [Header]
  , otlpMetricsHeaders :: Maybe [Header]
  , otlpCompression :: Maybe CompressionFormat
  , otlpTracesCompression :: Maybe CompressionFormat
  , otlpMetricsCompression :: Maybe CompressionFormat
  , otlpTimeout :: Maybe Int
  -- ^ Measured in seconds
  , otlpTracesTimeout :: Maybe Int
  , otlpMetricsTimeout :: Maybe Int
  , otlpProtocol :: Maybe Protocol
  , otlpTracesProtocol :: Maybe Protocol
  , otlpMetricsProtocol :: Maybe Protocol
  }

loadExporterEnvironmentVariables :: MonadIO m => m OTLPExporterConfig
loadExporterEnvironmentVariables = liftIO $ do
  OTLPExporterConfig <$>
    lookupEnv "OTEL_EXPORTER_OTLP_ENDPOINT" <*>
    lookupEnv "OTEL_EXPORTER_OTLP_TRACES_ENDPOINT" <*>
    lookupEnv "OTEL_EXPORTER_OTLP_METRICS_ENDPOINT" <*>
    (fmap (== "true") <$> lookupEnv "OTEL_EXPORTER_OTLP_INSECURE") <*>
    (fmap (== "true") <$> lookupEnv "OTEL_EXPORTER_OTLP_SPAN_INSECURE") <*>
    (fmap (== "true") <$> lookupEnv "OTEL_EXPORTER_OTLP_METRIC_INSECURE") <*>
    lookupEnv "OTEL_EXPORTER_OTLP_CERTIFICATE" <*>
    lookupEnv "OTEL_EXPORTER_OTLP_TRACES_CERTIFICATE" <*>
    lookupEnv "OTEL_EXPORTER_OTLP_METRICS_CERTIFICATE" <*>
    -- TODO lookupEnv "OTEL_EXPORTER_OTLP_HEADERS" <*>
    pure Nothing <*>
    -- TODO lookupEnv "OTEL_EXPORTER_OTLP_TRACES_HEADERS" <*>
    pure Nothing <*>
    -- TODO lookupEnv "OTEL_EXPORTER_OTLP_METRICS_HEADERS" <*>
    pure Nothing <*>
    -- TODO lookupEnv "OTEL_EXPORTER_OTLP_COMPRESSION" <*>
    pure Nothing <*>
    -- TODO lookupEnv "OTEL_EXPORTER_OTLP_TRACES_COMPRESSION" <*>
    pure Nothing <*>
    -- TODO lookupEnv "OTEL_EXPORTER_OTLP_METRICS_COMPRESSION" <*>
    pure Nothing <*>
    -- TODO lookupEnv "OTEL_EXPORTER_OTLP_TIMEOUT" <*>
    pure Nothing <*>
    -- TODO lookupEnv "OTEL_EXPORTER_OTLP_TRACES_TIMEOUT" <*>
    pure Nothing <*>
    -- TODO lookupEnv "OTEL_EXPORTER_OTLP_METRICS_TIMEOUT" <*>
    pure Nothing <*>
    -- TODO lookupEnv "OTEL_EXPORTER_OTLP_PROTOCOL" <*>
    pure Nothing <*>
    -- TODO lookupEnv "OTEL_EXPORTER_OTLP_TRACES_PROTOCOL" <*>
    pure Nothing <*>
    -- TODO lookupEnv "OTEL_EXPORTER_OTLP_METRICS_PROTOCOL"
    pure Nothing

protobufMimeType :: ByteString
protobufMimeType = "application/x-protobuf"

otlpExporter :: MonadIO m => OTLPExporterConfig -> m SpanExporter
otlpExporter conf = do
  pure $ SpanExporter
    { export = \spans -> do
        req <- parseRequest "http://localhost:4318/v1/traces"
        let req' = req
              { method = "POST"
              , requestHeaders =
                  (hContentType, protobufMimeType) :
                  (hAcceptEncoding, protobufMimeType) :
                  fromMaybe [] (otlpHeaders conf) ++
                  fromMaybe [] (otlpTracesHeaders conf) ++
                  requestHeaders req
              , requestBody =
                  RequestBodyBS $
                  encodeMessage $
                  immutableSpansToProtobuf spans
              }
        resp <- httpBS req'
        pure Success
    , shutdown = pure ()
    }

attributesToProto :: Functor f => f (Text, Attribute) -> f KeyValue
attributesToProto = fmap attributeToKeyValue
  where
    primAttributeToAnyValue = \case
      TextAttribute t -> defMessage & stringValue .~ t
      BoolAttribute b -> defMessage & boolValue .~ b
      DoubleAttribute d -> defMessage & doubleValue .~ d
      IntAttribute i -> defMessage & intValue .~ i
    attributeToKeyValue (k, v) = defMessage
      & key .~ k
      & value .~ (case v of
        AttributeValue a -> primAttributeToAnyValue a
        AttributeArray a -> defMessage
          & arrayValue .~ (defMessage & values .~ fmap primAttributeToAnyValue a)
      )


immutableSpansToProtobuf :: HashMap OT.InstrumentationLibrary (Vector OT.ImmutableSpan) -> ExportTraceServiceRequest
immutableSpansToProtobuf completedSpans = defMessage
  & vec'resourceSpans .~
    Vector.singleton
      ( defMessage
          & resource .~
            ( defMessage
                & attributes .~ []
                & droppedAttributesCount .~ 0
            )
          -- TODO, seems like spans need to be emitted via an API
          -- that lets us keep them grouped by instrumentation originator
          & instrumentationLibrarySpans .~
              fmap makeInstrumentationLibrarySpans ( H.toList completedSpans )
      )
  where
    makeInstrumentationLibrarySpans (library, completedSpans) = defMessage
      & instrumentationLibrary .~ (
          defMessage 
            & Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.name .~ OT.libraryName library
            & version .~ OT.libraryVersion library
        )
      & vec'spans .~ fmap makeSpan completedSpans
      -- & schemaUrl .~ "" -- TODO
    makeSpan completedSpan = let startTime = clockTimeToNanoSeconds (OT.spanStart completedSpan) in defMessage
      & traceId .~ traceIdBytes (OT.traceId $ OT.spanContext completedSpan)
      & spanId .~ spanIdBytes (OT.spanId $ OT.spanContext completedSpan)
      & traceState .~ "" -- TODO (_ $ OT.traceState $ OT.spanContext completedSpan)
      & Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.name .~ OT.spanName completedSpan
      & kind .~ (case OT.spanKind completedSpan of
       OT.Server -> Span'SPAN_KIND_SERVER
       OT.Client -> Span'SPAN_KIND_CLIENT
       OT.Producer -> Span'SPAN_KIND_PRODUCER
       OT.Consumer -> Span'SPAN_KIND_CONSUMER
       OT.Internal -> Span'SPAN_KIND_INTERNAL)
      & startTimeUnixNano .~ startTime
      & endTimeUnixNano .~ maybe startTime clockTimeToNanoSeconds (OT.spanEnd completedSpan)
      & attributes .~ attributesToProto (OT.spanAttributes completedSpan)
      & droppedAttributesCount .~ 0 -- TODO
      & events .~ fmap makeEvent (OT.spanEvents completedSpan)
      & droppedEventsCount .~ 0 -- TODO
      & links .~ fmap makeLink (OT.spanLinks completedSpan) -- TODO
      & droppedLinksCount .~ 0 -- TODO
      & status .~ (case OT.spanStatus completedSpan of
        OT.Unset -> defMessage
          & code .~ Status'STATUS_CODE_UNSET
        OT.Ok -> defMessage
          & code .~ Status'STATUS_CODE_OK
        (OT.Error e) -> defMessage
          & code .~ Status'STATUS_CODE_ERROR
          & message .~ e
      )
      & (\otlpSpan -> case OT.spanParent completedSpan of
          Nothing -> otlpSpan
          Just s -> otlpSpan & parentSpanId .~ spanIdBytes (OT.spanId $ unsafeDupablePerformIO (OT.getSpanContext s :: IO OT.SpanContext))
        )
    makeEvent e = defMessage
      & timeUnixNano .~ clockTimeToNanoSeconds (OT.eventTimestamp e)
      & Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.name .~ OT.eventName e
      & attributes .~ attributesToProto (OT.eventAttributes e)
      & droppedAttributesCount .~ 0
    makeLink l = defMessage
      & traceId .~ traceIdBytes (OT.traceId $ OT.linkContext l)
      & spanId .~ spanIdBytes (OT.spanId $ OT.linkContext l)
      & attributes .~ attributesToProto (OT.linkAttributes l)

clockTimeToNanoSeconds :: TimeSpec -> Word64
clockTimeToNanoSeconds TimeSpec{..} = fromIntegral (sec * 1_000_000_000) + fromIntegral nsec
-- TODO Retry-After, or exponential backoff if receive 429, 503
--  "Content-Type: application/x-protobuf"

-- ExportTraceServiceRequest -> ExportTraceServiceResponse
-- ExportMetricsServiceRequest -> ExportMetricsServiceResponse
-- ExportLogsServiceRequest -> ExportLogsServiceResponse