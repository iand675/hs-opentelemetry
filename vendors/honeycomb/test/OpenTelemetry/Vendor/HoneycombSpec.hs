{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.Vendor.HoneycombSpec where

import Data.Time.Calendar.OrdinalDate
import Data.Time.Clock
import OpenTelemetry.Trace.Id (bytesToTraceId)
import OpenTelemetry.Vendor.Honeycomb
import Test.Hspec
import Prelude


spec :: Spec
spec = describe "Honeycomb vendor integration" $ do
  let team_ = HoneycombTeam "teamName"
      Right fakeTraceId = bytesToTraceId "\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f"
      fakeUTCTime = UTCTime (fromOrdinalDate 2022 10) 0
  it "generates valid trace links for classic" $ do
    makeDirectTraceLink (HoneycombTarget team_ (Classic "datasetName")) fakeUTCTime fakeTraceId
      `shouldBe` "https://ui.honeycomb.io/teamName/datasets/datasetName/trace?trace_id=000102030405060708090a0b0c0d0e0f&trace_start_ts=1641769200&trace_end_ts=1641776400"
  it "generates valid trace links for current" $ do
    makeDirectTraceLink (HoneycombTarget team_ (Current (EnvironmentName "environmentName") "datasetName")) fakeUTCTime fakeTraceId
      `shouldBe` "https://ui.honeycomb.io/teamName/environments/environmentName/datasets/datasetName/trace?trace_id=000102030405060708090a0b0c0d0e0f&trace_start_ts=1641769200&trace_end_ts=1641776400"

