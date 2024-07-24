{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE DefaultSignatures #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE StrictData #-}

{- |
 Module      :  OpenTelemetry.Attributes
 Copyright   :  (c) Ian Duncan, 2021
 License     :  BSD-3
 Description :  Key-value pair metadata used in 'OpenTelemetry.Trace.Span's, 'OpenTelemetry.Trace.Link's, and 'OpenTelemetry.Trace.Event's
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)

 An Attribute is a key-value pair, which MUST have the following properties:

 - The attribute key MUST be a non-null and non-empty string.
 - The attribute value is either:
 - A primitive type: string, boolean, double precision floating point (IEEE 754-1985) or signed 64 bit integer.
 - An array of primitive type values. The array MUST be homogeneous, i.e., it MUST NOT contain values of different types. For protocols that do not natively support array values such values SHOULD be represented as JSON strings.
 - Attribute values expressing a numerical value of zero, an empty string, or an empty array are considered meaningful and MUST be stored and passed on to processors / exporters.
-}
module OpenTelemetry.Attributes (
  Attributes (attributesDropped),
  emptyAttributes,
  addAttribute,
  addAttributes,
  getAttributes,
  lookupAttribute,
  Attribute (..),
  ToAttribute (..),
  PrimitiveAttribute (..),
  ToPrimitiveAttribute (..),

  -- * Attribute limits
  AttributeLimits (..),
  defaultAttributeLimits,

  -- * Unsafe utilities
  unsafeAttributesFromListIgnoringLimits,
  unsafeMergeAttributesIgnoringLimits,
) where

import Data.Data (Data)
import qualified Data.HashMap.Strict as H
import Data.Hashable (Hashable)
import Data.Int (Int64)
import Data.String (IsString (..))
import Data.Text (Text)
import qualified Data.Text as T
import GHC.Generics (Generic)


{- | Default attribute limits used in the global attribute limit configuration if no environment variables are set.

 Values:

 - 'attributeCountLimit': @Just 128@
 - 'attributeLengthLimit':  or @Nothing@
-}
defaultAttributeLimits :: AttributeLimits
defaultAttributeLimits =
  AttributeLimits
    { attributeCountLimit = Just 128
    , attributeLengthLimit = Nothing
    }


