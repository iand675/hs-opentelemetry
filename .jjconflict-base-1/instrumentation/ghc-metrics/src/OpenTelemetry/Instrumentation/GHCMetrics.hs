{-# LANGUAGE CPP #-}
{-# LANGUAGE OverloadedStrings #-}

{- |
Module      : OpenTelemetry.Instrumentation.GHCMetrics
Copyright   : (c) Ian Duncan, 2021-2026
License     : BSD-3
Description : Export GHC runtime metrics as OpenTelemetry metrics
Stability   : experimental

= Overview

Registers observable instruments that report GHC runtime statistics
(memory usage, GC counters, mutator vs GC time, thread counts, etc.)
as OpenTelemetry metrics. These are collected automatically on each
metric export cycle.

The metric set covers every field in 'GHC.Stats.RTSStats' and
'GHC.Stats.GCDetails', matching or exceeding the coverage provided
by @ekg-core@'s @registerGcMetrics@.

= Quick example

@
import OpenTelemetry.Instrumentation.GHCMetrics (registerGHCMetrics)
import OpenTelemetry.Metric.Core (getGlobalMeterProvider, getMeter)
import OpenTelemetry.Trace.Core (instrumentationLibrary)

main :: IO ()
main = do
  mp <- getGlobalMeterProvider
  meter <- getMeter mp (instrumentationLibrary "ghc-metrics" "0.1.0")
  _handles <- registerGHCMetrics meter
  -- GHC metrics are now exported alongside your application metrics
@

= Exported metrics

All instrument names use the @process.runtime.ghc.@ prefix.

== Cumulative counters (from 'GHC.Stats.RTSStats')

* @process.runtime.ghc.allocated_bytes@ (By)
* @process.runtime.ghc.gc.count@ / @gc.major_count@
* @process.runtime.ghc.gc.cpu_time@ / @gc.elapsed_time@ (s)
* @process.runtime.ghc.gc.copied_bytes@ / @gc.par_copied_bytes@ (By)
* @process.runtime.ghc.gc.cumulative_live_bytes@ (By)
* @process.runtime.ghc.gc.cumulative_par_balanced_copied_bytes@ (By)
* @process.runtime.ghc.mutator.cpu_time@ / @mutator.elapsed_time@ (s)
* @process.runtime.ghc.init.cpu_time@ / @init.elapsed_time@ (s)
* @process.runtime.ghc.cpu_time@ / @elapsed_time@ (s)
* @process.runtime.ghc.nonmoving_gc.sync.cpu_time@ / @sync.elapsed_time@ (s)
* @process.runtime.ghc.nonmoving_gc.cpu_time@ / @nonmoving_gc.elapsed_time@ (s)

== Gauges: high-water marks (from 'GHC.Stats.RTSStats')

* @process.runtime.ghc.memory.max_live_bytes@ (By)
* @process.runtime.ghc.memory.max_large_objects_bytes@ (By)
* @process.runtime.ghc.memory.max_compact_bytes@ (By)
* @process.runtime.ghc.memory.max_slop_bytes@ (By)
* @process.runtime.ghc.memory.max_mem_in_use_bytes@ (By)
* @process.runtime.ghc.nonmoving_gc.sync.max_elapsed_time@ (s)
* @process.runtime.ghc.nonmoving_gc.max_elapsed_time@ (s)

== Gauges: last GC snapshot (from 'GHC.Stats.GCDetails')

* @process.runtime.ghc.memory.live_bytes@ / @memory.heap_size@ (By)
* @process.runtime.ghc.gc.last.*@ for generation, threads, allocated,
  large objects, compact, slop, copied, parallel copy stats, sync
  time, CPU\/elapsed time, and nonmoving GC sync time.
* @process.runtime.ghc.gc.last.block_fragmentation_bytes@ (GHC 9.6+)

Use 'unregisterObservableCallback' on the returned handles for optional cleanup.

__Note__: requires the program to be started with @+RTS -T@ (runtime
statistics enabled) or a GHC version that enables them by default.
If stats are disabled, 'registerGHCMetrics' returns an empty list.

@since 0.1.0.0
-}
module OpenTelemetry.Instrumentation.GHCMetrics (
  registerGHCMetrics,
) where

import Data.Int (Int64)
import Data.Text (Text)
import GHC.Stats (GCDetails (..), RTSStats (..), getRTSStats, getRTSStatsEnabled)
import OpenTelemetry.Attributes (emptyAttributes)
import OpenTelemetry.Metric.Core (
  AdvisoryParameters,
  Meter (..),
  ObservableCallbackHandle (..),
  ObservableCounter (..),
  ObservableGauge (..),
  ObservableResult (..),
  defaultAdvisoryParameters,
 )


{- | Register all GHC runtime metric instruments on the given 'Meter'.

Returns a list of callback handles that can be used to unregister the
callbacks (e.g. during shutdown). If RTS stats are not enabled
(@+RTS -T@ was not passed), returns an empty list and no instruments
are created.

@since 0.1.0.0
-}
registerGHCMetrics :: Meter -> IO [ObservableCallbackHandle]
registerGHCMetrics m = do
  enabled <- getRTSStatsEnabled
  if not enabled
    then pure []
    else
      sequence $
        concat
          [ rtsStatsCounters m
          , rtsStatsGauges m
          , gcDetailsGauges m
          ]


-- ── RTSStats cumulative counters ─────────────────────────────────────

rtsStatsCounters :: Meter -> [IO ObservableCallbackHandle]
rtsStatsCounters m =
  [ obsCounterI64 m "process.runtime.ghc.allocated_bytes" "By" "Total bytes allocated on the GHC heap" $
      \s -> fromIntegral (allocated_bytes s)
  , obsCounterI64 m "process.runtime.ghc.gc.count" "{gc}" "Total number of GCs" $
      \s -> fromIntegral (gcs s)
  , obsCounterI64 m "process.runtime.ghc.gc.major_count" "{gc}" "Total number of major (oldest generation) GCs" $
      \s -> fromIntegral (major_gcs s)
  , obsCounterDbl m "process.runtime.ghc.gc.cpu_time" "s" "Total CPU time spent in GC" $
      \s -> nsToSec (gc_cpu_ns s)
  , obsCounterDbl m "process.runtime.ghc.gc.elapsed_time" "s" "Total wall-clock time spent in GC" $
      \s -> nsToSec (gc_elapsed_ns s)
  , obsCounterI64 m "process.runtime.ghc.gc.copied_bytes" "By" "Total bytes copied during GC" $
      \s -> fromIntegral (copied_bytes s)
  , obsCounterI64 m "process.runtime.ghc.gc.par_copied_bytes" "By" "Total bytes copied during parallel GCs" $
      \s -> fromIntegral (par_copied_bytes s)
  , obsCounterI64 m "process.runtime.ghc.gc.cumulative_live_bytes" "By" "Sum of live bytes across all major GCs" $
      \s -> fromIntegral (cumulative_live_bytes s)
  , obsCounterI64 m "process.runtime.ghc.gc.cumulative_par_balanced_copied_bytes" "By" "Sum of balanced parallel-copied bytes across all GCs" $
      \s -> fromIntegral (cumulative_par_balanced_copied_bytes s)
  , obsCounterDbl m "process.runtime.ghc.mutator.cpu_time" "s" "Total CPU time spent in the mutator" $
      \s -> nsToSec (mutator_cpu_ns s)
  , obsCounterDbl m "process.runtime.ghc.mutator.elapsed_time" "s" "Total wall-clock time spent in the mutator" $
      \s -> nsToSec (mutator_elapsed_ns s)
  , obsCounterDbl m "process.runtime.ghc.init.cpu_time" "s" "Total CPU time used by the init phase" $
      \s -> nsToSec (init_cpu_ns s)
  , obsCounterDbl m "process.runtime.ghc.init.elapsed_time" "s" "Total wall-clock time used by the init phase" $
      \s -> nsToSec (init_elapsed_ns s)
  , obsCounterDbl m "process.runtime.ghc.cpu_time" "s" "Total CPU time elapsed since program start" $
      \s -> nsToSec (cpu_ns s)
  , obsCounterDbl m "process.runtime.ghc.elapsed_time" "s" "Total wall-clock time elapsed since program start" $
      \s -> nsToSec (elapsed_ns s)
  , obsCounterDbl m "process.runtime.ghc.nonmoving_gc.sync.cpu_time" "s" "CPU time spent in nonmoving GC sync phase" $
      \s -> nsToSec (nonmoving_gc_sync_cpu_ns s)
  , obsCounterDbl m "process.runtime.ghc.nonmoving_gc.sync.elapsed_time" "s" "Wall-clock time spent in nonmoving GC sync phase" $
      \s -> nsToSec (nonmoving_gc_sync_elapsed_ns s)
  , obsCounterDbl m "process.runtime.ghc.nonmoving_gc.cpu_time" "s" "Total CPU time used by the nonmoving GC" $
      \s -> nsToSec (nonmoving_gc_cpu_ns s)
  , obsCounterDbl m "process.runtime.ghc.nonmoving_gc.elapsed_time" "s" "Total wall-clock time with nonmoving GC active" $
      \s -> nsToSec (nonmoving_gc_elapsed_ns s)
  ]


-- ── RTSStats gauges (high-water marks) ───────────────────────────────

rtsStatsGauges :: Meter -> [IO ObservableCallbackHandle]
rtsStatsGauges m =
  [ obsGaugeI64 m "process.runtime.ghc.memory.max_live_bytes" "By" "Maximum live data seen in the heap (high-water mark)" $
      \s -> fromIntegral (max_live_bytes s)
  , obsGaugeI64 m "process.runtime.ghc.memory.max_large_objects_bytes" "By" "Maximum live data in large objects" $
      \s -> fromIntegral (max_large_objects_bytes s)
  , obsGaugeI64 m "process.runtime.ghc.memory.max_compact_bytes" "By" "Maximum live data in compact regions" $
      \s -> fromIntegral (max_compact_bytes s)
  , obsGaugeI64 m "process.runtime.ghc.memory.max_slop_bytes" "By" "Maximum slop (wasted memory)" $
      \s -> fromIntegral (max_slop_bytes s)
  , obsGaugeI64 m "process.runtime.ghc.memory.max_mem_in_use_bytes" "By" "Maximum memory in use by the RTS" $
      \s -> fromIntegral (max_mem_in_use_bytes s)
  , obsGaugeDbl m "process.runtime.ghc.nonmoving_gc.sync.max_elapsed_time" "s" "Maximum elapsed time of any nonmoving GC sync phase" $
      \s -> nsToSec (nonmoving_gc_sync_max_elapsed_ns s)
  , obsGaugeDbl m "process.runtime.ghc.nonmoving_gc.max_elapsed_time" "s" "Maximum elapsed time of any nonmoving GC cycle" $
      \s -> nsToSec (nonmoving_gc_max_elapsed_ns s)
  ]


-- ── GCDetails gauges (last GC snapshot) ──────────────────────────────

gcDetailsGauges :: Meter -> [IO ObservableCallbackHandle]
gcDetailsGauges m =
  [ obsGaugeI64 m "process.runtime.ghc.memory.live_bytes" "By" "Current live data in the heap (as of last major GC)" $
      \s -> fromIntegral (gcdetails_live_bytes (gc s))
  , obsGaugeI64 m "process.runtime.ghc.memory.heap_size" "By" "Current memory in use by the RTS" $
      \s -> fromIntegral (gcdetails_mem_in_use_bytes (gc s))
  , obsGaugeI64 m "process.runtime.ghc.gc.last.gen" "{gen}" "Generation number of the most recent GC" $
      \s -> fromIntegral (gcdetails_gen (gc s))
  , obsGaugeI64 m "process.runtime.ghc.gc.last.threads" "{thread}" "Number of threads used in the most recent GC" $
      \s -> fromIntegral (gcdetails_threads (gc s))
  , obsGaugeI64 m "process.runtime.ghc.gc.last.allocated_bytes" "By" "Bytes allocated since the previous GC" $
      \s -> fromIntegral (gcdetails_allocated_bytes (gc s))
  , obsGaugeI64 m "process.runtime.ghc.gc.last.large_objects_bytes" "By" "Live data in large objects (last GC)" $
      \s -> fromIntegral (gcdetails_large_objects_bytes (gc s))
  , obsGaugeI64 m "process.runtime.ghc.gc.last.compact_bytes" "By" "Live data in compact regions (last GC)" $
      \s -> fromIntegral (gcdetails_compact_bytes (gc s))
  , obsGaugeI64 m "process.runtime.ghc.gc.last.slop_bytes" "By" "Wasted memory (slop) in the last GC" $
      \s -> fromIntegral (gcdetails_slop_bytes (gc s))
  , obsGaugeI64 m "process.runtime.ghc.gc.last.copied_bytes" "By" "Bytes copied during the last GC" $
      \s -> fromIntegral (gcdetails_copied_bytes (gc s))
  , obsGaugeI64 m "process.runtime.ghc.gc.last.par_max_copied_bytes" "By" "Max bytes copied by any one thread (last GC)" $
      \s -> fromIntegral (gcdetails_par_max_copied_bytes (gc s))
  , obsGaugeI64 m "process.runtime.ghc.gc.last.par_balanced_copied_bytes" "By" "Balanced parallel-copied bytes (last GC)" $
      \s -> fromIntegral (gcdetails_par_balanced_copied_bytes (gc s))
  , obsGaugeDbl m "process.runtime.ghc.gc.last.sync_elapsed_time" "s" "Elapsed time for synchronisation before last GC" $
      \s -> nsToSec (gcdetails_sync_elapsed_ns (gc s))
  , obsGaugeDbl m "process.runtime.ghc.gc.last.cpu_time" "s" "CPU time used by the last GC" $
      \s -> nsToSec (gcdetails_cpu_ns (gc s))
  , obsGaugeDbl m "process.runtime.ghc.gc.last.elapsed_time" "s" "Wall-clock time of the last GC" $
      \s -> nsToSec (gcdetails_elapsed_ns (gc s))
  , obsGaugeDbl m "process.runtime.ghc.gc.last.nonmoving_gc_sync_cpu_time" "s" "Nonmoving GC sync CPU time (last GC)" $
      \s -> nsToSec (gcdetails_nonmoving_gc_sync_cpu_ns (gc s))
  , obsGaugeDbl m "process.runtime.ghc.gc.last.nonmoving_gc_sync_elapsed_time" "s" "Nonmoving GC sync elapsed time (last GC)" $
      \s -> nsToSec (gcdetails_nonmoving_gc_sync_elapsed_ns (gc s))
  ]
    ++ gcDetailsBlockFragGauge m


gcDetailsBlockFragGauge :: Meter -> [IO ObservableCallbackHandle]
#if MIN_VERSION_base(4,18,0)
gcDetailsBlockFragGauge m =
  [ obsGaugeI64 m "process.runtime.ghc.gc.last.block_fragmentation_bytes" "By" "Memory lost to block fragmentation (last GC)" $
      \s -> fromIntegral (gcdetails_block_fragmentation_bytes (gc s))
  ]
#else
gcDetailsBlockFragGauge _ = []
#endif


-- ── Helpers ──────────────────────────────────────────────────────────

noAdv :: AdvisoryParameters
noAdv = defaultAdvisoryParameters


obsCounterI64
  :: Meter -> Text -> Text -> Text -> (RTSStats -> Int64) -> IO ObservableCallbackHandle
obsCounterI64 m name unit desc extract = do
  oc <- meterCreateObservableCounterInt64 m name (Just unit) (Just desc) noAdv []
  observableCounterRegisterCallback oc $ \res -> do
    s <- getRTSStats
    observe res (extract s) emptyAttributes


obsCounterDbl
  :: Meter -> Text -> Text -> Text -> (RTSStats -> Double) -> IO ObservableCallbackHandle
obsCounterDbl m name unit desc extract = do
  oc <- meterCreateObservableCounterDouble m name (Just unit) (Just desc) noAdv []
  observableCounterRegisterCallback oc $ \res -> do
    s <- getRTSStats
    observe res (extract s) emptyAttributes


obsGaugeI64
  :: Meter -> Text -> Text -> Text -> (RTSStats -> Int64) -> IO ObservableCallbackHandle
obsGaugeI64 m name unit desc extract = do
  og <- meterCreateObservableGaugeInt64 m name (Just unit) (Just desc) noAdv []
  observableGaugeRegisterCallback og $ \res -> do
    s <- getRTSStats
    observe res (extract s) emptyAttributes


obsGaugeDbl
  :: Meter -> Text -> Text -> Text -> (RTSStats -> Double) -> IO ObservableCallbackHandle
obsGaugeDbl m name unit desc extract = do
  og <- meterCreateObservableGaugeDouble m name (Just unit) (Just desc) noAdv []
  observableGaugeRegisterCallback og $ \res -> do
    s <- getRTSStats
    observe res (extract s) emptyAttributes


nsToSec :: (Integral a) => a -> Double
nsToSec ns = fromIntegral ns / 1000000000
{-# INLINE nsToSec #-}
