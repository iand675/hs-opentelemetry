module OpenTelemetry.Trace.SpanProcessor 
  ( SpanProcessor(..)
  , ShutdownResult(..)
  ) where
import Control.Concurrent.Async
import OpenTelemetry.Context.Types
import OpenTelemetry.Trace.Types

-- TODO MUST implement simple processor
-- TODO MUST implement batching processor