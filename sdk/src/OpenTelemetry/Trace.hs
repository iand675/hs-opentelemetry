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
Copyright   :  (c) Ian Duncan, 2021-2026
License     :  BSD-3
Description :  Application tracing setup and initialization
Maintainer  :  Ian Duncan
Stability   :  experimental
Portability :  non-portable (GHC extensions)

= Getting started

This is the main entry point for adding distributed tracing to your Haskell
application. Here is a complete minimal example:

@
{\-# LANGUAGE OverloadedStrings #-\}
module Main where

import OpenTelemetry.Trace

main :: IO ()
main = withTracerProvider $ \tp -> do
  tracer <- getTracer tp "my-service" tracerOptions
  inSpan tracer "main" defaultSpanArguments $ do
    putStrLn "Hello, traced world!"
@

That's it! 'withTracerProvider' reads configuration from environment variables,
sets up processors and exporters, and ensures everything is flushed on shutdown
(including @SIGTERM@). 'getTracer' creates a 'Tracer' scoped to your service,
and 'inSpan' wraps your code in a trace span.

= What you get out of the box

* __OTLP export__: Spans are exported via OTLP (to an OpenTelemetry Collector or
  any OTLP-compatible backend) by default. Set @OTEL_EXPORTER_OTLP_ENDPOINT@ to
  point at your collector.
* __Batch processing__: Spans are batched for efficient export.
* __W3C propagation__: @traceparent@ and @baggage@ headers are propagated automatically.
* __Resource detection__: Host, OS, process, container, and cloud metadata are
  auto-detected and attached to every span.
* __Sampling__: Parent-based always-on sampling by default; configurable via
  @OTEL_TRACES_SAMPLER@.
* __YAML configuration__: Set @OTEL_CONFIG_FILE@ to configure all providers from
  a single file (see "OpenTelemetry.Configuration").

= Creating spans in your code

@
-- Simple: wrap an action
inSpan tracer "myOperation" defaultSpanArguments $ do
  doSomething

-- With span access: add attributes during execution
inSpan' tracer "fetchUser" defaultSpanArguments $ \span -> do
  user <- lookupUser uid
  addAttribute span "user.id" (toAttribute uid)
  pure user

-- With custom span kind (e.g. for HTTP clients):
let args = defaultSpanArguments { kind = Client }
inSpan tracer "GET /api/users" args $ do
  httpRequest ...
@

= Adding instrumentation to libraries

Pre-built instrumentation is available for common libraries:

* @hs-opentelemetry-instrumentation-wai@ : WAI middleware
* @hs-opentelemetry-instrumentation-http-client@ : HTTP client requests
* @hs-opentelemetry-instrumentation-persistent@ : Database queries (Persistent)
* @hs-opentelemetry-instrumentation-yesod@ : Yesod web framework
* @hs-opentelemetry-instrumentation-conduit@ : Conduit pipelines

See <https://hackage.haskell.org/packages/search?terms=hs-opentelemetry-instrumentation Hackage>
for the full list.

= Monadic interface

For cleaner code in a monad stack, see "OpenTelemetry.Trace.Monad" which
provides 'MonadTracer'-based variants that obtain the 'Tracer' from your
environment automatically.

= Spec reference

<https://opentelemetry.io/docs/specs/otel/trace/api/>
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
  detectBatchProcessorConfig,
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

  -- * SDK diagnostic output
  setGlobalErrorHandler,
  getGlobalErrorHandler,
) where

