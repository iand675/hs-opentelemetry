{- |
Module      : OpenTelemetry.Environment
Copyright   : (c) Ian Duncan, 2024-2026
License     : BSD-3
Description : Read standard OTEL_* environment variables for SDK configuration.
Stability   : experimental

Helpers for reading OpenTelemetry environment variables that control exporter
selection, metric export intervals, exemplar filters, and log exporter choice.
Used by the SDK during provider initialization.
-}
module OpenTelemetry.Environment (
  lookupBooleanEnv,
  MetricsExporterSelection (..),
  lookupMetricsExporterSelection,
  lookupMetricExportIntervalMillis,
  lookupMetricExportTimeoutMillis,
  MetricsExemplarFilter (..),
  lookupMetricsExemplarFilter,
  LogsExporterSelection (..),
  lookupLogsExporterSelection,
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


{- | Parsed value of @OTEL_METRICS_EXPORTER@ (first entry if comma-separated).
See <https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/#exporter-selection>.
-}
data MetricsExporterSelection
  = MetricsExporterNone
  | MetricsExporterOtlp
  | MetricsExporterPrometheus
  | MetricsExporterConsole
  | -- | A name not in the built-in set; looked up via the exporter registry.
    MetricsExporterCustom !String
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
          other -> Just (MetricsExporterCustom other)


{- | Read @OTEL_METRIC_EXPORT_INTERVAL@ (milliseconds between periodic export cycles).
See <https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/>.
-}
lookupMetricExportIntervalMillis :: IO (Maybe Int)
lookupMetricExportIntervalMillis = do
  me <- lookupEnv "OTEL_METRIC_EXPORT_INTERVAL"
  pure $ case me >>= readMaybe . trimSpaces of
    Just n | n > 0 -> Just n
    _ -> Nothing


{- | Read @OTEL_METRIC_EXPORT_TIMEOUT@ (milliseconds allowed per export call).
See <https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/>.
-}
lookupMetricExportTimeoutMillis :: IO (Maybe Int)
lookupMetricExportTimeoutMillis = do
  me <- lookupEnv "OTEL_METRIC_EXPORT_TIMEOUT"
  pure $ case me >>= readMaybe . trimSpaces of
    Just n | n > 0 -> Just n
    _ -> Nothing


{- | Parsed value of @OTEL_LOGS_EXPORTER@ (first entry if comma-separated).
See <https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/#exporter-selection>.

@since 0.4.0.0
-}
data LogsExporterSelection
  = LogsExporterNone
  | LogsExporterOtlp
  | LogsExporterConsole
  | -- | A name not in the built-in set; looked up via the exporter registry.
    LogsExporterCustom !String
  deriving (Eq, Show)


{- | Read @OTEL_LOGS_EXPORTER@. Empty values return 'Nothing' (caller defaults to OTLP).
Unknown names are returned as 'LogsExporterCustom' for registry lookup.
-}
lookupLogsExporterSelection :: IO (Maybe LogsExporterSelection)
lookupLogsExporterSelection = do
  me <- lookupEnv "OTEL_LOGS_EXPORTER"
  case me of
    Nothing -> pure Nothing
    Just raw ->
      let firstSeg = trimSpaces $ case break (== ',') raw of
            (a, _) -> a
          key = map C.toLower $ trimSpaces firstSeg
      in pure $ case key of
          "" -> Nothing
          "none" -> Just LogsExporterNone
          "otlp" -> Just LogsExporterOtlp
          "console" -> Just LogsExporterConsole
          other -> Just (LogsExporterCustom other)


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
