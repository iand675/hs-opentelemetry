module OpenTelemetry.Contrib.CarryOns (
  alterCarryOns,
  withCarryOnProcessor,
) where

import Control.Monad.IO.Class
import qualified Data.HashMap.Strict as H
import Data.IORef (atomicModifyIORef')
import Data.Maybe (fromMaybe)
import qualified OpenTelemetry.Attributes as Attributes
import OpenTelemetry.Attributes.Map (AttributeMap)
import OpenTelemetry.Context
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Context.ThreadLocal
import OpenTelemetry.Internal.Trace.Types
import System.IO.Unsafe (unsafePerformIO)


carryOnKey :: Key AttributeMap
carryOnKey = unsafePerformIO $ newKey "carryOn"
{-# NOINLINE carryOnKey #-}


alterCarryOns :: (MonadIO m) => (AttributeMap -> AttributeMap) -> m ()
alterCarryOns f = adjustContext $ \ctxt ->
  Context.insert carryOnKey (f $ fromMaybe mempty $ Context.lookup carryOnKey ctxt) ctxt


{- |
"Carry ons" are extra attributes that are added to every span that is completed for within a thread's context.
This helps us propagate attributes across a trace without having to manually add them to every span.

Be cautious about adding too many additional attributes via carry ons. The attributes are added to every span,
and will be discarded if the span has attributes that exceed the configured attribute limits for the configured
'TracerProvider'.
-}
withCarryOnProcessor :: SpanProcessor -> SpanProcessor
withCarryOnProcessor p =
  SpanProcessor
    { spanProcessorOnStart = spanProcessorOnStart p
    , spanProcessorOnEnd = \imm -> do
        ctxt <- getContext
        let carryOns = fromMaybe mempty $ Context.lookup carryOnKey ctxt
        if H.null carryOns
          then pure ()
          else do
            atomicModifyIORef' (spanHot imm) $ \h ->
              ( h
                  { hotAttributes =
                      Attributes.addAttributes
                        (tracerProviderAttributeLimits $ tracerProvider $ spanTracer imm)
                        (hotAttributes h)
                        carryOns
                  }
              , ()
              )
        spanProcessorOnEnd p imm
    , spanProcessorShutdown = spanProcessorShutdown p
    , spanProcessorForceFlush = spanProcessorForceFlush p
    }
