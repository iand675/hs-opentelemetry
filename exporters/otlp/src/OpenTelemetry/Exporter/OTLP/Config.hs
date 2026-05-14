{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.Exporter.OTLP.Config where

import qualified Codec.Compression.GZip as GZip
import Control.Applicative ((<|>))
import Control.Monad.IO.Class (MonadIO (..))
import Data.ByteString.Char8 (ByteString)
import qualified Data.ByteString.Char8 as ByteString
import Data.ByteString.Lazy (LazyByteString)
import qualified Data.CaseInsensitive as CI
import Data.Char (toLower)
import Data.Function ((&))
import qualified Data.HashMap.Strict as HashMap
import Data.Maybe (fromMaybe)
import Data.String (IsString)
import qualified Data.Text.Encoding as Text
import Network.HTTP.Client (Request, requestHeaders)
import Network.HTTP.Types.Header
import qualified OpenTelemetry.Baggage as Baggage
import OpenTelemetry.Environment (lookupBooleanEnv)
import System.Environment (lookupEnv)
import qualified System.IO as IO
import Text.Read (readMaybe)


data OTLPExporterConfig = OTLPExporterConfig
  { otlpEndpoint :: Maybe String
  , otlpTracesEndpoint :: Maybe String
  , otlpMetricsEndpoint :: Maybe String
  , otlpLogsEndpoint :: Maybe String
  , otlpInsecure :: Bool
  , otlpSpanInsecure :: Bool
  , otlpMetricInsecure :: Bool
  , otlpLogInsecure :: Bool
  , otlpCertificate :: Maybe FilePath
  , otlpTracesCertificate :: Maybe FilePath
  , otlpMetricsCertificate :: Maybe FilePath
  , otlpLogsCertificate :: Maybe FilePath
  , otlpHeaders :: Maybe [Header]
  , otlpTracesHeaders :: Maybe [Header]
  , otlpMetricsHeaders :: Maybe [Header]
  , otlpLogsHeaders :: Maybe [Header]
  , otlpCompression :: Maybe CompressionFormat
  , otlpTracesCompression :: Maybe CompressionFormat
  , otlpMetricsCompression :: Maybe CompressionFormat
  , otlpLogsCompression :: Maybe CompressionFormat
  , otlpTimeout :: Maybe Int
  -- ^ Measured in milliseconds.
  , otlpTracesTimeout :: Maybe Int
  -- ^ Measured in milliseconds.
  , otlpMetricsTimeout :: Maybe Int
  -- ^ Measured in milliseconds.
  , otlpLogsTimeout :: Maybe Int
  -- ^ Measured in milliseconds.
  , otlpProtocol :: Maybe Protocol
  , otlpTracesProtocol :: Maybe Protocol
  , otlpMetricsProtocol :: Maybe Protocol
  , otlpLogsProtocol :: Maybe Protocol
  }


loadExporterEnvironmentVariables :: (MonadIO m) => m OTLPExporterConfig
loadExporterEnvironmentVariables = liftIO $ do
  OTLPExporterConfig
    <$> lookupEnv "OTEL_EXPORTER_OTLP_ENDPOINT"
    <*> lookupEnv "OTEL_EXPORTER_OTLP_TRACES_ENDPOINT"
    <*> lookupEnv "OTEL_EXPORTER_OTLP_METRICS_ENDPOINT"
    <*> lookupEnv "OTEL_EXPORTER_OTLP_LOGS_ENDPOINT"
    <*> lookupBooleanEnv "OTEL_EXPORTER_OTLP_INSECURE"
    <*> lookupBooleanEnv "OTEL_EXPORTER_OTLP_SPAN_INSECURE"
    <*> lookupBooleanEnv "OTEL_EXPORTER_OTLP_METRIC_INSECURE"
    <*> lookupBooleanEnv "OTEL_EXPORTER_OTLP_LOG_INSECURE"
    <*> lookupEnv "OTEL_EXPORTER_OTLP_CERTIFICATE"
    <*> lookupEnv "OTEL_EXPORTER_OTLP_TRACES_CERTIFICATE"
    <*> lookupEnv "OTEL_EXPORTER_OTLP_METRICS_CERTIFICATE"
    <*> lookupEnv "OTEL_EXPORTER_OTLP_LOGS_CERTIFICATE"
    <*> (fmap decodeHeaders <$> lookupEnv "OTEL_EXPORTER_OTLP_HEADERS")
    <*> (fmap decodeHeaders <$> lookupEnv "OTEL_EXPORTER_OTLP_TRACES_HEADERS")
    <*> (fmap decodeHeaders <$> lookupEnv "OTEL_EXPORTER_OTLP_METRICS_HEADERS")
    <*> (fmap decodeHeaders <$> lookupEnv "OTEL_EXPORTER_OTLP_LOGS_HEADERS")
    <*> (traverse readCompressionFormat =<< lookupEnv "OTEL_EXPORTER_OTLP_COMPRESSION")
    <*> (traverse readCompressionFormat =<< lookupEnv "OTEL_EXPORTER_OTLP_TRACES_COMPRESSION")
    <*> (traverse readCompressionFormat =<< lookupEnv "OTEL_EXPORTER_OTLP_METRICS_COMPRESSION")
    <*> (traverse readCompressionFormat =<< lookupEnv "OTEL_EXPORTER_OTLP_LOGS_COMPRESSION")
    <*> (traverse readTimeout =<< lookupEnv "OTEL_EXPORTER_OTLP_TIMEOUT")
    <*> (traverse readTimeout =<< lookupEnv "OTEL_EXPORTER_OTLP_TRACES_TIMEOUT")
    <*> (traverse readTimeout =<< lookupEnv "OTEL_EXPORTER_OTLP_METRICS_TIMEOUT")
    <*> (traverse readTimeout =<< lookupEnv "OTEL_EXPORTER_OTLP_LOGS_TIMEOUT")
    <*> (traverse readProtocol =<< lookupEnv "OTEL_EXPORTER_OTLP_PROTOCOL")
    <*> (traverse readProtocol =<< lookupEnv "OTEL_EXPORTER_OTLP_TRACES_PROTOCOL")
    <*> (traverse readProtocol =<< lookupEnv "OTEL_EXPORTER_OTLP_METRICS_PROTOCOL")
    <*> (traverse readProtocol =<< lookupEnv "OTEL_EXPORTER_OTLP_LOGS_PROTOCOL")
  where
    decodeHeaders hsString = case Baggage.decodeBaggageHeader $ ByteString.pack hsString of
      Left _ -> mempty
      Right baggageFmt ->
        (\(k, v) -> (CI.mk $ Baggage.tokenValue k, Text.encodeUtf8 $ Baggage.value v)) <$> HashMap.toList (Baggage.values baggageFmt)


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
Print a warning to stderr
-}
putWarningLn :: (MonadIO m) => String -> m ()
putWarningLn = liftIO . IO.hPutStrLn IO.stderr


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
Get the HTTP host from the `OTLPExporterConfig`.
-}
httpHost :: OTLPExporterConfig -> String
httpHost conf = fromMaybe otlpExporterHttpEndpoint $ otlpEndpoint conf


