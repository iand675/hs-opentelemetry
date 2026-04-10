{-# LANGUAGE OverloadedStrings #-}

{- |
Module      :  OpenTelemetry.Metric.Core
Copyright   :  (c) Ian Duncan, 2021-2026
License     :  BSD-3
Description :  OpenTelemetry Metrics API
Stability   :  experimental

= Overview

This module defines the Metrics API for recording measurements in your
application. Libraries use this API to record metrics; the SDK provides
the actual aggregation and export.

Application authors should import @OpenTelemetry.Metric@ from the SDK
package instead, which re-exports everything here plus SDK initialization.

= Quick example

@
import OpenTelemetry.Metric.Core

main :: IO ()
main = do
  -- Obtain the global MeterProvider (set up by the SDK)
  mp <- getGlobalMeterProvider
  meter <- getMeter mp myInstrumentationLibrary

  -- Create instruments
  requestCounter <- meterCreateCounterInt64 meter "http.requests" "" Nothing defaultAdvisoryParameters
  latencyHist    <- meterCreateHistogram meter "http.request.duration" "ms" Nothing defaultAdvisoryParameters

  -- Record measurements
  counterAdd requestCounter 1 [("method", toAttribute "GET")]
  histogramRecord latencyHist 42.5 [("method", toAttribute "GET")]
@

= Instrument types

== Synchronous instruments

These are called inline with your application code:

* 'Counter' : monotonically increasing sum (e.g. request count, bytes sent).
  Use @counterAdd counter value attrs@.
* 'UpDownCounter' : sum that can increase or decrease (e.g. active connections,
  queue depth). Use @upDownCounterAdd counter value attrs@.
* 'Histogram' : distribution of values (e.g. request latency, payload size).
  Use @histogramRecord histogram value attrs@.
* 'Gauge' : point-in-time value (e.g. CPU temperature, memory usage).
  Use @gaugeRecord gauge value attrs@.

== Asynchronous (observable) instruments

These are read by callbacks during export:

* 'ObservableCounter' : monotonic sum read on demand (e.g. CPU time).
* 'ObservableUpDownCounter' : bidirectional sum read on demand.
* 'ObservableGauge' : snapshot value read on demand (e.g. disk free space).

Register a callback when creating the instrument:

@
obsGauge <- meterCreateObservableGaugeDouble meter
  "system.memory.usage" "By" Nothing defaultAdvisoryParameters
  (\result -> do
    memInfo <- getMemoryUsage
    observeDouble result memInfo [("state", toAttribute "used")]
  )
@

= No-op behavior

Before the SDK is installed, 'noopMeterProvider' is the global default.
All measurements are silently discarded. This makes it safe for libraries
to instrument unconditionally.

= Spec reference

<https://opentelemetry.io/docs/specs/otel/metrics/api/>
-}
module OpenTelemetry.Metric.Core (
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
import OpenTelemetry.Internal.Metric.Types
import qualified OpenTelemetry.Metric.InstrumentName as InstrumentName
import System.IO.Unsafe (unsafePerformIO)


-- | Preferred accessor for obtaining a 'Meter' (spec: Get a Meter).
--
-- @since 0.0.1.0
getMeter :: MeterProvider -> InstrumentationLibrary -> IO Meter
getMeter = meterProviderGetMeter


-- | @since 0.0.1.0
shutdownMeterProvider :: MeterProvider -> IO ShutdownResult
shutdownMeterProvider = meterProviderShutdown


-- | @since 0.0.1.0
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
--
-- @since 0.0.1.0
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
--
-- @since 0.0.1.0
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


-- | @since 0.0.1.0
getGlobalMeterProvider :: (MonadIO m) => m MeterProvider
getGlobalMeterProvider = liftIO $ readIORef globalMeterProvider


-- | @since 0.0.1.0
setGlobalMeterProvider :: (MonadIO m) => MeterProvider -> m ()
setGlobalMeterProvider p = liftIO $ atomicWriteIORef globalMeterProvider p
