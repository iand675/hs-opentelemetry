module OpenTelemetry.Exporter.LogRecord (
  LogRecordExporter,
  LogRecordExporterArguments (..),
  mkLogRecordExporter,
  logRecordExporterExport,
  logRecordExporterForceFlush,
  logRecordExporterShutdown,
  ShutdownResult (..),
  ExportResult (..),
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

