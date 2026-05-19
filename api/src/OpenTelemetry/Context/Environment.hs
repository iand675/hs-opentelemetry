{-# LANGUAGE OverloadedStrings #-}

{- |
Module      :  OpenTelemetry.Context.Environment
Copyright   :  (c) Ian Duncan, 2024
License     :  BSD-3
Description :  Propagate trace context to child processes via environment variables
Maintainer  :  Ian Duncan
Stability   :  alpha
Portability :  non-portable (GHC extensions)

This module implements the
<https://opentelemetry.io/docs/specs/otel/context/env-carriers/ Environment Variables as Context Propagation Carriers>
specification (Alpha).

It uses the globally configured 'TextMapPropagator' to inject\/extract
trace context through environment variables. Propagation field names are
normalized to POSIX-compatible environment variable names per the
specification, making this module __format-agnostic__: it works with
W3C, B3, Datadog, or any other registered propagator.

== Usage

__Extracting context in a child process__ (at startup):

@
main :: IO ()
main = do
  ctx <- 'extractContextFromEnvironment'
  _tok <- 'OpenTelemetry.Context.ThreadLocal.attachContext' ctx
  -- ... this process is now part of the parent's trace
@

__Injecting context when spawning a child process__:

@
import System.Process ('System.Process.CreateProcess', 'System.Process.proc', 'System.Process.createProcess')
import System.Environment ('System.Environment.getEnvironment')

spawnTracedChild :: IO ()
spawnTracedChild = do
  baseEnv <- 'System.Environment.getEnvironment'
  traceEnv <- 'injectCurrentContextToEnvironment'
  let childEnv = 'mergeEnvironment' traceEnv baseEnv
  'System.Process.createProcess' ('System.Process.proc' "my-child" []) { 'System.Process.env' = Just childEnv }
@

== Spec compliance

Per the specification, this module does __not__ handle process spawning.
The application is responsible for passing the injected environment
variables to its process-spawning mechanism.

The carrier is format-agnostic: key normalization follows POSIX rules
(uppercase, replace non-alphanumeric\/non-underscore with @_@, prefix
with @_@ if the name would start with a digit). Values are treated as
opaque strings.

@since 0.4.0.0
-}
module OpenTelemetry.Context.Environment (
  -- * Extract (child process startup)
  extractContextFromEnvironment,

  -- * Inject (before spawning child)
  injectContextToEnvironment,
  injectCurrentContextToEnvironment,

  -- * Helpers
  mergeEnvironment,

  -- * Key normalization
  normalizeKeyToEnvVar,

  -- * Well-known environment variable names
  envTraceparent,
  envTracestate,
  envBaggage,
) where

import Data.Char (isAsciiLower, isAsciiUpper, isDigit, toLower, toUpper)
import qualified Data.Text as T
import OpenTelemetry.Context (Context)
import OpenTelemetry.Context.ThreadLocal (getContext)
import OpenTelemetry.Propagator (TextMap, emptyTextMap, extract, getGlobalTextMapPropagator, inject, textMapFromList, textMapToList)
import System.Environment (getEnvironment)


-- | @since 0.4.0.0
envTraceparent :: String
envTraceparent = "TRACEPARENT"


-- | @since 0.4.0.0
envTracestate :: String
envTracestate = "TRACESTATE"


-- | @since 0.4.0.0
envBaggage :: String
envBaggage = "BAGGAGE"


{- | Normalize a propagation field name to a POSIX-compatible environment
variable name.

Per the OTel spec, environment variable names:

* MUST have ASCII letters uppercased
* MUST have every character that is not an ASCII letter, digit, or
  underscore replaced with an underscore
* MUST be prefixed with @_@ if the result would start with a digit

Examples:

@
normalizeKeyToEnvVar "traceparent"     == "TRACEPARENT"
normalizeKeyToEnvVar "x-b3-traceid"   == "X_B3_TRACEID"
normalizeKeyToEnvVar "x-datadog-trace" == "X_DATADOG_TRACE"
@

@since 0.4.0.0
-}
normalizeKeyToEnvVar :: T.Text -> String
normalizeKeyToEnvVar name =
  let raw = map normalizeChar (T.unpack name)
  in case raw of
       (c : _) | isDigit c -> '_' : map toUpper raw
       _ -> map toUpper raw
  where
    normalizeChar c
      | isAsciiUpper c || isAsciiLower c || isDigit c || c == '_' = c
      | otherwise = '_'
{-# INLINE normalizeKeyToEnvVar #-}


{- | Reverse-normalize an environment variable name to a plausible
propagation field name: lowercase and replace underscores with hyphens.

This is not a perfect inverse (the forward normalization is lossy), but
it produces the correct result for all standard propagation formats
(W3C, B3, Datadog, etc.) since field names universally use lowercase
letters and hyphens.
-}
reverseNormalizeEnvVarToKey :: String -> T.Text
reverseNormalizeEnvVarToKey = T.pack . map (\c -> if c == '_' then '-' else toLower c)
{-# INLINE reverseNormalizeEnvVarToKey #-}


{- | Extract trace context from the current process's environment variables.

Reads all environment variables, reverse-normalizes their names to
propagation field equivalents, and delegates to the globally configured
'TextMapPropagator' for parsing. The propagator determines which
variables are relevant (e.g. @TRACEPARENT@ for W3C, @X_B3_TRACEID@ for
B3).

Returns the current thread-local context enriched with any extracted
span context and baggage. If the environment variables are absent or
unparseable, the original context is returned unchanged.

@since 0.4.0.0
-}
extractContextFromEnvironment :: IO Context
extractContextFromEnvironment = do
  propagator <- getGlobalTextMapPropagator
  ctx <- getContext
  tm <- envToTextMap
  extract propagator tm ctx


{- | Inject the given context into a list of environment variable
key-value pairs.

Uses the globally configured 'TextMapPropagator' to serialize trace
context and baggage, then normalizes the resulting field names to
POSIX-compatible environment variable names.

The returned list contains only the trace-related variables. Use
'mergeEnvironment' to combine them with the current process environment
before passing to @CreateProcess@.

@since 0.4.0.0
-}
injectContextToEnvironment :: Context -> IO [(String, String)]
injectContextToEnvironment ctx = do
  propagator <- getGlobalTextMapPropagator
  tm <- inject propagator ctx emptyTextMap
  pure (textMapToEnv tm)


{- | Convenience wrapper: injects the current thread-local context.

Equivalent to @'getContext' >>= 'injectContextToEnvironment'@.

@since 0.4.0.0
-}
injectCurrentContextToEnvironment :: IO [(String, String)]
injectCurrentContextToEnvironment = getContext >>= injectContextToEnvironment


{- | Merge trace environment variables into a base environment.

Later entries (the base) are overwritten by earlier entries (the
trace vars) for matching keys. This is the intended merge direction:
trace context should override any stale @TRACEPARENT@ etc. that may
exist in the inherited environment.

@
baseEnv <- getEnvironment
traceEnv <- injectCurrentContextToEnvironment
let childEnv = mergeEnvironment traceEnv baseEnv
@

@since 0.4.0.0
-}
mergeEnvironment
  :: [(String, String)]
  -- ^ Trace environment variables (take precedence)
  -> [(String, String)]
  -- ^ Base environment
  -> [(String, String)]
mergeEnvironment traceVars baseEnv =
  traceVars <> filter (\(k, _) -> k `notElem` traceKeys) baseEnv
  where
    traceKeys = fmap fst traceVars


envToTextMap :: IO TextMap
envToTextMap = do
  allEnv <- getEnvironment
  pure $ textMapFromList $ map (\(k, v) -> (reverseNormalizeEnvVarToKey k, T.pack v)) allEnv


textMapToEnv :: TextMap -> [(String, String)]
textMapToEnv = map (\(k, v) -> (normalizeKeyToEnvVar k, T.unpack v)) . textMapToList
