{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.IORef
import qualified Data.Vault.Lazy as Vault
import Network.HTTP.Types (RequestHeaders, ok200)
import Network.Socket (SockAddr (..))
import Network.Wai (defaultRequest, responseLBS)
import Network.Wai.Internal (Request (..), ResponseReceived (..))
import OpenTelemetry.Attributes (Attributes, lookupAttribute)
import OpenTelemetry.Attributes.Attribute (Attribute (..), PrimitiveAttribute (..))
import OpenTelemetry.Exporter.InMemory.Span (inMemoryListExporter)
import OpenTelemetry.Instrumentation.Cloudflare
import OpenTelemetry.Instrumentation.Wai (newOpenTelemetryWaiMiddleware')
import OpenTelemetry.Trace.Core
import System.Environment (setEnv)
import Test.Hspec


main :: IO ()
main = do
  setEnv "OTEL_SEMCONV_STABILITY_OPT_IN" "http"
  hspec spec


spec :: Spec
spec = do
  describe "Cloudflare middleware (default config)" $ do
    coreHeaderSpecs
    semanticAttributeSpecs
    cfVisitorSpecs
    missingHeaderSpecs

  describe "Cloudflare middleware (config toggling)" $ do
    locationHeaderSpecs
    botHeaderSpecs
    disabledClientAddressSpecs
    disabledCfVisitorParsingSpecs


-------------------------------------------------------------------------------
-- Core raw header attributes
-------------------------------------------------------------------------------

coreHeaderSpecs :: Spec
coreHeaderSpecs = describe "core raw headers" $ do
  it "captures cf-connecting-ip" $ do
    attrs <- attrsFrom defaultCloudflareConfig [("cf-connecting-ip", "203.0.113.50"), ("Host", "example.com")]
    lookupAttribute attrs "http.request.header.cf-connecting-ip"
      `shouldBe` Just (AttributeValue (TextAttribute "203.0.113.50"))

  it "captures cf-ray" $ do
    attrs <- attrsFrom defaultCloudflareConfig [("cf-ray", "abc123-LAX"), ("Host", "example.com")]
    lookupAttribute attrs "http.request.header.cf-ray"
      `shouldBe` Just (AttributeValue (TextAttribute "abc123-LAX"))

  it "captures cf-ipcountry" $ do
    attrs <- attrsFrom defaultCloudflareConfig [("cf-ipcountry", "US"), ("Host", "example.com")]
    lookupAttribute attrs "http.request.header.cf-ipcountry"
      `shouldBe` Just (AttributeValue (TextAttribute "US"))

  it "captures true-client-ip" $ do
    attrs <- attrsFrom defaultCloudflareConfig [("true-client-ip", "198.51.100.42"), ("Host", "example.com")]
    lookupAttribute attrs "http.request.header.true-client-ip"
      `shouldBe` Just (AttributeValue (TextAttribute "198.51.100.42"))

  it "captures cf-worker" $ do
    attrs <- attrsFrom defaultCloudflareConfig [("cf-worker", "example.com"), ("Host", "example.com")]
    lookupAttribute attrs "http.request.header.cf-worker"
      `shouldBe` Just (AttributeValue (TextAttribute "example.com"))

  it "captures cf-visitor" $ do
    attrs <- attrsFrom defaultCloudflareConfig [("cf-visitor", "{\"scheme\":\"https\"}"), ("Host", "example.com")]
    lookupAttribute attrs "http.request.header.cf-visitor"
      `shouldBe` Just (AttributeValue (TextAttribute "{\"scheme\":\"https\"}"))

  it "captures cdn-loop" $ do
    attrs <- attrsFrom defaultCloudflareConfig [("cdn-loop", "cloudflare"), ("Host", "example.com")]
    lookupAttribute attrs "http.request.header.cdn-loop"
      `shouldBe` Just (AttributeValue (TextAttribute "cloudflare"))

  it "captures cf-ew-via" $ do
    attrs <- attrsFrom defaultCloudflareConfig [("cf-ew-via", "15"), ("Host", "example.com")]
    lookupAttribute attrs "http.request.header.cf-ew-via"
      `shouldBe` Just (AttributeValue (TextAttribute "15"))

  it "captures cf-connecting-ipv6" $ do
    attrs <- attrsFrom defaultCloudflareConfig [("cf-connecting-ipv6", "2001:db8::1"), ("Host", "example.com")]
    lookupAttribute attrs "http.request.header.cf-connecting-ipv6"
      `shouldBe` Just (AttributeValue (TextAttribute "2001:db8::1"))

  it "captures cf-connecting-o2o" $ do
    attrs <- attrsFrom defaultCloudflareConfig [("cf-connecting-o2o", "1"), ("Host", "example.com")]
    lookupAttribute attrs "http.request.header.cf-connecting-o2o"
      `shouldBe` Just (AttributeValue (TextAttribute "1"))


-------------------------------------------------------------------------------
-- Semantic attribute mapping
-------------------------------------------------------------------------------

semanticAttributeSpecs :: Spec
semanticAttributeSpecs = describe "semantic attributes" $ do
  it "sets client.address from cf-connecting-ip" $ do
    attrs <- attrsFrom defaultCloudflareConfig [("cf-connecting-ip", "203.0.113.50"), ("Host", "example.com")]
    lookupAttribute attrs "client.address"
      `shouldBe` Just (AttributeValue (TextAttribute "203.0.113.50"))

  it "falls back to true-client-ip for client.address when cf-connecting-ip is absent" $ do
    attrs <- attrsFrom defaultCloudflareConfig [("true-client-ip", "198.51.100.42"), ("Host", "example.com")]
    lookupAttribute attrs "client.address"
      `shouldBe` Just (AttributeValue (TextAttribute "198.51.100.42"))

  it "prefers cf-connecting-ip over true-client-ip for client.address" $ do
    attrs <-
      attrsFrom
        defaultCloudflareConfig
        [ ("cf-connecting-ip", "203.0.113.50")
        , ("true-client-ip", "198.51.100.42")
        , ("Host", "example.com")
        ]
    lookupAttribute attrs "client.address"
      `shouldBe` Just (AttributeValue (TextAttribute "203.0.113.50"))

  it "sets cloudflare.ray_id from cf-ray" $ do
    attrs <- attrsFrom defaultCloudflareConfig [("cf-ray", "abc123-LAX"), ("Host", "example.com")]
    lookupAttribute attrs "cloudflare.ray_id"
      `shouldBe` Just (AttributeValue (TextAttribute "abc123-LAX"))

  it "sets cloudflare.client.geo.country_code from cf-ipcountry" $ do
    attrs <- attrsFrom defaultCloudflareConfig [("cf-ipcountry", "US"), ("Host", "example.com")]
    lookupAttribute attrs "cloudflare.client.geo.country_code"
      `shouldBe` Just (AttributeValue (TextAttribute "US"))

  it "sets cloudflare.worker.upstream_zone from cf-worker" $ do
    attrs <- attrsFrom defaultCloudflareConfig [("cf-worker", "example.com"), ("Host", "example.com")]
    lookupAttribute attrs "cloudflare.worker.upstream_zone"
      `shouldBe` Just (AttributeValue (TextAttribute "example.com"))


-------------------------------------------------------------------------------
-- CF-Visitor parsing
-------------------------------------------------------------------------------

cfVisitorSpecs :: Spec
cfVisitorSpecs = describe "CF-Visitor parsing" $ do
  it "parses scheme from CF-Visitor JSON" $ do
    attrs <- attrsFrom defaultCloudflareConfig [("cf-visitor", "{\"scheme\":\"https\"}"), ("Host", "example.com")]
    lookupAttribute attrs "cloudflare.visitor.scheme"
      `shouldBe` Just (AttributeValue (TextAttribute "https"))

  it "parses http scheme" $ do
    attrs <- attrsFrom defaultCloudflareConfig [("cf-visitor", "{\"scheme\":\"http\"}"), ("Host", "example.com")]
    lookupAttribute attrs "cloudflare.visitor.scheme"
      `shouldBe` Just (AttributeValue (TextAttribute "http"))

  it "handles whitespace in CF-Visitor" $ do
    attrs <- attrsFrom defaultCloudflareConfig [("cf-visitor", "  {\"scheme\":\"https\"}  "), ("Host", "example.com")]
    lookupAttribute attrs "cloudflare.visitor.scheme"
      `shouldBe` Just (AttributeValue (TextAttribute "https"))

  it "does not set cloudflare.visitor.scheme on malformed JSON" $ do
    attrs <- attrsFrom defaultCloudflareConfig [("cf-visitor", "not json"), ("Host", "example.com")]
    lookupAttribute attrs "cloudflare.visitor.scheme"
      `shouldBe` Nothing


-------------------------------------------------------------------------------
-- Missing headers
-------------------------------------------------------------------------------

missingHeaderSpecs :: Spec
missingHeaderSpecs = describe "missing headers" $ do
  it "does not add attributes for absent CF headers" $ do
    attrs <- attrsFrom defaultCloudflareConfig [("Host", "example.com")]
    lookupAttribute attrs "http.request.header.cf-connecting-ip" `shouldBe` Nothing
    lookupAttribute attrs "http.request.header.cf-ray" `shouldBe` Nothing
    lookupAttribute attrs "cloudflare.ray_id" `shouldBe` Nothing
    lookupAttribute attrs "client.address" `shouldBe` Nothing


-------------------------------------------------------------------------------
-- Location headers (opt-in on Cloudflare dashboard)
-------------------------------------------------------------------------------

locationHeaderSpecs :: Spec
locationHeaderSpecs = describe "location headers" $ do
  it "captures location headers with default config" $ do
    attrs <-
      attrsFrom
        defaultCloudflareConfig
        [ ("cf-ipcity", "San Francisco")
        , ("cf-ipcontinent", "NA")
        , ("cf-iplongitude", "-122.4194")
        , ("cf-iplatitude", "37.7749")
        , ("cf-region", "California")
        , ("cf-region-code", "CA")
        , ("cf-metro-code", "807")
        , ("cf-postal-code", "94105")
        , ("cf-timezone", "America/Los_Angeles")
        , ("Host", "example.com")
        ]
    lookupAttribute attrs "http.request.header.cf-ipcity"
      `shouldBe` Just (AttributeValue (TextAttribute "San Francisco"))
    lookupAttribute attrs "http.request.header.cf-ipcontinent"
      `shouldBe` Just (AttributeValue (TextAttribute "NA"))
    lookupAttribute attrs "http.request.header.cf-iplongitude"
      `shouldBe` Just (AttributeValue (TextAttribute "-122.4194"))
    lookupAttribute attrs "http.request.header.cf-iplatitude"
      `shouldBe` Just (AttributeValue (TextAttribute "37.7749"))
    lookupAttribute attrs "http.request.header.cf-region"
      `shouldBe` Just (AttributeValue (TextAttribute "California"))
    lookupAttribute attrs "http.request.header.cf-region-code"
      `shouldBe` Just (AttributeValue (TextAttribute "CA"))
    lookupAttribute attrs "http.request.header.cf-metro-code"
      `shouldBe` Just (AttributeValue (TextAttribute "807"))
    lookupAttribute attrs "http.request.header.cf-postal-code"
      `shouldBe` Just (AttributeValue (TextAttribute "94105"))
    lookupAttribute attrs "http.request.header.cf-timezone"
      `shouldBe` Just (AttributeValue (TextAttribute "America/Los_Angeles"))

  it "does not capture location headers when disabled" $ do
    let cfg = defaultCloudflareConfig {cfgCaptureLocationHeaders = False}
    attrs <- attrsFrom cfg [("cf-ipcity", "San Francisco"), ("Host", "example.com")]
    lookupAttribute attrs "http.request.header.cf-ipcity" `shouldBe` Nothing


-------------------------------------------------------------------------------
-- Bot Management headers
-------------------------------------------------------------------------------

botHeaderSpecs :: Spec
botHeaderSpecs = describe "bot management headers" $ do
  it "does not capture bot headers with default config" $ do
    attrs <-
      attrsFrom
        defaultCloudflareConfig
        [("cf-bot-score", "30"), ("cf-verified-bot", "true"), ("Host", "example.com")]
    lookupAttribute attrs "http.request.header.cf-bot-score" `shouldBe` Nothing
    lookupAttribute attrs "http.request.header.cf-verified-bot" `shouldBe` Nothing

  it "captures bot headers when enabled" $ do
    let cfg = defaultCloudflareConfig {cfgCaptureBotHeaders = True}
    attrs <-
      attrsFrom
        cfg
        [ ("cf-bot-score", "30")
        , ("cf-verified-bot", "true")
        , ("cf-ja3-hash", "abc123def456")
        , ("cf-ja4", "t13d1516h2_8daaf6152771_b186095e22b6")
        , ("Host", "example.com")
        ]
    lookupAttribute attrs "http.request.header.cf-bot-score"
      `shouldBe` Just (AttributeValue (TextAttribute "30"))
    lookupAttribute attrs "http.request.header.cf-verified-bot"
      `shouldBe` Just (AttributeValue (TextAttribute "true"))
    lookupAttribute attrs "http.request.header.cf-ja3-hash"
      `shouldBe` Just (AttributeValue (TextAttribute "abc123def456"))
    lookupAttribute attrs "http.request.header.cf-ja4"
      `shouldBe` Just (AttributeValue (TextAttribute "t13d1516h2_8daaf6152771_b186095e22b6"))


-------------------------------------------------------------------------------
-- Config: disable client.address override
-------------------------------------------------------------------------------

disabledClientAddressSpecs :: Spec
disabledClientAddressSpecs = describe "cfgSetClientAddress = False" $ do
  it "does not overwrite client.address when disabled" $ do
    let cfg = defaultCloudflareConfig {cfgSetClientAddress = False}
    attrs <- attrsFrom cfg [("cf-connecting-ip", "203.0.113.50"), ("Host", "example.com")]
    -- WAI middleware sets client.address from remoteHost (127.0.0.1 in test).
    -- The Cloudflare middleware should NOT overwrite it.
    lookupAttribute attrs "client.address"
      `shouldBe` Just (AttributeValue (TextAttribute "127.0.0.1"))

  it "still captures the raw header when client.address override is disabled" $ do
    let cfg = defaultCloudflareConfig {cfgSetClientAddress = False}
    attrs <- attrsFrom cfg [("cf-connecting-ip", "203.0.113.50"), ("Host", "example.com")]
    lookupAttribute attrs "http.request.header.cf-connecting-ip"
      `shouldBe` Just (AttributeValue (TextAttribute "203.0.113.50"))


-------------------------------------------------------------------------------
-- Config: disable CF-Visitor parsing
-------------------------------------------------------------------------------

disabledCfVisitorParsingSpecs :: Spec
disabledCfVisitorParsingSpecs = describe "cfgParseCfVisitor = False" $ do
  it "does not set cloudflare.visitor.scheme when parsing disabled" $ do
    let cfg = defaultCloudflareConfig {cfgParseCfVisitor = False}
    attrs <- attrsFrom cfg [("cf-visitor", "{\"scheme\":\"https\"}"), ("Host", "example.com")]
    lookupAttribute attrs "cloudflare.visitor.scheme" `shouldBe` Nothing

  it "still captures raw cf-visitor header when parsing disabled" $ do
    let cfg = defaultCloudflareConfig {cfgParseCfVisitor = False}
    attrs <- attrsFrom cfg [("cf-visitor", "{\"scheme\":\"https\"}"), ("Host", "example.com")]
    lookupAttribute attrs "http.request.header.cf-visitor"
      `shouldBe` Just (AttributeValue (TextAttribute "{\"scheme\":\"https\"}"))


-------------------------------------------------------------------------------
-- Helpers
-------------------------------------------------------------------------------

firstSpan :: [ImmutableSpan] -> ImmutableSpan
firstSpan (s : _) = s
firstSpan [] = error "No spans recorded"


attrsFrom :: CloudflareConfig -> RequestHeaders -> IO Attributes
attrsFrom cfg headers = do
  spans <- withCloudflareMiddleware cfg headers
  hot <- readIORef (spanHot (firstSpan spans))
  pure (hotAttributes hot)
  where
    withCloudflareMiddleware :: CloudflareConfig -> RequestHeaders -> IO [ImmutableSpan]
    withCloudflareMiddleware c hdrs = do
      (processor, ref) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      let waiMw = newOpenTelemetryWaiMiddleware' tp
          cfMw = cloudflareInstrumentationMiddleware' c
          app _req respond = respond $ responseLBS ok200 [] "ok"
          req =
            defaultRequest
              { requestMethod = "GET"
              , rawPathInfo = "/test"
              , requestHeaders = hdrs
              , remoteHost = SockAddrInet 12345 0x0100007f
              , vault = Vault.empty
              }
      _ <- waiMw (cfMw app) req $ \_ -> pure ResponseReceived
      _ <- shutdownTracerProvider tp Nothing
      readIORef ref
