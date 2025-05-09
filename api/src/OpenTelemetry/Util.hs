{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE MagicHash #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE StrictData #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE UnboxedTuples #-}
{-# LANGUAGE UnliftedFFITypes #-}

-----------------------------------------------------------------------------

-----------------------------------------------------------------------------

{- |
 Module      :  OpenTelemetry.Util
 Copyright   :  (c) Ian Duncan, 2021
 License     :  BSD-3
 Description :  Convenience functions to simplify common instrumentation needs.
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)
-}
module OpenTelemetry.Util (
  constructorName,
  HasConstructor,
  getThreadId,
  bracketError,

  -- * Data structures
  AppendOnlyBoundedCollection,
  emptyAppendOnlyBoundedCollection,
  appendToBoundedCollection,
  appendOnlyBoundedCollectionSize,
  appendOnlyBoundedCollectionValues,
  appendOnlyBoundedCollectionDroppedElementCount,
) where

import Control.Exception (SomeException)
import qualified Control.Exception as EUnsafe
import Control.Monad.IO.Unlift
import Data.Kind
import qualified Data.Vector as V
import Foreign.C (CInt (..))
import GHC.Base (Addr#)
import GHC.Conc (ThreadId (ThreadId))
import GHC.Exts (unsafeCoerce#)
import GHC.Generics
import VectorBuilder.Builder (Builder)
import qualified VectorBuilder.Builder as Builder
import qualified VectorBuilder.Vector as Builder


{- | Useful for annotating which constructor in an ADT was chosen

 @since 0.1.0.0
-}
constructorName :: (HasConstructor (Rep a), Generic a) => a -> String
constructorName = genericConstrName . from


-- | Detect a constructor from any datatype which derives 'Generic'
class HasConstructor (f :: Type -> Type) where
  genericConstrName :: f x -> String


instance (HasConstructor f) => HasConstructor (D1 c f) where
  genericConstrName (M1 x) = genericConstrName x


instance (HasConstructor x, HasConstructor y) => HasConstructor (x :+: y) where
  genericConstrName (L1 l) = genericConstrName l
  genericConstrName (R1 r) = genericConstrName r


instance (Constructor c) => HasConstructor (C1 c f) where
  genericConstrName = conName


foreign import ccall unsafe "rts_getThreadId" c_getThreadId :: Addr# -> CInt


-- | Get an int representation of a thread id
getThreadId :: ThreadId -> Int
getThreadId (ThreadId tid#) = fromIntegral $ c_getThreadId (unsafeCoerce# tid#)
{-# INLINE getThreadId #-}


data AppendOnlyBoundedCollection a = AppendOnlyBoundedCollection
  { collection :: Builder a
  , maxSize :: {-# UNPACK #-} !Int
  , dropped :: {-# UNPACK #-} !Int
  }


instance forall a. (Show a) => Show (AppendOnlyBoundedCollection a) where
  showsPrec d AppendOnlyBoundedCollection {collection = c, maxSize = m, dropped = r} =
    let vec = Builder.build c :: V.Vector a
    in showParen (d > 10) $
        showString "AppendOnlyBoundedCollection {collection = "
          . shows vec
          . showString ", maxSize = "
          . shows m
          . showString ", dropped = "
          . shows r
          . showString "}"


-- | Initialize a bounded collection that admits a maximum size
emptyAppendOnlyBoundedCollection
  :: Int
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
appendToBoundedCollection c@(AppendOnlyBoundedCollection b ms d) x =
  if appendOnlyBoundedCollectionSize c < ms
    then AppendOnlyBoundedCollection (b <> Builder.singleton x) ms d
    else AppendOnlyBoundedCollection b ms (d + 1)


{- | Like 'Context.Exception.bracket', but provides the @after@ function with information about
 uncaught exceptions.

 @since 0.1.0.0
-}
bracketError :: (MonadUnliftIO m) => m a -> (Maybe SomeException -> a -> m b) -> (a -> m c) -> m c
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
