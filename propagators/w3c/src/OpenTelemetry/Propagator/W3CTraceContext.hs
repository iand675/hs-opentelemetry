{-# LANGUAGE BangPatterns #-}
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

import Data.ByteString (ByteString)
import qualified Data.ByteString as BS
import qualified Data.ByteString.Char8 as C8
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import Data.Word (Word8)
import qualified OpenTelemetry.Context as Ctxt
import OpenTelemetry.Propagator (Propagator (..), TextMap, textMapInsert, textMapLookup)
import OpenTelemetry.Registry (registerTextMapPropagator)
import OpenTelemetry.Trace.Core (
  Span,
  SpanContext (..),
  getSpanContext,
  traceFlagsFromWord8,
  traceFlagsValue,
  wrapSpanContext,
 )
import OpenTelemetry.Trace.Id (
  decodeTraceparent,
  encodeTraceparent,
 )
import OpenTelemetry.Trace.TraceState (Key (..), TraceState, Value (..), empty, fromList, toList)


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
  (_, tid, sid, fl) <- decodeTraceparent traceparentHeader
  let ts = case mTracestateHeader of
        Nothing -> empty
        Just tracestateHeader -> decodeTraceState tracestateHeader
  pure $!
    SpanContext
      { traceFlags = traceFlagsFromWord8 fl
      , isRemote = True
      , traceId = tid
      , spanId = sid
      , traceState = ts
      }


{- | Parse a W3C tracestate header value into a 'TraceState'.

Format: @OWS list-member *( OWS "," OWS list-member ) OWS@

See: https://www.w3.org/TR/trace-context/#tracestate-header

Returns 'empty' on parse failure.

@since 0.1.0.0
-}
decodeTraceState :: ByteString -> TraceState
decodeTraceState bs = case parseTraceState bs of
  Right ok -> ok
  Left _ -> empty


{- | Parse a W3C tracestate header value.

Invalid list-members are skipped per W3C Trace Context §3.3.1; the result is
always @Right ts@ (use 'empty' when nothing valid remains). The @Either@ type
is retained for backward compatibility.

@since 0.1.0.0
-}
parseTraceState :: ByteString -> Either String TraceState
parseTraceState bs =
  let !trimmed = C8.dropWhile isOWS bs
  in if BS.null trimmed
      then Right empty
      else Right $! fromList (go trimmed [])
  where
    go !remaining !acc
      | BS.null remaining = reverse acc
      | otherwise =
          case scanMember remaining of
            Right (!pair, !rest) ->
              let !rest' = skipCommaOWS rest
              in go rest' (pair : acc)
            Left _err ->
              let !rest = skipToNextMember remaining
              in go rest acc

    scanMember :: ByteString -> Either String ((Key, Value), ByteString)
    scanMember !input = do
      (!key, !afterKey) <- scanKey input
      if BS.null afterKey || BS.index afterKey 0 /= 0x3d
        then Left "expected '=' after key"
        else do
          let !valStart = BS.drop 1 afterKey
          (!val, !afterVal) <- scanValue valStart
          Right ((Key (TE.decodeUtf8 key), Value (TE.decodeUtf8 val)), afterVal)

    skipToNextMember :: ByteString -> ByteString
    skipToNextMember !input =
      case C8.elemIndex ',' input of
        Nothing -> BS.empty
        Just idx -> C8.dropWhile isOWS (BS.drop (idx + 1) input)

    scanKey :: ByteString -> Either String (ByteString, ByteString)
    scanKey !input =
      let !keyLen = BS.length (C8.takeWhile isTracestateKeyChar input)
      in if keyLen == 0
          then Left "empty tracestate key"
          else
            let !keyBs = BS.take keyLen input
            in if keyLen > 256
                then Left "tracestate key too long"
                else validateKey keyBs >> Right (keyBs, BS.drop keyLen input)

    validateKey :: ByteString -> Either String ()
    validateKey !keyBs =
      case C8.elemIndex '@' keyBs of
        Nothing ->
          if not (isLcAlpha (BS.index keyBs 0))
            then Left "simple tracestate key must start with a-z"
            else Right ()
        Just atIdx ->
          let !tenantPart = BS.take atIdx keyBs
              !systemPart = BS.drop (atIdx + 1) keyBs
          in if BS.null tenantPart
              then Left "empty tenant-id in multi-tenant key"
              else
                if BS.null systemPart
                  then Left "empty system-id in multi-tenant key"
                  else
                    if not (isLcAlphaOrDigit (BS.index tenantPart 0))
                      then Left "tenant-id must start with a-z or 0-9"
                      else
                        if not (isLcAlpha (BS.index systemPart 0))
                          then Left "system-id must start with a-z"
                          else
                            if C8.elem '@' systemPart
                              then Left "multiple '@' in tracestate key"
                              else
                                if BS.length tenantPart > 241
                                  then Left "tenant-id too long"
                                  else
                                    if BS.length systemPart > 14
                                      then Left "system-id too long"
                                      else Right ()

    isLcAlpha :: Word8 -> Bool
    isLcAlpha w = w >= 0x61 && w <= 0x7a

    isLcAlphaOrDigit :: Word8 -> Bool
    isLcAlphaOrDigit w = isLcAlpha w || (w >= 0x30 && w <= 0x39)

    scanValue :: ByteString -> Either String (ByteString, ByteString)
    scanValue !input =
      let !valLen = BS.length (C8.takeWhile isTracestateValueChar input)
      in if valLen == 0
          then Left "empty tracestate value"
          else
            let !raw = BS.take valLen input
                !stripped = fst (BS.spanEnd isOWSByte raw)
            in if BS.null stripped
                then Left "tracestate value is only whitespace"
                else
                  if BS.length stripped > 256
                    then Left "tracestate value too long"
                    else Right (stripped, BS.drop valLen input)

    skipCommaOWS :: ByteString -> ByteString
    skipCommaOWS !input =
      let !s1 = C8.dropWhile isOWS input
      in if BS.null s1
          then s1
          else
            if BS.index s1 0 == 0x2c -- ','
              then C8.dropWhile isOWS (BS.drop 1 s1)
              else s1


isOWS :: Char -> Bool
isOWS c = c == ' ' || c == '\t'


isOWSByte :: Word8 -> Bool
isOWSByte w = w == 0x20 || w == 0x09


isTracestateKeyChar :: Char -> Bool
isTracestateKeyChar c =
  (c >= 'a' && c <= 'z')
    || (c >= '0' && c <= '9')
    || c == '_'
    || c == '-'
    || c == '*'
    || c == '/'
    || c == '@'


isTracestateValueChar :: Char -> Bool
isTracestateValueChar c =
  c == ' ' || (c >= '!' && c <= '+') || (c >= '-' && c <= '<') || (c >= '>' && c <= '~')


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
      let currentSize = if null acc then 0 else sum (map C8.length acc) + length acc - 1
          newSize = currentSize + C8.length entry + if null acc then 0 else 1
      in if newSize <= limit || null acc
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
      else decodeTraceState combinedHeader


{- | Encoded the given 'Span' into a @traceparent@, @tracestate@ tuple.

 @since 0.0.1.0
-}
encodeSpanContext :: Span -> IO (ByteString, ByteString)
encodeSpanContext s = do
  ctxt <- getSpanContext s
  let !tp = encodeTraceparent 0 (traceId ctxt) (spanId ctxt) (traceFlagsValue (traceFlags ctxt))
  pure (tp, encodeTraceState (traceState ctxt))


{- | Propagate trace context information via headers using the w3c specification format

 @since 0.0.1.0
-}
w3cTraceContextPropagator :: Propagator Ctxt.Context TextMap TextMap
w3cTraceContextPropagator = Propagator {..}
  where
    propagatorFields = ["traceparent", "tracestate"]

    extractor tm c = do
      let traceParentHeader = TE.encodeUtf8 <$> textMapLookup "traceparent" tm
          combinedTraceState = TE.encodeUtf8 <$> textMapLookup "tracestate" tm
          mspanContext = decodeSpanContext traceParentHeader combinedTraceState
      pure $! case mspanContext of
        Nothing -> c
        Just s -> Ctxt.insertSpan (wrapSpanContext (s {isRemote = True})) c

    injector c tm = case Ctxt.lookupSpan c of
      Nothing -> pure tm
      Just s -> do
        (traceParentHeader, traceStateHeader) <- encodeSpanContext s
        pure $
          textMapInsert "traceparent" (TE.decodeUtf8 traceParentHeader) $
            textMapInsert "tracestate" (TE.decodeUtf8 traceStateHeader) $
              tm


{- | Register the W3C Trace Context propagator under the name
@\"tracecontext\"@ in the global registry.

@since 0.1.0.0
-}
registerW3CTraceContextPropagator :: IO ()
registerW3CTraceContextPropagator =
  registerTextMapPropagator "tracecontext" w3cTraceContextPropagator
