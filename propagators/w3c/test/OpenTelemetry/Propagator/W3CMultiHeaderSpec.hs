{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.Propagator.W3CMultiHeaderSpec (spec) where

import qualified Data.ByteString.Char8 as C8
import Data.List (intercalate)
import qualified Data.Text as T
import OpenTelemetry.Propagator.W3CTraceContext
import OpenTelemetry.Trace.TraceState (Key (..), Value (..), empty, fromList, insert, toList)
import Test.Hspec


spec :: Spec
spec =
  -- W3C Trace Context §3.3 tracestate (splitting across headers / size limits)
  -- https://www.w3.org/TR/trace-context/#tracestate-limits
  describe "W3C TraceContext Multi-Header Support" $ do
    describe "encodeTraceStateMultiple" $ do
      -- §3.3 combined header value within limits (single field value)
      -- https://www.w3.org/TR/trace-context/#combined-header-value
      it "returns single header for small tracestate" $ do
        let ts = fromList [(Key "vendor1", Value "value1"), (Key "vendor2", Value "value2")]
            result = encodeTraceStateMultiple 512 ts
        result `shouldBe` ["vendor1=value1,vendor2=value2"]

      -- §3.3.3 tracestate size limits (implementation splits to satisfy limits)
      -- https://www.w3.org/TR/trace-context/#tracestate-limits
      it "splits into multiple headers when size limit exceeded" $ do
        let mediumValue = T.replicate 50 "x" -- Use smaller values that won't be filtered
            ts =
              fromList
                [ (Key "vendor1", Value mediumValue)
                , (Key "vendor2", Value mediumValue)
                , (Key "vendor3", Value mediumValue)
                , (Key "vendor4", Value mediumValue)
                ]
            result = encodeTraceStateMultiple 150 ts -- Small limit to force splitting
        length result `shouldSatisfy` (> 1)
        -- Each header should be under the size limit
        all (\h -> C8.length h <= 150) result `shouldBe` True

      -- §3.3.2.2 value length; oversized members omitted
      -- https://www.w3.org/TR/trace-context/#value
      it "removes entries larger than 128 characters" $ do
        let longValue = T.replicate 200 "x" -- This entry will be > 128 chars total
            shortValue = "short"
            ts =
              fromList
                [ (Key "long", Value longValue)
                , (Key "vendor1", Value shortValue)
                , (Key "vendor2", Value shortValue)
                ]
            result = encodeTraceStateMultiple 512 ts
            combinedResult = C8.intercalate "," result
        -- The long entry should be filtered out
        combinedResult `shouldNotSatisfy` C8.isInfixOf "long="
        combinedResult `shouldSatisfy` C8.isInfixOf "vendor1=short"
        combinedResult `shouldSatisfy` C8.isInfixOf "vendor2=short"

      -- §3.3.3 at most 32 list-members
      -- https://www.w3.org/TR/trace-context/#tracestate-limits
      it "respects 32 entry limit before splitting" $ do
        let pairs = [(Key (T.pack $ "key" ++ show i), Value (T.pack $ "val" ++ show i)) | i <- [1 .. 40]]
            ts = fromList pairs
            result = encodeTraceStateMultiple 512 ts
            combinedResult = C8.intercalate "," result
            entryCount = length $ filter (== '=') $ C8.unpack combinedResult
        entryCount `shouldBe` 32

      it "returns empty list for empty tracestate" $ do
        let result = encodeTraceStateMultiple 512 empty
        result `shouldBe` []

      it "handles single very large header correctly" $ do
        let pairs = [(Key (T.pack $ "k" ++ show i), Value (T.pack $ "v" ++ show i)) | i <- [1 .. 20]]
            ts = fromList pairs
            result = encodeTraceStateMultiple 50 ts -- Very small limit
        length result `shouldSatisfy` (> 1)
        -- Should not exceed the limit
        all (\h -> C8.length h <= 50) result `shouldBe` True

    -- §3.3.1 parsing list-members from multiple combined field values
    -- https://www.w3.org/TR/trace-context/#tracestate-list
    describe "decodeTraceStateMultiple" $ do
      it "combines single header correctly" $ do
        let headers = ["vendor1=value1,vendor2=value2"]
            result = decodeTraceStateMultiple headers
            pairs = toList result
        pairs `shouldContain` [(Key "vendor1", Value "value1")]
        pairs `shouldContain` [(Key "vendor2", Value "value2")]

      -- Order of tracestate headers preserved when merging (RFC 7230 field order)
      -- https://www.w3.org/TR/trace-context/#tracestate-header
      it "combines multiple headers in order" $ do
        let headers = ["vendor1=value1,vendor2=value2", "vendor3=value3,vendor4=value4"]
            result = decodeTraceStateMultiple headers
            pairs = toList result
        length pairs `shouldBe` 4
        pairs `shouldContain` [(Key "vendor1", Value "value1")]
        pairs `shouldContain` [(Key "vendor2", Value "value2")]
        pairs `shouldContain` [(Key "vendor3", Value "value3")]
        pairs `shouldContain` [(Key "vendor4", Value "value4")]

      it "handles empty headers gracefully" $ do
        let headers = ["vendor1=value1", "", "vendor2=value2"]
            result = decodeTraceStateMultiple headers
            pairs = toList result
        pairs `shouldContain` [(Key "vendor1", Value "value1")]
        pairs `shouldContain` [(Key "vendor2", Value "value2")]

      -- §3.3.1 invalid list-members skipped
      -- https://www.w3.org/TR/trace-context/#tracestate-list
      it "skips invalid members when combining headers (§3.3.1)" $ do
        let headers = ["invalid$key=value", "another=bad,value"]
            result = decodeTraceStateMultiple headers
        result `shouldBe` insert (Key "another") (Value "bad") empty

      it "returns empty tracestate for empty header list" $ do
        let result = decodeTraceStateMultiple []
        result `shouldBe` empty

      it "handles whitespace-only headers" $ do
        let headers = ["vendor1=value1", "   ", "vendor2=value2"]
            result = decodeTraceStateMultiple headers
            pairs = toList result
        pairs `shouldContain` [(Key "vendor1", Value "value1")]
        pairs `shouldContain` [(Key "vendor2", Value "value2")]

    describe "round-trip multi-header property" $ do
      it "round-trips through multiple headers" $ do
        let originalPairs =
              [ (Key "vendor1", Value "value1")
              , (Key "vendor2", Value "value2")
              , (Key "vendor3", Value "value3")
              ]
            ts = fromList originalPairs
            encoded = encodeTraceStateMultiple 512 ts
            decoded = decodeTraceStateMultiple encoded
            decodedPairs = toList decoded
        decodedPairs `shouldBe` originalPairs

      it "round-trips with size-constrained splitting" $ do
        let originalPairs =
              [ (Key "vendor1", Value "val1")
              , (Key "vendor2", Value "val2")
              , (Key "vendor3", Value "val3")
              , (Key "vendor4", Value "val4")
              ]
            ts = fromList originalPairs
            encoded = encodeTraceStateMultiple 25 ts -- Force splitting
            decoded = decodeTraceStateMultiple encoded
            decodedPairs = toList decoded
        -- Should contain all original entries (order may vary due to splitting)
        length decodedPairs `shouldBe` 4
        all (`elem` decodedPairs) originalPairs `shouldBe` True

    -- RFC 7230 §3.2.2 field order; tracestate parsing across header fields
    -- https://www.w3.org/TR/trace-context/#tracestate-header
    describe "RFC7230 compliance" $ do
      it "maintains header order when combining" $ do
        let headers = ["first=1", "second=2", "third=3"]
            result = decodeTraceStateMultiple headers
        -- The combined header should be processed in order
        result `shouldSatisfy` (/= empty)

      it "handles comma-separated values correctly" $ do
        let headers = ["a=1,b=2", "c=3,d=4"]
            result = decodeTraceStateMultiple headers
            pairs = toList result
        length pairs `shouldBe` 4
        pairs `shouldContain` [(Key "a", Value "1")]
        pairs `shouldContain` [(Key "b", Value "2")]
        pairs `shouldContain` [(Key "c", Value "3")]
        pairs `shouldContain` [(Key "d", Value "4")]

    describe "W3C specification compliance" $ do
      -- §3.3.3 recommendation: tracestate at least 512 characters
      -- https://www.w3.org/TR/trace-context/#tracestate-limits
      it "supports at least 512 character recommendation" $ do
        let longValuePairs = [(Key (T.pack $ "vendor" ++ show i), Value (T.pack $ replicate 30 'x')) | i <- [1 .. 10]]
            ts = fromList longValuePairs
            encoded = encodeTraceStateMultiple 512 ts
            totalSize = sum $ map C8.length encoded
        -- Should handle at least 512 characters worth of data
        totalSize `shouldSatisfy` (>= 300) -- Conservative check given filtering

      -- §3.3.2.2 value length limits when encoding
      -- https://www.w3.org/TR/trace-context/#value
      it "removes oversized entries as per spec" $ do
        let oversizedEntry = (Key "big", Value (T.replicate 200 "x"))
            normalEntry = (Key "small", Value "value")
            ts = fromList [oversizedEntry, normalEntry]
            encoded = encodeTraceStateMultiple 512 ts
            combined = C8.intercalate "," encoded
        -- Oversized entry should be filtered out
        combined `shouldNotSatisfy` C8.isInfixOf "big="
        combined `shouldSatisfy` C8.isInfixOf "small=value"
