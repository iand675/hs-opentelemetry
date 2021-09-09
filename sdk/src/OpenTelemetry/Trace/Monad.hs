module OpenTelemetry.Trace.Monad 
  ( inSpan
  , MonadTracerProvider(..)
  , MonadTracer(..)
  , MonadGetContext(..)
  , MonadBracketError(..)
  , bracketErrorUnliftIO
  ) where

import "otel-api" OpenTelemetry.Trace.Monad