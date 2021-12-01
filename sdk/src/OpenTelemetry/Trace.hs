{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE DataKinds #-}
module OpenTelemetry.Trace 
  ( 
  -- * 'TracerProvider' operations
    TracerProvider
  , initializeGlobalTracerProvider
  , initializeTracerProvider
  , getTracerProviderInitializationOptions
  , shutdownTracerProvider
  -- ** Getting / setting the global 'TracerProvider'
  , getGlobalTracerProvider
  , setGlobalTracerProvider
  -- ** Alternative 'TracerProvider' initialization
  , createTracerProvider
  , TracerProviderOptions(..)
  , emptyTracerProviderOptions
  , detectBuiltInResources
  -- * 'Tracer' operations
  , Tracer
  , tracerName
  , getTracer
  , TracerOptions(..)
  , tracerOptions
  , HasTracer(..)
  , InstrumentationLibrary(..)
  -- * 'Span' operations
  , Span
  , createSpan
  , createSpanWithoutCallStack
  , defaultSpanArguments
  , SpanArguments(..)
  , updateName
  , addAttribute 
  , addAttributes
  , spanGetAttributes
  , ToAttribute(..)
  , ToPrimitiveAttribute(..)
  , Attribute(..)
  , PrimitiveAttribute(..)
  , SpanKind(..)
  , Link(..)
  , Event
  , NewEvent(..)
  , addEvent
  , recordException
  , setStatus
  , SpanStatus(..)
  , SpanContext(..)
  , endSpan
  -- TODO, don't remember if this is okay with the spec or not
  , ImmutableSpan(..)
  ) where

import OpenTelemetry.Trace.Core
import OpenTelemetry.Resource
import Data.Maybe (fromMaybe)
import Data.Either (partitionEithers)
import qualified Data.Text as T
import OpenTelemetry.Context (Context)
import Network.HTTP.Types.Header
import OpenTelemetry.Propagator.W3CTraceContext (w3cTraceContextPropagator)
import OpenTelemetry.Propagator.W3CBaggage (w3cBaggagePropagator)
import OpenTelemetry.Propagator (Propagator)
import System.Environment (lookupEnv)
import OpenTelemetry.Trace.Sampler (Sampler, alwaysOn, alwaysOff, traceIdRatioBased, parentBased, parentBasedOptions)
import Text.Read (readMaybe)
import OpenTelemetry.Exporter (Exporter)
import OpenTelemetry.Processor.Batch (BatchTimeoutConfig (..), batchTimeoutConfig, batchProcessor)
import OpenTelemetry.Attributes (AttributeLimits(..), defaultAttributeLimits)
import OpenTelemetry.Baggage (decodeBaggageHeader)
import qualified Data.ByteString.Char8 as B
import qualified OpenTelemetry.Baggage as Baggage
import qualified Data.HashMap.Strict as H
import Data.Text.Encoding (decodeUtf8)
import OpenTelemetry.Exporter.OTLP (loadExporterEnvironmentVariables, otlpExporter)
import OpenTelemetry.Processor (Processor)
import OpenTelemetry.Resource.Service.Detector (detectService)
import OpenTelemetry.Resource.Process.Detector (detectProcess, detectProcessRuntime)
import OpenTelemetry.Resource.OperatingSystem.Detector (detectOperatingSystem)
import OpenTelemetry.Resource.Host.Detector (detectHost)
import OpenTelemetry.Resource.Telemetry.Detector (detectTelemetry)
import OpenTelemetry.Trace.Id.Generator.Default (defaultIdGenerator)

knownPropagators :: [(T.Text, Propagator Context RequestHeaders ResponseHeaders)]
knownPropagators =
  [ ("tracecontext", w3cTraceContextPropagator)
  , ("baggage", w3cBaggagePropagator)
  , ("b3", error "B3 not yet implemented")
  , ("b3multi", error "B3 multi not yet implemented")
  , ("jaeger", error "Jaeger not yet implemented")
  ]

-- TODO, actually implement a registry systme
readRegisteredPropagators :: IO [(T.Text, Propagator Context RequestHeaders ResponseHeaders)]
readRegisteredPropagators = pure knownPropagators

initializeGlobalTracerProvider :: IO TracerProvider
initializeGlobalTracerProvider = do
  t <- initializeTracerProvider
  setGlobalTracerProvider t
  pure t

initializeTracerProvider :: IO TracerProvider
initializeTracerProvider = do
  (processors, opts) <- getTracerProviderInitializationOptions
  createTracerProvider processors opts

getTracerProviderInitializationOptions :: IO ([Processor], TracerProviderOptions)
getTracerProviderInitializationOptions  = do
  sampler <- detectSampler
  attrLimits <- detectAttributeLimits
  spanLimits <- detectSpanLimits
  propagators <- detectPropagators
  processorConf <- detectBatchProcessorConfig
  exporters <- detectExporters
  builtInRs <- detectBuiltInResources
  envVarRs <- (mkResource . map Just) <$> detectResourceAttributes
  let allRs = builtInRs <> envVarRs
  processors <- case exporters of
    [] -> do
      pure []
    e:_ -> do
      pure <$> batchProcessor processorConf e
  let providerOpts = emptyTracerProviderOptions
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
  , ("traceidratio", \case
      Nothing -> Nothing 
      Just val -> case readMaybe (T.unpack val) of
        Nothing -> Nothing
        Just ratioVal -> pure $ traceIdRatioBased ratioVal
    )
  , ("parentbased_always_on", const $ pure $ parentBased $ parentBasedOptions alwaysOn)
  , ("parentbased_always_off", const $ pure $ parentBased $ parentBasedOptions alwaysOff)
  , ("parentbased_traceidratio", \case
      Nothing -> Nothing 
      Just val -> case readMaybe (T.unpack val) of
        Nothing -> Nothing
        Just ratioVal -> pure $ parentBased $ parentBasedOptions $ traceIdRatioBased ratioVal
  )
  ]

