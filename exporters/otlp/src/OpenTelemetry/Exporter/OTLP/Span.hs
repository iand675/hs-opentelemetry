{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}

-----------------------------------------------------------------------------

-----------------------------------------------------------------------------

{- |
 Module      :  OpenTelemetry.Exporter.OTLP.Span
 Copyright   :  (c) Ian Duncan, 2021
 License     :  BSD-3
 Description :  OTLP Exporter
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)

 The OTLP Exporter is the recommend exporter format to use where possible.

 A number of vendors offer support for exporting traces, logs, and metrics using the vendor-agnostic OTLP protocol.

 Additionally, the OTLP format is supported by the <https://opentelemetry.io/docs/collector/ OpenTelemetry Collector>.

 The OpenTelemetry Collector offers a vendor-agnostic implementation of how to receive, process and export telemetry data.
 It removes the need to run, operate, and maintain multiple agents/collectors.
 This works with improved scalability and supports open-source observability data formats (e.g. Jaeger, Prometheus, Fluent Bit, etc.) sending to
 one or more open-source or commercial back-ends. The local Collector agent is the default location to which instrumentation libraries export
 their telemetry data.
-}
module OpenTelemetry.Exporter.OTLP.Span (
  -- * Initializing the exporter
  otlpExporter,

  -- * Configuring the exporter
  OTLPExporterConfig (..),
  CompressionFormat (..),
  Protocol (..),
  loadExporterEnvironmentVariables,

  -- * Default local endpoints
  otlpExporterHttpEndpoint,
  otlpExporterGRpcEndpoint,
) where

import Codec.Compression.GZip
import Control.Applicative ((<|>))
import Control.Concurrent (threadDelay)
import Control.Exception (SomeAsyncException (..), SomeException (..), fromException, throwIO, try)
import Control.Monad.IO.Class
import Data.Bits (shiftL)
import qualified Data.ByteString.Char8 as C
import qualified Data.ByteString.Lazy as L
import qualified Data.CaseInsensitive as CI
import Data.Char (toLower)
import qualified Data.HashMap.Strict as H
import Data.Maybe
import Data.ProtoLens.Encoding
import Data.ProtoLens.Message
import Data.Text (Text)
import qualified Data.Text.Encoding as T
import Data.Vector (Vector)
import qualified Data.Vector as V
import Lens.Micro
import Network.HTTP.Client
import qualified Network.HTTP.Client as HTTPClient
import Network.HTTP.Simple (httpBS)
import Network.HTTP.Types.Header
import Network.HTTP.Types.Status hiding (Status)
import OpenTelemetry.Attributes
import qualified OpenTelemetry.Baggage as Baggage
import OpenTelemetry.Common (TraceFlags (..), timestampToNano)
import OpenTelemetry.Environment
import OpenTelemetry.Exporter.Span (ExportResult (..), SpanExporter (..))
import qualified OpenTelemetry.Exporter.Span as OT
import OpenTelemetry.Internal.Trace.Id (spanIdBytes, traceIdBytes)
import OpenTelemetry.Propagator.W3CTraceContext (encodeTraceStateFull)
import OpenTelemetry.Resource (getMaterializedResourcesAttributes)
import qualified OpenTelemetry.Resource as OT
import OpenTelemetry.Trace.Core (timestampNanoseconds)
import qualified OpenTelemetry.Trace.Core as OT
import Proto.Opentelemetry.Proto.Collector.Trace.V1.TraceService (ExportTraceServiceRequest)
import Proto.Opentelemetry.Proto.Common.V1.Common (InstrumentationScope, KeyValue)
import qualified Proto.Opentelemetry.Proto.Common.V1.Common_Fields as Common_Fields
import Proto.Opentelemetry.Proto.Resource.V1.Resource (Resource)
import Proto.Opentelemetry.Proto.Trace.V1.Trace (ResourceSpans, ScopeSpans, Span, Span'Event, Span'Link, Span'SpanKind (..), Status, Status'StatusCode (..))
import qualified Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields as Trace_Fields
import System.Environment
import qualified System.IO as IO
import Text.Read (readMaybe)


