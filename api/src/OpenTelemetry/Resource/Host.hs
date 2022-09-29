{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}

-----------------------------------------------------------------------------

-----------------------------------------------------------------------------

{- |
 Module      :  OpenTelemetry.Resource.Host
 Copyright   :  (c) Ian Duncan, 2021
 License     :  BSD-3
 Description :  Information about the underlying general computing instance
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)
-}
module OpenTelemetry.Resource.Host (
  Host (..),
) where

import Data.Text (Text)
import OpenTelemetry.Resource (ToResource (..), mkResource, (.=?))


-- | A host is defined as a general computing instance.
data Host = Host
  { hostId :: Maybe Text
  -- ^ Unique host ID. For Cloud, this must be the instance_id assigned by the cloud provider.
  , hostName :: Maybe Text
  -- ^ Name of the host. On Unix systems, it may contain what the hostname command returns, or the fully qualified hostname, or another name specified by the user.
  , hostType :: Maybe Text
  -- ^ Type of host. For Cloud, this must be the machine type.
  , hostArch :: Maybe Text
  -- ^ The CPU architecture the host system is running on.
  , hostImageName :: Maybe Text
  -- ^ Name of the VM image or OS install the host was instantiated from.
  , hostImageId :: Maybe Text
  -- ^ VM image ID. For Cloud, this value is from the provider.
  , hostImageVersion :: Maybe Text
  -- ^ The version string of the VM image as defined in Version Attributes.
  }


instance ToResource Host where
  type ResourceSchema Host = 'Nothing
  toResource Host {..} =
    mkResource
      [ "host.id" .=? hostId
      , "host.name" .=? hostName
      , "host.type" .=? hostType
      , "host.arch" .=? hostArch
      , "host.image.name" .=? hostImageName
      , "host.image.id" .=? hostImageId
      , "host.image.version" .=? hostImageVersion
      ]
