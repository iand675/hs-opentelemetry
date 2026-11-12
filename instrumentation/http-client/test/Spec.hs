{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Concurrent (newEmptyMVar, putMVar, takeMVar, threadDelay, tryPutMVar)
import Control.Exception (ErrorCall (..), bracket, finally, throwIO)
import Control.Monad (forM_, replicateM_, void, when)
import Data.Foldable (toList)
import Data.IORef
import qualified Data.Text as T
import Network.HTTP.Client
import Network.HTTP.Types (status200, status302)
import qualified Network.Wai as Wai
import Network.Wai.Handler.Warp (testWithApplication)
import OpenTelemetry.Attributes (lookupAttribute)
import OpenTelemetry.Attributes.Attribute (Attribute (..), PrimitiveAttribute (..))
import OpenTelemetry.Attributes.Key (unkey)
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Context.ThreadLocal (attachContext, detachContext, getContext)
import OpenTelemetry.Context.ThreadLocal.Propagation (tracedConcurrently)
import OpenTelemetry.Exporter.InMemory.Span (inMemoryListExporter)
import OpenTelemetry.Exporter.Metric (HistogramDataPoint (..), MetricExport (..), NumberValue (..), ResourceMetricsExport (..), ScopeMetricsExport (..), SumDataPoint (..))
import OpenTelemetry.Instrumentation.HttpClient.Raw
import OpenTelemetry.MeterProvider (collectResourceMetrics, createMeterProvider, defaultSdkMeterProviderOptions)
import OpenTelemetry.Metric.Core (getMeter)
import OpenTelemetry.Processor.Span (SpanProcessor (..))
import OpenTelemetry.Resource (emptyMaterializedResources)
import qualified OpenTelemetry.SemanticConventions as SC
import OpenTelemetry.Trace.Core
import System.Environment (setEnv)
import System.Timeout (timeout)
import Test.Hspec


main :: IO ()
main = do
  setEnv "OTEL_SEMCONV_STABILITY_OPT_IN" "http"
  hspec spec


withTestSpan :: T.Text -> (Context.Context -> Span -> IO a) -> IO (ImmutableSpan, a)
withTestSpan name action = do
  (processor, ref) <- inMemoryListExporter
  tp <- createTracerProvider [processor] emptyTracerProviderOptions
  setGlobalTracerProvider tp
  let tracer = makeTracer tp "test" tracerOptions
  s <- createSpan tracer Context.empty name (defaultSpanArguments {kind = Client})
  let ctx = Context.insertSpan s Context.empty
  result <- action ctx s
  endSpan s Nothing
  _ <- shutdownTracerProvider tp Nothing
  spans <- readIORef ref
  case spans of
    (clientSpan : _) -> pure (clientSpan, result)
    [] -> error "No spans recorded"


spec :: Spec
spec = describe "HTTP client instrumentation" $ do
  describe "managed request lifecycle" $ do
    it "balances a successful request" $
      withManagedRequest 1 $ \manager req ->
        void (httpLbs req manager)

    it "balances one redirect" $
      withManagedRequest 2 $ \manager req ->
        void (httpLbs req {path = "/redirect"} manager)

    it "balances a refused connection" $
      withManagedRequest 1 $ \manager req -> do
        closedPort <- testWithApplication (pure testApplication) pure
        httpLbs req {port = closedPort} manager `shouldThrow` \case
          HttpExceptionRequest _ (ConnectionFailure _) -> True
          _ -> False

    it "balances a checkResponse exception" $
      withManagedRequest 1 $ \manager req -> do
        let request = req {checkResponse = \_ _ -> throwIO (ErrorCall "checkResponse failed")}
        httpLbs request manager `shouldThrow` errorCall "checkResponse failed"

    it "balances cancellation by timeout" $
      withManagedRequest 1 $ \manager req ->
        timeout 100000 (void (httpLbs req {path = "/slow"} manager)) `shouldReturn` Nothing

    it "exports no spans for responseOpenHistory" $
      withManagedRequest 0 $ \manager req ->
        bracket
          (responseOpenHistory req {path = "/redirect"} manager)
          (responseClose . hrFinalResponse)
          (void . brConsume . responseBody . hrFinalResponse)

    it "balances sequential requests on one thread" $
      withManagedRequest 3 $ \manager req ->
        replicateM_ 3 (void (httpLbs req manager))

    it "isolates overlapping requests through one manager" $
      withManagedRequest 2 $ \manager req -> do
        entered <- newEmptyMVar
        release <- newEmptyMVar
        let app request respond = do
              first <- tryPutMVar entered ()
              if first then takeMVar release else putMVar release ()
              testApplication request respond
        callerCtx <- getContext
        before <- traverse getSpanContext (Context.lookupSpan callerCtx)
        testWithApplication (pure app) $ \portNumber ->
          bracket (attachContext callerCtx) detachContext $ \_ -> do
            let send = do
                  void (httpLbs req {port = portNumber} manager)
                  after <- getContext >>= traverse getSpanContext . Context.lookupSpan
                  after `shouldBe` before
            timeout 5000000 (void (tracedConcurrently send send)) `shouldReturn` Just ()

  describe "instrumentRequest" $ do
    it "sets span name to HTTP method (low cardinality)" $ do
      req <- parseRequest "http://example.com/users/123?q=test"
      (clientSpan, _) <- withTestSpan "HTTP" $ \ctx _s -> do
        _ <- instrumentRequest httpClientInstrumentationConfig ctx req
        pure ()
      hot <- readIORef (spanHot clientSpan)
      hotName hot `shouldBe` "GET"

    it "uses requestName override when provided" $ do
      req <- parseRequest "http://example.com/users/123"
      let conf = httpClientInstrumentationConfig {requestName = Just "custom-op"}
      (clientSpan, _) <- withTestSpan "HTTP" $ \ctx _s -> do
        _ <- instrumentRequest conf ctx req
        pure ()
      hot <- readIORef (spanHot clientSpan)
      hotName hot `shouldBe` "custom-op"

    it "sets http.request.method" $ do
      req <- parseRequest "POST http://example.com/api/data"
      (clientSpan, _) <- withTestSpan "HTTP" $ \ctx _s -> do
        _ <- instrumentRequest httpClientInstrumentationConfig ctx req
        pure ()
      hot <- readIORef (spanHot clientSpan)
      lookupAttribute (hotAttributes hot) (unkey SC.http_request_method)
        `shouldBe` Just (AttributeValue (TextAttribute "POST"))

    it "sets url.path" $ do
      req <- parseRequest "http://example.com/api/data"
      (clientSpan, _) <- withTestSpan "HTTP" $ \ctx _s -> do
        _ <- instrumentRequest httpClientInstrumentationConfig ctx req
        pure ()
      hot <- readIORef (spanHot clientSpan)
      lookupAttribute (hotAttributes hot) (unkey SC.url_path)
        `shouldBe` Just (AttributeValue (TextAttribute "/api/data"))

    it "sets server.address" $ do
      req <- parseRequest "http://example.com/test"
      (clientSpan, _) <- withTestSpan "HTTP" $ \ctx _s -> do
        _ <- instrumentRequest httpClientInstrumentationConfig ctx req
        pure ()
      hot <- readIORef (spanHot clientSpan)
      lookupAttribute (hotAttributes hot) (unkey SC.server_address)
        `shouldBe` Just (AttributeValue (TextAttribute "example.com"))

    it "sets server.port" $ do
      req <- parseRequest "http://example.com:8080/test"
      (clientSpan, _) <- withTestSpan "HTTP" $ \ctx _s -> do
        _ <- instrumentRequest httpClientInstrumentationConfig ctx req
        pure ()
      hot <- readIORef (spanHot clientSpan)
      lookupAttribute (hotAttributes hot) (unkey SC.server_port)
        `shouldBe` Just (AttributeValue (IntAttribute 8080))

    it "sets url.scheme to http" $ do
      req <- parseRequest "http://example.com/test"
      (clientSpan, _) <- withTestSpan "HTTP" $ \ctx _s -> do
        _ <- instrumentRequest httpClientInstrumentationConfig ctx req
        pure ()
      hot <- readIORef (spanHot clientSpan)
      lookupAttribute (hotAttributes hot) (unkey SC.url_scheme)
        `shouldBe` Just (AttributeValue (TextAttribute "http"))


testApplication :: Wai.Application
testApplication req respond = do
  when (Wai.rawPathInfo req == "/slow") $ threadDelay 1000000
  respond $
    if Wai.rawPathInfo req == "/redirect"
      then Wai.responseLBS status302 [("Location", "/ok")] ""
      else Wai.responseLBS status200 [] "ok"


withManagedRequest :: Int -> (Manager -> Request -> IO ()) -> IO ()
withManagedRequest expected action = do
  (processor, ended) <- inMemoryListExporter
  started <- newIORef (0 :: Int)
  let counting = processor {spanProcessorOnStart = \_ _ -> atomicModifyIORef' started (\n -> (n + 1, ()))}
  provider <- createTracerProvider [counting] emptyTracerProviderOptions
  (meterProvider, meterEnv) <- createMeterProvider emptyMaterializedResources defaultSdkMeterProviderOptions
  metrics <- createHttpClientMetricsFromMeter =<< getMeter meterProvider "test"
  let tracer = makeTracer provider "test" tracerOptions
  bracket getGlobalTracerProvider setGlobalTracerProvider $ \_ ->
    flip finally (void (shutdownTracerProvider provider Nothing)) $ do
      setGlobalTracerProvider provider
      bracket (createSpan tracer Context.empty "caller" defaultSpanArguments) (`endSpan` Nothing) $ \parent -> do
        parentSpanContext <- getSpanContext parent
        marker <- Context.newKey "test.caller"
        let callerCtx = Context.insert marker True (Context.insertSpan parent Context.empty)
        testWithApplication (pure testApplication) $ \portNumber ->
          bracket (attachContext callerCtx) detachContext $ \_ -> do
            writeIORef started 0
            req <- parseRequest ("http://127.0.0.1:" <> show portNumber <> "/ok")
            manager <- newTracedManager httpClientInstrumentationConfig {httpClientMetrics = Just metrics} defaultManagerSettings
            action manager req
            after <- getContext
            traverse getSpanContext (Context.lookupSpan after) `shouldReturn` Just parentSpanContext
            Context.lookup marker after `shouldBe` Just True
            spans <- readIORef ended
            length spans `shouldBe` expected
            readIORef started `shouldReturn` length spans
            forM_ spans $ \s -> traverse getSpanContext (spanParent s) `shouldReturn` Just parentSpanContext
            batches <- collectResourceMetrics meterEnv
            let exports =
                  [ metric
                  | resource <- batches
                  , scopeMetrics <- toList (resourceMetricsScopes resource)
                  , metric <- toList (scopeMetricsExports scopeMetrics)
                  ]
                active =
                  [ n
                  | MetricExportSum {mesName = "http.client.active_requests", mesSumPoints = points} <- exports
                  , SumDataPoint {sumDataPointValue = IntNumber n} <- toList points
                  ]
                durations =
                  [ histogramDataPointCount point
                  | MetricExportHistogram {mehName = "http.client.request.duration", mehPoints = points} <- exports
                  , point <- toList points
                  ]
            when (expected > 0) $ active `shouldSatisfy` (not . null)
            active `shouldSatisfy` all (== 0)
            sum durations `shouldBe` fromIntegral (length spans)
