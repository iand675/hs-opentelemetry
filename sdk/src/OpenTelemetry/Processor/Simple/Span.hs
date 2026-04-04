{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TypeApplications #-}

module OpenTelemetry.Processor.Simple.Span (
  SimpleProcessorConfig (..),
  simpleProcessor,
) where

import Control.Concurrent.Async
import Control.Exception
import qualified Data.HashMap.Strict as HashMap
import Data.IORef
import Data.Maybe (fromMaybe)
import qualified OpenTelemetry.Exporter.Span as SpanExporter
import OpenTelemetry.Processor.Span
import OpenTelemetry.Trace.Core (spanTracer, tracerName)
import System.Timeout (timeout)


newtype SimpleProcessorConfig = SimpleProcessorConfig
  { spanExporter :: SpanExporter.SpanExporter
  -- ^ The exporter where the spans are pushed.
  }


{- | This is an implementation of SpanProcessor which passes finished spans
 and passes the export-friendly span data representation to the configured
 SpanExporter, as soon as they are finished.

 Per the OTel specification, @OnEnd@ calls the exporter synchronously. This
 means @span.end()@ blocks until the export completes. This matches the
 behavior of every other OTel SDK (Go, Java, .NET, C++, Rust, Python).

 Use 'OpenTelemetry.Processor.Batch.Span.batchProcessor' for non-blocking,
 production-grade span processing.

 @since 0.0.1.0
-}
simpleProcessor :: SimpleProcessorConfig -> IO SpanProcessor
simpleProcessor SimpleProcessorConfig {..} = do
  shutdownRef <- newIORef False
  pure $
    SpanProcessor
      { spanProcessorOnStart = \_ _ -> pure ()
      , spanProcessorOnEnd = \imm -> do
          isShutdown <- readIORef shutdownRef
          if isShutdown
            then pure ()
            else do
              _ <-
                try @SomeException $
                  -- Spec: export MUST NOT block indefinitely (30s upper bound)
                  fromMaybe (SpanExporter.Failure Nothing)
                    <$> timeout
                      30_000_000
                      ( spanExporter
                          `SpanExporter.spanExporterExport` HashMap.singleton (tracerName $ spanTracer imm) (pure imm)
                      )
              pure ()
      , spanProcessorShutdown = async $ do
          atomicWriteIORef shutdownRef True
          SpanExporter.spanExporterShutdown spanExporter
          pure ShutdownSuccess
      , spanProcessorForceFlush = SpanExporter.spanExporterForceFlush spanExporter
      }