-- | Initial the OTLP 'Exporter'
otlpExporter :: (MonadIO m) => OTLPExporterConfig -> m SpanExporter
otlpExporter conf = httpOtlpExporter conf


--------------------------------------------------------------------------------
-- OTLP Exporter configuration.
--------------------------------------------------------------------------------

data OTLPExporterConfig = OTLPExporterConfig
  { otlpEndpoint :: Maybe String
  , otlpTracesEndpoint :: Maybe String
  , otlpMetricsEndpoint :: Maybe String
  , otlpInsecure :: Bool
  , otlpSpanInsecure :: Bool
  , otlpMetricInsecure :: Bool
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
  -- ^ Measured in milliseconds.
  , otlpTracesTimeout :: Maybe Int
  -- ^ Measured in milliseconds.
  , otlpMetricsTimeout :: Maybe Int
  -- ^ Measured in milliseconds.
  , otlpProtocol :: Maybe Protocol
  , otlpTracesProtocol :: Maybe Protocol
  , otlpMetricsProtocol :: Maybe Protocol
  }


loadExporterEnvironmentVariables :: (MonadIO m) => m OTLPExporterConfig
loadExporterEnvironmentVariables = liftIO $ do
  OTLPExporterConfig
    <$> lookupEnv "OTEL_EXPORTER_OTLP_ENDPOINT"
    <*> lookupEnv "OTEL_EXPORTER_OTLP_TRACES_ENDPOINT"
    <*> lookupEnv "OTEL_EXPORTER_OTLP_METRICS_ENDPOINT"
    <*> lookupBooleanEnv "OTEL_EXPORTER_OTLP_INSECURE"
    <*> lookupBooleanEnv "OTEL_EXPORTER_OTLP_SPAN_INSECURE"
    <*> lookupBooleanEnv "OTEL_EXPORTER_OTLP_METRIC_INSECURE"
    <*> lookupEnv "OTEL_EXPORTER_OTLP_CERTIFICATE"
    <*> lookupEnv "OTEL_EXPORTER_OTLP_TRACES_CERTIFICATE"
    <*> lookupEnv "OTEL_EXPORTER_OTLP_METRICS_CERTIFICATE"
    <*> (fmap decodeHeaders <$> lookupEnv "OTEL_EXPORTER_OTLP_HEADERS")
    <*> (fmap decodeHeaders <$> lookupEnv "OTEL_EXPORTER_OTLP_TRACES_HEADERS")
    <*> (fmap decodeHeaders <$> lookupEnv "OTEL_EXPORTER_OTLP_METRICS_HEADERS")
    <*> (traverse readCompressionFormat =<< lookupEnv "OTEL_EXPORTER_OTLP_COMPRESSION")
    <*> (traverse readCompressionFormat =<< lookupEnv "OTEL_EXPORTER_OTLP_TRACES_COMPRESSION")
    <*> (traverse readCompressionFormat =<< lookupEnv "OTEL_EXPORTER_OTLP_METRICS_COMPRESSION")
    <*> (traverse readTimeout =<< lookupEnv "OTEL_EXPORTER_OTLP_TIMEOUT")
    <*> (traverse readTimeout =<< lookupEnv "OTEL_EXPORTER_OTLP_TRACES_TIMEOUT")
    <*> (traverse readTimeout =<< lookupEnv "OTEL_EXPORTER_OTLP_METRICS_TIMEOUT")
    <*> (traverse readProtocol =<< lookupEnv "OTEL_EXPORTER_OTLP_PROTOCOL")
    <*> (traverse readProtocol =<< lookupEnv "OTEL_EXPORTER_OTLP_TRACES_PROTOCOL")
    <*> (traverse readProtocol =<< lookupEnv "OTEL_EXPORTER_OTLP_METRICS_PROTOCOL")
  where
    decodeHeaders hsString = case Baggage.decodeBaggageHeader $ C.pack hsString of
      Left _ -> mempty
      Right baggageFmt ->
        (\(k, v) -> (CI.mk $ Baggage.tokenValue k, T.encodeUtf8 $ Baggage.value v)) <$> H.toList (Baggage.values baggageFmt)


