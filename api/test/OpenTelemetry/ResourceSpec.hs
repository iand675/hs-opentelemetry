{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE TypeApplications #-}

module OpenTelemetry.ResourceSpec where

import qualified Data.Text as T
import OpenTelemetry.Attributes (lookupAttribute, toAttribute)
import qualified OpenTelemetry.Resource as R
import qualified Test.Hspec as Hspec


spec :: Hspec.Spec
spec = Hspec.describe "Resource" $ do
  -- Resource SDK §Resource Creation: schema URL on materialized resources
  -- https://opentelemetry.io/docs/specs/otel/resource/sdk/
  Hspec.describe "materializeResourcesWithSchema" $ do
    Hspec.it "sets schema when Just is provided" $ do
      let mat =
            R.materializeResourcesWithSchema
              (Just "https://example.com")
              (mkExampleResource "svc" 1)
      R.getMaterializedResourcesSchema mat `Hspec.shouldBe` Just "https://example.com"

    Hspec.it "leaves schema Nothing when not provided" $ do
      let mat = R.materializeResourcesWithSchema Nothing (mkExampleResource "svc" 1)
      R.getMaterializedResourcesSchema mat `Hspec.shouldBe` Nothing

  Hspec.describe "setMaterializedResourcesSchema" $ do
    Hspec.it "overrides an existing schema" $ do
      let mat =
            R.materializeResourcesWithSchema
              (Just "https://example.com")
              (mkExampleResource "svc" 1)
          mat' = R.setMaterializedResourcesSchema (Just "new") mat
      R.getMaterializedResourcesSchema mat' `Hspec.shouldBe` Just "new"

  -- Resource SDK §Merge resources: conflicting attributes use primary (left) value
  -- https://opentelemetry.io/docs/specs/otel/resource/sdk/
  Hspec.describe "mergeResources" $ do
    Hspec.it "Is left-biased when attribute keys conflict" $ do
      let right = mkExampleResource "Old Right" 3
          left = mkExampleResource "New Left" 7
      R.materializeResources (R.mergeResources left right) `Hspec.shouldBe` R.materializeResources left

  Hspec.describe "Semigroup.<>" $ do
    Hspec.it "Is left-biased when attribute keys conflict" $ do
      let right = mkExampleResource "Old Right" 3
          left = mkExampleResource "New Left" 7
      R.materializeResources (left <> right) `Hspec.shouldBe` R.materializeResources left

  -- Resource SDK §Merge resources: schema URL merge rules
  -- https://opentelemetry.io/docs/specs/otel/resource/sdk/
  Hspec.describe "Schema URL merge" $ do
    Hspec.it "merge preserves schema when both match" $ do
      let r1 = R.mkResourceWithSchema (Just (T.pack "https://v1")) [ExampleName R..= ("a" :: T.Text), ExampleCount R..= (1 :: Int)]
          r2 = R.mkResourceWithSchema (Just (T.pack "https://v1")) [ExampleName R..= ("b" :: T.Text), ExampleCount R..= (2 :: Int)]
          merged = R.materializeResources (R.mergeResources r1 r2)
      R.getMaterializedResourcesSchema merged `Hspec.shouldBe` Just "https://v1"

    Hspec.it "merge with one empty schema takes non-empty" $ do
      let r1 = R.mkResourceWithSchema (Just (T.pack "https://v1")) [ExampleName R..= ("a" :: T.Text), ExampleCount R..= (1 :: Int)]
          r2 = R.mkResourceWithSchema Nothing [ExampleName R..= ("b" :: T.Text), ExampleCount R..= (2 :: Int)]
          merged = R.materializeResources (R.mergeResources r1 r2)
      R.getMaterializedResourcesSchema merged `Hspec.shouldBe` Just "https://v1"

    Hspec.it "merge with conflicting schemas takes left (updating) schema" $ do
      let r1 = R.mkResourceWithSchema (Just "https://v1") [ExampleName R..= ("a" :: T.Text)]
          r2 = R.mkResourceWithSchema (Just "https://v2") [ExampleCount R..= (1 :: Int)]
          merged = R.materializeResources (R.mergeResources r1 r2)
      R.getMaterializedResourcesSchema merged `Hspec.shouldBe` Just "https://v1"

  Hspec.describe "getMaterializedResourcesAttributes" $ do
    Hspec.it "returns the attributes from a materialized resource" $ do
      let r = R.mkResource [ExampleName R..= ("svc" :: T.Text)]
          mat = R.materializeResources r
          attrs = R.getMaterializedResourcesAttributes mat
      lookupAttribute attrs "example.name" `Hspec.shouldBe` Just (toAttribute @T.Text "svc")

  -- Resource SDK §Resource Creation: optional attributes
  -- https://opentelemetry.io/docs/specs/otel/resource/sdk/
  Hspec.describe "(.=?)" $ do
    Hspec.it "includes attribute when Just" $ do
      let r = R.mkResource [ExampleName R..=? Just ("svc" :: T.Text)]
          mat = R.materializeResources r
          attrs = R.getMaterializedResourcesAttributes mat
      lookupAttribute attrs "example.name" `Hspec.shouldBe` Just (toAttribute @T.Text "svc")

    Hspec.it "omits attribute when Nothing" $ do
      let r = R.mkResource [ExampleName R..=? (Nothing :: Maybe T.Text)]
          mat = R.materializeResources r
          attrs = R.getMaterializedResourcesAttributes mat
      lookupAttribute attrs "example.name" `Hspec.shouldBe` Nothing


mkExampleResource :: T.Text -> Int -> R.Resource
mkExampleResource name count =
  R.mkResource [ExampleName R..= name, ExampleCount R..= count]


pattern ExampleName :: T.Text
pattern ExampleName = "example.name"


pattern ExampleCount :: T.Text
pattern ExampleCount = "example.count"
