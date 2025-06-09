{-# LANGUAGE ImportQualifiedPost #-}

module OpenTelemetry.Metric.Meter (
  MeterProvider,
  getMeter,
  Version,
  Meter,
  Description,
  UnitOfMeasure,
  createGauge,
  createObservableGauge,
  record,
  observe,
) where

import Data.Int (Int64)
import Data.Text (Text)
import OpenTelemetry.Attributes (AttributeMap)


data MeterProvider = MeterProvider
  { getMeter :: Text -> Version -> IO Meter
  }


data Meter = Meter
  { scope :: Text
  , version :: Version
  , mkSynchronousInstrument :: InstrumentKind -> Text -> Description -> UnitOfMeasure -> IO SynchronousInstrument
  }


data Version
  = NoVersion
  | Version Text


createGauge :: Meter -> Text -> Description -> UnitOfMeasure -> IO SynchronousInstrument
createGauge meter = mkSynchronousInstrument meter GaugeKind


createObservableGauge :: Meter -> Text -> Description -> UnitOfMeasure -> (() -> IO [(Int64, AttributeMap)]) -> IO AsynchronousInstrument
createObservableGauge meter name desc unit measure = do
  meter <- createGauge meter name desc unit
  pure $ AsynchronousInstrument meter measure


data SynchronousInstrument = SynchronousInstrument
  { kind :: InstrumentKind
  , name :: Text
  , description :: Description
  , unit :: UnitOfMeasure
  , record :: Int64 -> AttributeMap -> IO ()
  }


data AsynchronousInstrument = AsynchronousInstrument
  { synch :: SynchronousInstrument
  , measure :: (() -> IO [(Int64, AttributeMap)])
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


-- Refreshes the value for the given asynchronous instrument
-- Called by the exporters.
observe :: AsynchronousInstrument -> IO ()
observe (AsynchronousInstrument instr measure) = do
  measurements <- measure ()
  sequence_ $ map recordOne measurements
  where
    recordOne (val, attrs) = record instr val attrs
