{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.IORef
import qualified Data.Vault.Lazy as Vault
import Network.HTTP.Types (RequestHeaders, ok200)
import Network.Socket (SockAddr (..))
import Network.Wai (defaultRequest, responseLBS)
import Network.Wai.Internal (Request (..), ResponseReceived (..))
import OpenTelemetry.Attributes (lookupAttribute)
import OpenTelemetry.Attributes.Attribute (Attribute (..), PrimitiveAttribute (..))
import OpenTelemetry.Exporter.InMemory.Span (inMemoryListExporter)
import OpenTelemetry.Instrumentation.Cloudflare (cloudflareInstrumentationMiddleware)
import OpenTelemetry.Instrumentation.Wai (newOpenTelemetryWaiMiddleware')
import OpenTelemetry.Trace.Core
import System.Environment (setEnv)
import Test.Hspec


main :: IO ()
main = do
  setEnv "OTEL_SEMCONV_STABILITY_OPT_IN" "http"
  hspec spec


spec :: Spec
spec = describe "Cloudflare middleware" $ do
  it "adds cf-connecting-ip header as attribute" $ do
    spans <-
      withCloudflareMiddleware
        [("cf-connecting-ip", "203.0.113.50"), ("Host", "example.com")]
    hot <- readIORef (spanHot (firstSpan spans))
    lookupAttribute (hotAttributes hot) "http.request.header.cf-connecting-ip"
      `shouldBe` Just (AttributeValue (TextAttribute "203.0.113.50"))

  it "adds cf-ray header as attribute" $ do
    spans <-
      withCloudflareMiddleware
        [("cf-ray", "abc123-LAX"), ("Host", "example.com")]
    hot <- readIORef (spanHot (firstSpan spans))
    lookupAttribute (hotAttributes hot) "http.request.header.cf-ray"
      `shouldBe` Just (AttributeValue (TextAttribute "abc123-LAX"))

  it "adds cf-ipcountry header as attribute" $ do
    spans <-
      withCloudflareMiddleware
        [("cf-ipcountry", "US"), ("Host", "example.com")]
    hot <- readIORef (spanHot (firstSpan spans))
    lookupAttribute (hotAttributes hot) "http.request.header.cf-ipcountry"
      `shouldBe` Just (AttributeValue (TextAttribute "US"))

  it "adds true-client-ip header as attribute" $ do
    spans <-
      withCloudflareMiddleware
        [("true-client-ip", "198.51.100.42"), ("Host", "example.com")]
    hot <- readIORef (spanHot (firstSpan spans))
    lookupAttribute (hotAttributes hot) "http.request.header.true-client-ip"
      `shouldBe` Just (AttributeValue (TextAttribute "198.51.100.42"))

  it "does not add attributes for missing CF headers" $ do
    spans <- withCloudflareMiddleware [("Host", "example.com")]
    hot <- readIORef (spanHot (firstSpan spans))
    lookupAttribute (hotAttributes hot) "http.request.header.cf-connecting-ip"
      `shouldBe` Nothing
    lookupAttribute (hotAttributes hot) "http.request.header.cf-ray"
      `shouldBe` Nothing


firstSpan :: [ImmutableSpan] -> ImmutableSpan
firstSpan (s : _) = s
firstSpan [] = error "No spans recorded"


withCloudflareMiddleware :: RequestHeaders -> IO [ImmutableSpan]
withCloudflareMiddleware headers = do
  (processor, ref) <- inMemoryListExporter
  tp <- createTracerProvider [processor] emptyTracerProviderOptions
  let waiMw = newOpenTelemetryWaiMiddleware' tp
      cfMw = cloudflareInstrumentationMiddleware
      app _req respond = respond $ responseLBS ok200 [] "ok"
      req =
        defaultRequest
          { requestMethod = "GET"
          , rawPathInfo = "/test"
          , requestHeaders = headers
          , remoteHost = SockAddrInet 12345 0x0100007f
          , vault = Vault.empty
          }
  _ <- waiMw (cfMw app) req $ \_ -> pure ResponseReceived
  _ <- shutdownTracerProvider tp Nothing
  readIORef ref
