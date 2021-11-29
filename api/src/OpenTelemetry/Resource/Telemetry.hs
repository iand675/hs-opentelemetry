{-# LANGUAGE CPP #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  OpenTelemetry.Resource.Telemetry
-- Copyright   :  (c) Ian Duncan, 2021
-- License     :  BSD-3
-- Description :  Information about the telemetry SDK used to capture data recorded 
-- by the instrumentation libraries.
-- Maintainer  :  Ian Duncan
-- Stability   :  experimental
-- Portability :  non-portable (GHC extensions)
--
-----------------------------------------------------------------------------
module OpenTelemetry.Resource.Telemetry where
import Data.Text ( Text )
import OpenTelemetry.Resource

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
data Telemetry = Telemetry
  { telemetrySdkName :: Text
  -- ^ The name of the telemetry SDK as defined above.
  , telemetrySdkLanguage :: Maybe Text
  -- ^ The name of the telemetry SDK as defined above.
  , telemetrySdkVersion :: Maybe Text
  -- ^ The version string of the telemetry SDK.
  , telemetryAutoVersion :: Maybe Text
  --- ^ The version string of the auto instrumentation agent, if used.

  }

instance ToResource Telemetry where  
  type ResourceSchema Telemetry = 'Nothing
  toResource Telemetry{..} = mkResource
    [ "telemetry.sdk.name" .= telemetrySdkName
    , "telemetry.sdk.language" .=? telemetrySdkLanguage
    , "telemetry.sdk.version" .=? telemetrySdkVersion
    , "telemetry.auto.version" .=? telemetryAutoVersion
    ]
