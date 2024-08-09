{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE OverloadedLists #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}

-----------------------------------------------------------------------------

-----------------------------------------------------------------------------

{- |
 Module      :  OpenTelemetry.Trace.Core
 Copyright   :  (c) Ian Duncan, 2021
 License     :  BSD-3
 Description :  Low-level tracing API
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)

 Traces track the progression of a single request, called a trace, as it is handled by services that make up an application. The request may be initiated by a user or an application. Distributed tracing is a form of tracing that traverses process, network and security boundaries. Each unit of work in a trace is called a span; a trace is a tree of spans. Spans are objects that represent the work being done by individual services or components involved in a request as it flows through a system. A span contains a span context, which is a set of globally unique identifiers that represent the unique request that each span is a part of. A span provides Request, Error and Duration (RED) metrics that can be used to debug availability as well as performance issues.

 A trace contains a single root span which encapsulates the end-to-end latency for the entire request. You can think of this as a single logical operation, such as clicking a button in a web application to add a product to a shopping cart. The root span would measure the time it took from an end-user clicking that button to the operation being completed or failing (so, the item is added to the cart or some error occurs) and the result being displayed to the user. A trace is comprised of the single root span and any number of child spans, which represent operations taking place as part of the request. Each span contains metadata about the operation, such as its name, start and end timestamps, attributes, events, and status.

 To create and manage 'Span's in OpenTelemetry, the <https://hackage.haskell.org/package/hs-opentelemetry-api OpenTelemetry API> provides the tracer interface. This object is responsible for tracking the active span in your process, and allows you to access the current span in order to perform operations on it such as adding attributes, events, and finishing it when the work it tracks is complete. One or more tracer objects can be created in a process through the tracer provider, a factory interface that allows for multiple 'Tracer's to be instantiated in a single process with different options.

 Generally, the lifecycle of a span resembles the following:

 A request is received by a service. The span context is extracted from the request headers, if it exists.
 A new span is created as a child of the extracted span context; if none exists, a new root span is created.
 The service handles the request. Additional attributes and events are added to the span that are useful for understanding the context of the request, such as the hostname of the machine handling the request, or customer identifiers.
 New spans may be created to represent work being done by sub-components of the service.
 When the service makes a remote call to another service, the current span context is serialized and forwarded to the next service by injecting the span context into the headers or message envelope.
 The work being done by the service completes, successfully or not. The span status is appropriately set, and the span is marked finished.
 For more information, see the traces specification, which covers concepts including: trace, span, parent/child relationship, span context, attributes, events and links.


 This module implements eveything required to conform to the trace & span public interface described
 by the OpenTelemetry specification.

 See OpenTelemetry.Trace.Monad for an implementation that's
 generally easier to use in idiomatic Haskell.
-}
module OpenTelemetry.Trace.Core (
  -- * @TracerProvider@ operations
  TracerProvider,
  createTracerProvider,
  shutdownTracerProvider,
  forceFlushTracerProvider,
  FlushResult (..),
  getTracerProviderResources,
  getTracerProviderPropagators,
  getGlobalTracerProvider,
  setGlobalTracerProvider,
  emptyTracerProviderOptions,
  TracerProviderOptions (..),

  -- * @Tracer@ operations
  Tracer,
  tracerName,
  HasTracer (..),
  makeTracer,
  getTracer,
  getImmutableSpanTracer,
  getTracerTracerProvider,
  InstrumentationLibrary (..),
  TracerOptions (..),
  tracerOptions,

  -- * Span operations
  Span,
  ImmutableSpan (..),
  SpanContext (..),
  -- | W3c Trace flags
  --
  -- https://www.w3.org/TR/trace-context/#trace-flags
  TraceFlags,
  traceFlagsValue,
  traceFlagsFromWord8,
  defaultTraceFlags,
  isSampled,
  setSampled,
  unsetSampled,

  -- ** Creating @Span@s
  inSpan,
  inSpan',
  inSpan'',
  createSpan,
  createSpanWithoutCallStack,
  wrapSpanContext,
  SpanKind (..),
  defaultSpanArguments,
  SpanArguments (..),
  NewLink (..),
  Link (..),

  -- ** Recording @Event@s
  Event (..),
  NewEvent (..),
  addEvent,

  -- ** Enriching @Span@s with additional information
  updateName,
  OpenTelemetry.Trace.Core.addAttribute,
  OpenTelemetry.Trace.Core.addAttributes,
  spanGetAttributes,
  Attribute (..),
  ToAttribute (..),
  PrimitiveAttribute (..),
  ToPrimitiveAttribute (..),

  -- ** Recording error information
  recordException,
  setStatus,
  SpanStatus (..),

  -- ** Completing @Span@s
  endSpan,

  -- ** Accessing other @Span@ information
  getSpanContext,
  isRecording,
  isValid,
  spanIsRemote,

  -- * Utilities
  Timestamp,
  getTimestamp,
  timestampNanoseconds,
  unsafeReadSpan,
  whenSpanIsRecording,
  ownCodeAttributes,
  callerAttributes,
  addAttributesToSpanArguments,

  -- * Limits
  SpanLimits (..),
  defaultSpanLimits,
  bracketError,
) where

