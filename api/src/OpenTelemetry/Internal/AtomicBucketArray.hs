{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE CPP #-}
{-# LANGUAGE MagicHash #-}
{-# LANGUAGE UnboxedTuples #-}

{- |
Module      :  OpenTelemetry.Internal.AtomicBucketArray
Copyright   :  (c) Ian Duncan, 2024-2026
License     :  BSD-3
Description :  Contiguous array of atomic counters for histogram bucket counts.
Stability   :  experimental

One 'MutableByteArray#' holds all bucket counts in a single allocation,
indexed by bucket number. Each slot supports atomic fetch-and-add via
@fetchAddIntArray#@, a single @ldadd@ (AArch64) or @lock xadd@ (x86)
instruction with no CAS retry and no allocation.

Used to eliminate the O(n) bucket vector copy that 'Data.Vector.Unboxed.modify'
performs on every histogram recording inside an @atomicModifyIORef'@ CAS loop.
-}
module OpenTelemetry.Internal.AtomicBucketArray (
  AtomicBucketArray,
  newAtomicBucketArray,
  atomicAddBucket,
  readBucketArray,
  readAndResetBucketArray,
) where


#include "MachDeps.h"

import Data.Vector.Unboxed (Vector)
import qualified Data.Vector.Unboxed as U
import Data.Word (Word64)
import GHC.Exts (
  Int (..),
  Int#,
  MutableByteArray#,
  RealWorld,
  State#,
  fetchAddIntArray#,
  isTrue#,
  negateInt#,
  newByteArray#,
  readIntArray#,
  writeIntArray#,
  (*#),
  (+#),
  (>=#),
 )
import GHC.IO (IO (..))


{- | Contiguous mutable array of atomic counters. Each element is one
machine-word 'Int', accessible via hardware fetch-and-add.

@since 0.0.1.0
-}
data AtomicBucketArray = AtomicBucketArray (MutableByteArray# RealWorld) Int#


{- | Allocate a new bucket array with all counters initialized to zero.

@since 0.0.1.0
-}
newAtomicBucketArray :: Int -> IO AtomicBucketArray
newAtomicBucketArray (I# n) = IO $ \s ->
  let !nbytes = n *# SIZEOF_HSINT#
  in case newByteArray# nbytes s of
      (# s1, arr #) -> case zeroFill arr n s1 of
        s2 -> (# s2, AtomicBucketArray arr n #)


zeroFill :: MutableByteArray# RealWorld -> Int# -> State# RealWorld -> State# RealWorld
zeroFill arr nwords s0 = go 0# s0
  where
    go i s
      | isTrue# (i >=# nwords) = s
      | otherwise = case writeIntArray# arr i 0# s of
          s' -> go (i +# 1#) s'


{- | Atomically increment the bucket at the given index by 1.
No bounds checking.

@since 0.0.1.0
-}
atomicAddBucket :: AtomicBucketArray -> Int -> IO ()
atomicAddBucket (AtomicBucketArray arr _) (I# i) = IO $ \s ->
  case fetchAddIntArray# arr i 1# s of
    (# s', _ #) -> (# s', () #)
{-# INLINE atomicAddBucket #-}


{- | Read all bucket values into an immutable 'U.Vector Word64'.
Each element is read individually; not globally atomic across buckets
(acceptable for metric snapshots).

@since 0.0.1.0
-}
readBucketArray :: AtomicBucketArray -> IO (Vector Word64)
readBucketArray (AtomicBucketArray arr len) = do
  let !n = I# len
  U.generateM n $ \(I# i) -> IO $ \s ->
    case readIntArray# arr i s of
      (# s', v #) -> (# s', fromIntegral (I# v) #)
{-# INLINE readBucketArray #-}


{- | Read all bucket values and atomically reset each to zero.
Uses fetch-and-add with the negated current value.
Between the read and the subtract another thread may increment,
but the net effect is correct across consecutive delta collections:
no sample is lost, at worst one sample shifts to the next cycle.

@since 0.0.1.0
-}
readAndResetBucketArray :: AtomicBucketArray -> IO (Vector Word64)
readAndResetBucketArray (AtomicBucketArray arr len) = do
  let !n = I# len
  U.generateM n $ \(I# i) -> IO $ \s ->
    case readIntArray# arr i s of
      (# s1, old #) -> case fetchAddIntArray# arr i (negateInt# old) s1 of
        (# s2, _ #) -> (# s2, fromIntegral (I# old) #)
{-# INLINE readAndResetBucketArray #-}
