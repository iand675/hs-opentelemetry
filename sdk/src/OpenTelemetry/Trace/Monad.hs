module OpenTelemetry.Trace.Monad 
  ( inSpan
  , inSpan'
  , MonadTracer(..)
  , MonadGetContext(..)
  , MonadLocalContext(..)
  , MonadBracketError(..)
  , bracketErrorUnliftIO
  ) where

import "hs-opentelemetry-api" OpenTelemetry.Trace.Monad