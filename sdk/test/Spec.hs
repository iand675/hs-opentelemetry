{-# LANGUAGE CPP #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

import Control.Exception (SomeException, try)
import qualified OpenTelemetry.BaggageSpec as BaggageSpec
import qualified OpenTelemetry.ConfigurationSpec as ConfigurationSpec
import qualified OpenTelemetry.ContextInSpanSpec as ContextInSpanSpec
import qualified OpenTelemetry.ContextSpec as ContextSpec
import qualified OpenTelemetry.MeterProviderSpec as MeterProviderSpec
import qualified OpenTelemetry.Resource.DetectorSpec as DetectorSpec
import qualified OpenTelemetry.ResourceSpec as ResourceSpec
import OpenTelemetry.Trace (initializeGlobalTracerProvider, withTracerProvider)
import qualified OpenTelemetry.TraceSpec as TraceSpec
import System.Environment (getArgs, setEnv, unsetEnv)
import System.Exit (ExitCode (..), exitWith)
import System.IO (hFlush, stdout)
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
    ResourceSpec.spec
    DetectorSpec.spec
    MeterProviderSpec.spec
    ConfigurationSpec.spec


signalTestHelper :: [String] -> IO ()
signalTestHelper [markerPath] = do
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
      -- Block on stdin — the parent will either send SIGTERM or close
      -- the handle, both of which unblock us.
      _ <- getLine
      waitForever
signalTestHelper _ = do
  putStrLn "Usage: --signal-test-helper <marker-path>"
  exitWith (ExitFailure 1)
