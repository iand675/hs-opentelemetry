module OpenTelemetry.Exporter.InMemory.LogRecord (
  inMemoryChannelExporter,
  inMemoryListExporter,
  module Control.Concurrent.Chan.Unagi,
) where

import Control.Concurrent.Async
import Control.Concurrent.Chan.Unagi
import Control.Monad.IO.Class
import Data.IORef
import OpenTelemetry.Internal.Logs.Types
import OpenTelemetry.Logs.Core
import OpenTelemetry.Processor.LogRecord


{- | Access exported logs via a concurrently accessible channel that produces log records.
 The log records are exported in the order that the log records end.
-}
inMemoryChannelExporter :: (MonadIO m) => m (LogRecordProcessor, OutChan ImmutableLogRecord)
inMemoryChannelExporter = liftIO $ do
  (inChan, outChan) <- newChan
  let processor =
        LogRecordProcessor
          { logRecordProcessorOnEmit = \ref _ -> do
              writeChan inChan =<< readLogRecord ref
          , logRecordProcessorShutdown = do
              async $ pure ShutdownSuccess
          , logRecordProcessorForceFlush = pure ()
          }
  pure (processor, outChan)


{- | Access exported logRecords via a mutable reference to a list of log records. The log records
 are not guaranteed to be exported in a particular order.
-}
inMemoryListExporter :: (MonadIO m) => m (LogRecordProcessor, IORef [ImmutableLogRecord])
inMemoryListExporter = liftIO $ do
  listRef <- newIORef []
  let processor =
        LogRecordProcessor
          { logRecordProcessorOnEmit = \ref _ -> do
              s <- readLogRecord ref
              atomicModifyIORef listRef (\l -> (s : l, ()))
          , logRecordProcessorShutdown = do
              async $ pure ShutdownSuccess
          , logRecordProcessorForceFlush = pure ()
          }
  pure (processor, listRef)
