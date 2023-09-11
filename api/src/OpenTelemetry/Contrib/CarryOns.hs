module OpenTelemetry.Contrib.CarryOns (
  alterCarryOns,
  withCarryOnProcessor,
) where

import Control.Monad.IO.Class
import qualified Data.HashMap.Strict as H
import Data.IORef (modifyIORef')
import Data.Maybe (fromMaybe)
import Data.Text (Text)
import OpenTelemetry.Attributes
import OpenTelemetry.Context
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Context.ThreadLocal
import OpenTelemetry.Internal.Trace.Types
import OpenTelemetry.Trace.Core
import System.IO.Unsafe (unsafePerformIO)


carryOnKey :: Key (H.HashMap Text Attribute)
carryOnKey = unsafePerformIO $ newKey "carryOn"
{-# NOINLINE carryOnKey #-}


alterCarryOns :: (MonadIO m) => (H.HashMap Text Attribute -> H.HashMap Text Attribute) -> m ()
alterCarryOns f = adjustContext $ \ctxt ->
  Context.insert carryOnKey (f $ fromMaybe mempty $ Context.lookup carryOnKey ctxt) ctxt


{- |
"Carry ons" are extra attributes that are added to every span that is completed for within a thread's context.
This helps us propagate attributes across a trace without having to manually add them to every span.

Be cautious about adding too many additional attributes via carry ons. The attributes are added to every span,
and will be discarded if the span has attributes that exceed the configured attribute limits for the configured
'TracerProvider'.
-}
withCarryOnProcessor :: Processor -> Processor
withCarryOnProcessor p =
  Processor
    { processorOnStart = processorOnStart p
    , processorOnEnd = \spanRef -> do
        ctxt <- getContext
        let carryOns = fromMaybe mempty $ Context.lookup carryOnKey ctxt
        if H.null carryOns
          then pure ()
          else do
            -- I doubt we need atomicity at this point. Hopefully people aren't trying to modify the same span after it has ended from multiple threads.
            modifyIORef' spanRef $ \is ->
              is
                { spanAttributes =
                    OpenTelemetry.Attributes.addAttributes
                      (tracerProviderAttributeLimits $ tracerProvider $ spanTracer is)
                      (spanAttributes is)
                      carryOns
                }
        processorOnEnd p spanRef
    , processorShutdown = processorShutdown p
    , processorForceFlush = processorForceFlush p
    }
