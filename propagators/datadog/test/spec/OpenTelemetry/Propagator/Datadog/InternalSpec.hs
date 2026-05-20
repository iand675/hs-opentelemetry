{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.Propagator.Datadog.InternalSpec where

import qualified Data.ByteString as B
import qualified Data.ByteString.Char8 as BC
import Data.Word (Word64, Word8)
import OpenTelemetry.Internal.Trace.Id (SpanId, TraceId, bytesToSpanId, bytesToTraceId)
import OpenTelemetry.Propagator.Datadog.Internal
import Test.Hspec
import Test.QuickCheck


mkTraceId :: [Word8] -> TraceId
mkTraceId bs = case bytesToTraceId (B.pack bs) of
  Right t -> t
  Left _ -> error "bad trace id"


mkSpanId :: [Word8] -> SpanId
mkSpanId bs = case bytesToSpanId (B.pack bs) of
  Right s -> s
  Left _ -> error "bad span id"


spec :: Spec
spec =
  -- Datadog decimal trace/parent id header encoding
  -- https://docs.datadoghq.com/tracing/trace_collection/trace_context_propagation/
  do
    context "newTraceIdFromHeader / newHeaderFromTraceId" $ do
      it "round-trips decimal header bytes to TraceId (zero high bits)" $
        property $ \(x1, x2, x3, x4, x5, x6, x7, x8) -> do
          let tid = mkTraceId $ replicate 8 0 ++ [x1, x2, x3, x4, x5, x6, x7, x8]
          newTraceIdFromHeader (newHeaderFromTraceId tid) `shouldBe` tid

      it "round-trips TraceId (zero high) to decimal header" $
        property $ \x -> do
          let x' = BC.pack $ show (x :: Word64)
          newHeaderFromTraceId (newTraceIdFromHeader x') `shouldBe` x'

    context "newSpanIdFromHeader / newHeaderFromSpanId" $ do
      it "round-trips decimal header bytes to SpanId" $
        property $ \(x1, x2, x3, x4, x5, x6, x7, x8) -> do
          let sid = mkSpanId [x1, x2, x3, x4, x5, x6, x7, x8]
          newSpanIdFromHeader (newHeaderFromSpanId sid) `shouldBe` sid

      it "round-trips SpanId to decimal header" $
        property $ \x -> do
          let x' = BC.pack $ show (x :: Word64)
          newHeaderFromSpanId (newSpanIdFromHeader x') `shouldBe` x'