import Control.Applicative
import Control.Concurrent (myThreadId)
import Control.Concurrent.Async
import Control.Exception (Exception (..), SomeException (..), try)
import Control.Monad
import Control.Monad.IO.Class
import Control.Monad.IO.Unlift
import Data.Coerce
import qualified Data.HashMap.Strict as H
import Data.IORef
import Data.Maybe (fromMaybe, isJust, isNothing)
import Data.Text (Text)
import qualified Data.Text as T
import Data.Typeable
import qualified Data.Vector as V
import Data.Word (Word64)
import GHC.Stack
import Network.HTTP.Types
import OpenTelemetry.Attributes
import qualified OpenTelemetry.Attributes as A
import OpenTelemetry.Common
import OpenTelemetry.Context
import OpenTelemetry.Context.ThreadLocal
import OpenTelemetry.Internal.Common.Types
import OpenTelemetry.Internal.Logs.Core (emitOTelLogRecord, logDroppedAttributes)
import qualified OpenTelemetry.Internal.Logs.Types as SeverityNumber (SeverityNumber (..))
import OpenTelemetry.Internal.Trace.Types
import qualified OpenTelemetry.Internal.Trace.Types as Types
import OpenTelemetry.Propagator (Propagator)
import OpenTelemetry.Resource
import OpenTelemetry.Trace.Id
import OpenTelemetry.Trace.Id.Generator
import OpenTelemetry.Trace.Id.Generator.Dummy
import OpenTelemetry.Trace.Sampler
import qualified OpenTelemetry.Trace.TraceState as TraceState
import OpenTelemetry.Util
import System.Clock
import System.IO.Unsafe
import System.Timeout (timeout)


{- | Create a 'Span'.

 If the provided 'Context' has a span in it (inserted via 'OpenTelemetry.Context.insertSpan'),
 that 'Span' will be used as the parent of the 'Span' created via this API.

 Note: if the @hs-opentelemetry-sdk@ or another SDK is not installed, all actions that use the created
 'Span's produced will be no-ops.

 @since 0.0.1.0
-}
createSpan
  :: (MonadIO m, HasCallStack)
  => Tracer
  -- ^ 'Tracer' to create the span from. Associated 'Processor's and 'Exporter's will be
  -- used for the lifecycle of the created 'Span'
  -> Context
  -- ^ Context, potentially containing a parent span. If no existing parent (or context) exists,
  -- you can use 'OpenTelemetry.Context.empty'.
  -> Text
  -- ^ Span name
  -> SpanArguments
  -- ^ Additional span information
  -> m Span
  -- ^ The created span.
createSpan t ctxt n args = createSpanWithoutCallStack t ctxt n (args {attributes = H.union (attributes args) callerAttributes})


-- | The same thing as 'createSpan', except that it does not have a 'HasCallStack' constraint.
createSpanWithoutCallStack
  :: (MonadIO m)
  => Tracer
  -- ^ 'Tracer' to create the span from. Associated 'Processor's and 'Exporter's will be
  -- used for the lifecycle of the created 'Span'
  -> Context
  -- ^ Context, potentially containing a parent span. If no existing parent (or context) exists,
  -- you can use 'OpenTelemetry.Context.empty'.
  -> Text
  -- ^ Span name
  -> SpanArguments
  -- ^ Additional span information
  -> m Span
  -- ^ The created span.
