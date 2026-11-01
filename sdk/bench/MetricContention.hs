{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE OverloadedStrings #-}

-- Run with +RTS -N4 -T for a four-capability allocation/throughput comparison.
-- Each invocation creates fresh instruments and verifies the exported count.
module Main (main) where

import Control.Concurrent (threadDelay)
import Control.Concurrent.Async (forConcurrently_, wait, withAsync)
import Control.Monad (forM, unless)
import Data.IORef (newIORef, readIORef, writeIORef)
import Data.Text (Text, pack)
import qualified Data.Vector as V
import GHC.Clock (getMonotonicTimeNSec)
import GHC.Stats (RTSStats (..), getRTSStats, getRTSStatsEnabled)
import OpenTelemetry.Attributes (Attributes, addAttribute, defaultAttributeLimits, emptyAttributes)
import OpenTelemetry.Exporter.Metric
import OpenTelemetry.MeterProvider
import OpenTelemetry.Metric.Core
import OpenTelemetry.Resource (emptyMaterializedResources)
import System.Environment (getArgs)
import System.Mem (performGC)
import Text.Printf (printf)
import Text.Read (readMaybe)


main :: IO ()
main = do
  args <- getArgs
  case args of
    [mode, kind, workersArg, loopsArg] -> run mode kind workersArg loopsArg False
    [mode, kind, workersArg, loopsArg, "collect"] -> run mode kind workersArg loopsArg True
    _ -> fail usage


usage :: String
usage = "metric-storage-contention <shared|instruments|providers|series|churn> <counter|histogram> <workers> <records-per-worker> [collect] [+RTS -N4 -T]"


run :: String -> String -> String -> String -> Bool -> IO ()
run mode kind workersArg loopsArg collect = do
  workers <- positiveInt workersArg
  loops <- positiveInt loopsArg
  unless (mode `elem` ["shared", "instruments", "providers", "series", "churn"] && kind `elem` ["counter", "histogram"]) (fail usage)
  statsEnabled <- getRTSStatsEnabled
  unless statsEnabled (fail "RTS statistics must be enabled with +RTS -T")
  let newMeter = do
        (provider, env) <-
          createMeterProvider
            emptyMaterializedResources
            defaultSdkMeterProviderOptions {cardinalityLimit = 0, aggregationTemporality = AggregationDelta}
        meter <- getMeter provider "metric-contention"
        pure (meter, env)
  shared <- newMeter
  meters <- if mode == "providers" then mapM (const newMeter) [1 .. workers] else pure [shared]
  records <- forM (zip [0 .. workers - 1] (if mode == "providers" then meters else replicate workers shared)) $ \(worker, (meter, _)) -> do
    let name = if mode == "instruments" then "records." <> pack (show worker) else "records"
        seriesAttrs = V.generate 1024 (numberedAttributes worker)
        attributes n = case mode of
          "series" -> seriesAttrs V.! (n `mod` 1024)
          "churn" -> numberedAttributes worker n
          _ -> sharedAttributes
    record <-
      if kind == "counter"
        then do
          counter <- meterCreateCounterInt64 meter name Nothing Nothing defaultAdvisoryParameters
          pure (counterAdd counter 1)
        else do
          histogram <- meterCreateHistogram meter name Nothing Nothing defaultAdvisoryParameters
          pure (histogramRecord histogram 0.01)
    pure (\n -> record (attributes n))
  stopped <- newIORef False
  let collectOnce = countMetrics . concat <$> mapM (collectResourceMetrics . snd) meters
      collector !total !collections !maxNanos = do
        done <- readIORef stopped
        if done
          then pure (total, collections, maxNanos)
          else do
            threadDelay 1000
            before <- getMonotonicTimeNSec
            !count <- collectOnce
            after <- getMonotonicTimeNSec
            collector (total + count) (collections + 1) (max maxNanos (after - before))
  performGC
  before <- getRTSStats
  start <- getMonotonicTimeNSec
  withAsync (if collect then collector 0 (0 :: Int) 0 else pure (0, 0, 0)) $ \background -> do
    forConcurrently_ records (\record -> loop record loops)
    recorded <- getMonotonicTimeNSec
    writeIORef stopped True
    (collected, collections, maxCollectionNanos) <- wait background
    !final <- collectOnce
    let expected = fromIntegral workers * fromIntegral loops :: Integer
    unless (collected + final == expected) (fail ("exported count mismatch: " <> show (collected + final, expected)))
    end <- getMonotonicTimeNSec
    performGC
    after <- getRTSStats
    let count = fromIntegral expected :: Double
        seconds = fromIntegral (recorded - start) / 1e9 :: Double
        endToEnd = fromIntegral (end - start) / 1e9 :: Double
        allocated = fromIntegral (allocated_bytes after - allocated_bytes before) / count :: Double
        gc = fromIntegral (gc_elapsed_ns after - gc_elapsed_ns before) / 1e9 :: Double
        maxCollectionSeconds = fromIntegral maxCollectionNanos / 1e9 :: Double
    printf
      "{\"mode\":\"%s\",\"kind\":\"%s\",\"workers\":%d,\"records\":%d,\"records_per_second\":%.3f,\"end_to_end_rps\":%.3f,\"bytes_per_record\":%.3f,\"gc_seconds\":%.9f,\"collections\":%d,\"max_collection_seconds\":%.9f}\n"
      mode
      kind
      workers
      expected
      (count / seconds)
      (count / endToEnd)
      allocated
      gc
      collections
      maxCollectionSeconds


positiveInt :: String -> IO Int
positiveInt value = case readMaybe value of
  Just n | n > 0 -> pure n
  _ -> fail usage


loop :: (Int -> IO ()) -> Int -> IO ()
loop record = go
  where
    go 0 = pure ()
    go !n = record n >> go (n - 1)


sharedAttributes :: Attributes
sharedAttributes = addAttribute defaultAttributeLimits emptyAttributes "http.request.method" ("GET" :: Text)


numberedAttributes :: Int -> Int -> Attributes
numberedAttributes worker series =
  addAttribute defaultAttributeLimits (addAttribute defaultAttributeLimits emptyAttributes "worker" worker) "series" series


countMetrics :: [ResourceMetricsExport] -> Integer
countMetrics batches =
  sum
    [ case metric of
        MetricExportSum {mesSumPoints = points} -> sum [fromIntegral n | SumDataPoint {sumDataPointValue = IntNumber n} <- V.toList points]
        MetricExportHistogram {mehPoints = points} -> sum (map (fromIntegral . histogramDataPointCount) (V.toList points))
        _ -> 0
    | resource <- batches
    , scope <- V.toList (resourceMetricsScopes resource)
    , metric <- V.toList (scopeMetricsExports scope)
    ]
