module OpenTelemetry.BaggageSpec where

import qualified Data.HashMap.Strict as HashMap
import OpenTelemetry.Baggage
import Test.Hspec


spec :: Spec
spec = describe "Baggage" $ do
  it "decodes simple header" $ do
    let baggage = values <$> decodeBaggageHeader "x-api-key=asdf"
    HashMap.mapKeys tokenValue <$> baggage `shouldBe` Right (HashMap.fromList [("x-api-key", Element {value = "asdf", properties = []})])
  it "decodes percent encoded header" $ do
    let baggage = values <$> decodeBaggageHeader "Authorization=Basic%20asdf"
    HashMap.mapKeys tokenValue <$> baggage `shouldBe` Right (HashMap.fromList [("Authorization", Element {value = "Basic asdf", properties = []})])