{- |
The OpenTelemetry Protocol Compression Format.
-}
data CompressionFormat
  = None
  | GZip


{- |
Internal helper.
Read the `CompressionFormat` from a `String`.
Defaults to `None` for unsupported values.
-}
readCompressionFormat :: (MonadIO m) => String -> m CompressionFormat
readCompressionFormat compressionFormat =
  compressionFormat & fmap toLower & \case
    "gzip" -> pure GZip
    "none" -> pure None
    _ -> do
      putWarningLn $ "Warning: unsupported compression format '" <> compressionFormat <> "'"
      pure None


{- |
The OpenTelemetry Protocol. Either HTTP/Protobuf or gRPC.

Note: gRPC and HTTP/JSON will likely be supported eventually, but not yet.
-}
data Protocol {- GRpc | HttpJson | -}
  = HttpProtobuf


{- |
Internal helper.
Read a `Protocol` from a `String`.
Defaults to `HttpProtobuf` for unsupported values.
-}
readProtocol :: (MonadIO m) => String -> m Protocol
readProtocol protocol =
  protocol & fmap toLower & \case
    "http/protobuf" -> pure HttpProtobuf
    _ -> do
      putWarningLn $ "Warning: unsupported protocol '" <> protocol <> "'"
      pure HttpProtobuf


{- |
Internal helper.
Read a timeout from a `String`.
-}
readTimeout :: (MonadIO m) => String -> m Int
readTimeout timeout =
  case readMaybe timeout of
    Just timeoutInt | timeoutInt >= 0 -> pure timeoutInt
    _otherwise -> do
      putWarningLn $ "Warning: unsupported timeout '" <> timeout <> "'"
      pure defaultExporterTimeout


{- |
Internal helper.
The default OTLP timeout in milliseconds.
-}
defaultExporterTimeout :: Int
defaultExporterTimeout = 10_000


{- |
The default OTLP HTTP endpoint.
-}
otlpExporterHttpEndpoint :: C.ByteString
otlpExporterHttpEndpoint = "http://localhost:4318"


{- |
The default OTLP gRPC endpoint.
-}
otlpExporterGRpcEndpoint :: C.ByteString
otlpExporterGRpcEndpoint = "http://localhost:4317"


{- |
Internal helper.
Print a warning to stderr
-}
putWarningLn :: (MonadIO m) => String -> m ()
putWarningLn = liftIO . IO.hPutStrLn IO.stderr


--------------------------------------------------------------------------------
-- OTLP Exporter using HTTP/Protobuf.
--------------------------------------------------------------------------------

