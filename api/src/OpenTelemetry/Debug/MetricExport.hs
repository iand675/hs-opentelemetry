{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

{- | Human-readable rendering of 'ResourceMetricsExport' batches for tests and debugging.

 This is not a stable interchange format.
-}
module OpenTelemetry.Debug.MetricExport (
  renderResourceMetricsExportDebug,
) where

import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Vector as V
import OpenTelemetry.Exporter.Metric (
  MetricExport (..),
  ResourceMetricsExport (..),
  ScopeMetricsExport (..),
 )


-- | Multi-line text summary (not Prometheus or OTLP format).
renderResourceMetricsExportDebug :: [ResourceMetricsExport] -> Text
renderResourceMetricsExportDebug rs =
  T.intercalate "\n---\n" (fmap renderResource rs)


renderResource :: ResourceMetricsExport -> Text
renderResource ResourceMetricsExport {..} =
  T.intercalate "\n" $
    "ResourceMetricsExport"
      : fmap renderScope (V.toList resourceMetricsScopes)


renderScope :: ScopeMetricsExport -> Text
renderScope ScopeMetricsExport {..} =
  T.intercalate "\n" $
    "  ScopeMetricsExport"
      : fmap (\m -> T.append "    " (renderMetric m)) (V.toList scopeMetricsExports)


renderMetric :: MetricExport -> Text
renderMetric = \case
  MetricExportSum n d u _ m i _ pts ->
    T.concat
      [ "Sum ", n, " ", d, " ", u, " monotonic=", T.pack (show m), " isInt=", T.pack (show i), " nPts=", T.pack (show (V.length pts))
      ]
  MetricExportHistogram n d u _ _ pts ->
    T.concat ["Histogram ", n, " ", d, " ", u, " nPts=", T.pack (show (V.length pts))]
  MetricExportExponentialHistogram n d u _ _ pts ->
    T.concat ["ExponentialHistogram ", n, " ", d, " ", u, " nPts=", T.pack (show (V.length pts))]
  MetricExportGauge n d u _ i pts ->
    T.concat ["Gauge ", n, " ", d, " ", u, " isInt=", T.pack (show i), " nPts=", T.pack (show (V.length pts))]
