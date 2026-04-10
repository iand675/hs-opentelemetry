{- |
Module      :  OpenTelemetry.Id.Generator
Copyright   :  (c) Ian Duncan, 2021
License     :  BSD-3
Description :  ID generation strategies for trace and span identifiers
Maintainer  :  Ian Duncan
Stability   :  experimental
Portability :  non-portable (GHC extensions)

Pluggable ID generation for creating Trace and Span ID bytes.

The default generator ('DefaultIdGenerator') uses a thread-local
xoshiro256++ PRNG seeded from the platform's native random source
(arc4random_buf on macOS, getrandom on Linux, BCryptGenRandom on
Windows). It is not cryptographically secure but is significantly
faster than a CSPRNG due to zero contention and no syscalls after
initial seeding. This matches the approach used by the Java OTel SDK
(@ThreadLocalRandom@). The OTel spec requires IDs to be "randomly
generated" but does not mandate cryptographic strength.

For fully custom generation (e.g. deterministic testing), use
'customIdGenerator' to provide your own functions.
-}
module OpenTelemetry.Trace.Id.Generator (
  IdGenerator (..),
  customIdGenerator,
) where

import Data.ByteString.Short (ShortByteString)


{- | Strategy for generating trace and span IDs.

Pattern-matching on known constructors in the hot path lets GHC
inline the generation functions directly, eliminating the indirect
call overhead of a record-of-functions approach.

 @since 0.0.1.0
-}
data IdGenerator
  = -- | Thread-local xoshiro256++ PRNG seeded from the platform CSPRNG.
    --
    -- Each OS thread gets its own PRNG state, seeded once from the
    -- platform CSPRNG. Subsequent ID generation is pure arithmetic
    -- with no syscalls, no shared state, and no atomic operations.
    --
    -- xoshiro256++ passes BigCrush and PractRand with a period of
    -- 2^256−1. Fork-safe: child processes reseed automatically via
    -- @pthread_atfork@.
    --
    -- @since 0.1.0.0
    DefaultIdGenerator
  | -- | Fully custom generation.
    --
    -- The first action must produce exactly 8 random bytes (span ID),
    -- the second exactly 16 bytes (trace ID).
    --
    -- @since 0.0.1.0
    CustomIdGenerator
      !(IO ShortByteString)
      !(IO ShortByteString)


{- | Construct a custom 'IdGenerator' from two actions producing raw ID bytes.

@
deterministicGen :: IORef Word64 -> IdGenerator
deterministicGen ref = customIdGenerator
  (genBytes ref 8)   -- span ID: 8 bytes
  (genBytes ref 16)  -- trace ID: 16 bytes
@

 @since 0.0.1.0
-}
customIdGenerator
  :: IO ShortByteString
  -- ^ Generate 8 bytes for span ID
  -> IO ShortByteString
  -- ^ Generate 16 bytes for trace ID
  -> IdGenerator
customIdGenerator = CustomIdGenerator
