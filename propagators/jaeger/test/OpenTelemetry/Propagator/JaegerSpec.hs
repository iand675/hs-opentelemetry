{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.Propagator.JaegerSpec (spec) where

import qualified Data.HashMap.Strict as H
import Data.Maybe (isNothing)
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import qualified OpenTelemetry.Baggage as Baggage
import OpenTelemetry.Common (TraceFlags (..))
import OpenTelemetry.Context (Context, empty, insertBaggage, insertSpan, lookupBaggage, lookupSpan)
import OpenTelemetry.Propagator (
  Propagator (..),
  TextMap,
  emptyTextMap,
  textMapFromList,
  textMapKeys,
  textMapLookup,
 )
import OpenTelemetry.Propagator.Jaeger (jaegerPropagator, jaegerTraceContextPropagator)
import qualified OpenTelemetry.Propagator.Jaeger.Internal as JI
import OpenTelemetry.Trace.Core (SpanContext (..), getSpanContext, isSampled, wrapSpanContext)
import OpenTelemetry.Trace.Id (Base (..), SpanId, TraceId, baseEncodedToSpanId, baseEncodedToTraceId)
import OpenTelemetry.Trace.TraceState (TraceState (..))
import Test.Hspec


spec :: Spec
spec = describe "OpenTelemetry.Propagator.Jaeger" $ do
  describe "Internal codec" $ do
    it "parses a 128-bit trace context header" $ do
      let hdr = "80f198ee56343ba864fe8b2a57d3eff7:e457b5a2e4d86bd1:0:1"
      case JI.decodeUberTraceId (TE.encodeUtf8 hdr) of
        Nothing -> expectationFailure "expected parse"
        Just jh -> do
          JI.jhTraceId jh `shouldBe` expectedTraceId
          JI.jhSpanId jh `shouldBe` expectedSpanId
          JI.jhParentSpanId jh `shouldBe` Nothing
          JI.flagsSampled (JI.jhFlags jh) `shouldBe` True
          JI.flagsDebug (JI.jhFlags jh) `shouldBe` False

    it "parses a 64-bit trace ID (left-padded to 128-bit)" $ do
      let hdr = "64fe8b2a57d3eff7:e457b5a2e4d86bd1:0:1"
      case JI.decodeUberTraceId (TE.encodeUtf8 hdr) of
        Nothing -> expectationFailure "expected parse"
        Just jh -> do
          JI.jhTraceId jh `shouldBe` expectedTraceId64
          JI.flagsSampled (JI.jhFlags jh) `shouldBe` True

    it "parses debug flag (flags=03 means sampled+debug)" $ do
      let hdr = "80f198ee56343ba864fe8b2a57d3eff7:e457b5a2e4d86bd1:0:03"
      case JI.decodeUberTraceId (TE.encodeUtf8 hdr) of
        Nothing -> expectationFailure "expected parse"
        Just jh -> do
          JI.flagsSampled (JI.jhFlags jh) `shouldBe` True
          JI.flagsDebug (JI.jhFlags jh) `shouldBe` True

    it "parses unsampled flag (flags=0)" $ do
      let hdr = "80f198ee56343ba864fe8b2a57d3eff7:e457b5a2e4d86bd1:0:0"
      case JI.decodeUberTraceId (TE.encodeUtf8 hdr) of
        Nothing -> expectationFailure "expected parse"
        Just jh -> do
          JI.flagsSampled (JI.jhFlags jh) `shouldBe` False
          JI.flagsDebug (JI.jhFlags jh) `shouldBe` False

    it "parses debug-only flag (flags=2)" $ do
      let hdr = "80f198ee56343ba864fe8b2a57d3eff7:e457b5a2e4d86bd1:0:2"
      case JI.decodeUberTraceId (TE.encodeUtf8 hdr) of
        Nothing -> expectationFailure "expected parse"
        Just jh -> do
          JI.flagsSampled (JI.jhFlags jh) `shouldBe` False
          JI.flagsDebug (JI.jhFlags jh) `shouldBe` True

    it "parses non-zero parent span ID" $ do
      let hdr = "80f198ee56343ba864fe8b2a57d3eff7:e457b5a2e4d86bd1:05e3ac9a4f6e3b90:1"
      case JI.decodeUberTraceId (TE.encodeUtf8 hdr) of
        Nothing -> expectationFailure "expected parse"
        Just jh -> case JI.jhParentSpanId jh of
          Nothing -> expectationFailure "expected parent span ID"
          Just _ -> pure ()

    it "rejects empty input" $ do
      JI.decodeUberTraceId "" `shouldBe` Nothing

    it "rejects missing fields" $ do
      JI.decodeUberTraceId "abc:def:0" `shouldBe` Nothing

    it "rejects non-hex characters in trace ID" $ do
      JI.decodeUberTraceId "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz:e457b5a2e4d86bd1:0:1"
        `shouldBe` Nothing

    it "rejects trailing garbage" $ do
      JI.decodeUberTraceId "80f198ee56343ba864fe8b2a57d3eff7:e457b5a2e4d86bd1:0:1:extra"
        `shouldBe` Nothing

  describe "trace context extraction" $ do
    it "extracts SpanContext from uber-trace-id (sampled)" $ do
      let headers =
            textMapFromList
              [("uber-trace-id", "80f198ee56343ba864fe8b2a57d3eff7:e457b5a2e4d86bd1:0:1")]
      ctx' <- extractor jaegerTraceContextPropagator headers empty
      case lookupSpan ctx' of
        Nothing -> expectationFailure "expected span in context"
        Just span' -> do
          sc <- getSpanContext span'
          traceId sc `shouldBe` expectedTraceId
          spanId sc `shouldBe` expectedSpanId
          isRemote sc `shouldBe` True
          isSampled (traceFlags sc) `shouldBe` True

    it "extracts SpanContext from uber-trace-id (unsampled)" $ do
      let headers =
            textMapFromList
              [("uber-trace-id", "80f198ee56343ba864fe8b2a57d3eff7:e457b5a2e4d86bd1:0:0")]
      ctx' <- extractor jaegerTraceContextPropagator headers empty
      case lookupSpan ctx' of
        Nothing -> expectationFailure "expected span in context"
        Just span' -> do
          sc <- getSpanContext span'
          isSampled (traceFlags sc) `shouldBe` False

    it "debug flag implies sampled" $ do
      let headers =
            textMapFromList
              [("uber-trace-id", "80f198ee56343ba864fe8b2a57d3eff7:e457b5a2e4d86bd1:0:2")]
      ctx' <- extractor jaegerTraceContextPropagator headers empty
      case lookupSpan ctx' of
        Nothing -> expectationFailure "expected span in context"
        Just span' -> do
          sc <- getSpanContext span'
          isSampled (traceFlags sc) `shouldBe` True

    it "leaves context unchanged when header is missing" $ do
      ctx' <- extractor jaegerTraceContextPropagator emptyTextMap empty
      lookupSpan ctx' `shouldSatisfy` isNothing

    it "leaves context unchanged for malformed header" $ do
      let headers = textMapFromList [("uber-trace-id", "not-a-valid-header")]
      ctx' <- extractor jaegerTraceContextPropagator headers empty
      lookupSpan ctx' `shouldSatisfy` isNothing

    it "header name is case-insensitive" $ do
      let headers =
            textMapFromList
              [("Uber-Trace-Id", "80f198ee56343ba864fe8b2a57d3eff7:e457b5a2e4d86bd1:0:1")]
      ctx' <- extractor jaegerTraceContextPropagator headers empty
      case lookupSpan ctx' of
        Nothing -> expectationFailure "expected span in context"
        Just span' -> do
          sc <- getSpanContext span'
          traceId sc `shouldBe` expectedTraceId

  describe "trace context injection" $ do
    it "injects uber-trace-id with sampled flag" $ do
      let ctx = insertSpan (wrapSpanContext sampledSpanContext) empty
      hs <- injector jaegerTraceContextPropagator ctx emptyTextMap
      case textMapLookup "uber-trace-id" hs of
        Nothing -> expectationFailure "expected uber-trace-id header"
        Just v -> do
          let parts = T.splitOn ":" v
          length parts `shouldBe` 4
          parts !! 0 `shouldBe` traceIdHex
          parts !! 1 `shouldBe` spanIdHex
          parts !! 2 `shouldBe` "0"
          parts !! 3 `shouldBe` "1"

    it "injects uber-trace-id with unsampled flag" $ do
      let ctx = insertSpan (wrapSpanContext unsampledSpanContext) empty
      hs <- injector jaegerTraceContextPropagator ctx emptyTextMap
      case textMapLookup "uber-trace-id" hs of
        Nothing -> expectationFailure "expected uber-trace-id header"
        Just v -> do
          let parts = T.splitOn ":" v
          parts !! 3 `shouldBe` "0"

    it "does not inject when no span in context" $ do
      hs <- injector jaegerTraceContextPropagator empty emptyTextMap
      textMapLookup "uber-trace-id" hs `shouldSatisfy` isNothing

  describe "round-trip" $ do
    it "extract after inject preserves trace and span IDs" $ do
      let ctx = insertSpan (wrapSpanContext sampledSpanContext) empty
      hs <- injector jaegerTraceContextPropagator ctx emptyTextMap
      ctx' <- extractor jaegerTraceContextPropagator hs empty
      case lookupSpan ctx' of
        Nothing -> expectationFailure "expected span in context after round-trip"
        Just span' -> do
          sc <- getSpanContext span'
          traceId sc `shouldBe` expectedTraceId
          spanId sc `shouldBe` expectedSpanId
          isSampled (traceFlags sc) `shouldBe` True

    it "round-trip preserves unsampled flag" $ do
      let ctx = insertSpan (wrapSpanContext unsampledSpanContext) empty
      hs <- injector jaegerTraceContextPropagator ctx emptyTextMap
      ctx' <- extractor jaegerTraceContextPropagator hs empty
      case lookupSpan ctx' of
        Nothing -> expectationFailure "expected span in context"
        Just span' -> do
          sc <- getSpanContext span'
          isSampled (traceFlags sc) `shouldBe` False

  describe "baggage propagation" $ do
    it "extracts baggage from uberctx-* headers" $ do
      let headers =
            textMapFromList
              [ ("uber-trace-id", "80f198ee56343ba864fe8b2a57d3eff7:e457b5a2e4d86bd1:0:1")
              , ("uberctx-user-id", "42")
              , ("uberctx-session", "abc123")
              ]
      ctx' <- extractor jaegerPropagator headers empty
      case lookupBaggage ctx' of
        Nothing -> expectationFailure "expected baggage in context"
        Just bag -> do
          let vals = H.toList (Baggage.values bag)
          length vals `shouldSatisfy` (>= 2)

    it "injects baggage as uberctx-* headers" $ do
      case Baggage.decodeBaggageHeader "user-id=42,session=abc123" of
        Left err -> expectationFailure $ "baggage setup failed: " ++ err
        Right bag -> do
          let ctx =
                insertSpan (wrapSpanContext sampledSpanContext) $
                  insertBaggage bag empty
          hs <- injector jaegerPropagator ctx emptyTextMap
          textMapLookup "uberctx-user-id" hs `shouldBe` Just "42"
          textMapLookup "uberctx-session" hs `shouldBe` Just "abc123"

    it "does not inject baggage headers when no baggage in context" $ do
      let ctx = insertSpan (wrapSpanContext sampledSpanContext) empty
      hs <- injector jaegerPropagator ctx emptyTextMap
      let baggageHeaders = filter (T.isPrefixOf "uberctx-") $ map fst $ textMapToListImpl hs
      baggageHeaders `shouldBe` []

  describe "propagatorFields" $ do
    it "trace context propagator declares uber-trace-id" $ do
      propagatorFields jaegerTraceContextPropagator `shouldBe` ["uber-trace-id"]


-- Helpers --------------------------------------------------------------------

textMapToListImpl :: TextMap -> [(T.Text, T.Text)]
textMapToListImpl tm =
  map (\k -> (k, maybe "" id (textMapLookup k tm))) (textMapKeys tm)


traceIdHex :: T.Text
traceIdHex = "80f198ee56343ba864fe8b2a57d3eff7"


spanIdHex :: T.Text
spanIdHex = "e457b5a2e4d86bd1"


expectedTraceId :: TraceId
expectedTraceId =
  case baseEncodedToTraceId Base16 (TE.encodeUtf8 traceIdHex) of
    Right t -> t
    Left e -> error ("expectedTraceId: " ++ e)


-- 64-bit trace ID "64fe8b2a57d3eff7" → zero-padded to 128-bit
expectedTraceId64 :: TraceId
expectedTraceId64 =
  case baseEncodedToTraceId Base16 "000000000000000064fe8b2a57d3eff7" of
    Right t -> t
    Left e -> error ("expectedTraceId64: " ++ e)


expectedSpanId :: SpanId
expectedSpanId =
  case baseEncodedToSpanId Base16 (TE.encodeUtf8 spanIdHex) of
    Right s -> s
    Left e -> error ("expectedSpanId: " ++ e)


sampledSpanContext :: SpanContext
sampledSpanContext =
  SpanContext
    { traceId = expectedTraceId
    , spanId = expectedSpanId
    , isRemote = False
    , traceFlags = TraceFlags 1
    , traceState = TraceState []
    }


unsampledSpanContext :: SpanContext
unsampledSpanContext =
  SpanContext
    { traceId = expectedTraceId
    , spanId = expectedSpanId
    , isRemote = False
    , traceFlags = TraceFlags 0
    , traceState = TraceState []
    }
