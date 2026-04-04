{-# LANGUAGE BangPatterns #-}
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

  -- * Lock-free IORef modification
  casModifyIORef_,

  casReadModifyIORef_,

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
import Data.IORef (IORef)
import Data.Kind
import qualified Data.Vector as V
import Foreign.C (CInt (..))
import GHC.Base (Addr#)
import GHC.Conc (ThreadId (ThreadId))
import GHC.Exts (unsafeCoerce#)
import GHC.Generics
import GHC.IO (IO (IO))
import GHC.IORef (IORef (IORef))
import GHC.STRef (STRef (STRef))
import qualified GHC.Exts as Exts


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


{- Note [NOINLINE on CAS functions]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
These functions MUST be NOINLINE. When inlined, GHC's Core-to-STG pass may
wrap the "new" constructor (the result of @f old@) in an updatable thunk rather
than allocating it directly as a constructor. This happens when the modification
function produces a record with a strict field whose value is a locally-allocated
closure (e.g. a DList function composition @dl . (x :)@ in
'AppendOnlyBoundedCollection'). The Core-to-STG pass conservatively inserts a
@case@ to force the strict field, turning the entire constructor into a thunk.

The thunk pointer has tag 0 (untagged). @casMutVar#@ writes this untagged
thunk to the MutVar. On the next read, the thunk is evaluated — it becomes an
indirection to the actual constructor at a different heap address (tag 1). The
CAS then compares the evaluated constructor pointer (tag 1) against the MutVar
contents (the indirection cell, tag 0). These are different addresses, so the
CAS fails *permanently* — every retry reads the indirection, evaluates to the
constructor, and mismatches again. Result: infinite spin-loop.

With NOINLINE, @let !new = f old@ forces the thunk inside the CAS function
before passing the evaluated (tagged) constructor pointer to @casMutVar#@.
The MutVar always contains a properly tagged constructor pointer, so the CAS
comparison works correctly.

Affects all GHC versions tested (9.4 through 9.12), both aarch64 and x86_64.

Note: we deliberately omit @yield#@ on the CAS failure path. NOINLINE already
makes the function call a GC safe point, and each retry re-evaluates @f old@
which allocates — providing another safe point. @yield#@ was measured to add
significant overhead even on the uncontended success path (likely because GHC
cannot prove it is dead code and its presence inhibits tail-call / loop
optimisation).
-}

{- | CAS-based strict IORef modification that avoids the closure and pair
allocation of 'atomicModifyIORef''.

@atomicModifyIORef' ref (\old -> (f old, ()))@ allocates a closure capturing
the modification function, a @(new, ())@ pair, and (in the GHC RTS) a thunk
indirection that is CAS'd into the MutVar.

This function instead reads the current value, applies @f@ strictly, and
performs a compare-and-swap. On success (the common, uncontended case), zero
intermediate heap objects are allocated beyond the new value itself. On CAS
failure (concurrent modification), it retries — safe because @f@ is pure.

Use for hot-path span operations (addAttribute, addEvent, setStatus, etc.)
where the IORef is rarely contended and the modification is a cheap record
update.
-}
casModifyIORef_ :: IORef a -> (a -> a) -> IO ()
casModifyIORef_ (IORef (STRef ref#)) f = IO go#
  where
    go# s0# =
      case Exts.readMutVar# ref# s0# of
        (# s1#, old #) ->
          let !new = f old
          in case Exts.casMutVar# ref# old new s1# of
            (# s2#, 0#, _ #) -> (# s2#, () #)
            (# s2#, _, _ #) -> go# s2#
{-# NOINLINE casModifyIORef_ #-}
-- NOINLINE is load-bearing: see Note [NOINLINE on CAS functions]


{- | CAS-based IORef modification that also reads the old value before the swap.

Performs a strict read, applies @f@ to decide both the new value and a
pre-swap result, then CAS's the new value in. Returns the old value (before
modification) on success. Retries on CAS failure.

Used by 'endSpan' where we need to atomically set @spanEnd@ and also read the
(unchanged) Tracer field to obtain the processor vector — all without
navigating the Tracer inside an @atomicModifyIORef'@ closure.
-}
casReadModifyIORef_ :: IORef a -> (a -> a) -> IO a
casReadModifyIORef_ (IORef (STRef ref#)) f = IO go#
  where
    go# s0# =
      case Exts.readMutVar# ref# s0# of
        (# s1#, old #) ->
          let !new = f old
          in case Exts.casMutVar# ref# old new s1# of
            (# s2#, 0#, _ #) -> (# s2#, old #)
            (# s2#, _, _ #) -> go# s2#
{-# NOINLINE casReadModifyIORef_ #-}
-- NOINLINE is load-bearing: see Note [NOINLINE on CAS functions]


{- | Bounded append-only collection using a difference list internally.

Append is O(1) — function composition, no copying. Read materializes the
accumulated elements into a 'V.Vector' via 'V.fromListN' in O(n).

Benchmarked against reversed list, 'V.Vector' snoc, 'Data.Sequence',
@vector-builder@, and mutable pre-allocated IOVector. DList ties RevList
for best pure lifecycle at all sizes and avoids the O(n²) copy cost that
the previous vector-snoc approach suffered at larger collection sizes (e.g.
22μs for N=128 vs 2.4μs for DList). Safe with 'atomicModifyIORef'' because
function composition is pure — no shared mutable state across CAS retries.
-}
data AppendOnlyBoundedCollection a = AppendOnlyBoundedCollection
  { collectionDList :: !([a] -> [a])
  , collectionSize :: {-# UNPACK #-} !Int
  , collectionMaxSize :: {-# UNPACK #-} !Int
  , collectionDropped :: {-# UNPACK #-} !Int
  }


instance forall a. (Show a) => Show (AppendOnlyBoundedCollection a) where
  showsPrec d c =
    let vec = appendOnlyBoundedCollectionValues c
    in showParen (d > 10) $
        showString "AppendOnlyBoundedCollection {collection = "
          . shows vec
          . showString ", maxSize = "
          . shows (collectionMaxSize c)
          . showString ", dropped = "
          . shows (collectionDropped c)
          . showString "}"


-- | Initialize a bounded collection that admits a maximum size
emptyAppendOnlyBoundedCollection
  :: Int
  -- ^ Maximum size
  -> AppendOnlyBoundedCollection a
emptyAppendOnlyBoundedCollection !s = AppendOnlyBoundedCollection id 0 s 0
{-# INLINE emptyAppendOnlyBoundedCollection #-}


-- | O(n). Materializes the difference list into a 'V.Vector' via 'V.fromListN'.
-- Called once per span at export time.
appendOnlyBoundedCollectionValues :: AppendOnlyBoundedCollection a -> V.Vector a
appendOnlyBoundedCollectionValues (AppendOnlyBoundedCollection dl sz _ _) =
  V.fromListN sz (dl [])
{-# INLINE appendOnlyBoundedCollectionValues #-}


appendOnlyBoundedCollectionSize :: AppendOnlyBoundedCollection a -> Int
appendOnlyBoundedCollectionSize = collectionSize
{-# INLINE appendOnlyBoundedCollectionSize #-}


appendOnlyBoundedCollectionDroppedElementCount :: AppendOnlyBoundedCollection a -> Int
appendOnlyBoundedCollectionDroppedElementCount = collectionDropped
{-# INLINE appendOnlyBoundedCollectionDroppedElementCount #-}


-- | Append an element. O(1) — function composition, no copying.
-- Returns the collection unchanged (with incremented drop count) when full.
appendToBoundedCollection :: AppendOnlyBoundedCollection a -> a -> AppendOnlyBoundedCollection a
appendToBoundedCollection (AppendOnlyBoundedCollection dl sz ms d) x
  | sz >= ms = AppendOnlyBoundedCollection dl sz ms (d + 1)
  | otherwise = AppendOnlyBoundedCollection (dl . (x :)) (sz + 1) ms d
{-# INLINE appendToBoundedCollection #-}


{- | Like 'Context.Exception.bracket', but provides the @after@ function with information about
 uncaught exceptions.

 @since 0.1.0.0
-}
bracketError :: (MonadUnliftIO m) => m a -> (Maybe SomeException -> a -> m b) -> (a -> m c) -> m c
{-# INLINABLE bracketError #-}
bracketError before after thing = withRunInIO $ \run -> EUnsafe.mask $ \restore -> do
  x <- run before
  y <-
    restore (run $ thing x) `EUnsafe.catch` \(e1 :: SomeException) -> do
      _ :: Either SomeException b <-
        EUnsafe.try $ EUnsafe.uninterruptibleMask_ $ run $ after (Just e1) x
      EUnsafe.throwIO e1
  _ <- EUnsafe.uninterruptibleMask_ $ run $ after Nothing x
  return y
