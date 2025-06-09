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
  createCounter,
  createObservableCounter,
  createUpDownCounter,
  createObservableUpDownCounter,
  createHistogram,
  createObservableHistogram,
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


createObservableGauge :: Meter -> Text -> Description -> UnitOfMeasure -> TakeMeasurements -> IO AsynchronousInstrument
createObservableGauge meter name desc unit measure = AsynchronousInstrument measure <$> createGauge meter name desc unit


createCounter :: Meter -> Text -> Description -> UnitOfMeasure -> AggregationTemporality -> IO SynchronousInstrument
createCounter meter name desc unit aggregation = mkSynchronousInstrument meter (SumKind OnlyUp aggregation) name desc unit


createObservableCounter :: Meter -> Text -> Description -> UnitOfMeasure -> AggregationTemporality -> TakeMeasurements -> IO AsynchronousInstrument
createObservableCounter meter name desc unit aggregation measure = AsynchronousInstrument measure <$> createCounter meter name desc unit aggregation


createUpDownCounter :: Meter -> Text -> Description -> UnitOfMeasure -> AggregationTemporality -> IO SynchronousInstrument
createUpDownCounter meter name desc unit aggregation = mkSynchronousInstrument meter (SumKind UpAndDown aggregation) name desc unit


createObservableUpDownCounter :: Meter -> Text -> Description -> UnitOfMeasure -> AggregationTemporality -> TakeMeasurements -> IO AsynchronousInstrument
createObservableUpDownCounter meter name desc unit aggregation measure = AsynchronousInstrument measure <$> createUpDownCounter meter name desc unit aggregation


createHistogram :: Meter -> Text -> Description -> UnitOfMeasure -> AggregationTemporality -> IO SynchronousInstrument
createHistogram meter name desc unit aggregation = mkSynchronousInstrument meter (HistogramKind aggregation) name desc unit


createObservableHistogram :: Meter -> Text -> Description -> UnitOfMeasure -> AggregationTemporality -> TakeMeasurements -> IO AsynchronousInstrument
createObservableHistogram meter name desc unit aggregation measure = AsynchronousInstrument measure <$> createHistogram meter name desc unit aggregation


data SynchronousInstrument = SynchronousInstrument
  { kind :: InstrumentKind
  , name :: Text
  , description :: Description
  , unit :: UnitOfMeasure
  , record :: Int64 -> AttributeMap -> IO ()
  }


type TakeMeasurements = (() -> IO [(Int64, AttributeMap)])


data AsynchronousInstrument = AsynchronousInstrument
  { measure :: TakeMeasurements
  , synch :: SynchronousInstrument
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
observe (AsynchronousInstrument measure instr) = do
  measurements <- measure ()
  sequence_ $ map recordOne measurements
  where
    recordOne (val, attrs) = record instr val attrs
