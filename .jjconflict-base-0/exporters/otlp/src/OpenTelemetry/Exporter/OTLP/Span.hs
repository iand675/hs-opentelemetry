{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE CPP #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}

{- |
Module      : OpenTelemetry.Exporter.OTLP.Span
Copyright   : (c) Ian Duncan, 2021-2026
License     : BSD-3
Description : OTLP span exporter (HTTP/protobuf)
Stability   : experimental

= Overview

Exports spans to any OTLP-compatible endpoint (OpenTelemetry Collector,
Jaeger, Grafana Tempo, Honeycomb, Datadog, etc.) using HTTP with protobuf
encoding.

= Quick example

Normally you do not create this exporter directly; the SDK creates it
automatically when @OTEL_TRACES_EXPORTER=otlp@ (the default). To customize:

@
import OpenTelemetry.Exporter.OTLP.Span

config <- loadExporterEnvironmentVariables
exporter <- otlpExporter config
@

= Configuration

All configuration is via environment variables. Per-signal variables override
the generic ones. See
<https://opentelemetry.io/docs/specs/otel/protocol/exporter/>.

=== Endpoint

* @OTEL_EXPORTER_OTLP_ENDPOINT@ — base URL (default: @http:\/\/localhost:4318@
  for HTTP, @http:\/\/localhost:4317@ for gRPC). HTTP appends @\/v1\/traces@.
* @OTEL_EXPORTER_OTLP_TRACES_ENDPOINT@ — overrides the above for traces
  (used as-is, no path appended).

=== Headers, auth, TLS

* @OTEL_EXPORTER_OTLP_HEADERS@ / @OTEL_EXPORTER_OTLP_TRACES_HEADERS@ —
  comma-separated @key=value@ pairs appended to every export request.
* @OTEL_EXPORTER_OTLP_CERTIFICATE@ / @OTEL_EXPORTER_OTLP_TRACES_CERTIFICATE@ —
  path to a custom CA certificate (PEM).
* @OTEL_EXPORTER_OTLP_INSECURE@ / @OTEL_EXPORTER_OTLP_TRACES_INSECURE@ —
  disable TLS verification (default: @false@).

=== Encoding and transport

* @OTEL_EXPORTER_OTLP_PROTOCOL@ / @OTEL_EXPORTER_OTLP_TRACES_PROTOCOL@ —
  @http\/protobuf@ (default) or @grpc@.
* @OTEL_EXPORTER_OTLP_COMPRESSION@ / @OTEL_EXPORTER_OTLP_TRACES_COMPRESSION@ —
  @gzip@ or @none@ (default: @none@).
* @OTEL_EXPORTER_OTLP_TIMEOUT@ / @OTEL_EXPORTER_OTLP_TRACES_TIMEOUT@ —
  export timeout in milliseconds (default: @10000@).
-}
module OpenTelemetry.Exporter.OTLP.Span (
  -- * Initializing the exporter
  otlpExporter,

  -- * Registry integration
  registerOtlpSpanExporter,

  -- * Configuring the exporter (re-exported from Internal.Config)
  OTLPExporterConfig (..),
  CompressionFormat (..),
  Protocol (..),
  loadExporterEnvironmentVariables,

  -- * Default local endpoints
  otlpExporterHttpEndpoint,
  otlpExporterGRpcEndpoint,

  -- * Testing
  immutableSpansToProtobuf,
) where

import Codec.Compression.GZip
import Control.Applicative ((<|>))
import Control.Concurrent (threadDelay)
import Control.Exception (SomeAsyncException (..), SomeException (..), fromException, throwIO, try)
import Control.Monad (when)
import Control.Monad.IO.Class
import Data.Bits (shiftL, (.|.))
import qualified Data.ByteString.Char8 as C
import qualified Data.ByteString.Lazy as L
import Data.HashMap.Strict (HashMap)
import qualified Data.HashMap.Strict as H
import Data.IORef (atomicModifyIORef', newIORef, readIORef)
import Data.Maybe
import Data.ProtoLens.Encoding
import Data.ProtoLens.Message
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import Data.Vector (Vector)
import qualified Data.Vector as V
import qualified Data.Vector as Vector
import Data.Word (Word32)
import Lens.Micro
import Network.HTTP.Client
import qualified Network.HTTP.Client as HTTPClient
import Network.HTTP.Simple (httpBS)
import Network.HTTP.Types.Header
import Network.HTTP.Types.Status
import OpenTelemetry.Attributes
import OpenTelemetry.Common (optionalTimestampToMaybe)
import OpenTelemetry.Exporter.OTLP.Internal.Config
import OpenTelemetry.Exporter.Span
import OpenTelemetry.Internal.Common.Types (FlushResult (..), ShutdownResult (..))
import OpenTelemetry.Internal.Logging (otelLogWarning)
import OpenTelemetry.Propagator.W3CTraceContext (encodeTraceStateFull)
import OpenTelemetry.Registry (registerSpanExporterFactory)
import OpenTelemetry.Resource
import OpenTelemetry.Trace.Core (timestampNanoseconds, traceFlagsValue)
import qualified OpenTelemetry.Trace.Core as OT
import OpenTelemetry.Trace.Id (spanIdBytes, traceIdBytes)
import OpenTelemetry.Util
import Proto.Opentelemetry.Proto.Collector.Trace.V1.TraceService (ExportTraceServiceRequest, ExportTraceServiceResponse)
import qualified Proto.Opentelemetry.Proto.Collector.Trace.V1.TraceService_Fields as TSF
import Proto.Opentelemetry.Proto.Common.V1.Common
import qualified Proto.Opentelemetry.Proto.Common.V1.Common_Fields as Common_Fields
import Proto.Opentelemetry.Proto.Trace.V1.Trace
import qualified Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields as Trace_Fields
import System.Random (randomRIO)


#ifdef GRPC_ENABLED
import qualified OpenTelemetry.Exporter.OTLP.GRPC
#endif


{- | Initialise the OTLP span exporter, choosing transport based on the
configured protocol (default: @http\/protobuf@).
-}
otlpExporter :: (MonadIO m) => OTLPExporterConfig -> m SpanExporter
otlpExporter conf = case resolvedProtocol conf of
  HttpProtobuf -> httpOtlpExporter conf
#ifdef GRPC_ENABLED
  GRpc -> OpenTelemetry.Exporter.OTLP.GRPC.grpcOtlpSpanExporter conf immutableSpansToProtobuf
#endif


resolvedProtocol :: OTLPExporterConfig -> Protocol
resolvedProtocol conf =
  case otlpTracesProtocol conf <|> otlpProtocol conf of
    Just p -> p
    Nothing -> HttpProtobuf


{- | Register the OTLP span exporter under the name @\"otlp\"@ in the
global registry. When the SDK resolves @OTEL_TRACES_EXPORTER=otlp@,
the registered factory will be used. Configuration is read from
standard @OTEL_EXPORTER_OTLP_*@ environment variables at construction
time.

@since 0.1.1.0
-}
registerOtlpSpanExporter :: IO ()
registerOtlpSpanExporter =
  registerSpanExporterFactory "otlp" $
    loadExporterEnvironmentVariables >>= otlpExporter


--------------------------------------------------------------------------------
-- OTLP Exporter using HTTP/Protobuf.
--------------------------------------------------------------------------------

httpOtlpExporter :: (MonadIO m) => OTLPExporterConfig -> m SpanExporter
httpOtlpExporter conf = do
  req <- liftIO $ parseRequest (httpSignalEndpointUrl (otlpTracesEndpoint conf) conf "/v1/traces")
  shutdownRef <- liftIO $ newIORef False
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
          isShutdown <- readIORef shutdownRef
          if isShutdown
            then pure $ Failure Nothing
            else do
              let anySpansToExport = H.size spans_ /= 0 && not (all V.null $ H.elems spans_)
              if anySpansToExport
                then do
                  result <- try $ exporterExportCall encoder baseReq spans_
                  case result of
                    Left err -> do
                      case fromException err of
                        Just (SomeAsyncException _) -> do
                          throwIO err
                        Nothing ->
                          pure $ Failure $ Just err
                    Right ok -> pure ok
                else pure Success
      , spanExporterShutdown = do
          _ <- atomicModifyIORef' shutdownRef $ \s -> (True, s)
          pure ShutdownSuccess
      , spanExporterForceFlush = pure FlushSuccess
      }
  where
    retryDelay = 100_000 -- 100ms
    maxRetryCount = 5
    isRetryableException = \case
      ResponseTimeout -> True
      ConnectionTimeout -> True
      ConnectionFailure _ -> True
      ConnectionClosed -> True
      _ -> False

    exporterExportCall encoder baseReq spans_ = do
      msg <- encodeMessage <$> immutableSpansToProtobuf spans_
      let req =
            baseReq
              { requestBody =
                  RequestBodyLBS $ encoder $ L.fromStrict msg
              }
      sendReq req 0
    sendReq req backoffCount = do
      eResp <- try $ httpBS req

      let exponentialBackoff =
            if backoffCount == maxRetryCount
              then pure $ Failure Nothing
              else do
                let !baseDelay = retryDelay `shiftL` backoffCount
                jitterUs <- randomRIO (0, baseDelay)
                threadDelay (baseDelay + jitterUs)
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
          if isRetryableHttpStatus (responseStatus resp)
            then case lookup hRetryAfter $ responseHeaders resp of
              Nothing -> exponentialBackoff
              Just retryAfter -> do
                -- Spec: honor Retry-After as delay-seconds or HTTP-date
                -- https://opentelemetry.io/docs/specs/otlp/#failures
                mMicros <- parseRetryAfterMicros retryAfter
                case mMicros of
                  Nothing -> exponentialBackoff
                  Just micros -> do
                    threadDelay micros
                    sendReq req (backoffCount + 1)
            else
              if statusCode (responseStatus resp) >= 300
                then do
                  putWarningLn $
                    "OTLP export failed with status "
                      <> show (statusCode (responseStatus resp))
                      <> ": "
                      <> C.unpack (statusMessage (responseStatus resp))
                  pure $ Failure Nothing
                else do
                  let body = responseBody resp
                  case decodeMessage body of
                    Right (tsResp :: ExportTraceServiceResponse) -> do
                      let ps = tsResp ^. TSF.partialSuccess
                          rejected = ps ^. TSF.rejectedSpans
                          errMsg = ps ^. TSF.errorMessage
                      when (rejected > 0) $
                        otelLogWarning $
                          "OTLP partial success: "
                            <> show rejected
                            <> " spans rejected"
                            <> if T.null errMsg then "" else ": " <> T.unpack errMsg
                      pure Success
                    Left _ -> pure Success


httpTracesResponseTimeout :: OTLPExporterConfig -> ResponseTimeout
httpTracesResponseTimeout conf = case otlpTracesTimeout conf <|> otlpTimeout conf of
  Just timeoutMilli
    | timeoutMilli >= 1 -> responseTimeoutMicro (timeoutMilli * 1_000)
  -- Spec: "Export MUST NOT block indefinitely." Treat 0, negative, or
  -- unset as "use default" rather than disabling the timeout.
  _otherwise -> responseTimeoutMicro (defaultExporterTimeout * 1_000)


type Encoder = L.ByteString -> L.ByteString


httpCompression :: OTLPExporterConfig -> ([(HeaderName, C.ByteString)], Encoder)
httpCompression conf =
  case otlpTracesCompression conf <|> otlpCompression conf of
    Just GZip -> ([(hContentEncoding, "gzip")], compress)
    _otherwise -> ([], id)


httpBaseHeaders :: OTLPExporterConfig -> Request -> [(HeaderName, C.ByteString)]
httpBaseHeaders conf req =
  concat
    [ [(hContentType, httpProtobufContentType)]
    , [(hAccept, httpProtobufContentType)]
    , [("User-Agent", otlpUserAgent)]
    , fromMaybe [] (otlpHeaders conf)
    , fromMaybe [] (otlpTracesHeaders conf)
    , requestHeaders req
    ]


--------------------------------------------------------------------------------
-- Convert from `hs-opentelemetry-api` data model into OTLP Protobuf.
--------------------------------------------------------------------------------

immutableSpansToProtobuf :: (MonadIO m) => HashMap OT.InstrumentationLibrary (Vector OT.ImmutableSpan) -> m ExportTraceServiceRequest
immutableSpansToProtobuf completedSpans = do
  spansByLibrary <- mapM makeScopeSpans spanGroupList
  let resourceAttrs = getMaterializedResourcesAttributes someResourceGroup
  pure $
    defMessage
      & Trace_Fields.vec'resourceSpans
        .~ Vector.singleton
          ( defMessage
              & Trace_Fields.resource
                .~ ( defMessage
                      & Trace_Fields.vec'attributes
                        .~ attributesToProto resourceAttrs
                      & Trace_Fields.droppedAttributesCount
                        .~ fromIntegral (getDropped resourceAttrs)
                   )
              & Trace_Fields.scopeSpans
                .~ spansByLibrary
              & Trace_Fields.schemaUrl
                .~ maybe T.empty T.pack (getMaterializedResourcesSchema someResourceGroup)
          )
  where
    someResourceGroup = case spanGroupList of
      [] -> emptyMaterializedResources
      ((_, r) : _) -> case r V.!? 0 of
        Nothing -> emptyMaterializedResources
        Just s -> OT.getTracerProviderResources $ OT.getTracerTracerProvider $ OT.spanTracer s

    spanGroupList = H.toList completedSpans


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
              & Common_Fields.vec'attributes
                .~ attributesToProto (OT.libraryAttributes library)
              & Common_Fields.droppedAttributesCount
                .~ fromIntegral (getDropped (OT.libraryAttributes library))
           )
      & Trace_Fields.vec'spans
        .~ spans_
      & Trace_Fields.schemaUrl
        .~ OT.librarySchemaUrl library


