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
import Data.IORef (atomicModifyIORef', newIORef)
import Data.Vector (Vector)
import qualified Data.Vector as V
import OpenTelemetry.Internal.Common.Types (ShutdownResult (..))
import OpenTelemetry.Internal.Logs.Types
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
  | bufCount buf + 1 >= bufBounds buf = Nothing
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


data ProcessorMessage = ScheduledFlush | MaxExportFlush | Shutdown


batchLogRecordProcessor :: (MonadIO m) => BatchLogRecordProcessorConfig -> m LogRecordProcessor
batchLogRecordProcessor BatchLogRecordProcessorConfig {..} = liftIO $ do
  unless rtsSupportsBoundThreads $ error "The hs-opentelemetry batch log record processor requires -threaded"
  batch <- newIORef $ emptyBuffer batchLogMaxQueueSize batchLogMaxExportBatchSize
  workSignal <- newEmptyTMVarIO
  shutdownSignal <- newEmptyTMVarIO

  let publish batchToExport =
        mask_ $
          logRecordExporterExport batchLogExporter batchToExport

  let flushQueueImmediately ret = do
        batchToExport <- atomicModifyIORef' batch buildExportBatch
        if V.null batchToExport
          then pure ret
          else do
            ret' <- publish batchToExport
            flushQueueImmediately ret'

  let waiting = do
        delay <- registerDelay (millisToMicros batchLogScheduledDelayMillis)
        atomically $
          msum
            [ ScheduledFlush <$ do
                continue <- readTVar delay
                check continue
            , MaxExportFlush <$ takeTMVar workSignal
            , Shutdown <$ takeTMVar shutdownSignal
            ]

  let workerAction = do
        req <- waiting
        batchToExport <- atomicModifyIORef' batch buildExportBatch
        res <- publish batchToExport
        case req of
          Shutdown -> flushQueueImmediately res
          _ -> workerAction

  worker <- asyncWithUnmask $ \unmask -> unmask workerAction

  pure
    LogRecordProcessor
      { logRecordProcessorOnEmit = \lr _ctxt -> do
          let readable = mkReadableLogRecord lr
          needsFlush <- atomicModifyIORef' batch $ \buf ->
            case pushBuffer readable buf of
              Nothing -> (buf, True)
              Just b' ->
                if bufCount b' >= bufExportBounds b'
                  then (b', True)
                  else (b', False)
          when needsFlush $ void $ atomically $ tryPutTMVar workSignal ()
      , logRecordProcessorForceFlush = do
          void $ atomically $ tryPutTMVar workSignal ()
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
