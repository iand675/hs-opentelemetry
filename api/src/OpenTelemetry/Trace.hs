{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE NumericUnderscores #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  OpenTelemetry.Trace
-- Copyright   :  (c) Ian Duncan, 2021
-- License     :  BSD-3
-- Description :  Low-level tracing API
-- Maintainer  :  Ian Duncan
-- Stability   :  experimental
-- Portability :  non-portable (GHC extensions)
--
-- Traces track the progression of a single request, called a trace, as it is handled by services that make up an application. The request may be initiated by a user or an application. Distributed tracing is a form of tracing that traverses process, network and security boundaries. Each unit of work in a trace is called a span; a trace is a tree of spans. Spans are objects that represent the work being done by individual services or components involved in a request as it flows through a system. A span contains a span context, which is a set of globally unique identifiers that represent the unique request that each span is a part of. A span provides Request, Error and Duration (RED) metrics that can be used to debug availability as well as performance issues.
--
-- A trace contains a single root span which encapsulates the end-to-end latency for the entire request. You can think of this as a single logical operation, such as clicking a button in a web application to add a product to a shopping cart. The root span would measure the time it took from an end-user clicking that button to the operation being completed or failing (so, the item is added to the cart or some error occurs) and the result being displayed to the user. A trace is comprised of the single root span and any number of child spans, which represent operations taking place as part of the request. Each span contains metadata about the operation, such as its name, start and end timestamps, attributes, events, and status.
-- 
-- To create and manage spans in OpenTelemetry, the OpenTelemetry API provides the tracer interface. This object is responsible for tracking the active span in your process, and allows you to access the current span in order to perform operations on it such as adding attributes, events, and finishing it when the work it tracks is complete. One or more tracer objects can be created in a process through the tracer provider, a factory interface that allows for multiple tracers to be instantiated in a single process with different options.
-- 
-- Generally, the lifecycle of a span resembles the following:
-- 
-- A request is received by a service. The span context is extracted from the request headers, if it exists.
-- A new span is created as a child of the extracted span context; if none exists, a new root span is created.
-- The service handles the request. Additional attributes and events are added to the span that are useful for understanding the context of the request, such as the hostname of the machine handling the request, or customer identifiers.
-- New spans may be created to represent work being done by sub-components of the service.
-- When the service makes a remote call to another service, the current span context is serialized and forwarded to the next service by injecting the span context into the headers or message envelope.
-- The work being done by the service completes, successfully or not. The span status is appropriately set, and the span is marked finished.
-- For more information, see the traces specification, which covers concepts including: trace, span, parent/child relationship, span context, attributes, events and links.
--
--
-- The specification-confirming trace & span public interface.
--
-- See OpenTelemetry.Trace.Monad for an implementation that's
-- generally easier to use in idiomatic Haskell.
--
-----------------------------------------------------------------------------
module OpenTelemetry.Trace
  (
  -- * @TracerProvider@ operations
    TracerProvider
  , createTracerProvider
  , shutdownTracerProvider
  , forceFlushTracerProvider
  , getTracerProviderResources
  , getTracerProviderPropagators
  , getGlobalTracerProvider
  , setGlobalTracerProvider
  , emptyTracerProviderOptions
  , TracerProviderOptions(..)
  -- * @Tracer@ operations
  , Tracer
  , tracerName
  , HasTracer(..)
  , getTracer
  , getImmutableSpanTracer
  , getTracerTracerProvider
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
  -- ** Creating @Span@s
  , createSpan
  , wrapSpanContext
  , SpanKind(..)
  , defaultSpanArguments
  , SpanArguments(..)
  , Link(..)
  -- ** Recording @Event@s
  , Event(..)
  , NewEvent(..)
  , addEvent
  -- ** Enriching @Span@s with additional information
  , updateName
  , addAttribute
  , addAttributes
  , getAttributes
  , Attribute(..)
  , ToAttribute(..)
  , PrimitiveAttribute(..)
  , ToPrimitiveAttribute(..)
  -- ** Recording error information 
  , recordException
  , setStatus
  , SpanStatus(..)
  -- ** Completing @Span@s
  , endSpan
  -- ** Accessing other @Span@ information
  , getSpanContext
  , isRecording
  , isValid
  -- * Utilities
  , Timestamp
  , getTimestamp
  , timestampNanoseconds
  , unsafeReadSpan
  , whenSpanIsRecording
  , AppendOnlySequence
  , append
  , sequenceValues
  -- * Limits
  , SpanLimits(..)
  , defaultSpanLimits
  ) where

import Control.Concurrent.Async
import Control.Monad.IO.Class
import Data.IORef
import Data.Text (Text)
import Data.Maybe (fromMaybe)
import qualified Data.Vector as V
import Lens.Micro (Lens')
import OpenTelemetry.Resource
import OpenTelemetry.Trace.Core
import OpenTelemetry.Trace.IdGenerator
import OpenTelemetry.Trace.Sampler
import OpenTelemetry.Internal.Trace.Types
import System.IO.Unsafe
import OpenTelemetry.Resource.Telemetry
import OpenTelemetry.Resource.Process (currentProcessRuntime, getProcess)
import OpenTelemetry.Resource.OperatingSystem (getOperatingSystem)
import OpenTelemetry.Resource.Service
import Control.Monad
import System.Timeout (timeout)
import OpenTelemetry.Resource.Host (getHost)
import OpenTelemetry.Attributes (Attribute(..), PrimitiveAttribute(..), ToAttribute(..), ToPrimitiveAttribute(..), AttributeLimits, defaultAttributeLimits)
import System.Clock
import Data.Word (Word64)
import Network.HTTP.Types
import OpenTelemetry.Context.Propagators (Propagator)
import OpenTelemetry.Context (Context)

builtInResources :: IO (Resource 'Nothing)
builtInResources = do
  svc <- getService
  processInfo <- getProcess
  osInfo <- getOperatingSystem
  host <- getHost
  let rs =
        toResource svc `mergeResources`
        toResource telemetry `mergeResources`
        toResource currentProcessRuntime `mergeResources`
        toResource processInfo `mergeResources`
        toResource osInfo `mergeResources`
        toResource host
  pure rs

globalTracer :: IORef TracerProvider
globalTracer = unsafePerformIO $ do
  p <- createTracerProvider
    []
    emptyTracerProviderOptions
  newIORef p
{-# NOINLINE globalTracer #-}

data TracerProviderOptions = TracerProviderOptions
  { tracerProviderOptionsIdGenerator :: Maybe IdGenerator
  , tracerProviderOptionsSampler :: Sampler
  , tracerProviderOptionsResources :: MaterializedResources
  , tracerProviderOptionsAttributeLimits :: AttributeLimits
  , tracerProviderOptionsSpanLimits :: SpanLimits
  , tracerProviderOptionsPropagators :: Propagator Context RequestHeaders ResponseHeaders
  }

emptyTracerProviderOptions :: TracerProviderOptions
emptyTracerProviderOptions = TracerProviderOptions 
  Nothing 
  (parentBased $ parentBasedOptions alwaysOn) 
  emptyMaterializedResources 
  defaultAttributeLimits 
  defaultSpanLimits
  mempty

-- | Initialize a new tracer provider
--
-- You should generally use 'getGlobalTracerProvider' for most applications.
createTracerProvider :: MonadIO m => [SpanProcessor] -> TracerProviderOptions -> m TracerProvider
createTracerProvider ps opts = liftIO $ do
  let g = fromMaybe defaultIdGenerator (tracerProviderOptionsIdGenerator opts)
  pure $ TracerProvider
    (V.fromList ps)
    g
    (tracerProviderOptionsSampler opts)
    (tracerProviderOptionsResources opts)
    (tracerProviderOptionsAttributeLimits opts)
    (tracerProviderOptionsSpanLimits opts)
    (tracerProviderOptionsPropagators opts)

getGlobalTracerProvider :: MonadIO m => m TracerProvider
getGlobalTracerProvider = liftIO $ readIORef globalTracer

setGlobalTracerProvider :: MonadIO m => TracerProvider -> m ()
setGlobalTracerProvider = liftIO . writeIORef globalTracer

getTracerProviderResources :: TracerProvider -> MaterializedResources
getTracerProviderResources = tracerProviderResources

getTracerProviderPropagators :: TracerProvider -> Propagator Context RequestHeaders ResponseHeaders
getTracerProviderPropagators = tracerProviderPropagators

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

getImmutableSpanTracer :: ImmutableSpan -> Tracer
getImmutableSpanTracer = spanTracer

getTracerTracerProvider :: Tracer -> TracerProvider
getTracerTracerProvider = tracerProvider

-- | Smart constructor for 'SpanArguments' providing reasonable values for most 'Span's created
-- that are internal to an application.
--
-- Defaults:
--
-- - `kind`: `Internal`
-- - `attributes`: @[]@
-- - `links`: @[]@
-- - `startTime`: `Nothing` (`getTimestamp` will be called upon `Span` creation)
defaultSpanArguments :: SpanArguments
defaultSpanArguments = SpanArguments
  { kind = Internal
  , attributes = []
  , links = []
  , startTime = Nothing
  }

-- | This method provides a way for provider to do any cleanup required.
--
-- This will also trigger shutdowns on all internal processors.
--
-- @since 0.0.1.0
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
  -- ^ Optional timeout in microseconds, defaults to 5,000,000 (5s)
  -> m FlushResult
  -- ^ Result that denotes whether the flush action succeeded, failed, or timed out.
forceFlushTracerProvider TracerProvider{..} mtimeout = liftIO $ do
  jobs <- forM tracerProviderProcessors $ \processor -> async $ do
    spanProcessorForceFlush processor
  mresult <- timeout (fromMaybe 5_000_000 mtimeout) $
    foldM
      (\status action -> do
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

-- | Utility function to only perform costly attribute annotations
-- for spans that are actually 
whenSpanIsRecording :: MonadIO m => Span -> m () -> m ()
whenSpanIsRecording (Span ref) m = do
  span_ <- liftIO $ readIORef ref
  case spanEnd span_ of
    Nothing -> m
    Just _ -> pure ()
whenSpanIsRecording (FrozenSpan _) _ = pure ()
whenSpanIsRecording (Dropped _) _ = pure ()

timestampNanoseconds :: Timestamp -> Word64
timestampNanoseconds (Timestamp TimeSpec{..}) = fromIntegral (sec * 1_000_000_000) + fromIntegral nsec