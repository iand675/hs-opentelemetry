{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module OpenTelemetry.ContextSpec where

import Data.Maybe (isJust, isNothing)
import OpenTelemetry.Context
import Test.Hspec
import Prelude hiding (lookup)


spec :: Spec
spec = describe "Context" $ do
  -- Context API §Context: empty context
  -- https://opentelemetry.io/docs/specs/otel/context/
  describe "empty" $ do
    -- Context API §Context interactions with OTel: span slot empty in empty context
    -- https://opentelemetry.io/docs/specs/otel/context/
    it "has no span" $ do
      lookupSpan empty `shouldSatisfy` isNothing

    -- Context API §Context interactions with OTel: baggage slot empty in empty context
    -- https://opentelemetry.io/docs/specs/otel/context/
    it "has no baggage" $ do
      lookupBaggage empty `shouldSatisfy` isNothing

  -- Context API §Context: get-value, set-value, and remove-value operations
  -- https://opentelemetry.io/docs/specs/otel/context/
  describe "key/value operations" $ do
    it "insert then lookup retrieves the value" $ do
      k <- newKey "test-key"
      let ctx = insert k (42 :: Int) empty
      lookup k ctx `shouldBe` Just 42

    it "lookup on empty returns Nothing" $ do
      k <- newKey "missing"
      lookup k (empty :: Context) `shouldBe` (Nothing :: Maybe Int)

    it "delete removes a key" $ do
      k <- newKey "del-key"
      let ctx = insert k (10 :: Int) empty
          ctx' = delete k ctx
      lookup k ctx' `shouldBe` Nothing

    it "adjust modifies an existing value" $ do
      k <- newKey "adj-key"
      let ctx = insert k (5 :: Int) empty
          ctx' = adjust (+ 10) k ctx
      lookup k ctx' `shouldBe` Just 15

    it "adjust on missing key is a no-op" $ do
      k <- newKey "no-adj"
      let f :: Int -> Int
          f = (+ 1)
          ctx' = adjust f k empty
      lookup k ctx' `shouldBe` Nothing

    it "union merges two contexts" $ do
      k1 <- newKey "k1"
      k2 <- newKey "k2"
      let ctx1 = insert k1 (1 :: Int) empty
          ctx2 = insert k2 (2 :: Int) empty
          merged = union ctx1 ctx2
      lookup k1 merged `shouldSatisfy` isJust
      lookup k2 merged `shouldSatisfy` isJust

    -- Implementation-specific: Context key diagnostic name
    -- https://opentelemetry.io/docs/specs/otel/context/
    it "keyName returns the name" $ do
      k <- newKey "my-key"
      keyName k `shouldBe` "my-key"

  -- Context API §Context interactions with OTel: active span slot
  -- https://opentelemetry.io/docs/specs/otel/context/
  describe "span slot" $ do
    it "removeSpan clears the span" $ do
      lookupSpan (removeSpan empty) `shouldSatisfy` isNothing

  -- Context API §Context interactions with OTel: baggage slot
  -- https://opentelemetry.io/docs/specs/otel/context/
  describe "baggage slot" $ do
    it "removeBaggage clears baggage" $ do
      lookupBaggage (removeBaggage empty) `shouldSatisfy` isNothing
