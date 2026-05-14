{-# LANGUAGE DuplicateRecordFields #-}

{- | Metric Points are the data elements in a metrics timeseries stream.
 - See https://opentelemetry.io/docs/specs/otel/metrics/data-model/#metric-points
-}
module OpenTelemetry.Metric.Point (
  GaugePoint (..),
  SumPoint (..),
  HistogramPoint (..),
) where

import Data.Int (Int64)
import Data.Word (Word64)
import OpenTelemetry.Attributes (AttributeMap)
import System.Clock (TimeSpec)


{- | The data points in a Gauge metric
See https://opentelemetry.io/docs/specs/otel/metrics/data-model/#gauge
-}
data GaugePoint = GaugePoint
  { value :: Int64
  , time :: TimeSpec
  -- ^ Corresponds to time_unix_nano here https://github.com/open-telemetry/opentelemetry-proto/blob/8672494217bfc858e2a82a4e8c623d4a5530473a/opentelemetry/proto/metrics/v1/metrics.proto#L368
  , attributes :: AttributeMap
  }


{- | The data points in a sum metric
See https://opentelemetry.io/docs/specs/otel/metrics/data-model/#sums
-}
data SumPoint = SumPoint
  { value :: Int64
  , timeWindow :: TimeWindow
  , attributes :: AttributeMap
  }


{- | The data points in a histogram metric
See https://opentelemetry.io/docs/specs/otel/metrics/data-model/#histogram
-}
data HistogramPoint = HistogramPoint
  { count :: Word64
  , sum :: Int64
  , timeWindow :: TimeWindow
  , attributes :: AttributeMap
  -- TODO add the buckets, etc
  }


-- | Period of time over which a point applies.
data TimeWindow = TimeWindow
  { startExclusive :: TimeSpec
  -- ^ Corresponds to start_time_unix_nano
  , endInclusive :: TimeSpec
  -- ^ Corresponds to time_unix_nano
  }
