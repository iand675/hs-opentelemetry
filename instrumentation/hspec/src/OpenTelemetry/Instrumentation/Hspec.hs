{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.Instrumentation.Hspec
  ( wrapSpec,
    wrapExampleInSpan,
  )
where

import Control.Monad.IO.Class
import Control.Monad.Reader
import Data.Text (Text)
import qualified Data.Text as T
import OpenTelemetry.Attributes (Attributes)
import OpenTelemetry.Context
import OpenTelemetry.Context.ThreadLocal (adjustContext, attachContext, getContext)
import OpenTelemetry.Trace.Core
import Test.Hspec.Core.Spec (ActionWith, Item (..), Spec, SpecWith, mapSpecItem_)

wrapSpec :: MonadIO m => m (SpecWith a -> SpecWith a)
wrapSpec = do
  tp <- getGlobalTracerProvider
  let tracer = makeTracer tp "hs-opentelemetry-instrumentation-hspec" tracerOptions
  context <- getContext

  -- FIXME: this kind of just dumps everything flat into one span. We could
  -- possibly do better, e.g. finding the `describe`s and making them into spans
  -- but I am not sure how that interacts with the evaluator
  pure $ \spec -> mapSpecItem_ (wrapExampleInSpan tracer context) spec

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
