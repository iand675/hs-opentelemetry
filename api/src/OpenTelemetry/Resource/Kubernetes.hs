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

newtype Cluster = Cluster
  { clusterName :: Maybe Text
  }

data Node = Node
  { nodeName :: Maybe Text
  , nodeUid :: Maybe Text
  }

newtype Namespace = Namespace
  { namespaceName :: Maybe Text
  }

data Container = Container
  { containerName :: Maybe Text
  , containerRestartCount :: Maybe Int
  }

data ReplicaSet = ReplicaSet
  { replicaSetUid :: Maybe Text
  , replicaSetName :: Maybe Text
  }

data Deployment = Deployment
  { deploymentUid :: Maybe Text
  , deploymentName :: Maybe Text
  }

data StatefulSet = StatefulSet
  { statefulSetUid :: Maybe Text
  , statefulSetName :: Maybe Text
  }

data DaemonSet = DaemonSet
  { daemonSetUid :: Maybe Text
  , daemonSetName :: Maybe Text
  }

data Job = Job
  { jobUid :: Maybe Text
  , jobName :: Maybe Text
  }

data CronJob = CronJob
  { cronJobUid :: Maybe Text
  , cronJobName :: Maybe Text
  }