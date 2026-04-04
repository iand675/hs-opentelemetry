{-# LANGUAGE CPP #-}
{-# LANGUAGE MagicHash #-}
{-# LANGUAGE UnboxedTuples #-}

{- | Machine-word atomic counter using hardware fetch-and-add.

Unlike @atomicModifyIORef'@ which does a CAS retry loop on the boxed
@IORef@ closure, these operations compile down to a single
@lock xadd@ (x86) or @ldadd@ (AArch64) instruction with no
allocation and no retry.
-}
module OpenTelemetry.Internal.AtomicCounter (
  AtomicCounter,
  newAtomicCounter,
  incrAtomicCounter,
  addAtomicCounter,
  fetchAddAtomicCounter,
  readAtomicCounter,
  writeAtomicCounter,
) where


#include "MachDeps.h"

import GHC.Exts (
  Int (..),
  MutableByteArray#,
  RealWorld,
  fetchAddIntArray#,
  newByteArray#,
  readIntArray#,
  writeIntArray#,
  (+#),
 )
import GHC.IO (IO (..))


{- | A mutable atomic counter backed by a single unboxed machine-word 'Int'.

Uses hardware fetch-and-add (@fetchAddIntArray#@) instead of CAS retry
loops, making increment\/add O(1) regardless of contention.
-}
data AtomicCounter = AtomicCounter (MutableByteArray# RealWorld)


-- | Create a new counter initialized to the given value.
newAtomicCounter :: Int -> IO AtomicCounter
newAtomicCounter (I# n) = IO $ \s ->
  case newByteArray# SIZEOF_HSINT# s of
    (# s1, arr #) -> case writeIntArray# arr 0# n s1 of
      s2 -> (# s2, AtomicCounter arr #)


-- | Atomically increment the counter by 1. Returns the value /after/ the increment.
incrAtomicCounter :: AtomicCounter -> IO Int
incrAtomicCounter = addAtomicCounter 1
{-# INLINE incrAtomicCounter #-}


-- | Atomically add to the counter. Returns the value /after/ the add.
addAtomicCounter :: Int -> AtomicCounter -> IO Int
addAtomicCounter (I# incr) (AtomicCounter arr) = IO $ \s ->
  case fetchAddIntArray# arr 0# incr s of
    (# s', old #) -> (# s', I# (old +# incr) #)
{-# INLINE addAtomicCounter #-}


{- | Atomically add to the counter. Returns the value /before/ the add.
Useful for monotonic ID allocation.
-}
fetchAddAtomicCounter :: Int -> AtomicCounter -> IO Int
fetchAddAtomicCounter (I# incr) (AtomicCounter arr) = IO $ \s ->
  case fetchAddIntArray# arr 0# incr s of
    (# s', old #) -> (# s', I# old #)
{-# INLINE fetchAddAtomicCounter #-}


{- | Read the current counter value.

This is a relaxed read; no ordering guarantee relative to concurrent adds
on other cores. Fine for diagnostics and metrics.
-}
readAtomicCounter :: AtomicCounter -> IO Int
readAtomicCounter (AtomicCounter arr) = IO $ \s ->
  case readIntArray# arr 0# s of
    (# s', val #) -> (# s', I# val #)
{-# INLINE readAtomicCounter #-}


-- | Overwrite the counter value. Not atomic with respect to concurrent adds.
writeAtomicCounter :: AtomicCounter -> Int -> IO ()
writeAtomicCounter (AtomicCounter arr) (I# n) = IO $ \s ->
  case writeIntArray# arr 0# n s of
    s' -> (# s', () #)
{-# INLINE writeAtomicCounter #-}
