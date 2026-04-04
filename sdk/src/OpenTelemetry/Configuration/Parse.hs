{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

{- | YAML configuration file parser with environment variable substitution.
Implements the "Parse" operation from the OpenTelemetry Configuration SDK spec.
See: https://opentelemetry.io/docs/specs/otel/configuration/sdk/#parse
-}
module OpenTelemetry.Configuration.Parse (
  parseConfigFile,
  parseConfigBytes,
  ConfigParseError (..),
) where

import Control.Exception (Exception, try)
import Data.Aeson (Object, Value (..))
import qualified Data.Aeson.Key as AesonKey
import qualified Data.Aeson.KeyMap as KM
import Data.Map.Strict (Map)
import qualified Data.Map.Strict as Map
import Data.Scientific (toBoundedInteger, toRealFloat)
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import qualified Data.Text.IO as TIO
import qualified Data.Text.Lazy as TL
import Data.Text.Lazy.Builder (toLazyText)
import Data.Text.Lazy.Builder.Int (decimal)
import Data.Text.Lazy.Builder.RealFloat (realFloat)
import qualified Data.Vector as V
import qualified Data.Yaml as Yaml
import OpenTelemetry.Configuration.Types
import System.Environment (lookupEnv)


data ConfigParseError
  = ConfigFileNotFound !FilePath
  | ConfigYamlError !Text
  | ConfigValidationError !Text
  deriving (Show, Eq)


instance Exception ConfigParseError


{- | Parse a configuration file from a file path.
Performs environment variable substitution and validates the result.
-}
parseConfigFile :: FilePath -> IO (Either ConfigParseError OTelConfiguration)
parseConfigFile path = do
  contentResult <- try (TIO.readFile path)
  case contentResult of
    Left (_ :: IOError) -> pure $ Left $ ConfigFileNotFound path
    Right content -> parseConfigBytes content


-- | Parse configuration from YAML text content.
parseConfigBytes :: Text -> IO (Either ConfigParseError OTelConfiguration)
parseConfigBytes content = do
  substituted <- substituteEnvVars content
  case parseYamlToValue substituted of
    Left err -> pure $ Left $ ConfigYamlError err
    Right val -> pure $ valueToConfig val


parseYamlToValue :: Text -> Either Text Value
parseYamlToValue input =
  case Yaml.decodeEither' (TE.encodeUtf8 input) of
    Left err -> Left (T.pack (Yaml.prettyPrintParseException err))
    Right val -> Right val


{- | Substitute environment variable references in text.
Supports: ${VAR}, ${env:VAR}, ${VAR:-default}, ${env:VAR:-default}
-}
substituteEnvVars :: Text -> IO Text
substituteEnvVars input = go input T.empty
  where
    go remaining acc
      | T.null remaining = pure acc
      | otherwise =
          case T.breakOn "${" remaining of
            (before, "") -> pure (acc <> before)
            (before, withRef) ->
              let afterOpen = T.drop 2 withRef
              in case T.breakOn "}" afterOpen of
                  (_, "") -> pure (acc <> remaining)
                  (ref, afterClose) -> do
                    val <- resolveRef ref
                    go (T.drop 1 afterClose) (acc <> before <> val)

    resolveRef ref =
      let (varSpec, defaultVal) = splitDefault ref
          varName = T.strip $ case T.stripPrefix "env:" varSpec of
            Just name -> name
            Nothing -> varSpec
      in do
          result <- lookupEnv (T.unpack varName)
          pure $ case result of
            Just v -> T.pack v
            Nothing -> defaultVal

    splitDefault ref =
      case T.breakOn ":-" ref of
        (v, "") -> (v, T.empty)
        (v, rest) -> (v, T.drop 2 rest)


-- | Convert a parsed JSON Value to an OTelConfiguration.
valueToConfig :: Value -> Either ConfigParseError OTelConfiguration
valueToConfig (Object obj) = do
  let fileFormat = getTextOr "file_format" "1.0" obj
      disabled = getBoolMaybe "disabled" obj
      attrLimits = case KM.lookup "attribute_limits" obj of
        Just (Object al) ->
          Just
            AttributeLimitsConfig
              { alAttributeValueLengthLimit = getIntMaybe "attribute_value_length_limit" al
              , alAttributeCountLimit = getIntMaybe "attribute_count_limit" al
              }
        _ -> Nothing
      resource = case KM.lookup "resource" obj of
        Just (Object r) ->
          Just
            ResourceConfig
              { resourceAttributes = case KM.lookup "attributes" r of
                  Just (Object attrs) -> Just $ objectToTextMap attrs
                  _ -> Nothing
              , resourceDetectors = case KM.lookup "detectors" r of
                  Just (Array arr) -> Just $ V.toList $ V.mapMaybe getText arr
                  _ -> Nothing
              , resourceSchemaUrl = getTextMaybe "schema_url" r
              }
        _ -> Nothing
      propagator = case KM.lookup "propagator" obj of
        Just (Object p) ->
          Just
            PropagatorConfig
              { propagatorComposite = case KM.lookup "composite" p of
                  Just (Array arr) -> Just $ V.toList $ V.mapMaybe getText arr
                  _ -> Nothing
              }
        _ -> Nothing
      tracerProvider = case KM.lookup "tracer_provider" obj of
        Just (Object tp) -> Just $ parseTracerProvider tp
        _ -> Nothing
      meterProvider = case KM.lookup "meter_provider" obj of
        Just (Object mp) -> Just $ parseMeterProvider mp
        _ -> Nothing
      loggerProvider = case KM.lookup "logger_provider" obj of
        Just (Object lp) -> Just $ parseLoggerProvider lp
        _ -> Nothing
  Right
    OTelConfiguration
      { configFileFormat = fileFormat
      , configDisabled = disabled
      , configAttributeLimits = attrLimits
      , configResource = resource
      , configPropagator = propagator
      , configTracerProvider = tracerProvider
      , configMeterProvider = meterProvider
      , configLoggerProvider = loggerProvider
      }
valueToConfig _ = Left $ ConfigValidationError "Top-level configuration must be a YAML mapping"


parseTracerProvider :: Object -> TracerProviderConfig
parseTracerProvider obj =
  TracerProviderConfig
    { tpProcessors = case KM.lookup "processors" obj of
        Just (Array arr) -> Just $ V.toList $ V.map parseSpanProcessor arr
        _ -> Nothing
    , tpSampler = case KM.lookup "sampler" obj of
        Just (Object s) -> parseSamplerConfig s
        _ -> Nothing
    , tpLimits = case KM.lookup "limits" obj of
        Just (Object l) ->
          Just
            SpanLimitsConfig
              { slAttributeValueLengthLimit = getIntMaybe "attribute_value_length_limit" l
              , slAttributeCountLimit = getIntMaybe "attribute_count_limit" l
              , slEventCountLimit = getIntMaybe "event_count_limit" l
              , slLinkCountLimit = getIntMaybe "link_count_limit" l
              , slEventAttributeCountLimit = getIntMaybe "event_attribute_count_limit" l
              , slLinkAttributeCountLimit = getIntMaybe "link_attribute_count_limit" l
              }
        _ -> Nothing
    }


parseSpanProcessor :: Value -> SpanProcessorConfig
parseSpanProcessor (Object obj) = case KM.lookup "batch" obj of
  Just (Object b) ->
    SpanProcessorBatch
      BatchSpanProcessorConfig
        { bspScheduleDelay = getIntMaybe "schedule_delay" b
        , bspExportTimeout = getIntMaybe "export_timeout" b
        , bspMaxQueueSize = getIntMaybe "max_queue_size" b
        , bspMaxExportBatchSize = getIntMaybe "max_export_batch_size" b
        , bspExporter = parseSpanExporter b
        }
  _ -> case KM.lookup "simple" obj of
    Just (Object s) ->
      SpanProcessorSimple
        SimpleSpanProcessorConfig
          { sspExporter = parseSpanExporter s
          }
    _ -> SpanProcessorBatch (BatchSpanProcessorConfig Nothing Nothing Nothing Nothing SpanExporterNone)
parseSpanProcessor _ = SpanProcessorBatch (BatchSpanProcessorConfig Nothing Nothing Nothing Nothing SpanExporterNone)


parseSpanExporter :: Object -> SpanExporterConfig
parseSpanExporter obj = case KM.lookup "exporter" obj of
  Just (Object e) -> parseExporterChoice e SpanExporterOtlpHttp SpanExporterConsole SpanExporterNone
  _ -> SpanExporterNone


parseExporterChoice
  :: Object
  -> (OtlpHttpExporterConfig -> a)
  -> (ConsoleExporterConfig -> a)
  -> a
  -> a
parseExporterChoice obj mkOtlp mkConsole fallback
  | Just v <- KM.lookup "otlp_http" obj = mkOtlp (parseOtlpConfig v)
  | Just _ <- KM.lookup "console" obj = mkConsole ConsoleExporterConfig
  | otherwise = fallback


parseOtlpConfig :: Value -> OtlpHttpExporterConfig
parseOtlpConfig (Object o) =
  OtlpHttpExporterConfig
    { otlpCfgEndpoint = getTextMaybe "endpoint" o
    , otlpSignalEndpoint = Nothing
    , otlpCfgTimeout = getIntMaybe "timeout" o
    , otlpCfgCompression = getTextMaybe "compression" o
    , otlpCfgHeaders = case KM.lookup "headers" o of
        Just (Object h) -> Just $ objectToTextMap h
        _ -> Nothing
    }
parseOtlpConfig Null =
  OtlpHttpExporterConfig Nothing Nothing Nothing Nothing Nothing
parseOtlpConfig _ =
  OtlpHttpExporterConfig Nothing Nothing Nothing Nothing Nothing


parseSamplerConfig :: Object -> Maybe SamplerConfig
parseSamplerConfig obj
  | Just _ <- KM.lookup "always_on" obj = Just SamplerAlwaysOn
  | Just _ <- KM.lookup "always_off" obj = Just SamplerAlwaysOff
  | Just (Object r) <- KM.lookup "trace_id_ratio_based" obj =
      case getDoubleMaybe "ratio" r of
        Just ratio -> Just $ SamplerTraceIdRatioBased (TraceIdRatioSamplerConfig ratio)
        Nothing -> Nothing
  | Just (Object p) <- KM.lookup "parent_based" obj =
      Just $
        SamplerParentBased
          ParentBasedSamplerConfig
            { pbRoot = case KM.lookup "root" p of
                Just (Object s) -> parseSamplerConfig s
                _ -> Nothing
            , pbRemoteParentSampled = case KM.lookup "remote_parent_sampled" p of
                Just (Object s) -> parseSamplerConfig s
                _ -> Nothing
            , pbRemoteParentNotSampled = case KM.lookup "remote_parent_not_sampled" p of
                Just (Object s) -> parseSamplerConfig s
                _ -> Nothing
            , pbLocalParentSampled = case KM.lookup "local_parent_sampled" p of
                Just (Object s) -> parseSamplerConfig s
                _ -> Nothing
            , pbLocalParentNotSampled = case KM.lookup "local_parent_not_sampled" p of
                Just (Object s) -> parseSamplerConfig s
                _ -> Nothing
            }
  | otherwise = Nothing


parseMeterProvider :: Object -> MeterProviderConfig
parseMeterProvider obj =
  MeterProviderConfig
    { mpReaders = case KM.lookup "readers" obj of
        Just (Array arr) -> Just $ V.toList $ V.map parseMetricReader arr
        _ -> Nothing
    }


parseMetricReader :: Value -> MetricReaderConfig
parseMetricReader (Object obj) = case KM.lookup "periodic" obj of
  Just (Object p) ->
    MetricReaderPeriodic
      PeriodicMetricReaderConfig
        { pmrInterval = getIntMaybe "interval" p
        , pmrTimeout = getIntMaybe "timeout" p
        , pmrExporter = parsePushMetricExporter p
        }
  _ -> MetricReaderPeriodic (PeriodicMetricReaderConfig Nothing Nothing PushMetricExporterNone)
parseMetricReader _ = MetricReaderPeriodic (PeriodicMetricReaderConfig Nothing Nothing PushMetricExporterNone)


parsePushMetricExporter :: Object -> PushMetricExporterConfig
parsePushMetricExporter obj = case KM.lookup "exporter" obj of
  Just (Object e) -> parseExporterChoice e PushMetricExporterOtlpHttp PushMetricExporterConsole PushMetricExporterNone
  _ -> PushMetricExporterNone


parseLoggerProvider :: Object -> LoggerProviderConfig
parseLoggerProvider obj =
  LoggerProviderConfig
    { lpProcessors = case KM.lookup "processors" obj of
        Just (Array arr) -> Just $ V.toList $ V.map parseLogRecordProcessor arr
        _ -> Nothing
    }


parseLogRecordProcessor :: Value -> LogRecordProcessorConfig
parseLogRecordProcessor (Object obj) = case KM.lookup "batch" obj of
  Just (Object b) ->
    LogRecordProcessorBatch
      BatchLogRecordProcessorConfig
        { blpScheduleDelay = getIntMaybe "schedule_delay" b
        , blpExportTimeout = getIntMaybe "export_timeout" b
        , blpMaxQueueSize = getIntMaybe "max_queue_size" b
        , blpMaxExportBatchSize = getIntMaybe "max_export_batch_size" b
        , blpExporter = parseLogRecordExporter b
        }
  _ -> case KM.lookup "simple" obj of
    Just (Object s) ->
      LogRecordProcessorSimple
        SimpleLogRecordProcessorConfig
          { slpExporter = parseLogRecordExporter s
          }
    _ -> LogRecordProcessorBatch (BatchLogRecordProcessorConfig Nothing Nothing Nothing Nothing LogRecordExporterNone)
parseLogRecordProcessor _ =
  LogRecordProcessorBatch (BatchLogRecordProcessorConfig Nothing Nothing Nothing Nothing LogRecordExporterNone)


parseLogRecordExporter :: Object -> LogRecordExporterConfig
parseLogRecordExporter obj = case KM.lookup "exporter" obj of
  Just (Object e) -> parseExporterChoice e LogRecordExporterOtlpHttp LogRecordExporterConsole LogRecordExporterNone
  _ -> LogRecordExporterNone


-- Helpers

objectToTextMap :: Object -> Map Text Text
objectToTextMap = KM.foldrWithKey (\k v m -> Map.insert (AesonKey.toText k) (valueToText v) m) Map.empty


valueToText :: Value -> Text
valueToText (String t) = t
valueToText (Number n) = case toBoundedInteger n :: Maybe Int of
  Just i -> TL.toStrict $ toLazyText $ decimal i
  Nothing -> TL.toStrict $ toLazyText $ realFloat (toRealFloat n :: Double)
valueToText (Bool True) = "true"
valueToText (Bool False) = "false"
valueToText Null = ""
valueToText _ = ""


getText :: Value -> Maybe Text
getText (String t) = Just t
getText _ = Nothing


getTextMaybe :: Text -> Object -> Maybe Text
getTextMaybe key obj = KM.lookup (AesonKey.fromText key) obj >>= getText


getTextOr :: Text -> Text -> Object -> Text
getTextOr key def obj = case getTextMaybe key obj of
  Just v -> v
  Nothing -> def


getIntMaybe :: Text -> Object -> Maybe Int
getIntMaybe key obj = case KM.lookup (AesonKey.fromText key) obj of
  Just (Number n) -> toBoundedInteger n
  _ -> Nothing


getDoubleMaybe :: Text -> Object -> Maybe Double
getDoubleMaybe key obj = case KM.lookup (AesonKey.fromText key) obj of
  Just (Number n) -> Just (toRealFloat n)
  _ -> Nothing


getBoolMaybe :: Text -> Object -> Maybe Bool
getBoolMaybe key obj = case KM.lookup (AesonKey.fromText key) obj of
  Just (Bool b) -> Just b
  _ -> Nothing
