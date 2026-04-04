{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

{- | Implements the "Create" operation from the OpenTelemetry Configuration SDK spec.
Interprets the in-memory configuration model and produces SDK components.
See: https://opentelemetry.io/docs/specs/otel/configuration/sdk/#create
-}
module OpenTelemetry.Configuration.Create (
  createFromConfig,
  OTelComponents (..),
) where

import qualified Data.CaseInsensitive as CI
import qualified Data.Map.Strict as Map
import Data.Maybe (fromMaybe)
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import Network.HTTP.Types.Header (Header)
import OpenTelemetry.Attributes (AttributeLimits (..), defaultAttributeLimits)
import OpenTelemetry.Configuration.Types
import qualified OpenTelemetry.Exporter.Handle.LogRecord as HandleLog
import qualified OpenTelemetry.Exporter.Handle.Metric as HandleMetric
import qualified OpenTelemetry.Exporter.Handle.Span as HandleSpan
import OpenTelemetry.Exporter.LogRecord (LogRecordExporter)
import OpenTelemetry.Exporter.Metric (MetricExporter)
import OpenTelemetry.Exporter.OTLP.LogRecord (otlpLogRecordExporter)
import OpenTelemetry.Exporter.OTLP.Metric (otlpMetricExporter)
import OpenTelemetry.Exporter.OTLP.Span (CompressionFormat (..), OTLPExporterConfig (..), otlpExporter)
import OpenTelemetry.Exporter.Span (SpanExporter)
import OpenTelemetry.Logs.Core (LoggerProvider, LoggerProviderOptions (..), createLoggerProvider, emptyLoggerProviderOptions, shutdownLoggerProvider)
import OpenTelemetry.MeterProvider
import OpenTelemetry.MetricReader
import OpenTelemetry.Metrics (MeterProvider (..))
import OpenTelemetry.Processor.Batch.LogRecord (batchLogRecordProcessor)
import qualified OpenTelemetry.Processor.Batch.LogRecord as BlogProc
import OpenTelemetry.Processor.Batch.Span (BatchTimeoutConfig (..), batchProcessor, batchTimeoutConfig)
import OpenTelemetry.Processor.LogRecord (LogRecordProcessor)
import qualified OpenTelemetry.Processor.Simple.LogRecord as SlogProc
import OpenTelemetry.Processor.Simple.Span (SimpleProcessorConfig (..), simpleProcessor)
import OpenTelemetry.Processor.Span (SpanProcessor)
import OpenTelemetry.Propagator (TextMapPropagator, setGlobalTextMapPropagator)
import OpenTelemetry.Propagator.B3 (b3MultiTraceContextPropagator, b3TraceContextPropagator)
import OpenTelemetry.Propagator.W3CBaggage
import OpenTelemetry.Propagator.W3CTraceContext
import OpenTelemetry.Resource
import OpenTelemetry.Trace.Core
import OpenTelemetry.Trace.Id.Generator.Default (defaultIdGenerator)
import OpenTelemetry.Trace.Sampler


data OTelComponents = OTelComponents
  { otelTracerProvider :: !TracerProvider
  , otelMeterProvider :: !MeterProvider
  , otelLoggerProvider :: !LoggerProvider
  , otelPropagators :: !TextMapPropagator
  , otelShutdown :: !(IO ())
  }


{- | Create SDK components from a parsed configuration model.
Returns all three providers and the composite propagator.
-}
createFromConfig :: OTelConfiguration -> IO OTelComponents
createFromConfig cfg = do
  let disabled = fromMaybe False (configDisabled cfg)
  if disabled
    then do
      tp <- createTracerProvider [] emptyTracerProviderOptions
      (mp, _env) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
      lp <- createLoggerProvider [] emptyLoggerProviderOptions
      pure
        OTelComponents
          { otelTracerProvider = tp
          , otelMeterProvider = mp
          , otelLoggerProvider = lp
          , otelPropagators = mempty
          , otelShutdown = pure ()
          }
    else do
      let globalAttrLimits = configAttrLimits cfg

      -- Resource
      let res = buildResource cfg

      -- Propagators
      let props = buildPropagators cfg
      setGlobalTextMapPropagator props

      -- TracerProvider
      (spanProcessors, spanShutdowns) <- buildSpanProcessors cfg
      let tpOpts =
            emptyTracerProviderOptions
              { tracerProviderOptionsIdGenerator = defaultIdGenerator
              , tracerProviderOptionsSampler = buildSampler cfg
              , tracerProviderOptionsAttributeLimits = globalAttrLimits
              , tracerProviderOptionsSpanLimits = buildSpanLimits cfg
              , tracerProviderOptionsPropagators = props
              , tracerProviderOptionsResources = res
              }
      tp <- createTracerProvider spanProcessors tpOpts

      -- MeterProvider
      (mp, meterShutdown) <- buildMeterProvider cfg res

      -- LoggerProvider
      (lp, logShutdowns) <- buildLoggerProvider cfg globalAttrLimits res

      let shutdown = do
            _ <- shutdownTracerProvider tp
            _ <- meterProviderShutdown mp
            _ <- shutdownLoggerProvider lp
            sequence_ spanShutdowns
            meterShutdown
            sequence_ logShutdowns

      pure
        OTelComponents
          { otelTracerProvider = tp
          , otelMeterProvider = mp
          , otelLoggerProvider = lp
          , otelPropagators = props
          , otelShutdown = shutdown
          }


configAttrLimits :: OTelConfiguration -> AttributeLimits
configAttrLimits cfg = case configAttributeLimits cfg of
  Nothing -> defaultAttributeLimits
  Just al ->
    defaultAttributeLimits
      { attributeCountLimit = alAttributeCountLimit al
      , attributeLengthLimit = alAttributeValueLengthLimit al
      }


buildResource :: OTelConfiguration -> MaterializedResources
buildResource cfg = case configResource cfg of
  Nothing -> emptyMaterializedResources
  Just rc ->
    let attrs = maybe [] (map (\(k, v) -> (k, toAttribute v)) . Map.toList) (resourceAttributes rc)
        r = mkResource (map Just attrs)
        schema = fmap T.unpack (resourceSchemaUrl rc)
    in materializeResourcesWithSchema schema r


buildPropagators :: OTelConfiguration -> TextMapPropagator
buildPropagators cfg = case configPropagator cfg of
  Nothing -> w3cTraceContextPropagator <> w3cBaggagePropagator
  Just pc -> case propagatorComposite pc of
    Nothing -> w3cTraceContextPropagator <> w3cBaggagePropagator
    Just names -> mconcat $ map resolvePropagator names
  where
    resolvePropagator name = case T.toLower name of
      "tracecontext" -> w3cTraceContextPropagator
      "baggage" -> w3cBaggagePropagator
      "b3" -> b3TraceContextPropagator
      "b3multi" -> b3MultiTraceContextPropagator
      "none" -> mempty
      _ -> mempty


buildSampler :: OTelConfiguration -> Sampler
buildSampler cfg = case configTracerProvider cfg of
  Nothing -> parentBased (parentBasedOptions alwaysOn)
  Just tp -> case tpSampler tp of
    Nothing -> parentBased (parentBasedOptions alwaysOn)
    Just sc -> resolveSampler sc
  where
    resolveSampler SamplerAlwaysOn = alwaysOn
    resolveSampler SamplerAlwaysOff = alwaysOff
    resolveSampler (SamplerTraceIdRatioBased r) = traceIdRatioBased (ratioValue r)
    resolveSampler (SamplerParentBased pb) =
      parentBased
        ParentBasedOptions
          { rootSampler = maybe alwaysOn resolveSampler (pbRoot pb)
          , remoteParentSampled = maybe alwaysOn resolveSampler (pbRemoteParentSampled pb)
          , remoteParentNotSampled = maybe alwaysOff resolveSampler (pbRemoteParentNotSampled pb)
          , localParentSampled = maybe alwaysOn resolveSampler (pbLocalParentSampled pb)
          , localParentNotSampled = maybe alwaysOff resolveSampler (pbLocalParentNotSampled pb)
          }


buildSpanLimits :: OTelConfiguration -> SpanLimits
buildSpanLimits cfg = case configTracerProvider cfg >>= tpLimits of
  Nothing -> defaultSpanLimits
  Just sl ->
    SpanLimits
      { spanAttributeValueLengthLimit = slAttributeValueLengthLimit sl
      , spanAttributeCountLimit = slAttributeCountLimit sl
      , eventCountLimit = slEventCountLimit sl
      , linkCountLimit = slLinkCountLimit sl
      , eventAttributeCountLimit = slEventAttributeCountLimit sl
      , linkAttributeCountLimit = slLinkAttributeCountLimit sl
      }


buildSpanProcessors :: OTelConfiguration -> IO ([SpanProcessor], [IO ()])
buildSpanProcessors cfg = case configTracerProvider cfg >>= tpProcessors of
  Nothing -> pure ([], [])
  Just procs -> do
    results <- mapM buildOneSpanProcessor procs
    let (sps, shutdowns) = unzip results
    pure (sps, shutdowns)


buildOneSpanProcessor :: SpanProcessorConfig -> IO (SpanProcessor, IO ())
buildOneSpanProcessor (SpanProcessorBatch bsp) = do
  exporter <- buildSpanExporter (bspExporter bsp)
  let conf =
        batchTimeoutConfig
          { maxQueueSize = fromMaybe (maxQueueSize batchTimeoutConfig) (bspMaxQueueSize bsp)
          , scheduledDelayMillis = fromMaybe (scheduledDelayMillis batchTimeoutConfig) (bspScheduleDelay bsp)
          , exportTimeoutMillis = fromMaybe (exportTimeoutMillis batchTimeoutConfig) (bspExportTimeout bsp)
          , maxExportBatchSize = fromMaybe (maxExportBatchSize batchTimeoutConfig) (bspMaxExportBatchSize bsp)
          }
  processor <- batchProcessor conf exporter
  pure (processor, pure ())
buildOneSpanProcessor (SpanProcessorSimple ssp) = do
  exporter <- buildSpanExporter (sspExporter ssp)
  processor <- simpleProcessor (SimpleProcessorConfig exporter)
  pure (processor, pure ())


buildSpanExporter :: SpanExporterConfig -> IO SpanExporter
buildSpanExporter (SpanExporterOtlpHttp otlpCfg) = do
  let envConfig = otlpHttpToExporterConfig otlpCfg
  otlpExporter envConfig
buildSpanExporter (SpanExporterConsole _) = pure $ HandleSpan.stdoutExporter' HandleSpan.defaultFormatter
buildSpanExporter SpanExporterNone = pure $ HandleSpan.stdoutExporter' HandleSpan.defaultFormatter


buildMeterProvider :: OTelConfiguration -> MaterializedResources -> IO (MeterProvider, IO ())
buildMeterProvider cfg res = case configMeterProvider cfg >>= mpReaders of
  Nothing -> do
    (mp, _env) <- createMeterProvider res defaultSdkMeterProviderOptions
    pure (mp, pure ())
  Just readers -> do
    -- Use the first reader's exporter for the provider
    case readers of
      [] -> do
        (mp, _env) <- createMeterProvider res defaultSdkMeterProviderOptions
        pure (mp, pure ())
      (MetricReaderPeriodic pmc : _) -> do
        mExporter <- buildMetricExporter (pmrExporter pmc)
        let opts = defaultSdkMeterProviderOptions {metricExporter = mExporter}
        (mp, env) <- createMeterProvider res opts
        case mExporter of
          Just ex -> do
            let interval = fromMaybe 60000 (pmrInterval pmc)
                readerOpts = PeriodicMetricReaderOptions {periodicIntervalMicros = interval * 1000}
            handle <- forkPeriodicMetricReader env ex readerOpts
            pure (mp, stopPeriodicMetricReader handle)
          Nothing -> pure (mp, pure ())


buildMetricExporter :: PushMetricExporterConfig -> IO (Maybe MetricExporter)
buildMetricExporter (PushMetricExporterOtlpHttp otlpCfg) = do
  let envConfig = otlpHttpToExporterConfig otlpCfg
  ex <- otlpMetricExporter envConfig
  pure (Just ex)
buildMetricExporter (PushMetricExporterConsole _) = do
  ex <- HandleMetric.stdoutMetricExporter
  pure (Just ex)
buildMetricExporter PushMetricExporterNone = pure Nothing


buildLoggerProvider :: OTelConfiguration -> AttributeLimits -> MaterializedResources -> IO (LoggerProvider, [IO ()])
buildLoggerProvider cfg attrLimits res = case configLoggerProvider cfg >>= lpProcessors of
  Nothing -> do
    lp <- createLoggerProvider [] (LoggerProviderOptions res attrLimits)
    pure (lp, [])
  Just procs -> do
    results <- mapM buildOneLogProcessor procs
    let (lps, shutdowns) = unzip results
        lpOpts = LoggerProviderOptions res attrLimits
    lp <- createLoggerProvider lps lpOpts
    pure (lp, shutdowns)


buildOneLogProcessor :: LogRecordProcessorConfig -> IO (LogRecordProcessor, IO ())
buildOneLogProcessor (LogRecordProcessorBatch blp) = do
  exporter <- buildLogExporter (blpExporter blp)
  let conf =
        BlogProc.BatchLogRecordProcessorConfig
          { BlogProc.batchLogExporter = exporter
          , BlogProc.batchLogMaxQueueSize = fromMaybe 2048 (blpMaxQueueSize blp)
          , BlogProc.batchLogScheduledDelayMillis = fromMaybe 1000 (blpScheduleDelay blp)
          , BlogProc.batchLogExportTimeoutMillis = fromMaybe 30000 (blpExportTimeout blp)
          , BlogProc.batchLogMaxExportBatchSize = fromMaybe 512 (blpMaxExportBatchSize blp)
          }
  processor <- batchLogRecordProcessor conf
  pure (processor, pure ())
buildOneLogProcessor (LogRecordProcessorSimple slp) = do
  exporter <- buildLogExporter (slpExporter slp)
  let conf = SlogProc.SimpleLogRecordProcessorConfig {SlogProc.simpleLogRecordExporter = exporter}
  processor <- SlogProc.simpleLogRecordProcessor conf
  pure (processor, pure ())


buildLogExporter :: LogRecordExporterConfig -> IO LogRecordExporter
buildLogExporter (LogRecordExporterOtlpHttp otlpCfg) = do
  let envConfig = otlpHttpToExporterConfig otlpCfg
  otlpLogRecordExporter envConfig
buildLogExporter (LogRecordExporterConsole _) = HandleLog.stdoutLogRecordExporter
buildLogExporter LogRecordExporterNone = HandleLog.stdoutLogRecordExporter


otlpHttpToExporterConfig :: OtlpHttpExporterConfig -> OTLPExporterConfig
otlpHttpToExporterConfig cfg' =
  OTLPExporterConfig
    { otlpEndpoint = fmap T.unpack (otlpCfgEndpoint cfg')
    , otlpTracesEndpoint = fmap T.unpack (otlpSignalEndpoint cfg')
    , otlpMetricsEndpoint = Nothing
    , otlpLogsEndpoint = Nothing
    , otlpInsecure = False
    , otlpTracesInsecure = False
    , otlpMetricsInsecure = False
    , otlpLogsInsecure = False
    , otlpCertificate = Nothing
    , otlpTracesCertificate = Nothing
    , otlpMetricsCertificate = Nothing
    , otlpLogsCertificate = Nothing
    , otlpHeaders = fmap headersFromMap (otlpCfgHeaders cfg')
    , otlpTracesHeaders = Nothing
    , otlpMetricsHeaders = Nothing
    , otlpLogsHeaders = Nothing
    , otlpCompression = otlpCfgCompression cfg' >>= parseCompression
    , otlpTracesCompression = Nothing
    , otlpMetricsCompression = Nothing
    , otlpLogsCompression = Nothing
    , otlpTimeout = otlpCfgTimeout cfg'
    , otlpTracesTimeout = Nothing
    , otlpMetricsTimeout = Nothing
    , otlpLogsTimeout = Nothing
    , otlpProtocol = Nothing
    , otlpTracesProtocol = Nothing
    , otlpMetricsProtocol = Nothing
    , otlpLogsProtocol = Nothing
    }


headersFromMap :: Map.Map Text Text -> [Header]
headersFromMap = map (\(k, v) -> (CI.mk (T.encodeUtf8 k), T.encodeUtf8 v)) . Map.toList


parseCompression :: Text -> Maybe CompressionFormat
parseCompression t = case T.toLower t of
  "gzip" -> Just GZip
  "none" -> Just None
  _ -> Nothing
