module OpenTelemetry.Trace.Monad 
  ( inSpan
  , MonadTracer(..)
  , MonadGetContext(..)
  , MonadLocalContext(..)
  , MonadBracketError(..)
  , bracketErrorUnliftIO
  ) where

import "hs-opentelemetry-api" OpenTelemetry.Trace.Monad