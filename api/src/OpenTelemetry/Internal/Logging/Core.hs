{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE TypeApplications #-}

module OpenTelemetry.Internal.Logging.Core (
  LoggerProviderOptions (..),
  emptyLoggerProviderOptions,
  createLoggerProvider,
  setGlobalLoggerProvider,
  getGlobalLoggerProvider,
  makeLogger,
  emitLogRecord,
  addAttribute,
  addAttributes,
  logRecordGetAttributes,
  logDroppedAttributes,
  emitOTelLogRecord,
) where

import Control.Applicative
import Control.Monad (void, when)
import Control.Monad.Trans
import Control.Monad.Trans.Maybe
import Data.Coerce
import Data.HashMap.Strict (HashMap)
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
import OpenTelemetry.LogAttributes (LogAttributes, ToValue)
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


createImmutableLogRecord
  :: (MonadIO m)
  => LA.AttributeLimits
  -> LogRecordArguments body
  -> m (ImmutableLogRecord body)
createImmutableLogRecord attributeLimits LogRecordArguments {..} = do
  currentTimestamp <- getCurrentTimestamp
  let logRecordObservedTimestamp = fromMaybe currentTimestamp observedTimestamp

  logRecordTracingDetails <- runMaybeT $ do
    currentContext <- liftIO getContext
    currentSpan <- MaybeT $ pure $ lookupSpan $ fromMaybe currentContext context
    SpanContext {traceId, spanId, traceFlags} <- getSpanContext currentSpan
    pure (traceId, spanId, traceFlags)

  let logRecordAttributes =
        LA.addAttributes
          attributeLimits
          LA.emptyAttributes
          attributes

  when (LA.attributesDropped logRecordAttributes > 0) $ void logDroppedAttributes

  pure
    ImmutableLogRecord
      { logRecordTimestamp = timestamp
      , logRecordObservedTimestamp
      , logRecordTracingDetails
      , logRecordSeverityNumber = severityNumber
      , logRecordSeverityText = severityText <|> (toShortName =<< severityNumber)
      , logRecordBody = body
      , logRecordAttributes
      }


-- | WARNING: this function should only be used to emit logs from the hs-opentelemetry-api library. DO NOT USE this function in any other context.
logDroppedAttributes :: (MonadIO m) => m (LogRecord Text)
logDroppedAttributes = emitOTelLogRecord H.empty Warn "At least 1 attribute was discarded due to the attribute limits set in the logger provider."


-- | WARNING: this function should only be used to emit logs from the hs-opentelemetry-api library. DO NOT USE this function in any other context.
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


{- | Emits a LogRecord with properties specified by the passed in Logger and LogRecordArguments.
If observedTimestamp is not set in LogRecordArguments, it will default to the current timestamp.
If context is not specified in LogRecordArguments it will default to the current context.
-}
emitLogRecord
  :: (MonadIO m)
  => Logger
  -> LogRecordArguments body
  -> m (LogRecord body)
emitLogRecord l args = do
  ilr <- createImmutableLogRecord (loggerProviderAttributeLimits $ loggerProvider l) args
  liftIO $ mkLogRecord l ilr


{- | Add an attribute to a @LogRecord@.

This is not an atomic modification

As an application developer when you need to record an attribute first consult existing semantic conventions for Resources, Spans, and Metrics. If an appropriate name does not exists you will need to come up with a new name. To do that consider a few options:

The name is specific to your company and may be possibly used outside the company as well. To avoid clashes with names introduced by other companies (in a distributed system that uses applications from multiple vendors) it is recommended to prefix the new name by your company’s reverse domain name, e.g. 'com.acme.shopname'.

The name is specific to your application that will be used internally only. If you already have an internal company process that helps you to ensure no name clashes happen then feel free to follow it. Otherwise it is recommended to prefix the attribute name by your application name, provided that the application name is reasonably unique within your organization (e.g. 'myuniquemapapp.longitude' is likely fine). Make sure the application name does not clash with an existing semantic convention namespace.

The name may be generally applicable to applications in the industry. In that case consider submitting a proposal to this specification to add a new name to the semantic conventions, and if necessary also to add a new namespace.

It is recommended to limit names to printable Basic Latin characters (more precisely to 'U+0021' .. 'U+007E' subset of Unicode code points), although the Haskell OpenTelemetry specification DOES provide full Unicode support.

Attribute names that start with 'otel.' are reserved to be defined by OpenTelemetry specification. These are typically used to express OpenTelemetry concepts in formats that don’t have a corresponding concept.

For example, the 'otel.library.name' attribute is used to record the instrumentation library name, which is an OpenTelemetry concept that is natively represented in OTLP, but does not have an equivalent in other telemetry formats and protocols.

Any additions to the 'otel.*' namespace MUST be approved as part of OpenTelemetry specification.
-}
addAttribute :: (ReadWriteLogRecord r, MonadIO m, ToValue a) => r body -> Text -> a -> m ()
addAttribute lr k v =
  let attributeLimits = readLogRecordAttributeLimits lr
  in liftIO $
      modifyLogRecord
        lr
        ( \ilr@ImmutableLogRecord {logRecordAttributes} ->
            ilr
              { logRecordAttributes =
                  LA.addAttribute
                    attributeLimits
                    logRecordAttributes
                    k
                    v
              }
        )


{- | A convenience function related to 'addAttribute' that adds multiple attributes to a @LogRecord@ at the same time.

This function may be slightly more performant than repeatedly calling 'addAttribute'.

This is not an atomic modification
-}
addAttributes :: (ReadWriteLogRecord r, MonadIO m, ToValue a) => r body -> HashMap Text a -> m ()
addAttributes lr attrs =
  let attributeLimits = readLogRecordAttributeLimits lr
  in liftIO $
      modifyLogRecord
        lr
        ( \ilr@ImmutableLogRecord {logRecordAttributes} ->
            ilr
              { logRecordAttributes =
                  LA.addAttributes
                    attributeLimits
                    logRecordAttributes
                    attrs
              }
        )


{- | This can be useful for pulling data for attributes and
 using it to copy / otherwise use the data to further enrich
 instrumentation.
-}
logRecordGetAttributes :: (ReadableLogRecord r, MonadIO m) => r a -> m LogAttributes
logRecordGetAttributes lr = liftIO $ logRecordAttributes <$> readLogRecord lr
