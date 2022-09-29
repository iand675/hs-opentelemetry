{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

-----------------------------------------------------------------------------

-----------------------------------------------------------------------------

{- |
 Module      :  OpenTelemetry.Propagators.W3CTraceContext
 Copyright   :  (c) Ian Duncan, 2021
 License     :  BSD-3
 Description :  Standardized trace context propagation format intended for HTTP headers
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)

 Distributed tracing is a methodology implemented by tracing tools to follow, analyze and debug a transaction across multiple software components. Typically, a distributed trace traverses more than one component which requires it to be uniquely identifiable across all participating systems. Trace context propagation passes along this unique identification. Today, trace context propagation is implemented individually by each tracing vendor. In multi-vendor environments, this causes interoperability problems, like:

 - Traces that are collected by different tracing vendors cannot be correlated as there is no shared unique identifier.
 - Traces that cross boundaries between different tracing vendors can not be propagated as there is no uniformly agreed set of identification that is forwarded.
 - Vendor specific metadata might be dropped by intermediaries.
 - Cloud platform vendors, intermediaries and service providers, cannot guarantee to support trace context propagation as there is no standard to follow.
 - In the past, these problems did not have a significant impact as most applications were monitored by a single tracing vendor and stayed within the boundaries of a single platform provider. Today, an increasing number of applications are highly distributed and leverage multiple middleware services and cloud platforms.

 - This transformation of modern applications calls for a distributed tracing context propagation standard.

 This module therefore provides support for tracing context propagation in accordance with the W3C tracing context
 propagation specifications: https://www.w3.org/TR/trace-context/
-}
module OpenTelemetry.Propagator.W3CTraceContext where

import Data.Attoparsec.ByteString.Char8 (
  Parser,
  hexadecimal,
  parseOnly,
  string,
  takeWhile,
 )
import Data.ByteString (ByteString)
import qualified Data.ByteString.Builder as B
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
 )
import OpenTelemetry.Trace.Id (Base (..), SpanId, TraceId, baseEncodedToSpanId, baseEncodedToTraceId, spanIdBaseEncodedBuilder, traceIdBaseEncodedBuilder)
import OpenTelemetry.Trace.TraceState (TraceState, empty)
import Prelude hiding (takeWhile)


{-
TODO: test against the conformance spec:
https://github.com/w3c/trace-context
-}
data TraceParent = TraceParent
  { version :: {-# UNPACK #-} !Word8
  , traceId :: {-# UNPACK #-} !TraceId
  , parentId :: {-# UNPACK #-} !SpanId
  , traceFlags :: {-# UNPACK #-} !TraceFlags
  }
  deriving (Show)


{- | Attempt to decode a 'SpanContext' from optional @traceparent@ and @tracestate@ header inputs.

 @since 0.0.1.0
-}
decodeSpanContext ::
  -- | @traceparent@ header value
  Maybe ByteString ->
  -- | @tracestate@ header value
  Maybe ByteString ->
  Maybe SpanContext
decodeSpanContext Nothing _ = Nothing
decodeSpanContext (Just traceparentHeader) mTracestateHeader = do
  TraceParent {..} <- decodeTraceparentHeader traceparentHeader
  ts <- case mTracestateHeader of
    Nothing -> pure empty
    Just tracestateHeader -> pure $ decodeTracestateHeader tracestateHeader
  pure $
    SpanContext
      { traceFlags = traceFlags
      , isRemote = True
      , traceId = traceId
      , spanId = parentId
      , traceState = ts
      }
  where
    decodeTraceparentHeader :: ByteString -> Maybe TraceParent
    decodeTraceparentHeader tp = case parseOnly traceparentParser tp of
      Left _ -> Nothing
      Right ok -> Just ok

    decodeTracestateHeader :: ByteString -> TraceState
    decodeTracestateHeader _ = empty


traceparentParser :: Parser TraceParent
traceparentParser = do
  version <- hexadecimal
  _ <- string "-"
  traceIdBs <- takeWhile isHexDigit
  traceId <- case baseEncodedToTraceId Base16 traceIdBs of
    Left err -> fail err
    Right ok -> pure ok
  _ <- string "-"
  parentIdBs <- takeWhile isHexDigit
  parentId <- case baseEncodedToSpanId Base16 parentIdBs of
    Left err -> fail err
    Right ok -> pure ok
  _ <- string "-"
  traceFlags <- traceFlagsFromWord8 <$> hexadecimal
  -- Intentionally not consuming end of input in case of version > 0
  pure $ TraceParent {..}


{- | Encoded the given 'Span' into a @traceparent@, @tracestate@ tuple.

 @since 0.0.1.0
-}
encodeSpanContext :: Span -> IO (ByteString, ByteString)
encodeSpanContext s = do
  ctxt <- getSpanContext s
  -- TODO tracestate
  pure (L.toStrict $ B.toLazyByteString $ traceparentHeader ctxt, "")
  where
    traceparentHeader SpanContext {..} =
      -- version
      B.word8HexFixed 0
        <> B.char7 '-'
        <> traceIdBaseEncodedBuilder Base16 traceId
        <> B.char7 '-'
        <> spanIdBaseEncodedBuilder Base16 spanId
        <> B.char7 '-'
        <> B.word8HexFixed (traceFlagsValue traceFlags)


{- | Propagate trace context information via headers using the w3c specification format

 @since 0.0.1.0
-}
w3cTraceContextPropagator :: Propagator Ctxt.Context RequestHeaders ResponseHeaders
w3cTraceContextPropagator = Propagator {..}
  where
    propagatorNames = ["tracecontext"]

    extractor hs c = do
      let traceParentHeader = Prelude.lookup "traceparent" hs
          traceStateHeader = Prelude.lookup "tracestate" hs
          mspanContext = decodeSpanContext traceParentHeader traceStateHeader
      pure $! case mspanContext of
        Nothing -> c
        Just s -> Ctxt.insertSpan (wrapSpanContext (s {isRemote = True})) c

    injector c hs = case Ctxt.lookupSpan c of
      Nothing -> pure hs
      Just s -> do
        (traceParentHeader, traceStateHeader) <- encodeSpanContext s
        pure
          ( ("traceparent", traceParentHeader)
              : ("tracestate", traceStateHeader)
              : hs
          )
