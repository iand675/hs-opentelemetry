module OpenTelemetry.Exporter.LogRecord (
  LogRecordExporter,
  LogRecordExporterInternal (..),
  mkLogRecordExporter,
  logRecordExporterExport,
  logRecordExporterForceFlush,
  logRecordExporterShutdown,
  ShutdownResult (..),
) where

import OpenTelemetry.Internal.Logs.Types (
  LogRecordExporter,
  LogRecordExporterInternal (..),
  logRecordExporterExport,
  logRecordExporterForceFlush,
  logRecordExporterShutdown,
  mkLogRecordExporter,
 )
import OpenTelemetry.Processor.LogRecord (ShutdownResult (..))

