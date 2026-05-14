{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}

module OpenTelemetry.Processor.Simple.Span (
  SimpleProcessorConfig (..),
  simpleProcessor,
) where

import Control.Concurrent.Async
import Control.Concurrent.Chan.Unagi
import Control.Exception
import Control.Monad
import qualified Data.HashMap.Strict as HashMap
import Data.IORef
import qualified OpenTelemetry.Exporter.Span as SpanExporter
import OpenTelemetry.Internal.Trace.Exporter (materializeResourceSpans)
import OpenTelemetry.Processor.Span
import OpenTelemetry.Trace.Core (ImmutableSpan, spanTracer, tracerName)


newtype SimpleProcessorConfig = SimpleProcessorConfig
  { spanExporter :: SpanExporter.SpanExporter
  -- ^ The exporter where the spans are pushed.
  }


{- | This is an implementation of SpanProcessor which passes finished spans
 and passes the export-friendly span data representation to the configured SpanExporter,
 as soon as they are finished.

 @since 0.0.1.0
-}
simpleProcessor :: SimpleProcessorConfig -> IO SpanProcessor
simpleProcessor SimpleProcessorConfig {..} = do
  (inChan :: InChan (IORef ImmutableSpan), outChan :: OutChan (IORef ImmutableSpan)) <- newChan
  exportWorker <- async $ forever $ do
    -- TODO, masking vs bracket here, not sure what's the right choice
    spanRef <- readChanOnException outChan (>>= writeChan inChan)
    span_ <- readIORef spanRef
    mask_ $ do
      let batchToProcess = HashMap.singleton (tracerName $ spanTracer span_) (pure span_)
      resourceSpans <- materializeResourceSpans batchToProcess
      SpanExporter.spanExporterExport spanExporter resourceSpans

  pure $
    SpanProcessor
      { spanProcessorOnStart = \_ _ -> pure ()
      , spanProcessorOnEnd = writeChan inChan
      , spanProcessorShutdown = async $ mask $ \restore -> do
          cancel exportWorker
          -- TODO handle timeouts
          restore $ do
            -- TODO, not convinced we should shut down processor here
            shutdownProcessor outChan `finally` SpanExporter.spanExporterShutdown spanExporter
          pure ShutdownSuccess
      , spanProcessorForceFlush = pure ()
      }
  where
    shutdownProcessor :: OutChan (IORef ImmutableSpan) -> IO ()
    shutdownProcessor outChan = do
      (Element m, _) <- tryReadChan outChan
      mSpan <- m
      case mSpan of
        Nothing -> pure ()
        Just spanRef -> do
          span_ <- readIORef spanRef
          let batchToProcess = HashMap.singleton (tracerName $ spanTracer span_) (pure span_)
          resourceSpans <- materializeResourceSpans batchToProcess
          _ <- SpanExporter.spanExporterExport spanExporter resourceSpans
          shutdownProcessor outChan
