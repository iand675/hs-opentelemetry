module OpenTelemetry.Trace.TraceFlagsSpec where

import Data.Word (Word8)
import OpenTelemetry.Trace.Core
import Test.Hspec


spec :: Spec
spec = describe "TraceFlags" $ do
  -- Trace API §TraceFlags: sampled flag (bit 0)
  -- https://opentelemetry.io/docs/specs/otel/trace/api/#traceflags
  describe "sampled bit" $ do
    it "starts unsampled by default" $ do
      defaultTraceFlags `shouldSatisfy` (not . isSampled)
    specify "setSampled updates flags correctly" $ do
      setSampled defaultTraceFlags `shouldSatisfy` isSampled
    specify "unsetSampled updates flags correctly" $ do
      unsetSampled (setSampled defaultTraceFlags) `shouldSatisfy` (not . isSampled)

  -- Trace API §TraceFlags: random trace flag (W3C Level 2, bit 1)
  -- https://opentelemetry.io/docs/specs/otel/trace/api/#traceflags
  describe "W3C Level 2 random bit" $ do
    it "starts without random flag by default" $ do
      defaultTraceFlags `shouldSatisfy` (not . isRandom)

    it "setRandom sets bit 1" $ do
      setRandom defaultTraceFlags `shouldSatisfy` isRandom

    it "unsetRandom clears bit 1" $ do
      unsetRandom (setRandom defaultTraceFlags) `shouldSatisfy` (not . isRandom)

    it "random and sampled are independent" $ do
      let both = setRandom (setSampled defaultTraceFlags)
      both `shouldSatisfy` isSampled
      both `shouldSatisfy` isRandom
      unsetSampled both `shouldSatisfy` isRandom
      unsetSampled both `shouldSatisfy` (not . isSampled)
      unsetRandom both `shouldSatisfy` isSampled
      unsetRandom both `shouldSatisfy` (not . isRandom)

    it "random flag roundtrips through Word8" $ do
      let flags = setRandom (setSampled defaultTraceFlags)
          w = traceFlagsValue flags
      w `shouldBe` (0x03 :: Word8)
      traceFlagsFromWord8 w `shouldSatisfy` isSampled
      traceFlagsFromWord8 w `shouldSatisfy` isRandom

    it "traceFlagsFromWord8 preserves random bit from remote context" $ do
      let remoteFlags = traceFlagsFromWord8 0x02
      remoteFlags `shouldSatisfy` isRandom
      remoteFlags `shouldSatisfy` (not . isSampled)
