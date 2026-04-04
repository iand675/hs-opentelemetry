{- | Push metric exporter interface (specification/metrics/sdk.md — MetricExporter).
-}
module OpenTelemetry.Exporter.Metric (
  MetricExporter (..),
  module OpenTelemetry.Internal.Metrics.Export,
) where

import OpenTelemetry.Internal.Metrics.Export
