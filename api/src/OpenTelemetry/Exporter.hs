{-# LANGUAGE PatternSynonyms #-}

module OpenTelemetry.Exporter
  {-# DEPRECATED "use OpenTelemetry.Exporter.Span instead" #-} (
  Exporter,
  mkExporter,
  SpanExporter (..),
  ExportResult (..),
) where

import Data.HashMap.Strict (HashMap)
import Data.Vector (Vector)
import OpenTelemetry.Exporter.Span
import OpenTelemetry.Internal.Common.Types (InstrumentationLibrary)
import OpenTelemetry.Internal.Trace.Types (ImmutableSpan)


{-# DEPRECATED Exporter "use SpanExporter instead" #-}


type Exporter a = SpanExporter


{-# DEPRECATED mkExporter "use SpanExporter constructor directly" #-}


mkExporter :: (HashMap InstrumentationLibrary (Vector ImmutableSpan) -> IO ExportResult) -> IO () -> Exporter ImmutableSpan
mkExporter export shutdown =
  SpanExporter
    { spanExporterExport = export
    , spanExporterShutdown = shutdown
    , spanExporterForceFlush = pure ()
    }
