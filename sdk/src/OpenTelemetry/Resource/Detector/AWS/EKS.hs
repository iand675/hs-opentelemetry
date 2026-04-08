{-# LANGUAGE OverloadedStrings #-}

{- |
Module      :  OpenTelemetry.Resource.Detector.AWS.EKS
Copyright   :  (c) Ian Duncan, 2024
License     :  BSD-3
Description :  Detect AWS EKS resource attributes via the Kubernetes API
Maintainer  :  Ian Duncan
Stability   :  experimental

Detects whether the process is running on Amazon EKS by querying the
in-cluster Kubernetes API for the @aws-auth@ ConfigMap in the
@kube-system@ namespace. If present, sets @cloud.provider=aws@ and
@cloud.platform=aws_eks@.

Also attempts to read the cluster name from the @cluster-info@
ConfigMap in the @amazon-cloudwatch@ namespace (populated by the
CloudWatch agent or Fluentd DaemonSet).

TLS validation uses the in-cluster CA certificate at
@\/var\/run\/secrets\/kubernetes.io\/serviceaccount\/ca.crt@.
Authentication uses the service account bearer token at
@\/var\/run\/secrets\/kubernetes.io\/serviceaccount\/token@.

Returns an empty 'Resource' if not running on EKS or if the
Kubernetes API is unreachable.

Populates: @cloud.provider@, @cloud.platform@, @k8s.cluster.name@.

@since 0.1.0.2
-}
module OpenTelemetry.Resource.Detector.AWS.EKS (
  detectEKS,
  detectEKSSelf,
) where

import Data.Aeson (FromJSON (..), withObject, (.:?))
import qualified Data.HashMap.Strict as H
import Data.Maybe (fromMaybe)
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.IO as T
import OpenTelemetry.Attributes.Key (unkey)
import OpenTelemetry.Resource (Resource, mkResource, (.=), (.=?))
import qualified OpenTelemetry.SemanticConventions as SC
import OpenTelemetry.Resource.Detector.Metadata
import System.Environment (lookupEnv)
import System.IO.Error (tryIOError)


k8sTokenPath :: FilePath
k8sTokenPath = "/var/run/secrets/kubernetes.io/serviceaccount/token"


k8sCertPath :: FilePath
k8sCertPath = "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"


mkK8sApiUrl :: String -> String -> String -> String
mkK8sApiUrl host port path
  | ':' `elem` host = "https://[" ++ host ++ "]:" ++ port ++ path
  | otherwise = "https://" ++ host ++ ":" ++ port ++ path


authConfigmapPath :: String
authConfigmapPath = "/api/v1/namespaces/kube-system/configmaps/aws-auth"


clusterInfoPath :: String
clusterInfoPath = "/api/v1/namespaces/amazon-cloudwatch/configmaps/cluster-info"


{- | Self-contained EKS detector suitable for the resource detector registry.

Checks for Kubernetes service account files and environment, then queries
the k8s API to confirm EKS. Skips if ECS or Lambda are detected (those
have more specific detectors). Returns an empty resource if not on EKS.
-}
detectEKSSelf :: IO Resource
detectEKSSelf = do
  mHost <- lookupEnv "KUBERNETES_SERVICE_HOST"
  case mHost of
    Nothing -> pure $ mkResource []
    Just host -> do
      mEcs <- lookupEnv "ECS_CONTAINER_METADATA_URI_V4"
      mLambda <- lookupEnv "AWS_LAMBDA_FUNCTION_NAME"
      if mEcs /= Nothing || mLambda /= Nothing
        then pure $ mkResource []
        else do
          mToken <- readFileStripped k8sTokenPath
          case mToken of
            Nothing -> pure $ mkResource []
            Just _ -> do
              port <- fromMaybe "443" <$> lookupEnv "KUBERNETES_SERVICE_PORT"
              mClient <- newTlsMetadataClient k8sCertPath host
              case mClient of
                Nothing -> pure $ mkResource []
                Just client -> detectEKS client host port


{- | Detect EKS attributes by querying the in-cluster Kubernetes API.

Checks for the @aws-auth@ ConfigMap (EKS-specific) and reads the cluster
name from @cluster-info@ if available. Returns an empty resource if the
API is unreachable or the @aws-auth@ ConfigMap is absent.
-}
detectEKS :: MetadataClient -> String -> String -> IO Resource
detectEKS client host port = do
  mToken <- readFileStripped k8sTokenPath
  case mToken of
    Nothing -> pure $ mkResource []
    Just token -> do
      let bearerHeaders = [("Authorization", "Bearer " <> token)]
          authUrl = mkK8sApiUrl host port authConfigmapPath
      mAuthCm <- fetchJSONWithHeaders client authUrl bearerHeaders
      case (mAuthCm :: Maybe ConfigMapResponse) of
        Nothing -> pure $ mkResource []
        Just _ -> do
          let infoUrl = mkK8sApiUrl host port clusterInfoPath
          mClusterInfo <- fetchJSONWithHeaders client infoUrl bearerHeaders
          let mClusterName = mClusterInfo >>= cmLookupData "cluster.name"
          pure $
            mkResource
              [ unkey SC.cloud_provider .= ("aws" :: Text)
              , unkey SC.cloud_platform .= ("aws_eks" :: Text)
              , unkey SC.k8s_cluster_name .=? mClusterName
              ]


readFileStripped :: FilePath -> IO (Maybe Text)
readFileStripped path = do
  result <- tryIOError (T.readFile path)
  pure $ case result of
    Right content
      | not (T.null (T.strip content)) -> Just (T.strip content)
    _ -> Nothing


data ConfigMapResponse = ConfigMapResponse
  { cmData :: !(Maybe (H.HashMap Text Text))
  }


instance FromJSON ConfigMapResponse where
  parseJSON = withObject "ConfigMapResponse" $ \o ->
    ConfigMapResponse <$> o .:? "data"


cmLookupData :: Text -> ConfigMapResponse -> Maybe Text
cmLookupData key cm = cmData cm >>= H.lookup key
