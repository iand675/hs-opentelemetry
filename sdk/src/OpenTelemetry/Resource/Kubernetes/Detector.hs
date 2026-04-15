{-# LANGUAGE OverloadedStrings #-}

{- |
Module      :  OpenTelemetry.Resource.Kubernetes.Detector
Copyright   :  (c) Ian Duncan, 2024
License     :  BSD-3
Description :  Auto-detect Kubernetes resource attributes
Maintainer  :  Ian Duncan
Stability   :  experimental
Portability :  non-portable (GHC extensions)

Detects Kubernetes resource attributes from the downward API, environment
variables, and mounted service account tokens. Returns empty resources
when not running in a Kubernetes cluster.

Detection sources:

* @KUBERNETES_SERVICE_HOST@: presence indicates k8s
* @HOSTNAME@: typically the pod name
* @\/var\/run\/secrets\/kubernetes.io\/serviceaccount\/namespace@: pod namespace
* @OTEL_RESOURCE_ATTRIBUTES@: may contain @k8s.cluster.name@, @k8s.node.name@, etc.

@since 0.1.0.2
-}
module OpenTelemetry.Resource.Kubernetes.Detector (
  detectKubernetes,
  isRunningInKubernetes,
  KubernetesResources (..),
) where

import qualified Data.Text as T
import qualified Data.Text.IO as T
import OpenTelemetry.Resource.Kubernetes (Cluster (..), Namespace (..), Node (..), Pod)
import qualified OpenTelemetry.Resource.Kubernetes as K8s
import System.Environment (lookupEnv)
import System.IO.Error (tryIOError)


-- | @since 0.0.1.0
isRunningInKubernetes :: IO Bool
isRunningInKubernetes = do
  mHost <- lookupEnv "KUBERNETES_SERVICE_HOST"
  pure $ case mHost of
    Just _ -> True
    Nothing -> False


-- | @since 0.0.1.0
data KubernetesResources = KubernetesResources
  { k8sCluster :: Cluster
  , k8sNamespace :: Namespace
  , k8sNode :: Node
  , k8sPod :: Pod
  }
  deriving (Show)


-- | @since 0.0.1.0
detectKubernetes :: IO (Maybe KubernetesResources)
detectKubernetes = do
  inK8s <- isRunningInKubernetes
  if not inK8s
    then pure Nothing
    else do
      cluster <- detectCluster
      ns <- detectNamespace
      node <- detectNode
      pod <- detectPod
      pure $
        Just
          KubernetesResources
            { k8sCluster = cluster
            , k8sNamespace = ns
            , k8sNode = node
            , k8sPod = pod
            }


detectCluster :: IO Cluster
detectCluster = do
  mName <- lookupEnvText "K8S_CLUSTER_NAME"
  pure Cluster {clusterName = mName, clusterUid = Nothing}


detectNamespace :: IO Namespace
detectNamespace = do
  mNs <- readNamespaceFile
  ns <- case mNs of
    Just n -> pure (Just n)
    Nothing -> lookupEnvText "K8S_NAMESPACE"
  pure Namespace {namespaceName = ns}
  where
    readNamespaceFile = do
      result <- tryIOError (T.readFile saNamespacePath)
      pure $ case result of
        Right content
          | not (T.null (T.strip content)) -> Just (T.strip content)
        _ -> Nothing
    saNamespacePath = "/var/run/secrets/kubernetes.io/serviceaccount/namespace"


detectNode :: IO Node
detectNode = do
  mName <- lookupEnvText "K8S_NODE_NAME"
  pure Node {nodeName = mName, nodeUid = Nothing}


detectPod :: IO Pod
detectPod = do
  mName <- lookupEnvText "K8S_POD_NAME"
  pName <- case mName of
    Just n -> pure (Just n)
    Nothing -> lookupEnvText "HOSTNAME"
  mUid <- lookupEnvText "K8S_POD_UID"
  pure K8s.Pod {K8s.podName = pName, K8s.podUid = mUid}


lookupEnvText :: String -> IO (Maybe T.Text)
lookupEnvText key = fmap (T.pack <$>) (lookupEnv key)
