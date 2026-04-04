{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.Propagator.Datadog (
  datadogTraceContextPropagator,
  convertOpenTelemetrySpanIdToDatadogSpanId,
  convertOpenTelemetryTraceIdToDatadogTraceId,

  -- * Registry integration
  registerDatadogPropagator,
) where

import qualified Data.ByteString.Char8 as BC
import qualified Data.ByteString.Short.Internal as SBI
import Data.Primitive (ByteArray (ByteArray))
import Data.Text (Text)
import qualified Data.Text.Encoding as TE
import Data.Word (Word64)
import OpenTelemetry.Common (TraceFlags (TraceFlags))
import OpenTelemetry.Context (
  Context,
  insertSpan,
  lookupSpan,
 )
import OpenTelemetry.Internal.Trace.Id (
  SpanId (SpanId),
  TraceId (TraceId),
 )
import OpenTelemetry.Propagator (Propagator (Propagator, extractor, injector, propagatorFields), TextMap, textMapInsert, textMapLookup)
import OpenTelemetry.Propagator.Datadog.Internal (
  indexByteArrayNbo,
  newHeaderFromSpanId,
  newHeaderFromTraceId,
  newSpanIdFromHeader,
  newTraceIdFromHeader,
 )
import OpenTelemetry.Registry (registerTextMapPropagator)
import OpenTelemetry.Trace.Core (
  SpanContext (SpanContext, isRemote, spanId, traceFlags, traceId, traceState),
  getSpanContext,
  isSampled,
  wrapSpanContext,
 )
import OpenTelemetry.Trace.TraceState (TraceState (TraceState))
import qualified OpenTelemetry.Trace.TraceState as TS


-- Reference: bi-directional conversion of IDs of Open Telemetry and ones of Datadog
-- - English: https://docs.datadoghq.com/tracing/other_telemetry/connect_logs_and_traces/opentelemetry/
-- - Japanese: https://docs.datadoghq.com/ja/tracing/connect_logs_and_traces/opentelemetry/
datadogTraceContextPropagator :: Propagator Context TextMap TextMap
datadogTraceContextPropagator =
  Propagator
    { propagatorFields = [traceIdKey, parentIdKey, samplingPriorityKey]
    , extractor = \tm c -> do
        let spanContext' = do
              traceId <- TraceId . newTraceIdFromHeader . TE.encodeUtf8 <$> textMapLookup traceIdKey tm
              parentId <- SpanId . newSpanIdFromHeader . TE.encodeUtf8 <$> textMapLookup parentIdKey tm
              let rawPriority = textMapLookup samplingPriorityKey tm
                  priorityInt = rawPriority >>= (fmap fst . BC.readInt . TE.encodeUtf8)
                  sampled = maybe True (> 0) priorityInt
              pure $
                SpanContext
                  { traceId
                  , spanId = parentId
                  , isRemote = True
                  , traceFlags = if sampled then TraceFlags 1 else TraceFlags 0
                  , traceState = case rawPriority of
                      Just p -> TraceState [(TS.Key samplingPriorityKey, TS.Value p)]
                      Nothing -> TraceState []
                  }
        case spanContext' of
          Nothing -> pure c
          Just spanContext -> pure $ insertSpan (wrapSpanContext spanContext) c
    , injector = \c tm ->
        case lookupSpan c of
          Nothing -> pure tm
          Just span' -> do
            SpanContext {traceId, spanId, traceFlags, traceState = TraceState traceState} <- getSpanContext span'
            let traceIdValue = TE.decodeUtf8 $ (\(TraceId b) -> newHeaderFromTraceId b) traceId
                parentIdValue = TE.decodeUtf8 $ (\(SpanId b) -> newHeaderFromSpanId b) spanId
                samplingPriority = case lookup (TS.Key samplingPriorityKey) traceState of
                  Just (TS.Value p) -> p
                  Nothing -> if isSampled traceFlags then "1" else "0"
            pure
              $ textMapInsert traceIdKey traceIdValue
              $ textMapInsert parentIdKey parentIdValue
              $ textMapInsert samplingPriorityKey samplingPriority
              $ tm
    }
  where
    traceIdKey, parentIdKey, samplingPriorityKey :: Text
    traceIdKey = "x-datadog-trace-id"
    parentIdKey = "x-datadog-parent-id"
    samplingPriorityKey = "x-datadog-sampling-priority"


convertOpenTelemetrySpanIdToDatadogSpanId :: SpanId -> Word64
convertOpenTelemetrySpanIdToDatadogSpanId (SpanId (SBI.SBS a)) = indexByteArrayNbo (ByteArray a) 0


convertOpenTelemetryTraceIdToDatadogTraceId :: TraceId -> Word64
convertOpenTelemetryTraceIdToDatadogTraceId (TraceId (SBI.SBS a)) = indexByteArrayNbo (ByteArray a) 1


{- | Register the Datadog propagator under the name @\"datadog\"@ in
the global registry.

@since 0.0.1.1
-}
registerDatadogPropagator :: IO ()
registerDatadogPropagator =
  registerTextMapPropagator "datadog" datadogTraceContextPropagator
