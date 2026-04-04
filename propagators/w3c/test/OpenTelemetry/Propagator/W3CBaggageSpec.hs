{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.Propagator.W3CBaggageSpec (spec) where

import qualified Data.ByteString.Char8 as C8
import qualified Data.HashMap.Strict as HM
import Data.Maybe (isJust, isNothing)
import qualified Data.Text as T
import OpenTelemetry.Baggage (Element (..), element, empty, insert, mkToken, values)
import OpenTelemetry.Context (insertBaggage, lookupBaggage)
import qualified OpenTelemetry.Context as Ctxt
import OpenTelemetry.Propagator (
  Propagator (..),
  emptyTextMap,
  extract,
  inject,
  textMapFromList,
  textMapLookup,
 )
import OpenTelemetry.Propagator.W3CBaggage (
  decodeBaggage,
  encodeBaggage,
  w3cBaggagePropagator,
 )
import Test.Hspec


spec :: Spec
spec = describe "W3C Baggage propagator" $ do
  it "decodeBaggage decodes valid header" $ do
    let Just k = mkToken "userid"
    case decodeBaggage "userid=alice" of
      Nothing -> expectationFailure "expected decode"
      Just b -> HM.lookup k (values b) `shouldBe` Just (element "alice")

  it "decodeBaggage returns Nothing for invalid input" $ do
    decodeBaggage "" `shouldSatisfy` isNothing
    decodeBaggage "%%%not-baggage%%%" `shouldSatisfy` isNothing

  it "encodeBaggage produces valid header" $ do
    let Just k = mkToken "session"
        b = insert k (element "abc-123") empty
        hdr = encodeBaggage b
    C8.unpack hdr `shouldContain` "session="
    C8.unpack hdr `shouldContain` "abc-123"

  it "encodeBaggage roundtrips with decodeBaggage" $ do
    let Just k1 = mkToken "k1"
        Just k2 = mkToken "k2"
        b0 =
          insert k2 (element "y") $
            insert k1 (element "x") $
              empty
        b1 = decodeBaggage (encodeBaggage b0)
    b1 `shouldBe` Just b0

  it "w3cBaggagePropagator propagatorFields is [\"baggage\"]" $
    propagatorFields w3cBaggagePropagator `shouldBe` ["baggage"]

  it "w3cBaggagePropagator extractor extracts baggage from headers" $ do
    let hs = textMapFromList [("baggage", "userid=nobody")]
    c <- extract w3cBaggagePropagator hs Ctxt.empty
    case lookupBaggage c of
      Nothing -> expectationFailure "expected baggage"
      Just b -> do
        let Just uid = mkToken "userid"
        HM.lookup uid (values b) `shouldBe` Just (element "nobody")

  it "w3cBaggagePropagator extractor ignores missing header" $ do
    c <- extract w3cBaggagePropagator emptyTextMap Ctxt.empty
    lookupBaggage c `shouldBe` Nothing

  it "w3cBaggagePropagator injector adds baggage header" $ do
    let Just k = mkToken "key"
        b = insert k (element "v") empty
        c = insertBaggage b Ctxt.empty
    hs <- inject w3cBaggagePropagator c emptyTextMap
    textMapLookup "baggage" hs `shouldNotBe` Nothing

  it "w3cBaggagePropagator injector no-ops without baggage" $ do
    hs <- inject w3cBaggagePropagator Ctxt.empty emptyTextMap
    textMapLookup "baggage" hs `shouldBe` Nothing

  it "decodeBaggage handles percent-encoded values" $ do
    let Just k = mkToken "key"
    case decodeBaggage "key=value%20with%20spaces" of
      Nothing -> expectationFailure "expected decode of percent-encoded value"
      Just b -> do
        case HM.lookup k (values b) of
          Nothing -> expectationFailure "expected key in baggage"
          Just el ->
            value el `shouldSatisfy` (not . T.null)

  it "decodeBaggage handles multiple entries" $ do
    let Just k1 = mkToken "k1"
        Just k2 = mkToken "k2"
    case decodeBaggage "k1=v1,k2=v2" of
      Nothing -> expectationFailure "expected decode of multi-entry"
      Just b -> do
        HM.lookup k1 (values b) `shouldSatisfy` isJust
        HM.lookup k2 (values b) `shouldSatisfy` isJust

  it "decodeBaggage handles entry with metadata properties" $ do
    let Just k = mkToken "key"
    case decodeBaggage "key=value;property1=p1" of
      Nothing -> expectationFailure "expected decode with properties"
      Just b -> HM.lookup k (values b) `shouldSatisfy` isJust

  it "encodeBaggage handles special characters in values" $ do
    let Just k = mkToken "key"
        b = insert k (element "val=ue") empty
        hdr = encodeBaggage b
    C8.unpack hdr `shouldContain` "key="