{- |
Internal helper.
Construct a `SpanExporter` that uses HTTP/Protobuf.
-}
httpOtlpExporter :: (MonadIO m) => OTLPExporterConfig -> m SpanExporter
httpOtlpExporter conf = do
  -- TODO url parsing is jankym
  -- TODO make retryDelay and maximum retry counts configurable
  req <- liftIO $ parseRequest (httpHost conf <> "/v1/traces")
  let (encodingHeaders, encoder) = httpCompression conf
  let baseReq =
        req
          { method = "POST"
          , requestHeaders = encodingHeaders <> httpBaseHeaders conf req
          , responseTimeout = httpTracesResponseTimeout conf
          }
  pure $
    SpanExporter
      { spanExporterExport = \spans_ -> do
          if not (V.null spans_)
            then do
              result <- try $ exporterExportCall encoder baseReq spans_
              case result of
                Left err -> do
                  -- If the exception is async, then we need to rethrow it
                  -- here. Otherwise, there's a good chance that the
                  -- calling code will swallow the exception and cause
                  -- a problem.
                  case fromException err of
                    Just (SomeAsyncException _) -> do
                      throwIO err
                    Nothing ->
                      pure $ Failure $ Just err
                Right ok -> pure ok
            else pure Success
      , spanExporterShutdown = pure ()
      }
  where
    retryDelay = 100_000 -- 100ms
    maxRetryCount = 5
    isRetryableStatusCode status_ =
      status_ == status408 || status_ == status429 || (statusCode status_ >= 500 && statusCode status_ < 600)
    isRetryableException = \case
      ResponseTimeout -> True
      ConnectionTimeout -> True
      ConnectionFailure _ -> True
      ConnectionClosed -> True
      _ -> False

    exporterExportCall encoder baseReq spans_ = do
      let msg = encodeMessage (makeExportTraceServiceRequest spans_)
      -- TODO handle server disconnect
      let req =
            baseReq
              { requestBody =
                  RequestBodyLBS $ encoder $ L.fromStrict msg
              }
      sendReq req 0 -- TODO =<< getTime for maximum cutoff
    sendReq req backoffCount = do
      eResp <- try $ httpBS req

      let exponentialBackoff =
            if backoffCount == maxRetryCount
              then pure $ Failure Nothing
              else do
                threadDelay (retryDelay `shiftL` backoffCount)
                sendReq req (backoffCount + 1)

      case eResp of
        Left err@(HttpExceptionRequest req' e)
          | HTTPClient.host req' == "localhost"
          , HTTPClient.port req' == 4317 || HTTPClient.port req' == 4318
          , ConnectionFailure _someExn <- e ->
              do
                pure $ Failure Nothing
          | otherwise ->
              if isRetryableException e
                then exponentialBackoff
                else pure $ Failure $ Just $ SomeException err
        Left err -> do
          pure $ Failure $ Just $ SomeException err
        Right resp ->
          if isRetryableStatusCode (responseStatus resp)
            then case lookup hRetryAfter $ responseHeaders resp of
              Nothing -> exponentialBackoff
              Just retryAfter -> do
                -- TODO support date in retry-after header
                case readMaybe $ C.unpack retryAfter of
                  Nothing -> exponentialBackoff
                  Just seconds -> do
                    threadDelay (seconds * 1_000_000)
                    sendReq req (backoffCount + 1)
            else
              if statusCode (responseStatus resp) >= 300
                then do
                  print resp
                  pure $ Failure Nothing
                else pure Success


{- |
Internal helper.
Get the HTTP `ResponseTimeout` from the `OTLPExporterConfig`.
-}
httpTracesResponseTimeout :: OTLPExporterConfig -> ResponseTimeout
httpTracesResponseTimeout conf = case otlpTracesTimeout conf <|> otlpTimeout conf of
  Just timeoutMilli
    | timeoutMilli == 0 -> responseTimeoutNone
    | timeoutMilli >= 1 -> responseTimeoutMilli timeoutMilli
  _otherwise -> responseTimeoutMilli defaultExporterTimeout
  where
    responseTimeoutMilli :: Int -> ResponseTimeout
    responseTimeoutMilli = responseTimeoutMicro . (* 1_000)


{- |
Internal helper.
Get the HTTP host from the `OTLPExporterConfig`.
-}
httpHost :: OTLPExporterConfig -> String
httpHost conf = fromMaybe defaultHost $ otlpEndpoint conf
  where
    -- TODO shouldn't this be http://localhost:4317 ?
    defaultHost = "http://localhost:4318"


{- |
Internal helper.
The type of `L.ByteString` encoders.
-}
type Encoder = L.ByteString -> L.ByteString


{- |
Internal helper.
Get a function that adds the compression header to the HTTP headers and a function that performs the compression.
-}
httpCompression :: OTLPExporterConfig -> ([(HeaderName, C.ByteString)], Encoder)
httpCompression conf =
  case otlpTracesCompression conf <|> otlpCompression conf of
    Just GZip -> ([(hContentEncoding, "gzip")], compress)
    _otherwise -> ([], id)


{- |
Internal helper.
The mimetype used by HTTP/Protobuf.
-}
httpProtobufMimeType :: C.ByteString
httpProtobufMimeType = "application/x-protobuf"


{- |
Internal helper.
Get the base HTTP headers for the request.
-}
httpBaseHeaders :: OTLPExporterConfig -> Request -> [(HeaderName, C.ByteString)]
httpBaseHeaders conf req =
  concat
    [ [(hContentType, httpProtobufMimeType)]
    , [(hAcceptEncoding, httpProtobufMimeType)]
    , fromMaybe [] (otlpHeaders conf)
    , fromMaybe [] (otlpTracesHeaders conf)
    , requestHeaders req
    ]


--------------------------------------------------------------------------------
-- Convert from `hs-opentelemetry-api` data model into OTLP Protobuf.
--------------------------------------------------------------------------------

makeExportTraceServiceRequest :: Vector OT.MaterializedResourceSpans -> ExportTraceServiceRequest
makeExportTraceServiceRequest materializedResourceSpans =
  defMessage
    & Trace_Fields.vec'resourceSpans
      .~ fmap resourceSpansToProto materializedResourceSpans


resourceSpansToProto :: OT.MaterializedResourceSpans -> ResourceSpans
resourceSpansToProto OT.MaterializedResourceSpans {..} =
  defMessage
    & maybe id ((Trace_Fields.resource .~) . resourceToProto) materializedResource
    & Trace_Fields.vec'scopeSpans
      .~ fmap scopeSpansToProto materializedScopeSpans


resourceToProto :: OT.MaterializedResources -> Resource
resourceToProto materializedResource =
  defMessage
    & Trace_Fields.vec'attributes
      .~ attributesToProto (getMaterializedResourcesAttributes materializedResource)
    -- TODO
    & Trace_Fields.droppedAttributesCount
      .~ 0


scopeSpansToProto :: OT.MaterializedScopeSpans -> ScopeSpans
scopeSpansToProto OT.MaterializedScopeSpans {..} =
  -- TODO: Trace_Fields.schemaUrl
  defMessage
    & maybe id ((Trace_Fields.scope .~) . scopeToProto) materializedScope
    & Trace_Fields.vec'spans
      .~ fmap materializedSpanToProto materializedSpans


scopeToProto :: OT.InstrumentationLibrary -> InstrumentationScope
scopeToProto instrumentationLibrary =
  defMessage
    & Trace_Fields.name
      .~ OT.libraryName instrumentationLibrary
    & Common_Fields.version
      .~ OT.libraryVersion instrumentationLibrary


materializedSpanToProto :: OT.MaterializedSpan -> Span
materializedSpanToProto OT.MaterializedSpan {..} =
  let TraceFlags flags = OT.traceFlags materializedContext
  in defMessage
      & Trace_Fields.traceId
        .~ traceIdBytes (OT.traceId materializedContext)
      & Trace_Fields.spanId
        .~ spanIdBytes (OT.spanId materializedContext)
      & Trace_Fields.traceState
        .~ T.decodeUtf8 (encodeTraceStateFull $ OT.traceState materializedContext)
      & Trace_Fields.flags
        .~ fromIntegral flags
      & Trace_Fields.name
        .~ materializedName
      & Trace_Fields.kind
        .~ ( case materializedKind of
              OT.Server -> Span'SPAN_KIND_SERVER
              OT.Client -> Span'SPAN_KIND_CLIENT
              OT.Producer -> Span'SPAN_KIND_PRODUCER
              OT.Consumer -> Span'SPAN_KIND_CONSUMER
              OT.Internal -> Span'SPAN_KIND_INTERNAL
           )
      & Trace_Fields.parentSpanId
        .~ materializedParentSpanId
      & Trace_Fields.startTimeUnixNano
        .~ timestampToNano materializedStartTimeUnixNano
      & Trace_Fields.endTimeUnixNano
        .~ timestampToNano materializedEndTimeUnixNano
      & Trace_Fields.vec'attributes
        .~ attributesToProto materializedAttributes
      & Trace_Fields.droppedAttributesCount
        .~ fromIntegral materializedDroppedAttributesCount
      & Trace_Fields.vec'events
        .~ fmap spanEventToProto materializedEvents
      & Trace_Fields.droppedEventsCount
        .~ materializedDroppedEventsCount
      & Trace_Fields.vec'links
        .~ fmap spanLinkToProto materializedLinks
      & Trace_Fields.droppedLinksCount
        .~ materializedDroppedLinksCount
      & maybe id ((Trace_Fields.status .~) . spanStatusToProto) materializedStatus


spanStatusToProto :: OT.SpanStatus -> Status
spanStatusToProto = \case
  OT.Unset ->
    defMessage
      & Trace_Fields.code
        .~ Status'STATUS_CODE_UNSET
  OT.Ok ->
    defMessage
      & Trace_Fields.code
        .~ Status'STATUS_CODE_OK
  (OT.Error e) ->
    defMessage
      & Trace_Fields.code
        .~ Status'STATUS_CODE_ERROR
      & Trace_Fields.message
        .~ e


spanEventToProto :: OT.Event -> Span'Event
spanEventToProto e =
  defMessage
    & Trace_Fields.timeUnixNano
      .~ timestampNanoseconds (OT.eventTimestamp e)
    & Trace_Fields.name
      .~ OT.eventName e
    & Trace_Fields.vec'attributes
      .~ attributesToProto (OT.eventAttributes e)
    & Trace_Fields.droppedAttributesCount
      .~ fromIntegral (getCount $ OT.eventAttributes e)


spanLinkToProto :: OT.Link -> Span'Link
spanLinkToProto l =
  defMessage
    & Trace_Fields.traceId
      .~ traceIdBytes (OT.traceId $ OT.frozenLinkContext l)
    & Trace_Fields.spanId
      .~ spanIdBytes (OT.spanId $ OT.frozenLinkContext l)
    & Trace_Fields.traceState
      .~ T.decodeUtf8 (encodeTraceStateFull $ OT.traceState $ OT.frozenLinkContext l)
    & Trace_Fields.vec'attributes
      .~ attributesToProto (OT.frozenLinkAttributes l)
    & Trace_Fields.droppedAttributesCount
      .~ fromIntegral (getCount $ OT.frozenLinkAttributes l)


attributesToProto :: Attributes -> Vector KeyValue
attributesToProto =
  V.fromList
    . fmap attributeToKeyValue
    . H.toList
    . snd
    . ((,) <$> getCount <*> getAttributeMap)
  where
    primAttributeToAnyValue = \case
      TextAttribute t -> defMessage & Common_Fields.stringValue .~ t
      BoolAttribute b -> defMessage & Common_Fields.boolValue .~ b
      DoubleAttribute d -> defMessage & Common_Fields.doubleValue .~ d
      IntAttribute i -> defMessage & Common_Fields.intValue .~ i
    attributeToKeyValue :: (Text, Attribute) -> KeyValue
    attributeToKeyValue (k, v) =
      defMessage
        & Common_Fields.key
          .~ k
        & Common_Fields.value
          .~ ( case v of
                AttributeValue a -> primAttributeToAnyValue a
                AttributeArray a ->
                  defMessage
                    & Common_Fields.arrayValue
                      .~ (defMessage & Common_Fields.values .~ fmap primAttributeToAnyValue a)
             )
