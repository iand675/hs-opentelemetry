{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE TypeApplications #-}

module OpenTelemetry.Logging.Core (
  LogRecord (..),
  mkSeverityNumber,
  shortName,
  severityNumber,
  emitLogRecord,
) where

import Control.Applicative
import Control.Monad.Trans
import Control.Monad.Trans.Maybe
import Data.Coerce
import Data.Maybe
import OpenTelemetry.Common
import OpenTelemetry.Context
import OpenTelemetry.Context.ThreadLocal
import OpenTelemetry.Internal.Logging.Types
import OpenTelemetry.Internal.Trace.Types
import System.Clock


getCurrentTimestamp :: (MonadIO m) => m Timestamp
getCurrentTimestamp = liftIO $ coerce @(IO TimeSpec) @(IO Timestamp) $ getTime Realtime


{- | Emits a LogRecord with properties specified by the passed in Logger and LogRecordArguments.
If observedTimestamp is not set in LogRecordArguments, it will default to the current timestamp.
If context is not specified in LogRecordArguments it will default to the current context.
-}
emitLogRecord
  :: (MonadIO m)
  => Logger
  -> LogRecordArguments body
  -> m (LogRecord body)
emitLogRecord logger LogRecordArguments {..} = do
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
      , logRecordResource = loggerResource logger
      , logRecordAttributes = attributes
      }
