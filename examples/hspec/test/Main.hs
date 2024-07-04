{-# LANGUAGE OverloadedStrings #-}

import Control.Monad (void)
import Data.Text (Text, unpack)
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Context.ThreadLocal (attachContext, getContext)
import OpenTelemetry.Instrumentation.Hspec (instrumentSpec, wrapSpec)
import OpenTelemetry.SpanExporter.Handle
import OpenTelemetry.SpanProcessor.Batch
import OpenTelemetry.Trace hiding (inSpan)
import qualified OpenTelemetry.Trace as Trace
import OpenTelemetry.Trace.Core (getSpanContext)
import OpenTelemetry.Trace.Id (Base (..), traceIdBaseEncodedText)
import OpenTelemetry.Trace.Sampler
import qualified Spec
import Test.Hspec
import Test.Hspec.Runner (defaultConfig, hspecWith)
import UnliftIO (MonadUnliftIO, bracket, finally, throwString)


{- | Initialize the global tracing provider for the application and run an action
   (that action is generally the entry point of the application), cleaning
   up the provider afterwards.

   This also sets up an empty context (creating a new trace ID).
-}
withGlobalTracing :: Sampler -> IO a -> IO a
withGlobalTracing sampler act = do
  void $ attachContext Context.empty
  bracket
    (initializeTracing sampler)
    shutdownTracerProvider
    $ const act


printTraceLink :: IO ()
printTraceLink = do
  -- It's helpful to print out a trace link for the run so the user can look at it.
  -- The precise link to view a trace by ID is left as an exercise to the reader
  -- as it depends on which service you use.
  --
  -- For Honeycomb, see https://docs.honeycomb.io/api/direct-trace-links/
  theSpan <- maybe (throwString "no context?") pure . Context.lookupSpan =<< getContext
  theTraceId <- traceIdBaseEncodedText Base16 . traceId <$> getSpanContext theSpan

  putStrLn $ "Trace link: (some service)/" <> unpack theTraceId


initializeTracing :: Sampler -> IO TracerProvider
initializeTracing sampler = do
  (processors, tracerOptions') <- getTracerProviderInitializationOptions

  -- forcibly adds a stderr exporter; this is just for demo purposes
  stderrProc <- batchProcessor batchTimeoutConfig $ stderrExporter' (pure . defaultFormatter)
  let processors' = stderrProc : processors

  provider <- createTracerProvider processors' (tracerOptions' {tracerProviderOptionsSampler = sampler})
  setGlobalTracerProvider provider

  pure provider


inSpan :: (MonadUnliftIO m, HasCallStack) => Text -> SpanArguments -> m a -> m a
inSpan name args act = do
  tp <- getGlobalTracerProvider
  let tracer = makeTracer tp "hspec-example" tracerOptions
  Trace.inSpan tracer name args act


main :: IO ()
main = do
  putStrLn "Begin tests"
  withGlobalTracing alwaysOn $
    inSpan "Run tests" defaultSpanArguments $
      runTests `finally` printTraceLink


runTests :: IO ()
runTests = do
  tp <- getGlobalTracerProvider
  let tracer = makeTracer tp "hspec-example" tracerOptions
  ctxt <- getContext
  hspecWith
    defaultConfig
    $ instrumentSpec tracer ctxt (parallel Spec.spec)
  putStrLn "Done"
