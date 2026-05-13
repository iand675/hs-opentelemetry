{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import qualified Criterion.Main as C
import qualified Data.ByteString.Char8 as C8
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Propagator (extract, inject)
import OpenTelemetry.Propagator.B3
import OpenTelemetry.Trace.Core (SpanContext (..), defaultTraceFlags, wrapSpanContext)
import OpenTelemetry.Trace.Id (Base (Base16), SpanId, TraceId, baseEncodedToSpanId, baseEncodedToTraceId)
import qualified OpenTelemetry.Trace.TraceState as TS


main :: IO ()
main = do
  let singleHeaders = [("b3", "4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-1")]
      multiHeaders =
        [ ("X-B3-TraceId", "4bf92f3577b34da6a3ce929d0e0e4736")
        , ("X-B3-SpanId", "00f067aa0ba902b7")
        , ("X-B3-Sampled", "1")
        ]
      spanContext = mkSpanContext
      contextWithSpan = Context.insertSpan (wrapSpanContext spanContext) Context.empty

  C.defaultMain
    [ C.bgroup
        "extract"
        [ C.bench "single" $ C.whnfIO $ extract b3TraceContextPropagator singleHeaders Context.empty
        , C.bench "multi" $ C.whnfIO $ extract b3MultiTraceContextPropagator multiHeaders Context.empty
        ]
    , C.bgroup
        "inject"
        [ C.bench "single" $ C.whnfIO $ inject b3TraceContextPropagator contextWithSpan []
        , C.bench "multi" $ C.whnfIO $ inject b3MultiTraceContextPropagator contextWithSpan []
        ]
    ]


mkSpanContext :: SpanContext
mkSpanContext =
  SpanContext
    { traceId = mkTraceId "4bf92f3577b34da6a3ce929d0e0e4736"
    , spanId = mkSpanId "00f067aa0ba902b7"
    , isRemote = False
    , traceFlags = defaultTraceFlags
    , traceState = TS.empty
    }


mkTraceId :: C8.ByteString -> TraceId
mkTraceId value =
  case baseEncodedToTraceId Base16 value of
    Left err -> error err
    Right ok -> ok


mkSpanId :: C8.ByteString -> SpanId
mkSpanId value =
  case baseEncodedToSpanId Base16 value of
    Left err -> error err
    Right ok -> ok
