{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module OpenTelemetry.ContextInSpanSpec (spec) where

import Control.Exception (SomeException, handle, throwIO)
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Context.ThreadLocal (getContext)
import OpenTelemetry.Trace
import OpenTelemetry.Trace.Core
import Test.Hspec


spec :: Spec
spec = describe "Nested context restoration" $ do
  it "outer context is restored after inner scope" $ do
    p <- getGlobalTracerProvider
    let t = makeTracer p "ctx-test" tracerOptions
    inSpan' t "outer" defaultSpanArguments $ \outerSpan -> do
      outerSc <- getSpanContext outerSpan
      inSpan' t "inner" defaultSpanArguments $ \_innerSpan -> do
        pure ()
      ctxt <- getContext
      case Context.lookupSpan ctxt of
        Nothing -> expectationFailure "expected outer span after inner scope"
        Just restored -> do
          rsc <- getSpanContext restored
          rsc `shouldBe` outerSc

  it "context is restored after exception in inSpan" $ do
    p <- getGlobalTracerProvider
    let t = makeTracer p "ctx-exception" tracerOptions
    inSpan' t "outer-ex" defaultSpanArguments $ \outerSpan -> do
      outerSc <- getSpanContext outerSpan
      handle (\(_ :: SomeException) -> pure ()) $
        inSpan' t "throwing" defaultSpanArguments $ \_s ->
          throwIO (userError "boom")
      ctxt <- getContext
      case Context.lookupSpan ctxt of
        Nothing -> expectationFailure "expected outer span restored after exception"
        Just restored -> do
          rsc <- getSpanContext restored
          rsc `shouldBe` outerSc
