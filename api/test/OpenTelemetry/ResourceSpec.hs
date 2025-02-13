{-# LANGUAGE DataKinds #-}
{-# LANGUAGE PatternSynonyms #-}

module OpenTelemetry.ResourceSpec where

import qualified Data.Text as T
import qualified OpenTelemetry.Resource as R
import qualified Test.Hspec as Hspec


spec :: Hspec.Spec
spec = Hspec.describe "Resource" $ do
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


mkExampleResource :: T.Text -> Int -> R.Resource 'Nothing
mkExampleResource name count =
  R.mkResource [ExampleName R..= name, ExampleCount R..= count]


pattern ExampleName :: T.Text
pattern ExampleName = "example.name"


pattern ExampleCount :: T.Text
pattern ExampleCount = "example.count"
