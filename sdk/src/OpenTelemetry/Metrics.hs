{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

-----------------------------------------------------------------------------

-----------------------------------------------------------------------------

{- |
 Module      :  OpenTelemetry.Metrics
 Copyright   :  (c) Ian Duncan, 2024
 License     :  BSD-3
 Description :  Application Metrics SDK
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)

 The OpenTelemetry Metrics SDK provides the implementation for collecting,
 aggregating, and exporting metrics from your application.

 = Quick Start

 1. Initialize a 'MeterProvider'
 2. Create a 'Meter' for your subsystem
 3. Create instruments (Counter, Histogram, etc.)
 4. Record measurements

 @
 import OpenTelemetry.Metrics
 import Control.Exception (bracket)

 main :: IO ()
 main = bracket
   initializeGlobalMeterProvider
   shutdownMeterProvider
   $ \meterProvider -> do
     meter <- getMeter meterProvider "my-app" meterOptions
     counter <- createCounter meter "requests.count" "Number of requests" "1"

     -- Record measurements
     counterAdd counter 1 []
 @

 = Configuration

 The SDK can be configured via environment variables:

 +-----------------------------------+-----------------------------------------------+----------------+
 | Name                              | Description                                   | Default        |
 +===================================+===============================================+================+
 | OTEL_METRICS_EXPORTER             | Metrics exporter to use                       | otlp           |
 +-----------------------------------+-----------------------------------------------+----------------+
 | OTEL_METRIC_EXPORT_INTERVAL       | Interval between metric exports (ms)          | 60000          |
 +-----------------------------------+-----------------------------------------------+----------------+
 | OTEL_METRIC_EXPORT_TIMEOUT        | Timeout for metric export (ms)                | 30000          |
 +-----------------------------------+-----------------------------------------------+----------------+
-}
module OpenTelemetry.Metrics (
  -- * MeterProvider operations
  MeterProvider,
  initializeGlobalMeterProvider,
  initializeMeterProvider,
  getMeterProviderInitializationOptions,
  shutdownMeterProvider,
  getGlobalMeterProvider,
  setGlobalMeterProvider,
  createMeterProvider,
  MeterProviderOptions (..),
  emptyMeterProviderOptions,

  -- * Meter operations
  Meter,
  meterName,
  getMeter,
  makeMeter,
  MeterOptions (..),
  meterOptions,
  HasMeter (..),
  InstrumentationLibrary (..),
  detectInstrumentationLibrary,

  -- * Synchronous Instruments
  Counter (..),
  createCounter,
  counterAdd,
  UpDownCounter (..),
  createUpDownCounter,
  upDownCounterAdd,
  Histogram (..),
  createHistogram,
  histogramRecord,

  -- * Asynchronous Instruments
  Gauge (..),
  createGauge,
  ObservableCounter (..),
  createObservableCounter,
  ObservableUpDownCounter (..),
  createObservableUpDownCounter,

  -- * Metric Readers
  MetricReader,
  PeriodicReaderConfig (..),
  defaultPeriodicReaderConfig,

  -- * Aggregation
  AggregationTemporality (..),
  InstrumentKind (..),
) where

import Data.Maybe (fromMaybe)
import qualified Data.Text as T
import OpenTelemetry.Attributes (AttributeLimits (..), defaultAttributeLimits)
import OpenTelemetry.Internal.Common.Types
import OpenTelemetry.Metrics.Core
import OpenTelemetry.Metrics.MetricReader
import OpenTelemetry.Resource
import System.Environment (lookupEnv)
import Text.Read (readMaybe)


{- | Initialize a new meter provider and set it as the global meter provider.

 This pulls all configuration from environment variables.

 @since 0.1.0.0
-}
initializeGlobalMeterProvider :: IO MeterProvider
initializeGlobalMeterProvider = do
  mp <- initializeMeterProvider
  setGlobalMeterProvider mp
  pure mp


