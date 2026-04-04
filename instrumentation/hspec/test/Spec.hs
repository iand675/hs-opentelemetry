{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.IORef
import OpenTelemetry.Context.ThreadLocal (getContext)
import OpenTelemetry.Exporter.InMemory.Span (inMemoryListExporter)
import OpenTelemetry.Instrumentation.Hspec (instrumentSpec)
import OpenTelemetry.Trace.Core
import Test.Hspec
import Test.Hspec.Core.Runner (hspecResult)


main :: IO ()
main = hspec spec


spec :: Spec
spec = describe "Hspec instrumentation" $ do
  it "instrumentSpec creates spans for each test item" $ do
    (processor, ref) <- inMemoryListExporter
    tp <- createTracerProvider [processor] emptyTracerProviderOptions
    setGlobalTracerProvider tp
    let tracer = makeTracer tp "test" tracerOptions
    ctx <- getContext

    let innerSpec = instrumentSpec tracer ctx $ do
          it "alpha" $ True `shouldBe` True
          it "beta" $ True `shouldBe` True

    _summary <- hspecResult innerSpec

    shutdownTracerProvider tp
    spans <- readIORef ref
    names <- traverse (\s -> hotName <$> readIORef (spanHot s)) spans
    names `shouldContain` ["alpha"]
    names `shouldContain` ["beta"]

  it "instrumentSpec nests describe groups as spans" $ do
    (processor, ref) <- inMemoryListExporter
    tp <- createTracerProvider [processor] emptyTracerProviderOptions
    setGlobalTracerProvider tp
    let tracer = makeTracer tp "test-nested" tracerOptions
    ctx <- getContext

    let innerSpec =
          instrumentSpec tracer ctx $
            describe "outer group" $
              it "nested test" $
                True `shouldBe` True

    _summary <- hspecResult innerSpec

    shutdownTracerProvider tp
    spans <- readIORef ref
    names <- traverse (\s -> hotName <$> readIORef (spanHot s)) spans
    names `shouldContain` ["nested test"]
    names `shouldContain` ["outer group"]
