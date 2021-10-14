{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE ExistentialQuantification #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE DataKinds #-}
module OpenTelemetry.Internal.Trace.Types where

import Control.Concurrent.Async (Async)
import Control.Exception (SomeException)
import Data.ByteString (ByteString)
import Data.ByteString.Short (ShortByteString)
import Data.IORef (IORef)
import Data.Word (Word8)
import Data.Text (Text)
import Data.Hashable (Hashable)
import Data.Vector (Vector)
import OpenTelemetry.Context.Types
import OpenTelemetry.Resource
import OpenTelemetry.Internal.Trace.Id
import OpenTelemetry.Trace.IdGenerator
import System.Clock (TimeSpec)

data ExportResult
  = Success
  | Failure SomeException

data SpanExporter = SpanExporter
  { export :: forall f. Foldable f => f ImmutableSpan -> IO ExportResult
  , shutdown :: IO ()
  }

data ShutdownResult = ShutdownSuccess | ShutdownFailure | ShutdownTimeout

data SpanProcessor = SpanProcessor
  { onStart :: IORef ImmutableSpan -> Context -> IO ()
  , onEnd :: IORef ImmutableSpan -> IO ()
  , shutdown :: IO (Async ShutdownResult)
  , forceFlush :: IO ()
  }

data TracerProvider = forall s. TracerProvider 
  { tracerProviderProcessors :: Vector SpanProcessor
  , tracerProviderIdGenerator :: IdGenerator
  , tracerProviderResources :: Resource s
  -- ^ TODO schema support
  }

type TracerName = Text

data Tracer = Tracer
  { tracerProcessors :: Vector SpanProcessor
  , tracerIdGenerator :: IdGenerator
  , tracerResources :: [(Text, Attribute)]
  }

type Time = TimeSpec
type Timestamp = TimeSpec
type Duration = TimeSpec

type SpanParent = Maybe Context

data Link = Link
  { linkContext :: SpanContext
  , linkAttributes :: [(Text, Attribute)]
  }
  deriving (Show)

data CreateSpanArguments = CreateSpanArguments
  { startingKind :: SpanKind
  , startingLinks :: [Link]
  , startingTimestamp :: Maybe Timestamp
  }

data FlushResult = FlushTimeout | FlushSuccess
  deriving (Show)

data SpanKind = Server | Client | Producer | Consumer | Internal
  deriving (Show)
data TraceFlags = TraceFlags
  deriving (Show)

data SpanStatus = Unset | Error Text | Ok
  deriving (Show, Eq, Ord)

data ImmutableSpan = ImmutableSpan
  { spanName :: Text
  , spanParent :: Maybe Span
  , spanContext :: SpanContext
  , spanKind :: SpanKind
  , spanStart :: Timestamp
  , spanEnd :: Maybe Timestamp
  , spanAttributes :: [(Text, Attribute)]
  -- ^ TODO, this should probably be a DList
  -- | TODO Links SHOULD preserve the order in which they're set
  , spanLinks :: [Link]
  , spanEvents :: [Event]
  , spanStatus :: SpanStatus
  , spanTracer :: Tracer
  -- ^ Creator of the span
  }

data Span 
  = Span (IORef ImmutableSpan)
  | FrozenSpan SpanContext

-- | A `SpanContext` represents the portion of a `Span` which must be serialized and
-- propagated along side of a distributed context. `SpanContext`s are immutable.

-- The OpenTelemetry `SpanContext` representation conforms to the [W3C TraceContext
-- specification](https://www.w3.org/TR/trace-context/). It contains two
-- identifiers - a `TraceId` and a `SpanId` - along with a set of common
-- `TraceFlags` and system-specific `TraceState` values.

-- `TraceId` A valid trace identifier is a 16-byte array with at least one
-- non-zero byte.

-- `SpanId` A valid span identifier is an 8-byte array with at least one non-zero
-- byte.

-- `TraceFlags` contain details about the trace. Unlike TraceState values,
-- TraceFlags are present in all traces. The current version of the specification
-- only supports a single flag called [sampled](https://www.w3.org/TR/trace-context/#sampled-flag).

-- `TraceState` carries vendor-specific trace identification data, represented as a list
-- of key-value pairs. TraceState allows multiple tracing
-- systems to participate in the same trace. It is fully described in the [W3C Trace Context
-- specification](https://www.w3.org/TR/trace-context/#tracestate-header).

-- The API MUST implement methods to create a `SpanContext`. These methods SHOULD be the only way to
-- create a `SpanContext`. This functionality MUST be fully implemented in the API, and SHOULD NOT be
-- overridable.
data SpanContext = SpanContext
  { traceFlags :: Word8
  , isRemote :: Bool
  , traceId :: TraceId
  , spanId :: SpanId
  , traceState :: [(Text, Text)] -- TODO have to move TraceState impl from W3CTraceContext to here
  -- list of up to 32, remove rightmost if exceeded
  -- see w3c trace-context spec
  } deriving (Show, Eq)

newtype NonRecordingSpan = NonRecordingSpan SpanContext

data NewEvent = NewEvent
  { newEventName :: Text
  , newEventAttributes :: [(Text, Attribute)]
  , newEventTimestamp :: Maybe Timestamp
  }

data Event = Event
  { eventName :: Text
  , eventAttributes :: [(Text, Attribute)]
  , eventTimestamp :: Timestamp
  }
  deriving (Show)

class ToEvent a where
  toEvent :: a -> Event