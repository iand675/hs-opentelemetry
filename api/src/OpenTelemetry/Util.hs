{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE MagicHash #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE UnboxedTuples #-}
{-# LANGUAGE UnliftedFFITypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  OpenTelemetry.Util
-- Copyright   :  (c) Ian Duncan, 2021
-- License     :  BSD-3
-- Description :  Convenience functions to simplify common instrumentation needs.
-- Maintainer  :  Ian Duncan
-- Stability   :  experimental
-- Portability :  non-portable (GHC extensions)
--
-----------------------------------------------------------------------------
module OpenTelemetry.Util
  ( constructorName
  , HasConstructor
  , getThreadId
  , bracketError
  -- * Data structures
  , AppendOnlyBoundedCollection
  , emptyAppendOnlyBoundedCollection
  , appendToBoundedCollection
  , appendOnlyBoundedCollectionSize
  , appendOnlyBoundedCollectionValues
  , appendOnlyBoundedCollectionDroppedElementCount
  , FrozenBoundedCollection
  , frozenBoundedCollection
  , frozenBoundedCollectionValues
  , frozenBoundedCollectionDroppedElementCount
  ) where

import Data.Foldable
import Data.Kind
import qualified Data.Vector as V
import GHC.Generics
import GHC.Conc (ThreadId(ThreadId))
import GHC.Base (ThreadId#)
import Foreign.C (CInt(..))
import VectorBuilder.Builder (Builder)
import qualified VectorBuilder.Builder as Builder
import qualified VectorBuilder.Vector as Builder
import Control.Monad.IO.Unlift
import Control.Exception (SomeException)
import qualified Control.Exception as EUnsafe

-- | Useful for annotating which constructor in an ADT was chosen
--
-- @since 0.1.0.0
constructorName :: (HasConstructor (Rep a), Generic a) => a -> String
constructorName = genericConstrName . from

-- | Detect a constructor from any datatype which derives 'Generic'
class HasConstructor (f :: Type -> Type) where
  genericConstrName :: f x -> String

instance HasConstructor f => HasConstructor (D1 c f) where
  genericConstrName (M1 x) = genericConstrName x

instance (HasConstructor x, HasConstructor y) => HasConstructor (x :+: y) where
  genericConstrName (L1 l) = genericConstrName l
  genericConstrName (R1 r) = genericConstrName r

instance Constructor c => HasConstructor (C1 c f) where
  genericConstrName x = conName x

foreign import ccall unsafe "rts_getThreadId" c_getThreadId :: ThreadId# -> CInt

-- | Get an int representation of a thread id
getThreadId :: ThreadId -> Int
getThreadId (ThreadId tid#) = fromIntegral (c_getThreadId tid#)
{-# INLINE getThreadId #-}

data AppendOnlyBoundedCollection a = AppendOnlyBoundedCollection
  { collection :: Builder a
  , maxSize :: {-# UNPACK #-} !Int
  , dropped :: {-# UNPACK #-} !Int
  }

instance forall a. Show a => Show (AppendOnlyBoundedCollection a) where
  show AppendOnlyBoundedCollection {collection=c} =
    let vec = Builder.build c :: V.Vector a
        in show vec

-- | Initialize a bounded collection that admits a maximum size
emptyAppendOnlyBoundedCollection ::
     Int
  -- ^ Maximum size
  -> AppendOnlyBoundedCollection a
emptyAppendOnlyBoundedCollection s = AppendOnlyBoundedCollection mempty s 0

appendOnlyBoundedCollectionValues :: AppendOnlyBoundedCollection a -> V.Vector a
appendOnlyBoundedCollectionValues (AppendOnlyBoundedCollection a _ _) = Builder.build a

appendOnlyBoundedCollectionSize :: AppendOnlyBoundedCollection a -> Int
appendOnlyBoundedCollectionSize (AppendOnlyBoundedCollection b _ _) = Builder.size b

appendOnlyBoundedCollectionDroppedElementCount :: AppendOnlyBoundedCollection a -> Int
appendOnlyBoundedCollectionDroppedElementCount (AppendOnlyBoundedCollection _ _ d) = d

appendToBoundedCollection :: AppendOnlyBoundedCollection a -> a -> AppendOnlyBoundedCollection a
appendToBoundedCollection c@(AppendOnlyBoundedCollection b ms d) x = if appendOnlyBoundedCollectionSize c < ms
  then AppendOnlyBoundedCollection (b <> Builder.singleton x) ms d
  else AppendOnlyBoundedCollection b ms (d + 1)

data FrozenBoundedCollection a = FrozenBoundedCollection
  { collection :: !(V.Vector a)
  , dropped :: !Int
  } deriving (Show)

frozenBoundedCollection :: Foldable f => Int -> f a -> FrozenBoundedCollection a
frozenBoundedCollection maxSize_ coll = FrozenBoundedCollection (V.fromListN maxSize_ $ toList coll) (collLength - maxSize_)
  where
    collLength = length coll

frozenBoundedCollectionValues :: FrozenBoundedCollection a -> V.Vector a
frozenBoundedCollectionValues (FrozenBoundedCollection coll _) = coll

frozenBoundedCollectionDroppedElementCount :: FrozenBoundedCollection a -> Int
frozenBoundedCollectionDroppedElementCount (FrozenBoundedCollection _ dropped_) = dropped_

-- | Like 'Context.Exception.bracket', but provides the @after@ function with information about
-- uncaught exceptions.
--
-- @since 0.1.0.0
bracketError :: MonadUnliftIO m => m a -> (Maybe SomeException -> a -> m b) -> (a -> m c) -> m c
bracketError before after thing = withRunInIO $ \run -> EUnsafe.mask $ \restore -> do
  x <- run before
  res1 <- EUnsafe.try $ restore $ run $ thing x
  case res1 of
    Left (e1 :: SomeException) -> do
      -- explicitly ignore exceptions from after. We know that
      -- no async exceptions were thrown there, so therefore
      -- the stronger exception must come from thing
      --
      -- https://github.com/fpco/safe-exceptions/issues/2
      _ :: Either SomeException b <-
          EUnsafe.try $ EUnsafe.uninterruptibleMask_ $ run $ after (Just e1) x
      EUnsafe.throwIO e1
    Right y -> do
      _ <- EUnsafe.uninterruptibleMask_ $ run $ after Nothing x
      return y
