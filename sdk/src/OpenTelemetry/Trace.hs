{-# LANGUAGE DataKinds #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE TypeOperators #-}

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

  -- * 'TracerProvider' operations
  -- $tracerProvider
  TracerProvider,
  initializeGlobalTracerProvider,
  initializeTracerProvider,
  getTracerProviderInitializationOptions,
  getTracerProviderInitializationOptions',
  shutdownTracerProvider,

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

  -- * 'Span' operations
  Span,
  inSpan,
  defaultSpanArguments,
  SpanArguments (..),
  SpanKind (..),
  NewLink (..),
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

  -- * Primitive span and tracing operations

  -- ** Alternative 'TracerProvider' initialization
  createTracerProvider,
  TracerProviderOptions (..),
  emptyTracerProviderOptions,
  detectBuiltInResources,
  detectSampler,
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
  -- TODO, don't remember if this is okay with the spec or not
  ImmutableSpan (..),
) where

import qualified Data.ByteString.Char8 as B
import Data.Either (partitionEithers)
import qualified Data.HashMap.Strict as H
import Data.Maybe (fromMaybe)
import qualified Data.Text as T
import Data.Text.Encoding (decodeUtf8)
import Network.HTTP.Types.Header
import OpenTelemetry.Attributes (AttributeLimits (..), defaultAttributeLimits)
import OpenTelemetry.Baggage (decodeBaggageHeader)
import qualified OpenTelemetry.Baggage as Baggage
import OpenTelemetry.Context (Context)
import OpenTelemetry.Propagator (Propagator)
import OpenTelemetry.Propagator.B3 (b3MultiTraceContextPropagator, b3TraceContextPropagator)
import OpenTelemetry.Propagator.Datadog (datadogTraceContextPropagator)
import OpenTelemetry.Propagator.W3CBaggage (w3cBaggagePropagator)
import OpenTelemetry.Propagator.W3CTraceContext (w3cTraceContextPropagator)
import OpenTelemetry.Resource
import OpenTelemetry.Resource.Host.Detector (detectHost)
import OpenTelemetry.Resource.OperatingSystem.Detector (detectOperatingSystem)
import OpenTelemetry.Resource.Process.Detector (detectProcess, detectProcessRuntime)
import OpenTelemetry.Resource.Service.Detector (detectService)
import OpenTelemetry.Resource.Telemetry.Detector (detectTelemetry)
import OpenTelemetry.SpanExporter (SpanExporter)
import OpenTelemetry.SpanExporter.OTLP (loadExporterEnvironmentVariables, otlpExporter)
import OpenTelemetry.SpanProcessor (SpanProcessor)
import OpenTelemetry.SpanProcessor.Batch (BatchTimeoutConfig (..), batchProcessor, batchTimeoutConfig)
import OpenTelemetry.Trace.Core
import OpenTelemetry.Trace.Id.Generator.Default (defaultIdGenerator)
import OpenTelemetry.Trace.Sampler (Sampler, alwaysOff, alwaysOn, parentBased, parentBasedOptions, traceIdRatioBased)
import System.Environment (lookupEnv)
import Text.Read (readMaybe)


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

 +---------------------------+---------------------------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
 | Name                      | Description                                                                                                   | Default                                                                                                                                        | Notes                                                                                                                                                                                                                                                                          |
 +===========================+===============================================================================================================+================================================================================================================================================+================================================================================================================================================================================================================================================================================+
 | OTEL_RESOURCE_ATTRIBUTES  | Key-value pairs to be used as resource attributes                                                             | See [Resource semantic conventions](resource/semantic_conventions/README.md#semantic-attributes-with-sdk-provided-default-value) for details.  | See [Resource SDK](./resource/sdk.md#specifying-resource-information-via-an-environment-variable) for more details.                                                                                                                                                            |
 +---------------------------+---------------------------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
 | OTEL_SERVICE_NAME         | Sets the value of the [`service.name`](./resource/semantic_conventions/README.md#service) resource attribute  |                                                                                                                                                | If `service.name` is also provided in `OTEL_RESOURCE_ATTRIBUTES`, then `OTEL_SERVICE_NAME` takes precedence.                                                                                                                                                                   |
 +---------------------------+---------------------------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
 | OTEL_LOG_LEVEL            | Log level used by the SDK logger                                                                              | "info"                                                                                                                                         |                                                                                                                                                                                                                                                                                |
 +---------------------------+---------------------------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
 | OTEL_PROPAGATORS          | Propagators to be used as a comma-separated list                                                              | "tracecontext,baggage"                                                                                                                         | Values MUST be deduplicated in order to register a `Propagator` only once.                                                                                                                                                                                                     |
 +---------------------------+---------------------------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
 | OTEL_TRACES_SAMPLER       | Sampler to be used for traces                                                                                 | "parentbased_always_on"                                                                                                                        | See [Sampling](./trace/sdk.md#sampling)                                                                                                                                                                                                                                        |
 +---------------------------+---------------------------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
 | OTEL_TRACES_SAMPLER_ARG   | String value to be used as the sampler argument                                                               |                                                                                                                                                | The specified value will only be used if OTEL_TRACES_SAMPLER is set. Each Sampler type defines its own expected input, if any. Invalid or unrecognized input MUST be logged and MUST be otherwise ignored, i.e. the SDK MUST behave as if OTEL_TRACES_SAMPLER_ARG is not set.  |
 +---------------------------+---------------------------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
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


knownPropagators :: [(T.Text, Propagator Context RequestHeaders ResponseHeaders)]
knownPropagators =
  [ ("tracecontext", w3cTraceContextPropagator)
  , ("baggage", w3cBaggagePropagator)
  , ("b3", b3TraceContextPropagator)
  , ("b3multi", b3MultiTraceContextPropagator)
  , ("datadog", datadogTraceContextPropagator)
  , ("jaeger", error "Jaeger not yet implemented")
  ]


-- TODO, actually implement a registry systme
readRegisteredPropagators :: IO [(T.Text, Propagator Context RequestHeaders ResponseHeaders)]
readRegisteredPropagators = pure knownPropagators


{- | Create a new 'TracerProvider' and set it as the global
 tracer provider. This pulls all configuration from environment
 variables. The full list of environment variables supported is
 specified in the configuration section of this module's documentation.

 Note however, that 3rd-party span processors, exporters, sampling strategies,
 etc. may have their own set of environment-based configuration values that they
 utilize.
-}
initializeGlobalTracerProvider :: IO TracerProvider
initializeGlobalTracerProvider = do
  t <- initializeTracerProvider
  setGlobalTracerProvider t
  pure t


initializeTracerProvider :: IO TracerProvider
initializeTracerProvider = do
  (processors, opts) <- getTracerProviderInitializationOptions
  createTracerProvider processors opts


getTracerProviderInitializationOptions :: IO ([SpanProcessor], TracerProviderOptions)
getTracerProviderInitializationOptions = getTracerProviderInitializationOptions' (mempty :: Resource 'Nothing)


{- | Detect options for initializing a tracer provider from the app environment, taking additional supported resources as well.

 @since 0.0.3.1
-}
getTracerProviderInitializationOptions' :: (ResourceMerge 'Nothing any ~ 'Nothing) => Resource any -> IO ([SpanProcessor], TracerProviderOptions)
getTracerProviderInitializationOptions' rs = do
  sampler <- detectSampler
  attrLimits <- detectAttributeLimits
  spanLimits <- detectSpanLimits
  propagators <- detectPropagators
  processorConf <- detectBatchProcessorConfig
  exporters <- detectExporters
  builtInRs <- detectBuiltInResources
  envVarRs <- mkResource . map Just <$> detectResourceAttributes
  let allRs = mergeResources (builtInRs <> envVarRs) rs
  processors <- case exporters of
    [] -> do
      pure []
    e : _ -> do
      pure <$> batchProcessor processorConf e
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


detectPropagators :: IO (Propagator Context RequestHeaders ResponseHeaders)
detectPropagators = do
  registeredPropagators <- readRegisteredPropagators
  propagatorsInEnv <- fmap (T.splitOn "," . T.pack) <$> lookupEnv "OTEL_PROPAGATORS"
  if propagatorsInEnv == Just ["none"]
    then pure mempty
    else do
      let envPropagators = fromMaybe ["tracecontext", "baggage"] propagatorsInEnv
          propagatorsAndRegistryEntry = map (\k -> maybe (Left k) Right $ lookup k registeredPropagators) envPropagators
          (_notFound, propagators) = partitionEithers propagatorsAndRegistryEntry
      -- TODO log warn notFound
      pure $ mconcat propagators


knownSamplers :: [(T.Text, Maybe T.Text -> Maybe Sampler)]
knownSamplers =
  [ ("always_on", const $ pure alwaysOn)
  , ("always_off", const $ pure alwaysOff)
  ,
    ( "traceidratio"
    , \case
        Nothing -> Nothing
        Just val -> case readMaybe (T.unpack val) of
          Nothing -> Nothing
          Just ratioVal -> pure $ traceIdRatioBased ratioVal
    )
  , ("parentbased_always_on", const $ pure $ parentBased $ parentBasedOptions alwaysOn)
  , ("parentbased_always_off", const $ pure $ parentBased $ parentBasedOptions alwaysOff)
  ,
    ( "parentbased_traceidratio"
    , \case
        Nothing -> Nothing
        Just val -> case readMaybe (T.unpack val) of
          Nothing -> Nothing
          Just ratioVal -> pure $ parentBased $ parentBasedOptions $ traceIdRatioBased ratioVal
    )
  ]


-- TODO MUST log invalid arg

{- | Detect a sampler from the app environment. If no sampler is specified,
 the parentbased sampler is used.

 @since 0.0.3.3
-}
detectSampler :: IO Sampler
detectSampler = do
  envSampler <- lookupEnv "OTEL_TRACES_SAMPLER"
  envArg <- lookupEnv "OTEL_TRACES_SAMPLER_ARG"
  let sampler = fromMaybe (parentBased $ parentBasedOptions alwaysOn) $ do
        samplerName <- envSampler
        samplerConstructor <- lookup (T.pack samplerName) knownSamplers
        samplerConstructor (T.pack <$> envArg)
  pure sampler


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
    <*> readEnv "OTEL_SPAN_LINK_COUNT_LIMIT"
    <*> readEnv "OTEL_EVENT_ATTRIBUTE_COUNT_LIMIT"
    <*> readEnv "OTEL_LINK_ATTRIBUTE_COUNT_LIMIT"


knownExporters :: [(T.Text, IO SpanExporter)]
knownExporters =
  [
    ( "otlp"
    , do
        otlpConfig <- loadExporterEnvironmentVariables
        otlpExporter otlpConfig
    )
  , ("jaeger", error "Jaeger exporter not implemented")
  , ("zipkin", error "Zipkin exporter not implemented")
  ]


-- TODO, support multiple exporters
detectExporters :: IO [SpanExporter]
detectExporters = do
  exportersInEnv <- fmap (T.splitOn "," . T.pack) <$> lookupEnv "OTEL_TRACES_EXPORTER"
  if exportersInEnv == Just ["none"]
    then pure []
    else do
      let envExporters = fromMaybe ["otlp"] exportersInEnv
          exportersAndRegistryEntry = map (\k -> maybe (Left k) Right $ lookup k knownExporters) envExporters
          (_notFound, exporterIntializers) = partitionEithers exportersAndRegistryEntry
      -- TODO, notFound logging
      sequence exporterIntializers


-- -- detectMetricsExporterSelection :: _
-- -- TODO other metrics stuff

detectResourceAttributes :: IO [(T.Text, Attribute)]
detectResourceAttributes = do
  mEnv <- lookupEnv "OTEL_RESOURCE_ATTRIBUTES"
  case mEnv of
    Nothing -> pure []
    Just envVar -> case decodeBaggageHeader $ B.pack envVar of
      Left err -> do
        -- TODO logError
        putStrLn err
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


{- | Use all built-in resource detectors to populate resource information.

 Currently used detectors include:

 - 'detectService'
 - 'detectProcess'
 - 'detectOperatingSystem'
 - 'detectHost'
 - 'detectTelemetry'
 - 'detectProcessRuntime'

 This list will grow in the future as more detectors are implemented.

 @since 0.0.1.0
-}
detectBuiltInResources :: IO (Resource 'Nothing)
detectBuiltInResources = do
  svc <- detectService
  processInfo <- detectProcess
  osInfo <- detectOperatingSystem
  host <- detectHost
  let rs =
        toResource svc
          `mergeResources` toResource detectTelemetry
          `mergeResources` toResource detectProcessRuntime
          `mergeResources` toResource processInfo
          `mergeResources` toResource osInfo
          `mergeResources` toResource host
  pure rs
