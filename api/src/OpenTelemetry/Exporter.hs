{-# LANGUAGE PatternSynonyms #-}

{- |
Module      : OpenTelemetry.Exporter
Description : Re-exports of span exporter types.
Stability   : experimental

This module is deprecated; prefer 'OpenTelemetry.Exporter.Span'.
-}
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
import OpenTelemetry.Internal.Common.Types (FlushResult (..), InstrumentationLibrary, ShutdownResult (..))
import OpenTelemetry.Internal.Trace.Types (ImmutableSpan)


{-# DEPRECATED Exporter "use SpanExporter instead" #-}


type Exporter a = SpanExporter


{-# DEPRECATED mkExporter "use SpanExporter constructor directly" #-}
mkExporter :: (HashMap InstrumentationLibrary (Vector ImmutableSpan) -> IO ExportResult) -> IO () -> Exporter ImmutableSpan
mkExporter export shutdown =
  SpanExporter
    { spanExporterExport = export
    , spanExporterShutdown = shutdown >> pure ShutdownSuccess
    , spanExporterForceFlush = pure FlushSuccess
    }
