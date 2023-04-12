{-# LANGUAGE OverloadedStrings #-}

-- | Instrumentation for Hspec test suites
module OpenTelemetry.Instrumentation.Hspec (
  wrapSpec,
  wrapExampleInSpan,
) where

import Control.Monad (void)
import Control.Monad.IO.Class
import Control.Monad.Reader
import Data.Text (Text)
import qualified Data.Text as T
import OpenTelemetry.Attributes (Attributes)
import OpenTelemetry.Context
import OpenTelemetry.Context.ThreadLocal (adjustContext, attachContext, getContext)
import OpenTelemetry.Trace.Core
import Test.Hspec.Core.Spec (ActionWith, Item (..), Spec, SpecWith, mapSpecItem_)


{- | Creates a wrapper function that you can pass a spec into.

   This function will wrap each @it@ test case with a span with the name of
   the test case.

   The context in which this is called determines the parent span of all of
   the spec items.
-}
wrapSpec :: MonadIO m => m (SpecWith a -> SpecWith a)
wrapSpec = do
  tp <- getGlobalTracerProvider
  let tracer = makeTracer tp "hs-opentelemetry-instrumentation-hspec" tracerOptions
  context <- getContext

  -- FIXME: this kind of just dumps everything flat into one span per `it`. We
  -- could possibly do better, e.g. finding the `describe`s and making them into
  -- spans but I am not sure how that would be achieved.
  pure $ \spec -> mapSpecItem_ (wrapExampleInSpan tracer context) spec


{- | Wraps one example in a span parented by the specified context, and ensures
   the thread running the spec item will have a context available.
-}
wrapExampleInSpan :: Tracer -> Context -> Item a -> Item a
wrapExampleInSpan tp traceContext item@Item {itemExample = ex, itemRequirement = req} =
  item
    { itemExample = \params aroundAction pcb -> do
        let aroundAction' a = do
              -- we need to reattach the context, since we are on a forked thread
              void $ attachContext traceContext
              inSpan tp (T.pack req) defaultSpanArguments (aroundAction a)

        ex params aroundAction' pcb
    }
