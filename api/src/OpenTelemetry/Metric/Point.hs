{-# LANGUAGE DuplicateRecordFields #-}

module OpenTelemetry.Metric.Point (
  GaugePoint,
  SumPoint,
  HistogramPoint,
) where

import Data.Int (Int64)
import Data.Word (Word64)
import OpenTelemetry.Attributes (AttributeMap)
import System.Clock (TimeSpec)


data GaugePoint = GaugePoint
  { value :: Int64
  , time :: TimeSpec
  , attributes :: AttributeMap
  }


data SumPoint = SumPoint
  { value :: Int64
  , timeWindow :: TimeWindow
  , attributes :: AttributeMap
  }


data HistogramPoint = HistogramPoint
  { count :: Word64
  , sum :: Int64
  , timeWindow :: TimeWindow
  , attributes :: AttributeMap
  }


data TimeWindow = TimeWindow
  { startExclusive :: TimeSpec
  , endInclusive :: TimeSpec
  }
