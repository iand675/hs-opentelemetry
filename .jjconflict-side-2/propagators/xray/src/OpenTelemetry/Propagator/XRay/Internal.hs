{-# LANGUAGE BangPatterns #-}
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
decodeXRayHeader = parseXRayKVs


{- | Hand-rolled parser for semicolon-separated key=value pairs.
Extracts Root, Parent, Sampled; ignores other fields.
-}
parseXRayKVs :: ByteString -> Maybe XRayHeader
parseXRayKVs bs = go bs Nothing Nothing Nothing
  where
    go !remaining mRoot mParent mSampled
      | BS.null remaining =
          case (mRoot, mParent) of
            (Just tid, Just sid) -> Just $! XRayHeader tid sid (mSampled == Just True)
            _ -> Nothing
      | otherwise =
          let !trimmed = BS.dropWhile (== charW8 ' ') remaining
              (!key, !afterEq) = BS.break (== charW8 '=') trimmed
          in if BS.null afterEq
               then Nothing -- no '=' found
               else
                 let !valAndRest = BS.drop 1 afterEq -- skip '='
                     (!val, !rest) = breakSemicolon valAndRest
                     !next = skipSpacesAfterSemicolon rest
                 in case () of
                      _
                        | key == "Root" ->
                            case xrayTraceIdToOTel val of
                              Nothing -> Nothing
                              Just !tid -> go next (Just tid) mParent mSampled
                        | key == "Parent" ->
                            case parseSpanIdHex val of
                              Nothing -> Nothing
                              Just !sid -> go next mRoot (Just sid) mSampled
                        | key == "Sampled" ->
                            let !s = val == "1"
                            in go next mRoot mParent (Just s)
                        | otherwise ->
                            go next mRoot mParent mSampled

    breakSemicolon :: ByteString -> (ByteString, ByteString)
    breakSemicolon bs' =
      let (!v, !rest) = BS.break (== charW8 ';') bs'
      in (stripTrailingSpaces v, rest)

    stripTrailingSpaces :: ByteString -> ByteString
    stripTrailingSpaces = fst . BS.spanEnd (== charW8 ' ')

    skipSpacesAfterSemicolon :: ByteString -> ByteString
    skipSpacesAfterSemicolon !rest
      | BS.null rest = rest
      | otherwise =
          let !afterSemi = BS.drop 1 rest -- skip ';'
          in BS.dropWhile (== charW8 ' ') afterSemi


parseSpanIdHex :: ByteString -> Maybe SpanId
parseSpanIdHex bs
  | BS.length bs /= 16 = Nothing
  | otherwise = case baseEncodedToSpanId Base16 bs of
      Left _ -> Nothing
      Right sid -> Just sid


charW8 :: Char -> Word8
charW8 = fromIntegral . fromEnum