createSpanWithoutCallStack t ctxt n args@SpanArguments {..} = liftIO $ do
  sId <- newSpanId $ tracerProviderIdGenerator $ tracerProvider t
  let parent = lookupSpan ctxt
  tId <- case parent of
    Nothing -> newTraceId $ tracerProviderIdGenerator $ tracerProvider t
    Just (Span s) ->
      traceId . Types.spanContext <$> readIORef s
    Just (FrozenSpan s) -> pure $ traceId s
    Just (Dropped s) -> pure $ traceId s

  if null $ tracerProviderProcessors $ tracerProvider t
    then pure $ Dropped $ SpanContext defaultTraceFlags False tId sId TraceState.empty
    else do
      (samplingOutcome, attrs, samplingTraceState) <- case parent of
        -- TODO, this seems logically like what we'd do here
        Just (Dropped _) -> pure (Drop, [], TraceState.empty)
        _ ->
          shouldSample
            (tracerProviderSampler $ tracerProvider t)
            ctxt
            tId
            n
            args

      -- TODO properly populate
      let ctxtForSpan =
            SpanContext
              { traceFlags = case samplingOutcome of
                  Drop -> defaultTraceFlags
                  RecordOnly -> defaultTraceFlags
                  RecordAndSample -> setSampled defaultTraceFlags
              , isRemote = False
              , traceState = samplingTraceState
              , spanId = sId
              , traceId = tId
              }

          mkRecordingSpan = do
            st <- maybe getTimestamp pure startTime
            tid <- myThreadId
            let additionalInfo = [("thread.id", toAttribute $ getThreadId tid)]
                is =
                  ImmutableSpan
                    { spanName = n
                    , spanContext = ctxtForSpan
                    , spanParent = parent
                    , spanKind = kind
                    , spanAttributes =
                        A.addAttributes
                          (limitBy t spanAttributeCountLimit)
                          emptyAttributes
                          (H.unions [additionalInfo, attrs, attributes])
                    , spanLinks =
                        let limitedLinks = fromMaybe 128 (linkCountLimit $ tracerProviderSpanLimits $ tracerProvider t)
                        in frozenBoundedCollection limitedLinks $ fmap freezeLink links
                    , spanEvents = emptyAppendOnlyBoundedCollection $ fromMaybe 128 (eventCountLimit $ tracerProviderSpanLimits $ tracerProvider t)
                    , spanStatus = Unset
                    , spanStart = st
                    , spanEnd = Nothing
                    , spanTracer = t
                    }

            when (A.attributesDropped (spanAttributes is) > 0) $ void logDroppedAttributes

            s <- newIORef is
            eResult <- try $ mapM_ (\processor -> spanProcessorOnStart processor s ctxt) $ tracerProviderProcessors $ tracerProvider t
            case eResult of
              Left err -> void $ emitOTelLogRecord H.empty SeverityNumber.Error $ T.pack $ show (err :: SomeException)
              Right _ -> pure ()
            pure $ Span s

      case samplingOutcome of
        Drop -> pure $ Dropped ctxtForSpan
        RecordOnly -> mkRecordingSpan
        RecordAndSample -> mkRecordingSpan
  where
    freezeLink :: NewLink -> Link
    freezeLink NewLink {..} =
      Link
        { frozenLinkContext = linkContext
        , frozenLinkAttributes = A.addAttributes (limitBy t linkAttributeCountLimit) A.emptyAttributes linkAttributes
        }


ownCodeAttributes :: (HasCallStack) => H.HashMap Text Attribute
ownCodeAttributes = case getCallStack callStack of
  -- The call stack is (probably) not frozen and the top entry is our call. Assume we have a full call stack
  -- and look one further step up for our own code.
  (("ownCodeAttributes", _) : ownCode : _) -> srcAttributes ownCode
  -- The call stack doesn't look like we expect, potentially frozen or empty. In this case we can't
  -- really do much, so give up.
  _ -> mempty


callerAttributes :: (HasCallStack) => H.HashMap Text Attribute
callerAttributes = case getCallStack callStack of
  -- The call stack is (probably) not frozen and the top entry is our call. Assume we have a full call stack
  -- and look two further steps up for the caller.
  (("callerAttributes", _) : _ : caller : _) -> srcAttributes caller
  -- The call stack doesn't look like we expect. Guess that it got frozen, and so the most
  -- useful thing to do is to assume that the "caller" is the top of the frozen call stack
  (caller : _) -> srcAttributes caller
  -- Empty call stack
  _ -> mempty


