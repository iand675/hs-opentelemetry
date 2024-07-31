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
import OpenTelemetry.Exporter.LogRecord
import OpenTelemetry.Logs.Core
import OpenTelemetry.Processor.LogRecord


{- | This is an implementation of LogRecordProcessor which passes finished logs and passes the export-friendly ReadableLogRecord
representation to the configured LogRecordExporter, as soon as they are finished.
-}
simpleProcessor :: LogRecordExporter -> IO LogRecordProcessor
simpleProcessor exporter = do
  (inChan :: InChan ReadableLogRecord, outChan :: OutChan ReadableLogRecord) <- newChan
  exportWorker <- async $ forever $ do
    bracketOnError
      (readChan outChan)
      (writeChan inChan)
      (logRecordExporterExport exporter . V.singleton)

  let logRecordProcessorForceFlush =
        handle flushErrorHandler $
          do
            chanFlushRes <-
              takeWorstFlushResult
                . fmap exportResultToFlushResult
                <$> forceFlushOutChan outChan []

            exporterFlushRes <- logRecordExporterForceFlush exporter

            pure $ exporterFlushRes <> chanFlushRes

  pure $
    LogRecordProcessor
      { logRecordProcessorOnEmit = \lr _ -> writeChan inChan $ mkReadableLogRecord lr
      , logRecordProcessorShutdown = handle shutdownErrorHandler $ mask $ \restore -> do
          cancel exportWorker
          flushResult <- restore logRecordProcessorForceFlush

          shutdownResult <- logRecordExporterShutdown exporter

          pure $ (shutdownResult <>) $ flushResultToShutdownResult flushResult
      , logRecordProcessorForceFlush
      }
  where
    forceFlushOutChan outChan acc = do
      (Element m, _) <- tryReadChan outChan
      mlr <- m
      case mlr of
        Nothing -> pure acc
        Just lr -> do
          res <- logRecordExporterExport exporter $ V.singleton lr
          forceFlushOutChan outChan (res : acc)