{- |
The default OTLP HTTP endpoint.
-}
otlpExporterHttpEndpoint :: IsString s => s
otlpExporterHttpEndpoint = "http://localhost:4318"


{- |
The default OTLP gRPC endpoint.
-}
otlpExporterGRpcEndpoint :: IsString s => s
otlpExporterGRpcEndpoint = "http://localhost:4317"


{- |
Internal helper.
The type of `LazyByteString` encoders.
-}
type Encoder = LazyByteString -> LazyByteString


{- |
Internal helper.
Get a function that adds the compression header to the HTTP headers and a function that performs the compression.
-}
httpCompression :: OTLPExporterConfig -> ([(HeaderName, ByteString)], Encoder)
httpCompression conf =
  case otlpTracesCompression conf <|> otlpCompression conf of
    Just GZip -> ([(hContentEncoding, "gzip")], GZip.compress)
    _otherwise -> ([], id)


{- |
Internal helper.
The mimetype used by HTTP/Protobuf.
-}
httpProtobufMimeType :: ByteString
httpProtobufMimeType = "application/x-protobuf"


{- |
Internal helper.
Get the base HTTP headers for the request.
-}
httpBaseHeaders :: OTLPExporterConfig -> Request -> [(HeaderName, ByteString)]
httpBaseHeaders conf req =
  concat
    [ [(hContentType, httpProtobufMimeType)]
    , [(hAcceptEncoding, httpProtobufMimeType)]
    , fromMaybe [] (otlpHeaders conf)
    , fromMaybe [] (otlpTracesHeaders conf)
    , requestHeaders req
    ]
