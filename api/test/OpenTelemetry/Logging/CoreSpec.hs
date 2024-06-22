{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.Logging.CoreSpec where

import qualified Data.HashMap.Strict as H
import Data.IORef
import qualified OpenTelemetry.Attributes as A
import OpenTelemetry.Internal.Logging.Types
import qualified OpenTelemetry.LogAttributes as LA
import OpenTelemetry.Logging.Core
import OpenTelemetry.Resource
import OpenTelemetry.Resource.OperatingSystem
import Test.Hspec


newtype TestLogRecordProcessor body = TestLogRecordProcessor (LogRecordProcessor body)


instance Show (TestLogRecordProcessor body) where
  show _ = "LogRecordProcessor {..}"


spec :: Spec
spec = describe "Core" $ do
  describe "The global logger provider" $ do
    it "Returns a no-op LoggerProvider when not initialized" $ do
      LoggerProvider {..} <- getGlobalLoggerProvider
      fmap TestLogRecordProcessor loggerProviderProcessors `shouldSatisfy` null
      loggerProviderResource `shouldBe` emptyMaterializedResources
      loggerProviderAttributeLimits `shouldBe` LA.defaultAttributeLimits
    it "Allows a LoggerProvider to be set and returns that with subsequent calls to getGlobalLoggerProvider" $ do
      let lp =
            createLoggerProvider [] $
              LoggerProviderOptions
                { loggerProviderOptionsResource =
                    materializeResources $
                      toResource
                        OperatingSystem
                          { osType = "exampleOs"
                          , osDescription = Nothing
                          , osName = Nothing
                          , osVersion = Nothing
                          }
                , loggerProviderOptionsAttributeLimits =
                    LA.AttributeLimits
                      { attributeCountLimit = Just 50
                      , attributeLengthLimit = Just 50
                      }
                }

      setGlobalLoggerProvider lp

      glp <- getGlobalLoggerProvider
      fmap TestLogRecordProcessor (loggerProviderProcessors glp) `shouldSatisfy` null
      loggerProviderResource glp `shouldBe` loggerProviderResource lp
      loggerProviderAttributeLimits glp `shouldBe` loggerProviderAttributeLimits lp
  describe "addAttribute" $ do
    it "works" $ do
      lp <- getGlobalLoggerProvider
      let l = makeLogger lp InstrumentationLibrary {libraryName = "exampleLibrary", libraryVersion = "", librarySchemaUrl = "", libraryAttributes = A.emptyAttributes}
      lr <- emitLogRecord l $ (emptyLogRecordArguments ()) {attributes = H.fromList [("something", "a thing")]}

      addAttribute lr "anotherThing" ("another thing" :: LA.AnyValue)

      (_, attrs) <- LA.getAttributes <$> logRecordGetAttributes lr
      attrs
        `shouldBe` H.fromList
          [ ("anotherThing", "another thing")
          , ("something", "a thing")
          ]
  describe "addAttributes" $ do
    it "works" $ do
      lp <- getGlobalLoggerProvider
      let l = makeLogger lp InstrumentationLibrary {libraryName = "exampleLibrary", libraryVersion = "", librarySchemaUrl = "", libraryAttributes = A.emptyAttributes}
      lr <- emitLogRecord l $ (emptyLogRecordArguments ()) {attributes = H.fromList [("something", "a thing")]}

      addAttributes lr $
        H.fromList
          [ ("anotherThing", "another thing" :: LA.AnyValue)
          , ("twoThing", "the second another thing")
          ]

      (_, attrs) <- LA.getAttributes <$> logRecordGetAttributes lr
      attrs
        `shouldBe` H.fromList
          [ ("anotherThing", "another thing")
          , ("something", "a thing")
          , ("twoThing", "the second another thing")
          ]
