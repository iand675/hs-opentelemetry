{-# LANGUAGE OverloadedStrings #-}

module HTTPTestSupport (Signal (..), signals, exportBatch, withExporterEnv, signalPrefix, succeeded) where

import Control.Exception (bracket)
import Control.Monad (forM_, void)
import qualified Data.HashMap.Strict as H
import Data.IORef
import Data.List (isPrefixOf)
import qualified Data.Vector as V
import OpenTelemetry.Attributes (emptyAttributes)
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Exporter.Metric
import OpenTelemetry.Exporter.OTLP.LogRecord
import OpenTelemetry.Exporter.OTLP.Metric
import OpenTelemetry.Exporter.OTLP.Span
import OpenTelemetry.Exporter.Span (spanExporterExport)
import OpenTelemetry.Internal.Common.Types
import qualified OpenTelemetry.Internal.Log.Core as Log
import qualified OpenTelemetry.Internal.Log.Types as Log
import OpenTelemetry.Processor.Span (SpanProcessor (..))
import OpenTelemetry.Resource (emptyMaterializedResources)
import qualified OpenTelemetry.Trace.Core as Trace
import System.Environment


data Signal = Traces | Metrics | Logs deriving (Eq, Show)


signals :: [Signal]
signals = [Traces, Metrics, Logs]


signalPrefix :: Signal -> String
signalPrefix s = "OTEL_EXPORTER_OTLP_" <> case s of Traces -> "TRACES"; Metrics -> "METRICS"; Logs -> "LOGS"


withExporterEnv :: IO a -> IO a
withExporterEnv action = bracket snapshot restore $ \_ -> clear >> action
  where
    snapshot = filter (isPrefixOf "OTEL_EXPORTER_OTLP" . fst) <$> getEnvironment
    clear = snapshot >>= mapM_ (unsetEnv . fst)
    restore values = clear >> forM_ values (uncurry setEnv)


succeeded :: ExportResult -> Bool
succeeded Success = True
succeeded _ = False


exportBatch :: Signal -> OTLPExporterConfig -> IO ExportResult
exportBatch signal conf = case signal of
  Metrics -> do
    ex <- otlpMetricExporter conf
    let p = SumDataPoint 0 1 (IntNumber 1) emptyAttributes V.empty
        m = MetricExportSum "test.counter" "" "1" "test" True True AggregationCumulative (V.singleton p)
        b = ResourceMetricsExport emptyMaterializedResources (V.singleton (ScopeMetricsExport "test" (V.singleton m)))
    metricExporterExport ex (V.singleton b)
  Traces -> do
    let proc = SpanProcessor (\_ _ -> pure ()) (\_ -> pure ()) (pure ShutdownSuccess) (pure FlushSuccess)
    provider <- Trace.createTracerProvider [proc] Trace.emptyTracerProviderOptions
    let tracer = Trace.makeTracer provider "test" Trace.tracerOptions
    s <- Trace.createSpanWithoutCallStack tracer Context.empty "test" Trace.defaultSpanArguments
    Trace.endSpan s Nothing
    immutable <- Trace.toImmutableSpan s >>= either (fail . show) pure
    ex <- otlpExporter conf
    spanExporterExport ex (H.singleton "test" (V.singleton immutable))
  Logs -> do
    records <- newIORef []
    let proc =
          Log.LogRecordProcessor
            (\r _ -> Log.mkReadableLogRecord r >>= \s -> modifyIORef' records (s :))
            (pure ShutdownSuccess)
            (pure FlushSuccess)
    provider <- Log.createLoggerProvider [proc] Log.emptyLoggerProviderOptions
    void $ Log.emitLogRecord (Log.makeLogger provider "test") Log.emptyLogRecordArguments
    batch <- V.fromList <$> readIORef records
    ex <- otlpLogRecordExporter conf
    Log.logRecordExporterExport ex batch
