{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DefaultSignatures #-}
module OpenTelemetry.Resource where
import Data.Text (Text)
import Data.Int
import GHC.TypeLits

data AttributeLimits = AttributeLimits
  { attributeCountLimit :: Maybe Int
  , attributeLengthLimit :: Maybe Int
  }

class ToPrimitiveAttribute a where
  toPrimitiveAttribute :: a -> PrimitiveAttribute

data Attribute
  = AttributeValue PrimitiveAttribute
  | AttributeArray [PrimitiveAttribute]
  deriving (Show)

data PrimitiveAttribute
  = TextAttribute Text
  | BoolAttribute Bool
  | DoubleAttribute Double
  | IntAttribute Int64
  deriving (Show)

class ToAttribute a where
  toAttribute :: a -> Attribute
  default toAttribute :: ToPrimitiveAttribute a => a -> Attribute
  toAttribute = AttributeValue . toPrimitiveAttribute

instance ToPrimitiveAttribute Text where
  toPrimitiveAttribute = TextAttribute
instance ToAttribute Text

instance ToPrimitiveAttribute Bool where
  toPrimitiveAttribute = BoolAttribute
instance ToAttribute Bool

instance ToPrimitiveAttribute Double where
  toPrimitiveAttribute = DoubleAttribute
instance ToAttribute Double

instance ToPrimitiveAttribute Int64 where
  toPrimitiveAttribute = IntAttribute
instance ToAttribute Int64

instance ToPrimitiveAttribute a => ToAttribute [a] where
  toAttribute = AttributeArray . map toPrimitiveAttribute

newtype Resource (schema :: Maybe Symbol) = Resource [(Text, Attribute)]

instance (s ~ ResourceMerge s s) => Semigroup (Resource s) where
  (<>) = mergeResources

instance (s ~ ResourceMerge s s) => Monoid (Resource s) where
  mempty = Resource []

data ResourceCreationParameters = ResourceCreationParameters
  {
  }

createResource :: [(Text, Attribute)] -> ResourceCreationParameters -> Resource s
createResource attrs params = Resource attrs

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
mergeResources (Resource l) (Resource r) = Resource (l <> r)

-- TODO MUST implement
-- https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/resource/sdk.md#specifying-resource-information-via-an-environment-variable

class ResourceDetector d where
  type DetectedResource d :: Maybe Symbol
  detect :: d -> IO (Resource (DetectedResource d))
