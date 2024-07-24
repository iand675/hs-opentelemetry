{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DefaultSignatures #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}

-----------------------------------------------------------------------------

-----------------------------------------------------------------------------

{- |
 Module      :  OpenTelemetry.Resource
 Copyright   :  (c) Ian Duncan, 2021
 License     :  BSD-3
 Description :  Facilities for attaching metadata attributes to all spans in a trace
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)

 A Resource is an immutable representation of the entity producing
 telemetry. For example, a process producing telemetry that is running in
 a container on Kubernetes has a Pod name, it is in a namespace and
 possibly is part of a Deployment which also has a name. All three of
 these attributes can be included in the Resource.
-}
module OpenTelemetry.Resource (
  -- * Creating resources directly
  mkResource,
  Resource,
  (.=),
  (.=?),
  ResourceMerge,
  mergeResources,

  -- * Creating resources from data structures
  ToResource (..),
  materializeResources,

  -- * Using resources with a 'OpenTelemetry.Trace.TracerProvider'
  MaterializedResources,
  emptyMaterializedResources,
  getMaterializedResourcesSchema,
  getMaterializedResourcesAttributes,
) where

import Data.Maybe (catMaybes)
import Data.Proxy (Proxy (..))
import Data.Text (Text)
import GHC.TypeLits
import OpenTelemetry.Attributes


{- | A set of attributes created from one or more resources.

 A Resource is an immutable representation of the entity producing telemetry as Attributes.
 For example, a process producing telemetry that is running in a container on Kubernetes has a Pod name,
 it is in a namespace and possibly is part of a Deployment which also has a name.

 All three of these attributes can be included in the Resource.

 Note that there are certain <https://github.com/open-telemetry/opentelemetry-specification/blob/34144d02baaa39f7aa97ee914539089e1481166c/specification/resource/semantic_conventions/README.md "standard attributes"> that have prescribed meanings.

 A number of these standard resources may be found in the @OpenTelemetry.Resource.*@ modules.

 The primary purpose of resources as a first-class concept in the SDK is decoupling of discovery of resource information from exporters.
 This allows for independent development and easy customization for users that need to integrate with closed source environments.
-}
newtype Resource (schema :: Maybe Symbol) = Resource Attributes


{- | Utility function to create a resource from a list
 of fields and attributes. See the '.=' and '.=?' functions.

 @since 0.0.1.0
-}
mkResource :: [Maybe (Text, Attribute)] -> Resource r
mkResource = Resource . unsafeAttributesFromListIgnoringLimits . catMaybes


{- | Utility function to convert a required resource attribute
 into the format needed for 'mkResource'.
-}
(.=) :: (ToAttribute a) => Text -> a -> Maybe (Text, Attribute)
k .= v = Just (k, toAttribute v)


{- | Utility function to convert an optional resource attribute
 into the format needed for 'mkResource'.
-}
(.=?) :: (ToAttribute a) => Text -> Maybe a -> Maybe (Text, Attribute)
k .=? mv = (\k' v -> (k', toAttribute v)) k <$> mv


instance Semigroup (Resource s) where
  (<>) (Resource l) (Resource r) = Resource (unsafeMergeAttributesIgnoringLimits l r)


instance Monoid (Resource s) where
  mempty = Resource emptyAttributes


{- | Static checks to prevent invalid resources from being merged.

 Note: This is intended to be utilized for merging of resources whose attributes
 come from different sources,
 such as environment variables, or metadata extracted from the host or container.

 The resulting resource will have all attributes that are on any of the two input resources.
 If a key exists on both the old and updating resource, the value of the updating
 resource will be picked (even if the updated value is "empty").

 The resulting resource will have the Schema URL calculated as follows:

 - If the old resource's Schema URL is empty then the resulting resource's Schema
   URL will be set to the Schema URL of the updating resource,
 - Else if the updating resource's Schema URL is empty then the resulting
   resource's Schema URL will be set to the Schema URL of the old resource,
 - Else if the Schema URLs of the old and updating resources are the same then
   that will be the Schema URL of the resulting resource,
 - Else this is a merging error (this is the case when the Schema URL of the old
   and updating resources are not empty and are different). The resulting resource is
   therefore statically prohibited by this type-level function.
-}
type family ResourceMerge schemaLeft schemaRight :: Maybe Symbol where
  ResourceMerge 'Nothing 'Nothing = 'Nothing
  ResourceMerge 'Nothing ('Just s) = 'Just s
  ResourceMerge ('Just s) 'Nothing = 'Just s
  ResourceMerge ('Just s) ('Just s) = 'Just s


{- | Combine two 'Resource' values into a new 'Resource' that contains the
 attributes of the two inputs.

 See the 'ResourceMerge' documentation about the additional semantics of merging two resources.

 @since 0.0.1.0
-}
mergeResources
  :: Resource old
  -- ^ the old resource
  -> Resource new
  -- ^ the updating resource whose attributes take precedence
  -> Resource (ResourceMerge old new)
mergeResources (Resource l) (Resource r) = Resource (unsafeMergeAttributesIgnoringLimits l r)


-- | A convenience class for converting arbitrary data into resources.
class ToResource a where
  -- | Resource schema (if any) associated with the defined resource
  type ResourceSchema a :: Maybe Symbol


  type ResourceSchema a = 'Nothing


  -- | Convert the input value to a 'Resource'
  toResource :: a -> Resource (ResourceSchema a)


class MaterializeResource schema where
  -- | Convert resource fields into a version that discharges the schema from the
  -- type level to the runtime level.
  materializeResources :: Resource schema -> MaterializedResources


instance MaterializeResource 'Nothing where
  materializeResources (Resource attrs) = MaterializedResources Nothing attrs


instance (KnownSymbol s) => MaterializeResource ('Just s) where
  materializeResources (Resource attrs) = MaterializedResources (Just $ symbolVal (Proxy @s)) attrs


-- | A read-only resource attribute collection with an associated schema.
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
