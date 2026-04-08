{-# LANGUAGE PatternSynonyms #-}

module OpenTelemetry.AttributesSpec where

import qualified Data.HashMap.Strict as H
import qualified Data.Text as T
import qualified OpenTelemetry.Attributes as A
import qualified Test.Hspec as Hspec


spec :: Hspec.Spec
spec = Hspec.describe "Attributes" $ do
  -- Common §Attribute: attribute key/value collection
  -- https://opentelemetry.io/docs/specs/otel/common/#attribute
  Hspec.describe "addAttribute" $ do
    let overwritesPrevious :: (A.ToAttribute a) => T.Text -> a -> a -> A.Attributes -> Hspec.Spec
        overwritesPrevious attrKey newValue prevValue attrs = do
          let addAttr = addAttributeDefault attrKey
          -- Common §Attribute: setting an attribute replaces any existing value for the same key
          -- https://opentelemetry.io/docs/specs/otel/common/#attribute
          Hspec.it "Overwrites previous value with new value at this key." $
            addAttr newValue (addAttr prevValue attrs) `Hspec.shouldBe` addAttr newValue attrs

    overwritesPrevious Example ("new value" :: T.Text) "prev value" A.emptyAttributes
  -- Common §Attribute: batch attribute updates
  -- https://opentelemetry.io/docs/specs/otel/common/#attribute
  Hspec.describe "addAttributes" $ do
    Hspec.it "new values override existing for same key" $ do
      let initial = addAttributeDefault Example ("old" :: T.Text) A.emptyAttributes
          batch = H.singleton Example ("new" :: T.Text)
          result = A.addAttributes A.defaultAttributeLimits initial batch
      A.lookupAttribute result Example `Hspec.shouldBe` Just (A.toAttribute ("new" :: T.Text))

  -- Implementation-specific: merge helper (not part of the portable Attributes API)
  -- https://opentelemetry.io/docs/specs/otel/common/#attribute
  Hspec.describe "unsafeMergeAttributesIgnoringLimits" $ do
    Hspec.it "Is left-biased when keys conflict" $ do
      let left = addAttributeDefault Example (1 :: Int) A.emptyAttributes
          right = addAttributeDefault Example (2 :: Int) A.emptyAttributes
      A.unsafeMergeAttributesIgnoringLimits left right `Hspec.shouldBe` left

  -- Common §Attribute: empty attribute set
  -- https://opentelemetry.io/docs/specs/otel/common/#attribute
  Hspec.describe "emptyAttributes" $ do
    Hspec.it "has count 0" $ do
      A.getCount A.emptyAttributes `Hspec.shouldBe` 0
    Hspec.it "has dropped 0" $ do
      A.getDropped A.emptyAttributes `Hspec.shouldBe` 0

  Hspec.describe "lookupAttribute" $ do
    Hspec.it "finds an added attribute" $ do
      let attrs = addAttributeDefault Example ("hello" :: T.Text) A.emptyAttributes
      A.lookupAttribute attrs Example `Hspec.shouldBe` Just (A.toAttribute ("hello" :: T.Text))

    Hspec.it "returns Nothing for missing key" $ do
      A.lookupAttribute A.emptyAttributes "no-such-key" `Hspec.shouldBe` Nothing

  -- Common §Attribute: strongly-typed attribute keys (API ergonomics)
  -- https://opentelemetry.io/docs/specs/otel/common/#attribute
  Hspec.describe "addAttributeByKey" $ do
    Hspec.it "adds attribute with typed key" $ do
      let key = A.AttributeKey "typed-key"
          attrs = A.addAttributeByKey A.defaultAttributeLimits A.emptyAttributes key (42 :: Int)
      A.lookupAttributeByKey attrs key `Hspec.shouldBe` Just (A.toAttribute (42 :: Int))

  Hspec.describe "lookupAttributeByKey" $ do
    Hspec.it "returns Nothing for missing typed key" $ do
      let key = A.AttributeKey "missing"
      A.lookupAttributeByKey A.emptyAttributes key `Hspec.shouldBe` (Nothing :: Maybe A.Attribute)

  -- Implementation-specific: exposing the underlying attribute map for interop
  -- https://opentelemetry.io/docs/specs/otel/common/#attribute
  Hspec.describe "getAttributeMap" $ do
    Hspec.it "returns the underlying map" $ do
      let attrs = addAttributeDefault Example ("v" :: T.Text) A.emptyAttributes
          m = A.getAttributeMap attrs
      H.lookup Example m `Hspec.shouldBe` Just (A.toAttribute ("v" :: T.Text))

  -- Common §Attribute limits: count and dropped-attribute accounting
  -- https://opentelemetry.io/docs/specs/otel/common/#attribute-limits
  Hspec.describe "getCount / getDropped" $ do
    Hspec.it "getCount increments with addAttribute" $ do
      let a1 = addAttributeDefault "k1" ("v1" :: T.Text) A.emptyAttributes
          a2 = addAttributeDefault "k2" ("v2" :: T.Text) a1
      A.getCount a2 `Hspec.shouldBe` 2

    Hspec.it "getDropped increases when limit exceeded" $ do
      let lim = A.AttributeLimits {attributeCountLimit = Just 1, attributeLengthLimit = Nothing}
          a1 = A.addAttribute lim A.emptyAttributes "k1" ("v1" :: T.Text)
          a2 = A.addAttribute lim a1 "k2" ("v2" :: T.Text)
      A.getDropped a2 `Hspec.shouldBe` 1

  Hspec.describe "addAttributesFromBuilder" $ do
    Hspec.it "adds attributes from a builder" $ do
      let builder = A.attr "bk" ("bv" :: T.Text)
          attrs = A.addAttributesFromBuilder A.defaultAttributeLimits A.emptyAttributes builder
      A.lookupAttribute attrs "bk" `Hspec.shouldBe` Just (A.toAttribute ("bv" :: T.Text))

  -- Implementation-specific: attribute builder helpers
  -- https://opentelemetry.io/docs/specs/otel/common/#attribute
  Hspec.describe "attr builder" $ do
    Hspec.it "attr creates a single-attribute builder" $ do
      let builder = A.attr "test" (True :: Bool)
          attrs = A.addAttributesFromBuilder A.defaultAttributeLimits A.emptyAttributes builder
      A.lookupAttribute attrs "test" `Hspec.shouldBe` Just (A.toAttribute True)

    Hspec.it "optAttr includes Just values" $ do
      let builder = A.optAttr "opt" (Just (7 :: Int))
          attrs = A.addAttributesFromBuilder A.defaultAttributeLimits A.emptyAttributes builder
      A.lookupAttribute attrs "opt" `Hspec.shouldBe` Just (A.toAttribute (7 :: Int))

    Hspec.it "optAttr skips Nothing values" $ do
      let builder = A.optAttr "opt" (Nothing :: Maybe Int)
          attrs = A.addAttributesFromBuilder A.defaultAttributeLimits A.emptyAttributes builder
      A.lookupAttribute attrs "opt" `Hspec.shouldBe` Nothing

    Hspec.it "buildAttrs builds from a builder" $ do
      let builder = A.attr "b1" ("v1" :: T.Text) <> A.attr "b2" (2 :: Int)
          m = A.buildAttrs builder
      H.size m `Hspec.shouldBe` 2


pattern Example :: T.Text
pattern Example = "example"


addAttributeDefault :: (A.ToAttribute a) => T.Text -> a -> A.Attributes -> A.Attributes
addAttributeDefault attrKey value attrs = A.addAttribute A.defaultAttributeLimits attrs attrKey value
