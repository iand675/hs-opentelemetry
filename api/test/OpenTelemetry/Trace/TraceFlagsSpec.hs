module OpenTelemetry.Trace.TraceFlagsSpec where

import OpenTelemetry.Trace.Core
import Test.Hspec


spec :: Spec
spec = describe "TraceFlags" $ do
  it "starts unsampled by default" $ do
    defaultTraceFlags `shouldSatisfy` (not . isSampled)
  specify "setSampled updates flags correctly" $ do
    setSampled defaultTraceFlags `shouldSatisfy` isSampled
  specify "unsetSampled updates flags correctly" $ do
    unsetSampled (setSampled defaultTraceFlags) `shouldSatisfy` (not . isSampled)
