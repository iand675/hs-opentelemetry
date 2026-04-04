{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Data.Maybe (isJust, isNothing)
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import OpenTelemetry.Common (TraceFlags (..))
import OpenTelemetry.Context (Context, empty, insertSpan, lookupSpan)
import OpenTelemetry.Propagator (
  Propagator (..),
  emptyTextMap,
  textMapFromList,
  textMapLookup,
 )
import OpenTelemetry.Propagator.B3 (b3MultiTraceContextPropagator, b3TraceContextPropagator)
import qualified OpenTelemetry.Propagator.B3.Internal as B3I
import OpenTelemetry.Trace.Core (SpanContext (..), getSpanContext, isSampled, wrapSpanContext)
import OpenTelemetry.Trace.Id (Base (..), SpanId, TraceId, baseEncodedToSpanId, baseEncodedToTraceId)
import qualified OpenTelemetry.Trace.TraceState as TS
import Test.Hspec


main :: IO ()
main = hspec spec


spec :: Spec
spec = describe "OpenTelemetry.Propagator.B3" $ do
  describe "extraction" $ do
    it "extracts SpanContext from the single b3 header (sampled)" $ do
      let headers =
            textMapFromList
              [
                ( "b3"
                , "80f198ee56343ba864fe8b2a57d3eff7-e457b5a2e4d86bd1-1"
                )
              ]
      ctx' <- extractor b3TraceContextPropagator headers empty
      assertExpectedRemoteSampled ctx'

    it "extracts the same SpanContext from multi-header B3 (sampled)" $ do
      let headers =
            textMapFromList
              [ ("x-b3-traceid", "80f198ee56343ba864fe8b2a57d3eff7")
              , ("x-b3-spanid", "e457b5a2e4d86bd1")
              , ("x-b3-sampled", "1")
              ]
      ctx' <- extractor b3MultiTraceContextPropagator headers empty
      assertExpectedRemoteSampled ctx'

    it "leaves the context unchanged when headers are missing" $ do
      ctx1 <- extractor b3TraceContextPropagator emptyTextMap empty
      ctx2 <- extractor b3MultiTraceContextPropagator emptyTextMap empty
      lookupSpan ctx1 `shouldSatisfy` isNothing
      lookupSpan ctx2 `shouldSatisfy` isNothing

    it "extracts SpanContext with sampled bit unset when b3 ends in -0" $ do
      let headers =
            textMapFromList
              [
                ( "b3"
                , "80f198ee56343ba864fe8b2a57d3eff7-e457b5a2e4d86bd1-0"
                )
              ]
      ctx' <- extractor b3TraceContextPropagator headers empty
      case lookupSpan ctx' of
        Nothing -> expectationFailure "expected span in context"
        Just span -> do
          sc <- getSpanContext span
          traceId sc `shouldBe` expectedTraceId
          spanId sc `shouldBe` expectedSpanId
          isRemote sc `shouldBe` True
          isSampled (traceFlags sc) `shouldBe` False

    it "debug flag takes precedence over X-B3-Sampled: 0 in multi-header" $ do
      let headers =
            textMapFromList
              [ ("x-b3-traceid", "80f198ee56343ba864fe8b2a57d3eff7")
              , ("x-b3-spanid", "e457b5a2e4d86bd1")
              , ("x-b3-sampled", "0")
              , ("x-b3-flags", "1")
              ]
      ctx' <- extractor b3MultiTraceContextPropagator headers empty
      case lookupSpan ctx' of
        Nothing -> expectationFailure "expected span in context"
        Just span -> do
          sc <- getSpanContext span
          traceId sc `shouldBe` expectedTraceId
          spanId sc `shouldBe` expectedSpanId
          isRemote sc `shouldBe` True
          isSampled (traceFlags sc) `shouldBe` True

    it "X-B3-Sampled: 0 alone means unsampled in multi-header" $ do
      let headers =
            textMapFromList
              [ ("x-b3-traceid", "80f198ee56343ba864fe8b2a57d3eff7")
              , ("x-b3-spanid", "e457b5a2e4d86bd1")
              , ("x-b3-sampled", "0")
              ]
      ctx' <- extractor b3MultiTraceContextPropagator headers empty
      case lookupSpan ctx' of
        Nothing -> expectationFailure "expected span in context"
        Just span -> do
          sc <- getSpanContext span
          isSampled (traceFlags sc) `shouldBe` False

  describe "injection" $ do
    it "injects the b3 single header with traceId-spanId" $ do
      let ctx = insertSpan (wrapSpanContext sampleSpanContext) empty
      hs <- injector b3TraceContextPropagator ctx emptyTextMap
      case textMapLookup B3I.b3Header hs of
        Nothing -> expectationFailure "expected b3 header"
        Just v -> case T.splitOn "-" v of
          [tid, sid] -> do
            tid `shouldBe` traceIdHex
            sid `shouldBe` spanIdHex
          _ ->
            expectationFailure $
              "expected traceId-spanId in b3 header, got: " ++ show v

    it "injects X-B3-TraceId and X-B3-SpanId for multi-header propagation" $ do
      let ctx = insertSpan (wrapSpanContext sampleSpanContext) empty
      hs <- injector b3MultiTraceContextPropagator ctx emptyTextMap
      textMapLookup B3I.xb3TraceIdHeader hs `shouldBe` Just traceIdHex
      textMapLookup B3I.xb3SpanIdHeader hs `shouldBe` Just spanIdHex

  describe "B3 Internal" $ do
    it "decodeXb3TraceIdHeader parses 128-bit trace ID" $ do
      B3I.decodeXb3TraceIdHeader "80f198ee56343ba864fe8b2a57d3eff7" `shouldSatisfy` isJust

    it "decodeXb3TraceIdHeader parses 64-bit trace ID (zero-padded)" $ do
      B3I.decodeXb3TraceIdHeader "e457b5a2e4d86bd1" `shouldSatisfy` isJust

    it "decodeXb3TraceIdHeader rejects invalid hex" $ do
      B3I.decodeXb3TraceIdHeader "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz" `shouldBe` Nothing

    it "decodeXb3TraceIdHeader rejects empty" $ do
      B3I.decodeXb3TraceIdHeader "" `shouldBe` Nothing

    it "decodeXb3SpanIdHeader parses valid span ID" $ do
      B3I.decodeXb3SpanIdHeader "e457b5a2e4d86bd1" `shouldSatisfy` isJust

    it "decodeXb3SpanIdHeader rejects too-short hex" $ do
      B3I.decodeXb3SpanIdHeader "e457" `shouldBe` Nothing

    it "decodeB3SingleHeader parses full header with parent" $ do
      let hdr = "80f198ee56343ba864fe8b2a57d3eff7-e457b5a2e4d86bd1-1-05e3ac9a4f6e3b90"
      case B3I.decodeB3SingleHeader hdr of
        Nothing -> expectationFailure "expected parse"
        Just b3 -> do
          B3I.parentSpanId b3 `shouldSatisfy` isJust
          B3I.spanId b3 `shouldBe` expectedSpanId
          B3I.traceId b3 `shouldBe` expectedTraceId

    it "decodeB3SingleHeader parses header with sampling=d (debug)" $ do
      let hdr = "80f198ee56343ba864fe8b2a57d3eff7-e457b5a2e4d86bd1-d"
      case B3I.decodeB3SingleHeader hdr of
        Nothing -> expectationFailure "expected parse"
        Just b3 -> (B3I.samplingState b3 == B3I.Debug) `shouldBe` True

    it "decodeB3SingleHeader parses header without sampling" $ do
      let hdr = "80f198ee56343ba864fe8b2a57d3eff7-e457b5a2e4d86bd1"
      case B3I.decodeB3SingleHeader hdr of
        Nothing -> expectationFailure "expected parse"
        Just b3 -> (B3I.samplingState b3 == B3I.Defer) `shouldBe` True

    it "decodeXb3SampledHeader parses 1 as Accept" $ do
      (B3I.decodeXb3SampledHeader "1" == Just B3I.Accept) `shouldBe` True

    it "decodeXb3SampledHeader parses 0 as Deny" $ do
      (B3I.decodeXb3SampledHeader "0" == Just B3I.Deny) `shouldBe` True

    it "decodeXb3FlagsHeader parses 1 as Debug" $ do
      (B3I.decodeXb3FlagsHeader "1" == Just B3I.Debug) `shouldBe` True

    it "decodeXb3FlagsHeader rejects 0" $ do
      isNothing (B3I.decodeXb3FlagsHeader "0") `shouldBe` True


traceIdHex :: T.Text
traceIdHex = "80f198ee56343ba864fe8b2a57d3eff7"


spanIdHex :: T.Text
spanIdHex = "e457b5a2e4d86bd1"


expectedTraceId :: TraceId
expectedTraceId =
  case baseEncodedToTraceId Base16 (TE.encodeUtf8 traceIdHex) of
    Right t -> t
    Left e -> error ("expectedTraceId: " ++ e)


expectedSpanId :: SpanId
expectedSpanId =
  case baseEncodedToSpanId Base16 (TE.encodeUtf8 spanIdHex) of
    Right s -> s
    Left e -> error ("expectedSpanId: " ++ e)


sampleSpanContext :: SpanContext
sampleSpanContext =
  SpanContext
    { traceId = expectedTraceId
    , spanId = expectedSpanId
    , isRemote = False
    , traceFlags = TraceFlags 1
    , traceState = TS.empty
    }


assertExpectedRemoteSampled :: Context -> IO ()
assertExpectedRemoteSampled ctx' =
  case lookupSpan ctx' of
    Nothing -> expectationFailure "expected span in context"
    Just span -> do
      sc <- getSpanContext span
      traceId sc `shouldBe` expectedTraceId
      spanId sc `shouldBe` expectedSpanId
      isRemote sc `shouldBe` True
      isSampled (traceFlags sc) `shouldBe` True
