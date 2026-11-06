{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.Metric.MultiReader (createMeterProviderWithReaders) where

import Control.Concurrent.Async (mapConcurrently)
import Control.Exception (evaluate)
import Control.Monad (forM, forM_, when)
import Data.List (nub)
import OpenTelemetry.Internal.Common.Types (FlushResult (..), InstrumentationLibrary, ShutdownResult (..), worstFlush, worstShutdown)
import OpenTelemetry.MeterProvider
import OpenTelemetry.Metric.Core
import OpenTelemetry.Resource (MaterializedResources)
import System.Mem.StableName (makeStableName)


{- | Register independent readers on one provider. Each gets its own aggregation,
cardinality accounting, callbacks, timestamps, and export lifecycle. Supply a
distinct exporter instance for each reader. An empty list retains the legacy
single-provider behavior; one reader returns its meter directly, without fanout.
-}
createMeterProviderWithReaders :: MaterializedResources -> SdkMeterProviderOptions -> [MetricReader] -> IO (MeterProvider, [SdkMeterEnv])
createMeterProviderWithReaders res opts [] = do
  (provider, env) <- createMeterProvider res opts
  pure (provider, [env])
createMeterProviderWithReaders res opts readers = do
  identities <- mapM (\reader -> evaluate (metricReaderExporter reader) >>= makeStableName) readers
  when (length (nub identities) /= length identities) $ ioError (userError "Each metric reader needs its own exporter instance")
  children <- forM readers $ \reader -> do
    (provider, env) <- createMeterProvider res opts {metricExporter = Just (metricReaderExporter reader)}
    setMetricReaderTemporality env (metricReaderTemporalityFor reader)
    pure (provider, env)
  let providers = map fst children
      provider =
        MeterProvider
          { meterProviderGetMeter = \scope -> combineMeters scope <$> mapM (\p -> meterProviderGetMeter p scope) providers
          , meterProviderForceFlush = \limit -> foldr worstFlush FlushSuccess <$> mapConcurrently (\p -> meterProviderForceFlush p limit) providers
          , meterProviderShutdown = \limit -> foldr worstShutdown ShutdownSuccess <$> mapConcurrently (\p -> meterProviderShutdown p limit) providers
          }
  pure (provider, map snd children)


combineMeters :: InstrumentationLibrary -> [Meter] -> Meter
combineMeters scope [] = noopMeter scope
combineMeters _ [one] = one
combineMeters scope meters =
  (noopMeter scope)
    { meterCreateCounterInt64 = \name unit desc advisory -> combineCounter <$> mapM (\m -> meterCreateCounterInt64 m name unit desc advisory) meters
    , meterCreateCounterDouble = \name unit desc advisory -> combineCounter <$> mapM (\m -> meterCreateCounterDouble m name unit desc advisory) meters
    , meterCreateUpDownCounterInt64 = \name unit desc advisory -> combineUpDownCounter <$> mapM (\m -> meterCreateUpDownCounterInt64 m name unit desc advisory) meters
    , meterCreateUpDownCounterDouble = \name unit desc advisory -> combineUpDownCounter <$> mapM (\m -> meterCreateUpDownCounterDouble m name unit desc advisory) meters
    , meterCreateHistogram = \name unit desc advisory -> combineHistogram <$> mapM (\m -> meterCreateHistogram m name unit desc advisory) meters
    , meterCreateGaugeInt64 = \name unit desc advisory -> combineGauge <$> mapM (\m -> meterCreateGaugeInt64 m name unit desc advisory) meters
    , meterCreateGaugeDouble = \name unit desc advisory -> combineGauge <$> mapM (\m -> meterCreateGaugeDouble m name unit desc advisory) meters
    , meterCreateObservableCounterInt64 = \name unit desc advisory callbacks -> combineObservableCounter <$> mapM (\m -> meterCreateObservableCounterInt64 m name unit desc advisory callbacks) meters
    , meterCreateObservableCounterDouble = \name unit desc advisory callbacks -> combineObservableCounter <$> mapM (\m -> meterCreateObservableCounterDouble m name unit desc advisory callbacks) meters
    , meterCreateObservableUpDownCounterInt64 = \name unit desc advisory callbacks -> combineObservableUpDownCounter <$> mapM (\m -> meterCreateObservableUpDownCounterInt64 m name unit desc advisory callbacks) meters
    , meterCreateObservableUpDownCounterDouble = \name unit desc advisory callbacks -> combineObservableUpDownCounter <$> mapM (\m -> meterCreateObservableUpDownCounterDouble m name unit desc advisory callbacks) meters
    , meterCreateObservableGaugeInt64 = \name unit desc advisory callbacks -> combineObservableGauge <$> mapM (\m -> meterCreateObservableGaugeInt64 m name unit desc advisory callbacks) meters
    , meterCreateObservableGaugeDouble = \name unit desc advisory callbacks -> combineObservableGauge <$> mapM (\m -> meterCreateObservableGaugeDouble m name unit desc advisory callbacks) meters
    }


combineCounter :: [Counter a] -> Counter a
combineCounter xs =
  Counter
    (\n attrs -> forM_ xs (\x -> counterAdd x n attrs))
    (or <$> mapM counterEnabled xs)


combineUpDownCounter :: [UpDownCounter a] -> UpDownCounter a
combineUpDownCounter xs =
  UpDownCounter
    (\n attrs -> forM_ xs (\x -> upDownCounterAdd x n attrs))
    (or <$> mapM upDownCounterEnabled xs)


combineHistogram :: [Histogram] -> Histogram
combineHistogram xs =
  Histogram
    (\n attrs -> forM_ xs (\x -> histogramRecord x n attrs))
    (or <$> mapM histogramEnabled xs)


combineGauge :: [Gauge a] -> Gauge a
combineGauge xs =
  Gauge
    (\n attrs -> forM_ xs (\x -> gaugeRecord x n attrs))
    (or <$> mapM gaugeEnabled xs)


combineObservableCounter :: [ObservableCounter a] -> ObservableCounter a
combineObservableCounter [] = error "No metric reader for observable instrument"
combineObservableCounter xs@(first : _) =
  first
    { observableCounterRegisterCallback = \callback -> do
        handles <- mapM (\x -> observableCounterRegisterCallback x callback) xs
        pure $ ObservableCallbackHandle (mapM_ unregisterObservableCallback handles)
    , observableCounterEnabled = or <$> mapM observableCounterEnabled xs
    }


combineObservableUpDownCounter :: [ObservableUpDownCounter a] -> ObservableUpDownCounter a
combineObservableUpDownCounter [] = error "No metric reader for observable instrument"
combineObservableUpDownCounter xs@(first : _) =
  first
    { observableUpDownCounterRegisterCallback = \callback -> do
        handles <- mapM (\x -> observableUpDownCounterRegisterCallback x callback) xs
        pure $ ObservableCallbackHandle (mapM_ unregisterObservableCallback handles)
    , observableUpDownCounterEnabled = or <$> mapM observableUpDownCounterEnabled xs
    }


combineObservableGauge :: [ObservableGauge a] -> ObservableGauge a
combineObservableGauge [] = error "No metric reader for observable instrument"
combineObservableGauge xs@(first : _) =
  first
    { observableGaugeRegisterCallback = \callback -> do
        handles <- mapM (\x -> observableGaugeRegisterCallback x callback) xs
        pure $ ObservableCallbackHandle (mapM_ unregisterObservableCallback handles)
    , observableGaugeEnabled = or <$> mapM observableGaugeEnabled xs
    }
