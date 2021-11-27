{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DataKinds #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  OpenTelemetry.Resource.Host
-- Copyright   :  (c) Ian Duncan, 2021
-- License     :  BSD-3
--
-- Maintainer  :  Ian Duncan
-- Stability   :  experimental
-- Portability :  non-portable (GHC extensions)
--
-----------------------------------------------------------------------------
module OpenTelemetry.Resource.Host 
  ( Host (..)
  , getHost
  , HostDetector
  , builtInHostDetectors
  ) where
import Data.Text (Text)
import qualified Data.Text as T
import Network.BSD
import Control.Monad
import OpenTelemetry.Resource (ToResource(..), mkResource, (.=?))
import System.Info (arch)

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

adaptedArch :: Text
adaptedArch = case arch of
  "aarch64" -> "arm64"
  "arm" -> "arm32"
  "x86_64" -> "amd64"
  "i386" -> "x86"
  "ia64" -> "ia64"
  "powerpc" -> "ppc32"
  "powerpc64" -> "ppc64"
  "powerpc64le" -> "ppc64"
  other -> T.pack other
instance ToResource Host where
  type ResourceSchema Host = 'Nothing
  toResource Host{..} = mkResource
    [ "host.id" .=? hostId
    , "host.name" .=? hostName
    , "host.type" .=? hostType
    , "host.arch" .=? hostArch
    , "host.image.name" .=? hostImageName
    , "host.image.id" .=? hostImageId
    , "host.image.version" .=? hostImageVersion
    ]

-- | Detect as much host information as possible
getHost :: IO Host
getHost = do
  mhost <- foldM go Nothing builtInHostDetectors
  pure $ case mhost of
    Nothing -> Host Nothing Nothing Nothing Nothing Nothing Nothing Nothing
    Just host -> host
  where
    go Nothing detectHost = detectHost
    go mhost@(Just _host) _ = pure mhost

-- | A set of detectors for e.g. AWS, GCP, and other cloud providers.
--
-- Currently only emits hostName and hostArch. Additional detectors are
-- welcome via PR.
builtInHostDetectors :: [HostDetector]
builtInHostDetectors =
  [
  -- TODO
  -- AWS support
  -- GCP support
  -- any other user contributed
     fallbackHostDetector
  ]

type HostDetector = IO (Maybe Host)

fallbackHostDetector :: HostDetector
fallbackHostDetector = Just <$> do
  let hostId = Nothing
      hostType = Nothing
      hostArch = Just adaptedArch
      hostImageName = Nothing
      hostImageId = Nothing
      hostImageVersion = Nothing
  hostName <- Just . T.pack <$> getHostName
  pure Host{..}