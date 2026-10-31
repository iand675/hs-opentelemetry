{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE OverloadedStrings #-}

module TransportSpec (spec, Signal (..), newExport, respondWith, completedSuccessfully, completedWithFailure) where

import Control.Concurrent (threadDelay)
import Control.Concurrent.Async (AsyncCancelled (..), cancel, waitCatch, withAsync)
import Control.Exception (AsyncException (ThreadKilled), SomeException, fromException)
import Control.Monad (forM_)
import qualified Data.HashMap.Strict as H
import Data.IORef
import qualified Data.Vector as V
import GHC.Clock (getMonotonicTimeNSec)
import Network.HTTP.Types (status200, status429, status503)
import Network.HTTP.Types.Header (ResponseHeaders)
import Network.HTTP.Types.Status (Status)
import qualified Network.Wai as Wai
import Network.Wai.Handler.Warp (testWithApplication)
import OpenTelemetry.Attributes (emptyAttributes)
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Exporter.Metric
import OpenTelemetry.Exporter.OTLP.Internal.Timeout (withExportTimeout)
import OpenTelemetry.Exporter.OTLP.LogRecord (otlpLogRecordExporter)
import OpenTelemetry.Exporter.OTLP.Metric (otlpMetricExporter)
import OpenTelemetry.Exporter.OTLP.Span
import OpenTelemetry.Exporter.Span (spanExporterExport)
import OpenTelemetry.Internal.Common.Types (ExportResult (..), FlushResult (..), ShutdownResult (..))
import qualified OpenTelemetry.Internal.Log.Core as Log
import qualified OpenTelemetry.Internal.Log.Types as Log
import OpenTelemetry.Processor.Span (SpanProcessor (..))
import OpenTelemetry.Resource (emptyMaterializedResources)
import qualified OpenTelemetry.Trace.Core as Trace
import System.Timeout (timeout)
import Test.Hspec


data Signal = Traces | Metrics | Logs deriving (Show)


spec :: Spec
spec = do
  describe "batch export timeout" $ do
    it "preserves explicit zero as no timeout" $ do
      result <- withExportTimeout (Just 0) (threadDelay 20_000 >> pure Success)
      succeeded result `shouldBe` True
    it "does not overflow a large positive timeout" $ do
      result <- withExportTimeout (Just maxBound) (pure Success)
      succeeded result `shouldBe` True

  forM_ [Traces, Metrics, Logs] $ \signal ->
    describe (show signal <> " HTTP transport") $ do
      it "exports successfully before the deadline" $
        testWithApplication (pure (respondWith status200 [])) $ \port -> do
          export <- newExport signal port (Just 1000)
          result <- timeout 2_000_000 export
          completedSuccessfully result `shouldBe` True

      it "bounds a slow request by the batch timeout" $
        testWithApplication (pure slowResponse) $ \port -> do
          export <- newExport signal port (Just 100)
          assertBatchTimeout export

      it "bounds a Retry-After wait by the batch timeout" $
        testWithApplication (pure (respondWith status429 [("Retry-After", "3600")])) $ \port -> do
          export <- newExport signal port (Just 100)
          assertBatchTimeout export

      it "does not restart the batch timeout after retries" $ do
        calls <- newIORef (0 :: Int)
        let app req respond = do
              atomicModifyIORef' calls (\n -> (n + 1, ()))
              respondWith status503 [] req respond
        testWithApplication (pure app) $ \port -> do
          export <- newExport signal port (Just 250)
          result <- timeout 600_000 export
          completedWithFailure result `shouldBe` True
          readIORef calls >>= (\n -> n `shouldSatisfy` (> 1))

      it "preserves an earlier caller timeout" $
        testWithApplication (pure slowResponse) $ \port -> do
          export <- newExport signal port (Just 1000)
          result <- timeout 50_000 export
          isNothing result `shouldBe` True

      it "propagates caller cancellation during Retry-After" $ do
        received <- newIORef False
        let app req respond = do
              writeIORef received True
              respondWith status429 [("Retry-After", "3600")] req respond
        testWithApplication (pure app) $ \port -> do
          export <- newExport signal port (Just 1000)
          withAsync export $ \worker -> do
            let awaitRequest = do
                  seen <- readIORef received
                  if seen then pure () else threadDelay 1000 >> awaitRequest
            timeout 500_000 awaitRequest `shouldReturn` Just ()
            cancel worker
            result <- waitCatch worker
            wasCancelled result `shouldBe` True


assertBatchTimeout :: IO ExportResult -> Expectation
assertBatchTimeout export = do
  before <- getMonotonicTimeNSec
  result <- timeout 500_000 export
  after <- getMonotonicTimeNSec
  completedWithFailure result `shouldBe` True
  -- Reject an immediate transport failure masquerading as our 100ms deadline.
  (after - before) `shouldSatisfy` (>= 70_000_000)


respondWith :: Status -> ResponseHeaders -> Wai.Application
respondWith status headers _ respond = respond (Wai.responseLBS status headers "")


slowResponse :: Wai.Application
slowResponse req respond = do
  threadDelay 1_000_000
  respondWith status200 [] req respond


succeeded :: ExportResult -> Bool
succeeded Success = True
succeeded _ = False


completedSuccessfully :: Maybe ExportResult -> Bool
completedSuccessfully (Just Success) = True
completedSuccessfully _ = False


completedWithFailure :: Maybe ExportResult -> Bool
completedWithFailure (Just (Failure _)) = True
completedWithFailure _ = False


isNothing :: Maybe a -> Bool
isNothing Nothing = True
isNothing _ = False


wasCancelled :: Either SomeException ExportResult -> Bool
wasCancelled (Left e) =
  case fromException e of
    Just ThreadKilled -> True
    _ -> case fromException e of
      Just AsyncCancelled -> True
      _ -> False
wasCancelled _ = False


-- Each action sends a real, nonempty batch through the public exporter API.
newExport :: Signal -> Int -> Maybe Int -> IO (IO ExportResult)
newExport signal port limit = do
  config <- loadExporterEnvironmentVariables
  let conf =
        config
          { otlpEndpoint = Just ("http://127.0.0.1:" <> show port)
          , otlpTracesEndpoint = Nothing
          , otlpMetricsEndpoint = Nothing
          , otlpTimeout = limit
          , otlpTracesTimeout = Nothing
          , otlpMetricsTimeout = Nothing
          , otlpHeaders = Nothing
          , otlpTracesHeaders = Nothing
          , otlpMetricsHeaders = Nothing
          , otlpCompression = Just None
          , otlpTracesCompression = Just None
          , otlpMetricsCompression = Just None
          }
  case signal of
    Metrics -> do
      exporter <- otlpMetricExporter conf
      let point = SumDataPoint 0 1 (IntNumber 1) emptyAttributes V.empty
          metric = MetricExportSum "test.counter" "" "1" "test" True False AggregationCumulative (V.singleton point)
          batch = ResourceMetricsExport emptyMaterializedResources (V.singleton (ScopeMetricsExport "test" (V.singleton metric)))
      pure (metricExporterExport exporter (V.singleton batch))
    Traces -> do
      let processor =
            SpanProcessor
              { spanProcessorOnStart = \_ _ -> pure ()
              , spanProcessorOnEnd = \_ -> pure ()
              , spanProcessorShutdown = pure ShutdownSuccess
              , spanProcessorForceFlush = pure FlushSuccess
              }
      provider <- Trace.createTracerProvider [processor] Trace.emptyTracerProviderOptions
      let tracer = Trace.makeTracer provider "test" Trace.tracerOptions
      span <- Trace.createSpanWithoutCallStack tracer Context.empty "test" Trace.defaultSpanArguments
      Trace.endSpan span Nothing
      immutable <- Trace.toImmutableSpan span >>= either (fail . show) pure
      exporter <- otlpExporter conf
      pure (spanExporterExport exporter (H.singleton "test" (V.singleton immutable)))
    Logs -> do
      records <- newIORef []
      let processor =
            Log.LogRecordProcessor
              { Log.logRecordProcessorOnEmit = \record _ -> do
                  snapshot <- Log.mkReadableLogRecord record
                  modifyIORef' records (snapshot :)
              , Log.logRecordProcessorShutdown = pure ShutdownSuccess
              , Log.logRecordProcessorForceFlush = pure FlushSuccess
              }
      provider <- Log.createLoggerProvider [processor] Log.emptyLoggerProviderOptions
      Log.emitLogRecord (Log.makeLogger provider "test") Log.emptyLogRecordArguments
      batch <- V.fromList <$> readIORef records
      V.null batch `shouldBe` False
      exporter <- otlpLogRecordExporter conf
      pure (Log.logRecordExporterExport exporter batch)
