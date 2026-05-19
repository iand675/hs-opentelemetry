{-# LANGUAGE DataKinds #-}

{- |
 Module      :  OpenTelemetry.Registry
 Copyright   :  (c) Ian Duncan, 2021
 License     :  BSD-3
 Description :  Global registry for exporters and propagators
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)

 A global, process-wide registry that allows exporter and propagator
 libraries to make themselves discoverable by the SDK at
 initialization time.

 This follows the same pattern as Go's
 [@autoexport@](https://pkg.go.dev/go.opentelemetry.io/contrib/exporters/autoexport)
 and
 [@autoprop@](https://pkg.go.dev/go.opentelemetry.io/contrib/propagators/autoprop)
 packages: the registry is the single source of truth for resolving
 @OTEL_TRACES_EXPORTER@, @OTEL_PROPAGATORS@, and similar environment
 variables.

 == How it works

 * The SDK registers its known defaults (otlp, tracecontext, baggage,
   b3, datadog) using the @IfAbsent@ variants during initialization.
 * Third-party packages that call the plain @register@ variants
   /before/ SDK init will therefore take precedence over built-in
   defaults.
 * After SDK init, the registry is no longer consulted; changes have
   no retroactive effect on an already-initialized 'TracerProvider'.

 == Usage example

 @
 import OpenTelemetry.Registry ('registerSpanExporterFactory', 'registerTextMapPropagator')
 import OpenTelemetry.Trace ('initializeGlobalTracerProvider')

 main :: IO ()
 main = do
   -- Register a custom exporter before SDK init.
   -- When OTEL_TRACES_EXPORTER=\"zipkin\", the SDK will use this factory.
   'registerSpanExporterFactory' \"zipkin\" myZipkinExporterFactory

   -- Register a custom propagator.
   -- When OTEL_PROPAGATORS=\"xray\", the SDK will use this propagator.
   'registerTextMapPropagator' \"xray\" myXRayPropagator

   -- The SDK now resolves exporter\/propagator names from the registry.
   'initializeGlobalTracerProvider'
   ...
 @

 @since 0.4.0.0
-}
module OpenTelemetry.Registry (
  -- * Span Exporter Registry
  registerSpanExporterFactory,
  registerSpanExporterFactoryIfAbsent,
  lookupSpanExporterFactory,
  registeredSpanExporterFactories,

  -- * Metric Exporter Registry
  registerMetricExporterFactory,
  registerMetricExporterFactoryIfAbsent,
  lookupMetricExporterFactory,
  registeredMetricExporterFactories,

  -- * Log Record Exporter Registry
  registerLogRecordExporterFactory,
  registerLogRecordExporterFactoryIfAbsent,
  lookupLogRecordExporterFactory,
  registeredLogRecordExporterFactories,

  -- * Text Map Propagator Registry
  registerTextMapPropagator,
  registerTextMapPropagatorIfAbsent,
  lookupRegisteredTextMapPropagator,
  registeredTextMapPropagators,

  -- * Resource Detector Registry
  ResourceDetector,
  registerResourceDetector,
  registerResourceDetectorIfAbsent,
  lookupResourceDetector,
  registeredResourceDetectors,
) where

import Data.HashMap.Strict (HashMap)
import qualified Data.HashMap.Strict as H
import Data.IORef (IORef, atomicModifyIORef', newIORef, readIORef)
import Data.Text (Text)
import OpenTelemetry.Internal.Log.Types (LogRecordExporter)
import OpenTelemetry.Internal.Metric.Export (MetricExporter)
import OpenTelemetry.Internal.Trace.Types (SpanExporter)
import OpenTelemetry.Propagator (TextMapPropagator)
import OpenTelemetry.Resource (Resource)
import System.IO.Unsafe (unsafePerformIO)


-- Internal: insert-or-replace into an IORef HashMap.
insertRegistry :: IORef (HashMap Text v) -> Text -> v -> IO ()
insertRegistry ref name val =
  atomicModifyIORef' ref $ \m -> (H.insert name val m, ())
{-# INLINE insertRegistry #-}


-- Internal: insert only if the key is absent.  Returns True when a
-- new entry was actually inserted.
insertRegistryIfAbsent :: IORef (HashMap Text v) -> Text -> v -> IO Bool
insertRegistryIfAbsent ref name val =
  atomicModifyIORef' ref $ \m ->
    if H.member name m
      then (m, False)
      else (H.insert name val m, True)
{-# INLINE insertRegistryIfAbsent #-}


lookupRegistry :: IORef (HashMap Text v) -> Text -> IO (Maybe v)
lookupRegistry ref name = H.lookup name <$> readIORef ref
{-# INLINE lookupRegistry #-}


readRegistry :: IORef (HashMap Text v) -> IO (HashMap Text v)
readRegistry = readIORef
{-# INLINE readRegistry #-}


-- Span Exporters --------------------------------------------------------------

spanExporterRegistry :: IORef (HashMap Text (IO SpanExporter))
spanExporterRegistry = unsafePerformIO $ newIORef H.empty
{-# NOINLINE spanExporterRegistry #-}


{- | Register a span exporter factory, replacing any existing entry
with the same name.

Use this from third-party exporter packages to override or extend the
set of exporters available to the SDK.

@since 0.4.0.0
-}
registerSpanExporterFactory :: Text -> IO SpanExporter -> IO ()
registerSpanExporterFactory = insertRegistry spanExporterRegistry


{- | Register a span exporter factory only if no factory is already
registered under the given name.  Returns 'True' if the factory was
registered, 'False' if an entry already existed.

The SDK uses this for built-in defaults so that user registrations
(made before SDK initialization) take precedence.

@since 0.4.0.0
-}
registerSpanExporterFactoryIfAbsent :: Text -> IO SpanExporter -> IO Bool
registerSpanExporterFactoryIfAbsent = insertRegistryIfAbsent spanExporterRegistry


{- | Look up a span exporter factory by name.

@since 0.4.0.0
-}
lookupSpanExporterFactory :: Text -> IO (Maybe (IO SpanExporter))
lookupSpanExporterFactory = lookupRegistry spanExporterRegistry


{- | Return all registered span exporter factories.

@since 0.4.0.0
-}
registeredSpanExporterFactories :: IO (HashMap Text (IO SpanExporter))
registeredSpanExporterFactories = readRegistry spanExporterRegistry


-- Metric Exporters ------------------------------------------------------------

metricExporterRegistry :: IORef (HashMap Text (IO MetricExporter))
metricExporterRegistry = unsafePerformIO $ newIORef H.empty
{-# NOINLINE metricExporterRegistry #-}


{- | Register a metric exporter factory, replacing any existing entry.

@since 0.4.0.0
-}
registerMetricExporterFactory :: Text -> IO MetricExporter -> IO ()
registerMetricExporterFactory = insertRegistry metricExporterRegistry


{- | Register a metric exporter factory only if absent.

@since 0.4.0.0
-}
registerMetricExporterFactoryIfAbsent :: Text -> IO MetricExporter -> IO Bool
registerMetricExporterFactoryIfAbsent = insertRegistryIfAbsent metricExporterRegistry


{- | Look up a metric exporter factory by name.

@since 0.4.0.0
-}
lookupMetricExporterFactory :: Text -> IO (Maybe (IO MetricExporter))
lookupMetricExporterFactory = lookupRegistry metricExporterRegistry


{- | Return all registered metric exporter factories.

@since 0.4.0.0
-}
registeredMetricExporterFactories :: IO (HashMap Text (IO MetricExporter))
registeredMetricExporterFactories = readRegistry metricExporterRegistry


-- Log Record Exporters --------------------------------------------------------

logRecordExporterRegistry :: IORef (HashMap Text (IO LogRecordExporter))
logRecordExporterRegistry = unsafePerformIO $ newIORef H.empty
{-# NOINLINE logRecordExporterRegistry #-}


{- | Register a log record exporter factory, replacing any existing entry.

@since 0.4.0.0
-}
registerLogRecordExporterFactory :: Text -> IO LogRecordExporter -> IO ()
registerLogRecordExporterFactory = insertRegistry logRecordExporterRegistry


{- | Register a log record exporter factory only if absent.

@since 0.4.0.0
-}
registerLogRecordExporterFactoryIfAbsent :: Text -> IO LogRecordExporter -> IO Bool
registerLogRecordExporterFactoryIfAbsent = insertRegistryIfAbsent logRecordExporterRegistry


{- | Look up a log record exporter factory by name.

@since 0.4.0.0
-}
lookupLogRecordExporterFactory :: Text -> IO (Maybe (IO LogRecordExporter))
lookupLogRecordExporterFactory = lookupRegistry logRecordExporterRegistry


{- | Return all registered log record exporter factories.

@since 0.4.0.0
-}
registeredLogRecordExporterFactories :: IO (HashMap Text (IO LogRecordExporter))
registeredLogRecordExporterFactories = readRegistry logRecordExporterRegistry


-- Text Map Propagators --------------------------------------------------------

propagatorRegistry :: IORef (HashMap Text TextMapPropagator)
propagatorRegistry = unsafePerformIO $ newIORef H.empty
{-# NOINLINE propagatorRegistry #-}


{- | Register a text map propagator, replacing any existing entry with
the same name.

@since 0.4.0.0
-}
registerTextMapPropagator :: Text -> TextMapPropagator -> IO ()
registerTextMapPropagator = insertRegistry propagatorRegistry


{- | Register a text map propagator only if absent.  Returns 'True'
when a new entry was inserted.

@since 0.4.0.0
-}
registerTextMapPropagatorIfAbsent :: Text -> TextMapPropagator -> IO Bool
registerTextMapPropagatorIfAbsent = insertRegistryIfAbsent propagatorRegistry


{- | Look up a text map propagator by name.

@since 0.4.0.0
-}
lookupRegisteredTextMapPropagator :: Text -> IO (Maybe TextMapPropagator)
lookupRegisteredTextMapPropagator = lookupRegistry propagatorRegistry


{- | Return all registered text map propagators.

@since 0.4.0.0
-}
registeredTextMapPropagators :: IO (HashMap Text TextMapPropagator)
registeredTextMapPropagators = readRegistry propagatorRegistry


-- Resource Detectors ----------------------------------------------------------

{- | A resource detector is an IO action that produces a 'Resource'.
Detectors that do not apply to the current environment should return
@'mkResource' []@ (an empty resource).

@since 0.4.0.0
-}
type ResourceDetector = IO Resource


resourceDetectorRegistry :: IORef (HashMap Text ResourceDetector)
resourceDetectorRegistry = unsafePerformIO $ newIORef H.empty
{-# NOINLINE resourceDetectorRegistry #-}


{- | Register a resource detector, replacing any existing entry with
the same name.

Use this from application code or third-party packages to make a
custom detector available to the SDK.

@since 0.4.0.0
-}
registerResourceDetector :: Text -> ResourceDetector -> IO ()
registerResourceDetector = insertRegistry resourceDetectorRegistry


{- | Register a resource detector only if absent.  Returns 'True'
when a new entry was inserted.

The SDK uses this for built-in detectors so that user registrations
(made before SDK initialization) take precedence.

@since 0.4.0.0
-}
registerResourceDetectorIfAbsent :: Text -> ResourceDetector -> IO Bool
registerResourceDetectorIfAbsent = insertRegistryIfAbsent resourceDetectorRegistry


{- | Look up a resource detector by name.

@since 0.4.0.0
-}
lookupResourceDetector :: Text -> IO (Maybe ResourceDetector)
lookupResourceDetector = lookupRegistry resourceDetectorRegistry


{- | Return all registered resource detectors.

@since 0.4.0.0
-}
registeredResourceDetectors :: IO (HashMap Text ResourceDetector)
registeredResourceDetectors = readRegistry resourceDetectorRegistry
