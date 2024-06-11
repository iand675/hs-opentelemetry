{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE TypeApplications #-}

module OpenTelemetry.Logging.Core (
  -- LoggerProvider operations
  LoggerProvider (..),
  LoggerProviderOptions (..),
  emptyLoggerProviderOptions,
  createLoggerProvider,
  globalLoggerProvider,
  setGlobalLoggerProvider,
  getGlobalLoggerProvider,
  -- Logger operations
  Logger (..),
  makeLogger,
  -- LogRecord operations
  LogRecord (..),
  LogRecordArguments (..),
  mkSeverityNumber,
  shortName,
  severityInt,
  emitLogRecord,
) where

import Control.Applicative
import Control.Monad.Trans
import Control.Monad.Trans.Maybe
import Data.Coerce
import Data.IORef
import Data.Maybe
import GHC.IO (unsafePerformIO)
import OpenTelemetry.Common
import OpenTelemetry.Context
import OpenTelemetry.Context.ThreadLocal
import OpenTelemetry.Internal.Common.Types
import OpenTelemetry.Internal.Logging.Types
import OpenTelemetry.Internal.Trace.Types
import OpenTelemetry.Resource (MaterializedResources, emptyMaterializedResources)
import System.Clock


getCurrentTimestamp :: (MonadIO m) => m Timestamp
getCurrentTimestamp = liftIO $ coerce @(IO TimeSpec) @(IO Timestamp) $ getTime Realtime


data LoggerProviderOptions = LoggerProviderOptions {loggerProviderOptionsResource :: Maybe MaterializedResources}


emptyLoggerProviderOptions :: LoggerProviderOptions
emptyLoggerProviderOptions =
  LoggerProviderOptions
    { loggerProviderOptionsResource = Just emptyMaterializedResources
    }


createLoggerProvider :: (MonadIO m) => LoggerProviderOptions -> m LoggerProvider
createLoggerProvider LoggerProviderOptions {..} = pure LoggerProvider {loggerProviderResource = loggerProviderOptionsResource}


globalLoggerProvider :: IORef LoggerProvider
globalLoggerProvider = unsafePerformIO $ newIORef =<< createLoggerProvider emptyLoggerProviderOptions
{-# NOINLINE globalLoggerProvider #-}


getGlobalLoggerProvider :: (MonadIO m) => m LoggerProvider
getGlobalLoggerProvider = liftIO $ readIORef globalLoggerProvider


setGlobalLoggerProvider :: (MonadIO m) => LoggerProvider -> m ()
setGlobalLoggerProvider = liftIO . writeIORef globalLoggerProvider


makeLogger :: LoggerProvider -> InstrumentationLibrary -> Logger
makeLogger loggerProvider loggerInstrumentationScope = Logger {..}


{- | Emits a LogRecord with properties specified by the passed in Logger and LogRecordArguments.
If observedTimestamp is not set in LogRecordArguments, it will default to the current timestamp.
If context is not specified in LogRecordArguments it will default to the current context.
-}
emitLogRecord
  :: (MonadIO m)
  => Logger
  -> LogRecordArguments body
  -> m (LogRecord body)
emitLogRecord Logger {..} LogRecordArguments {..} = do
  currentTimestamp <- getCurrentTimestamp
  let logRecordObservedTimestamp = fromMaybe currentTimestamp observedTimestamp

  logRecordTracingDetails <- runMaybeT $ do
    currentContext <- liftIO getContext
    currentSpan <- MaybeT $ pure $ lookupSpan $ fromMaybe currentContext context
    SpanContext {traceId, spanId, traceFlags} <- getSpanContext currentSpan
    pure (traceId, spanId, traceFlags)

  pure
    LogRecord
      { logRecordTimestamp = timestamp
      , logRecordObservedTimestamp
      , logRecordTracingDetails
      , logRecordSeverityNumber = fmap mkSeverityNumber severityNumber
      , logRecordSeverityText = severityText <|> (shortName . mkSeverityNumber =<< severityNumber)
      , logRecordBody = body
      , logRecordResource = loggerProviderResource loggerProvider
      , logRecordInstrumentationScope = loggerInstrumentationScope
      , logRecordAttributes = attributes
      }
