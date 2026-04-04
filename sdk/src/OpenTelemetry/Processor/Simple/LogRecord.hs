{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}

module OpenTelemetry.Processor.Simple.LogRecord (
  SimpleLogRecordProcessorConfig (..),
  simpleLogRecordProcessor,
) where

import Control.Concurrent.Async
import Control.Concurrent.Chan.Unagi
import Control.Exception
import Control.Monad
import Data.IORef
import qualified Data.Vector as V
import OpenTelemetry.Internal.Common.Types (ShutdownResult (..))
import OpenTelemetry.Internal.Logs.Types


newtype SimpleLogRecordProcessorConfig = SimpleLogRecordProcessorConfig
  { simpleLogRecordExporter :: LogRecordExporter
  }


simpleLogRecordProcessor :: SimpleLogRecordProcessorConfig -> IO LogRecordProcessor
simpleLogRecordProcessor SimpleLogRecordProcessorConfig {..} = do
  (inChan :: InChan ReadWriteLogRecord, outChan :: OutChan ReadWriteLogRecord) <- newChan
  exportWorker <- async $ forever $ do
    rw <- readChanOnException outChan (>>= writeChan inChan)
    let readable = mkReadableLogRecord rw
    mask_ (logRecordExporterExport simpleLogRecordExporter (V.singleton readable))

  pure
    LogRecordProcessor
      { logRecordProcessorOnEmit = \lr _ctxt -> writeChan inChan lr
      , logRecordProcessorShutdown = async $ mask $ \restore -> do
          cancel exportWorker
          restore $ do
            drainAndExport outChan `finally` logRecordExporterShutdown simpleLogRecordExporter
          pure ShutdownSuccess
      , logRecordProcessorForceFlush = logRecordExporterForceFlush simpleLogRecordExporter
      }
  where
    drainAndExport :: OutChan ReadWriteLogRecord -> IO ()
    drainAndExport outChan = do
      (Element m, _) <- tryReadChan outChan
      mLr <- m
      case mLr of
        Nothing -> pure ()
        Just rw -> do
          let readable = mkReadableLogRecord rw
          _ <- logRecordExporterExport simpleLogRecordExporter (V.singleton readable)
          drainAndExport outChan
