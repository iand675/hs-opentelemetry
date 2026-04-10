{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}

{- | Jaeger Propagation Format:
 <https://www.jaegertracing.io/docs/1.21/client-libraries/#propagation-format>

 The Jaeger propagation format is deprecated in favour of W3C Trace
 Context. This package exists for interoperability with legacy systems.

 == Header: @uber-trace-id@

 @
 {trace-id}:{span-id}:{parent-span-id}:{flags}
 @

 == Baggage: @uberctx-{key}@

 Each baggage entry is a separate header with prefix @uberctx-@.
-}
module OpenTelemetry.Propagator.Jaeger (
  jaegerPropagator,
  jaegerTraceContextPropagator,

  -- * Registry integration
  registerJaegerPropagator,
) where

import qualified Data.ByteString.Char8 as C
import qualified Data.HashMap.Strict as H
import Data.Maybe (catMaybes)
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import OpenTelemetry.Baggage (decodeBaggageHeader)
import qualified OpenTelemetry.Baggage as Baggage
import OpenTelemetry.Common (TraceFlags (..))
import OpenTelemetry.Context (Context)
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Propagator (
  Propagator (..),
  TextMap,
  textMapInsert,
  textMapKeys,
  textMapLookup,
 )
import OpenTelemetry.Propagator.Jaeger.Internal
import OpenTelemetry.Registry (registerTextMapPropagator)
import qualified OpenTelemetry.Trace.Core as Core
import OpenTelemetry.Trace.TraceState (TraceState (..))


{- | Propagator for the Jaeger trace context format.

Handles both the @uber-trace-id@ header (trace context) and
@uberctx-*@ headers (baggage).
-}
jaegerPropagator :: Propagator Context TextMap TextMap
jaegerPropagator = jaegerTraceContextPropagator <> jaegerBaggagePropagator


{- | Propagator for the @uber-trace-id@ header only (no baggage).

Use 'jaegerPropagator' if you also need Jaeger baggage propagation.
-}
jaegerTraceContextPropagator :: Propagator Context TextMap TextMap
jaegerTraceContextPropagator =
  Propagator
    { propagatorFields = [uberTraceIdHeader]
    , extractor = \tm c ->
        case textMapLookup uberTraceIdHeader tm of
          Nothing -> pure c
          Just val ->
            case decodeUberTraceId (TE.encodeUtf8 val) of
              Nothing -> pure c
              Just jh ->
                let sampled = flagsSampled (jhFlags jh) || flagsDebug (jhFlags jh)
                    sc =
                      Core.SpanContext
                        { Core.traceId = jhTraceId jh
                        , Core.spanId = jhSpanId jh
                        , Core.isRemote = True
                        , Core.traceFlags = if sampled then TraceFlags 1 else TraceFlags 0
                        , Core.traceState = TraceState []
                        }
                in pure $ Context.insertSpan (Core.wrapSpanContext sc) c
    , injector = \c tm ->
        case Context.lookupSpan c of
          Nothing -> pure tm
          Just span' -> do
            sc <- Core.getSpanContext span'
            let !sampled = Core.isSampled (Core.traceFlags sc)
                !headerBs = encodeUberTraceId (Core.traceId sc) (Core.spanId sc) sampled
                !headerValue = TE.decodeUtf8 headerBs
            pure $ textMapInsert uberTraceIdHeader headerValue tm
    }


-- | Propagator for Jaeger-style baggage (@uberctx-*@ headers).
jaegerBaggagePropagator :: Propagator Context TextMap TextMap
jaegerBaggagePropagator =
  Propagator
    { propagatorFields = []
    , extractor = \tm c -> do
        let baggageKeys = filter (T.isPrefixOf uberBaggagePrefix) (textMapKeys tm)
            entries = catMaybes $ map (extractBaggageEntry tm) baggageKeys
        case entries of
          [] -> pure c
          kvs ->
            case decodeBaggageHeader (C.pack $ encodeBaggageString kvs) of
              Left _ -> pure c
              Right bag -> pure $ Context.insertBaggage bag c
    , injector = \c tm ->
        case Context.lookupBaggage c of
          Nothing -> pure tm
          Just bag ->
            let entries = H.toList (Baggage.values bag)
            in pure $
                foldl
                  ( \acc (k, v) ->
                      let headerName = uberBaggagePrefix <> TE.decodeUtf8 (Baggage.tokenValue k)
                      in textMapInsert headerName (Baggage.value v) acc
                  )
                  tm
                  entries
    }


extractBaggageEntry :: TextMap -> Text -> Maybe (Text, Text)
extractBaggageEntry tm headerKey = do
  val <- textMapLookup headerKey tm
  let key = T.drop (T.length uberBaggagePrefix) headerKey
  if T.null key
    then Nothing
    else Just (key, val)


encodeBaggageString :: [(Text, Text)] -> String
encodeBaggageString kvs =
  T.unpack $ T.intercalate "," $ map (\(k, v) -> k <> "=" <> v) kvs


{- | Register the Jaeger propagator under the name @\"jaeger\"@ in the
global registry.

@since 0.0.1.0
-}
registerJaegerPropagator :: IO ()
registerJaegerPropagator =
  registerTextMapPropagator "jaeger" jaegerPropagator
