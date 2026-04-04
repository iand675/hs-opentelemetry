{- |
Module      :  OpenTelemetry.Trace.Id.Generator.Default
Copyright   :  (c) Ian Duncan, 2021
License     :  BSD-3
Maintainer  :  Ian Duncan
Stability   :  experimental
Portability :  non-portable (GHC extensions)

Default ID generation using the platform CSPRNG (arc4random_buf on
macOS\/BSD, getrandom on Linux, BCryptGenRandom on Windows).
-}
module OpenTelemetry.Trace.Id.Generator.Default (
  defaultIdGenerator,
) where

import OpenTelemetry.Internal.Trace.Id (generateSpanIdBS, generateSpanIdSBS, generateTraceIdBS, generateTraceIdSBS)
import OpenTelemetry.Trace.Id.Generator (IdGenerator (..))


{- | The default generator for trace and span ids.

Uses the platform's native CSPRNG via C FFI, which is faster and
avoids Haskell-side atomic contention compared to the previous
@System.Random.Stateful@ implementation.

@since 0.1.0.0
-}
defaultIdGenerator :: IdGenerator
defaultIdGenerator =
  IdGenerator
    { generateSpanIdBytes = generateSpanIdBS
    , generateTraceIdBytes = generateTraceIdBS
    , genSpanIdSBS = generateSpanIdSBS
    , genTraceIdSBS = generateTraceIdSBS
    }
