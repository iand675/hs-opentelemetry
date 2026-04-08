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

  -- * Registry integration
  registerB3Propagators,
) where

--------------------------------------------------------------------------------

import Control.Applicative ((<|>))
import Data.ByteString (ByteString)
import Data.List (intersperse)
import Data.Maybe (catMaybes, fromMaybe)
import Data.Text (Text)
import qualified Data.Text.Encoding as Text
import OpenTelemetry.Common (TraceFlags (..))
import OpenTelemetry.Context (Context)
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Propagator (Propagator (..), TextMap, textMapInsert, textMapLookup)
import OpenTelemetry.Propagator.B3.Internal
import OpenTelemetry.Registry (registerTextMapPropagator)
import qualified OpenTelemetry.Trace.Core as Core
import qualified OpenTelemetry.Trace.TraceState as TS
import Prelude


--------------------------------------------------------------------------------

b3TraceContextPropagator :: Propagator Context TextMap TextMap
b3TraceContextPropagator =
  Propagator
    { propagatorFields =
        [ b3Header
        , xb3TraceIdHeader
        , xb3SpanIdHeader
        , xb3SampledHeader
        , xb3FlagsHeader
        , xb3ParentSpanIdHeader
        ]
    , extractor = \tm c ->
        case b3Extractor tm of
          Nothing -> pure c
          Just spanContext' -> pure $ Context.insertSpan (Core.wrapSpanContext spanContext') c
    , injector = \c tm ->
        case Context.lookupSpan c of
          Nothing -> pure tm
          Just span' -> do
            scx@Core.SpanContext {traceId, spanId, traceState = TS.TraceState traceState} <- Core.getSpanContext span'
            let traceIdValue = encodeTraceId traceId
                spanIdValue = encodeSpanId spanId
                fromTs = lookup (TS.Key "sampling-state") traceState >>= samplingStateFromValue >>= printSamplingStateSingle
                fromFlags
                  | Core.isSampled (Core.traceFlags scx) = Just "1"
                  | otherwise = Just "0"
                samplingStateValue = fromTs <|> fromFlags
                value = mconcat $ intersperse "-" $ [traceIdValue, spanIdValue] <> catMaybes [Text.encodeUtf8 <$> samplingStateValue]

            pure $ textMapInsert b3Header (Text.decodeUtf8 value) tm
    }


b3MultiTraceContextPropagator :: Propagator Context TextMap TextMap
b3MultiTraceContextPropagator =
  Propagator
    { propagatorFields =
        [ b3Header
        , xb3TraceIdHeader
        , xb3SpanIdHeader
        , xb3SampledHeader
        , xb3FlagsHeader
        , xb3ParentSpanIdHeader
        ]
    , extractor = \tm c -> do
        case b3Extractor tm of
          Nothing -> pure c
          Just spanContext' -> pure $ Context.insertSpan (Core.wrapSpanContext spanContext') c
    , injector = \c tm ->
        case Context.lookupSpan c of
          Nothing -> pure tm
          Just span' -> do
            scx@Core.SpanContext {traceId, spanId, traceState = TS.TraceState traceState} <- Core.getSpanContext span'
            let traceIdValue = encodeTraceId traceId
                spanIdValue = encodeSpanId spanId
                fromTs = lookup (TS.Key "sampling-state") traceState >>= samplingStateFromValue >>= printSamplingStateMulti
                fromFlags
                  | Core.isSampled (Core.traceFlags scx) = Just (xb3SampledHeader, "1")
                  | otherwise = Just (xb3SampledHeader, "0")
                samplingStateValue = fromTs <|> fromFlags
                baseTm =
                  textMapInsert xb3TraceIdHeader (Text.decodeUtf8 traceIdValue) $
                    textMapInsert xb3SpanIdHeader (Text.decodeUtf8 spanIdValue) tm
            pure $ case samplingStateValue of
              Nothing -> baseTm
              Just (k, v) -> textMapInsert k v baseTm
    }


--------------------------------------------------------------------------------

{- | For both @B3@ and @B3 Multi@ formats, we must attempt single and
 multi header extraction:
 https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/context/api-propagators.md#configuration
-}
b3Extractor :: TextMap -> Maybe Core.SpanContext
b3Extractor tm = b3SingleExtractor tm <|> b3MultiExtractor tm


tmLookupBs :: Text -> TextMap -> Maybe ByteString
tmLookupBs k tm = Text.encodeUtf8 <$> textMapLookup k tm


b3SingleExtractor :: TextMap -> Maybe Core.SpanContext
b3SingleExtractor tm = do
  B3SingleHeader {..} <- decodeB3SingleHeader =<< tmLookupBs b3Header tm

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
b3MultiExtractor tm = do
  traceId <- decodeXb3TraceIdHeader =<< tmLookupBs xb3TraceIdHeader tm
  spanId <- decodeXb3SpanIdHeader =<< tmLookupBs xb3SpanIdHeader tm

  let sampled = decodeXb3SampledHeader =<< tmLookupBs xb3SampledHeader tm
      debug = decodeXb3FlagsHeader =<< tmLookupBs xb3FlagsHeader tm
      samplingState = fromMaybe Defer $ debug <|> sampled
      traceFlags = if samplingState == Accept || samplingState == Debug then TraceFlags 1 else TraceFlags 0
      _parentSpanId = decodeXb3SpanIdHeader =<< tmLookupBs xb3ParentSpanIdHeader tm

  pure $
    Core.SpanContext
      { traceId = traceId
      , spanId = spanId
      , isRemote = True
      , traceFlags = traceFlags
      , traceState = TS.TraceState [(TS.Key "sampling-state", samplingStateToValue samplingState)]
      }


{- | Register the B3 single-header and multi-header propagators under
the names @\"b3\"@ and @\"b3multi\"@ in the global registry.

@since 0.0.1.3
-}
registerB3Propagators :: IO ()
registerB3Propagators = do
  registerTextMapPropagator "b3" b3TraceContextPropagator
  registerTextMapPropagator "b3multi" b3MultiTraceContextPropagator
