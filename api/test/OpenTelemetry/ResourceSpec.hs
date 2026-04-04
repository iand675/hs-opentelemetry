{-# LANGUAGE PatternSynonyms #-}

module OpenTelemetry.ResourceSpec where

import qualified Data.Text as T
import qualified OpenTelemetry.Resource as R
import qualified Test.Hspec as Hspec


spec :: Hspec.Spec
spec = Hspec.describe "Resource" $ do
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


mkExampleResource :: T.Text -> Int -> R.Resource
mkExampleResource name count =
  R.mkResource [ExampleName R..= name, ExampleCount R..= count]


pattern ExampleName :: T.Text
pattern ExampleName = "example.name"


pattern ExampleCount :: T.Text
pattern ExampleCount = "example.count"
