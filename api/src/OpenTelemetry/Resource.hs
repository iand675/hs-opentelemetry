{-# LANGUAGE DataKinds #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DefaultSignatures #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  OpenTelemetry.Resource
-- Copyright   :  (c) Ian Duncan, 2021
-- License     :  BSD-3
-- Description :  Facilities for attaching metadata attributes to all spans in a trace
-- Maintainer  :  Ian Duncan
-- Stability   :  experimental
-- Portability :  non-portable (GHC extensions)
--
-- A Resource is an immutable representation of the entity producing
-- telemetry. For example, a process producing telemetry that is running in
-- a container on Kubernetes has a Pod name, it is in a namespace and
-- possibly is part of a Deployment which also has a name. All three of
-- these attributes can be included in the Resource.
--
-----------------------------------------------------------------------------
module OpenTelemetry.Resource 
  ( mkResource
  , Resource
  , (.=)
  , (.=?)
  , ResourceMerge
  , mergeResources
  , ToResource(..)
  , MaterializeResource
  , materializeResources
  , MaterializedResources
  , emptyMaterializedResources
  , getMaterializedResourcesSchema
  , getMaterializedResourcesAttributes
  ) where

import Data.Proxy (Proxy(..))
import Data.Text (Text)
import GHC.TypeLits
import Data.Maybe (catMaybes)
import OpenTelemetry.Attributes

newtype Resource (schema :: Maybe Symbol) = Resource Attributes

-- resourceAttributes :: Resource s -> Attributes
-- resourceAttributes (Resource attrs) = attrs

-- Utility function to create a resource from a list
-- of fields and attributes. See the '.=' and '.=?' functions.
--
-- @since 0.0.1.0
mkResource :: [Maybe (Text, Attribute)] -> Resource r
mkResource = Resource . unsafeAttributesFromListIgnoringLimits . catMaybes

-- | Utility function to convert a required resource attribute
-- into the format needed for 'mkResource'.
(.=) :: ToAttribute a => Text -> a -> Maybe (Text, Attribute)
k .= v = Just (k, toAttribute v)

-- | Utility function to convert an optional resource attribute
-- into the format needed for 'mkResource'.
(.=?) :: ToAttribute a => Text -> Maybe a -> Maybe (Text, Attribute)
k .=? mv = (\k' v -> (k', toAttribute v)) k <$> mv
instance Semigroup (Resource s) where
  (<>) (Resource l) (Resource r) = Resource (unsafeMergeAttributesIgnoringLimits l r)

instance Monoid (Resource s) where
  mempty = Resource emptyAttributes

-- data ResourceCreationParameters = ResourceCreationParameters
--   {
--   }

-- Create a resource from list of attributes.
-- createResource :: Attributes -> ResourceCreationParameters -> Resource s
-- createResource attrs _params = Resource attrs

-- | Static checks to prevent invalid resources from being merged.
--
-- According to the OpenTelemetry specification:
--
-- The interface MUST provide a way for an old resource and an
-- updating resource to be merged into a new resource.
--
-- Note: This is intended to be utilized for merging of resources whose attributes
-- come from different sources,
-- such as environment variables, or metadata extracted from the host or container.
--
-- The resulting resource MUST have all attributes that are on any of the two input resources.
-- If a key exists on both the old and updating resource, the value of the updating
-- resource MUST be picked (even if the updated value is empty).
--
-- The resulting resource will have the Schema URL calculated as follows:
--
-- - If the old resource's Schema URL is empty then the resulting resource's Schema
--   URL will be set to the Schema URL of the updating resource,
-- - Else if the updating resource's Schema URL is empty then the resulting
--   resource's Schema URL will be set to the Schema URL of the old resource,
-- - Else if the Schema URLs of the old and updating resources are the same then
--   that will be the Schema URL of the resulting resource,
-- - Else this is a merging error (this is the case when the Schema URL of the old
--   and updating resources are not empty and are different). The resulting resource is
--   undefined, and its contents are implementation-specific.
--
-- Required parameters:
--
-- - the old resource
-- - the updating resource whose attributes take precedence
type family ResourceMerge schemaLeft schemaRight :: Maybe Symbol where
  ResourceMerge 'Nothing 'Nothing = 'Nothing
  ResourceMerge 'Nothing ('Just s) = 'Just s
  ResourceMerge ('Just s) 'Nothing = 'Just s
  ResourceMerge ('Just s) ('Just s) = 'Just s

mergeResources :: Resource l -> Resource r -> Resource (ResourceMerge l r)
mergeResources (Resource l) (Resource r) = Resource (unsafeMergeAttributesIgnoringLimits l r)

class ToResource a where
  type ResourceSchema a :: Maybe Symbol
  toResource :: a -> Resource (ResourceSchema a)

class MaterializeResource o where
  materializeResources :: Resource o -> MaterializedResources

instance MaterializeResource 'Nothing where
  materializeResources (Resource attrs) = MaterializedResources Nothing attrs

instance KnownSymbol s => MaterializeResource ('Just s) where
  materializeResources (Resource attrs) = MaterializedResources (Just $ symbolVal (Proxy @s)) attrs

data MaterializedResources = MaterializedResources
  { materializedResourcesSchema :: Maybe String
  , materializedResourcesAttributes :: Attributes
  }

emptyMaterializedResources :: MaterializedResources
emptyMaterializedResources = MaterializedResources Nothing emptyAttributes

getMaterializedResourcesSchema :: MaterializedResources -> Maybe String
getMaterializedResourcesSchema = materializedResourcesSchema

getMaterializedResourcesAttributes :: MaterializedResources -> Attributes
getMaterializedResourcesAttributes = materializedResourcesAttributes
