{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TupleSections #-}

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
import Data.ByteString (ByteString)
import Data.List (intersperse)
import Data.Maybe (catMaybes, fromMaybe)
import qualified Data.Text.Encoding as Text
import Network.HTTP.Types (HeaderName, RequestHeaders, ResponseHeaders)
import OpenTelemetry.Common (TraceFlags (..))
import OpenTelemetry.Context (Context)
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Propagator (Propagator (..))
import OpenTelemetry.Propagator.B3.Internal
import qualified OpenTelemetry.Trace.Core as Core
import qualified OpenTelemetry.Trace.TraceState as TS
import Prelude


--------------------------------------------------------------------------------

b3TraceContextPropagator :: Propagator Context RequestHeaders ResponseHeaders
b3TraceContextPropagator =
  Propagator
    { propagatorNames = ["B3 Trace Context"]
    , extractor = \hs c ->
        case b3Extractor hs of
          Nothing -> pure c
          Just spanContext' -> pure $ Context.insertSpan (Core.wrapSpanContext spanContext') c
    , injector = \c hs ->
        case Context.lookupSpan c of
          Nothing -> pure hs
          Just span' -> do
            Core.SpanContext {traceId, spanId, traceState = TS.TraceState traceState} <- Core.getSpanContext span'
            let traceIdValue = encodeTraceId traceId
                spanIdValue = encodeSpanId spanId
                samplingStateValue = lookup (TS.Key "sampling-state") traceState >>= samplingStateFromValue >>= printSamplingStateSingle
                value = mconcat $ intersperse "-" $ [traceIdValue, spanIdValue] <> catMaybes [Text.encodeUtf8 <$> samplingStateValue]

            pure $ (b3Header, value) : hs
    }


b3MultiTraceContextPropagator :: Propagator Context RequestHeaders ResponseHeaders
b3MultiTraceContextPropagator =
  Propagator
    { propagatorNames = ["B3 Multi Trace Context"]
    , extractor = \hs c -> do
        case b3Extractor hs of
          Nothing -> pure c
          Just spanContext' -> pure $ Context.insertSpan (Core.wrapSpanContext spanContext') c
    , injector = \c hs ->
        case Context.lookupSpan c of
          Nothing -> pure hs
          Just span' -> do
            Core.SpanContext {traceId, spanId, traceState = TS.TraceState traceState} <- Core.getSpanContext span'
            let traceIdValue = encodeTraceId traceId
                spanIdValue = encodeSpanId spanId
                samplingStateValue = lookup (TS.Key "sampling-state") traceState >>= samplingStateFromValue >>= printSamplingStateMulti

            pure $
              (xb3TraceIdHeader, traceIdValue)
                : (xb3SpanIdHeader, spanIdValue)
                : hs
                ++ catMaybes [fmap Text.encodeUtf8 <$> samplingStateValue]
    }


--------------------------------------------------------------------------------

{- | For both @B3@ and @B3 Multi@ formats, we must attempt single and
 multi header extraction:
 https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/context/api-propagators.md#configuration
-}
b3Extractor :: [(HeaderName, ByteString)] -> Maybe Core.SpanContext
b3Extractor hs = b3SingleExtractor hs <|> b3MultiExtractor hs


b3SingleExtractor :: [(HeaderName, ByteString)] -> Maybe Core.SpanContext
b3SingleExtractor hs = do
  B3SingleHeader {..} <- decodeB3SingleHeader =<< Prelude.lookup b3Header hs

  let traceFlags = if samplingState == Accept || samplingState == Debug then TraceFlags 1 else TraceFlags 0

  pure $
    Core.SpanContext
      { traceId = traceId
      , spanId = spanId
      , isRemote = True
      , traceFlags = traceFlags
      , traceState = TS.TraceState [(TS.Key "sampling-state", samplingStateToValue samplingState)]
      }


b3MultiExtractor :: [(HeaderName, ByteString)] -> Maybe Core.SpanContext
b3MultiExtractor hs = do
  traceId <- decodeXb3TraceIdHeader =<< Prelude.lookup xb3TraceIdHeader hs
  spanId <- decodeXb3SpanIdHeader =<< Prelude.lookup xb3SpanIdHeader hs

  let sampled = decodeXb3SampledHeader =<< Prelude.lookup xb3SampledHeader hs
      debug = decodeXb3FlagsHeader =<< Prelude.lookup xb3FlagsHeader hs
      -- NOTE: Debug implies Accept (https://github.com/openzipkin/b3-propagation#debug-flag)
      samplingState = fromMaybe Defer $ sampled <|> debug
  let traceFlags = if samplingState == Accept || samplingState == Debug then TraceFlags 1 else TraceFlags 0

  pure $
    Core.SpanContext
      { traceId = traceId
      , spanId = spanId
      , isRemote = True
      , traceFlags = traceFlags
      , traceState = TS.TraceState [(TS.Key "sampling-state", samplingStateToValue samplingState)]
      }
