module OpenTelemetry.Logs.Core (
  -- * @LoggerProvider@ operations
  LoggerProvider (..),
  LoggerProviderOptions (..),
  emptyLoggerProviderOptions,
  createLoggerProvider,
  setGlobalLoggerProvider,
  getGlobalLoggerProvider,
  shutdownLoggerProvider,
  forceFlushLoggerProvider,

  -- * @Logger@ operations
  InstrumentationLibrary (..),
  Logger (..),
  makeLogger,

  -- * @LogRecord@ operations
  ReadableLogRecord,
  ReadWriteLogRecord,
  IsReadableLogRecord (..),
  IsReadWriteLogRecord (..),
  LogRecordArguments (..),
  AnyValue (..),
  ToValue (..),
  SeverityNumber (..),
  toShortName,
  emitLogRecord,
  addAttribute,
  addAttributes,
  logRecordGetAttributes,
) where

import OpenTelemetry.Internal.Common.Types
import OpenTelemetry.Internal.Logs.Core
import OpenTelemetry.Internal.Logs.Types

