{-# LANGUAGE NumericUnderscores #-}

-- | A single timeout for an entire OTLP batch, including serialization and retries.
module OpenTelemetry.Exporter.OTLP.Internal.Timeout (
  withExportTimeout,
) where

import Data.Maybe (fromMaybe)
import OpenTelemetry.Internal.Common.Types (ExportResult (..))
import System.Timeout (timeout)


{- | Bound a batch export by its configured timeout in milliseconds.

Zero retains the existing explicit no-timeout setting. Invalid negative values
use the default of ten seconds. Convert through 'Integer' so a large configured
timeout cannot overflow into a negative (unlimited) timeout.

The timeout encloses the exporter's exception handling: our deadline becomes a
failure result, while an earlier caller timeout or cancellation still propagates.
-}
withExportTimeout :: Maybe Int -> IO ExportResult -> IO ExportResult
withExportTimeout configured export =
  if millis == 0
    then export
    else fromMaybe (Failure Nothing) <$> timeout micros export
  where
    millis = case configured of
      Just n | n >= 0 -> n
      _ -> 10_000
    micros = fromInteger (min (toInteger (maxBound :: Int)) (toInteger millis * 1_000))
