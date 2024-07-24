module OpenTelemetry.Logging.Core (
  -- * @LoggerProvider@ operations
  LoggerProvider (..),
  LoggerProviderOptions (..),
  emptyLoggerProviderOptions,
  createLoggerProvider,
  setGlobalLoggerProvider,
  getGlobalLoggerProvider,

  -- * @Logger@ operations
  InstrumentationLibrary (..),
  Logger (..),
  makeLogger,

  -- * @LogRecord@ operations
  LogRecord (..),
  LogRecordArguments (..),
  SeverityNumber (..),
  toShortName,
  emitLogRecord,
) where

import OpenTelemetry.Internal.Common.Types
import OpenTelemetry.Internal.Logging.Core
import OpenTelemetry.Internal.Logging.Types

