{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE LambdaCase #-}
module OpenTelemetry.Trace.Core where
import Control.Applicative
import Control.Exception (Exception(..))
import Control.Monad.IO.Class
import Data.IORef
import Data.Maybe (isNothing)
import Data.Text (Text)
import Data.Typeable
import qualified Data.Text as T
import GHC.Stack.CCS (whoCreated)
import OpenTelemetry.Context
import OpenTelemetry.Internal.Trace.Types
import qualified OpenTelemetry.Internal.Trace.Types as Types
import OpenTelemetry.Resource
import OpenTelemetry.Trace.Id
import qualified OpenTelemetry.Trace.TraceState as TraceState
import System.Clock
import qualified VectorBuilder.Builder as Builder

createSpan
  :: MonadIO m
  => Tracer
  -> Context
  -> Text
  -> CreateSpanArguments
  -> m Span
createSpan t ctxt n args@CreateSpanArguments{..} = liftIO $ do
  sId <- newSpanId $ tracerProviderIdGenerator $ tracerProvider t
  let parent = lookupSpan ctxt
  tId <- case parent of
    Nothing -> newTraceId $ tracerProviderIdGenerator $ tracerProvider t
    Just (Span s) ->
      traceId . Types.spanContext <$> readIORef s
    Just (FrozenSpan s) -> pure $ traceId s
    Just (Dropped s) -> pure $ traceId s

  (samplingOutcome, additionalAttrs, samplingTraceState) <- case parent of
    -- TODO, this seems logically like what we'd do here
    Just (Dropped _) -> pure (Drop, [], TraceState.empty)
    _ -> shouldSample (tracerProviderSampler $ tracerProvider t)
      ctxt
      tId
      n
      args

  -- TODO properly populate
  let ctxtForSpan = SpanContext
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
        st <- case startingTimestamp of
          Nothing -> getTime Realtime
          Just time -> pure time

        let is = ImmutableSpan
              { spanName = n
              , spanContext = ctxtForSpan
              , spanParent = parent
              , spanKind = startingKind
              , spanAttributes = startingAttributes ++ additionalAttrs
              , spanLinks = startingLinks
              , spanEvents = Builder.empty
              , spanStatus = Unset
              , spanStart = st
              , spanEnd = Nothing
              , spanTracer = t
              }
        s <- newIORef is
        mapM_ (\processor -> spanProcessorOnStart processor s ctxt) $ tracerProviderProcessors $ tracerProvider t
        pure $ Span s

  case samplingOutcome of
    Drop -> pure $ Dropped ctxtForSpan
    RecordOnly -> mkRecordingSpan
    RecordAndSample -> mkRecordingSpan

-- | When sending tracing information across process boundaries,
-- the @SpanContext@ is used to serialize the relevant information.
getSpanContext :: MonadIO m => Span -> m SpanContext
getSpanContext (Span s) = liftIO (Types.spanContext <$> readIORef s)
getSpanContext (FrozenSpan c) = pure c
getSpanContext (Dropped c) = pure c

-- | Returns whether the the @Span@ is currently recording. If a span
-- is dropped, this will always return False. If a span is from an
-- external process, this will return True, and if the span was 
-- created by this process, the span will return True until endSpan
-- is called.
isRecording :: MonadIO m => Span -> m Bool
isRecording (Span s) = liftIO (isNothing . spanEnd <$> readIORef s)
isRecording (FrozenSpan _) = pure True
isRecording (Dropped _) = pure False

{- |
As an application developer when you need to record an attribute first consult existing semantic conventions for Resources, Spans, and Metrics. If an appropriate name does not exists you will need to come up with a new name. To do that consider a few options:

The name is specific to your company and may be possibly used outside the company as well. To avoid clashes with names introduced by other companies (in a distributed system that uses applications from multiple vendors) it is recommended to prefix the new name by your company’s reverse domain name, e.g. 'com.acme.shopname'.

The name is specific to your application that will be used internally only. If you already have an internal company process that helps you to ensure no name clashes happen then feel free to follow it. Otherwise it is recommended to prefix the attribute name by your application name, provided that the application name is reasonably unique within your organization (e.g. 'myuniquemapapp.longitude' is likely fine). Make sure the application name does not clash with an existing semantic convention namespace.

The name may be generally applicable to applications in the industry. In that case consider submitting a proposal to this specification to add a new name to the semantic conventions, and if necessary also to add a new namespace.

It is recommended to limit names to printable Basic Latin characters (more precisely to 'U+0021' .. 'U+007E' subset of Unicode code points), although the Haskell OpenTelemetry specification DOES provide full Unicode support.

Attribute names that start with 'otel.' are reserved to be defined by OpenTelemetry specification. These are typically used to express OpenTelemetry concepts in formats that don’t have a corresponding concept.

For example, the 'otel.library.name' attribute is used to record the instrumentation library name, which is an OpenTelemetry concept that is natively represented in OTLP, but does not have an equivalent in other telemetry formats and protocols.

Any additions to the 'otel.*' namespace MUST be approved as part of OpenTelemetry specification.
-}
insertAttribute :: MonadIO m => ToAttribute a => Span -> Text -> a -> m ()
insertAttribute (Span s) k v = liftIO $ modifyIORef s $ \i -> i
  { spanAttributes = (k, toAttribute v) : spanAttributes i
  }
insertAttribute (FrozenSpan _) _ _ = pure ()
insertAttribute (Dropped _) _ _ = pure ()

insertAttributes :: MonadIO m => Span -> [(Text, Attribute)] -> m ()
insertAttributes (Span s) attrs = liftIO $ modifyIORef s $ \i -> i
  { spanAttributes = attrs ++ spanAttributes i
  }
insertAttributes (FrozenSpan _) _ = pure ()
insertAttributes (Dropped _) _ = pure ()

addEvent :: MonadIO m => Span -> NewEvent -> m ()
addEvent (Span s) NewEvent{..} = liftIO $ do
  t <- case newEventTimestamp of
    Nothing -> getTime Realtime
    Just t -> pure t
  modifyIORef s $ \i -> i
    { spanEvents = spanEvents i <> Builder.singleton
        (Event
          { eventName = newEventName
          , eventAttributes = newEventAttributes
          , eventTimestamp = t
          }
        ) 
    }
addEvent (FrozenSpan _) _ = pure ()
addEvent (Dropped _) _ = pure ()

-- | Sets the Status of the Span. If used, this will override the default @Span@ status, which is @Unset@.
--
-- These values form a total order: Ok > Error > Unset. This means that setting Status with StatusCode=Ok will override any prior or future attempts to set span Status with StatusCode=Error or StatusCode=Unset.
setStatus :: MonadIO m => Span -> SpanStatus -> m ()
setStatus (Span s) st = liftIO $ modifyIORef s $ \i -> i
  { spanStatus = if st > spanStatus i
      then st
      else spanStatus i
  }
setStatus (FrozenSpan _) _ = pure ()
setStatus (Dropped _) _ = pure ()

{- |
Updates the Span name. Upon this update, any sampling behavior based on Span name will depend on the implementation.

Note that @Sampler@s can only consider information already present during span creation. Any changes done later, including updated span name, cannot change their decisions.

Alternatives for the name update may be late Span creation, when Span is started with the explicit timestamp from the past at the moment where the final Span name is known, or reporting a Span with the desired name as a child Span.
-}
updateName :: MonadIO m => 
     Span 
  -> Text 
  -- ^ The new span name, which supersedes whatever was passed in when the Span was started
  -> m ()
updateName (Span s) n = liftIO $ modifyIORef s $ \i -> i { spanName = n }
updateName (FrozenSpan _) _ = pure ()
updateName (Dropped _) _ = pure ()

{- |
Signals that the operation described by this span has now (or at the time optionally specified) ended.

This does have any effects on child spans. Those may still be running and can be ended later.

This also does not inactivate the Span in any Context it is active in. It is still possible to use an ended span as 
parent via a Context it is contained in. Also, putting the Span into a Context will still work after the Span was ended.
-}
endSpan :: MonadIO m 
  => Span 
  -> Maybe Timestamp
  -- ^ Optional @Timestamp@ signalling the end time of the span. If not provided, the current time will be used.
  -> m ()
endSpan (Span s) mts = liftIO $ do
  ts <- case mts of
    Nothing -> getTime Realtime
    Just t -> pure t
  frozenS <- atomicModifyIORef s $ \i ->
    let ref = i { spanEnd = spanEnd i <|> Just ts }
    in (ref, ref)
  mapM_ (`spanProcessorOnEnd` s) $ tracerProviderProcessors $ tracerProvider $ spanTracer frozenS
endSpan (FrozenSpan _) _ = pure ()
endSpan (Dropped _) _ = pure ()

-- | A specialized variant of @addEvent@ that records attributes conforming to
-- the OpenTelemetry specification's 
-- <https://github.com/open-telemetry/opentelemetry-specification/blob/49c2f56f3c0468ceb2b69518bcadadd96e0a5a8b/specification/trace/semantic_conventions/exceptions.md semantic conventions>
recordException :: (MonadIO m, Exception e) => Span -> [(Text, Attribute)] -> Maybe Timestamp -> e -> m ()
recordException s attrs ts e = liftIO $ do
  cs <- whoCreated e
  let message = T.pack $ show e
  addEvent s $ NewEvent
    { newEventName = "exception"
    , newEventAttributes = 
        [ ("exception.type", toAttribute $ T.pack $ show $ typeOf e)
        , ("exception.message", toAttribute message)
        , ("exception.stacktrace", toAttribute $ T.unlines $ map T.pack cs)
        ] ++ attrs
    , newEventTimestamp = ts
    }

-- | Returns @True@ if the @SpanContext@ has a non-zero @TraceID@ and a non-zero @SpanID@
isValid :: SpanContext -> Bool
isValid sc = not
  (isEmptyTraceId (traceId sc) && isEmptySpanId (spanId sc))

{- |
Returns @True@ if the @SpanContext@ was propagated from a remote parent, 

When extracting a SpanContext through the Propagators API, isRemote MUST return @True@,
whereas for the SpanContext of any child spans it MUST return @False@.
-}
isRemote :: MonadIO m => Span -> m Bool
isRemote (Span s) = liftIO $ do
  i <- readIORef s
  pure $ Types.isRemote $ Types.spanContext i
isRemote (FrozenSpan c) = pure $ Types.isRemote c
isRemote (Dropped _) = pure False

-- | Really only intended for tests, this function does not conform
-- to semantic versioning .
unsafeReadSpan :: MonadIO m => Span -> m ImmutableSpan
unsafeReadSpan = \case
  Span ref -> liftIO $ readIORef ref
  FrozenSpan _s -> error "This span is from another process"
  Dropped _s -> error "This span was dropped"

wrapSpanContext :: SpanContext -> Span
wrapSpanContext = FrozenSpan