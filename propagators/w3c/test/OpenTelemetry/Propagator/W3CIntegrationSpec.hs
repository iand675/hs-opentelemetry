{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.Propagator.W3CIntegrationSpec (spec) where

import Data.ByteString (ByteString)
import qualified Data.ByteString.Char8 as C8
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import OpenTelemetry.Common (TraceFlags (..))
import qualified OpenTelemetry.Context as Ctxt
import OpenTelemetry.Propagator (Propagator (..), emptyTextMap, textMapFromList, textMapLookup)
import OpenTelemetry.Propagator.W3CTraceContext (
  decodeSpanContext,
  encodeTraceState,
  w3cTraceContextPropagator,
 )
import OpenTelemetry.Trace.Core
import OpenTelemetry.Trace.Id
import OpenTelemetry.Trace.TraceState (Key (..), Value (..), empty, fromList, insert, toList)
import Test.Hspec


spec :: Spec
spec =
  -- W3C Trace Context: traceparent + tracestate integration
  -- https://www.w3.org/TR/trace-context/
  describe "W3C TraceContext Integration" $ do
    -- §2.2.2 traceparent + §3.3 tracestate
    -- https://www.w3.org/TR/trace-context/#traceparent-header
    describe "decodeSpanContext" $ do
      -- traceparent: version-trace_id-parent_id-trace_flags; tracestate optional
      -- https://www.w3.org/TR/trace-context/#traceparent-header-field-values
      it "decodes traceparent and empty tracestate" $ do
        let traceparent = Just "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01"
            tracestate = Nothing
            result = decodeSpanContext traceparent tracestate
        case result of
          Just spanCtx -> do
            OpenTelemetry.Trace.Core.traceFlags spanCtx `shouldBe` TraceFlags 1
            traceState spanCtx `shouldBe` empty
          Nothing -> expectationFailure "Failed to decode span context"

      -- §3.3 tracestate with valid list-members
      -- https://www.w3.org/TR/trace-context/#tracestate-header
      it "decodes traceparent and tracestate with single entry" $ do
        let traceparent = Just "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01"
            tracestate = Just "vendor1=value1"
            result = decodeSpanContext traceparent tracestate
        case result of
          Just spanCtx -> do
            OpenTelemetry.Trace.Core.traceFlags spanCtx `shouldBe` TraceFlags 1
            traceState spanCtx `shouldBe` insert (Key "vendor1") (Value "value1") empty
          Nothing -> expectationFailure "Failed to decode span context"

      -- §3.3.1 comma-separated list-members
      -- https://www.w3.org/TR/trace-context/#tracestate-list
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

      -- §3.3.1 invalid list-members ignored; traceparent still valid
      -- https://www.w3.org/TR/trace-context/#tracestate-list
      it "handles invalid tracestate gracefully" $ do
        let traceparent = Just "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01"
            tracestate = Just "INVALID$KEY=value1" -- Invalid key format
            result = decodeSpanContext traceparent tracestate
        case result of
          Just spanCtx -> do
            OpenTelemetry.Trace.Core.traceFlags spanCtx `shouldBe` TraceFlags 1
            traceState spanCtx `shouldBe` empty -- Should fall back to empty
          Nothing -> expectationFailure "Failed to decode span context"

      -- §2.2.2 invalid traceparent → no trace context
      -- https://www.w3.org/TR/trace-context/#traceparent-header-field-values
      it "returns Nothing for invalid traceparent" $ do
        let traceparent = Just "invalid-traceparent"
            tracestate = Just "vendor1=value1"
            result = decodeSpanContext traceparent tracestate
        result `shouldBe` Nothing

      -- §2.2.2 traceparent required when propagating trace context
      -- https://www.w3.org/TR/trace-context/#traceparent-header
      it "returns Nothing for missing traceparent" $ do
        let traceparent = Nothing
            tracestate = Just "vendor1=value1"
            result = decodeSpanContext traceparent tracestate
        result `shouldBe` Nothing

      -- §2.2.2 trace-id all zeros invalid
      -- https://www.w3.org/TR/trace-context/#trace-id
      it "rejects all-zero trace-id" $ do
        let traceparent = Just "00-00000000000000000000000000000000-b7ad6b7169203331-01"
            result = decodeSpanContext traceparent Nothing
        result `shouldBe` Nothing

      -- §2.2.2 parent-id all zeros invalid
      -- https://www.w3.org/TR/trace-context/#parent-id
      it "rejects all-zero parent-id" $ do
        let traceparent = Just "00-0af7651916cd43dd8448eb211c80319c-0000000000000000-01"
            result = decodeSpanContext traceparent Nothing
        result `shouldBe` Nothing

      -- §2.2.2 combined invalid trace-id and parent-id
      -- https://www.w3.org/TR/trace-context/#traceparent-header-field-values
      it "rejects all-zero trace-id and parent-id" $ do
        let traceparent = Just "00-00000000000000000000000000000000-0000000000000000-01"
            result = decodeSpanContext traceparent Nothing
        result `shouldBe` Nothing

    -- §3.3 tracestate round-trip with traceparent
    -- https://www.w3.org/TR/trace-context/#tracestate-header
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

      -- §3.3 empty tracestate / absent header equivalence
      -- https://www.w3.org/TR/trace-context/#tracestate-header
      it "handles empty tracestate in round-trip" $ do
        let encoded = encodeTraceState empty
        encoded `shouldBe` ""
        let traceparent = Just "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01"
            result = decodeSpanContext traceparent (if encoded == "" then Nothing else Just encoded)
        case result of
          Just spanCtx -> traceState spanCtx `shouldBe` empty
          Nothing -> expectationFailure "Failed to handle empty tracestate"

    -- §3.3 tracestate limits and key/value rules
    -- https://www.w3.org/TR/trace-context/#tracestate-limits
    describe "W3C specification compliance" $ do
      -- §3.3.3 at most 32 list-members
      -- https://www.w3.org/TR/trace-context/#tracestate-limits
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

      -- §3.3.2.1 key ABNF (simple-key / multi-tenant-key)
      -- https://www.w3.org/TR/trace-context/#key
      it "validates key format according to spec" $ do
        let testCases =
              [ ("validkey", True)
              , ("valid123", True)
              , ("valid_key", True)
              , ("valid-key", True)
              , ("valid*key", True)
              , ("valid/key", True)
              , ("tenant@vendor", True)
              , ("123numeric", False) -- simple-key must start with lcalpha (§3.3.2.1)
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

      -- §3.3.2.2 value ABNF
      -- https://www.w3.org/TR/trace-context/#value
      it "validates value format according to spec" $ do
        let testCases =
              [ ("validvalue", True)
              , ("valid value with spaces", True)
              , ("valid-value_with*special/chars", True)
              , ("valid!value#with$symbols%", True)
              , ("value,with,comma", False) -- Comma ends value; member still parsed leniently (§3.3.1)
              , ("value=with=equals", False) -- '=' ends value; same lenient behavior
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
                                        Just spanCtx ->
                                          toList (traceState spanCtx)
                                            == [(Key "validkey", Value "value")]
                                        Nothing -> False
                                    )
          )
          testCases

    -- OpenTelemetry propagator API + W3C header names (traceparent, tracestate)
    -- https://www.w3.org/TR/trace-context/#traceparent-header
    describe "w3cTraceContextPropagator injector" $ do
      -- §2.2.2 + §3.3 inject traceparent and tracestate
      -- https://www.w3.org/TR/trace-context/#traceparent-header-field-values
      it "injects traceparent and tracestate headers" $ do
        case baseEncodedToTraceId Base16 "0af7651916cd43dd8448eb211c80319c" of
          Left err -> expectationFailure err
          Right tid ->
            case baseEncodedToSpanId Base16 "b7ad6b7169203331" of
              Left err -> expectationFailure err
              Right sid -> do
                let ts = insert (Key "vendor1") (Value "value1") empty
                    spanCtx =
                      SpanContext
                        { traceFlags = TraceFlags 1
                        , isRemote = False
                        , traceId = tid
                        , spanId = sid
                        , traceState = ts
                        }
                    ctxt = Ctxt.insertSpan (wrapSpanContext spanCtx) Ctxt.empty
                hdrs <- injector w3cTraceContextPropagator ctxt emptyTextMap
                textMapLookup "traceparent" hdrs
                  `shouldBe` Just "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01"
                textMapLookup "tracestate" hdrs `shouldBe` Just "vendor1=value1"

      -- §3.3 tracestate header present but empty when no vendor state
      -- https://www.w3.org/TR/trace-context/#tracestate-header
      it "injects empty tracestate for span with no tracestate" $ do
        case baseEncodedToTraceId Base16 "0af7651916cd43dd8448eb211c80319c" of
          Left err -> expectationFailure err
          Right tid ->
            case baseEncodedToSpanId Base16 "b7ad6b7169203331" of
              Left err -> expectationFailure err
              Right sid -> do
                let spanCtx =
                      SpanContext
                        { traceFlags = TraceFlags 1
                        , isRemote = False
                        , traceId = tid
                        , spanId = sid
                        , traceState = empty
                        }
                    ctxt = Ctxt.insertSpan (wrapSpanContext spanCtx) Ctxt.empty
                hdrs <- injector w3cTraceContextPropagator ctxt emptyTextMap
                textMapLookup "tracestate" hdrs `shouldBe` Just ""

      it "does not inject when context has no span" $ do
        hdrs <- injector w3cTraceContextPropagator Ctxt.empty emptyTextMap
        hdrs `shouldBe` emptyTextMap

    -- §2.2.2 extract traceparent; §3.3 extract tracestate
    -- https://www.w3.org/TR/trace-context/#traceparent-header
    describe "w3cTraceContextPropagator extractor" $ do
      it "extracts span from traceparent header" $ do
        case baseEncodedToTraceId Base16 "0af7651916cd43dd8448eb211c80319c" of
          Left err -> expectationFailure err
          Right tid ->
            case baseEncodedToSpanId Base16 "b7ad6b7169203331" of
              Left err -> expectationFailure err
              Right sid -> do
                let hs =
                      textMapFromList
                        [ ("traceparent", "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01")
                        ]
                ctxt <- extractor w3cTraceContextPropagator hs Ctxt.empty
                case Ctxt.lookupSpan ctxt of
                  Nothing -> expectationFailure "expected span in context"
                  Just sp -> do
                    sc <- getSpanContext sp
                    traceFlags sc `shouldBe` TraceFlags 1
                    traceId sc `shouldBe` tid
                    spanId sc `shouldBe` sid
                    traceState sc `shouldBe` empty

      -- §3.3 multiple tracestate header fields (RFC 7230 comma vs multiple headers)
      -- https://www.w3.org/TR/trace-context/#tracestate-header
      it "combines multiple tracestate headers" $ do
        let hs =
              textMapFromList
                [ ("traceparent", "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01")
                , ("tracestate", "vendor1=value1,vendor2=value2")
                ]
        ctxt <- extractor w3cTraceContextPropagator hs Ctxt.empty
        case Ctxt.lookupSpan ctxt of
          Nothing -> expectationFailure "expected span in context"
          Just sp -> do
            sc <- getSpanContext sp
            let pairs = toList (traceState sc)
            pairs `shouldContain` [(Key "vendor1", Value "value1")]
            pairs `shouldContain` [(Key "vendor2", Value "value2")]

      -- §2.2.2 no valid traceparent → no context update
      -- https://www.w3.org/TR/trace-context/#traceparent-header
      it "leaves context unchanged when traceparent missing" $ do
        ctxt <- extractor w3cTraceContextPropagator emptyTextMap Ctxt.empty
        case Ctxt.lookupSpan ctxt of
          Nothing -> pure ()
          Just _ -> expectationFailure "expected no span in context"

      -- TextMap normalizes keys to lowercase on construction, so traceparent lookup is
      -- case-insensitive (HTTP header semantics). Duplicate keys collapse to one entry:
      -- Data.HashMap.Strict.fromList keeps the last association for a key.

      -- HTTP field-name case-insensitivity (RFC 9110); traceparent field name
      -- https://www.w3.org/TR/trace-context/#traceparent-header
      it "extracts span when duplicate traceparent keys appear (last value wins)" $ do
        let tp1 = "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01"
            tp2 = "00-0af7651916cd43dd8448eb211c80319c-1111111111111111-01"
        case baseEncodedToSpanId Base16 "1111111111111111" of
          Left err -> expectationFailure err
          Right expectedSid -> do
            let hs =
                  textMapFromList
                    [ ("traceparent", tp1)
                    , ("traceparent", tp2)
                    ]
            ctxt <- extractor w3cTraceContextPropagator hs Ctxt.empty
            case Ctxt.lookupSpan ctxt of
              Nothing -> expectationFailure "expected span in context"
              Just sp -> do
                sc <- getSpanContext sp
                spanId sc `shouldBe` expectedSid

      it "extracts span when traceparent header name uses non-lowercase spelling" $ do
        let tp = "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01"
        case baseEncodedToTraceId Base16 "0af7651916cd43dd8448eb211c80319c" of
          Left err -> expectationFailure err
          Right tid ->
            case baseEncodedToSpanId Base16 "b7ad6b7169203331" of
              Left err2 -> expectationFailure err2
              Right sid -> do
                let hs = textMapFromList [("TraceParent", tp)]
                ctxt <- extractor w3cTraceContextPropagator hs Ctxt.empty
                case Ctxt.lookupSpan ctxt of
                  Nothing -> expectationFailure "expected span in context"
                  Just sp -> do
                    sc <- getSpanContext sp
                    traceId sc `shouldBe` tid
                    spanId sc `shouldBe` sid

      it "extracts span when traceparent header name is uppercase" $ do
        let tp = "00-0af7651916cd43dd8448eb211c80319c-b7ad6b7169203331-01"
        case baseEncodedToTraceId Base16 "0af7651916cd43dd8448eb211c80319c" of
          Left err -> expectationFailure err
          Right tid ->
            case baseEncodedToSpanId Base16 "b7ad6b7169203331" of
              Left err2 -> expectationFailure err2
              Right sid -> do
                let hs = textMapFromList [("TRACEPARENT", tp)]
                ctxt <- extractor w3cTraceContextPropagator hs Ctxt.empty
                case Ctxt.lookupSpan ctxt of
                  Nothing -> expectationFailure "expected span in context"
                  Just sp -> do
                    sc <- getSpanContext sp
                    traceId sc `shouldBe` tid
                    spanId sc `shouldBe` sid
