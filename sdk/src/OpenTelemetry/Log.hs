{-# LANGUAGE DataKinds #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}

module OpenTelemetry.Log where

import Data.Either (partitionEithers)
import Data.Maybe (fromMaybe)
import qualified Data.Text as T
import OpenTelemetry.Environment
import OpenTelemetry.Environment.Detect
import OpenTelemetry.Exporter.OTLP.Config (loadExporterEnvironmentVariables)
import OpenTelemetry.Exporter.OTLP.LogRecord (otlpExporter)
import OpenTelemetry.Internal.Logs.Types
import OpenTelemetry.Logs.Core
import OpenTelemetry.Processor.Batch.LogRecord (batchProcessor)
import OpenTelemetry.Processor.Batch.TimeoutConfig (BatchTimeoutConfig (..), batchTimeoutConfig)
import OpenTelemetry.Resource
import OpenTelemetry.Resource.Detector (detectBuiltInResources)
import System.Environment (lookupEnv)


initializeGlobalLoggerProvider :: IO LoggerProvider
initializeGlobalLoggerProvider = do
  t <- initializeLoggerProvider
  setGlobalLoggerProvider t
  pure t


initializeLoggerProvider :: IO LoggerProvider
initializeLoggerProvider = do
  (processors, opts) <- getLoggerProviderInitializationOptions
  pure $ createLoggerProvider processors opts


getLoggerProviderInitializationOptions :: IO ([LogRecordProcessor], LoggerProviderOptions)
getLoggerProviderInitializationOptions = getLoggerProviderInitializationOptions' (mempty :: Resource 'Nothing)


getLoggerProviderInitializationOptions'
  :: forall schema
   . (MaterializeResource schema)
  => Resource schema
  -> IO ([LogRecordProcessor], LoggerProviderOptions)
getLoggerProviderInitializationOptions' rs = do
  disabled <- lookupBooleanEnv "OTEL_SDK_DISABLED"
  if disabled
    then pure ([], emptyLoggerProviderOptions)
    else do
      attrLimits <- detectAttributeLimits
      processorConf <- detectBatchProcessorConfig
      exporters <- detectExporters
      builtInRs <- detectBuiltInResources
      envVarRs <- mkResource . map Just <$> detectResourceAttributes
      let
        -- NB: Resource merge prioritizes the left value on attribute key conflict.
        allRs = mergeResources rs (envVarRs <> builtInRs)
      processors <- mapM (batchProcessor processorConf) exporters
      let providerOpts =
            emptyLoggerProviderOptions
              { loggerProviderOptionsResources = materializeResources allRs
              , loggerProviderOptionsAttributeLimits = attrLimits
              }
      pure (processors, providerOpts)


detectBatchProcessorConfig :: IO BatchTimeoutConfig
detectBatchProcessorConfig =
  BatchTimeoutConfig
    <$> readEnvDefault "OTEL_BLRP_MAX_QUEUE_SIZE" (maxQueueSize batchTimeoutConfig)
    <*> readEnvDefault "OTEL_BLRP_SCHEDULE_DELAY" (scheduledDelayMillis batchTimeoutConfig)
    <*> readEnvDefault "OTEL_BLRP_EXPORT_TIMEOUT" (exportTimeoutMillis batchTimeoutConfig)
    <*> readEnvDefault "OTEL_BLRP_MAX_EXPORT_BATCH_SIZE" (maxExportBatchSize batchTimeoutConfig)


knownExporters :: [(T.Text, IO LogRecordExporter)]
knownExporters =
  [ ("otlp", otlpExporter =<< loadExporterEnvironmentVariables)
  ]


detectExporters :: IO [LogRecordExporter]
detectExporters = do
  exportersInEnv <- fmap (T.splitOn "," . T.pack) <$> lookupEnv "OTEL_LOGS_EXPORTER"
  if exportersInEnv == Just ["none"]
    then pure []
    else do
      let envExporters = fromMaybe ["otlp"] exportersInEnv
          exportersAndRegistryEntry = map (\k -> maybe (Left k) Right $ lookup k knownExporters) envExporters
          (_notFound, exporterIntializers) = partitionEithers exportersAndRegistryEntry
      -- TODO, notFound logging
      sequence exporterIntializers
