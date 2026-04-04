{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.ContextSpec where

import Control.Concurrent
import Control.Monad
import Data.Maybe
import qualified OpenTelemetry.Baggage as Baggage
import OpenTelemetry.Context (
  Context,
  Key,
  empty,
  insert,
  insertBaggage,
  lookup,
  lookupBaggage,
  lookupSpan,
  newKey,
 )
import OpenTelemetry.Context.ThreadLocal
import OpenTelemetry.Propagator (
  Propagator (..),
  emptyTextMap,
  extract,
  getGlobalTextMapPropagator,
  inject,
  textMapFromList,
  textMapLookup,
 )
import OpenTelemetry.Propagator.B3 (b3TraceContextPropagator)
import OpenTelemetry.Propagator.W3CBaggage (w3cBaggagePropagator)
import OpenTelemetry.Propagator.W3CTraceContext (w3cTraceContextPropagator)
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

  describe "Thread-local advanced API" $ do
    specify "adjustContext modifies stored context" $ do
      k <- newKey "adj"
      attachContext empty
      adjustContext (insert k ("ok" :: String))
      mctxt <- lookupContext
      (mctxt >>= lookup k) `shouldBe` Just "ok"

    specify "attachContextOnThread and lookupContextOnThread roundtrip" $ do
      started <- newEmptyMVar
      mainDone <- newEmptyMVar
      _childTid <-
        forkIO $ do
          tid <- myThreadId
          putMVar started tid
          takeMVar mainDone
      k <- newKey "remote"
      childTid <- takeMVar started
      attachContextOnThread childTid (insert k True empty)
      mc <- lookupContextOnThread childTid
      (mc >>= lookup k) `shouldBe` Just True
      putMVar mainDone ()

    specify "detachContextFromThread removes context" $ do
      started <- newEmptyMVar
      mainDone <- newEmptyMVar
      _childTid <-
        forkIO $ do
          tid <- myThreadId
          putMVar started tid
          takeMVar mainDone
      k <- newKey "detach"
      childTid <- takeMVar started
      attachContextOnThread childTid (insert k True empty)
      _ <- detachContextFromThread childTid
      mc <- lookupContextOnThread childTid
      isNothing mc `shouldBe` True
      putMVar mainDone ()

    specify "adjustContextOnThread updates remote thread context" $ do
      started <- newEmptyMVar
      mainDone <- newEmptyMVar
      _childTid <-
        forkIO $ do
          tid <- myThreadId
          putMVar started tid
          takeMVar mainDone
      k <- newKey "adj-remote"
      childTid <- takeMVar started
      attachContextOnThread childTid empty
      adjustContextOnThread childTid (insert k (7 :: Int))
      mc <- lookupContextOnThread childTid
      (mc >>= lookup k) `shouldBe` Just 7
      putMVar mainDone ()

  specify "Composite Propagator" $ do
    let composed = w3cTraceContextPropagator <> w3cBaggagePropagator
    propagatorFields composed `shouldBe` ["traceparent", "tracestate", "baggage"]
    let Propagator {extractor = ex, injector = inj} = composed
    c <- ex emptyTextMap empty
    isNothing (lookupSpan c) `shouldBe` True
    isNothing (lookupBaggage c) `shouldBe` True
    hs <- inj c emptyTextMap
    hs `shouldBe` emptyTextMap

  specify "Global Propagator" $ do
    p <- getGlobalTextMapPropagator
    propagatorFields p `shouldNotBe` []
    propagatorFields p `shouldContain` ["traceparent"]

  specify "TraceContext Propagator" $
    propagatorFields w3cTraceContextPropagator `shouldBe` ["traceparent", "tracestate"]

  specify "B3 Propagator" $
    propagatorFields b3TraceContextPropagator `shouldBe` ["b3"]

  specify "Jaeger Propagator" $
    pendingWith "No Jaeger propagator implementation in this repository."

  describe "TextMap Propagator" $ do
    specify "Fields" $
      propagatorFields w3cBaggagePropagator `shouldBe` ["baggage"]

    specify "Setter argument" $ do
      let Just tok = Baggage.mkToken "uid"
          baggage = Baggage.insert tok (Baggage.element "x") Baggage.empty
          ctxt = insertBaggage baggage empty
      hs <- inject w3cBaggagePropagator ctxt emptyTextMap
      textMapLookup "baggage" hs `shouldNotBe` Nothing

    specify "Getter argument" $ do
      let hs = textMapFromList [("baggage", "uid=alpha")]
      ctxt' <- extract w3cBaggagePropagator hs empty
      lookupBaggage ctxt' `shouldNotBe` Nothing

    specify "Getter argument returning keys" $ do
      let hs = textMapFromList [("baggage", "a=1")]
      ctxt' <- extract w3cBaggagePropagator hs empty
      case lookupBaggage ctxt' of
        Nothing -> expectationFailure "expected baggage in context"
        Just b -> Baggage.values b `shouldNotBe` mempty
