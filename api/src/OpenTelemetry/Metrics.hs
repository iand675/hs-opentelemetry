{-# LANGUAGE OverloadedStrings #-}

{- | OpenTelemetry Metrics API (stable specification: https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/metrics/api.md).

 Applications obtain a 'Meter' from a 'MeterProvider' (typically the SDK implementation).
 Libraries should use the API only; the default global provider is a no-op until an SDK is installed.
-}
module OpenTelemetry.Metrics (
  -- * Provider
  MeterProvider (..),
  getMeter,
  noopMeterProvider,
  noopMeter,
  shutdownMeterProvider,
  forceFlushMeterProvider,
  getGlobalMeterProvider,
  setGlobalMeterProvider,

  -- * Meter
  Meter (..),

  -- * Instruments
  InstrumentKind (..),
  HistogramAggregation (..),
  AdvisoryParameters (..),
  defaultAdvisoryParameters,
  Counter (..),
  UpDownCounter (..),
  Histogram (..),
  Gauge (..),
  ObservableResult (..),
  ObservableCallbackHandle (..),
  ObservableCounter (..),
  ObservableUpDownCounter (..),
  ObservableGauge (..),

  -- * Instrument name validation (for SDK implementers)
  InstrumentName.validateInstrumentName,
  InstrumentName.validateInstrumentUnit,
) where

import Control.Monad.IO.Class (MonadIO, liftIO)
import Data.IORef (IORef, atomicWriteIORef, newIORef, readIORef)
import Data.Int (Int64)
import Data.Text (Text)
import OpenTelemetry.Internal.Common.Types (FlushResult (..), InstrumentationLibrary (..), ShutdownResult (..))
import OpenTelemetry.Internal.Metrics.Types
import qualified OpenTelemetry.Metrics.InstrumentName as InstrumentName
import System.IO.Unsafe (unsafePerformIO)


-- | Preferred accessor for obtaining a 'Meter' (spec: Get a Meter).
getMeter :: MeterProvider -> InstrumentationLibrary -> IO Meter
getMeter = meterProviderGetMeter


shutdownMeterProvider :: MeterProvider -> IO ShutdownResult
shutdownMeterProvider = meterProviderShutdown


forceFlushMeterProvider
  :: MeterProvider
  -> Maybe Int
  -- ^ Optional timeout in microseconds. @Nothing@ uses the SDK default (5s).
  -> IO FlushResult
forceFlushMeterProvider mp = meterProviderForceFlush mp


noopCounterI64 :: Counter Int64
noopCounterI64 = Counter (\_ _ -> pure ()) (pure False)


noopCounterDbl :: Counter Double
noopCounterDbl = Counter (\_ _ -> pure ()) (pure False)


noopUpDownI64 :: UpDownCounter Int64
noopUpDownI64 = UpDownCounter (\_ _ -> pure ()) (pure False)


noopUpDownDbl :: UpDownCounter Double
noopUpDownDbl = UpDownCounter (\_ _ -> pure ()) (pure False)


noopHistogram :: Histogram
noopHistogram = Histogram (\_ _ -> pure ()) (pure False)


noopGaugeI64 :: Gauge Int64
noopGaugeI64 = Gauge (\_ _ -> pure ()) (pure False)


noopGaugeDbl :: Gauge Double
noopGaugeDbl = Gauge (\_ _ -> pure ()) (pure False)


noopReg :: IO ObservableCallbackHandle
noopReg = pure (ObservableCallbackHandle (pure ()))


noopObservableCounter :: InstrumentationLibrary -> Text -> ObservableCounter a
noopObservableCounter scope name =
  ObservableCounter
    { observableCounterRegisterCallback = \_ -> noopReg
    , observableCounterInstrumentScope = scope
    , observableCounterInstrumentName = name
    , observableCounterEnabled = pure False
    }


noopObservableUpDown :: InstrumentationLibrary -> Text -> ObservableUpDownCounter a
noopObservableUpDown scope name =
  ObservableUpDownCounter
    { observableUpDownCounterRegisterCallback = \_ -> noopReg
    , observableUpDownCounterInstrumentScope = scope
    , observableUpDownCounterInstrumentName = name
    , observableUpDownCounterEnabled = pure False
    }


noopObservableGauge :: InstrumentationLibrary -> Text -> ObservableGauge a
noopObservableGauge scope name =
  ObservableGauge
    { observableGaugeRegisterCallback = \_ -> noopReg
    , observableGaugeInstrumentScope = scope
    , observableGaugeInstrumentName = name
    , observableGaugeEnabled = pure False
    }


-- | A 'Meter' that records no telemetry (used by 'noopMeterProvider').
noopMeter :: InstrumentationLibrary -> Meter
noopMeter scope =
  Meter
    { meterInstrumentationScope = scope
    , meterCreateCounterInt64 = \_ _ _ _ -> pure noopCounterI64
    , meterCreateCounterDouble = \_ _ _ _ -> pure noopCounterDbl
    , meterCreateUpDownCounterInt64 = \_ _ _ _ -> pure noopUpDownI64
    , meterCreateUpDownCounterDouble = \_ _ _ _ -> pure noopUpDownDbl
    , meterCreateHistogram = \_ _ _ _ -> pure noopHistogram
    , meterCreateGaugeInt64 = \_ _ _ _ -> pure noopGaugeI64
    , meterCreateGaugeDouble = \_ _ _ _ -> pure noopGaugeDbl
    , meterCreateObservableCounterInt64 = \name _ _ _ _ -> pure (noopObservableCounter scope name)
    , meterCreateObservableCounterDouble = \name _ _ _ _ -> pure (noopObservableCounter scope name)
    , meterCreateObservableUpDownCounterInt64 = \name _ _ _ _ -> pure (noopObservableUpDown scope name)
    , meterCreateObservableUpDownCounterDouble = \name _ _ _ _ -> pure (noopObservableUpDown scope name)
    , meterCreateObservableGaugeInt64 = \name _ _ _ _ -> pure (noopObservableGauge scope name)
    , meterCreateObservableGaugeDouble = \name _ _ _ _ -> pure (noopObservableGauge scope name)
    }


-- | No-op provider: safe for libraries; all measurements are discarded.
noopMeterProvider :: MeterProvider
noopMeterProvider =
  MeterProvider
    { meterProviderGetMeter = \scope -> pure (noopMeter scope)
    , meterProviderShutdown = pure ShutdownSuccess
    , meterProviderForceFlush = \_ -> pure FlushSuccess
    }


globalMeterProvider :: IORef MeterProvider
{-# NOINLINE globalMeterProvider #-}
globalMeterProvider = unsafePerformIO $ newIORef noopMeterProvider


getGlobalMeterProvider :: (MonadIO m) => m MeterProvider
getGlobalMeterProvider = liftIO $ readIORef globalMeterProvider


setGlobalMeterProvider :: (MonadIO m) => MeterProvider -> m ()
setGlobalMeterProvider p = liftIO $ atomicWriteIORef globalMeterProvider p
