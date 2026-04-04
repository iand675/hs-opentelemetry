{-# LANGUAGE OverloadedStrings #-}

{- |
Module      :  OpenTelemetry.Resource.Detector.Azure
Copyright   :  (c) Ian Duncan, 2024
License     :  BSD-3
Description :  Detect Azure VM resource attributes via IMDS
Maintainer  :  Ian Duncan
Stability   :  experimental

Queries the Azure Instance Metadata Service (IMDS) to populate resource
attributes for services running on Azure VMs.

Uses the non-routable endpoint @169.254.169.254@ with @Metadata: true@
header. Returns an empty 'Resource' if not running on Azure.

Populates: @cloud.provider@, @cloud.platform@, @cloud.region@,
@cloud.resource_id@, @host.id@, @host.name@, @host.type@,
@os.type@, @os.version@.

@since 0.1.0.2
-}
module OpenTelemetry.Resource.Detector.Azure (
  detectAzureVM,
  detectAzureVMSelf,
) where

import Data.Aeson (FromJSON (..), withObject, (.:?))
import Data.Text (Text)
import OpenTelemetry.Resource (Resource, mkResource, (.=), (.=?))
import OpenTelemetry.Resource.Detector.Metadata
import System.Environment (lookupEnv)


azureImdsEndpoint :: String
azureImdsEndpoint =
  "http://169.254.169.254/metadata/instance/compute?api-version=2021-12-13&format=json"


azureHeaders :: [(Text, Text)]
azureHeaders = [("Metadata", "True")]


{- | Self-contained Azure VM detector suitable for the resource detector
registry. Creates its own 'MetadataClient' and queries the Azure IMDS.
Returns an empty resource if not on Azure or IMDS is unreachable.
-}
detectAzureVMSelf :: IO Resource
detectAzureVMSelf = do
  client <- newMetadataClient
  detectAzureVM client


{- | Detect Azure VM attributes via IMDS with an existing client.
Returns an empty resource if IMDS is unreachable.

When @KUBERNETES_SERVICE_HOST@ is set, the platform is reported as
@azure_aks@ instead of @azure_vm@.
-}
detectAzureVM :: MetadataClient -> IO Resource
detectAzureVM client = do
  mMeta <- fetchJSONWithHeaders client azureImdsEndpoint azureHeaders
  case mMeta of
    Nothing -> pure $ mkResource []
    Just meta -> do
      mK8sHost <- lookupEnv "KUBERNETES_SERVICE_HOST"
      let platform :: Text
          platform = case mK8sHost of
            Just _ -> "azure_aks"
            Nothing -> "azure_vm"
      pure $
        mkResource
          [ "cloud.provider" .= ("azure" :: Text)
          , "cloud.platform" .= platform
          , "cloud.region" .=? vmLocation meta
          , "cloud.resource_id" .=? vmResourceId meta
          , "host.id" .=? vmId meta
          , "host.name" .=? vmName meta
          , "host.type" .=? vmSize meta
          , "os.type" .=? vmOsType meta
          , "os.version" .=? vmOsVersion meta
          ]


data AzureVMMetadata = AzureVMMetadata
  { vmId :: !(Maybe Text)
  , vmLocation :: !(Maybe Text)
  , vmResourceId :: !(Maybe Text)
  , vmName :: !(Maybe Text)
  , vmSize :: !(Maybe Text)
  , vmOsType :: !(Maybe Text)
  , vmOsVersion :: !(Maybe Text)
  }


instance FromJSON AzureVMMetadata where
  parseJSON = withObject "AzureVMMetadata" $ \o ->
    AzureVMMetadata
      <$> o .:? "vmId"
      <*> o .:? "location"
      <*> o .:? "resourceId"
      <*> o .:? "name"
      <*> o .:? "vmSize"
      <*> o .:? "osType"
      <*> o .:? "version"
