{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.ContextSpec where

import Control.Concurrent
import Control.Monad
import Data.Maybe
import qualified OpenTelemetry.Baggage as Baggage
import OpenTelemetry.Context (
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
  -- Context API: immutable key/value context
  -- https://opentelemetry.io/docs/specs/otel/context/
  describe "Create Context Key" $ do
    -- Context API §Create a key: unique keys for Context values
    -- https://opentelemetry.io/docs/specs/otel/context/#create-a-key
    it "works" $ do
      void (newKey "k" :: IO (Key ()))
  describe "Set value for Context" $ do
    -- Context API §Get value / Set value
    -- https://opentelemetry.io/docs/specs/otel/context/#set-value
    it "works" $ do
      k <- newKey "k"
      let ctxt = insert k (12 :: Int) empty
      lookup k ctxt `shouldBe` Just 12
  describe "Get value from Context" $ do
    -- Context API §Get value
    -- https://opentelemetry.io/docs/specs/otel/context/#get-value
    it "works" $ do
      k1 <- newKey "k.1"
      k2 <- newKey "k.2"
      let ctxt = insert k2 (Just False) $ insert k1 (12 :: Int) empty
      lookup k1 ctxt `shouldBe` Just 12
      lookup k2 ctxt `shouldBe` (Just (Just False))
  describe "Attach Context" $ do
    -- Implementation-specific: thread-local attach maps to runtime propagation of "current" Context
    -- https://opentelemetry.io/docs/specs/otel/context/#optional-global-operations
    specify "ThreadLocal works" $ do
      k <- newKey "thingum"
      tok <- attachContext $ insert k True empty
      mctxt <- lookupContext
      (mctxt >>= lookup k) `shouldBe` Just True
      detachContext tok
  describe "Detach Context" $ do
    -- Implementation-specific: thread-local detach restores previous Context
    -- https://opentelemetry.io/docs/specs/otel/context/#optional-global-operations
    specify "ThreadLocal works" $ do
      k <- newKey "thingum"
      tok <- attachContext $ insert k True empty
      detachContext tok
      ctx <- getContext
      lookup k ctx `shouldBe` (Nothing :: Maybe Bool)

  -- Implementation-specific: nested attach/detach stack (thread-local)
  -- https://opentelemetry.io/docs/specs/otel/context/#optional-global-operations
  specify "Get current Context" $ do
    k1 <- newKey "k.1"
    k2 <- newKey "k.2"
    let ctxt1 = insert k1 (12 :: Int) empty
    tok1 <- attachContext ctxt1
    let ctxt2 = insert k2 (13 :: Int) empty
    tok2 <- attachContext ctxt2
    (Just ctxt) <- lookupContext
    lookup k1 ctxt `shouldBe` Nothing
    lookup k2 ctxt `shouldBe` Just 13
    detachContext tok2
    detachContext tok1

  describe "Thread-local advanced API" $ do
    -- Implementation-specific: Haskell thread-local Context helpers (not OTel API surface)
    specify "adjustContext modifies stored context" $ do
      k <- newKey "adj"
      tok <- attachContext empty
      adjustContext (insert k ("ok" :: String))
      mctxt <- lookupContext
      (mctxt >>= lookup k) `shouldBe` Just "ok"
      detachContext tok

    -- Implementation-specific: attach Context on another OS thread
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
      tok <- attachContextOnThread childTid (insert k True empty)
      mc <- lookupContextOnThread childTid
      (mc >>= lookup k) `shouldBe` Just True
      detachContextFromThread childTid tok
      putMVar mainDone ()

    -- Implementation-specific: detach restores prior Context on remote thread
    specify "detachContextFromThread restores previous context" $ do
      started <- newEmptyMVar
      mainDone <- newEmptyMVar
      _childTid <-
        forkIO $ do
          tid <- myThreadId
          putMVar started tid
          takeMVar mainDone
      k <- newKey "detach"
      childTid <- takeMVar started
      tok <- attachContextOnThread childTid (insert k True empty)
      detachContextFromThread childTid tok
      mc <- lookupContextOnThread childTid
      (mc >>= lookup k) `shouldBe` (Nothing :: Maybe Bool)
      putMVar mainDone ()

    -- Implementation-specific: mutate current Context on remote thread
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
      tok <- attachContextOnThread childTid empty
      adjustContextOnThread childTid (insert k (7 :: Int))
      mc <- lookupContextOnThread childTid
      (mc >>= lookup k) `shouldBe` Just 7
      detachContextFromThread childTid tok
      putMVar mainDone ()

  -- Propagators API §Composite Propagator
  -- https://opentelemetry.io/docs/specs/otel/context/api-propagators/#composite-propagator
  specify "Composite Propagator" $ do
    let composed = w3cTraceContextPropagator <> w3cBaggagePropagator
    propagatorFields composed `shouldBe` ["traceparent", "tracestate", "baggage"]
    let Propagator {extractor = ex, injector = inj} = composed
    c <- ex emptyTextMap empty
    isNothing (lookupSpan c) `shouldBe` True
    isNothing (lookupBaggage c) `shouldBe` True
    hs <- inj c emptyTextMap
    hs `shouldBe` emptyTextMap

  -- Propagators API: global TextMapPropagator (SDK/runtime wiring)
  -- https://opentelemetry.io/docs/specs/otel/context/api-propagators/#global-propagators
  specify "Global Propagator" $ do
    p <- getGlobalTextMapPropagator
    propagatorFields p `shouldNotBe` []
    propagatorFields p `shouldContain` ["traceparent"]

  -- W3C Trace Context propagation (fields: traceparent, tracestate)
  -- https://opentelemetry.io/docs/specs/otel/context/api-propagators/#trace-context-propagator
  specify "TraceContext Propagator" $
    propagatorFields w3cTraceContextPropagator `shouldBe` ["traceparent", "tracestate"]

  -- B3 propagator (de facto); OTel defines composite/multi-header behavior
  -- https://opentelemetry.io/docs/specs/otel/context/api-propagators/
  specify "B3 Propagator" $
    propagatorFields b3TraceContextPropagator
      `shouldBe` ["b3", "x-b3-traceid", "x-b3-spanid", "x-b3-sampled", "x-b3-flags", "x-b3-parentspanid"]

  -- Implementation gap: Jaeger propagator not provided by this repo
  specify "Jaeger Propagator" $
    pendingWith "No Jaeger propagator implementation in this repository."

  describe "TextMap Propagator" $ do
    -- Baggage API §Propagating baggage: W3C Baggage header
    -- https://opentelemetry.io/docs/specs/otel/baggage/api/#propagating-baggage
    specify "Fields" $
      propagatorFields w3cBaggagePropagator `shouldBe` ["baggage"]

    -- Propagators API §Inject
    -- https://opentelemetry.io/docs/specs/otel/context/api-propagators/#inject
    specify "Setter argument" $ do
      let Just tok = Baggage.mkToken "uid"
          baggage = Baggage.insert tok (Baggage.element "x") Baggage.empty
          ctxt = insertBaggage baggage empty
      hs <- inject w3cBaggagePropagator ctxt emptyTextMap
      textMapLookup "baggage" hs `shouldNotBe` Nothing

    -- Propagators API §Extract
    -- https://opentelemetry.io/docs/specs/otel/context/api-propagators/#extract
    specify "Getter argument" $ do
      let hs = textMapFromList [("baggage", "uid=alpha")]
      ctxt' <- extract w3cBaggagePropagator hs empty
      lookupBaggage ctxt' `shouldNotBe` Nothing

    -- Baggage API: extract yields non-empty baggage in Context
    -- https://opentelemetry.io/docs/specs/otel/baggage/api/
    specify "Getter argument returning keys" $ do
      let hs = textMapFromList [("baggage", "a=1")]
      ctxt' <- extract w3cBaggagePropagator hs empty
      case lookupBaggage ctxt' of
        Nothing -> expectationFailure "expected baggage in context"
        Just b -> Baggage.values b `shouldNotBe` mempty
