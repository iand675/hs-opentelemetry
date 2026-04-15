{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE Strict #-}

{- | Conversion of the hs-opentelemetry internal representation of the trace ID and the span ID and the B3 header representation of them each other.

|----------------+---------------------------------------+------------------------------|
|                | Trace ID                              | Span ID                      |
|----------------+---------------------------------------+------------------------------|
| Internal       | 128-bit integer                       | 64-bit integer               |
| B3 Header      | Hex text of 64-bit or 128-bit integer | Hex text of 64-bit integer   |
|----------------+---------------------------------------+------------------------------|
-}
module OpenTelemetry.Propagator.B3.Internal (
  -- * Encoders
  encodeTraceId,
  encodeSpanId,

  -- * Decoders
  decodeXb3TraceIdHeader,
  decodeXb3SpanIdHeader,
  decodeXb3SampledHeader,
  decodeXb3FlagsHeader,
  decodeB3SampleHeader,
  decodeB3SingleHeader,

  -- * B3SingleHeader
  B3SingleHeader (..),

  -- * SampleState
  SamplingState (..),

  -- ** Conversions
  samplingStateToValue,
  samplingStateFromValue,
  printSamplingStateSingle,
  printSamplingStateMulti,

  -- * Header Keys
  b3Header,
  xb3TraceIdHeader,
  xb3SpanIdHeader,
  xb3SampledHeader,
  xb3FlagsHeader,
  xb3ParentSpanIdHeader,
) where

--------------------------------------------------------------------------------

import Data.ByteString (ByteString)
import qualified Data.ByteString as BS
import qualified Data.ByteString.Builder as BB
import qualified Data.ByteString.Lazy as BL
import Data.Text (Text)
import Data.Word (Word8)
import OpenTelemetry.Trace.Id (
  Base (..),
  SpanId,
  TraceId,
  baseEncodedToSpanId,
  baseEncodedToTraceId,
  bytesToTraceId,
  spanIdBaseEncodedBuilder,
  spanIdBytes,
  traceIdBaseEncodedBuilder,
 )
import OpenTelemetry.Trace.TraceState (Value (..))


--------------------------------------------------------------------------------

encodeTraceId
  :: TraceId
  -> ByteString
  -- ^ ASCII text of 64-bit integer
encodeTraceId = BL.toStrict . BB.toLazyByteString . traceIdBaseEncodedBuilder Base16


encodeSpanId
  :: SpanId
  -> ByteString
  -- ^ ASCII text of 64-bit integer
encodeSpanId = BL.toStrict . BB.toLazyByteString . spanIdBaseEncodedBuilder Base16


--------------------------------------------------------------------------------

decodeXb3TraceIdHeader :: ByteString -> Maybe TraceId
decodeXb3TraceIdHeader bs = either (const Nothing) Just (decodeTraceIdFromHex bs)


decodeXb3SpanIdHeader :: ByteString -> Maybe SpanId
decodeXb3SpanIdHeader bs = either (const Nothing) Just (baseEncodedToSpanId Base16 bs)


decodeXb3SampledHeader :: ByteString -> Maybe SamplingState
decodeXb3SampledHeader "1" = Just Accept
decodeXb3SampledHeader "0" = Just Deny
decodeXb3SampledHeader _ = Nothing


decodeXb3FlagsHeader :: ByteString -> Maybe SamplingState
decodeXb3FlagsHeader "1" = Just Debug
decodeXb3FlagsHeader _ = Nothing


decodeB3SingleHeader :: ByteString -> Maybe B3SingleHeader
decodeB3SingleHeader = parseB3Single


decodeB3SampleHeader :: ByteString -> Maybe SamplingState
decodeB3SampleHeader "1" = Just Accept
decodeB3SampleHeader "0" = Just Deny
decodeB3SampleHeader "d" = Just Debug
decodeB3SampleHeader _ = Nothing


--------------------------------------------------------------------------------

{- | Decode a B3 @X-B3-TraceId@ value: 32 hex chars (128-bit) or 16 hex chars
 (64-bit, zero-padded to 128-bit per B3).
-}
decodeTraceIdFromHex :: ByteString -> Either String TraceId
decodeTraceIdFromHex hexBs
  | BS.length hexBs == 32 = baseEncodedToTraceId Base16 hexBs
  | BS.length hexBs == 16 = do
      sid <- baseEncodedToSpanId Base16 hexBs
      bytesToTraceId (BS.replicate 8 0 <> spanIdBytes sid)
  | otherwise = Left "B3 trace id: expected 16 or 32 hex characters"


data SamplingState = Accept | Deny | Debug | Defer
  deriving (Eq)


{- | Encode a 'SamplingState' as the Sampling State component of the
 @b3@ header value.
-}
printSamplingStateSingle :: SamplingState -> Maybe Text
printSamplingStateSingle = \case
  Accept -> Just "1"
  Deny -> Just "0"
  Debug -> Just "d"
  Defer -> Nothing


printSamplingStateMulti :: SamplingState -> Maybe (Text, Text)
printSamplingStateMulti = \case
  Accept -> Just (xb3SampledHeader, "1")
  Deny -> Just (xb3SampledHeader, "0")
  Debug -> Just (xb3FlagsHeader, "1")
  Defer -> Nothing


-- | Encode a 'SamplingState' as a 'Value'.
samplingStateToValue :: SamplingState -> Value
samplingStateToValue = \case
  Accept -> Value "accept"
  Deny -> Value "deny"
  Debug -> Value "debug"
  Defer -> Value "defer"


-- | Used to decode the 'SamplingState' from a 'TraceState' 'Value'.
samplingStateFromValue :: Value -> Maybe SamplingState
samplingStateFromValue = \case
  Value "accept" -> Just Accept
  Value "deny" -> Just Deny
  Value "debug" -> Just Debug
  Value "defer" -> Just Defer
  _ -> Nothing


data B3SingleHeader = B3SingleHeader
  { traceId :: TraceId
  , spanId :: SpanId
  , samplingState :: SamplingState
  , parentSpanId :: Maybe SpanId
  }


{- | Hand-rolled parser for @{traceId}-{spanId}[-{samplingState}[-{parentSpanId}]]@.
Scans for dash positions instead of using attoparsec.
-}
parseB3Single :: ByteString -> Maybe B3SingleHeader
parseB3Single bs = do
  let !len = BS.length bs
  -- Find the first dash — trace ID is 16 or 32 hex chars
  !dashIdx <- findDash bs 0
  !tid <- either (const Nothing) Just (decodeTraceIdFromHex (BS.take dashIdx bs))
  -- Span ID: next 16 hex chars after the dash
  let !spanStart = dashIdx + 1
      !spanEnd = spanStart + 16
  if spanEnd > len
    then Nothing
    else do
      !sid <- either (const Nothing) Just (baseEncodedToSpanId Base16 (BS.take 16 (BS.drop spanStart bs)))
      -- Optional sampling state and parent span ID
      if spanEnd == len
        then Just $! B3SingleHeader tid sid Defer Nothing
        else do
          guardByte bs spanEnd 0x2d -- '-'
          let !sampStart = spanEnd + 1
          if sampStart >= len
            then Nothing
            else do
              let (!ss, !afterSamp) = parseSamplingAt bs sampStart
              if afterSamp >= len
                then Just $! B3SingleHeader tid sid ss Nothing
                else do
                  guardByte bs afterSamp 0x2d -- '-'
                  let !parentStart = afterSamp + 1
                      !parentEnd = parentStart + 16
                  if parentEnd > len
                    then Nothing
                    else do
                      !psid <- either (const Nothing) Just (baseEncodedToSpanId Base16 (BS.take 16 (BS.drop parentStart bs)))
                      Just $! B3SingleHeader tid sid ss (Just psid)


findDash :: ByteString -> Int -> Maybe Int
findDash bs i
  | i >= BS.length bs = Nothing
  | BS.index bs i == 0x2d = Just i
  | otherwise = findDash bs (i + 1)


guardByte :: ByteString -> Int -> Word8 -> Maybe ()
guardByte bs i expected
  | i < BS.length bs && BS.index bs i == expected = Just ()
  | otherwise = Nothing


parseSamplingAt :: ByteString -> Int -> (SamplingState, Int)
parseSamplingAt bs i
  | i >= BS.length bs = (Defer, i)
  | otherwise = case BS.index bs i of
      0x31 -> (Accept, i + 1) -- '1'
      0x30 -> (Deny, i + 1) -- '0'
      0x64 -> (Debug, i + 1) -- 'd'
      _ -> (Defer, i)


--------------------------------------------------------------------------------

b3Header :: Text
b3Header = "b3"


xb3TraceIdHeader :: Text
xb3TraceIdHeader = "x-b3-traceid"


xb3SpanIdHeader :: Text
xb3SpanIdHeader = "x-b3-spanid"


xb3SampledHeader :: Text
xb3SampledHeader = "x-b3-sampled"


xb3FlagsHeader :: Text
xb3FlagsHeader = "x-b3-flags"


xb3ParentSpanIdHeader :: Text
xb3ParentSpanIdHeader = "x-b3-parentspanid"
