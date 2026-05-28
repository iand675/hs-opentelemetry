{- |
 Module      :  OpenTelemetry.Resource.Webengine
 Copyright   :  (c) Ian Duncan, 2021-2026
 License     :  BSD-3
 Description :  Resource describing the web engine running the application
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)

 Resource describing the packaged software running the application code.
 Web engines are typically executed using @process.runtime@.
-}
module OpenTelemetry.Resource.Webengine where

import Data.Text (Text)
import OpenTelemetry.Attributes.Key (unkey)
import OpenTelemetry.Resource
import qualified OpenTelemetry.SemanticConventions as SC


{- | A web engine instance.

@since 1.0.0.0
-}
data Webengine = Webengine
  { webengineName :: Text
  -- ^ The name of the web engine. Required.
  , webengineVersion :: Maybe Text
  -- ^ The version of the web engine.
  , webengineDescription :: Maybe Text
  -- ^ Additional description of the web engine.
  }


instance ToResource Webengine where
  toResource Webengine {..} =
    mkResourceWithSchema
      (Just semConvSchemaUrl)
      [ unkey SC.webengine_name .= webengineName
      , unkey SC.webengine_version .=? webengineVersion
      , unkey SC.webengine_description .=? webengineDescription
      ]
