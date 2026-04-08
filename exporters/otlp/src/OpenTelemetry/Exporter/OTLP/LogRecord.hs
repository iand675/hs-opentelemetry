{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TupleSections #-}

module OpenTelemetry.Exporter.OTLP.LogRecord where

import Control.Applicative ((<|>))
import Control.Concurrent (threadDelay)
import Control.Exception (SomeAsyncException (..), SomeException (..), fromException, throwIO, try)
import Control.Monad.IO.Class
import Data.Bits (shiftL)
import qualified Data.ByteString.Char8 as ByteString
import qualified Data.ByteString.Lazy as LazyByteString
import Data.HashMap.Strict (HashMap)
import qualified Data.HashMap.Strict as HashMap
import Data.ProtoLens.Encoding
import Data.ProtoLens.Message
import Data.Text (Text)
import qualified Data.Text as Text
import Data.Vector (Vector)
import qualified Data.Vector as Vector
import Lens.Micro
import Network.HTTP.Client
import qualified Network.HTTP.Client as HTTPClient
import Network.HTTP.Simple (httpBS)
import Network.HTTP.Types.Header
import Network.HTTP.Types.Status
import OpenTelemetry.Attributes
import OpenTelemetry.Common (TraceFlags (..))
import OpenTelemetry.Exporter.LogRecord
import OpenTelemetry.Exporter.OTLP.Config
import qualified OpenTelemetry.Internal.Common.Types as OT
import OpenTelemetry.Internal.Logs.Types (ImmutableLogRecord (..), IsReadableLogRecord (..), readLogRecordResource)
import qualified OpenTelemetry.Internal.Logs.Types as OT
import OpenTelemetry.Internal.Trace.Id
import OpenTelemetry.LogAttributes (LogAttributes (..))
import OpenTelemetry.Resource hiding (Resource)
import OpenTelemetry.Trace.Core (timestampNanoseconds)
import Proto.Opentelemetry.Proto.Collector.Logs.V1.LogsService (ExportLogsServiceRequest)
import Proto.Opentelemetry.Proto.Common.V1.Common
import qualified Proto.Opentelemetry.Proto.Common.V1.Common_Fields as Common_Fields
import Proto.Opentelemetry.Proto.Logs.V1.Logs
import qualified Proto.Opentelemetry.Proto.Logs.V1.Logs_Fields as Logs_Fields
import Proto.Opentelemetry.Proto.Resource.V1.Resource
import qualified Proto.Opentelemetry.Proto.Resource.V1.Resource_Fields as Resource_Fields
import Text.Read (readMaybe)
import qualified VectorBuilder.Builder as VectorBuilder
import qualified VectorBuilder.Vector as VectorBuilder


otlpExporter :: (MonadIO m) => OTLPExporterConfig -> m LogRecordExporter
otlpExporter = httpOtlpExporter


--------------------------------------------------------------------------------
-- OTLP Exporter using HTTP/Protobuf.
--------------------------------------------------------------------------------

{- |
Internal helper.
Construct a `LogRecordExporter` that uses HTTP/Protobuf.
-}
httpOtlpExporter :: (MonadIO m) => OTLPExporterConfig -> m LogRecordExporter
httpOtlpExporter conf = do
  -- TODO url parsing is jankym
  -- TODO make retryDelay and maximum retry counts configurable
  req <- liftIO $ parseRequest (httpHost conf <> "/v1/logs")
  let (encodingHeaders, encoder) = httpCompression conf
  let baseReq =
        req
          { method = "POST"
          , requestHeaders = encodingHeaders <> httpBaseHeaders conf req
          , responseTimeout = httpLogsResponseTimeout conf
          }
  liftIO $
    mkLogRecordExporter
      LogRecordExporterArguments
        { logRecordExporterArgumentsExport = \logs_ -> do
            let anySpansToExport = not $ Vector.null logs_
            if anySpansToExport
              then do
                result <- try $ exporterExportCall encoder baseReq logs_
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
        , logRecordExporterArgumentsShutdown = pure ()
        , logRecordExporterArgumentsForceFlush = pure ()
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

    exporterExportCall encoder baseReq logs_ = do
      msg <- encodeMessage <$> readableLogRecordsToProtobuf logs_
      -- TODO handle server disconnect
      let req =
            baseReq
              { requestBody =
                  RequestBodyLBS $ encoder $ LazyByteString.fromStrict msg
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
                case readMaybe $ ByteString.unpack retryAfter of
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
httpLogsResponseTimeout :: OTLPExporterConfig -> ResponseTimeout
httpLogsResponseTimeout conf = case otlpLogsTimeout conf <|> otlpTimeout conf of
  Just timeoutMilli
    | timeoutMilli == 0 -> responseTimeoutNone
    | timeoutMilli >= 1 -> responseTimeoutMilli timeoutMilli
  _otherwise -> responseTimeoutMilli defaultExporterTimeout
  where
    responseTimeoutMilli :: Int -> ResponseTimeout
    responseTimeoutMilli = responseTimeoutMicro . (* 1_000)


--------------------------------------------------------------------------------
-- Convert from `hs-opentelemetry-api` data model into OTLP Protobuf.
--------------------------------------------------------------------------------

readableLogRecordsToProtobuf :: (MonadIO m) => Vector OT.ReadableLogRecord -> m ExportLogsServiceRequest
readableLogRecordsToProtobuf logs = do
  logRecords <- liftIO . Vector.forM logs $ \l -> (readLogRecordResource l,readLogRecordInstrumentationScope l,) <$> readLogRecord l
  let
    resources :: HashMap MaterializedResources (HashMap OT.InstrumentationLibrary (Vector OT.ImmutableLogRecord))
    resources =
      HashMap.fromListWith
        (HashMap.unionWith (<>))
        ( Vector.toList logRecords <&> \(resource, scope, record) ->
            ( resource
            , HashMap.singleton scope (VectorBuilder.singleton record)
            )
        )
        & (fmap . fmap) VectorBuilder.build
  pure $
    defMessage
      & Logs_Fields.resourceLogs .~ (uncurry makeResourceLogs <$> HashMap.toList resources)


makeResourceProto :: MaterializedResources -> Resource
makeResourceProto r =
  defMessage
    & Resource_Fields.vec'attributes .~ attributesToProto (getMaterializedResourcesAttributes r)
    -- TODO
    & Resource_Fields.droppedAttributesCount .~ 0


makeResourceLogs :: MaterializedResources -> HashMap OT.InstrumentationLibrary (Vector OT.ImmutableLogRecord) -> ResourceLogs
makeResourceLogs resource scopeLogs =
  defMessage
    & Logs_Fields.resource .~ makeResourceProto resource
    & maybe id ((Logs_Fields.schemaUrl .~) . Text.pack) (getMaterializedResourcesSchema resource)
    & Logs_Fields.scopeLogs .~ (uncurry makeScopeLogs <$> HashMap.toList scopeLogs)


makeScopeLogs :: OT.InstrumentationLibrary -> Vector OT.ImmutableLogRecord -> ScopeLogs
makeScopeLogs scope lrs =
  defMessage
    & Logs_Fields.scope
      .~ ( defMessage
            & Common_Fields.name .~ OT.libraryName scope
            & Common_Fields.version .~ OT.libraryVersion scope
         )
    & Logs_Fields.schemaUrl .~ OT.librarySchemaUrl scope
    & Logs_Fields.vec'logRecords .~ (makeLogRecord <$> lrs)


makeLogRecord :: OT.ImmutableLogRecord -> LogRecord
makeLogRecord logRecord =
  defMessage
    & Logs_Fields.timeUnixNano .~ maybe 0 timestampNanoseconds (logRecordTimestamp logRecord)
    & Logs_Fields.observedTimeUnixNano .~ timestampNanoseconds (logRecordObservedTimestamp logRecord)
    & maybe id (Logs_Fields.severityNumber .~) (maybeToEnum . fromEnum =<< logRecordSeverityNumber logRecord)
    & maybe id (Logs_Fields.severityText .~) (logRecordSeverityText logRecord)
    & maybe id (Logs_Fields.eventName .~) (logRecordEventName logRecord)
    & Logs_Fields.body .~ anyValueToProto (logRecordBody logRecord)
    & Logs_Fields.vec'attributes .~ logAttributesToProto (logRecordAttributes logRecord)
    & Logs_Fields.droppedAttributesCount .~ (fromIntegral . attributesDropped) (logRecordAttributes logRecord)
    & maybe
      id
      ( \(traceId, spanId, TraceFlags traceFlags) ->
          (Logs_Fields.flags .~ fromIntegral traceFlags)
            . (Logs_Fields.traceId .~ traceIdBytes traceId)
            . (Logs_Fields.spanId .~ spanIdBytes spanId)
      )
      (logRecordTracingDetails logRecord)


anyValueToProto :: OT.AnyValue -> AnyValue
anyValueToProto v =
  defMessage
    & ( case v of
          OT.TextValue t -> Common_Fields.stringValue .~ t
          OT.BoolValue b -> Common_Fields.boolValue .~ b
          OT.DoubleValue d -> Common_Fields.doubleValue .~ d
          OT.IntValue i -> Common_Fields.intValue .~ i
          OT.ByteStringValue bs -> Common_Fields.bytesValue .~ bs
          OT.ArrayValue xs -> Common_Fields.arrayValue .~ (defMessage & Common_Fields.values .~ (anyValueToProto <$> xs))
          OT.HashMapValue h -> Common_Fields.kvlistValue .~ (defMessage & Common_Fields.values .~ (keyAnyValueToProto <$> HashMap.toList h))
          OT.NullValue -> id
      )


keyAnyValueToProto :: (Text, OT.AnyValue) -> KeyValue
keyAnyValueToProto (key, val) =
  defMessage
    & Common_Fields.key .~ key
    & Common_Fields.value .~ anyValueToProto val


{- |
Internal helper.
Translate a collection of `Attributes` to a vector of OTLP `KeyValue` pairs.
-}
attributesToProto :: Attributes -> Vector KeyValue
attributesToProto =
  Vector.fromList
    . fmap attributeToKeyValue
    . HashMap.toList
    . getAttributeMap
  where
    primAttributeToAnyValue = \case
      TextAttribute t -> defMessage & Common_Fields.stringValue .~ t
      BoolAttribute b -> defMessage & Common_Fields.boolValue .~ b
      DoubleAttribute d -> defMessage & Common_Fields.doubleValue .~ d
      IntAttribute i -> defMessage & Common_Fields.intValue .~ i
    attributeToKeyValue :: (Text, Attribute) -> KeyValue
    attributeToKeyValue (k, v) =
      defMessage
        & Common_Fields.key .~ k
        & Common_Fields.value
          .~ ( case v of
                AttributeValue a -> primAttributeToAnyValue a
                AttributeArray a ->
                  defMessage
                    & Common_Fields.arrayValue
                      .~ (defMessage & Common_Fields.values .~ fmap primAttributeToAnyValue a)
             )


logAttributesToProto :: LogAttributes -> Vector KeyValue
logAttributesToProto =
  Vector.fromList
    . fmap keyAnyValueToProto
    . HashMap.toList
    . attributes
