{-# LANGUAGE DataKinds #-}
{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# OPTIONS_GHC -Wno-orphans #-}

{- | gRPC transport for OTLP export via grapesy.

Provides gRPC-based span, metric, and log exporters that speak the native
OTLP\/gRPC protocol (default port 4317).

Requires the @grpc@ cabal flag to be enabled.

@since 0.2.0.0
-}
module OpenTelemetry.Exporter.OTLP.GRPC (
  grpcOtlpSpanExporter,
  grpcOtlpMetricExporter,
  grpcOtlpLogRecordExporter,
  grpcEndpoint,
  grpcTracesEndpoint,
  grpcMetricsEndpoint,
  grpcLogsEndpoint,
) where

import Control.Applicative ((<|>))
import Control.Concurrent (threadDelay)
import Control.Exception (SomeException (..), catch)
import Control.Monad (void)
import Control.Monad.IO.Class (MonadIO, liftIO)
import Data.HashMap.Strict (HashMap)
import Data.IORef (atomicModifyIORef', newIORef, readIORef)
import Data.List (isPrefixOf)
import Data.Vector (Vector)
import Network.GRPC.Client (
  Address (..),
  CertificateStoreSpec,
  ConnParams (..),
  Reconnect (..),
  ReconnectDecision (..),
  ReconnectPolicy (..),
  ReconnectTo (..),
  Server (..),
  ServerValidation (..),
  certStoreFromPath,
  certStoreFromSystem,
  closeConnection,
  openConnection,
  rpc,
 )
import Network.GRPC.Client.StreamType.IO (nonStreaming)
import Network.GRPC.Common (
  NoMetadata,
  RequestMetadata,
  ResponseInitialMetadata,
  ResponseTrailingMetadata,
  def,
 )
import Network.GRPC.Common.Protobuf (Proto (..), Protobuf)
import OpenTelemetry.Exporter.Metric (MetricExporter (..), ResourceMetricsExport)
import OpenTelemetry.Exporter.OTLP.Internal.Config (
  OTLPExporterConfig (..),
  grpcEndpoint,
  grpcLogsEndpoint,
  grpcMetricsEndpoint,
  grpcTracesEndpoint,
 )
import OpenTelemetry.Exporter.Span (SpanExporter (..))
import OpenTelemetry.Internal.Common.Types (ExportResult (..), FlushResult (..), InstrumentationLibrary, ShutdownResult (..))
import OpenTelemetry.Internal.Log.Types (LogRecordExporter, LogRecordExporterArguments (..), ReadableLogRecord, mkLogRecordExporter)
import OpenTelemetry.Internal.Logging (otelLogWarning)
import qualified OpenTelemetry.Trace.Core as OT
import Proto.Opentelemetry.Proto.Collector.Logs.V1.LogsService (ExportLogsServiceRequest, LogsService)
import Proto.Opentelemetry.Proto.Collector.Metrics.V1.MetricsService (ExportMetricsServiceRequest, MetricsService)
import Proto.Opentelemetry.Proto.Collector.Trace.V1.TraceService (ExportTraceServiceRequest, TraceService)
import System.Timeout (timeout)


type ExportTracesRPC = Protobuf TraceService "export"


type ExportMetricsRPC = Protobuf MetricsService "export"


type ExportLogsRPC = Protobuf LogsService "export"


type instance RequestMetadata (Protobuf TraceService meth) = NoMetadata


type instance ResponseInitialMetadata (Protobuf TraceService meth) = NoMetadata


type instance ResponseTrailingMetadata (Protobuf TraceService meth) = NoMetadata


type instance RequestMetadata (Protobuf MetricsService meth) = NoMetadata


type instance ResponseInitialMetadata (Protobuf MetricsService meth) = NoMetadata


type instance ResponseTrailingMetadata (Protobuf MetricsService meth) = NoMetadata


type instance RequestMetadata (Protobuf LogsService meth) = NoMetadata


type instance ResponseInitialMetadata (Protobuf LogsService meth) = NoMetadata


type instance ResponseTrailingMetadata (Protobuf LogsService meth) = NoMetadata


parseGrpcAddress :: String -> Address
parseGrpcAddress url =
  let authority = takeWhile (/= '/') (dropScheme url)
      (host, portPart) = break (== ':') authority
      port = case portPart of
        ':' : rest -> case reads rest of
          [(p, "")] -> p
          _ -> 4317
        _ -> 4317
  in Address
       { addressHost = host
       , addressPort = port
       , addressAuthority = Nothing
       }
  where
    dropScheme s = case break (== ':') s of
      (_, ':' : '/' : '/' : rest) -> rest
      _ -> s


{- | Connection parameters shared by the gRPC exporters.

grapesy's default 'ReconnectPolicy' is 'DontReconnect', which means a single
dropped connection (collector restart, idle timeout, proxy reset) would
permanently break export for the rest of the process lifetime. Telemetry
should instead ride out collector outages, so reconnect indefinitely with
capped exponential backoff. grapesy resets the policy after each successful
connection, so the backoff always starts small again after a recovery.
-}
exporterConnParams :: ConnParams
exporterConnParams = def {connReconnectPolicy = reconnectPolicy 1}
  where
    maxDelaySeconds = 30
    reconnectPolicy delaySeconds = ReconnectPolicy $ do
      threadDelay (delaySeconds * 1_000_000)
      pure $
        DoReconnect
          Reconnect
            { reconnectTo = ReconnectToOriginal
            , onReconnect = Nothing
            , nextPolicy = reconnectPolicy (min maxDelaySeconds (delaySeconds * 2))
            }


resolveGrpcServer :: Bool -> Maybe FilePath -> String -> Server
resolveGrpcServer insecure mCert endpoint
  | insecure = ServerInsecure addr
  | "https://" `isPrefixOf` endpoint = ServerSecure validation def addr
  | otherwise = ServerInsecure addr
  where
    addr = parseGrpcAddress endpoint
    validation = case mCert of
      Just certPath -> ValidateServer (certStoreFromPath certPath)
      Nothing -> ValidateServer certStoreFromSystem


{- | Create a gRPC-based span exporter.

The serialization function converts the SDK's span map into the OTLP
protobuf request. Pass 'OpenTelemetry.Exporter.OTLP.Span.immutableSpansToProtobuf'.
-}
grpcOtlpSpanExporter
  :: (MonadIO m)
  => OTLPExporterConfig
  -> (HashMap InstrumentationLibrary (Vector OT.ImmutableSpan) -> IO ExportTraceServiceRequest)
  -> m SpanExporter
grpcOtlpSpanExporter conf toProto = liftIO $ do
  let endpoint = grpcTracesEndpoint conf
      server = resolveGrpcServer (otlpTracesInsecure conf || otlpInsecure conf) (otlpTracesCertificate conf <|> otlpCertificate conf) endpoint
  conn <- openConnection exporterConnParams server
  shutdownRef <- newIORef False
  pure $
    SpanExporter
      { spanExporterExport = \spans_ -> do
          isShut <- readIORef shutdownRef
          if isShut
            then pure $ Failure Nothing
            else do
              req <- toProto spans_
              let timeoutUs = maybe 10_000_000 (* 1_000) (otlpTracesTimeout conf <|> otlpTimeout conf)
              ( do
                  result <- timeout timeoutUs $ nonStreaming conn (rpc @ExportTracesRPC) (Proto req)
                  case result of
                    Nothing -> do
                      otelLogWarning "gRPC trace export timed out"
                      pure $ Failure Nothing
                    Just _ -> pure Success
                )
                `catch` \(e :: SomeException) -> do
                  otelLogWarning $ "gRPC trace export failed: " <> show e
                  pure $ Failure (Just e)
      , spanExporterShutdown = do
          void $ atomicModifyIORef' shutdownRef $ \s -> (True, s)
          closeConnection conn
          pure ShutdownSuccess
      , spanExporterForceFlush = pure FlushSuccess
      }


{- | Create a gRPC-based metric exporter.

The serialization function converts metric batches into the OTLP
protobuf request. Pass 'OpenTelemetry.Exporter.OTLP.Metric.resourceMetricsToExportRequest'.
-}
grpcOtlpMetricExporter
  :: (MonadIO m)
  => OTLPExporterConfig
  -> (Vector ResourceMetricsExport -> ExportMetricsServiceRequest)
  -> m MetricExporter
grpcOtlpMetricExporter conf toProto = liftIO $ do
  let endpoint = grpcMetricsEndpoint conf
      server = resolveGrpcServer (otlpMetricsInsecure conf || otlpInsecure conf) (otlpMetricsCertificate conf <|> otlpCertificate conf) endpoint
  conn <- openConnection exporterConnParams server
  shutdownRef <- newIORef False
  pure $
    MetricExporter
      { metricExporterExport = \rmes -> do
          isShut <- readIORef shutdownRef
          if isShut
            then pure $ Failure Nothing
            else do
              let req = toProto rmes
                  timeoutUs = maybe 10_000_000 (* 1_000) (otlpMetricsTimeout conf <|> otlpTimeout conf)
              ( do
                  result <- timeout timeoutUs $ nonStreaming conn (rpc @ExportMetricsRPC) (Proto req)
                  case result of
                    Nothing -> do
                      otelLogWarning "gRPC metric export timed out"
                      pure $ Failure Nothing
                    Just _ -> pure Success
                )
                `catch` \(e :: SomeException) -> do
                  otelLogWarning $ "gRPC metric export failed: " <> show e
                  pure $ Failure (Just e)
      , metricExporterShutdown = do
          void $ atomicModifyIORef' shutdownRef $ \s -> (True, s)
          closeConnection conn
          pure ShutdownSuccess
      , metricExporterForceFlush = pure FlushSuccess
      }


{- | Create a gRPC-based log record exporter.

The serialization function converts log records into the OTLP
protobuf request.
-}
grpcOtlpLogRecordExporter
  :: (MonadIO m)
  => OTLPExporterConfig
  -> (Vector ReadableLogRecord -> IO ExportLogsServiceRequest)
  -> m LogRecordExporter
grpcOtlpLogRecordExporter conf toProto = liftIO $ do
  let endpoint = grpcLogsEndpoint conf
      server = resolveGrpcServer (otlpLogsInsecure conf || otlpInsecure conf) (otlpLogsCertificate conf <|> otlpCertificate conf) endpoint
  conn <- openConnection exporterConnParams server
  shutdownRef <- newIORef False
  mkLogRecordExporter
    LogRecordExporterArguments
      { logRecordExporterArgumentsExport = \lrs -> do
          isShut <- readIORef shutdownRef
          if isShut
            then pure $ Failure Nothing
            else do
              req <- toProto lrs
              let timeoutUs = maybe 10_000_000 (* 1_000) (otlpLogsTimeout conf <|> otlpTimeout conf)
              ( do
                  result <- timeout timeoutUs $ nonStreaming conn (rpc @ExportLogsRPC) (Proto req)
                  case result of
                    Nothing -> do
                      otelLogWarning "gRPC log export timed out"
                      pure $ Failure Nothing
                    Just _ -> pure Success
                )
                `catch` \(e :: SomeException) -> do
                  otelLogWarning $ "gRPC log export failed: " <> show e
                  pure $ Failure (Just e)
      , logRecordExporterArgumentsForceFlush = pure FlushSuccess
      , logRecordExporterArgumentsShutdown = do
          void $ atomicModifyIORef' shutdownRef $ \s -> (True, s)
          closeConnection conn
      }
