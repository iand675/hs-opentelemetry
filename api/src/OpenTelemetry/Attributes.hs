{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE DefaultSignatures #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveLift #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE RankNTypes #-}
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
  addAttributesFromBuilder,
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
  AttributeKey (..),
  module Key,

  -- * Attribute builder
  AttrsBuilder,
  attr,
  optAttr,
  (.@),
  (.@?),
  buildAttrs,

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
import Data.Maybe (isJust)
import Data.Text (Text)
import qualified Data.Text as T
import GHC.Generics (Generic)
import qualified Language.Haskell.TH.Syntax as TH
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
  deriving stock (Show, Generic, Eq, Ord, TH.Lift)


instance Hashable Attributes


emptyAttributes :: Attributes
emptyAttributes = Attributes mempty 0 0
{-# INLINE emptyAttributes #-}


addAttribute :: (ToAttribute a) => AttributeLimits -> Attributes -> Text -> a -> Attributes
addAttribute AttributeLimits {..} Attributes {..} !k !v =
  let !attr = maybe id limitLengths attributeLengthLimit $! toAttribute v
      (!replacing, !newAttrs) = H.alterF (\old -> (isJust old, Just attr)) k attributeMap
      !newCount = if replacing then attributesCount else attributesCount + 1
  in case attributeCountLimit of
      Nothing -> Attributes newAttrs newCount attributesDropped
      Just limit_ ->
        if not replacing && newCount > limit_
          then Attributes attributeMap attributesCount (attributesDropped + 1)
          else Attributes newAttrs newCount attributesDropped
{-# INLINE [0] addAttribute #-}


addAttributeByKey :: (ToAttribute a) => AttributeLimits -> Attributes -> AttributeKey a -> a -> Attributes
addAttributeByKey limits attrs (AttributeKey k) !v = addAttribute limits attrs k v
{-# INLINE addAttributeByKey #-}


-- Fuse two nested pure addAttribute calls into a single addAttributesFromBuilder pass.
-- Two H.alterF → one fold. Only fires in phases ≥1 (before addAttribute inlines in phase 0).
{-# RULES
"addAttribute/addAttribute" forall lim attrs k1 v1 k2 v2.
  addAttribute lim (addAttribute lim attrs k1 v1) k2 v2 =
    addAttributesFromBuilder lim attrs (attr k1 v1 <> attr k2 v2)
  #-}


addAttributes :: (ToAttribute a) => AttributeLimits -> Attributes -> H.HashMap Text a -> Attributes
addAttributes AttributeLimits {..} Attributes {..} attrs
  | H.null attrs = Attributes attributeMap attributesCount attributesDropped
  | otherwise =
      let convertVal = maybe id limitLengths attributeLengthLimit . toAttribute
      in case attributeCountLimit of
          Nothing ->
            let (!newAttrs, !added) =
                  H.foldlWithKey'
                    (\(!m, !n) k v -> let !m' = H.insert k (convertVal v) m in (m', if H.member k attributeMap then n else n + 1))
                    (attributeMap, 0 :: Int)
                    attrs
                !newCount = attributesCount + added
            in Attributes newAttrs newCount attributesDropped
          Just limit_ ->
            let (!merged, !accepted, !totalNew) =
                  H.foldlWithKey'
                    ( \(!m, !n, !seen) k v ->
                        if H.member k attributeMap
                          then (H.insert k (convertVal v) m, n, seen)
                          else
                            if n < limit_
                              then (H.insert k (convertVal v) m, n + 1, seen + 1)
                              else (m, n, seen + 1)
                    )
                    (attributeMap, attributesCount, 0 :: Int)
                    attrs
                !newKeys = accepted - attributesCount
                !dropped = totalNew - newKeys
            in Attributes merged accepted (attributesDropped + dropped)
{-# INLINE addAttributes #-}


{- | Like 'addAttributes', but consumes an 'AttrsBuilder' instead of a 'HashMap'.
Folds each attribute directly into the existing 'Attributes' without allocating
an intermediate collection.
-}
addAttributesFromBuilder :: AttributeLimits -> Attributes -> AttrsBuilder -> Attributes
addAttributesFromBuilder AttributeLimits {..} as@Attributes {..} (AttrsBuilder fold) =
  let limitVal = maybe id limitLengths attributeLengthLimit
  in case attributeCountLimit of
      Nothing ->
        let (!newMap, !added) = fold (\(!m, !n) k v -> (H.insert k (limitVal v) m, if H.member k m then n else n + 1)) (attributeMap, 0 :: Int)
            !newCount = attributesCount + added
        in Attributes newMap newCount attributesDropped
      Just limit_ ->
        let step (!m, !cnt, !drp) !k !v =
              let !a = limitVal v
              in if H.member k m
                  then (H.insert k a m, cnt, drp)
                  else
                    if cnt < limit_
                      then (H.insert k a m, cnt + 1, drp)
                      else (m, cnt, drp + 1)
            (!newMap, !newCount, !newDropped) = fold step (attributeMap, attributesCount, attributesDropped)
        in Attributes newMap newCount newDropped
{-# INLINE addAttributesFromBuilder #-}


-- Eliminate no-ops at compile time.
{-# RULES
"addAttributesFromBuilder/mempty" forall lim attrs.
  addAttributesFromBuilder lim attrs mempty = attrs
  #-}


{- | Church-encoded left fold over attribute key-value pairs. Avoids allocating
intermediate tuples, list spines, or 'HashMap's when adding multiple
attributes to a span.

Construct individual entries with 'attr' \/ '.@' and combine with '<>'.
GHC can inline and fuse static builder expressions, eliminating all
intermediate allocation.

@
'addAttributes'' span $
    SC.http_request_method '.@' method
 <> SC.url_full '.@' url
 <> SC.server_port '.@?' mPort
@
-}
newtype AttrsBuilder = AttrsBuilder
  { foldAttrsBuilder :: forall r. (r -> Text -> Attribute -> r) -> r -> r
  }


instance Semigroup AttrsBuilder where
  AttrsBuilder f <> AttrsBuilder g = AttrsBuilder (\step z -> g step (f step z))
  {-# INLINE (<>) #-}


instance Monoid AttrsBuilder where
  mempty = AttrsBuilder (\_ z -> z)
  {-# INLINE mempty #-}


{- | Build an attribute entry from a 'Text' key. The value is converted
to 'Attribute' eagerly via 'toAttribute'.
-}
attr :: (ToAttribute a) => Text -> a -> AttrsBuilder
attr !k v = let !a = toAttribute v in AttrsBuilder (\step z -> step z k a)
{-# INLINE attr #-}


{- | Build an optional attribute entry. 'Nothing' contributes nothing
to the builder (zero cost).
-}
optAttr :: (ToAttribute a) => Text -> Maybe a -> AttrsBuilder
optAttr _ Nothing = mempty
optAttr !k (Just v) = attr k v
{-# INLINE optAttr #-}


{- | Build an attribute entry from a typed 'AttributeKey'. Type-safe:
the value type must match the key's phantom type.

@
SC.http_request_method '.@' ("GET" :: Text)
@
-}
(.@) :: (ToAttribute a) => AttributeKey a -> a -> AttrsBuilder
(AttributeKey !k) .@ v = attr k v
{-# INLINE (.@) #-}


infixl 8 .@


{- | Build an optional attribute entry from a typed 'AttributeKey'.
'Nothing' contributes nothing to the builder.
-}
(.@?) :: (ToAttribute a) => AttributeKey a -> Maybe a -> AttrsBuilder
_ .@? Nothing = mempty
(AttributeKey !k) .@? (Just v) = attr k v
{-# INLINE (.@?) #-}


infixl 8 .@?


{- | Materialize a builder into an 'Map.AttributeMap'. Useful when a raw
'HashMap' is needed (e.g. for 'NewEvent' attributes or 'SpanArguments').
-}
buildAttrs :: AttrsBuilder -> Map.AttributeMap
buildAttrs (AttrsBuilder f) = f (\m k v -> H.insert k v m) H.empty
{-# INLINE buildAttrs #-}


limitPrimAttr :: Int -> PrimitiveAttribute -> PrimitiveAttribute
limitPrimAttr limit (TextAttribute t) = TextAttribute (T.take limit t)
limitPrimAttr _ attr = attr


limitLengths :: Int -> Attribute -> Attribute
limitLengths limit (AttributeValue val) = AttributeValue $ limitPrimAttr limit val
limitLengths limit (AttributeArray arr) = AttributeArray $ fmap (limitPrimAttr limit) arr


getAttributeMap :: Attributes -> Map.AttributeMap
getAttributeMap Attributes {..} = attributeMap
{-# INLINE getAttributeMap #-}


getCount :: Attributes -> Int
getCount Attributes {..} = attributesCount
{-# INLINE getCount #-}


getDropped :: Attributes -> Int
getDropped Attributes {..} = attributesDropped
{-# INLINE getDropped #-}


lookupAttribute :: Attributes -> Text -> Maybe Attribute
lookupAttribute Attributes {..} k = H.lookup k attributeMap
{-# INLINE lookupAttribute #-}


lookupAttributeByKey :: FromAttribute a => Attributes -> AttributeKey a -> Maybe a
lookupAttributeByKey Attributes {..} k = Map.lookupByKey k attributeMap
{-# INLINABLE lookupAttributeByKey #-}


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
