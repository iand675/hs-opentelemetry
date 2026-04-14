{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.Context.ThreadLocalSpec where

import Data.Maybe (isNothing)
import OpenTelemetry.Context (empty, insert, lookup, newKey)
import OpenTelemetry.Context.ThreadLocal
import Test.Hspec
import Prelude hiding (lookup)


spec :: Spec
spec = describe "Context.ThreadLocal" $ do
  -- Context API §Context: attach/detach current context (language-specific carrier)
  -- https://opentelemetry.io/docs/specs/otel/context/
  describe "getContext / attachContext" $ do
    it "getContext returns empty context when nothing meaningful attached" $ do
      k <- newKey "clean-state"
      tok <- attachContext (insert k (1 :: Int) empty)
      detachContext tok
      ctx <- getContext
      lookup k ctx `shouldBe` Nothing

    it "attachContext then getContext retrieves the same context" $ do
      k <- newKey "tl-test"
      let ctx = insert k (42 :: Int) empty
      tok <- attachContext ctx
      ctx' <- getContext
      lookup k ctx' `shouldBe` Just 42
      detachContext tok

    it "attachContext returns a token that restores previous context" $ do
      k <- newKey "prev"
      let ctx1 = insert k (1 :: Int) empty
          ctx2 = insert k (2 :: Int) empty
      tok1 <- attachContext ctx1
      tok2 <- attachContext ctx2
      ctx' <- getContext
      lookup k ctx' `shouldBe` Just 2
      detachContext tok2
      restored <- getContext
      lookup k restored `shouldBe` Just 1
      detachContext tok1

  describe "detachContext" $ do
    it "detach restores the context from before attach" $ do
      k1 <- newKey "before"
      let before = insert k1 (42 :: Int) empty
      tok0 <- attachContext before
      k2 <- newKey "detach"
      let ctx = insert k2 (99 :: Int) empty
      tok <- attachContext ctx
      detachContext tok
      ctx' <- getContext
      lookup k1 ctx' `shouldBe` Just 42
      lookup k2 ctx' `shouldBe` Nothing
      detachContext tok0

    it "nested attach/detach restores correctly" $ do
      k <- newKey "nested"
      tok1 <- attachContext (insert k (1 :: Int) empty)
      tok2 <- attachContext (insert k (2 :: Int) empty)
      tok3 <- attachContext (insert k (3 :: Int) empty)
      ctx3 <- getContext
      lookup k ctx3 `shouldBe` Just 3
      detachContext tok3
      ctx2 <- getContext
      lookup k ctx2 `shouldBe` Just 2
      detachContext tok2
      ctx1 <- getContext
      lookup k ctx1 `shouldBe` Just 1
      detachContext tok1

  -- Implementation-specific: LIFO detach validation (error handling)
  -- https://opentelemetry.io/docs/specs/otel/context/
  describe "LIFO validation" $ do
    it "detaching in wrong order does not crash (logs error)" $ do
      k <- newKey "lifo"
      let ctx1 = insert k (1 :: Int) empty
          ctx2 = insert k (2 :: Int) empty
      tok1 <- attachContext ctx1
      tok2 <- attachContext ctx2
      -- Out-of-order detach: should log error but still restore
      detachContext tok1
      detachContext tok2 :: IO ()

  describe "adjustContext" $ do
    it "modifies the current thread context" $ do
      k <- newKey "adjust-tl"
      let ctx = insert k (10 :: Int) empty
      tok <- attachContext ctx
      adjustContext (insert k (20 :: Int))
      ctx' <- getContext
      lookup k ctx' `shouldBe` Just 20
      detachContext tok
