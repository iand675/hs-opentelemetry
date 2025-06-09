{-# LANGUAGE DuplicateRecordFields #-}

module OpenTelemetry.Metric.Point (
  GuagePoint,
  SumPoint,
  HistogramPoint,
) where

import Data.Int (Int64)
import Data.Word (Word64)
import OpenTelemetry.Attributes (AttributeMap)
import System.Clock (TimeSpec)


data GuagePoint = GuagePoint
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
