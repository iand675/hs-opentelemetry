module OpenTelemetry.Processor.LogRecord (
  LogRecordProcessor (..),
  FlushResult (..),
  takeWorseFlushResult,
  takeWorstFlushResult,
  ShutdownResult (..),
  takeWorseShutdownResult,
  takeWorstShutdownResult,
  flushResultToShutdownResult,
) where

import OpenTelemetry.Internal.Common.Types
import OpenTelemetry.Internal.Logs.Types

