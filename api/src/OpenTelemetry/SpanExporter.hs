-----------------------------------------------------------------------------

-----------------------------------------------------------------------------

{- |
 Module      :  OpenTelemetry.SpanExporter
 Copyright   :  (c) Ian Duncan, 2021
 License     :  BSD-3
 Description :  Encode and transmit telemetry to external systems
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)

 Span Exporter defines the interface that protocol-specific exporters must implement so that they can be plugged into OpenTelemetry SDK and support sending of telemetry data.

 The goal of the interface is to minimize burden of implementation for protocol-dependent telemetry exporters. The protocol exporter is expected to be primarily a simple telemetry data encoder and transmitter.
-}
module OpenTelemetry.SpanExporter (
  SpanExporter (..),
  ExportResult (..),
) where

import OpenTelemetry.Internal.Common.Types
import OpenTelemetry.Internal.Trace.Types

