{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

{- | In-memory representation of the OpenTelemetry declarative configuration model.
See: https://opentelemetry.io/docs/specs/otel/configuration/sdk/
-}
module OpenTelemetry.Configuration.Types (
  OTelConfiguration (..),
  AttributeLimitsConfig (..),
  ResourceConfig (..),
  PropagatorConfig (..),
  TracerProviderConfig (..),
  SpanProcessorConfig (..),
  BatchSpanProcessorConfig (..),
  SimpleSpanProcessorConfig (..),
  SpanExporterConfig (..),
  OtlpHttpExporterConfig (..),
  ConsoleExporterConfig (..),
  SamplerConfig (..),
  ParentBasedSamplerConfig (..),
  TraceIdRatioSamplerConfig (..),
  SpanLimitsConfig (..),
  MeterProviderConfig (..),
  MetricReaderConfig (..),
  PeriodicMetricReaderConfig (..),
  PushMetricExporterConfig (..),
  LoggerProviderConfig (..),
  LogRecordProcessorConfig (..),
  BatchLogRecordProcessorConfig (..),
  SimpleLogRecordProcessorConfig (..),
  LogRecordExporterConfig (..),
  emptyConfiguration,
) where

import qualified Data.Map.Strict as Map
import Data.Text (Text)
import GHC.Generics (Generic)


-- | @since 0.1.0.0
data OTelConfiguration = OTelConfiguration
  { configFileFormat :: !Text
  , configDisabled :: !(Maybe Bool)
  , configAttributeLimits :: !(Maybe AttributeLimitsConfig)
  , configResource :: !(Maybe ResourceConfig)
  , configPropagator :: !(Maybe PropagatorConfig)
  , configTracerProvider :: !(Maybe TracerProviderConfig)
  , configMeterProvider :: !(Maybe MeterProviderConfig)
  , configLoggerProvider :: !(Maybe LoggerProviderConfig)
  }
  deriving (Show, Eq, Generic)


-- | @since 0.1.0.0
data AttributeLimitsConfig = AttributeLimitsConfig
  { alAttributeValueLengthLimit :: !(Maybe Int)
  , alAttributeCountLimit :: !(Maybe Int)
  }
  deriving (Show, Eq, Generic)


-- | @since 0.1.0.0
data ResourceConfig = ResourceConfig
  { resourceAttributes :: !(Maybe (Map.Map Text Text))
  , resourceDetectors :: !(Maybe [Text])
  , resourceSchemaUrl :: !(Maybe Text)
  }
  deriving (Show, Eq, Generic)


-- | @since 0.1.0.0
newtype PropagatorConfig = PropagatorConfig
  { propagatorComposite :: Maybe [Text]
  }
  deriving (Show, Eq, Generic)


-- | @since 0.1.0.0
data TracerProviderConfig = TracerProviderConfig
  { tpProcessors :: !(Maybe [SpanProcessorConfig])
  , tpSampler :: !(Maybe SamplerConfig)
  , tpLimits :: !(Maybe SpanLimitsConfig)
  }
  deriving (Show, Eq, Generic)


-- | @since 0.1.0.0
data SpanProcessorConfig
  = SpanProcessorBatch !BatchSpanProcessorConfig
  | SpanProcessorSimple !SimpleSpanProcessorConfig
  deriving (Show, Eq, Generic)


-- | @since 0.1.0.0
data BatchSpanProcessorConfig = BatchSpanProcessorConfig
  { bspScheduleDelay :: !(Maybe Int)
  , bspExportTimeout :: !(Maybe Int)
  , bspMaxQueueSize :: !(Maybe Int)
  , bspMaxExportBatchSize :: !(Maybe Int)
  , bspExporter :: !SpanExporterConfig
  }
  deriving (Show, Eq, Generic)


-- | @since 0.1.0.0
newtype SimpleSpanProcessorConfig = SimpleSpanProcessorConfig
  { sspExporter :: SpanExporterConfig
  }
  deriving (Show, Eq, Generic)


-- | @since 0.1.0.0
data SpanExporterConfig
  = SpanExporterOtlpHttp !OtlpHttpExporterConfig
  | SpanExporterConsole !ConsoleExporterConfig
  | SpanExporterNone
  deriving (Show, Eq, Generic)


-- | @since 0.1.0.0
data OtlpHttpExporterConfig = OtlpHttpExporterConfig
  { otlpCfgEndpoint :: !(Maybe Text)
  , otlpSignalEndpoint :: !(Maybe Text)
  , otlpCfgTimeout :: !(Maybe Int)
  , otlpCfgCompression :: !(Maybe Text)
  , otlpCfgHeaders :: !(Maybe (Map.Map Text Text))
  }
  deriving (Show, Eq, Generic)


-- | @since 0.1.0.0
data ConsoleExporterConfig = ConsoleExporterConfig
  deriving (Show, Eq, Generic)


-- | @since 0.1.0.0
data SamplerConfig
  = SamplerAlwaysOn
  | SamplerAlwaysOff
  | SamplerTraceIdRatioBased !TraceIdRatioSamplerConfig
  | SamplerParentBased !ParentBasedSamplerConfig
  deriving (Show, Eq, Generic)


-- | @since 0.1.0.0
data ParentBasedSamplerConfig = ParentBasedSamplerConfig
  { pbRoot :: !(Maybe SamplerConfig)
  , pbRemoteParentSampled :: !(Maybe SamplerConfig)
  , pbRemoteParentNotSampled :: !(Maybe SamplerConfig)
  , pbLocalParentSampled :: !(Maybe SamplerConfig)
  , pbLocalParentNotSampled :: !(Maybe SamplerConfig)
  }
  deriving (Show, Eq, Generic)


-- | @since 0.1.0.0
newtype TraceIdRatioSamplerConfig = TraceIdRatioSamplerConfig
  { ratioValue :: Double
  }
  deriving (Show, Eq, Generic)


-- | @since 0.1.0.0
data SpanLimitsConfig = SpanLimitsConfig
  { slAttributeValueLengthLimit :: !(Maybe Int)
  , slAttributeCountLimit :: !(Maybe Int)
  , slEventCountLimit :: !(Maybe Int)
  , slLinkCountLimit :: !(Maybe Int)
  , slEventAttributeCountLimit :: !(Maybe Int)
  , slLinkAttributeCountLimit :: !(Maybe Int)
  }
  deriving (Show, Eq, Generic)


-- | @since 0.1.0.0
data MeterProviderConfig = MeterProviderConfig
  { mpReaders :: !(Maybe [MetricReaderConfig])
  }
  deriving (Show, Eq, Generic)


-- | @since 0.1.0.0
newtype MetricReaderConfig
  = MetricReaderPeriodic PeriodicMetricReaderConfig
  deriving (Show, Eq, Generic)


-- | @since 0.1.0.0
data PeriodicMetricReaderConfig = PeriodicMetricReaderConfig
  { pmrInterval :: !(Maybe Int)
  , pmrTimeout :: !(Maybe Int)
  , pmrExporter :: !PushMetricExporterConfig
  }
  deriving (Show, Eq, Generic)


-- | @since 0.1.0.0
data PushMetricExporterConfig
  = PushMetricExporterOtlpHttp !OtlpHttpExporterConfig
  | PushMetricExporterConsole !ConsoleExporterConfig
  | PushMetricExporterNone
  deriving (Show, Eq, Generic)


-- | @since 0.1.0.0
data LoggerProviderConfig = LoggerProviderConfig
  { lpProcessors :: !(Maybe [LogRecordProcessorConfig])
  }
  deriving (Show, Eq, Generic)


-- | @since 0.1.0.0
data LogRecordProcessorConfig
  = LogRecordProcessorBatch !BatchLogRecordProcessorConfig
  | LogRecordProcessorSimple !SimpleLogRecordProcessorConfig
  deriving (Show, Eq, Generic)


-- | @since 0.1.0.0
data BatchLogRecordProcessorConfig = BatchLogRecordProcessorConfig
  { blpScheduleDelay :: !(Maybe Int)
  , blpExportTimeout :: !(Maybe Int)
  , blpMaxQueueSize :: !(Maybe Int)
  , blpMaxExportBatchSize :: !(Maybe Int)
  , blpExporter :: !LogRecordExporterConfig
  }
  deriving (Show, Eq, Generic)


-- | @since 0.1.0.0
newtype SimpleLogRecordProcessorConfig = SimpleLogRecordProcessorConfig
  { slpExporter :: LogRecordExporterConfig
  }
  deriving (Show, Eq, Generic)


-- | @since 0.1.0.0
data LogRecordExporterConfig
  = LogRecordExporterOtlpHttp !OtlpHttpExporterConfig
  | LogRecordExporterConsole !ConsoleExporterConfig
  | LogRecordExporterNone
  deriving (Show, Eq, Generic)


-- | @since 0.1.0.0
emptyConfiguration :: OTelConfiguration
emptyConfiguration =
  OTelConfiguration
    { configFileFormat = "1.0"
    , configDisabled = Nothing
    , configAttributeLimits = Nothing
    , configResource = Nothing
    , configPropagator = Nothing
    , configTracerProvider = Nothing
    , configMeterProvider = Nothing
    , configLoggerProvider = Nothing
    }
