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
  -- ** Getting / setting the global 'TracerProvider'
  , getGlobalTracerProvider
  , setGlobalTracerProvider
  -- ** Alternative 'TracerProvider' initialization
  , createTracerProvider
  , TracerProviderOptions(..)
  , emptyTracerProviderOptions
  , builtInResources
  -- * 'Tracer' operations
  , Tracer
  , tracerName
  , getTracer
  , tracerOptions
  , HasTracer(..)
  , InstrumentationLibrary(..)
  -- * 'Span' operations
  , Span
  , createSpan
  , defaultSpanArguments
  , SpanArguments(..)
  , updateName
  , addAttribute 
  , addAttributes
  , getAttributes
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
  -- TODO, don't remember if this is okay with the spec or not
  , ImmutableSpan(..)
  ) where

import "hs-opentelemetry-api" OpenTelemetry.Trace
import "hs-opentelemetry-api" OpenTelemetry.Resource
import Data.Maybe (fromMaybe)
import Data.Either (partitionEithers)
import qualified Data.Text as T
import OpenTelemetry.Context.Propagators (Propagator (propagatorNames))
import OpenTelemetry.Context (Context)
import Network.HTTP.Types.Header

import OpenTelemetry.Propagators.W3CTraceContext (w3cTraceContextPropagator)
import OpenTelemetry.Propagators.W3CBaggage (w3cBaggagePropagator)
import System.Environment (lookupEnv)
import OpenTelemetry.Trace.Sampler (Sampler (getDescription), alwaysOn, alwaysOff, traceIdRatioBased, parentBased, parentBasedOptions)
import Text.Read (readMaybe)
import OpenTelemetry.Trace.SpanExporter (SpanExporter)
import OpenTelemetry.Trace.SpanProcessors.Batch (BatchTimeoutConfig (..), batchTimeoutConfig, batchProcessor)
import OpenTelemetry.Attributes (AttributeLimits(..), defaultAttributeLimits)
import OpenTelemetry.Baggage (decodeBaggageHeader)
import qualified Data.ByteString.Char8 as B
import qualified OpenTelemetry.Baggage as Baggage
import qualified Data.HashMap.Strict as H
import Data.Text.Encoding (decodeUtf8)
import OpenTelemetry.Exporters.OTLP (loadExporterEnvironmentVariables, otlpExporter)
import OpenTelemetry.Trace.SpanProcessor (SpanProcessor)

knownPropagators :: [(T.Text, Propagator Context RequestHeaders ResponseHeaders)]
knownPropagators =
  [ ("tracecontext", w3cTraceContextPropagator)
  , ("baggage", w3cBaggagePropagator)
  , ("b3", error "B3 not yet implemented")
  , ("b3multi", error "B3 multi not yet implemented")
  , ("jaeger", error "B3 multi not yet implemented")
  ]

-- TODO, actually implement a registry systme
readRegisteredPropagators :: IO [(T.Text, Propagator Context RequestHeaders ResponseHeaders)]
readRegisteredPropagators = pure knownPropagators

initializeGlobalTracerProvider :: IO ()
initializeGlobalTracerProvider = do
  t <- initializeTracerProvider
  setGlobalTracerProvider t

initializeTracerProvider :: IO TracerProvider
initializeTracerProvider = do
  (processors, opts) <- getTracerProviderInitializationOptions
  createTracerProvider processors opts

getTracerProviderInitializationOptions :: IO ([SpanProcessor], TracerProviderOptions)
getTracerProviderInitializationOptions  = do
  sampler <- detectSampler
  attrLimits <- detectAttributeLimits
  spanLimits <- detectSpanLimits
  propagators <- detectPropagators
  spanProcessorConf <- detectBatchSpanProcessorConfig
  exporters <- detectTraceExporters
  builtInRs <- builtInResources
  envVarRs <- (mkResource . map Just) <$> detectResourceAttributes
  let allRs = builtInRs <> envVarRs
  processors <- case exporters of
    [] -> do
      pure []
    e:_ -> do
      pure <$> batchProcessor spanProcessorConf e
  let providerOpts = emptyTracerProviderOptions
        { tracerProviderOptionsSampler = sampler
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

detectBatchSpanProcessorConfig :: IO BatchTimeoutConfig
detectBatchSpanProcessorConfig = BatchTimeoutConfig 
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
    -- detectOtlpExporterConfig :: _
    -- -- detectJaegerExporterConfig :: _
    -- -- detectZipkinExporterConfig :: _
    -- -- detectPrometheusExporterConfig :: _

knownTraceExporters :: [(T.Text, IO SpanExporter)]
knownTraceExporters =
  [ ("otlp", do
      otlpConfig <- loadExporterEnvironmentVariables
      otlpExporter otlpConfig
    )
  , ("jaeger", error "Jaeger exporter not implemented")
  , ("zipkin", error "Zipkin exporter not implemented")
  ]

-- TODO, rename SpanExporter to TraceExporter
-- TODO, support multiple exporters
detectTraceExporters :: IO [SpanExporter]
detectTraceExporters = do
  exportersInEnv <- fmap (T.splitOn "," . T.pack) <$> lookupEnv "OTEL_TRACES_EXPORTER"
  if exportersInEnv == Just ["none"]
    then pure []
    else do
      let envExporters = fromMaybe ["otlp"] exportersInEnv
          exportersAndRegistryEntry = map (\k -> maybe (Left k) Right $ lookup k knownTraceExporters) envExporters
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