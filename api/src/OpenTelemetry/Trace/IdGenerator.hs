{-# LANGUAGE CPP #-}
module OpenTelemetry.Trace.IdGenerator where
import Data.ByteString (ByteString)
import System.Random.MWC
#if MIN_VERSION_random(1,2,0)
import System.Random.Stateful
#else
import Data.ByteString.Random
#endif

data IdGenerator = IdGenerator
  { generateSpanIdBytes :: IO ByteString
    -- ^ Should generate 8 bytes
  , generateTraceIdBytes :: IO ByteString
    -- ^ Should generate 16 bytes
  }

makeDefaultIdGenerator :: IO IdGenerator
makeDefaultIdGenerator = do
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