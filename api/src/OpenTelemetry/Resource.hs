{-# LANGUAGE DefaultSignatures #-}

{- |
Module      :  OpenTelemetry.Resource
Copyright   :  (c) Ian Duncan, 2021-2026
License     :  BSD-3
Description :  Metadata describing the entity producing telemetry
Stability   :  experimental

= Overview

A 'Resource' is an immutable set of attributes describing the entity that
produces telemetry: the service name, host, container, cloud environment, etc.
Every span, metric, and log record is associated with a resource.

= Quick example

@
import OpenTelemetry.Resource

-- Build a resource from key-value pairs:
myResource :: Resource
myResource = mkResource
  [ "service.name" .= ("my-service" :: Text)
  , "service.version" .= ("1.2.0" :: Text)
  ]

-- Build from a typed data structure:
import OpenTelemetry.Resource.Service
myService :: Resource
myService = toResource Service
  { serviceName = "my-service"
  , serviceNamespace = Just "production"
  , serviceInstanceId = Nothing
  , serviceVersion = Just "1.2.0"
  , serviceCriticality = Nothing
  }
@

= Automatic detection

The SDK automatically detects resources from the environment (hostname, OS,
process info, container ID, cloud metadata). You can add your own on top:

@
(processors, opts) <- getTracerProviderInitializationOptions' myResource
@

= Merging

Resources can be combined with '<>' or 'mergeResources'. When keys conflict,
the first argument (the /updating/ resource) wins. Schema URLs are merged per the OTel spec.

= Spec reference

<https://opentelemetry.io/docs/specs/otel/resource/sdk/>
-}
module OpenTelemetry.Resource (
  -- * Creating resources directly
  mkResource,
  mkResourceWithSchema,
  semConvSchemaUrl,
  Resource,
  (.=),
  (.=?),
  mergeResources,

  -- * Creating resources from data structures
  ToResource (..),

  -- * Using resources with a 'OpenTelemetry.Trace.TracerProvider'
  MaterializedResources,
  materializeResources,
  emptyMaterializedResources,
  getMaterializedResourcesSchema,
  getMaterializedResourcesAttributes,

  -- * Convenience constructors
  materializeResourcesWithSchema,
  setMaterializedResourcesSchema,

  -- * Accessing resource fields
  getResourceAttributes,
  getResourceSchemaUrl,
) where

import Data.Maybe (catMaybes)
import Data.Text (Text)
import qualified Data.Text as T
import OpenTelemetry.Attributes
import OpenTelemetry.Internal.Logging (otelLogWarning)
import System.IO.Unsafe (unsafePerformIO)


{- | The OpenTelemetry semantic conventions schema URL for version 1.40.0.
Resources that use semantic convention attributes SHOULD carry this URL
so backends can perform automatic attribute migration across versions.

@since 0.4.0.0
-}
semConvSchemaUrl :: Text
semConvSchemaUrl = "https://opentelemetry.io/schemas/1.40.0"


{- | A set of attributes with an optional schema URL.

A Resource is an immutable representation of the entity producing telemetry as
Attributes. For example, a process producing telemetry that is running in a
container on Kubernetes has a Pod name, it is in a namespace and possibly is
part of a Deployment which also has a name.

All three of these attributes can be included in the Resource.

Note that there are certain
<https://github.com/open-telemetry/opentelemetry-specification/blob/34144d02baaa39f7aa97ee914539089e1481166c/specification/resource/semantic_conventions/README.md "standard attributes">
that have prescribed meanings.

A number of these standard resources may be found in the @OpenTelemetry.Resource.*@ modules.

The primary purpose of resources as a first-class concept in the SDK is
decoupling of discovery of resource information from exporters. This allows for
independent development and easy customization for users that need to integrate
with closed source environments.

@since 0.0.1.0
-}
data Resource = Resource
  { resourceSchemaUrl :: !(Maybe Text)
  , resourceAttributes :: !Attributes
  }


instance Show Resource where
  showsPrec d (Resource s a) =
    showParen (d > 10) $
      showString "Resource "
        . showsPrec 11 s
        . showChar ' '
        . showsPrec 11 a


instance Eq Resource where
  Resource s1 a1 == Resource s2 a2 = s1 == s2 && a1 == a2


{- | Utility function to create a resource from a list
 of fields and attributes. See the '.=' and '.=?' functions.

 @since 0.0.1.0
-}
mkResource :: [Maybe (Text, Attribute)] -> Resource
mkResource = Resource Nothing . unsafeAttributesFromListIgnoringLimits . catMaybes


{- | Create a resource with an explicit schema URL.

@since 0.4.0.0
-}
mkResourceWithSchema :: Maybe Text -> [Maybe (Text, Attribute)] -> Resource
mkResourceWithSchema schema = Resource schema . unsafeAttributesFromListIgnoringLimits . catMaybes


{- | Utility function to convert a required resource attribute
 into the format needed for 'mkResource'.

 @since 0.0.1.0
-}
(.=) :: (ToAttribute a) => Text -> a -> Maybe (Text, Attribute)
k .= v = Just (k, toAttribute v)


{- | Utility function to convert an optional resource attribute
 into the format needed for 'mkResource'.

 @since 0.0.1.0
-}
(.=?) :: (ToAttribute a) => Text -> Maybe a -> Maybe (Text, Attribute)
k .=? mv = (\k' v -> (k', toAttribute v)) k <$> mv


