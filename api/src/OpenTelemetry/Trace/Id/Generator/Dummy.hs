module OpenTelemetry.Trace.Id.Generator.Dummy where

import Data.ByteString.Short (toShort)
import OpenTelemetry.Trace.Id.Generator


-- | A non-functioning id generator for use when an SDK is not installed
dummyIdGenerator :: IdGenerator
dummyIdGenerator =
  IdGenerator
    { generateSpanIdBytes = pure "\NUL\NUL\NUL\NUL\NUL\NUL\NUL\NUL"
    , generateTraceIdBytes = pure "\NUL\NUL\NUL\NUL\NUL\NUL\NUL\NUL\NUL\NUL\NUL\NUL\NUL\NUL\NUL\NUL"
    , genSpanIdSBS = pure $! toShort "\NUL\NUL\NUL\NUL\NUL\NUL\NUL\NUL"
    , genTraceIdSBS = pure $! toShort "\NUL\NUL\NUL\NUL\NUL\NUL\NUL\NUL\NUL\NUL\NUL\NUL\NUL\NUL\NUL\NUL"
    }
