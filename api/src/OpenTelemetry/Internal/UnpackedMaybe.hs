{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE UnboxedSums #-}
{-# LANGUAGE UnboxedTuples #-}

{- | Unboxed @Maybe@ using @UnboxedSums@ to eliminate the @Just@/@Nothing@
heap indirection. When stored as @{\-\# UNPACK \#-\} !(UMaybe a)@ in a
parent record, GHC can inline the tag + pointer directly into the parent
closure, so there is zero extra indirection for the Maybe layer.

Based on unpacked-maybe by Kyle McKean & chessai (BSD-3).
-}
module OpenTelemetry.Internal.UnpackedMaybe (
  UMaybe (UMaybe, UJust, UNothing),
  umaybe,
  isUJust,
  isUNothing,
  fromUMaybe,
  toBaseMaybe,
  fromBaseMaybe,
) where

import Data.Function (id)
import Prelude (Bool (..), Maybe (..))


{- | An unboxed optional value. Single-constructor wrapper around an unboxed
sum, so @{\-\# UNPACK \#-\}@ can flatten it into a parent record.

@since 0.0.1.0
-}
data UMaybe a = UMaybe (# (# #) | a #)


pattern UJust :: a -> UMaybe a
pattern UJust a = UMaybe (# | a #)


pattern UNothing :: UMaybe a
pattern UNothing = UMaybe (# (# #) | #)


{-# COMPLETE UJust, UNothing #-}


-- | @since 0.0.1.0
umaybe :: b -> (a -> b) -> UMaybe a -> b
umaybe def f (UMaybe x) = case x of
  (# (# #) | #) -> def
  (# | a #) -> f a
{-# INLINE umaybe #-}


-- | @since 0.0.1.0
isUJust :: UMaybe a -> Bool
isUJust (UJust _) = True
isUJust _ = False
{-# INLINE isUJust #-}


-- | @since 0.0.1.0
isUNothing :: UMaybe a -> Bool
isUNothing UNothing = True
isUNothing _ = False
{-# INLINE isUNothing #-}


-- | @since 0.0.1.0
fromUMaybe :: a -> UMaybe a -> a
fromUMaybe def = umaybe def id
{-# INLINE fromUMaybe #-}


-- | @since 0.0.1.0
toBaseMaybe :: UMaybe a -> Maybe a
toBaseMaybe = umaybe Nothing Just
{-# INLINE toBaseMaybe #-}


-- | @since 0.0.1.0
fromBaseMaybe :: Maybe a -> UMaybe a
fromBaseMaybe (Just x) = UJust x
fromBaseMaybe Nothing = UNothing
{-# INLINE fromBaseMaybe #-}
