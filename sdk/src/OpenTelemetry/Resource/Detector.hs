{-# LANGUAGE DataKinds #-}
{-# LANGUAGE GADTs #-}

module OpenTelemetry.Resource.Detector where

import OpenTelemetry.Resource (Resource, mergeResources, toResource)
import OpenTelemetry.Resource.Host.Detector (detectHost)
import OpenTelemetry.Resource.OperatingSystem.Detector (detectOperatingSystem)
import OpenTelemetry.Resource.Process.Detector (detectProcess, detectProcessRuntime)
import OpenTelemetry.Resource.Service.Detector (detectService)
import OpenTelemetry.Resource.Telemetry.Detector (detectTelemetry)


{- | Use all built-in resource detectors to populate resource information.

 Currently used detectors include:

 - 'detectService'
 - 'detectProcess'
 - 'detectOperatingSystem'
 - 'detectHost'
 - 'detectTelemetry'
 - 'detectProcessRuntime'

 This list will grow in the future as more detectors are implemented.

 @since 0.0.1.0
-}
detectBuiltInResources :: IO (Resource 'Nothing)
detectBuiltInResources = do
  svc <- detectService
  processInfo <- detectProcess
  osInfo <- detectOperatingSystem
  host <- detectHost
  let rs =
        toResource svc
          `mergeResources` toResource detectTelemetry
          `mergeResources` toResource detectProcessRuntime
          `mergeResources` toResource processInfo
          `mergeResources` toResource osInfo
          `mergeResources` toResource host
  pure rs
