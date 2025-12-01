{-# LANGUAGE PatternSynonyms #-}

module OpenTelemetry.Exporter
  {-# DEPRECATED "use OpenTelemetry.Exporter.Span instead" #-} (
  Exporter,
  SpanExporter (Exporter, exporterExport, exporterShutdown),
  ExportResult (..),
) where

import Data.Vector (Vector)
import OpenTelemetry.Exporter.Span


{-# DEPRECATED Exporter "use SpanExporter instead" #-}


type Exporter a = SpanExporter


pattern Exporter :: (Vector MaterializedResourceSpans -> IO ExportResult) -> IO () -> Exporter MaterializedResourceSpans
pattern Exporter {exporterExport, exporterShutdown} =
  SpanExporter
    { spanExporterExport = exporterExport
    , spanExporterShutdown = exporterShutdown
    }
