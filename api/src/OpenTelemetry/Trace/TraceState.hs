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
  lookup,
  insert,
  update,
  delete,
  toList,
  maxTraceStateEntries,
) where

import Data.List (find)
import Data.Text (Text)
import Prelude hiding (lookup)


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


{- | Create a 'TraceState' from a list of key-value pairs.

Silently truncates to 32 entries (W3C spec limit).

 O(n) when list exceeds 32 entries, O(1) otherwise.
-}
fromList :: [(Key, Value)] -> TraceState
fromList = TraceState . take maxTraceStateEntries


{- | Get the value associated with a given key.

 O(n)
-}
lookup :: Key -> TraceState -> Maybe Value
lookup k (TraceState ts) = snd <$> find (\(k', _) -> k' == k) ts


{- | Add a key-value pair to a 'TraceState'.

If the key already exists, the entry is updated and moved to the front.
The W3C spec limits tracestate to 32 list-members; if inserting a new key
would exceed that limit, the rightmost (oldest) entry is dropped.

 O(n)
-}
insert :: Key -> Value -> TraceState -> TraceState
insert k v ts = case delete k ts of
  (TraceState l) -> TraceState $ take maxTraceStateEntries ((k, v) : l)


-- | W3C spec maximum: 32 list-members.
maxTraceStateEntries :: Int
maxTraceStateEntries = 32


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
