{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.Propagator.XRaySpec (spec) where

import Data.Maybe (isJust, isNothing)
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import OpenTelemetry.Common (TraceFlags (..))
import OpenTelemetry.Context (Context, empty, insertSpan, lookupSpan)
import OpenTelemetry.Propagator (
  Propagator (..),
  TextMap,
  emptyTextMap,
  textMapFromList,
  textMapLookup,
 )
import OpenTelemetry.Propagator.XRay (xrayPropagator)
import OpenTelemetry.Propagator.XRay.Internal
import qualified OpenTelemetry.Trace.Core as Core
import OpenTelemetry.Trace.Id (
  Base (..),
  SpanId,
  TraceId,
  baseEncodedToSpanId,
  baseEncodedToTraceId,
 )
import OpenTelemetry.Trace.TraceState (TraceState (..))
import Test.Hspec


mkTraceId :: String -> TraceId
mkTraceId hex = case baseEncodedToTraceId Base16 (TE.encodeUtf8 $ T.pack hex) of
  Right tid -> tid
  Left err -> error $ "bad test trace id: " ++ err


mkSpanId :: String -> SpanId
mkSpanId hex = case baseEncodedToSpanId Base16 (TE.encodeUtf8 $ T.pack hex) of
  Right sid -> sid
  Left err -> error $ "bad test span id: " ++ err


mkContext :: TraceId -> SpanId -> Bool -> IO Context
mkContext tid sid sampled = do
  let sc =
        Core.SpanContext
          { Core.traceId = tid
          , Core.spanId = sid
          , Core.isRemote = False
          , Core.traceFlags = if sampled then TraceFlags 1 else TraceFlags 0
          , Core.traceState = TraceState []
          }
  pure $ insertSpan (Core.wrapSpanContext sc) empty


extractWith :: T.Text -> IO Context
extractWith headerVal = do
  let tm = textMapFromList [("x-amzn-trace-id", headerVal)]
  extractor xrayPropagator tm empty


spec :: Spec
spec =
  -- AWS X-Ray tracing header (Root, Parent, Sampled)
  -- https://docs.aws.amazon.com/xray/latest/devguide/xray-concepts.html#xray-concepts-tracingheader
  describe "OpenTelemetry.Propagator.XRay" $ do
    describe "Internal: trace ID conversion" $ do
      -- Root=1-{8 hex epoch}-{24 hex unique}
      -- https://docs.aws.amazon.com/xray/latest/devguide/xray-concepts.html#xray-concepts-tracingheader
      it "converts OTel trace ID to X-Ray format" $ do
        let tid = mkTraceId "5759e988bd862e3fe1be46a994272793"
        otelTraceIdToXRay tid `shouldBe` "1-5759e988-bd862e3fe1be46a994272793"

      it "converts X-Ray trace ID back to OTel format" $ do
        let expected = mkTraceId "5759e988bd862e3fe1be46a994272793"
        xrayTraceIdToOTel "1-5759e988-bd862e3fe1be46a994272793" `shouldBe` Just expected

      it "round-trips trace ID through X-Ray encoding" $ do
        let tid = mkTraceId "463ac35c9f6413ad48485a3953bb6124"
            xray = otelTraceIdToXRay tid
        xrayTraceIdToOTel xray `shouldBe` Just tid

      it "rejects trace ID with wrong version" $ do
        xrayTraceIdToOTel "2-5759e988-bd862e3fe1be46a994272793" `shouldBe` Nothing

      it "rejects trace ID with wrong length" $ do
        xrayTraceIdToOTel "1-5759e988-bd862e3fe1be46a99427279" `shouldBe` Nothing

      it "rejects trace ID with missing delimiters" $ do
        xrayTraceIdToOTel "1-5759e988bd862e3fe1be46a994272793" `shouldBe` Nothing

    describe "Internal: header parsing" $ do
      it "parses a standard X-Ray header" $ do
        let hdr = "Root=1-5759e988-bd862e3fe1be46a994272793;Parent=53995c3f42cd8ad8;Sampled=1"
        let result = decodeXRayHeader hdr
        result `shouldSatisfy` \case
          Just xh ->
            xhTraceId xh == mkTraceId "5759e988bd862e3fe1be46a994272793"
              && xhSpanId xh == mkSpanId "53995c3f42cd8ad8"
              && xhSampled xh
          Nothing -> False

      it "parses header with Sampled=0" $ do
        let hdr = "Root=1-5759e988-bd862e3fe1be46a994272793;Parent=53995c3f42cd8ad8;Sampled=0"
        let result = decodeXRayHeader hdr
        result `shouldSatisfy` \case
          Just xh -> not (xhSampled xh)
          Nothing -> False

      it "handles missing Sampled field (defaults to not sampled)" $ do
        let hdr = "Root=1-5759e988-bd862e3fe1be46a994272793;Parent=53995c3f42cd8ad8"
        let result = decodeXRayHeader hdr
        result `shouldSatisfy` \case
          Just xh -> not (xhSampled xh)
          Nothing -> False

      it "handles reordered fields" $ do
        let hdr = "Sampled=1;Parent=53995c3f42cd8ad8;Root=1-5759e988-bd862e3fe1be46a994272793"
        let result = decodeXRayHeader hdr
        result `shouldSatisfy` \case
          Just xh ->
            xhTraceId xh == mkTraceId "5759e988bd862e3fe1be46a994272793"
              && xhSpanId xh == mkSpanId "53995c3f42cd8ad8"
              && xhSampled xh
          Nothing -> False

      it "ignores extra fields (Self, Lineage, etc.)" $ do
        let hdr = "Root=1-5759e988-bd862e3fe1be46a994272793;Parent=53995c3f42cd8ad8;Sampled=1;Self=1-abc12345-def67890123456789012"
        let result = decodeXRayHeader hdr
        result `shouldSatisfy` \case
          Just xh ->
            xhTraceId xh == mkTraceId "5759e988bd862e3fe1be46a994272793"
              && xhSampled xh
          Nothing -> False

      it "handles spaces around semicolons" $ do
        let hdr = "Root=1-5759e988-bd862e3fe1be46a994272793 ; Parent=53995c3f42cd8ad8 ; Sampled=1"
        let result = decodeXRayHeader hdr
        result `shouldSatisfy` \case
          Just xh ->
            xhTraceId xh == mkTraceId "5759e988bd862e3fe1be46a994272793"
          Nothing -> False

      it "rejects header with missing Root" $ do
        let hdr = "Parent=53995c3f42cd8ad8;Sampled=1"
        decodeXRayHeader hdr `shouldSatisfy` isNothing

      it "rejects header with missing Parent" $ do
        let hdr = "Root=1-5759e988-bd862e3fe1be46a994272793;Sampled=1"
        decodeXRayHeader hdr `shouldSatisfy` isNothing

      it "rejects header with invalid trace ID" $ do
        let hdr = "Root=1-ZZZZZZZZ-bd862e3fe1be46a994272793;Parent=53995c3f42cd8ad8;Sampled=1"
        decodeXRayHeader hdr `shouldSatisfy` isNothing

      it "rejects empty header" $ do
        decodeXRayHeader "" `shouldSatisfy` isNothing

    describe "trace context extraction" $ do
      it "extracts sampled span context from header" $ do
        ctx <- extractWith "Root=1-65a8c9d2-0abcdef1234567890abcdef0;Parent=53995c3f42cd8ad8;Sampled=1"
        case lookupSpan ctx of
          Nothing -> expectationFailure "expected span in context"
          Just span' -> do
            sc <- Core.getSpanContext span'
            Core.traceId sc `shouldBe` mkTraceId "65a8c9d20abcdef1234567890abcdef0"
            Core.spanId sc `shouldBe` mkSpanId "53995c3f42cd8ad8"
            Core.isRemote sc `shouldBe` True
            Core.isSampled (Core.traceFlags sc) `shouldBe` True

      it "extracts unsampled span context from header" $ do
        ctx <- extractWith "Root=1-65a8c9d2-0abcdef1234567890abcdef0;Parent=53995c3f42cd8ad8;Sampled=0"
        case lookupSpan ctx of
          Nothing -> expectationFailure "expected span in context"
          Just span' -> do
            sc <- Core.getSpanContext span'
            Core.isSampled (Core.traceFlags sc) `shouldBe` False

      it "returns unchanged context when header is missing" $ do
        ctx <- extractor xrayPropagator emptyTextMap empty
        lookupSpan ctx `shouldSatisfy` (not . isJust)

      it "returns unchanged context on malformed header" $ do
        ctx <- extractWith "not-a-valid-header"
        lookupSpan ctx `shouldSatisfy` (not . isJust)

    describe "trace context injection" $ do
      it "injects X-Ray header from span context" $ do
        let tid = mkTraceId "65a8c9d20abcdef1234567890abcdef0"
            sid = mkSpanId "53995c3f42cd8ad8"
        ctx <- mkContext tid sid True
        tm <- injector xrayPropagator ctx emptyTextMap
        textMapLookup "x-amzn-trace-id" tm
          `shouldBe` Just "Root=1-65a8c9d2-0abcdef1234567890abcdef0;Parent=53995c3f42cd8ad8;Sampled=1"

      it "injects unsampled X-Ray header" $ do
        let tid = mkTraceId "65a8c9d20abcdef1234567890abcdef0"
            sid = mkSpanId "53995c3f42cd8ad8"
        ctx <- mkContext tid sid False
        tm <- injector xrayPropagator ctx emptyTextMap
        textMapLookup "x-amzn-trace-id" tm
          `shouldBe` Just "Root=1-65a8c9d2-0abcdef1234567890abcdef0;Parent=53995c3f42cd8ad8;Sampled=0"

      it "does not inject when no span in context" $ do
        tm <- injector xrayPropagator empty emptyTextMap
        textMapLookup "x-amzn-trace-id" tm `shouldBe` Nothing

    describe "round-trip" $ do
      it "inject then extract preserves trace identity" $ do
        let tid = mkTraceId "5759e988bd862e3fe1be46a994272793"
            sid = mkSpanId "abcdef0123456789"
        ctx <- mkContext tid sid True
        tm <- injector xrayPropagator ctx emptyTextMap
        ctx' <- extractor xrayPropagator tm empty
        case lookupSpan ctx' of
          Nothing -> expectationFailure "expected span after round-trip"
          Just span' -> do
            sc <- Core.getSpanContext span'
            Core.traceId sc `shouldBe` tid
            Core.spanId sc `shouldBe` sid
            Core.isSampled (Core.traceFlags sc) `shouldBe` True
            Core.isRemote sc `shouldBe` True

      it "round-trips unsampled spans" $ do
        let tid = mkTraceId "0000000100000002000000030000000f"
            sid = mkSpanId "1234567890abcdef"
        ctx <- mkContext tid sid False
        tm <- injector xrayPropagator ctx emptyTextMap
        ctx' <- extractor xrayPropagator tm empty
        case lookupSpan ctx' of
          Nothing -> expectationFailure "expected span after round-trip"
          Just span' -> do
            sc <- Core.getSpanContext span'
            Core.traceId sc `shouldBe` tid
            Core.spanId sc `shouldBe` sid
            Core.isSampled (Core.traceFlags sc) `shouldBe` False

    -- X-Ray vs W3C in same carrier (extractor behavior with multiple formats)
    describe "W3C interoperability" $ do
      it "works alongside W3C headers in the same TextMap" $ do
        let tm =
              textMapFromList
                [ ("traceparent", "00-65a8c9d20abcdef1234567890abcdef0-53995c3f42cd8ad8-01")
                , ("x-amzn-trace-id", "Root=1-65a8c9d2-0abcdef1234567890abcdef0;Parent=53995c3f42cd8ad8;Sampled=1")
                ]
        ctx <- extractor xrayPropagator tm empty
        case lookupSpan ctx of
          Nothing -> expectationFailure "expected X-Ray extraction to succeed"
          Just span' -> do
            sc <- Core.getSpanContext span'
            Core.traceId sc `shouldBe` mkTraceId "65a8c9d20abcdef1234567890abcdef0"

      it "injected header can be extracted by the same propagator" $ do
        let tid = mkTraceId "aabbccdd11223344aabbccdd11223344"
            sid = mkSpanId "ff00ff00ff00ff00"
        ctx <- mkContext tid sid True
        tm <- injector xrayPropagator ctx emptyTextMap
        let headerVal = textMapLookup "x-amzn-trace-id" tm
        headerVal `shouldSatisfy` \case
          Just v -> "Root=1-aabbccdd-11223344aabbccdd11223344" `T.isPrefixOf` v
          Nothing -> False
