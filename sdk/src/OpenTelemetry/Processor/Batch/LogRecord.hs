{-# LANGUAGE RecordWildCards #-}

module OpenTelemetry.Processor.Batch.LogRecord (
  BatchLogRecordProcessorConfig (..),
  defaultBatchLogRecordProcessorConfig,
  batchLogRecordProcessor,
) where

import Control.Concurrent (rtsSupportsBoundThreads)
import Control.Concurrent.Async
import Control.Concurrent.STM
import Control.Exception
import Control.Monad
import Control.Monad.IO.Class
import Data.IORef (IORef, atomicModifyIORef', newIORef)
import Data.Vector (Vector)
import qualified Data.Vector as V
import OpenTelemetry.Internal.Common.Types (ExportResult (..), ShutdownResult (..))
import OpenTelemetry.Internal.Logs.Types
import System.IO (hPutStrLn, stderr)
import System.Timeout (timeout)
import VectorBuilder.Builder as Builder
import VectorBuilder.Vector as Builder


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


data BoundedBuffer = BoundedBuffer
  { bufBounds :: !Int
  , bufExportBounds :: !Int
  , bufCount :: !Int
  , bufItems :: !(Builder.Builder ReadableLogRecord)
  }


emptyBuffer :: Int -> Int -> BoundedBuffer
emptyBuffer bounds exportBounds = BoundedBuffer bounds exportBounds 0 mempty


pushBuffer :: ReadableLogRecord -> BoundedBuffer -> Maybe BoundedBuffer
pushBuffer lr buf
  | bufCount buf >= bufBounds buf = Nothing
  | otherwise =
      Just $!
        buf
          { bufCount = bufCount buf + 1
          , bufItems = bufItems buf <> Builder.singleton lr
          }


buildExportBatch :: BoundedBuffer -> (BoundedBuffer, Vector ReadableLogRecord)
buildExportBatch buf =
  ( buf {bufCount = 0, bufItems = mempty}
  , Builder.build (bufItems buf)
  )


data ProcessorMessage = ScheduledFlush | MaxExportFlush | FlushRequested | Shutdown


batchLogRecordProcessor :: (MonadIO m) => BatchLogRecordProcessorConfig -> m LogRecordProcessor
batchLogRecordProcessor BatchLogRecordProcessorConfig {..} = liftIO $ do
  unless rtsSupportsBoundThreads $
    throwIO (userError "The threaded runtime is required for the batch log record processor")
  batch <- newIORef $ emptyBuffer batchLogMaxQueueSize batchLogMaxExportBatchSize
  droppedRef <- newIORef (0 :: Int)
  warnedRef <- newIORef False
  workSignal <- newEmptyTMVarIO
  shutdownSignal <- newEmptyTMVarIO
  flushRequestSignal <- newEmptyTMVarIO
  flushDoneSignal <- newEmptyTMVarIO

  let timeoutMicros = millisToMicros batchLogExportTimeoutMillis

  let publish batchToExport = do
        mResult <-
          timeout timeoutMicros $
            mask_ $
              logRecordExporterExport batchLogExporter batchToExport
        pure $ case mResult of
          Nothing -> Failure Nothing
          Just r -> r

  let publishBounded batchToExport
        | V.null batchToExport = pure Success
        | V.length batchToExport <= batchLogMaxExportBatchSize =
            publish batchToExport
        | otherwise = do
            let (chunk, rest) = V.splitAt batchLogMaxExportBatchSize batchToExport
            res <- publish chunk
            case res of
              Failure _ -> pure res
              Success -> publishBounded rest

  let flushQueueImmediately ret = do
        batchToExport <- atomicModifyIORef' batch buildExportBatch
        if V.null batchToExport
          then pure ret
          else do
            ret' <- publishBounded batchToExport
            flushQueueImmediately ret'

  -- Shutdown and FlushRequested are tried before work signals so they
  -- cannot be starved under sustained high throughput.
  let waiting = do
        delay <- registerDelay (millisToMicros batchLogScheduledDelayMillis)
        atomically $
          msum
            [ Shutdown <$ takeTMVar shutdownSignal
            , FlushRequested <$ takeTMVar flushRequestSignal
            , MaxExportFlush <$ takeTMVar workSignal
            , ScheduledFlush <$ do
                continue <- readTVar delay
                check continue
            ]

  let workerAction = do
        req <- waiting
        batchToExport <- atomicModifyIORef' batch buildExportBatch
        res <- publishBounded batchToExport
        case req of
          Shutdown -> flushQueueImmediately res
          FlushRequested -> do
            _ <- flushQueueImmediately res
            atomically $ putTMVar flushDoneSignal ()
            workerAction
          _ -> workerAction

  worker <- asyncWithUnmask $ \unmask -> unmask workerAction

  pure
    LogRecordProcessor
      { logRecordProcessorOnEmit = \lr _ctxt -> do
          let readable = mkReadableLogRecord lr
          (dropped, exportNeeded) <- atomicModifyIORef' batch $ \buf ->
            case pushBuffer readable buf of
              Nothing -> (buf, (True, True))
              Just b' ->
                if bufCount b' >= bufExportBounds b'
                  then (b', (False, True))
                  else (b', (False, False))
          when dropped $ warnOnDrop droppedRef warnedRef batchLogMaxQueueSize "BatchLogRecordProcessor"
          when exportNeeded $ void $ atomically $ tryPutTMVar workSignal ()
      , logRecordProcessorForceFlush = do
          atomically $ putTMVar flushRequestSignal ()
          atomically $ takeTMVar flushDoneSignal
          logRecordExporterForceFlush batchLogExporter
      , logRecordProcessorShutdown =
          asyncWithUnmask $ \unmask -> unmask $ do
            mask $ \_restore -> do
              void $ atomically $ putTMVar shutdownSignal ()
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


warnOnDrop :: IORef Int -> IORef Bool -> Int -> String -> IO ()
warnOnDrop droppedRef warnedRef capacity processorName = do
  n <- atomicModifyIORef' droppedRef (\c -> let c' = c + 1 in (c', c'))
  alreadyWarned <- atomicModifyIORef' warnedRef (\w -> (True, w))
  unless alreadyWarned $
    hPutStrLn stderr $
      "OpenTelemetry [WARN] "
        <> processorName
        <> ": queue full (capacity "
        <> show capacity
        <> "), dropping log record. Total dropped so far: "
        <> show n
