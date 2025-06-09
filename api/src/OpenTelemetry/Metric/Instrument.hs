{-# LANGUAGE DuplicateRecordFields #-}

module OpenTelemetry.Metric.Instrument where

import Data.Int (Int64)
import Data.Text
import OpenTelemetry.Attributes (AttributeMap)


data Instrument = Instrument
  { kind :: InstrumentKind
  , name :: Text
  , description :: Description
  , unit :: UnitOfMeasure
  }


data InstrumentKind
  = GaugeKind
  | SumKind
      { monotonic :: Monotonicity
      , aggregation :: AggregationTemporality
      }
  | HistogramKind {aggregation :: AggregationTemporality}


-- Whether each measurement is the newest cumulative value, or a delta to be added to previous results
data AggregationTemporality
  = Cumulative
  | Delta


data Monotonicity
  = UpAndDown
  | OnlyUp


data Description
  = NoDescription
  | Description Text


data UnitOfMeasure
  = NoUnit
  | Unit Text


-- Uses an instrument to record a measurement
record :: Instrument -> Int64 -> AttributeMap -> IO ()
record _ value attrs = pure () -- TODO: actually record it
