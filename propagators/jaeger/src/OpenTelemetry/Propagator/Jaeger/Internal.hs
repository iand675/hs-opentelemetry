{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
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

import Control.Monad (void)
import qualified Data.Attoparsec.ByteString.Char8 as Atto
import Data.Bits (Bits ((.&.)))
import Data.ByteString (ByteString)
import qualified Data.ByteString as BS
import qualified Data.ByteString.Builder as BB
import qualified Data.ByteString.Lazy as BL
import qualified Data.Char as C
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
encodeTraceId = BL.toStrict . BB.toLazyByteString . traceIdBaseEncodedBuilder Base16


encodeSpanId :: SpanId -> ByteString
encodeSpanId = BL.toStrict . BB.toLazyByteString . spanIdBaseEncodedBuilder Base16


-- Decoders -------------------------------------------------------------------

decodeUberTraceId :: ByteString -> Maybe JaegerHeader
decodeUberTraceId bs = case Atto.parseOnly parserJaeger bs of
  Left _ -> Nothing
  Right jh -> Just jh


-- Internal parsers -----------------------------------------------------------

decodeTraceIdFromHex :: ByteString -> Either String TraceId
decodeTraceIdFromHex hexBs
  | BS.length hexBs == 32 = baseEncodedToTraceId Base16 hexBs
  | BS.length hexBs == 16 = do
      sid <- baseEncodedToSpanId Base16 hexBs
      bytesToTraceId (BS.replicate 8 0 <> spanIdBytes sid)
  | otherwise = Left "Jaeger trace id: expected 16 or 32 hex characters"


parserTraceId :: Atto.Parser TraceId
parserTraceId = do
  hexBs <- Atto.takeWhile1 C.isHexDigit
  case decodeTraceIdFromHex hexBs of
    Left err -> fail err
    Right tid -> pure tid


parserSpanId :: Atto.Parser SpanId
parserSpanId = do
  hexBs <- Atto.takeWhile1 C.isHexDigit
  case baseEncodedToSpanId Base16 hexBs of
    Left err -> fail err
    Right sid -> pure sid


parserFlags :: Atto.Parser JaegerFlags
parserFlags = do
  hexBs <- Atto.takeWhile1 C.isHexDigit
  case BS.length hexBs of
    1 -> pure $ JaegerFlags (hexVal (BS.index hexBs 0))
    2 -> pure $ JaegerFlags (hexVal (BS.index hexBs 0) * 16 + hexVal (BS.index hexBs 1))
    _ -> fail "Jaeger flags: expected 1-2 hex characters"
  where
    hexVal :: Word8 -> Word8
    hexVal c
      | c >= 0x30 && c <= 0x39 = c - 0x30
      | c >= 0x41 && c <= 0x46 = c - 0x41 + 10
      | c >= 0x61 && c <= 0x66 = c - 0x61 + 10
      | otherwise = 0


-- | The parent span ID field: either a valid hex span ID or literal "0".
parserParentSpanId :: Atto.Parser (Maybe SpanId)
parserParentSpanId = do
  hexBs <- Atto.takeWhile1 C.isHexDigit
  if BS.all (== 0x30) hexBs
    then pure Nothing
    else case baseEncodedToSpanId Base16 hexBs of
      Left _ -> pure Nothing
      Right sid -> pure (Just sid)


parserJaeger :: Atto.Parser JaegerHeader
parserJaeger = do
  jhTraceId <- parserTraceId
  void $ Atto.char ':'
  jhSpanId <- parserSpanId
  void $ Atto.char ':'
  jhParentSpanId <- parserParentSpanId
  void $ Atto.char ':'
  jhFlags <- parserFlags
  Atto.endOfInput
  pure JaegerHeader {..}
