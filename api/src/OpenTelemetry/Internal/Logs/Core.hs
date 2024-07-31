{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE TypeApplications #-}

module OpenTelemetry.Internal.Logs.Core (
  LoggerProviderOptions (..),
  emptyLoggerProviderOptions,
  createLoggerProvider,
  setGlobalLoggerProvider,
  getGlobalLoggerProvider,
  shutdownLoggerProvider,
  forceFlushLoggerProvider,
  makeLogger,
  emitLogRecord,
  addAttribute,
  addAttributes,
  logRecordGetAttributes,
  logDroppedAttributes,
  emitOTelLogRecord,
) where

import Control.Applicative
import Control.Concurrent.Async
import Control.Monad
import Control.Monad.Trans
import Control.Monad.Trans.Maybe
import Data.Coerce
import Data.HashMap.Strict (HashMap)
import qualified Data.HashMap.Strict as H
import Data.IORef
import Data.Maybe
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Vector as V
import Data.Version (showVersion)
import GHC.IO (unsafePerformIO)
import qualified OpenTelemetry.Attributes as A
import OpenTelemetry.Common
import OpenTelemetry.Context
import OpenTelemetry.Context.ThreadLocal
import OpenTelemetry.Internal.Common.Types
import OpenTelemetry.Internal.Logs.Types
import OpenTelemetry.Internal.Trace.Types (SpanContext (..), getSpanContext)
import OpenTelemetry.LogAttributes (LogAttributes, ToValue)
import qualified OpenTelemetry.LogAttributes as LA
import OpenTelemetry.Resource (MaterializedResources, emptyMaterializedResources)
import Paths_hs_opentelemetry_api (version)
import System.Clock
import System.Timeout (timeout)


getCurrentTimestamp :: (MonadIO m) => m Timestamp
getCurrentTimestamp = liftIO $ coerce @(IO TimeSpec) @(IO Timestamp) $ getTime Realtime


data LoggerProviderOptions = LoggerProviderOptions
  { loggerProviderOptionsResource :: MaterializedResources
  , loggerProviderOptionsAttributeLimits :: A.AttributeLimits
  }


{- | Options for creating a @LoggerProvider@ with no resources and default limits.

 In effect, logging is a no-op when using this configuration and no-op Processors.
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
createLoggerProvider :: [LogRecordProcessor] -> LoggerProviderOptions -> LoggerProvider
createLoggerProvider ps LoggerProviderOptions {..} =
  LoggerProvider
    { loggerProviderProcessors = V.fromList ps
    , loggerProviderResource = loggerProviderOptionsResource
    , loggerProviderAttributeLimits = loggerProviderOptionsAttributeLimits
    }


-- | Logging is no-op when using this @LoggerProvider@ because it has no processors and empty options.
noOpLoggerProvider :: LoggerProvider
noOpLoggerProvider = createLoggerProvider [] emptyLoggerProviderOptions


globalLoggerProvider :: IORef LoggerProvider
globalLoggerProvider = unsafePerformIO $ newIORef noOpLoggerProvider
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


{- | This method provides a way for provider to do any cleanup required.

 This will also trigger shutdowns on all internal processors.
-}
shutdownLoggerProvider :: (MonadIO m) => LoggerProvider -> m ()
shutdownLoggerProvider LoggerProvider {loggerProviderProcessors} = liftIO $ do
  asyncShutdownResults <- V.forM loggerProviderProcessors $ \processor -> do
    logRecordProcessorShutdown processor
  mapM_ wait asyncShutdownResults


{- | This method provides a way for provider to immediately export all @LogRecord@s that have not yet
 been exported for all the internal processors.
-}
forceFlushLoggerProvider
  :: (MonadIO m)
  => LoggerProvider
  -> Maybe Int
  -- ^ Optional timeout in microseconds, defaults to 5,000,000 (5s)
  -> m FlushResult
  -- ^ Result that denotes whether the flush action succeeded, failed, or timed out.
forceFlushLoggerProvider LoggerProvider {loggerProviderProcessors} mtimeout = liftIO $ do
  jobs <- V.forM loggerProviderProcessors $ \processor -> async $ do
    logRecordProcessorForceFlush processor
  mresult <-
    timeout (fromMaybe 5_000_000 mtimeout) $
      V.foldM
        ( \status action -> do
            res <- waitCatch action
            pure $! case res of
              Left _err -> FlushError
              Right _ok -> status
        )
        FlushSuccess
        jobs
  case mresult of
    Nothing -> pure FlushTimeout
    Just res -> pure res


makeLogger
  :: LoggerProvider
  -- ^ The @LoggerProvider@ holds the configuration for the @Logger@.
  -> InstrumentationLibrary
  -- ^ The library that the @Logger@ instruments. This uniquely identifies the @Logger@.
  -> Logger
makeLogger loggerLoggerProvider loggerInstrumentationScope = Logger {..}


createImmutableLogRecord
  :: (MonadIO m)
  => LA.AttributeLimits
  -> LogRecordArguments
  -> m ImmutableLogRecord
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
logDroppedAttributes :: (MonadIO m) => m ReadWriteLogRecord
logDroppedAttributes = emitOTelLogRecord H.empty Warn "At least 1 attribute was discarded due to the attribute limits set in the logger provider."


-- | WARNING: this function should only be used to emit logs from the hs-opentelemetry-api library. DO NOT USE this function in any other context.
emitOTelLogRecord :: (MonadIO m) => H.HashMap Text LA.AnyValue -> SeverityNumber -> Text -> m ReadWriteLogRecord
emitOTelLogRecord attrs severity bodyText = do
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
    emptyLogRecordArguments
      { severityNumber = Just severity
      , body = toValue bodyText
      , attributes = attrs
      }


{- | Emits a @LogRecord@ with properties specified by the passed in Logger and LogRecordArguments.
If observedTimestamp is not set in LogRecordArguments, it will default to the current timestamp.
If context is not specified in LogRecordArguments it will default to the current context.

The emitted @LogRecord@ will be passed to any @LogRecordProcessor@s registered on the @LoggerProvider@
that created the @Logger@.
-}
emitLogRecord
  :: (MonadIO m)
  => Logger
  -> LogRecordArguments
  -> m ReadWriteLogRecord
emitLogRecord l args = do
  let LoggerProvider {loggerProviderProcessors, loggerProviderAttributeLimits} = loggerLoggerProvider l

  ilr <- createImmutableLogRecord loggerProviderAttributeLimits args
  lr <- liftIO $ mkReadWriteLogRecord l ilr

  ctxt <- getContext
  mapM_ (\processor -> liftIO $ logRecordProcessorOnEmit processor lr ctxt) loggerProviderProcessors

  pure lr


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
addAttribute :: (IsReadWriteLogRecord r, MonadIO m, ToValue a) => r -> Text -> a -> m ()
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
addAttributes :: (IsReadWriteLogRecord r, MonadIO m, ToValue a) => r -> HashMap Text a -> m ()
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
logRecordGetAttributes :: (IsReadableLogRecord r, MonadIO m) => r -> m LogAttributes
logRecordGetAttributes lr = liftIO $ logRecordAttributes <$> readLogRecord lr
