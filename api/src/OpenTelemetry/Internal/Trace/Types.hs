{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE ExistentialQuantification #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
module OpenTelemetry.Internal.Trace.Types where

import Control.Concurrent.Async (Async)
import Control.Exception (SomeException)
import Control.Monad.IO.Class
import Data.Bits
import Data.Hashable (Hashable)
import Data.HashMap.Strict (HashMap)
import Data.IORef (IORef, readIORef)
import Data.String ( IsString(..) )
import Data.Text (Text)
import Data.Vector (Vector)
import Data.Word (Word8)
import GHC.Generics
import Network.HTTP.Types (RequestHeaders, ResponseHeaders)
import OpenTelemetry.Attributes
import OpenTelemetry.Common
import OpenTelemetry.Context.Types
import OpenTelemetry.Logging.Core (Log)
import OpenTelemetry.Trace.Id
import OpenTelemetry.Resource
import OpenTelemetry.Trace.Id.Generator
import OpenTelemetry.Propagator (Propagator)
import OpenTelemetry.Trace.TraceState
import OpenTelemetry.Util


data ExportResult
  = Success
  | Failure (Maybe SomeException)

-- | An identifier for the library that provides the instrumentation for a given Instrumented Library.
-- Instrumented Library and Instrumentation Library may be the same library if it has built-in OpenTelemetry instrumentation.
--
-- The inspiration of the OpenTelemetry project is to make every library and application observable out of the box by having them call OpenTelemetry API directly.
-- However, many libraries will not have such integration, and as such there is a need for a separate library which would inject such calls, using mechanisms such as wrapping interfaces,
-- subscribing to library-specific callbacks, or translating existing telemetry into the OpenTelemetry model.
--
-- A library that enables OpenTelemetry observability for another library is called an Instrumentation Library.
--
-- An instrumentation library should be named to follow any naming conventions of the instrumented library (e.g. 'middleware' for a web framework).
--
-- If there is no established name, the recommendation is to prefix packages with "hs-opentelemetry-instrumentation", followed by the instrumented library name itself.
--
-- In general, you can initialize the instrumentation library like so:
--
-- @
--
-- import qualified Data.Text as T
-- import Data.Version (showVersion)
-- import Paths_your_package_name
--
-- instrumentationLibrary :: InstrumentationLibrary
-- instrumentationLibrary = InstrumentationLibrary
--   { libraryName = "your_package_name"
--   , libraryVersion = T.pack $ showVersion version
--   }
--
-- @
data InstrumentationLibrary = InstrumentationLibrary
  { libraryName :: {-# UNPACK #-} !Text
  -- ^ The name of the instrumentation library
  , libraryVersion :: {-# UNPACK #-} !Text
  -- ^ The version of the instrumented library
  } deriving (Ord, Eq, Generic, Show)

instance Hashable InstrumentationLibrary
instance IsString InstrumentationLibrary where
  fromString str = InstrumentationLibrary (fromString str) ""

data Exporter a = Exporter
  { exporterExport :: HashMap InstrumentationLibrary (Vector a) -> IO ExportResult
  , exporterShutdown :: IO ()
  }

data ShutdownResult = ShutdownSuccess | ShutdownFailure | ShutdownTimeout

data Processor = Processor
  { processorOnStart :: IORef ImmutableSpan -> Context -> IO ()
  -- ^ Called when a span is started. This method is called synchronously on the thread that started the span, therefore it should not block or throw exceptions.
  , processorOnEnd :: IORef ImmutableSpan -> IO ()
  -- ^ Called after a span is ended (i.e., the end timestamp is already set). This method is called synchronously within the 'OpenTelemetry.Trace.endSpan' API, therefore it should not block or throw an exception.
  , processorShutdown :: IO (Async ShutdownResult)
  -- ^ Shuts down the processor. Called when SDK is shut down. This is an opportunity for processor to do any cleanup required.
  --
  -- Shutdown SHOULD be called only once for each SpanProcessor instance. After the call to Shutdown, subsequent calls to OnStart, OnEnd, or ForceFlush are not allowed. SDKs SHOULD ignore these calls gracefully, if possible.
  --
  -- Shutdown SHOULD let the caller know whether it succeeded, failed or timed out.
  --
  -- Shutdown MUST include the effects of ForceFlush.
  --
  -- Shutdown SHOULD complete or abort within some timeout. Shutdown can be implemented as a blocking API or an asynchronous API which notifies the caller via a callback or an event. OpenTelemetry client authors can decide if they want to make the shutdown timeout configurable.
  , processorForceFlush :: IO ()
  -- ^ This is a hint to ensure that any tasks associated with Spans for which the SpanProcessor had already received events prior to the call to ForceFlush SHOULD be completed as soon as possible, preferably before returning from this method.
  --
  -- In particular, if any Processor has any associated exporter, it SHOULD try to call the exporter's Export with all spans for which this was not already done and then invoke ForceFlush on it. The built-in SpanProcessors MUST do so. If a timeout is specified (see below), the SpanProcessor MUST prioritize honoring the timeout over finishing all calls. It MAY skip or abort some or all Export or ForceFlush calls it has made to achieve this goal.
  --
  -- ForceFlush SHOULD provide a way to let the caller know whether it succeeded, failed or timed out.
  --
  -- ForceFlush SHOULD only be called in cases where it is absolutely necessary, such as when using some FaaS providers that may suspend the process after an invocation, but before the SpanProcessor exports the completed spans.
  --
  -- ForceFlush SHOULD complete or abort within some timeout. ForceFlush can be implemented as a blocking API or an asynchronous API which notifies the caller via a callback or an event. OpenTelemetry client authors can decide if they want to make the flush timeout configurable.
  }

{- |
'Tracer's can be created from a 'TracerProvider'.
-}
data TracerProvider = TracerProvider
  { tracerProviderProcessors :: !(Vector Processor)
  , tracerProviderIdGenerator :: !IdGenerator
  , tracerProviderSampler :: !Sampler
  , tracerProviderResources :: !MaterializedResources
  , tracerProviderAttributeLimits :: !AttributeLimits
  , tracerProviderSpanLimits :: !SpanLimits
  , tracerProviderPropagators :: !(Propagator Context RequestHeaders ResponseHeaders)
  , tracerProviderLogger :: Log Text -> IO ()
  }

-- | The 'Tracer' is responsible for creating 'Span's.
--
-- Each 'Tracer' should be associated with the library or application that
-- it instruments.
data Tracer = Tracer
  { tracerName :: {-# UNPACK #-} !InstrumentationLibrary
  -- ^ Get the name of the 'Tracer'
  --
  -- @since 0.0.10
  , tracerProvider :: !TracerProvider
  -- ^ Get the TracerProvider from which the 'Tracer' was created
  --
  -- @since 0.0.10
  }

instance Show Tracer where
  show Tracer {tracerName = name} = "Tracer { tracerName = " <> show name <> "}"

{- |
This is a link that is being added to a span which is going to be created.

A @Span@ may be linked to zero or more other @Spans@ (defined by @SpanContext@) that are causally related.
@Link@s can point to Spans inside a single Trace or across different Traces. @Link@s can be used to represent
batched operations where a @Span@ was initiated by multiple initiating Spans, each representing a single incoming
item being processed in the batch.

Another example of using a Link is to declare the relationship between the originating and following trace.
This can be used when a Trace enters trusted boundaries of a service and service policy requires the generation
of a new Trace rather than trusting the incoming Trace context. The new linked Trace may also represent a long
running asynchronous data processing operation that was initiated by one of many fast incoming requests.

When using the scatter/gather (also called fork/join) pattern, the root operation starts multiple downstream
processing operations and all of them are aggregated back in a single Span.
This last Span is linked to many operations it aggregates.
All of them are the Spans from the same Trace. And similar to the Parent field of a Span.
It is recommended, however, to not set parent of the Span in this scenario as semantically the parent field
represents a single parent scenario, in many cases the parent Span fully encloses the child Span.
This is not the case in scatter/gather and batch scenarios.
-}
data NewLink = NewLink
  { linkContext :: !SpanContext
  -- ^ @SpanContext@ of the @Span@ to link to.
  , linkAttributes :: [(Text, Attribute)]
  -- ^ Zero or more Attributes further describing the link.
  }
  deriving (Show)

{- |
This is an immutable link for an existing span.

A @Span@ may be linked to zero or more other @Spans@ (defined by @SpanContext@) that are causally related.
@Link@s can point to Spans inside a single Trace or across different Traces. @Link@s can be used to represent
batched operations where a @Span@ was initiated by multiple initiating Spans, each representing a single incoming
item being processed in the batch.

Another example of using a Link is to declare the relationship between the originating and following trace.
This can be used when a Trace enters trusted boundaries of a service and service policy requires the generation
of a new Trace rather than trusting the incoming Trace context. The new linked Trace may also represent a long
running asynchronous data processing operation that was initiated by one of many fast incoming requests.

When using the scatter/gather (also called fork/join) pattern, the root operation starts multiple downstream
processing operations and all of them are aggregated back in a single Span.
This last Span is linked to many operations it aggregates.
All of them are the Spans from the same Trace. And similar to the Parent field of a Span.
It is recommended, however, to not set parent of the Span in this scenario as semantically the parent field
represents a single parent scenario, in many cases the parent Span fully encloses the child Span.
This is not the case in scatter/gather and batch scenarios.
-}
data Link = Link
  { frozenLinkContext :: !SpanContext
  -- ^ @SpanContext@ of the @Span@ to link to.
  , frozenLinkAttributes :: Attributes
  -- ^ Zero or more Attributes further describing the link.
  }
  deriving (Show)

-- | Non-name fields that may be set on initial creation of a 'Span'.
data SpanArguments = SpanArguments
  { kind :: SpanKind
  -- ^ The kind of the span. See 'SpanKind's documentation for the semantics
  -- of the various values that may be specified.
  , attributes :: [(Text, Attribute)]
  -- ^ An initial set of attributes that may be set on initial 'Span' creation.
  -- These attributes are provided to 'Processor's, so they may be useful in some
  -- scenarios where calling `addAttribute` or `addAttributes` is too late.
  , links :: [NewLink]
  -- ^ A collection of `Link`s that point to causally related 'Span's.
  , startTime :: Maybe Timestamp
  -- ^ An explicit start time, if the span has already begun.
  }

-- | The outcome of a call to 'OpenTelemetry.Trace.forceFlush'
data FlushResult
  = FlushTimeout
  -- ^ One or more spans did not export from all associated exporters
  -- within the alotted timeframe.
  | FlushSuccess
  -- ^ Flushing spans to all associated exporters succeeded.
  | FlushError
  -- ^ One or more exporters failed to successfully export one or more
  -- unexported spans.
  deriving (Show)

{- |
@SpanKind@ describes the relationship between the @Span@, its parents, and its children in a Trace. @SpanKind@ describes two independent properties that benefit tracing systems during analysis.

The first property described by @SpanKind@ reflects whether the @Span@ is a remote child or parent. @Span@s with a remote parent are interesting because they are sources of external load. Spans with a remote child are interesting because they reflect a non-local system dependency.

The second property described by @SpanKind@ reflects whether a child @Span@ represents a synchronous call. When a child span is synchronous, the parent is expected to wait for it to complete under ordinary circumstances. It can be useful for tracing systems to know this property, since synchronous @Span@s may contribute to the overall trace latency. Asynchronous scenarios can be remote or local.

In order for @SpanKind@ to be meaningful, callers SHOULD arrange that a single @Span@ does not serve more than one purpose. For example, a server-side span SHOULD NOT be used directly as the parent of another remote span. As a simple guideline, instrumentation should create a new @Span@ prior to extracting and serializing the @SpanContext@ for a remote call.

To summarize the interpretation of these kinds

+-------------+--------------+---------------+------------------+------------------+
| `SpanKind`  | Synchronous  | Asynchronous  | Remote Incoming  | Remote Outgoing  |
+=============+==============+===============+==================+==================+
| `Client`    | yes          |               |                  | yes              |
+-------------+--------------+---------------+------------------+------------------+
| `Server`    | yes          |               | yes              |                  |
+-------------+--------------+---------------+------------------+------------------+
| `Producer`  |              | yes           |                  | maybe            |
+-------------+--------------+---------------+------------------+------------------+
| `Consumer`  |              | yes           | maybe            |                  |
+-------------+--------------+---------------+------------------+------------------+
| `Internal`  |              |               |                  |                  |
+-------------+--------------+---------------+------------------+------------------+

-}
data SpanKind
  = Server
  -- ^ Indicates that the span covers server-side handling of a synchronous RPC or other remote request.
  -- This span is the child of a remote @Client@ span that was expected to wait for a response.
  | Client
  -- ^ Indicates that the span describes a synchronous request to some remote service.
  -- This span is the parent of a remote @Server@ span and waits for its response.
  | Producer
  -- ^ Indicates that the span describes the parent of an asynchronous request.
  -- This parent span is expected to end before the corresponding child @Producer@ span,
  -- possibly even before the child span starts. In messaging scenarios with batching,
  -- tracing individual messages requires a new @Producer@ span per message to be created.
  | Consumer
  -- ^ Indicates that the span describes the child of an asynchronous @Producer@ request.
  | Internal
  -- ^  Default value. Indicates that the span represents an internal operation within an application,
  -- as opposed to an operations with remote parents or children.
  deriving (Show)

-- | The status of a @Span@. This may be used to indicate the successful completion of a span.
--
-- The default is @Unset@
--
-- These values form a total order: Ok > Error > Unset. This means that setting Status with StatusCode=Ok will override any prior or future attempts to set span Status with StatusCode=Error or StatusCode=Unset.
data SpanStatus
  = Unset
  -- ^ The default status.
  | Error Text
  -- ^ The operation contains an error. The text field may be empty, or else provide a description of the error.
  | Ok
  -- ^ The operation has been validated by an Application developer or Operator to have completed successfully.
  deriving (Show, Eq)

instance Ord SpanStatus where
  compare Unset Unset = EQ
  compare Unset (Error _) = LT
  compare Unset Ok = LT
  compare (Error _) Unset = GT
  compare (Error _) (Error _) = GT -- This is a weird one, but last writer wins for errors
  compare (Error _) Ok = LT
  compare Ok Unset = GT
  compare Ok (Error _) = GT
  compare Ok Ok = EQ

-- | The frozen representation of a 'Span' that originates from the currently running process.
--
-- Only 'Processor's and 'Exporter's should use rely on this interface.
data ImmutableSpan = ImmutableSpan
  { spanName :: Text
  -- ^ A name identifying the role of the span (like function or method name).
  , spanParent :: Maybe Span
  , spanContext :: SpanContext
  -- ^ A `SpanContext` represents the portion of a `Span` which must be serialized and
  -- propagated along side of a distributed context. `SpanContext`s are immutable.
  , spanKind :: SpanKind
  -- ^ The kind of the span. See 'SpanKind's documentation for the semantics
  -- of the various values that may be specified.
  , spanStart :: Timestamp
  -- ^ A timestamp that corresponds to the start of the span
  , spanEnd :: Maybe Timestamp
  -- ^ A timestamp that corresponds to the end of the span, if the span has ended.
  , spanAttributes :: Attributes
  , spanLinks :: FrozenBoundedCollection Link
  -- ^ Zero or more links to related spans. Links can be useful for connecting causal relationships between things like web requests that enqueue asynchronous tasks to be processed.
  , spanEvents :: AppendOnlyBoundedCollection Event
  -- ^ Events, which denote a point in time occurrence. These can be useful for recording data about a span such as when an exception was thrown, or to emit structured logs into the span tree.
  , spanStatus :: SpanStatus
  , spanTracer :: Tracer
  -- ^ Creator of the span
  } deriving (Show)

-- | A 'Span' is the fundamental type you'll work with to trace your systems.
--
-- A span is a single piece of instrumentation from a single location in your code or infrastructure. A span represents a single "unit of work" done by a service. Each span contains several key pieces of data:
--
-- - A service name identifying the service the span is from
-- - A name identifying the role of the span (like function or method name)
-- - A timestamp that corresponds to the start of the span
-- - A duration that describes how long that unit of work took to complete
-- - An ID that uniquely identifies the span
-- - A trace ID identifying which trace the span belongs to
-- - A parent ID representing the parent span that called this span. (There is no parent ID for the root span of a given trace, which denotes that it's the start of the trace.)
-- - Any additional metadata that might be helpful.
-- - Zero or more links to related spans. Links can be useful for connecting causal relationships between things like web requests that enqueue asynchronous tasks to be processed.
-- - Events, which denote a point in time occurrence. These can be useful for recording data about a span such as when an exception was thrown, or to emit structured logs into the span tree.
--
-- A trace is made up of multiple spans. Tracing vendors such as Zipkin, Jaeger, Honeycomb, Datadog, Lightstep, etc. use the metadata from each span to reconstruct the relationships between them and generate a trace diagram.
data Span
  = Span (IORef ImmutableSpan)
  | FrozenSpan SpanContext
  | Dropped SpanContext

instance Show Span where
  show (Span _ioref) = "(mutable span)"
  show (FrozenSpan ctx) = show ctx
  show (Dropped ctx) = show ctx

-- | TraceFlags with the @sampled@ flag not set. This means that it is up to the
-- sampling configuration to decide whether or not to sample the trace.
defaultTraceFlags :: TraceFlags
defaultTraceFlags = TraceFlags 0

-- | Will the trace associated with this @TraceFlags@ value be sampled?
isSampled :: TraceFlags -> Bool
isSampled (TraceFlags flags) = flags `testBit` 0

-- | Set the @sampled@ flag on the @TraceFlags@
setSampled :: TraceFlags -> TraceFlags
setSampled (TraceFlags flags) = TraceFlags (flags `setBit` 0)

-- | Unset the @sampled@ flag on the @TraceFlags@. This means that the
-- application may choose whether or not to emit this Trace.
unsetSampled :: TraceFlags -> TraceFlags
unsetSampled (TraceFlags flags) = TraceFlags (flags `clearBit` 0)

-- | Get the current bitmask for the @TraceFlags@, useful for serialization purposes.
traceFlagsValue :: TraceFlags -> Word8
traceFlagsValue (TraceFlags flags) = flags

-- | Create a @TraceFlags@, from an arbitrary @Word8@. Note that for backwards-compatibility
-- reasons, no checking is performed to determine whether the @TraceFlags@ bitmask provided
-- is valid.
traceFlagsFromWord8 :: Word8 -> TraceFlags
traceFlagsFromWord8 = TraceFlags

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
  { traceFlags :: TraceFlags
  , isRemote :: Bool
  , traceId :: TraceId
  , spanId :: SpanId
  , traceState :: TraceState -- TODO have to move TraceState impl from W3CTraceContext to here
  -- list of up to 32, remove rightmost if exceeded
  -- see w3c trace-context spec
  } deriving (Show, Eq)

newtype NonRecordingSpan = NonRecordingSpan SpanContext

-- | A “log” that happens as part of a span. An operation that is too fast for its own span, but too unique to roll up into its parent span.
--
-- Events contain a name, a timestamp, and an optional set of Attributes, along with a timestamp. Events represent an event that occurred at a specific time within a span’s workload.
--
-- When creating an event, this is the version that you will use. Attributes added that exceed the configured attribute limits will be dropped,
-- which is accounted for in the 'Event' structure.
--
-- @since 0.0.1.0
data NewEvent = NewEvent
  { newEventName :: Text
  -- ^ The name of an event. Ideally this should be a relatively unique, but low cardinality value.
  , newEventAttributes :: [(Text, Attribute)]
  -- ^ Additional context or metadata related to the event, (stack traces, callsites, etc.).
  , newEventTimestamp :: Maybe Timestamp
  -- ^ The time that the event occurred.
  --
  -- If not specified, 'OpenTelemetry.Trace.getTimestamp' will be used to get a timestamp.
  }

-- | A “log” that happens as part of a span. An operation that is too fast for its own span, but too unique to roll up into its parent span.
--
-- Events contain a name, a timestamp, and an optional set of Attributes, along with a timestamp. Events represent an event that occurred at a specific time within a span’s workload.
data Event = Event
  { eventName :: Text
  -- ^ The name of an event. Ideally this should be a relatively unique, but low cardinality value.
  , eventAttributes :: Attributes
  -- ^ Additional context or metadata related to the event, (stack traces, callsites, etc.).
  , eventTimestamp :: Timestamp
  -- ^ The time that the event occurred.
  }
  deriving (Show)

-- | Utility class to format arbitrary values to events.
class ToEvent a where
  -- | Convert a value to an 'Event'
  --
  -- @since 0.0.1.0
  toEvent :: a -> Event

-- | The outcome of a call to 'Sampler' indicating
-- whether the 'Tracer' should sample a 'Span'.
data SamplingResult
  = Drop
  -- ^ isRecording == false. Span will not be recorded and all events and attributes will be dropped.
  | RecordOnly
  -- ^ isRecording == true, but Sampled flag MUST NOT be set.
  | RecordAndSample
  -- ^ isRecording == true, AND Sampled flag MUST be set.
  deriving (Show, Eq)

-- | Interface that allows users to create custom samplers which will return a sampling SamplingResult based on information that
-- is typically available just before the Span was created.
data Sampler = Sampler
  { getDescription :: Text
  -- ^ Returns the sampler name or short description with the configuration. This may be displayed on debug pages or in the logs.
  , shouldSample :: Context -> TraceId -> Text -> SpanArguments -> IO (SamplingResult, [(Text, Attribute)], TraceState)
  }

data SpanLimits = SpanLimits
  { spanAttributeValueLengthLimit :: Maybe Int
  , spanAttributeCountLimit :: Maybe Int
  , eventCountLimit :: Maybe Int
  , eventAttributeCountLimit :: Maybe Int
  , linkCountLimit :: Maybe Int
  , linkAttributeCountLimit :: Maybe Int
  } deriving (Show, Eq)

defaultSpanLimits :: SpanLimits
defaultSpanLimits = SpanLimits
  Nothing
  Nothing
  Nothing
  Nothing
  Nothing
  Nothing

type Lens s t a b = forall f. Functor f => (a -> f b) -> s -> f t
type Lens' s a = Lens s s a a

-- | When sending tracing information across process boundaries,
-- the @SpanContext@ is used to serialize the relevant information.
getSpanContext :: MonadIO m => Span -> m SpanContext
getSpanContext (Span s) = liftIO (spanContext <$> readIORef s)
getSpanContext (FrozenSpan c) = pure c
getSpanContext (Dropped c) = pure c
