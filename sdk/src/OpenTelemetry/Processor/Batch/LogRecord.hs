{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}

module OpenTelemetry.Processor.Batch.LogRecord where

import Control.Concurrent (rtsSupportsBoundThreads)
import Control.Concurrent.Async
import Control.Concurrent.STM
import Control.Exception
import Control.Monad
import Control.Monad.IO.Class
import Data.IORef (IORef, atomicModifyIORef', newIORef)
import Data.Vector (Vector)
import qualified OpenTelemetry.Exporter.LogRecord as LogRecordExporter
import OpenTelemetry.Internal.Logs.Types
import OpenTelemetry.Processor.Batch.TimeoutConfig
import OpenTelemetry.Processor.LogRecord
import VectorBuilder.Builder as Builder
import VectorBuilder.Vector as Builder


data BoundedVector a = BoundedVector
  { itemBounds :: !Int
  , itemMaxExportBounds :: !Int
  , itemVector :: Builder.Builder a
  }


boundedVector :: Int -> Int -> BoundedVector a
boundedVector bounds exportBounds = BoundedVector bounds exportBounds Builder.empty


push :: a -> BoundedVector a -> Maybe (BoundedVector a)
push s v =
  if Builder.size (itemVector v) + 1 >= itemBounds v
    then Nothing
    else Just $! v {itemVector = itemVector v <> Builder.singleton s}


buildExport :: BoundedVector a -> (BoundedVector a, Vector a)
buildExport v =
  ( v {itemVector = Builder.empty}
  , Builder.build $ itemVector v
  )


data ProcessorMessage = ScheduledFlush | MaxExportFlush | Shutdown


{- |
 The batch processor accepts log records and places them into batches. Batching helps better compress the data and reduce the number of outgoing connections
 required to transmit the data. This processor supports both size and time based batching.

 NOTE: this function requires the program be compiled with the @-threaded@ GHC
 option and will throw an error if this is not the case.
-}
batchProcessor :: (MonadIO m) => BatchTimeoutConfig -> LogRecordExporter -> m LogRecordProcessor
batchProcessor BatchTimeoutConfig {..} exporter = liftIO $ do
  unless rtsSupportsBoundThreads $ error "The hs-opentelemetry batch processor does not work without the -threaded GHC flag!"
  batch :: IORef (BoundedVector ReadableLogRecord) <- newIORef $ boundedVector maxQueueSize maxExportBatchSize
  workSignal <- newEmptyTMVarIO
  shutdownSignal <- newEmptyTMVarIO
  let publish batchToProcess = mask_ $ do
        -- we mask async exceptions in this, so that a buggy exporter that
        -- catches async exceptions won't swallow them. since we use
        -- an interruptible mask, blocking calls can still be killed, like
        -- `threadDelay` or `putMVar` or most file I/O operations.
        --
        -- if we've received a shutdown, then we should be expecting
        -- a `cancel` anytime now.
        LogRecordExporter.logRecordExporterExport exporter batchToProcess

  let flushQueueImmediately ret = do
        batchToProcess <- atomicModifyIORef' batch buildExport
        if null batchToProcess
          then do
            pure ret
          else do
            ret' <- publish batchToProcess
            flushQueueImmediately ret'

  let waiting = do
        delay <- registerDelay (millisToMicros scheduledDelayMillis)
        atomically $ do
          msum
            -- Flush every scheduled delay time, when we've reached the max export size, or when the shutdown signal is received.
            [ ScheduledFlush <$ do
                continue <- readTVar delay
                check continue
            , MaxExportFlush <$ takeTMVar workSignal
            , Shutdown <$ takeTMVar shutdownSignal
            ]

  let workerAction = do
        req <- waiting
        batchToProcess <- atomicModifyIORef' batch buildExport
        res <- publish batchToProcess

        -- if we were asked to shutdown, stop waiting and flush it all out
        case req of
          Shutdown ->
            flushQueueImmediately res
          _ ->
            workerAction
  -- see note [Unmasking Asyncs]
  worker <- asyncWithUnmask $ \unmask -> unmask workerAction

  pure $
    LogRecordProcessor
      { logRecordProcessorOnEmit = \logRecord _c -> do
          appendFailedOrExportNeeded <- atomicModifyIORef' batch $ \builder ->
            case push (mkReadableLogRecord logRecord) builder of
              Nothing -> (builder, True)
              Just b' ->
                if Builder.size (itemVector b') >= itemMaxExportBounds b'
                  then -- If the batch has grown to the maximum export size, prompt the worker to export it.
                    (b', True)
                  else (b', False)
          when appendFailedOrExportNeeded $ void $ atomically $ tryPutTMVar workSignal ()
      , logRecordProcessorForceFlush = void $ atomically $ tryPutTMVar workSignal ()
      , -- TODO where to call restore, if anywhere?
        logRecordProcessorShutdown =
          asyncWithUnmask $ \unmask -> unmask $ do
            -- we call asyncWithUnmask here because the shutdown action is
            -- likely to happen inside of a `finally` or `bracket`. the
            -- @safe-exceptions@ pattern (followed by unliftio as well)
            -- will use uninterruptibleMask in an exception cleanup. the
            -- uninterruptibleMask state means that the `timeout` call
            -- below will never exit, because `wait worker` will be in the
            -- `uninterruptibleMasked` state, and the timeout async
            -- exception will not be delivered.
            --
            -- see note [Unmasking Asyncs]
            mask $ \_restore -> do
              -- is it a little silly that we unmask and remask? seems
              -- silly! but the `mask` here is doing an interruptible mask.
              -- which means that async exceptions can still be delivered
              -- if a process is blocking.

              -- flush remaining messages and signal the worker to shutdown
              void $ atomically $ putTMVar shutdownSignal ()

              -- gracefully wait for the worker to stop. we may be in
              -- a `bracket` or responding to an async exception, so we
              -- must be very careful not to wait too long. the following
              -- STM action will block, so we'll be susceptible to an async
              -- exception.
              delay <- registerDelay (millisToMicros exportTimeoutMillis)
              shutdownResult <-
                atomically $
                  msum
                    [ Just <$> waitCatchSTM worker
                    , Nothing <$ do
                        shouldStop <- readTVar delay
                        check shouldStop
                    ]

              -- make sure the worker comes down if we timed out.
              cancel worker
              -- TODO, not convinced we should shut down processor here

              pure $ case shutdownResult of
                Nothing ->
                  ShutdownTimeout
                Just er ->
                  case er of
                    Left _ ->
                      ShutdownFailure
                    Right _ ->
                      ShutdownSuccess
      }
  where
    millisToMicros = (* 1000)
