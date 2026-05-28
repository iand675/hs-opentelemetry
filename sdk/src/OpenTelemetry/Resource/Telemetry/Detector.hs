{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.Resource.Telemetry.Detector where

import qualified Data.Text as T
import Data.Version (showVersion)
import OpenTelemetry.Resource.Telemetry
import Paths_hs_opentelemetry_sdk


-- | Built-in information about this package
detectTelemetry :: Telemetry
detectTelemetry =
  Telemetry
    { telemetrySdkName = "opentelemetry"
    , telemetrySdkLanguage = Just "haskell"
    , telemetrySdkVersion = Just $ T.pack $ showVersion version
    , telemetryDistroName = Nothing
    , telemetryDistroVersion = Nothing
    }
