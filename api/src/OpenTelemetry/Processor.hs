{-# LANGUAGE PatternSynonyms #-}

module OpenTelemetry.Processor
  {-# DEPRECATED "use OpenTelemetry.Processor.Span instead" #-} (
  Processor,
  SpanProcessor (
    Processor,
    processorOnStart,
    processorOnEnd,
    processorShutdown,
    processorForceFlush
  ),
  ShutdownResult (..),
) where

import Control.Concurrent.Async (Async)
import Data.IORef (IORef)
import OpenTelemetry.Context (Context)
import OpenTelemetry.Internal.Trace.Types (ImmutableSpan)
import OpenTelemetry.Processor.Span


{-# DEPRECATED Processor "use SpanProcessor instead" #-}


type Processor = SpanProcessor


pattern Processor
  :: (IORef ImmutableSpan -> Context -> IO ())
  -> (IORef ImmutableSpan -> IO ())
  -> IO (Async ShutdownResult)
  -> IO ()
  -> SpanProcessor
pattern Processor {processorOnStart, processorOnEnd, processorShutdown, processorForceFlush} =
  SpanProcessor
    { spanProcessorOnStart = processorOnStart
    , spanProcessorOnEnd = processorOnEnd
    , spanProcessorShutdown = processorShutdown
    , spanProcessorForceFlush = processorForceFlush
    }
