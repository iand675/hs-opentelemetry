{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.Propagator.W3CTraceContextSpec (spec) where

import Data.ByteString (ByteString)
import qualified Data.ByteString.Char8 as C8
import qualified Data.Text as T
import OpenTelemetry.Propagator.W3CTraceContext
import OpenTelemetry.Trace.TraceState (Key (..), Value (..), empty, fromList, insert, toList)
import Test.Hspec


spec :: Spec
spec = describe "W3C TraceContext TraceState" $ do
  describe "parseTraceState" $ do
    it "parses empty tracestate" $ do
      parseTraceState "" `shouldBe` empty

    it "parses single key=value pair" $ do
      parseTraceState "vendor1=value1" `shouldBe` insert (Key "vendor1") (Value "value1") empty

    it "parses multiple key=value pairs" $ do
      let ts = parseTraceState "vendor1=value1,vendor2=value2"
          pairs = toList ts
      pairs `shouldContain` [(Key "vendor1", Value "value1")]
      pairs `shouldContain` [(Key "vendor2", Value "value2")]

    it "parses key=value pairs with spaces" $ do
      let ts = parseTraceState " vendor1=value1 , vendor2=value2 "
          pairs = toList ts
      pairs `shouldContain` [(Key "vendor1", Value "value1")]
      pairs `shouldContain` [(Key "vendor2", Value "value2")]

    it "handles multi-tenant keys" $ do
      parseTraceState "tenant@vendor=value1"
        `shouldBe` insert (Key "tenant@vendor") (Value "value1") empty

    it "handles special characters in keys" $ do
      parseTraceState "vendor-1_2*3/4@tenant=value1"
        `shouldBe` insert (Key "vendor-1_2*3/4@tenant") (Value "value1") empty

    it "handles special characters in values" $ do
      parseTraceState "vendor1=value-with_special*chars/and@symbols"
        `shouldBe` insert (Key "vendor1") (Value "value-with_special*chars/and@symbols") empty

    it "limits to 32 entries" $ do
      let pairs = [C8.pack $ "key" ++ show i ++ "=value" ++ show i | i <- [1 :: Int .. 40]]
          input = C8.intercalate "," pairs
          ts = parseTraceState input
      length (toList ts) `shouldBe` 32

    it "skips invalid key starting with uppercase" $ do
      parseTraceState "VENDOR=value1" `shouldBe` empty

    it "skips invalid key with invalid characters" $ do
      parseTraceState "vendor$=value1" `shouldBe` empty

    it "skips keys that are too long" $ do
      let longKey = T.replicate 257 "a"
          input = C8.pack $ T.unpack longKey ++ "=value1"
      parseTraceState input `shouldBe` empty

    it "skips values that are too long" $ do
      let longValue = T.replicate 257 "a"
          input = C8.pack $ "vendor1=" ++ T.unpack longValue
      parseTraceState input `shouldBe` empty

    it "splits at comma in value (comma delimits entries)" $ do
      let ts = parseTraceState "vendor1=value,with,comma"
          pairs = toList ts
      pairs `shouldContain` [(Key "vendor1", Value "value")]

    it "truncates value at equals sign" $ do
      parseTraceState "vendor1=value=with=equals"
        `shouldBe` insert (Key "vendor1") (Value "value") empty

  describe "encodeTraceState" $ do
    it "encodes empty tracestate" $ do
      encodeTraceState empty `shouldBe` ""

    it "encodes single key=value pair" $ do
      let ts = insert (Key "vendor1") (Value "value1") empty
      encodeTraceState ts `shouldBe` "vendor1=value1"

    it "encodes multiple key=value pairs" $ do
      let ts = fromList [(Key "vendor1", Value "value1"), (Key "vendor2", Value "value2")]
      let encoded = encodeTraceState ts
      encoded `shouldSatisfy` \s ->
        s == "vendor1=value1,vendor2=value2"
          || s == "vendor2=value2,vendor1=value1"

    it "limits to 32 entries when encoding" $ do
      let buildTS n acc
            | n > 40 = acc
            | otherwise =
                buildTS (n + 1) $
                  insert
                    (Key $ T.pack $ "key" ++ show n)
                    (Value $ T.pack $ "value" ++ show n)
                    acc
          ts = buildTS (1 :: Int) empty
          encoded = encodeTraceState ts
          entryCount = length $ filter (== ',') $ C8.unpack encoded
      entryCount `shouldBe` 31

    it "handles special characters in encoding" $ do
      let ts = insert (Key "vendor-1_2*3/4@tenant") (Value "value-with_special*chars/and@symbols") empty
      encodeTraceState ts `shouldBe` "vendor-1_2*3/4@tenant=value-with_special*chars/and@symbols"

  describe "encodeTraceStateFull" $ do
    it "encodes empty tracestate" $ do
      encodeTraceStateFull empty `shouldBe` ""

    it "encodes single key=value pair" $ do
      let ts = insert (Key "vendor1") (Value "value1") empty
      encodeTraceStateFull ts `shouldBe` "vendor1=value1"

    it "encodes at most 32 entries (W3C list-member limit via fromList)" $ do
      let pairs = [(Key $ T.pack $ "key" ++ show i, Value $ T.pack $ "value" ++ show i) | i <- [1 :: Int .. 40]]
          ts = fromList pairs
          encoded = encodeTraceStateFull ts
          entryCount = length $ filter (== '=') $ C8.unpack encoded
      entryCount `shouldBe` 32

    it "does not filter oversized entries" $ do
      let longValue = T.replicate 200 "x"
          ts = insert (Key "longentry") (Value longValue) empty
          encoded = encodeTraceStateFull ts
      encoded `shouldSatisfy` C8.isInfixOf "longentry="
      C8.length encoded `shouldSatisfy` (> 200)

    it "matches encodeTraceState for small tracestates" $ do
      let ts = fromList [(Key "vendor1", Value "value1"), (Key "vendor2", Value "value2")]
      encodeTraceStateFull ts `shouldBe` encodeTraceState ts

  describe "round-trip property" $ do
    it "round-trips simple valid tracestate" $ do
      let validPairs = [("vendor1", "value1"), ("vendor2", "value2")]
          ts = fromList [(Key $ T.pack k, Value $ T.pack v) | (k, v) <- validPairs]
          encoded = encodeTraceState ts
      toList (parseTraceState encoded) `shouldBe` toList ts

    it "round-trips complex valid tracestate" $ do
      let validPairs = [("tenant@vendor", "complex-value_with*chars"), ("simple123", "value")]
          ts = fromList [(Key $ T.pack k, Value $ T.pack v) | (k, v) <- validPairs]
          encoded = encodeTraceState ts
      toList (parseTraceState encoded) `shouldBe` toList ts
