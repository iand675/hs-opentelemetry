{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
module OpenTelemetry.Propagators.W3CTraceContext where

import Data.ByteString (ByteString)
import Network.HTTP.Types
import OpenTelemetry.Context
import OpenTelemetry.Context.Propagators
import OpenTelemetry.Trace

data TraceParent = TraceParent
  { version :: {-# UNPACK #-} !Word8
  , traceId :: {-# UNPACK #-} !TraceId
  , parentId :: {-# UNPACK #-} !SpanId
  , traceFlags :: {-# UNPACK #-} !Word8
  }

newtype Key = Key Text
newtype Value = Key Text

newtype TraceState = TraceState [(Key, Value)]

empty :: TraceState
empty = TraceState []

insert :: Key -> Value -> TraceState -> TraceState
insert k v ts = case delete k v ts of
  (TraceState l) -> TraceState ((k, v) : l)

update :: Key -> (Value -> Value) -> TraceState -> TraceState
update k f (TraceState ts) = case break (\(k', v) -> k == k') of
  (before, []) -> TraceState before
  (before, (_, v) : kvs) -> TraceState ((k, f v) : (before ++ kvs))

delete :: Key -> TraceState -> TraceState
delete k (TraceState ts) = TraceState $ filter (\(k', _) -> k' /= k) ts

toList :: TraceState -> [(Key, Value)]
toList (TraceState ts) = ts

decodeSpanContext :: Maybe ByteString -> Maybe ByteString -> IO (Maybe Span)
decodeSpanContext _ _ = pure Nothing

encodeSpanContext :: Span -> IO (ByteString, ByteString)
encodeSpanContext _ = pure ()
  where
    traceparentHeader = 
      -- version
      word8HexFixed 0 <>
      char7 '-' <>
      encodeTraceId _ <>
      char7 '-' <>
      encodeSpanId _ <>
      char7 '-' <>
      word8HexFixed traceFlags

      

w3cTraceContextPropagator :: Propagator Context RequestHeaders ResponseHeaders
w3cTraceContextPropagator = Propagator{..}
  where
    propagatorNames = [ "w3cTraceContext" ]

    extractor hs c = do
      let traceParentHeader = Prelude.lookup "traceparent" hs
          traceStateHeader = Prelude.lookup "tracestate" hs
      mspanContext <- decodeSpanContext traceParentHeader traceStateHeader
      pure $! case mspanContext of
        Nothing -> c
        Just s -> insertSpan s c

    injector c hs = case lookupSpan c of
      Nothing -> pure hs
      Just s -> do
        (traceParentHeader, traceStateHeader) <- encodeSpanContext s
        pure 
          (
            ("traceparent", traceParentHeader) :
            ("tracestate", traceStateHeader) :
            hs
          )
