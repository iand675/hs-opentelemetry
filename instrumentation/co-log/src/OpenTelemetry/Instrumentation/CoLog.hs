{-# LANGUAGE OverloadedStrings #-}

{- |
Module      : OpenTelemetry.Instrumentation.CoLog
Copyright   : (c) Ian Duncan, 2021-2026
License     : BSD-3
Description : Bridge co-log to OpenTelemetry Logs
Stability   : experimental

Provides 'LogAction' values that forward co-log messages to the
OpenTelemetry Logs pipeline.

* 'otelLogAction' for co-log's standard 'Message' type (from @co-log@),
  which carries severity, call stack, and text.

* 'otelLogActionWith' for arbitrary message types — supply your own
  conversion function.

Trace correlation is automatic: log records emitted inside an
'OpenTelemetry.Trace.Core.inSpan' block carry the active trace\/span IDs.

= Usage with co-log's @Message@

@
import Colog (logInfo)
import Colog.Core (LogAction)
import OpenTelemetry.Log.Core
import OpenTelemetry.Instrumentation.CoLog

main :: IO ()
main = do
  lp <- getGlobalLoggerProvider
  let logger = makeLogger lp (instrumentationLibrary \"my-app\" \"1.0.0\")
      action = otelLogAction logger
  -- use action with your co-log setup
@

= Usage with a custom message type

@
myBridge :: Logger -> LogAction IO Text
myBridge logger = otelLogActionWith logger $ \\txt ->
  emptyLogRecordArguments
    { severityNumber = Just Info
    , body = toValue txt
    }
@

@since 0.1.0.0
-}
module OpenTelemetry.Instrumentation.CoLog (
  otelLogAction,
  otelLogActionWith,
  coLogSeverity,
) where

import Colog.Core (LogAction (..))
import Colog.Core.Severity (Severity (..))
import qualified Colog.Core.Severity as CS
import Colog.Message (Message, Msg (..))
import Control.Monad (void)
import qualified Data.HashMap.Strict as H
import Data.Text (Text)
import qualified Data.Text as T
import GHC.Stack (CallStack, getCallStack, srcLocFile, srcLocModule, srcLocStartLine)
import OpenTelemetry.Internal.Common.Types (AnyValue (..), ToValue (..))
import OpenTelemetry.Internal.Log.Types (
  LogRecordArguments (..),
  SeverityNumber (..),
  emptyLogRecordArguments,
 )
import OpenTelemetry.Log.Core (Logger, emitLogRecord)


{- | A 'LogAction' for co-log's standard 'Message' type that forwards
to the OTel Logs pipeline.

@since 0.1.0.0
-}
otelLogAction :: Logger -> LogAction IO Message
otelLogAction logger = LogAction $ \msg -> do
  let (sevNum, sevText) = coLogSeverity (msgSeverity msg)
      attrs = callStackAttributes (msgStack msg)
      args =
        emptyLogRecordArguments
          { severityText = Just sevText
          , severityNumber = Just sevNum
          , body = toValue (msgText msg)
          , attributes = attrs
          }
  void $ emitLogRecord logger args


{- | A generic 'LogAction' for arbitrary message types. Supply a function
that converts your message to 'LogRecordArguments'.

@since 0.1.0.0
-}
otelLogActionWith :: Logger -> (msg -> LogRecordArguments) -> LogAction IO msg
otelLogActionWith logger toArgs = LogAction $ \msg ->
  void $ emitLogRecord logger (toArgs msg)


{- | Map co-log 'Severity' to OTel 'SeverityNumber' and short text.

@since 0.1.0.0
-}
coLogSeverity :: Severity -> (SeverityNumber, Text)
coLogSeverity CS.Debug = (OpenTelemetry.Internal.Log.Types.Debug, "DEBUG")
coLogSeverity CS.Info = (OpenTelemetry.Internal.Log.Types.Info, "INFO")
coLogSeverity CS.Warning = (Warn, "WARN")
coLogSeverity CS.Error = (OpenTelemetry.Internal.Log.Types.Error, "ERROR")


callStackAttributes :: CallStack -> H.HashMap Text AnyValue
callStackAttributes cs = case getCallStack cs of
  [] -> H.empty
  ((_, loc) : _) ->
    H.fromList
      [ ("code.filepath", toValue (T.pack (srcLocFile loc)))
      , ("code.function.name", toValue (T.pack (srcLocModule loc)))
      , ("code.lineno", IntValue (fromIntegral (srcLocStartLine loc)))
      ]
