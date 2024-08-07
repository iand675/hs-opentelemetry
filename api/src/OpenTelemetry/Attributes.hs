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
  Attributes,
  emptyAttributes,
  addAttribute,
  addAttributeByKey,
  addAttributes,
  lookupAttribute,
  lookupAttributeByKey,
  getAttributeMap,
  getCount,
  getDropped,
  Attribute (..),
  ToAttribute (..),
  FromAttribute (..),
  PrimitiveAttribute (..),
  ToPrimitiveAttribute (..),
  FromPrimitiveAttribute (..),
  Map.AttributeMap,
  Key (..),
  module Key,

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
import Data.Text (Text)
import qualified Data.Text as T
import GHC.Generics (Generic)
import OpenTelemetry.Attributes.Attribute (Attribute (..), FromAttribute (..), FromPrimitiveAttribute (..), PrimitiveAttribute (..), ToAttribute (..), ToPrimitiveAttribute (..))
import OpenTelemetry.Attributes.Key as Key
import qualified OpenTelemetry.Attributes.Map as Map


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
  { attributeMap :: !Map.AttributeMap
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
      then Attributes attributeMap attributesCount (attributesDropped + 1)
      else Attributes newAttrs newCount attributesDropped
  where
    newAttrs = H.insert k (maybe id limitLengths attributeLengthLimit $ toAttribute v) attributeMap
    newCount = H.size newAttrs
{-# INLINE addAttribute #-}


addAttributeByKey :: (ToAttribute a) => AttributeLimits -> Attributes -> Key a -> a -> Attributes
addAttributeByKey limits attrs (Key k) !v = addAttribute limits attrs k v


addAttributes :: (ToAttribute a) => AttributeLimits -> Attributes -> H.HashMap Text a -> Attributes
addAttributes AttributeLimits {..} Attributes {..} attrs = case attributeCountLimit of
  Nothing -> Attributes newAttrs newCount attributesDropped
  Just limit_ ->
    if newCount > limit_
      then Attributes attributeMap attributesCount (attributesDropped + H.size attrs)
      else Attributes newAttrs newCount attributesDropped
  where
    newAttrs = H.union attributeMap $ H.map (maybe id limitLengths attributeLengthLimit . toAttribute) attrs
    newCount = H.size newAttrs
{-# INLINE addAttributes #-}


limitPrimAttr :: Int -> PrimitiveAttribute -> PrimitiveAttribute
limitPrimAttr limit (TextAttribute t) = TextAttribute (T.take limit t)
limitPrimAttr _ attr = attr


limitLengths :: Int -> Attribute -> Attribute
limitLengths limit (AttributeValue val) = AttributeValue $ limitPrimAttr limit val
limitLengths limit (AttributeArray arr) = AttributeArray $ fmap (limitPrimAttr limit) arr


getAttributeMap :: Attributes -> Map.AttributeMap
getAttributeMap Attributes {..} = attributeMap


getCount :: Attributes -> Int
getCount Attributes {..} = attributesCount


getDropped :: Attributes -> Int
getDropped Attributes {..} = attributesDropped


lookupAttribute :: Attributes -> Text -> Maybe Attribute
lookupAttribute Attributes {..} k = H.lookup k attributeMap


lookupAttributeByKey :: FromAttribute a => Attributes -> Key a -> Maybe a
lookupAttributeByKey Attributes {..} k = Map.lookupByKey k attributeMap


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


-- | Left-biased merge.
unsafeMergeAttributesIgnoringLimits :: Attributes -> Attributes -> Attributes
unsafeMergeAttributesIgnoringLimits left right = Attributes hm c d
  where
    hm = attributeMap left <> attributeMap right
    c = H.size hm
    d = attributesDropped left + attributesDropped right


unsafeAttributesFromListIgnoringLimits :: [(Text, Attribute)] -> Attributes
unsafeAttributesFromListIgnoringLimits l = Attributes hm c 0
  where
    hm = H.fromList l
    c = H.size hm
