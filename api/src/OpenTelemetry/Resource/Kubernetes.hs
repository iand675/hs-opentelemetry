{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DataKinds #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  OpenTelemetry.Resource.Kubernetes
-- Copyright   :  (c) Ian Duncan, 2021
-- License     :  BSD-3
--
-- Maintainer  :  Ian Duncan
-- Stability   :  experimental
-- Portability :  non-portable (GHC extensions)
--
-----------------------------------------------------------------------------
module OpenTelemetry.Resource.Kubernetes where
import Data.Text (Text)
import OpenTelemetry.Resource

-- | A Kubernetes Cluster.
newtype Cluster = Cluster
  { clusterName :: Maybe Text
  -- ^ The name of the cluster.
  }

instance ToResource Cluster where
  type ResourceSchema Cluster = 'Nothing
  toResource Cluster{..} = mkResource
    ["k8s.cluster.name" .=? clusterName]

-- | A Kubernetes Node.
data Node = Node
  { nodeName :: Maybe Text
  , nodeUid :: Maybe Text
  }
instance ToResource Node where
  type ResourceSchema Node = 'Nothing
  toResource Node{..} = mkResource
    [ "k8s.node.name" .=? nodeName
    , "k8s.node.uid" .=? nodeUid
    ]

-- | Namespaces provide a scope for names. Names of objects need to be unique within a namespace, but not across namespaces.
newtype Namespace = Namespace
  { namespaceName :: Maybe Text
  -- ^ The name of the namespace that the pod is running in.
  }

instance ToResource Namespace where
  type ResourceSchema Namespace = 'Nothing
  toResource Namespace{..} = mkResource
    [ "k8s.namespace.name" .=? namespaceName
    ]

-- | The smallest and simplest Kubernetes object. A Pod represents a set of running containers on your cluster.
data Pod = Pod
  { podName :: Maybe Text
  -- ^ The name of the Pod.
  , podUid :: Maybe Text
  -- ^ The UID of the Pod.
  }

instance ToResource Pod where
  type ResourceSchema Pod = 'Nothing
  toResource Pod{..} = mkResource
    [ "k8s.pod.name" .=? podName
    , "k8s.pod.uid" .=? podUid
    ]

data Container = Container
  { containerName :: Maybe Text
  -- ^ The name of the Container from Pod specification, must be unique within a Pod. Container runtime usually uses different globally unique name (container.name).	
  , containerRestartCount :: Maybe Int
  -- ^ Number of times the container was restarted. This attribute can be used to identify a particular container (running or stopped) within a container spec.	
  }

instance ToResource Container where
  type ResourceSchema Container = 'Nothing
  toResource Container{..} = mkResource
    [ "k8s.container.name" .=? containerName
    , "k8s.container.restart_count" .=? containerRestartCount
    ]

-- | A ReplicaSet’s purpose is to maintain a stable set of replica Pods running at any given time.
data ReplicaSet = ReplicaSet
  { replicaSetUid :: Maybe Text
  , replicaSetName :: Maybe Text
  }

instance ToResource ReplicaSet where
  type ResourceSchema ReplicaSet = 'Nothing
  toResource ReplicaSet{..} = mkResource
    [ "k8s.replicaset.name" .=? replicaSetName
    , "k8s.replicaset.uid" .=? replicaSetUid
    ]

-- | An API object that manages a replicated application, typically by running Pods with no local state. Each replica is represented by a Pod, and the Pods are distributed among the nodes of a cluster.
data Deployment = Deployment
  { deploymentUid :: Maybe Text
  -- ^ The UID of the Deployment.
  , deploymentName :: Maybe Text
  -- ^ The name of the Deployment.
  }

instance ToResource Deployment where
  type ResourceSchema Deployment = 'Nothing
  toResource Deployment{..} = mkResource
    [ "k8s.deployment.name" .=? deploymentName
    , "k8s.deployment.uid" .=? deploymentUid
    ]

-- | Manages the deployment and scaling of a set of Pods, and provides guarantees about the ordering and uniqueness of these Pods.
data StatefulSet = StatefulSet
  { statefulSetUid :: Maybe Text
  -- ^ The UID of the StatefulSet.
  , statefulSetName :: Maybe Text
  -- ^ The name of the StatefulSet.
  }

instance ToResource StatefulSet where
  type ResourceSchema StatefulSet = 'Nothing
  toResource StatefulSet{..} = mkResource
    [ "k8s.statefulset.name" .=? statefulSetName
    , "k8s.statefulset.uid" .=? statefulSetUid
    ]

-- | A DaemonSet ensures that all (or some) Nodes run a copy of a Pod.
data DaemonSet = DaemonSet
  { daemonSetUid :: Maybe Text
  -- ^ The UID of the DaemonSet.	
  , daemonSetName :: Maybe Text
  -- ^ The name of the DaemonSet.
  }

instance ToResource DaemonSet where
  type ResourceSchema DaemonSet = 'Nothing
  toResource DaemonSet{..} = mkResource
    [ "k8s.daemonset.name" .=? daemonSetName
    , "k8s.daemonset.uid" .=? daemonSetUid
    ]

-- | A Job creates one or more Pods and ensures that a specified number of them successfully terminate.
data Job = Job
  { jobUid :: Maybe Text
  -- ^ The UID of the Job.
  , jobName :: Maybe Text
  -- ^ The name of the Job.
  }

instance ToResource Job where
  type ResourceSchema Job = 'Nothing
  toResource Job{..} = mkResource
    [ "k8s.job.name" .=? jobName
    , "k8s.job.uid" .=? jobUid
    ]

-- | A CronJob creates Jobs on a repeating schedule.
data CronJob = CronJob
  { cronJobUid :: Maybe Text
  -- ^ The UID of the CronJob.
  , cronJobName :: Maybe Text
  -- ^ The name of the CronJob.
  }

instance ToResource CronJob where
  type ResourceSchema CronJob = 'Nothing
  toResource CronJob{..} = mkResource
    [ "k8s.cronjob.name" .=? cronJobName
    , "k8s.cronjob.uid" .=? cronJobUid
    ]
