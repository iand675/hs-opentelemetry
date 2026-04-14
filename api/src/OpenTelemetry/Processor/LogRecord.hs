{- |
Module      : OpenTelemetry.Processor.LogRecord
Description : Re-exports of log record processor types.
Stability   : experimental
-}
module OpenTelemetry.Processor.LogRecord (
  LogRecordProcessor (..),
  ShutdownResult (..),
  FlushResult (..),
) where

import OpenTelemetry.Internal.Common.Types
import OpenTelemetry.Internal.Log.Types

