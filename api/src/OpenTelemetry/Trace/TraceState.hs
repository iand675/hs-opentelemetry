-----------------------------------------------------------------------------

-----------------------------------------------------------------------------

{- |
 Module      :  OpenTelemetry.Trace.TraceState
 Copyright   :  (c) Ian Duncan, 2021
 License     :  BSD-3
 Description :  W3C-compliant way to provide additional vendor-specific trace identification information across different distributed tracing systems
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)

 The main purpose of the tracestate HTTP header is to provide additional vendor-specific trace identification information across different distributed tracing systems and is a companion header for the traceparent field. It also conveys information about the request’s position in multiple distributed tracing graphs.

 The tracestate field may contain any opaque value in any of the keys. Tracestate MAY be sent or received as multiple header fields. Multiple tracestate header fields MUST be handled as specified by RFC7230 Section 3.2.2 Field Order. The tracestate header SHOULD be sent as a single field when possible, but MAY be split into multiple header fields. When sending tracestate as multiple header fields, it MUST be split according to RFC7230. When receiving multiple tracestate header fields, they MUST be combined into a single header according to RFC7230.

 See the W3C specification https://www.w3.org/TR/trace-context/#tracestate-header
 for more details.
-}
module OpenTelemetry.Trace.TraceState (
  TraceState (TraceState),
  Key (..),
  Value (..),
  empty,
  fromList,
  insert,
  update,
  delete,
  toList,
) where

import Data.Text (Text)


newtype Key = Key Text
  deriving (Show, Eq, Ord)


newtype Value = Value Text
  deriving (Show, Eq, Ord)


{- | Data structure compliant with the storage and serialization needs of
 the W3C @tracestate@ header.
-}
newtype TraceState = TraceState [(Key, Value)]
  deriving (Show, Eq, Ord)


-- | An empty 'TraceState' key-value pair dictionary
empty :: TraceState
empty = TraceState []


{- | Create a 'TraceState' from a list of key-value pairs

 O(1)
-}
fromList :: [(Key, Value)] -> TraceState
fromList = TraceState


{- | Add a key-value pair to a 'TraceState'

 O(n)
-}
insert :: Key -> Value -> TraceState -> TraceState
insert k v ts = case delete k ts of
  (TraceState l) -> TraceState ((k, v) : l)


{- | Update a value in the 'TraceState'. Does nothing if
 the value associated with the given key doesn't exist.

 O(n)
-}
update :: Key -> (Value -> Value) -> TraceState -> TraceState
update k f (TraceState ts) = case break (\(k', _v) -> k == k') ts of
  (before, []) -> TraceState before
  (before, (_, v) : kvs) -> TraceState ((k, f v) : (before ++ kvs))


{- | Remove a key-value pair for the given key.

 O(n)
-}
delete :: Key -> TraceState -> TraceState
delete k (TraceState ts) = TraceState $ filter (\(k', _) -> k' /= k) ts


{- | Convert the 'TraceState' to a list.

 O(1)
-}
toList :: TraceState -> [(Key, Value)]
toList (TraceState ts) = ts
