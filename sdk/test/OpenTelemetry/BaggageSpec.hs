{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.BaggageSpec where

import qualified Data.HashMap.Strict as HM
import Data.Maybe (isJust)
import qualified Data.Text as T
import OpenTelemetry.Baggage (Element (..), element, insert, mkToken, values)
import qualified OpenTelemetry.Baggage as Baggage
import OpenTelemetry.Context (empty)
import qualified OpenTelemetry.Context as Ctxt
import OpenTelemetry.Propagator (Propagator (..), emptyTextMap, inject, textMapLookup)
import OpenTelemetry.Propagator.W3CBaggage (w3cBaggagePropagator)
import Test.Hspec


spec :: Spec
spec = describe "Baggage" $ do
  -- Baggage API §Baggage Operations
  -- https://opentelemetry.io/docs/specs/otel/baggage/api/#operations
  specify "Basic support" $ do
    let Just k1 = mkToken "key1"
        Just k2 = mkToken "key2"
        b =
          insert k2 (element "two") $
            insert k1 (element "one") $
              Baggage.empty
    HM.lookup k1 (values b) `shouldBe` Just (element "one")
    HM.lookup k2 (values b) `shouldBe` Just (element "two")

  -- Baggage API §Propagating baggage (W3C Baggage header name)
  -- https://opentelemetry.io/docs/specs/otel/baggage/api/#propagating-baggage
  specify "User official header name `baggage`" $ do
    propagatorFields w3cBaggagePropagator `shouldBe` ["baggage"]
    let Just k = mkToken "userid"
        baggage = insert k (element "alice") Baggage.empty
        ctxt = Ctxt.insertBaggage baggage Ctxt.empty
    headers <- inject w3cBaggagePropagator ctxt emptyTextMap
    textMapLookup "baggage" headers `shouldSatisfy` isJust
    case textMapLookup "baggage" headers of
      Nothing -> expectationFailure "missing baggage header"
      Just v -> T.unpack v `shouldContain` "userid=alice"
