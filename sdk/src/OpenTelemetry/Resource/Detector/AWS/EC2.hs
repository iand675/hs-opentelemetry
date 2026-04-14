{-# LANGUAGE OverloadedStrings #-}

{- |
Module      :  OpenTelemetry.Resource.Detector.AWS.EC2
Copyright   :  (c) Ian Duncan, 2024
License     :  BSD-3
Description :  Detect EC2 instance resource attributes via IMDS
Maintainer  :  Ian Duncan
Stability   :  experimental

Queries the EC2 Instance Metadata Service (IMDS) to populate rich resource
attributes for services running on EC2 instances.

Uses IMDSv2 (session-oriented, token-based) with a 2-second timeout.
Falls back to IMDSv1 if token acquisition fails. Returns an empty
'Resource' if not running on EC2.

Populates: @cloud.provider@, @cloud.platform@, @cloud.region@,
@cloud.availability_zone@, @cloud.account_id@, @host.id@, @host.type@,
@host.name@, @host.image.id@.

@since 0.1.0.2
-}
module OpenTelemetry.Resource.Detector.AWS.EC2 (
  detectEC2,
  detectEC2Self,
) where

import Data.Aeson (FromJSON (..), withObject, (.:?))
import Data.Text (Text)
import OpenTelemetry.Attributes.Key (unkey)
import OpenTelemetry.Resource (Resource, mkResource, (.=), (.=?))
import OpenTelemetry.Resource.Detector.Metadata
import qualified OpenTelemetry.SemanticConventions as SC
import System.Environment (lookupEnv)


imdsBase :: String
imdsBase = "http://169.254.169.254/latest"


tokenEndpoint :: String
tokenEndpoint = imdsBase ++ "/api/token"


metadataPath :: String -> String
metadataPath p = imdsBase ++ "/meta-data/" ++ p


{- | Self-contained EC2 detector suitable for the resource detector registry.
Checks for AWS env vars first, creates its own 'MetadataClient', then
queries IMDS. Returns an empty resource if not on AWS or IMDS is unreachable.
-}
detectEC2Self :: IO Resource
detectEC2Self = do
  mRegion <- lookupEnv "AWS_REGION"
  mDefault <- lookupEnv "AWS_DEFAULT_REGION"
  mExecEnv <- lookupEnv "AWS_EXECUTION_ENV"
  -- Also check for ECS. If on ECS, the ECS detector is more specific
  mEcs <- lookupEnv "ECS_CONTAINER_METADATA_URI_V4"
  let isNonEcsAws = any (/= Nothing) [mRegion, mDefault, mExecEnv] && mEcs == Nothing
  if isNonEcsAws
    then do
      client <- newMetadataClient
      detectEC2 client
    else pure $ mkResource []


{- | Detect EC2 instance attributes via IMDS with an existing client.
Returns an empty resource if IMDS is unreachable.
-}
detectEC2 :: MetadataClient -> IO Resource
detectEC2 client = do
  mToken <- acquireIMDSv2Token client
  let fetch path = fetchWithToken client mToken (metadataPath path)
  mInstanceId <- fetch "instance-id"
  case mInstanceId of
    Nothing -> pure $ mkResource []
    Just instanceId -> do
      mInstanceType <- fetch "instance-type"
      mAmiId <- fetch "ami-id"
      mHostname <- fetch "hostname"
      mAz <- fetch "placement/availability-zone"
      mRegion <- fetch "placement/region"
      mAcctId <- fetchAccountId client mToken
      pure $
        mkResource
          [ unkey SC.cloud_provider .= ("aws" :: Text)
          , unkey SC.cloud_platform .= ("aws_ec2" :: Text)
          , unkey SC.cloud_region .=? mRegion
          , unkey SC.cloud_availabilityZone .=? mAz
          , unkey SC.cloud_account_id .=? mAcctId
          , unkey SC.host_id .= instanceId
          , unkey SC.host_type .=? mInstanceType
          , unkey SC.host_name .=? mHostname
          , unkey SC.host_image_id .=? mAmiId
          ]


acquireIMDSv2Token :: MetadataClient -> IO (Maybe Text)
acquireIMDSv2Token client =
  putForText
    client
    tokenEndpoint
    [("X-aws-ec2-metadata-token-ttl-seconds", "21600")]


fetchWithToken :: MetadataClient -> Maybe Text -> String -> IO (Maybe Text)
fetchWithToken client mToken url = case mToken of
  Just token -> fetchTextWithHeaders client url [("X-aws-ec2-metadata-token", token)]
  Nothing -> fetchText client url


data IdentityDocument = IdentityDocument
  { idAccountId :: Maybe Text
  }


instance FromJSON IdentityDocument where
  parseJSON = withObject "IdentityDocument" $ \o ->
    IdentityDocument <$> o .:? "accountId"


fetchAccountId :: MetadataClient -> Maybe Text -> IO (Maybe Text)
fetchAccountId client mToken = do
  let url = imdsBase ++ "/dynamic/instance-identity/document"
  mDoc <- case mToken of
    Just token ->
      fetchJSONWithHeaders client url [("X-aws-ec2-metadata-token", token)]
    Nothing ->
      fetchJSON client url
  pure $ mDoc >>= idAccountId
