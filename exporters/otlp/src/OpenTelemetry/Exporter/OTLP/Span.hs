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

  -- * Protobuf conversion (testing)
  immutableSpansToProtobuf,
) where

import Codec.Compression.GZip
import Control.Applicative ((<|>))
import Control.Concurrent (threadDelay)
import Control.Exception (SomeAsyncException (..), SomeException (..), fromException, throwIO, try)
import Control.Monad.IO.Class
import Data.Bits (shiftL, (.|.))
import qualified Data.ByteString.Char8 as C
import qualified Data.ByteString.Lazy as L
import qualified Data.CaseInsensitive as CI
import Data.Char (toLower)
import Data.Function ((&))
import Data.HashMap.Strict (HashMap)
import qualified Data.HashMap.Strict as H
import Data.IORef (readIORef)
import Data.Maybe
import Data.Text (Text)
import qualified Data.Text.Encoding as T
import Data.Vector (Vector)
import qualified Data.Vector as V
import qualified Data.Vector as Vector
import qualified Data.Word
import Network.HTTP.Client
import Network.HTTP.Simple (httpBS)
import Network.HTTP.Types.Header
import Network.HTTP.Types.Status
import OpenTelemetry.Attributes
import qualified OpenTelemetry.Baggage as Baggage
import OpenTelemetry.Common (optionalTimestampToMaybe)
import OpenTelemetry.Environment
import OpenTelemetry.Exporter.Span
import OpenTelemetry.Internal.Common.Types (FlushResult (..), ShutdownResult (..))
import OpenTelemetry.Propagator.W3CTraceContext (encodeTraceStateFull)
import OpenTelemetry.Resource
import OpenTelemetry.Trace.Core (timestampNanoseconds)
import qualified OpenTelemetry.Trace.Core as OT
import OpenTelemetry.Trace.Id (spanIdBytes, traceIdBytes)
import OpenTelemetry.Util
import Proto.Encode (encodeMessage)
import Proto.OpenTelemetry.Proto.Collector.Trace.V1.TraceService (ExportTraceServiceRequest, defaultExportTraceServiceRequest)
import qualified Proto.OpenTelemetry.Proto.Collector.Trace.V1.TraceService as PCT
import qualified Proto.OpenTelemetry.Proto.Common.V1.Common as PC
import qualified Proto.OpenTelemetry.Proto.Resource.V1.Resource as PR
import qualified Proto.OpenTelemetry.Proto.Trace.V1.Trace as PT
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
    <*> (traverse decodeHeaders =<< lookupEnv "OTEL_EXPORTER_OTLP_HEADERS")
    <*> (traverse decodeHeaders =<< lookupEnv "OTEL_EXPORTER_OTLP_TRACES_HEADERS")
    <*> (traverse decodeHeaders =<< lookupEnv "OTEL_EXPORTER_OTLP_METRICS_HEADERS")
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
      Left err -> do
        putWarningLn $ "Warning: failed to parse OTEL_EXPORTER_OTLP_HEADERS: " <> show err
        pure mempty
      Right baggageFmt ->
        pure $ (\(k, v) -> (CI.mk $ Baggage.tokenValue k, T.encodeUtf8 $ Baggage.value v)) <$> H.toList (Baggage.values baggageFmt)


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
      , spanExporterShutdown = pure ShutdownSuccess
      , spanExporterForceFlush = pure FlushSuccess
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
        Left (HttpExceptionRequest _req' e)
          | isRetryableException e -> exponentialBackoff
        Left err ->
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
                then pure $ Failure Nothing
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
httpHost conf = fromMaybe defaultHost $ otlpTracesEndpoint conf <|> otlpEndpoint conf
  where
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
    , [(hAccept, httpProtobufMimeType)]
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
    defaultExportTraceServiceRequest
      { PCT.exportTraceServiceRequestResourceSpans =
          Vector.singleton
            PT.defaultResourceSpans
              { PT.resourceSpansResource =
                  Just
                    PR.defaultResource
                      { PR.resourceAttributes =
                          attributesToProto (getMaterializedResourcesAttributes someResourceGroup)
                      , -- TODO
                        PR.resourceDroppedAttributesCount = 0
                      }
              , -- TODO, seems like spans need to be emitted via an API
                -- that lets us keep them grouped by instrumentation originator
                PT.resourceSpansScopeSpans = Vector.fromList spansByLibrary
              }
      }
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
makeScopeSpans :: (MonadIO m) => (OT.InstrumentationLibrary, Vector OT.ImmutableSpan) -> m PT.ScopeSpans
makeScopeSpans (library, completedSpans_) = do
  spans_ <- mapM makeSpan completedSpans_
  pure $
    PT.defaultScopeSpans
      { PT.scopeSpansScope =
          Just
            PC.defaultInstrumentationScope
              { PC.instrumentationScopeName = OT.libraryName library
              , PC.instrumentationScopeVersion = OT.libraryVersion library
              }
      , PT.scopeSpansSpans = spans_
      }


{- |
Internal helper.
Translate an `OT.ImmutableSpan` span to an OTLP `Span`.
-}
makeSpan :: (MonadIO m) => OT.ImmutableSpan -> m PT.Span
makeSpan completedSpan = do
  hot <- liftIO $ readIORef (OT.spanHot completedSpan)
  let startTime = timestampNanoseconds (OT.spanStart completedSpan)
  parentSpanId_ <- case OT.spanParent completedSpan of
    Nothing -> pure mempty
    Just s -> spanIdBytes . OT.spanId <$> OT.getSpanContext s

  pure $
    PT.defaultSpan
      { PT.spanTraceId = traceIdBytes (OT.traceId $ OT.spanContext completedSpan)
      , PT.spanSpanId = spanIdBytes (OT.spanId $ OT.spanContext completedSpan)
      , PT.spanParentSpanId = parentSpanId_
      , PT.spanTraceState = T.decodeUtf8 (encodeTraceStateFull $ OT.traceState $ OT.spanContext completedSpan)
      , PT.spanFlags = fromIntegral (OT.traceFlagsValue $ OT.traceFlags $ OT.spanContext completedSpan)
      , PT.spanName = OT.hotName hot
      , PT.spanKind =
          case OT.spanKind completedSpan of
            OT.Server -> PT.Span'SpanKind'SpanKindServer
            OT.Client -> PT.Span'SpanKind'SpanKindClient
            OT.Producer -> PT.Span'SpanKind'SpanKindProducer
            OT.Consumer -> PT.Span'SpanKind'SpanKindConsumer
            OT.Internal -> PT.Span'SpanKind'SpanKindInternal
      , PT.spanStartTimeUnixNano = startTime
      , PT.spanEndTimeUnixNano = maybe startTime timestampNanoseconds (optionalTimestampToMaybe (OT.hotEnd hot))
      , PT.spanAttributes = attributesToProto (OT.hotAttributes hot)
      , PT.spanDroppedAttributesCount = fromIntegral (getDropped $ OT.hotAttributes hot)
      , PT.spanEvents = fmap makeEvent (appendOnlyBoundedCollectionValues $ OT.hotEvents hot)
      , PT.spanDroppedEventsCount = fromIntegral (appendOnlyBoundedCollectionDroppedElementCount (OT.hotEvents hot))
      , PT.spanLinks = fmap makeLink (appendOnlyBoundedCollectionValues $ OT.hotLinks hot)
      , PT.spanDroppedLinksCount = fromIntegral (appendOnlyBoundedCollectionDroppedElementCount (OT.hotLinks hot))
      , PT.spanStatus =
          Just $ case OT.hotStatus hot of
            OT.Unset -> PT.defaultStatus {PT.statusCode = PT.Status'StatusCode'StatusCodeUnset}
            OT.Ok -> PT.defaultStatus {PT.statusCode = PT.Status'StatusCode'StatusCodeOk}
            OT.Error e ->
              PT.defaultStatus
                { PT.statusCode = PT.Status'StatusCode'StatusCodeError
                , PT.statusMessage = e
                }
      }


{- |
Internal helper.
Translate an `OT.Event` to an OTLP `Span'Event`.
-}
makeEvent :: OT.Event -> PT.Span'Event
makeEvent e =
  PT.defaultSpan'Event
    { PT.spanEventTimeUnixNano = timestampNanoseconds (OT.eventTimestamp e)
    , PT.spanEventName = OT.eventName e
    , PT.spanEventAttributes = attributesToProto (OT.eventAttributes e)
    , PT.spanEventDroppedAttributesCount = fromIntegral (getDropped $ OT.eventAttributes e)
    }


{- |
Internal helper.
Translate an `OT.Link` to an OTLP `Span'Link`.
-}
makeLink :: OT.Link -> PT.Span'Link
makeLink l =
  PT.defaultSpan'Link
    { PT.spanLinkTraceId = traceIdBytes (OT.traceId ctx)
    , PT.spanLinkSpanId = spanIdBytes (OT.spanId ctx)
    , PT.spanLinkTraceState = T.decodeUtf8 (encodeTraceStateFull $ OT.traceState ctx)
    , PT.spanLinkFlags = linkFlags ctx
    , PT.spanLinkAttributes = attributesToProto (OT.frozenLinkAttributes l)
    , PT.spanLinkDroppedAttributesCount = fromIntegral (getDropped $ OT.frozenLinkAttributes l)
    }
  where
    ctx = OT.frozenLinkContext l


{- |
Internal helper.
Translate a collection of `Attributes` to a vector of OTLP `KeyValue` pairs.
-}

-- | OTLP link flags: bits 0-7 = W3C trace flags, bit 8 = HAS_IS_REMOTE, bit 9 = IS_REMOTE.
linkFlags :: OT.SpanContext -> Data.Word.Word32
linkFlags ctx =
  let w8flags = fromIntegral (OT.traceFlagsValue $ OT.traceFlags ctx) :: Data.Word.Word32
      hasIsRemote = 1 `shiftL` 8
      isRemoteBit = if OT.isRemote ctx then 1 `shiftL` 9 else 0
  in w8flags .|. hasIsRemote .|. isRemoteBit


attributesToProto :: Attributes -> Vector PC.KeyValue
attributesToProto =
  V.fromList
    . fmap attributeToKeyValue
    . H.toList
    . snd
    . ((,) <$> getCount <*> getAttributeMap)
  where
    primAttributeToAnyValue = \case
      TextAttribute t -> wrapAnyValue (PC.AnyValue'Value'StringValue t)
      BoolAttribute b -> wrapAnyValue (PC.AnyValue'Value'BoolValue b)
      DoubleAttribute d -> wrapAnyValue (PC.AnyValue'Value'DoubleValue d)
      IntAttribute i -> wrapAnyValue (PC.AnyValue'Value'IntValue i)
    attributeToKeyValue :: (Text, Attribute) -> PC.KeyValue
    attributeToKeyValue (k, v) =
      PC.defaultKeyValue
        { PC.keyValueKey = k
        , PC.keyValueValue =
            Just $ case v of
              AttributeValue a -> primAttributeToAnyValue a
              AttributeArray a ->
                wrapAnyValue
                  ( PC.AnyValue'Value'ArrayValue
                      PC.defaultArrayValue
                        {PC.arrayValueValues = V.fromList (fmap primAttributeToAnyValue a)}
                  )
        }
    wrapAnyValue :: PC.AnyValue'Value -> PC.AnyValue
    wrapAnyValue v = PC.defaultAnyValue {PC.anyValueValue = Just v}
