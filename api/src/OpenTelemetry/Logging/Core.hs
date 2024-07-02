{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE TypeApplications #-}

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
  logDroppedAttributes,
  emitOTelLogRecord,
) where

import Control.Applicative
import Control.Monad (void, when)
import Control.Monad.Trans
import Control.Monad.Trans.Maybe
import Data.Coerce
import qualified Data.HashMap.Strict as H
import Data.IORef
import Data.Maybe
import Data.Text (Text)
import qualified Data.Text as T
import Data.Version (showVersion)
import GHC.IO (unsafePerformIO)
import qualified OpenTelemetry.Attributes as A
import OpenTelemetry.Common
import OpenTelemetry.Context
import OpenTelemetry.Context.ThreadLocal
import OpenTelemetry.Internal.Common.Types
import OpenTelemetry.Internal.Logging.Types
import OpenTelemetry.Internal.Trace.Types (SpanContext (..), getSpanContext)
import OpenTelemetry.LogAttributes (LogAttributes)
import qualified OpenTelemetry.LogAttributes as LA
import OpenTelemetry.Resource (MaterializedResources, emptyMaterializedResources)
import Paths_hs_opentelemetry_api (version)
import System.Clock


getCurrentTimestamp :: (MonadIO m) => m Timestamp
getCurrentTimestamp = liftIO $ coerce @(IO TimeSpec) @(IO Timestamp) $ getTime Realtime


data LoggerProviderOptions = LoggerProviderOptions
  { loggerProviderOptionsResource :: MaterializedResources
  , loggerProviderOptionsAttributeLimits :: A.AttributeLimits
  }


{- | Options for creating a @LoggerProvider@ with no resources and default limits.

 In effect, logging is a no-op when using this configuration.
-}
emptyLoggerProviderOptions :: LoggerProviderOptions
emptyLoggerProviderOptions =
  LoggerProviderOptions
    { loggerProviderOptionsResource = emptyMaterializedResources
    , loggerProviderOptionsAttributeLimits = A.defaultAttributeLimits
    }


{- | Initialize a new @LoggerProvider@

 You should generally use @getGlobalLoggerProvider@ for most applications.
-}
createLoggerProvider :: LoggerProviderOptions -> LoggerProvider
createLoggerProvider LoggerProviderOptions {..} =
  LoggerProvider
    { loggerProviderResource = loggerProviderOptionsResource
    , loggerProviderAttributeLimits = loggerProviderOptionsAttributeLimits
    }


globalLoggerProvider :: IORef LoggerProvider
globalLoggerProvider = unsafePerformIO $ newIORef $ createLoggerProvider emptyLoggerProviderOptions
{-# NOINLINE globalLoggerProvider #-}


-- | Access the globally configured @LoggerProvider@. This @LoggerProvider@ is no-op until initialized by the SDK
getGlobalLoggerProvider :: (MonadIO m) => m LoggerProvider
getGlobalLoggerProvider = liftIO $ readIORef globalLoggerProvider


{- | Overwrite the globally configured @LoggerProvider@.

 @Logger@s acquired from the previously installed @LoggerProvider@s
 will continue to use that @LoggerProvider@s settings.
-}
setGlobalLoggerProvider :: (MonadIO m) => LoggerProvider -> m ()
setGlobalLoggerProvider = liftIO . writeIORef globalLoggerProvider


makeLogger
  :: LoggerProvider
  -- ^ The @LoggerProvider@ holds the configuration for the @Logger@.
  -> InstrumentationLibrary
  -- ^ The library that the @Logger@ instruments. This uniquely identifies the @Logger@.
  -> Logger
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

  let logRecordAttributes =
        LA.addAttributes
          (loggerProviderAttributeLimits loggerProvider)
          LA.emptyAttributes
          attributes

  when (LA.attributesDropped logRecordAttributes > 0) $ void logDroppedAttributes

  pure
    LogRecord
      { logRecordTimestamp = timestamp
      , logRecordObservedTimestamp
      , logRecordTracingDetails
      , logRecordSeverityNumber = severityNumber
      , logRecordSeverityText = severityText <|> (toShortName =<< severityNumber)
      , logRecordBody = body
      , logRecordResource = loggerProviderResource loggerProvider
      , logRecordInstrumentationScope = loggerInstrumentationScope
      , logRecordAttributes
      }


logDroppedAttributes :: (MonadIO m) => m (LogRecord Text)
logDroppedAttributes = emitOTelLogRecord H.empty Warn "At least 1 attribute was discarded due to the attribute limits set in the logger provider."


emitOTelLogRecord :: (MonadIO m) => H.HashMap Text LA.AnyValue -> SeverityNumber -> Text -> m (LogRecord Text)
emitOTelLogRecord attrs severity body = do
  glp <- getGlobalLoggerProvider
  let gl =
        makeLogger glp $
          InstrumentationLibrary
            { libraryName = "hs-opentelemetry-api"
            , libraryVersion = T.pack $ showVersion version
            , librarySchemaUrl = ""
            , libraryAttributes = A.emptyAttributes
            }

  emitLogRecord gl $
    (emptyLogRecordArguments body)
      { severityNumber = Just severity
      , attributes = attrs
      }
