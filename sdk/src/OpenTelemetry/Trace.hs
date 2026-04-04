{-# LANGUAGE CPP #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

-----------------------------------------------------------------------------

-----------------------------------------------------------------------------

{- |
 Module      :  OpenTelemetry.Trace
 Copyright   :  (c) Ian Duncan, 2021
 License     :  BSD-3
 Description :  Application Tracing API
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)

 Traces track the progression of a single request, called a trace, as it is handled
 by services that make up an application. The request may be initiated by a user or
 an application. Distributed tracing is a form of tracing that traverses process, network
 and security boundaries. Each unit of work in a trace is called a span; a trace is a tree of spans.
 Spans are objects that represent the work being done by individual services or components involved in a request as it flows through a system. A span contains a span context, which is a set of globally unique identifiers that represent the unique request that each span is a part of.
 A span provides Request, Error and Duration (RED) metrics that can be used to debug availability as well as performance issues.

 Here is a visualization of the relationship between traces and spans:

 <<docs/img/traces_spans.png>>

 A trace contains a single root span which encapsulates the end-to-end latency for the entire request. You can think of this as a single logical operation, such as clicking a button in a web application to add a product to a shopping cart. The root span would measure the time it took from an end-user clicking that button to the operation being completed or failing (so, the item is added to the cart or some error occurs) and the result being displayed to the user. A trace is comprised of the single root span and any number of child spans, which represent operations taking place as part of the request. Each span contains metadata about the operation, such as its name, start and end timestamps, attributes (which represent additonal user-defined metadata about a span), events, and status.

 To create and manage spans in OpenTelemetry, the OpenTelemetry API provides the tracer interface. This object is responsible for tracking the active span in your process, and allows you to access the current span in order to perform operations on it such as adding attributes, events, and finishing it when the work it tracks is complete. One or more tracer objects can be created in a process through the tracer provider, a factory interface that allows for multiple tracers to be instantiated in a single process with different options.

 Generally, the lifecycle of a span resembles the following:

 - A request is received by a service. The span context is extracted from the request headers, if it exists.
 - A new span is created as a child of the extracted span context; if none exists, a new root span is created.
 - The service handles the request. Additional attributes and events are added to the span that are useful for understanding the context of the request, such as the hostname of the machine handling the request, or customer identifiers.
 - New spans may be created to represent work being done by sub-components of the service.
 - When the service makes a remote call to another service, the current span context is serialized and forwarded to the next service by injecting the span context into the headers or message envelope.
 - The work being done by the service completes, successfully or not. The span status is appropriately set, and the span is marked finished.
 - For more information, see the traces specification, which covers concepts including: trace, span, parent/child relationship, span context, attributes, events and links.


 This module implements eveything required to conform to the trace & span public interface described
 by the OpenTelemetry specification.

 See "OpenTelemetry.Trace.Monad" for an implementation of 'inSpan' variants that are
 slightly easier to use in idiomatic Haskell monadic code.
-}
module OpenTelemetry.Trace (
  -- * How to use this library

  -- ** Quick start
  -- $use

  -- ** Configuration

  -- Nearly everything is configurable via environment variables.

  -- *** General configuration variables
  -- $envGeneral

  -- *** Batch span processor configuration variables
  -- $envBsp

  -- *** Attribute limits
  -- $envAttributeLimits

  -- *** Span limits
  -- $envSpanLimits

  -- ** Exporting data

  --
  -- By default, the <https://hackage.haskell.org/package/hs-opentelemetry-exporter-otlp OTLP protocol exporter>
  -- will be used. It supports exporting to the <https://opentelemetry.io/docs/collector/getting-started/ OpenTelemetry collector agent>,
  -- which supports a wide array of 3rd party services, and also provides a wide array of data enrichment abilities.
  --
  -- Additionally, a number of third party services directly support the OTLP protocol, so you can also often directly connect
  -- to their API gateway to send data. See your telemetry vendor's documentation to determine if this is the case.
  --
  -- There are a number of other exporters <https://hackage.haskell.org/packages/search?terms=hs-opentelemetry-exporter available on hackage>, including
  -- an in-memory exporter for testing.
  --
  -- Third-party exporters can register themselves with the global
  -- registry (see "OpenTelemetry.Registry") so that
  -- @OTEL_TRACES_EXPORTER@ can reference them by name.  Likewise,
  -- custom propagators can be registered for @OTEL_PROPAGATORS@
  -- resolution.  Registrations made before 'initializeGlobalTracerProvider'
  -- take precedence over built-in defaults.

  -- * 'TracerProvider' operations
  -- $tracerProvider
  TracerProvider,
  withTracerProvider,
  initializeGlobalTracerProvider,
  initializeTracerProvider,
  getTracerProviderInitializationOptions,
  getTracerProviderInitializationOptions',
  shutdownTracerProvider,
  shutdownGlobalProviders,
  forceFlushTracerProvider,

  -- ** Getting / setting the global 'TracerProvider'
  getGlobalTracerProvider,
  setGlobalTracerProvider,

  -- * 'Tracer' operations
  Tracer,
  tracerName,
  getTracer,
  makeTracer,
  TracerOptions (..),
  tracerOptions,
  HasTracer (..),
  InstrumentationLibrary (..),
  instrumentationLibrary,
  withSchemaUrl,
  withLibraryAttributes,
  detectInstrumentationLibrary,

  -- * 'Span' operations
  Span,
  inSpan,
  defaultSpanArguments,
  SpanArguments (..),
  SpanKind (..),
  NewLink (..),
  addLink,
  inSpan',
  updateName,
  addAttribute,
  addAttributes,
  recordException,
  setStatus,
  SpanStatus (..),
  NewEvent (..),
  addEvent,
  inSpan'',

  -- ** Exception handling
  ExceptionClassification (..),
  ExceptionResponse (..),
  ExceptionHandler,
  defaultExceptionResponse,
  resolveException,

  -- * Primitive span and tracing operations

  -- ** Alternative 'TracerProvider' initialization
  createTracerProvider,
  TracerProviderOptions (..),
  emptyTracerProviderOptions,
  detectBuiltInResources,
  registerBuiltinResourceDetectors,
  detectSampler,
  detectSpanLimits,

  -- ** Sampling
  Sampler,
  alwaysOn,
  alwaysOff,
  alwaysRecord,
  parentBased,
  parentBasedOptions,
  traceIdRatioBased,
  createSpan,
  createSpanWithoutCallStack,
  endSpan,
  spanGetAttributes,
  ToAttribute (..),
  ToPrimitiveAttribute (..),
  Attribute (..),
  PrimitiveAttribute (..),
  Link,
  Event,
  SpanContext (..),
  -- Exporters need field access to serialize span data per the spec
  ImmutableSpan (..),
) where