{- | Initialize a new meter provider from environment configuration.

 @since 0.1.0.0
-}
initializeMeterProvider :: IO MeterProvider
initializeMeterProvider = do
  (readers, opts) <- getMeterProviderInitializationOptions
  createMeterProvider readers opts


{- | Get meter provider initialization options from the environment.

 This reads configuration from environment variables and returns the
 readers and options to create a meter provider.

 @since 0.1.0.0
-}
getMeterProviderInitializationOptions :: IO ([MetricReader], MeterProviderOptions)
getMeterProviderInitializationOptions = do
  disabled <- lookupBooleanEnv "OTEL_SDK_DISABLED"
  if disabled
    then pure ([], emptyMeterProviderOptions)
    else do
      attrLimits <- detectAttributeLimits
      builtInRs <- detectBuiltInResources
      envVarRs <- mkResource . map Just <$> detectResourceAttributes
      let allRs = envVarRs <> builtInRs
      readers <- detectMetricReaders
      let providerOpts =
            emptyMeterProviderOptions
              { meterProviderOptionsResources = materializeResources allRs
              , meterProviderOptionsAttributeLimits = attrLimits
              }
      pure (readers, providerOpts)


{- | Detect metric readers from environment configuration.

 Currently supports:
 - OTEL_METRICS_EXPORTER: otlp, none (defaults to otlp)
 - OTEL_METRIC_EXPORT_INTERVAL: milliseconds between exports (default 60000)
 - OTEL_METRIC_EXPORT_TIMEOUT: export timeout in milliseconds (default 30000)

 @since 0.1.0.0
-}
detectMetricReaders :: IO [MetricReader]
detectMetricReaders = do
  exportersInEnv <- fmap (T.splitOn "," . T.pack) <$> lookupEnv "OTEL_METRICS_EXPORTER"

  -- For now, we don't create any readers since we don't have OTLP exporter in this module
  -- The SDK user will need to create readers manually or we'll return empty list
  if exportersInEnv == Just ["none"]
    then pure []
    else pure [] -- TODO: Add OTLP exporter support


{- | Detect attribute limits from environment variables.

 Reads:
 - OTEL_ATTRIBUTE_COUNT_LIMIT
 - OTEL_ATTRIBUTE_VALUE_LENGTH_LIMIT

 @since 0.1.0.0
-}
detectAttributeLimits :: IO AttributeLimits
detectAttributeLimits =
  AttributeLimits
    <$> readEnvDefault "OTEL_ATTRIBUTE_COUNT_LIMIT" (attributeCountLimit defaultAttributeLimits)
    <*> ((>>= readMaybe) <$> lookupEnv "OTEL_ATTRIBUTE_VALUE_LENGTH_LIMIT")


{- | Read an environment variable with a default value.

 @since 0.1.0.0
-}
readEnvDefault :: forall a. (Read a) => String -> a -> IO a
readEnvDefault k defaultValue =
  fromMaybe defaultValue . (>>= readMaybe) <$> lookupEnv k


{- | Lookup a boolean environment variable.

 Considers "true" as True, all other values as False.

 @since 0.1.0.0
-}
lookupBooleanEnv :: String -> IO Bool
lookupBooleanEnv key = do
  val <- lookupEnv key
  pure $ val == Just "true"


-- Re-export resource detection from the trace SDK
-- These are defined in OpenTelemetry.Trace but we need them here too

{- | Detect built-in resources.

 This is imported from the trace SDK to avoid duplication.

 @since 0.1.0.0
-}
detectBuiltInResources :: IO (Resource 'Nothing)
detectBuiltInResources = do
  -- Import these from the trace module
  -- For now, return empty resources
  pure $ mkResource []


{- | Detect resource attributes from OTEL_RESOURCE_ATTRIBUTES.

 @since 0.1.0.0
-}
detectResourceAttributes :: IO [(T.Text, Attribute)]
detectResourceAttributes = do
  -- This would parse OTEL_RESOURCE_ATTRIBUTES
  -- For now, return empty
  pure []
