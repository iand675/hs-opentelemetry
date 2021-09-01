module OpenTelemetry.Trace
  ( TracerProvider
  , createTracerProvider
  , getGlobalTracerProvider
  , setGlobalTracerProvider
  , emptyTracerProviderOptions
  , TracerProviderOptions(..)
  , Tracer
  , getTracer
  , TracerOptions(..)
  , tracerOptions
  -- * Span operations
  , createSpan
  , emptySpanArguments
  , endSpan
  , CreateSpanArguments(..)
  , SpanParent(..)
  , addLink
  , addEvent
  , NewEvent(..)
  , updateName
  , setStatus
  , SpanStatus(..)
  , OpenTelemetry.Trace.spanContext
  , insertAttribute
  , insertAttributes
  , isRecording
  , isValid
  ) where

import Control.Applicative
import Control.Concurrent.Async
import Control.Monad.IO.Class
import qualified Data.ByteString as B
import Data.IORef
import Data.Maybe (isNothing)
import Data.Text (Text)
import qualified Data.Vector as V
import OpenTelemetry.Context
import OpenTelemetry.Resource
import OpenTelemetry.Trace.SpanExporter
import OpenTelemetry.Trace.IdGenerator
import OpenTelemetry.Trace.Types
import qualified OpenTelemetry.Trace.Types as Types
import System.Clock
import System.IO.Unsafe

globalTracer :: IORef TracerProvider
globalTracer = unsafePerformIO $ do
  p <- createTracerProvider [] emptyTracerProviderOptions
  newIORef p
{-# NOINLINE globalTracer #-}

newtype TracerProviderOptions = TracerProviderOptions 
  { tracerProviderOptionsIdGenerator :: Maybe IdGenerator
  }

emptyTracerProviderOptions :: TracerProviderOptions
emptyTracerProviderOptions = TracerProviderOptions Nothing

createTracerProvider :: MonadIO m => [SpanProcessor] -> TracerProviderOptions -> m TracerProvider
createTracerProvider ps opts = liftIO $ do
  g <- case tracerProviderOptionsIdGenerator opts of
    Nothing -> makeDefaultIdGenerator
    Just g -> pure g
  pure $ TracerProvider (V.fromList ps) g

getGlobalTracerProvider :: MonadIO m => m TracerProvider
getGlobalTracerProvider = liftIO $ readIORef globalTracer

setGlobalTracerProvider :: MonadIO m => TracerProvider -> m ()
setGlobalTracerProvider = liftIO . writeIORef globalTracer

data TracerOptions = TracerOptions
  { tracerSchema :: Maybe Text
  }

tracerOptions :: TracerOptions
tracerOptions = TracerOptions Nothing

getTracer :: MonadIO m => TracerProvider -> TracerName -> TracerOptions -> m Tracer
getTracer p n TracerOptions{..} = liftIO $ do
  pure $ Tracer (tracerProviderProcessors p) (tracerProviderIdGenerator p)

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
  sId <- SpanId <$> generateSpanIdBytes (tracerIdGenerator t)
  st <- case startingTimestamp of
    Nothing -> getTime Realtime
    Just t -> pure t
  let ctxt = case p of
        Just c -> c
        Nothing -> mempty
  let parent = case lookupSpan ctxt of
        Nothing -> Nothing
        Just s -> Just s
  tId <- case parent of
    Nothing -> 
      TraceId <$> generateTraceIdBytes (tracerIdGenerator t)
    Just (Span s) ->
      traceId . Types.spanContext <$> readIORef s

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
        , spanParent = Left <$> parent 
        , spanKind = startingKind
        , spanAttributes = []
        , spanLinks = []
        , spanEvents = []
        , spanStatus = Unset
        , spanStart = st
        , spanEnd = Nothing
        }
  s <- Span <$> newIORef is 
  mapM_ (\processor -> (onStart processor) s ctxt) $ tracerProcessors t
  pure s

-- TODO should this use the atomic variant
addLink :: MonadIO m => Span -> Link -> m ()
addLink (Span s) l = liftIO $ modifyIORef s $ \i -> i { spanLinks = l : spanLinks i }

spanContext :: MonadIO m => Span -> m SpanContext
spanContext (Span s) = liftIO (Types.spanContext <$> readIORef s)
spanContext (FrozenSpan c) = pure c

isRecording :: MonadIO m => Span -> m Bool
isRecording (Span s) = liftIO (isNothing . spanEnd <$> readIORef s)
isRecording (FrozenSpan _) = pure True

shutdownTracer :: MonadIO m => Tracer -> m ()
shutdownTracer = undefined

forceFlushTracer :: MonadIO m => Tracer -> Int -> m (Async FlushResult)
forceFlushTracer = undefined

insertAttribute :: ToAttribute a => Span -> Text -> a -> IO ()
insertAttribute (Span s) k v = modifyIORef s $ \i -> i
  { spanAttributes = (k, toAttribute v) : spanAttributes i
  }
insertAttribute (FrozenSpan _) _ _ = pure ()

insertAttributes :: Span -> [(Text, Attribute)] -> IO ()
insertAttributes (Span s) attrs = modifyIORef s $ \i -> i
  { spanAttributes = attrs ++ spanAttributes i
  }
insertAttributes (FrozenSpan _) _ = pure ()

addEvent :: Span -> NewEvent -> IO ()
addEvent (Span s) NewEvent{..} = do
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

setStatus :: Span -> SpanStatus -> IO ()
setStatus (Span s) st = modifyIORef s $ \i -> i 
  { spanStatus = if st > spanStatus i
      then st
      else spanStatus i
  }
setStatus (FrozenSpan _) _ = pure ()

updateName :: Span -> Text -> IO ()
updateName (Span s) n = modifyIORef s $ \i -> i { spanName = n }
updateName (FrozenSpan _) _ = pure ()

endSpan :: Span -> Maybe Timestamp -> IO ()
endSpan (Span s) mts = do
  ts <- case mts of
    Nothing -> getTime Realtime
    Just t -> pure t
  modifyIORef s $ \i -> i { spanEnd = spanEnd i <|> Just ts }
endSpan (FrozenSpan _) _ = pure ()

recordException :: Span -> () -> IO ()
recordException = undefined

wrapSpanContext :: SpanContext -> Span
wrapSpanContext = FrozenSpan

isValid :: SpanContext -> Bool
isValid sc = not (B.all (== 0) tbs && B.all (== 0) sbs)
  where
    (TraceId tbs) = traceId sc
    (SpanId sbs) = spanId sc

isRemote :: MonadIO m => Span -> m Bool
isRemote (Span s) = liftIO $ do
  i <- readIORef s
  pure $ Types.isRemote $ Types.spanContext i
isRemote (FrozenSpan c) = pure $ Types.isRemote c
