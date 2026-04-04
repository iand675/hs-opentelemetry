{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
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
) where

--------------------------------------------------------------------------------

import Control.Applicative ((<|>))
import Control.Monad (void)
import qualified Data.Attoparsec.ByteString.Char8 as Atto
import Data.ByteString (ByteString)
import qualified Data.ByteString as BS
import qualified Data.ByteString.Builder as BB
import qualified Data.ByteString.Lazy as BL
import qualified Data.Char as C
import Data.Functor (($>))
import Data.Text (Text)
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
decodeXb3TraceIdHeader tp = case Atto.parseOnly parserTraceId tp of
  Left _ -> Nothing
  Right traceId -> Just traceId


decodeXb3SpanIdHeader :: ByteString -> Maybe SpanId
decodeXb3SpanIdHeader tp = case Atto.parseOnly parserSpanId tp of
  Left _ -> Nothing
  Right spanId -> Just spanId


decodeXb3SampledHeader :: ByteString -> Maybe SamplingState
decodeXb3SampledHeader tp = case Atto.parseOnly parserXb3Sampled tp of
  Left _ -> Nothing
  Right sampled -> Just sampled


decodeXb3FlagsHeader :: ByteString -> Maybe SamplingState
decodeXb3FlagsHeader tp = case Atto.parseOnly parserXb3Flags tp of
  Left _ -> Nothing
  Right flags -> Just flags


decodeB3SingleHeader :: ByteString -> Maybe B3SingleHeader
decodeB3SingleHeader tp = case Atto.parseOnly parserB3Single tp of
  Left _ -> Nothing
  Right b3 -> Just b3


decodeB3SampleHeader :: ByteString -> Maybe SamplingState
decodeB3SampleHeader tp = case Atto.parseOnly parserSamplingState tp of
  Left _ -> Nothing
  Right b3 -> Just b3


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


parserTraceId :: Atto.Parser TraceId
parserTraceId = do
  traceIdBs <- Atto.takeWhile C.isHexDigit
  case decodeTraceIdFromHex traceIdBs of
    Left err -> fail err
    Right traceId -> pure traceId


parserSpanId :: Atto.Parser SpanId
parserSpanId = do
  parentIdBs <- Atto.takeWhile C.isHexDigit
  case baseEncodedToSpanId Base16 parentIdBs of
    Left err -> fail err
    Right ok -> pure ok


data SamplingState = Accept | Deny | Debug | Defer
  deriving (Eq)


-- | Parser for the @x-b3-sampled@ header value.
parserXb3Sampled :: Atto.Parser SamplingState
parserXb3Sampled = accept <|> deny
  where
    accept = "1" $> Accept
    deny = "0" $> Deny


parserXb3Flags :: Atto.Parser SamplingState
parserXb3Flags = "1" $> Debug


{- | Note that this parser is only correct for the B3 single header
 format. In B3 Multi you can only pass a @0@ or @1@ for the sample
 state for 'Accept' and 'Deny' respectively.
-}
parserSamplingState :: Atto.Parser SamplingState
parserSamplingState = accept <|> deny <|> debug
  where
    accept = "1" $> Accept
    deny = "0" $> Deny
    debug = "d" $> Debug


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


parserB3Single :: Atto.Parser B3SingleHeader
parserB3Single = do
  traceId <- parserTraceId
  spanId <- void "-" *> parserSpanId
  samplingState <- Atto.option Defer (void "-" *> parserSamplingState)
  parentSpanId <- Atto.option Nothing (void "-" *> fmap Just parserSpanId)
  pure B3SingleHeader {..}


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