import Control.Concurrent (ThreadId, myThreadId)
import Control.Exception (Exception, bracket, throwTo)
import Control.Monad (when)
import Data.Either (partitionEithers)
import qualified Data.HashMap.Strict as H
import Data.IORef (IORef, atomicModifyIORef', newIORef)
import Data.List (nub)
import Data.Maybe (fromMaybe)
import qualified Data.Text as T
import qualified Data.Text.Read as TR
import OpenTelemetry.Attributes (AttributeLimits (..), defaultAttributeLimits)
import OpenTelemetry.Attributes.Key (unkey)
import OpenTelemetry.Configuration (OTelComponents (..), initializeFromConfigFile)
import OpenTelemetry.Environment
import OpenTelemetry.Exporter.OTLP.Span (loadExporterEnvironmentVariables, otlpExporter)
import OpenTelemetry.Exporter.Span (SpanExporter)
import OpenTelemetry.Internal.Logging (getGlobalErrorHandler, otelLogWarning, setGlobalErrorHandler)
import OpenTelemetry.Log (initializeGlobalLoggerProvider)
import OpenTelemetry.Log.Core (setGlobalLoggerProvider, shutdownLoggerProvider)
import OpenTelemetry.Metric.Core (MeterProvider (..), setGlobalMeterProvider)
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
import OpenTelemetry.Resource.Detect (detectBuiltInResources, detectResourceAttributes, registerBuiltinResourceDetectors)
import qualified OpenTelemetry.SemanticConventions as SC
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

=== Step 1: Initialize

@
main :: IO ()
main = withTracerProvider $ \tp -> do
  ...
@

'withTracerProvider' handles setup and teardown. It reads @OTEL_*@ environment
variables, starts batch processors, installs a SIGTERM handler for graceful
shutdown, and flushes pending spans when your application exits.

=== Step 2: Get a Tracer

@
tracer <- getTracer tp "my-service" tracerOptions
@

The first argument is your 'TracerProvider'. The second is the name of your
service or library (this appears in trace data). 'tracerOptions' provides
defaults.

=== Step 3: Instrument your code

@
inSpan tracer "handleRequest" defaultSpanArguments $ do
  -- your code here
  pure result
@

=== Step 4: Add pre-built instrumentation

Install instrumentation packages for the libraries you use (WAI, http-client,
persistent, etc.). These automatically create spans for HTTP requests, database
queries, and other operations.
-}


{- $tracerProvider

A 'TracerProvider' holds the configuration for how spans are processed and
exported. You typically create one at application startup and shut it down on
exit.

=== Recommended: bracket-style

@
main :: IO ()
main = withTracerProvider $ \tp -> do
  tracer <- getTracer tp "my-service" tracerOptions
  -- ... your application ...
@

'withTracerProvider' handles SIGTERM, flushes in-flight spans, and shuts down
all co-created providers (logs, metrics) automatically.

=== Manual: init + shutdown

@
main :: IO ()
main = do
  tp <- initializeGlobalTracerProvider
  tracer <- getTracer tp "my-service" tracerOptions
  -- ... your application ...
  shutdownTracerProvider tp Nothing
@

Use the manual approach when you need to integrate with your own signal
handling or lifecycle management.
-}


{- $envGeneral

=== General

* @OTEL_SDK_DISABLED@ (default: @false@) — if @"true"@, a no-op SDK is used
  for all signals. Propagators configured via @OTEL_PROPAGATORS@ still work.
* @OTEL_CONFIG_FILE@ / @OTEL_EXPERIMENTAL_CONFIG_FILE@ — path to a YAML
  configuration file. When set, all providers are configured from the file
  (see "OpenTelemetry.Configuration"). @OTEL_SDK_DISABLED@ takes precedence.
* @OTEL_RESOURCE_ATTRIBUTES@ — comma-separated key=value pairs for resource
  attributes.
* @OTEL_SERVICE_NAME@ — sets @service.name@; takes precedence over
  @OTEL_RESOURCE_ATTRIBUTES@.
* @OTEL_RESOURCE_DETECTORS@ — comma-separated list of resource detector names
  (default: all built-in detectors).
* @OTEL_LOG_LEVEL@ (default: @"info"@) — internal SDK log level.
* @OTEL_SEMCONV_STABILITY_OPT_IN@ — controls semantic convention migration.
  Values: @"code"@ (stable names), @"code\/dup"@ (both old and stable).

=== Traces

* @OTEL_TRACES_EXPORTER@ (default: @"otlp"@) — exporter name. Values:
  @"otlp"@, @"console"@, @"none"@. Custom exporters can be registered
  via "OpenTelemetry.Registry".
* @OTEL_PROPAGATORS@ (default: @"tracecontext,baggage"@) — comma-separated
  list of propagator names. Values MUST be deduplicated.
* @OTEL_TRACES_SAMPLER@ (default: @"parentbased_always_on"@) — sampler name.
  Matched case-insensitively. See
  <https://opentelemetry.io/docs/specs/otel/trace/sdk/#sampling>.
* @OTEL_TRACES_SAMPLER_ARG@ — sampler argument (e.g. ratio for
  @trace_id_ratio_based@). Only used when @OTEL_TRACES_SAMPLER@ is set.
-}


