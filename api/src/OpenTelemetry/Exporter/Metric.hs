-----------------------------------------------------------------------------

-----------------------------------------------------------------------------

{- |
 Module      :  OpenTelemetry.Exporter.Metric
 Copyright   :  (c) Ian Duncan, 2024
 License     :  BSD-3
 Description :  Encode and transmit metric data to external systems
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)

 Metric Exporter defines the interface that protocol-specific exporters must
 implement so that they can be plugged into OpenTelemetry SDK and support sending
 of metric data.

 The goal of the interface is to minimize burden of implementation for
 protocol-dependent telemetry exporters. The protocol exporter is expected to be
 primarily a simple telemetry data encoder and transmitter.

 Metric exporters should also specify their preferred aggregation temporality for
 different instrument kinds. This allows the SDK to configure aggregations appropriately.
-}
module OpenTelemetry.Exporter.Metric (
  MetricExporter (..),
  ExportResult (..),
  InstrumentKind (..),
  AggregationTemporality (..),
) where

import OpenTelemetry.Internal.Common.Types
import OpenTelemetry.Internal.Metrics.Types
