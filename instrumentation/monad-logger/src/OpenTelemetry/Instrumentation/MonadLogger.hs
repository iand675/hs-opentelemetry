{-# LANGUAGE OverloadedStrings #-}

{- |
Module      : OpenTelemetry.Instrumentation.MonadLogger
Copyright   : (c) Ian Duncan, 2021-2026
License     : BSD-3
Description : Bridge monad-logger to OpenTelemetry Logs
Stability   : experimental

Provides a logging callback compatible with @runLoggingT@ that forwards
@monad-logger@ messages to the OpenTelemetry Logs pipeline. Log records
are emitted via the OTel Logs Bridge API, which means:

* __Trace correlation is automatic__: if a log statement executes inside
  an 'OpenTelemetry.Trace.Core.inSpan' block, the emitted log record
  carries the active trace\/span IDs with no extra code.

* __Severity mapping__: 'LevelDebug' → 'Debug', 'LevelInfo' → 'Info',
  'LevelWarn' → 'Warn', 'LevelError' → 'Error', 'LevelOther' → 'Info'
  (with the original level name preserved in @severityText@).

* __Source location__: The 'Loc' from Template Haskell logging macros
  (e.g. @$logInfo@) is mapped to @code.filepath@, @code.function.name@,
  and @code.lineno@ attributes.

= Usage

@
import OpenTelemetry.Log.Core
import OpenTelemetry.Instrumentation.MonadLogger

main :: IO ()
main = do
  lp <- getGlobalLoggerProvider
  let logger = makeLogger lp (instrumentationLibrary \"my-app\" \"1.0.0\")
  runLoggingT myApp (makeOTelLogCallback logger)
@

Or with 'LoggingT' and the SDK's auto-initialized provider:

@
import OpenTelemetry.Trace (withTracerProvider)
import OpenTelemetry.Log (getGlobalLoggerProvider)
import OpenTelemetry.Instrumentation.MonadLogger

main :: IO ()
main = withTracerProvider $ \\_ -> do
  lp <- getGlobalLoggerProvider
  let logger = makeLogger lp (instrumentationLibrary \"my-app\" \"1.0.0\")
  runLoggingT myApp (makeOTelLogCallback logger)
@

@since 0.1.0.0
-}
module OpenTelemetry.Instrumentation.MonadLogger (
  makeOTelLogCallback,
  monadLoggerSeverity,
) where

import Control.Monad (void)
import Control.Monad.Logger (Loc (..), LogLevel (..), LogSource, LogStr)
import qualified Data.HashMap.Strict as H
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import OpenTelemetry.Internal.Common.Types (AnyValue (..), ToValue (..))
import OpenTelemetry.Internal.Log.Types (
  LogRecordArguments (..),
  SeverityNumber (..),
  emptyLogRecordArguments,
 )
import OpenTelemetry.Log.Core (Logger, emitLogRecord)
import System.Log.FastLogger (fromLogStr)


{- | Create a logging callback for use with @runLoggingT@ that forwards
all log messages to the OTel Logs pipeline via the given 'Logger'.

The callback signature matches what 'Control.Monad.Logger.runLoggingT'
expects: @Loc -> LogSource -> LogLevel -> LogStr -> IO ()@.

@since 0.1.0.0
-}
makeOTelLogCallback :: Logger -> (Loc -> LogSource -> LogLevel -> LogStr -> IO ())
makeOTelLogCallback logger loc src level msg = do
  let bodyText = TE.decodeUtf8 (fromLogStr msg)
      (sevNum, sevText) = monadLoggerSeverity level
      attrs = locAttributes loc <> sourceAttributes src
      args =
        emptyLogRecordArguments
          { severityText = Just sevText
          , severityNumber = Just sevNum
          , body = toValue bodyText
          , attributes = attrs
          }
  void $ emitLogRecord logger args


{- | Map a monad-logger 'LogLevel' to an OTel 'SeverityNumber' and
short text name.

@since 0.1.0.0
-}
monadLoggerSeverity :: LogLevel -> (SeverityNumber, Text)
monadLoggerSeverity LevelDebug = (Debug, "DEBUG")
monadLoggerSeverity LevelInfo = (Info, "INFO")
monadLoggerSeverity LevelWarn = (Warn, "WARN")
monadLoggerSeverity LevelError = (Error, "ERROR")
monadLoggerSeverity (LevelOther t) = (Info, t)


locAttributes :: Loc -> H.HashMap Text AnyValue
locAttributes loc =
  H.fromList
    [ ("code.filepath", toValue (T.pack (loc_filename loc)))
    , ("code.function.name", toValue (T.pack (loc_module loc)))
    , ("code.lineno", IntValue (fromIntegral (fst (loc_start loc))))
    ]


sourceAttributes :: LogSource -> H.HashMap Text AnyValue
sourceAttributes src
  | T.null src = H.empty
  | otherwise = H.singleton "log.source" (toValue src)
