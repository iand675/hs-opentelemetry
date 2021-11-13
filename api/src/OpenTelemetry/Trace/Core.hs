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

-- TODO should this use the atomic variant
addLink :: MonadIO m => Span -> Link -> m ()
addLink (Span s) l = liftIO $ modifyIORef s $ \i -> i
  { spanLinks = (l { linkAttributes = linkAttributes l }) : spanLinks i
  }
addLink (FrozenSpan _) _ = pure ()
addLink (Dropped _) _ = pure ()

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

updateName :: MonadIO m => Span -> Text -> m ()
updateName (Span s) n = liftIO $ modifyIORef s $ \i -> i { spanName = n }
updateName (FrozenSpan _) _ = pure ()
updateName (Dropped _) _ = pure ()

endSpan :: MonadIO m => Span -> Maybe Timestamp -> m ()
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

recordException :: Exception e => Span -> e -> IO ()
recordException s e = do
  cs <- whoCreated e
  let message = T.pack $ show e
  setStatus s $ Error message
  insertAttributes s
    [ ("exception.type", toAttribute $ T.pack $ show $ typeOf e)
    , ("exception.message", toAttribute message)
    , ("exception.stacktrace", toAttribute $ T.unlines $ map T.pack cs)
    ]

isValid :: SpanContext -> Bool
isValid sc = not
  (isEmptyTraceId (traceId sc) && isEmptySpanId (spanId sc))

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