module OpenTelemetry.Trace.Monad 
  ( inSpan
  , MonadTracerProvider(..)
  , MonadTracer(..)
  , MonadGetContext(..)
  , MonadLocalContext(..)
  , MonadBracketError(..)
  , bracketErrorUnliftIO
  ) where

import "hs-opentelemetry-api" OpenTelemetry.Trace.Monad