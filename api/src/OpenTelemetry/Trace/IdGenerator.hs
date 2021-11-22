{-# LANGUAGE CPP #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  OpenTelemetry.Trace.IdGenerator
-- Copyright   :  (c) Ian Duncan, 2021
-- License     :  BSD-3
-- Description :  Raw byte generation facilities for ID generation
-- Maintainer  :  Ian Duncan
-- Stability   :  experimental
-- Portability :  non-portable (GHC extensions)
--
-- Stateful random number generation interface for creating Trace and Span ID
-- bytes.
--
-- In most cases, using the 'defaultIdGenerator' will be sufficient, but the
-- interface is exposed for more exotic needs. 
--
-----------------------------------------------------------------------------
module OpenTelemetry.Trace.IdGenerator where
import Data.ByteString (ByteString)
import System.Random.MWC
#if MIN_VERSION_random(1,2,0)
import System.Random.Stateful
#else
import Data.ByteString.Random
#endif
import System.IO.Unsafe (unsafePerformIO)

-- | An interface for generating the underlying bytes for
-- trace and span ids.
data IdGenerator = IdGenerator
  { generateSpanIdBytes :: IO ByteString
    -- ^ MUST generate exactly 8 bytes
  , generateTraceIdBytes :: IO ByteString
    -- ^ MUST generate exactly 16 bytes
  }

-- | The default generator for trace and span ids.
--
-- @since 0.1.0.0
defaultIdGenerator :: IdGenerator
defaultIdGenerator = unsafePerformIO $ do
  g <- createSystemRandom
#if MIN_VERSION_random(1,2,0)
  pure $ IdGenerator
    { generateSpanIdBytes = uniformByteStringM 8 g
    , generateTraceIdBytes = uniformByteStringM 16 g
    }
#else
  pure $ IdGenerator
    { generateSpanIdBytes = randomGen g 8
    , generateTraceIdBytes = randomGen g 16
    }
#endif
{-# NOINLINE defaultIdGenerator #-}
