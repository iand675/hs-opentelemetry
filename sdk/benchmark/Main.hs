{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import qualified Criterion.Main as C
import OpenTelemetry.Context (empty)
import OpenTelemetry.Exporter.Span (ExportResult (Success), SpanExporter (..))
import OpenTelemetry.Processor.Batch.Span
import OpenTelemetry.Processor.Simple.Span
import OpenTelemetry.Processor.Span (SpanProcessor)
import OpenTelemetry.Trace.Core
import OpenTelemetry.Trace.Id (newSpanId, newTraceId)
import OpenTelemetry.Trace.Id.Generator.Default (defaultIdGenerator)


main :: IO ()
main = do
  droppedTracer <- mkDroppedTracer
  simpleTracer <- mkSimpleTracer
  batchTracer <- mkBatchTracer

  let spanArgs = defaultSpanArguments

  C.defaultMain
    [ C.bgroup
        "id-generation"
        [ C.bench "newTraceId" $ C.whnfIO $ newTraceId defaultIdGenerator
        , C.bench "newSpanId" $ C.whnfIO $ newSpanId defaultIdGenerator
        ]
    , C.bgroup
        "span-lifecycle"
        [ C.bench "dropped" $ C.nfIO $ createAndEnd droppedTracer spanArgs
        , C.bench "simple-processor" $ C.nfIO $ createAndEnd simpleTracer spanArgs
        , C.bench "batch-processor" $ C.nfIO $ createAndEnd batchTracer spanArgs
        ]
    ]


createAndEnd :: Tracer -> SpanArguments -> IO ()
createAndEnd tracer args = do
  s <- createSpanWithoutCallStack tracer empty "benchmark.sdk" args
  endSpan s Nothing


mkDroppedTracer :: IO Tracer
mkDroppedTracer = mkTracer []


mkSimpleTracer :: IO Tracer
mkSimpleTracer = do
  processor <- simpleProcessor $ SimpleProcessorConfig noOpExporter
  mkTracer [processor]


mkBatchTracer :: IO Tracer
mkBatchTracer = do
  processor <- batchProcessor (batchTimeoutConfig {maxQueueSize = 4096, maxExportBatchSize = 512}) noOpExporter
  mkTracer [processor]


mkTracer :: [SpanProcessor] -> IO Tracer
mkTracer processors = do
  tp <- createTracerProvider processors emptyTracerProviderOptions
  pure $ makeTracer tp "benchmark.sdk" tracerOptions


noOpExporter :: SpanExporter
noOpExporter =
  SpanExporter
    { spanExporterExport = \_ -> pure Success
    , spanExporterShutdown = pure ()
    }
