{-# LANGUAGE ScopedTypeVariables #-}

{- |
Module      :  OpenTelemetry.SDK
Copyright   :  (c) Ian Duncan, 2026
License     :  BSD-3
Description :  Unified SDK initialization for all three signals (traces, metrics, logs).
Stability   :  stable

= Overview

This is the recommended entry point for applications using the
OpenTelemetry SDK. It initializes all three signal providers
(TracerProvider, MeterProvider, LoggerProvider) from environment
variables in a single call.

= Quick example

@
import OpenTelemetry.SDK

main :: IO ()
main = withOpenTelemetry $ \otel -> do
  let tracer = makeTracer (otelTracerProvider otel) "my-app" tracerOptions
  -- ... application code ...
@

All configuration is via the standard @OTEL_*@ environment variables:

* @OTEL_SERVICE_NAME@ — service name resource attribute
* @OTEL_TRACES_EXPORTER@ — trace exporter (default: @otlp@)
* @OTEL_METRICS_EXPORTER@ — metrics exporter (default: @otlp@)
* @OTEL_LOGS_EXPORTER@ — logs exporter (default: @otlp@)
* @OTEL_EXPORTER_OTLP_ENDPOINT@ — OTLP endpoint
* @OTEL_METRIC_EXPORT_INTERVAL@ — metrics export interval (ms, default: 60000)

See "OpenTelemetry.Trace", "OpenTelemetry.Metric", and "OpenTelemetry.Log"
for signal-specific configuration and per-signal initialization.
-}
module OpenTelemetry.SDK (
  -- * Unified initialization
  OTelSignals (..),
  initializeOpenTelemetry,
  withOpenTelemetry,
) where

import Control.Exception (SomeException, bracket, catch)
import Control.Monad (void)
import OpenTelemetry.Configuration.Create (OTelSignals (..))
import OpenTelemetry.Log (initializeGlobalLoggerProvider, shutdownLoggerProvider)
import OpenTelemetry.Metric (MeterProviderHandle (..), initializeGlobalMeterProvider, shutdownMeterProviderHandle)
import OpenTelemetry.Trace (initializeGlobalTracerProvider, shutdownTracerProvider)


{- | Initialize all three signal providers from @OTEL_*@ environment variables,
install them as globals, and return an 'OTelSignals' with a unified shutdown handle.

@since 1.0.0.0
-}
initializeOpenTelemetry :: IO OTelSignals
initializeOpenTelemetry = do
  tp <- initializeGlobalTracerProvider
  mph <- initializeGlobalMeterProvider
  lp <- initializeGlobalLoggerProvider
  let shutdown = do
        void (shutdownTracerProvider tp Nothing) `catch` \(_ :: SomeException) -> pure ()
        shutdownMeterProviderHandle mph `catch` \(_ :: SomeException) -> pure ()
        void (shutdownLoggerProvider lp Nothing) `catch` \(_ :: SomeException) -> pure ()
  pure
    OTelSignals
      { otelTracerProvider = tp
      , otelMeterProvider = meterProviderHandleProvider mph
      , otelLoggerProvider = lp
      , otelPropagators = mempty
      , otelShutdown = shutdown
      }


{- | Initialize all signal providers, run an action, then shut everything down.

@
main = withOpenTelemetry $ \otel -> do
  -- use otelTracerProvider, otelMeterProvider, otelLoggerProvider
  runMyApp
@

@since 1.0.0.0
-}
withOpenTelemetry :: (OTelSignals -> IO a) -> IO a
withOpenTelemetry = bracket initializeOpenTelemetry otelShutdown
