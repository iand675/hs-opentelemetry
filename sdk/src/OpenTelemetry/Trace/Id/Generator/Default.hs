{-# LANGUAGE CPP #-}

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
 state with zero contention. ~5x faster than the Haskell AtomicGenM
 single-threaded, and ~1200x faster under contention (4 threads).
-}
module OpenTelemetry.Trace.Id.Generator.Default (
  defaultIdGenerator,
) where

import qualified Data.ByteString.Internal as BSI
import Data.Word (Word8)
import Foreign.Ptr (Ptr)
import OpenTelemetry.Trace.Id.Generator (IdGenerator (..))


foreign import ccall unsafe "hs_rng_splitmix_span"
  c_splitmix_span :: Ptr Word8 -> IO ()

foreign import ccall unsafe "hs_rng_splitmix_trace"
  c_splitmix_trace :: Ptr Word8 -> IO ()


{- | The default generator for trace and span ids.

 Uses a SplitMix64 PRNG with per-thread state via C @__thread@ TLS.
 Each OS thread gets its own generator, seeded from RDRAND (if available)
 or getrandom(2), eliminating all contention between threads.

 @since 0.1.0.0
-}
defaultIdGenerator :: IdGenerator
defaultIdGenerator =
  IdGenerator
    { generateSpanIdBytes = BSI.create 8 c_splitmix_span
    , generateTraceIdBytes = BSI.create 16 c_splitmix_trace
    }
