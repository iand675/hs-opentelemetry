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
  char,
  endOfInput,
  hexadecimal,
  parseOnly,
  sepBy,
  skipSpace,
  string,
  takeWhile,
  takeWhile1,
 )
import Data.ByteString (ByteString)
import qualified Data.ByteString.Builder as B
import qualified Data.ByteString.Char8 as C8
import qualified Data.ByteString.Lazy as L
import Data.Char (isHexDigit)
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import Data.Word (Word8)
import Network.HTTP.Types (RequestHeaders)
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
import OpenTelemetry.Trace.TraceState (Key (..), TraceState, Value (..), empty, fromList, toList)
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
decodeSpanContext
  :: Maybe ByteString
  -- ^ @traceparent@ header value
  -> Maybe ByteString
  -- ^ @tracestate@ header value
  -> Maybe SpanContext
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
    decodeTracestateHeader ts = case parseOnly tracestateParser ts of
      Left _ -> empty
      Right ok -> ok


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


{- | Parser for W3C tracestate header format
Format: OWS list-member *( OWS "," OWS list-member ) OWS
See: https://www.w3.org/TR/trace-context/#tracestate-header
-}
tracestateParser :: Parser TraceState
tracestateParser = do
  skipSpace
  pairs <- tracestateEntry `sepBy` (skipSpace >> char ',' >> skipSpace)
  skipSpace
  endOfInput
  -- Limit to 32 entries as per spec, take first 32 if more
  let limitedPairs = take 32 pairs
  pure $ fromList [(Key k, Value v) | (k, v) <- limitedPairs]
  where
    -- Parse a single key=value entry (list-member)
    tracestateEntry = do
      key <- tracestateKey
      _ <- char '='
      value <- tracestateValue
      pure (key, value)

    -- Parse tracestate key according to W3C spec
    -- key = simple-key / multi-tenant-key
    -- simple-key = lcalpha 0*255( lcalpha / DIGIT / "_" / "-"/ "*" / "/" )
    -- multi-tenant-key = tenant-id "@" system-id
    tracestateKey = do
      keyBytes <- takeWhile1 isTracestateKeyChar
      let keyText = TE.decodeUtf8 keyBytes
      -- Validate key format and length (max 256 chars)
      if T.length keyText <= 256 && isValidTracestateKey keyText
        then pure keyText
        else fail "Invalid tracestate key"

    -- Parse tracestate value according to W3C spec
    -- value = 0*255(chr) nblk-chr
    -- chr = %x20 / %x21-2B / %x2D-3C / %x3E-7E
    -- nblk-chr = %x21-2B / %x2D-3C / %x3E-7E
    tracestateValue = do
      valueBytes <- takeWhile1 isTracestateValueChar
      let valueText = T.stripEnd $ TE.decodeUtf8 valueBytes -- Strip trailing whitespace
      -- Validate value length (max 256 chars)
      if T.length valueText <= 256 && not (T.null valueText)
        then pure valueText
        else fail "Invalid tracestate value"

    -- Valid characters for tracestate keys
    isTracestateKeyChar c =
      (c >= 'a' && c <= 'z')
        || (c >= '0' && c <= '9')
        || c == '_'
        || c == '-'
        || c == '*'
        || c == '/'
        || c == '@'

    -- Valid characters for tracestate values (chr)
    -- %x20 / %x21-2B / %x2D-3C / %x3E-7E (excludes comma and equals)
    isTracestateValueChar c =
      c == ' ' || (c >= '!' && c <= '+') || (c >= '-' && c <= '<') || (c >= '>' && c <= '~')

    -- Validate tracestate key format
    isValidTracestateKey key =
      case T.uncons key of
        Nothing -> False
        Just (firstChar, rest) ->
          -- Must start with lowercase letter or digit
          (firstChar >= 'a' && firstChar <= 'z' || firstChar >= '0' && firstChar <= '9')
            &&
            -- Rest must be valid key characters
            T.all
              ( \c ->
                  (c >= 'a' && c <= 'z')
                    || (c >= '0' && c <= '9')
                    || c == '_'
                    || c == '-'
                    || c == '*'
                    || c == '/'
                    || c == '@'
              )
              rest


