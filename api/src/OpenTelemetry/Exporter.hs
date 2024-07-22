{-# LANGUAGE PatternSynonyms #-}

module OpenTelemetry.Exporter
  {-# DEPRECATED "use OpenTelemetry.Exporter.Span instead" #-} (
  Exporter,
  SpanExporter (Exporter, exporterExport, exporterShutdown),
  ExportResult (..),
) where

import Data.HashMap.Strict (HashMap)
import Data.Vector (Vector)
import OpenTelemetry.Exporter.Span
import OpenTelemetry.Internal.Common.Types (InstrumentationLibrary)
import OpenTelemetry.Internal.Trace.Types (ImmutableSpan)


{-# DEPRECATED Exporter "use SpanExporter instead" #-}


type Exporter a = SpanExporter


pattern Exporter :: (HashMap InstrumentationLibrary (Vector ImmutableSpan) -> IO ExportResult) -> IO () -> Exporter ImmutableSpan
pattern Exporter {exporterExport, exporterShutdown} =
  SpanExporter
    { spanExporterExport = exporterExport
    , spanExporterShutdown = exporterShutdown
    }
