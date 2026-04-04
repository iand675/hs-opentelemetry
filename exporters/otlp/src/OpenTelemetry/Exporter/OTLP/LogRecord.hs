{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

module OpenTelemetry.Exporter.OTLP.LogRecord (
  otlpLogRecordExporter,
  immutableLogRecordToProto,
) where

import Codec.Compression.GZip (compress)
import Control.Concurrent (threadDelay)
import Control.Exception (SomeAsyncException (..), SomeException (..), fromException, throwIO, try)
import Control.Monad.IO.Class (MonadIO, liftIO)
import Data.Bits (shiftL)
import qualified Data.ByteString as BS
import qualified Data.ByteString.Char8 as C
import qualified Data.ByteString.Lazy as L
import qualified Data.HashMap.Strict as H
import Data.List (isInfixOf)
import Data.Maybe (fromMaybe)
import Data.ProtoLens (defMessage, encodeMessage)
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Vector as V
import Data.Word (Word64)
import Lens.Micro ((&), (.~))
import Network.HTTP.Client
import qualified Network.HTTP.Client as HTTPClient
import Network.HTTP.Simple (httpBS)
import Network.HTTP.Types.Header
import Network.HTTP.Types.Status
import qualified OpenTelemetry.Attributes as A
import OpenTelemetry.Common (Timestamp (..))
import OpenTelemetry.Exporter.OTLP.Span (CompressionFormat (..), OTLPExporterConfig (..))
import OpenTelemetry.Internal.Common.Types
import OpenTelemetry.Internal.Logs.Types
import OpenTelemetry.Internal.Trace.Id (spanIdBytes, traceIdBytes)
import OpenTelemetry.LogAttributes (AnyValue (..), LogAttributes (..))
import OpenTelemetry.Resource (MaterializedResources, emptyMaterializedResources, getMaterializedResourcesAttributes, getMaterializedResourcesSchema)
import OpenTelemetry.Trace.Core (timestampNanoseconds, traceFlagsValue)
import Proto.Opentelemetry.Proto.Collector.Logs.V1.LogsService (ExportLogsServiceRequest)
import qualified Proto.Opentelemetry.Proto.Collector.Logs.V1.LogsService_Fields as LSF
import Proto.Opentelemetry.Proto.Common.V1.Common (InstrumentationScope, KeyValue)
import qualified Proto.Opentelemetry.Proto.Common.V1.Common as Common
import qualified Proto.Opentelemetry.Proto.Common.V1.Common_Fields as CF
import Proto.Opentelemetry.Proto.Logs.V1.Logs (ResourceLogs, ScopeLogs)
import qualified Proto.Opentelemetry.Proto.Logs.V1.Logs as PL
import qualified Proto.Opentelemetry.Proto.Logs.V1.Logs_Fields as LF
import qualified Proto.Opentelemetry.Proto.Resource.V1.Resource as Res
import qualified Proto.Opentelemetry.Proto.Resource.V1.Resource_Fields as RF
import Text.Read (readMaybe)


defaultExporterTimeout :: Int
defaultExporterTimeout = 10_000


httpProtobufMimeType :: C.ByteString
httpProtobufMimeType = "application/x-protobuf"


otlpLogRecordExporter :: (MonadIO m) => OTLPExporterConfig -> m LogRecordExporter
otlpLogRecordExporter conf = liftIO $ do
  req <- parseRequest (logsEndpointUrl conf)
  let (encodingHeaders, encoder) = httpLogsCompression conf
  let baseReq =
        req
          { method = "POST"
          , requestHeaders = encodingHeaders <> httpLogsBaseHeaders conf req
          , responseTimeout = httpLogsResponseTimeout conf
          }
  mkLogRecordExporter
    LogRecordExporterArguments
      { logRecordExporterArgumentsExport = \lrs -> do
          if V.null lrs
            then pure Success
            else do
              result <- try $ exporterExportCall encoder baseReq lrs
              case result of
                Left err -> case fromException err of
                  Just (SomeAsyncException _) -> throwIO err
                  Nothing -> pure $ Failure $ Just err
                Right ok -> pure ok
      , logRecordExporterArgumentsForceFlush = pure ()
      , logRecordExporterArgumentsShutdown = pure ()
      }
  where
    retryDelay = 100_000
    maxRetryCount = 5
    isRetryableStatusCode status_ =
      status_ == status408 || status_ == status429 || (statusCode status_ >= 500 && statusCode status_ < 600)
    isRetryableException = \case
      ResponseTimeout -> True
      ConnectionTimeout -> True
      ConnectionFailure _ -> True
      ConnectionClosed -> True
      _ -> False

    exporterExportCall encoder baseReq lrs = do
      rl <- buildResourceLogsFromBatch lrs
      let exportReq :: ExportLogsServiceRequest
          exportReq =
            defMessage
              & LSF.vec'resourceLogs
                .~ V.singleton rl
      let msg = encodeMessage exportReq
      let req =
            baseReq
              { requestBody = RequestBodyLBS $ encoder $ L.fromStrict msg
              }
      sendReq req 0

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
          , ConnectionFailure _ <- e ->
              pure $ Failure Nothing
          | otherwise ->
              if isRetryableException e
                then exponentialBackoff
                else pure $ Failure $ Just $ SomeException err
        Left err -> pure $ Failure $ Just $ SomeException err
        Right resp ->
          if isRetryableStatusCode (responseStatus resp)
            then case lookup hRetryAfter $ responseHeaders resp of
              Nothing -> exponentialBackoff
              Just retryAfter -> case readMaybe $ C.unpack retryAfter of
                Nothing -> exponentialBackoff
                Just seconds -> do
                  threadDelay (seconds * 1_000_000)
                  sendReq req (backoffCount + 1)
            else
              if statusCode (responseStatus resp) >= 300
                then pure $ Failure Nothing
                else pure Success


groupByScope
  :: H.HashMap InstrumentationLibrary [ReadableLogRecord]
  -> ReadableLogRecord
  -> IO (H.HashMap InstrumentationLibrary [ReadableLogRecord])
groupByScope acc lr = do
  let scope = readLogRecordInstrumentationScope lr
  pure $ H.insertWith (++) scope [lr] acc


buildResourceLogsFromBatch :: V.Vector ReadableLogRecord -> IO ResourceLogs
buildResourceLogsFromBatch lrs = do
  grouped <- V.foldM' groupByScope H.empty lrs
  scopeLogsList <- mapM (uncurry buildScopeLogs) (H.toList grouped)
  let res = if V.null lrs then emptyMaterializedResources else readLogRecordResource (V.head lrs)
  pure $
    defMessage
      & LF.resource
        .~ materializedResourceToProto res
      & LF.vec'scopeLogs
        .~ V.fromList scopeLogsList
      & LF.schemaUrl
        .~ maybe T.empty T.pack (getMaterializedResourcesSchema res)


buildScopeLogs :: InstrumentationLibrary -> [ReadableLogRecord] -> IO ScopeLogs
buildScopeLogs scope lrs = do
  protoRecords <- mapM readableLogRecordToProtoIO lrs
  pure $
    defMessage
      & LF.scope
        .~ instrumentationLibraryToProto scope
      & LF.vec'logRecords
        .~ V.fromList protoRecords
      & LF.schemaUrl
        .~ librarySchemaUrl scope


readableLogRecordToProtoIO :: ReadableLogRecord -> IO PL.LogRecord
readableLogRecordToProtoIO rlr = do
  ilr <- readLogRecord rlr
  pure $ immutableLogRecordToProto ilr


immutableLogRecordToProto :: ImmutableLogRecord -> PL.LogRecord
immutableLogRecordToProto ImmutableLogRecord {..} =
  defMessage
    & LF.timeUnixNano
      .~ maybe 0 tsToNanos logRecordTimestamp
    & LF.observedTimeUnixNano
      .~ tsToNanos logRecordObservedTimestamp
    & LF.severityNumber
      .~ maybe PL.SEVERITY_NUMBER_UNSPECIFIED severityToProto logRecordSeverityNumber
    & LF.severityText
      .~ fromMaybe "" logRecordSeverityText
    & LF.maybe'body
      .~ Just (anyValueToProto logRecordBody)
    & LF.vec'attributes
      .~ logAttributesToProto logRecordAttributes
    & LF.droppedAttributesCount
      .~ fromIntegral (attributesDropped logRecordAttributes)
    & LF.traceId
      .~ maybe BS.empty (\(tid, _, _) -> traceIdBytes tid) logRecordTracingDetails
    & LF.spanId
      .~ maybe BS.empty (\(_, sid, _) -> spanIdBytes sid) logRecordTracingDetails
    & LF.flags
      .~ maybe 0 (\(_, _, fl) -> fromIntegral (traceFlagsValue fl)) logRecordTracingDetails
    & LF.eventName
      .~ fromMaybe "" logRecordEventName


tsToNanos :: Timestamp -> Word64
tsToNanos = fromIntegral . timestampNanoseconds


severityToProto :: SeverityNumber -> PL.SeverityNumber
severityToProto = \case
  Trace -> PL.SEVERITY_NUMBER_TRACE
  Trace2 -> PL.SEVERITY_NUMBER_TRACE2
  Trace3 -> PL.SEVERITY_NUMBER_TRACE3
  Trace4 -> PL.SEVERITY_NUMBER_TRACE4
  Debug -> PL.SEVERITY_NUMBER_DEBUG
  Debug2 -> PL.SEVERITY_NUMBER_DEBUG2
  Debug3 -> PL.SEVERITY_NUMBER_DEBUG3
  Debug4 -> PL.SEVERITY_NUMBER_DEBUG4
  Info -> PL.SEVERITY_NUMBER_INFO
  Info2 -> PL.SEVERITY_NUMBER_INFO2
  Info3 -> PL.SEVERITY_NUMBER_INFO3
  Info4 -> PL.SEVERITY_NUMBER_INFO4
  Warn -> PL.SEVERITY_NUMBER_WARN
  Warn2 -> PL.SEVERITY_NUMBER_WARN2
  Warn3 -> PL.SEVERITY_NUMBER_WARN3
  Warn4 -> PL.SEVERITY_NUMBER_WARN4
  Error -> PL.SEVERITY_NUMBER_ERROR
  Error2 -> PL.SEVERITY_NUMBER_ERROR2
  Error3 -> PL.SEVERITY_NUMBER_ERROR3
  Error4 -> PL.SEVERITY_NUMBER_ERROR4
  Fatal -> PL.SEVERITY_NUMBER_FATAL
  Fatal2 -> PL.SEVERITY_NUMBER_FATAL2
  Fatal3 -> PL.SEVERITY_NUMBER_FATAL3
  Fatal4 -> PL.SEVERITY_NUMBER_FATAL4
  Unknown n -> toEnum n


logAttributesToProto :: LogAttributes -> V.Vector KeyValue
logAttributesToProto LogAttributes {..} =
  V.fromList $ fmap anyValueToKeyValue $ H.toList attributes
  where
    anyValueToKeyValue :: (Text, OpenTelemetry.LogAttributes.AnyValue) -> KeyValue
    anyValueToKeyValue (k, v) =
      defMessage
        & CF.key .~ k
        & CF.value .~ anyValueToProto v


anyValueToProto :: OpenTelemetry.LogAttributes.AnyValue -> Common.AnyValue
anyValueToProto = \case
  TextValue t -> defMessage & CF.stringValue .~ t
  BoolValue b -> defMessage & CF.boolValue .~ b
  DoubleValue d -> defMessage & CF.doubleValue .~ d
  IntValue i -> defMessage & CF.intValue .~ fromIntegral i
  ByteStringValue bs -> defMessage & CF.bytesValue .~ bs
  ArrayValue arr ->
    defMessage
      & CF.arrayValue
        .~ (defMessage & CF.values .~ fmap anyValueToProto arr)
  HashMapValue hm ->
    defMessage
      & CF.kvlistValue
        .~ (defMessage & CF.values .~ fmap (\(k, v) -> defMessage & CF.key .~ k & CF.value .~ anyValueToProto v) (H.toList hm))
  NullValue -> defMessage


materializedResourceToProto :: MaterializedResources -> Res.Resource
materializedResourceToProto r =
  let attrs = getMaterializedResourcesAttributes r
  in defMessage
      & RF.vec'attributes
        .~ attrsToProto attrs
      & RF.droppedAttributesCount
        .~ fromIntegral (A.getCount attrs)


instrumentationLibraryToProto :: InstrumentationLibrary -> InstrumentationScope
instrumentationLibraryToProto InstrumentationLibrary {..} =
  defMessage
    & CF.name .~ libraryName
    & CF.version .~ libraryVersion
    & CF.vec'attributes .~ attrsToProto libraryAttributes
    & CF.droppedAttributesCount .~ fromIntegral (A.getCount libraryAttributes)


attrsToProto :: A.Attributes -> V.Vector KeyValue
attrsToProto =
  V.fromList
    . fmap attrToKeyValue
    . H.toList
    . A.getAttributeMap
  where
    primToAnyValue = \case
      A.TextAttribute t -> defMessage & CF.stringValue .~ t
      A.BoolAttribute b -> defMessage & CF.boolValue .~ b
      A.DoubleAttribute d -> defMessage & CF.doubleValue .~ d
      A.IntAttribute i -> defMessage & CF.intValue .~ i
    attrToKeyValue :: (Text, A.Attribute) -> KeyValue
    attrToKeyValue (k, v) =
      defMessage
        & CF.key .~ k
        & CF.value
          .~ ( case v of
                A.AttributeValue a -> primToAnyValue a
                A.AttributeArray a ->
                  defMessage
                    & CF.arrayValue
                      .~ (defMessage & CF.values .~ fmap primToAnyValue a)
             )


type Encoder = L.ByteString -> L.ByteString


httpLogsCompression :: OTLPExporterConfig -> ([(HeaderName, C.ByteString)], Encoder)
httpLogsCompression conf =
  case otlpCompression conf of
    Just GZip -> ([(hContentEncoding, "gzip")], compress)
    _ -> ([], id)


httpLogsResponseTimeout :: OTLPExporterConfig -> ResponseTimeout
httpLogsResponseTimeout conf = case otlpTimeout conf of
  Just timeoutMilli
    | timeoutMilli == 0 -> responseTimeoutNone
    | timeoutMilli >= 1 -> responseTimeoutMicro (timeoutMilli * 1_000)
  _ -> responseTimeoutMicro (defaultExporterTimeout * 1_000)


httpLogsBaseHeaders :: OTLPExporterConfig -> Request -> RequestHeaders
httpLogsBaseHeaders conf req =
  concat
    [ [(hContentType, httpProtobufMimeType)]
    , [(hAcceptEncoding, httpProtobufMimeType)]
    , fromMaybe [] (otlpHeaders conf)
    , requestHeaders req
    ]


logsEndpointUrl :: OTLPExporterConfig -> String
logsEndpointUrl conf =
  case otlpEndpoint conf of
    Nothing -> "http://localhost:4318/v1/logs"
    Just e ->
      if "/v1/" `isInfixOf` e
        then e
        else trimTrailingSlash e <> "/v1/logs"


trimTrailingSlash :: String -> String
trimTrailingSlash = reverse . dropWhile (== '/') . reverse
