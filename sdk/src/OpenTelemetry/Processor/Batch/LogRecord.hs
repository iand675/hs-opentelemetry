{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TypeApplications #-}

module OpenTelemetry.Processor.Batch.LogRecord (
  BatchLogRecordProcessorConfig (..),
  defaultBatchLogRecordProcessorConfig,
  batchLogRecordProcessor,
) where

import Control.Concurrent (rtsSupportsBoundThreads)
import Control.Concurrent.Async
import qualified Control.Concurrent.Chan.Unagi.Bounded as UChan
import Control.Concurrent.STM
import Control.Exception
import Control.Monad (msum, unless, void, when)
import Control.Monad.IO.Class
import Data.IORef (atomicWriteIORef, newIORef, readIORef)
import Data.Maybe (fromMaybe)
import Data.Vector (Vector)
import qualified Data.Vector as V
import OpenTelemetry.Internal.Common.Types (ExportResult (..), ShutdownResult (..))
import OpenTelemetry.Internal.Logging (otelLogWarning)
import OpenTelemetry.Internal.Logs.Types
import System.Timeout (timeout)


data BatchLogRecordProcessorConfig = BatchLogRecordProcessorConfig
  { batchLogExporter :: !LogRecordExporter
  , batchLogMaxQueueSize :: !Int
  , batchLogScheduledDelayMillis :: !Int
  , batchLogExportTimeoutMillis :: !Int
  , batchLogMaxExportBatchSize :: !Int
  }


defaultBatchLogRecordProcessorConfig :: LogRecordExporter -> BatchLogRecordProcessorConfig
defaultBatchLogRecordProcessorConfig e =
  BatchLogRecordProcessorConfig
    { batchLogExporter = e
    , batchLogMaxQueueSize = 2048
    , batchLogScheduledDelayMillis = 1000
    , batchLogExportTimeoutMillis = 30000
    , batchLogMaxExportBatchSize = 512
    }


data ProcessorMessage = ScheduledFlush | MaxExportFlush | Shutdown


batchLogRecordProcessor :: (MonadIO m) => BatchLogRecordProcessorConfig -> m LogRecordProcessor
batchLogRecordProcessor BatchLogRecordProcessorConfig {..} = liftIO $ do
  unless rtsSupportsBoundThreads $
    otelLogWarning "Batch log record processor running without -threaded; blocking exporter calls may stall the application"
  (inChan, outChan) <- UChan.newChan batchLogMaxQueueSize
  workSignal <- newEmptyTMVarIO
  shutdownSignal <- newEmptyTMVarIO
  flushGen <- newTVarIO (0 :: Int)
  shutdownRef <- newIORef False

  let publish batchToExport = do
        mResult <-
          timeout (millisToMicros batchLogExportTimeoutMillis) $
            mask_ $
              logRecordExporterExport batchLogExporter batchToExport
        pure $ fromMaybe (Failure Nothing) mResult

      publishChunked allRecords = do
        let chunks = chunksOfV batchLogMaxExportBatchSize allRecords
        mapConcurrently_ (\chunk -> void $ try @SomeException $ publish chunk) chunks

      drainUpTo :: Int -> IO (Vector ReadableLogRecord)
      drainUpTo n = do
        est <- UChan.estimatedLength inChan
        let toRead = min n (max 0 est)
        V.replicateM toRead (UChan.readChan outChan)

      flushQueueImmediately ret = do
        batch <- drainUpTo batchLogMaxQueueSize
        if V.null batch
          then pure ret
          else do
            publishChunked batch
            flushQueueImmediately ret

      waiting = do
        delay <- registerDelay (millisToMicros batchLogScheduledDelayMillis)
        atomically $
          msum
            [ ScheduledFlush <$ do
                continue <- readTVar delay
                check continue
            , MaxExportFlush <$ takeTMVar workSignal
            , Shutdown <$ takeTMVar shutdownSignal
            ]

      workerAction = do
        req <- waiting
        batch <- drainUpTo batchLogMaxExportBatchSize
        unless (V.null batch) $ publishChunked batch
        atomically $ modifyTVar' flushGen (+ 1)
        case req of
          Shutdown -> flushQueueImmediately Success
          _ -> workerAction

  worker <- asyncWithUnmask $ \unmask -> unmask workerAction

  pure
    LogRecordProcessor
      { logRecordProcessorOnEmit = \lr _ctxt -> do
          isShutdown <- readIORef shutdownRef
          unless isShutdown $ do
            readable <- mkReadableLogRecord lr
            ok <- UChan.tryWriteChan inChan readable
            when ok $ do
              len <- UChan.estimatedLength inChan
              when (len >= batchLogMaxExportBatchSize) $
                void $
                  atomically $
                    tryPutTMVar workSignal ()
      , logRecordProcessorForceFlush = do
          gen <- readTVarIO flushGen
          void $ atomically $ tryPutTMVar workSignal ()
          void $
            timeout (millisToMicros batchLogExportTimeoutMillis) $
              atomically $ do
                current <- readTVar flushGen
                check (current > gen)
          logRecordExporterForceFlush batchLogExporter
      , logRecordProcessorShutdown =
          asyncWithUnmask $ \unmask -> unmask $ do
            mask $ \_restore -> do
              atomicWriteIORef shutdownRef True
              void $ atomically $ tryPutTMVar shutdownSignal ()
              delay <- registerDelay (millisToMicros batchLogExportTimeoutMillis)
              shutdownResult <-
                atomically $
                  msum
                    [ Just <$> waitCatchSTM worker
                    , Nothing <$ do
                        shouldStop <- readTVar delay
                        check shouldStop
                    ]
              cancel worker
              logRecordExporterShutdown batchLogExporter

              pure $ case shutdownResult of
                Nothing -> ShutdownTimeout
                Just (Left _) -> ShutdownFailure
                Just (Right _) -> ShutdownSuccess
      }
  where
    millisToMicros = (* 1000)


chunksOfV :: Int -> V.Vector a -> [V.Vector a]
chunksOfV n v
  | V.null v = []
  | otherwise =
      let (chunk, rest) = V.splitAt n v
      in chunk : chunksOfV n rest
