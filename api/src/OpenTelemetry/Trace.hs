{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE LambdaCase #-}
module OpenTelemetry.Trace
  ( TracerProvider
  , HasTracerProvider(..)
  , createTracerProvider
  , shutdownTracerProvider
  , forceFlushTracerProvider
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
  -- | W3c Trace flags 
  --
  -- https://www.w3.org/TR/trace-context/#trace-flags
  , TraceFlags
  , traceFlagsValue
  , traceFlagsFromWord8
  , defaultTraceFlags
  , isSampled
  , setSampled
  , unsetSampled
  , createSpan
  , wrapSpanContext
  , emptySpanArguments
  , SpanKind(..)
  , endSpan
  , CreateSpanArguments(..)
  , Link(..)
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

import Control.Concurrent.Async
import Control.Monad.IO.Class
import Data.IORef
import Data.Text (Text)
import qualified Data.Vector as V
import Lens.Micro (Lens')
import OpenTelemetry.Resource
import OpenTelemetry.Trace.Core
import OpenTelemetry.Trace.IdGenerator
import OpenTelemetry.Trace.Sampler
import OpenTelemetry.Internal.Trace.Types
import System.Clock
import System.IO.Unsafe
import OpenTelemetry.Resource.Telemetry
import OpenTelemetry.Resource.Process (currentProcessRuntime, getProcess)
import OpenTelemetry.Resource.OperatingSystem (getOperatingSystem)
import OpenTelemetry.Resource.Service
import Control.Monad

class HasTracerProvider s where
  tracerProviderL :: Lens' s TracerProvider

builtInResources :: IO (Resource 'Nothing)
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
    ((emptyTracerProviderOptions @'Nothing)
      { tracerProviderOptionsResources = rs
      })
  newIORef p
{-# NOINLINE globalTracer #-}

getTimestamp :: MonadIO m => m Timestamp
getTimestamp = liftIO $ getTime Realtime

data TracerProviderOptions o = TracerProviderOptions
  { tracerProviderOptionsIdGenerator :: Maybe IdGenerator
  , tracerProviderOptionsSampler :: Sampler
  , tracerProviderOptionsResources :: Resource o
  }

emptyTracerProviderOptions :: (o ~ ResourceMerge o o) => TracerProviderOptions o
emptyTracerProviderOptions = TracerProviderOptions Nothing (parentBased $ parentBasedOptions alwaysOn) mempty 

createTracerProvider :: MonadIO m => [SpanProcessor] -> TracerProviderOptions o -> m TracerProvider
createTracerProvider ps opts = liftIO $ do
  envVarResource <- getEnvVarResourceAttributes
  g <- maybe
    makeDefaultIdGenerator pure (tracerProviderOptionsIdGenerator opts)
  pure $ TracerProvider
    (V.fromList ps)
    g
    (tracerProviderOptionsSampler opts)
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
getTracer tp n TracerOptions{} = liftIO $ do
  pure $ Tracer n tp

emptySpanArguments :: CreateSpanArguments
emptySpanArguments = CreateSpanArguments
  { startingKind = Internal
  , startingAttributes = []
  , startingLinks = []
  , startingTimestamp = Nothing
  }

-- This method provides a way for provider to do any cleanup required.
--
-- This will also trigger shutdowns on all internal processors.
shutdownTracerProvider :: MonadIO m => TracerProvider -> m ()
shutdownTracerProvider TracerProvider{..} = liftIO $ do
  asyncShutdownResults <- forM tracerProviderProcessors $ \processor -> do
    spanProcessorShutdown processor
  mapM_ wait asyncShutdownResults

-- | This method provides a way for provider to immediately export all spans that have not yet 
-- been exported for all the internal processors.
forceFlushTracerProvider 
  :: MonadIO m 
  => TracerProvider 
  -> Maybe Int
  -- ^ Optional timeout
  -> m (Async FlushResult)
  -- ^ Async result that denotes whether the flush action succeeded, failed, or timed out.
forceFlushTracerProvider = undefined