{- $envBsp

* @OTEL_BSP_SCHEDULE_DELAY_MILLIS@ (default: @5000@) — delay between
  consecutive exports, in milliseconds. Legacy alias: @OTEL_BSP_SCHEDULE_DELAY@.
* @OTEL_BSP_EXPORT_TIMEOUT_MILLIS@ (default: @30000@) — maximum time for a
  single export, in milliseconds. Legacy alias: @OTEL_BSP_EXPORT_TIMEOUT@.
* @OTEL_BSP_MAX_QUEUE_SIZE@ (default: @2048@) — maximum number of spans in the
  queue.
* @OTEL_BSP_MAX_EXPORT_BATCH_SIZE@ (default: @512@) — maximum batch size per
  export. Clamped to @OTEL_BSP_MAX_QUEUE_SIZE@ if larger.
-}


{- $envAttributeLimits

* @OTEL_ATTRIBUTE_VALUE_LENGTH_LIMIT@ (default: no limit) — maximum allowed
  attribute value size. Empty value is treated as infinity.
* @OTEL_ATTRIBUTE_COUNT_LIMIT@ (default: @128@) — maximum allowed attribute
  count per span.
-}


{- $envSpanLimits

These override the general @OTEL_ATTRIBUTE_*@ limits for spans specifically:

* @OTEL_SPAN_ATTRIBUTE_VALUE_LENGTH_LIMIT@ (default: no limit) — max attribute
  value size on spans.
* @OTEL_SPAN_ATTRIBUTE_COUNT_LIMIT@ (default: @128@) — max attribute count per
  span.
* @OTEL_SPAN_EVENT_COUNT_LIMIT@ (default: @128@) — max events per span.
* @OTEL_SPAN_LINK_COUNT_LIMIT@ (default: @128@) — max links per span.
* @OTEL_EVENT_ATTRIBUTE_COUNT_LIMIT@ (default: @128@) — max attributes per
  span event.
* @OTEL_LINK_ATTRIBUTE_COUNT_LIMIT@ (default: @128@) — max attributes per span
  link.
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

@since 0.0.1.0
-}
shutdownGlobalProviders :: TracerProvider -> IO ()
shutdownGlobalProviders tp = do
  _ <- shutdownTracerProvider tp Nothing
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

@since 0.0.1.0
-}
initializeGlobalTracerProvider :: IO TracerProvider
initializeGlobalTracerProvider = do
  disabled <- lookupBooleanEnv "OTEL_SDK_DISABLED"
  if disabled
    then do
      -- Spec: OTEL_SDK_DISABLED overrides all configuration including config files.
      -- Propagators MUST still be configured (see 'getTracerProviderInitializationOptions').
      t <- initializeTracerProvider
      setGlobalTracerProvider t
      _ <- initializeGlobalLoggerProvider
      pure t
    else do
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
                _ <- shutdownLoggerProvider (otelLoggerProvider components) Nothing
                pure ()
            , ()
            )
          pure tp
        Nothing -> do
          t <- initializeTracerProvider
          setGlobalTracerProvider t
          lp <- initializeGlobalLoggerProvider
          atomicModifyIORef' globalExtraShutdown $ \_ ->
            ( do
                _ <- shutdownLoggerProvider lp Nothing
                pure ()
            , ()
            )
          pure t


-- | @since 0.0.1.0
initializeTracerProvider :: IO TracerProvider
initializeTracerProvider = do
  (processors, opts) <- getTracerProviderInitializationOptions
  createTracerProvider processors opts


