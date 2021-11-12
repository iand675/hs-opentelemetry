module OpenTelemetry.Trace.TraceState 
  ( TraceState
  , Key(..)
  , Value(..)
  , empty
  , insert
  , update
  , delete
  , toList
  ) where

import Data.Text (Text)

newtype Key = Key Text
  deriving (Show, Eq, Ord)

newtype Value = Value Text
  deriving (Show, Eq, Ord)

newtype TraceState = TraceState [(Key, Value)]
  deriving (Show, Eq, Ord)

empty :: TraceState
empty = TraceState []

-- | O(n)
insert :: Key -> Value -> TraceState -> TraceState
insert k v ts = case delete k ts of
  (TraceState l) -> TraceState ((k, v) : l)

-- | O(n)
update :: Key -> (Value -> Value) -> TraceState -> TraceState
update k f (TraceState ts) = case break (\(k', _v) -> k == k') ts of
  (before, []) -> TraceState before
  (before, (_, v) : kvs) -> TraceState ((k, f v) : (before ++ kvs))

-- | O(n)
delete :: Key -> TraceState -> TraceState
delete k (TraceState ts) = TraceState $ filter (\(k', _) -> k' /= k) ts

-- | O(1)
toList :: TraceState -> [(Key, Value)]
toList (TraceState ts) = ts
