{-# LANGUAGE OverloadedStrings #-}

{- |
Module      :  OpenTelemetry.Resource.Detector.GCP
Copyright   :  (c) Ian Duncan, 2024
License     :  BSD-3
Description :  Detect GCP Compute Engine resource attributes via the metadata server
Maintainer  :  Ian Duncan
Stability   :  experimental

Queries the GCP metadata server (@metadata.google.internal@) to populate
resource attributes for services running on GCP Compute Engine, GKE,
Cloud Run, etc.

All requests include the required @Metadata-Flavor: Google@ header.
Returns an empty 'Resource' if the metadata server is not reachable.

Populates: @cloud.provider@, @cloud.platform@, @cloud.region@,
@cloud.availability_zone@, @cloud.account_id@, @host.id@, @host.name@,
@host.type@.

@since 0.1.0.2
-}
module OpenTelemetry.Resource.Detector.GCP (
  detectGCPCompute,
  detectGCPComputeSelf,
) where

import Data.Text (Text)
import qualified Data.Text as T
import OpenTelemetry.Attributes.Key (unkey)
import OpenTelemetry.Resource (Resource, mkResource, (.=), (.=?))
import OpenTelemetry.Resource.Detector.Metadata
import qualified OpenTelemetry.SemanticConventions as SC
import System.Environment (lookupEnv)


metadataBase :: String
metadataBase = "http://metadata.google.internal/computeMetadata/v1/"


gcpHeaders :: [(Text, Text)]
gcpHeaders = [("Metadata-Flavor", "Google")]


fetchGCP :: MetadataClient -> String -> IO (Maybe Text)
fetchGCP client path =
  fetchTextWithHeaders client (metadataBase ++ path) gcpHeaders


{- | Self-contained GCP detector suitable for the resource detector registry.
Checks for GCP env vars first, creates its own 'MetadataClient', then
queries the metadata server. Returns an empty resource if not on GCP or
the metadata server is unreachable.
-}
detectGCPComputeSelf :: IO Resource
detectGCPComputeSelf = do
  mProject <- lookupEnv "GOOGLE_CLOUD_PROJECT"
  mGcloud <- lookupEnv "GCLOUD_PROJECT"
  mGcp <- lookupEnv "GCP_PROJECT"
  mKService <- lookupEnv "K_SERVICE"
  let isGcp = any (/= Nothing) [mProject, mGcloud, mGcp, mKService]
  if isGcp
    then do
      client <- newMetadataClient
      detectGCPCompute client
    else pure $ mkResource []


{- | Detect GCP Compute Engine attributes via the metadata server.
Returns an empty resource if not running on GCP.

Also detects GKE by checking for @instance\/attributes\/cluster-name@
on the metadata server. If present, sets @cloud.platform@ to
@gcp_kubernetes_engine@ and populates @k8s.cluster.name@.
-}
detectGCPCompute :: MetadataClient -> IO Resource
detectGCPCompute client = do
  mProjectId <- fetchGCP client "project/project-id"
  case mProjectId of
    Nothing -> pure $ mkResource []
    Just projectId -> do
      mInstanceId <- fetchGCP client "instance/id"
      mInstanceName <- fetchGCP client "instance/name"
      mZone <- fetchGCP client "instance/zone"
      mMachineType <- fetchGCP client "instance/machine-type"
      mClusterName <- fetchGCP client "instance/attributes/cluster-name"

      let mAz = extractLastSegment <$> mZone
          mRegion = extractRegionFromZone =<< mAz
          mHostType = extractLastSegment <$> mMachineType
          platform :: Text
          platform = case mClusterName of
            Just _ -> "gcp_kubernetes_engine"
            Nothing -> "gcp_compute_engine"

      pure $
        mkResource
          [ unkey SC.cloud_provider .= ("gcp" :: Text)
          , unkey SC.cloud_platform .= platform
          , unkey SC.cloud_region .=? mRegion
          , unkey SC.cloud_availabilityZone .=? mAz
          , unkey SC.cloud_account_id .= projectId
          , unkey SC.host_id .=? mInstanceId
          , unkey SC.host_name .=? mInstanceName
          , unkey SC.host_type .=? mHostType
          , unkey SC.k8s_cluster_name .=? mClusterName
          ]


-- Metadata server returns zone as "projects/{num}/zones/{zone}"
-- and machine-type as "projects/{num}/machineTypes/{type}".
extractLastSegment :: Text -> Text
extractLastSegment t = case T.splitOn "/" t of
  [] -> t
  parts -> last parts


-- "us-central1-a" -> "us-central1"
extractRegionFromZone :: Text -> Maybe Text
extractRegionFromZone az =
  let parts = T.splitOn "-" az
  in if length parts >= 3
       then Just $ T.intercalate "-" (take (length parts - 1) parts)
       else Nothing
