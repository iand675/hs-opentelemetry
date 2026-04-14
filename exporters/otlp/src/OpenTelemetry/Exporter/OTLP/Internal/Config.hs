{- FOURMOLU_DISABLE -}
{-# LANGUAGE CPP #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

{- | Internal module containing shared OTLP exporter configuration types.

Not intended for direct use — import via "OpenTelemetry.Exporter.OTLP.Span" instead.

= Environment variables

'loadExporterEnvironmentVariables' reads the following @OTEL_EXPORTER_OTLP_*@
variables. Each generic variable has per-signal overrides for traces, metrics,
and logs (e.g. @OTEL_EXPORTER_OTLP_TRACES_ENDPOINT@). Per-signal values take
precedence over generic ones.

=== Endpoint

* @OTEL_EXPORTER_OTLP_ENDPOINT@ (default: @http:\/\/localhost:4318@ HTTP,
  @http:\/\/localhost:4317@ gRPC)
* @OTEL_EXPORTER_OTLP_TRACES_ENDPOINT@, @OTEL_EXPORTER_OTLP_METRICS_ENDPOINT@,
  @OTEL_EXPORTER_OTLP_LOGS_ENDPOINT@

=== Security

* @OTEL_EXPORTER_OTLP_INSECURE@ (default: @false@)
* @OTEL_EXPORTER_OTLP_TRACES_INSECURE@ (fallback: @OTEL_EXPORTER_OTLP_SPAN_INSECURE@)
* @OTEL_EXPORTER_OTLP_METRICS_INSECURE@ (fallback: @OTEL_EXPORTER_OTLP_METRIC_INSECURE@)
* @OTEL_EXPORTER_OTLP_LOGS_INSECURE@
* @OTEL_EXPORTER_OTLP_CERTIFICATE@, @OTEL_EXPORTER_OTLP_TRACES_CERTIFICATE@,
  @OTEL_EXPORTER_OTLP_METRICS_CERTIFICATE@, @OTEL_EXPORTER_OTLP_LOGS_CERTIFICATE@

=== Headers

* @OTEL_EXPORTER_OTLP_HEADERS@, @OTEL_EXPORTER_OTLP_TRACES_HEADERS@,
  @OTEL_EXPORTER_OTLP_METRICS_HEADERS@, @OTEL_EXPORTER_OTLP_LOGS_HEADERS@

Format: @key1=value1,key2=value2@ (W3C Baggage encoding).

=== Compression

* @OTEL_EXPORTER_OTLP_COMPRESSION@, @OTEL_EXPORTER_OTLP_TRACES_COMPRESSION@,
  @OTEL_EXPORTER_OTLP_METRICS_COMPRESSION@, @OTEL_EXPORTER_OTLP_LOGS_COMPRESSION@

Values: @gzip@, @none@ (default: @none@).

=== Timeout

* @OTEL_EXPORTER_OTLP_TIMEOUT@, @OTEL_EXPORTER_OTLP_TRACES_TIMEOUT@,
  @OTEL_EXPORTER_OTLP_METRICS_TIMEOUT@, @OTEL_EXPORTER_OTLP_LOGS_TIMEOUT@

Milliseconds (default: @10000@).

=== Protocol

* @OTEL_EXPORTER_OTLP_PROTOCOL@, @OTEL_EXPORTER_OTLP_TRACES_PROTOCOL@,
  @OTEL_EXPORTER_OTLP_METRICS_PROTOCOL@, @OTEL_EXPORTER_OTLP_LOGS_PROTOCOL@

Values: @http\/protobuf@ (default), @grpc@.
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

  -- * Shared HTTP transport helpers
  otlpUserAgent,
  httpProtobufContentType,
  httpSignalEndpointUrl,
  isRetryableHttpStatus,

  -- * Retry-After parsing
  parseRetryAfterMicros,

  -- * gRPC endpoint resolution (same env vars as HTTP; default port 4317)
  grpcEndpoint,
  grpcTracesEndpoint,
  grpcMetricsEndpoint,
  grpcLogsEndpoint,
) where

import Control.Monad.IO.Class (MonadIO, liftIO)
import Data.Char (toLower)
import Data.Function ((&))
import Data.Maybe (fromMaybe)
import Data.Version (showVersion)
import qualified Data.ByteString.Char8 as C
import qualified Data.CaseInsensitive as CI
import qualified Data.HashMap.Strict as H
import qualified Data.Text.Encoding as T
import Data.Time.Clock (getCurrentTime, diffUTCTime)
import Data.Time.Format (parseTimeM, defaultTimeLocale, rfc822DateFormat)
import Network.HTTP.Types.Header (Header)
import Network.HTTP.Types.Status (Status, status429, status502, status503, status504)
import qualified OpenTelemetry.Baggage as Baggage
import OpenTelemetry.Environment (lookupBooleanEnv)
import OpenTelemetry.Internal.Logging (otelLogWarning)
import Paths_hs_opentelemetry_exporter_otlp (version)
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
  , otlpConcurrentExports :: !Int
  -- ^ Maximum number of concurrent export requests per signal.
  -- Default: 1 (sequential). Set higher for pipelined export.
  -- Spec: <https://opentelemetry.io/docs/specs/otlp/>
  }


