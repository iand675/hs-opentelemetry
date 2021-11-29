{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  OpenTelemetry.Resource.Service
-- Copyright   :  (c) Ian Duncan, 2021
-- License     :  BSD-3
-- Description :  Resource information about a "service"
-- Maintainer  :  Ian Duncan
-- Stability   :  experimental
-- Portability :  non-portable (GHC extensions)
--
-----------------------------------------------------------------------------
module OpenTelemetry.Resource.Service where
import Data.Text
import OpenTelemetry.Resource

-- | A service instance
data Service = Service
  { serviceName :: Text
  -- ^ Logical name of the service.
  --
  -- MUST be the same for all instances of horizontally scaled services. 
  -- If the value was not specified, SDKs MUST fallback to unknown_service: concatenated with process.executable.name, 
  -- e.g. unknown_service:bash. If process.executable.name is not available, the value MUST be set to unknown_service.
  --
  -- If using the built-in resource detectors, this can be specified via the
  -- @OTEL_SERVICE_NAME@ environment variable
  --
  -- Example: @shoppingcart@
  , serviceNamespace :: Maybe Text
  -- ^ A namespace for service.name.
  --
  -- A string value having a meaning that helps to distinguish a group of services, for example the team name that owns a group of services. service.name is expected to be unique within the same namespace. If service.namespace is not specified in the Resource then service.name is expected to be unique for all services that have no explicit namespace defined (so the empty/unspecified namespace is simply one more valid namespace). Zero-length namespace string is assumed equal to unspecified namespace.
  --
  -- Example: @Shop@
  , serviceInstanceId :: Maybe Text
  -- ^ The string ID of the service instance.
  --
  -- Example: @627cc493-f310-47de-96bd-71410b7dec09@
  , serviceVersion :: Maybe Text
  -- ^ The version string of the service API or implementation.
  --
  -- Example: @2.0.0@
  }

instance ToResource Service where
  type ResourceSchema Service = 'Nothing
  toResource Service{..} = mkResource
    [ "service.name" .= serviceName
    , "service.namespace" .=? serviceNamespace
    , "service.instance.id" .=? serviceInstanceId
    , "service.version" .=? serviceVersion
    ]
