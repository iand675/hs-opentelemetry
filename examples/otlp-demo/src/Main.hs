{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

{- |
A self-contained integration demo that exercises traces, metrics, and logs
through the OTel SDK and sends them to a local OpenTelemetry Collector.

Run the collector first (inside examples\/otlp-demo\/):

@
docker compose up -d
@

Then run this program:

@
OTEL_EXPERIMENTAL_CONFIG_FILE=otel-config.yaml cabal run otlp-demo
@

Watch the collector's stdout for the arriving data:

@
docker compose logs -f collector
@

Expected output: ResourceSpans, ResourceMetrics (demo.requests counter +
demo.request.duration histogram), and ResourceLogs (INFO, WARN, ERROR records).
-}
module Main where

import Control.Concurrent (threadDelay)
import Control.Exception (finally)
import Control.Monad (forM_)
import Data.HashMap.Strict (fromList)
import qualified Data.Text as T
import OpenTelemetry.Attributes (
  addAttribute,
  defaultAttributeLimits,
  emptyAttributes,
 )
import OpenTelemetry.Attributes.Attribute (ToAttribute (..))
import OpenTelemetry.Configuration (
  OTelSignals (..),
  initializeFromConfigFile,
  initializeFromText,
 )
import OpenTelemetry.Internal.Common.Types (instrumentationLibrary)
import OpenTelemetry.Internal.Log.Types (
  LogRecordArguments (..),
  SeverityNumber (..),
  emptyLogRecordArguments,
 )
import OpenTelemetry.Log.Core (emitLogRecord, makeLogger)
import OpenTelemetry.LogAttributes (AnyValue (..))
import OpenTelemetry.Metric.Core (
  Counter (..),
  Histogram (..),
  Meter (..),
  defaultAdvisoryParameters,
  getMeter,
 )
import OpenTelemetry.Trace.Core (
  defaultSpanArguments,
  inSpan,
  makeTracer,
  tracerOptions,
 )


-- | Fallback config used when @OTEL_EXPERIMENTAL_CONFIG_FILE@ is not set.
fallbackConfig :: T.Text
fallbackConfig =
  T.unlines
    [ "sdk:"
    , "  disabled: false"
    , "  resource:"
    , "    attributes:"
    , "      - name: service.name"
    , "        value: hs-otel-demo"
    , "  tracer_provider:"
    , "    processors:"
    , "      - batch:"
    , "          exporter:"
    , "            otlp:"
    , "              protocol: http/protobuf"
    , "              endpoint: http://localhost:4318"
    , "  meter_provider:"
    , "    readers:"
    , "      - periodic:"
    , "          interval: 2000"
    , "          exporter:"
    , "            otlp:"
    , "              protocol: http/protobuf"
    , "              endpoint: http://localhost:4318"
    , "  logger_provider:"
    , "    processors:"
    , "      - batch:"
    , "          exporter:"
    , "            otlp:"
    , "              protocol: http/protobuf"
    , "              endpoint: http://localhost:4318"
    , "propagator:"
    , "  composite:"
    , "    - tracecontext"
    , "    - baggage"
    ]


main :: IO ()
main = do
  putStrLn "Starting hs-opentelemetry integration demo..."
  putStrLn "If a collector is running, watch its logs for incoming telemetry."
  putStrLn ""

  mComponents <- initializeFromConfigFile
  components <- case mComponents of
    Just c -> do
      putStrLn "Loaded config from OTEL_EXPERIMENTAL_CONFIG_FILE"
      pure c
    Nothing -> do
      putStrLn "OTEL_EXPERIMENTAL_CONFIG_FILE not set — using built-in fallback config"
      initializeFromText fallbackConfig

  finally (runDemo components) (otelShutdown components)


runDemo :: OTelSignals -> IO ()
runDemo OTelSignals {..} = do
  let lib = instrumentationLibrary "hs-otel-demo" "0.1.0"
      tracer = makeTracer otelTracerProvider "hs-otel-demo" tracerOptions
      logger = makeLogger otelLoggerProvider lib

  meter <- getMeter otelMeterProvider lib

  -- Create metric instruments
  requestCounter <-
    meterCreateCounterInt64
      meter
      "demo.requests"
      (Just "{request}")
      (Just "Total number of demo requests processed")
      defaultAdvisoryParameters

  latencyHistogram <-
    meterCreateHistogram
      meter
      "demo.request.duration"
      (Just "s")
      (Just "Duration of demo request processing")
      defaultAdvisoryParameters

  -- Log records
  putStrLn "Emitting log records..."
  emitLogRecord logger $
    emptyLogRecordArguments
      { severityNumber = Just Info
      , severityText = Just "Info"
      , body = TextValue "Application started successfully"
      , attributes =
          fromList
            [ ("deployment.environment", TextValue "development")
            , ("host.name", TextValue "localhost")
            ]
      }

  emitLogRecord logger $
    emptyLogRecordArguments
      { severityNumber = Just Warn
      , severityText = Just "Warn"
      , body = TextValue "This is a warning log — for demo purposes only"
      , attributes = fromList [("demo.warning", BoolValue True)]
      }

  -- Traces + metrics
  putStrLn "Creating spans and recording metrics..."
  inSpan tracer "demo.operation" defaultSpanArguments $ do
    forM_ (["GET", "POST", "GET", "DELETE", "GET"] :: [T.Text]) $ \method -> do
      inSpan tracer ("handle." <> method) defaultSpanArguments $ do
        let methodAttr = addAttribute defaultAttributeLimits emptyAttributes "http.request.method" (toAttribute method)
        counterAdd requestCounter 1 methodAttr
        let latency = case method of
              "GET" -> 0.05
              "POST" -> 0.12
              "DELETE" -> 0.08
              _ -> 0.07 :: Double
        histogramRecord latencyHistogram latency methodAttr

  -- Error log
  emitLogRecord logger $
    emptyLogRecordArguments
      { severityNumber = Just Error
      , severityText = Just "Error"
      , body = TextValue "Simulated error for demo — everything is fine"
      , attributes =
          fromList
            [ ("error.type", TextValue "DemoError")
            , ("demo.simulated", BoolValue True)
            ]
      }

  -- Wait for the periodic metric reader to flush (interval is 2s in the config)
  putStrLn "Waiting 3 seconds for the periodic metric reader to flush..."
  threadDelay (3 * 1_000_000)

  putStrLn ""
  putStrLn "Demo complete. Collector should have received:"
  putStrLn "  ResourceSpans  (demo.operation + handle.* spans)"
  putStrLn "  ResourceMetrics (demo.requests counter + demo.request.duration histogram)"
  putStrLn "  ResourceLogs   (INFO, WARN, ERROR records)"
