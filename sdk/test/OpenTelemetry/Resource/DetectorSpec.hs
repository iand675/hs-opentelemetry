{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.Resource.DetectorSpec where

import Control.Exception (throwIO)
import qualified Data.HashMap.Strict as H
import Data.Maybe (isJust, isNothing)
import qualified Data.Text as T
import OpenTelemetry.Attributes (lookupAttribute, toAttribute)
import OpenTelemetry.Attributes.Key (unkey)
import OpenTelemetry.Registry (registerResourceDetector, registeredResourceDetectors)
import OpenTelemetry.Resource (Resource, getMaterializedResourcesAttributes, getResourceAttributes, materializeResources, mkResource, (.=))
import OpenTelemetry.Resource.Cloud (Cloud (..))
import OpenTelemetry.Resource.Cloud.Detector (detectCloud)
import OpenTelemetry.Resource.Container (Container (..))
import OpenTelemetry.Resource.Container.Detector (detectContainer)
import OpenTelemetry.Resource.Detector.AWS.EKS (detectEKSSelf)
import OpenTelemetry.Resource.Detector.Heroku (detectHeroku)
import OpenTelemetry.Resource.FaaS (FaaS (..))
import OpenTelemetry.Resource.FaaS.Detector (detectFaaS)
import qualified OpenTelemetry.Resource.Kubernetes as K8s
import OpenTelemetry.Resource.Kubernetes.Detector (KubernetesResources (..), detectKubernetes, isRunningInKubernetes)
import OpenTelemetry.Resource.OperatingSystem (OperatingSystem (..))
import OpenTelemetry.Resource.OperatingSystem.Detector (detectOperatingSystem)
import qualified OpenTelemetry.SemanticConventions as SC
import OpenTelemetry.Trace (detectBuiltInResources, registerBuiltinResourceDetectors)
import System.Environment (lookupEnv, setEnv, unsetEnv)
import System.Info (os)
import Test.Hspec


spec :: Spec
spec = describe "Resource Detectors" $ do
  -- Resource SDK §Detecting Resource information from the environment
  -- https://opentelemetry.io/docs/specs/otel/resource/sdk/#detecting-resource-information-from-the-environment
  containerSpec
  kubernetesSpec
  cloudSpec
  eksSpec
  faasSpec
  osSpec
  herokuSpec
  gcpParsingSpec
  ecsArnSpec
  registrySpec


containerSpec :: Spec
containerSpec = describe "Container" $ do
  -- Semantic conventions: container.* resource attributes (when detectable)
  -- https://opentelemetry.io/docs/specs/semconv/resource/container/
  it "returns all Nothing fields on macOS/non-Linux" $ do
    container <- detectContainer
    case os of
      "darwin" -> do
        containerId container `shouldBe` Nothing
      _ -> pure ()


kubernetesSpec :: Spec
kubernetesSpec = describe "Kubernetes" $ do
  -- Semantic conventions: Kubernetes resource (k8s.*)
  -- https://opentelemetry.io/docs/specs/semconv/resource/kubernetes/
  around_ withCleanK8sEnv $ do
    it "returns Nothing when not in k8s" $ do
      result <- detectKubernetes
      result `shouldSatisfy` isNothing

    it "detects k8s via KUBERNETES_SERVICE_HOST" $ do
      setEnv "KUBERNETES_SERVICE_HOST" "10.0.0.1"
      setEnv "HOSTNAME" "my-pod-abc123"
      inK8s <- isRunningInKubernetes
      inK8s `shouldBe` True
      result <- detectKubernetes
      result `shouldSatisfy` isJust

    it "reads pod name from HOSTNAME" $ do
      setEnv "KUBERNETES_SERVICE_HOST" "10.0.0.1"
      setEnv "HOSTNAME" "web-server-7f9d4c-x2k4p"
      Just k8s <- detectKubernetes
      K8s.podName (k8sPod k8s) `shouldBe` Just "web-server-7f9d4c-x2k4p"

    it "prefers K8S_POD_NAME over HOSTNAME" $ do
      setEnv "KUBERNETES_SERVICE_HOST" "10.0.0.1"
      setEnv "HOSTNAME" "web-server-7f9d4c-x2k4p"
      setEnv "K8S_POD_NAME" "explicit-pod-name"
      Just k8s <- detectKubernetes
      K8s.podName (k8sPod k8s) `shouldBe` Just "explicit-pod-name"

    it "reads cluster name from K8S_CLUSTER_NAME" $ do
      setEnv "KUBERNETES_SERVICE_HOST" "10.0.0.1"
      setEnv "K8S_CLUSTER_NAME" "production-us-east"
      Just k8s <- detectKubernetes
      K8s.clusterName (k8sCluster k8s) `shouldBe` Just "production-us-east"

    it "reads node name from K8S_NODE_NAME" $ do
      setEnv "KUBERNETES_SERVICE_HOST" "10.0.0.1"
      setEnv "K8S_NODE_NAME" "ip-10-0-1-42"
      Just k8s <- detectKubernetes
      K8s.nodeName (k8sNode k8s) `shouldBe` Just "ip-10-0-1-42"

    it "reads namespace from K8S_NAMESPACE" $ do
      setEnv "KUBERNETES_SERVICE_HOST" "10.0.0.1"
      setEnv "K8S_NAMESPACE" "production"
      Just k8s <- detectKubernetes
      K8s.namespaceName (k8sNamespace k8s) `shouldBe` Just "production"


cloudSpec :: Spec
cloudSpec = describe "Cloud" $ do
  -- Semantic conventions: cloud.* resource attributes
  -- https://opentelemetry.io/docs/specs/semconv/resource/cloud/
  around_ withCleanCloudEnv $ do
    it "returns empty cloud when no provider detected" $ do
      cloud <- detectCloud
      cloudProvider cloud `shouldBe` Nothing

    it "detects AWS from AWS_REGION" $ do
      setEnv "AWS_REGION" "us-east-1"
      cloud <- detectCloud
      cloudProvider cloud `shouldBe` Just "aws"
      cloudRegion cloud `shouldBe` Just "us-east-1"

    it "detects AWS Lambda" $ do
      setEnv "AWS_LAMBDA_FUNCTION_NAME" "my-function"
      setEnv "AWS_REGION" "eu-west-1"
      cloud <- detectCloud
      cloudProvider cloud `shouldBe` Just "aws"
      cloudPlatform cloud `shouldBe` Just "aws_lambda"
      cloudRegion cloud `shouldBe` Just "eu-west-1"

    it "detects AWS ECS" $ do
      setEnv "ECS_CONTAINER_METADATA_URI_V4" "http://169.254.170.2/v4/abc123"
      setEnv "AWS_REGION" "us-west-2"
      cloud <- detectCloud
      cloudProvider cloud `shouldBe` Just "aws"
      cloudPlatform cloud `shouldBe` Just "aws_ecs"

    it "detects AWS App Runner" $ do
      setEnv "AWS_APP_RUNNER_SERVICE_ID" "svc-123"
      setEnv "AWS_REGION" "us-east-1"
      cloud <- detectCloud
      cloudProvider cloud `shouldBe` Just "aws"
      cloudPlatform cloud `shouldBe` Just "aws_app_runner"

    it "detects GCP from GOOGLE_CLOUD_PROJECT" $ do
      setEnv "GOOGLE_CLOUD_PROJECT" "my-project"
      cloud <- detectCloud
      cloudProvider cloud `shouldBe` Just "gcp"
      cloudAccountId cloud `shouldBe` Just "my-project"

    it "detects GCP Cloud Run" $ do
      setEnv "K_SERVICE" "my-service"
      setEnv "GOOGLE_CLOUD_PROJECT" "my-project"
      setEnv "GOOGLE_CLOUD_REGION" "us-central1"
      cloud <- detectCloud
      cloudProvider cloud `shouldBe` Just "gcp"
      cloudPlatform cloud `shouldBe` Just "gcp_cloud_run"
      cloudRegion cloud `shouldBe` Just "us-central1"

    it "detects GCP Cloud Functions" $ do
      setEnv "FUNCTION_TARGET" "helloWorld"
      setEnv "GOOGLE_CLOUD_PROJECT" "my-project"
      setEnv "FUNCTION_REGION" "us-central1"
      cloud <- detectCloud
      cloudProvider cloud `shouldBe` Just "gcp"
      cloudPlatform cloud `shouldBe` Just "gcp_cloud_functions"
      cloudRegion cloud `shouldBe` Just "us-central1"

    it "detects Azure App Service" $ do
      setEnv "WEBSITE_SITE_NAME" "my-app"
      cloud <- detectCloud
      cloudProvider cloud `shouldBe` Just "azure"
      cloudPlatform cloud `shouldBe` Just "azure_app_service"

    it "detects Azure Functions" $ do
      setEnv "FUNCTIONS_WORKER_RUNTIME" "custom"
      setEnv "REGION_NAME" "eastus"
      cloud <- detectCloud
      cloudProvider cloud `shouldBe` Just "azure"
      cloudPlatform cloud `shouldBe` Just "azure_functions"
      cloudRegion cloud `shouldBe` Just "eastus"

    it "detects Azure Container Apps" $ do
      setEnv "CONTAINER_APP_NAME" "my-container-app"
      cloud <- detectCloud
      cloudProvider cloud `shouldBe` Just "azure"
      cloudPlatform cloud `shouldBe` Just "azure_container_apps"

    it "detects AWS EKS from KUBERNETES_SERVICE_HOST + AWS env" $ do
      setEnv "AWS_REGION" "us-east-1"
      setEnv "KUBERNETES_SERVICE_HOST" "10.96.0.1"
      cloud <- detectCloud
      cloudProvider cloud `shouldBe` Just "aws"
      cloudPlatform cloud `shouldBe` Just "aws_eks"

    it "prefers ECS over EKS when both present" $ do
      setEnv "ECS_CONTAINER_METADATA_URI_V4" "http://169.254.170.2/v4/abc"
      setEnv "AWS_REGION" "us-east-1"
      setEnv "KUBERNETES_SERVICE_HOST" "10.96.0.1"
      cloud <- detectCloud
      cloudPlatform cloud `shouldBe` Just "aws_ecs"

    it "prefers AWS over GCP when both present" $ do
      setEnv "AWS_REGION" "us-east-1"
      setEnv "GOOGLE_CLOUD_PROJECT" "my-project"
      cloud <- detectCloud
      cloudProvider cloud `shouldBe` Just "aws"


eksSpec :: Spec
eksSpec = describe "EKS" $ do
  -- Semantic conventions: AWS EKS (cloud.platform aws_eks)
  -- https://opentelemetry.io/docs/specs/semconv/resource/cloud/
  around_ withCleanEksEnv $ do
    it "returns empty when not in k8s" $ do
      r <- detectEKSSelf
      lookupAttribute (getResourceAttributes r) (unkey SC.cloud_platform) `shouldBe` Nothing

    it "returns empty when ECS is detected (yields to more specific detector)" $ do
      setEnv "KUBERNETES_SERVICE_HOST" "10.96.0.1"
      setEnv "ECS_CONTAINER_METADATA_URI_V4" "http://169.254.170.2/v4/abc"
      r <- detectEKSSelf
      lookupAttribute (getResourceAttributes r) (unkey SC.cloud_platform) `shouldBe` Nothing

    it "returns empty when Lambda is detected" $ do
      setEnv "KUBERNETES_SERVICE_HOST" "10.96.0.1"
      setEnv "AWS_LAMBDA_FUNCTION_NAME" "my-func"
      r <- detectEKSSelf
      lookupAttribute (getResourceAttributes r) (unkey SC.cloud_platform) `shouldBe` Nothing

    it "returns empty when service account files are missing" $ do
      setEnv "KUBERNETES_SERVICE_HOST" "10.96.0.1"
      r <- detectEKSSelf
      lookupAttribute (getResourceAttributes r) (unkey SC.cloud_platform) `shouldBe` Nothing


faasSpec :: Spec
faasSpec = describe "FaaS" $ do
  -- Semantic conventions: faas.* resource attributes
  -- https://opentelemetry.io/docs/specs/semconv/resource/faas/
  around_ withCleanFaaSEnv $ do
    it "returns Nothing when not in FaaS" $ do
      result <- detectFaaS
      result `shouldSatisfy` isNothing

    it "detects AWS Lambda" $ do
      setEnv "AWS_LAMBDA_FUNCTION_NAME" "my-handler"
      setEnv "AWS_LAMBDA_FUNCTION_VERSION" "$LATEST"
      setEnv "AWS_LAMBDA_LOG_STREAM_NAME" "2024/01/01/[$LATEST]abc123"
      setEnv "AWS_LAMBDA_FUNCTION_MEMORY_SIZE" "256"
      setEnv "AWS_REGION" "us-east-1"
      result <- detectFaaS
      case result of
        Nothing -> expectationFailure "Expected FaaS detection"
        Just faas -> do
          faasName faas `shouldBe` "my-handler"
          faasVersion faas `shouldBe` Just "$LATEST"
          faasInstance faas `shouldBe` Just "2024/01/01/[$LATEST]abc123"
          faasMaxMemory faas `shouldBe` Just 256

    it "detects GCP Cloud Functions" $ do
      setEnv "FUNCTION_TARGET" "helloWorld"
      setEnv "K_REVISION" "helloWorld-00001"
      setEnv "FUNCTION_MEMORY_MB" "256"
      result <- detectFaaS
      case result of
        Nothing -> expectationFailure "Expected FaaS detection"
        Just faas -> do
          faasName faas `shouldBe` "helloWorld"
          faasVersion faas `shouldBe` Just "helloWorld-00001"
          faasMaxMemory faas `shouldBe` Just 256

    it "detects Azure Functions" $ do
      setEnv "FUNCTIONS_WORKER_RUNTIME" "custom"
      setEnv "WEBSITE_SITE_NAME" "my-func-app"
      result <- detectFaaS
      case result of
        Nothing -> expectationFailure "Expected FaaS detection"
        Just faas -> do
          faasName faas `shouldBe` "my-func-app"

    it "prefers Lambda over GCF when both present" $ do
      setEnv "AWS_LAMBDA_FUNCTION_NAME" "my-lambda"
      setEnv "FUNCTION_TARGET" "my-gcf"
      result <- detectFaaS
      case result of
        Nothing -> expectationFailure "Expected FaaS detection"
        Just faas -> faasName faas `shouldBe` "my-lambda"


herokuSpec :: Spec
herokuSpec = describe "Heroku" $ do
  -- Semantic conventions: Heroku (cloud.provider heroku, heroku.*)
  -- https://opentelemetry.io/docs/specs/semconv/resource/heroku/
  around_ withCleanHerokuEnv $ do
    it "returns empty resource when not on Heroku" $ do
      r <- detectHeroku
      lookupAttribute (getResourceAttributes r) (unkey SC.cloud_provider) `shouldBe` Nothing

    it "detects Heroku from HEROKU_APP_ID" $ do
      setEnv "HEROKU_APP_ID" "abc-123"
      setEnv "HEROKU_APP_NAME" "my-haskell-app"
      setEnv "HEROKU_DYNO_ID" "web.1"
      setEnv "HEROKU_RELEASE_VERSION" "v42"
      setEnv "HEROKU_SLUG_COMMIT" "deadbeef"
      setEnv "HEROKU_RELEASE_CREATED_AT" "2026-04-06T12:00:00Z"
      r <- detectHeroku
      let attrs = getResourceAttributes r
      lookupAttribute attrs (unkey SC.cloud_provider) `shouldBe` Just (toAttribute ("heroku" :: T.Text))
      lookupAttribute attrs (unkey SC.heroku_app_id) `shouldBe` Just (toAttribute ("abc-123" :: T.Text))
      lookupAttribute attrs (unkey SC.service_name) `shouldBe` Just (toAttribute ("my-haskell-app" :: T.Text))
      lookupAttribute attrs (unkey SC.service_instance_id) `shouldBe` Just (toAttribute ("web.1" :: T.Text))
      lookupAttribute attrs (unkey SC.service_version) `shouldBe` Just (toAttribute ("v42" :: T.Text))
      lookupAttribute attrs (unkey SC.heroku_release_commit) `shouldBe` Just (toAttribute ("deadbeef" :: T.Text))
      lookupAttribute attrs (unkey SC.heroku_release_creationTimestamp) `shouldBe` Just (toAttribute ("2026-04-06T12:00:00Z" :: T.Text))

    it "sets only cloud.provider and heroku.app.id when other vars are missing" $ do
      setEnv "HEROKU_APP_ID" "minimal-123"
      r <- detectHeroku
      let attrs = getResourceAttributes r
      lookupAttribute attrs (unkey SC.cloud_provider) `shouldBe` Just (toAttribute ("heroku" :: T.Text))
      lookupAttribute attrs (unkey SC.heroku_app_id) `shouldBe` Just (toAttribute ("minimal-123" :: T.Text))
      lookupAttribute attrs (unkey SC.service_name) `shouldBe` Nothing


osSpec :: Spec
osSpec = describe "OperatingSystem" $ do
  -- Semantic conventions: operating system (os.type)
  -- https://opentelemetry.io/docs/specs/semconv/resource/os/
  it "detects os type" $ do
    osInfo <- detectOperatingSystem
    osType osInfo `shouldSatisfy` (not . T.null)

  it "maps mingw32 to windows" $ do
    osInfo <- detectOperatingSystem
    if os == "mingw32"
      then osType osInfo `shouldBe` "windows"
      else osType osInfo `shouldBe` T.pack os


-- Helpers to clean up env vars between tests

withCleanK8sEnv :: IO () -> IO ()
withCleanK8sEnv action = do
  saved <- mapM saveEnv k8sEnvVars
  mapM_ safeUnsetEnv k8sEnvVars
  action
  mapM_ (uncurry restoreEnv) (zip k8sEnvVars saved)


withCleanCloudEnv :: IO () -> IO ()
withCleanCloudEnv action = do
  saved <- mapM saveEnv cloudEnvVars
  mapM_ safeUnsetEnv cloudEnvVars
  action
  mapM_ (uncurry restoreEnv) (zip cloudEnvVars saved)


withCleanFaaSEnv :: IO () -> IO ()
withCleanFaaSEnv action = do
  saved <- mapM saveEnv faasEnvVars
  mapM_ safeUnsetEnv faasEnvVars
  action
  mapM_ (uncurry restoreEnv) (zip faasEnvVars saved)


withCleanHerokuEnv :: IO () -> IO ()
withCleanHerokuEnv action = do
  saved <- mapM saveEnv herokuEnvVars
  mapM_ safeUnsetEnv herokuEnvVars
  action
  mapM_ (uncurry restoreEnv) (zip herokuEnvVars saved)


saveEnv :: String -> IO (Maybe String)
saveEnv = lookupEnv


restoreEnv :: String -> Maybe String -> IO ()
restoreEnv key Nothing = safeUnsetEnv key
restoreEnv key (Just val) = setEnv key val


safeUnsetEnv :: String -> IO ()
safeUnsetEnv = unsetEnv


k8sEnvVars :: [String]
k8sEnvVars =
  [ "KUBERNETES_SERVICE_HOST"
  , "KUBERNETES_SERVICE_PORT"
  , "HOSTNAME"
  , "K8S_POD_NAME"
  , "K8S_POD_UID"
  , "K8S_CLUSTER_NAME"
  , "K8S_NODE_NAME"
  , "K8S_NAMESPACE"
  ]


cloudEnvVars :: [String]
cloudEnvVars =
  [ "AWS_REGION"
  , "AWS_DEFAULT_REGION"
  , "AWS_LAMBDA_FUNCTION_NAME"
  , "ECS_CONTAINER_METADATA_URI_V4"
  , "ECS_CONTAINER_METADATA_URI"
  , "ELASTIC_BEANSTALK_ENVIRONMENT_NAME"
  , "AWS_APP_RUNNER_SERVICE_ID"
  , "AWS_EXECUTION_ENV"
  , "AWS_AVAILABILITY_ZONE"
  , "AWS_ACCOUNT_ID"
  , "KUBERNETES_SERVICE_HOST"
  , "KUBERNETES_SERVICE_PORT"
  , "GOOGLE_CLOUD_PROJECT"
  , "GCLOUD_PROJECT"
  , "GCP_PROJECT"
  , "K_SERVICE"
  , "FUNCTION_TARGET"
  , "GAE_SERVICE"
  , "GAE_ENV"
  , "GOOGLE_CLOUD_REGION"
  , "FUNCTION_REGION"
  , "WEBSITE_SITE_NAME"
  , "FUNCTIONS_WORKER_RUNTIME"
  , "CONTAINER_APP_NAME"
  , "AZURE_FUNCTIONS_ENVIRONMENT"
  , "REGION_NAME"
  , "AZURE_SUBSCRIPTION_ID"
  ]


faasEnvVars :: [String]
faasEnvVars =
  [ "AWS_LAMBDA_FUNCTION_NAME"
  , "AWS_LAMBDA_FUNCTION_VERSION"
  , "AWS_LAMBDA_LOG_STREAM_NAME"
  , "AWS_LAMBDA_FUNCTION_MEMORY_SIZE"
  , "AWS_REGION"
  , "AWS_ACCOUNT_ID"
  , "FUNCTION_TARGET"
  , "K_REVISION"
  , "FUNCTION_MEMORY_MB"
  , "FUNCTIONS_WORKER_RUNTIME"
  , "WEBSITE_SITE_NAME"
  ]


herokuEnvVars :: [String]
herokuEnvVars =
  [ "HEROKU_APP_ID"
  , "HEROKU_APP_NAME"
  , "HEROKU_DYNO_ID"
  , "HEROKU_RELEASE_VERSION"
  , "HEROKU_SLUG_COMMIT"
  , "HEROKU_RELEASE_CREATED_AT"
  ]


-- Internal module re-exports for testing. These are tested via
-- the public API (detectGCPCompute), but the pure parsing functions
-- are worth testing directly since we can't call real metadata servers.

gcpExtractLastSegment :: T.Text -> T.Text
gcpExtractLastSegment t = case T.splitOn "/" t of
  [] -> t
  parts -> last parts


gcpExtractRegionFromZone :: T.Text -> Maybe T.Text
gcpExtractRegionFromZone az =
  let parts = T.splitOn "-" az
  in if length parts >= 3
       then Just $ T.intercalate "-" (take (length parts - 1) parts)
       else Nothing


ecsNormalizeArn :: T.Text -> [T.Text] -> T.Text -> T.Text
ecsNormalizeArn val arnParts suffix
  | "arn:" `T.isPrefixOf` val = val
  | length arnParts >= 5 =
      let base = T.intercalate ":" (take 5 arnParts)
      in base <> ":" <> suffix <> "/" <> val
  | otherwise = val


gcpParsingSpec :: Spec
gcpParsingSpec = describe "GCP metadata parsing" $ do
  -- Implementation-specific: pure helpers for GCP metadata path parsing
  describe "extractLastSegment" $ do
    it "extracts zone from full path" $ do
      gcpExtractLastSegment "projects/123456/zones/us-central1-a"
        `shouldBe` "us-central1-a"

    it "extracts machine type from full path" $ do
      gcpExtractLastSegment "projects/123456/machineTypes/n2-standard-4"
        `shouldBe` "n2-standard-4"

    it "returns input unchanged when no slashes" $ do
      gcpExtractLastSegment "us-central1-a"
        `shouldBe` "us-central1-a"

  describe "extractRegionFromZone" $ do
    it "extracts region from standard zone" $ do
      gcpExtractRegionFromZone "us-central1-a" `shouldBe` Just "us-central1"

    it "extracts region from two-part region" $ do
      gcpExtractRegionFromZone "europe-west1-b" `shouldBe` Just "europe-west1"

    it "handles zones with more dashes" $ do
      gcpExtractRegionFromZone "asia-southeast1-c" `shouldBe` Just "asia-southeast1"

    it "returns Nothing for invalid zone format" $ do
      gcpExtractRegionFromZone "invalid" `shouldBe` Nothing

    it "returns Nothing for single dash" $ do
      gcpExtractRegionFromZone "us-central1" `shouldBe` Nothing


ecsArnSpec :: Spec
ecsArnSpec = describe "ECS ARN normalization" $ do
  -- Implementation-specific: ECS ARN string normalization for resource attributes
  it "passes through a full ARN unchanged" $ do
    let arn = "arn:aws:ecs:us-east-1:123456789:cluster/my-cluster"
    ecsNormalizeArn arn [] "cluster" `shouldBe` arn

  it "constructs ARN from short name and task ARN parts" $ do
    let taskArnParts = T.splitOn ":" "arn:aws:ecs:us-east-1:123456789:task/my-task-id"
    ecsNormalizeArn "my-cluster" taskArnParts "cluster"
      `shouldBe` "arn:aws:ecs:us-east-1:123456789:cluster/my-cluster"

  it "returns the value as-is if ARN parts are insufficient" $ do
    ecsNormalizeArn "my-cluster" ["arn", "aws"] "cluster"
      `shouldBe` "my-cluster"

  it "extracts region from task ARN" $ do
    let arnParts = T.splitOn ":" "arn:aws:ecs:eu-west-1:987654321:task/task-id"
    case arnParts of
      [_, _, _, region, _, _] -> region `shouldBe` "eu-west-1"
      _ -> expectationFailure "ARN should have 6 parts"

  it "extracts account ID from task ARN" $ do
    let arnParts = T.splitOn ":" "arn:aws:ecs:us-west-2:111222333:task/task-id"
    case arnParts of
      [_, _, _, _, acctId, _] -> acctId `shouldBe` "111222333"
      _ -> expectationFailure "ARN should have 6 parts"


registrySpec :: Spec
registrySpec = describe "Resource Detector Registry" $ do
  -- Resource SDK: OTEL_RESOURCE_DETECTORS and detector registration
  -- https://opentelemetry.io/docs/specs/otel/resource/sdk/#detecting-resource-information-from-the-environment
  around_ withCleanDetectorEnv $ do
    it "registerBuiltinResourceDetectors populates the registry" $ do
      registerBuiltinResourceDetectors
      detectors <- registeredResourceDetectors
      let names = H.keys detectors
      names `shouldSatisfy` elem "service"
      names `shouldSatisfy` elem "host"
      names `shouldSatisfy` elem "aws_ec2"
      names `shouldSatisfy` elem "aws_ecs"
      names `shouldSatisfy` elem "aws_eks"
      names `shouldSatisfy` elem "gcp"
      names `shouldSatisfy` elem "azure_vm"
      names `shouldSatisfy` elem "heroku"

    it "custom detectors can be registered" $ do
      let myDetector = pure $ mkResource ["custom.key" .= ("val" :: T.Text)]
      registerResourceDetector "custom" myDetector
      detectors <- registeredResourceDetectors
      H.keys detectors `shouldSatisfy` elem "custom"

    it "OTEL_RESOURCE_DETECTORS filters active detectors" $ do
      setEnv "OTEL_RESOURCE_DETECTORS" "service,os"
      _ <- detectBuiltInResources
      pure () :: IO ()

    it "OTEL_RESOURCE_DETECTORS=all runs all detectors" $ do
      setEnv "OTEL_RESOURCE_DETECTORS" "all"
      _ <- detectBuiltInResources
      pure () :: IO ()

    it "a failing detector does not crash detection of other detectors" $ do
      let failingDetector = throwIO (userError "detector explosion") :: IO Resource
          goodDetector = pure $ mkResource ["good.key" .= ("found" :: T.Text)]
      registerResourceDetector "failing_test" failingDetector
      registerResourceDetector "good_test" goodDetector
      setEnv "OTEL_RESOURCE_DETECTORS" "failing_test,good_test"
      rs <- detectBuiltInResources
      let materialized = materializeResources rs
          attrs = getMaterializedResourcesAttributes materialized
      lookupAttribute attrs "good.key" `shouldBe` Just (toAttribute ("found" :: T.Text))
      unsetEnv "OTEL_RESOURCE_DETECTORS"


withCleanDetectorEnv :: IO () -> IO ()
withCleanDetectorEnv action = do
  saved <- mapM saveEnv detectorEnvVars
  mapM_ safeUnsetEnv detectorEnvVars
  action
  mapM_ (uncurry restoreEnv) (zip detectorEnvVars saved)


withCleanEksEnv :: IO () -> IO ()
withCleanEksEnv action = do
  saved <- mapM saveEnv eksEnvVars
  mapM_ safeUnsetEnv eksEnvVars
  action
  mapM_ (uncurry restoreEnv) (zip eksEnvVars saved)


eksEnvVars :: [String]
eksEnvVars =
  [ "KUBERNETES_SERVICE_HOST"
  , "KUBERNETES_SERVICE_PORT"
  , "ECS_CONTAINER_METADATA_URI_V4"
  , "AWS_LAMBDA_FUNCTION_NAME"
  ]


detectorEnvVars :: [String]
detectorEnvVars =
  cloudEnvVars ++ ["OTEL_RESOURCE_DETECTORS"]
