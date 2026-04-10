{-# LANGUAGE PatternSynonyms #-}

-- |
-- Module      : OpenTelemetry.Processor
-- Description : Re-exports of span processor types.
-- Stability   : experimental
--
-- This module is deprecated; prefer 'OpenTelemetry.Processor.Span'.
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

import OpenTelemetry.Context (Context)
import OpenTelemetry.Internal.Trace.Types (ImmutableSpan)
import OpenTelemetry.Processor.Span


{-# DEPRECATED Processor "use SpanProcessor instead" #-}


type Processor = SpanProcessor


pattern Processor
  :: (ImmutableSpan -> Context -> IO ())
  -> (ImmutableSpan -> IO ())
  -> IO ShutdownResult
  -> IO FlushResult
  -> SpanProcessor
pattern Processor {processorOnStart, processorOnEnd, processorShutdown, processorForceFlush} =
  SpanProcessor
    { spanProcessorOnStart = processorOnStart
    , spanProcessorOnEnd = processorOnEnd
    , spanProcessorShutdown = processorShutdown
    , spanProcessorForceFlush = processorForceFlush
    }
