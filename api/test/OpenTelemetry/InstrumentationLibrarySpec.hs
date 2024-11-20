module OpenTelemetry.InstrumentationLibrarySpec where

import OpenTelemetry.Attributes
import OpenTelemetry.Internal.Common.Types
import Test.Hspec


spec :: Spec
spec = describe "InstrumentationLibrary" $ do
  describe "parsing" $ do
    it "handles a simple example basic example" $ do
      parseInstrumentationLibrary "hello-world-1.0.5"
        `shouldBe` Just (InstrumentationLibrary {libraryName = "hello-world", libraryVersion = "1.0.5", librarySchemaUrl = "", libraryAttributes = emptyAttributes})

    it "handles capital letters and numbers in package names" $ do
      parseInstrumentationLibrary "HUnit2-v3-1"
        `shouldBe` Just (InstrumentationLibrary {libraryName = "HUnit2-v3", libraryVersion = "1", librarySchemaUrl = "", libraryAttributes = emptyAttributes})

    it "discards trailing content" $ do
      parseInstrumentationLibrary "hello-world-1.0.5-inplace"
        `shouldBe` Just (InstrumentationLibrary {libraryName = "hello-world", libraryVersion = "1.0.5", librarySchemaUrl = "", libraryAttributes = emptyAttributes})

    it "handles missing version" $ do
      parseInstrumentationLibrary "hello-world"
        `shouldBe` Just (InstrumentationLibrary {libraryName = "hello-world", libraryVersion = "", librarySchemaUrl = "", libraryAttributes = emptyAttributes})
