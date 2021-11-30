{-# LANGUAGE OverloadedStrings #-}
module OpenTelemetry.ContextSpec where
import Control.Monad
import Data.Maybe
import OpenTelemetry.Context
import OpenTelemetry.Context.ThreadLocal
import Test.Hspec
import Prelude hiding (lookup)

spec :: Spec
spec = describe "Context" $ do
  describe "Create Context Key" $ do
    it "works" $ do
      void (newKey "k" :: IO (Key ()))
  describe "Set value for Context" $ do
    it "works" $ do
      k <- newKey "k"
      let ctxt = insert k (12 :: Int) empty
      lookup k ctxt `shouldBe` Just 12
  describe "Get value from Context" $ do
    it "works" $ do
      k1 <- newKey "k.1"
      k2 <- newKey "k.2"
      let ctxt = insert k2 (Just False) $ insert k1 (12 :: Int) empty
      lookup k1 ctxt `shouldBe` Just 12
      lookup k2 ctxt `shouldBe` (Just (Just False))
  describe "Attach Context" $ do
    specify "ThreadLocal works" $ do
      k <- newKey "thingum"
      attachContext $ insert k True empty
      mctxt <- lookupContext
      (mctxt >>= lookup k) `shouldBe` Just True
  describe "Detach Context" $ do
    specify "ThreadLocal works" $ do
      k <- newKey "thingum"
      attachContext $ insert k True empty
      mctxt <- detachContext
      (mctxt >>= lookup k) `shouldBe` Just True
      mctxt' <- lookupContext
      isNothing mctxt' `shouldBe` True

  specify "Get current Context" $ do
    k1 <- newKey "k.1"
    k2 <- newKey "k.2"
    let ctxt1 = insert k1 (12 :: Int) empty
    attachContext ctxt1
    let ctxt2 = insert k2 (13 :: Int) empty
    attachContext ctxt2
    (Just ctxt) <- lookupContext
    lookup k1 ctxt `shouldBe` Nothing
    lookup k2 ctxt `shouldBe` Just 13

  specify "Composite Propagator" pending
  specify "Global Propagator" pending
  specify "TraceContext Propagator" pending
  specify "B3 Propagator" pending
  specify "Jaeger Propagator" pending
  describe "TextMap Propagator" $ do
    specify "Fields" pending
    specify "Setter argument" pending
    specify "Getter argument" pending
    specify "Getter argument returning keys" pending

