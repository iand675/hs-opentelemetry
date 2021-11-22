-----------------------------------------------------------------------------
-- |
-- Module      :  OpenTelemetry.Trace.Id
-- Copyright   :  (c) Ian Duncan, 2021
-- License     :  BSD-3
-- Description :  Trace and Span ID generation, validation, serialization, and deserialization
-- Maintainer  :  Ian Duncan
-- Stability   :  experimental
-- Portability :  non-portable (GHC extensions)
--
-- Trace and Span Id generation
--
-- No Aeson instances are provided since they've got the potential to be
-- transport-specific in format. Use newtypes for serialisation instead.
--
-----------------------------------------------------------------------------
module OpenTelemetry.Trace.Id 
  ( -- $ Working with 'TraceId's
    TraceId
    -- $$ Creating 'TraceId's
  , newTraceId
    -- $$ Checking 'TraceId's for validity
  , isEmptyTraceId
    -- $$ Encoding / decoding 'TraceId' from bytes
  , traceIdBytes
  , bytesToTraceId
    -- $$ Encoding / decoding 'TraceId' from a given 'Base' encoding
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
