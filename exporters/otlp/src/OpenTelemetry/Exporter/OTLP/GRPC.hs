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
) where

import Control.Exception (SomeException (..), catch)
import Control.Monad (void)
import Control.Monad.IO.Class (MonadIO, liftIO)
import Data.HashMap.Strict (HashMap)
import Data.IORef (atomicModifyIORef', newIORef, readIORef)
import Data.Maybe (fromMaybe)
import Data.Vector (Vector)
import Network.GRPC.Client (
  Address (..),
  Server (..),
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
import Network.GRPC.Common.Protobuf (Protobuf, Proto (..))
import OpenTelemetry.Exporter.OTLP.Internal.Config (OTLPExporterConfig (..))
import OpenTelemetry.Exporter.Metric (MetricExporter (..), ResourceMetricsExport)
import OpenTelemetry.Exporter.Span (SpanExporter (..))
import OpenTelemetry.Internal.Common.Types (ExportResult (..), InstrumentationLibrary, ShutdownResult (..), FlushResult (..))
import OpenTelemetry.Internal.Logging (otelLogWarning)
import OpenTelemetry.Internal.Logs.Types (LogRecordExporter, LogRecordExporterArguments (..), ReadableLogRecord, mkLogRecordExporter)
import qualified OpenTelemetry.Trace.Core as OT
import Proto.Opentelemetry.Proto.Collector.Logs.V1.LogsService (ExportLogsServiceRequest, LogsService)
import Proto.Opentelemetry.Proto.Collector.Metrics.V1.MetricsService (ExportMetricsServiceRequest, MetricsService)
import Proto.Opentelemetry.Proto.Collector.Trace.V1.TraceService (ExportTraceServiceRequest, TraceService)


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
  let stripped = dropScheme url
      (host, portPart) = break (== ':') stripped
      port = case portPart of
        ':' : rest -> case reads rest of
          [(p, "")] -> p
          [(p, "/")] -> p
          _ -> 4317
        _ -> 4317
  in Address
      { addressHost = host
      , addressPort = port
      , addressAuthority = Nothing
      }
  where
    dropScheme s = case break (== '/') (drop 1 $ dropWhile (/= ':') s) of
      (_, '/' : rest) -> rest
      _ -> s


grpcEndpoint :: OTLPExporterConfig -> String
grpcEndpoint conf =
  fromMaybe "http://localhost:4317" (otlpEndpoint conf)


-- | Create a gRPC-based span exporter.
--
-- The serialization function converts the SDK's span map into the OTLP
-- protobuf request. Pass 'OpenTelemetry.Exporter.OTLP.Span.immutableSpansToProtobuf'.
grpcOtlpSpanExporter
  :: (MonadIO m)
  => OTLPExporterConfig
  -> (HashMap InstrumentationLibrary (Vector OT.ImmutableSpan) -> IO ExportTraceServiceRequest)
  -> m SpanExporter
grpcOtlpSpanExporter conf toProto = liftIO $ do
  let addr = parseGrpcAddress (grpcEndpoint conf)
      server = ServerInsecure addr
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
              (do
                _ <- nonStreaming conn (rpc @ExportTracesRPC) (Proto req)
                pure Success)
                `catch` \(e :: SomeException) -> do
                  otelLogWarning $ "gRPC trace export failed: " <> show e
                  pure $ Failure (Just e)
      , spanExporterShutdown = do
          void $ atomicModifyIORef' shutdownRef $ \s -> (True, s)
          closeConnection conn
      , spanExporterForceFlush = pure ()
      }


-- | Create a gRPC-based metric exporter.
--
-- The serialization function converts metric batches into the OTLP
-- protobuf request. Pass 'OpenTelemetry.Exporter.OTLP.Metric.resourceMetricsToExportRequest'.
grpcOtlpMetricExporter
  :: (MonadIO m)
  => OTLPExporterConfig
  -> ([ResourceMetricsExport] -> ExportMetricsServiceRequest)
  -> m MetricExporter
grpcOtlpMetricExporter conf toProto = liftIO $ do
  let addr = parseGrpcAddress (grpcEndpoint conf)
      server = ServerInsecure addr
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
              (do
                _ <- nonStreaming conn (rpc @ExportMetricsRPC) (Proto req)
                pure Success)
                `catch` \(e :: SomeException) -> do
                  otelLogWarning $ "gRPC metric export failed: " <> show e
                  pure $ Failure (Just e)
      , metricExporterShutdown = do
          void $ atomicModifyIORef' shutdownRef $ \s -> (True, s)
          closeConnection conn
          pure ShutdownSuccess
      , metricExporterForceFlush = pure FlushSuccess
      }


-- | Create a gRPC-based log record exporter.
--
-- The serialization function converts log records into the OTLP
-- protobuf request.
grpcOtlpLogRecordExporter
  :: (MonadIO m)
  => OTLPExporterConfig
  -> (Vector ReadableLogRecord -> ExportLogsServiceRequest)
  -> m LogRecordExporter
grpcOtlpLogRecordExporter conf toProto = liftIO $ do
  let addr = parseGrpcAddress (grpcEndpoint conf)
      server = ServerInsecure addr
  conn <- openConnection def server
  shutdownRef <- newIORef False
  mkLogRecordExporter
    LogRecordExporterArguments
      { logRecordExporterArgumentsExport = \lrs -> do
          isShut <- readIORef shutdownRef
          if isShut
            then pure $ Failure Nothing
            else do
              let req = toProto lrs
              (do
                _ <- nonStreaming conn (rpc @ExportLogsRPC) (Proto req)
                pure Success)
                `catch` \(e :: SomeException) -> do
                  otelLogWarning $ "gRPC log export failed: " <> show e
                  pure $ Failure (Just e)
      , logRecordExporterArgumentsForceFlush = pure ()
      , logRecordExporterArgumentsShutdown = do
          void $ atomicModifyIORef' shutdownRef $ \s -> (True, s)
          closeConnection conn
      }
