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
  tracerIsEnabled,
  HasTracer (..),
  makeTracer,
  getTracer,
  getImmutableSpanTracer,
  getTracerTracerProvider,
  InstrumentationLibrary (..),
  instrumentationLibrary,
  withSchemaUrl,
  withLibraryAttributes,
  detectInstrumentationLibrary,
  TracerOptions (..),
  tracerOptions,

  -- * Span operations
  Span,
  toImmutableSpan,
  FrozenOrDropped (..),
  ImmutableSpan (..),
  SpanHot (..),
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
  wrapDroppedContext,
  SpanKind (..),
  defaultSpanArguments,
  SpanArguments (..),

  -- ** Recording @Event@s
  Event (..),
  NewEvent (..),
  addEvent,

  -- ** Enriching @Span@s with additional information
  updateName,
  OpenTelemetry.Trace.Core.addAttribute,
  OpenTelemetry.Trace.Core.addAttributes,
  OpenTelemetry.Trace.Core.addAttributes',
  spanGetAttributes,
  Attribute (..),
  ToAttribute (..),
  PrimitiveAttribute (..),
  ToPrimitiveAttribute (..),

  -- *** Attribute builder
  A.AttrsBuilder,
  A.attr,
  A.optAttr,
  (A..@),
  (A..@?),
  A.buildAttrs,

  Link (..),
  NewLink (..),
  addLink,

  -- ** Recording error information
  recordException,
  recordError,
  setStatus,
  SpanStatus (..),

  -- ** Exception handling
  ExceptionClassification (..),
  ExceptionResponse (..),
  ExceptionHandler,
  defaultExceptionResponse,
  resolveException,

  -- ** Completing @Span@s
  endSpan,

  -- ** Accessing other @Span@ information
  getSpanContext,
  isRecording,
  isValid,
  spanIsRemote,

  -- * Active span
  getActiveSpan,
  withActiveSpan,
  getActiveSpanContext,

  -- * Event constructors
  newEvent,
  newEventWith,

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
import qualified Control.Concurrent.Thread.Storage as TLS
import qualified Control.Exception as EUnsafe
import Control.Exception (Exception (..), SomeException (..), catch)
import Control.Monad
import Control.Monad.IO.Class
import Control.Monad.IO.Unlift
import Data.Coerce
import qualified Data.HashMap.Strict as H
import Data.IORef (IORef, atomicWriteIORef, newIORef, readIORef)
import Data.List (foldl')
import Data.Maybe (fromMaybe)
import Data.Text (Text)
import qualified Data.Text as T
import Data.Typeable
import qualified Data.Vector as V
import Data.Word (Word64)
import GHC.Stack
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
import OpenTelemetry.Propagator (TextMapPropagator)
import OpenTelemetry.Resource
import OpenTelemetry.Trace.Id
import OpenTelemetry.Trace.Id.Generator
import OpenTelemetry.Trace.Id.Generator.Dummy
import OpenTelemetry.Trace.Sampler
import qualified OpenTelemetry.Trace.TraceState as TraceState
import OpenTelemetry.Util
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
  -- Try and infer source code information unless the user has set any of the attributes already, which
  -- we take as an indication that our automatic strategy won't work well.
createSpan t ctxt n args = createSpanWithoutCallStack t ctxt n (addAttributesToSpanArgumentsIfNonePresent callerAttributes args)
{-# INLINE createSpan #-}


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
createSpanWithoutCallStack t ctxt n args = liftIO $ do
  !tidInt <- getThreadId <$> myThreadId
  createSpanHelper t ctxt n args H.empty tidInt
{-# INLINE createSpanWithoutCallStack #-}


{- | Like 'createSpanWithoutCallStack' but accepts lazy extra attributes
(e.g. source location info) that are only forced when the span is recorded.
The Int parameter is a pre-computed thread ID for the @thread.id@ span
attribute, avoiding a redundant myThreadId + FFI call when the caller
(e.g. inSpanInternal) already has the value.
-}
createSpanHelper :: Tracer -> Context -> Text -> SpanArguments -> AttributeMap -> Int -> IO Span
createSpanHelper t ctxt n args@SpanArguments {..} extraAttrs !tidInt = do
  let !tp = tracerProvider t
      !procs = tracerProviderProcessors tp
  isShutdown <- readIORef $ tracerProviderIsShutdown tp
  if isShutdown || V.null procs
    then do
      let parent = lookupSpan ctxt
          parentSc = case parent of
            Nothing -> Nothing
            Just (Span imm) -> Just (Types.spanContext imm)
            Just (FrozenSpan s') -> Just s'
            Just (Dropped s') -> Just s'
          (!tId, !parentTs) = case parentSc of
            Nothing -> ("00000000000000000000000000000000", TraceState.empty)
            Just sc -> (traceId sc, traceState sc)
      pure $! Dropped $! SpanContext defaultTraceFlags False tId "0000000000000000" parentTs
    else do
      let !idGen = tracerProviderIdGenerator tp
          parent = lookupSpan ctxt
          parentSc = case parent of
            Nothing -> Nothing
            Just (Span imm) -> Just (Types.spanContext imm)
            Just (FrozenSpan s) -> Just s
            Just (Dropped s) -> Just s
      sId <- newSpanId idGen

      tId <- case parentSc of
        Nothing -> newTraceId idGen
        Just sc -> pure $! traceId sc

      let !parentTraceState = maybe TraceState.empty traceState parentSc

      (samplingOutcome, samplerAttrs, samplingTraceState) <- case parent of
        Just (Dropped _) -> pure (Drop, H.empty, parentTraceState)
        _ ->
          shouldSample
            (tracerProviderSampler tp)
            ctxt
            tId
            n
            args

      let !ctxtForSpan =
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

      case samplingOutcome of
        Drop -> pure $! Dropped ctxtForSpan
        _ -> do
          st <- maybe getTimestampIO pure startTime
          let !spanLimits = tracerProviderSpanLimits tp
              !attrLimits = tracerSpanAttributeLimits t
              !tidVal = toAttribute tidInt
              !allAttrs =
                H.insert ("thread.id" :: Text) tidVal $!
                  case (H.null samplerAttrs, H.null extraAttrs) of
                    (True, True) -> attributes
                    (True, False) -> H.union attributes extraAttrs
                    (False, True) -> H.union samplerAttrs attributes
                    (False, False) -> H.union samplerAttrs (H.union attributes extraAttrs)
              !initialAttrs = A.addAttributes attrLimits emptyAttributes allAttrs
              !initialLinks =
                foldl' (\c l -> appendToBoundedCollection c (freezeLink t l)) emptyLinks links
              !linkLimit = fromMaybe 128 (linkCountLimit spanLimits)
              !evtLimit = fromMaybe 128 (eventCountLimit spanLimits)
              emptyLinks = emptyAppendOnlyBoundedCollection linkLimit
              emptyEvts = emptyAppendOnlyBoundedCollection evtLimit

          when (A.getDropped initialAttrs > 0) $ void logDroppedAttributes

          hotRef <- newIORef $! SpanHot
            { hotName = n
            , hotEnd = NoTimestamp
            , hotAttributes = initialAttrs
            , hotLinks = initialLinks
            , hotEvents = emptyEvts
            , hotStatus = Unset
            }
          let !imm = ImmutableSpan
                { spanContext = ctxtForSpan
                , spanKind = kind
                , spanStart = st
                , spanParent = parent
                , spanTracer = t
                , spanHot = hotRef
                }
          V.mapM_ (\processor -> spanProcessorOnStart processor imm ctxt) procs
            `catch` \(err :: SomeException) ->
              void $ emitOTelLogRecord H.empty SeverityNumber.Error $ T.pack $ show err
          pure $! Span imm


{- |
Creates source code attributes describing the caller of the current function. You should use this if you are getting
source code attributes from inside a function that is creating a span.

Note: this will return nothing if the call stack is frozen.
-}
ownCodeAttributes :: (HasCallStack) => AttributeMap
ownCodeAttributes = case getCallStack callStack of
  -- The call stack is (probably) not frozen and the top entry is our call. Assume we have a full call stack
  -- and look one further step up for our own code.
  (("ownCodeAttributes", ownCodeCalledAt) : (ownFunction, _ownFunctionCalledAt) : _) ->
    -- The source location attributes for the call to 'ownCode' will do well enough to identify the function
    fnAttributes ownFunction <> srcLocAttributes ownCodeCalledAt
  (("ownCodeAttributes", ownCodeCalledAt) : _) ->
    -- We couldn't determine the calling function, but we should still be able to see the call location
    fnAttributes "<unknown>" <> srcLocAttributes ownCodeCalledAt
  -- The call stack doesn't look like we expect, potentially frozen or empty. In this case we can't
  -- really do much, so give up. (see discussion below in 'callerAttributes')
  _ -> mempty


{- |
Creates source code attributes describing where the current function is called. You should use this if
you are getting source code attributes from inside a "span creation" function.

Note: this will return nothing if the call stack is frozen.
-}
callerAttributes :: (HasCallStack) => AttributeMap
callerAttributes = case getCallStack callStack of
  -- The call stack is (probably) not frozen and the top entry is our call. Assume we have a full call stack
  -- and look two further steps up for the caller.
  (("callerAttributes", _callerAttributesCalledAt) : (_ownFunction, ownFunctionCalledAt) : (callerFunction, _) : _) ->
    fnAttributes callerFunction <> srcLocAttributes ownFunctionCalledAt
  (("callerAttributes", _callerAttributesCalledAt) : (_ownFunction, ownFunctionCalledAt) : _) ->
    -- We couldn't determine the calling function, but we should still be able to see the call location
    fnAttributes "<unknown>" <> srcLocAttributes ownFunctionCalledAt
  -- The call stack doesn't look like we expect. It could be empty (in which case we can't do anything), or frozen
  --
  -- If it's frozen, there are at least two ways we could interpret it:
  -- 1. The "current function" is the top of the call stack. This is likely if the call stack got frozen in a
  -- helper function.
  -- 2. The "caller" is the top of the call stack. This is likely if the call stack got frozen further up.
  --
  -- This means we really don't know what is going on, so we can't pick something that will work in all
  -- circumstances. So we do nothing, and rely on the user to set these themselves.
  _ -> mempty


fnAttributes :: String -> AttributeMap
fnAttributes fn =
  H.fromList
    [ ("code.function", toAttribute $ T.pack fn)
    ]


srcLocAttributes :: SrcLoc -> AttributeMap
srcLocAttributes loc =
  H.insert ("code.namespace" :: Text) (toAttribute $ T.pack $ srcLocModule loc) $!
    H.insert ("code.filepath" :: Text) (toAttribute $ T.pack $ srcLocFile loc) $!
      H.insert ("code.lineno" :: Text) (toAttribute $ srcLocStartLine loc) $!
        H.singleton ("code.package" :: Text) (toAttribute $ T.pack $ srcLocPackage loc)


{- | Attributes are added to the end of the span argument list, so will be discarded
 if the number of attributes in the span exceeds the limit.
-}
addAttributesToSpanArguments :: AttributeMap -> SpanArguments -> SpanArguments
addAttributesToSpanArguments attrs args = args {attributes = H.union (attributes args) attrs}


-- | Add the given attributes to the span arguments, but only if *none* of them are present already.
addAttributesToSpanArgumentsIfNonePresent :: AttributeMap -> SpanArguments -> SpanArguments
addAttributesToSpanArgumentsIfNonePresent attrs args
  | H.null attrs = args
  | H.null existingAttrs = addAttributesToSpanArguments attrs args
  | anyOverlap = args
  | otherwise = addAttributesToSpanArguments attrs args
  where
    existingAttrs = attributes args
    anyOverlap = any (`H.member` existingAttrs) (H.keys attrs)


hasCodeAttributes :: AttributeMap -> Bool
hasCodeAttributes m =
  H.member ("code.function" :: Text) m
    || H.member ("code.namespace" :: Text) m
    || H.member ("code.filepath" :: Text) m
{-# INLINE hasCodeAttributes #-}


{- | Extract caller source location from a 'CallStack' and build attributes.
Takes the 'CallStack' directly so the thunk captures only the implicit
parameter, deferring all 'T.pack' / 'H.insert' work until forced.

The call stack from @inSpan@ (HasCallStack) looks like:
  (\"inSpan\", call_site) : (caller_of_inSpan, ...) : ...
We want the call_site (where inSpan was called) and the caller function name.
-}
callerCodeAttrs :: CallStack -> AttributeMap
callerCodeAttrs cs = case getCallStack cs of
  ((_inSpanFn, callSite) : (callerFn, _) : _) ->
    H.insert ("code.function" :: Text) (toAttribute $ T.pack callerFn) $!
      srcLocAttributes callSite
  ((_inSpanFn, callSite) : _) ->
    H.insert ("code.function" :: Text) (toAttribute ("<unknown>" :: Text)) $!
      srcLocAttributes callSite
  _ -> H.empty
{-# INLINE callerCodeAttrs #-}


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
inSpan t n args m =
  let codeAttrs = if hasCodeAttributes (attributes args) then H.empty else callerCodeAttrs callStack
  in inSpanInternal t n args codeAttrs (const m)
{-# INLINE inSpan #-}


inSpan'
  :: (MonadUnliftIO m, HasCallStack)
  => Tracer
  -> Text
  -- ^ The name of the span. This may be updated later via 'updateName'
  -> SpanArguments
  -> (Span -> m a)
  -> m a
-- Try and infer source code information unless the user has set any of the attributes already, which
-- we take as an indication that our automatic strategy won't work well.
inSpan' t n args =
  let codeAttrs = if hasCodeAttributes (attributes args) then H.empty else callerCodeAttrs callStack
  in inSpanInternal t n args codeAttrs
{-# INLINE inSpan' #-}


inSpan''
  :: (MonadUnliftIO m, HasCallStack)
  => Tracer
  -> Text
  -- ^ The name of the span. This may be updated later via 'updateName'
  -> SpanArguments
  -> (Span -> m a)
  -> m a
inSpan'' t n args = inSpanInternal t n args H.empty
{-# INLINE inSpan'' #-}


{- | Internal workhorse: takes lazy extra attributes (e.g. callerAttributes)
that are only evaluated when the span is actually recorded.
-}
inSpanInternal
  :: (MonadUnliftIO m)
  => Tracer
  -> Text
  -> SpanArguments
  -> AttributeMap
  -> (Span -> m a)
  -> m a
inSpanInternal t n args extraAttrs f
  | V.null (tracerProviderProcessors (tracerProvider t)) =
      -- Fast path: no processors means every span is Dropped. Skip mask,
      -- context modification, and exception recording entirely. We still
      -- propagate trace ID via a lightweight Dropped span for context
      -- continuity in case a child uses a different (active) tracer.
      liftIO (getContext >>= \ctx -> createSpanHelper t ctx n args extraAttrs (-1)) >>= f
  | otherwise = withRunInIO $ \run -> EUnsafe.mask $ \restore -> do
      -- Setup (runs masked — protected from async exceptions)
      tid <- myThreadId
      let !tidWord = TLS.getThreadId tid
      mctx <- TLS.lookupRaw threadContextMap tidWord
      let !ctx = fromMaybe OpenTelemetry.Context.empty mctx
      s <- createSpanHelper t ctx n args extraAttrs (fromIntegral tidWord)
      TLS.updateRaw threadContextMap tid tidWord $ \_ ->
        (Just (insertSpan s ctx), ())
      -- User code (unmasked via restore)
      a <- restore (run $ f s) `EUnsafe.catch` \someEx@(SomeException inner) -> do
        let ExceptionResponse classification exAttrs = resolveException t someEx
        case classification of
          ErrorException -> do
            setStatus s $ Error $ T.pack $ displayException inner
            recordException s (H.union [("exception.escaped", toAttribute True)] exAttrs) Nothing inner
          RecordedException ->
            recordException s (H.union [("exception.escaped", toAttribute True)] exAttrs) Nothing inner
          IgnoredException ->
            pure ()
        endSpan s Nothing
        TLS.updateRaw threadContextMap tid tidWord $ \_ ->
          (Just ctx, ())
        EUnsafe.throwIO someEx
      -- Success cleanup (runs masked — non-blocking, no uninterruptibleMask_ needed)
      endSpan s Nothing
      TLS.updateRaw threadContextMap tid tidWord $ \_ ->
        (Just ctx, ())
      pure a
{-# INLINABLE inSpanInternal #-}
{-# SPECIALIZE inSpanInternal :: Tracer -> Text -> SpanArguments -> AttributeMap -> (Span -> IO a) -> IO a #-}


{- | Returns whether the the @Span@ is currently recording. If a span
 is dropped, this will always return False. If a span is from an
 external process, this will return True, and if the span was
 created by this process, the span will return True until endSpan
 is called.
-}
isRecording :: (MonadIO m) => Span -> m Bool
isRecording (Span imm) = liftIO (not . isEnded . hotEnd <$> readIORef (spanHot imm))
isRecording (FrozenSpan _) = pure False
isRecording (Dropped _) = pure False
{-# INLINE isRecording #-}


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
addAttribute (Span imm) k v = liftIO $ casModifyIORef_ (spanHot imm) $ \(!h) ->
  if isEnded (hotEnd h)
    then h
    else
      h
        { hotAttributes =
            OpenTelemetry.Attributes.addAttribute
              (tracerSpanAttributeLimits $ spanTracer imm)
              (hotAttributes h)
              k
              v
        }
addAttribute (FrozenSpan _) _ _ = pure ()
addAttribute (Dropped _) _ _ = pure ()
{-# INLINABLE addAttribute #-}
{-# SPECIALIZE OpenTelemetry.Trace.Core.addAttribute :: (A.ToAttribute a) => Span -> Text -> a -> IO () #-}


{- | A convenience function related to 'addAttribute' that adds multiple attributes to a span at the same time.

 This function may be slightly more performant than repeatedly calling 'addAttribute'.

 @since 0.0.1.0
-}
addAttributes :: (MonadIO m) => Span -> H.HashMap Text A.Attribute -> m ()
addAttributes (Span imm) attrs = liftIO $ casModifyIORef_ (spanHot imm) $ \(!h) ->
  if isEnded (hotEnd h)
    then h
    else
      h
        { hotAttributes =
            OpenTelemetry.Attributes.addAttributes
              (tracerSpanAttributeLimits $ spanTracer imm)
              (hotAttributes h)
              attrs
        }
addAttributes (FrozenSpan _) _ = pure ()
addAttributes (Dropped _) _ = pure ()
{-# INLINABLE addAttributes #-}
{-# SPECIALIZE OpenTelemetry.Trace.Core.addAttributes :: Span -> H.HashMap Text A.Attribute -> IO () #-}


{- | Like 'addAttributes', but takes an 'A.AttrsBuilder' instead of a 'HashMap'.
Avoids intermediate tuple, list, and 'HashMap' allocation by folding each
attribute directly into the span's existing 'Attributes'.

With typed 'AttributeKey's from semantic conventions:

@
'addAttributes'' span $
    SC.http_request_method '.@' method
 <> SC.url_full '.@' url
 <> SC.server_port '.@?' mPort
@

With plain 'Text' keys:

@
'addAttributes'' span $
    'attr' "custom.key" value
 <> 'optAttr' "custom.optional" mValue
@

@since 0.4.1.0
-}
addAttributes' :: (MonadIO m) => Span -> A.AttrsBuilder -> m ()
addAttributes' (Span imm) builder = liftIO $ casModifyIORef_ (spanHot imm) $ \(!h) ->
  if isEnded (hotEnd h)
    then h
    else
      h
        { hotAttributes =
            A.addAttributesFromBuilder
              (tracerSpanAttributeLimits $ spanTracer imm)
              (hotAttributes h)
              builder
        }
addAttributes' (FrozenSpan _) _ = pure ()
addAttributes' (Dropped _) _ = pure ()
{-# INLINABLE addAttributes' #-}
{-# SPECIALIZE addAttributes' :: Span -> A.AttrsBuilder -> IO () #-}


-- Skip the CAS entirely when there's nothing to add.
{-# RULES
"addAttributes'/mempty" forall s. addAttributes' s mempty = pure ()
"addAttributes/empty"   forall s. OpenTelemetry.Trace.Core.addAttributes s H.empty = pure ()
  #-}


{- | Add an event to a recording span. Events will not be recorded for remote spans and dropped spans.

 @since 0.0.1.0
-}
addEvent :: (MonadIO m) => Span -> NewEvent -> m ()
addEvent (Span imm) NewEvent {..} = liftIO $ do
  t <- maybe getTimestampIO pure newEventTimestamp
  casModifyIORef_ (spanHot imm) $ \(!h) ->
    if isEnded (hotEnd h)
      then h
      else
        h
          { hotEvents =
              appendToBoundedCollection (hotEvents h) $
                Event
                  { eventName = newEventName
                  , eventAttributes =
                      A.addAttributes
                        (tracerEventAttributeLimits $ spanTracer imm)
                        emptyAttributes
                        newEventAttributes
                  , eventTimestamp = t
                  }
          }
addEvent (FrozenSpan _) _ = pure ()
addEvent (Dropped _) _ = pure ()
{-# INLINABLE addEvent #-}
{-# SPECIALIZE addEvent :: Span -> NewEvent -> IO () #-}


{- | Construct a 'NewEvent' with just a name (no attributes, current timestamp).

@
addEvent span (newEvent "cache-miss")
@

@since 0.4.1.0
-}
newEvent :: Text -> NewEvent
newEvent name = NewEvent {newEventName = name, newEventAttributes = H.empty, newEventTimestamp = Nothing}
{-# INLINE newEvent #-}


{- | Construct a 'NewEvent' with a name and attributes (current timestamp).

@
addEvent span (newEventWith "retry" [("attempt", toAttribute retryCount)])
@

@since 0.4.1.0
-}
newEventWith :: Text -> AttributeMap -> NewEvent
newEventWith name attrs = NewEvent {newEventName = name, newEventAttributes = attrs, newEventTimestamp = Nothing}
{-# INLINE newEventWith #-}


-- | Add a link to a recording span.
addLink :: (MonadIO m) => Span -> NewLink -> m ()
addLink (Span imm) l = liftIO $
  casModifyIORef_ (spanHot imm) $ \(!h) ->
    if isEnded (hotEnd h)
      then h
      else h {hotLinks = appendToBoundedCollection (hotLinks h) (freezeLink (spanTracer imm) l)}
addLink (FrozenSpan _) _ = pure ()
addLink (Dropped _) _ = pure ()
{-# INLINABLE addLink #-}
{-# SPECIALIZE addLink :: Span -> NewLink -> IO () #-}


freezeLink :: Tracer -> NewLink -> Link
freezeLink t NewLink {..} =
  Link
    { frozenLinkContext = linkContext
    , frozenLinkAttributes = A.addAttributes (tracerLinkAttributeLimits t) A.emptyAttributes linkAttributes
    }


{- | Sets the Status of the Span. If used, this will override the default @Span@ status, which is @Unset@.

 These values form a total order: Ok > Error > Unset. This means that setting Status with StatusCode=Ok will override any prior or future attempts to set span Status with StatusCode=Error or StatusCode=Unset.

 @since 0.0.1.0
-}
setStatus :: (MonadIO m) => Span -> SpanStatus -> m ()
setStatus (Span imm) st = liftIO $ casModifyIORef_ (spanHot imm) $ \(!h) ->
  if isEnded (hotEnd h)
    then h
    else h {hotStatus = mergeStatus st (hotStatus h)}
setStatus (FrozenSpan _) _ = pure ()
setStatus (Dropped _) _ = pure ()
{-# INLINABLE setStatus #-}
{-# SPECIALIZE setStatus :: Span -> SpanStatus -> IO () #-}


{- | Merge a new status into the existing status per the OTel spec:

1. Ok is final — once set, it cannot be changed
2. Setting Unset is always ignored
3. Otherwise the new status wins (last writer wins)
-}
mergeStatus :: SpanStatus -> SpanStatus -> SpanStatus
mergeStatus _ Ok = Ok
mergeStatus Unset old = old
mergeStatus new _ = new


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
updateName (Span imm) n = liftIO $ casModifyIORef_ (spanHot imm) $ \(!h) ->
  if isEnded (hotEnd h)
    then h
    else h {hotName = n}
updateName (FrozenSpan _) _ = pure ()
updateName (Dropped _) _ = pure ()
{-# INLINABLE updateName #-}
{-# SPECIALIZE updateName :: Span -> Text -> IO () #-}


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
endSpan (Span imm) mts = liftIO $ do
  ts <- maybe getTimestampIO pure mts
  let !optTs = timestampToOptional ts
  old <- casReadModifyIORef_ (spanHot imm) $ \(!h) ->
    case hotEnd h of
      SomeTimestamp _ -> h
      NoTimestamp -> h {hotEnd = optTs}
  case hotEnd old of
    SomeTimestamp _ -> pure ()
    NoTimestamp ->
      let !procs = tracerProviderProcessors $ tracerProvider $ spanTracer imm
      in V.mapM_ (\p -> spanProcessorOnEnd p imm) procs
          `catch` \(_ :: SomeException) -> pure ()
endSpan (FrozenSpan _) _ = pure ()
endSpan (Dropped _) _ = pure ()
{-# INLINABLE endSpan #-}
{-# SPECIALIZE endSpan :: Span -> Maybe Timestamp -> IO () #-}


{- | A specialized variant of @addEvent@ that records attributes conforming to
 the OpenTelemetry specification's
 <https://github.com/open-telemetry/opentelemetry-specification/blob/49c2f56f3c0468ceb2b69518bcadadd96e0a5a8b/specification/trace/semantic_conventions/exceptions.md semantic conventions>

 @since 0.0.1.0
-}
recordException :: (MonadIO m, Exception e) => Span -> AttributeMap -> Maybe Timestamp -> e -> m ()
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
{-# INLINABLE recordException #-}
{-# SPECIALIZE recordException :: (Exception e) => Span -> AttributeMap -> Maybe Timestamp -> e -> IO () #-}


{- | Record an error and set the span status in one call.

Combines 'setStatus' with 'Error' and 'recordException'. This is a common
pattern when handling errors outside of 'inSpan' (which does this
automatically for uncaught exceptions).

@
case result of
  Left err -> recordError span err
  Right _  -> setStatus span Ok
@

@since 0.4.1.0
-}
recordError :: (MonadIO m, Exception e) => Span -> e -> m ()
recordError s e = do
  setStatus s $ Error $ T.pack $ displayException e
  recordException s H.empty Nothing e
{-# INLINE recordError #-}


{- | Returns @True@ if the @SpanContext@ has a non-zero @TraceID@ and a non-zero @SpanID@.
Spec: "true if the SpanContext has a non-zero TraceID and a non-zero SpanID".
-}
isValid :: SpanContext -> Bool
isValid sc =
  not (isEmptyTraceId (traceId sc)) && not (isEmptySpanId (spanId sc))


{- |
Returns @True@ if the @SpanContext@ was propagated from a remote parent,

When extracting a SpanContext through the Propagators API, isRemote MUST return @True@,
whereas for the SpanContext of any child spans it MUST return @False@.
-}
spanIsRemote :: (MonadIO m) => Span -> m Bool
spanIsRemote (Span imm) = pure $ Types.isRemote $ Types.spanContext imm
spanIsRemote (FrozenSpan c) = pure $ Types.isRemote c
spanIsRemote (Dropped _) = pure False


{- | Really only intended for tests, this function does not conform
 to semantic versioning .
-}
unsafeReadSpan :: (MonadIO m) => Span -> m ImmutableSpan
unsafeReadSpan s =
  toImmutableSpan s >>= \case
    Right span -> pure span
    Left frozenOrDropped -> case frozenOrDropped of
      SpanFrozen -> error "This span is from another process"
      SpanDropped -> error "This span was dropped"


wrapSpanContext :: SpanContext -> Span
wrapSpanContext = FrozenSpan


{- | Construct a non-recording parent span representing a dropped (not sampled) trace,
e.g. for tests or when continuing a trace whose parent was not recorded.

@since 0.4.0.0
-}
wrapDroppedContext :: SpanContext -> Span
wrapDroppedContext = Dropped


{- | This can be useful for pulling data for attributes and
 using it to copy / otherwise use the data to further enrich
 instrumentation.
-}
spanGetAttributes :: (MonadIO m) => Span -> m A.Attributes
spanGetAttributes = \case
  Span imm -> liftIO $ hotAttributes <$> readIORef (spanHot imm)
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
getTimestamp = liftIO getTimestampIO
{-# INLINE getTimestamp #-}


foreign import ccall unsafe "hs_otel_gettime_ns"
  getTimestampIO :: IO Timestamp


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
  , tracerProviderOptionsPropagators :: TextMapPropagator
  , tracerProviderOptionsExceptionHandlers :: [ExceptionHandler]
  -- ^ Exception handlers consulted (after any tracer-level handlers) when
  -- 'inSpan' catches an exception. Defaults to @[]@ (all exceptions are errors).
  --
  -- @since 0.4.0.0
  }


{- | Options for creating a 'TracerProvider' with invalid ids, no resources, default limits, and no propagators.

 In effect, tracing is a no-op when using this configuration.

 @since 0.0.1.0
-}
emptyTracerProviderOptions :: TracerProviderOptions
emptyTracerProviderOptions =
  TracerProviderOptions
    { tracerProviderOptionsIdGenerator = dummyIdGenerator
    , tracerProviderOptionsSampler = parentBased $ parentBasedOptions alwaysOn
    , tracerProviderOptionsResources = emptyMaterializedResources
    , tracerProviderOptionsAttributeLimits = defaultAttributeLimits
    , tracerProviderOptionsSpanLimits = defaultSpanLimits
    , tracerProviderOptionsPropagators = mempty
    , tracerProviderOptionsExceptionHandlers = []
    }


{- | Initialize a new tracer provider

 You should generally use 'getGlobalTracerProvider' for most applications.
-}
createTracerProvider :: (MonadIO m) => [SpanProcessor] -> TracerProviderOptions -> m TracerProvider
createTracerProvider ps opts = liftIO $ do
  let g = tracerProviderOptionsIdGenerator opts
  shutRef <- newIORef False
  pure $
    TracerProvider
      { tracerProviderProcessors = V.fromList ps
      , tracerProviderIdGenerator = g
      , tracerProviderSampler = tracerProviderOptionsSampler opts
      , tracerProviderResources = tracerProviderOptionsResources opts
      , tracerProviderAttributeLimits = tracerProviderOptionsAttributeLimits opts
      , tracerProviderSpanLimits = tracerProviderOptionsSpanLimits opts
      , tracerProviderPropagators = tracerProviderOptionsPropagators opts
      , tracerProviderExceptionHandlers = tracerProviderOptionsExceptionHandlers opts
      , tracerProviderIsShutdown = shutRef
      }


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
setGlobalTracerProvider = liftIO . atomicWriteIORef globalTracer


getTracerProviderResources :: TracerProvider -> MaterializedResources
getTracerProviderResources = tracerProviderResources


getTracerProviderPropagators :: TracerProvider -> TextMapPropagator
getTracerProviderPropagators = tracerProviderPropagators


-- | Tracer configuration options.
data TracerOptions = TracerOptions
  { tracerSchema :: Maybe Text
  -- ^ OpenTelemetry provides a schema for describing common attributes so that backends can easily parse and identify relevant information.
  -- It is important to understand these conventions when writing instrumentation, in order to normalize your data and increase its utility.
  --
  -- In particular, this option is valuable to set when possible, because it allows vendors to normalize data accross releases in order to account
  -- for attribute name changes.
  , tracerExceptionHandlerOptions :: [ExceptionHandler]
  -- ^ Exception handlers specific to this tracer, consulted before
  -- provider-level handlers. Defaults to @[]@.
  --
  -- @since 0.4.0.0
  }


-- | Default Tracer options
tracerOptions :: TracerOptions
tracerOptions = TracerOptions Nothing []


{- | A small utility lens for extracting a 'Tracer' from a larger data type

 This will generally be most useful as a means of implementing 'OpenTelemetry.Trace.Monad.getTracer'

 @since 0.0.1.0
-}
class HasTracer s where
  tracerL :: Lens' s Tracer


makeTracer :: TracerProvider -> InstrumentationLibrary -> TracerOptions -> Tracer
makeTracer tp n opts =
  let n' = case tracerSchema opts of
        Nothing -> n
        Just s -> n {librarySchemaUrl = s}
      resolveLimits countF =
        AttributeLimits
          { attributeCountLimit =
              countF (tracerProviderSpanLimits tp)
                <|> attributeCountLimit (tracerProviderAttributeLimits tp)
          , attributeLengthLimit =
              spanAttributeValueLengthLimit (tracerProviderSpanLimits tp)
                <|> attributeLengthLimit (tracerProviderAttributeLimits tp)
          }
  in Tracer
      { tracerName = n'
      , tracerProvider = tp
      , tracerExceptionHandlers = tracerExceptionHandlerOptions opts
      , tracerSpanAttributeLimits = resolveLimits spanAttributeCountLimit
      , tracerEventAttributeLimits = resolveLimits eventAttributeCountLimit
      , tracerLinkAttributeLimits = resolveLimits linkAttributeCountLimit
      }


getTracer :: (MonadIO m) => TracerProvider -> InstrumentationLibrary -> TracerOptions -> m Tracer
getTracer tp n opts = liftIO $ do
  pure $ makeTracer tp n opts
{-# DEPRECATED getTracer "use makeTracer" #-}


getImmutableSpanTracer :: ImmutableSpan -> Tracer
getImmutableSpanTracer = spanTracer


getTracerTracerProvider :: Tracer -> TracerProvider
getTracerTracerProvider = tracerProvider


{- | Check if the 'Tracer' is enabled.

 This function helps users avoid performing computationally expensive operations
 when creating 'Span's if the tracer is not enabled.

 A 'Tracer' is considered enabled if it has at least one configured processor.
 If the 'TracerProvider' has no processors, all spans will be dropped, so the
 tracer is disabled.

 @since 0.3.1.0
-}
tracerIsEnabled :: Tracer -> Bool
tracerIsEnabled t = not $ V.null $ tracerProviderProcessors $ tracerProvider t


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
  atomicWriteIORef tracerProviderIsShutdown True
  asyncShutdownResults <- V.mapM (spanProcessorShutdown) tracerProviderProcessors
  V.mapM_ waitCatch asyncShutdownResults


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
  jobs <- V.forM tracerProviderProcessors $ \processor -> async $ do
    spanProcessorForceFlush processor
  mresult <-
    timeout (fromMaybe 5_000_000 mtimeout) $
      V.foldM'
        ( \status action -> do
            res <- waitCatch action
            pure $! case res of
              Left _err -> FlushError
              Right _ok -> status
        )
        FlushSuccess
        jobs
  case mresult of
    Nothing -> do
      V.mapM_ cancel jobs
      pure FlushTimeout
    Just res -> pure res


{- | Utility function to only perform costly attribute annotations
 for spans that are actually
-}
whenSpanIsRecording :: (MonadIO m) => Span -> m () -> m ()
whenSpanIsRecording (Span imm) m = do
  hot <- liftIO $ readIORef (spanHot imm)
  case hotEnd hot of
    NoTimestamp -> m
    _ -> pure ()
whenSpanIsRecording (FrozenSpan _) _ = pure ()
whenSpanIsRecording (Dropped _) _ = pure ()


{- | Retrieve the active 'Span' from the current thread's context.

Returns 'Nothing' if there is no span in the current context (e.g. at
the top level, before any tracing has started).

This is the Haskell equivalent of Go's @trace.SpanFromContext(ctx)@ and
Rust's @get_active_span@.

@since 0.4.1.0
-}
getActiveSpan :: (MonadIO m) => m (Maybe Span)
getActiveSpan = lookupSpan <$> getContext
{-# INLINE getActiveSpan #-}


{- | Run an action on the active span. If there is no active span in the
current context, the action is silently skipped.

@
withActiveSpan $ \\span -> do
  addAttribute span "user.id" (toAttribute userId)
  addEvent span (newEvent "cache-miss")
@

@since 0.4.1.0
-}
withActiveSpan :: (MonadIO m) => (Span -> m ()) -> m ()
withActiveSpan f = do
  mSpan <- getActiveSpan
  forM_ mSpan f
{-# INLINE withActiveSpan #-}


{- | Retrieve the 'SpanContext' of the active span, useful for log
correlation (extracting trace\/span IDs) without needing the full 'Span'
handle.

@since 0.4.1.0
-}
getActiveSpanContext :: (MonadIO m) => m (Maybe SpanContext)
getActiveSpanContext = do
  mSpan <- getActiveSpan
  case mSpan of
    Nothing -> pure Nothing
    Just s -> Just <$> getSpanContext s
{-# INLINE getActiveSpanContext #-}


timestampNanoseconds :: Timestamp -> Word64
timestampNanoseconds = coerce
{-# INLINE timestampNanoseconds #-}
