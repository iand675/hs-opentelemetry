{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DataKinds #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  OpenTelemetry.Resource.Cloud
-- Copyright   :  (c) Ian Duncan, 2021
-- License     :  BSD-3
--
-- Maintainer  :  Ian Duncan
-- Stability   :  experimental
-- Portability :  non-portable (GHC extensions)
--
-- Cloud resource detection
--
-----------------------------------------------------------------------------
module OpenTelemetry.Resource.Cloud 
  ( Cloud(..)
  ) where
import Data.Text (Text)
import OpenTelemetry.Resource (ToResource(..), mkResource, (.=?))

-- | A cloud infrastructure (e.g. GCP, Azure, AWS).
data Cloud = Cloud
  { cloudProvider :: Maybe Text
  -- ^ Name of the cloud provider.
  --
  -- Examples: @alibaba_cloud@
  --
  -- cloud.provider MUST be one of the following or, if none of the listed values apply, a custom value:
  --
  -- +------------------+------------------------+
  -- | Value            | Description            |
  -- +==================+========================+
  -- | @alibaba_cloud@  | Alibaba Cloud          |
  -- +------------------+------------------------+
  -- | @aws@            | Amazon Web Services    |
  -- +------------------+------------------------+
  -- | @azure@          | Microsoft Azure        |
  -- +------------------+------------------------+
  -- | @gcp@            | Google Cloud Platform  |
  -- +------------------+------------------------+
  -- | @tencent_cloud@  | Tencent Cloud          |
  -- +------------------+------------------------+
  --
  , cloudAccountId :: Maybe Text
  -- ^ The cloud account ID the resource is assigned to.
  , cloudRegion :: Maybe Text
  -- ^ The geographical region the resource is running.
  , cloudAvailabilityZone :: Maybe Text
  -- ^ Cloud regions often have multiple, isolated locations known as zones to increase availability. Availability zone represents the zone where the resource is running.
  , cloudPlatform :: Maybe Text
  -- ^ The cloud platform in use.
  --
  -- Example: @alibaba_cloud_ecs@
  --
  -- MUST be one of the following or, if none of the listed values apply, a custom value:
  --
  -- +------------------------------+-------------------------------------------------+
  -- | Value                        | Description                                     |
  -- +==============================+=================================================+
  -- | @alibaba_cloud_ecs@          | Alibaba Cloud Elastic Compute Service           |
  -- +------------------------------+-------------------------------------------------+
  -- | @alibaba_cloud_fc@           | Alibaba Cloud Function Compute                  |
  -- +------------------------------+-------------------------------------------------+
  -- | @aws_ec2@                    | AWS Elastic Compute Cloud                       |
  -- +------------------------------+-------------------------------------------------+
  -- | @aws_ecs@                    | AWS Elastic Container Service                   |
  -- +------------------------------+-------------------------------------------------+
  -- | @aws_eks@                    | AWS Elastic Kubernetes Service                  |
  -- +------------------------------+-------------------------------------------------+
  -- | @aws_lambda@                 | AWS Lambda                                      |
  -- +------------------------------+-------------------------------------------------+
  -- | @aws_elastic_beanstalk@      | AWS Elastic Beanstalk                           |
  -- +------------------------------+-------------------------------------------------+
  -- | @aws_app_runner@             | AWS App Runner                                  |
  -- +------------------------------+-------------------------------------------------+
  -- | @azure_vm@                   | Azure Virtual Machines                          |
  -- +------------------------------+-------------------------------------------------+
  -- | @azure_container_instances@  | Azure Container Instances                       |
  -- +------------------------------+-------------------------------------------------+
  -- | @azure_aks@                  | Azure Kubernetes Service                        |
  -- +------------------------------+-------------------------------------------------+
  -- | @azure_functions@            | Azure Functions                                 |
  -- +------------------------------+-------------------------------------------------+
  -- | @azure_app_service@          | Azure App Service                               |
  -- +------------------------------+-------------------------------------------------+
  -- | @gcp_compute_engine@         | Google Cloud Compute Engine (GCE)               |
  -- +------------------------------+-------------------------------------------------+
  -- | @gcp_cloud_run@              | Google Cloud Run                                |
  -- +------------------------------+-------------------------------------------------+
  -- | @gcp_kubernetes_engine@      | Google Cloud Kubernetes Engine (GKE)            |
  -- +------------------------------+-------------------------------------------------+
  -- | @gcp_cloud_functions@        | Google Cloud Functions (GCF)                    |
  -- +------------------------------+-------------------------------------------------+
  -- | @gcp_app_engine@             | Google Cloud App Engine (GAE)                   |
  -- +------------------------------+-------------------------------------------------+
  -- | @tencent_cloud_cvm@          | Tencent Cloud Cloud Virtual Machine (CVM)       |
  -- +------------------------------+-------------------------------------------------+
  -- | @tencent_cloud_eks@          | Tencent Cloud Elastic Kubernetes Service (EKS)  |
  -- +------------------------------+-------------------------------------------------+
  -- | @tencent_cloud_scf@          | Tencent Cloud Serverless Cloud Function (SCF)   |
  -- +------------------------------+-------------------------------------------------+
  --
  }

instance ToResource Cloud where
  type ResourceSchema Cloud = 'Nothing
  toResource Cloud{..} = mkResource
    [ "cloud.provider" .=? cloudProvider
    , "cloud.account.id" .=? cloudAccountId
    , "cloud.region" .=? cloudRegion
    , "cloud.availability_zone" .=? cloudAvailabilityZone
    , "cloud.platform" .=? cloudPlatform
    ]
