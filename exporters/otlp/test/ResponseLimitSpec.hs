{-# LANGUAGE OverloadedStrings #-}

module ResponseLimitSpec (spec) where

import Codec.Compression.GZip (compress)
import Control.Monad (forM_, replicateM_)
import Data.ByteString.Builder (lazyByteString)
import qualified Data.ByteString.Lazy as L
import Data.IORef
import HTTPTestSupport
import Network.HTTP.Types
import qualified Network.Wai as W
import Network.Wai.Handler.Warp (testWithApplication)
import OpenTelemetry.Exporter.OTLP.HTTP (defaultMaxResponseBytes)
import OpenTelemetry.Exporter.OTLP.Span
import System.Environment (setEnv)
import System.Timeout (timeout)
import Test.Hspec


spec :: Spec
spec = around_ withExporterEnv $ describe "HTTP response limits" $ forM_ signals $ \signal -> describe (show signal) $ do
  forM_ [1022, 1024, 1026] $ \size ->
    it ("enforces an explicit budget at byte " <> show size) $ do
      result <- send signal (Just 1024) status200 [] (payload size)
      result `shouldBe` (size <= 1024)

  it "supports an explicitly larger response budget" $ do
    send signal (Just 2048) status200 [] (payload 1026) `shouldReturn` True

  it "rejects oversized gzip after decompression" $ do
    send signal (Just 1024) status200 [("Content-Encoding", "gzip")] (compress (payload 8192)) `shouldReturn` False

  it "accepts gzip whose decompressed body fits" $ do
    send signal (Just 1024) status200 [("Content-Encoding", "gzip")] (compress (payload 1024)) `shouldReturn` True

  it "applies the default budget to ordinary and gzip responses" $ do
    send signal Nothing status200 [] (payload (defaultMaxResponseBytes + 2)) `shouldReturn` False
    send signal Nothing status200 [("Content-Encoding", "gzip")] (compress (payload (defaultMaxResponseBytes + 2))) `shouldReturn` False

  it "rejects oversized chunked responses without trusting Content-Length" $ do
    testWithApplication
      ( pure $ \_ respond -> respond $ W.responseStream status200 [] $ \write flush ->
          replicateM_ 16 (write (lazyByteString (payload 128)) >> flush)
      )
      $ \port -> do
        setEnv "OTEL_EXPORTER_OTLP_ENDPOINT" (url port)
        conf <- loadExporterEnvironmentVariables
        result <- timeout 1000000 (exportBatchWithLimit (Just 1024) signal conf)
        fmap succeeded result `shouldBe` Just False

  it "does not retry an oversized retryable-status response" $ do
    calls <- newIORef (0 :: Int)
    testWithApplication (pure $ \_ respond -> modifyIORef' calls (+ 1) >> respond (W.responseLBS status503 [] (payload 2048))) $ \port -> do
      setEnv "OTEL_EXPORTER_OTLP_ENDPOINT" (url port)
      conf <- loadExporterEnvironmentVariables
      result <- timeout 1000000 (exportBatchWithLimit (Just 1024) signal conf)
      fmap succeeded result `shouldBe` Just False
    readIORef calls `shouldReturn` 1

  it "accepts an empty body with a zero-byte budget" $ do
    send signal (Just 0) status200 [] "" `shouldReturn` True


-- Repeated unknown protobuf varint fields: valid for every signal response.
payload :: Int -> L.ByteString
payload size = L.pack (take size (cycle [0x78, 0]))


url :: Int -> String
url port = "http://127.0.0.1:" <> show port


send :: Signal -> Maybe Int -> Status -> ResponseHeaders -> L.ByteString -> IO Bool
send signal limit status headers bytes =
  testWithApplication (pure $ \_ respond -> respond (W.responseLBS status headers bytes)) $ \port -> do
    setEnv "OTEL_EXPORTER_OTLP_ENDPOINT" (url port)
    conf <- loadExporterEnvironmentVariables
    succeeded <$> exportBatchWithLimit limit signal conf
