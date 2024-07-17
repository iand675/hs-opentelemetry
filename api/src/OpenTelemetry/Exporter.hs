module OpenTelemetry.Exporter (
  module OpenTelemetry.Exporter.Span,
  module OpenTelemetry.Exporter.LogRecord,
) where

import OpenTelemetry.Exporter.LogRecord
import OpenTelemetry.Exporter.Span


type Exporter a = SpanExporter