-- | Encode TraceState to W3C tracestate header format
encodeTraceState :: TraceState -> ByteString
encodeTraceState ts =
  let pairs = toList ts
      -- Limit to 32 entries as per spec
      limitedPairs = take 32 pairs
      encodedPairs = map (\(Key k, Value v) -> TE.encodeUtf8 k <> "=" <> TE.encodeUtf8 v) limitedPairs
  in C8.intercalate "," encodedPairs


{- | Encode TraceState for non-HTTP contexts (like OTLP binary format).

 This function preserves all tracestate entries without applying HTTP header
 constraints like the 32-entry limit. Use this for binary protocols where
 the full tracestate should be preserved.

 @since 0.0.1.5
-}
encodeTraceStateFull :: TraceState -> ByteString
encodeTraceStateFull ts =
  let pairs = toList ts
      encodedPairs = map (\(Key k, Value v) -> TE.encodeUtf8 k <> "=" <> TE.encodeUtf8 v) pairs
  in C8.intercalate "," encodedPairs


{- | Split a TraceState into multiple tracestate header values based on size constraints.

 This function respects the W3C recommendation that vendors should propagate at least
 512 characters, while following RFC7230 rules for splitting header fields.

 When splitting is needed:
 - Entries larger than 128 characters are removed first (as per W3C spec)
 - Remaining entries are split to keep each header under the size limit
 - Entry order is preserved within each header

 @since 0.0.1.5
-}
encodeTraceStateMultiple
  :: Int
  -- ^ Maximum size per header (e.g., 512 for minimum recommended size)
  -> TraceState
  -> [ByteString]
  -- ^ List of tracestate header values
encodeTraceStateMultiple maxSize ts =
  let pairs = toList ts
      -- Limit to 32 entries as per spec, then filter out oversized entries
      limitedPairs = take 32 pairs
      filteredPairs = filter (\(Key k, Value v) -> T.length k + T.length v + 1 <= 128) limitedPairs
      encodedPairs = map (\(Key k, Value v) -> TE.encodeUtf8 k <> "=" <> TE.encodeUtf8 v) filteredPairs
  in splitIntoHeaders maxSize encodedPairs
  where
    splitIntoHeaders :: Int -> [ByteString] -> [ByteString]
    splitIntoHeaders _ [] = []
    splitIntoHeaders limit entries =
      let (currentHeader, remaining) = buildHeader limit entries []
      in if C8.null currentHeader
          then []
          else currentHeader : splitIntoHeaders limit remaining

    buildHeader :: Int -> [ByteString] -> [ByteString] -> (ByteString, [ByteString])
    buildHeader _ [] acc = (C8.intercalate "," (reverse acc), [])
    buildHeader limit (entry : rest) acc =
      let currentSize = if null acc then 0 else sum (map C8.length acc) + length acc - 1 -- account for commas
          newSize = currentSize + C8.length entry + if null acc then 0 else 1
      in if newSize <= limit || null acc -- Always include at least one entry
          then buildHeader limit rest (entry : acc)
          else (C8.intercalate "," (reverse acc), entry : rest)


{- | Combine multiple tracestate header values into a single TraceState.

 This function implements RFC7230 Section 3.2.2 rules for combining multiple
 header fields with the same name. Header values are combined with commas
 in the order provided.

 Invalid entries are skipped with a fallback to empty TraceState on complete failure.

 @since 0.0.1.5
-}
decodeTraceStateMultiple :: [ByteString] -> TraceState
decodeTraceStateMultiple headers =
  let nonEmptyHeaders = filter (not . C8.all (\c -> c == ' ' || c == '\t')) headers
      combinedHeader = C8.intercalate "," nonEmptyHeaders
  in if C8.null combinedHeader
      then empty
      else case parseOnly tracestateParser combinedHeader of
        Right ts -> ts
        Left _ -> empty -- Fallback to empty on parse failure


{- | Encoded the given 'Span' into a @traceparent@, @tracestate@ tuple.

 @since 0.0.1.0
-}
encodeSpanContext :: Span -> IO (ByteString, ByteString)
encodeSpanContext s = do
  ctxt <- getSpanContext s
  pure (L.toStrict $ B.toLazyByteString $ traceparentHeader ctxt, encodeTraceState (traceState ctxt))
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
w3cTraceContextPropagator :: Propagator Ctxt.Context RequestHeaders RequestHeaders
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
