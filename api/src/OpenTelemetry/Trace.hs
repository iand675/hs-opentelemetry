{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE LambdaCase #-}
module OpenTelemetry.Trace
  ( TracerProvider
  , HasTracerProvider(..)
  , createTracerProvider
  , getGlobalTracerProvider
  , setGlobalTracerProvider
  , emptyTracerProviderOptions
  , TracerProviderOptions(..)
  , Tracer
  , tracerName
  , HasTracer(..)
  , getTracer
  , InstrumentationLibrary(..)
  , TracerOptions(..)
  , tracerOptions
  , builtInResources
  -- * Span operations
  , Span
  , ImmutableSpan(..)
  , SpanContext(..)
  , createSpan
  , createRemoteSpan
  , emptySpanArguments
  , SpanKind(..)
  , endSpan
  , CreateSpanArguments(..)
  , SpanParent(..)
  , Link(..)
  , addLink
  , Event(..)
  , addEvent
  , recordException
  , NewEvent(..)
  , updateName
  , setStatus
  , SpanStatus(..)
  , getSpanContext
  , insertAttribute
  , insertAttributes
  , isRecording
  , isValid
  -- $ Utilities
  , getTimestamp
  , unsafeReadSpan
  ) where

import Control.Applicative
import Control.Concurrent.Async
import Control.Exception (Exception(..))
import Control.Monad.IO.Class
import qualified Data.ByteString as B
import Data.ByteString.Short (toShort)
import Data.IORef
import Data.Maybe (isNothing, fromMaybe)
import Data.Text (Text)
import qualified Data.Vector as V
import Lens.Micro (Lens')
import OpenTelemetry.Context
import OpenTelemetry.Resource
import OpenTelemetry.Trace.SpanExporter
import OpenTelemetry.Trace.Id
import OpenTelemetry.Trace.IdGenerator
import OpenTelemetry.Internal.Trace.Types
import qualified OpenTelemetry.Internal.Trace.Types as Types
import System.Clock
import System.IO.Unsafe
import OpenTelemetry.Resource.Telemetry
import OpenTelemetry.Resource.Process (currentProcessRuntime, getProcess)
import OpenTelemetry.Resource.OperatingSystem (getOperatingSystem)
import OpenTelemetry.Resource.Service
import qualified Data.Text as T
import GHC.Stack.CCS (whoCreated)
import Data.Typeable (typeOf)

class HasTracerProvider s where
  tracerProviderL :: Lens' s TracerProvider

builtInResources :: IO (Resource Nothing)
builtInResources = do
  svc <- getService
  processInfo <- getProcess
  osInfo <- getOperatingSystem
  let rs = 
        toResource svc `mergeResources`
        toResource telemetry `mergeResources`
        toResource currentProcessRuntime `mergeResources`
        toResource processInfo `mergeResources`
        toResource osInfo
  pure rs

globalTracer :: IORef TracerProvider
globalTracer = unsafePerformIO $ do
  rs <- builtInResources
  p <- createTracerProvider
    []
    ((emptyTracerProviderOptions @Nothing)
      { tracerProviderOptionsResources = rs
      })
  newIORef p
{-# NOINLINE globalTracer #-}

getTimestamp :: MonadIO m => m Timestamp
getTimestamp = liftIO $ getTime Realtime

data TracerProviderOptions o = TracerProviderOptions
  { tracerProviderOptionsIdGenerator :: Maybe IdGenerator
  , tracerProviderOptionsResources :: Resource o
  }

emptyTracerProviderOptions :: (o ~ ResourceMerge o o) => TracerProviderOptions o
emptyTracerProviderOptions = TracerProviderOptions Nothing mempty

createTracerProvider :: MonadIO m => [SpanProcessor] -> TracerProviderOptions o -> m TracerProvider
createTracerProvider ps opts = liftIO $ do
  envVarResource <- getEnvVarResourceAttributes
  g <- maybe
    makeDefaultIdGenerator pure (tracerProviderOptionsIdGenerator opts)
  pure $ TracerProvider
    (V.fromList ps)
    g
    (envVarResource `mergeResources` tracerProviderOptionsResources opts)

getGlobalTracerProvider :: MonadIO m => m TracerProvider
getGlobalTracerProvider = liftIO $ readIORef globalTracer

setGlobalTracerProvider :: MonadIO m => TracerProvider -> m ()
setGlobalTracerProvider = liftIO . writeIORef globalTracer

newtype TracerOptions = TracerOptions
  { tracerSchema :: Maybe Text
  }

tracerOptions :: TracerOptions
tracerOptions = TracerOptions Nothing

class HasTracer s where
  tracerL :: Lens' s Tracer

getTracer :: MonadIO m => TracerProvider -> InstrumentationLibrary -> TracerOptions -> m Tracer
getTracer TracerProvider{..} n TracerOptions{..} = liftIO $ do
  pure $ Tracer
    n
    tracerProviderProcessors
    tracerProviderIdGenerator
    (resourceAttributes tracerProviderResources)

emptySpanArguments :: CreateSpanArguments
emptySpanArguments = CreateSpanArguments
  { startingKind = Internal
  , startingLinks = []
  , startingTimestamp = Nothing
  }

createSpan
  :: MonadIO m
  => Tracer
  -> SpanParent
  -> Text
  -> CreateSpanArguments
  -> m Span
createSpan t p n CreateSpanArguments{..} = liftIO $ do
  sId <- newSpanId $ tracerIdGenerator t
  st <- case startingTimestamp of
    Nothing -> getTime Realtime
    Just t -> pure t
  let ctxt = fromMaybe mempty p
  let parent = lookupSpan ctxt
  tId <- case parent of
    Nothing -> newTraceId $ tracerIdGenerator t
    Just (Span s) ->
      traceId . Types.spanContext <$> readIORef s
    Just (FrozenSpan s) -> pure $ traceId s

  let is = ImmutableSpan
        { spanName = n
        -- TODO properly populate
        , spanContext = SpanContext
            { traceFlags = 0
            , isRemote = False
            , traceState = []
            , spanId = sId
            , traceId = tId
            }
        , spanParent = parent
        , spanKind = startingKind
        , spanAttributes = []
        , spanLinks = startingLinks
        , spanEvents = []
        , spanStatus = Unset
        , spanStart = st
        , spanEnd = Nothing
        , spanTracer = t
        }
  s <- newIORef is
  mapM_ (\processor -> (onStart processor) s ctxt) $ tracerProcessors t
  pure $ Span s

createRemoteSpan :: SpanContext -> Span
createRemoteSpan = FrozenSpan

-- TODO should this use the atomic variant
addLink :: MonadIO m => Span -> Link -> m ()
addLink (Span s) l = liftIO $ modifyIORef s $ \i -> i 
  { spanLinks = (l { linkAttributes = linkAttributes l }) : spanLinks i 
  }
addLink (FrozenSpan _) _ = pure ()

getSpanContext :: MonadIO m => Span -> m SpanContext
getSpanContext (Span s) = liftIO (Types.spanContext <$> readIORef s)
getSpanContext (FrozenSpan c) = pure c

isRecording :: MonadIO m => Span -> m Bool
isRecording (Span s) = liftIO (isNothing . spanEnd <$> readIORef s)
isRecording (FrozenSpan _) = pure True

shutdownTracer :: MonadIO m => Tracer -> m ()
shutdownTracer = undefined

forceFlushTracer :: MonadIO m => Tracer -> Int -> m (Async FlushResult)
forceFlushTracer = undefined

insertAttribute :: MonadIO m => ToAttribute a => Span -> Text -> a -> m ()
insertAttribute (Span s) k v = liftIO $ modifyIORef s $ \i -> i
  { spanAttributes = (k, toAttribute v) : spanAttributes i
  }
insertAttribute (FrozenSpan _) _ _ = pure ()

insertAttributes :: MonadIO m => Span -> [(Text, Attribute)] -> m ()
insertAttributes (Span s) attrs = liftIO $ modifyIORef s $ \i -> i
  { spanAttributes = attrs ++ spanAttributes i
  }
insertAttributes (FrozenSpan _) _ = pure ()

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

setStatus :: MonadIO m => Span -> SpanStatus -> m ()
setStatus (Span s) st = liftIO $ modifyIORef s $ \i -> i
  { spanStatus = if st > spanStatus i
      then st
      else spanStatus i
  }
setStatus (FrozenSpan _) _ = pure ()

updateName :: MonadIO m => Span -> Text -> m ()
updateName (Span s) n = liftIO $ modifyIORef s $ \i -> i { spanName = n }
updateName (FrozenSpan _) _ = pure ()

endSpan :: MonadIO m => Span -> Maybe Timestamp -> m ()
endSpan (Span s) mts = liftIO $ do
  ts <- case mts of
    Nothing -> getTime Realtime
    Just t -> pure t
  frozenS <- atomicModifyIORef s $ \i ->
    let ref = i { spanEnd = spanEnd i <|> Just ts }
    in (ref, ref)
  mapM_ (`onEnd` s) $ tracerProcessors $ spanTracer frozenS
endSpan (FrozenSpan _) _ = pure ()

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

wrapSpanContext :: SpanContext -> Span
wrapSpanContext = FrozenSpan

isValid :: SpanContext -> Bool
isValid sc = not
  ( isEmptyTraceId (traceId sc) && isEmptySpanId (spanId sc))

isRemote :: MonadIO m => Span -> m Bool
isRemote (Span s) = liftIO $ do
  i <- readIORef s
  pure $ Types.isRemote $ Types.spanContext i
isRemote (FrozenSpan c) = pure $ Types.isRemote c

-- | Really only intended for tests, this function does not conform
-- to semantic versioning .
unsafeReadSpan :: MonadIO m => Span -> m ImmutableSpan
unsafeReadSpan = \case
  Span ref -> liftIO $ readIORef ref
  FrozenSpan s -> error "This span is from another process"