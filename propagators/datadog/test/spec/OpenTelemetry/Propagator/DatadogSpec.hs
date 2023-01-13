{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -Wno-type-defaults #-}

module OpenTelemetry.Propagator.DatadogSpec where

import qualified Data.ByteString as B
import qualified Data.ByteString.Short as SB
import OpenTelemetry.Propagator.Datadog
import OpenTelemetry.Trace.Id
import Test.Hspec
import Test.QuickCheck


spec :: Spec
spec = do
  context "convertOpenTelemetrySpanIdToDatadogSpanId" $ do
    it "can conert values" $
      property $ \(x1, x2, x3, x4, x5, x6, x7, x8) -> do
        let
          v =
            fromIntegral x1 * (2 ^ 8) ^ 7
              + fromIntegral x2 * (2 ^ 8) ^ 6
              + fromIntegral x3 * (2 ^ 8) ^ 5
              + fromIntegral x4 * (2 ^ 8) ^ 4
              + fromIntegral x5 * (2 ^ 8) ^ 3
              + fromIntegral x6 * (2 ^ 8) ^ 2
              + fromIntegral x7 * (2 ^ 8) ^ 1
              + fromIntegral x8
          spanId = SpanId $ SB.toShort $ B.pack [x1, x2, x3, x4, x5, x6, x7, x8]
        convertOpenTelemetrySpanIdToDatadogSpanId spanId `shouldBe` v

  context "convertOpenTelemetryTraceIdToDatadogTraceId" $ do
    it "can conert values" $
      property $ \(x1, x2, x3, x4, x5, x6, x7, x8) -> do
        let
          v =
            fromIntegral x1 * (2 ^ 8) ^ 7
              + fromIntegral x2 * (2 ^ 8) ^ 6
              + fromIntegral x3 * (2 ^ 8) ^ 5
              + fromIntegral x4 * (2 ^ 8) ^ 4
              + fromIntegral x5 * (2 ^ 8) ^ 3
              + fromIntegral x6 * (2 ^ 8) ^ 2
              + fromIntegral x7 * (2 ^ 8) ^ 1
              + fromIntegral x8
          traceId = TraceId $ SB.toShort $ B.pack $ replicate 8 0 ++ [x1, x2, x3, x4, x5, x6, x7, x8]
        convertOpenTelemetryTraceIdToDatadogTraceId traceId `shouldBe` v
