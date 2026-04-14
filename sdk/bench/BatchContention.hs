{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Control.Concurrent (getNumCapabilities, threadDelay)
import Control.Concurrent.Async (mapConcurrently_)
import Control.Monad (forM_, replicateM_, void, when)
import qualified Data.HashMap.Strict as HashMap
import qualified Data.Vector as V
import GHC.Clock (getMonotonicTimeNSec)
import OpenTelemetry.Exporter.Span (SpanExporter (..))
import OpenTelemetry.Internal.AtomicCounter
import OpenTelemetry.Internal.Common.Types (ExportResult (..), FlushResult (..), ShutdownResult (..), instrumentationLibrary)
import OpenTelemetry.Processor.Batch.Span (BatchTimeoutConfig (..), batchProcessor, batchTimeoutConfig)
import OpenTelemetry.Trace.Core
import Text.Printf (printf)


main :: IO ()
main = do
  caps <- getNumCapabilities
  printf "=== Batch Processor Contention Benchmark ===\n"
  printf "Capabilities: %d\n\n" caps

  printf "--- Warm-up ---\n"
  runThroughputBench 4 5000 0
  runThroughputBench 8 5000 0

  printf "\n--- Enqueue throughput (50000 spans, fast exporter) ---\n"
  printf "%-8s  %12s  %12s  %12s\n" ("Threads" :: String) ("Wall (ms)" :: String) ("ns/span" :: String) ("Exported" :: String)
  forM_ [1, 2, 4, 8, 16, 32] $ \nThreads ->
    runThroughputBench nThreads 50000 0

  printf "\n--- Backpressure (16 threads, 20000 spans, queue=1024) ---\n"
  printf "%-12s  %12s  %12s  %12s  %12s\n" ("Delay (us)" :: String) ("Wall (ms)" :: String) ("Exported" :: String) ("Dropped" :: String) ("Drop %" :: String)
  forM_ [0, 1_000, 10_000] $ \delayUs ->
    runBackpressureBench 16 delayUs 20000

  printf "\n--- Scaling test (100000 spans, fast exporter) ---\n"
  printf "%-8s  %12s  %12s  %12s\n" ("Threads" :: String) ("Wall (ms)" :: String) ("ns/span" :: String) ("Exported" :: String)
  forM_ [1, 2, 4, 8, 16, 32] $ \nThreads ->
    runThroughputBench nThreads 100000 0


runThroughputBench :: Int -> Int -> Int -> IO ()
runThroughputBench nThreads totalSpans exportDelayUs = do
  (ex, exported) <- mkExporter exportDelayUs
  let cfg =
        batchTimeoutConfig
          { maxQueueSize = 16384
          , maxExportBatchSize = 512
          , exportTimeoutMillis = 5000
          }
  proc <- batchProcessor cfg ex
  tp <- createTracerProvider [proc] emptyTracerProviderOptions
  let !t = makeTracer tp (instrumentationLibrary "bench" "1.0") tracerOptions
      !perThread = totalSpans `div` nThreads

  !startNs <- getWallNs
  mapConcurrently_
    (\_ -> replicateM_ perThread $ inSpan t "op" defaultSpanArguments (pure ()))
    [1 .. nThreads]
  !endNs <- getWallNs

  void $ shutdownTracerProvider tp Nothing
  !e <- readAtomicCounter exported

  let !wallNs = endNs - startNs
      !wallMs = fromIntegral wallNs / 1_000_000 :: Double
      !nsPerSpan = if totalSpans > 0 then wallNs `div` fromIntegral totalSpans else 0
  printf "%-8d  %12.2f  %12d  %12d\n" nThreads wallMs nsPerSpan e


runBackpressureBench :: Int -> Int -> Int -> IO ()
runBackpressureBench nThreads exportDelayUs totalSpans = do
  enqueued <- newAtomicCounter 0
  (ex, exported) <- mkExporter exportDelayUs
  let cfg =
        batchTimeoutConfig
          { maxQueueSize = 1024
          , maxExportBatchSize = 256
          , scheduledDelayMillis = 100
          , exportTimeoutMillis = 5000
          }
  proc <- batchProcessor cfg ex
  tp <- createTracerProvider [proc] emptyTracerProviderOptions
  let !t = makeTracer tp (instrumentationLibrary "bench" "1.0") tracerOptions
      !perThread = totalSpans `div` nThreads

  !startNs <- getWallNs
  mapConcurrently_
    ( \_ -> replicateM_ perThread $ do
        inSpan t "op" defaultSpanArguments (pure ())
        void $ incrAtomicCounter enqueued
    )
    [1 .. nThreads]
  !endNs <- getWallNs

  void $ shutdownTracerProvider tp Nothing
  !e <- readAtomicCounter exported
  !total <- readAtomicCounter enqueued
  let !dropped = total - e
      !wallMs = fromIntegral (endNs - startNs) / 1_000_000 :: Double
      !dropPct =
        if total > 0
          then 100.0 * fromIntegral dropped / fromIntegral total :: Double
          else 0.0
  printf "%-12d  %12.2f  %12d  %12d  %11.1f%%\n" exportDelayUs wallMs e dropped dropPct


mkExporter :: Int -> IO (SpanExporter, AtomicCounter)
mkExporter delayUs = do
  exported <- newAtomicCounter 0
  let ex =
        SpanExporter
          { spanExporterExport = \batch -> do
              when (delayUs > 0) $ threadDelay delayUs
              mapM_ (\(_, spans) -> void $ addAtomicCounter (V.length spans) exported) (HashMap.toList batch)
              pure Success
          , spanExporterForceFlush = pure FlushSuccess
          , spanExporterShutdown = pure ShutdownSuccess
          }
  pure (ex, exported)


getWallNs :: IO Integer
getWallNs = fromIntegral <$> getMonotonicTimeNSec
