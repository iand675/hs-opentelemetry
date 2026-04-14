{-# LANGUAGE CPP #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

import Control.Concurrent (myThreadId)
import Control.Exception (AsyncException (UserInterrupt), SomeException, throwTo, try)
import qualified OpenTelemetry.BaggageSpec as BaggageSpec
import qualified OpenTelemetry.ConfigurationSpec as ConfigurationSpec
import qualified OpenTelemetry.ContextInSpanSpec as ContextInSpanSpec
import qualified OpenTelemetry.ContextSpec as ContextSpec
import qualified OpenTelemetry.LogSpec as LogSpec
import qualified OpenTelemetry.MeterProviderSpec as MeterProviderSpec
import qualified OpenTelemetry.MetricReaderSpec as MetricReaderSpec
import qualified OpenTelemetry.Resource.DetectorSpec as DetectorSpec
import qualified OpenTelemetry.ResourceSpec as ResourceSpec
import OpenTelemetry.Trace (initializeGlobalTracerProvider, withTracerProvider)
import qualified OpenTelemetry.Trace.CallStackSpec as CallStackSpec
import qualified OpenTelemetry.TraceSpec as TraceSpec
import System.Environment (getArgs, setEnv, unsetEnv)
import System.Exit (ExitCode (..), exitWith)
import System.IO (hFlush, stdout)

{- FOURMOLU_DISABLE -}
#if !defined(mingw32_HOST_OS)
import System.Posix.Signals (Handler (CatchOnce), installHandler, sigTERM)
#endif
{- FOURMOLU_ENABLE -}
import Test.Hspec


main :: IO ()
main = do
  args <- getArgs
  case args of
    ("--signal-test-helper" : rest) -> signalTestHelper rest
    _ -> runTests


runTests :: IO ()
runTests = do
  setEnv "OTEL_ATTRIBUTE_VALUE_LENGTH_LIMIT" "50"
  setEnv "OTEL_RESOURCE_ATTRIBUTES" "host.name=env_host_name,example.name=env_example_name,example.count=42"
  initializeGlobalTracerProvider
  hspec $ do
    BaggageSpec.spec
    ContextSpec.spec
    ContextInSpanSpec.spec
    TraceSpec.spec
    CallStackSpec.spec
    ResourceSpec.spec
    DetectorSpec.spec
    LogSpec.spec
    MeterProviderSpec.spec
    MetricReaderSpec.spec
    ConfigurationSpec.spec


signalTestHelper :: [String] -> IO ()

{- FOURMOLU_DISABLE -}
#if !defined(mingw32_HOST_OS)
signalTestHelper [markerPath] = do
  tid <- myThreadId
  _ <- installHandler sigTERM (CatchOnce (throwTo tid UserInterrupt)) Nothing
  setEnv "OTEL_TRACES_EXPORTER" "none"
  setEnv "OTEL_PROPAGATORS" "none"
  unsetEnv "OTEL_CONFIG_FILE"
  setEnv "OTEL_LOG_LEVEL" "none"
  _ <- try @SomeException $ withTracerProvider $ \_ -> do
    putStrLn "READY"
    hFlush stdout
    waitForever
  writeFile markerPath "SHUTDOWN_COMPLETE"
  exitWith ExitSuccess
  where
    waitForever :: IO ()
    waitForever = do
      _ <- getLine
      waitForever
#else
signalTestHelper [_markerPath] = pure ()
#endif
{- FOURMOLU_ENABLE -}

signalTestHelper _ = do
  putStrLn "Usage: --signal-test-helper <marker-path>"
  exitWith (ExitFailure 1)
