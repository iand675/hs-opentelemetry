{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.IORef
import Data.Text (Text)
import qualified Data.Vault.Lazy as Vault
import Network.HTTP.Types
import Network.Socket (SockAddr (..))
import Network.Wai (defaultRequest, responseLBS)
import Network.Wai.Internal (Request (..), ResponseReceived (..))
import OpenTelemetry.Attributes (lookupAttribute)
import OpenTelemetry.Attributes.Attribute (Attribute (..), PrimitiveAttribute (..))
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Context.ThreadLocal (getContext)
import OpenTelemetry.Exporter.InMemory.Span (inMemoryListExporter)
import OpenTelemetry.Instrumentation.Wai (newOpenTelemetryWaiMiddleware')
import OpenTelemetry.Trace.Core
import System.Environment (setEnv)
import Test.Hspec


main :: IO ()
main = do
  setEnv "OTEL_SEMCONV_STABILITY_OPT_IN" "http"
  hspec spec


mkRequest :: StdMethod -> [Header] -> Request
mkRequest method_ headers =
  defaultRequest
    { requestMethod = renderStdMethod method_
    , rawPathInfo = "/users/123"
    , requestHeaders = headers
    , remoteHost = SockAddrInet 12345 0x0100007f
    , vault = Vault.empty
    }


withTestMiddleware :: (TracerProvider -> IO ResponseReceived) -> IO [ImmutableSpan]
withTestMiddleware action = do
  (processor, ref) <- inMemoryListExporter
  tp <- createTracerProvider [processor] emptyTracerProviderOptions
  _ <- action tp
  shutdownTracerProvider tp
  readIORef ref


firstSpan :: [ImmutableSpan] -> ImmutableSpan
firstSpan (s : _) = s
firstSpan [] = error "No spans recorded"


spec :: Spec
spec = describe "WAI middleware" $ do
  describe "span naming" $ do
    it "initial span name is just the HTTP method (low cardinality)" $ do
      spans <- withTestMiddleware $ \tp -> do
        let mw = newOpenTelemetryWaiMiddleware' tp
            app _req respond = respond $ responseLBS ok200 [] "ok"
            req = mkRequest GET [("Host", "example.com")]
        mw app req $ \_ -> pure ResponseReceived
      hot <- readIORef (spanHot (firstSpan spans))
      hotName hot `shouldBe` "GET"

    it "updates span name to {method} {route} when http.route is set" $ do
      spans <- withTestMiddleware $ \tp -> do
        let mw = newOpenTelemetryWaiMiddleware' tp
            app _req respond = do
              ctx <- getContext
              case Context.lookupSpan ctx of
                Just s -> addAttribute s ("http.route" :: Text) ("/users/:id" :: Text)
                Nothing -> pure ()
              respond $ responseLBS ok200 [] "ok"
            req = mkRequest GET [("Host", "example.com")]
        mw app req $ \_ -> pure ResponseReceived
      hot <- readIORef (spanHot (firstSpan spans))
      hotName hot `shouldBe` "GET /users/:id"

  describe "error.type attribute" $ do
    it "sets error.type on 5xx responses" $ do
      spans <- withTestMiddleware $ \tp -> do
        let mw = newOpenTelemetryWaiMiddleware' tp
            app _req respond = respond $ responseLBS internalServerError500 [] "err"
            req = mkRequest GET [("Host", "example.com")]
        mw app req $ \_ -> pure ResponseReceived
      hot <- readIORef (spanHot (firstSpan spans))
      lookupAttribute (hotAttributes hot) "error.type"
        `shouldBe` Just (AttributeValue (TextAttribute "500"))

    it "does not set error.type on 2xx responses" $ do
      spans <- withTestMiddleware $ \tp -> do
        let mw = newOpenTelemetryWaiMiddleware' tp
            app _req respond = respond $ responseLBS ok200 [] "ok"
            req = mkRequest GET [("Host", "example.com")]
        mw app req $ \_ -> pure ResponseReceived
      hot <- readIORef (spanHot (firstSpan spans))
      lookupAttribute (hotAttributes hot) "error.type"
        `shouldBe` Nothing

    it "does not set error.type on 4xx responses" $ do
      spans <- withTestMiddleware $ \tp -> do
        let mw = newOpenTelemetryWaiMiddleware' tp
            app _req respond = respond $ responseLBS notFound404 [] "nope"
            req = mkRequest GET [("Host", "example.com")]
        mw app req $ \_ -> pure ResponseReceived
      hot <- readIORef (spanHot (firstSpan spans))
      lookupAttribute (hotAttributes hot) "error.type"
        `shouldBe` Nothing

  describe "stable HTTP attributes (OTEL_SEMCONV_STABILITY_OPT_IN=http)" $ do
    it "sets http.request.method" $ do
      spans <- withTestMiddleware $ \tp -> do
        let mw = newOpenTelemetryWaiMiddleware' tp
            app _req respond = respond $ responseLBS ok200 [] "ok"
            req = mkRequest POST [("Host", "example.com")]
        mw app req $ \_ -> pure ResponseReceived
      hot <- readIORef (spanHot (firstSpan spans))
      lookupAttribute (hotAttributes hot) "http.request.method"
        `shouldBe` Just (AttributeValue (TextAttribute "POST"))

    it "sets url.path" $ do
      spans <- withTestMiddleware $ \tp -> do
        let mw = newOpenTelemetryWaiMiddleware' tp
            app _req respond = respond $ responseLBS ok200 [] "ok"
            req = mkRequest GET [("Host", "example.com")]
        mw app req $ \_ -> pure ResponseReceived
      hot <- readIORef (spanHot (firstSpan spans))
      lookupAttribute (hotAttributes hot) "url.path"
        `shouldBe` Just (AttributeValue (TextAttribute "/users/123"))

    it "sets server.address from Host header" $ do
      spans <- withTestMiddleware $ \tp -> do
        let mw = newOpenTelemetryWaiMiddleware' tp
            app _req respond = respond $ responseLBS ok200 [] "ok"
            req = mkRequest GET [("Host", "example.com:8080")]
        mw app req $ \_ -> pure ResponseReceived
      hot <- readIORef (spanHot (firstSpan spans))
      lookupAttribute (hotAttributes hot) "server.address"
        `shouldBe` Just (AttributeValue (TextAttribute "example.com"))

    it "sets http.response.status_code" $ do
      spans <- withTestMiddleware $ \tp -> do
        let mw = newOpenTelemetryWaiMiddleware' tp
            app _req respond = respond $ responseLBS ok200 [] "ok"
            req = mkRequest GET [("Host", "example.com")]
        mw app req $ \_ -> pure ResponseReceived
      hot <- readIORef (spanHot (firstSpan spans))
      lookupAttribute (hotAttributes hot) "http.response.status_code"
        `shouldBe` Just (AttributeValue (IntAttribute 200))

    it "sets url.scheme" $ do
      spans <- withTestMiddleware $ \tp -> do
        let mw = newOpenTelemetryWaiMiddleware' tp
            app _req respond = respond $ responseLBS ok200 [] "ok"
            req = mkRequest GET [("Host", "example.com")]
        mw app req $ \_ -> pure ResponseReceived
      hot <- readIORef (spanHot (firstSpan spans))
      lookupAttribute (hotAttributes hot) "url.scheme"
        `shouldBe` Just (AttributeValue (TextAttribute "http"))

    it "sets server.port default 80 for non-secure" $ do
      spans <- withTestMiddleware $ \tp -> do
        let mw = newOpenTelemetryWaiMiddleware' tp
            app _req respond = respond $ responseLBS ok200 [] "ok"
            req = mkRequest GET [("Host", "example.com")]
        mw app req $ \_ -> pure ResponseReceived
      hot <- readIORef (spanHot (firstSpan spans))
      lookupAttribute (hotAttributes hot) "server.port"
        `shouldBe` Just (AttributeValue (IntAttribute 80))
