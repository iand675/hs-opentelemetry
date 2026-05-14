{-# LANGUAGE ImportQualifiedPost #-}

module OpenTelemetry.Metric.Meter (
  MeterProvider (getMeter),
  Version (..),
  Meter,
  Description (..),
  UnitOfMeasure (..),
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


{- | The entry point to the metrics API
| See https://opentelemetry.io/docs/specs/otel/metrics/api/#meterprovider
|
| Example usage:
|    meter <- getMeter meterProvider "home" NoVersion
|    gauge <- createGauge meter "kettle.temp" (Description "The temperature of the water in the kettle") (Unit "Celcius")
|    record guage 55 (H.singleton "room" kitchen))
-}
data MeterProvider = MeterProvider
  { getMeter :: Text -> Version -> IO Meter
  -- ^ Generates a Meter
  -- TODO add schema_url and attributes
  }


{- | The Meter is responsible for creating Instruments, which allow us to record Measurements.
| See https://opentelemetry.io/docs/specs/otel/metrics/api/#meter
-}
data Meter = Meter
  { scope :: Text
  , version :: Version
  , mkSynchronousInstrument :: InstrumentKind -> Text -> Description -> UnitOfMeasure -> IO SynchronousInstrument
  }


data Version
  = NoVersion
  | Version Text


-- | https://opentelemetry.io/docs/specs/otel/metrics/api/#gauge-creation
createGauge :: Meter -> Text -> Description -> UnitOfMeasure -> IO SynchronousInstrument
createGauge meter = mkSynchronousInstrument meter GaugeKind


-- | https://opentelemetry.io/docs/specs/otel/metrics/api/#asynchronous-gauge-creation
createObservableGauge :: Meter -> Text -> Description -> UnitOfMeasure -> TakeMeasurements -> IO AsynchronousInstrument
createObservableGauge meter name desc unit measure = AsynchronousInstrument measure <$> createGauge meter name desc unit


-- | https://opentelemetry.io/docs/specs/otel/metrics/api/#counter-creation
createCounter :: Meter -> Text -> Description -> UnitOfMeasure -> AggregationTemporality -> IO SynchronousInstrument
createCounter meter name desc unit aggregation = mkSynchronousInstrument meter (SumKind (SumKindData OnlyUp aggregation)) name desc unit


-- | https://opentelemetry.io/docs/specs/otel/metrics/api/#asynchronous-counter-creation
createObservableCounter :: Meter -> Text -> Description -> UnitOfMeasure -> AggregationTemporality -> TakeMeasurements -> IO AsynchronousInstrument
createObservableCounter meter name desc unit aggregation measure = AsynchronousInstrument measure <$> createCounter meter name desc unit aggregation


-- | https://opentelemetry.io/docs/specs/otel/metrics/api/#updowncounter-creation
createUpDownCounter :: Meter -> Text -> Description -> UnitOfMeasure -> AggregationTemporality -> IO SynchronousInstrument
createUpDownCounter meter name desc unit aggregation = mkSynchronousInstrument meter (SumKind (SumKindData UpAndDown aggregation)) name desc unit


-- | https://opentelemetry.io/docs/specs/otel/metrics/api/#asynchronous-updowncounter-creation
createObservableUpDownCounter :: Meter -> Text -> Description -> UnitOfMeasure -> AggregationTemporality -> TakeMeasurements -> IO AsynchronousInstrument
createObservableUpDownCounter meter name desc unit aggregation measure = AsynchronousInstrument measure <$> createUpDownCounter meter name desc unit aggregation


-- | https://opentelemetry.io/docs/specs/otel/metrics/api/#histogram-creation
createHistogram :: Meter -> Text -> Description -> UnitOfMeasure -> AggregationTemporality -> IO SynchronousInstrument
createHistogram meter name desc unit aggregation = mkSynchronousInstrument meter (HistogramKind aggregation) name desc unit


-- | https://opentelemetry.io/docs/specs/otel/metrics/api/#histogram-creation
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
  | SumKind SumKindData
  | HistogramKind AggregationTemporality


data SumKindData = SumKindData
  { monotonic :: Monotonicity
  , aggregation :: AggregationTemporality
  }


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
