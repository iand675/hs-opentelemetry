{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.Propagator.W3CIntegrationSpec (spec) where

import Data.ByteString (ByteString)
import qualified Data.ByteString.Char8 as C8
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import OpenTelemetry.Common (TraceFlags (..))
import OpenTelemetry.Propagator.W3CTraceContext
import OpenTelemetry.Trace.Core
import OpenTelemetry.Trace.Id
import OpenTelemetry.Trace.TraceState (Key (..), Value (..), empty, fromList, insert, toList)
import Test.Hspec


spec :: Spec
spec = describe "W3C TraceContext Integration" $ do
  describe "decodeSpanContext" $ do
    it "decodes traceparent and empty tracestate" $ do
      let traceparent = Just "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01"
          tracestate = Nothing
          result = decodeSpanContext traceparent tracestate
      case result of
        Just spanCtx -> do
          OpenTelemetry.Trace.Core.traceFlags spanCtx `shouldBe` TraceFlags 1
          traceState spanCtx `shouldBe` empty
        Nothing -> expectationFailure "Failed to decode span context"

    it "decodes traceparent and tracestate with single entry" $ do
      let traceparent = Just "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01"
          tracestate = Just "vendor1=value1"
          result = decodeSpanContext traceparent tracestate
      case result of
        Just spanCtx -> do
          OpenTelemetry.Trace.Core.traceFlags spanCtx `shouldBe` TraceFlags 1
          traceState spanCtx `shouldBe` insert (Key "vendor1") (Value "value1") empty
        Nothing -> expectationFailure "Failed to decode span context"

    it "decodes traceparent and tracestate with multiple entries" $ do
      let traceparent = Just "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01"
          tracestate = Just "vendor1=value1,vendor2=value2,vendor3=value3"
          result = decodeSpanContext traceparent tracestate
      case result of
        Just spanCtx -> do
          OpenTelemetry.Trace.Core.traceFlags spanCtx `shouldBe` TraceFlags 1
          let decodedPairs = toList (traceState spanCtx)
          decodedPairs `shouldContain` [(Key "vendor1", Value "value1")]
          decodedPairs `shouldContain` [(Key "vendor2", Value "value2")]
          decodedPairs `shouldContain` [(Key "vendor3", Value "value3")]
          length decodedPairs `shouldBe` 3
        Nothing -> expectationFailure "Failed to decode span context"

    it "handles invalid tracestate gracefully" $ do
      let traceparent = Just "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01"
          tracestate = Just "INVALID$KEY=value1" -- Invalid key format
          result = decodeSpanContext traceparent tracestate
      case result of
        Just spanCtx -> do
          OpenTelemetry.Trace.Core.traceFlags spanCtx `shouldBe` TraceFlags 1
          traceState spanCtx `shouldBe` empty -- Should fall back to empty
        Nothing -> expectationFailure "Failed to decode span context"

    it "returns Nothing for invalid traceparent" $ do
      let traceparent = Just "invalid-traceparent"
          tracestate = Just "vendor1=value1"
          result = decodeSpanContext traceparent tracestate
      result `shouldBe` Nothing

    it "returns Nothing for missing traceparent" $ do
      let traceparent = Nothing
          tracestate = Just "vendor1=value1"
          result = decodeSpanContext traceparent tracestate
      result `shouldBe` Nothing

  describe "encodeTraceState integration" $ do
    it "encodes complex tracestate correctly" $ do
      let complexState =
            fromList
              [ (Key "tenant@vendor", Value "complex-value_with*chars")
              , (Key "simple", Value "value")
              , (Key "numeric123", Value "123-456")
              ]
          encoded = encodeTraceState complexState
      -- Verify it can be round-tripped
      let traceparent = Just "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01"
          result = decodeSpanContext traceparent (Just encoded)
      case result of
        Just spanCtx -> do
          let decodedState = traceState spanCtx
          decodedState `shouldBe` complexState
        Nothing -> expectationFailure "Failed to round-trip complex tracestate"

    it "handles empty tracestate in round-trip" $ do
      let encoded = encodeTraceState empty
      encoded `shouldBe` ""
      let traceparent = Just "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01"
          result = decodeSpanContext traceparent (if encoded == "" then Nothing else Just encoded)
      case result of
        Just spanCtx -> traceState spanCtx `shouldBe` empty
        Nothing -> expectationFailure "Failed to handle empty tracestate"

  describe "W3C specification compliance" $ do
    it "respects 32 entry limit in parsing" $ do
      let entries = ["key" ++ show i ++ "=value" ++ show i | i <- [1 .. 40]]
          longTracestate = C8.intercalate "," $ map C8.pack entries
          traceparent = Just "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01"
          result = decodeSpanContext traceparent (Just longTracestate)
      case result of
        Just spanCtx -> do
          let stateEntries = traceState spanCtx
          length (toList stateEntries) `shouldBe` 32
        Nothing -> expectationFailure "Failed to parse long tracestate"

    it "validates key format according to spec" $ do
      let testCases =
            [ ("validkey", True)
            , ("valid123", True)
            , ("valid_key", True)
            , ("valid-key", True)
            , ("valid*key", True)
            , ("valid/key", True)
            , ("tenant@vendor", True)
            , ("123numeric", True)
            , ("INVALIDKEY", False) -- Must start with lowercase
            , ("invalid$key", False) -- Invalid character
            , ("", False) -- Empty key
            ]
      mapM_
        ( \(key, shouldSucceed) -> do
            let tracestate = C8.pack $ T.unpack key ++ "=value"
                traceparent = Just "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01"
                result = decodeSpanContext traceparent (Just tracestate)
            if shouldSucceed
              then
                result
                  `shouldSatisfy` ( \case
                                      Just spanCtx -> not $ null $ toList $ traceState spanCtx
                                      Nothing -> False
                                  )
              else
                result
                  `shouldSatisfy` ( \case
                                      Just spanCtx -> null $ toList $ traceState spanCtx
                                      Nothing -> True
                                  )
        )
        testCases

    it "validates value format according to spec" $ do
      let testCases =
            [ ("validvalue", True)
            , ("valid value with spaces", True)
            , ("valid-value_with*special/chars", True)
            , ("valid!value#with$symbols%", True)
            , ("value,with,comma", False) -- Comma not allowed
            , ("value=with=equals", False) -- Equals not allowed in continuation
            ]
      mapM_
        ( \(value, shouldSucceed) -> do
            let tracestate = C8.pack $ "validkey=" ++ T.unpack value
                traceparent = Just "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01"
                result = decodeSpanContext traceparent (Just tracestate)
            if shouldSucceed
              then
                result
                  `shouldSatisfy` ( \case
                                      Just spanCtx -> not $ null $ toList $ traceState spanCtx
                                      Nothing -> False
                                  )
              else
                result
                  `shouldSatisfy` ( \case
                                      Just spanCtx -> null $ toList $ traceState spanCtx
                                      Nothing -> True
                                  )
        )
        testCases
