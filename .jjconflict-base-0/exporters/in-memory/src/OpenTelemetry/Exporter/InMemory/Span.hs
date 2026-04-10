-- |
-- Module      : OpenTelemetry.Exporter.InMemory.Span
-- Copyright   : (c) Ian Duncan, 2021-2026
-- License     : BSD-3
-- Description : In-memory span exporter for testing
-- Stability   : experimental
--
-- = Overview
--
-- Stores exported spans in an 'IORef' for inspection in tests. This is the
-- recommended exporter for unit testing your instrumentation.
--
-- = Quick example
--
-- @
-- import OpenTelemetry.Exporter.InMemory.Span (inMemoryListExporter)
--
-- (processor, ref) <- inMemoryListExporter
-- tp <- createTracerProvider [processor] emptyTracerProviderOptions
-- let tracer = makeTracer tp "test" tracerOptions
--
-- -- ... run your instrumented code ...
--
-- forceFlushTracerProvider tp Nothing
-- spans <- readIORef ref
-- -- Now inspect 'spans' to verify your instrumentation
-- @
module OpenTelemetry.Exporter.InMemory.Span (
  inMemoryChannelExporter,
  inMemoryListExporter,
  module Control.Concurrent.Chan.Unagi,
) where

import Control.Concurrent.Chan.Unagi
import Control.Monad.IO.Class
import Data.IORef
import OpenTelemetry.Processor.Span
import OpenTelemetry.Trace.Core


{- | Access exported spans via a concurrently accessible channel that produces spans.
 The spans are exported in the order that the spans end.
-}
inMemoryChannelExporter :: (MonadIO m) => m (SpanProcessor, OutChan ImmutableSpan)
inMemoryChannelExporter = liftIO $ do
  (inChan, outChan) <- newChan
  let processor =
        SpanProcessor
          { spanProcessorOnStart = \_ _ -> pure ()
          , spanProcessorOnEnd = \imm ->
              writeChan inChan imm
          , spanProcessorShutdown = pure ShutdownSuccess
          , spanProcessorForceFlush = pure FlushSuccess
          }
  pure (processor, outChan)


{- | Access exported spans via a mutable reference to a list of spans. The spans
 are not guaranteed to be exported in a particular order.
-}
inMemoryListExporter :: (MonadIO m) => m (SpanProcessor, IORef [ImmutableSpan])
inMemoryListExporter = liftIO $ do
  listRef <- newIORef []
  let processor =
        SpanProcessor
          { spanProcessorOnStart = \_ _ -> pure ()
          , spanProcessorOnEnd = \imm ->
              atomicModifyIORef listRef (\l -> (imm : l, ()))
          , spanProcessorShutdown = pure ShutdownSuccess
          , spanProcessorForceFlush = pure FlushSuccess
          }
  pure (processor, listRef)
