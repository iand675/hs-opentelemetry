{-# LANGUAGE CPP #-}
{- |
 Module      :  OpenTelemetry.Resource.Telemetry
 Copyright   :  (c) Ian Duncan, 2021
 License     :  BSD-3
 Description :  Information about the telemetry SDK used to capture data recorded
 by the instrumentation libraries.
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)
-}
module OpenTelemetry.Resource.Telemetry where

import Data.Text (Text)
import OpenTelemetry.Attributes.Key (unkey)
import OpenTelemetry.Resource
import qualified OpenTelemetry.SemanticConventions as SC


-- - id: cpp
--   value: "cpp"
-- - id: dotnet
--   value: "dotnet"
-- - id: erlang
--   value: "erlang"
-- - id: go
--   value: "go"
-- - id: java
--   value: "java"
-- - id: nodejs
--   value: "nodejs"
-- - id: php
--   value: "php"
-- - id: python
--   value: "python"
-- - id: ruby
--   value: "ruby"
-- - id: webjs
--   value: "webjs"
-- other allowed

-- | The telemetry SDK used to capture data recorded by the instrumentation libraries.
--
-- @since 0.0.1.0
data Telemetry = Telemetry
  { telemetrySdkName :: Text
  -- ^ The name of the telemetry SDK as defined above.
  , telemetrySdkLanguage :: Maybe Text
  -- ^ The name of the telemetry SDK as defined above.
  , telemetrySdkVersion :: Maybe Text
  -- ^ The version string of the telemetry SDK.
  , telemetryDistroName :: Maybe Text
  -- ^ The name of the telemetry auto instrumentation provider, if used.
  , telemetryDistroVersion :: Maybe Text
  -- ^ The version string of the telemetry auto instrumentation provider, if used.
  }


instance ToResource Telemetry where
  toResource Telemetry {..} =
    mkResourceWithSchema (Just semConvSchemaUrl)
      [ unkey SC.telemetry_sdk_name .= telemetrySdkName
      , unkey SC.telemetry_sdk_language .=? telemetrySdkLanguage
      , unkey SC.telemetry_sdk_version .=? telemetrySdkVersion
      , unkey SC.telemetry_distro_name .=? telemetryDistroName
      , unkey SC.telemetry_distro_version .=? telemetryDistroVersion
      ]
