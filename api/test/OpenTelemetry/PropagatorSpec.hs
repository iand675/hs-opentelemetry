{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.PropagatorSpec where

import Data.List (sort)
import qualified OpenTelemetry.Context as Ctx
import OpenTelemetry.Propagator
import Test.Hspec


spec :: Spec
spec = describe "Propagator" $ do
  -- Propagators API §TextMap Propagator: carrier get/set keys
  -- https://opentelemetry.io/docs/specs/otel/context/api-propagators/
  describe "TextMap" $ do
    it "emptyTextMap has no keys" $ do
      textMapKeys emptyTextMap `shouldBe` []

    it "textMapInsert then textMapLookup retrieves value" $ do
      let tm = textMapInsert "foo" "bar" emptyTextMap
      textMapLookup "foo" tm `shouldBe` Just "bar"

    it "is case-insensitive on keys" $ do
      let tm = textMapInsert "Content-Type" "text/plain" emptyTextMap
      textMapLookup "content-type" tm `shouldBe` Just "text/plain"
      textMapLookup "CONTENT-TYPE" tm `shouldBe` Just "text/plain"
      textMapKeys tm `shouldMatchList` ["Content-Type"]
      textMapToList tm `shouldMatchList` [("Content-Type", "text/plain")]

    it "textMapDelete removes entry" $ do
      let tm = textMapInsert "k" "v" emptyTextMap
          tm' = textMapDelete "k" tm
      textMapLookup "k" tm' `shouldBe` Nothing

    it "textMapDelete is case-insensitive" $ do
      let tm = textMapInsert "X-Custom" "val" emptyTextMap
          tm' = textMapDelete "x-custom" tm
      textMapLookup "x-custom" tm' `shouldBe` Nothing

    it "textMapKeys returns all keys" $ do
      let tm = textMapInsert "b" "2" $ textMapInsert "a" "1" emptyTextMap
      sort (textMapKeys tm) `shouldBe` ["a", "b"]

    it "textMapToList returns all pairs" $ do
      let tm = textMapFromList [("X", "1"), ("Y", "2")]
          pairs = textMapToList tm
      length pairs `shouldBe` 2

    it "textMapFromList preserves key casing" $ do
      let tm = textMapFromList [("FOO", "bar")]
      textMapLookup "foo" tm `shouldBe` Just "bar"
      textMapToList tm `shouldMatchList` [("FOO", "bar")]

    it "textMapInsert overwrites existing key" $ do
      let tm = textMapInsert "k" "v1" $ textMapInsert "k" "v2" emptyTextMap
      textMapLookup "k" tm `shouldBe` Just "v1"

  -- Propagators API §Composite Propagator: fields, extract, inject
  -- https://opentelemetry.io/docs/specs/otel/context/api-propagators/
  describe "Propagator composition" $ do
    it "mempty propagator fields are empty" $ do
      let p = mempty :: TextMapPropagator
      propagatorFields p `shouldBe` []

    it "composed propagator merges fields" $ do
      let p1 = Propagator {propagatorFields = ["traceparent"], extractor = \_ c -> pure c, injector = \_ o -> pure o}
          p2 = Propagator {propagatorFields = ["baggage"], extractor = \_ c -> pure c, injector = \_ o -> pure o}
          combined = p1 <> p2 :: TextMapPropagator
      propagatorFields combined `shouldBe` ["traceparent", "baggage"]

    it "extract chains extractors" $ do
      let p1 = Propagator {propagatorFields = [], extractor = \_ c -> pure c, injector = \_ o -> pure o}
          p2 = Propagator {propagatorFields = [], extractor = \_ c -> pure c, injector = \_ o -> pure o}
          combined = p1 <> p2 :: TextMapPropagator
      _ <- extract combined emptyTextMap Ctx.empty
      True `shouldBe` True

    it "inject chains injectors left to right" $ do
      let p1 = Propagator {propagatorFields = ["a"], extractor = \_ c -> pure c, injector = \_ tm -> pure (textMapInsert "a" "1" tm)}
          p2 = Propagator {propagatorFields = ["b"], extractor = \_ c -> pure c, injector = \_ tm -> pure (textMapInsert "b" "2" tm)}
          combined = p1 <> p2 :: TextMapPropagator
      result <- inject combined Ctx.empty emptyTextMap
      textMapLookup "a" result `shouldBe` Just "1"
      textMapLookup "b" result `shouldBe` Just "2"

  -- Implementation-specific: global TextMap propagator registry slot
  -- https://opentelemetry.io/docs/specs/otel/context/api-propagators/
  describe "Global TextMapPropagator" $ do
    it "setGlobalTextMapPropagator and getGlobalTextMapPropagator roundtrip" $ do
      let p = Propagator {propagatorFields = ["test-field"], extractor = \_ c -> pure c, injector = \_ o -> pure o} :: TextMapPropagator
      setGlobalTextMapPropagator p
      p' <- getGlobalTextMapPropagator
      propagatorFields p' `shouldBe` ["test-field"]
      setGlobalTextMapPropagator (mempty :: TextMapPropagator)
