module OpenTelemetry.Exporter.LogRecord (
  LogRecordExporter,
  LogRecordExporterArguments (..),
  mkLogRecordExporter,
  logRecordExporterExport,
  logRecordExporterForceFlush,
  logRecordExporterShutdown,
  ExportResult (..),
  FlushResult (..),
  flushErrorHandler,
  takeWorstFlushResult,
  exportResultToFlushResult,
  ShutdownResult (..),
  shutdownErrorHandler,
  takeWorstShutdownResult,
  flushResultToShutdownResult,
) where

import OpenTelemetry.Internal.Common.Types
import OpenTelemetry.Internal.Logs.Types (
  LogRecordExporter,
  LogRecordExporterArguments (..),
  logRecordExporterExport,
  logRecordExporterForceFlush,
  logRecordExporterShutdown,
  mkLogRecordExporter,
 )

