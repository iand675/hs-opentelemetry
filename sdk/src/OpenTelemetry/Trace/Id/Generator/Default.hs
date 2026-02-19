{-# LANGUAGE CPP #-}
{-# LANGUAGE MagicHash #-}
{-# LANGUAGE UnboxedTuples #-}

-----------------------------------------------------------------------------

-----------------------------------------------------------------------------

{- |
 Module      :  OpenTelemetry.Trace.Id.Generator.Default
 Copyright   :  (c) Ian Duncan, 2021
 License     :  BSD-3
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)

 A performant implementation of random span and trace id generation.

 Uses a SplitMix64 PRNG in C @__thread@ TLS, giving each OS thread its own
 state with zero contention. Generates directly into unpinned ByteArray#
 (ShortByteString), avoiding the pinned ByteString intermediate allocation.
-}
module OpenTelemetry.Trace.Id.Generator.Default (
  defaultIdGenerator,
) where

import qualified Data.ByteString.Internal as BSI
import Data.ByteString.Short.Internal (ShortByteString (SBS))
import Data.Word (Word8)
import Foreign.Ptr (Ptr)
import GHC.Exts (
  Int#,
  Ptr (..),
  mutableByteArrayContents#,
  newPinnedByteArray#,
  unsafeFreezeByteArray#,
 )
import GHC.IO (IO (..))
import OpenTelemetry.Trace.Id.Generator (IdGenerator (..))


foreign import ccall unsafe "hs_rng_splitmix_span"
  c_splitmix_span :: Ptr Word8 -> IO ()

foreign import ccall unsafe "hs_rng_splitmix_trace"
  c_splitmix_trace :: Ptr Word8 -> IO ()


{- | The default generator for trace and span ids.

 Uses a SplitMix64 PRNG with per-thread state via C @__thread@ TLS.
 Each OS thread gets its own generator, seeded from RDRAND (if available)
 or getrandom(2), eliminating all contention between threads.

 Provides both the standard ByteString path and the direct ShortByteString
 path. The direct path generates into a pinned ByteArray# which is then
 frozen into a ShortByteString, avoiding the ByteString allocation +
 toShort copy that the standard path requires.

 @since 0.1.0.0
-}
defaultIdGenerator :: IdGenerator
defaultIdGenerator =
  IdGenerator
    { generateSpanIdBytes = BSI.create 8 c_splitmix_span
    , generateTraceIdBytes = BSI.create 16 c_splitmix_trace
    , generateSpanIdSBS = Just (generateSBS 8# c_splitmix_span)
    , generateTraceIdSBS = Just (generateSBS 16# c_splitmix_trace)
    }


-- Generate directly into a pinned ByteArray# and freeze to ShortByteString.
-- This avoids the ForeignPtr + ByteString wrapper allocation that BSI.create
-- produces, and also avoids the subsequent toShort copy.
--
-- We use pinned memory (newPinnedByteArray#) so that mutableByteArrayContents#
-- returns a stable pointer for the duration of the ccall unsafe.
generateSBS :: Int# -> (Ptr Word8 -> IO ()) -> IO ShortByteString
generateSBS n# fill = IO $ \s0 ->
  case newPinnedByteArray# n# s0 of
    (# s1, mba# #) ->
      case fill (Ptr (mutableByteArrayContents# mba#)) of
        IO f -> case f s1 of
          (# s2, () #) ->
            case unsafeFreezeByteArray# mba# s2 of
              (# s3, ba# #) -> (# s3, SBS ba# #)
{-# INLINE generateSBS #-}
