{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

module OpenTelemetry.Propagator.B3 (b3Propagator, b3MultiPropagator) where

import Prelude hiding (takeWhile)
import Data.Maybe (fromMaybe)
import Safe (atMay)
import Control.Applicative ((<|>))
import Data.ByteString (ByteString)
import qualified Data.ByteString as BS
import qualified Data.ByteString.Builder as B
import qualified Data.ByteString.Char8 as BC
import qualified Data.ByteString.Lazy as L
import Data.Char (isHexDigit)
import Data.Word (Word8)
import Network.HTTP.Types (RequestHeaders, ResponseHeaders)
import qualified OpenTelemetry.Context as Ctxt
import OpenTelemetry.Propagator (Propagator (..))
import OpenTelemetry.Trace.Core (
  Span,
  SpanContext (..),
  TraceFlags,
  getSpanContext,
  traceFlagsFromWord8,
  traceFlagsValue,
  wrapSpanContext,
  defaultTraceFlags
 )
import OpenTelemetry.Trace.Id (Base (..), SpanId, TraceId, baseEncodedToSpanId, baseEncodedToTraceId, spanIdBaseEncodedBuilder, traceIdBaseEncodedBuilder)
import OpenTelemetry.Trace.TraceState (TraceState, empty)
import Data.ByteArray.Encoding (
  Base (Base16),
  convertFromBase,
  convertToBase,
 )



{- | Attempt to decode a 'SpanContext' .
-}
decodeSpanContext ::
  -- | @traceId@ header value
  Maybe ByteString ->
  -- | @spanId@ header value
  Maybe ByteString ->
  -- | @sampling@ header value
  Maybe ByteString ->
  Maybe SpanContext
decodeSpanContext Nothing _ _ = Nothing
decodeSpanContext _ Nothing _ = Nothing
decodeSpanContext (Just traceId) (Just spanId) mSamplingH = do
  (tId, sId) <- case decodeIds of
    Left err -> Nothing
    Right tuple  -> Just tuple

  flags <- case mSamplingH of
    Nothing -> Just $ defaultTraceFlags
    Just h -> parseTraceFlags h
  pure $
    SpanContext
      { traceFlags = flags
      , isRemote = True
      , traceId = tId
      , spanId = sId
      , traceState = empty
      }
  where
    decodeIds :: Either String (TraceId, SpanId)
    decodeIds = do
      tid <- baseEncodedToTraceId Base16 traceId
      spid <- baseEncodedToSpanId Base16 spanId
      pure (tid, spid)


bytesToTraceFlags :: ByteString -> Either String TraceFlags
bytesToTraceFlags bs | BS.length bs == 1 = pure $ traceFlagsFromWord8 (head $ BS.unpack bs)
bytesToTraceFlags _ = Left "bytesToTraceFlags: TraceFlag must be 1 bytes long"

parseTraceFlags :: ByteString -> Maybe TraceFlags
parseTraceFlags bs = either (const Nothing) Just $ convertFromBase Base16 bs >>= bytesToTraceFlags


{- | Encoded the given 'Span' into a single b3 header.
-}
encodeSpanContext :: Span -> IO (B.Builder, B.Builder, B.Builder)
encodeSpanContext s = do
  ctxt <- getSpanContext s
  pure $ b3Header ctxt
  where
    b3Header SpanContext {..} =
        ( traceIdBaseEncodedBuilder Base16 traceId
        , spanIdBaseEncodedBuilder Base16 spanId
        , B.word8HexFixed (traceFlagsValue traceFlags)
        )

encodeSpanContextSingle :: Span -> IO ByteString
encodeSpanContextSingle s = do
  (t, s, f) <- encodeSpanContext s
  pure $ L.toStrict $ B.toLazyByteString $ (t <> B.char7 '-' <> s <> B.char7 '-' <> f)



{- | Propagate trace context information via single header using the b3 specification format
-}
b3Propagator :: Propagator Ctxt.Context RequestHeaders ResponseHeaders
b3Propagator = Propagator {..}
  where
    propagatorNames = ["b3 single"]

    extractor hs c = do
      let
          b3 = fromMaybe [] $ BC.split '-' <$> Prelude.lookup "b3" hs
          traceIdHeader = b3 `atMay` 0
          spanIdHeader  = b3 `atMay` 1
          sampledHeader = b3 `atMay` 2
          mSpanContext  = decodeSpanContext traceIdHeader spanIdHeader sampledHeader
      pure $! case mSpanContext of
        Nothing -> c
        Just s -> Ctxt.insertSpan (wrapSpanContext (s {isRemote = True})) c

    injector c hs = case Ctxt.lookupSpan c of
      Nothing -> pure hs
      Just s -> do
        b3 <- encodeSpanContextSingle s
        pure
          ( ("b3", b3) : hs )


{- | Propagate trace context information via multiple b3 specification format headers
-}
b3MultiPropagator :: Propagator Ctxt.Context RequestHeaders ResponseHeaders
b3MultiPropagator = Propagator {..}
  where
    propagatorNames = ["b3 multi"]
    extractor hs c = do
      let
        traceIdHeader = Prelude.lookup "x-b3-traceid" hs
        spanIdHeader  = Prelude.lookup "x-b3-spanid" hs
        sampledHeader = Prelude.lookup "x-b3-sampled" hs
        mSpanContext  = decodeSpanContext traceIdHeader spanIdHeader sampledHeader
      pure $! case mSpanContext of
        Nothing -> c
        Just s -> Ctxt.insertSpan (wrapSpanContext (s {isRemote = True})) c

    injector c hs = case Ctxt.lookupSpan c of
      Nothing -> pure hs
      Just s -> do
        (traceId, spanId, sample) <- encodeSpanContext s
        pure
          ( ("x-b3-traceid", toHeader traceId) : ("x-b3-spanid", toHeader spanId) : ("x-b3-sampled", toHeader sample) : hs )
      where
        toHeader = L.toStrict . B.toLazyByteString

