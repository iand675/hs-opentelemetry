{-# LANGUAGE LambdaCase #-}

{- |
Module      :  OpenTelemetry.Internal.Logging
Copyright   :  (c) Ian Duncan, 2021
License     :  BSD-3
Description :  SDK-internal diagnostic logging, per the OTel specification.
Maintainer  :  Ian Duncan
Stability   :  internal
Portability :  non-portable (GHC extensions)

The OpenTelemetry specification mandates that the SDK produces
self-diagnostic output controllable via @OTEL_LOG_LEVEL@
(error, warn, info, debug) and that users can plug a custom error
handler.

Output goes to @stderr@ by default so it never interferes with
application stdout. The log level is read once from the environment
on first use and cached for the process lifetime. Users can override
the output sink via 'setGlobalErrorHandler'.

This module is internal. Library authors should not depend on it.

@since 0.4.0.0
-}
module OpenTelemetry.Internal.Logging (
  OTelLogLevel (..),
  otelLogError,
  otelLogWarning,
  otelLogInfo,
  otelLogDebug,
  getOTelLogLevel,
  setGlobalErrorHandler,
  getGlobalErrorHandler,
) where

import Data.Char (toLower)
import Data.IORef (IORef, newIORef, readIORef, writeIORef)
import System.Environment (lookupEnv)
import System.IO (hPutStrLn, stderr)
import System.IO.Unsafe (unsafePerformIO)


-- | @since 0.4.0.0
data OTelLogLevel
  = OTelLogNone
  | OTelLogError
  | OTelLogWarning
  | OTelLogInfo
  | OTelLogDebug
  deriving (Eq, Ord, Show)


parseLogLevel :: String -> OTelLogLevel
parseLogLevel s = case map toLower s of
  "none" -> OTelLogNone
  "error" -> OTelLogError
  "warn" -> OTelLogWarning
  "warning" -> OTelLogWarning
  "info" -> OTelLogInfo
  "debug" -> OTelLogDebug
  _ -> OTelLogInfo


cachedLogLevel :: IORef OTelLogLevel
cachedLogLevel = unsafePerformIO $ do
  mEnv <- lookupEnv "OTEL_LOG_LEVEL"
  newIORef $ case mEnv of
    Nothing -> OTelLogInfo
    Just v -> parseLogLevel v
{-# NOINLINE cachedLogLevel #-}


globalErrorHandler :: IORef (String -> IO ())
globalErrorHandler = unsafePerformIO $ newIORef (hPutStrLn stderr)
{-# NOINLINE globalErrorHandler #-}


{- | Replace the global error handler used by all OTel SDK diagnostic
output. The default writes to @stderr@. The OTel spec requires that
the SDK allow users to plug a custom error handler.

The handler receives a pre-formatted message string including the
severity prefix (e.g. @"OpenTelemetry [ERROR] ..."@).

@since 0.4.0.0
-}
setGlobalErrorHandler :: (String -> IO ()) -> IO ()
setGlobalErrorHandler = writeIORef globalErrorHandler


{- | Retrieve the current global error handler.

@since 0.4.0.0
-}
getGlobalErrorHandler :: IO (String -> IO ())
getGlobalErrorHandler = readIORef globalErrorHandler


{- | Retrieve the currently configured log level.

@since 0.4.0.0
-}
getOTelLogLevel :: IO OTelLogLevel
getOTelLogLevel = readIORef cachedLogLevel
{-# INLINE getOTelLogLevel #-}


otelLog :: OTelLogLevel -> String -> String -> IO ()
otelLog minLevel prefix msg = do
  level <- getOTelLogLevel
  if level >= minLevel
    then do
      handler <- getGlobalErrorHandler
      handler (prefix <> msg)
    else pure ()
{-# INLINE otelLog #-}


{- | Log at ERROR level. Always emitted unless @OTEL_LOG_LEVEL=none@.

@since 0.4.0.0
-}
otelLogError :: String -> IO ()
otelLogError = otelLog OTelLogError "OpenTelemetry [ERROR] "
{-# INLINE otelLogError #-}


{- | Log at WARNING level.

@since 0.4.0.0
-}
otelLogWarning :: String -> IO ()
otelLogWarning = otelLog OTelLogWarning "OpenTelemetry [WARN] "
{-# INLINE otelLogWarning #-}


{- | Log at INFO level.

@since 0.4.0.0
-}
otelLogInfo :: String -> IO ()
otelLogInfo = otelLog OTelLogInfo "OpenTelemetry [INFO] "
{-# INLINE otelLogInfo #-}


{- | Log at DEBUG level.

@since 0.4.0.0
-}
otelLogDebug :: String -> IO ()
otelLogDebug = otelLog OTelLogDebug "OpenTelemetry [DEBUG] "
{-# INLINE otelLogDebug #-}
