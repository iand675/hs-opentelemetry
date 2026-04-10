{- |
 Module      :  OpenTelemetry.Resource.Kubernetes
 Copyright   :  (c) Ian Duncan, 2021
 License     :  BSD-3
 Description :  Information about how and where a process is running in a k8s cluster
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)
-}
module OpenTelemetry.Resource.Kubernetes where

import Data.Text (Text)
import OpenTelemetry.Attributes.Key (unkey)
import OpenTelemetry.Resource
import qualified OpenTelemetry.SemanticConventions as SC


{- | A Kubernetes Cluster.

@since 0.0.1.0
-}
data Cluster = Cluster
  { clusterName :: Maybe Text
  -- ^ The name of the cluster.
  , clusterUid :: Maybe Text
  -- ^ The UID of the cluster.
  }
  deriving (Show)


instance ToResource Cluster where
  toResource Cluster {..} =
    mkResourceWithSchema
      (Just semConvSchemaUrl)
      [ unkey SC.k8s_cluster_name .=? clusterName
      , unkey SC.k8s_cluster_uid .=? clusterUid
      ]


{- | A Kubernetes Node.

@since 0.0.1.0
-}
data Node = Node
  { nodeName :: Maybe Text
  , nodeUid :: Maybe Text
  }
  deriving (Show)


instance ToResource Node where
  toResource Node {..} =
    mkResourceWithSchema
      (Just semConvSchemaUrl)
      [ unkey SC.k8s_node_name .=? nodeName
      , unkey SC.k8s_node_uid .=? nodeUid
      ]


{- | Namespaces provide a scope for names. Names of objects need to be unique within a namespace, but not across namespaces.

@since 0.0.1.0
-}
newtype Namespace = Namespace
  { namespaceName :: Maybe Text
  -- ^ The name of the namespace that the pod is running in.
  }
  deriving (Show)


instance ToResource Namespace where
  toResource Namespace {..} =
    mkResourceWithSchema
      (Just semConvSchemaUrl)
      [ unkey SC.k8s_namespace_name .=? namespaceName
      ]


{- | The smallest and simplest Kubernetes object. A Pod represents a set of running containers on your cluster.

@since 0.0.1.0
-}
data Pod = Pod
  { podName :: Maybe Text
  -- ^ The name of the Pod.
  , podUid :: Maybe Text
  -- ^ The UID of the Pod.
  }
  deriving (Show)


instance ToResource Pod where
  toResource Pod {..} =
    mkResourceWithSchema
      (Just semConvSchemaUrl)
      [ unkey SC.k8s_pod_name .=? podName
      , unkey SC.k8s_pod_uid .=? podUid
      ]


{- | A container in a PodTemplate.

@since 0.0.1.0
-}
data Container = Container
  { containerName :: Maybe Text
  -- ^ The name of the Container from Pod specification, must be unique within a Pod. Container runtime usually uses different globally unique name (container.name).
  , containerRestartCount :: Maybe Int
  -- ^ Number of times the container was restarted. This attribute can be used to identify a particular container (running or stopped) within a container spec.
  }


instance ToResource Container where
  toResource Container {..} =
    mkResourceWithSchema
      (Just semConvSchemaUrl)
      [ unkey SC.k8s_container_name .=? containerName
      , unkey SC.k8s_container_restartCount .=? containerRestartCount
      ]


{- | A ReplicaSet’s purpose is to maintain a stable set of replica Pods running at any given time.

@since 0.0.1.0
-}
data ReplicaSet = ReplicaSet
  { replicaSetUid :: Maybe Text
  , replicaSetName :: Maybe Text
  }


instance ToResource ReplicaSet where
  toResource ReplicaSet {..} =
    mkResourceWithSchema
      (Just semConvSchemaUrl)
      [ unkey SC.k8s_replicaset_name .=? replicaSetName
      , unkey SC.k8s_replicaset_uid .=? replicaSetUid
      ]


{- | An API object that manages a replicated application, typically by running Pods with no local state. Each replica is represented by a Pod, and the Pods are distributed among the nodes of a cluster.

@since 0.0.1.0
-}
data Deployment = Deployment
  { deploymentUid :: Maybe Text
  -- ^ The UID of the Deployment.
  , deploymentName :: Maybe Text
  -- ^ The name of the Deployment.
  }


instance ToResource Deployment where
  toResource Deployment {..} =
    mkResourceWithSchema
      (Just semConvSchemaUrl)
      [ unkey SC.k8s_deployment_name .=? deploymentName
      , unkey SC.k8s_deployment_uid .=? deploymentUid
      ]


{- | Manages the deployment and scaling of a set of Pods, and provides guarantees about the ordering and uniqueness of these Pods.

@since 0.0.1.0
-}
data StatefulSet = StatefulSet
  { statefulSetUid :: Maybe Text
  -- ^ The UID of the StatefulSet.
  , statefulSetName :: Maybe Text
  -- ^ The name of the StatefulSet.
  }


instance ToResource StatefulSet where
  toResource StatefulSet {..} =
    mkResourceWithSchema
      (Just semConvSchemaUrl)
      [ unkey SC.k8s_statefulset_name .=? statefulSetName
      , unkey SC.k8s_statefulset_uid .=? statefulSetUid
      ]


{- | A DaemonSet ensures that all (or some) Nodes run a copy of a Pod.

@since 0.0.1.0
-}
data DaemonSet = DaemonSet
  { daemonSetUid :: Maybe Text
  -- ^ The UID of the DaemonSet.
  , daemonSetName :: Maybe Text
  -- ^ The name of the DaemonSet.
  }


instance ToResource DaemonSet where
  toResource DaemonSet {..} =
    mkResourceWithSchema
      (Just semConvSchemaUrl)
      [ unkey SC.k8s_daemonset_name .=? daemonSetName
      , unkey SC.k8s_daemonset_uid .=? daemonSetUid
      ]


{- | A Job creates one or more Pods and ensures that a specified number of them successfully terminate.

@since 0.0.1.0
-}
data Job = Job
  { jobUid :: Maybe Text
  -- ^ The UID of the Job.
  , jobName :: Maybe Text
  -- ^ The name of the Job.
  }


instance ToResource Job where
  toResource Job {..} =
    mkResourceWithSchema
      (Just semConvSchemaUrl)
      [ unkey SC.k8s_job_name .=? jobName
      , unkey SC.k8s_job_uid .=? jobUid
      ]


{- | A CronJob creates Jobs on a repeating schedule.

@since 0.0.1.0
-}
data CronJob = CronJob
  { cronJobUid :: Maybe Text
  -- ^ The UID of the CronJob.
  , cronJobName :: Maybe Text
  -- ^ The name of the CronJob.
  }


instance ToResource CronJob where
  toResource CronJob {..} =
    mkResourceWithSchema
      (Just semConvSchemaUrl)
      [ unkey SC.k8s_cronjob_name .=? cronJobName
      , unkey SC.k8s_cronjob_uid .=? cronJobUid
      ]