-- TODO MUST log invalid arg
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
detectBatchProcessorConfig = BatchTimeoutConfig 
  <$> readEnvDefault "OTEL_BSP_MAX_QUEUE_SIZE" (maxQueueSize batchTimeoutConfig)
  <*> readEnvDefault "OTEL_BSP_SCHEDULE_DELAY" (scheduledDelayMillis batchTimeoutConfig)
  <*> readEnvDefault "OTEL_BSP_EXPORT_TIMEOUT" (exportTimeoutMillis batchTimeoutConfig)
  <*> readEnvDefault "OTEL_BSP_MAX_EXPORT_BATCH_SIZE" (maxExportBatchSize batchTimeoutConfig)

detectAttributeLimits :: IO AttributeLimits
detectAttributeLimits = AttributeLimits
  <$> readEnvDefault "OTEL_ATTRIBUTE_COUNT_LIMIT" (attributeCountLimit defaultAttributeLimits)
  <*> ((>>= readMaybe) <$> lookupEnv "OTEL_ATTRIBUTE_VALUE_LENGTH_LIMIT")

detectSpanLimits :: IO SpanLimits
detectSpanLimits = SpanLimits
  <$> readEnv "OTEL_SPAN_ATTRIBUTE_VALUE_LENGTH_LIMIT"
  <*> readEnv "OTEL_SPAN_ATTRIBUTE_COUNT_LIMIT"
  <*> readEnv "OTEL_SPAN_EVENT_COUNT_LIMIT"
  <*> readEnv "OTEL_SPAN_LINK_COUNT_LIMIT"
  <*> readEnv "OTEL_EVENT_ATTRIBUTE_COUNT_LIMIT"
  <*> readEnv "OTEL_LINK_ATTRIBUTE_COUNT_LIMIT"

knownExporters :: [(T.Text, IO Exporter)]
knownExporters =
  [ ("otlp", do
      otlpConfig <- loadExporterEnvironmentVariables
      otlpExporter otlpConfig
    )
  , ("jaeger", error "Jaeger exporter not implemented")
  , ("zipkin", error "Zipkin exporter not implemented")
  ]

-- TODO, rename Exporter to Exporter
-- TODO, support multiple exporters
detectExporters :: IO [Exporter]
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
        pure
          $ map (\(k, v) -> (decodeUtf8 $ Baggage.tokenValue k, toAttribute $ Baggage.value v))
          $ H.toList
          $ Baggage.values ok

readEnvDefault :: forall a. Read a => String -> a -> IO a 
readEnvDefault k defaultValue =
  fromMaybe defaultValue . (>>= readMaybe) <$> lookupEnv k

readEnv :: forall a. Read a => String -> IO (Maybe a)
readEnv k = (>>= readMaybe) <$> lookupEnv k

detectBuiltInResources :: IO (Resource 'Nothing)
detectBuiltInResources = do
  svc <- detectService
  processInfo <- detectProcess
  osInfo <- detectOperatingSystem
  host <- detectHost
  let rs =
        toResource svc `mergeResources`
        toResource detectTelemetry `mergeResources`
        toResource detectProcessRuntime `mergeResources`
        toResource processInfo `mergeResources`
        toResource osInfo `mergeResources`
        toResource host
  pure rs