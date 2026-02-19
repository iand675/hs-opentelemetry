-----------------------------------------------------------------------------

-----------------------------------------------------------------------------

{- |
 Module      :  OpenTelemetry.Id.Generator
 Copyright   :  (c) Ian Duncan, 2021
 License     :  BSD-3
 Description :  Raw byte generation facilities for ID generation
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)

 Stateful random number generation interface for creating Trace and Span ID
 bytes.

 In most cases, the built-in generator in the hs-opentelemetry-sdk will be sufficient, but the
 interface is exposed for more exotic needs.
-}
module OpenTelemetry.Trace.Id.Generator (
  IdGenerator (..),
) where

import Data.ByteString (ByteString)
import Data.ByteString.Short (ShortByteString)


{- | An interface for generating the underlying bytes for
 trace and span ids.
-}
data IdGenerator = IdGenerator
  { generateSpanIdBytes :: IO ByteString
  -- ^ MUST generate exactly 8 bytes
  , generateTraceIdBytes :: IO ByteString
  -- ^ MUST generate exactly 16 bytes
  , generateSpanIdSBS :: !(Maybe (IO ShortByteString))
  -- ^ Optional: generate directly as ShortByteString, avoiding the
  -- ByteString -> toShort copy. When set, 'newSpanId' prefers this.
  , generateTraceIdSBS :: !(Maybe (IO ShortByteString))
  -- ^ Optional: generate directly as ShortByteString.
  }