import Control.Concurrent (ThreadId, myThreadId)
import Control.Exception (Exception, SomeException, bracket, catch, throwTo)
import qualified Data.ByteString.Char8 as B
import Data.Either (partitionEithers)
import qualified Data.HashMap.Strict as H
import Data.IORef (IORef, atomicModifyIORef', newIORef)
import Data.List (foldl', nub)
import Data.Maybe (fromMaybe)
import qualified Data.Text as T
import Data.Text.Encoding (decodeUtf8)
import qualified Data.Text.Read as TR
import OpenTelemetry.Attributes (AttributeLimits (..), defaultAttributeLimits)
import OpenTelemetry.Baggage (decodeBaggageHeader)
import qualified OpenTelemetry.Baggage as Baggage
import OpenTelemetry.Configuration (OTelComponents (..), initializeFromConfigFile)
import OpenTelemetry.Environment
import OpenTelemetry.Exporter.Handle.LogRecord (stdoutLogRecordExporter)
import OpenTelemetry.Exporter.OTLP.LogRecord (otlpLogRecordExporter)
import OpenTelemetry.Exporter.OTLP.Span (loadExporterEnvironmentVariables, otlpExporter)
import OpenTelemetry.Exporter.Span (SpanExporter)
import OpenTelemetry.Internal.Logging (otelLogDebug, otelLogError, otelLogWarning)
import OpenTelemetry.Internal.Logs.Types (LogRecordExporter)
import OpenTelemetry.Logs.Core (LoggerProvider, createLoggerProvider, emptyLoggerProviderOptions, setGlobalLoggerProvider, shutdownLoggerProvider)
import OpenTelemetry.Metrics (MeterProvider (..), setGlobalMeterProvider)
import OpenTelemetry.Processor.Batch.LogRecord (BatchLogRecordProcessorConfig (..), batchLogRecordProcessor)
import OpenTelemetry.Processor.Batch.Span (BatchTimeoutConfig (..), batchProcessor, batchTimeoutConfig)
import OpenTelemetry.Processor.Span (SpanProcessor)
import OpenTelemetry.Propagator (TextMapPropagator, setGlobalTextMapPropagator)
import OpenTelemetry.Propagator.B3 (b3MultiTraceContextPropagator, b3TraceContextPropagator)
import OpenTelemetry.Propagator.Datadog (datadogTraceContextPropagator)
import OpenTelemetry.Propagator.Jaeger (jaegerPropagator)
import OpenTelemetry.Propagator.W3CBaggage (w3cBaggagePropagator)
import OpenTelemetry.Propagator.W3CTraceContext (w3cTraceContextPropagator)
import OpenTelemetry.Propagator.XRay (xrayPropagator)
import qualified OpenTelemetry.Registry as Registry
import OpenTelemetry.Resource
import OpenTelemetry.Resource.Cloud ()
import OpenTelemetry.Resource.Cloud.Detector (detectCloud)
import OpenTelemetry.Resource.Container ()
import OpenTelemetry.Resource.Container.Detector (detectContainer)
import OpenTelemetry.Resource.Detector.AWS.EC2 (detectEC2Self)
import OpenTelemetry.Resource.Detector.AWS.ECS (detectECSSelf)
import OpenTelemetry.Resource.Detector.AWS.EKS (detectEKSSelf)
import OpenTelemetry.Resource.Detector.Azure (detectAzureVMSelf)
import OpenTelemetry.Resource.Detector.GCP (detectGCPComputeSelf)
import OpenTelemetry.Resource.Detector.Heroku (detectHeroku)
import OpenTelemetry.Resource.FaaS (FaaS)
import OpenTelemetry.Resource.FaaS.Detector (detectFaaS)
import OpenTelemetry.Resource.Host.Detector (detectHost)
import OpenTelemetry.Resource.Kubernetes (Cluster, Namespace, Node, Pod)
import OpenTelemetry.Resource.Kubernetes.Detector (KubernetesResources (..), detectKubernetes)
import OpenTelemetry.Resource.OperatingSystem.Detector (detectOperatingSystem)
import OpenTelemetry.Resource.Process.Detector (detectProcess, detectProcessRuntime)
import OpenTelemetry.Resource.Service.Detector (detectService)
import OpenTelemetry.Resource.Telemetry.Detector (detectTelemetry)
import OpenTelemetry.Trace.Core
import OpenTelemetry.Trace.Id.Generator.Default (defaultIdGenerator)
import OpenTelemetry.Trace.Sampler (Sampler, alwaysOff, alwaysOn, alwaysRecord, parentBased, parentBasedOptions, traceIdRatioBased)
import System.Environment (lookupEnv)
import System.IO.Unsafe (unsafePerformIO)
import Text.Read (readMaybe)


#if !defined(mingw32_HOST_OS)
import System.Posix.Signals (installHandler, sigTERM, Handler(CatchOnce))
#endif


{- $use

 1. Initialize a 'TracerProvider'.
 2. Create a 'Tracer' for your system.
 3. Add <https://hackage.haskell.org/packages/search?terms=hs-opentelemetry-instrumentation relevant pre-made instrumentation>
 4. Annotate your internal functions using the 'inSpan' function or one of its variants.
-}


{- $tracerProvider

 A `TracerProvider` is key to using OpenTelemetry tracing. It is the data structure responsible for designating how spans are processed and exported

 You will generally only need to call 'initializeGlobalTracerProvider' on initialization,
 and 'shutdownTracerProvider' when your application exits.

 @

 main :: IO ()
 main = withTracer $ \tracer -> do
   -- your existing code here...
   pure ()
   where
     withTracer f = bracket
       -- Install the SDK, pulling configuration from the environment
       initializeGlobalTracerProvider
       -- Ensure that any spans that haven't been exported yet are flushed
       shutdownTracerProvider
       (\tracerProvider -> do
         -- Get a tracer so you can create spans
         tracer <- getTracer tracerProvider "your-app-name-or-subsystem"
         f tracer
       )

 @
-}


{- $envGeneral

 +---------------------------+---------------------------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
 | Name                      | Description                                                                                                   | Default                                                                                                                                        | Notes                                                                                                                                                                                                                                                                                    |
 +===========================+===============================================================================================================+================================================================================================================================================+==========================================================================================================================================================================================================================================================================================+
 | OTEL_SDK_DISABLED         | Disable the SDK for all signals                                                                               | false                                                                                                                                          | Boolean value. If “true”, a no-op SDK implementation will be used for all telemetry signals. Any other value or absence of the variable will have no effect and the SDK will remain enabled. This setting has no effect on propagators configured through the OTEL_PROPAGATORS variable. |
 +---------------------------+---------------------------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
 | OTEL_RESOURCE_ATTRIBUTES  | Key-value pairs to be used as resource attributes                                                             | See [Resource semantic conventions](resource/semantic_conventions/README.md#semantic-attributes-with-sdk-provided-default-value) for details.  | See [Resource SDK](./resource/sdk.md#specifying-resource-information-via-an-environment-variable) for more details.                                                                                                                                                                      |
 +---------------------------+---------------------------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
 | OTEL_SERVICE_NAME         | Sets the value of the [`service.name`](./resource/semantic_conventions/README.md#service) resource attribute  |                                                                                                                                                | If `service.name` is also provided in `OTEL_RESOURCE_ATTRIBUTES`, then `OTEL_SERVICE_NAME` takes precedence.                                                                                                                                                                             |
 +---------------------------+---------------------------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
 | OTEL_LOG_LEVEL            | Log level used by the SDK logger                                                                              | "info"                                                                                                                                         |                                                                                                                                                                                                                                                                                          |
 +---------------------------+---------------------------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
 | OTEL_PROPAGATORS          | Propagators to be used as a comma-separated list                                                              | "tracecontext,baggage"                                                                                                                         | Values MUST be deduplicated in order to register a `Propagator` only once.                                                                                                                                                                                                               |
 +---------------------------+---------------------------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
 | OTEL_TRACES_SAMPLER       | Sampler to be used for traces                                                                                 | "parentbased_always_on"                                                                                                                        | See [Sampling](./trace/sdk.md#sampling)                                                                                                                                                                                                                                                  |
 +---------------------------+---------------------------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
 | OTEL_TRACES_SAMPLER_ARG   | String value to be used as the sampler argument                                                               |                                                                                                                                                | The specified value will only be used if OTEL_TRACES_SAMPLER is set. Each Sampler type defines its own expected input, if any. Invalid or unrecognized input MUST be logged and MUST be otherwise ignored, i.e. the SDK MUST behave as if OTEL_TRACES_SAMPLER_ARG is not set.            |
 +---------------------------+---------------------------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
-}


{- $envBsp
 +---------------------------------+-------------------------------------------------+----------+--------------------------------------------------------+
 | Name                            | Description                                     | Default  | Notes                                                  |
 +=================================+=================================================+==========+========================================================+
 | OTEL_BSP_SCHEDULE_DELAY         | Delay interval between two consecutive exports  | 5000     |                                                        |
 +---------------------------------+-------------------------------------------------+----------+--------------------------------------------------------+
 | OTEL_BSP_EXPORT_TIMEOUT         | Maximum allowed time to export data             | 30000    |                                                        |
 +---------------------------------+-------------------------------------------------+----------+--------------------------------------------------------+
 | OTEL_BSP_MAX_QUEUE_SIZE         | Maximum queue size                              | 2048     |                                                        |
 +---------------------------------+-------------------------------------------------+----------+--------------------------------------------------------+
 | OTEL_BSP_MAX_EXPORT_BATCH_SIZE  | Maximum batch size                              | 512      | Must be less than or equal to OTEL_BSP_MAX_QUEUE_SIZE  |
 +---------------------------------+-------------------------------------------------+----------+--------------------------------------------------------+
-}


{- $envAttributeLimits
 +------------------------------------+---------------------------------------+----------+-----------------------------------------------------------------------------------+
 | Name                               | Description                           | Default  | Notes                                                                             |
 +====================================+=======================================+==========+===================================================================================+
 | OTEL_ATTRIBUTE_VALUE_LENGTH_LIMIT  | Maximum allowed attribute value size  |          | Empty value is treated as infinity. Non-integer and negative values are invalid.  |
 +------------------------------------+---------------------------------------+----------+-----------------------------------------------------------------------------------+
 | OTEL_ATTRIBUTE_COUNT_LIMIT         | Maximum allowed span attribute count  | 128      |                                                                                   |
 +------------------------------------+---------------------------------------+----------+-----------------------------------------------------------------------------------+
-}


{- $envSpanLimits
 +-----------------------------------------+-------------------------------------------------+----------+-----------------------------------------------------------------------------------+
 | Name                                    | Description                                     | Default  | Notes                                                                             |
 +=========================================+=================================================+==========+===================================================================================+
 | OTEL_SPAN_ATTRIBUTE_VALUE_LENGTH_LIMIT  | Maximum allowed attribute value size            |          | Empty value is treated as infinity. Non-integer and negative values are invalid.  |
 +-----------------------------------------+-------------------------------------------------+----------+-----------------------------------------------------------------------------------+
 | OTEL_SPAN_ATTRIBUTE_COUNT_LIMIT         | Maximum allowed span attribute count            | 128      |                                                                                   |
 +-----------------------------------------+-------------------------------------------------+----------+-----------------------------------------------------------------------------------+
 | OTEL_SPAN_EVENT_COUNT_LIMIT             | Maximum allowed span event count                | 128      |                                                                                   |
 +-----------------------------------------+-------------------------------------------------+----------+-----------------------------------------------------------------------------------+
 | OTEL_SPAN_LINK_COUNT_LIMIT              | Maximum allowed span link count                 | 128      |                                                                                   |
 +-----------------------------------------+-------------------------------------------------+----------+-----------------------------------------------------------------------------------+
 | OTEL_EVENT_ATTRIBUTE_COUNT_LIMIT        | Maximum allowed attribute per span event count  | 128      |                                                                                   |
 +-----------------------------------------+-------------------------------------------------+----------+-----------------------------------------------------------------------------------+
 | OTEL_LINK_ATTRIBUTE_COUNT_LIMIT         | Maximum allowed attribute per span link count   | 128      |                                                                                   |
 +-----------------------------------------+-------------------------------------------------+----------+-----------------------------------------------------------------------------------+
-}


registerBuiltinPropagators :: IO ()
registerBuiltinPropagators = do
  _ <- Registry.registerTextMapPropagatorIfAbsent "tracecontext" w3cTraceContextPropagator
  _ <- Registry.registerTextMapPropagatorIfAbsent "baggage" w3cBaggagePropagator
  _ <- Registry.registerTextMapPropagatorIfAbsent "b3" b3TraceContextPropagator
  _ <- Registry.registerTextMapPropagatorIfAbsent "b3multi" b3MultiTraceContextPropagator
  _ <- Registry.registerTextMapPropagatorIfAbsent "datadog" datadogTraceContextPropagator
  _ <- Registry.registerTextMapPropagatorIfAbsent "jaeger" jaegerPropagator
  _ <- Registry.registerTextMapPropagatorIfAbsent "xray" xrayPropagator
  pure ()


{- | Stores the composite shutdown action from YAML-based initialization so
that 'withTracerProvider' and 'shutdownGlobalProviders' can shut down
meter + logger providers that were co-created alongside the tracer.
-}
globalExtraShutdown :: IORef (IO ())
globalExtraShutdown = unsafePerformIO $ newIORef (pure ())
{-# NOINLINE globalExtraShutdown #-}


{- | Shut down all providers that were registered via
'initializeGlobalTracerProvider' (YAML config path).

When the YAML config path is used, 'initializeGlobalTracerProvider' registers
the 'MeterProvider' and 'LoggerProvider' globally and stores their composite
shutdown. This function runs that shutdown after 'shutdownTracerProvider'.
-}
shutdownGlobalProviders :: TracerProvider -> IO ()
shutdownGlobalProviders tp = do
  _ <- shutdownTracerProvider tp
  extra <- atomicModifyIORef' globalExtraShutdown $ \act -> (pure (), act)
  extra


{- | Create a new 'TracerProvider' and set it as the global
 tracer provider.

 If @OTEL_CONFIG_FILE@ is set, the provider is configured from that
 YAML file (see "OpenTelemetry.Configuration").  Otherwise, configuration
 is pulled from individual @OTEL_*@ environment variables as documented
 in this module.

 When using YAML configuration, this also sets the global 'MeterProvider'
 and 'LoggerProvider' so that 'getGlobalMeterProvider' and
 'getGlobalLoggerProvider' return the YAML-configured providers.
 Shutdown of all three providers is coordinated automatically when using
 'withTracerProvider' or 'shutdownGlobalProviders'.

 Note however, that 3rd-party span processors, exporters, sampling strategies,
 etc. may have their own set of environment-based configuration values that they
 utilize.
-}
initializeGlobalTracerProvider :: IO TracerProvider
initializeGlobalTracerProvider = do
  mConfigComponents <- initializeFromConfigFile
  case mConfigComponents of
    Just components -> do
      let tp = otelTracerProvider components
      setGlobalTracerProvider tp
      setGlobalMeterProvider (otelMeterProvider components)
      setGlobalLoggerProvider (otelLoggerProvider components)
      atomicModifyIORef' globalExtraShutdown $ \_ ->
        ( do
            _ <- meterProviderShutdown (otelMeterProvider components)
            shutdownLoggerProvider (otelLoggerProvider components)
        , ()
        )
      pure tp
    Nothing -> do
      disabled <- lookupBooleanEnv "OTEL_SDK_DISABLED"
      t <- initializeTracerProvider
      setGlobalTracerProvider t
      if disabled
        then do
          lp <- createLoggerProvider [] emptyLoggerProviderOptions
          setGlobalLoggerProvider lp
          pure t
        else do
          lp <- initializeLoggerProvider
          setGlobalLoggerProvider lp
          atomicModifyIORef' globalExtraShutdown $ \_ ->
            (shutdownLoggerProvider lp, ())
          pure t


initializeTracerProvider :: IO TracerProvider
initializeTracerProvider = do
  (processors, opts) <- getTracerProviderInitializationOptions
  createTracerProvider processors opts


{- | Initialize the global 'TracerProvider', run an action, then shut down
the provider — including on @SIGTERM@ and @SIGINT@.

This is the recommended entry point for applications. It mirrors the
bracket pattern used by Go (@defer tp.Shutdown(ctx)@) and Python
(@atexit@) SDKs, and ensures in-flight spans are flushed on container
kills and Ctrl-C.

@
main :: IO ()
main = withTracerProvider $ \\tp -> do
  tracer <- getTracer tp "my-service" tracerOptions
  -- ... application code ...
@

=== How shutdown works

Shutdown relies on GHC's async-exception mechanism:

* __SIGINT__ (Ctrl-C): GHC's runtime already throws 'Control.Exception.UserInterrupt'
  to the main thread. 'bracket' catches it, @shutdownTracerProvider@ runs.
* __SIGTERM__ (container kill): By default the process terminates
  immediately with no cleanup. 'withTracerProvider' installs a handler
  that throws 'ShutdownBySignal' to the main thread, so 'bracket'
  catches it and @shutdownTracerProvider@ runs.

=== Signal handler caveats

On Unix, signal handlers are process-global and last-writer-wins.

* If you install your own @SIGTERM@ handler /after/ entering
  'withTracerProvider', the OTel handler is replaced and graceful
  shutdown on @SIGTERM@ will not happen automatically. You are then
  responsible for ensuring @shutdownTracerProvider@ is called.
* If another library installs a @SIGTERM@ handler (e.g. a web
  framework's graceful-stop hook), the same applies. In that case,
  use 'initializeGlobalTracerProvider' and 'shutdownTracerProvider'
  directly inside your own shutdown logic rather than
  'withTracerProvider'.
* @SIGINT@ is not touched — GHC's default @UserInterrupt@ handler is
  left in place.

If you need full control over signal handling, use the lower-level API:

@
main :: IO ()
main = bracket initializeGlobalTracerProvider shutdownTracerProvider $ \\tp -> do
  -- install your own signal handlers here
  ...
@

On Windows, signal handling is a no-op; shutdown runs only via the
normal 'bracket' path (exception or return).

@since 0.1.1.0
-}
withTracerProvider :: (TracerProvider -> IO a) -> IO a
withTracerProvider body = do
  mainTid <- myThreadId
  bracket
    ( do
        tp <- initializeGlobalTracerProvider
        oldHandler <- installSigtermHandler mainTid
        pure (tp, oldHandler)
    )
    ( \(tp, oldHandler) -> do
        restoreSigtermHandler oldHandler
        shutdownGlobalProviders tp
    )
    (\(tp, _) -> body tp)


{- | Thrown to the main thread when SIGTERM is received inside
'withTracerProvider'. Caught by 'bracket' to trigger graceful shutdown.
-}
data ShutdownBySignal = ShutdownBySignal
  deriving (Show)


instance Exception ShutdownBySignal

#if !defined(mingw32_HOST_OS)
installSigtermHandler :: ThreadId -> IO Handler
installSigtermHandler mainTid =
  installHandler sigTERM (CatchOnce (throwTo mainTid ShutdownBySignal)) Nothing


restoreSigtermHandler :: Handler -> IO ()
restoreSigtermHandler old = do
  _ <- installHandler sigTERM old Nothing
  pure ()
#else
installSigtermHandler :: ThreadId -> IO ()
installSigtermHandler _ = pure ()

restoreSigtermHandler :: () -> IO ()
restoreSigtermHandler _ = pure ()
#endif


getTracerProviderInitializationOptions :: IO ([SpanProcessor], TracerProviderOptions)
getTracerProviderInitializationOptions = getTracerProviderInitializationOptions' mempty


{- | Detect options for initializing a tracer provider from the app environment, taking additional supported resources as well.

 @since 0.0.3.1
-}
getTracerProviderInitializationOptions'
  :: Resource
  -> IO ([SpanProcessor], TracerProviderOptions)
getTracerProviderInitializationOptions' rs = do
  disabled <- lookupBooleanEnv "OTEL_SDK_DISABLED"
  -- Spec: propagators MUST still be configured even when the SDK is disabled
  propagators <- detectPropagators
  if disabled
    then pure ([], emptyTracerProviderOptions)
    else do
      sampler <- detectSampler
      attrLimits <- detectAttributeLimits
      spanLimits <- detectSpanLimits
      processorConf <- detectBatchProcessorConfig
      exporters <- detectExporters
      builtInRs <- detectBuiltInResources
      envVarRs <- mkResource . map Just <$> detectResourceAttributes
      -- Spec: OTEL_SERVICE_NAME takes precedence over ALL other sources for service.name
      mSvcName <- lookupEnv "OTEL_SERVICE_NAME"
      let svcOverride :: Resource
          svcOverride = case mSvcName of
            Nothing -> mempty
            Just sn -> mkResource ["service.name" .= T.pack sn]
          baseRs = mergeResources rs (envVarRs <> builtInRs)
          allRs = mergeResources svcOverride baseRs
      processors <- mapM (batchProcessor processorConf) exporters
      let providerOpts =
            emptyTracerProviderOptions
              { tracerProviderOptionsIdGenerator = defaultIdGenerator
              , tracerProviderOptionsSampler = sampler
              , tracerProviderOptionsAttributeLimits = attrLimits
              , tracerProviderOptionsSpanLimits = spanLimits
              , tracerProviderOptionsPropagators = propagators
              , tracerProviderOptionsResources = materializeResources allRs
              }
      pure (processors, providerOpts)


detectPropagators :: IO TextMapPropagator
detectPropagators = do
  registerBuiltinPropagators
  allPropagators <- Registry.registeredTextMapPropagators
  propagatorsInEnv <- fmap (map T.strip . T.splitOn "," . T.pack) <$> lookupEnv "OTEL_PROPAGATORS"
  propagator <-
    if propagatorsInEnv == Just ["none"]
      then pure mempty
      else do
        let envPropagators = nub $ fromMaybe ["tracecontext", "baggage"] propagatorsInEnv
            propagatorsAndRegistryEntry = map (\k -> maybe (Left k) Right $ H.lookup k allPropagators) envPropagators
            (notFound, propagators) = partitionEithers propagatorsAndRegistryEntry
        mapM_ (\k -> otelLogWarning $ "Unknown propagator '" <> T.unpack k <> "' in OTEL_PROPAGATORS, ignoring") notFound
        pure $ mconcat propagators
  setGlobalTextMapPropagator propagator
  pure propagator


knownSamplers :: [(T.Text, Maybe T.Text -> Maybe Sampler)]
knownSamplers =
  [ ("always_on", const $ pure alwaysOn)
  , ("always_off", const $ pure alwaysOff)
  ,
    ( "traceidratio"
    , \case
        Nothing -> Nothing
        Just val -> case TR.rational val of
          Right (ratioVal, _) -> pure $ traceIdRatioBased ratioVal
          Left _ -> Nothing
    )
  , ("parentbased_always_on", const $ pure $ parentBased $ parentBasedOptions alwaysOn)
  , ("parentbased_always_off", const $ pure $ parentBased $ parentBasedOptions alwaysOff)
  ,
    ( "parentbased_traceidratio"
    , \case
        Nothing -> Nothing
        Just val -> case TR.rational val of
          Right (ratioVal, _) -> pure $ parentBased $ parentBasedOptions $ traceIdRatioBased ratioVal
          Left _ -> Nothing
    )
  ]


{- | Detect a sampler from the app environment. If no sampler is specified,
 the parentbased sampler is used.

 @since 0.0.3.3
-}
detectSampler :: IO Sampler
detectSampler = do
  envSampler <- lookupEnv "OTEL_TRACES_SAMPLER"
  envArg <- lookupEnv "OTEL_TRACES_SAMPLER_ARG"
  case envSampler of
    Nothing -> pure (parentBased $ parentBasedOptions alwaysOn)
    Just samplerName -> case lookup (T.pack samplerName) knownSamplers of
      Nothing -> do
        otelLogWarning $ "Unknown sampler '" <> samplerName <> "', falling back to parentbased_always_on"
        pure (parentBased $ parentBasedOptions alwaysOn)
      Just ctor -> case ctor (T.pack <$> envArg) of
        Nothing -> do
          otelLogWarning $ "Invalid OTEL_TRACES_SAMPLER_ARG for sampler '" <> samplerName <> "', falling back to parentbased_always_on"
          pure (parentBased $ parentBasedOptions alwaysOn)
        Just sampler -> pure sampler


detectBatchProcessorConfig :: IO BatchTimeoutConfig
detectBatchProcessorConfig =
  BatchTimeoutConfig
    <$> readEnvDefault "OTEL_BSP_MAX_QUEUE_SIZE" (maxQueueSize batchTimeoutConfig)
    <*> readEnvDefault "OTEL_BSP_SCHEDULE_DELAY" (scheduledDelayMillis batchTimeoutConfig)
    <*> readEnvDefault "OTEL_BSP_EXPORT_TIMEOUT" (exportTimeoutMillis batchTimeoutConfig)
    <*> readEnvDefault "OTEL_BSP_MAX_EXPORT_BATCH_SIZE" (maxExportBatchSize batchTimeoutConfig)


detectAttributeLimits :: IO AttributeLimits
detectAttributeLimits =
  AttributeLimits
    <$> readEnvDefault "OTEL_ATTRIBUTE_COUNT_LIMIT" (attributeCountLimit defaultAttributeLimits)
    <*> ((>>= readMaybe) <$> lookupEnv "OTEL_ATTRIBUTE_VALUE_LENGTH_LIMIT")


detectSpanLimits :: IO SpanLimits
detectSpanLimits =
  SpanLimits
    <$> readEnv "OTEL_SPAN_ATTRIBUTE_VALUE_LENGTH_LIMIT"
    <*> readEnv "OTEL_SPAN_ATTRIBUTE_COUNT_LIMIT"
    <*> readEnv "OTEL_SPAN_EVENT_COUNT_LIMIT"
    <*> readEnv "OTEL_EVENT_ATTRIBUTE_COUNT_LIMIT"
    <*> readEnv "OTEL_SPAN_LINK_COUNT_LIMIT"
    <*> readEnv "OTEL_LINK_ATTRIBUTE_COUNT_LIMIT"


registerBuiltinExporters :: IO ()
registerBuiltinExporters = do
  _ <-
    Registry.registerSpanExporterFactoryIfAbsent "otlp" $ do
      otlpConfig <- loadExporterEnvironmentVariables
      otlpExporter otlpConfig
  pure ()


detectExporters :: IO [SpanExporter]
detectExporters = do
  registerBuiltinExporters
  allExporters <- Registry.registeredSpanExporterFactories
  exportersInEnv <- fmap (map T.strip . T.splitOn "," . T.pack) <$> lookupEnv "OTEL_TRACES_EXPORTER"
  if exportersInEnv == Just ["none"]
    then pure []
    else do
      let envExporters = fromMaybe ["otlp"] exportersInEnv
          exportersAndRegistryEntry = map (\k -> maybe (Left k) Right $ H.lookup k allExporters) envExporters
          (notFound, exporterInitializers) = partitionEithers exportersAndRegistryEntry
      mapM_ (\k -> otelLogWarning $ "Unknown exporter '" <> T.unpack k <> "' in OTEL_TRACES_EXPORTER, ignoring") notFound
      sequence exporterInitializers


-- Log provider initialization (env-var path) ---------------------------------

initializeLoggerProvider :: IO LoggerProvider
initializeLoggerProvider = do
  sel <- lookupLogsExporterSelection
  case sel of
    Just LogsExporterNone -> createLoggerProvider [] emptyLoggerProviderOptions
    _ -> do
      exporter <- detectLogExporter sel
      blrpConf <- detectBatchLogProcessorConfig exporter
      processor <- batchLogRecordProcessor blrpConf
      createLoggerProvider [processor] emptyLoggerProviderOptions


detectLogExporter :: Maybe LogsExporterSelection -> IO LogRecordExporter
detectLogExporter sel = do
  registerBuiltinLogExporters
  case sel of
    Just LogsExporterConsole -> stdoutLogRecordExporter
    _ -> do
      allExporters <- Registry.registeredLogRecordExporterFactories
      case H.lookup "otlp" allExporters of
        Just factory -> factory
        Nothing -> do
          otelLogWarning "No OTLP log exporter registered, using console"
          stdoutLogRecordExporter


registerBuiltinLogExporters :: IO ()
registerBuiltinLogExporters = do
  _ <-
    Registry.registerLogRecordExporterFactoryIfAbsent "otlp" $ do
      otlpConfig <- loadExporterEnvironmentVariables
      otlpLogRecordExporter otlpConfig
  _ <-
    Registry.registerLogRecordExporterFactoryIfAbsent
      "console"
      stdoutLogRecordExporter
  pure ()


detectBatchLogProcessorConfig :: LogRecordExporter -> IO BatchLogRecordProcessorConfig
detectBatchLogProcessorConfig exporter =
  BatchLogRecordProcessorConfig exporter
    <$> readEnvDefault "OTEL_BLRP_MAX_QUEUE_SIZE" 2048
    <*> readEnvDefault "OTEL_BLRP_SCHEDULE_DELAY" 1000
    <*> readEnvDefault "OTEL_BLRP_EXPORT_TIMEOUT" 30000
    <*> readEnvDefault "OTEL_BLRP_MAX_EXPORT_BATCH_SIZE" 512


detectResourceAttributes :: IO [(T.Text, Attribute)]
detectResourceAttributes = do
  mEnv <- lookupEnv "OTEL_RESOURCE_ATTRIBUTES"
  case mEnv of
    Nothing -> pure []
    Just envVar -> case decodeBaggageHeader $ B.pack envVar of
      Left err -> do
        otelLogError $ "Failed to parse OTEL_RESOURCE_ATTRIBUTES: " <> err
        pure []
      Right ok ->
        pure $
          map (\(k, v) -> (decodeUtf8 $ Baggage.tokenValue k, toAttribute $ Baggage.value v)) $
            H.toList $
              Baggage.values ok


readEnvDefault :: forall a. (Read a) => String -> a -> IO a
readEnvDefault k defaultValue =
  fromMaybe defaultValue . (>>= readMaybe) <$> lookupEnv k


readEnv :: forall a. (Read a) => String -> IO (Maybe a)
readEnv k = (>>= readMaybe) <$> lookupEnv k


{- | Register all built-in resource detectors in the global registry.

Each detector is registered under a short name using 'IfAbsent' so that
user registrations (made before SDK init) take precedence.

Detector names:

* @service@ — service name, version, instance ID from env vars
* @telemetry@ — SDK name\/language\/version from build info
* @process@ — PID, executable, command args
* @process_runtime@ — runtime name\/version
* @os@ — operating system type
* @host@ — hostname and CPU architecture
* @container@ — container ID and runtime from \/proc
* @cloud@ — cloud provider\/platform\/region from env vars
* @faas@ — serverless function attributes from env vars
* @kubernetes@ — k8s cluster\/namespace\/pod from env vars and SA token
* @aws_ecs@ — ECS task metadata endpoint (HTTP)
* @aws_ec2@ — EC2 IMDS (HTTP)
* @aws_eks@ — EKS detection via Kubernetes API (HTTPS, in-cluster CA)
* @gcp@ — GCP metadata server (HTTP); detects GKE via cluster-name attribute
* @azure_vm@ — Azure IMDS (HTTP); detects AKS when in Kubernetes
* @heroku@ — Heroku dyno metadata from env vars

@since 0.1.0.2
-}
registerBuiltinResourceDetectors :: IO ()
registerBuiltinResourceDetectors = do
  _ <- Registry.registerResourceDetectorIfAbsent "service" (toResource <$> detectService)
  _ <- Registry.registerResourceDetectorIfAbsent "telemetry" (pure $ toResource detectTelemetry)
  _ <- Registry.registerResourceDetectorIfAbsent "process_runtime" (pure $ toResource detectProcessRuntime)
  _ <- Registry.registerResourceDetectorIfAbsent "process" (toResource <$> detectProcess)
  _ <- Registry.registerResourceDetectorIfAbsent "os" (toResource <$> detectOperatingSystem)
  _ <- Registry.registerResourceDetectorIfAbsent "host" (toResource <$> detectHost)
  _ <- Registry.registerResourceDetectorIfAbsent "container" (toResource <$> detectContainer)
  _ <- Registry.registerResourceDetectorIfAbsent "cloud" (toResource <$> detectCloud)
  _ <- Registry.registerResourceDetectorIfAbsent "faas" (mergeOptionalFaaS <$> detectFaaS)
  _ <- Registry.registerResourceDetectorIfAbsent "kubernetes" (mergeOptionalK8s <$> detectKubernetes)
  _ <- Registry.registerResourceDetectorIfAbsent "aws_ecs" detectECSSelf
  _ <- Registry.registerResourceDetectorIfAbsent "aws_ec2" detectEC2Self
  _ <- Registry.registerResourceDetectorIfAbsent "aws_eks" detectEKSSelf
  _ <- Registry.registerResourceDetectorIfAbsent "gcp" detectGCPComputeSelf
  _ <- Registry.registerResourceDetectorIfAbsent "azure_vm" detectAzureVMSelf
  _ <- Registry.registerResourceDetectorIfAbsent "heroku" detectHeroku
  pure ()


{- | Use all registered resource detectors to populate resource information.

Reads the @OTEL_RESOURCE_DETECTORS@ environment variable (comma-separated
list of detector names) to control which detectors run.  The special value
@all@ (the default) runs every registered detector.

Resource detectors are registered via 'registerBuiltinResourceDetectors'
(called automatically during SDK initialization) and can be extended with
'Registry.registerResourceDetector' before calling
'initializeGlobalTracerProvider'.

@since 0.0.1.0
-}
detectBuiltInResources :: IO Resource
detectBuiltInResources = do
  registerBuiltinResourceDetectors
  allDetectors <- Registry.registeredResourceDetectors
  mFilter <- lookupEnv "OTEL_RESOURCE_DETECTORS"
  let activeDetectors = case mFilter of
        Nothing -> H.elems allDetectors
        Just filterStr ->
          let names = fmap T.strip $ T.splitOn "," $ T.pack filterStr
          in if names == ["all"]
              then H.elems allDetectors
              else
                let pick acc name = case H.lookup name allDetectors of
                      Just d -> d : acc
                      Nothing -> acc
                in foldl' pick [] names
  resources <- mapM runDetectorSafely activeDetectors
  pure $ foldl' mergeResources (mkResource []) resources
  where
    runDetectorSafely :: IO Resource -> IO Resource
    runDetectorSafely detector =
      detector `catch` \(_ex :: SomeException) -> do
        otelLogDebug "Resource detector failed, skipping"
        pure (mkResource [])


mergeOptionalFaaS :: Maybe FaaS -> Resource
mergeOptionalFaaS Nothing = emptyResource
mergeOptionalFaaS (Just faas) = toResource faas


mergeOptionalK8s :: Maybe KubernetesResources -> Resource
mergeOptionalK8s Nothing = emptyResource
mergeOptionalK8s (Just KubernetesResources {..}) =
  toResource (k8sCluster :: Cluster)
    `mergeResources` toResource (k8sNamespace :: Namespace)
    `mergeResources` toResource (k8sNode :: Node)
    `mergeResources` toResource (k8sPod :: Pod)


emptyResource :: Resource
emptyResource = mkResource []
