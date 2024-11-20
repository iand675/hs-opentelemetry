{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}

module OpenTelemetry.Instrumentation.Tasty (instrumentTestTree, instrumentTestTreeWithTracer) where

import Control.Exception (bracket)
import Data.Tagged (Tagged, retag)
import Data.Text qualified as T
import OpenTelemetry.Context (insertSpan, lookupSpan, removeSpan)
import OpenTelemetry.Context.ThreadLocal (adjustContext, getContext)
import OpenTelemetry.Trace (Span, SpanStatus (Error, Ok), Tracer, addAttribute, createSpan, defaultSpanArguments, endSpan, getGlobalTracerProvider, inSpan, makeTracer, setStatus, tracerOptions)
import OpenTelemetry.Trace.Core (detectInstrumentationLibrary)
import Test.Tasty (TestTree, withResource)
import Test.Tasty.Options (OptionDescription)
import Test.Tasty.Providers (IsTest (run, testOptions))
import Test.Tasty.Runners (Outcome (Failure, Success), ResourceSpec (ResourceSpec), Result (Result, resultDescription, resultOutcome), TestTree (After, AskOptions, PlusTestOptions, SingleTest, TestGroup, WithResource))


{- | A test case with a wrapper function that can do some IO around the
test. We use the wrapper to set up spans appropriately.
-}
data WrappedTest t = WrappedTest
  {wrapper :: forall a. IO a -> IO a, innerTest :: t}


instance IsTest t => IsTest (WrappedTest t) where
  run opts (WrappedTest {wrapper, innerTest}) progress =
    wrapper $ do
      ctx <- getContext
      let mspan = lookupSpan ctx
      res@Result {resultOutcome, resultDescription} <- run opts innerTest progress
      case mspan of
        Just s -> do
          addAttribute s "result.description" (T.pack resultDescription)
          case resultOutcome of
            Success -> do
              setStatus s $ Ok
            Failure reason -> do
              setStatus s $ Error $ T.pack $ show reason
        Nothing -> pure ()

      pure res
  testOptions = retag (testOptions :: Tagged t [OptionDescription])


-- | Transform a 'TestTree' into one that emits spans around tests and test groups.
instrumentTestTree :: TestTree -> IO TestTree
instrumentTestTree t = do
  provider <- getGlobalTracerProvider
  let tracer = makeTracer provider $detectInstrumentationLibrary tracerOptions
  pure $ instrumentTestTreeWithTracer tracer t


-- | See 'instrumentTestTree'.
instrumentTestTreeWithTracer :: Tracer -> TestTree -> TestTree
instrumentTestTreeWithTracer tracer = instrumentTestTree' tracer (pure Nothing)


instrumentTestTree'
  :: Tracer
  -> IO (Maybe Span)
  -> TestTree
  -> TestTree
instrumentTestTree' tracer = go
  where
    -- See Note [Test parallelism] for why we pass around 'getParentSpan'
    go :: IO (Maybe Span) -> TestTree -> TestTree
    go getParentSpan = \case
      TestGroup name tests ->
        -- We use 'withResource' to associate the creation and destruction of the
        -- group span with the beginning and end of the group itself. This way
        -- 'tasty' manages the lifetime of the span for us.
        withResource
          (mkSpan (T.pack name))
          (\s -> endSpan s Nothing)
          $ \getGroupSpan ->
            let getParentSpan' = Just <$> getGroupSpan
            in TestGroup name (fmap (go getParentSpan') tests)
      SingleTest name t ->
        SingleTest name $
          WrappedTest {wrapper = withNamedSpan name, innerTest = t}
      WithResource (ResourceSpec acquire release) f ->
        -- Add spans for resource acquisition and release
        -- Nit: currently we don't create a span for the top-level itself, so
        -- if you acquire outside a test group then the spans will be detached.
        -- We could add a span for the top level, although it's maybe a little odd.
        let newResourceSpec = ResourceSpec (withNamedSpan "acquire" acquire) (fmap (withNamedSpan "release") release)
        in WithResource newResourceSpec (go' . f)
      PlusTestOptions modifier t -> PlusTestOptions modifier (go' t)
      AskOptions f -> AskOptions (go' . f)
      After d e t -> After d e $ go' t
      where
        go' = go getParentSpan
        mkSpan name = do
          ctx <- getContext
          -- See Note [Test parallelism]
          parentSpan <- getParentSpan
          -- This does not modify the thread-local context, just locally
          ctx' <- case parentSpan of
            Just s -> pure $ insertSpan s ctx
            Nothing -> pure ctx
          createSpan tracer ctx' name defaultSpanArguments
        withNamedSpan :: String -> (forall a. IO a -> IO a)
        withNamedSpan name act = do
          -- See Note [Test parallelism]
          parentSpan <- getParentSpan
          let wrapper = case parentSpan of
                Just ps -> withParentSpan ps
                Nothing -> id
          wrapper $ inSpan tracer (T.pack name) defaultSpanArguments act


-- Possibly should upstream this to the SDK?

{- | Given a span, produces a wrapper function that sets the given span
as the installed span in the context.
-}
withParentSpan :: Span -> (forall a. IO a -> IO a)
withParentSpan parentSpan act =
  bracket setup teardown $ \_ -> act
  where
    setup = do
      ctx <- getContext
      adjustContext (insertSpan parentSpan)
      pure (lookupSpan ctx, ctx)
    teardown (originalParentSpan, _ctx) = do
      adjustContext $ \ctx -> maybe (removeSpan ctx) (`insertSpan` ctx) originalParentSpan

{- Note [Test parallelism]
Tasty runs tests in parallel by default, and we don't want to disturb that.
However, that means that any individual test case may be running on a random thread at tasty's
discretion, and so we can't rely on the thread-local context to link up spans.

Our solution is just to track (an action to access) the parent span manually as we traverse
the tree, so we can connect them up manually.
-}
