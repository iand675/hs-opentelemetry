{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TypeApplications #-}

{- |
Module      : OpenTelemetry.Processor.Simple.Span
Description : Simple span processor. Immediately forwards each ended span to the exporter.
Stability   : experimental
-}
module OpenTelemetry.Processor.Simple.Span (
  SimpleProcessorConfig (..),
  simpleProcessor,
) where

import Control.Concurrent.MVar
import Control.Exception
import qualified Data.HashMap.Strict as HashMap
import Data.IORef
import Data.Maybe (fromMaybe)
import qualified OpenTelemetry.Exporter.Span as SpanExporter
import OpenTelemetry.Internal.Logging (otelLogWarning)
import OpenTelemetry.Processor.Span
import OpenTelemetry.Trace.Core (isSampled, spanContext, spanTracer, traceFlags, tracerName)
import System.Timeout (timeout)


-- | @since 0.0.1.0
data SimpleProcessorConfig = SimpleProcessorConfig
  { spanExporter :: SpanExporter.SpanExporter
  -- ^ The exporter where the spans are pushed.
  , simpleSpanExportTimeoutMicros :: !Int
  -- ^ Export timeout in microseconds, defaults to 30,000,000 (30s)
  }


{- | This is an implementation of SpanProcessor which passes finished spans
 and passes the export-friendly span data representation to the configured
 SpanExporter, as soon as they are finished.

 Per the OTel specification, @OnEnd@ calls the exporter synchronously. This
 means @span.end()@ blocks until the export completes. This matches the
 behavior of every other OTel SDK (Go, Java, .NET, C++, Rust, Python).

 Export calls are serialized via an internal MVar so that the exporter is
 never invoked concurrently, per the spec requirement that a processor MUST
 NOT invoke the exporter concurrently.

 Use 'OpenTelemetry.Processor.Batch.Span.batchProcessor' for non-blocking,
 production-grade span processing.

 Spec: <https://opentelemetry.io/docs/specs/otel/trace/sdk/#simple-processor>

 @since 0.0.1.0
-}
simpleProcessor :: SimpleProcessorConfig -> IO SpanProcessor
simpleProcessor SimpleProcessorConfig {..} = do
  shutdownRef <- newIORef False
  exportLock <- newMVar ()
  pure $
    SpanProcessor
      { spanProcessorOnStart = \_ _ -> pure ()
      , spanProcessorOnEnd = \imm -> do
          isShutdown <- readIORef shutdownRef
          if isShutdown
            then pure ()
            else
              if not (isSampled (traceFlags (spanContext imm)))
                then pure ()
                else withMVar exportLock $ \_ -> do
                  er <-
                    try @SomeException $
                      fromMaybe (SpanExporter.Failure Nothing)
                        <$> timeout
                          simpleSpanExportTimeoutMicros
                          ( spanExporter
                              `SpanExporter.spanExporterExport` HashMap.singleton (tracerName $ spanTracer imm) (pure imm)
                          )
                  case er of
                    Left ex ->
                      otelLogWarning $ "Simple span export failed: " <> show ex
                    Right SpanExporter.Success -> pure ()
                    Right (SpanExporter.Failure mex) ->
                      otelLogWarning $
                        "Simple span export failed: "
                          <> maybe "timeout or unspecified" show mex
      , spanProcessorShutdown = do
          atomicWriteIORef shutdownRef True
          _ <- SpanExporter.spanExporterForceFlush spanExporter
          SpanExporter.spanExporterShutdown spanExporter
      , spanProcessorForceFlush = SpanExporter.spanExporterForceFlush spanExporter
      }
