{-# LANGUAGE CPP #-}
module OpenTelemetry.Trace.IdGenerator.Default 
  ( defaultIdGenerator
  ) where

import System.Random.MWC
#if MIN_VERSION_random(1,2,0)
import System.Random.Stateful
#else
import Data.ByteString.Random
#endif
import System.IO.Unsafe (unsafePerformIO)
import OpenTelemetry.Trace.IdGenerator (IdGenerator(..))

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
