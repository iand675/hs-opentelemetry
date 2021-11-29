{-# LANGUAGE OverloadedStrings #-}
module OpenTelemetry.Resource.Telemetry.Detector where
import qualified Data.Text as T
import OpenTelemetry.Resource.Telemetry
import Paths_hs_opentelemetry_sdk

-- | Built-in information about this package
telemetry :: Telemetry
telemetry = Telemetry
  { telemetrySdkName = "hs-opentelemetry-sdk"
  , telemetrySdkLanguage = Just "haskell"
  , telemetrySdkVersion = Just $ T.pack $ show version
  , telemetryAutoVersion = Nothing
  }
