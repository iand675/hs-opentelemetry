module OpenTelemetry.Trace.Monad 
  ( inSpan
  , MonadTracerProvider(..)
  , MonadTracer(..)
  , MonadGetContext(..)
  , MonadLocalContext(..)
  , MonadBracketError(..)
  , bracketErrorUnliftIO
  ) where

import "otel-api" OpenTelemetry.Trace.Monad