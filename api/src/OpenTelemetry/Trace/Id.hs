-- | Trace and Span Id generation
--
-- No Aeson instances are provided since they've got the potential to be
-- transport-specific in format. Use newtypes for serialisation instead.
module OpenTelemetry.Trace.Id 
  ( -- $ Working with 'TraceId's
    TraceId
  , newTraceId
  , isEmptyTraceId
  , traceIdBytes
  , bytesToTraceId
  , baseEncodedToTraceId
  , traceIdBaseEncodedBuilder
  , traceIdBaseEncodedByteString
  , traceIdBaseEncodedText
    -- $ Working with 'SpanId's
  , SpanId
    -- $$ Creating 'SpanId's
  , newSpanId
    -- $$ Checking 'SpanId's for validity
  , isEmptySpanId
    -- $$ Encoding / decoding 'SpanId' from bytes
  , spanIdBytes
  , bytesToSpanId
    -- $$ Encoding / decoding 'SpanId' from a given 'Base' encoding
  , Base(..)
  , baseEncodedToSpanId
  , spanIdBaseEncodedBuilder
  , spanIdBaseEncodedByteString
  , spanIdBaseEncodedText
  ) where

import Data.ByteArray.Encoding
import OpenTelemetry.Internal.Trace.Id
