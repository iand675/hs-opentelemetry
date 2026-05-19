module OpenTelemetry.Trace.Id.Generator.Dummy where

import OpenTelemetry.Trace.Id.Generator


{- | A non-functioning id generator for use when an SDK is not installed.

Uses 'DefaultIdGenerator' so ID generation is available if spans
are ever actually created (the no-processor path short-circuits
before ID generation, so this is never called in practice).
-}
dummyIdGenerator :: IdGenerator
dummyIdGenerator = DefaultIdGenerator
