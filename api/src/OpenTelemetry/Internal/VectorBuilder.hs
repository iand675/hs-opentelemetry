{- |
Minimal vendored replacement for the vector-builder package.

Provides an O(1) append builder that produces a 'Vector' in O(n).
Uses a difference-list internally for efficient right-associated concatenation.
-}
module OpenTelemetry.Internal.VectorBuilder (
  Builder,
  singleton,
  size,
  build,
) where

import qualified Data.Vector as V


-- | An efficient builder for 'Vector's. Supports O(1) 'singleton' and O(1) '<>'.
data Builder a = Builder
  {-# UNPACK #-} !Int
  ([a] -> [a])


instance Semigroup (Builder a) where
  {-# INLINE (<>) #-}
  Builder n1 f1 <> Builder n2 f2 = Builder (n1 + n2) (f1 . f2)


instance Monoid (Builder a) where
  {-# INLINE mempty #-}
  mempty = Builder 0 id


-- | Create a builder containing a single element.
{-# INLINE singleton #-}
singleton :: a -> Builder a
singleton a = Builder 1 (a :)


-- | The number of elements in the builder.
{-# INLINE size #-}
size :: Builder a -> Int
size (Builder n _) = n


-- | Materialize the builder into a 'Vector'.
{-# INLINE build #-}
build :: Builder a -> V.Vector a
build (Builder n f) = V.fromListN n (f [])
