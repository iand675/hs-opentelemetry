{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}

module OpenTelemetry.Processor.Simple.LogRecord (
  SimpleLogRecordProcessorConfig (..),
  simpleLogRecordProcessor,
) where

import Control.Concurrent.Async
import Control.Concurrent.STM
import Control.Exception (mask_)
import Control.Monad
import Data.IORef
import qualified Data.Vector as V
import OpenTelemetry.Internal.Common.Types (ShutdownResult (..))
import OpenTelemetry.Internal.Log.Types
import OpenTelemetry.Internal.Logging (otelLogWarning)


data SimpleLogRecordProcessorConfig = SimpleLogRecordProcessorConfig
  { simpleLogRecordExporter :: LogRecordExporter
  , simpleLogRecordExportTimeoutMicros :: !Int
  -- ^ Timeout for individual export calls in microseconds. Default: 30s.
  }


defaultSimpleQueueBound :: Int
defaultSimpleQueueBound = 2048


simpleLogRecordProcessor :: SimpleLogRecordProcessorConfig -> IO LogRecordProcessor
simpleLogRecordProcessor SimpleLogRecordProcessorConfig {..} = do
  queue <- newTBQueueIO (fromIntegral defaultSimpleQueueBound)
  droppedRef <- newIORef (0 :: Int)
  warnedRef <- newIORef False
  shutdownVar <- newTVarIO False
  flushReq <- newEmptyTMVarIO
  flushDone <- newEmptyTMVarIO

  let exportOne rw = do
        readable <- mkReadableLogRecord rw
        mask_ (logRecordExporterExport simpleLogRecordExporter (V.singleton readable))

  let drainQueue = do
        mRw <- atomically $ tryReadTBQueue queue
        case mRw of
          Nothing -> pure ()
          Just rw -> do
            _ <- exportOne rw
            drainQueue

  let workerLoop = do
        cmd <-
          atomically $
            msum
              [ Nothing <$ (readTVar shutdownVar >>= check)
              , Just Nothing <$ takeTMVar flushReq
              , Just . Just <$> readTBQueue queue
              ]
        case cmd of
          Nothing -> do
            drainQueue
            void $ atomically $ tryPutTMVar flushDone ()
          Just Nothing -> do
            drainQueue
            atomically $ putTMVar flushDone ()
            workerLoop
          Just (Just rw) -> do
            _ <- exportOne rw
            workerLoop

  exportWorker <- async workerLoop

  pure
    LogRecordProcessor
      { logRecordProcessorOnEmit = \lr _ctxt -> do
          written <- atomically $ do
            full <- isFullTBQueue queue
            if full then pure False else writeTBQueue queue lr >> pure True
          unless written $ do
            n <- atomicModifyIORef' droppedRef (\c -> let c' = c + 1 in (c', c'))
            alreadyWarned <- atomicModifyIORef' warnedRef (\w -> (True, w))
            unless alreadyWarned $
              otelLogWarning $
                "SimpleLogRecordProcessor: queue full (capacity "
                  <> show defaultSimpleQueueBound
                  <> "), dropping log record. Total dropped so far: "
                  <> show n
      , logRecordProcessorShutdown = do
          atomically $ writeTVar shutdownVar True
          wait exportWorker
          logRecordExporterShutdown simpleLogRecordExporter
          pure ShutdownSuccess
      , logRecordProcessorForceFlush = do
          isShut <- readTVarIO shutdownVar
          unless isShut $ do
            atomically $ putTMVar flushReq ()
            atomically $ takeTMVar flushDone
          logRecordExporterForceFlush simpleLogRecordExporter
      }
