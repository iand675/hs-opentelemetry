{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import Control.Exception (IOException, throwIO, try)
import Control.Monad (filterM)
import Data.IORef
import Data.Text (Text)
import OpenTelemetry.Attributes (Attributes, lookupAttribute)
import OpenTelemetry.Attributes.Attribute (Attribute (..), PrimitiveAttribute (..))
import OpenTelemetry.Exporter.InMemory.Span (inMemoryListExporter)
import OpenTelemetry.Trace.Core
import OpenTelemetry.Utils.Exceptions
import Test.Hspec


main :: IO ()
main = hspec spec


withTracer :: (Tracer -> IO a) -> IO ([ImmutableSpan], a)
withTracer action = do
  (processor, ref) <- inMemoryListExporter
  tp <- createTracerProvider [processor] emptyTracerProviderOptions
  let tracer = makeTracer tp "test-exceptions" tracerOptions
  result <- action tracer
  _ <- shutdownTracerProvider tp Nothing
  spans <- readIORef ref
  pure (spans, result)


firstSpan :: [ImmutableSpan] -> ImmutableSpan
firstSpan (s : _) = s
firstSpan [] = error "No spans recorded"


getSpanName :: ImmutableSpan -> IO Text
getSpanName s = hotName <$> readIORef (spanHot s)


getSpanStatus :: ImmutableSpan -> IO SpanStatus
getSpanStatus s = hotStatus <$> readIORef (spanHot s)


getSpanAttrs :: ImmutableSpan -> IO Attributes
getSpanAttrs s = hotAttributes <$> readIORef (spanHot s)


spec :: Spec
spec = describe "OpenTelemetry.Utils.Exceptions" $ do
  describe "inSpanM" $ do
    it "creates a span with the given name" $ do
      (spans, _) <- withTracer $ \t ->
        inSpanM t "test-operation" defaultSpanArguments (pure ())
      name <- getSpanName (firstSpan spans)
      name `shouldBe` "test-operation"

    it "returns the action's result" $ do
      (_, result) <- withTracer $ \t ->
        inSpanM t "compute" defaultSpanArguments (pure (42 :: Int))
      result `shouldBe` 42

    it "records exception and rethrows on failure" $ do
      (spans, result) <- withTracer $ \t -> do
        r <-
          try $
            inSpanM t "failing" defaultSpanArguments $
              throwIO (userError "boom")
        pure (r :: Either IOException ())
      case result of
        Left _ -> pure ()
        Right _ -> expectationFailure "expected exception"
      let s = firstSpan spans
      status <- getSpanStatus s
      status `shouldBe` Error "user error (boom)"

    it "sets code.function attribute from callstack" $ do
      (spans, _) <- withTracer $ \t ->
        inSpanM t "traced" defaultSpanArguments (pure ())
      let s = firstSpan spans
      attrs <- getSpanAttrs s
      lookupAttribute attrs "code.function"
        `shouldSatisfy` (/= Nothing)

  describe "inSpanM'" $ do
    it "provides the span to the callback" $ do
      spanRef <- newIORef (Nothing :: Maybe Span)
      (spans, _) <- withTracer $ \t ->
        inSpanM' t "with-span" defaultSpanArguments $ \s -> do
          writeIORef spanRef (Just s)
          addAttribute s ("custom.attr" :: Text) ("hello" :: Text)
      let s = firstSpan spans
      attrs <- getSpanAttrs s
      lookupAttribute attrs "custom.attr"
        `shouldBe` Just (AttributeValue (TextAttribute "hello"))

  describe "inSpanM''" $ do
    it "restores parent context after span ends" $ do
      (spans, _) <- withTracer $ \t -> do
        inSpanM t "outer" defaultSpanArguments $ do
          inSpanM t "inner" defaultSpanArguments (pure ())
      length spans `shouldSatisfy` (>= 2)
      innerSpans <- filterM (\s -> (== "inner") <$> getSpanName s) spans
      case innerSpans of
        [] -> expectationFailure "no span named 'inner'"
        (inner : _) -> case spanParent inner of
          Nothing -> expectationFailure "expected inner span to have a parent"
          Just _ -> pure ()
