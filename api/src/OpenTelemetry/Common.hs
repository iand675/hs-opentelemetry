module OpenTelemetry.Common where

import Data.Word (Word64, Word8)
import System.Clock (TimeSpec, toNanoSecs)


newtype Timestamp = Timestamp TimeSpec
  deriving (Read, Show, Eq, Ord)


-- | Convert a 'Timestamp' to a 'Word64' in nanoseconds.
timestampToNano :: Timestamp -> Word64
timestampToNano (Timestamp t) = fromIntegral (toNanoSecs t)


-- | Contain details about the trace. Unlike TraceState values, TraceFlags are present in all traces. The current version of the specification only supports a single flag called sampled.
newtype TraceFlags = TraceFlags Word8
  deriving (Show, Eq, Ord)
