{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -Wno-type-defaults #-}

module OpenTelemetry.Propagator.DatadogSpec where

import qualified Data.ByteString as B
import Data.Maybe (isNothing)
import Data.Text (Text)
import Data.Word (Word8)
import OpenTelemetry.Common (TraceFlags (..))
import OpenTelemetry.Context (empty, insertSpan, lookupSpan)
import OpenTelemetry.Internal.Trace.Id
import OpenTelemetry.Propagator (
  Propagator (..),
  TextMap,
  emptyTextMap,
  textMapFromList,
  textMapLookup,
 )
import OpenTelemetry.Propagator.Datadog
import OpenTelemetry.Trace.Core (SpanContext (..), getSpanContext, isSampled, wrapSpanContext)
import qualified OpenTelemetry.Trace.TraceState as TS
import Test.Hspec
import Test.QuickCheck


mkTraceId :: [Word8] -> TraceId
mkTraceId bs = case bytesToTraceId (B.pack bs) of
  Right t -> t
  Left _ -> error "bad trace id"


mkSpanId :: [Word8] -> SpanId
mkSpanId bs = case bytesToSpanId (B.pack bs) of
  Right s -> s
  Left _ -> error "bad span id"


spec :: Spec
spec =
  -- Datadog HTTP headers for distributed tracing propagation
  -- https://docs.datadoghq.com/tracing/trace_collection/trace_context_propagation/
  do
    context "convertOpenTelemetrySpanIdToDatadogSpanId" $ do
      -- Trace id / span id mapping (64-bit decimal in headers)
      -- https://docs.datadoghq.com/tracing/trace_collection/trace_context_propagation/
      it "can conert values" $
        property $ \(x1, x2, x3, x4, x5, x6, x7, x8) -> do
          let v =
                fromIntegral x1 * (2 ^ 8) ^ 7
                  + fromIntegral x2 * (2 ^ 8) ^ 6
                  + fromIntegral x3 * (2 ^ 8) ^ 5
                  + fromIntegral x4 * (2 ^ 8) ^ 4
                  + fromIntegral x5 * (2 ^ 8) ^ 3
                  + fromIntegral x6 * (2 ^ 8) ^ 2
                  + fromIntegral x7 * (2 ^ 8) ^ 1
                  + fromIntegral x8
              otSid = mkSpanId [x1, x2, x3, x4, x5, x6, x7, x8]
          convertOpenTelemetrySpanIdToDatadogSpanId otSid `shouldBe` v

    context "convertOpenTelemetryTraceIdToDatadogTraceId" $ do
      -- 128-bit OTel trace id → 64-bit Datadog trace id (lower 64 bits)
      -- https://docs.datadoghq.com/tracing/trace_collection/trace_context_propagation/
      it "can conert values" $
        property $ \(x1, x2, x3, x4, x5, x6, x7, x8) -> do
          let v =
                fromIntegral x1 * (2 ^ 8) ^ 7
                  + fromIntegral x2 * (2 ^ 8) ^ 6
                  + fromIntegral x3 * (2 ^ 8) ^ 5
                  + fromIntegral x4 * (2 ^ 8) ^ 4
                  + fromIntegral x5 * (2 ^ 8) ^ 3
                  + fromIntegral x6 * (2 ^ 8) ^ 2
                  + fromIntegral x7 * (2 ^ 8) ^ 1
                  + fromIntegral x8
              otTid = mkTraceId $ replicate 8 0 ++ [x1, x2, x3, x4, x5, x6, x7, x8]
          convertOpenTelemetryTraceIdToDatadogTraceId otTid `shouldBe` v

    context "extraction" $ do
      let mkHeaders :: Text -> Text -> Maybe Text -> TextMap
          mkHeaders tid sid mPriority =
            textMapFromList $
              [ ("x-datadog-trace-id", tid)
              , ("x-datadog-parent-id", sid)
              ]
                ++ maybe [] (\p -> [("x-datadog-sampling-priority", p)]) mPriority

      -- x-datadog-sampling-priority: 1 = keep / sampled
      -- https://docs.datadoghq.com/tracing/trace_collection/trace_context_propagation/
      it "extracts sampled span when priority is 1" $ do
        let hs = mkHeaders "12345" "67890" (Just "1")
        ctx' <- extractor datadogTraceContextPropagator hs empty
        case lookupSpan ctx' of
          Nothing -> expectationFailure "expected span in context"
          Just span -> do
            sc <- getSpanContext span
            isRemote sc `shouldBe` True
            isSampled (traceFlags sc) `shouldBe` True

      -- Priority 2: user keep
      -- https://docs.datadoghq.com/tracing/trace_collection/trace_context_propagation/
      it "extracts sampled span when priority is 2 (user keep)" $ do
        let hs = mkHeaders "12345" "67890" (Just "2")
        ctx' <- extractor datadogTraceContextPropagator hs empty
        case lookupSpan ctx' of
          Nothing -> expectationFailure "expected span in context"
          Just span -> do
            sc <- getSpanContext span
            isSampled (traceFlags sc) `shouldBe` True

      it "extracts unsampled span when priority is 0" $ do
        let hs = mkHeaders "12345" "67890" (Just "0")
        ctx' <- extractor datadogTraceContextPropagator hs empty
        case lookupSpan ctx' of
          Nothing -> expectationFailure "expected span in context"
          Just span -> do
            sc <- getSpanContext span
            isSampled (traceFlags sc) `shouldBe` False

      it "extracts unsampled span when priority is -1 (user reject)" $ do
        let hs = mkHeaders "12345" "67890" (Just "-1")
        ctx' <- extractor datadogTraceContextPropagator hs empty
        case lookupSpan ctx' of
          Nothing -> expectationFailure "expected span in context"
          Just span -> do
            sc <- getSpanContext span
            isSampled (traceFlags sc) `shouldBe` False

      it "defaults to sampled when priority header is absent" $ do
        let hs = mkHeaders "12345" "67890" Nothing
        ctx' <- extractor datadogTraceContextPropagator hs empty
        case lookupSpan ctx' of
          Nothing -> expectationFailure "expected span in context"
          Just span -> do
            sc <- getSpanContext span
            isSampled (traceFlags sc) `shouldBe` True

      -- Required headers: x-datadog-trace-id, x-datadog-parent-id
      -- https://docs.datadoghq.com/tracing/trace_collection/trace_context_propagation/
      it "returns unchanged context when trace-id header is missing" $ do
        let hs = textMapFromList [("x-datadog-parent-id", "67890")]
        ctx' <- extractor datadogTraceContextPropagator hs empty
        lookupSpan ctx' `shouldSatisfy` isNothing

      it "returns unchanged context when parent-id header is missing" $ do
        let hs = textMapFromList [("x-datadog-trace-id", "12345")]
        ctx' <- extractor datadogTraceContextPropagator hs empty
        lookupSpan ctx' `shouldSatisfy` isNothing

      it "returns unchanged context when both headers missing" $ do
        ctx' <- extractor datadogTraceContextPropagator emptyTextMap empty
        lookupSpan ctx' `shouldSatisfy` isNothing

      it "handles non-numeric sampling priority gracefully" $ do
        let hs = mkHeaders "12345" "67890" (Just "abc")
        ctx' <- extractor datadogTraceContextPropagator hs empty
        case lookupSpan ctx' of
          Nothing -> expectationFailure "expected span in context"
          Just span -> do
            sc <- getSpanContext span
            isSampled (traceFlags sc) `shouldBe` True

    context "injection" $ do
      -- Inject x-datadog-sampling-priority from sampling decision
      -- https://docs.datadoghq.com/tracing/trace_collection/trace_context_propagation/
      it "injects sampling priority 1 for sampled span" $ do
        let sc =
              SpanContext
                { traceId = mkTraceId (replicate 8 0 ++ [0, 0, 0, 0, 0, 0, 0, 1])
                , spanId = mkSpanId [0, 0, 0, 0, 0, 0, 0, 2]
                , isRemote = False
                , traceFlags = TraceFlags 1
                , traceState = TS.TraceState []
                }
            ctx = insertSpan (wrapSpanContext sc) empty
        hs <- injector datadogTraceContextPropagator ctx emptyTextMap
        textMapLookup "x-datadog-sampling-priority" hs `shouldBe` Just "1"

      it "injects sampling priority 0 for unsampled span" $ do
        let sc =
              SpanContext
                { traceId = mkTraceId (replicate 8 0 ++ [0, 0, 0, 0, 0, 0, 0, 1])
                , spanId = mkSpanId [0, 0, 0, 0, 0, 0, 0, 2]
                , isRemote = False
                , traceFlags = TraceFlags 0
                , traceState = TS.TraceState []
                }
            ctx = insertSpan (wrapSpanContext sc) empty
        hs <- injector datadogTraceContextPropagator ctx emptyTextMap
        textMapLookup "x-datadog-sampling-priority" hs `shouldBe` Just "0"

      -- tracestate carries Datadog priority for round-trip
      -- https://docs.datadoghq.com/tracing/trace_collection/trace_context_propagation/
      it "preserves explicit priority from tracestate over traceFlags" $ do
        let sc =
              SpanContext
                { traceId = mkTraceId (replicate 8 0 ++ [0, 0, 0, 0, 0, 0, 0, 1])
                , spanId = mkSpanId [0, 0, 0, 0, 0, 0, 0, 2]
                , isRemote = False
                , traceFlags = TraceFlags 1
                , traceState = TS.TraceState [(TS.Key "x-datadog-sampling-priority", TS.Value "2")]
                }
            ctx = insertSpan (wrapSpanContext sc) empty
        hs <- injector datadogTraceContextPropagator ctx emptyTextMap
        textMapLookup "x-datadog-sampling-priority" hs `shouldBe` Just "2"
