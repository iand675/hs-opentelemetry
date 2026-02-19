module OpenTelemetry.BaggageSpec where

import qualified Data.HashMap.Strict as HashMap
import OpenTelemetry.Baggage
import Test.Hspec


spec :: Spec
spec = describe "Baggage" $ do
  describe "decode" $ do
    it "decodes simple header" $ do
      let baggage = values <$> decodeBaggageHeader "x-api-key=asdf"
      HashMap.mapKeys tokenValue <$> baggage `shouldBe` Right (HashMap.fromList [("x-api-key", Element {value = "asdf", properties = []})])

    it "decodes percent encoded header" $ do
      let baggage = values <$> decodeBaggageHeader "Authorization=Basic%20asdf"
      HashMap.mapKeys tokenValue <$> baggage `shouldBe` Right (HashMap.fromList [("Authorization", Element {value = "Basic asdf", properties = []})])

    it "decodes multiple members" $ do
      let baggage = values <$> decodeBaggageHeader "key1=val1,key2=val2"
      fmap (HashMap.size . HashMap.mapKeys tokenValue) baggage `shouldBe` Right 2

    it "decodes with OWS around commas" $ do
      let baggage = values <$> decodeBaggageHeader "key1=val1 , key2=val2"
      fmap (HashMap.size . HashMap.mapKeys tokenValue) baggage `shouldBe` Right 2

    it "decodes properties" $ do
      let result = decodeBaggageHeader "key1=val1;prop1;prop2=pval"
      case result of
        Left err -> expectationFailure err
        Right bag -> do
          let members = HashMap.mapKeys tokenValue $ values bag
          case HashMap.lookup "key1" members of
            Nothing -> expectationFailure "key1 not found"
            Just (Element v props) -> do
              v `shouldBe` "val1"
              length props `shouldBe` 2

    it "rejects empty input" $ do
      decodeBaggageHeader "" `shouldSatisfy` isLeft

    it "decodes empty value" $ do
      let result = decodeBaggageHeader "key1="
      result `shouldSatisfy` isRight

  describe "encode" $ do
    it "encodes simple baggage" $ do
      case mkToken "key1" of
        Nothing -> expectationFailure "bad token"
        Just tok -> do
          let bag = insert tok (element "val1") empty
              encoded = encodeBaggageHeader bag
          encoded `shouldBe` "key1=val1"

  describe "round-trip" $ do
    it "decode . encode preserves simple baggage" $ do
      case mkToken "mykey" of
        Nothing -> expectationFailure "bad token"
        Just tok -> do
          let original = insert tok (element "hello world") empty
              encoded = encodeBaggageHeader original
              decoded = decodeBaggageHeader encoded
          case decoded of
            Left err -> expectationFailure err
            Right bag -> do
              let members = HashMap.mapKeys tokenValue $ values bag
              HashMap.lookup "mykey" members `shouldBe` Just (Element "hello world" [])

  describe "decodeBaggageHeaderP" $ do
    it "is usable via runParser" $ do
      let result = runParser decodeBaggageHeaderP "key1=val1"
      case result of
        Nothing -> expectationFailure "parser failed"
        Just (bag, remaining) -> do
          remaining `shouldBe` ""
          HashMap.size (values bag) `shouldBe` 1

  describe "mkToken" $ do
    it "accepts valid tokens" $ do
      mkToken "hello" `shouldSatisfy` isJust
      mkToken "x-api-key" `shouldSatisfy` isJust

    it "accepts empty string (vacuous truth on character check)" $ do
      mkToken "" `shouldSatisfy` isJust

    it "rejects invalid characters" $ do
      mkToken "hello world" `shouldBe` Nothing
      mkToken "key=val" `shouldBe` Nothing


isLeft :: Either a b -> Bool
isLeft (Left _) = True
isLeft _ = False

isRight :: Either a b -> Bool
isRight (Right _) = True
isRight _ = False

isJust :: Maybe a -> Bool
isJust (Just _) = True
isJust _ = False
