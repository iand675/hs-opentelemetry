{-# LANGUAGE OverloadedStrings #-}

module Main where

import Criterion.Main
import OpenTelemetry.Trace.Core


main :: IO ()
main = do
  tp <- getGlobalTracerProvider
  let tracer = makeTracer tp "bench" tracerOptions

  defaultMain
    [ bgroup "inert-tracing"
      [ bench "inSpan (no callback arg)" $
          whnfIO (inSpan tracer "test-span" defaultSpanArguments (pure ()))
      , bench "inSpan' (with span arg)" $
          whnfIO (inSpan' tracer "test-span" defaultSpanArguments (\_ -> pure ()))
      , bench "createSpan + endSpan" $
          whnfIO $ do
            s <- createSpan tracer mempty "test-span" defaultSpanArguments
            endSpan s Nothing
      , bench "tracerIsEnabled check" $
          whnf tracerIsEnabled tracer
      , bench "baseline (pure ())" $
          whnfIO (pure () :: IO ())
      ]
    ]
