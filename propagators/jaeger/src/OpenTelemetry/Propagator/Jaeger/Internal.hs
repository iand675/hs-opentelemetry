{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE Strict #-}

{- | Internal codec for the Jaeger propagation format.

The wire format for the @uber-trace-id@ header is:

@
{trace-id}:{span-id}:{parent-span-id}:{flags}
@

See <https://www.jaegertracing.io/docs/1.21/client-libraries/#propagation-format>.
-}
module OpenTelemetry.Propagator.Jaeger.Internal (
  -- * Encoders
  encodeTraceId,
  encodeSpanId,
  encodeUberTraceId,

  -- * Decoders
  decodeUberTraceId,

  -- * Parsed header
  JaegerHeader (..),

  -- * Flags
  JaegerFlags (..),
  flagsSampled,
  flagsDebug,

  -- * Header keys
  uberTraceIdHeader,
  uberBaggagePrefix,
) where

import Data.Bits (Bits ((.&.)))
import Data.ByteString (ByteString)
import qualified Data.ByteString as BS
import Data.Text (Text)
import Data.Word (Word8)
import OpenTelemetry.Trace.Id (
  Base (..),
  SpanId,
  TraceId,
  baseEncodedToSpanId,
  baseEncodedToTraceId,
  bytesToTraceId,
  spanIdBaseEncodedByteString,
  spanIdBytes,
  traceIdBaseEncodedByteString,
 )


-- Header keys ----------------------------------------------------------------

uberTraceIdHeader :: Text
uberTraceIdHeader = "uber-trace-id"


uberBaggagePrefix :: Text
uberBaggagePrefix = "uberctx-"


-- Flags ----------------------------------------------------------------------

-- | Jaeger flags byte from the wire format.
newtype JaegerFlags = JaegerFlags Word8
  deriving (Eq, Show)


flagsSampled :: JaegerFlags -> Bool
flagsSampled (JaegerFlags f) = f .&. 0x01 /= 0


flagsDebug :: JaegerFlags -> Bool
flagsDebug (JaegerFlags f) = f .&. 0x02 /= 0


-- Parsed header --------------------------------------------------------------

data JaegerHeader = JaegerHeader
  { jhTraceId :: !TraceId
  , jhSpanId :: !SpanId
  , jhParentSpanId :: !(Maybe SpanId)
  , jhFlags :: !JaegerFlags
  }
  deriving (Eq, Show)


-- Encoders -------------------------------------------------------------------

encodeTraceId :: TraceId -> ByteString
encodeTraceId = traceIdBaseEncodedByteString Base16
{-# INLINE encodeTraceId #-}


encodeSpanId :: SpanId -> ByteString
encodeSpanId = spanIdBaseEncodedByteString Base16
{-# INLINE encodeSpanId #-}


{- | Encode a Jaeger uber-trace-id header value directly as a ByteString.

Format: @{trace-id}:{span-id}:0:{flags}@
-}
encodeUberTraceId :: TraceId -> SpanId -> Bool -> ByteString
encodeUberTraceId tid sid sampled =
  traceIdBaseEncodedByteString Base16 tid
    <> ":"
    <> spanIdBaseEncodedByteString Base16 sid
    <> ":0:"
    <> if sampled then "1" else "0"


-- Decoders -------------------------------------------------------------------

{- | Decode a Jaeger @uber-trace-id@ header value.

Uses memchr to locate colon delimiters and the existing SIMD hex
decoders for trace/span ID parsing.
-}
decodeUberTraceId :: ByteString -> Maybe JaegerHeader
decodeUberTraceId bs = do
  let !len = BS.length bs
  -- Need at least: 16 (tid) + 1 (:) + 1 (sid) + 1 (:) + 1 (parent) + 1 (:) + 1 (flags) = 22
  if len < 22
    then Nothing
    else do
      -- Find three colons via memchr.
      !c1 <- BS.elemIndex 0x3a bs
      !c2rel <- BS.elemIndex 0x3a (BS.drop (c1 + 1) bs)
      let !c2 = c1 + 1 + c2rel
      !c3rel <- BS.elemIndex 0x3a (BS.drop (c2 + 1) bs)
      let !c3 = c2 + 1 + c3rel

      -- Reject extra colons (trailing garbage).
      case BS.elemIndex 0x3a (BS.drop (c3 + 1) bs) of
        Just _ -> Nothing
        Nothing -> do
          let !tidHex = BS.take c1 bs
              !sidHex = BS.take c2rel (BS.drop (c1 + 1) bs)
              !parentHex = BS.take c3rel (BS.drop (c2 + 1) bs)
              !flagsHex = BS.drop (c3 + 1) bs

          -- Flags: 1-2 hex digits, validated first (cheapest check).
          !flags <- parseFlags flagsHex

          -- Trace ID: 16 or 32 hex chars.
          !tid <- eitherToMaybe (decodeTraceIdFromHex tidHex)

          -- Span ID: must be valid hex (length validated by baseEncodedToSpanId).
          !sid <- eitherToMaybe (baseEncodedToSpanId Base16 sidHex)

          -- Parent span ID: all-zeros means "no parent".
          let !parentSid
                | BS.null parentHex = Nothing
                | BS.all (== 0x30) parentHex = Nothing
                | otherwise = eitherToMaybe (baseEncodedToSpanId Base16 parentHex)

          pure
            JaegerHeader
              { jhTraceId = tid
              , jhSpanId = sid
              , jhParentSpanId = parentSid
              , jhFlags = flags
              }


-- Internal helpers -----------------------------------------------------------

{- | Decode a trace ID from hex, accepting both 64-bit (16 chars, zero-padded)
and 128-bit (32 chars) representations.
-}
decodeTraceIdFromHex :: ByteString -> Either String TraceId
decodeTraceIdFromHex hexBs
  | BS.length hexBs == 32 = baseEncodedToTraceId Base16 hexBs
  | BS.length hexBs == 16 = do
      sid <- baseEncodedToSpanId Base16 hexBs
      bytesToTraceId (BS.replicate 8 0 <> spanIdBytes sid)
  | otherwise = Left "Jaeger trace id: expected 16 or 32 hex characters"


-- | Parse 1-2 hex characters into a flags byte.
parseFlags :: ByteString -> Maybe JaegerFlags
parseFlags flagsHex = case BS.length flagsHex of
  1 -> do
    !a <- hexNibble (BS.index flagsHex 0)
    Just $! JaegerFlags a
  2 -> do
    !a <- hexNibble (BS.index flagsHex 0)
    !b <- hexNibble (BS.index flagsHex 1)
    Just $! JaegerFlags (a * 16 + b)
  _ -> Nothing


hexNibble :: Word8 -> Maybe Word8
hexNibble c
  | c >= 0x30 && c <= 0x39 = Just (c - 0x30)
  | c >= 0x41 && c <= 0x46 = Just (c - 0x41 + 10)
  | c >= 0x61 && c <= 0x66 = Just (c - 0x61 + 10)
  | otherwise = Nothing
{-# INLINE hexNibble #-}


eitherToMaybe :: Either a b -> Maybe b
eitherToMaybe (Right x) = Just x
eitherToMaybe (Left _) = Nothing
{-# INLINE eitherToMaybe #-}
