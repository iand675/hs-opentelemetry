{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE UndecidableInstances #-}
{-# OPTIONS_GHC -Wno-orphans #-}

{- | gRPC transport for OTLP export via @wireform-grpc@.

Provides gRPC-based span, metric, and log exporters that speak the native
OTLP\/gRPC protocol (default port 4317).

The gRPC service glue (the @Protobuf@-tagged RPC types and their @IsRPC@ \/
@SupportsClientRpc@ instances) is written by hand here against the
@wireform-proto@ generated message types, mirroring what
@Network.GRPC.Protobuf.TH.loadProtoServices@ would emit. There is exactly one
unary method per service (@Export@), so the boilerplate is small.

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
import Control.Exception (SomeException (..), catch)
import Control.Monad (void)
import Control.Monad.IO.Class (MonadIO, liftIO)
import Data.Char (isDigit)
import Data.HashMap.Strict (HashMap)
import Data.IORef (atomicModifyIORef', newIORef, readIORef)
import Data.List (isPrefixOf)
import Data.Maybe (fromMaybe)
import Data.Vector (Vector)
import Text.Read (readMaybe)
import Network.GRPC.Client (
  Address (..),
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
import Network.GRPC.Common.Protobuf (Proto (..), Protobuf, getProto)
import Network.GRPC.Spec (
  HasStreamingType (..),
  Input,
  IsRPC (..),
  Output,
  StreamingType (..),
  SupportsClientRpc (..),
  SupportsStreamingType,
 )
import Network.GRPC.Spec.Util.Protobuf (buildLazy, parseLazy)
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
import Proto.OpenTelemetry.Proto.Collector.Logs.V1.LogsService (ExportLogsServiceRequest, ExportLogsServiceResponse)
import Proto.OpenTelemetry.Proto.Collector.Metrics.V1.MetricsService (ExportMetricsServiceRequest, ExportMetricsServiceResponse)
import Proto.OpenTelemetry.Proto.Collector.Trace.V1.TraceService (ExportTraceServiceRequest, ExportTraceServiceResponse)
import System.Timeout (timeout)


--------------------------------------------------------------------------------
-- gRPC service definitions for the OTLP collector services.
--
-- Each service has a single unary method, @Export@. These declarations
-- replicate what @Network.GRPC.Protobuf.TH.loadProtoServices@ would generate,
-- but bound to the @wireform-proto@ generated request/response records.
--------------------------------------------------------------------------------

data TraceService


data MetricsService


data LogsService


type ExportTracesRPC = Protobuf TraceService "export"


type ExportMetricsRPC = Protobuf MetricsService "export"


type ExportLogsRPC = Protobuf LogsService "export"


type instance Input ExportTracesRPC = Proto ExportTraceServiceRequest


type instance Output ExportTracesRPC = Proto ExportTraceServiceResponse


type instance Input ExportMetricsRPC = Proto ExportMetricsServiceRequest


type instance Output ExportMetricsRPC = Proto ExportMetricsServiceResponse


type instance Input ExportLogsRPC = Proto ExportLogsServiceRequest


type instance Output ExportLogsRPC = Proto ExportLogsServiceResponse


instance IsRPC ExportTracesRPC where
  rpcContentType _ = "application/grpc+proto"
  rpcServiceName _ = "opentelemetry.proto.collector.trace.v1.TraceService"
  rpcMethodName _ = "Export"
  rpcMessageType _ = Just "opentelemetry.proto.collector.trace.v1.ExportTraceServiceRequest"


instance IsRPC ExportMetricsRPC where
  rpcContentType _ = "application/grpc+proto"
  rpcServiceName _ = "opentelemetry.proto.collector.metrics.v1.MetricsService"
  rpcMethodName _ = "Export"
  rpcMessageType _ = Just "opentelemetry.proto.collector.metrics.v1.ExportMetricsServiceRequest"


instance IsRPC ExportLogsRPC where
  rpcContentType _ = "application/grpc+proto"
  rpcServiceName _ = "opentelemetry.proto.collector.logs.v1.LogsService"
  rpcMethodName _ = "Export"
  rpcMessageType _ = Just "opentelemetry.proto.collector.logs.v1.ExportLogsServiceRequest"


instance SupportsClientRpc ExportTracesRPC where
  rpcSerializeInput _ = buildLazy . getProto
  rpcDeserializeOutput _ = fmap Proto . parseLazy


instance SupportsClientRpc ExportMetricsRPC where
  rpcSerializeInput _ = buildLazy . getProto
  rpcDeserializeOutput _ = fmap Proto . parseLazy


instance SupportsClientRpc ExportLogsRPC where
  rpcSerializeInput _ = buildLazy . getProto
  rpcDeserializeOutput _ = fmap Proto . parseLazy


instance SupportsStreamingType ExportTracesRPC 'NonStreaming


instance SupportsStreamingType ExportMetricsRPC 'NonStreaming


instance SupportsStreamingType ExportLogsRPC 'NonStreaming


instance HasStreamingType ExportTracesRPC where
  type RpcStreamingType ExportTracesRPC = 'NonStreaming


instance HasStreamingType ExportMetricsRPC where
  type RpcStreamingType ExportMetricsRPC = 'NonStreaming


instance HasStreamingType ExportLogsRPC where
  type RpcStreamingType ExportLogsRPC = 'NonStreaming


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
  let hostPort = takeWhile (/= '/') (dropScheme url)
      (host, portPart) = break (== ':') hostPort
      port = case portPart of
        ':' : rest -> fromMaybe 4317 (readMaybe (takeWhile isDigit rest))
        _ -> 4317
  in Address
       { addressHost = host
       , addressPort = port
       , addressAuthority = Nothing
       }
  where
    -- Strip a leading @scheme:\/\/@ if present, otherwise leave the input as-is
    -- (so both @http:\/\/host:port@ and bare @host:port@ parse correctly).
    dropScheme ('/' : '/' : rest) = rest
    dropScheme (_ : rest) = dropScheme rest
    dropScheme [] = url


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
  conn <- openConnection def server
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
  conn <- openConnection def server
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
  conn <- openConnection def server
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
