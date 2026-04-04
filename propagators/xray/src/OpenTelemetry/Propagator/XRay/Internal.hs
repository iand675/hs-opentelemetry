{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE Strict #-}

{- | Internal codec for the AWS X-Ray propagation format.

The wire format for the @X-Amzn-Trace-Id@ header is:

@
Root=1-{8hex-epoch}-{24hex-unique};Parent={16hex-spanid};Sampled={0|1}
@

The trace ID is a standard 128-bit value. X-Ray splits it into a 4-byte
epoch timestamp and a 12-byte unique part, separated by dashes and
prefixed with a version number (@1@). Stripping the delimiters yields a
32-hex-char OpenTelemetry trace ID.

See <https://docs.aws.amazon.com/xray/latest/devguide/xray-concepts.html#xray-concepts-tracingheader>.
-}
module OpenTelemetry.Propagator.XRay.Internal (
  -- * Header key
  xrayTraceIdHeader,

  -- * Parsed header
  XRayHeader (..),

  -- * Decoders
  decodeXRayHeader,

  -- * Trace ID conversion
  otelTraceIdToXRay,
  xrayTraceIdToOTel,
) where

import Control.Monad (void, when)
import qualified Data.Attoparsec.ByteString.Char8 as Atto
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
  traceIdBaseEncodedBuilder,
 )


-- Header key -----------------------------------------------------------------

xrayTraceIdHeader :: Text
xrayTraceIdHeader = "x-amzn-trace-id"


-- Parsed header --------------------------------------------------------------

data XRayHeader = XRayHeader
  { xhTraceId :: !TraceId
  , xhSpanId :: !SpanId
  , xhSampled :: !Bool
  }
  deriving (Eq, Show)


-- Trace ID conversion --------------------------------------------------------

-- | Convert an OTel 128-bit trace ID to X-Ray format: @1-{epoch8}-{unique24}@.
otelTraceIdToXRay :: TraceId -> ByteString
otelTraceIdToXRay tid =
  let hex = BL.toStrict $ BB.toLazyByteString $ traceIdBaseEncodedBuilder Base16 tid
      (epoch, unique) = BS.splitAt 8 hex
  in "1-" <> epoch <> "-" <> unique


{- | Parse an X-Ray trace ID (@1-{epoch8}-{unique24}@) into an OTel trace ID.
Returns 'Nothing' on malformed input.
-}
xrayTraceIdToOTel :: ByteString -> Maybe TraceId
xrayTraceIdToOTel bs
  | BS.length bs /= 35 = Nothing
  | BS.index bs 0 /= charW8 '1' = Nothing
  | BS.index bs 1 /= charW8 '-' = Nothing
  | BS.index bs 10 /= charW8 '-' = Nothing
  | otherwise =
      let epoch = BS.take 8 (BS.drop 2 bs)
          unique = BS.drop 11 bs
          combined = epoch <> unique
      in case baseEncodedToTraceId Base16 combined of
          Left _ -> Nothing
          Right tid -> Just tid


-- Decoders -------------------------------------------------------------------

-- | Parse a full @X-Amzn-Trace-Id@ header value.
decodeXRayHeader :: ByteString -> Maybe XRayHeader
decodeXRayHeader bs = case Atto.parseOnly parseXRayHeader bs of
  Left _ -> Nothing
  Right xh -> Just xh


-- Internal parsers -----------------------------------------------------------

{- Parse semicolon-separated key=value pairs. The fields can appear in any
   order. We only care about Root, Parent, and Sampled; extra fields
   (Self, Lineage, etc.) are silently ignored.
-}
parseXRayHeader :: Atto.Parser XRayHeader
parseXRayHeader = do
  kvs <- parseKVPair `Atto.sepBy1` parseSemicolon
  Atto.endOfInput
  traceId <- lookupRequired "Root" kvs >>= parseTraceId
  spanId <- lookupRequired "Parent" kvs >>= parseSpanId
  sampled <- case lookup "Sampled" kvs of
    Nothing -> pure False
    Just v -> parseSampled v
  pure $ XRayHeader traceId spanId sampled
  where
    lookupRequired :: ByteString -> [(ByteString, ByteString)] -> Atto.Parser ByteString
    lookupRequired key kvs = case lookup key kvs of
      Nothing -> fail $ "missing required key: " ++ show key
      Just v -> pure v


parseSemicolon :: Atto.Parser ()
parseSemicolon = do
  Atto.skipWhile (== ' ')
  void $ Atto.char ';'
  Atto.skipWhile (== ' ')


parseKVPair :: Atto.Parser (ByteString, ByteString)
parseKVPair = do
  key <- Atto.takeWhile1 (\c -> c /= '=' && c /= ';' && c /= ' ')
  void $ Atto.char '='
  val <- Atto.takeWhile1 (\c -> c /= ';' && c /= ' ')
  pure (key, val)


parseTraceId :: ByteString -> Atto.Parser TraceId
parseTraceId bs = case xrayTraceIdToOTel bs of
  Nothing -> fail "invalid X-Ray trace ID"
  Just tid -> pure tid


parseSpanId :: ByteString -> Atto.Parser SpanId
parseSpanId bs = do
  when (BS.length bs /= 16) $ fail "invalid X-Ray span ID: expected 16 hex chars"
  case baseEncodedToSpanId Base16 bs of
    Left err -> fail err
    Right sid -> pure sid


parseSampled :: ByteString -> Atto.Parser Bool
parseSampled "1" = pure True
parseSampled "0" = pure False
parseSampled v = fail $ "invalid Sampled value: " ++ show v


charW8 :: Char -> Word8
charW8 = fromIntegral . fromEnum
