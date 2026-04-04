{-# LANGUAGE OverloadedStrings #-}

{- |
Module      :  OpenTelemetry.Resource.Cloud.Detector
Copyright   :  (c) Ian Duncan, 2024
License     :  BSD-3
Description :  Auto-detect cloud provider resource attributes from environment variables
Maintainer  :  Ian Duncan
Stability   :  experimental
Portability :  non-portable (GHC extensions)

Detects cloud provider, region, and platform from well-known environment
variables set by AWS, GCP, and Azure runtimes. This covers the common case
where services run on managed compute (ECS, Lambda, Cloud Run, App Service,
etc.) and the runtime injects env vars.

For full instance metadata (account ID, instance ID, availability zone),
use IMDS-based detection. That requires an HTTP client and is left to
a future @hs-opentelemetry-resource-detector-aws@ (or similar) package.

@since 0.1.0.2
-}
module OpenTelemetry.Resource.Cloud.Detector (
  detectCloud,
) where

import qualified Data.Text as T
import OpenTelemetry.Resource.Cloud (Cloud (..))
import System.Environment (lookupEnv)


detectCloud :: IO Cloud
detectCloud = do
  mAws <- detectAWS
  case mAws of
    Just cloud -> pure cloud
    Nothing -> do
      mGcp <- detectGCP
      case mGcp of
        Just cloud -> pure cloud
        Nothing -> do
          mAzure <- detectAzure
          case mAzure of
            Just cloud -> pure cloud
            Nothing -> pure emptyCloud


emptyCloud :: Cloud
emptyCloud =
  Cloud
    { cloudProvider = Nothing
    , cloudAccountId = Nothing
    , cloudRegion = Nothing
    , cloudAvailabilityZone = Nothing
    , cloudPlatform = Nothing
    }


-- AWS detection via environment variables injected by ECS, Lambda, Beanstalk, etc.
-- When KUBERNETES_SERVICE_HOST is present and no more specific platform matches,
-- falls back to aws_eks as a heuristic.
detectAWS :: IO (Maybe Cloud)
detectAWS = do
  mRegion <- firstEnv ["AWS_REGION", "AWS_DEFAULT_REGION"]
  mLambda <- lookupEnvText "AWS_LAMBDA_FUNCTION_NAME"
  mEcs <- lookupEnvText "ECS_CONTAINER_METADATA_URI_V4"
  mEcsLegacy <- lookupEnvText "ECS_CONTAINER_METADATA_URI"
  mBeanstalk <- lookupEnvText "ELASTIC_BEANSTALK_ENVIRONMENT_NAME"
  mAppRunner <- lookupEnvText "AWS_APP_RUNNER_SERVICE_ID"
  mExecEnv <- lookupEnvText "AWS_EXECUTION_ENV"

  let isAws =
        any
          (/= Nothing)
          [mRegion, mLambda, mEcs, mEcsLegacy, mBeanstalk, mAppRunner, mExecEnv]

  if not isAws
    then pure Nothing
    else do
      mAz <- lookupEnvText "AWS_AVAILABILITY_ZONE"
      mAcct <- lookupEnvText "AWS_ACCOUNT_ID"
      mK8sHost <- lookupEnvText "KUBERNETES_SERVICE_HOST"
      let platform = case () of
            _
              | mLambda /= Nothing -> Just "aws_lambda"
              | mEcs /= Nothing || mEcsLegacy /= Nothing -> Just "aws_ecs"
              | mBeanstalk /= Nothing -> Just "aws_elastic_beanstalk"
              | mAppRunner /= Nothing -> Just "aws_app_runner"
              | mExecEnv == Just "AWS_ECS_EC2" -> Just "aws_ecs"
              | mExecEnv == Just "AWS_ECS_FARGATE" -> Just "aws_ecs"
              | mK8sHost /= Nothing -> Just "aws_eks"
              | otherwise -> Nothing
      pure $
        Just
          Cloud
            { cloudProvider = Just "aws"
            , cloudAccountId = mAcct
            , cloudRegion = mRegion
            , cloudAvailabilityZone = mAz
            , cloudPlatform = platform
            }


-- GCP detection via environment variables set by Cloud Run, Cloud Functions,
-- App Engine, and Compute Engine.
detectGCP :: IO (Maybe Cloud)
detectGCP = do
  mProject <- firstEnv ["GOOGLE_CLOUD_PROJECT", "GCLOUD_PROJECT", "GCP_PROJECT"]
  mCloudRun <- lookupEnvText "K_SERVICE"
  mCloudFn <- lookupEnvText "FUNCTION_TARGET"
  mAppEngine <- lookupEnvText "GAE_SERVICE"
  mGaeEnv <- lookupEnvText "GAE_ENV"

  let isGcp =
        any
          (/= Nothing)
          [mProject, mCloudRun, mCloudFn, mAppEngine, mGaeEnv]

  if not isGcp
    then pure Nothing
    else do
      mRegion <- firstEnv ["GOOGLE_CLOUD_REGION", "FUNCTION_REGION"]
      let platform = case () of
            _
              | mCloudRun /= Nothing -> Just "gcp_cloud_run"
              | mCloudFn /= Nothing -> Just "gcp_cloud_functions"
              | mAppEngine /= Nothing || mGaeEnv /= Nothing -> Just "gcp_app_engine"
              | otherwise -> Nothing
      pure $
        Just
          Cloud
            { cloudProvider = Just "gcp"
            , cloudAccountId = mProject
            , cloudRegion = mRegion
            , cloudAvailabilityZone = Nothing
            , cloudPlatform = platform
            }


-- Azure detection via environment variables set by App Service, Functions, etc.
detectAzure :: IO (Maybe Cloud)
detectAzure = do
  mWebsite <- lookupEnvText "WEBSITE_SITE_NAME"
  mFunctions <- lookupEnvText "FUNCTIONS_WORKER_RUNTIME"
  mContainerApp <- lookupEnvText "CONTAINER_APP_NAME"
  mAzureEnv <- lookupEnvText "AZURE_FUNCTIONS_ENVIRONMENT"

  let isAzure =
        any
          (/= Nothing)
          [mWebsite, mFunctions, mContainerApp, mAzureEnv]

  if not isAzure
    then pure Nothing
    else do
      mRegion <- lookupEnvText "REGION_NAME"
      mSub <- lookupEnvText "AZURE_SUBSCRIPTION_ID"
      let platform = case () of
            _
              | mFunctions /= Nothing || mAzureEnv /= Nothing -> Just "azure_functions"
              | mContainerApp /= Nothing -> Just "azure_container_apps"
              | mWebsite /= Nothing -> Just "azure_app_service"
              | otherwise -> Nothing
      pure $
        Just
          Cloud
            { cloudProvider = Just "azure"
            , cloudAccountId = mSub
            , cloudRegion = mRegion
            , cloudAvailabilityZone = Nothing
            , cloudPlatform = platform
            }


lookupEnvText :: String -> IO (Maybe T.Text)
lookupEnvText key = fmap (T.pack <$>) (lookupEnv key)


firstEnv :: [String] -> IO (Maybe T.Text)
firstEnv [] = pure Nothing
firstEnv (k : ks) = do
  mVal <- lookupEnvText k
  case mVal of
    Just v -> pure (Just v)
    Nothing -> firstEnv ks
