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
(error, warn, info, debug).  This module provides the shared
implementation used by all packages in the hs-opentelemetry
distribution.

Output goes to @stderr@ so it never interferes with application
stdout.  The log level is read once from the environment on first
use and cached for the process lifetime.

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
) where

import Data.Char (toLower)
import Data.IORef (IORef, newIORef, readIORef)
import System.Environment (lookupEnv)
import System.IO (hPutStrLn, stderr)
import System.IO.Unsafe (unsafePerformIO)


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


-- | Retrieve the currently configured log level.
getOTelLogLevel :: IO OTelLogLevel
getOTelLogLevel = readIORef cachedLogLevel
{-# INLINE getOTelLogLevel #-}


otelLog :: OTelLogLevel -> String -> String -> IO ()
otelLog minLevel prefix msg = do
  level <- getOTelLogLevel
  if level >= minLevel
    then hPutStrLn stderr (prefix <> msg)
    else pure ()
{-# INLINE otelLog #-}


-- | Log at ERROR level. Always emitted unless @OTEL_LOG_LEVEL=none@.
otelLogError :: String -> IO ()
otelLogError = otelLog OTelLogError "OpenTelemetry [ERROR] "
{-# INLINE otelLogError #-}


-- | Log at WARNING level.
otelLogWarning :: String -> IO ()
otelLogWarning = otelLog OTelLogWarning "OpenTelemetry [WARN] "
{-# INLINE otelLogWarning #-}


-- | Log at INFO level.
otelLogInfo :: String -> IO ()
otelLogInfo = otelLog OTelLogInfo "OpenTelemetry [INFO] "
{-# INLINE otelLogInfo #-}


-- | Log at DEBUG level.
otelLogDebug :: String -> IO ()
otelLogDebug = otelLog OTelLogDebug "OpenTelemetry [DEBUG] "
{-# INLINE otelLogDebug #-}