srcAttributes :: (String, SrcLoc) -> H.HashMap Text Attribute
srcAttributes (fn, loc) =
  H.fromList
    [ ("code.function", toAttribute $ T.pack fn)
    , ("code.namespace", toAttribute $ T.pack $ srcLocModule loc)
    , ("code.filepath", toAttribute $ T.pack $ srcLocFile loc)
    , ("code.lineno", toAttribute $ srcLocStartLine loc)
    , ("code.package", toAttribute $ T.pack $ srcLocPackage loc)
    ]


{- | Attributes are added to the end of the span argument list, so will be discarded
 if the number of attributes in the span exceeds the limit.
-}
addAttributesToSpanArguments :: H.HashMap Text Attribute -> SpanArguments -> SpanArguments
addAttributesToSpanArguments attrs args = args {attributes = H.union (attributes args) attrs}


{- | The simplest function for annotating code with trace information.

 @since 0.0.1.0
-}
inSpan
  :: (MonadUnliftIO m, HasCallStack)
  => Tracer
  -> Text
  -- ^ The name of the span. This may be updated later via 'updateName'
  -> SpanArguments
  -- ^ Additional options for creating the span, such as 'SpanKind',
  -- span links, starting attributes, etc.
  -> m a
  -- ^ The action to perform. 'inSpan' will record the time spent on the
  -- action without forcing strict evaluation of the result. Any uncaught
  -- exceptions will be recorded and rethrown.
  -> m a
inSpan t n args m = inSpan'' t n (args {attributes = H.union (attributes args) callerAttributes}) (const m)


inSpan'
  :: (MonadUnliftIO m, HasCallStack)
  => Tracer
  -> Text
  -- ^ The name of the span. This may be updated later via 'updateName'
  -> SpanArguments
  -> (Span -> m a)
  -> m a
inSpan' t n args = inSpan'' t n (args {attributes = H.union (attributes args) callerAttributes})


inSpan''
  :: (MonadUnliftIO m, HasCallStack)
  => Tracer
  -> Text
  -- ^ The name of the span. This may be updated later via 'updateName'
  -> SpanArguments
  -> (Span -> m a)
  -> m a
inSpan'' t n args f = do
  bracketError
    ( liftIO $ do
        ctx <- getContext
        s <- createSpanWithoutCallStack t ctx n args
        adjustContext (insertSpan s)
        pure (lookupSpan ctx, s)
    )
    ( \e (parent, s) -> liftIO $ do
        forM_ e $ \(SomeException inner) -> do
          setStatus s $ Error $ T.pack $ displayException inner
          recordException s [("exception.escaped", toAttribute True)] Nothing inner
        endSpan s Nothing
        adjustContext $ \ctx ->
          maybe (removeSpan ctx) (`insertSpan` ctx) parent
    )
    (\(_, s) -> f s)


{- | Returns whether the the @Span@ is currently recording. If a span
 is dropped, this will always return False. If a span is from an
 external process, this will return True, and if the span was
 created by this process, the span will return True until endSpan
 is called.
-}
isRecording :: (MonadIO m) => Span -> m Bool
isRecording (Span s) = liftIO (isNothing . spanEnd <$> readIORef s)
isRecording (FrozenSpan _) = pure True
isRecording (Dropped _) = pure False


