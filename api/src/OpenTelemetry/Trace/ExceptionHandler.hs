{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

{- |
Module      :  OpenTelemetry.Trace.ExceptionHandler
Copyright   :  (c) Ian Duncan, 2024
License     :  BSD-3
Description :  Exception classification for tracing
Maintainer  :  Ian Duncan
Stability   :  experimental
Portability :  non-portable (GHC extensions)

Register exception handlers on a 'TracerProvider' or 'Tracer' to control how
exceptions interact with span status and events.

By default, every exception caught by 'inSpan' sets the span status to
'Error' and records an exception event. This module provides combinators to
override that behavior for specific exception types. For example, treating
'System.Exit.ExitSuccess' or 'Control.Exception.AsyncCancelled' as
non-errors.

@since 0.4.0.0
-}
module OpenTelemetry.Trace.ExceptionHandler (
  -- * Types
  ExceptionClassification (..),
  ExceptionResponse (..),
  ExceptionHandler,
  defaultExceptionResponse,

  -- * Smart constructors
  ignoreExceptionType,
  ignoreExceptionMatching,
  recordExceptionType,
  recordExceptionMatching,
  classifyException,

  -- * Common handlers
  exitSuccessHandler,

  -- * Resolution
  resolveException,
) where

import Control.Exception (Exception (..), SomeException (..))
import qualified Data.HashMap.Strict as H
import OpenTelemetry.Internal.Trace.Types
import System.Exit (ExitCode (..))


{- | Ignore all exceptions of the given type. They will not be recorded as
events and will not set the span status to Error.

@
import Control.Exception (AsyncCancelled)

myHandlers = [ignoreExceptionType \@AsyncCancelled]
@

@since 0.4.0.0
-}
ignoreExceptionType :: forall e. (Exception e) => ExceptionHandler
ignoreExceptionType (SomeException ex) = case fromException @e (SomeException ex) of
  Just _ -> Just $ ExceptionResponse IgnoredException H.empty
  Nothing -> Nothing


{- | Ignore exceptions of the given type that match a predicate.

@
ignoreExceptionMatching \@ExitCode (== ExitSuccess)
@

@since 0.4.0.0
-}
ignoreExceptionMatching :: forall e. (Exception e) => (e -> Bool) -> ExceptionHandler
ignoreExceptionMatching p (SomeException ex) = case fromException @e (SomeException ex) of
  Just e
    | p e -> Just $ ExceptionResponse IgnoredException H.empty
  _ -> Nothing


{- | Record exceptions of the given type as events but do not set the span
status to Error. The exception remains visible in traces but is not counted
as an error.

@since 0.4.0.0
-}
recordExceptionType :: forall e. (Exception e) => ExceptionHandler
recordExceptionType (SomeException ex) = case fromException @e (SomeException ex) of
  Just _ -> Just $ ExceptionResponse RecordedException H.empty
  Nothing -> Nothing


{- | Record exceptions of the given type matching a predicate as events,
without setting Error status.

@since 0.4.0.0
-}
recordExceptionMatching :: forall e. (Exception e) => (e -> Bool) -> ExceptionHandler
recordExceptionMatching p (SomeException ex) = case fromException @e (SomeException ex) of
  Just e
    | p e -> Just $ ExceptionResponse RecordedException H.empty
  _ -> Nothing


{- | Full control: inspect an exception and return a classification with
optional extra attributes. Use this to enrich spans with domain-specific
information extracted from the exception.

@
classifyException \@HttpException $ \\(HttpException status _body) ->
  ExceptionResponse ErrorException
    (HashMap.fromList [("http.response.status_code", toAttribute (statusCode status))])
@

@since 0.4.0.0
-}
classifyException :: forall e. (Exception e) => (e -> ExceptionResponse) -> ExceptionHandler
classifyException f (SomeException ex) = case fromException @e (SomeException ex) of
  Just e -> Just (f e)
  Nothing -> Nothing


{- | Handler that classifies 'ExitSuccess' as ignored. 'ExitFailure' is left
unhandled (falls through to the next handler or the default).

This is a common handler to register globally:

@
opts = emptyTracerProviderOptions
  { tracerProviderOptionsExceptionHandlers = [exitSuccessHandler]
  }
@

@since 0.4.0.0
-}
exitSuccessHandler :: ExceptionHandler
exitSuccessHandler = ignoreExceptionMatching @ExitCode (== ExitSuccess)
