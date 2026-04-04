{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.Context.EnvironmentSpec (spec) where

import OpenTelemetry.Context.Environment (normalizeKeyToEnvVar)
import Test.Hspec


spec :: Spec
spec = describe "Context.Environment" $ do
  describe "normalizeKeyToEnvVar" $ do
    it "uppercases W3C traceparent" $
      normalizeKeyToEnvVar "traceparent" `shouldBe` "TRACEPARENT"

    it "uppercases W3C tracestate" $
      normalizeKeyToEnvVar "tracestate" `shouldBe` "TRACESTATE"

    it "uppercases W3C baggage" $
      normalizeKeyToEnvVar "baggage" `shouldBe` "BAGGAGE"

    it "replaces hyphens with underscores for B3" $
      normalizeKeyToEnvVar "x-b3-traceid" `shouldBe` "X_B3_TRACEID"

    it "handles B3 SpanId" $
      normalizeKeyToEnvVar "x-b3-spanid" `shouldBe` "X_B3_SPANID"

    it "handles B3 Sampled" $
      normalizeKeyToEnvVar "x-b3-sampled" `shouldBe` "X_B3_SAMPLED"

    it "handles Datadog trace id" $
      normalizeKeyToEnvVar "x-datadog-trace-id" `shouldBe` "X_DATADOG_TRACE_ID"

    it "handles Datadog parent id" $
      normalizeKeyToEnvVar "x-datadog-parent-id" `shouldBe` "X_DATADOG_PARENT_ID"

    it "replaces dots with underscores" $
      normalizeKeyToEnvVar "some.dotted.header" `shouldBe` "SOME_DOTTED_HEADER"

    it "prefixes with underscore when name starts with digit" $
      normalizeKeyToEnvVar "1bad-name" `shouldBe` "_1BAD_NAME"

    it "preserves underscores" $
      normalizeKeyToEnvVar "already_has_underscores" `shouldBe` "ALREADY_HAS_UNDERSCORES"