loadExporterEnvironmentVariables :: (MonadIO m) => m OTLPExporterConfig
loadExporterEnvironmentVariables = liftIO $ do
  hdrs <- lookupDecodeHeaders "OTEL_EXPORTER_OTLP_HEADERS"
  tracesHdrs <- lookupDecodeHeaders "OTEL_EXPORTER_OTLP_TRACES_HEADERS"
  metricsHdrs <- lookupDecodeHeaders "OTEL_EXPORTER_OTLP_METRICS_HEADERS"
  logsHdrs <- lookupDecodeHeaders "OTEL_EXPORTER_OTLP_LOGS_HEADERS"
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
    <*> pure hdrs
    <*> pure tracesHdrs
    <*> pure metricsHdrs
    <*> pure logsHdrs
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
    <*> (maybe 1 (\s -> max 1 (fromMaybe 1 (readMaybe s))) <$> lookupEnv "OTEL_EXPORTER_OTLP_CONCURRENT_EXPORTS")
  where
    lookupDecodeHeaders :: String -> IO (Maybe [Header])
    lookupDecodeHeaders envName = do
      m <- lookupEnv envName
      case m of
        Nothing -> pure Nothing
        Just hsString -> case Baggage.decodeBaggageHeader $ C.pack hsString of
          Left _err -> do
            otelLogWarning ("Failed to parse " <> envName <> ", ignoring")
            pure (Just [])
          Right baggageFmt ->
            pure $
              Just $
                (\(k, v) -> (CI.mk $ Baggage.tokenValue k, T.encodeUtf8 $ Baggage.value v))
                  <$> H.toList (Baggage.values baggageFmt)

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


{- | Base OTLP gRPC URL from @OTEL_EXPORTER_OTLP_ENDPOINT@.

Defaults to @http:\/\/localhost:4317@. Per-signal
@OTEL_EXPORTER_OTLP_TRACES_ENDPOINT@ (and metrics\/logs variants) override via
'grpcTracesEndpoint' and siblings.
-}
grpcEndpoint :: OTLPExporterConfig -> String
grpcEndpoint conf =
  fromMaybe "http://localhost:4317" (otlpEndpoint conf)


{- | Effective gRPC URL for traces: per-signal env overrides the generic endpoint.

See <https://opentelemetry.io/docs/specs/otel/protocol/exporter/#endpoint-urls>.
-}
grpcTracesEndpoint :: OTLPExporterConfig -> String
grpcTracesEndpoint conf =
  fromMaybe (grpcEndpoint conf) (otlpTracesEndpoint conf)


{- | Effective gRPC URL for metrics (per-signal override or generic base).
-}
grpcMetricsEndpoint :: OTLPExporterConfig -> String
grpcMetricsEndpoint conf =
  fromMaybe (grpcEndpoint conf) (otlpMetricsEndpoint conf)


