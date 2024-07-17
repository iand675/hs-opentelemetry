module OpenTelemetry.SpanExporter.InMemory (
  inMemoryChannelExporter,
  inMemoryListExporter,
  module Control.Concurrent.Chan.Unagi,
) where

import Control.Concurrent.Async
import Control.Concurrent.Chan.Unagi
import Control.Monad.IO.Class
import Data.IORef
import OpenTelemetry.SpanProcessor
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
          , spanProcessorOnEnd = \ref -> do
              writeChan inChan =<< readIORef ref
          , spanProcessorShutdown = do
              async $ pure ShutdownSuccess
          , spanProcessorForceFlush = pure ()
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
          , spanProcessorOnEnd = \ref -> do
              s <- readIORef ref
              atomicModifyIORef listRef (\l -> (s : l, ()))
          , spanProcessorShutdown = do
              async $ pure ShutdownSuccess
          , spanProcessorForceFlush = pure ()
          }
  pure (processor, listRef)
