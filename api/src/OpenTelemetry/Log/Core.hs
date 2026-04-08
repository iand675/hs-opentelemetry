-- |
-- Module      : OpenTelemetry.Log.Core
-- Copyright   : (c) Ian Duncan, 2021-2026
-- License     : BSD-3
-- Description : Public API for OpenTelemetry Logs
-- Stability   : experimental
--
-- = Overview
--
-- This module provides the Logs Bridge API for connecting existing logging
-- systems (e.g. @monad-logger@, @katip@, @co-log@) to OpenTelemetry. It is
-- /not/ intended as a direct logging API for end users; instead, it gives
-- logging library authors the hooks to route log records through the
-- OpenTelemetry pipeline (processors, exporters, and correlation with traces).
--
-- = Quick example
--
-- @
-- import OpenTelemetry.Log.Core
--
-- main :: IO ()
-- main = do
--   -- Create a provider (typically done by the SDK during initialization)
--   lp <- createLoggerProvider processors emptyLoggerProviderOptions
--   let logger = makeLogger lp "my-app"
--
--   -- Emit a log record
--   emitLogRecord logger $ LogRecordArguments
--     { severityNumber  = Just SeverityNumberInfo
--     , severityText    = Just "INFO"
--     , body            = Just (toValue ("User logged in" :: Text))
--     , attributes      = mempty
--     , timestamp       = Nothing
--     , observedTimestamp = Nothing
--     , traceContext     = Nothing
--     , instrumentationAttributes = Nothing
--     }
-- @
--
-- = Key concepts
--
-- [@LoggerProvider@] Factory for 'Logger's. Holds processors, resource info,
-- and attribute limits. Create with 'createLoggerProvider'.
--
-- [@Logger@] Obtained from a 'LoggerProvider', scoped to an instrumentation
-- library. Use 'makeLogger' or 'getLogger'.
--
-- [@LogRecord@] A single log entry with severity, body, attributes, and
-- optional correlation to a trace span. Emitted via 'emitLogRecord'.
--
-- = Severity filtering
--
-- You can set a minimum severity level to suppress low-priority logs:
--
-- @
-- setLoggerMinSeverity lp (Just SeverityNumberWarn)
-- -- Now only WARN and above are emitted
-- @
--
-- Both 'loggerIsEnabled' and 'emitLogRecord' respect this threshold.
-- Use 'Nothing' to disable filtering.
--
-- = Spec reference
--
-- <https://opentelemetry.io/docs/specs/otel/logs/bridge-api/>
--
module OpenTelemetry.Log.Core (
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

  -- * @Logger@ operations
  InstrumentationLibrary (..),
  instrumentationLibrary,
  withSchemaUrl,
  withLibraryAttributes,
  Logger (..),
  makeLogger,
  getLogger,
  loggerIsEnabled,
  loggerIsEnabled',
  setLoggerMinSeverity,
  getLoggerMinSeverity,

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
import OpenTelemetry.Internal.Log.Core
import OpenTelemetry.Internal.Log.Types

