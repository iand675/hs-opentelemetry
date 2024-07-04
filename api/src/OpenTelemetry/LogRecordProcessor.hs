{- |
 @LogRecordProcessor@ is an interface which allows hooks for @LogRecord@ emit method invocations.

 Built-in log processors are responsible for batching and conversion of spans to exportable representation and passing batches to exporters.

 Log processors can be registered directly on SDK LoggerProvider and they are invoked in the same order as they were registered.

 Each processor registered on LoggerProvider is a start of pipeline that consist of log processor and optional exporter. SDK MUST allow to end each pipeline with individual exporter.

 SDK MUST allow users to implement and configure custom processors and decorate built-in processors for advanced scenarios such as tagging or filtering.
-}
module OpenTelemetry.LogRecordProcessor (
  LogRecordProcessor (..),
  ShutdownResult (..),
) where

import OpenTelemetry.Internal.Common.Types
import OpenTelemetry.Internal.Logs.Types

