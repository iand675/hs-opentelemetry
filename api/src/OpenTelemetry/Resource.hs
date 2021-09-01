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

newtype Resource (s :: Maybe Symbol) = Resource [(Text, Attribute)]

instance (s ~ ResourceMerge s s) => Semigroup (Resource s) where
  (<>) = mergeResources

instance (s ~ ResourceMerge s s) => Monoid (Resource s) where
  mempty = Resource []

data ResourceCreationParameters = ResourceCreationParameters
  {
  }

createResource :: [(Text, Attribute)] -> ResourceCreationParameters -> Resource s
createResource attrs params = Resource attrs

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
