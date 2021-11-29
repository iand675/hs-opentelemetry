{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DataKinds #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  OpenTelemetry.Resource.DeploymentEnvironment
-- Copyright   :  (c) Ian Duncan, 2021
-- License     :  BSD-3
-- Description :  Name of the deployment environment (aka deployment tier)
-- Maintainer  :  Ian Duncan
-- Stability   :  experimental
-- Portability :  non-portable (GHC extensions)
--
-----------------------------------------------------------------------------
module OpenTelemetry.Resource.DeploymentEnvironment where
import Data.Text (Text)
import OpenTelemetry.Resource

-- | The software deployment.
--
-- This resource doesn't have a an automatic detector because
-- deployment environments tend to have very different detection
-- mechanisms for differing projects.
newtype DeploymentEnvironment = DeploymentEnvironment
  { deploymentEnvironment :: Maybe Text
  -- ^ Name of the deployment environment (aka deployment tier). 
  --
  -- Examples: @staging@, @production@
  }

instance ToResource DeploymentEnvironment where
  type ResourceSchema DeploymentEnvironment = 'Nothing
  toResource DeploymentEnvironment{..} = mkResource
    [ "deployment.environment" .=? deploymentEnvironment
    ]