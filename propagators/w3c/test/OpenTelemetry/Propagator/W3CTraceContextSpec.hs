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
spec =
  -- W3C Trace Context §3.3 tracestate header
  -- https://www.w3.org/TR/trace-context/#tracestate-header
  describe "W3C TraceContext TraceState" $ do
    -- W3C Trace Context §3.3.1 list of key-value pairs
    -- https://www.w3.org/TR/trace-context/#tracestate-list
    describe "parseTraceState" $ do
      -- §3.3.1 empty tracestate
      -- https://www.w3.org/TR/trace-context/#tracestate-list
      it "parses empty tracestate" $ do
        parseTraceState "" `shouldBe` Right empty

      -- §3.3.1 list-member: key=value
      -- https://www.w3.org/TR/trace-context/#tracestate-list
      it "parses single key=value pair" $ do
        let result = parseTraceState "vendor1=value1"
        result `shouldBe` Right (insert (Key "vendor1") (Value "value1") empty)

      -- §3.3.1 comma-separated list-members
      -- https://www.w3.org/TR/trace-context/#tracestate-list
      it "parses multiple key=value pairs" $ do
        let result = parseTraceState "vendor1=value1,vendor2=value2"
        case result of
          Right ts -> do
            let pairs = toList ts
            pairs `shouldContain` [(Key "vendor1", Value "value1")]
            pairs `shouldContain` [(Key "vendor2", Value "value2")]
          Left err -> expectationFailure $ "Parse failed: " ++ err

      -- §3.3.1 optional OWS around list-members
      -- https://www.w3.org/TR/trace-context/#tracestate-list
      it "parses key=value pairs with spaces" $ do
        let result = parseTraceState " vendor1=value1 , vendor2=value2 "
        case result of
          Right ts -> do
            let pairs = toList ts
            pairs `shouldContain` [(Key "vendor1", Value "value1")]
            pairs `shouldContain` [(Key "vendor2", Value "value2")]
          Left err -> expectationFailure $ "Parse failed: " ++ err

      -- §3.3.2.1 multi-tenant-key (tenant-id@system-id)
      -- https://www.w3.org/TR/trace-context/#key
      it "handles multi-tenant keys" $ do
        let result = parseTraceState "tenant@vendor=value1"
        result `shouldBe` Right (insert (Key "tenant@vendor") (Value "value1") empty)

      -- §3.3.2.1 key character classes (simple-key / multi-tenant-key)
      -- https://www.w3.org/TR/trace-context/#key
      it "handles special characters in keys" $ do
        let result = parseTraceState "vendor-1_2*3/4@tenant=value1"
        result `shouldBe` Right (insert (Key "vendor-1_2*3/4@tenant") (Value "value1") empty)

      -- §3.3.2.2 value character set
      -- https://www.w3.org/TR/trace-context/#value
      it "handles special characters in values" $ do
        let result = parseTraceState "vendor1=value-with_special*chars/and@symbols"
        result `shouldBe` Right (insert (Key "vendor1") (Value "value-with_special*chars/and@symbols") empty)

      -- §3.3.3 vendor limits: at most 32 list-members
      -- https://www.w3.org/TR/trace-context/#tracestate-limits
      it "limits to 32 entries" $ do
        let pairs = [C8.pack $ "key" ++ show i ++ "=value" ++ show i | i <- [1 .. 40]]
            input = C8.intercalate "," pairs
            result = parseTraceState input
        case result of
          Right ts -> length (toList ts) `shouldBe` 32
          Left err -> expectationFailure $ "Parse failed: " ++ err

      -- §3.3.2.1 simple-key must start with lcalpha; invalid member skipped (§3.3.1)
      -- https://www.w3.org/TR/trace-context/#key
      it "rejects invalid key starting with uppercase" $ do
        let result = parseTraceState "VENDOR=value1"
        result `shouldBe` Right empty

      -- §3.3.2.1 invalid key characters; member skipped
      -- https://www.w3.org/TR/trace-context/#key
      it "rejects invalid key with invalid characters" $ do
        let result = parseTraceState "vendor$=value1"
        result `shouldBe` Right empty

      -- §3.3.2.1 key length limits (simple-key / tenant-id / system-id)
      -- https://www.w3.org/TR/trace-context/#key
      it "rejects keys that are too long" $ do
        let longKey = T.replicate 257 "a"
            input = C8.pack $ T.unpack longKey ++ "=value1"
            result = parseTraceState input
        result `shouldBe` Right empty

      -- §3.3.2.2 value length limit (0*255 characters)
      -- https://www.w3.org/TR/trace-context/#value
      it "rejects values that are too long" $ do
        let longValue = T.replicate 257 "a"
            input = C8.pack $ "vendor1=" ++ T.unpack longValue
            result = parseTraceState input
        result `shouldBe` Right empty

      -- §3.3.2.2 value must not contain comma; parsing truncates (§3.3.1)
      -- https://www.w3.org/TR/trace-context/#value
      it "rejects invalid value with comma" $ do
        let result = parseTraceState "vendor1=value,with,comma"
        result `shouldBe` Right (insert (Key "vendor1") (Value "value") empty)

      -- §3.3.2.2 value must not contain '='; parsing truncates (§3.3.1)
      -- https://www.w3.org/TR/trace-context/#value
      it "rejects invalid value with equals" $ do
        let result = parseTraceState "vendor1=value=with=equals"
        result `shouldBe` Right (insert (Key "vendor1") (Value "value") empty)

      -- W3C Trace Context §3.3.2.1 Key (https://www.w3.org/TR/trace-context/#key)
      -- simple-key = lcalpha 0*255( lcalpha / DIGIT / "_" / "-" / "*" / "/" )
      it "W3C §3.3.2.1: simple key starting with digit is invalid, member skipped" $ do
        let result = parseTraceState "3vendor=value1"
        result `shouldBe` Right empty

      it "W3C §3.3.2.1: simple key starting with lcalpha is valid" $ do
        let result = parseTraceState "vendor3=value1"
        result `shouldBe` Right (insert (Key "vendor3") (Value "value1") empty)

      -- multi-tenant-key = tenant-id "@" system-id
      -- tenant-id = ( lcalpha / DIGIT ) 0*240(...)
      -- system-id = lcalpha 0*13(...)
      it "W3C §3.3.2.1: multi-tenant key with digit-starting tenant-id is valid" $ do
        let result = parseTraceState "123@vendor=value1"
        result `shouldBe` Right (insert (Key "123@vendor") (Value "value1") empty)

      it "W3C §3.3.2.1: multi-tenant key with digit-starting system-id is invalid" $ do
        let result = parseTraceState "tenant@123=value1"
        result `shouldBe` Right empty

      it "W3C §3.3.2.1: multiple '@' in key is invalid" $ do
        let result = parseTraceState "a@b@c=value1"
        result `shouldBe` Right empty

      it "W3C §3.3.2.1: system-id longer than 14 chars is invalid" $ do
        let result = parseTraceState "tenant@abcdefghijklmno=value1"
        result `shouldBe` Right empty

      it "W3C §3.3.2.1: tenant-id up to 241 chars is valid" $ do
        let tenant = C8.pack (replicate 241 'a')
            input = tenant <> "@v=ok"
            result = parseTraceState input
        case result of
          Right ts -> toList ts `shouldSatisfy` (not . null)
          Left err -> expectationFailure err

      -- §3.3.1: invalid list-members are skipped, valid ones retained
      it "W3C §3.3: invalid member is skipped, valid members retained" $ do
        let result = parseTraceState "good=value,3bad=nope,alsogood=yes"
        case result of
          Right ts -> do
            toList ts `shouldContain` [(Key "good", Value "value")]
            toList ts `shouldContain` [(Key "alsogood", Value "yes")]
            length (toList ts) `shouldBe` 2
          Left err -> expectationFailure err

      it "W3C §3.3: all-invalid members yields empty tracestate" $ do
        parseTraceState "3bad=x,4bad=y" `shouldBe` Right empty

      it "W3C §3.3: leading comma (empty member) is tolerated" $ do
        let result = parseTraceState ",vendor=value"
        case result of
          Right ts -> toList ts `shouldContain` [(Key "vendor", Value "value")]
          Left err -> expectationFailure err

    -- §3.3 tracestate serialization (implementation encodes valid list-members)
    -- https://www.w3.org/TR/trace-context/#tracestate-header
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

      -- §3.3.3 at most 32 list-members
      -- https://www.w3.org/TR/trace-context/#tracestate-limits
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

      -- §3.3.2 key=value encoding
      -- https://www.w3.org/TR/trace-context/#tracestate-list
      it "handles special characters in encoding" $ do
        let ts = insert (Key "vendor-1_2*3/4@tenant") (Value "value-with_special*chars/and@symbols") empty
        encodeTraceState ts `shouldBe` "vendor-1_2*3/4@tenant=value-with_special*chars/and@symbols"

    -- Full encoding without filtering (contrast with size-limited encode)
    -- https://www.w3.org/TR/trace-context/#tracestate-header
    describe "encodeTraceStateFull" $ do
      it "encodes empty tracestate" $ do
        encodeTraceStateFull empty `shouldBe` ""

      it "encodes single key=value pair" $ do
        let ts = insert (Key "vendor1") (Value "value1") empty
        encodeTraceStateFull ts `shouldBe` "vendor1=value1"

      -- §3.3.3 at most 32 list-members
      -- https://www.w3.org/TR/trace-context/#tracestate-limits
      it "fromList caps at 32 entries per W3C spec" $ do
        let pairs = [(Key $ T.pack $ "key" ++ show i, Value $ T.pack $ "value" ++ show i) | i <- [1 .. 40 :: Int]]
            ts = fromList pairs
            encoded = encodeTraceStateFull ts
            entryCount = length $ filter (== '=') $ C8.unpack encoded
        entryCount `shouldBe` 32

      it "does not filter oversized entries" $ do
        let longValue = T.replicate 200 "x" -- Much longer than 128 char limit
            ts = insert (Key "longentry") (Value longValue) empty
            encoded = encodeTraceStateFull ts
        encoded `shouldSatisfy` C8.isInfixOf "longentry="
        C8.length encoded `shouldSatisfy` (> 200)

      it "matches encodeTraceState for small tracestates" $ do
        let ts = fromList [(Key "vendor1", Value "value1"), (Key "vendor2", Value "value2")]
        encodeTraceStateFull ts `shouldBe` encodeTraceState ts

    -- Parse/encode consistency for valid tracestate (§3.3)
    -- https://www.w3.org/TR/trace-context/#tracestate-header
    describe "round-trip property" $ do
      it "round-trips simple valid tracestate" $ do
        let validPairs = [("vendor1", "value1"), ("vendor2", "value2")]
            ts = fromList [(Key $ T.pack k, Value $ T.pack v) | (k, v) <- validPairs]
            encoded = encodeTraceState ts
            parsed = parseTraceState encoded
        case parsed of
          Right ts' -> toList ts' `shouldBe` toList ts
          Left err -> expectationFailure $ "Round-trip failed: " ++ err

      it "round-trips complex valid tracestate" $ do
        let validPairs = [("tenant@vendor", "complex-value_with*chars"), ("simple123", "value")]
            ts = fromList [(Key $ T.pack k, Value $ T.pack v) | (k, v) <- validPairs]
            encoded = encodeTraceState ts
            parsed = parseTraceState encoded
        case parsed of
          Right ts' -> toList ts' `shouldBe` toList ts
          Left err -> expectationFailure $ "Round-trip failed: " ++ err