{- | Initialize the global 'TracerProvider', run an action, then shut down
the provider, including on @SIGTERM@ and @SIGINT@.

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
* @SIGINT@ is not touched. GHC's default @UserInterrupt@ handler is
  left in place.

If you need full control over signal handling, use the lower-level API:

@
main :: IO ()
main = bracket initializeGlobalTracerProvider (\\tp -> shutdownTracerProvider tp Nothing >> pure ()) $ \\tp -> do
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


-- | @since 0.0.1.0
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
    then pure ([], emptyTracerProviderOptions {tracerProviderOptionsPropagators = propagators})
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
            Just sn -> mkResource [unkey SC.service_name .= T.pack sn]
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
  rawPropEnv <- lookupEnv "OTEL_PROPAGATORS"
  let propagatorsInEnv = case rawPropEnv of
        Nothing -> Nothing
        Just "" -> Nothing
        Just v -> Just $ filter (not . T.null) $ map T.strip $ T.splitOn "," $ T.pack v
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
    Just samplerName -> case lookup (T.toLower $ T.pack samplerName) knownSamplers of
      Nothing -> do
        otelLogWarning $ "Unknown sampler '" <> samplerName <> "', falling back to parentbased_always_on"
        pure (parentBased $ parentBasedOptions alwaysOn)
      Just ctor -> case ctor (T.pack <$> envArg) of
        Nothing -> do
          otelLogWarning $ "Invalid OTEL_TRACES_SAMPLER_ARG for sampler '" <> samplerName <> "', falling back to parentbased_always_on"
          pure (parentBased $ parentBasedOptions alwaysOn)
        Just sampler -> pure sampler


-- | @since 0.0.1.0
detectBatchProcessorConfig :: IO BatchTimeoutConfig
detectBatchProcessorConfig = do
  queueSize <- readEnvDefault "OTEL_BSP_MAX_QUEUE_SIZE" (maxQueueSize batchTimeoutConfig)
  delay <- readEnvDefaultWithAlias "OTEL_BSP_SCHEDULE_DELAY_MILLIS" "OTEL_BSP_SCHEDULE_DELAY" (scheduledDelayMillis batchTimeoutConfig)
  exportTimeout <- readEnvDefaultWithAlias "OTEL_BSP_EXPORT_TIMEOUT_MILLIS" "OTEL_BSP_EXPORT_TIMEOUT" (exportTimeoutMillis batchTimeoutConfig)
  rawBatchSize <- readEnvDefault "OTEL_BSP_MAX_EXPORT_BATCH_SIZE" (maxExportBatchSize batchTimeoutConfig)
  let batchSize = min rawBatchSize queueSize
  when (rawBatchSize > queueSize) $
    otelLogWarning ("OTEL_BSP_MAX_EXPORT_BATCH_SIZE (" <> show rawBatchSize <> ") exceeds OTEL_BSP_MAX_QUEUE_SIZE (" <> show queueSize <> "), clamping to " <> show batchSize)
  pure (BatchTimeoutConfig queueSize delay exportTimeout batchSize)


detectAttributeLimits :: IO AttributeLimits
detectAttributeLimits =
  AttributeLimits
    <$> readEnvDefault "OTEL_ATTRIBUTE_COUNT_LIMIT" (attributeCountLimit defaultAttributeLimits)
    <*> ((>>= readMaybe) <$> lookupEnv "OTEL_ATTRIBUTE_VALUE_LENGTH_LIMIT")


-- | @since 0.0.1.0
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
  rawExpEnv <- lookupEnv "OTEL_TRACES_EXPORTER"
  let exportersInEnv = case rawExpEnv of
        Nothing -> Nothing
        Just "" -> Nothing
        Just v -> Just $ filter (not . T.null) $ map T.strip $ T.splitOn "," $ T.pack v
  if exportersInEnv == Just ["none"]
    then pure []
    else do
      let envExporters = fromMaybe ["otlp"] exportersInEnv
          exportersAndRegistryEntry = map (\k -> maybe (Left k) Right $ H.lookup k allExporters) envExporters
          (notFound, exporterInitializers) = partitionEithers exportersAndRegistryEntry
      mapM_ (\k -> otelLogWarning $ "Unknown exporter '" <> T.unpack k <> "' in OTEL_TRACES_EXPORTER, ignoring") notFound
      sequence exporterInitializers


readEnvDefault :: forall a. (Read a) => String -> a -> IO a
readEnvDefault k defaultValue =
  fromMaybe defaultValue . (>>= readMaybe) <$> lookupEnv k


readEnvDefaultWithAlias :: forall a. (Read a) => String -> String -> a -> IO a
readEnvDefaultWithAlias primary fallback defaultValue = do
  mv <- lookupEnv primary
  case mv >>= readMaybe of
    Just v -> pure v
    Nothing -> readEnvDefault fallback defaultValue


readEnv :: forall a. (Read a) => String -> IO (Maybe a)
readEnv k = (>>= readMaybe) <$> lookupEnv k
