module OpenTelemetry.BaggageSpec where

import qualified Data.ByteString as BS
import qualified Data.ByteString.Char8 as B8
import Data.Either (isLeft, isRight)
import qualified Data.HashMap.Strict as HashMap
import Data.Maybe (fromJust)
import qualified Data.Text as T
import OpenTelemetry.Baggage (
  Element (..),
  InvalidBaggage (..),
  decodeBaggageHeader,
  delete,
  empty,
  encodeBaggageHeader,
  insert,
  insertChecked,
  maxBaggageBytes,
  maxMemberBytes,
  maxMembers,
  mkToken,
  property,
  tokenValue,
  values,
 )
import Test.Hspec


spec :: Spec
spec = describe "Baggage" $ do
  it "decodes simple header" $ do
    let baggage = values <$> decodeBaggageHeader "x-api-key=asdf"
    HashMap.mapKeys tokenValue <$> baggage `shouldBe` Right (HashMap.fromList [("x-api-key", Element {value = "asdf", properties = []})])
  it "decodes percent encoded header" $ do
    let baggage = values <$> decodeBaggageHeader "Authorization=Basic%20asdf"
    HashMap.mapKeys tokenValue <$> baggage `shouldBe` Right (HashMap.fromList [("Authorization", Element {value = "Basic asdf", properties = []})])

  it "encodes and decodes simple baggage (roundtrip)" $ do
    let k = fromJust (mkToken "x-key")
        b0 = insert k (Element {value = "hello", properties = []}) empty
        hdr = encodeBaggageHeader b0
    HashMap.mapKeys tokenValue . values <$> decodeBaggageHeader hdr
      `shouldBe` Right (HashMap.fromList [("x-key", Element {value = "hello", properties = []})])

  it "encodes baggage with multiple entries" $ do
    let k1 = fromJust (mkToken "a")
        k2 = fromJust (mkToken "b")
        b0 =
          insert k1 (Element {value = "1", properties = []}) $
            insert k2 (Element {value = "2", properties = []}) empty
        hdr = encodeBaggageHeader b0
    case HashMap.mapKeys tokenValue . values <$> decodeBaggageHeader hdr of
      Left e -> expectationFailure e
      Right m -> do
        HashMap.lookup "a" m `shouldBe` Just (Element {value = "1", properties = []})
        HashMap.lookup "b" m `shouldBe` Just (Element {value = "2", properties = []})

  it "insert overwrites existing key" $ do
    let k = fromJust (mkToken "k")
        b0 = insert k (Element {value = "first", properties = []}) empty
        b1 = insert k (Element {value = "second", properties = []}) b0
    HashMap.mapKeys tokenValue (values b1)
      `shouldBe` HashMap.fromList [("k", Element {value = "second", properties = []})]

  it "delete removes entry" $ do
    let k = fromJust (mkToken "k")
        b0 = insert k (Element {value = "v", properties = []}) empty
        b1 = delete k b0
    values b1 `shouldBe` HashMap.empty

  it "empty baggage encodes to empty" $ do
    encodeBaggageHeader empty `shouldBe` ""

  it "decodes header with properties" $ do
    let expected =
          HashMap.fromList
            [
              ( "key"
              , Element
                  { value = "value"
                  , properties =
                      [ property (fromJust (mkToken "prop1")) Nothing
                      , property (fromJust (mkToken "prop2")) (Just "val2")
                      ]
                  }
              )
            ]
    HashMap.mapKeys tokenValue . values <$> decodeBaggageHeader "key=value;prop1;prop2=val2"
      `shouldBe` Right expected

  it "decodes header with multiple entries" $ do
    let expected =
          HashMap.fromList
            [ ("k1", Element {value = "v1", properties = []})
            , ("k2", Element {value = "v2", properties = []})
            ]
    HashMap.mapKeys tokenValue . values <$> decodeBaggageHeader "k1=v1,k2=v2"
      `shouldBe` Right expected

  it "rejects empty input" $ do
    decodeBaggageHeader "" `shouldSatisfy` isLeft

  describe "W3C Baggage size limits" $ do
    it "decode rejects header exceeding 8192 bytes" $ do
      let longVal = B8.replicate (maxBaggageBytes + 1 - 2) 'x'
          hdr = "k=" <> longVal
      decodeBaggageHeader hdr `shouldSatisfy` isLeft

    it "decode accepts header at exactly 8192 bytes" $ do
      let valLen = maxBaggageBytes - 2
          longVal = B8.replicate valLen 'x'
          hdr = "k=" <> longVal
      BS.length hdr `shouldBe` maxBaggageBytes
      decodeBaggageHeader hdr `shouldSatisfy` isRight

    it "decode rejects more than 180 members" $ do
      let mkEntry i = B8.pack ("k" ++ show (i :: Int) ++ "=v")
          entries = map mkEntry [1 .. maxMembers + 1]
          hdr = BS.intercalate "," entries
      decodeBaggageHeader hdr `shouldSatisfy` isLeft

    it "decode accepts exactly 180 members" $ do
      let mkEntry i = B8.pack ("k" ++ show (i :: Int) ++ "=v")
          entries = map mkEntry [1 .. maxMembers]
          hdr = BS.intercalate "," entries
      case decodeBaggageHeader hdr of
        Left err -> expectationFailure err
        Right b -> HashMap.size (values b) `shouldBe` maxMembers

    it "encode skips member exceeding 4096 bytes" $ do
      let shortKey = fromJust (mkToken "short")
          longKey = fromJust (mkToken "long")
          longVal = T.replicate maxMemberBytes "x"
          b =
            insert shortKey (Element "ok" []) $
              insert longKey (Element longVal []) empty
          hdr = encodeBaggageHeader b
      case decodeBaggageHeader hdr of
        Left err -> expectationFailure err
        Right decoded -> do
          let m = HashMap.mapKeys tokenValue (values decoded)
          HashMap.lookup "short" m `shouldBe` Just (Element "ok" [])
          HashMap.member "long" m `shouldBe` False

    it "encode respects 8192 byte total limit" $ do
      let bigBaggage = foldr addEntry empty [1 :: Int .. 200]
          addEntry i b = case mkToken (T.pack ("key" ++ show i)) of
            Nothing -> b
            Just k -> insert k (Element (T.replicate 50 "x") []) b
      BS.length (encodeBaggageHeader bigBaggage) `shouldSatisfy` (<= maxBaggageBytes)

  describe "insertChecked" $ do
    it "accepts normal entries" $ do
      let k = fromJust (mkToken "key1")
      insertChecked k (Element "val" []) empty `shouldSatisfy` isRight

    it "rejects when exceeding 180 members" $ do
      let base = foldr addEntry empty [1 :: Int .. maxMembers]
          addEntry i b = case mkToken (T.pack ("k" ++ show i)) of
            Nothing -> b
            Just k -> insert k (Element "v" []) b
          extra = fromJust (mkToken "overflow")
      insertChecked extra (Element "v" []) base `shouldBe` Left TooManyListMembers

    it "rejects when total serialized size exceeds 8192 bytes" $ do
      let base = foldr addEntry empty [1 :: Int .. 80]
          addEntry i b = case mkToken (T.pack ("k" ++ show i)) of
            Nothing -> b
            Just k -> insert k (Element (T.replicate 100 "x") []) b
          extra = fromJust (mkToken "overflow")
      insertChecked extra (Element (T.replicate 100 "x") []) base `shouldBe` Left BaggageTooLong

    it "allows replacing an existing key without exceeding limits" $ do
      let k = fromJust (mkToken "key")
          b0 = insert k (Element "old" []) empty
      insertChecked k (Element "new" []) b0 `shouldSatisfy` isRight
