{- FOURMOLU_DISABLE -}
{-# LANGUAGE CPP #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}

{- |
Module      :  OpenTelemetry.Resource.Detect
Copyright   :  (c) Ian Duncan, 2024-2026
License     :  BSD-3
Description :  Shared resource detection orchestration for trace and metrics SDK initialization.
Stability   :  experimental

Shared resource detection orchestration used by both the trace and
metrics SDK initialization paths. Separated to avoid circular module
dependencies between @OpenTelemetry.Trace@ and @OpenTelemetry.Metric@.
-}
module OpenTelemetry.Resource.Detect (
  detectBuiltInResources,
  registerBuiltinResourceDetectors,
  detectResourceAttributes,
) where

import Control.Exception (SomeException, catch)
import Control.Monad (foldM)
import qualified Data.ByteString.Char8 as B
import qualified Data.HashMap.Strict as H
{- FOURMOLU_DISABLE -}
#if !MIN_VERSION_base(4,20,0)
import Data.List (foldl')
#endif
{- FOURMOLU_ENABLE -}
import Data.Maybe (mapMaybe)
import qualified Data.Set as Set
import qualified Data.Text as T
import Data.Text.Encoding (decodeUtf8)
import OpenTelemetry.Attributes.Attribute (Attribute, ToAttribute (..))
import OpenTelemetry.Baggage (decodeBaggageHeader)
import qualified OpenTelemetry.Baggage as Baggage
import OpenTelemetry.Internal.Logging (otelLogDebug, otelLogError, otelLogWarning)
import qualified OpenTelemetry.Registry as Registry
import OpenTelemetry.Resource
import OpenTelemetry.Resource.Cloud ()
import OpenTelemetry.Resource.Cloud.Detector (detectCloud)
import OpenTelemetry.Resource.Container ()
import OpenTelemetry.Resource.Container.Detector (detectContainer)
import OpenTelemetry.Resource.Detector.AWS.EC2 (detectEC2Self)
import OpenTelemetry.Resource.Detector.AWS.ECS (detectECSSelf)
import OpenTelemetry.Resource.Detector.AWS.EKS (detectEKSSelf)
import OpenTelemetry.Resource.Detector.Azure (detectAzureVMSelf)
import OpenTelemetry.Resource.Detector.GCP (detectGCPComputeSelf)
import OpenTelemetry.Resource.Detector.Heroku (detectHeroku)
import OpenTelemetry.Resource.FaaS (FaaS)
import OpenTelemetry.Resource.FaaS.Detector (detectFaaS)
import OpenTelemetry.Resource.Host ()
import OpenTelemetry.Resource.Host.Detector (detectHost)
import OpenTelemetry.Resource.Kubernetes (Cluster, Namespace, Node, Pod)
import OpenTelemetry.Resource.Kubernetes.Detector (KubernetesResources (..), detectKubernetes)
import OpenTelemetry.Resource.OperatingSystem ()
import OpenTelemetry.Resource.OperatingSystem.Detector (detectOperatingSystem)
import OpenTelemetry.Resource.Process ()
import OpenTelemetry.Resource.Process.Detector (detectProcess, detectProcessRuntime)
import OpenTelemetry.Resource.Service ()
import OpenTelemetry.Resource.Service.Detector (detectService)
import OpenTelemetry.Resource.Telemetry ()
import OpenTelemetry.Resource.Telemetry.Detector (detectTelemetry)
import System.Environment (lookupEnv)


{- | Register all built-in resource detectors in the global registry.
Idempotent: uses 'Registry.registerResourceDetectorIfAbsent'.

@since 0.1.0.2
-}
registerBuiltinResourceDetectors :: IO ()
registerBuiltinResourceDetectors = do
  _ <- Registry.registerResourceDetectorIfAbsent "service" (toResource <$> detectService)
  _ <- Registry.registerResourceDetectorIfAbsent "telemetry" (pure $ toResource detectTelemetry)
  _ <- Registry.registerResourceDetectorIfAbsent "process_runtime" (pure $ toResource detectProcessRuntime)
  _ <- Registry.registerResourceDetectorIfAbsent "process" (toResource <$> detectProcess)
  _ <- Registry.registerResourceDetectorIfAbsent "os" (toResource <$> detectOperatingSystem)
  _ <- Registry.registerResourceDetectorIfAbsent "host" (toResource <$> detectHost)
  _ <- Registry.registerResourceDetectorIfAbsent "container" (toResource <$> detectContainer)
  _ <- Registry.registerResourceDetectorIfAbsent "cloud" (toResource <$> detectCloud)
  _ <- Registry.registerResourceDetectorIfAbsent "faas" (mergeOptionalFaaS <$> detectFaaS)
  _ <- Registry.registerResourceDetectorIfAbsent "kubernetes" (mergeOptionalK8s <$> detectKubernetes)
  _ <- Registry.registerResourceDetectorIfAbsent "aws_ecs" detectECSSelf
  _ <- Registry.registerResourceDetectorIfAbsent "aws_ec2" detectEC2Self
  _ <- Registry.registerResourceDetectorIfAbsent "aws_eks" detectEKSSelf
  _ <- Registry.registerResourceDetectorIfAbsent "gcp" detectGCPComputeSelf
  _ <- Registry.registerResourceDetectorIfAbsent "azure_vm" detectAzureVMSelf
  _ <- Registry.registerResourceDetectorIfAbsent "heroku" detectHeroku
  pure ()


builtinDetectorOrder :: [T.Text]
builtinDetectorOrder =
  [ "telemetry"
  , "service"
  , "process_runtime"
  , "process"
  , "os"
  , "host"
  , "container"
  , "cloud"
  , "faas"
  , "kubernetes"
  , "aws_ec2"
  , "aws_ecs"
  , "aws_eks"
  , "gcp"
  , "azure_vm"
  , "heroku"
  ]


allDetectorsInDefaultOrder :: H.HashMap T.Text (IO Resource) -> [IO Resource]
allDetectorsInDefaultOrder allDetectors =
  let orderedBuiltins = mapMaybe (`H.lookup` allDetectors) builtinDetectorOrder
      builtinNames = Set.fromList builtinDetectorOrder
      extraDetectors =
        H.elems $
          H.filterWithKey (\k _ -> not (k `Set.member` builtinNames)) allDetectors
  in orderedBuiltins ++ extraDetectors


{- | Use all registered resource detectors to populate resource information.

Reads @OTEL_RESOURCE_DETECTORS@ (comma-separated) to control which detectors
run. The special value @all@ (the default) runs every registered detector.

@since 0.0.1.0
-}
detectBuiltInResources :: IO Resource
detectBuiltInResources = do
  registerBuiltinResourceDetectors
  allDetectors <- Registry.registeredResourceDetectors
  mFilter <- lookupEnv "OTEL_RESOURCE_DETECTORS"
  activeDetectors <- case mFilter of
    Nothing -> pure $ allDetectorsInDefaultOrder allDetectors
    Just filterStr ->
      let names = fmap T.strip $ T.splitOn "," $ T.pack filterStr
      in if names == ["all"]
          then pure $ allDetectorsInDefaultOrder allDetectors
          else
            foldM
              ( \acc name -> case H.lookup name allDetectors of
                  Just d -> pure (d : acc)
                  Nothing -> do
                    otelLogWarning ("Unknown resource detector '" <> T.unpack name <> "' in OTEL_RESOURCE_DETECTORS, ignoring")
                    pure acc
              )
              []
              names
  resources <- mapM runDetectorSafely activeDetectors
  pure $ foldl' mergeResources (mkResource []) resources
  where
    runDetectorSafely :: IO Resource -> IO Resource
    runDetectorSafely detector =
      detector `catch` \(_ex :: SomeException) -> do
        otelLogDebug "Resource detector failed, skipping"
        pure (mkResource [])


-- | Parse @OTEL_RESOURCE_ATTRIBUTES@ into key-value pairs.
detectResourceAttributes :: IO [(T.Text, Attribute)]
detectResourceAttributes = do
  mEnv <- lookupEnv "OTEL_RESOURCE_ATTRIBUTES"
  case mEnv of
    Nothing -> pure []
    Just envVar -> case decodeBaggageHeader $ B.pack envVar of
      Left err -> do
        otelLogError $ "Failed to parse OTEL_RESOURCE_ATTRIBUTES: " <> err
        pure []
      Right ok ->
        pure $
          map (\(k, v) -> (decodeUtf8 $ Baggage.tokenValue k, toAttribute $ Baggage.value v)) $
            H.toList $
              Baggage.values ok


mergeOptionalFaaS :: Maybe FaaS -> Resource
mergeOptionalFaaS Nothing = mkResource []
mergeOptionalFaaS (Just faas) = toResource faas


mergeOptionalK8s :: Maybe KubernetesResources -> Resource
mergeOptionalK8s Nothing = mkResource []
mergeOptionalK8s (Just KubernetesResources {..}) =
  toResource (k8sCluster :: Cluster)
    `mergeResources` toResource (k8sNamespace :: Namespace)
    `mergeResources` toResource (k8sNode :: Node)
    `mergeResources` toResource (k8sPod :: Pod)
