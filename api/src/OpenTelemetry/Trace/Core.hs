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
              , spanEvents = []
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

getSpanContext :: MonadIO m => Span -> m SpanContext
getSpanContext (Span s) = liftIO (Types.spanContext <$> readIORef s)
getSpanContext (FrozenSpan c) = pure c
getSpanContext (Dropped c) = pure c

isRecording :: MonadIO m => Span -> m Bool
isRecording (Span s) = liftIO (isNothing . spanEnd <$> readIORef s)
isRecording (FrozenSpan _) = pure True
isRecording (Dropped _) = pure False

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
    { spanEvents =
        Event
          { eventName = newEventName
          , eventAttributes = newEventAttributes
          , eventTimestamp = t
          }
        : spanEvents i
    }
addEvent (FrozenSpan _) _ = pure ()
addEvent (Dropped _) _ = pure ()

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