{- | Add an attribute to a span. Only has a useful effect on recording spans.

As an application developer when you need to record an attribute first consult existing semantic conventions for Resources, Spans, and Metrics. If an appropriate name does not exists you will need to come up with a new name. To do that consider a few options:

The name is specific to your company and may be possibly used outside the company as well. To avoid clashes with names introduced by other companies (in a distributed system that uses applications from multiple vendors) it is recommended to prefix the new name by your company’s reverse domain name, e.g. 'com.acme.shopname'.

The name is specific to your application that will be used internally only. If you already have an internal company process that helps you to ensure no name clashes happen then feel free to follow it. Otherwise it is recommended to prefix the attribute name by your application name, provided that the application name is reasonably unique within your organization (e.g. 'myuniquemapapp.longitude' is likely fine). Make sure the application name does not clash with an existing semantic convention namespace.

The name may be generally applicable to applications in the industry. In that case consider submitting a proposal to this specification to add a new name to the semantic conventions, and if necessary also to add a new namespace.

It is recommended to limit names to printable Basic Latin characters (more precisely to 'U+0021' .. 'U+007E' subset of Unicode code points), although the Haskell OpenTelemetry specification DOES provide full Unicode support.

Attribute names that start with 'otel.' are reserved to be defined by OpenTelemetry specification. These are typically used to express OpenTelemetry concepts in formats that don’t have a corresponding concept.

For example, the 'otel.library.name' attribute is used to record the instrumentation library name, which is an OpenTelemetry concept that is natively represented in OTLP, but does not have an equivalent in other telemetry formats and protocols.

Any additions to the 'otel.*' namespace MUST be approved as part of OpenTelemetry specification.

@since 0.0.1.0
-}
addAttribute
  :: (MonadIO m, A.ToAttribute a)
  => Span
  -- ^ Span to add the attribute to
  -> Text
  -- ^ Attribute name
  -> a
  -- ^ Attribute value
  -> m ()
addAttribute (Span s) k v = liftIO $ modifyIORef' s $ \(!i) ->
  i
    { spanAttributes =
        OpenTelemetry.Attributes.addAttribute
          (limitBy (spanTracer i) spanAttributeCountLimit)
          (spanAttributes i)
          k
          v
    }
addAttribute (FrozenSpan _) _ _ = pure ()
addAttribute (Dropped _) _ _ = pure ()


{- | A convenience function related to 'addAttribute' that adds multiple attributes to a span at the same time.

 This function may be slightly more performant than repeatedly calling 'addAttribute'.

 @since 0.0.1.0
-}
addAttributes :: (MonadIO m) => Span -> H.HashMap Text A.Attribute -> m ()
addAttributes (Span s) attrs = liftIO $ modifyIORef' s $ \(!i) ->
  i
    { spanAttributes =
        OpenTelemetry.Attributes.addAttributes
          (limitBy (spanTracer i) spanAttributeCountLimit)
          (spanAttributes i)
          attrs
    }
addAttributes (FrozenSpan _) _ = pure ()
addAttributes (Dropped _) _ = pure ()


{- | Add an event to a recording span. Events will not be recorded for remote spans and dropped spans.

 @since 0.0.1.0
-}
addEvent :: (MonadIO m) => Span -> NewEvent -> m ()
addEvent (Span s) NewEvent {..} = liftIO $ do
  t <- maybe getTimestamp pure newEventTimestamp
  modifyIORef' s $ \(!i) ->
    i
      { spanEvents =
          appendToBoundedCollection (spanEvents i) $
            Event
              { eventName = newEventName
              , eventAttributes =
                  A.addAttributes
                    (limitBy (spanTracer i) eventAttributeCountLimit)
                    emptyAttributes
                    newEventAttributes
              , eventTimestamp = t
              }
      }
addEvent (FrozenSpan _) _ = pure ()
addEvent (Dropped _) _ = pure ()


{- | Sets the Status of the Span. If used, this will override the default @Span@ status, which is @Unset@.

 These values form a total order: Ok > Error > Unset. This means that setting Status with StatusCode=Ok will override any prior or future attempts to set span Status with StatusCode=Error or StatusCode=Unset.

 @since 0.0.1.0
-}
setStatus :: (MonadIO m) => Span -> SpanStatus -> m ()
setStatus (Span s) st = liftIO $ modifyIORef' s $ \(!i) ->
  i
    { spanStatus = max st (spanStatus i)
    }
setStatus (FrozenSpan _) _ = pure ()
setStatus (Dropped _) _ = pure ()


alterFlags :: (MonadIO m) => Span -> (TraceFlags -> TraceFlags) -> m ()
alterFlags (Span s) f = liftIO $ modifyIORef' s $ \(!i) ->
  i
    { spanContext =
        (spanContext i)
          { traceFlags = f $ traceFlags $ spanContext i
          }
    }
alterFlags (FrozenSpan _) _ = pure ()
alterFlags (Dropped _) _ = pure ()


{- |
Updates the Span name. Upon this update, any sampling behavior based on Span name will depend on the implementation.

Note that @Sampler@s can only consider information already present during span creation. Any changes done later, including updated span name, cannot change their decisions.

Alternatives for the name update may be late Span creation, when Span is started with the explicit timestamp from the past at the moment where the final Span name is known, or reporting a Span with the desired name as a child Span.

@since 0.0.1.0
-}
updateName
  :: (MonadIO m)
  => Span
  -> Text
  -- ^ The new span name, which supersedes whatever was passed in when the Span was started
  -> m ()
