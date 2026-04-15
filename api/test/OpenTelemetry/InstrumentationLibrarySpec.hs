module OpenTelemetry.InstrumentationLibrarySpec where

import OpenTelemetry.Attributes (addAttribute, defaultAttributeLimits, emptyAttributes)
import OpenTelemetry.Internal.Common.Types (
  InstrumentationLibrary (..),
  InstrumentationScope,
  instrumentationLibrary,
  instrumentationScope,
  parseInstrumentationLibrary,
  withLibraryAttributes,
  withSchemaUrl,
 )
import Test.Hspec


spec :: Spec
spec = describe "InstrumentationLibrary / InstrumentationScope" $ do
  -- Spec §Instrumentation scope: name, version, schema URL, attributes
  -- https://opentelemetry.io/docs/specs/otel/common/instrumentation-scope/
  describe "InstrumentationScope alias" $ do
    it "is the same type as InstrumentationLibrary" $ do
      let scope = instrumentationScope "my-lib" "1.0" :: InstrumentationScope
          lib = instrumentationLibrary "my-lib" "1.0" :: InstrumentationLibrary
      scope `shouldBe` lib

    it "instrumentationScope produces valid scope with all fields" $ do
      let scope =
            withSchemaUrl
              "https://opentelemetry.io/schemas/1.40.0"
              (instrumentationScope "my-lib" "2.0")
      libraryName scope `shouldBe` "my-lib"
      libraryVersion scope `shouldBe` "2.0"
      librarySchemaUrl scope `shouldBe` "https://opentelemetry.io/schemas/1.40.0"

  -- Glossary §Instrumentation scope: name, version, schema URL, attributes
  -- https://opentelemetry.io/docs/specs/otel/glossary/#instrumentation-scope
  describe "construction helpers" $ do
    it "builds a library with name, version, and empty schema and attributes" $ do
      let lib = instrumentationLibrary "my-lib" "1.0"
      libraryName lib `shouldBe` "my-lib"
      libraryVersion lib `shouldBe` "1.0"
      librarySchemaUrl lib `shouldBe` ""
      libraryAttributes lib `shouldBe` emptyAttributes

    it "withSchemaUrl sets librarySchemaUrl" $ do
      let lib =
            withSchemaUrl "https://example.com" (instrumentationLibrary "x" "1")
      librarySchemaUrl lib `shouldBe` "https://example.com"

    it "withLibraryAttributes sets libraryAttributes" $ do
      let someAttrs = addAttribute defaultAttributeLimits emptyAttributes "k" (True :: Bool)
          lib = withLibraryAttributes someAttrs (instrumentationLibrary "x" "1")
      libraryAttributes lib `shouldBe` someAttrs

  -- Implementation-specific: parse Cabal/GHC-style package IDs into scope fields
  -- https://opentelemetry.io/docs/specs/otel/glossary/#instrumentation-scope
  describe "parsing" $ do
    let mkLib n v =
          Just
            InstrumentationLibrary
              { libraryName = n
              , libraryVersion = v
              , librarySchemaUrl = ""
              , libraryAttributes = emptyAttributes
              }

    it "handles a simple versioned package" $ do
      parseInstrumentationLibrary "hello-world-1.0.5"
        `shouldBe` mkLib "hello-world" "1.0.5"

    it "handles capital letters and numbers in package names" $ do
      parseInstrumentationLibrary "HUnit2-v3-1"
        `shouldBe` mkLib "HUnit2-v3" "1"

    it "discards trailing content after version" $ do
      parseInstrumentationLibrary "hello-world-1.0.5-inplace"
        `shouldBe` mkLib "hello-world" "1.0.5"

    it "handles GHC-style package-id with hash suffix" $ do
      parseInstrumentationLibrary "base-4.20.2.0-3188"
        `shouldBe` mkLib "base" "4.20.2.0"

    it "handles missing version (bare package name)" $ do
      parseInstrumentationLibrary "hello-world"
        `shouldBe` mkLib "hello-world" ""

    it "handles single-segment version" $ do
      parseInstrumentationLibrary "aeson-2"
        `shouldBe` mkLib "aeson" "2"

    it "handles multi-segment package names" $ do
      parseInstrumentationLibrary "hs-opentelemetry-api-0.4.0.0"
        `shouldBe` mkLib "hs-opentelemetry-api" "0.4.0.0"

    it "handles package name with only digits in segments" $ do
      parseInstrumentationLibrary "utf8-string-1.0.2"
        `shouldBe` mkLib "utf8-string" "1.0.2"

    it "rejects empty string" $ do
      (parseInstrumentationLibrary "" :: Maybe InstrumentationLibrary)
        `shouldBe` Nothing

    it "rejects single character" $ do
      (parseInstrumentationLibrary "a" :: Maybe InstrumentationLibrary)
        `shouldBe` Nothing

    it "rejects name ending with dash" $ do
      (parseInstrumentationLibrary "hello-" :: Maybe InstrumentationLibrary)
        `shouldBe` Nothing

    it "rejects pure version string" $ do
      (parseInstrumentationLibrary "1.2.3" :: Maybe InstrumentationLibrary)
        `shouldBe` Nothing

    it "rejects invalid characters" $ do
      (parseInstrumentationLibrary "hello world" :: Maybe InstrumentationLibrary)
        `shouldBe` Nothing

    it "handles two-character package name without version" $ do
      parseInstrumentationLibrary "ab"
        `shouldBe` mkLib "ab" ""

    it "handles package name with version starting with zero" $ do
      parseInstrumentationLibrary "foo-0.1"
        `shouldBe` mkLib "foo" "0.1"

    it "prefers rightmost valid version split" $ do
      parseInstrumentationLibrary "x-1-2"
        `shouldBe` mkLib "x-1" "2"

    it "handles real-world GHC package names" $ do
      parseInstrumentationLibrary "hs-opentelemetry-sdk-0.1.0.0-inplace"
        `shouldBe` mkLib "hs-opentelemetry-sdk" "0.1.0.0"

    it "handles real-world GHC package with letter-only trailing" $ do
      parseInstrumentationLibrary "text-2.1.3-a641"
        `shouldBe` mkLib "text" "2.1.3"
