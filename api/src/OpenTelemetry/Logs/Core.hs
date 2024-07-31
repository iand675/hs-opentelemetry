module OpenTelemetry.Logs.Core (
  -- * @LoggerProvider@ operations
  LoggerProvider (..),
  LoggerProviderOptions (..),
  emptyLoggerProviderOptions,
  createLoggerProvider,
  setGlobalLoggerProvider,
  getGlobalLoggerProvider,
  shutdownLoggerProvider,
  ShutdownResult (..),
  forceFlushLoggerProvider,
  FlushResult (..),

  -- * @Logger@ operations
  InstrumentationLibrary (..),
  Logger (..),
  makeLogger,

  -- * @LogRecord@ operations
  ReadableLogRecord,
  mkReadableLogRecord,
  ReadWriteLogRecord,
  IsReadableLogRecord (..),
  IsReadWriteLogRecord (..),
  ImmutableLogRecord (..),
  LogRecordArguments (..),
  emptyLogRecordArguments,
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

