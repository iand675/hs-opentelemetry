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
import Data.HashMap.Strict (HashMap)
import qualified Data.HashMap.Strict as H
import Data.Maybe
import Data.ProtoLens.Encoding
import Data.ProtoLens.Message
import Data.Text (Text)
import qualified Data.Text.Encoding as T
import Data.Vector (Vector)
import qualified Data.Vector as V
import qualified Data.Vector as Vector
import Lens.Micro
import Network.HTTP.Client
import qualified Network.HTTP.Client as HTTPClient
import Network.HTTP.Simple (httpBS)
import Network.HTTP.Types.Header
import Network.HTTP.Types.Status
import OpenTelemetry.Attributes
import qualified OpenTelemetry.Baggage as Baggage
import OpenTelemetry.Environment
import OpenTelemetry.Exporter.Span
import OpenTelemetry.Resource
import OpenTelemetry.Trace.Core (timestampNanoseconds)
import qualified OpenTelemetry.Trace.Core as OT
import OpenTelemetry.Trace.Id (spanIdBytes, traceIdBytes)
import OpenTelemetry.Util
import Proto.Opentelemetry.Proto.Collector.Trace.V1.TraceService (ExportTraceServiceRequest)
import Proto.Opentelemetry.Proto.Common.V1.Common
import qualified Proto.Opentelemetry.Proto.Common.V1.Common_Fields as Common_Fields
import Proto.Opentelemetry.Proto.Trace.V1.Trace
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
          let anySpansToExport = H.size spans_ /= 0 && not (all V.null $ H.elems spans_)
          if anySpansToExport
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
      msg <- encodeMessage <$> immutableSpansToProtobuf spans_
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

{- |
Translate a collection of `OT.ImmutableSpan` spans to an OTLP `ExportTraceServiceRequest`.
-}
immutableSpansToProtobuf :: (MonadIO m) => HashMap OT.InstrumentationLibrary (Vector OT.ImmutableSpan) -> m ExportTraceServiceRequest
immutableSpansToProtobuf completedSpans = do
  spansByLibrary <- mapM makeScopeSpans spanGroupList
  pure $
    defMessage
      & Trace_Fields.vec'resourceSpans
        .~ Vector.singleton
          ( defMessage
              & Trace_Fields.resource
                .~ ( defMessage
                      & Trace_Fields.vec'attributes
                        .~ attributesToProto (getMaterializedResourcesAttributes someResourceGroup)
                      -- TODO
                      & Trace_Fields.droppedAttributesCount
                        .~ 0
                   )
              -- TODO, seems like spans need to be emitted via an API
              -- that lets us keep them grouped by instrumentation originator
              & Trace_Fields.scopeSpans
                .~ spansByLibrary
          )
  where
    -- TODO this won't work right if multiple TracerProviders are exporting to a single OTLP exporter with different resources
    someResourceGroup = case spanGroupList of
      [] -> emptyMaterializedResources
      ((_, r) : _) -> case r V.!? 0 of
        Nothing -> emptyMaterializedResources
        Just s -> OT.getTracerProviderResources $ OT.getTracerTracerProvider $ OT.spanTracer s

    spanGroupList = H.toList completedSpans


{- |
Internal helper.
Translate a collection of `OT.ImmutableSpan` spans to OTLP `ScopeSpans`.
-}
makeScopeSpans :: (MonadIO m) => (OT.InstrumentationLibrary, Vector OT.ImmutableSpan) -> m ScopeSpans
makeScopeSpans (library, completedSpans_) = do
  spans_ <- mapM makeSpan completedSpans_
  pure $
    defMessage
      & Trace_Fields.scope
        .~ ( defMessage
              & Trace_Fields.name
                .~ OT.libraryName library
              & Common_Fields.version
                .~ OT.libraryVersion library
           )
      & Trace_Fields.vec'spans
        .~ spans_


-- & schemaUrl .~ "" -- TODO

