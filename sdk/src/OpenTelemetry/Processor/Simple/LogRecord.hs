{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TypeApplications #-}

module OpenTelemetry.Processor.Simple.LogRecord (
  SimpleLogRecordProcessorConfig (..),
  simpleLogRecordProcessor,
) where

import Control.Concurrent.Async
import Control.Exception
import Data.IORef
import Data.Maybe (fromMaybe)
import qualified Data.Vector as V
import OpenTelemetry.Internal.Common.Types (ExportResult (..), ShutdownResult (..))
import OpenTelemetry.Internal.Logs.Types
import System.Timeout (timeout)


newtype SimpleLogRecordProcessorConfig = SimpleLogRecordProcessorConfig
  { simpleLogRecordExporter :: LogRecordExporter
  }


{- | Simple log record processor that exports each log record synchronously in
 @onEmit@.

 Per the OTel specification, the simple processor passes log records directly
 to the exporter. This means @onEmit@ blocks until the export completes,
 matching Go, Java, .NET, C++, Rust, and Python SDKs.

 Use 'OpenTelemetry.Processor.Batch.LogRecord.batchLogRecordProcessor' for
 non-blocking, production-grade log processing.

 @since 0.4.0.0
-}
simpleLogRecordProcessor :: SimpleLogRecordProcessorConfig -> IO LogRecordProcessor
simpleLogRecordProcessor SimpleLogRecordProcessorConfig {..} = do
  shutdownRef <- newIORef False
  pure
    LogRecordProcessor
      { logRecordProcessorOnEmit = \lr _ctxt -> do
          isShutdown <- readIORef shutdownRef
          if isShutdown
            then pure ()
            else do
              readable <- mkReadableLogRecord lr
              _ <-
                try @SomeException $
                  fromMaybe (Failure Nothing)
                    <$> timeout 30_000_000 (logRecordExporterExport simpleLogRecordExporter (V.singleton readable))
              pure ()
      , logRecordProcessorShutdown = async $ do
          atomicWriteIORef shutdownRef True
          logRecordExporterShutdown simpleLogRecordExporter
          pure ShutdownSuccess
      , logRecordProcessorForceFlush = logRecordExporterForceFlush simpleLogRecordExporter
      }
