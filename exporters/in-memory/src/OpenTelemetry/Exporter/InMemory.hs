module OpenTelemetry.Exporter.InMemory (
  inMemoryChannelExporter,
  inMemoryListExporter,
  module Control.Concurrent.Chan.Unagi,
) where

import Control.Concurrent.Async
import Control.Concurrent.Chan.Unagi
import Control.Monad.IO.Class
import Data.IORef
import OpenTelemetry.Processor
import OpenTelemetry.Trace.Core


{- | Access exported spans via a concurrently accessible channel that produces spans.
 The spans are exported in the order that the spans end.
-}
inMemoryChannelExporter :: (MonadIO m) => m (Processor, OutChan ImmutableSpan)
inMemoryChannelExporter = liftIO $ do
  (inChan, outChan) <- newChan
  let processor =
        Processor
          { processorOnStart = \_ _ -> pure ()
          , processorOnEnd = \ref -> do
              writeChan inChan =<< readIORef ref
          , processorShutdown = do
              async $ pure ShutdownSuccess
          , processorForceFlush = pure ()
          }
  pure (processor, outChan)


{- | Access exported spans via a mutable reference to a list of spans. The spans
 are not guaranteed to be exported in a particular order.
-}
inMemoryListExporter :: (MonadIO m) => m (Processor, IORef [ImmutableSpan])
inMemoryListExporter = liftIO $ do
  listRef <- newIORef []
  let processor =
        Processor
          { processorOnStart = \_ _ -> pure ()
          , processorOnEnd = \ref -> do
              s <- readIORef ref
              atomicModifyIORef listRef (\l -> (s : l, ()))
          , processorShutdown = do
              async $ pure ShutdownSuccess
          , processorForceFlush = pure ()
          }
  pure (processor, listRef)
