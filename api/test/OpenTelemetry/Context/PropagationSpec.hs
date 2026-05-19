{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.Context.PropagationSpec where

import Control.Concurrent.Async (wait)
import Control.Concurrent.MVar (newEmptyMVar, putMVar, takeMVar)
import OpenTelemetry.Context (empty, insert, lookup, newKey)
import OpenTelemetry.Context.ThreadLocal (attachContext, detachContext, getContext)
import OpenTelemetry.Context.ThreadLocal.Propagation
import Test.Hspec
import Prelude hiding (lookup)


spec :: Spec
spec = describe "Context.ThreadLocal.Propagation" $ do
  -- Context API §Context: propagate implicit context across continuations
  -- https://opentelemetry.io/docs/specs/otel/context/
  describe "propagateContext" $ do
    it "captures caller context for deferred execution" $ do
      k <- newKey "prop-test"
      let ctx = insert k (42 :: Int) empty
      tok <- attachContext ctx
      wrapped <- propagateContext $ do
        ctx' <- getContext
        pure (lookup k ctx')
      detachContext tok
      result <- wrapped
      result `shouldBe` Just 42

  describe "tracedForkIO" $ do
    it "child thread inherits caller context" $ do
      k <- newKey "fork-test"
      let ctx = insert k (99 :: Int) empty
      tok <- attachContext ctx
      mv <- newEmptyMVar
      _ <- tracedForkIO $ do
        ctx' <- getContext
        putMVar mv (lookup k ctx')
      result <- takeMVar mv
      result `shouldBe` Just 99
      detachContext tok

  describe "tracedAsync" $ do
    it "async task inherits caller context" $ do
      k <- newKey "async-test"
      let ctx = insert k (7 :: Int) empty
      tok <- attachContext ctx
      a <- tracedAsync $ do
        ctx' <- getContext
        pure (lookup k ctx')
      result <- wait a
      result `shouldBe` Just 7
      detachContext tok

  describe "tracedConcurrently" $ do
    it "both branches inherit caller context" $ do
      k <- newKey "conc-test"
      let ctx = insert k (33 :: Int) empty
      tok <- attachContext ctx
      (r1, r2) <-
        tracedConcurrently
          (do ctx' <- getContext; pure (lookup k ctx'))
          (do ctx' <- getContext; pure (lookup k ctx'))
      r1 `shouldBe` Just 33
      r2 `shouldBe` Just 33
      detachContext tok

  describe "tracedMapConcurrently" $ do
    it "all workers inherit caller context" $ do
      k <- newKey "map-conc"
      let ctx = insert k (55 :: Int) empty
      tok <- attachContext ctx
      results <- tracedMapConcurrently (\_ -> do ctx' <- getContext; pure (lookup k ctx')) [1 :: Int, 2, 3]
      results `shouldBe` [Just 55, Just 55, Just 55]
      detachContext tok

  describe "tracedForConcurrently" $ do
    it "all workers inherit caller context" $ do
      k <- newKey "for-conc"
      let ctx = insert k (88 :: Int) empty
      tok <- attachContext ctx
      results <- tracedForConcurrently [1 :: Int, 2] $ \_ -> do
        ctx' <- getContext
        pure (lookup k ctx')
      results `shouldBe` [Just 88, Just 88]
      detachContext tok

  describe "tracedWithAsync" $ do
    it "async task inherits caller context" $ do
      k <- newKey "with-async"
      let ctx = insert k (66 :: Int) empty
      tok <- attachContext ctx
      result <- tracedWithAsync (do ctx' <- getContext; pure (lookup k ctx')) wait
      result `shouldBe` Just 66
      detachContext tok
