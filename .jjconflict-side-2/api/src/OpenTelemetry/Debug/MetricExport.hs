{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

{- |
Module      :  OpenTelemetry.Debug.MetricExport
Copyright   :  (c) Ian Duncan, 2024-2026
License     :  BSD-3
Description :  Human-readable rendering of 'ResourceMetricsExport' batches for tests and debugging.
Stability   :  experimental

This is not a stable interchange format.
-}
module OpenTelemetry.Debug.MetricExport (
  renderResourceMetricsExportDebug,
) where

import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.Lazy as TL
import Data.Text.Lazy.Builder (Builder, fromText, toLazyText)
import Data.Text.Lazy.Builder.Int (decimal)
import qualified Data.Vector as V
import OpenTelemetry.Exporter.Metric (
  MetricExport (..),
  ResourceMetricsExport (..),
  ScopeMetricsExport (..),
 )


{- | Multi-line text summary (not Prometheus or OTLP format).

@since 0.0.1.0
-}
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
renderMetric = TL.toStrict . toLazyText . renderMetricB


renderMetricB :: MetricExport -> Builder
renderMetricB = \case
  MetricExportSum n d u _ m i _ pts ->
    "Sum "
      <> fromText n
      <> " "
      <> fromText d
      <> " "
      <> fromText u
      <> " monotonic="
      <> showBool m
      <> " isInt="
      <> showBool i
      <> " nPts="
      <> decimal (V.length pts)
  MetricExportHistogram n d u _ _ pts ->
    "Histogram "
      <> fromText n
      <> " "
      <> fromText d
      <> " "
      <> fromText u
      <> " nPts="
      <> decimal (V.length pts)
  MetricExportExponentialHistogram n d u _ _ pts ->
    "ExponentialHistogram "
      <> fromText n
      <> " "
      <> fromText d
      <> " "
      <> fromText u
      <> " nPts="
      <> decimal (V.length pts)
  MetricExportGauge n d u _ i pts ->
    "Gauge "
      <> fromText n
      <> " "
      <> fromText d
      <> " "
      <> fromText u
      <> " isInt="
      <> showBool i
      <> " nPts="
      <> decimal (V.length pts)


showBool :: Bool -> Builder
showBool True = "True"
showBool False = "False"
