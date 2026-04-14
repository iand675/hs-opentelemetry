{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.MetricSpec (spec) where

import Data.Maybe (isJust)
import OpenTelemetry.Attributes (emptyAttributes)
import OpenTelemetry.Internal.Common.Types (FlushResult (..), InstrumentationLibrary (..), ShutdownResult (..))
import OpenTelemetry.Metric.Core
import OpenTelemetry.Metric.InstrumentName (validateInstrumentName, validateInstrumentUnit)
import Test.Hspec


spec :: Spec
spec = do
  -- Metrics API §Instrument naming rules (SDK validation; API does not validate names)
  -- https://opentelemetry.io/docs/specs/otel/metrics/api/#instrument-name-syntax
  describe "validateInstrumentName (SDK uses this; API MUST NOT validate names)" $ do
    it "MUST reject empty names" $
      validateInstrumentName mempty `shouldSatisfy` isJust
    it "MUST reject names longer than 255 characters" $
      validateInstrumentName (mconcat (replicate 256 "a")) `shouldSatisfy` isJust
    it "MUST reject names not starting with a letter" $
      validateInstrumentName "1abc" `shouldSatisfy` isJust
    it "MUST reject disallowed characters" $
      validateInstrumentName "a b" `shouldSatisfy` isJust
    it "accepts typical valid names" $ do
      validateInstrumentName "a" `shouldBe` Nothing
      validateInstrumentName "http.server.duration" `shouldBe` Nothing
      validateInstrumentName "a_B-c/d" `shouldBe` Nothing

  -- Metrics API §Instrument unit: unit field constraints
  -- https://opentelemetry.io/docs/specs/otel/metrics/api/#instrument-unit
  describe "validateInstrumentUnit" $ do
    it "MUST reject units longer than 63 characters" $
      validateInstrumentUnit (mconcat (replicate 64 "x")) `shouldSatisfy` isJust
    it "accepts empty unit (caller may omit)" $
      validateInstrumentUnit mempty `shouldBe` Nothing

  -- Metrics API §Enabled: noop provider returns disabled instruments
  -- https://opentelemetry.io/docs/specs/otel/metrics/api/#enabled
  describe "noopMeterProvider" $ do
    it "SHOULD return disabled synchronous instruments (Enabled API)" $ do
      let mp = noopMeterProvider
      m <- getMeter mp ("test" :: InstrumentationLibrary)
      c <- meterCreateCounterInt64 m "requests" Nothing Nothing defaultAdvisoryParameters
      enabled <- counterEnabled c
      enabled `shouldBe` False
      counterAdd c 1 emptyAttributes
    it "SHOULD return disabled observable instruments (Enabled API)" $ do
      let mp = noopMeterProvider
      m <- getMeter mp ("obs" :: InstrumentationLibrary)
      oc <- meterCreateObservableCounterInt64 m "oc" Nothing Nothing defaultAdvisoryParameters []
      oud <- meterCreateObservableUpDownCounterInt64 m "oud" Nothing Nothing defaultAdvisoryParameters []
      og <- meterCreateObservableGaugeInt64 m "og" Nothing Nothing defaultAdvisoryParameters []
      observableCounterEnabled oc `shouldReturn` False
      observableUpDownCounterEnabled oud `shouldReturn` False
      observableGaugeEnabled og `shouldReturn` False

  -- Metrics API §MeterProvider: Shutdown and ForceFlush on noop provider
  -- https://opentelemetry.io/docs/specs/otel/metrics/api/#meterprovider-operations
  describe "noopMeterProvider shutdown" $ do
    it "implements Shutdown and ForceFlush without error" $ do
      shutdownMeterProvider noopMeterProvider `shouldReturn` ShutdownSuccess
      forceFlushMeterProvider noopMeterProvider Nothing `shouldReturn` FlushSuccess
