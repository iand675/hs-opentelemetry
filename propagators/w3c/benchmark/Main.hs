{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import qualified Criterion.Main as C
import qualified Data.ByteString.Char8 as C8
import qualified Data.Text as T
import OpenTelemetry.Propagator.W3CTraceContext
import OpenTelemetry.Trace.TraceState (Key (Key), TraceState, Value (Value), fromList)


main :: IO ()
main = do
  let traceparent = "00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01"
      tracestateSmall = "rojo=00f067aa0ba902b7,congo=t61rcWkgMzE"
      tracestateMedium = mkTracestateHeader 16
      tracestateLarge = mkTracestateHeader 32
      tsSmall = mkTraceState 8
      tsLarge = mkTraceState 32

  C.defaultMain
    [ C.bgroup
        "decodeSpanContext"
        [ C.bench "traceparent-only" $ C.whnf (decodeSpanContext (Just traceparent)) Nothing
        , C.bench "with-tracestate-small" $ C.whnf (decodeSpanContext (Just traceparent)) (Just tracestateSmall)
        , C.bench "with-tracestate-medium" $ C.whnf (decodeSpanContext (Just traceparent)) (Just tracestateMedium)
        , C.bench "with-tracestate-large" $ C.whnf (decodeSpanContext (Just traceparent)) (Just tracestateLarge)
        ]
    , C.bgroup
        "encodeTraceState"
        [ C.bench "single-header-small" $ C.whnf encodeTraceState tsSmall
        , C.bench "single-header-large" $ C.whnf encodeTraceState tsLarge
        , C.bench "multi-header-small" $ C.whnf (encodeTraceStateMultiple 512) tsSmall
        , C.bench "multi-header-large" $ C.whnf (encodeTraceStateMultiple 512) tsLarge
        ]
    ]


mkTraceState :: Int -> TraceState
mkTraceState n =
  fromList
    [ (Key $ T.pack ("vendor" <> show i), Value $ T.pack ("state" <> show i))
    | i <- [1 .. n]
    ]


mkTracestateHeader :: Int -> C8.ByteString
mkTracestateHeader n =
  C8.intercalate
    ","
    [ C8.pack ("vendor" <> show i <> "=state" <> show i)
    | i <- [1 .. n]
    ]
