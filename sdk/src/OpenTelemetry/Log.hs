{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

{- |
Module      :  OpenTelemetry.Log
Copyright   :  (c) Ian Duncan, 2021-2026
License     :  BSD-3
Description :  OpenTelemetry Logs SDK — batteries-included setup
Stability   :  experimental

= Overview

This is the main entry point for connecting logging systems to OpenTelemetry.
It re-exports the Logs Bridge API from "OpenTelemetry.Log.Core" and adds
SDK-level initialization with env-var configuration.

Note: this is the /Logs Bridge API/ — it is intended for logging library
authors who want to route log records through the OpenTelemetry pipeline
(processors, exporters, trace correlation). End users typically interact
with their existing logging framework, which uses this bridge internally.

= Quick example

@
{\-# LANGUAGE OverloadedStrings #-\}
module Main where

import OpenTelemetry.Log

main :: IO ()
main = withLoggerProvider $ \\lp -> do
  let logger = makeLogger lp "my-app"
  emitLogRecord logger $ emptyLogRecordArguments
    { body = Just (toValue ("Application started" :: Text))
    , severityNumber = Just SeverityNumberInfo
    }
  -- ... application code ...
@

'withLoggerProvider' reads configuration from @OTEL_*@ environment variables,
sets up a batch log record processor with an OTLP exporter, and ensures
shutdown on exit.

If you also use 'OpenTelemetry.Trace.withTracerProvider', it already sets up
a 'LoggerProvider' for you — use this module when you need logs without
traces, or want explicit control.

= Configuration

| Variable | Default | Description |
|---|---|---|
| @OTEL_SDK_DISABLED@ | @false@ | Disable all telemetry |
| @OTEL_LOGS_EXPORTER@ | @otlp@ | @otlp@, @console@, @none@ |
| @OTEL_BLRP_MAX_QUEUE_SIZE@ | @2048@ | Batch processor queue size |
| @OTEL_BLRP_SCHEDULE_DELAY_MILLIS@ | @1000@ | Batch export delay (ms). Legacy alias: @OTEL_BLRP_SCHEDULE_DELAY@ |
| @OTEL_BLRP_EXPORT_TIMEOUT_MILLIS@ | @30000@ | Export timeout (ms). Legacy alias: @OTEL_BLRP_EXPORT_TIMEOUT@ |
| @OTEL_BLRP_MAX_EXPORT_BATCH_SIZE@ | @512@ | Max records per batch (clamped to queue size) |
| @OTEL_LOGRECORD_ATTRIBUTE_COUNT_LIMIT@ | @128@ | Max attributes per log record. Falls back to @OTEL_ATTRIBUTE_COUNT_LIMIT@ |
| @OTEL_LOGRECORD_ATTRIBUTE_VALUE_LENGTH_LIMIT@ | no limit | Max attribute value length. Falls back to @OTEL_ATTRIBUTE_VALUE_LENGTH_LIMIT@ |

= Spec reference

<https://opentelemetry.io/docs/specs/otel/logs/sdk/>
-}
module OpenTelemetry.Log (
  -- * Provider lifecycle
  withLoggerProvider,
  initializeGlobalLoggerProvider,

  -- * Logs Bridge API (re-exported from "OpenTelemetry.Log.Core")

  -- ** LoggerProvider
  LoggerProvider (..),
  LoggerProviderOptions (..),
  emptyLoggerProviderOptions,
  createLoggerProvider,
  setGlobalLoggerProvider,
  getGlobalLoggerProvider,
  shutdownLoggerProvider,

  -- ** Logger
  Logger (..),
  makeLogger,
  getLogger,
  loggerIsEnabled,
  loggerIsEnabled',
  setLoggerMinSeverity,
  getLoggerMinSeverity,

  -- ** LogRecord
  ReadableLogRecord,
  ReadWriteLogRecord,
  IsReadableLogRecord (..),
  IsReadWriteLogRecord (..),
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

  -- * Processors

  -- ** Batch processor
  BatchLogRecordProcessorConfig (..),
  defaultBatchLogRecordProcessorConfig,
  batchLogRecordProcessor,

  -- ** Simple processor
  SimpleLogRecordProcessorConfig (..),
  simpleLogRecordProcessor,

  -- * Common types
  InstrumentationLibrary (..),
  instrumentationLibrary,
  withSchemaUrl,
  withLibraryAttributes,
  ShutdownResult (..),
  FlushResult (..),
) where

import Control.Applicative ((<|>))
import Control.Exception (bracket)
import Control.Monad (when)
import qualified Data.HashMap.Strict as H
import Data.Maybe (fromMaybe)
import qualified Data.Text as T
import OpenTelemetry.Attributes (AttributeLimits (..), defaultAttributeLimits)
import OpenTelemetry.Environment (LogsExporterSelection (..), lookupBooleanEnv, lookupLogsExporterSelection)
import OpenTelemetry.Exporter.Handle.LogRecord (stdoutLogRecordExporter)
import OpenTelemetry.Exporter.OTLP.LogRecord (otlpLogRecordExporter)
import OpenTelemetry.Exporter.OTLP.Span (loadExporterEnvironmentVariables)
import OpenTelemetry.Internal.Common.Types (FlushResult (..), InstrumentationLibrary (..), ShutdownResult (..))
import OpenTelemetry.Internal.Log.Types (LogRecordExporter, emptyLogRecordArguments)
import OpenTelemetry.Internal.Logging (otelLogDebug, otelLogWarning)
import OpenTelemetry.Log.Core
import OpenTelemetry.Processor.Batch.LogRecord (BatchLogRecordProcessorConfig (..), batchLogRecordProcessor, defaultBatchLogRecordProcessorConfig)
import OpenTelemetry.Processor.Simple.LogRecord (SimpleLogRecordProcessorConfig (..), simpleLogRecordProcessor)
import qualified OpenTelemetry.Registry as Registry
import System.Environment (lookupEnv)
import Text.Read (readMaybe)


{- | Initialize a 'LoggerProvider' from environment variables, set it as the
global logger provider, and run an action. The provider is shut down on exit
(including exceptions).

@
main :: IO ()
main = withLoggerProvider $ \\lp -> do
  let logger = makeLogger lp "my-service"
  emitLogRecord logger ...
@

@since 0.0.1.0
-}
withLoggerProvider :: (LoggerProvider -> IO a) -> IO a
withLoggerProvider body =
  bracket
    initializeGlobalLoggerProvider
    (\lp -> shutdownLoggerProvider lp Nothing >> pure ())
    body


{- | Create a 'LoggerProvider' from @OTEL_*@ environment variables and install
it as the global provider via 'setGlobalLoggerProvider'.

Returns the 'LoggerProvider'. The caller must call 'shutdownLoggerProvider'
when the application exits.

Reads:

* @OTEL_SDK_DISABLED@ — if @true@, returns an empty provider
* @OTEL_LOGS_EXPORTER@ — selects the exporter (default: @otlp@)
* @OTEL_BLRP_MAX_QUEUE_SIZE@, @OTEL_BLRP_SCHEDULE_DELAY_MILLIS@,
  @OTEL_BLRP_EXPORT_TIMEOUT_MILLIS@, @OTEL_BLRP_MAX_EXPORT_BATCH_SIZE@ —
  batch processor configuration
* @OTEL_LOGRECORD_ATTRIBUTE_COUNT_LIMIT@, @OTEL_LOGRECORD_ATTRIBUTE_VALUE_LENGTH_LIMIT@ —
  signal-specific attribute limits (fall back to @OTEL_ATTRIBUTE_COUNT_LIMIT@ /
  @OTEL_ATTRIBUTE_VALUE_LENGTH_LIMIT@)

@since 0.0.1.0
-}
initializeGlobalLoggerProvider :: IO LoggerProvider
initializeGlobalLoggerProvider = do
  disabled <- lookupBooleanEnv "OTEL_SDK_DISABLED"
  if disabled
    then do
      otelLogDebug "OTEL_SDK_DISABLED=true, using empty LoggerProvider"
      lp <- createLoggerProvider [] emptyLoggerProviderOptions
      setGlobalLoggerProvider lp
      pure lp
    else do
      lp <- initializeLoggerProvider
      setGlobalLoggerProvider lp
      otelLogDebug "LoggerProvider initialized from environment"
      pure lp


-- Internal: create provider from env vars
initializeLoggerProvider :: IO LoggerProvider
initializeLoggerProvider = do
  attrLimits <- detectLogRecordAttributeLimits
  let opts = emptyLoggerProviderOptions {loggerProviderOptionsAttributeLimits = attrLimits}
  sel <- lookupLogsExporterSelection
  case sel of
    Just LogsExporterNone -> createLoggerProvider [] opts
    _ -> do
      exporter <- detectLogExporter sel
      blrpConf <- detectBatchLogProcessorConfig exporter
      processor <- batchLogRecordProcessor blrpConf
      createLoggerProvider [processor] opts


detectLogExporter :: Maybe LogsExporterSelection -> IO LogRecordExporter
detectLogExporter sel = do
  registerBuiltinLogExporters
  let lookupByName name = do
        allExporters <- Registry.registeredLogRecordExporterFactories
        case H.lookup name allExporters of
          Just factory -> factory
          Nothing -> do
            otelLogWarning ("No log exporter registered for '" <> T.unpack name <> "', using console")
            stdoutLogRecordExporter
  case sel of
    Just LogsExporterConsole -> stdoutLogRecordExporter
    Just (LogsExporterCustom name) -> lookupByName (T.pack name)
    _ -> lookupByName "otlp"


registerBuiltinLogExporters :: IO ()
registerBuiltinLogExporters = do
  _ <-
    Registry.registerLogRecordExporterFactoryIfAbsent "otlp" $ do
      otlpConfig <- loadExporterEnvironmentVariables
      otlpLogRecordExporter otlpConfig
  _ <-
    Registry.registerLogRecordExporterFactoryIfAbsent
      "console"
      stdoutLogRecordExporter
  pure ()


detectBatchLogProcessorConfig :: LogRecordExporter -> IO BatchLogRecordProcessorConfig
detectBatchLogProcessorConfig exporter = do
  queueSize <- readEnvDefault "OTEL_BLRP_MAX_QUEUE_SIZE" 2048
  delay <- readEnvDefaultWithAlias "OTEL_BLRP_SCHEDULE_DELAY_MILLIS" "OTEL_BLRP_SCHEDULE_DELAY" 1000
  exportTimeout <- readEnvDefaultWithAlias "OTEL_BLRP_EXPORT_TIMEOUT_MILLIS" "OTEL_BLRP_EXPORT_TIMEOUT" 30000
  rawBatchSize <- readEnvDefault "OTEL_BLRP_MAX_EXPORT_BATCH_SIZE" 512
  let batchSize = min rawBatchSize queueSize
  when (rawBatchSize > queueSize) $
    otelLogWarning ("OTEL_BLRP_MAX_EXPORT_BATCH_SIZE (" <> show rawBatchSize <> ") exceeds OTEL_BLRP_MAX_QUEUE_SIZE (" <> show queueSize <> "), clamping to " <> show batchSize)
  pure (BatchLogRecordProcessorConfig exporter queueSize delay exportTimeout batchSize)


{- | Detect attribute limits for log records from environment variables.

Signal-specific vars take precedence over general vars, per the spec:

@OTEL_LOGRECORD_ATTRIBUTE_COUNT_LIMIT@ > @OTEL_ATTRIBUTE_COUNT_LIMIT@ > 128
@OTEL_LOGRECORD_ATTRIBUTE_VALUE_LENGTH_LIMIT@ > @OTEL_ATTRIBUTE_VALUE_LENGTH_LIMIT@ > no limit
-}
detectLogRecordAttributeLimits :: IO AttributeLimits
detectLogRecordAttributeLimits = do
  generalCount <- readEnvMaybe "OTEL_ATTRIBUTE_COUNT_LIMIT"
  logCount <- readEnvMaybe "OTEL_LOGRECORD_ATTRIBUTE_COUNT_LIMIT"
  generalLength <- readEnvMaybe "OTEL_ATTRIBUTE_VALUE_LENGTH_LIMIT"
  logLength <- readEnvMaybe "OTEL_LOGRECORD_ATTRIBUTE_VALUE_LENGTH_LIMIT"
  pure
    AttributeLimits
      { attributeCountLimit = logCount <|> generalCount <|> attributeCountLimit defaultAttributeLimits
      , attributeLengthLimit = logLength <|> generalLength
      }
  where
    readEnvMaybe :: (Read a) => String -> IO (Maybe a)
    readEnvMaybe k = (>>= readMaybe) <$> lookupEnv k


readEnvDefault :: forall a. (Read a) => String -> a -> IO a
readEnvDefault k defaultValue =
  fromMaybe defaultValue . (>>= readMaybe) <$> lookupEnv k


readEnvDefaultWithAlias :: forall a. (Read a) => String -> String -> a -> IO a
readEnvDefaultWithAlias primary fallback defaultValue = do
  mv <- lookupEnv primary
  case mv >>= readMaybe of
    Just v -> pure v
    Nothing -> readEnvDefault fallback defaultValue
