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
Copyright   :  (c) Ian Duncan, 2021-2026
License     :  BSD-3
Description :  Key-value pair metadata for spans, events, links, and resources
Stability   :  experimental

= Overview

Attributes are key-value pairs attached to spans, events, links, and
resources. Keys are 'Text' strings; values are one of the OpenTelemetry
primitive types: 'Text', 'Bool', 'Int64', 'Double', or arrays thereof.

= Quick example

@
import OpenTelemetry.Attributes

-- On a span:
addAttribute span "http.request.method" (toAttribute "GET")
addAttribute span "http.response.status_code" (toAttribute (200 :: Int))
addAttributes span
  [ ("user.id", toAttribute "abc123")
  , ("user.role", toAttribute "admin")
  ]

-- Using the builder API:
let attrs = buildAttrs $
      attr "http.request.method" ("GET" :: Text)
      <> attr "http.response.status_code" (200 :: Int)
@

= Typed attribute keys

For type-safe attribute access, use 'AttributeKey':

@
import OpenTelemetry.Attributes.Key (AttributeKey(..), unkey)
import qualified OpenTelemetry.SemanticConventions as SC

let attrs' = addAttributeByKey defaultAttributeLimits attrs SC.http_request_method "GET"
lookupAttributeByKey attrs' SC.http_response_statusCode  -- Maybe Int64
@

= Attribute limits

The SDK enforces limits on attribute count and value length, configured via
@OTEL_ATTRIBUTE_COUNT_LIMIT@ and @OTEL_ATTRIBUTE_VALUE_LENGTH_LIMIT@
environment variables. When limits are exceeded, attributes are dropped
(tracked by 'getDropped').

= Spec reference

<https://opentelemetry.io/docs/specs/otel/common/#attribute>
-}
module OpenTelemetry.Attributes (
  Attributes,
  emptyAttributes,
  unsafeAttributesFromMap,
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
  unsafeAttributesFromMapIgnoringLimits,
  unsafeMergeAttributesIgnoringLimits,
) where

import Data.Data (Data)
import qualified Data.HashMap.Lazy as H
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

@since 0.0.1.0
-}
defaultAttributeLimits :: AttributeLimits
defaultAttributeLimits =
  AttributeLimits
    { attributeCountLimit = Just 128
    , attributeLengthLimit = Nothing
    }