data Attributes = Attributes
  { attributes :: !(H.HashMap Text Attribute)
  , attributesCount :: {-# UNPACK #-} !Int
  , attributesDropped :: {-# UNPACK #-} !Int
  }
  deriving stock (Show, Generic, Eq, Ord)


instance Hashable Attributes


emptyAttributes :: Attributes
emptyAttributes = Attributes mempty 0 0


addAttribute :: (ToAttribute a) => AttributeLimits -> Attributes -> Text -> a -> Attributes
addAttribute AttributeLimits {..} Attributes {..} !k !v = case attributeCountLimit of
  Nothing -> Attributes newAttrs newCount attributesDropped
  Just limit_ ->
    if newCount > limit_
      then Attributes attributes attributesCount (attributesDropped + 1)
      else Attributes newAttrs newCount attributesDropped
  where
    newAttrs = H.insert k (maybe id limitLengths attributeCountLimit $ toAttribute v) attributes
    newCount = H.size newAttrs
{-# INLINE addAttribute #-}


addAttributes :: (ToAttribute a) => AttributeLimits -> Attributes -> H.HashMap Text a -> Attributes
addAttributes AttributeLimits {..} Attributes {..} attrs = case attributeCountLimit of
  Nothing -> Attributes newAttrs newCount attributesDropped
  Just limit_ ->
    if newCount > limit_
      then Attributes attributes attributesCount (attributesDropped + H.size attrs)
      else Attributes newAttrs newCount attributesDropped
  where
    newAttrs = H.union attributes $ H.map toAttribute attrs
    newCount = H.size newAttrs
{-# INLINE addAttributes #-}


limitPrimAttr :: Int -> PrimitiveAttribute -> PrimitiveAttribute
limitPrimAttr limit (TextAttribute t) = TextAttribute (T.take limit t)
limitPrimAttr _ attr = attr


limitLengths :: Int -> Attribute -> Attribute
limitLengths limit (AttributeValue val) = AttributeValue $ limitPrimAttr limit val
limitLengths limit (AttributeArray arr) = AttributeArray $ fmap (limitPrimAttr limit) arr


getAttributes :: Attributes -> (Int, H.HashMap Text Attribute)
getAttributes Attributes {..} = (attributesCount, attributes)


lookupAttribute :: Attributes -> Text -> Maybe Attribute
lookupAttribute Attributes {..} k = H.lookup k attributes


{- | It is possible when adding attributes that a programming error might cause too many
 attributes to be added to an event. Thus, 'Attributes' use the limits set here as a safeguard
 against excessive memory consumption.
-}
data AttributeLimits = AttributeLimits
  { attributeCountLimit :: Maybe Int
  -- ^ The number of unique attributes that may be added to an 'Attributes' structure before they are dropped.
  , attributeLengthLimit :: Maybe Int
  -- ^ The maximum length of string attributes that may be set. Longer-length string values will be truncated to the
  -- specified amount.
  }
  deriving stock (Read, Show, Eq, Ord, Data, Generic)
  deriving anyclass (Hashable)


-- | Convert a Haskell value to a 'PrimitiveAttribute' value.
class ToPrimitiveAttribute a where
  toPrimitiveAttribute :: a -> PrimitiveAttribute


{- | An attribute represents user-provided metadata about a span, link, or event.

 Telemetry tools may use this data to support high-cardinality querying, visualization
 in waterfall diagrams, trace sampling decisions, and more.
-}
data Attribute
  = -- | An attribute representing a single primitive value
    AttributeValue PrimitiveAttribute
  | -- | An attribute representing an array of primitive values.
    --
    -- All values in the array MUST be of the same primitive attribute type.
    AttributeArray [PrimitiveAttribute]
  deriving stock (Read, Show, Eq, Ord, Data, Generic)
  deriving anyclass (Hashable)


{- | Create a `TextAttribute` from the string value.

 @since 0.0.2.1
-}
instance IsString PrimitiveAttribute where
  fromString = TextAttribute . fromString


{- | Create a `TextAttribute` from the string value.

 @since 0.0.2.1
-}
instance IsString Attribute where
  fromString = AttributeValue . fromString


data PrimitiveAttribute
  = TextAttribute Text
  | BoolAttribute Bool
  | DoubleAttribute Double
  | IntAttribute Int64
  deriving stock (Read, Show, Eq, Ord, Data, Generic)
  deriving anyclass (Hashable)


{- | Convert a Haskell value to an 'Attribute' value.

 For most values, you can define an instance of 'ToPrimitiveAttribute' and use the default 'toAttribute' implementation:

 @

 data Foo = Foo

 instance ToPrimitiveAttribute Foo where
   toPrimitiveAttribute Foo = TextAttribute "Foo"
 instance ToAttribute foo

 @
-}
class ToAttribute a where
  toAttribute :: a -> Attribute
  default toAttribute :: (ToPrimitiveAttribute a) => a -> Attribute
  toAttribute = AttributeValue . toPrimitiveAttribute


instance ToPrimitiveAttribute PrimitiveAttribute where
  toPrimitiveAttribute = id


instance ToAttribute PrimitiveAttribute where
  toAttribute = AttributeValue


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


instance ToPrimitiveAttribute Int where
  toPrimitiveAttribute = IntAttribute . fromIntegral


instance ToAttribute Int


instance ToAttribute Attribute where
  toAttribute = id


instance (ToPrimitiveAttribute a) => ToAttribute [a] where
  toAttribute = AttributeArray . map toPrimitiveAttribute


unsafeMergeAttributesIgnoringLimits :: Attributes -> Attributes -> Attributes
unsafeMergeAttributesIgnoringLimits (Attributes l lc ld) (Attributes r rc rd) = Attributes (l <> r) (lc + rc) (ld + rd)


unsafeAttributesFromListIgnoringLimits :: [(Text, Attribute)] -> Attributes
unsafeAttributesFromListIgnoringLimits l = Attributes hm c 0
  where
    hm = H.fromList l
    c = H.size hm