updateName (Span s) n = liftIO $ modifyIORef' s $ \(!i) -> i {spanName = n}
updateName (FrozenSpan _) _ = pure ()
updateName (Dropped _) _ = pure ()


{- |
Signals that the operation described by this span has now (or at the time optionally specified) ended.

This does have any effects on child spans. Those may still be running and can be ended later.

This also does not inactivate the Span in any Context it is active in. It is still possible to use an ended span as
parent via a Context it is contained in. Also, putting the Span into a Context will still work after the Span was ended.

@since 0.0.1.0
-}
endSpan
  :: (MonadIO m)
  => Span
  -> Maybe Timestamp
  -- ^ Optional @Timestamp@ signalling the end time of the span. If not provided, the current time will be used.
  -> m ()
endSpan (Span s) mts = liftIO $ do
  ts <- maybe getTimestamp pure mts
  (alreadyFinished, frozenS) <- atomicModifyIORef' s $ \(!i) ->
    let ref = i {spanEnd = spanEnd i <|> Just ts}
    in (ref, (isJust $ spanEnd i, ref))
  unless alreadyFinished $ do
    eResult <- try $ mapM_ (`spanProcessorOnEnd` s) $ tracerProviderProcessors $ tracerProvider $ spanTracer frozenS
    case eResult of
      Left err -> print (err :: SomeException)
      Right _ -> pure ()
endSpan (FrozenSpan _) _ = pure ()
endSpan (Dropped _) _ = pure ()


{- | A specialized variant of @addEvent@ that records attributes conforming to
 the OpenTelemetry specification's
 <https://github.com/open-telemetry/opentelemetry-specification/blob/49c2f56f3c0468ceb2b69518bcadadd96e0a5a8b/specification/trace/semantic_conventions/exceptions.md semantic conventions>

 @since 0.0.1.0
-}
recordException :: (MonadIO m, Exception e) => Span -> H.HashMap Text Attribute -> Maybe Timestamp -> e -> m ()
recordException s attrs ts e = liftIO $ do
  cs <- whoCreated e
  let message = T.pack $ show e
  addEvent s $
    NewEvent
      { newEventName = "exception"
      , newEventAttributes =
          H.union
            attrs
            [ ("exception.type", A.toAttribute $ T.pack $ show $ typeOf e)
            , ("exception.message", A.toAttribute message)
            , ("exception.stacktrace", A.toAttribute $ T.unlines $ map T.pack cs)
            ]
      , newEventTimestamp = ts
      }


-- | Returns @True@ if the @SpanContext@ has a non-zero @TraceID@ and a non-zero @SpanID@
isValid :: SpanContext -> Bool
isValid sc =
  not
    (isEmptyTraceId (traceId sc) && isEmptySpanId (spanId sc))


{- |
Returns @True@ if the @SpanContext@ was propagated from a remote parent,

When extracting a SpanContext through the Propagators API, isRemote MUST return @True@,
whereas for the SpanContext of any child spans it MUST return @False@.
-}
spanIsRemote :: (MonadIO m) => Span -> m Bool
spanIsRemote (Span s) = liftIO $ do
  i <- readIORef s
  pure $ Types.isRemote $ Types.spanContext i
spanIsRemote (FrozenSpan c) = pure $ Types.isRemote c
spanIsRemote (Dropped _) = pure False


{- | Really only intended for tests, this function does not conform
 to semantic versioning .
-}
unsafeReadSpan :: (MonadIO m) => Span -> m ImmutableSpan
unsafeReadSpan = \case
  Span ref -> liftIO $ readIORef ref
  FrozenSpan _s -> error "This span is from another process"
  Dropped _s -> error "This span was dropped"


wrapSpanContext :: SpanContext -> Span
wrapSpanContext = FrozenSpan


{- | This can be useful for pulling data for attributes and
 using it to copy / otherwise use the data to further enrich
 instrumentation.
-}
spanGetAttributes :: (MonadIO m) => Span -> m A.Attributes
spanGetAttributes = \case
  Span ref -> do
    s <- liftIO $ readIORef ref
    pure $ spanAttributes s
  FrozenSpan _ -> pure A.emptyAttributes
  Dropped _ -> pure A.emptyAttributes


