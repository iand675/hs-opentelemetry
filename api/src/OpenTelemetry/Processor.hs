-----------------------------------------------------------------------------

-----------------------------------------------------------------------------

{- |
 Module      :  OpenTelemetry.Processor
 Copyright   :  (c) Ian Duncan, 2021
 License     :  BSD-3
 Description :  Hooks for performing actions on the start and end of recording spans
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)

 Span processor is an interface which allows hooks for span start and end method invocations. The span processors are invoked only when IsRecording is true.

 Built-in span processors are responsible for batching and conversion of spans to exportable representation and passing batches to exporters.

 Span processors can be registered directly on SDK TracerProvider and they are invoked in the same order as they were registered.

 Each processor registered on TracerProvider is a start of pipeline that consist of span processor and optional exporter. SDK MUST allow to end each pipeline with individual exporter.

 SDK MUST allow users to implement and configure custom processors and decorate built-in processors for advanced scenarios such as tagging or filtering.
-}
module OpenTelemetry.Processor (
  Processor (..),
  ShutdownResult (..),
) where

import OpenTelemetry.Internal.Common.Types
import OpenTelemetry.Internal.Trace.Types

