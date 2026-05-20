{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.Propagator.Datadog (
  datadogTraceContextPropagator,
  convertOpenTelemetrySpanIdToDatadogSpanId,
  convertOpenTelemetryTraceIdToDatadogTraceId,
) where

import Data.Bits (shiftL, (.|.))
import qualified Data.ByteString.Short as SB
import qualified Data.ByteString.Short.Internal as SBI
import Data.Primitive.ByteArray (ByteArray (ByteArray))
import qualified Data.Primitive.ByteArray as BA
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.Encoding as Text
import qualified Data.Text.Read as TR
import Data.Word (Word64, Word8)
import OpenTelemetry.Common (TraceFlags (TraceFlags))
import OpenTelemetry.Context (
  insertSpan,
  lookupSpan,
 )
import OpenTelemetry.Internal.Trace.Id (
  SpanId,
  TraceId,
 )
import OpenTelemetry.Propagator (
  Propagator (Propagator, extractor, injector, propagatorFields),
  TextMapPropagator,
  textMapInsert,
  textMapLookup,
 )
import OpenTelemetry.Propagator.Datadog.Internal (
  newHeaderFromSpanId,
  newHeaderFromTraceId,
  newSpanIdFromHeader,
  newTraceIdFromHeader,
 )
import OpenTelemetry.Trace.Core (
  SpanContext (SpanContext, isRemote, spanId, traceFlags, traceId, traceState),
  getSpanContext,
  isSampled,
  wrapSpanContext,
 )
import OpenTelemetry.Trace.Id (spanIdBytes, traceIdBytes)
import OpenTelemetry.Trace.TraceState (TraceState (TraceState), Value (Value))
import qualified OpenTelemetry.Trace.TraceState as TS


-- Reference: bi-directional conversion of IDs of Open Telemetry and ones of Datadog
-- - English: https://docs.datadoghq.com/tracing/other_telemetry/connect_logs_and_traces/opentelemetry/
-- - Japanese: https://docs.datadoghq.com/ja/tracing/connect_logs_and_traces/opentelemetry/
datadogTraceContextPropagator :: TextMapPropagator
datadogTraceContextPropagator =
  Propagator
    { propagatorFields = ["datadog trace context"]
    , extractor = \tm c -> do
        let spanContext' = do
              tidText <- textMapLookup traceIdKey tm
              sidText <- textMapLookup parentIdKey tm
              let tidBs = Text.encodeUtf8 tidText
                  sidBs = Text.encodeUtf8 sidText
                  traceId = newTraceIdFromHeader tidBs
                  parentId = newSpanIdFromHeader sidBs
                  mPri = textMapLookup samplingPriorityKey tm
                  (prioFlags, tsEntries) =
                    case mPri of
                      Nothing -> (TraceFlags 1, [])
                      Just txt ->
                        ( if datadogSamplingPriorityIndicatesSampled txt
                            then TraceFlags 1
                            else TraceFlags 0
                        , [(TS.Key samplingPriorityKey, TS.Value txt)]
                        )
              pure $
                SpanContext
                  { traceId
                  , spanId = parentId
                  , isRemote = True
                  , traceFlags = prioFlags
                  , traceState = TraceState tsEntries
                  }
        case spanContext' of
          Nothing -> pure c
          Just spanContext -> pure $ insertSpan (wrapSpanContext spanContext) c
    , injector = \c tm ->
        case lookupSpan c of
          Nothing -> pure tm
          Just span' -> do
            SpanContext {traceId, spanId, traceState = TraceState traceState, traceFlags} <- getSpanContext span'
            let traceIdValue = newHeaderFromTraceId traceId
                parentIdValue = newHeaderFromSpanId spanId
            samplingPriority <-
              case lookup (TS.Key samplingPriorityKey) traceState of
                Nothing ->
                  pure $
                    if isSampled traceFlags then "1" else "0"
                Just (Value p) -> pure p
            pure $
              textMapInsert samplingPriorityKey samplingPriority $
                textMapInsert parentIdKey (Text.decodeUtf8 parentIdValue) $
                  textMapInsert traceIdKey (Text.decodeUtf8 traceIdValue) tm
    }
  where
    traceIdKey, parentIdKey, samplingPriorityKey :: Text
    traceIdKey = "x-datadog-trace-id"
    parentIdKey = "x-datadog-parent-id"
    samplingPriorityKey = "x-datadog-sampling-priority"

    -- Parsed sampling decisions for Datadog @x-datadog-sampling-priority@.
    -- Non-numeric values are treated as sampled (upstream senders disagree;
    -- see propagator tests).
    datadogSamplingPriorityIndicatesSampled :: Text -> Bool
    datadogSamplingPriorityIndicatesSampled txt =
      case TR.signed TR.decimal (T.strip txt) of
        Right (n, rest)
          | T.null rest ->
              n > (0 :: Integer)
        _ -> True


-- | Read eight bytes at @8 * offset@ as a big-endian 'Word64'.
indexByteArrayNbo :: BA.ByteArray -> Int -> Word64
indexByteArrayNbo ba !off = go 0 0
  where
    !base = 8 * off
    go :: Int -> Word64 -> Word64
    go 8 !acc = acc
    go n !acc =
      let !b = fromIntegral (BA.indexByteArray ba (base + n) :: Word8) :: Word64
      in go (n + 1) ((acc `shiftL` 8) .|. b)


convertOpenTelemetrySpanIdToDatadogSpanId :: SpanId -> Word64
convertOpenTelemetrySpanIdToDatadogSpanId s = case SB.toShort (spanIdBytes s) of
  SBI.SBS a -> indexByteArrayNbo (ByteArray a) 0


convertOpenTelemetryTraceIdToDatadogTraceId :: TraceId -> Word64
convertOpenTelemetryTraceIdToDatadogTraceId t = case SB.toShort (traceIdBytes t) of
  SBI.SBS a -> indexByteArrayNbo (ByteArray a) 1
