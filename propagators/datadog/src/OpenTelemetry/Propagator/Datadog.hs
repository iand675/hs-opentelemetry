{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.Propagator.Datadog (
  datadogTraceContextPropagator,
  convertOpenTelemetrySpanIdToDatadogSpanId,
  convertOpenTelemetryTraceIdToDatadogTraceId,
) where

import qualified Data.ByteString.Char8 as BC
import qualified Data.ByteString.Short as SB
import qualified Data.ByteString.Short.Internal as SBI
import Data.Primitive (ByteArray (ByteArray))
import Data.String (IsString)
import qualified Data.Text as T
import Data.Word (Word64)
import Network.HTTP.Types (RequestHeaders)
import OpenTelemetry.Common (TraceFlags (TraceFlags))
import OpenTelemetry.Context (
  Context,
  insertSpan,
  lookupSpan,
 )
import OpenTelemetry.Internal.Trace.Id (
  SpanId,
  TraceId,
  bytesToSpanId,
  bytesToTraceId,
 )
import OpenTelemetry.Propagator (Propagator (Propagator, extractor, injector, propagatorFields))
import OpenTelemetry.Propagator.Datadog.Internal (
  indexByteArrayNbo,
  newHeaderFromSpanId,
  newHeaderFromTraceId,
  newSpanIdFromHeader,
  newTraceIdFromHeader,
 )
import OpenTelemetry.Trace.Core (
  SpanContext (SpanContext, isRemote, spanId, traceFlags, traceId, traceState),
  getSpanContext,
  wrapSpanContext,
 )
import OpenTelemetry.Trace.Id (spanIdBytes, traceIdBytes)
import OpenTelemetry.Trace.TraceState (TraceState (TraceState))
import qualified OpenTelemetry.Trace.TraceState as TS


-- Reference: bi-directional conversion of IDs of Open Telemetry and ones of Datadog
-- - English: https://docs.datadoghq.com/tracing/other_telemetry/connect_logs_and_traces/opentelemetry/
-- - Japanese: https://docs.datadoghq.com/ja/tracing/connect_logs_and_traces/opentelemetry/
datadogTraceContextPropagator :: Propagator Context RequestHeaders RequestHeaders
datadogTraceContextPropagator =
  Propagator
    { propagatorFields = ["datadog trace context"]
    , extractor = \hs c -> do
        let spanContext' = do
              tidBs <- lookup traceIdKey hs
              sidBs <- lookup parentIdKey hs
              traceId <- eitherToMaybe $ bytesToTraceId $ SB.fromShort $ newTraceIdFromHeader tidBs
              parentId <- eitherToMaybe $ bytesToSpanId $ SB.fromShort $ newSpanIdFromHeader sidBs
              samplingPriority <- T.pack . BC.unpack <$> lookup samplingPriorityKey hs
              pure $
                SpanContext
                  { traceId
                  , spanId = parentId
                  , isRemote = True
                  , -- when 0, not sampled
                    -- refer: OpenTelemetry.Internal.Trace.Types.isSampled
                    traceFlags = TraceFlags 1
                  , traceState = TraceState [(TS.Key samplingPriorityKey, TS.Value samplingPriority)]
                  }
        case spanContext' of
          Nothing -> pure c
          Just spanContext -> pure $ insertSpan (wrapSpanContext spanContext) c
    , injector = \c hs ->
        case lookupSpan c of
          Nothing -> pure hs
          Just span' -> do
            SpanContext {traceId, spanId, traceState = TraceState traceState} <- getSpanContext span'
            let traceIdValue = newHeaderFromTraceId $ shortFromTraceId traceId
                parentIdValue = newHeaderFromSpanId $ shortFromSpanId spanId
            samplingPriority <-
              case lookup (TS.Key samplingPriorityKey) traceState of
                Nothing -> pure "1" -- when an origin of the trace
                Just (TS.Value p) -> pure $ BC.pack $ T.unpack p
            pure $
              (traceIdKey, traceIdValue)
                : (parentIdKey, parentIdValue)
                : (samplingPriorityKey, samplingPriority)
                : hs
    }
  where
    traceIdKey, parentIdKey, samplingPriorityKey :: (IsString s) => s
    traceIdKey = "x-datadog-trace-id"
    parentIdKey = "x-datadog-parent-id"
    samplingPriorityKey = "x-datadog-sampling-priority"

    eitherToMaybe :: Either e a -> Maybe a
    eitherToMaybe = either (const Nothing) Just

    shortFromTraceId :: TraceId -> SB.ShortByteString
    shortFromTraceId = SB.toShort . traceIdBytes

    shortFromSpanId :: SpanId -> SB.ShortByteString
    shortFromSpanId = SB.toShort . spanIdBytes


convertOpenTelemetrySpanIdToDatadogSpanId :: SpanId -> Word64
convertOpenTelemetrySpanIdToDatadogSpanId s = case SB.toShort (spanIdBytes s) of
  SBI.SBS a -> indexByteArrayNbo (ByteArray a) 0


convertOpenTelemetryTraceIdToDatadogTraceId :: TraceId -> Word64
convertOpenTelemetryTraceIdToDatadogTraceId t = case SB.toShort (traceIdBytes t) of
  SBI.SBS a -> indexByteArrayNbo (ByteArray a) 1
