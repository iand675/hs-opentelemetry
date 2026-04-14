{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

{- |
Module      : OpenTelemetry.Instrumentation.Hspec
Copyright   : (c) Ian Duncan, 2021-2026
License     : BSD-3
Description : Trace Hspec test suites as spans
Stability   : experimental

= Overview

Adds tracing around Hspec examples. Useful for CI observability: see which
tests ran, how long they took, and which ones failed.

'wrapSpec' uses the global tracer provider; compose it with
'OpenTelemetry.Trace.withTracerProvider' so the provider is initialized before
@hspec@ runs. For full control over tracer and parent context, use
'instrumentSpec' instead.

= Quick example

@
import Test.Hspec
import OpenTelemetry.Instrumentation.Hspec (wrapSpec)
import OpenTelemetry.Trace (withTracerProvider)

main :: IO ()
main = withTracerProvider $ \_ -> do
  runSpec <- wrapSpec
  hspec $ runSpec mySpec
@

'OpenTelemetry.Trace.withTracerProvider' lives in @hs-opentelemetry-sdk@.

= Nested structure

'instrumentSpec' adds spans for @describe@ nesting; 'wrapSpec' produces a flat
span per @it@ (see its Haddock for rationale).
-}
module OpenTelemetry.Instrumentation.Hspec (
  wrapSpec,
  wrapExampleInSpan,
  instrumentSpec,
) where

import Control.Monad.IO.Class
import qualified Data.List as List
import qualified Data.Text as T
import OpenTelemetry.Context
import OpenTelemetry.Context.ThreadLocal (attachContext, getContext)
import OpenTelemetry.Trace.Core
import Test.Hspec.Core.Spec (Item (..), SpecWith, Tree (..), mapSpecForest, mapSpecItem_)


{- | Creates a wrapper function that you can pass a spec into.

   This function will wrap each @it@ test case with a span with the name of
   the test case.

   The context in which this is called determines the parent span of all of
   the spec items.
-}
wrapSpec :: (MonadIO m) => m (SpecWith a -> SpecWith a)
wrapSpec = do
  tp <- getGlobalTracerProvider
  let tracer = makeTracer tp $detectInstrumentationLibrary tracerOptions
  context <- getContext

  -- Span structure is flat: one span per @it@ item. Nesting spans under
  -- @describe@ blocks would require access to hspec's internal spec tree
  -- before execution, which isn't exposed by the hspec public API.
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
              _ <- attachContext traceContext
              inSpan tp (T.pack req) defaultSpanArguments (aroundAction a)

        ex params aroundAction' pcb
    }


{- | Instrument each test case. Each 'describe' and friends will add
 a span, and the final test will be in a span described by 'it'.
-}
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
        Leaf
          item
            { itemExample = \params aroundAction pcb -> do
                let aroundAction' a = do
                      -- we need to reattach the context, since we are on a forked thread
                      _ <- attachContext traceContext
                      addSpans spans $ inSpan tracer (T.pack (itemRequirement item)) defaultSpanArguments (aroundAction a)

                itemExample item params aroundAction' pcb
            }

    addSpans spans k =
      List.foldl' (\acc x -> inSpan tracer (T.pack x) defaultSpanArguments acc) k spans
