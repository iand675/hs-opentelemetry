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
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Vector as V
import Data.Word (Word64)
import Network.HTTP.Client
import Network.HTTP.Simple (httpBS)
import Network.HTTP.Types.Header
import Network.HTTP.Types.Status
import qualified OpenTelemetry.Attributes as A
import OpenTelemetry.Common (Timestamp (..))
import OpenTelemetry.Exporter.OTLP.Span (CompressionFormat (..), OTLPExporterConfig (..))
import OpenTelemetry.Internal.Common.Types
import OpenTelemetry.Internal.Log.Types
import OpenTelemetry.Internal.Trace.Id (spanIdBytes, traceIdBytes)
import OpenTelemetry.LogAttributes (AnyValue (..), LogAttributes (..))
import OpenTelemetry.Resource (MaterializedResources, emptyMaterializedResources, getMaterializedResourcesAttributes, getMaterializedResourcesSchema)
import OpenTelemetry.Trace.Core (timestampNanoseconds, traceFlagsValue)
import Proto.Encode (encodeMessage)
import Proto.OpenTelemetry.Proto.Collector.Logs.V1.LogsService (ExportLogsServiceRequest, defaultExportLogsServiceRequest)
import qualified Proto.OpenTelemetry.Proto.Collector.Logs.V1.LogsService as LSF
import Proto.OpenTelemetry.Proto.Common.V1.Common (KeyValue)
import qualified Proto.OpenTelemetry.Proto.Common.V1.Common as Common
import Proto.OpenTelemetry.Proto.Logs.V1.Logs (ResourceLogs, ScopeLogs)
import qualified Proto.OpenTelemetry.Proto.Logs.V1.Logs as PL
import qualified Proto.OpenTelemetry.Proto.Resource.V1.Resource as Res
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
      , logRecordExporterArgumentsForceFlush = pure FlushSuccess
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
            defaultExportLogsServiceRequest
              { LSF.exportLogsServiceRequestResourceLogs = V.singleton rl
              }
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
        Left (HttpExceptionRequest _req' e)
          | isRetryableException e -> exponentialBackoff
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
    PL.defaultResourceLogs
      { PL.resourceLogsResource = Just (materializedResourceToProto res)
      , PL.resourceLogsScopeLogs = V.fromList scopeLogsList
      , PL.resourceLogsSchemaUrl = maybe T.empty T.pack (getMaterializedResourcesSchema res)
      }


buildScopeLogs :: InstrumentationLibrary -> [ReadableLogRecord] -> IO ScopeLogs
buildScopeLogs scope lrs = do
  protoRecords <- mapM readableLogRecordToProtoIO lrs
  pure $
    PL.defaultScopeLogs
      { PL.scopeLogsScope = Just (instrumentationLibraryToProto scope)
      , PL.scopeLogsLogRecords = V.fromList protoRecords
      , PL.scopeLogsSchemaUrl = librarySchemaUrl scope
      }


readableLogRecordToProtoIO :: ReadableLogRecord -> IO PL.LogRecord
readableLogRecordToProtoIO rlr = do
  ilr <- readLogRecord rlr
  pure $ immutableLogRecordToProto ilr


immutableLogRecordToProto :: ImmutableLogRecord -> PL.LogRecord
immutableLogRecordToProto ImmutableLogRecord {..} =
  PL.defaultLogRecord
    { PL.logRecordTimeUnixNano = maybe 0 tsToNanos (toBaseMaybe logRecordTimestamp)
    , PL.logRecordObservedTimeUnixNano = tsToNanos logRecordObservedTimestamp
    , PL.logRecordSeverityNumber =
        maybe PL.SeverityNumber'SeverityNumberUnspecified severityToProto (toBaseMaybe logRecordSeverityNumber)
    , PL.logRecordSeverityText = fromMaybe "" (toBaseMaybe logRecordSeverityText)
    , PL.logRecordBody = Just (anyValueToProto logRecordBody)
    , PL.logRecordAttributes = logAttributesToProto logRecordAttributes
    , PL.logRecordDroppedAttributesCount = fromIntegral (attributesDropped logRecordAttributes)
    , PL.logRecordTraceId =
        case logRecordTracingDetails of
          TracingDetails tid _ _ -> traceIdBytes tid
          NoTracingDetails -> BS.empty
    , PL.logRecordSpanId =
        case logRecordTracingDetails of
          TracingDetails _ sid _ -> spanIdBytes sid
          NoTracingDetails -> BS.empty
    , PL.logRecordFlags =
        case logRecordTracingDetails of
          TracingDetails _ _ fl -> fromIntegral (traceFlagsValue fl)
          NoTracingDetails -> 0
    , PL.logRecordEventName = fromMaybe "" (toBaseMaybe logRecordEventName)
    }


tsToNanos :: Timestamp -> Word64
tsToNanos = fromIntegral . timestampNanoseconds


severityToProto :: SeverityNumber -> PL.SeverityNumber
severityToProto = \case
  Trace -> PL.SeverityNumber'SeverityNumberTrace
  Trace2 -> PL.SeverityNumber'SeverityNumberTrace2
  Trace3 -> PL.SeverityNumber'SeverityNumberTrace3
  Trace4 -> PL.SeverityNumber'SeverityNumberTrace4
  Debug -> PL.SeverityNumber'SeverityNumberDebug
  Debug2 -> PL.SeverityNumber'SeverityNumberDebug2
  Debug3 -> PL.SeverityNumber'SeverityNumberDebug3
  Debug4 -> PL.SeverityNumber'SeverityNumberDebug4
  Info -> PL.SeverityNumber'SeverityNumberInfo
  Info2 -> PL.SeverityNumber'SeverityNumberInfo2
  Info3 -> PL.SeverityNumber'SeverityNumberInfo3
  Info4 -> PL.SeverityNumber'SeverityNumberInfo4
  Warn -> PL.SeverityNumber'SeverityNumberWarn
  Warn2 -> PL.SeverityNumber'SeverityNumberWarn2
  Warn3 -> PL.SeverityNumber'SeverityNumberWarn3
  Warn4 -> PL.SeverityNumber'SeverityNumberWarn4
  Error -> PL.SeverityNumber'SeverityNumberError
  Error2 -> PL.SeverityNumber'SeverityNumberError2
  Error3 -> PL.SeverityNumber'SeverityNumberError3
  Error4 -> PL.SeverityNumber'SeverityNumberError4
  Fatal -> PL.SeverityNumber'SeverityNumberFatal
  Fatal2 -> PL.SeverityNumber'SeverityNumberFatal2
  Fatal3 -> PL.SeverityNumber'SeverityNumberFatal3
  Fatal4 -> PL.SeverityNumber'SeverityNumberFatal4
  Unknown _ -> PL.SeverityNumber'SeverityNumberUnspecified


wrapAnyValue :: Common.AnyValue'Value -> Common.AnyValue
wrapAnyValue v = Common.defaultAnyValue {Common.anyValueValue = Just v}


logAttributesToProto :: LogAttributes -> V.Vector KeyValue
logAttributesToProto LogAttributes {..} =
  V.fromList $ fmap anyValueToKeyValue $ H.toList attributes
  where
    anyValueToKeyValue :: (Text, OpenTelemetry.LogAttributes.AnyValue) -> KeyValue
    anyValueToKeyValue (k, v) =
      Common.defaultKeyValue
        { Common.keyValueKey = k
        , Common.keyValueValue = Just (anyValueToProto v)
        }


anyValueToProto :: OpenTelemetry.LogAttributes.AnyValue -> Common.AnyValue
anyValueToProto = \case
  TextValue t -> wrapAnyValue (Common.AnyValue'Value'StringValue t)
  BoolValue b -> wrapAnyValue (Common.AnyValue'Value'BoolValue b)
  DoubleValue d -> wrapAnyValue (Common.AnyValue'Value'DoubleValue d)
  IntValue i -> wrapAnyValue (Common.AnyValue'Value'IntValue (fromIntegral i))
  ByteStringValue bs -> wrapAnyValue (Common.AnyValue'Value'BytesValue bs)
  ArrayValue arr ->
    wrapAnyValue
      ( Common.AnyValue'Value'ArrayValue
          Common.defaultArrayValue {Common.arrayValueValues = V.fromList (fmap anyValueToProto arr)}
      )
  HashMapValue hm ->
    wrapAnyValue
      ( Common.AnyValue'Value'KvlistValue
          Common.defaultKeyValueList
            { Common.keyValueListValues =
                V.fromList
                  ( fmap
                      ( \(k, v) ->
                          Common.defaultKeyValue
                            { Common.keyValueKey = k
                            , Common.keyValueValue = Just (anyValueToProto v)
                            }
                      )
                      (H.toList hm)
                  )
            }
      )
  NullValue -> Common.defaultAnyValue


materializedResourceToProto :: MaterializedResources -> Res.Resource
materializedResourceToProto r =
  let attrs = getMaterializedResourcesAttributes r
  in Res.defaultResource
       { Res.resourceAttributes = attrsToProto attrs
       , Res.resourceDroppedAttributesCount = fromIntegral (A.getDropped attrs)
       }


instrumentationLibraryToProto :: InstrumentationLibrary -> Common.InstrumentationScope
instrumentationLibraryToProto InstrumentationLibrary {..} =
  Common.defaultInstrumentationScope
    { Common.instrumentationScopeName = libraryName
    , Common.instrumentationScopeVersion = libraryVersion
    , Common.instrumentationScopeAttributes = attrsToProto libraryAttributes
    , Common.instrumentationScopeDroppedAttributesCount = fromIntegral (A.getDropped libraryAttributes)
    }


attrsToProto :: A.Attributes -> V.Vector KeyValue
attrsToProto =
  V.fromList
    . fmap attrToKeyValue
    . H.toList
    . A.getAttributeMap
  where
    primToAnyValue = \case
      A.TextAttribute t -> wrapAnyValue (Common.AnyValue'Value'StringValue t)
      A.BoolAttribute b -> wrapAnyValue (Common.AnyValue'Value'BoolValue b)
      A.DoubleAttribute d -> wrapAnyValue (Common.AnyValue'Value'DoubleValue d)
      A.IntAttribute i -> wrapAnyValue (Common.AnyValue'Value'IntValue i)
    attrToKeyValue :: (Text, A.Attribute) -> KeyValue
    attrToKeyValue (k, v) =
      Common.defaultKeyValue
        { Common.keyValueKey = k
        , Common.keyValueValue =
            Just
              ( case v of
                  A.AttributeValue a -> primToAnyValue a
                  A.AttributeArray a ->
                    wrapAnyValue
                      ( Common.AnyValue'Value'ArrayValue
                          Common.defaultArrayValue {Common.arrayValueValues = V.fromList (fmap primToAnyValue a)}
                      )
              )
        }


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
    , [(hAccept, httpProtobufMimeType)]
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