{- | Sometimes, you may have a more accurate notion of when a traced
 operation has ended. In this case you may call 'getTimestamp', and then
 supply 'endSpan' with the more accurate timestamp you have acquired.

 When using the monadic interface, (such as 'OpenTelemetry.Trace.Monad.inSpan', you may call
 'endSpan' early to record the information, and the first call to 'endSpan' will be honored.

 @since 0.0.1.0
-}
getTimestamp :: (MonadIO m) => m Timestamp
getTimestamp = liftIO $ coerce @(IO TimeSpec) @(IO Timestamp) $ getTime Realtime


limitBy
  :: Tracer
  -> (SpanLimits -> Maybe Int)
  -- ^ Attribute count
  -> AttributeLimits
limitBy t countF =
  AttributeLimits
    { attributeCountLimit = countLimit
    , attributeLengthLimit = lengthLimit
    }
  where
    countLimit =
      countF (tracerProviderSpanLimits $ tracerProvider t)
        <|> attributeCountLimit
          (tracerProviderAttributeLimits $ tracerProvider t)
    lengthLimit =
      spanAttributeValueLengthLimit (tracerProviderSpanLimits $ tracerProvider t)
        <|> attributeLengthLimit
          (tracerProviderAttributeLimits $ tracerProvider t)


globalTracer :: IORef TracerProvider
globalTracer = unsafePerformIO $ do
  p <-
    createTracerProvider
      []
      emptyTracerProviderOptions
  newIORef p
{-# NOINLINE globalTracer #-}


data TracerProviderOptions = TracerProviderOptions
  { tracerProviderOptionsIdGenerator :: IdGenerator
  , tracerProviderOptionsSampler :: Sampler
  , tracerProviderOptionsResources :: MaterializedResources
  , tracerProviderOptionsAttributeLimits :: AttributeLimits
  , tracerProviderOptionsSpanLimits :: SpanLimits
  , tracerProviderOptionsPropagators :: Propagator Context RequestHeaders ResponseHeaders
  }


{- | Options for creating a 'TracerProvider' with invalid ids, no resources, default limits, and no propagators.

 In effect, tracing is a no-op when using this configuration.

 @since 0.0.1.0
-}
emptyTracerProviderOptions :: TracerProviderOptions
emptyTracerProviderOptions =
  TracerProviderOptions
    dummyIdGenerator
    (parentBased $ parentBasedOptions alwaysOn)
    emptyMaterializedResources
    defaultAttributeLimits
    defaultSpanLimits
    mempty


{- | Initialize a new tracer provider

 You should generally use 'getGlobalTracerProvider' for most applications.
-}
createTracerProvider :: (MonadIO m) => [SpanProcessor] -> TracerProviderOptions -> m TracerProvider
createTracerProvider ps opts = liftIO $ do
  let g = tracerProviderOptionsIdGenerator opts
  pure $
    TracerProvider
      (V.fromList ps)
      g
      (tracerProviderOptionsSampler opts)
      (tracerProviderOptionsResources opts)
      (tracerProviderOptionsAttributeLimits opts)
      (tracerProviderOptionsSpanLimits opts)
      (tracerProviderOptionsPropagators opts)


{- | Access the globally configured 'TracerProvider'. Once the
 the global tracer provider is initialized via the OpenTelemetry SDK,
 'Tracer's created from this 'TracerProvider' will export spans to their
 configured exporters. Prior to that, any 'Tracer's acquired from the
 uninitialized 'TracerProvider' will create no-op spans.

 @since 0.0.1.0
-}
getGlobalTracerProvider :: (MonadIO m) => m TracerProvider
getGlobalTracerProvider = liftIO $ readIORef globalTracer


{- | Overwrite the globally configured 'TracerProvider'.

 'Tracer's acquired from the previously installed 'TracerProvider'
 will continue to use that 'TracerProvider's configured span processors,
 exporters, and other settings.

 @since 0.0.1.0
-}
setGlobalTracerProvider :: (MonadIO m) => TracerProvider -> m ()
setGlobalTracerProvider = liftIO . writeIORef globalTracer


getTracerProviderResources :: TracerProvider -> MaterializedResources
getTracerProviderResources = tracerProviderResources


getTracerProviderPropagators :: TracerProvider -> Propagator Context RequestHeaders ResponseHeaders
getTracerProviderPropagators = tracerProviderPropagators


-- | Tracer configuration options.
newtype TracerOptions = TracerOptions
  { tracerSchema :: Maybe Text
  -- ^ OpenTelemetry provides a schema for describing common attributes so that backends can easily parse and identify relevant information.
  -- It is important to understand these conventions when writing instrumentation, in order to normalize your data and increase its utility.
  --
  -- In particular, this option is valuable to set when possible, because it allows vendors to normalize data accross releases in order to account
  -- for attribute name changes.
  }


-- | Default Tracer options
tracerOptions :: TracerOptions
tracerOptions = TracerOptions Nothing


{- | A small utility lens for extracting a 'Tracer' from a larger data type

 This will generally be most useful as a means of implementing 'OpenTelemetry.Trace.Monad.getTracer'

 @since 0.0.1.0
-}
class HasTracer s where
  tracerL :: Lens' s Tracer


makeTracer :: TracerProvider -> InstrumentationLibrary -> TracerOptions -> Tracer
makeTracer tp n TracerOptions {} = Tracer n tp


getTracer :: (MonadIO m) => TracerProvider -> InstrumentationLibrary -> TracerOptions -> m Tracer
getTracer tp n TracerOptions {} = liftIO $ do
  pure $ Tracer n tp
{-# DEPRECATED getTracer "use makeTracer" #-}


getImmutableSpanTracer :: ImmutableSpan -> Tracer
getImmutableSpanTracer = spanTracer


getTracerTracerProvider :: Tracer -> TracerProvider
getTracerTracerProvider = tracerProvider


{- | Smart constructor for 'SpanArguments' providing reasonable values for most 'Span's created
 that are internal to an application.

 Defaults:

 - `kind`: `Internal`
 - `attributes`: @[]@
 - `links`: @[]@
 - `startTime`: `Nothing` (`getTimestamp` will be called upon `Span` creation)
-}
defaultSpanArguments :: SpanArguments
defaultSpanArguments =
  SpanArguments
    { kind = Internal
    , attributes = []
    , links = []
    , startTime = Nothing
    }


{- | This method provides a way for provider to do any cleanup required.

 This will also trigger shutdowns on all internal processors.

 @since 0.0.1.0
-}
shutdownTracerProvider :: (MonadIO m) => TracerProvider -> m ()
shutdownTracerProvider TracerProvider {..} = liftIO $ do
  asyncShutdownResults <- forM tracerProviderProcessors $ \processor -> do
    spanProcessorShutdown processor
  mapM_ wait asyncShutdownResults


{- | This method provides a way for provider to immediately export all spans that have not yet
 been exported for all the internal processors.
-}
forceFlushTracerProvider
  :: (MonadIO m)
  => TracerProvider
  -> Maybe Int
  -- ^ Optional timeout in microseconds, defaults to 5,000,000 (5s)
  -> m FlushResult
  -- ^ Result that denotes whether the flush action succeeded, failed, or timed out.
forceFlushTracerProvider TracerProvider {..} mtimeout = liftIO $ do
  jobs <- forM tracerProviderProcessors $ \processor -> async $ do
    spanProcessorForceFlush processor
  mresult <-
    timeout (fromMaybe 5_000_000 mtimeout) $
      foldM
        ( \status action -> do
            res <- waitCatch action
            pure $! case res of
              Left _err -> FlushError
              Right _ok -> status
        )
        FlushSuccess
        jobs
  case mresult of
    Nothing -> pure FlushTimeout
    Just res -> pure res


{- | Utility function to only perform costly attribute annotations
 for spans that are actually
-}
whenSpanIsRecording :: (MonadIO m) => Span -> m () -> m ()
whenSpanIsRecording (Span ref) m = do
  span_ <- liftIO $ readIORef ref
  case spanEnd span_ of
    Nothing -> m
    Just _ -> pure ()
whenSpanIsRecording (FrozenSpan _) _ = pure ()
whenSpanIsRecording (Dropped _) _ = pure ()


timestampNanoseconds :: Timestamp -> Word64
timestampNanoseconds (Timestamp TimeSpec {..}) = fromIntegral (sec * 1_000_000_000) + fromIntegral nsec
