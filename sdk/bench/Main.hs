{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

module Main (main) where

import Control.Concurrent.Async (async)
import Control.Monad (void)
import Data.IORef
import qualified Data.Text as T
import OpenTelemetry.Attributes (defaultAttributeLimits, emptyAttributes)
import qualified OpenTelemetry.Attributes as A
import OpenTelemetry.Context (empty)
import OpenTelemetry.Internal.AtomicCounter
import OpenTelemetry.Internal.Common.Types (InstrumentationLibrary (..), ShutdownResult (..), instrumentationLibrary)
import OpenTelemetry.MeterProvider (createMeterProvider, defaultSdkMeterProviderOptions)
import OpenTelemetry.Metrics
import OpenTelemetry.Processor.Span (SpanProcessor (..))
import OpenTelemetry.Resource (emptyMaterializedResources)
import OpenTelemetry.Trace.Core
import Test.Tasty.Bench


main :: IO ()
main = do
  let scope = instrumentationLibrary "bench" "1.0"
  (mp, _env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
  m <- getMeter mp scope

  counterI <- meterCreateCounterInt64 m "bench_counter_i64" Nothing Nothing defaultAdvisoryParameters
  counterD <- meterCreateCounterDouble m "bench_counter_dbl" Nothing Nothing defaultAdvisoryParameters
  upDown <- meterCreateUpDownCounterInt64 m "bench_updown" Nothing Nothing defaultAdvisoryParameters
  hist <- meterCreateHistogram m "bench_hist" Nothing Nothing defaultAdvisoryParameters

  let oneAttr = A.addAttribute defaultAttributeLimits emptyAttributes "key" ("v" :: T.Text)
      fiveAttrs =
        foldl
          (\a (k, v) -> A.addAttribute defaultAttributeLimits a k (v :: T.Text))
          emptyAttributes
          [("k1", "v"), ("k2", "v"), ("k3", "v"), ("k4", "v"), ("k5", "v")]

  dummyProcessor <- mkCountingProcessor
  activeTp <- createTracerProvider [dummyProcessor] emptyTracerProviderOptions
  let activeTracer = makeTracer activeTp scope tracerOptions

  defaultMain
    [ bgroup
        "counter-int64"
        [ bench "add 1 (no attrs)" $
            whnfIO $
              counterAdd counterI 1 emptyAttributes
        , bench "add 1 (1 attr)" $
            whnfIO $
              counterAdd counterI 1 oneAttr
        , bench "add 1 (5 attrs)" $
            whnfIO $
              counterAdd counterI 1 fiveAttrs
        ]
    , bgroup
        "counter-double"
        [ bench "add 1.0 (no attrs)" $
            whnfIO $
              counterAdd counterD 1.0 emptyAttributes
        ]
    , bgroup
        "updown-counter"
        [ bench "add 1" $
            whnfIO $
              upDownCounterAdd upDown 1 emptyAttributes
        , bench "add -1" $
            whnfIO $
              upDownCounterAdd upDown (-1) emptyAttributes
        ]
    , bgroup
        "histogram"
        [ bench "record (no attrs)" $
            whnfIO $
              histogramRecord hist 42.0 emptyAttributes
        , bench "record (1 attr)" $
            whnfIO $
              histogramRecord hist 42.0 oneAttr
        , bench "record (5 attrs)" $
            whnfIO $
              histogramRecord hist 42.0 fiveAttrs
        ]
    , bgroup
        "combined"
        [ bench "inSpan + counter" $
            whnfIO $
              inSpan
                activeTracer
                "op"
                defaultSpanArguments
                (counterAdd counterI 1 emptyAttributes)
        , bench "inSpan + histogram" $
            whnfIO $
              inSpan
                activeTracer
                "op"
                defaultSpanArguments
                (histogramRecord hist 42.0 emptyAttributes)
        ]
    ]


mkCountingProcessor :: IO SpanProcessor
mkCountingProcessor = do
  ref <- newAtomicCounter 0
  pure
    SpanProcessor
      { spanProcessorOnStart = \_ _ -> pure ()
      , spanProcessorOnEnd = \_ -> void $ incrAtomicCounter ref
      , spanProcessorShutdown = async (pure ShutdownSuccess)
      , spanProcessorForceFlush = pure ()
      }
