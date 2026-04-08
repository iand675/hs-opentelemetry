{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TypeApplications #-}

{- |
Module      : OpenTelemetry.Processor.Batch.LogRecord
Description : Batch log record processor. Buffers log records and exports them in batches on a configurable schedule.
Stability   : experimental
-}
module OpenTelemetry.Processor.Batch.LogRecord (
  BatchLogRecordProcessorConfig (..),
  defaultBatchLogRecordProcessorConfig,
  batchLogRecordProcessor,
) where

import Control.Concurrent (rtsSupportsBoundThreads, threadDelay)
import Control.Concurrent.Async
import qualified Control.Concurrent.Chan.Unagi.Bounded as UChan
import Control.Concurrent.MVar
import Control.Exception
import Control.Monad (unless, void, when)
import Control.Monad.IO.Class
import Data.IORef (atomicModifyIORef', atomicWriteIORef, newIORef, readIORef)
import Data.Maybe (fromMaybe)
import Data.Vector (Vector)
import qualified Data.Vector as V
import OpenTelemetry.Internal.Common.Types (ExportResult (..), FlushResult (..), ShutdownResult (..), worstShutdown)
import OpenTelemetry.Internal.Log.Types
import OpenTelemetry.Internal.Logging (otelLogDebug, otelLogWarning)
import OpenTelemetry.Util (chunksOfV)
import System.Timeout (timeout)


-- | @since 0.0.1.0
data BatchLogRecordProcessorConfig = BatchLogRecordProcessorConfig
  { batchLogExporter :: !LogRecordExporter
  , batchLogMaxQueueSize :: !Int
  , batchLogScheduledDelayMillis :: !Int
  , batchLogExportTimeoutMillis :: !Int
  , batchLogMaxExportBatchSize :: !Int
  }


-- | @since 0.0.1.0
defaultBatchLogRecordProcessorConfig :: LogRecordExporter -> BatchLogRecordProcessorConfig
defaultBatchLogRecordProcessorConfig e =
  BatchLogRecordProcessorConfig
    { batchLogExporter = e
    , batchLogMaxQueueSize = 2048
    , batchLogScheduledDelayMillis = 1000
    , batchLogExportTimeoutMillis = 30000
    , batchLogMaxExportBatchSize = 512
    }


data CtrlMsg
  = WakeFlush
  | FlushAndNotify !(MVar ())
  | ShutdownMsg


-- | @since 0.0.1.0
batchLogRecordProcessor :: (MonadIO m) => BatchLogRecordProcessorConfig -> m LogRecordProcessor
batchLogRecordProcessor BatchLogRecordProcessorConfig {..} = liftIO $ do
  unless rtsSupportsBoundThreads $
    otelLogWarning "Batch log record processor running without -threaded; blocking exporter calls may stall the application"
  (dataIn, dataOut) <- UChan.newChan batchLogMaxQueueSize
  (ctrlIn, ctrlOut) <- UChan.newChan 64
  shutdownRef <- newIORef False
  droppedLogs <- newIORef (0 :: Int)

  timerThread <-
    async $
      let loop = do
            threadDelay (millisToMicros batchLogScheduledDelayMillis)
            void $ UChan.tryWriteChan ctrlIn WakeFlush
            shut <- readIORef shutdownRef
            unless shut loop
      in loop

  let publish batchToExport = do
        mResult <-
          timeout (millisToMicros batchLogExportTimeoutMillis) $
            mask_ $
              logRecordExporterExport batchLogExporter batchToExport
        pure $ fromMaybe (Failure Nothing) mResult

      -- Spec: "The processor MUST synchronize calls to LogRecordExporter's
      -- Export to make sure that they are not invoked concurrently."
      publishChunked allRecords = do
        let chunks = chunksOfV batchLogMaxExportBatchSize allRecords
        mapM_
          ( \chunk -> do
              result <- try @SomeException $ publish chunk
              case result of
                Right Success -> pure ()
                Left ex ->
                  otelLogWarning $ "Batch log record export failed: " <> show ex
                Right (Failure mex) ->
                  otelLogWarning $
                    "Batch log record export failed: "
                      <> maybe "timeout or unspecified" show mex
          )
          chunks

      drainUpTo :: Int -> IO (Vector ReadableLogRecord)
      drainUpTo n = do
        est <- UChan.estimatedLength dataIn
        let !toRead = min n (max 0 est)
        V.replicateM toRead (UChan.readChan dataOut)

      drainLoop = do
        batch <- drainUpTo batchLogMaxExportBatchSize
        unless (V.null batch) $ do
          publishChunked batch
          est <- UChan.estimatedLength dataIn
          when (est > 0) drainLoop

      flushQueueImmediately ret = do
        batch <- drainUpTo batchLogMaxQueueSize
        if V.null batch
          then pure ret
          else do
            publishChunked batch
            flushQueueImmediately ret

      workerAction = do
        msg <- UChan.readChan ctrlOut
        drainLoop
        shut <- readIORef shutdownRef
        if shut
          then flushQueueImmediately Success
          else case msg of
            ShutdownMsg -> flushQueueImmediately Success
            FlushAndNotify mv -> do
              void $ tryPutMVar mv ()
              workerAction
            WakeFlush -> workerAction

  worker <- asyncWithUnmask $ \unmask -> unmask workerAction

  pure
    LogRecordProcessor
      { logRecordProcessorOnEmit = \lr _ctxt -> do
          isShutdown <- readIORef shutdownRef
          unless isShutdown $ do
            readable <- mkReadableLogRecord lr
            ok <- UChan.tryWriteChan dataIn readable
            if ok
              then do
                len <- UChan.estimatedLength dataIn
                when (len >= batchLogMaxExportBatchSize) $
                  void $
                    UChan.tryWriteChan ctrlIn WakeFlush
              else do
                n <- atomicModifyIORef' droppedLogs (\c -> let !c' = c + 1 in (c', c'))
                when (n == 1 || n `mod` 1000 == 0) $
                  otelLogDebug ("Batch log processor queue full, dropped " <> show n <> " log record(s) so far")
      , logRecordProcessorForceFlush = do
          mv <- newEmptyMVar
          ok <- UChan.tryWriteChan ctrlIn (FlushAndNotify mv)
          if ok
            then do
              mDone <- timeout (millisToMicros batchLogExportTimeoutMillis) (takeMVar mv)
              logRecordExporterForceFlush batchLogExporter
              pure $ case mDone of
                Nothing -> FlushTimeout
                Just () -> FlushSuccess
            else do
              logRecordExporterForceFlush batchLogExporter
              pure FlushSuccess
      , logRecordProcessorShutdown = do
          atomicWriteIORef shutdownRef True
          void $ UChan.tryWriteChan ctrlIn ShutdownMsg

          mResult <- timeout (millisToMicros batchLogExportTimeoutMillis) (waitCatch worker)
          cancel worker
          cancel timerThread
          _ <- logRecordExporterForceFlush batchLogExporter
          logRecordExporterShutdown batchLogExporter

          let !workerResult = case mResult of
                Nothing -> ShutdownTimeout
                Just (Left _) -> ShutdownFailure
                Just (Right _) -> ShutdownSuccess
          pure $! worstShutdown workerResult ShutdownSuccess
      }
  where
    millisToMicros = (* 1000)
