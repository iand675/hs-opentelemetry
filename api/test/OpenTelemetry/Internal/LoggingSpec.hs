{-# LANGUAGE LambdaCase #-}

module OpenTelemetry.Internal.LoggingSpec (spec) where

import Control.Exception (bracket_)
import Data.IORef
import Data.List (isInfixOf)
import OpenTelemetry.Internal.Logging
import Test.Hspec


spec :: Spec
spec = sequential $
  describe "OpenTelemetry.Internal.Logging" $ do
    -- Implementation-specific: internal log level ordering for filtering
    -- https://opentelemetry.io/docs/specs/otel/error-handling/
    describe "OTelLogLevel" $ do
      it "orders None < Error < Warning < Info < Debug" $ do
        OTelLogNone `shouldSatisfy` (< OTelLogError)
        OTelLogError `shouldSatisfy` (< OTelLogWarning)
        OTelLogWarning `shouldSatisfy` (< OTelLogInfo)
        OTelLogInfo `shouldSatisfy` (< OTelLogDebug)

    -- Error handling §Error handling principles: global error handler
    -- https://opentelemetry.io/docs/specs/otel/error-handling/
    describe "global error handler" $ do
      it "setGlobalErrorHandler and getGlobalErrorHandler roundtrip" $ do
        ref <- newIORef ([] :: [String])
        old <- getGlobalErrorHandler
        let custom msg = modifyIORef ref (msg :)
        bracket_
          (setGlobalErrorHandler custom)
          (setGlobalErrorHandler old)
          $ do
            handler <- getGlobalErrorHandler
            handler "probe"
            msgs <- readIORef ref
            msgs `shouldBe` ["probe"]

      it "otelLogError passes a message containing ERROR and the payload" $ do
        captured <- newIORef Nothing
        old <- getGlobalErrorHandler
        let custom msg = writeIORef captured (Just msg)
        bracket_
          (setGlobalErrorHandler custom)
          (setGlobalErrorHandler old)
          $ do
            otelLogError "test"
            mmsg <- readIORef captured
            mmsg `shouldSatisfy` \case
              Just msg -> "ERROR" `isInfixOf` msg && "test" `isInfixOf` msg
              Nothing -> False

      it "otelLogWarning passes a message containing WARN and the payload" $ do
        captured <- newIORef Nothing
        old <- getGlobalErrorHandler
        let custom msg = writeIORef captured (Just msg)
        bracket_
          (setGlobalErrorHandler custom)
          (setGlobalErrorHandler old)
          $ do
            otelLogWarning "notice"
            mmsg <- readIORef captured
            mmsg `shouldSatisfy` \case
              Just msg -> "WARN" `isInfixOf` msg && "notice" `isInfixOf` msg
              Nothing -> False

      it "invokes the handler only when getOTelLogLevel reaches each minimum" $ do
        lvl <- getOTelLogLevel
        called <- newIORef False
        old <- getGlobalErrorHandler
        let mark _ = writeIORef called True
        let reset = writeIORef called False
        bracket_
          (setGlobalErrorHandler mark)
          (setGlobalErrorHandler old)
          $ do
            reset
            otelLogDebug "x"
            readIORef called >>= (`shouldBe` (lvl >= OTelLogDebug))
            reset
            otelLogInfo "x"
            readIORef called >>= (`shouldBe` (lvl >= OTelLogInfo))
            reset
            otelLogError "x"
            readIORef called >>= (`shouldBe` (lvl >= OTelLogError))
