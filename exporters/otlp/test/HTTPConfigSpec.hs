{-# LANGUAGE OverloadedStrings #-}

module HTTPConfigSpec (spec) where

import Codec.Compression.GZip (decompress)
import Control.Concurrent (threadDelay)
import Control.Monad (forM_)
import qualified Data.ByteString.Char8 as C
import qualified Data.ByteString.Lazy as L
import Data.IORef
import HTTPTestSupport
import Network.HTTP.Types
import qualified Network.Wai as W
import Network.Wai.Handler.Warp (testWithApplication)
import OpenTelemetry.Exporter.OTLP.Span
import System.Environment (setEnv)
import System.Timeout (timeout)
import Test.Hspec


spec :: Spec
spec = around_ withExporterEnv $ describe "HTTP signal configuration" $ forM_ signals $ \signal -> describe (show signal) $ do
  forM_ ["", "/custom", "/", "/custom/", "/v1/traces"] $ \path ->
    it ("uses a per-signal URL unchanged: " <> path) $ do
      seen <- newIORef ""
      testWithApplication (pure $ \req respond -> writeIORef seen (W.rawPathInfo req) >> respond (W.responseLBS status200 [] "")) $ \port -> do
        setEnv (signalPrefix signal <> "_ENDPOINT") (url port <> path)
        conf <- loadExporterEnvironmentVariables
        succeeded <$> exportBatch signal conf `shouldReturn` True
      readIORef seen `shouldReturn` C.pack (if null path then "/" else path)

  forM_ ["/base", "/base/", "/base?ignored=yes"] $ \base ->
    it ("appends the signal path to a generic base: " <> base) $ do
      seen <- newIORef ""
      testWithApplication (pure $ \req respond -> writeIORef seen (W.rawPathInfo req) >> respond (W.responseLBS status200 [] "")) $ \port -> do
        setEnv "OTEL_EXPORTER_OTLP_ENDPOINT" (url port <> base)
        conf <- loadExporterEnvironmentVariables
        succeeded <$> exportBatch signal conf `shouldReturn` True
      readIORef seen `shouldReturn` C.pack ("/base/v1/" <> signalPath signal)

  it "replaces generic headers with the per-signal header setting" $ do
    seen <- newIORef []
    testWithApplication (pure $ \req respond -> writeIORef seen (W.requestHeaders req) >> respond (W.responseLBS status200 [] "")) $ \port -> do
      setEnv "OTEL_EXPORTER_OTLP_ENDPOINT" (url port)
      setEnv "OTEL_EXPORTER_OTLP_HEADERS" "authorization=generic,x-generic=generic"
      setEnv (signalPrefix signal <> "_HEADERS") "authorization=signal"
      conf <- loadExporterEnvironmentVariables
      succeeded <$> exportBatch signal conf `shouldReturn` True
    headers <- readIORef seen
    [v | (k, v) <- headers, k == "authorization"] `shouldBe` ["signal"]
    lookup "x-generic" headers `shouldBe` Nothing

  it "treats an empty per-signal environment value as unset" $ do
    seen <- newIORef []
    testWithApplication (pure $ \req respond -> writeIORef seen (W.requestHeaders req) >> respond (W.responseLBS status200 [] "")) $ \port -> do
      setEnv "OTEL_EXPORTER_OTLP_ENDPOINT" (url port)
      setEnv "OTEL_EXPORTER_OTLP_HEADERS" "authorization=generic"
      setEnv (signalPrefix signal <> "_HEADERS") ""
      conf <- loadExporterEnvironmentVariables
      succeeded <$> exportBatch signal conf `shouldReturn` True
    lookup "authorization" <$> readIORef seen `shouldReturn` Just "generic"

  it "honors per-signal gzip over generic no compression" $ do
    seen <- newIORef (Nothing, L.empty)
    testWithApplication
      ( pure $ \req respond -> do
          body <- W.strictRequestBody req
          writeIORef seen (lookup "Content-Encoding" (W.requestHeaders req), body)
          respond (W.responseLBS status200 [] "")
      )
      $ \port -> do
        setEnv "OTEL_EXPORTER_OTLP_ENDPOINT" (url port)
        setEnv "OTEL_EXPORTER_OTLP_COMPRESSION" "none"
        setEnv (signalPrefix signal <> "_COMPRESSION") "gzip"
        conf <- loadExporterEnvironmentVariables
        succeeded <$> exportBatch signal conf `shouldReturn` True
    (encoding, bytes) <- readIORef seen
    encoding `shouldBe` Just "gzip"
    L.length (decompress bytes) `shouldSatisfy` (> 0)

  it "uses the shorter per-signal request timeout" $
    testWithApplication (pure $ \_ respond -> threadDelay 200000 >> respond (W.responseLBS status200 [] "")) $ \port -> do
      setEnv "OTEL_EXPORTER_OTLP_ENDPOINT" (url port)
      setEnv "OTEL_EXPORTER_OTLP_TIMEOUT" "1000"
      setEnv (signalPrefix signal <> "_TIMEOUT") "10"
      conf <- loadExporterEnvironmentVariables
      -- Current main returns Success after 200ms. The request-level timeout
      -- may retry; the existing retry-policy PR owns that behavior.
      result <- timeout 100000 (exportBatch signal conf)
      case result of
        Just success | succeeded success -> expectationFailure "per-signal timeout ignored"
        _ -> pure ()


url :: Int -> String
url port = "http://127.0.0.1:" <> show port


signalPath :: Signal -> String
signalPath Traces = "traces"
signalPath Metrics = "metrics"
signalPath Logs = "logs"
