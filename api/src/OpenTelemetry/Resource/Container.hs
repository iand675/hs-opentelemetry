{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}

-----------------------------------------------------------------------------

-----------------------------------------------------------------------------

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
import OpenTelemetry.Resource


-- | A container instance.
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
  }


instance ToResource Container where
  type ResourceSchema Container = 'Nothing
  toResource Container {..} =
    mkResource
      [ "container.name" .=? containerName
      , "container.id" .=? containerId
      , "container.runtime" .=? containerRuntime
      , "container.image.name" .=? containerImageName
      , "container.image.tag" .=? containerImageTag
      ]
