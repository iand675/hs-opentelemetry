{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.Propagator.W3CTraceContextSpec (spec) where

import Data.Attoparsec.ByteString (parseOnly)
import Data.ByteString (ByteString)
import qualified Data.ByteString.Char8 as C8
import Data.Either (isLeft)
import qualified Data.Text as T
import OpenTelemetry.Propagator.W3CTraceContext
import OpenTelemetry.Trace.TraceState (Key (..), Value (..), empty, fromList, insert, toList)
import Test.Hspec


spec :: Spec
spec = describe "W3C TraceContext TraceState" $ do
  describe "tracestateParser" $ do
    it "parses empty tracestate" $ do
      parseOnly tracestateParser "" `shouldBe` Right empty

    it "parses single key=value pair" $ do
      let result = parseOnly tracestateParser "vendor1=value1"
      result `shouldBe` Right (insert (Key "vendor1") (Value "value1") empty)

    it "parses multiple key=value pairs" $ do
      let result = parseOnly tracestateParser "vendor1=value1,vendor2=value2"
      case result of
        Right ts -> do
          let pairs = toList ts
          pairs `shouldContain` [(Key "vendor1", Value "value1")]
          pairs `shouldContain` [(Key "vendor2", Value "value2")]
        Left err -> expectationFailure $ "Parse failed: " ++ err

    it "parses key=value pairs with spaces" $ do
      let result = parseOnly tracestateParser " vendor1=value1 , vendor2=value2 "
      case result of
        Right ts -> do
          let pairs = toList ts
          pairs `shouldContain` [(Key "vendor1", Value "value1")]
          pairs `shouldContain` [(Key "vendor2", Value "value2")]
        Left err -> expectationFailure $ "Parse failed: " ++ err

    it "handles multi-tenant keys" $ do
      let result = parseOnly tracestateParser "tenant@vendor=value1"
      result `shouldBe` Right (insert (Key "tenant@vendor") (Value "value1") empty)

    it "handles special characters in keys" $ do
      let result = parseOnly tracestateParser "vendor-1_2*3/4@tenant=value1"
      result `shouldBe` Right (insert (Key "vendor-1_2*3/4@tenant") (Value "value1") empty)

    it "handles special characters in values" $ do
      let result = parseOnly tracestateParser "vendor1=value-with_special*chars/and@symbols"
      result `shouldBe` Right (insert (Key "vendor1") (Value "value-with_special*chars/and@symbols") empty)

    it "limits to 32 entries" $ do
      let pairs = [C8.pack $ "key" ++ show i ++ "=value" ++ show i | i <- [1 .. 40]]
          input = C8.intercalate "," pairs
          result = parseOnly tracestateParser input
      case result of
        Right ts -> length (toList ts) `shouldBe` 32
        Left err -> expectationFailure $ "Parse failed: " ++ err

    it "rejects invalid key starting with uppercase" $ do
      let result = parseOnly tracestateParser "VENDOR=value1"
      result `shouldSatisfy` isLeft

    it "rejects invalid key with invalid characters" $ do
      let result = parseOnly tracestateParser "vendor$=value1"
      result `shouldSatisfy` isLeft

    it "rejects keys that are too long" $ do
      let longKey = T.replicate 257 "a"
          input = C8.pack $ T.unpack longKey ++ "=value1"
          result = parseOnly tracestateParser input
      result `shouldSatisfy` isLeft

    it "rejects values that are too long" $ do
      let longValue = T.replicate 257 "a"
          input = C8.pack $ "vendor1=" ++ T.unpack longValue
          result = parseOnly tracestateParser input
      result `shouldSatisfy` isLeft

    it "rejects invalid value with comma" $ do
      let result = parseOnly tracestateParser "vendor1=value,with,comma"
      result `shouldSatisfy` isLeft

    it "rejects invalid value with equals" $ do
      let result = parseOnly tracestateParser "vendor1=value=with=equals"
      result `shouldSatisfy` isLeft

  describe "encodeTraceState" $ do
    it "encodes empty tracestate" $ do
      encodeTraceState empty `shouldBe` ""

    it "encodes single key=value pair" $ do
      let ts = insert (Key "vendor1") (Value "value1") empty
      encodeTraceState ts `shouldBe` "vendor1=value1"

    it "encodes multiple key=value pairs" $ do
      let ts = fromList [(Key "vendor1", Value "value1"), (Key "vendor2", Value "value2")]
      let encoded = encodeTraceState ts
      -- Order might vary, so check both possibilities
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
          ts = buildTS 1 empty
          encoded = encodeTraceState ts
          entryCount = length $ filter (== ',') $ C8.unpack encoded
      entryCount `shouldBe` 31 -- 32 entries = 31 commas
    it "handles special characters in encoding" $ do
      let ts = insert (Key "vendor-1_2*3/4@tenant") (Value "value-with_special*chars/and@symbols") empty
      encodeTraceState ts `shouldBe` "vendor-1_2*3/4@tenant=value-with_special*chars/and@symbols"

  describe "encodeTraceStateFull" $ do
    it "encodes empty tracestate" $ do
      encodeTraceStateFull empty `shouldBe` ""

    it "encodes single key=value pair" $ do
      let ts = insert (Key "vendor1") (Value "value1") empty
      encodeTraceStateFull ts `shouldBe` "vendor1=value1"

    it "preserves all entries beyond 32 limit" $ do
      let pairs = [(Key $ T.pack $ "key" ++ show i, Value $ T.pack $ "value" ++ show i) | i <- [1 .. 40]]
          ts = fromList pairs
          encoded = encodeTraceStateFull ts
          entryCount = length $ filter (== '=') $ C8.unpack encoded
      entryCount `shouldBe` 40 -- Should preserve all 40 entries
    it "does not filter oversized entries" $ do
      let longValue = T.replicate 200 "x" -- Much longer than 128 char limit
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
          parsed = parseOnly tracestateParser encoded
      case parsed of
        Right ts' -> toList ts' `shouldBe` toList ts
        Left err -> expectationFailure $ "Round-trip failed: " ++ err

    it "round-trips complex valid tracestate" $ do
      let validPairs = [("tenant@vendor", "complex-value_with*chars"), ("simple123", "value")]
          ts = fromList [(Key $ T.pack k, Value $ T.pack v) | (k, v) <- validPairs]
          encoded = encodeTraceState ts
          parsed = parseOnly tracestateParser encoded
      case parsed of
        Right ts' -> toList ts' `shouldBe` toList ts
        Left err -> expectationFailure $ "Round-trip failed: " ++ err
