{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE CPP #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE OverloadedLists #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}

{- |
Module      :  OpenTelemetry.Trace.Core
Copyright   :  (c) Ian Duncan, 2021-2026
License     :  BSD-3
Description :  Low-level tracing API
Maintainer  :  Ian Duncan
Stability   :  experimental
Portability :  non-portable (GHC extensions)

= Overview

This module provides the core tracing API for creating and managing spans.
Most application code should use "OpenTelemetry.Trace" (from the SDK package)
for initialization and "OpenTelemetry.Trace.Monad" for a cleaner monadic
interface. This module is useful when you need direct control or are writing
instrumentation libraries.

= Quick example

> import OpenTelemetry.Trace.Core
>
> -- Wrap any IO action in a span:
> handleRequest :: Tracer -> Request -> IO Response
> handleRequest tracer req =
>   inSpan tracer "handleRequest" defaultSpanArguments $ do
>     result <- processRequest req
>     pure result
>
> -- Access the span to add attributes:
> fetchUser :: Tracer -> UserId -> IO User
> fetchUser tracer uid =
>   inSpan' tracer "fetchUser" defaultSpanArguments $ \span -> do
>     addAttribute span "user.id" (toAttribute uid)
>     user <- db_lookupUser uid
>     addAttribute span "user.name" (toAttribute (userName user))
>     pure user

= Key concepts

[@TracerProvider@] Factory that holds configuration (processors, exporters,
samplers) and creates 'Tracer's. Typically one per application, created at
startup.

[@Tracer@] Obtained from a 'TracerProvider', scoped to an instrumentation
library or application component. Carries the library name and version for
attribution.

[@Span@] Represents a unit of work. Has a name, start\/end timestamps,
attributes, events, links, and status. Created by 'OpenTelemetry.Trace.Core.inSpan'
or 'createSpan'.

= Creating spans

The @inSpan@ family of functions is the primary API:

* @inSpan@: wraps an @IO a@ action (or any 'MonadUnliftIO' action),
  automatically ending the span and recording exceptions. Captures source
  location from the call site.
* @inSpan@′: like @inSpan@, but passes the 'Span' to the callback so you can
  add attributes or events during execution. (In Haskell source the name ends
  with one ASCII prime character.)
* @inSpan@′′: raw variant with no automatic @code.*@ attributes from the call
  site. Preferred for instrumentation libraries where those attributes would
  describe library internals rather than user code. (In Haskell source the
  name ends with two ASCII prime characters.)

For manual span lifecycle management, use 'createSpan' and 'endSpan'.

= Adding metadata

> inSpan' tracer "processOrder" defaultSpanArguments $ \span -> do
>   addAttribute span "order.id" (toAttribute orderId)
>   addAttributes span
>     [ ("order.total", toAttribute total)
>     , ("order.currency", toAttribute "USD")
>     ]
>   addEvent span (newEvent "order.validated")
>   setStatus span Ok

= Error handling

@inSpan@ and @inSpan@′ automatically catch exceptions, record them on the span (as an exception
event with stack trace), set the span status to Error, and re-throw. You
can also manually set error status:

> setStatus span (Error "payment declined")
> recordException span mempty Nothing myException

= Source location

@inSpan@, @inSpan@′, and 'createSpan' automatically add source location
attributes from GHC's 'HasCallStack'. The attribute names depend on the
@OTEL_SEMCONV_STABILITY_OPT_IN@ setting:

* Default (@Old@): @code.function@, @code.namespace@, @code.filepath@, @code.lineno@
* @code@: @code.function.name@, @code.file.path@, @code.line.number@ (stable semconv v1.33+)
* @code\/dup@: both old and stable names emitted

If you provide any @code.*@ attribute yourself in
'SpanArguments', the automatic attributes are suppressed.

= Spec reference

<https://opentelemetry.io/docs/specs/otel/trace/api/>
-}
module OpenTelemetry.Trace.Core (
  -- * @TracerProvider@ operations
  TracerProvider,
  createTracerProvider,
  shutdownTracerProvider,
  ShutdownResult (..),
  worstShutdown,
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
  isRandom,
  setRandom,
  unsetRandom,

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
  codeAttributes,
  ownCodeAttributes,
  callerAttributes,
  addAttributesToSpanArguments,

  -- * Limits
  SpanLimits (..),
  defaultSpanLimits,
  bracketError,
) where

import Control.Applicative
import Control.Concurrent.Async
import Control.Concurrent.Thread.Storage (getCurrentThreadId)
import Control.Exception (Exception (..), SomeException (..), catch, displayException)
import qualified Control.Exception as EUnsafe
import Control.Monad
import Control.Monad.IO.Class
import Control.Monad.IO.Unlift
import Data.Coerce
import qualified Data.HashMap.Strict as H
import Data.IORef (IORef, atomicModifyIORef', atomicWriteIORef, newIORef, readIORef, writeIORef)


#if !MIN_VERSION_base(4,20,0)
import Data.List (foldl')
#endif
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
import OpenTelemetry.Internal.Log.Core (emitOTelLogRecord)
import qualified OpenTelemetry.Internal.Log.Types as SeverityNumber (SeverityNumber (..))
import OpenTelemetry.Internal.Logging (otelLogWarning)
import OpenTelemetry.Internal.Trace.Types
import qualified OpenTelemetry.Internal.Trace.Types as Types
import OpenTelemetry.Propagator (TextMapPropagator)
import OpenTelemetry.Resource
import qualified OpenTelemetry.SemanticConventions as SC
import OpenTelemetry.SemanticsConfig (StabilityOpt (..), codeOption, getSemanticsOptions)
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


{- | The same thing as 'createSpan', except that it does not have a 'HasCallStack' constraint.

@since 0.0.1.0
-}
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
  !tidInt <- getCurrentThreadId
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
  when (T.null n) $
    otelLogWarning "Span created with empty name"
  let !tp = tracerProvider t
  isShutdown <- readIORef $ tracerProviderIsShutdown tp
  if isShutdown || not (tracerProviderHasProcessor tp)
    then do
      let parent = lookupSpan ctxt
          parentSc = case parent of
            Nothing -> Nothing
            Just (Span imm) -> Just (Types.spanContext imm)
            Just (FrozenSpan s') -> Just s'
            Just (Dropped s') -> Just s'
          (!tId, !parentTs) = case parentSc of
            Nothing -> (nilTraceId, TraceState.empty)
            Just sc -> (traceId sc, traceState sc)
      pure $! Dropped $! SpanContext defaultTraceFlags False tId nilSpanId parentTs
    else do
      let parent = lookupSpan ctxt
          parentSc = case parent of
            Nothing -> Nothing
            Just (Span imm) -> Just (Types.spanContext imm)
            Just (FrozenSpan s) -> Just s
            Just (Dropped s) -> Just s

      -- Dropped parent: propagate trace context, skip all ID generation
      case parent of
        Just (Dropped _) -> do
          let !ts = maybe TraceState.empty traceState parentSc
              !tId = maybe nilTraceId traceId parentSc
          pure $! Dropped $! SpanContext defaultTraceFlags False tId nilSpanId ts
        _ -> do
          let !idGen = tracerProviderIdGenerator tp

          -- Root spans: generate TraceId + SpanId in one FFI call (3 xoshiro
          -- steps) instead of 3 separate calls. The SpanId bytes are drawn
          -- before sampling but used after — the spec requires the ID to be
          -- fresh regardless of sampling outcome, which this satisfies.
          -- Child spans: inherit TraceId, generate only SpanId (1 call).
          (!tId, !preSpanId) <- case parentSc of
            Nothing -> newTraceAndSpanId idGen
            Just sc -> do
              !sid <- newSpanId idGen
              pure (traceId sc, sid)

          let !baseFlags = case parentSc of
                Nothing -> case idGen of
                  DefaultIdGenerator -> setRandom defaultTraceFlags
                  _ -> defaultTraceFlags
                Just sc
                  | isRandom (Types.traceFlags sc) -> setRandom defaultTraceFlags
                  | otherwise -> defaultTraceFlags

          -- Spec: shouldSample receives the InstrumentationScope of the Tracer.
          -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#shouldsample
          SamplingDecision {..} <-
            shouldSample
              (tracerProviderSampler tp)
              ctxt
              tId
              n
              args
              (tracerName t)

          let !sId = preSpanId

          case samplingOutcome of
            Drop ->
              pure $! Dropped $! SpanContext baseFlags False tId sId samplingTraceState
            _ -> do
              let !ctxtForSpan =
                    SpanContext
                      { traceFlags = case samplingOutcome of
                          Drop -> baseFlags
                          RecordOnly -> baseFlags
                          RecordAndSample -> setSampled baseFlags
                      , isRemote = False
                      , traceState = samplingTraceState
                      , spanId = sId
                      , traceId = tId
                      }
              st <- maybe getTimestampIO pure startTime
              let !attrLimits = tracerSpanAttributeLimits t
                  !tidVal = toAttribute tidInt
                  !allAttrs =
                    H.insert (unkey SC.thread_id) tidVal $!
                      case (H.null samplingAttributes, H.null extraAttrs) of
                        (True, True) -> attributes
                        (True, False) -> H.union attributes extraAttrs
                        (False, True) -> H.union samplingAttributes attributes
                        (False, False) -> H.union samplingAttributes (H.union attributes extraAttrs)
                  !initialAttrs = A.unsafeAttributesFromMap attrLimits allAttrs
                  !initialLinks =
                    foldl' (\c l -> appendToBoundedCollection c (freezeLink t l)) emptyLinks links
                  emptyLinks = emptyAppendOnlyBoundedCollection (tracerLinkCountLimit t)
                  emptyEvts = emptyAppendOnlyBoundedCollection (tracerEventCountLimit t)

              hotRef <-
                newIORef $!
                  SpanHot
                    { hotName = n
                    , hotEnd = NoTimestamp
                    , hotAttributes = initialAttrs
                    , hotLinks = initialLinks
                    , hotEvents = emptyEvts
                    , hotStatus = Unset
                    }
              let !imm =
                    ImmutableSpan
                      { spanContext = ctxtForSpan
                      , spanKind = kind
                      , spanStart = st
                      , spanParent = parent
                      , spanTracer = t
                      , spanHot = hotRef
                      }
              tracerProviderOnStart tp imm ctxt
                `catch` \(err :: SomeException) -> do
                  otelLogWarning $ "Span processor onStart failed: " <> show err
                  void $ emitOTelLogRecord H.empty SeverityNumber.Error $ T.pack $ show err
              pure $! Span imm


{- |
Creates source code attributes describing the caller of the current function. You should use this if you are getting
source code attributes from inside a function that is creating a span.

Respects @OTEL_SEMCONV_STABILITY_OPT_IN=code@ to select stable vs legacy attribute names.

Note: this will return nothing if the call stack is frozen.
-}
ownCodeAttributes :: (HasCallStack) => AttributeMap
ownCodeAttributes =
  let opt = codeOption $ unsafePerformIO getSemanticsOptions
  in case getCallStack callStack of
      (("ownCodeAttributes", ownCodeCalledAt) : (ownFunction, _ownFunctionCalledAt) : _) ->
        codeAttributes opt ownFunction ownCodeCalledAt
      (("ownCodeAttributes", ownCodeCalledAt) : _) ->
        codeAttributes opt "<unknown>" ownCodeCalledAt
      _ -> mempty


{- |
Creates source code attributes describing where the current function is called. You should use this if
you are getting source code attributes from inside a "span creation" function.

Respects @OTEL_SEMCONV_STABILITY_OPT_IN=code@ to select stable vs legacy attribute names.

Note: this will return nothing if the call stack is frozen.
-}
callerAttributes :: (HasCallStack) => AttributeMap
callerAttributes =
  let opt = codeOption $ unsafePerformIO getSemanticsOptions
  in case getCallStack callStack of
      (("callerAttributes", _callerAttributesCalledAt) : (_ownFunction, ownFunctionCalledAt) : (callerFunction, _) : _) ->
        codeAttributes opt callerFunction ownFunctionCalledAt
      (("callerAttributes", _callerAttributesCalledAt) : (_ownFunction, ownFunctionCalledAt) : _) ->
        codeAttributes opt "<unknown>" ownFunctionCalledAt
      _ -> mempty


codeAttributes :: StabilityOpt -> String -> SrcLoc -> AttributeMap
codeAttributes opt fn loc = case opt of
  Stable -> stableAttrs
  StableAndOld -> H.union stableAttrs oldAttrs
  Old -> oldAttrs
  where
    modName = srcLocModule loc
    qualifiedName = T.pack $ modName <> "." <> fn
    stableAttrs =
      H.insert (unkey SC.code_function_name) (toAttribute qualifiedName) $!
        H.insert (unkey SC.code_file_path) (toAttribute $ T.pack $ srcLocFile loc) $!
          H.singleton (unkey SC.code_line_number) (toAttribute $ srcLocStartLine loc)
    oldAttrs =
      H.insert (unkey SC.code_function) (toAttribute $ T.pack fn) $!
        H.insert (unkey SC.code_namespace) (toAttribute $ T.pack modName) $!
          H.insert (unkey SC.code_filepath) (toAttribute $ T.pack $ srcLocFile loc) $!
            H.singleton (unkey SC.code_lineno) (toAttribute $ srcLocStartLine loc)
{-# INLINE codeAttributes #-}


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
  H.member (unkey SC.code_function) m
    || H.member (unkey SC.code_namespace) m
    || H.member (unkey SC.code_filepath) m
    || H.member (unkey SC.code_function_name) m
    || H.member (unkey SC.code_file_path) m
{-# INLINE hasCodeAttributes #-}


{- | Extract caller source location from a 'CallStack' and build attributes.
Takes the 'CallStack' directly so the thunk captures only the implicit
parameter, deferring all 'T.pack' / 'H.insert' work until forced.

The call stack from @inSpan@ (HasCallStack) looks like:
  (\"inSpan\", call_site) : (caller_of_inSpan, ...) : ...
We want the call_site (where inSpan was called) and the caller function name.
-}
callerCodeAttrs :: StabilityOpt -> CallStack -> AttributeMap
callerCodeAttrs opt cs = case getCallStack cs of
  ((_inSpanFn, callSite) : (callerFn, _) : _) ->
    codeAttributes opt callerFn callSite
  ((_inSpanFn, callSite) : _) ->
    codeAttributes opt "<unknown>" callSite
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
  let opt = codeOption $ unsafePerformIO getSemanticsOptions
      codeAttrs = if hasCodeAttributes (attributes args) then H.empty else callerCodeAttrs opt callStack
  in inSpanInternal t n args codeAttrs (const m)
{-# INLINE inSpan #-}


{- | Like 'inSpan', but passes the created 'Span' to the action.

 @since 0.0.1.0
-}
inSpan'
  :: (MonadUnliftIO m, HasCallStack)
  => Tracer
  -> Text
  -- ^ The name of the span. This may be updated later via 'updateName'
  -> SpanArguments
  -> (Span -> m a)
  -> m a
inSpan' t n args =
  let opt = codeOption $ unsafePerformIO getSemanticsOptions
      codeAttrs = if hasCodeAttributes (attributes args) then H.empty else callerCodeAttrs opt callStack
  in inSpanInternal t n args codeAttrs
{-# INLINE inSpan' #-}


{- | Like @inSpan@′ (the Haskell name has one ASCII prime), but does not add
 automatic caller source location attributes.

 @since 0.4.0.0
-}
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
  | not (tracerProviderHasProcessor (tracerProvider t)) =
      -- Fast path: no processors means every span is Dropped. Skip mask,
      -- context modification, and exception recording entirely. We still
      -- propagate trace ID via a lightweight Dropped span for context
      -- continuity in case a child uses a different (active) tracer.
      liftIO (getContext >>= \ctx -> createSpanHelper t ctx n args extraAttrs (-1)) >>= f
  | otherwise = withRunInIO $ \run -> EUnsafe.mask $ \restore -> do
      -- Fused CMM fast path: reads CurrentTSO.id + probes flat table
      -- in a single CMM call. No ThreadId allocation, no FFI, no Maybe.
      -- On steady state this is one CMM call + one readArray#.
      (!tidInt, ctxRef) <- ensureContextRefFast
      entry <- readIORef ctxRef
      let ctx = ceContext entry
      s <- createSpanHelper t ctx n args extraAttrs tidInt
      writeIORef ctxRef $! entry {ceContext = insertSpan s ctx}
      -- User code (unmasked via restore)
      a <-
        restore (run $ f s) `EUnsafe.catch` \someEx@(SomeException inner) -> do
          let ExceptionResponse classification exAttrs = resolveException t someEx
          case classification of
            ErrorException -> do
              setStatus s $ Error $ T.pack $ displayException inner
              recordException s (H.union [(unkey SC.exception_escaped, toAttribute True)] exAttrs) Nothing inner
            RecordedException ->
              recordException s (H.union [(unkey SC.exception_escaped, toAttribute True)] exAttrs) Nothing inner
            IgnoredException ->
              pure ()
          endSpan s Nothing
          writeIORef ctxRef entry
          EUnsafe.throwIO someEx
      -- Success cleanup (runs masked; non-blocking, no uninterruptibleMask_ needed)
      endSpan s Nothing
      writeIORef ctxRef entry
      pure a
{-# INLINEABLE inSpanInternal #-}
{-# SPECIALIZE inSpanInternal :: Tracer -> Text -> SpanArguments -> AttributeMap -> (Span -> IO a) -> IO a #-}


{- | Returns whether the @Span@ is currently recording.

A live 'Span' created by this process returns 'True' until 'endSpan' is
called.  A 'FrozenSpan' (non-recording context-only wrapper, e.g. from
'wrapSpanContext') and a 'Dropped' span always return 'False'.

 @since 0.0.1.0
-}
isRecording :: (MonadIO m) => Span -> m Bool
isRecording (Span imm) = liftIO (not . isEnded . hotEnd <$> readIORef (spanHot imm))
isRecording (FrozenSpan _) = pure False
isRecording (Dropped _) = pure False
{-# INLINE isRecording #-}


{- | Add an attribute to a span. Only affects recording spans.

See the [OTel attribute naming conventions](https://opentelemetry.io/docs/specs/otel/common/attribute-naming/)
for guidance on choosing attribute names.

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
{-# INLINEABLE addAttribute #-}


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
{-# INLINEABLE addAttributes #-}


{-# SPECIALIZE OpenTelemetry.Trace.Core.addAttributes :: Span -> H.HashMap Text A.Attribute -> IO () #-}


{- | Like 'addAttributes', but takes an 'A.AttrsBuilder' instead of a 'HashMap'.
More efficient when setting many attributes at once.

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
{-# INLINEABLE addAttributes' #-}
{-# SPECIALIZE addAttributes' :: Span -> A.AttrsBuilder -> IO () #-}


-- Skip the CAS entirely when there's nothing to add.
{-# RULES
"addAttributes'/mempty" forall s. addAttributes' s mempty = pure ()
"addAttributes/empty" forall s. OpenTelemetry.Trace.Core.addAttributes s H.empty = pure ()
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
{-# INLINEABLE addEvent #-}
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


{- | Add a link to a recording span.

@since 0.0.1.0
-}
addLink :: (MonadIO m) => Span -> NewLink -> m ()
addLink (Span imm) l = liftIO $
  casModifyIORef_ (spanHot imm) $ \(!h) ->
    if isEnded (hotEnd h)
      then h
      else h {hotLinks = appendToBoundedCollection (hotLinks h) (freezeLink (spanTracer imm) l)}
addLink (FrozenSpan _) _ = pure ()
addLink (Dropped _) _ = pure ()
{-# INLINEABLE addLink #-}
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
{-# INLINEABLE setStatus #-}
{-# SPECIALIZE setStatus :: Span -> SpanStatus -> IO () #-}


{- | Merge a new status into the existing status per the OTel spec.

The spec defines a total order: @Ok > Error > Unset@. Setting @Ok@
overrides any prior status. Setting @Error@ overrides @Unset@ but not
@Ok@. Setting @Unset@ is always a no-op.

@since 0.0.1.0
-}
mergeStatus :: SpanStatus -> SpanStatus -> SpanStatus
mergeStatus _ Ok = Ok
mergeStatus Ok _ = Ok
mergeStatus new Unset = new
mergeStatus _new current = current


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
{-# INLINEABLE updateName #-}
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
    NoTimestamp -> do
      let !spanName = hotName old
          !droppedAttributeCount =
            A.getDropped (hotAttributes old)
              + V.foldl' (\acc e -> acc + A.getDropped (eventAttributes e)) 0 (appendOnlyBoundedCollectionValues (hotEvents old))
              + V.foldl' (\acc l -> acc + A.getDropped (frozenLinkAttributes l)) 0 (appendOnlyBoundedCollectionValues (hotLinks old))
          !droppedEventsCount = appendOnlyBoundedCollectionDroppedElementCount (hotEvents old)
          !droppedLinksCount = appendOnlyBoundedCollectionDroppedElementCount (hotLinks old)
      when (droppedAttributeCount > 0 || droppedEventsCount > 0 || droppedLinksCount > 0) $
        otelLogWarning $
          "Span '"
            <> T.unpack spanName
            <> "' dropped data due to limits: "
            <> show droppedAttributeCount
            <> " attribute(s), "
            <> show droppedEventsCount
            <> " event(s), "
            <> show droppedLinksCount
            <> " link(s)"
      tracerProviderOnEnd (tracerProvider (spanTracer imm)) imm
        `catch` \(ex :: SomeException) -> otelLogWarning ("Span processor onEnd failed: " <> show ex)
endSpan (FrozenSpan _) _ = pure ()
endSpan (Dropped _) _ = pure ()
{-# INLINEABLE endSpan #-}
{-# SPECIALIZE endSpan :: Span -> Maybe Timestamp -> IO () #-}


{- | A specialized variant of @addEvent@ that records attributes conforming to
 the OpenTelemetry specification's
 <https://github.com/open-telemetry/opentelemetry-specification/blob/49c2f56f3c0468ceb2b69518bcadadd96e0a5a8b/specification/trace/semantic_conventions/exceptions.md semantic conventions>

 @since 0.0.1.0
-}
recordException :: (MonadIO m, Exception e) => Span -> AttributeMap -> Maybe Timestamp -> e -> m ()
recordException s attrs ts e = liftIO $ do
  cs <- whoCreated e
  let message = T.pack $ displayException e
  addEvent s $
    NewEvent
      { newEventName = "exception"
      , newEventAttributes =
          H.union
            attrs
            [ (unkey SC.exception_type, A.toAttribute $ T.pack $ show $ typeOf e)
            , (unkey SC.exception_message, A.toAttribute message)
            , (unkey SC.exception_stacktrace, A.toAttribute $ T.unlines $ map T.pack cs)
            ]
      , newEventTimestamp = ts
      }
{-# INLINEABLE recordException #-}
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

 @since 0.0.1.0
-}
isValid :: SpanContext -> Bool
isValid sc =
  not (isEmptyTraceId (traceId sc)) && not (isEmptySpanId (spanId sc))


{- |
Returns @True@ if the @SpanContext@ was propagated from a remote parent,

When extracting a SpanContext through the Propagators API, isRemote MUST return @True@,
whereas for the SpanContext of any child spans it MUST return @False@.

 @since 0.0.1.0
-}
spanIsRemote :: (MonadIO m) => Span -> m Bool
spanIsRemote (Span imm) = pure $ Types.isRemote $ Types.spanContext imm
spanIsRemote (FrozenSpan c) = pure $ Types.isRemote c
spanIsRemote (Dropped _) = pure False


{- | Really only intended for tests, this function does not conform
 to semantic versioning .

 @since 0.0.1.0
-}
unsafeReadSpan :: (MonadIO m) => Span -> m ImmutableSpan
unsafeReadSpan s =
  toImmutableSpan s >>= \case
    Right span -> pure span
    Left frozenOrDropped -> case frozenOrDropped of
      SpanFrozen -> error "This span is from another process"
      SpanDropped -> error "This span was dropped"


{- | Wrap a 'SpanContext' as a non-recording 'Span' ('FrozenSpan').

@since 0.0.1.0
-}
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

 @since 0.0.1.0
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


{- | Options used when creating a 'TracerProvider'.

@since 0.0.1.0
-}
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

 @since 0.0.1.0
-}
createTracerProvider :: (MonadIO m) => [SpanProcessor] -> TracerProviderOptions -> m TracerProvider
createTracerProvider ps opts = liftIO $ do
  let g = tracerProviderOptionsIdGenerator opts
      !procsVec = V.fromList ps
      !hasProc = not (V.null procsVec)
      !onStart = case V.length procsVec of
        0 -> \_ _ -> pure ()
        1 -> spanProcessorOnStart (V.unsafeHead procsVec)
        _ -> \imm ctx -> V.mapM_ (\p -> spanProcessorOnStart p imm ctx) procsVec
      !onEnd = case V.length procsVec of
        0 -> \_ -> pure ()
        1 -> spanProcessorOnEnd (V.unsafeHead procsVec)
        _ -> \imm -> V.mapM_ (\p -> spanProcessorOnEnd p imm) procsVec
  shutRef <- newIORef False
  cacheRef <- newIORef H.empty
  pure $
    TracerProvider
      { tracerProviderOnStart = onStart
      , tracerProviderOnEnd = onEnd
      , tracerProviderProcessors = procsVec
      , tracerProviderHasProcessor = hasProc
      , tracerProviderIdGenerator = g
      , tracerProviderSampler = tracerProviderOptionsSampler opts
      , tracerProviderResources = tracerProviderOptionsResources opts
      , tracerProviderAttributeLimits = tracerProviderOptionsAttributeLimits opts
      , tracerProviderSpanLimits = tracerProviderOptionsSpanLimits opts
      , tracerProviderPropagators = tracerProviderOptionsPropagators opts
      , tracerProviderExceptionHandlers = tracerProviderOptionsExceptionHandlers opts
      , tracerProviderIsShutdown = shutRef
      , tracerProviderTracerCache = cacheRef
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


-- | @since 0.0.1.0
getTracerProviderResources :: TracerProvider -> MaterializedResources
getTracerProviderResources = tracerProviderResources


-- | @since 0.0.1.0
getTracerProviderPropagators :: TracerProvider -> TextMapPropagator
getTracerProviderPropagators = tracerProviderPropagators


{- | Tracer configuration options.

@since 0.0.1.0
-}
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


{- | Default Tracer options

@since 0.0.1.0
-}
tracerOptions :: TracerOptions
tracerOptions = TracerOptions Nothing []


{- | A small utility lens for extracting a 'Tracer' from a larger data type

 This will generally be most useful as a means of implementing 'OpenTelemetry.Trace.Monad.getTracer'

 @since 0.0.1.0
-}
class HasTracer s where
  tracerL :: Lens' s Tracer


{- | Construct a 'Tracer' from a provider, library, and options.

Prefer a non-empty 'libraryName' per the OpenTelemetry specification; use 'getTracer'
if you want a warning when the name is empty.

@since 0.0.1.0
-}
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
      !sl = tracerProviderSpanLimits tp
  in Tracer
      { tracerName = n'
      , tracerProvider = tp
      , tracerExceptionHandlers = tracerExceptionHandlerOptions opts
      , tracerSpanAttributeLimits = resolveLimits spanAttributeCountLimit
      , tracerEventAttributeLimits = resolveLimits eventAttributeCountLimit
      , tracerLinkAttributeLimits = resolveLimits linkAttributeCountLimit
      , tracerEventCountLimit = fromMaybe 128 (eventCountLimit sl)
      , tracerLinkCountLimit = fromMaybe 128 (linkCountLimit sl)
      }


{- | Like 'makeTracer' but caches by 'InstrumentationLibrary', so repeated
calls with the same scope return the same 'Tracer' instance.
Spec: implementations SHOULD return a single Tracer per InstrumentationScope.

@since 0.0.1.0
-}
getTracer :: (MonadIO m) => TracerProvider -> InstrumentationLibrary -> TracerOptions -> m Tracer
getTracer tp n opts = liftIO $ do
  when (T.null (libraryName n)) $
    otelLogWarning "Tracer created with empty name; returning working Tracer with empty name per spec"
  let !t = makeTracer tp n opts
      !key = tracerName t
  atomicModifyIORef' (tracerProviderTracerCache tp) $ \cache ->
    case H.lookup key cache of
      Just cached -> (cache, cached)
      Nothing -> (H.insert key t cache, t)


-- | @since 0.0.1.0
getImmutableSpanTracer :: ImmutableSpan -> Tracer
getImmutableSpanTracer = spanTracer


-- | @since 0.0.1.0
getTracerTracerProvider :: Tracer -> TracerProvider
getTracerTracerProvider = tracerProvider


{- | Check if the 'Tracer' is enabled.

 This function helps users avoid performing computationally expensive operations
 when creating 'Span's if the tracer is not enabled.

 A 'Tracer' is considered enabled if it has at least one configured processor.
 If the 'TracerProvider' has no processors, all spans will be dropped, so the
 tracer is disabled.

 Callers SHOULD invoke this before each span creation to get the most up-to-date
 response, as the result may change over time.

 @since 0.3.1.0
-}
tracerIsEnabled :: Tracer -> Bool
tracerIsEnabled t = tracerProviderHasProcessor $ tracerProvider t


{- | Smart constructor for 'SpanArguments' providing reasonable values for most 'Span's created
 that are internal to an application.

 Defaults:

 - `kind`: `Internal`
 - `attributes`: @[]@
 - `links`: @[]@
 - `startTime`: `Nothing` (`getTimestamp` will be called upon `Span` creation)

 @since 0.0.1.0
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
shutdownTracerProvider
  :: (MonadIO m)
  => TracerProvider
  -> Maybe Int
  -- ^ Optional timeout in microseconds, defaults to 5,000,000 (5s)
  -> m ShutdownResult
shutdownTracerProvider TracerProvider {..} mtimeout = liftIO $ do
  alreadyShut <- atomicModifyIORef' tracerProviderIsShutdown $ \s -> (True, s)
  if alreadyShut
    then pure ShutdownFailure
    else do
      jobs <- V.mapM (async . spanProcessorShutdown) tracerProviderProcessors
      mresult <-
        timeout (fromMaybe 5_000_000 mtimeout) $
          V.foldM'
            ( \status action -> do
                res <- waitCatch action
                pure $! case res of
                  Left _err -> worstShutdown status ShutdownFailure
                  Right sr -> worstShutdown status sr
            )
            ShutdownSuccess
            jobs
      case mresult of
        Nothing -> do
          V.mapM_ cancel jobs
          pure ShutdownTimeout
        Just res -> pure res


{- | This method provides a way for provider to immediately export all spans that have not yet
 been exported for all the internal processors.

 @since 0.0.1.0
-}
forceFlushTracerProvider
  :: (MonadIO m)
  => TracerProvider
  -> Maybe Int
  -- ^ Optional timeout in microseconds, defaults to 5,000,000 (5s)
  -> m FlushResult
  -- ^ Result that denotes whether the flush action succeeded, failed, or timed out.
forceFlushTracerProvider TracerProvider {..} mtimeout = liftIO $ do
  isShut <- readIORef tracerProviderIsShutdown
  if isShut
    then pure FlushError
    else do
      jobs <- V.forM tracerProviderProcessors $ \processor ->
        async $
          spanProcessorForceFlush processor
      mresult <-
        timeout (fromMaybe 5_000_000 mtimeout) $
          V.foldM'
            ( \status action -> do
                res <- waitCatch action
                pure $! case res of
                  Left _err -> FlushError
                  Right fr -> worstFlush status fr
            )
            FlushSuccess
            jobs
      case mresult of
        Nothing -> do
          V.mapM_ cancel jobs
          pure FlushTimeout
        Just res -> pure res


{- | Run an action only when the span is recording. Use this to guard
expensive attribute computation that would be wasted on non-recording spans.

 @since 0.0.1.0
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


{- | Nanoseconds since the Unix epoch.

@since 0.0.1.0
-}
timestampNanoseconds :: Timestamp -> Word64
timestampNanoseconds = coerce
{-# INLINE timestampNanoseconds #-}
