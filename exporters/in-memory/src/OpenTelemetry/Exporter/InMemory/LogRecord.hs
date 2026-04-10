{- |
Module      : OpenTelemetry.Exporter.InMemory.LogRecord
Description : In-memory log record exporter for testing. Stores exported log records in an IORef.
Stability   : experimental
-}
module OpenTelemetry.Exporter.InMemory.LogRecord (
  inMemoryLogRecordExporter,
  getExportedLogRecords,
) where

import Control.Monad.IO.Class
import Data.IORef
import qualified Data.Vector as V
import OpenTelemetry.Internal.Common.Types (ExportResult (..), FlushResult (..))
import OpenTelemetry.Internal.Log.Types


inMemoryLogRecordExporter :: (MonadIO m) => m (LogRecordExporter, IORef [ReadableLogRecord])
inMemoryLogRecordExporter = liftIO $ do
  ref <- newIORef []
  exporter <-
    mkLogRecordExporter
      LogRecordExporterArguments
        { logRecordExporterArgumentsExport = \lrs -> do
            let newRecords = V.toList lrs
            atomicModifyIORef ref (\existing -> (newRecords ++ existing, ()))
            pure Success
        , logRecordExporterArgumentsForceFlush = pure FlushSuccess
        , logRecordExporterArgumentsShutdown = pure ()
        }
  pure (exporter, ref)


getExportedLogRecords :: (MonadIO m) => IORef [ReadableLogRecord] -> m [ReadableLogRecord]
getExportedLogRecords = liftIO . readIORef
