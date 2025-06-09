module OpenTelemetry.Metric.Meter (
  MeterProvider,
  getMeter,
  createGauge,
) where

import Data.Text
import OpenTelemetry.Metric.Instrument


data MeterProvider = MeterProvider


data Meter = Meter
  { scope :: Text
  , version :: Version
  }


data Version
  = NoVersion
  | Version Text


getMeter :: MeterProvider -> Text -> Version -> IO Meter
getMeter _ scope version = pure $ Meter scope version


createGauge :: Meter -> Text -> Description -> UnitOfMeasure -> IO Instrument
createGauge _ name desc unit = pure $ Instrument GaugeKind name desc unit
