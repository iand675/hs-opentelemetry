module OpenTelemetry.Trace.IdGenerator where
import Data.ByteString (ByteString)
import System.Random.MWC
import System.Random.Stateful

data IdGenerator = IdGenerator
  { generateSpanIdBytes :: IO ByteString
    -- ^ Should generate 8 bytes
  , generateTraceIdBytes :: IO ByteString
    -- ^ Should generate 16 bytes
  }

newtype DefaultIdGenerator = DefaultIdGenerator GenIO

makeDefaultIdGenerator :: IO IdGenerator
makeDefaultIdGenerator = do
  g <- createSystemRandom
  pure $ IdGenerator
    { generateSpanIdBytes = uniformByteStringM 8 g
    , generateTraceIdBytes = uniformByteStringM 16 g
    }
