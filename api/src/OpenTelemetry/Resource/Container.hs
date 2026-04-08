{- |
 Module      :  OpenTelemetry.Resource.Container
 Copyright   :  (c) Ian Duncan, 2021
 License     :  BSD-3
 Description :  Detect & provide resource info about a container
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)
-}
module OpenTelemetry.Resource.Container where

import Data.Text (Text)
import OpenTelemetry.Attributes.Key (unkey)
import OpenTelemetry.Resource
import qualified OpenTelemetry.SemanticConventions as SC


-- | A container instance.
--
-- @since 0.0.1.0
data Container = Container
  { containerName :: Maybe Text
  -- ^ Container name used by container runtime.
  --
  -- Examples: 'opentelemetry-autoconf'
  , containerId :: Maybe Text
  -- ^ Container ID. Usually a UUID, as for example used to identify Docker containers. The UUID might be abbreviated.
  , containerRuntime :: Maybe Text
  -- ^ The container runtime managing this container.
  , containerImageName :: Maybe Text
  -- ^ Name of the image the container was built on.
  , containerImageTag :: Maybe Text
  -- ^ Container image tag.
  , containerImageId :: Maybe Text
  -- ^ Runtime-specific image identifier (e.g., digest).
  }


instance ToResource Container where
  toResource Container {..} =
    mkResourceWithSchema (Just semConvSchemaUrl)
      [ unkey SC.container_name .=? containerName
      , unkey SC.container_id .=? containerId
      , unkey SC.container_runtime_name .=? containerRuntime
      , unkey SC.container_runtime .=? containerRuntime
      , unkey SC.container_image_name .=? containerImageName
      , unkey SC.container_image_id .=? containerImageId
      , unkey SC.container_image_tags .=? ((: []) <$> containerImageTag)
      ]