{- | Effective gRPC URL for logs (per-signal override or generic base).
-}
grpcLogsEndpoint :: OTLPExporterConfig -> String
grpcLogsEndpoint conf =
  fromMaybe (grpcEndpoint conf) (otlpLogsEndpoint conf)


putWarningLn :: (MonadIO m) => String -> m ()
putWarningLn = liftIO . otelLogWarning


-- | @OTel-OTLP-Exporter-Haskell\/\<version\>@ per the OTLP spec User-Agent convention.
otlpUserAgent :: C.ByteString
otlpUserAgent = C.pack $ "OTel-OTLP-Exporter-Haskell/" <> showVersion version


httpProtobufContentType :: C.ByteString
httpProtobufContentType = "application/x-protobuf"


{- | Build the effective endpoint URL for a signal.

Per the OTLP exporter spec:

* If a per-signal endpoint is set, use it as-is.
* Otherwise, append the signal path (@\/v1\/traces@, @\/v1\/metrics@, @\/v1\/logs@)
  to the base endpoint.
-}
httpSignalEndpointUrl
  :: Maybe String
  -- ^ Per-signal endpoint (e.g. 'otlpTracesEndpoint')
  -> OTLPExporterConfig
  -> String
  -- ^ Signal path, e.g. @\"\/v1\/traces\"@
  -> String
httpSignalEndpointUrl perSignalEndpoint conf signalPath =
  case perSignalEndpoint of
    Just url -> url
    Nothing ->
      let base = maybe "http://localhost:4318" id (otlpEndpoint conf)
      in ensureTrailingSlash base <> dropWhile (== '/') signalPath


ensureTrailingSlash :: String -> String
ensureTrailingSlash [] = "/"
ensureTrailingSlash s
  | last s == '/' = s
  | otherwise = s <> "/"


{- | Whether an HTTP status code is retryable per the OTLP spec.

Only 429 (Too Many Requests), 502 (Bad Gateway), 503 (Service Unavailable),
and 504 (Gateway Timeout) are retryable. All other status codes, including
other 4xx\/5xx codes, MUST NOT be retried.

Spec: <https://opentelemetry.io/docs/specs/otel/protocol/exporter/#retry>
-}
isRetryableHttpStatus :: Status -> Bool
isRetryableHttpStatus s =
  s == status429 || s == status502 || s == status503 || s == status504


{- | Parse an HTTP @Retry-After@ header value into microseconds.

Supports both formats defined in RFC 7231 Section 7.1.3:

* @delay-seconds@ — a non-negative integer (e.g. @\"120\"@)
* @HTTP-date@ — RFC 822 / RFC 1123 format (e.g. @\"Fri, 31 Dec 1999 23:59:59 GMT\"@)

Returns 'Nothing' when the value cannot be parsed in either format or
the resulting delay is non-positive.

Spec: <https://opentelemetry.io/docs/specs/otlp/#failures>

@since 0.1.2.0
-}
parseRetryAfterMicros :: C.ByteString -> IO (Maybe Int)
parseRetryAfterMicros bs =
  case readMaybe (C.unpack bs) of
    Just (seconds :: Int)
      | seconds > 0 -> pure $ Just (seconds * 1_000_000)
    _ -> do
      let dateStr = C.unpack bs
      case parseTimeM True defaultTimeLocale rfc822DateFormat dateStr of
        Just targetTime -> do
          now <- getCurrentTime
          let diffSecs = diffUTCTime targetTime now
              micros = ceiling (diffSecs * 1_000_000) :: Int
          pure $ if micros > 0 then Just micros else Nothing
        Nothing ->
          case parseTimeM True defaultTimeLocale "%a, %d %b %Y %H:%M:%S GMT" dateStr of
            Just targetTime -> do
              now <- getCurrentTime
              let diffSecs = diffUTCTime targetTime now
                  micros = ceiling (diffSecs * 1_000_000) :: Int
              pure $ if micros > 0 then Just micros else Nothing
            Nothing -> pure Nothing
