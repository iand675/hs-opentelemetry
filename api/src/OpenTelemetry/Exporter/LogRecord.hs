{- |
Module      : OpenTelemetry.Exporter.LogRecord
Description : Re-exports of log record exporter types.
Stability   : experimental
-}
module OpenTelemetry.Exporter.LogRecord (
  LogRecordExporter,
  LogRecordExporterArguments (..),
  mkLogRecordExporter,
  logRecordExporterExport,
  logRecordExporterForceFlush,
  logRecordExporterShutdown,
  ShutdownResult (..),
) where

import OpenTelemetry.Internal.Log.Types (
  LogRecordExporter,
  LogRecordExporterArguments (..),
  logRecordExporterExport,
  logRecordExporterForceFlush,
  logRecordExporterShutdown,
  mkLogRecordExporter,
 )
import OpenTelemetry.Processor.LogRecord (ShutdownResult (..))

