{-# LANGUAGE PatternSynonyms #-}

module OpenTelemetry.AttributesSpec where

import qualified Data.Text as T
import qualified OpenTelemetry.Attributes as A
import qualified Test.Hspec as Hspec


spec :: Hspec.Spec
spec = Hspec.describe "Attributes" $ do
  Hspec.describe "addAttribute" $ do
    let overwritesPrevious :: (A.ToAttribute a) => T.Text -> a -> a -> A.Attributes -> Hspec.Spec
        overwritesPrevious attrKey newValue prevValue attrs = do
          let addAttr = addAttributeDefault attrKey
          Hspec.it "Overwrites previous value with new value at this key." $
            addAttr newValue (addAttr prevValue attrs) `Hspec.shouldBe` addAttr newValue attrs

    overwritesPrevious Example ("new value" :: T.Text) "prev value" A.emptyAttributes
  Hspec.describe "unsafeMergeAttributesIgnoringLimits" $ do
    Hspec.it "Is left-biased when keys conflict" $ do
      let left = addAttributeDefault Example (1 :: Int) A.emptyAttributes
          right = addAttributeDefault Example (2 :: Int) A.emptyAttributes
      A.unsafeMergeAttributesIgnoringLimits left right `Hspec.shouldBe` left


pattern Example :: T.Text
pattern Example = "example"


addAttributeDefault :: (A.ToAttribute a) => T.Text -> a -> A.Attributes -> A.Attributes
addAttributeDefault attrKey value attrs = A.addAttribute A.defaultAttributeLimits attrs attrKey value
