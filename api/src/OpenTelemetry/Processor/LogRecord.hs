module OpenTelemetry.Processor.LogRecord (
  LogRecordProcessor (..),
  FlushResult (..),
  flushErrorHandler,
  takeWorstFlushResult,
  ShutdownResult (..),
  shutdownErrorHandler,
  takeWorstShutdownResult,
  flushResultToShutdownResult,
) where

import OpenTelemetry.Internal.Common.Types
import OpenTelemetry.Internal.Logs.Types