makeSpan :: (MonadIO m) => OT.ImmutableSpan -> m Span
makeSpan completedSpan = do
  hot <- liftIO $ readIORef (OT.spanHot completedSpan)
  let startTime = timestampNanoseconds (OT.spanStart completedSpan)
  (parentSpanF, parentRemoteBits) <- do
    case OT.spanParent completedSpan of
      Nothing -> pure (id, 0 :: Word32)
      Just s -> do
        scx <- OT.getSpanContext s
        let remoteBits
              | OT.isRemote scx = 0x300
              | otherwise = 0x100
        pure
          ( \otlpSpan -> otlpSpan & Trace_Fields.parentSpanId .~ spanIdBytes (OT.spanId scx)
          , remoteBits
          )

  let !spanFlags =
        fromIntegral (traceFlagsValue $ OT.traceFlags $ OT.spanContext completedSpan)
          .|. parentRemoteBits

  pure $
    defMessage
      & Trace_Fields.traceId
        .~ traceIdBytes (OT.traceId $ OT.spanContext completedSpan)
      & Trace_Fields.spanId
        .~ spanIdBytes (OT.spanId $ OT.spanContext completedSpan)
      & Trace_Fields.traceState
        .~ TE.decodeUtf8 (encodeTraceStateFull $ OT.traceState $ OT.spanContext completedSpan)
      & Trace_Fields.flags
        .~ spanFlags
      & Trace_Fields.name
        .~ OT.hotName hot
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
        .~ maybe startTime timestampNanoseconds (optionalTimestampToMaybe $ OT.hotEnd hot)
      & Trace_Fields.vec'attributes
        .~ attributesToProto (OT.hotAttributes hot)
      & Trace_Fields.droppedAttributesCount
        .~ fromIntegral (getDropped $ OT.hotAttributes hot)
      & Trace_Fields.vec'events
        .~ fmap makeEvent (appendOnlyBoundedCollectionValues $ OT.hotEvents hot)
      & Trace_Fields.droppedEventsCount
        .~ fromIntegral (appendOnlyBoundedCollectionDroppedElementCount (OT.hotEvents hot))
      & Trace_Fields.vec'links
        .~ fmap makeLink (appendOnlyBoundedCollectionValues $ OT.hotLinks hot)
      & Trace_Fields.droppedLinksCount
        .~ fromIntegral (appendOnlyBoundedCollectionDroppedElementCount (OT.hotLinks hot))
      & Trace_Fields.status
        .~ ( case OT.hotStatus hot of
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
      .~ fromIntegral (getDropped $ OT.eventAttributes e)


makeLink :: OT.Link -> Span'Link
makeLink l =
  let lctx = OT.frozenLinkContext l
      remoteBits :: Word32
      remoteBits
        | OT.isRemote lctx = 0x300
        | otherwise = 0x100
      !linkFlags =
        fromIntegral (traceFlagsValue $ OT.traceFlags lctx) .|. remoteBits
  in defMessage
      & Trace_Fields.traceId
        .~ traceIdBytes (OT.traceId lctx)
      & Trace_Fields.spanId
        .~ spanIdBytes (OT.spanId lctx)
      & Trace_Fields.traceState
        .~ TE.decodeUtf8 (encodeTraceStateFull $ OT.traceState lctx)
      & Trace_Fields.flags
        .~ linkFlags
      & Trace_Fields.vec'attributes
        .~ attributesToProto (OT.frozenLinkAttributes l)
      & Trace_Fields.droppedAttributesCount
        .~ fromIntegral (getDropped $ OT.frozenLinkAttributes l)


attributesToProto :: Attributes -> Vector KeyValue
attributesToProto attrs =
  V.map (uncurry attributeToKeyValue) $
    V.fromListN (H.size m) (H.toList m)
  where
    m = getAttributeMap attrs
    primAttributeToAnyValue = \case
      TextAttribute t -> defMessage & Common_Fields.stringValue .~ t
      BoolAttribute b -> defMessage & Common_Fields.boolValue .~ b
      DoubleAttribute d -> defMessage & Common_Fields.doubleValue .~ d
      IntAttribute i -> defMessage & Common_Fields.intValue .~ i
    attributeToKeyValue :: Text -> Attribute -> KeyValue
    attributeToKeyValue k v =
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
