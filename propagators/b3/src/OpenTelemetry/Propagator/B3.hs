{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

{- | B3 Propagation Requirements:
 https://github.com/openzipkin/b3-propagation
 https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/context/api-propagators.md#b3-requirements
-}
module OpenTelemetry.Propagator.B3 (
  b3TraceContextPropagator,
  b3MultiTraceContextPropagator,
) where

--------------------------------------------------------------------------------

import Control.Applicative ((<|>))
import Data.List (intersperse)
import Data.Maybe (catMaybes, fromMaybe)
import qualified Data.Text.Encoding as Text
import OpenTelemetry.Common (TraceFlags (..))
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Propagator (
  Propagator (..),
  TextMap,
  TextMapPropagator,
  textMapInsert,
  textMapLookup,
 )
import OpenTelemetry.Propagator.B3.Internal
import qualified OpenTelemetry.Trace.Core as Core
import qualified OpenTelemetry.Trace.TraceState as TS
import Prelude


--------------------------------------------------------------------------------

b3TraceContextPropagator :: TextMapPropagator
b3TraceContextPropagator =
  Propagator
    { propagatorFields = ["B3 Trace Context"]
    , extractor = \hs c ->
        case b3Extractor hs of
          Nothing -> pure c
          Just spanContext' -> pure $ Context.insertSpan (Core.wrapSpanContext spanContext') c
    , injector = \c hs ->
        case Context.lookupSpan c of
          Nothing -> pure hs
          Just span' -> do
            Core.SpanContext {traceId, spanId, traceState = TS.TraceState traceState, traceFlags} <- Core.getSpanContext span'
            let traceIdValue = encodeTraceId traceId
                spanIdValue = encodeSpanId spanId
                samplingStateValue =
                  printSamplingStateSingle $ injectSamplingState traceState traceFlags
                value = mconcat $ intersperse "-" $ [traceIdValue, spanIdValue] <> catMaybes [Text.encodeUtf8 <$> samplingStateValue]

            pure $ textMapInsert b3Header (Text.decodeUtf8 value) hs
    }


b3MultiTraceContextPropagator :: TextMapPropagator
b3MultiTraceContextPropagator =
  Propagator
    { propagatorFields = ["B3 Multi Trace Context"]
    , extractor = \hs c -> do
        case b3Extractor hs of
          Nothing -> pure c
          Just spanContext' -> pure $ Context.insertSpan (Core.wrapSpanContext spanContext') c
    , injector = \c hs ->
        case Context.lookupSpan c of
          Nothing -> pure hs
          Just span' -> do
            Core.SpanContext {traceId, spanId, traceState = TS.TraceState traceState, traceFlags} <- Core.getSpanContext span'
            let traceIdValue = encodeTraceId traceId
                spanIdValue = encodeSpanId spanId
                samplingStateMay =
                  printSamplingStateMulti $ injectSamplingState traceState traceFlags
                hs' =
                  textMapInsert xb3SpanIdHeader (Text.decodeUtf8 spanIdValue) $
                    textMapInsert xb3TraceIdHeader (Text.decodeUtf8 traceIdValue) hs
            pure $ case samplingStateMay of
              Nothing -> hs'
              Just (k, v) -> textMapInsert k v hs'
    }


--------------------------------------------------------------------------------

{- | B3 sampling for injection: prefer explicit @sampling-state@ in trace state,
otherwise derive from 'TraceFlags' (so local spans inject without a prior extract).
-}
injectSamplingState :: [(TS.Key, TS.Value)] -> TraceFlags -> SamplingState
injectSamplingState traceState traceFlags =
  case lookup (TS.Key "sampling-state") traceState >>= samplingStateFromValue of
    Just s -> s
    Nothing ->
      if Core.isSampled traceFlags then Accept else Deny


--------------------------------------------------------------------------------

{- | For both @B3@ and @B3 Multi@ formats, we must attempt single and
 multi header extraction:
 https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/context/api-propagators.md#configuration
-}
b3Extractor :: TextMap -> Maybe Core.SpanContext
b3Extractor hs = b3SingleExtractor hs <|> b3MultiExtractor hs


b3SingleExtractor :: TextMap -> Maybe Core.SpanContext
b3SingleExtractor hs = do
  B3SingleHeader {..} <- decodeB3SingleHeader =<< (Text.encodeUtf8 <$> textMapLookup b3Header hs)

  let traceFlags = if samplingState == Accept || samplingState == Debug then TraceFlags 1 else TraceFlags 0

  pure $
    Core.SpanContext
      { traceId = traceId
      , spanId = spanId
      , isRemote = True
      , traceFlags = traceFlags
      , traceState = TS.TraceState [(TS.Key "sampling-state", samplingStateToValue samplingState)]
      }


b3MultiExtractor :: TextMap -> Maybe Core.SpanContext
b3MultiExtractor hs = do
  traceId <- decodeXb3TraceIdHeader =<< (Text.encodeUtf8 <$> textMapLookup xb3TraceIdHeader hs)
  spanId <- decodeXb3SpanIdHeader =<< (Text.encodeUtf8 <$> textMapLookup xb3SpanIdHeader hs)

  let sampled = decodeXb3SampledHeader =<< (Text.encodeUtf8 <$> textMapLookup xb3SampledHeader hs)
      debug = decodeXb3FlagsHeader =<< (Text.encodeUtf8 <$> textMapLookup xb3FlagsHeader hs)
      -- NOTE: Debug implies Accept (https://github.com/openzipkin/b3-propagation#debug-flag)
      samplingState = fromMaybe Defer $ debug <|> sampled
  let traceFlags = if samplingState == Accept || samplingState == Debug then TraceFlags 1 else TraceFlags 0

  pure $
    Core.SpanContext
      { traceId = traceId
      , spanId = spanId
      , isRemote = True
      , traceFlags = traceFlags
      , traceState = TS.TraceState [(TS.Key "sampling-state", samplingStateToValue samplingState)]
      }