-- | Merge two resources, taking the left-biased union of attributes.
instance Semigroup Resource where
  (<>) = mergeResources


instance Monoid Resource where
  mempty = Resource Nothing emptyAttributes


{- | Combine two 'Resource' values into a new 'Resource' that contains the
 attributes of the two inputs.

 If a key exists on both resources, the value of the first (updating)
 resource takes precedence.

 Schema URL merge follows the OpenTelemetry specification:

 * If one resource's Schema URL is empty, the other's is used.
 * If both are the same, that URL is used.
 * If both are non-empty and different, the first resource's URL is kept
   (the spec says this case is \"implementation-specific\"); a warning is also
   emitted to the OTel diagnostic logger.

 @since 0.0.1.0
-}
mergeResources
  :: Resource
  -- ^ the updating resource whose attributes take precedence
  -> Resource
  -- ^ the old resource
  -> Resource
mergeResources (Resource newSchema newAttrs) (Resource oldSchema oldAttrs) =
  Resource (mergeSchemaUrls newSchema oldSchema) (unsafeMergeAttributesIgnoringLimits newAttrs oldAttrs)


mergeSchemaUrls :: Maybe Text -> Maybe Text -> Maybe Text
mergeSchemaUrls Nothing b = b
mergeSchemaUrls a Nothing = a
mergeSchemaUrls a@(Just s1) (Just s2)
  | s1 == s2 = a
  | otherwise =
      unsafePerformIO $ do
        otelLogWarning ("Resource schema URL conflict: '" <> T.unpack s1 <> "' vs '" <> T.unpack s2 <> "'")
        pure a


{- | A convenience class for converting arbitrary data into resources.

@since 0.0.1.0
-}
class ToResource a where
  -- | Convert the input value to a 'Resource'
  toResource :: a -> Resource


{- | Access the attributes of a resource.

@since 0.0.1.0
-}
getResourceAttributes :: Resource -> Attributes
getResourceAttributes = resourceAttributes


{- | Access the schema URL of a resource.

@since 0.0.1.0
-}
getResourceSchemaUrl :: Resource -> Maybe Text
getResourceSchemaUrl = resourceSchemaUrl


{- | A read-only resource attribute collection with an associated schema.

@since 0.0.1.0
-}
data MaterializedResources = MaterializedResources
  { materializedResourcesSchema :: Maybe String
  , materializedResourcesAttributes :: Attributes
  }
  deriving (Show, Eq)


{- | A placeholder for 'MaterializedResources' when no resource information is
 available, needed, or required.

 @since 0.0.1.0
-}
emptyMaterializedResources :: MaterializedResources
emptyMaterializedResources = MaterializedResources Nothing emptyAttributes


{- | Access the schema for a 'MaterializedResources' value.

 @since 0.0.1.0
-}
getMaterializedResourcesSchema :: MaterializedResources -> Maybe String
getMaterializedResourcesSchema = materializedResourcesSchema


{- | Access the attributes for a 'MaterializedResources' value.

 @since 0.0.1.0
-}
getMaterializedResourcesAttributes :: MaterializedResources -> Attributes
getMaterializedResourcesAttributes = materializedResourcesAttributes


{- | Convert a 'Resource' to 'MaterializedResources'.

@since 0.0.1.0
-}
materializeResources :: Resource -> MaterializedResources
materializeResources (Resource mSchema attrs) =
  MaterializedResources (T.unpack <$> mSchema) attrs


{- | Materialize a resource with an explicit runtime schema URL,
overriding any schema URL on the resource itself.

@
let res = materializeResourcesWithSchema
            (Just "https:\/\/opentelemetry.io\/schemas\/1.25.0")
            (mkResource ["service.name" .= ("my-app" :: Text)])
@

@since 0.4.0.0
-}
materializeResourcesWithSchema :: Maybe String -> Resource -> MaterializedResources
materializeResourcesWithSchema schema (Resource _ attrs) = MaterializedResources schema attrs


{- | Override the schema URL on an already-materialized resource.
Replaces any previously set schema URL.

@since 0.4.0.0
-}
setMaterializedResourcesSchema :: Maybe String -> MaterializedResources -> MaterializedResources
setMaterializedResourcesSchema schema mr = mr {materializedResourcesSchema = schema}
