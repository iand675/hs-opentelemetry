{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE ExistentialQuantification #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE StrictData #-}

module OpenTelemetry.Internal.Trace.Types where

import Control.Concurrent.Async (Async)
import Control.Exception (SomeException)
import Control.Monad.IO.Class
import Data.Bits
import Data.HashMap.Strict (HashMap)
import qualified Data.HashMap.Strict as H
import Data.IORef (IORef)
import Data.Text (Text)
import Data.Vector (Vector)
import Data.Word (Word8)
import OpenTelemetry.Attributes
import OpenTelemetry.Common
import OpenTelemetry.Context.Types
import OpenTelemetry.Internal.Common.Types
import OpenTelemetry.Propagator (TextMapPropagator)
import OpenTelemetry.Resource
import OpenTelemetry.Trace.Id
import OpenTelemetry.Trace.Id.Generator
import OpenTelemetry.Trace.TraceState
import OpenTelemetry.Util


{- | How an exception should be treated by the tracing system when caught
by 'inSpan' and similar bracket-style functions.

@since 0.4.0.0
-}
data ExceptionClassification
  = -- | Set span status to 'Error', record an exception event. This is the
    -- default behavior for all exceptions.
    ErrorException
  | -- | Record an exception event on the span, but do not set the span status
    -- to 'Error'. Useful for exceptions that represent expected control flow
    -- (e.g. a cache miss exception) that you still want visibility into.
    RecordedException
  | -- | Do not record an exception event and do not set the span status to
    -- 'Error'. The exception is completely invisible to the tracing system.
    -- Useful for 'System.Exit.ExitSuccess', 'Control.Exception.AsyncCancelled',
    -- and similar non-error exceptions.
    IgnoredException
  deriving (Show, Eq, Ord)


{- | The result of classifying an exception via an 'ExceptionHandler'.

@since 0.4.0.0
-}
data ExceptionResponse = ExceptionResponse
  { exceptionClassification :: !ExceptionClassification
  , exceptionAdditionalAttributes :: !AttributeMap
  -- ^ Extra attributes to add to the exception event (when classification is
  -- 'ErrorException' or 'RecordedException') or directly to the span.
  }


{- | A function that inspects a 'SomeException' and optionally classifies it.

Returns 'Nothing' to indicate this handler does not recognize the exception,
deferring to the next handler in the chain. Returns @'Just' 'ExceptionResponse'@
to provide a classification and optional extra attributes.

Multiple handlers are chained: tracer-level handlers are consulted first,
then provider-level handlers. The first @Just@ result wins. If all handlers
return 'Nothing', the default behavior ('ErrorException' with no extra
attributes) applies.

@since 0.4.0.0
-}
type ExceptionHandler = SomeException -> Maybe ExceptionResponse


{- | The default response when no handler matches: classify as 'ErrorException'
with no additional attributes.

@since 0.4.0.0
-}
defaultExceptionResponse :: ExceptionResponse
defaultExceptionResponse = ExceptionResponse ErrorException H.empty


data SpanExporter = SpanExporter
  { spanExporterExport :: HashMap InstrumentationLibrary (Vector ImmutableSpan) -> IO ExportResult
  , spanExporterShutdown :: IO ()
  , spanExporterForceFlush :: IO ()
  }


data SpanProcessor = SpanProcessor
  { spanProcessorOnStart :: ImmutableSpan -> Context -> IO ()
  -- ^ Called when a span is started with a snapshot of the initial span state.
  , spanProcessorOnEnd :: ImmutableSpan -> IO ()
  -- ^ Called after a span is ended with the final frozen span state.
  , spanProcessorShutdown :: IO (Async ShutdownResult)
  -- ^ Shuts down the processor. Called when SDK is shut down. This is an opportunity for processor to do any cleanup required.
  --
  -- Shutdown SHOULD be called only once for each SpanProcessor instance. After the call to Shutdown, subsequent calls to OnStart, OnEnd, or ForceFlush are not allowed. SDKs SHOULD ignore these calls gracefully, if possible.
  --
  -- Shutdown SHOULD let the caller know whether it succeeded, failed or timed out.
  --
  -- Shutdown MUST include the effects of ForceFlush.
  --
  -- Shutdown SHOULD complete or abort within some timeout. Shutdown can be implemented as a blocking API or an asynchronous API which notifies the caller via a callback or an event. OpenTelemetry client authors can decide if they want to make the shutdown timeout configurable.
  , spanProcessorForceFlush :: IO ()
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
  { tracerProviderProcessors :: !(Vector SpanProcessor)
  , tracerProviderIdGenerator :: !IdGenerator
  , tracerProviderSampler :: !Sampler
  , tracerProviderResources :: !MaterializedResources
  , tracerProviderAttributeLimits :: !AttributeLimits
  , tracerProviderSpanLimits :: !SpanLimits
  , tracerProviderPropagators :: !TextMapPropagator
  , tracerProviderExceptionHandlers :: ![ExceptionHandler]
  -- ^ Ordered list of exception handlers consulted when 'inSpan' catches an
  -- exception. These are checked after any tracer-level handlers.
  , tracerProviderIsShutdown :: !(IORef Bool)
  -- ^ Set to 'True' after 'shutdownTracerProvider'. Spec: after shutdown,
  -- subsequent 'createSpan' calls SHOULD return non-recording spans.
  }


{- | The 'Tracer' is responsible for creating 'Span's.

 Each 'Tracer' should be associated with the library or application that
 it instruments.
-}
data Tracer = Tracer
  { tracerName :: {-# UNPACK #-} !InstrumentationLibrary
  -- ^ Get the name of the 'Tracer'
  --
  -- @since 0.0.10
  , tracerProvider :: !TracerProvider
  -- ^ Get the TracerProvider from which the 'Tracer' was created
  --
  -- @since 0.0.10
  , tracerExceptionHandlers :: ![ExceptionHandler]
  -- ^ Tracer-level exception handlers, consulted before provider-level handlers.
  --
  -- @since 0.4.0.0
  , tracerSpanAttributeLimits :: !AttributeLimits
  -- ^ Pre-resolved attribute limits for span attributes, avoiding repeated
  -- pointer chasing through TracerProvider on every addAttribute call.
  , tracerEventAttributeLimits :: !AttributeLimits
  -- ^ Pre-resolved attribute limits for event attributes.
  , tracerLinkAttributeLimits :: !AttributeLimits
  -- ^ Pre-resolved attribute limits for link attributes.
  }


instance Show Tracer where
  showsPrec d Tracer {tracerName = name} = showParen (d > 10) $ showString "Tracer {tracerName = " . shows name . showString "}"


{- | Resolve exception classification by consulting tracer-level handlers first,
then provider-level handlers. Returns 'defaultExceptionResponse' if no handler
matches.

@since 0.4.0.0
-}
resolveException :: Tracer -> SomeException -> ExceptionResponse
resolveException t ex =
  let allHandlers = tracerExceptionHandlers t <> tracerProviderExceptionHandlers (tracerProvider t)
  in go allHandlers
  where
    go [] = defaultExceptionResponse
    go (h : hs) = case h ex of
      Just resp -> resp
      Nothing -> go hs


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

When using the scatter\/gather (also called fork\/join) pattern, the root operation starts multiple downstream
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
  , linkAttributes :: AttributeMap
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
  , attributes :: AttributeMap
  -- ^ An initial set of attributes that may be set on initial 'Span' creation.
  -- These attributes are provided to 'Processor's, so they may be useful in some
  -- scenarios where calling `addAttribute` or `addAttributes` is too late.
  , links :: [NewLink]
  -- ^ A collection of `Link`s that point to causally related 'Span's.
  , startTime :: Maybe Timestamp
  -- ^ An explicit start time, if the span has already begun.
  }


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
  = -- | Indicates that the span covers server-side handling of a synchronous RPC or other remote request.
    -- This span is the child of a remote @Client@ span that was expected to wait for a response.
    Server
  | -- | Indicates that the span describes a synchronous request to some remote service.
    -- This span is the parent of a remote @Server@ span and waits for its response.
    Client
  | -- | Indicates that the span describes the parent of an asynchronous request.
    -- This parent span is expected to end before the corresponding child @Producer@ span,
    -- possibly even before the child span starts. In messaging scenarios with batching,
    -- tracing individual messages requires a new @Producer@ span per message to be created.
    Producer
  | -- | Indicates that the span describes the child of an asynchronous @Producer@ request.
    Consumer
  | -- |  Default value. Indicates that the span represents an internal operation within an application,
    -- as opposed to an operations with remote parents or children.
    Internal
  deriving (Show, Eq)


{- | The status of a @Span@. This may be used to indicate the successful completion of a span.

 The default is @Unset@

 These values form a total order: Ok > Error > Unset. This means that setting Status with StatusCode=Ok will override any prior or future attempts to set span Status with StatusCode=Error or StatusCode=Unset.
-}
data SpanStatus
  = -- | The default status.
    Unset
  | -- | The operation contains an error. The text field may be empty, or else provide a description of the error.
    Error Text
  | -- | The operation has been validated by an Application developer or Operator to have completed successfully.
    Ok
  deriving (Show, Eq)


{- | Ok > Error > Unset. When both are Error, they compare as EQ so
@max existing new@ returns the new (second) argument — achieving
last-writer-wins semantics in 'setStatus'.
-}
instance Ord SpanStatus where
  compare Unset Unset = EQ
  compare Unset (Error _) = LT
  compare Unset Ok = LT
  compare (Error _) Unset = GT
  compare (Error _) (Error _) = EQ
  compare (Error _) Ok = LT
  compare Ok Unset = GT
  compare Ok (Error _) = GT
  compare Ok Ok = EQ


-- | Mutable fields of a span, stored behind an 'IORef' and updated via CAS.
-- Only ~48 bytes, so each CAS allocates much less than copying the full span.
data SpanHot = SpanHot
  { hotName :: !Text
  , hotEnd :: !OptionalTimestamp
  , hotAttributes :: !Attributes
  , hotLinks :: !(AppendOnlyBoundedCollection Link)
  , hotEvents :: !(AppendOnlyBoundedCollection Event)
  , hotStatus :: !SpanStatus
  }
  deriving (Show)


{- | The representation of a 'Span' for processors and exporters.

Cold (immutable) fields live directly in the record and are never copied.
Hot (mutable) fields sit behind an 'IORef' so that CAS operations only
allocate a fresh 'SpanHot' instead of the entire span.
-}
data ImmutableSpan = ImmutableSpan
  { spanContext :: !SpanContext
  -- ^ A @SpanContext@ represents the portion of a @Span@ which must be serialized and
  -- propagated along side of a distributed context. @SpanContext@s are immutable.
  , spanKind :: !SpanKind
  -- ^ The kind of the span.
  , spanStart :: !Timestamp
  -- ^ Timestamp corresponding to the start of the span.
  , spanParent :: !(Maybe Span)
  , spanTracer :: !Tracer
  -- ^ Creator of the span.
  , spanHot :: {-# UNPACK #-} !(IORef SpanHot)
  -- ^ Mutable span fields (name, end time, attributes, links, events, status).
  -- Updated via CAS during the span's lifetime.
  }


instance Show ImmutableSpan where
  showsPrec d imm = showParen (d > 10) $
    showString "ImmutableSpan {spanContext = " . showsPrec 11 (spanContext imm)
      . showString ", spanKind = " . showsPrec 11 (spanKind imm)
      . showString ", spanStart = " . showsPrec 11 (spanStart imm)
      . showString ", spanHot = <IORef>}"


{- | A 'Span' is the fundamental type you'll work with to trace your systems.

 A span is a single piece of instrumentation from a single location in your code or infrastructure. A span represents a single "unit of work" done by a service. Each span contains several key pieces of data:

 - A service name identifying the service the span is from
 - A name identifying the role of the span (like function or method name)
 - A timestamp that corresponds to the start of the span
 - A duration that describes how long that unit of work took to complete
 - An ID that uniquely identifies the span
 - A trace ID identifying which trace the span belongs to
 - A parent ID representing the parent span that called this span. (There is no parent ID for the root span of a given trace, which denotes that it's the start of the trace.)
 - Any additional metadata that might be helpful.
 - Zero or more links to related spans. Links can be useful for connecting causal relationships between things like web requests that enqueue asynchronous tasks to be processed.
 - Events, which denote a point in time occurrence. These can be useful for recording data about a span such as when an exception was thrown, or to emit structured logs into the span tree.

 A trace is made up of multiple spans. Tracing vendors such as Zipkin, Jaeger, Honeycomb, Datadog, Lightstep, etc. use the metadata from each span to reconstruct the relationships between them and generate a trace diagram.
-}
data Span
  = Span !ImmutableSpan
  | FrozenSpan !SpanContext
  | Dropped !SpanContext


instance Show Span where
  showsPrec d (Span imm) = showParen (d > 10) $ showString "Span " . showsPrec 11 imm
  showsPrec d (FrozenSpan ctx) = showParen (d > 10) $ showString "FrozenSpan " . showsPrec 11 ctx
  showsPrec d (Dropped ctx) = showParen (d > 10) $ showString "Dropped " . showsPrec 11 ctx


data FrozenOrDropped = SpanFrozen | SpanDropped deriving (Show, Eq)


-- | Extracts the values from a @Span@ if it is still mutable. Returns a @Left@ with @FrozenOrDropped@ if the @Span@ is frozen or dropped.
toImmutableSpan :: MonadIO m => Span -> m (Either FrozenOrDropped ImmutableSpan)
toImmutableSpan (Span imm) = pure (Right imm)
toImmutableSpan (FrozenSpan _ctx) = pure $ Left SpanFrozen
toImmutableSpan (Dropped _ctx) = pure $ Left SpanDropped
{-# INLINE toImmutableSpan #-}


{- | TraceFlags with the @sampled@ flag not set. This means that it is up to the
 sampling configuration to decide whether or not to sample the trace.
-}
defaultTraceFlags :: TraceFlags
defaultTraceFlags = TraceFlags 0
{-# INLINE defaultTraceFlags #-}


-- | Will the trace associated with this @TraceFlags@ value be sampled?
isSampled :: TraceFlags -> Bool
isSampled (TraceFlags flags) = flags `testBit` 0
{-# INLINE isSampled #-}


-- | Set the @sampled@ flag on the @TraceFlags@
setSampled :: TraceFlags -> TraceFlags
setSampled (TraceFlags flags) = TraceFlags (flags `setBit` 0)
{-# INLINE setSampled #-}


{- | Unset the @sampled@ flag on the @TraceFlags@. This means that the
 application may choose whether or not to emit this Trace.
-}
unsetSampled :: TraceFlags -> TraceFlags
unsetSampled (TraceFlags flags) = TraceFlags (flags `clearBit` 0)


-- | Get the current bitmask for the @TraceFlags@, useful for serialization purposes.
traceFlagsValue :: TraceFlags -> Word8
traceFlagsValue (TraceFlags flags) = flags


{- | Create a @TraceFlags@, from an arbitrary @Word8@. Note that for backwards-compatibility
 reasons, no checking is performed to determine whether the @TraceFlags@ bitmask provided
 is valid.
-}
traceFlagsFromWord8 :: Word8 -> TraceFlags
traceFlagsFromWord8 = TraceFlags


{- | A `SpanContext` represents the portion of a `Span` which must be serialized and
 propagated along side of a distributed context. `SpanContext`s are immutable.
-}

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
  { traceFlags :: {-# UNPACK #-} !TraceFlags
  , isRemote :: !Bool
  , traceId :: {-# UNPACK #-} !TraceId
  , spanId :: {-# UNPACK #-} !SpanId
  , traceState :: !TraceState
  }
  deriving (Show, Eq)


newtype NonRecordingSpan = NonRecordingSpan SpanContext


{- | A “log” that happens as part of a span. An operation that is too fast for its own span, but too unique to roll up into its parent span.

 Events contain a name, a timestamp, and an optional set of Attributes, along with a timestamp. Events represent an event that occurred at a specific time within a span’s workload.

 When creating an event, this is the version that you will use. Attributes added that exceed the configured attribute limits will be dropped,
 which is accounted for in the 'Event' structure.

 @since 0.0.1.0
-}
data NewEvent = NewEvent
  { newEventName :: Text
  -- ^ The name of an event. Ideally this should be a relatively unique, but low cardinality value.
  , newEventAttributes :: AttributeMap
  -- ^ Additional context or metadata related to the event, (stack traces, callsites, etc.).
  , newEventTimestamp :: Maybe Timestamp
  -- ^ The time that the event occurred.
  --
  -- If not specified, 'OpenTelemetry.Trace.getTimestamp' will be used to get a timestamp.
  }


{- | A “log” that happens as part of a span. An operation that is too fast for its own span, but too unique to roll up into its parent span.

 Events contain a name, a timestamp, and an optional set of Attributes, along with a timestamp. Events represent an event that occurred at a specific time within a span’s workload.
-}
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


{- | The outcome of a call to 'Sampler' indicating
 whether the 'Tracer' should sample a 'Span'.
-}
data SamplingResult
  = -- | isRecording == false. Span will not be recorded and all events and attributes will be dropped.
    Drop
  | -- | isRecording == true, but Sampled flag MUST NOT be set.
    RecordOnly
  | -- | isRecording == true, AND Sampled flag MUST be set.
    RecordAndSample
  deriving (Show, Eq)


{- | Interface that allows users to create custom samplers which will return a sampling SamplingResult based on information that
 is typically available just before the Span was created.
-}
data Sampler = Sampler
  { getDescription :: Text
  -- ^ Returns the sampler name or short description with the configuration. This may be displayed on debug pages or in the logs.
  , shouldSample :: Context -> TraceId -> Text -> SpanArguments -> IO (SamplingResult, AttributeMap, TraceState)
  }


data SpanLimits = SpanLimits
  { spanAttributeValueLengthLimit :: Maybe Int
  , spanAttributeCountLimit :: Maybe Int
  , eventCountLimit :: Maybe Int
  , eventAttributeCountLimit :: Maybe Int
  , linkCountLimit :: Maybe Int
  , linkAttributeCountLimit :: Maybe Int
  }
  deriving (Show, Eq)


defaultSpanLimits :: SpanLimits
defaultSpanLimits =
  SpanLimits
    Nothing
    Nothing
    Nothing
    Nothing
    Nothing
    Nothing


type Lens s t a b = forall f. (Functor f) => (a -> f b) -> s -> f t


type Lens' s a = Lens s s a a


{- | When sending tracing information across process boundaries,
 the @SpanContext@ is used to serialize the relevant information.
-}
getSpanContext :: (MonadIO m) => Span -> m SpanContext
getSpanContext (Span imm) = pure (spanContext imm)
getSpanContext (FrozenSpan c) = pure c
getSpanContext (Dropped c) = pure c
{-# INLINE getSpanContext #-}
