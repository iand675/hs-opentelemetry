module OpenTelemetry.Exporter.LogRecord (
  LogRecordExporter,
  LogRecordExporterArguments (..),
  mkLogRecordExporter,
  logRecordExporterExport,
  logRecordExporterForceFlush,
  logRecordExporterShutdown,
  ShutdownResult (..),
) where

import OpenTelemetry.Internal.Logs.Types (
  LogRecordExporter,
  LogRecordExporterArguments (..),
  logRecordExporterExport,
  logRecordExporterForceFlush,
  logRecordExporterShutdown,
  mkLogRecordExporter,
 )
import OpenTelemetry.Processor.LogRecord (ShutdownResult (..))

