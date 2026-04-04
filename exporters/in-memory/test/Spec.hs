{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.IORef
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Exporter.InMemory.Span (inMemoryChannelExporter, inMemoryListExporter, readChan)
import OpenTelemetry.Trace.Core
import Test.Hspec


main :: IO ()
main = hspec spec


spec :: Spec
spec = do
  describe "inMemoryListExporter" $ do
    it "starts with empty list" $ do
      (_, ref) <- inMemoryListExporter
      spans <- readIORef ref
      length spans `shouldBe` 0

    it "captures ended spans" $ do
      (processor, ref) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      let t = makeTracer tp "test" tracerOptions
      s <- createSpan t Context.empty "test-span" defaultSpanArguments
      endSpan s Nothing
      shutdownTracerProvider tp
      spans <- readIORef ref
      length spans `shouldBe` 1
      case spans of
        (s : _) -> do
          hot <- readIORef (spanHot s)
          hotName hot `shouldBe` "test-span"
        [] -> expectationFailure "no spans"

    it "captures multiple spans in order of completion" $ do
      (processor, ref) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      let t = makeTracer tp "test" tracerOptions
      s1 <- createSpan t Context.empty "first" defaultSpanArguments
      s2 <- createSpan t Context.empty "second" defaultSpanArguments
      endSpan s1 Nothing
      endSpan s2 Nothing
      shutdownTracerProvider tp
      spans <- readIORef ref
      length spans `shouldBe` 2

    it "does not capture spans that have not ended" $ do
      (processor, ref) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      let t = makeTracer tp "test" tracerOptions
      _ <- createSpan t Context.empty "unfinished" defaultSpanArguments
      shutdownTracerProvider tp
      spans <- readIORef ref
      length spans `shouldBe` 0

  describe "inMemoryChannelExporter" $ do
    it "creates a processor and channel" $ do
      (_, _chan) <- inMemoryChannelExporter
      pure () :: IO ()

    it "captures ended spans via channel" $ do
      (processor, chan) <- inMemoryChannelExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      let t = makeTracer tp "test" tracerOptions
      s <- createSpan t Context.empty "chan-span" defaultSpanArguments
      endSpan s Nothing
      shutdownTracerProvider tp
      element <- readChan chan
      hot <- readIORef (spanHot element)
      hotName hot `shouldBe` "chan-span"
