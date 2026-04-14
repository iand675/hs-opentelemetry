{- |
Module      :  OpenTelemetry.Trace.Id.Generator.Default
Copyright   :  (c) Ian Duncan, 2021
License     :  BSD-3
Maintainer  :  Ian Duncan
Stability   :  experimental
Portability :  non-portable (GHC extensions)

Default ID generation using thread-local xoshiro256++ seeded from the
platform CSPRNG (arc4random_buf on macOS\/BSD, getrandom on Linux,
BCryptGenRandom on Windows).
-}
module OpenTelemetry.Trace.Id.Generator.Default (
  defaultIdGenerator,
) where

import OpenTelemetry.Trace.Id.Generator (IdGenerator (..))


{- | The default generator for trace and span ids.

Uses thread-local xoshiro256++ PRNG seeded from the platform CSPRNG.
Each OS thread gets its own state. Zero contention, zero syscalls
after initial seed.

@since 0.1.0.0
-}
defaultIdGenerator :: IdGenerator
defaultIdGenerator = DefaultIdGenerator
