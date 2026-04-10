{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TypeApplications #-}

-- |
-- Module      : OpenTelemetry.Processor.Simple.LogRecord
-- Description : Simple log record processor. Immediately forwards each log record to the exporter.
-- Stability   : experimental
--
module OpenTelemetry.Processor.Simple.LogRecord (
  SimpleLogRecordProcessorConfig (..),
  simpleLogRecordProcessor,
) where

import Control.Concurrent.MVar
import Control.Exception
import Data.IORef
import Data.Maybe (fromMaybe)
import qualified Data.Vector as V
import OpenTelemetry.Internal.Common.Types (ExportResult (..), FlushResult (..), ShutdownResult (..))
import OpenTelemetry.Internal.Logging (otelLogWarning)
import OpenTelemetry.Internal.Log.Types
import System.Timeout (timeout)


-- | @since 0.0.1.0
data SimpleLogRecordProcessorConfig = SimpleLogRecordProcessorConfig
  { simpleLogRecordExporter :: LogRecordExporter
  , simpleLogRecordExportTimeoutMicros :: !Int
  -- ^ Export timeout in microseconds, defaults to 30,000,000 (30s)
  }


{- | Simple log record processor that exports each log record synchronously in
 @onEmit@.

 Per the OTel specification, the simple processor passes log records directly
 to the exporter. This means @onEmit@ blocks until the export completes,
 matching Go, Java, .NET, C++, Rust, and Python SDKs.

 Export calls are serialized via an internal MVar so that the exporter is
 never invoked concurrently, per the spec requirement that a processor MUST
 NOT invoke the exporter concurrently.

 Use 'OpenTelemetry.Processor.Batch.LogRecord.batchLogRecordProcessor' for
 non-blocking, production-grade log processing.

 @since 0.4.0.0
-}
simpleLogRecordProcessor :: SimpleLogRecordProcessorConfig -> IO LogRecordProcessor
simpleLogRecordProcessor SimpleLogRecordProcessorConfig {..} = do
  shutdownRef <- newIORef False
  exportLock <- newMVar ()
  pure
    LogRecordProcessor
      { logRecordProcessorOnEmit = \lr _ctxt -> do
          isShutdown <- readIORef shutdownRef
          if isShutdown
            then pure ()
            else do
              readable <- mkReadableLogRecord lr
              withMVar exportLock $ \_ -> do
                er <-
                  try @SomeException $
                    fromMaybe (Failure Nothing)
                      <$> timeout simpleLogRecordExportTimeoutMicros (logRecordExporterExport simpleLogRecordExporter (V.singleton readable))
                case er of
                  Left ex ->
                    otelLogWarning $ "Simple log record export failed: " <> show ex
                  Right Success -> pure ()
                  Right (Failure mex) ->
                    otelLogWarning $
                      "Simple log record export failed: "
                        <> maybe "timeout or unspecified" show mex
      , logRecordProcessorShutdown = do
          atomicWriteIORef shutdownRef True
          _ <- logRecordExporterForceFlush simpleLogRecordExporter
          logRecordExporterShutdown simpleLogRecordExporter
          pure ShutdownSuccess
      , logRecordProcessorForceFlush = logRecordExporterForceFlush simpleLogRecordExporter >> pure FlushSuccess
      }
