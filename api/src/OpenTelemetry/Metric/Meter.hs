{-# LANGUAGE ImportQualifiedPost #-}

module OpenTelemetry.Metric.Meter (
  MeterProvider,
  Meter,
  Version,
  Description,
  UnitOfMeasure,
  getMeter,
  createGauge,
  createObservableGauge,
  record,
  observe,
) where

import Data.Int (Int64)
import Data.Text (Text)
import OpenTelemetry.Attributes (AttributeMap)
import System.Clock qualified as Clock


data MeterProvider = MeterProvider


data Meter = Meter
  { scope :: Text
  , version :: Version
  , getTime :: (() -> IO Clock.TimeSpec)
  }


data Version
  = NoVersion
  | Version Text


getMeter :: MeterProvider -> Text -> Version -> IO Meter
getMeter _ scope version =
  pure $
    Meter
      { scope = scope
      , version = version
      , getTime = getTime
      }
  where
    getTime () = Clock.getTime (Clock.Monotonic)


mkSynchronousInstrument :: Meter -> InstrumentKind -> Text -> Description -> UnitOfMeasure -> IO SynchronousInstrument
mkSynchronousInstrument meter kind name desc unit =
  -- TODO use the meter to remember this instrument so the exporters can find it
  pure $ SynchronousInstrument meter kind name desc unit


createGauge :: Meter -> Text -> Description -> UnitOfMeasure -> IO SynchronousInstrument
createGauge meter = mkSynchronousInstrument meter GaugeKind


createObservableGauge :: Meter -> Text -> Description -> UnitOfMeasure -> (() -> IO [(Int64, AttributeMap)]) -> IO AsynchronousInstrument
createObservableGauge meter name desc unit measure = do
  meter <- createGauge meter name desc unit
  pure $ AsynchronousInstrument meter measure


data SynchronousInstrument = SynchronousInstrument
  { meter :: Meter
  , kind :: InstrumentKind
  , name :: Text
  , description :: Description
  , unit :: UnitOfMeasure
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


-- Records a measurement for a synchronous instrument.
-- Called by applications.
record :: SynchronousInstrument -> Int64 -> AttributeMap -> IO ()
record instr value attrs = pure () -- TODO: use the Meter put the value somewhere the exporters can get it


-- Refreshes the value for the given asynchronous instrument
-- Called by the exporters.
observe :: AsynchronousInstrument -> IO ()
observe (AsynchronousInstrument instr measure) = do
  measurements <- measure ()
  sequence_ $ map recordOne measurements
  where
    recordOne (val, attrs) = record instr val attrs
