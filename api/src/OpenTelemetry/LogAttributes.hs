{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE FlexibleInstances #-}

module OpenTelemetry.LogAttributes (
  LogAttributes (..),
  emptyAttributes,
  addAttribute,
  addAttributes,
  getAttributes,
  lookupAttribute,
  AnyValue (..),
  ToValue (..),

  -- * Attribute limits
  AttributeLimits (..),
  defaultAttributeLimits,

  -- * unsafe utilities
  unsafeLogAttributesFromListIgnoringLimits,
  unsafeMergeLogAttributesIgnoringLimits,
) where

import Data.ByteString (ByteString)
import Data.Data (Data)
import qualified Data.HashMap.Strict as H
import Data.Hashable (Hashable)
import Data.Int (Int64)
import Data.String (IsString (..))
import Data.Text (Text)
import qualified Data.Text as T
import GHC.Generics (Generic)
import OpenTelemetry.Attributes (AttributeLimits (..), defaultAttributeLimits)
import OpenTelemetry.Internal.Common.Types


data LogAttributes = LogAttributes
  { attributes :: !(H.HashMap Text AnyValue)
  , attributesCount :: {-# UNPACK #-} !Int
  , attributesDropped :: {-# UNPACK #-} !Int
  }
  deriving stock (Show, Eq)


emptyAttributes :: LogAttributes
emptyAttributes = LogAttributes mempty 0 0


addAttribute :: (ToValue a) => AttributeLimits -> LogAttributes -> Text -> a -> LogAttributes
addAttribute AttributeLimits {..} LogAttributes {..} !k !v = case attributeCountLimit of
  Nothing -> LogAttributes newAttrs newCount attributesDropped
  Just limit_ ->
    if newCount > limit_
      then LogAttributes attributes attributesCount (attributesDropped + 1)
      else LogAttributes newAttrs newCount attributesDropped
  where
    newAttrs = H.insert k (maybe id limitLengths attributeCountLimit $ toValue v) attributes
    newCount = H.size newAttrs
{-# INLINE addAttribute #-}


addAttributes :: (ToValue a) => AttributeLimits -> LogAttributes -> H.HashMap Text a -> LogAttributes
addAttributes AttributeLimits {..} LogAttributes {..} attrs = case attributeCountLimit of
  Nothing -> LogAttributes newAttrs newCount attributesDropped
  Just limit_ ->
    if newCount > limit_
      then LogAttributes attributes attributesCount (attributesDropped + H.size attrs)
      else LogAttributes newAttrs newCount attributesDropped
  where
    newAttrs = H.union attributes $ H.map toValue attrs
    newCount = H.size newAttrs
{-# INLINE addAttributes #-}


getAttributes :: LogAttributes -> (Int, H.HashMap Text AnyValue)
getAttributes LogAttributes {..} = (attributesCount, attributes)


lookupAttribute :: LogAttributes -> Text -> Maybe AnyValue
lookupAttribute LogAttributes {..} k = H.lookup k attributes


limitLengths :: Int -> AnyValue -> AnyValue
limitLengths limit (TextValue t) = TextValue (T.take limit t)
limitLengths limit (ArrayValue arr) = ArrayValue $ fmap (limitLengths limit) arr
limitLengths limit (HashMapValue h) = HashMapValue $ fmap (limitLengths limit) h
limitLengths _ val = val


unsafeMergeLogAttributesIgnoringLimits :: LogAttributes -> LogAttributes -> LogAttributes
unsafeMergeLogAttributesIgnoringLimits (LogAttributes l lc ld) (LogAttributes r rc rd) = LogAttributes (l <> r) (lc + rc) (ld + rd)


unsafeLogAttributesFromListIgnoringLimits :: [(Text, AnyValue)] -> LogAttributes
unsafeLogAttributesFromListIgnoringLimits l = LogAttributes hm c 0
  where
    hm = H.fromList l
    c = H.size hm