-- | @since 0.0.1.0
data Attributes = Attributes
  { attributeMap :: !Map.AttributeMap
  , attributesCount :: {-# UNPACK #-} !Int
  , attributesDropped :: {-# UNPACK #-} !Int
  }
  deriving stock (Show, Generic, Eq, Ord, TH.Lift)


instance Hashable Attributes


-- | @since 0.0.1.0
emptyAttributes :: Attributes
emptyAttributes = Attributes mempty 0 0
{-# INLINE emptyAttributes #-}


{- | Build 'Attributes' directly from a pre-built 'AttributeMap', applying
count and length limits. Faster than @addAttributes limits emptyAttributes map@
because it skips the per-key membership check against an empty base map.

@since 0.4.0.0
-}
unsafeAttributesFromMap :: AttributeLimits -> Map.AttributeMap -> Attributes
unsafeAttributesFromMap AttributeLimits {..} m =
  let limitVal = case attributeLengthLimit of
        Nothing -> id
        Just limit -> limitLengths limit
  in case attributeCountLimit of
      Nothing ->
        let !m' = case attributeLengthLimit of
              Nothing -> m
              Just _ -> H.map limitVal m
        in Attributes m' (H.size m) 0
      Just limit_ ->
        let !sz = H.size m
        in if sz <= limit_
            then
              let !m' = case attributeLengthLimit of
                    Nothing -> m
                    Just _ -> H.map limitVal m
              in Attributes m' sz 0
            else
              let (!kept, !dropped) = H.foldlWithKey'
                    (\(!acc, !d) k v ->
                      if H.size acc < limit_
                        then (H.insert k (limitVal v) acc, d)
                        else (acc, d + 1))
                    (H.empty, 0)
                    m
              in Attributes kept (H.size kept) dropped
{-# INLINE unsafeAttributesFromMap #-}


-- | @since 0.0.1.0
addAttribute :: (ToAttribute a) => AttributeLimits -> Attributes -> Text -> a -> Attributes
addAttribute AttributeLimits {..} Attributes {..} !k v =
  let attr = case attributeLengthLimit of
        Nothing -> toAttribute v
        Just limit -> limitLengths limit (toAttribute v)
      (!replacing, !newAttrs) = H.alterF (\old -> (isJust old, Just attr)) k attributeMap
      !newCount = if replacing then attributesCount else attributesCount + 1
  in case attributeCountLimit of
      Nothing -> Attributes newAttrs newCount attributesDropped
      Just limit_ ->
        if not replacing && newCount > limit_
          then Attributes attributeMap attributesCount (attributesDropped + 1)
          else Attributes newAttrs newCount attributesDropped
{-# INLINE [0] addAttribute #-}


-- | @since 0.0.1.0
addAttributeByKey :: (ToAttribute a) => AttributeLimits -> Attributes -> AttributeKey a -> a -> Attributes
addAttributeByKey limits attrs (AttributeKey k) v = addAttribute limits attrs k v
{-# INLINE addAttributeByKey #-}


-- Fuse two nested pure addAttribute calls into a single addAttributesFromBuilder pass.
-- Two H.alterF to one fold. Only fires in phases >=1 (before addAttribute inlines in phase 0).
{-# RULES
"addAttribute/addAttribute" forall lim attrs k1 v1 k2 v2.
  addAttribute lim (addAttribute lim attrs k1 v1) k2 v2 =
    addAttributesFromBuilder lim attrs (attr k1 v1 <> attr k2 v2)
  #-}


-- | @since 0.0.1.0
addAttributes :: (ToAttribute a) => AttributeLimits -> Attributes -> H.HashMap Text a -> Attributes
addAttributes AttributeLimits {..} Attributes {..} attrs
  | H.null attrs = Attributes attributeMap attributesCount attributesDropped
  | otherwise =
      let convertVal = case attributeLengthLimit of
            Nothing -> toAttribute
            Just limit -> limitLengths limit . toAttribute
      in case attributeCountLimit of
          Nothing ->
            let (!newAttrs, !added) =
                  H.foldlWithKey'
                    (\(!m, !n) k v -> (H.insert k (convertVal v) m, if H.member k attributeMap then n else n + 1))
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

@since 0.4.0.0
-}
addAttributesFromBuilder :: AttributeLimits -> Attributes -> AttrsBuilder -> Attributes
addAttributesFromBuilder AttributeLimits {..} _as@Attributes {..} (AttrsBuilder fold) =
  let limitVal = case attributeLengthLimit of
        Nothing -> id
        Just limit -> limitLengths limit
  in case attributeCountLimit of
      Nothing ->
        let (!newMap, !added) = fold (\(!m, !n) k v -> (H.insert k (limitVal v) m, if H.member k m then n else n + 1)) (attributeMap, 0 :: Int)
            !newCount = attributesCount + added
        in Attributes newMap newCount attributesDropped
      Just limit_ ->
        let step (!m, !cnt, !drp) !k v =
              let a = limitVal v
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
  addAttributesFromBuilder lim attrs mempty =
    attrs
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

@since 0.4.0.0
-}
newtype AttrsBuilder = AttrsBuilder (forall r. (r -> Text -> Attribute -> r) -> r -> r)


instance Semigroup AttrsBuilder where
  AttrsBuilder f <> AttrsBuilder g = AttrsBuilder (\step z -> g step (f step z))
  {-# INLINE (<>) #-}


instance Monoid AttrsBuilder where
  mempty = AttrsBuilder (\_ z -> z)
  {-# INLINE mempty #-}


{- | Build an attribute entry from a 'Text' key. The value is converted
to 'Attribute' lazily; actual conversion is deferred until the exporter
thread reads the attribute, keeping the instrumented thread fast.

@since 0.4.0.0
-}
attr :: (ToAttribute a) => Text -> a -> AttrsBuilder
attr !k v = let a = toAttribute v in AttrsBuilder (\step z -> step z k a)
{-# INLINE attr #-}


{- | Build an optional attribute entry. 'Nothing' contributes nothing
to the builder (zero cost).

@since 0.4.0.0
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

@since 0.4.0.0
-}
(.@) :: (ToAttribute a) => AttributeKey a -> a -> AttrsBuilder
(AttributeKey !k) .@ v = attr k v
{-# INLINE (.@) #-}


infixl 8 .@


{- | Build an optional attribute entry from a typed 'AttributeKey'.
'Nothing' contributes nothing to the builder.

@since 0.4.0.0
-}
(.@?) :: (ToAttribute a) => AttributeKey a -> Maybe a -> AttrsBuilder
_ .@? Nothing = mempty
(AttributeKey !k) .@? (Just v) = attr k v
{-# INLINE (.@?) #-}


infixl 8 .@?


{- | Materialize a builder into an 'Map.AttributeMap'. Useful when a raw
'HashMap' is needed (e.g. for 'NewEvent' attributes or 'SpanArguments').

@since 0.4.0.0
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


-- | @since 0.0.1.0
getAttributeMap :: Attributes -> Map.AttributeMap
getAttributeMap Attributes {..} = attributeMap
{-# INLINE getAttributeMap #-}


-- | @since 0.0.1.0
getCount :: Attributes -> Int
getCount Attributes {..} = attributesCount
{-# INLINE getCount #-}


-- | @since 0.0.1.0
getDropped :: Attributes -> Int
getDropped Attributes {..} = attributesDropped
{-# INLINE getDropped #-}


-- | @since 0.0.1.0
lookupAttribute :: Attributes -> Text -> Maybe Attribute
lookupAttribute Attributes {..} k = H.lookup k attributeMap
{-# INLINE lookupAttribute #-}


-- | @since 0.0.1.0
lookupAttributeByKey :: FromAttribute a => Attributes -> AttributeKey a -> Maybe a
lookupAttributeByKey Attributes {..} k = Map.lookupByKey k attributeMap
{-# INLINEABLE lookupAttributeByKey #-}


{- | It is possible when adding attributes that a programming error might cause too many
 attributes to be added to an event. Thus, 'Attributes' use the limits set here as a safeguard
 against excessive memory consumption.

@since 0.0.1.0
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
--
-- @since 0.0.1.0
unsafeMergeAttributesIgnoringLimits :: Attributes -> Attributes -> Attributes
unsafeMergeAttributesIgnoringLimits left right = Attributes hm c d
  where
    hm = attributeMap left <> attributeMap right
    c = H.size hm
    d = attributesDropped left + attributesDropped right


-- | @since 0.0.1.0
unsafeAttributesFromListIgnoringLimits :: [(Text, Attribute)] -> Attributes
unsafeAttributesFromListIgnoringLimits l = Attributes hm c 0
  where
    hm = H.fromList l
    c = H.size hm


{- | Wrap a pre-built HashMap directly into 'Attributes' with zero conversion.
No limit enforcement.  Used by 'filterAttributesByKeys' to avoid
a HashMap -> list -> HashMap roundtrip.

@since 0.0.1.0
-}
unsafeAttributesFromMapIgnoringLimits :: H.HashMap Text Attribute -> Attributes
unsafeAttributesFromMapIgnoringLimits m = Attributes m (H.size m) 0
{-# INLINE unsafeAttributesFromMapIgnoringLimits #-}
