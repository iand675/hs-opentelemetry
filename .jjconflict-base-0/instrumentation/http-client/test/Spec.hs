{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.IORef
import qualified Data.Text as T
import Network.HTTP.Client (parseRequest)
import OpenTelemetry.Attributes (lookupAttribute)
import OpenTelemetry.Attributes.Attribute (Attribute (..), PrimitiveAttribute (..))
import OpenTelemetry.Attributes.Key (unkey)
import qualified OpenTelemetry.SemanticConventions as SC
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Exporter.InMemory.Span (inMemoryListExporter)
import OpenTelemetry.Instrumentation.HttpClient.Raw
import OpenTelemetry.Trace.Core
import System.Environment (setEnv)
import Test.Hspec


main :: IO ()
main = do
  setEnv "OTEL_SEMCONV_STABILITY_OPT_IN" "http"
  hspec spec


withTestSpan :: T.Text -> (Context.Context -> Span -> IO a) -> IO (ImmutableSpan, a)
withTestSpan name action = do
  (processor, ref) <- inMemoryListExporter
  tp <- createTracerProvider [processor] emptyTracerProviderOptions
  setGlobalTracerProvider tp
  let tracer = makeTracer tp "test" tracerOptions
  s <- createSpan tracer Context.empty name (defaultSpanArguments {kind = Client})
  let ctx = Context.insertSpan s Context.empty
  result <- action ctx s
  endSpan s Nothing
  _ <- shutdownTracerProvider tp Nothing
  spans <- readIORef ref
  case spans of
    (clientSpan : _) -> pure (clientSpan, result)
    [] -> error "No spans recorded"


spec :: Spec
spec = describe "HTTP client instrumentation" $ do
  describe "instrumentRequest" $ do
    it "sets span name to HTTP method (low cardinality)" $ do
      req <- parseRequest "http://example.com/users/123?q=test"
      (clientSpan, _) <- withTestSpan "HTTP" $ \ctx _s -> do
        _ <- instrumentRequest httpClientInstrumentationConfig ctx req
        pure ()
      hot <- readIORef (spanHot clientSpan)
      hotName hot `shouldBe` "GET"

    it "uses requestName override when provided" $ do
      req <- parseRequest "http://example.com/users/123"
      let conf = httpClientInstrumentationConfig {requestName = Just "custom-op"}
      (clientSpan, _) <- withTestSpan "HTTP" $ \ctx _s -> do
        _ <- instrumentRequest conf ctx req
        pure ()
      hot <- readIORef (spanHot clientSpan)
      hotName hot `shouldBe` "custom-op"

    it "sets http.request.method" $ do
      req <- parseRequest "POST http://example.com/api/data"
      (clientSpan, _) <- withTestSpan "HTTP" $ \ctx _s -> do
        _ <- instrumentRequest httpClientInstrumentationConfig ctx req
        pure ()
      hot <- readIORef (spanHot clientSpan)
      lookupAttribute (hotAttributes hot) (unkey SC.http_request_method)
        `shouldBe` Just (AttributeValue (TextAttribute "POST"))

    it "sets url.path" $ do
      req <- parseRequest "http://example.com/api/data"
      (clientSpan, _) <- withTestSpan "HTTP" $ \ctx _s -> do
        _ <- instrumentRequest httpClientInstrumentationConfig ctx req
        pure ()
      hot <- readIORef (spanHot clientSpan)
      lookupAttribute (hotAttributes hot) (unkey SC.url_path)
        `shouldBe` Just (AttributeValue (TextAttribute "/api/data"))

    it "sets server.address" $ do
      req <- parseRequest "http://example.com/test"
      (clientSpan, _) <- withTestSpan "HTTP" $ \ctx _s -> do
        _ <- instrumentRequest httpClientInstrumentationConfig ctx req
        pure ()
      hot <- readIORef (spanHot clientSpan)
      lookupAttribute (hotAttributes hot) (unkey SC.server_address)
        `shouldBe` Just (AttributeValue (TextAttribute "example.com"))

    it "sets server.port" $ do
      req <- parseRequest "http://example.com:8080/test"
      (clientSpan, _) <- withTestSpan "HTTP" $ \ctx _s -> do
        _ <- instrumentRequest httpClientInstrumentationConfig ctx req
        pure ()
      hot <- readIORef (spanHot clientSpan)
      lookupAttribute (hotAttributes hot) (unkey SC.server_port)
        `shouldBe` Just (AttributeValue (IntAttribute 8080))

    it "sets url.scheme to http" $ do
      req <- parseRequest "http://example.com/test"
      (clientSpan, _) <- withTestSpan "HTTP" $ \ctx _s -> do
        _ <- instrumentRequest httpClientInstrumentationConfig ctx req
        pure ()
      hot <- readIORef (spanHot clientSpan)
      lookupAttribute (hotAttributes hot) (unkey SC.url_scheme)
        `shouldBe` Just (AttributeValue (TextAttribute "http"))
