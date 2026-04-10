{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE NumericUnderscores #-}

{- |
Module      : OpenTelemetry.Internal.Log.Core
Copyright   :  (c) Ian Duncan, 2024-2026
License     :  BSD-3
Description : Internal implementation of the Logs API: LoggerProvider creation, Logger, and LogRecord emission.
Stability   : experimental
-}
module OpenTelemetry.Internal.Log.Core (
  LoggerProviderOptions (..),
  emptyLoggerProviderOptions,
  createLoggerProvider,
  getLogger,
  setGlobalLoggerProvider,
  getGlobalLoggerProvider,
  shutdownLoggerProvider,
  ShutdownResult (..),
  forceFlushLoggerProvider,
  makeLogger,
  loggerIsEnabled,
  loggerIsEnabled',
  setLoggerMinSeverity,
  getLoggerMinSeverity,
  emitLogRecord,
  addAttribute,
  addAttributes,
  logRecordGetAttributes,
  emitOTelLogRecord,
) where

import Control.Applicative
import OpenTelemetry.Internal.UnpackedMaybe (fromBaseMaybe)
import Control.Concurrent.Async
import Control.Monad
import Control.Monad.IO.Class (MonadIO, liftIO)
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
import OpenTelemetry.Internal.Log.Types
import OpenTelemetry.Internal.Logging (otelLogWarning)
import OpenTelemetry.Internal.Trace.Types (SpanContext (..), getSpanContext)
import OpenTelemetry.LogAttributes (LogAttributes)
import qualified OpenTelemetry.LogAttributes as LA
import OpenTelemetry.Resource (MaterializedResources, emptyMaterializedResources)
import Paths_hs_opentelemetry_api (version)
import System.Timeout (timeout)


foreign import ccall unsafe "hs_otel_gettime_ns"
  getTimestampIO :: IO Timestamp


-- | @since 0.0.1.0
data LoggerProviderOptions = LoggerProviderOptions
  { loggerProviderOptionsResource :: MaterializedResources
  , loggerProviderOptionsAttributeLimits :: A.AttributeLimits
  , loggerProviderOptionsMinSeverity :: Maybe SeverityNumber
  -- ^ When @Just sev@, log records with severity below @sev@ are
  -- suppressed (both 'loggerIsEnabled' and 'emitLogRecord' respect
  -- this). 'Nothing' means no filtering. Can be changed at runtime
  -- via 'setLoggerMinSeverity'.
  }


{- | Options for creating a @LoggerProvider@ with no resources and default limits.

 In effect, logging is a no-op when using this configuration and no-op Processors.

@since 0.0.1.0
-}
emptyLoggerProviderOptions :: LoggerProviderOptions
emptyLoggerProviderOptions =
  LoggerProviderOptions
    { loggerProviderOptionsResource = emptyMaterializedResources
    , loggerProviderOptionsAttributeLimits = A.defaultAttributeLimits
    , loggerProviderOptionsMinSeverity = Nothing
    }


{- | Initialize a new @LoggerProvider@

 You should generally use @getGlobalLoggerProvider@ for most applications.

@since 0.0.1.0
-}
createLoggerProvider :: (MonadIO m) => [LogRecordProcessor] -> LoggerProviderOptions -> m LoggerProvider
createLoggerProvider ps LoggerProviderOptions {..} = liftIO $ do
  shutRef <- newIORef False
  sevRef <- newIORef loggerProviderOptionsMinSeverity
  loggerCache <- newIORef H.empty
  let !processors = V.fromList ps
      !hasProcs = not (V.null processors)
      !onEmit = case ps of
        [] -> \_ _ -> pure ()
        [p] -> logRecordProcessorOnEmit p
        _ -> \lr ctx -> V.mapM_ (\p -> logRecordProcessorOnEmit p lr ctx) processors
  pure
    LoggerProvider
      { loggerProviderProcessors = processors
      , loggerProviderResource = loggerProviderOptionsResource
      , loggerProviderAttributeLimits = loggerProviderOptionsAttributeLimits
      , loggerProviderIsShutdown = shutRef
      , loggerProviderHasProcessors = hasProcs
      , loggerProviderOnEmit = onEmit
      , loggerProviderMinSeverity = sevRef
      , loggerProviderLoggerCache = loggerCache
      }


globalLoggerProvider :: IORef LoggerProvider
globalLoggerProvider = unsafePerformIO $ do
  p <- createLoggerProvider [] emptyLoggerProviderOptions
  newIORef p
{-# NOINLINE globalLoggerProvider #-}


{- | Access the globally configured @LoggerProvider@. This @LoggerProvider@ is no-op until initialized by the SDK

@since 0.0.1.0
-}
getGlobalLoggerProvider :: (MonadIO m) => m LoggerProvider
getGlobalLoggerProvider = liftIO $ readIORef globalLoggerProvider


{- | Overwrite the globally configured @LoggerProvider@.

 @Logger@s acquired from the previously installed @LoggerProvider@s
 will continue to use that @LoggerProvider@s settings.

@since 0.0.1.0
-}
setGlobalLoggerProvider :: (MonadIO m) => LoggerProvider -> m ()
setGlobalLoggerProvider = liftIO . atomicWriteIORef globalLoggerProvider


{- | This method provides a way for provider to do any cleanup required.

 This will also trigger shutdowns on all internal processors.

@since 0.0.1.0
-}
shutdownLoggerProvider
  :: (MonadIO m)
  => LoggerProvider
  -> Maybe Int
  -- ^ Optional timeout in microseconds, defaults to 5,000,000 (5s)
  -> m ShutdownResult
shutdownLoggerProvider LoggerProvider {loggerProviderProcessors, loggerProviderIsShutdown} mtimeout = liftIO $ do
  alreadyShut <- atomicModifyIORef' loggerProviderIsShutdown $ \s -> (True, s)
  if alreadyShut
    then pure ShutdownFailure
    else do
      jobs <- V.forM loggerProviderProcessors $ \processor ->
        async (logRecordProcessorShutdown processor)
      mresult <-
        timeout (fromMaybe 5_000_000 mtimeout) $
          V.foldM
            ( \status action -> do
                res <- waitCatch action
                pure $! case res of
                  Left _err -> worstShutdown status ShutdownFailure
                  Right sr -> worstShutdown status sr
            )
            ShutdownSuccess
            jobs
      case mresult of
        Nothing -> do
          V.mapM_ cancel jobs
          pure ShutdownTimeout
        Just res -> pure res


{- | This method provides a way for provider to immediately export all @LogRecord@s that have not yet
 been exported for all the internal processors.

@since 0.0.1.0
-}
forceFlushLoggerProvider
  :: (MonadIO m)
  => LoggerProvider
  -> Maybe Int
  -- ^ Optional timeout in microseconds, defaults to 5,000,000 (5s)
  -> m FlushResult
  -- ^ Result that denotes whether the flush action succeeded, failed, or timed out.
forceFlushLoggerProvider LoggerProvider {loggerProviderProcessors} mtimeout = liftIO $ do
  jobs <- V.forM loggerProviderProcessors $ \processor ->
    async $
      logRecordProcessorForceFlush processor
  mresult <-
    timeout (fromMaybe 5_000_000 mtimeout) $
      V.foldM
        ( \status action -> do
            res <- waitCatch action
            pure $! case res of
              Left _err -> FlushError
              Right fr -> worstFlush status fr
        )
        FlushSuccess
        jobs
  case mresult of
    Nothing -> do
      V.mapM_ cancel jobs
      pure FlushTimeout
    Just res -> pure res


-- | @since 0.0.1.0
makeLogger
  :: LoggerProvider
  -- ^ The @LoggerProvider@ holds the configuration for the @Logger@.
  -> InstrumentationLibrary
  -- ^ The library that the @Logger@ instruments. This uniquely identifies the @Logger@.
  -- Use a non-empty 'libraryName' per the OpenTelemetry specification; use 'getLogger'
  -- if you want a warning when the name is empty.
  -> Logger
makeLogger loggerLoggerProvider loggerInstrumentationScope = Logger {..}


{- | Like 'makeLogger', but logs a warning when 'libraryName' is empty.

@since 0.0.1.0
-}
getLogger :: (MonadIO m) => LoggerProvider -> InstrumentationLibrary -> m Logger
getLogger lp il = liftIO $ do
  when (T.null (libraryName il)) $
    otelLogWarning "Logger created with empty name; returning working Logger with empty name per spec"
  let !l = makeLogger lp il
      !key = loggerInstrumentationScope l
  atomicModifyIORef' (loggerProviderLoggerCache lp) $ \cache ->
    case H.lookup key cache of
      Just cached -> (cache, cached)
      Nothing -> (H.insert key l cache, l)


{- | Returns @True@ if a log record with the given severity (and optional
event name) would be forwarded to processors.

Checks, in order:

1. Whether the provider has any registered processors.
2. Whether the provider has been shut down.
3. Whether the record's severity meets the provider's minimum severity
   threshold (set via 'LoggerProviderOptions' or 'setLoggerMinSeverity').

When the caller passes 'Nothing' for severity, the minimum-severity gate
is skipped (the record is allowed through).

Callers SHOULD invoke this before each log emit to get the most up-to-date
response, as the result may change over time.

@since 0.1.0.0
-}
loggerIsEnabled :: Logger -> Maybe SeverityNumber -> Maybe Text -> IO Bool
loggerIsEnabled Logger {loggerLoggerProvider = lp} severity _eventName = do
  if not (loggerProviderHasProcessors lp)
    then pure False
    else do
      isShutdown <- readIORef (loggerProviderIsShutdown lp)
      if isShutdown
        then pure False
        else case severity of
          Nothing -> pure True
          Just sev -> do
            minSev <- readIORef (loggerProviderMinSeverity lp)
            pure $! case minSev of
              Nothing -> True
              Just threshold -> sev >= threshold
{-# INLINE loggerIsEnabled #-}


{- | Like 'loggerIsEnabled' but accepts an explicit 'Context'.
When 'Nothing', uses the current implicit context.

@since 0.4.0.0
-}
loggerIsEnabled' :: (MonadIO m) => Logger -> Maybe SeverityNumber -> Maybe Text -> Maybe Context -> m Bool
loggerIsEnabled' logger msev mname _mctx = liftIO $ loggerIsEnabled logger msev mname
{-# INLINE loggerIsEnabled' #-}


{- | Set the minimum severity for a 'LoggerProvider' at runtime.

Log records with a severity below the threshold will be suppressed by
both 'loggerIsEnabled' and 'emitLogRecord'. Pass 'Nothing' to disable
severity filtering (the default).

@since 0.4.0.0
-}
setLoggerMinSeverity :: (MonadIO m) => LoggerProvider -> Maybe SeverityNumber -> m ()
setLoggerMinSeverity lp = liftIO . atomicWriteIORef (loggerProviderMinSeverity lp)


{- | Read the current minimum severity threshold for a 'LoggerProvider'.

Returns 'Nothing' when no severity filtering is active.

@since 0.4.0.0
-}
getLoggerMinSeverity :: (MonadIO m) => LoggerProvider -> m (Maybe SeverityNumber)
getLoggerMinSeverity = liftIO . readIORef . loggerProviderMinSeverity


createImmutableLogRecord
  :: LA.AttributeLimits
  -> Context
  -> LogRecordArguments
  -> IO ImmutableLogRecord
createImmutableLogRecord attributeLimits !ctx LogRecordArguments {..} = do
  currentTimestamp <- getTimestampIO
  let !logRecordObservedTimestamp = fromMaybe currentTimestamp observedTimestamp

  logRecordTracingDetails <- case lookupSpan ctx of
    Nothing -> pure Nothing
    Just s -> do
      SpanContext {traceId, spanId, traceFlags} <- getSpanContext s
      pure $! Just (traceId, spanId, traceFlags)

  let !logRecordAttributes =
        LA.addAttributes
          attributeLimits
          LA.emptyAttributes
          attributes
      !droppedCount = LA.attributesDropped logRecordAttributes

  when (droppedCount > 0) $
    otelLogWarning ("LogRecord dropped " <> show droppedCount <> " attribute(s) due to limits")

  pure
    ImmutableLogRecord
      { logRecordTimestamp = fromBaseMaybe timestamp
      , logRecordObservedTimestamp
      , logRecordTracingDetails = fromBaseMaybe logRecordTracingDetails
      , logRecordSeverityNumber = fromBaseMaybe severityNumber
      , logRecordSeverityText = fromBaseMaybe (severityText <|> (toShortName =<< severityNumber))
      , logRecordBody = body
      , logRecordAttributes
      , logRecordEventName = fromBaseMaybe eventName
      }


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
that created the @Logger@, provided the record's severity meets the provider's minimum severity
threshold.

@since 0.0.1.0
-}
emitLogRecord
  :: (MonadIO m)
  => Logger
  -> LogRecordArguments
  -> m ReadWriteLogRecord
emitLogRecord l args = liftIO $ do
  let !lp = loggerLoggerProvider l
  ctx <- maybe getContext pure (context args)
  ilr <- createImmutableLogRecord (loggerProviderAttributeLimits lp) ctx args
  lr <- mkReadWriteLogRecord l ilr
  when (loggerProviderHasProcessors lp) $ do
    isShutdown <- readIORef (loggerProviderIsShutdown lp)
    unless isShutdown $ do
      minSev <- readIORef (loggerProviderMinSeverity lp)
      let dominated = case minSev of
            Nothing -> False
            Just threshold -> case severityNumber args of
              Nothing -> False
              Just sev -> sev < threshold
      unless dominated $
        loggerProviderOnEmit lp lr ctx
  pure lr


{- | Add an attribute to a log record. Not an atomic modification.

See the [OTel attribute naming conventions](https://opentelemetry.io/docs/specs/otel/common/attribute-naming/)
for guidance on choosing attribute names.

@since 0.0.1.0
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

@since 0.0.1.0
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

@since 0.0.1.0
-}
logRecordGetAttributes :: (IsReadableLogRecord r, MonadIO m) => r -> m LogAttributes
logRecordGetAttributes lr = liftIO $ logRecordAttributes <$> readLogRecord lr
