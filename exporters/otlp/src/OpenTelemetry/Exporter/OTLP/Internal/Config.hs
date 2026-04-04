{-# LANGUAGE CPP #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE OverloadedStrings #-}

{- | Internal module containing shared OTLP exporter configuration types.

Not intended for direct use — import via "OpenTelemetry.Exporter.OTLP.Span" instead.
-}
module OpenTelemetry.Exporter.OTLP.Internal.Config (
  OTLPExporterConfig (..),
  CompressionFormat (..),
  Protocol (..),
  loadExporterEnvironmentVariables,
  otlpExporterHttpEndpoint,
  otlpExporterGRpcEndpoint,
  defaultExporterTimeout,
  readCompressionFormat,
  readProtocol,
  readTimeout,
  putWarningLn,
) where

import Control.Monad.IO.Class (MonadIO, liftIO)
import Data.Char (toLower)
import Data.Function ((&))
import qualified Data.ByteString.Char8 as C
import qualified Data.CaseInsensitive as CI
import qualified Data.HashMap.Strict as H
import qualified Data.Text.Encoding as T
import Network.HTTP.Types.Header (Header)
import qualified OpenTelemetry.Baggage as Baggage
import OpenTelemetry.Environment (lookupBooleanEnv)
import OpenTelemetry.Internal.Logging (otelLogWarning)
import System.Environment (lookupEnv)
import Text.Read (readMaybe)


data OTLPExporterConfig = OTLPExporterConfig
  { otlpEndpoint :: Maybe String
  , otlpTracesEndpoint :: Maybe String
  , otlpMetricsEndpoint :: Maybe String
  , otlpLogsEndpoint :: Maybe String
  , otlpInsecure :: Bool
  , otlpTracesInsecure :: Bool
  , otlpMetricsInsecure :: Bool
  , otlpLogsInsecure :: Bool
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
    <*> lookupBooleanEnvFallback "OTEL_EXPORTER_OTLP_TRACES_INSECURE" "OTEL_EXPORTER_OTLP_SPAN_INSECURE"
    <*> lookupBooleanEnvFallback "OTEL_EXPORTER_OTLP_METRICS_INSECURE" "OTEL_EXPORTER_OTLP_METRIC_INSECURE"
    <*> lookupBooleanEnv "OTEL_EXPORTER_OTLP_LOGS_INSECURE"
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
    decodeHeaders hsString = case Baggage.decodeBaggageHeader $ C.pack hsString of
      Left _ -> mempty
      Right baggageFmt ->
        (\(k, v) -> (CI.mk $ Baggage.tokenValue k, T.encodeUtf8 $ Baggage.value v)) <$> H.toList (Baggage.values baggageFmt)

    lookupBooleanEnvFallback primary fallback = do
      p <- lookupBooleanEnv primary
      if p then pure True else lookupBooleanEnv fallback


data CompressionFormat
  = None
  | GZip


{- |
The OpenTelemetry Protocol.

@http\/protobuf@ is always available. When the @grpc@ cabal flag is enabled,
@grpc@ is also supported (native HTTP\/2 gRPC via grapesy).
-}
data Protocol
  = HttpProtobuf
#ifdef GRPC_ENABLED
  | GRpc
#endif


readCompressionFormat :: (MonadIO m) => String -> m CompressionFormat
readCompressionFormat compressionFormat =
  compressionFormat & fmap toLower & \case
    "gzip" -> pure GZip
    "none" -> pure None
    _ -> do
      putWarningLn $ "Unsupported compression format '" <> compressionFormat <> "'"
      pure None


readProtocol :: (MonadIO m) => String -> m Protocol
readProtocol protocol =
  protocol & fmap toLower & \case
    "http/protobuf" -> pure HttpProtobuf
#ifdef GRPC_ENABLED
    "grpc" -> pure GRpc
#endif
    _ -> do
      putWarningLn $ "Unsupported protocol '" <> protocol <> "'"
      pure HttpProtobuf


readTimeout :: (MonadIO m) => String -> m Int
readTimeout timeout =
  case readMaybe timeout of
    Just timeoutInt | timeoutInt >= 0 -> pure timeoutInt
    _otherwise -> do
      putWarningLn $ "Unsupported timeout value '" <> timeout <> "'"
      pure defaultExporterTimeout


defaultExporterTimeout :: Int
defaultExporterTimeout = 10_000


otlpExporterHttpEndpoint :: C.ByteString
otlpExporterHttpEndpoint = "http://localhost:4318"


otlpExporterGRpcEndpoint :: C.ByteString
otlpExporterGRpcEndpoint = "http://localhost:4317"


putWarningLn :: (MonadIO m) => String -> m ()
putWarningLn = liftIO . otelLogWarning