{- |
Internal helper.
Translate an `OT.ImmutableSpan` span to an OTLP `Span`.
-}
makeSpan :: (MonadIO m) => OT.ImmutableSpan -> m Span
makeSpan completedSpan = do
  let startTime = timestampNanoseconds (OT.spanStart completedSpan)
  parentSpanF <- do
    case OT.spanParent completedSpan of
      Nothing -> pure id
      Just s -> do
        spanCtxt <- OT.spanId <$> OT.getSpanContext s
        pure (\otlpSpan -> otlpSpan & Trace_Fields.parentSpanId .~ spanIdBytes spanCtxt)

  pure $
    defMessage
      & Trace_Fields.traceId
        .~ traceIdBytes (OT.traceId $ OT.spanContext completedSpan)
      & Trace_Fields.spanId
        .~ spanIdBytes (OT.spanId $ OT.spanContext completedSpan)
      & Trace_Fields.traceState
        .~ "" -- TODO (_ $ OT.traceState $ OT.spanContext completedSpan)
      & Trace_Fields.name
        .~ OT.spanName completedSpan
      & Trace_Fields.kind
        .~ ( case OT.spanKind completedSpan of
              OT.Server -> Span'SPAN_KIND_SERVER
              OT.Client -> Span'SPAN_KIND_CLIENT
              OT.Producer -> Span'SPAN_KIND_PRODUCER
              OT.Consumer -> Span'SPAN_KIND_CONSUMER
              OT.Internal -> Span'SPAN_KIND_INTERNAL
           )
      & Trace_Fields.startTimeUnixNano
        .~ startTime
      & Trace_Fields.endTimeUnixNano
        .~ maybe startTime timestampNanoseconds (OT.spanEnd completedSpan)
      & Trace_Fields.vec'attributes
        .~ attributesToProto (OT.spanAttributes completedSpan)
      & Trace_Fields.droppedAttributesCount
        .~ fromIntegral (getCount $ OT.spanAttributes completedSpan)
      & Trace_Fields.vec'events
        .~ fmap makeEvent (appendOnlyBoundedCollectionValues $ OT.spanEvents completedSpan)
      & Trace_Fields.droppedEventsCount
        .~ fromIntegral (appendOnlyBoundedCollectionDroppedElementCount (OT.spanEvents completedSpan))
      & Trace_Fields.vec'links
        .~ fmap makeLink (appendOnlyBoundedCollectionValues $ OT.spanLinks completedSpan)
      & Trace_Fields.droppedLinksCount
        .~ fromIntegral (appendOnlyBoundedCollectionDroppedElementCount (OT.spanLinks completedSpan))
      & Trace_Fields.status
        .~ ( case OT.spanStatus completedSpan of
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
           )
      & parentSpanF


{- |
Internal helper.
Translate an `OT.Event` to an OTLP `Span'Event`.
-}
makeEvent :: OT.Event -> Span'Event
makeEvent e =
  defMessage
    & Trace_Fields.timeUnixNano
      .~ timestampNanoseconds (OT.eventTimestamp e)
    & Trace_Fields.name
      .~ OT.eventName e
    & Trace_Fields.vec'attributes
      .~ attributesToProto (OT.eventAttributes e)
    & Trace_Fields.droppedAttributesCount
      .~ fromIntegral (getCount $ OT.eventAttributes e)


{- |
Internal helper.
Translate an `OT.Link` to an OTLP `Span'Link`.
-}
makeLink :: OT.Link -> Span'Link
makeLink l =
  defMessage
    & Trace_Fields.traceId
      .~ traceIdBytes (OT.traceId $ OT.frozenLinkContext l)
    & Trace_Fields.spanId
      .~ spanIdBytes (OT.spanId $ OT.frozenLinkContext l)
    & Trace_Fields.vec'attributes
      .~ attributesToProto (OT.frozenLinkAttributes l)
    & Trace_Fields.droppedAttributesCount
      .~ fromIntegral (getCount $ OT.frozenLinkAttributes l)


{- |
Internal helper.
Translate a collection of `Attributes` to a vector of OTLP `KeyValue` pairs.
-}
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
