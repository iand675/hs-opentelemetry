{-# LANGUAGE CPP #-}
{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE OverloadedStrings #-}

{- |
Module      : OpenTelemetry.Instrumentation.ProcessMetrics
Copyright   : (c) Ian Duncan, 2021-2026
License     : BSD-3
Description : OS-level process metrics following OTel semantic conventions
Stability   : experimental

Registers observable instruments for standard OS-level process metrics
(@process.cpu.time@, @process.memory.usage@, @process.uptime@, etc.)
as defined by the
<https://opentelemetry.io/docs/specs/semconv/system/process-metrics/ OpenTelemetry semantic conventions for process metrics>.

These complement the GHC-specific runtime metrics in
"OpenTelemetry.Instrumentation.GHCMetrics" — those cover the Haskell
runtime internals, while these cover what the OS reports about the
process.

Also includes @process.runtime.ghc.capability.count@ (number of HEC
capabilities, analogous to @go.processor.limit@ in the Go SDK).

= Metrics registered

== Standard process metrics

* @process.cpu.time@ — counter (s), with @cpu.mode=user@ and @cpu.mode=system@
* @process.memory.usage@ — gauge (By), resident set size
* @process.memory.virtual@ — gauge (By), virtual memory size (Linux only)
* @process.thread.count@ — gauge, live thread count from @\/proc\/self\/status@ (Linux only)
* @process.unix.file_descriptor.count@ — gauge, open FD count via @\/proc\/self\/fd@ (Linux only)
* @process.disk.io@ — counter (By), with @disk.io.direction=read|write@ from @\/proc\/self\/io@ (Linux only)
* @process.uptime@ — gauge (s), wall-clock time since registration
* @process.paging.faults@ — counter, with @system.paging.fault.type=minor|major@
* @process.context_switches@ — counter, with @process.context_switch.type=voluntary|involuntary@

== Haskell-specific

* @process.runtime.ghc.capability.count@ — gauge, number of HEC capabilities

= Data sources

On POSIX (Linux, macOS): @getrusage(2)@ for CPU, page faults, context switches.
Linux: @\/proc\/self\/status@ for VmRSS, VmSize, and Threads; @\/proc\/self\/fd@ for FD count;
@\/proc\/self\/io@ for read\/write bytes.
macOS: @task_info(MACH_TASK_BASIC_INFO)@ for resident size.

@since 0.1.0.0
-}
module OpenTelemetry.Instrumentation.ProcessMetrics (
  registerProcessMetrics,
) where

import Data.Int (Int64)
import Data.Text (Text)
import Data.Word (Word64)
import Foreign.C.Types (CLong (..))
import Foreign.Marshal.Alloc (allocaBytes)
import Foreign.Ptr (Ptr)
import Foreign.Storable (peekByteOff)
import GHC.Clock (getMonotonicTimeNSec)
import GHC.Conc (getNumCapabilities)
import OpenTelemetry.Attributes (
  Attributes,
  emptyAttributes,
  toAttribute,
  unsafeAttributesFromListIgnoringLimits,
 )
import OpenTelemetry.Metric.Core (
  AdvisoryParameters,
  Meter (..),
  ObservableCallbackHandle (..),
  ObservableCounter (..),
  ObservableGauge (..),
  ObservableResult (..),
  defaultAdvisoryParameters,
 )
import System.IO.Unsafe (unsafePerformIO)


#if defined(linux_HOST_OS)
import Control.Exception (SomeException, catch)
import qualified Data.ByteString as BS
import System.Directory (listDirectory)
#endif


{- | Register OS-level process metric instruments on the given 'Meter'.

Returns callback handles for optional cleanup via
@unregisterObservableCallback@.

@since 0.1.0.0
-}
registerProcessMetrics :: Meter -> IO [ObservableCallbackHandle]
registerProcessMetrics m =
  sequence $
    concat
      [ cpuTimeCounters m
      , memoryGauges m
      , uptimeGauge m
      , pagingFaultsCounters m
      , contextSwitchCounters m
      , capabilityGauge m
      , threadCountGauge m
      , fdCountGauge m
      , diskIoCounters m
      ]


-- ── CPU time ────────────────────────────────────────────────────────

cpuTimeCounters :: Meter -> [IO ObservableCallbackHandle]
cpuTimeCounters m =
  [ do
      oc <- meterCreateObservableCounterDouble m "process.cpu.time" (Just "s") (Just "Total CPU seconds broken down by different states") noAdv []
      observableCounterRegisterCallback oc $ \res -> do
        ru <- getRUsage
        observe res (ruUserSec ru) userModeAttr
        observe res (ruSystemSec ru) systemModeAttr
  ]


-- ── Memory ──────────────────────────────────────────────────────────

memoryGauges :: Meter -> [IO ObservableCallbackHandle]
memoryGauges m =
  rssGauge m ++ virtualGauge m


rssGauge :: Meter -> [IO ObservableCallbackHandle]
rssGauge m =
  [ do
      og <- meterCreateObservableGaugeInt64 m "process.memory.usage" (Just "By") (Just "The amount of physical memory in use") noAdv []
      observableGaugeRegisterCallback og $ \res -> do
        rss <- getResidentBytes
        observe res rss emptyAttributes
  ]

#if defined(linux_HOST_OS)
virtualGauge :: Meter -> [IO ObservableCallbackHandle]
virtualGauge m =
  [ do
      og <- meterCreateObservableGaugeInt64 m "process.memory.virtual" (Just "By") (Just "The amount of committed virtual memory") noAdv []
      observableGaugeRegisterCallback og $ \res -> do
        vm <- getVirtualBytes
        observe res vm emptyAttributes
  ]
#else
virtualGauge :: Meter -> [IO ObservableCallbackHandle]
virtualGauge _ = []
#endif


-- ── Uptime ──────────────────────────────────────────────────────────

startTimeNs :: Word64
startTimeNs = unsafePerformIO getMonotonicTimeNSec
{-# NOINLINE startTimeNs #-}


uptimeGauge :: Meter -> [IO ObservableCallbackHandle]
uptimeGauge m =
  [ do
      og <- meterCreateObservableGaugeDouble m "process.uptime" (Just "s") (Just "The time the process has been running") noAdv []
      observableGaugeRegisterCallback og $ \res -> do
        now <- getMonotonicTimeNSec
        let uptimeSec = fromIntegral (now - startTimeNs) / 1e9 :: Double
        observe res uptimeSec emptyAttributes
  ]


-- ── Paging faults ───────────────────────────────────────────────────

pagingFaultsCounters :: Meter -> [IO ObservableCallbackHandle]
pagingFaultsCounters m =
  [ do
      oc <- meterCreateObservableCounterInt64 m "process.paging.faults" (Just "{fault}") (Just "Number of page faults the process has made") noAdv []
      observableCounterRegisterCallback oc $ \res -> do
        ru <- getRUsage
        observe res (ruMinorFaults ru) minorFaultAttr
        observe res (ruMajorFaults ru) majorFaultAttr
  ]


-- ── Context switches ────────────────────────────────────────────────

contextSwitchCounters :: Meter -> [IO ObservableCallbackHandle]
contextSwitchCounters m =
  [ do
      oc <- meterCreateObservableCounterInt64 m "process.context_switches" (Just "{context_switch}") (Just "Number of times the process has been context switched") noAdv []
      observableCounterRegisterCallback oc $ \res -> do
        ru <- getRUsage
        observe res (ruVoluntaryCSW ru) voluntaryCSWAttr
        observe res (ruInvoluntaryCSW ru) involuntaryCSWAttr
  ]


-- ── GHC capabilities ───────────────────────────────────────────────

capabilityGauge :: Meter -> [IO ObservableCallbackHandle]
capabilityGauge m =
  [ do
      og <- meterCreateObservableGaugeInt64 m "process.runtime.ghc.capability.count" (Just "{capability}") (Just "Number of GHC HEC capabilities (green thread execution contexts)") noAdv []
      observableGaugeRegisterCallback og $ \res -> do
        n <- getNumCapabilities
        observe res (fromIntegral n) emptyAttributes
  ]

#if defined(linux_HOST_OS)
readDirAttr :: Attributes
readDirAttr = unsafeAttributesFromListIgnoringLimits [("disk.io.direction", toAttribute ("read" :: Text))]


writeDirAttr :: Attributes
writeDirAttr = unsafeAttributesFromListIgnoringLimits [("disk.io.direction", toAttribute ("write" :: Text))]


threadCountGauge :: Meter -> [IO ObservableCallbackHandle]
threadCountGauge m =
  [ do
      og <- meterCreateObservableGaugeInt64 m "process.thread.count" (Just "{thread}") (Just "Process threads count") noAdv []
      observableGaugeRegisterCallback og $ \res -> do
        r <- parseProcCountField "Threads:"
        observe res (maybe 0 id r) emptyAttributes
  ]

fdCountGauge :: Meter -> [IO ObservableCallbackHandle]
fdCountGauge m =
  [ do
      og <- meterCreateObservableGaugeInt64 m "process.unix.file_descriptor.count" (Just "{file_descriptor}") (Just "Number of unix file descriptors in use by the process") noAdv []
      observableGaugeRegisterCallback og $ \res -> do
        n <- countOpenFds
        observe res n emptyAttributes
  ]

diskIoCounters :: Meter -> [IO ObservableCallbackHandle]
diskIoCounters m =
  [ do
      oc <- meterCreateObservableCounterInt64 m "process.disk.io" (Just "By") (Just "Disk bytes transferred") noAdv []
      observableCounterRegisterCallback oc $ \res -> do
        (r, w) <- getDiskIo
        observe res r readDirAttr
        observe res w writeDirAttr
  ]
#else
threadCountGauge :: Meter -> [IO ObservableCallbackHandle]
threadCountGauge _ = []

fdCountGauge :: Meter -> [IO ObservableCallbackHandle]
fdCountGauge _ = []

diskIoCounters :: Meter -> [IO ObservableCallbackHandle]
diskIoCounters _ = []
#endif


-- ── Attribute constants ─────────────────────────────────────────────

userModeAttr :: Attributes
userModeAttr = unsafeAttributesFromListIgnoringLimits [("cpu.mode", toAttribute ("user" :: Text))]


systemModeAttr :: Attributes
systemModeAttr = unsafeAttributesFromListIgnoringLimits [("cpu.mode", toAttribute ("system" :: Text))]


minorFaultAttr :: Attributes
minorFaultAttr = unsafeAttributesFromListIgnoringLimits [("system.paging.fault.type", toAttribute ("minor" :: Text))]


majorFaultAttr :: Attributes
majorFaultAttr = unsafeAttributesFromListIgnoringLimits [("system.paging.fault.type", toAttribute ("major" :: Text))]


voluntaryCSWAttr :: Attributes
voluntaryCSWAttr = unsafeAttributesFromListIgnoringLimits [("process.context_switch.type", toAttribute ("voluntary" :: Text))]


involuntaryCSWAttr :: Attributes
involuntaryCSWAttr = unsafeAttributesFromListIgnoringLimits [("process.context_switch.type", toAttribute ("involuntary" :: Text))]


-- ── getrusage FFI ───────────────────────────────────────────────────

data RUsage = RUsage
  { ruUserSec :: {-# UNPACK #-} !Double
  , ruSystemSec :: {-# UNPACK #-} !Double
  , ruMinorFaults :: {-# UNPACK #-} !Int64
  , ruMajorFaults :: {-# UNPACK #-} !Int64
  , ruVoluntaryCSW :: {-# UNPACK #-} !Int64
  , ruInvoluntaryCSW :: {-# UNPACK #-} !Int64
  }


foreign import ccall unsafe "sys/resource.h getrusage"
  c_getrusage :: Int -> Ptr () -> IO Int


-- struct rusage layout on 64-bit POSIX (Linux glibc, macOS):
--   ru_utime  @ offset 0   (struct timeval: long tv_sec, long tv_usec)
--   ru_stime  @ offset 16
--   remaining long fields at 4× long-size intervals
getRUsage :: IO RUsage
getRUsage = allocaBytes rusageSize $ \ptr -> do
  _ <- c_getrusage 0 ptr -- RUSAGE_SELF = 0
  uSec <- peekByteOff ptr 0 :: IO CLong
  uUsec <- peekByteOff ptr longSize :: IO CLong
  sSec <- peekByteOff ptr (2 * longSize) :: IO CLong
  sUsec <- peekByteOff ptr (3 * longSize) :: IO CLong
  minflt <- peekByteOff ptr (7 * longSize) :: IO CLong
  majflt <- peekByteOff ptr (8 * longSize) :: IO CLong
  nvcsw <- peekByteOff ptr (14 * longSize) :: IO CLong
  nivcsw <- peekByteOff ptr (15 * longSize) :: IO CLong
  pure $!
    RUsage
      { ruUserSec = timevalToSec uSec uUsec
      , ruSystemSec = timevalToSec sSec sUsec
      , ruMinorFaults = fromIntegral minflt
      , ruMajorFaults = fromIntegral majflt
      , ruVoluntaryCSW = fromIntegral nvcsw
      , ruInvoluntaryCSW = fromIntegral nivcsw
      }
  where
    longSize = 8 -- 64-bit platforms (aarch64, x86_64)
    rusageSize = 18 * longSize
    timevalToSec :: CLong -> CLong -> Double
    timevalToSec s us = fromIntegral s + fromIntegral us / 1e6
{-# INLINE getRUsage #-}

-- ── Memory reading (platform-specific) ──────────────────────────────

#if defined(linux_HOST_OS)

getResidentBytes :: IO Int64
getResidentBytes = do
  r <- parseProcField "VmRSS:"
  pure $ maybe 0 id r

getVirtualBytes :: IO Int64
getVirtualBytes = do
  r <- parseProcField "VmSize:"
  pure $ maybe 0 id r

parseProcField :: BS.ByteString -> IO (Maybe Int64)
parseProcField label =
  (do
    bs <- BS.readFile "/proc/self/status"
    pure $ extractKbField label bs
  )
    `catch` \(_ :: SomeException) -> pure Nothing

parseProcCountField :: BS.ByteString -> IO (Maybe Int64)
parseProcCountField label =
  (do
    bs <- BS.readFile "/proc/self/status"
    pure $ extractCountField label bs
  )
    `catch` \(_ :: SomeException) -> pure Nothing

extractCountField :: BS.ByteString -> BS.ByteString -> Maybe Int64
extractCountField label bs = go (BS.lines bs)
  where
    go [] = Nothing
    go (line : rest)
      | label `BS.isPrefixOf` line =
          let stripped = BS.dropWhile isSpace (BS.drop (BS.length label) line)
              digits = BS.takeWhile isDigit stripped
          in case parseDecimal digits of
              Just n -> Just n
              Nothing -> go rest
      | otherwise = go rest
    isSpace w = w == 0x20 || w == 0x09
    isDigit w = w >= 0x30 && w <= 0x39

extractKbField :: BS.ByteString -> BS.ByteString -> Maybe Int64
extractKbField label bs = go (BS.lines bs)
  where
    go [] = Nothing
    go (line : rest)
      | label `BS.isPrefixOf` line =
          let stripped = BS.dropWhile isSpace (BS.drop (BS.length label) line)
              digits = BS.takeWhile isDigit stripped
          in case parseDecimal digits of
              Just kb -> Just (kb * 1024) -- VmRSS/VmSize report in kB
              Nothing -> go rest
      | otherwise = go rest
    isSpace w = w == 0x20 || w == 0x09
    isDigit w = w >= 0x30 && w <= 0x39

parseDecimal :: BS.ByteString -> Maybe Int64
parseDecimal bs
  | BS.null bs = Nothing
  | otherwise = Just $ BS.foldl' (\acc w -> acc * 10 + fromIntegral (w - 0x30)) 0 bs

countOpenFds :: IO Int64
countOpenFds =
  ( do
      entries <- listDirectory "/proc/self/fd"
      pure $! fromIntegral (length entries)
  )
    `catch` \(_ :: SomeException) -> pure 0

getDiskIo :: IO (Int64, Int64)
getDiskIo =
  ( do
      bs <- BS.readFile "/proc/self/io"
      let rb = maybe 0 id $ extractCountField "read_bytes:" bs
          wb = maybe 0 id $ extractCountField "write_bytes:" bs
      pure (rb, wb)
  )
    `catch` \(_ :: SomeException) -> pure (0, 0)

#elif defined(darwin_HOST_OS)

foreign import ccall unsafe "hs_otel_get_rss"
  c_get_rss :: IO Int64

getResidentBytes :: IO Int64
getResidentBytes = c_get_rss

#else

-- Fallback for unsupported platforms
getResidentBytes :: IO Int64
getResidentBytes = pure 0

#endif


-- ── Helpers ─────────────────────────────────────────────────────────

noAdv :: AdvisoryParameters
noAdv = defaultAdvisoryParameters
