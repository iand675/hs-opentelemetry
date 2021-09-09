{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
module OpenTelemetry.Propagators.W3CTraceContext where

import Data.Attoparsec.ByteString.Char8
import Data.ByteString (ByteString)
import Data.Char (isHexDigit)
import Data.Text (Text)
import Data.Word (Word8)
import qualified Data.ByteString.Builder as B
import qualified Data.ByteString.Lazy as L
import Network.HTTP.Types
import qualified OpenTelemetry.Context as Ctxt
import OpenTelemetry.Context.Propagators
import OpenTelemetry.Trace
import qualified OpenTelemetry.Trace as Trace
import OpenTelemetry.Trace.Id (TraceId, SpanId, Base(..), spanIdBaseEncodedBuilder, traceIdBaseEncodedBuilder, baseEncodedToTraceId, baseEncodedToSpanId)
import Prelude hiding (takeWhile)

data TraceParent = TraceParent
  { version :: {-# UNPACK #-} !Word8
  , traceId :: {-# UNPACK #-} !TraceId
  , parentId :: {-# UNPACK #-} !SpanId
  , traceFlags :: {-# UNPACK #-} !Word8
  } deriving (Show)

newtype Key = Key Text
  deriving (Eq)

newtype Value = Value Text
  deriving (Eq)

newtype TraceState = TraceState [(Key, Value)]

empty :: TraceState
empty = TraceState []

-- | O(n)
insert :: Key -> Value -> TraceState -> TraceState
insert k v ts = case delete k ts of
  (TraceState l) -> TraceState ((k, v) : l)

-- | O(n)
update :: Key -> (Value -> Value) -> TraceState -> TraceState
update k f (TraceState ts) = case break (\(k', v) -> k == k') ts of
  (before, []) -> TraceState before
  (before, (_, v) : kvs) -> TraceState ((k, f v) : (before ++ kvs))

-- | O(n)
delete :: Key -> TraceState -> TraceState
delete k (TraceState ts) = TraceState $ filter (\(k', _) -> k' /= k) ts

-- | O(1)
toList :: TraceState -> [(Key, Value)]
toList (TraceState ts) = ts

decodeSpanContext :: Maybe ByteString -> Maybe ByteString -> Maybe SpanContext
-- W3C spec says:
-- If a tracestate header is received without an accompanying traceparent header, 
-- it is invalid and MUST be discarded.
decodeSpanContext Nothing _ = Nothing
decodeSpanContext (Just traceparentHeader) mTracestateHeader = do
  TraceParent{..} <- decodeTraceparentHeader traceparentHeader
  ts <- case mTracestateHeader of
    Nothing -> pure empty
    Just tracestateHeader -> pure $ decodeTracestateHeader tracestateHeader
  pure $ SpanContext
    { Trace.traceFlags = traceFlags
    , Trace.isRemote = True
    , Trace.traceId = traceId
    , Trace.spanId = parentId
    , Trace.traceState = [] -- TODO
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
  traceFlags <- hexadecimal
  -- Intentionally not consuming end of input in case of version > 0
  pure $ TraceParent {..}

encodeSpanContext :: Span -> IO (ByteString, ByteString)
encodeSpanContext s = do
  ctxt <- getSpanContext s
  -- TODO tracestate
  pure (L.toStrict $ B.toLazyByteString $ traceparentHeader ctxt, "")
  where
    traceparentHeader SpanContext{..} = 
      -- version
      B.word8HexFixed 0 <>
      B.char7 '-' <>
      traceIdBaseEncodedBuilder Base16 traceId <>
      B.char7 '-' <>
      spanIdBaseEncodedBuilder Base16 spanId <>
      B.char7 '-' <>
      B.word8HexFixed traceFlags

      

w3cTraceContextPropagator :: Propagator Ctxt.Context RequestHeaders ResponseHeaders
w3cTraceContextPropagator = Propagator{..}
  where
    propagatorNames = [ "w3cTraceContext" ]

    extractor hs c = do
      let traceParentHeader = Prelude.lookup "traceparent" hs
          traceStateHeader = Prelude.lookup "tracestate" hs
          mspanContext = decodeSpanContext traceParentHeader traceStateHeader
      pure $! case mspanContext of
        Nothing -> c
        Just s -> Ctxt.insertSpan (createRemoteSpan s) c

    injector c hs = case Ctxt.lookupSpan c of
      Nothing -> pure hs
      Just s -> do
        (traceParentHeader, traceStateHeader) <- encodeSpanContext s
        pure 
          (
            ("traceparent", traceParentHeader) :
            ("tracestate", traceStateHeader) :
            hs
          )
