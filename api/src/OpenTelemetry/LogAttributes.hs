{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE InstanceSigs #-}

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


{- | An attribute represents user-provided metadata about a span, link, or event.

 'Any' values are used in place of 'Standard Attributes' in logs because third-party
 logs may not conform to the 'Standard Attribute' format.

 Telemetry tools may use this data to support high-cardinality querying, visualization
 in waterfall diagrams, trace sampling decisions, and more.
-}
data AnyValue
  = TextValue Text
  | BoolValue Bool
  | DoubleValue Double
  | IntValue Int64
  | ByteStringValue ByteString
  | ArrayValue [AnyValue]
  | HashMapValue (H.HashMap Text AnyValue)
  deriving stock (Read, Show, Eq, Ord, Data, Generic)
  deriving anyclass (Hashable)


-- | Create a `TextAttribute` from the string value.
instance IsString AnyValue where
  fromString :: String -> AnyValue
  fromString = TextValue . fromString


{- | Convert a Haskell value to an 'Any' value.

 @

 data Foo = Foo

 instance ToValue Foo where
   toValue Foo = TextValue "Foo"

 @
-}
class ToValue a where
  toValue :: a -> AnyValue


instance ToValue Text where
  toValue :: Text -> AnyValue
  toValue = TextValue


instance ToValue Bool where
  toValue :: Bool -> AnyValue
  toValue = BoolValue


instance ToValue Double where
  toValue :: Double -> AnyValue
  toValue = DoubleValue


instance ToValue Int64 where
  toValue :: Int64 -> AnyValue
  toValue = IntValue


instance ToValue ByteString where
  toValue :: ByteString -> AnyValue
  toValue = ByteStringValue


instance (ToValue a) => ToValue [a] where
  toValue :: (ToValue a) => [a] -> AnyValue
  toValue = ArrayValue . fmap toValue


instance (ToValue a) => ToValue (H.HashMap Text a) where
  toValue :: (ToValue a) => H.HashMap Text a -> AnyValue
  toValue = HashMapValue . fmap toValue


instance ToValue AnyValue where
  toValue :: AnyValue -> AnyValue
  toValue = id


unsafeMergeLogAttributesIgnoringLimits :: LogAttributes -> LogAttributes -> LogAttributes
unsafeMergeLogAttributesIgnoringLimits (LogAttributes l lc ld) (LogAttributes r rc rd) = LogAttributes (l <> r) (lc + rc) (ld + rd)


unsafeLogAttributesFromListIgnoringLimits :: [(Text, AnyValue)] -> LogAttributes
unsafeLogAttributesFromListIgnoringLimits l = LogAttributes hm c 0
  where
    hm = H.fromList l
    c = H.size hm
