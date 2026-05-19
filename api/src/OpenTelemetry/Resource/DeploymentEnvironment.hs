{- |
 Module      :  OpenTelemetry.Resource.DeploymentEnvironment
 Copyright   :  (c) Ian Duncan, 2021
 License     :  BSD-3
 Description :  Name of the deployment environment (aka deployment tier)
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)
-}
module OpenTelemetry.Resource.DeploymentEnvironment where

import Data.Text (Text)
import OpenTelemetry.Attributes.Key (unkey)
import OpenTelemetry.Resource
import qualified OpenTelemetry.SemanticConventions as SC


{- | The software deployment.

 This resource doesn't have a an automatic detector because
 deployment environments tend to have very different detection
 mechanisms for differing projects.

 @since 0.0.1.0
-}
newtype DeploymentEnvironment = DeploymentEnvironment
  { deploymentEnvironment :: Maybe Text
  {- ^ Name of the deployment environment (aka deployment tier).

  Examples: @staging@, @production@
  -}
  }


instance ToResource DeploymentEnvironment where
  -- 'deployment.environment' is deprecated in favor of 'deployment.environment.name';
  -- we emit both for backward compatibility with older consumers.
  toResource DeploymentEnvironment {..} =
    mkResourceWithSchema
      (Just semConvSchemaUrl)
      [ unkey SC.deployment_environment_name .=? deploymentEnvironment
      , unkey SC.deployment_environment .=? deploymentEnvironment
      ]
