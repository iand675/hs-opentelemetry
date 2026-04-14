{-# LANGUAGE OverloadedStrings #-}

{- | AWS X-Ray Propagation Format.

The @X-Amzn-Trace-Id@ header is used by AWS services (ALB, API Gateway,
Lambda, etc.) to propagate trace context. The trace ID embeds a Unix
epoch timestamp in its first 4 bytes, but is otherwise a standard 128-bit
identifier that maps directly to an OpenTelemetry trace ID.

== Header format

@
X-Amzn-Trace-Id: Root=1-{epoch8hex}-{unique24hex};Parent={spanid16hex};Sampled={0|1}
@

== Interoperability with W3C Trace Context

Use alongside W3C propagators for mixed AWS / non-AWS environments:

@
OTEL_PROPAGATORS=tracecontext,baggage,xray
@

Both propagators will extract context from their respective headers.
On injection both headers are emitted, so downstream services can
consume whichever format they understand.

See <https://docs.aws.amazon.com/xray/latest/devguide/xray-concepts.html#xray-concepts-tracingheader>.
-}
module OpenTelemetry.Propagator.XRay (
  xrayPropagator,

  -- * Registry integration
  registerXRayPropagator,
) where

import qualified Data.ByteString.Builder as BB
import qualified Data.ByteString.Lazy as BL
import qualified Data.Text.Encoding as TE
import OpenTelemetry.Common (TraceFlags (..))
import OpenTelemetry.Context (Context)
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Propagator (
  Propagator (..),
  TextMap,
  textMapInsert,
  textMapLookup,
 )
import OpenTelemetry.Propagator.XRay.Internal
import OpenTelemetry.Registry (registerTextMapPropagator)
import qualified OpenTelemetry.Trace.Core as Core
import OpenTelemetry.Trace.Id (Base (..), spanIdBaseEncodedBuilder)
import OpenTelemetry.Trace.TraceState (TraceState (..))


{- | Propagator for the AWS X-Ray @X-Amzn-Trace-Id@ header.

Extracts @Root@, @Parent@, and @Sampled@ fields from incoming headers
and injects them on outgoing headers.

@since 0.0.1.0
-}
xrayPropagator :: Propagator Context TextMap TextMap
xrayPropagator =
  Propagator
    { propagatorFields = [xrayTraceIdHeader]
    , extractor = \tm c ->
        case textMapLookup xrayTraceIdHeader tm of
          Nothing -> pure c
          Just val ->
            case decodeXRayHeader (TE.encodeUtf8 val) of
              Nothing -> pure c
              Just xh ->
                let sc =
                      Core.SpanContext
                        { Core.traceId = xhTraceId xh
                        , Core.spanId = xhSpanId xh
                        , Core.isRemote = True
                        , Core.traceFlags = if xhSampled xh then TraceFlags 1 else TraceFlags 0
                        , Core.traceState = TraceState []
                        }
                in pure $ Context.insertSpan (Core.wrapSpanContext sc) c
    , injector = \c tm ->
        case Context.lookupSpan c of
          Nothing -> pure tm
          Just span' -> do
            sc <- Core.getSpanContext span'
            let root = TE.decodeUtf8 $ otelTraceIdToXRay (Core.traceId sc)
                parent =
                  TE.decodeUtf8 $
                    BL.toStrict $
                      BB.toLazyByteString $
                        spanIdBaseEncodedBuilder Base16 (Core.spanId sc)
                sampled = if Core.isSampled (Core.traceFlags sc) then "1" else "0"
                headerValue = "Root=" <> root <> ";Parent=" <> parent <> ";Sampled=" <> sampled
            pure $ textMapInsert xrayTraceIdHeader headerValue tm
    }


{- | Register the X-Ray propagator under the name @\"xray\"@ in the
global registry.

@since 0.0.1.0
-}
registerXRayPropagator :: IO ()
registerXRayPropagator =
  registerTextMapPropagator "xray" xrayPropagator
