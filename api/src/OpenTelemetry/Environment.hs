module OpenTelemetry.Environment (
  lookupBooleanEnv,
  MetricsExporterSelection (..),
  lookupMetricsExporterSelection,
  lookupMetricExportIntervalMillis,
  MetricsExemplarFilter (..),
  lookupMetricsExemplarFilter,
) where

import qualified Data.Char as C
import Data.List (dropWhileEnd)
import System.Environment (lookupEnv)
import Text.Read (readMaybe)


{- | Does the given value of an environment variable correspond to "true" according
to [the OpenTelemetry specification](https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/#boolean-value)?
-}
isTrue :: String -> Bool
isTrue = ("true" ==) . map C.toLower


lookupBooleanEnv :: String -> IO Bool
lookupBooleanEnv = fmap (maybe False isTrue) . lookupEnv


-- | Parsed value of @OTEL_METRICS_EXPORTER@ (first entry if comma-separated).
-- See <https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/#exporter-selection>.
data MetricsExporterSelection
  = MetricsExporterNone
  | MetricsExporterOtlp
  | MetricsExporterPrometheus
  | MetricsExporterConsole
  deriving (Eq, Show)


trimSpaces :: String -> String
trimSpaces = dropWhile C.isSpace . dropWhileEnd C.isSpace


-- | Read @OTEL_METRICS_EXPORTER@. Unknown or empty values return 'Nothing' (caller may default to OTLP).
lookupMetricsExporterSelection :: IO (Maybe MetricsExporterSelection)
lookupMetricsExporterSelection = do
  me <- lookupEnv "OTEL_METRICS_EXPORTER"
  case me of
    Nothing -> pure Nothing
    Just raw ->
      let firstSeg = trimSpaces $ case break (== ',') raw of
            (a, _) -> a
          key = map C.toLower $ trimSpaces firstSeg
       in pure $ case key of
            "" -> Nothing
            "none" -> Just MetricsExporterNone
            "otlp" -> Just MetricsExporterOtlp
            "prometheus" -> Just MetricsExporterPrometheus
            "console" -> Just MetricsExporterConsole
            _ -> Nothing


-- | Read @OTEL_METRIC_EXPORT_INTERVAL@ (milliseconds between periodic export cycles).
-- See <https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/>.
lookupMetricExportIntervalMillis :: IO (Maybe Int)
lookupMetricExportIntervalMillis = do
  me <- lookupEnv "OTEL_METRIC_EXPORT_INTERVAL"
  pure $ case me >>= readMaybe . trimSpaces of
    Just n | n > 0 -> Just n
    _ -> Nothing


-- | Parsed @OTEL_METRICS_EXEMPLAR_FILTER@ (when present).
data MetricsExemplarFilter
  = MetricsExemplarFilterTraceBased
  | MetricsExemplarFilterAlwaysOn
  | MetricsExemplarFilterAlwaysOff
  deriving (Eq, Show)


-- | Read @OTEL_METRICS_EXEMPLAR_FILTER@ (first segment if comma-separated). Unknown values return 'Nothing'.
lookupMetricsExemplarFilter :: IO (Maybe MetricsExemplarFilter)
lookupMetricsExemplarFilter = do
  me <- lookupEnv "OTEL_METRICS_EXEMPLAR_FILTER"
  case me of
    Nothing -> pure Nothing
    Just raw ->
      let firstSeg = trimSpaces $ case break (== ',') raw of
            (a, _) -> a
          key = map C.toLower $ trimSpaces firstSeg
       in pure $ case key of
            "" -> Nothing
            "trace_based" -> Just MetricsExemplarFilterTraceBased
            "always_on" -> Just MetricsExemplarFilterAlwaysOn
            "always_off" -> Just MetricsExemplarFilterAlwaysOff
            _ -> Nothing
