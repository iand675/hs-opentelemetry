{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE ScopedTypeVariables #-}

module OpenTelemetry.Processor.Simple.LogRecord (
  simpleProcessor,
) where

import Control.Concurrent.Async (async, cancel)
import Control.Concurrent.Chan.Unagi
import Control.Exception
import Control.Monad (forever)
import qualified Data.Vector as V
import OpenTelemetry.Internal.Common.Types
import OpenTelemetry.Internal.Logs.Types


{- | This is an implementation of LogRecordProcessor which passes finished logs and passes the export-friendly ReadableLogRecord
representation to the configured LogRecordExporter, as soon as they are finished.
-}
simpleProcessor :: LogRecordExporter -> IO LogRecordProcessor
simpleProcessor exporter = do
  (inChan :: InChan ReadWriteLogRecord, outChan :: OutChan ReadWriteLogRecord) <- newChan
  exportWorker <- async $ forever $ do
    bracket
      (readChan outChan)
      (writeChan inChan)
      exportSingleLogRecord

  let logRecordProcessorForceFlush =
        ( do
            chanFlushRes <-
              takeWorstFlushResult
                . fmap exportResultToFlushResult
                <$> forceFlushOutChan outChan []

            exporterFlushRes <- logRecordExporterForceFlush exporter

            pure $ takeWorseFlushResult exporterFlushRes chanFlushRes
        )
          `catch` \(SomeException _) -> pure FlushError

  pure $
    LogRecordProcessor
      { logRecordProcessorOnEmit = \lr _ -> writeChan inChan lr
      , logRecordProcessorShutdown = mask $ \restore -> do
          cancel exportWorker
          flushResult <- restore logRecordProcessorForceFlush

          shutdownResult <- logRecordExporterShutdown exporter

          pure $ takeWorseShutdownResult shutdownResult $ flushResultToShutdownResult flushResult
      , logRecordProcessorForceFlush
      }
  where
    forceFlushOutChan outChan acc = do
      (Element m, _) <- tryReadChan outChan
      mlr <- m
      case mlr of
        Nothing -> pure acc
        Just lr -> do
          res <- exportSingleLogRecord lr
          forceFlushOutChan outChan (res : acc)

    exportSingleLogRecord = logRecordExporterExport exporter . V.singleton . mkReadableLogRecord
