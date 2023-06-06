{-# LANGUAGE OverloadedStrings #-}

-- | Instrumentation for Hspec test suites
module OpenTelemetry.Instrumentation.Hspec (
  wrapSpec,
  wrapExampleInSpan,
  instrumentSpec,
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
import Test.Hspec.Core.Spec (ActionWith, Item (..), Tree(..), Spec, SpecWith, mapSpecItem_, mapSpecForest)
import qualified Data.List as List


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

-- | Instrument each test case. Each 'describe' and friends will add
-- a span, and the final test will be in a span described by 'it'.
instrumentSpec :: Tracer -> Context -> SpecWith a -> SpecWith a
instrumentSpec tracer traceContext spec = do
  mapSpecForest (map (go [])) spec
    where
      go spans t = case t of
        Node str rest ->
          Node str (map (go (str : spans)) rest)
        NodeWithCleanup mloc c rest ->
          NodeWithCleanup mloc c (map (go spans) rest)
        Leaf item ->
          Leaf item
            { itemExample = \params aroundAction pcb -> do
                let aroundAction' a = do
                      -- we need to reattach the context, since we are on a forked thread
                      void $ attachContext traceContext
                      addSpans spans $ inSpan tracer (T.pack (itemRequirement item)) defaultSpanArguments (aroundAction a)

                itemExample item params aroundAction' pcb
            }

      addSpans spans k =
        List.foldl' (\acc x -> inSpan tracer (T.pack x) defaultSpanArguments acc) k spans
