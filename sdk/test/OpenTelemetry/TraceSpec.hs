{-# LANGUAGE CPP #-}
{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

module OpenTelemetry.TraceSpec where

import Control.Concurrent (forkIO)
import Control.Concurrent.Async (async, mapConcurrently_, wait)
import Control.Concurrent.MVar (newEmptyMVar, putMVar, takeMVar)
import Control.Exception (SomeException, bracket, handle, throwIO)
import Control.Monad
import Control.Monad.IO.Class (liftIO)
import qualified Data.ByteString as BS
import qualified Data.ByteString.Short as SBS
import Data.Foldable (traverse_)
import qualified Data.HashMap.Strict as HM
import Data.IORef
import Data.Int
import Data.List (isInfixOf, nub)
import Data.Maybe (isJust)
import Data.Text (Text)
import qualified Data.Text as Text
import qualified Data.Vector as V
import GHC.Stack (withFrozenCallStack)
import OpenTelemetry.Attributes (AttributeLimits (..), Attributes, attr, defaultAttributeLimits, getCount, lookupAttribute, toAttribute)
import OpenTelemetry.Attributes.Key (unkey)
import OpenTelemetry.Common (timestampToOptional)
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Context.ThreadLocal (attachContext, detachContext, getContext)
import OpenTelemetry.Exporter.InMemory.Span (inMemoryListExporter)
import OpenTelemetry.Exporter.LogRecord (LogRecordExporterArguments (..), mkLogRecordExporter)
import OpenTelemetry.Exporter.Span (ExportResult (..), SpanExporter (..))
import OpenTelemetry.Internal.AtomicCounter
import OpenTelemetry.Internal.Common.Types (FlushResult (..), ShutdownResult (..))
import OpenTelemetry.Internal.Log.Types (LogRecordProcessor (..))
import OpenTelemetry.Internal.Logging (otelLogWarning)
import OpenTelemetry.Processor.Batch.LogRecord (BatchLogRecordProcessorConfig (..), batchLogRecordProcessor, defaultBatchLogRecordProcessorConfig)
import OpenTelemetry.Processor.Batch.Span (BatchTimeoutConfig (..), batchProcessor, batchTimeoutConfig)
import OpenTelemetry.Processor.Simple.Span (SimpleProcessorConfig (..), simpleProcessor)
import OpenTelemetry.Processor.Span (SpanProcessor (..))
import OpenTelemetry.Propagator (Propagator (..), getGlobalTextMapPropagator, setGlobalTextMapPropagator)
import qualified OpenTelemetry.Registry as Registry
import OpenTelemetry.Resource
import qualified OpenTelemetry.SemanticConventions as SC
import OpenTelemetry.Trace
import OpenTelemetry.Trace.Core hiding (addAttribute, addAttributes)
import OpenTelemetry.Trace.Id
import OpenTelemetry.Trace.Id.Generator
import OpenTelemetry.Trace.Id.Generator.Default
import OpenTelemetry.Trace.Sampler (Sampler (..), SamplingDecision (..), SamplingResult (..), alwaysOff, getDescription, shouldSample)
import OpenTelemetry.Trace.TraceState (Key (Key), Value (Value))
import qualified OpenTelemetry.Trace.TraceState as TraceState
import OpenTelemetry.Util (appendOnlyBoundedCollectionDroppedElementCount, appendOnlyBoundedCollectionSize, appendOnlyBoundedCollectionValues)
import System.Directory (removeFile)
import System.Environment (getExecutablePath, lookupEnv, setEnv, unsetEnv)
import System.IO (hClose, hFlush, hGetLine)
import System.Process (CreateProcess (..), StdStream (..), createProcess, getPid, proc, terminateProcess, waitForProcess)
import Test.Hspec


#if !defined(mingw32_HOST_OS)
import System.Posix.Signals (signalProcess, sigTERM)
#endif


asIO :: IO a -> IO a
asIO = id


pattern ExampleName :: Text
pattern ExampleName = "example.name"


pattern ExampleCount :: Text
pattern ExampleCount = "example.count"


spec :: Spec
spec = describe "Trace" $ do
  -- Trace SDK
  -- https://opentelemetry.io/docs/specs/otel/trace/sdk/
  describe "TracerProvider" $ do
    -- Trace SDK §TracerProvider creation
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#tracerprovider
    specify "Create TracerProvider" $ do
      void (createTracerProvider [] (emptyTracerProviderOptions :: TracerProviderOptions) :: IO TracerProvider)
    -- Trace SDK §Tracer: create spans from Tracer obtained from TracerProvider
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#tracer
    specify "makeTracer creates a usable tracer" $ asIO $ do
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      let t = makeTracer tp "make-tracer-test" tracerOptions
      s <- createSpan t Context.empty "test-span" defaultSpanArguments
      endSpan s Nothing
      im <- unsafeReadSpan s
      hot <- readIORef (spanHot im)
      hotName hot `shouldBe` "test-span"
      libraryName (tracerName (spanTracer im)) `shouldBe` "make-tracer-test"
    -- Implementation-specific: TracerProvider thread safety under concurrent span creation
    specify "Safe for concurrent calls" $ asIO $ do
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      let t = makeTracer tp "concurrent-tp" tracerOptions
      done <- newEmptyMVar
      replicateM_ 10 $
        forkIO $
          handle (\(_ :: SomeException) -> putMVar done ()) $ do
            s <- createSpan t Context.empty "c" defaultSpanArguments
            endSpan s Nothing
            putMVar done ()
      replicateM_ 10 $ takeMVar done
    -- Trace SDK §Shutdown TracerProvider
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#shutdown
    specify "Shutdown" $ asIO $ do
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      _ <- shutdownTracerProvider tp Nothing
      pure ()
    -- Trace SDK §ForceFlush TracerProvider
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#forceflushtracerprovider
    specify "ForceFlush" $ asIO $ do
      exportedRef <- newIORef ([] :: [ImmutableSpan])
      let testExporter =
            SpanExporter
              { spanExporterExport = \batch -> do
                  let allSpans = concatMap V.toList (HM.elems batch)
                  atomicModifyIORef' exportedRef (\acc -> (acc ++ allSpans, ()))
                  pure Success
              , spanExporterShutdown = pure ShutdownSuccess
              , spanExporterForceFlush = pure FlushSuccess
              }
      processor <- simpleProcessor (SimpleProcessorConfig {spanExporter = testExporter, simpleSpanExportTimeoutMicros = 30_000_000})
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      let t = makeTracer tp "ff-tp" tracerOptions
      s <- createSpan t Context.empty "ff-span" defaultSpanArguments
      endSpan s Nothing
      _ <- forceFlushTracerProvider tp Nothing
      spans <- readIORef exportedRef
      length spans `shouldBe` 1
    -- Resource SDK §Detecting Resource from environment (OTEL_RESOURCE_ATTRIBUTES, overrides)
    -- https://opentelemetry.io/docs/specs/otel/resource/sdk/#detecting-resource-information-from-the-environment
    specify "Resource initialization prioritizes user override, then OTEL_RESOURCE_ATTRIBUTES env var" $ do
      let getInitialResourceAttrs :: Resource -> IO Attributes
          getInitialResourceAttrs resource = do
            opts <- snd <$> getTracerProviderInitializationOptions' resource
            pure . getMaterializedResourcesAttributes $ tracerProviderOptionsResources opts
          shouldHaveAttrPair :: Attributes -> (Text, Attribute) -> Expectation
          shouldHaveAttrPair attrs (k, v) = lookupAttribute attrs k `shouldBe` Just v
      attrsFromEnv <- getInitialResourceAttrs mempty
      traverse_
        (attrsFromEnv `shouldHaveAttrPair`)
        [ (unkey SC.host_name, toAttribute @Text "env_host_name")
        , (unkey SC.telemetry_sdk_language, toAttribute @Text "haskell")
        , (ExampleName, toAttribute @Text "env_example_name")
        , -- OTEL_RESOURCE_ATTRIBUTES uses Baggage format, where attribute values are always text
          (ExampleCount, toAttribute @Text "42")
        ]
      attrsFromUser <-
        getInitialResourceAttrs $
          mkResource
            [ unkey SC.host_name .= ("user_host_name" :: Text)
            , unkey SC.telemetry_sdk_language .= ("GHC2021" :: Text)
            , ExampleCount .= toAttribute @Int 11
            ]
      traverse_
        (attrsFromUser `shouldHaveAttrPair`)
        [ (unkey SC.host_name, toAttribute @Text "user_host_name")
        , (unkey SC.telemetry_sdk_language, toAttribute @Text "GHC2021")
        , -- No user override for "example.name", so the value from OTEL_RESOURCES_ATTRIBUTES shines through
          (ExampleName, toAttribute @Text "env_example_name")
        , (ExampleCount, toAttribute @Int 11)
        ]

  describe "Trace / Context interaction" $ do
    -- Trace API §Context interaction (span stored in Context)
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#context-interaction
    specify "Set active span, Get active span" $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "create_root_span" defaultSpanArguments
      spanContext1 <- spanContext <$> unsafeReadSpan s
      let ctxt = Context.insertSpan s mempty
      let Just s' = Context.lookupSpan ctxt
      spanContext2 <- spanContext <$> unsafeReadSpan s'
      spanContext1 `shouldBe` spanContext2

  describe "Tracer" $ do
    -- Trace API §Span creation
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#span-creation
    specify "Create a new span" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      void $ createSpan t Context.empty "create_root_span" defaultSpanArguments
    -- Trace API §Context interaction: active span in current Context
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#context-interaction
    specify "Get active new span" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      inSpan' t "active-lookup" defaultSpanArguments $ \s -> do
        ctxt <- getContext
        case Context.lookupSpan ctxt of
          Nothing -> expectationFailure "expected active span in Context"
          Just active -> do
            sid <- getSpanContext s
            aid <- getSpanContext active
            sid `shouldBe` aid
    -- Trace API: propagating Context with current Span (attach)
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#context-interaction
    specify "Mark Span active" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "mark-active" defaultSpanArguments
      tok <- attachContext (Context.insertSpan s mempty)
      ctxt <- getContext
      case Context.lookupSpan ctxt of
        Nothing -> do
          detachContext tok
          expectationFailure "expected span after attachContext"
        Just active -> do
          sc <- getSpanContext s
          ac <- getSpanContext active
          sc `shouldBe` ac
          detachContext tok
    -- Implementation-specific: concurrent span operations on global TracerProvider
    specify "Safe for concurrent calls" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      done <- newEmptyMVar
      replicateM_ 10 $
        forkIO $
          handle (\(_ :: SomeException) -> putMVar done ()) $ do
            s <- createSpan t Context.empty "ct" defaultSpanArguments
            endSpan s Nothing
            putMVar done ()
      replicateM_ 10 $ takeMVar done
  describe "SpanContext" $ do
    -- Trace API §SpanContext validity (non-zero trace id and span id)
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#spancontext
    specify "IsValid" $ do
      t <- newTraceId defaultIdGenerator
      s <- newSpanId defaultIdGenerator
      let (Right goodSpan) = bytesToSpanId "\1\0\0\0\0\0\0\1"
          (Right goodTrace) = bytesToTraceId "\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1"
          (Right badSpan) = bytesToSpanId "\0\0\0\0\0\0\0\0"
          (Right badTrace) = bytesToTraceId "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
          validSpan =
            SpanContext
              { traceFlags = defaultTraceFlags
              , isRemote = False
              , traceState = TraceState.empty
              , spanId = goodSpan
              , traceId = goodTrace
              }
      validSpan `shouldSatisfy` isValid
      (validSpan {spanId = badSpan, traceId = badTrace}) `shouldSatisfy` (not . isValid)
      -- Spec: BOTH TraceId AND SpanId must be non-zero
      (validSpan {spanId = badSpan}) `shouldSatisfy` (not . isValid)
      (validSpan {traceId = badTrace}) `shouldSatisfy` (not . isValid)
    -- Trace API §SpanContext isRemote flag
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#spancontext
    specify "IsRemote" $ do
      t <- newTraceId defaultIdGenerator
      s <- newSpanId defaultIdGenerator
      let scRemote =
            SpanContext
              { traceFlags = defaultTraceFlags
              , isRemote = True
              , traceState = TraceState.empty
              , spanId = s
              , traceId = t
              }
          scLocal = scRemote {isRemote = False}
      isRemote scRemote `shouldBe` True
      isRemote scLocal `shouldBe` False
    -- W3C Trace Context: trace-id and parent-id lengths
    -- https://www.w3.org/TR/trace-context/
    specify "Conforms to the W3C TraceContext spec" $ do
      t <- newTraceId defaultIdGenerator
      s <- newSpanId defaultIdGenerator
      BS.length (traceIdBytes t) `shouldBe` 16
      BS.length (spanIdBytes s) `shouldBe` 8
  describe "Span" $ do
    -- Trace API §Span creation (root span, no parent in Context)
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#span-creation
    specify "Create root span" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      void $ createSpan t Context.empty "create_root_span" defaultSpanArguments
    -- Trace API §Span creation: parent from implicit Context
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#span-creation
    specify "Create with default parent (active span)" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      inSpan' t "parent" defaultSpanArguments $ \parent -> do
        ctxt <- getContext
        child <- createSpan t ctxt "child" defaultSpanArguments
        im <- unsafeReadSpan child
        case spanParent im of
          Nothing -> expectationFailure "expected parent on child span"
          Just pspan -> do
            psc <- getSpanContext parent
            cpsc <- getSpanContext pspan
            psc `shouldBe` cpsc
    -- Trace API §Span creation: explicit parent Context
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#span-creation
    specify "Create with parent from Context" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      parent <- createSpan t Context.empty "parent-ctx" defaultSpanArguments
      let ctxt = Context.insertSpan parent mempty
      child <- createSpan t ctxt "child-ctx" defaultSpanArguments
      im <- unsafeReadSpan child
      case spanParent im of
        Nothing -> expectationFailure "expected parent on child span"
        Just pspan -> do
          psc <- getSpanContext parent
          cpsc <- getSpanContext pspan
          psc `shouldBe` cpsc
    -- Trace SDK §Span processor: OnStart receives parent Context
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#span-processor
    specify "Processor.OnStart receives parent Context" $ asIO $ do
      onStartCtxtRef <- newIORef Nothing
      let processor =
            SpanProcessor
              { spanProcessorOnStart = \_ ctxt ->
                  writeIORef onStartCtxtRef (Just ctxt)
              , spanProcessorOnEnd = \_ -> pure ()
              , spanProcessorShutdown = pure ShutdownSuccess
              , spanProcessorForceFlush = pure FlushSuccess
              }
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      let t = makeTracer tp "on-start-ctx" tracerOptions
      parent <- createSpan t Context.empty "p-onstart" defaultSpanArguments
      let ctxt = Context.insertSpan parent mempty
      void $ createSpan t ctxt "c-onstart" defaultSpanArguments
      Just recorded <- readIORef onStartCtxtRef
      case Context.lookupSpan recorded of
        Nothing -> expectationFailure "expected parent span in OnStart context"
        Just sp -> do
          psc <- getSpanContext parent
          spsc <- getSpanContext sp
          psc `shouldBe` spsc
    -- Trace API §UpdateName
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#updatename
    specify "UpdateName" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "create_root_span" defaultSpanArguments
      updateName s "renamed_span"
    -- Trace API §Set span start time
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#set-span-start-time
    specify "User-defined start timestamp" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      ts <- getTimestamp
      s <-
        createSpan t Context.empty "timed" $
          defaultSpanArguments {startTime = Just ts}
      im <- unsafeReadSpan s
      spanStart im `shouldBe` ts
    -- Trace API §End
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#end
    specify "End" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "create_root_span" defaultSpanArguments
      endSpan s Nothing
    -- Trace API §End with explicit timestamp
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#end
    specify "End with timestamp" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      ts <- getTimestamp
      s <- createSpan t Context.empty "create_root_span" defaultSpanArguments
      endSpan s (Just ts)
    -- Trace API §IsRecording
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#isrecording
    specify "IsRecording" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "create_root_span" defaultSpanArguments
      recording <- isRecording s
      recording `shouldBe` True

    -- Trace API §IsRecording after span end
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#isrecording
    specify "IsRecording becomes false after End" $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "create_root_span" defaultSpanArguments
      endSpan s Nothing
      recording <- isRecording s
      recording `shouldBe` False

    specify "Set status: both Ok and Error are final (spec compliance)" $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "create_root_span" defaultSpanArguments

      setStatus s $ Error "woo"
      do
        i <- unsafeReadSpan s
        h <- readIORef (spanHot i)
        hotStatus h `shouldBe` Error "woo"
      -- Per spec: Ok > Error > Unset. Ok overrides Error.
      setStatus s $ Ok
      do
        i <- unsafeReadSpan s
        h <- readIORef (spanHot i)
        hotStatus h `shouldBe` Ok
      -- Once Ok is set, nothing can override it.
      setStatus s $ Error "different"
      do
        i <- unsafeReadSpan s
        h <- readIORef (spanHot i)
        hotStatus h `shouldBe` Ok

    -- Trace API §Set span status
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#set-status
    specify "SetStatus: Error overwrites Unset" $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "status_error_over_unset" defaultSpanArguments
      i0 <- unsafeReadSpan s
      h0 <- readIORef (spanHot i0)
      hotStatus h0 `shouldBe` Unset
      setStatus s (Error "e1")
      i1 <- unsafeReadSpan s
      h1 <- readIORef (spanHot i1)
      hotStatus h1 `shouldBe` Error "e1"

    -- Trace API §Set span status (Error is sticky)
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#set-status
    specify "SetStatus: Error is final, second Error is ignored" $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "status_error_over_error" defaultSpanArguments
      setStatus s (Error "first")
      setStatus s (Error "second")
      i <- unsafeReadSpan s
      h <- readIORef (spanHot i)
      hotStatus h `shouldBe` Error "first"

    -- Trace API §Set span status (Ok is highest priority)
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#set-status
    specify "SetStatus: Ok is final, Error cannot override" $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "status_ok_final" defaultSpanArguments
      setStatus s Ok
      setStatus s (Error "should be ignored")
      i <- unsafeReadSpan s
      h <- readIORef (spanHot i)
      hotStatus h `shouldBe` Ok

    -- Trace API §Set span status (Unset does not downgrade)
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#set-status
    specify "SetStatus: Unset on Unset is a no-op" $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "status_unset_unset" defaultSpanArguments
      i0 <- unsafeReadSpan s
      h0 <- readIORef (spanHot i0)
      hotStatus h0 `shouldBe` Unset
      setStatus s Unset
      i1 <- unsafeReadSpan s
      h1 <- readIORef (spanHot i1)
      hotStatus h1 `shouldBe` Unset

    -- Trace API §Set span status
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#set-status
    specify "SetStatus: Ok on Ok is a no-op (Ok remains)" $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "status_ok_ok" defaultSpanArguments
      setStatus s Ok
      setStatus s Ok
      i <- unsafeReadSpan s
      h <- readIORef (spanHot i)
      hotStatus h `shouldBe` Ok

    -- Trace API §Set span status
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#set-status
    specify "SetStatus: Ok is final, Unset cannot override" $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "status_ok_final2" defaultSpanArguments
      setStatus s Ok
      setStatus s Unset
      i <- unsafeReadSpan s
      h <- readIORef (spanHot i)
      hotStatus h `shouldBe` Ok

    -- Trace API §Set span status (Unset ignored when status already set)
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#set-status
    specify "SetStatus: setting Unset is always ignored" $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "status_unset_ignored" defaultSpanArguments
      setStatus s (Error "err")
      setStatus s Unset
      i <- unsafeReadSpan s
      h <- readIORef (spanHot i)
      hotStatus h `shouldBe` Error "err"

    -- Trace API §Set span status precedence (Ok > Error > Unset)
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#set-status
    specify "SetStatus: Ok overrides Error (spec: Ok > Error > Unset)" $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "status_ok_over_error" defaultSpanArguments
      setStatus s (Error "e")
      setStatus s Ok
      i <- unsafeReadSpan s
      h <- readIORef (spanHot i)
      hotStatus h `shouldBe` Ok

    -- Trace API §Wrapping a SpanContext (non-recording span)
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#wrapping-a-spancontext-into-a-span
    specify "IsRecording is False for FrozenSpan (wrapSpanContext)" $ do
      tid <- newTraceId defaultIdGenerator
      sid <- newSpanId defaultIdGenerator
      let sc =
            SpanContext
              { traceFlags = defaultTraceFlags
              , isRemote = True
              , traceId = tid
              , spanId = sid
              , traceState = TraceState.empty
              }
          frozenSpan = wrapSpanContext sc
      r <- isRecording frozenSpan
      r `shouldBe` False

    -- Trace API §Span operations invalid after end
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#end
    specify "SetStatus is no-op after End" $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "noop_after_end" defaultSpanArguments
      setStatus s (Error "before end")
      endSpan s Nothing
      setStatus s Ok
      i <- unsafeReadSpan s
      h <- readIORef (spanHot i)
      hotStatus h `shouldBe` Error "before end"

    -- Trace API §Add attributes: no effect after span end
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#add-attributes
    specify "addAttribute is no-op after End" $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "attr_after_end" defaultSpanArguments
      endSpan s Nothing
      addAttribute s "should.not.exist" (42 :: Int64)
      i <- unsafeReadSpan s
      hi <- readIORef (spanHot i)
      lookupAttribute (hotAttributes hi) "should.not.exist" `shouldBe` Nothing

    -- Trace API §Add events: no effect after span end
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#add-events
    specify "addEvent is no-op after End" $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "event_after_end" defaultSpanArguments
      endSpan s Nothing
      addEvent s $
        NewEvent
          { newEventName = "ghost"
          , newEventAttributes = mempty
          , newEventTimestamp = Nothing
          }
      i <- unsafeReadSpan s
      hi <- readIORef (spanHot i)
      appendOnlyBoundedCollectionValues (hotEvents hi) `shouldSatisfy` V.null

    -- Trace API §UpdateName: no effect after span end
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#updatename
    specify "updateName is no-op after End" $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "original_name" defaultSpanArguments
      endSpan s Nothing
      updateName s "changed_name"
      i <- unsafeReadSpan s
      hi <- readIORef (spanHot i)
      hotName hi `shouldBe` "original_name"

    -- Trace API §Add links: no effect after span end
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#add-links
    specify "addLink is no-op after End" $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "link_after_end" defaultSpanArguments
      endSpan s Nothing
      tid <- newTraceId defaultIdGenerator
      sid <- newSpanId defaultIdGenerator
      let sc =
            SpanContext
              { traceFlags = defaultTraceFlags
              , isRemote = False
              , traceId = tid
              , spanId = sid
              , traceState = TraceState.empty
              }
      addLink s (NewLink {linkContext = sc, linkAttributes = mempty})
      i <- unsafeReadSpan s
      hi <- readIORef (spanHot i)
      appendOnlyBoundedCollectionSize (hotLinks hi) `shouldBe` 0

    -- Trace API §End idempotency
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#end
    specify "endSpan is idempotent: second call preserves first timestamp" $ do
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      let t = makeTracer tp "woo" tracerOptions
      ts1 <- getTimestamp
      s <- createSpan t Context.empty "end_idem" defaultSpanArguments
      endSpan s (Just ts1)
      ts2 <- getTimestamp
      endSpan s (Just ts2)
      i <- unsafeReadSpan s
      hi <- readIORef (spanHot i)
      hotEnd hi `shouldBe` timestampToOptional ts1

    -- Trace SDK §Span processor: OnEnd invoked once per ended span
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#span-processor
    specify "endSpan calls processors exactly once" $ do
      callCount <- newAtomicCounter 0
      let countingProcessor =
            SpanProcessor
              { spanProcessorOnStart = \_ _ -> pure ()
              , spanProcessorOnEnd = \_ ->
                  void $ incrAtomicCounter callCount
              , spanProcessorShutdown = pure ShutdownSuccess
              , spanProcessorForceFlush = pure FlushSuccess
              }
      tp <- createTracerProvider [countingProcessor] emptyTracerProviderOptions
      let t = makeTracer tp "woo" tracerOptions
      s <- createSpan t Context.empty "proc_once" defaultSpanArguments
      endSpan s Nothing
      endSpan s Nothing
      endSpan s Nothing
      n <- readAtomicCounter callCount
      n `shouldBe` 1

    -- Implementation-specific: SpanStatus ordering mirrors API precedence
    specify "Ord SpanStatus: Ok > Error > Unset" $ do
      compare Unset (Error "x") `shouldBe` LT
      compare Unset Ok `shouldBe` LT
      compare (Error "x") Unset `shouldBe` GT
      compare (Error "x") Ok `shouldBe` LT
      compare Ok Unset `shouldBe` GT
      compare Ok (Error "x") `shouldBe` GT

    -- Implementation-specific: Ord instance for SpanStatus
    specify "Ord SpanStatus: Error/Error is EQ (lawful)" $ do
      compare (Error "a") (Error "b") `shouldBe` EQ
      compare (Error "b") (Error "a") `shouldBe` EQ
      (Error "a" <= Error "b") `shouldBe` True
      (Error "b" <= Error "a") `shouldBe` True

    -- Implementation-specific: concurrent mutations on one recording span
    specify "Safe for concurrent calls" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "concurrent-span" defaultSpanArguments
      mapConcurrently_
        ( \i -> do
            addAttribute s ("k" <> Text.pack (show (i :: Int))) (1 :: Int64)
            addEvent s $
              NewEvent
                { newEventName = "ev" <> Text.pack (show i)
                , newEventAttributes = mempty
                , newEventTimestamp = Nothing
                }
            setStatus s Ok
        )
        [(1 :: Int) .. 10]
    -- Trace SDK §Span limits: event count
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#span-limits
    specify "events collection size limit" $ asIO $ do
      let limits =
            defaultSpanLimits
              { eventCountLimit = Just 2
              }
          opts = emptyTracerProviderOptions {tracerProviderOptionsSpanLimits = limits}
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] opts
      let t = makeTracer tp "ev-limit" tracerOptions
      s <- createSpan t Context.empty "many-events" defaultSpanArguments
      forM_ [(1 :: Int) .. 5] $ \i ->
        addEvent s $
          NewEvent
            { newEventName = "e" <> Text.pack (show i)
            , newEventAttributes = mempty
            , newEventTimestamp = Nothing
            }
      im <- unsafeReadSpan s
      hm <- readIORef (spanHot im)
      appendOnlyBoundedCollectionSize (hotEvents hm) `shouldBe` 2
      appendOnlyBoundedCollectionDroppedElementCount (hotEvents hm) `shouldSatisfy` (> 0)
    -- Trace SDK §Span limits: attribute count
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#span-limits
    specify "attribute collection size limit" $ asIO $ do
      let limits =
            defaultSpanLimits
              { spanAttributeCountLimit = Just 2
              }
          opts = emptyTracerProviderOptions {tracerProviderOptionsSpanLimits = limits}
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] opts
      let t = makeTracer tp "attr-limit" tracerOptions
      s <- createSpan t Context.empty "many-attrs" defaultSpanArguments
      forM_ [(1 :: Int) .. 5] $ \i ->
        addAttribute s ("a" <> Text.pack (show i)) (fromIntegral i :: Int64)
      im <- unsafeReadSpan s
      hm <- readIORef (spanHot im)
      getCount (hotAttributes hm) `shouldBe` 2
    -- Trace SDK §Span limits: link count
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#span-limits
    specify "links collection size limit" $ asIO $ do
      let limits =
            defaultSpanLimits
              { linkCountLimit = Just 2
              }
          opts = emptyTracerProviderOptions {tracerProviderOptionsSpanLimits = limits}
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] opts
      let t = makeTracer tp "link-limit" tracerOptions
      links <-
        forM [(1 :: Int) .. 6] $ \_ -> do
          tid <- newTraceId defaultIdGenerator
          sid <- newSpanId defaultIdGenerator
          let sc =
                SpanContext
                  { traceFlags = defaultTraceFlags
                  , isRemote = False
                  , traceId = tid
                  , spanId = sid
                  , traceState = TraceState.empty
                  }
          pure $ NewLink {linkContext = sc, linkAttributes = mempty}
      s <-
        createSpan t Context.empty "many-links" $
          defaultSpanArguments {links = links}
      im <- unsafeReadSpan s
      hm <- readIORef (spanHot im)
      appendOnlyBoundedCollectionSize (hotLinks hm) `shouldBe` 2
      appendOnlyBoundedCollectionDroppedElementCount (hotLinks hm) `shouldSatisfy` (> 0)

  describe "Span attributes" $ do
    -- Trace API §Add attributes
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#add-attributes
    specify "SetAttribute" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "create_root_span" defaultSpanArguments
      addAttribute s "attr" (1.0 :: Double)

    -- Trace API §Add attributes (ordering preserved for export)
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#add-attributes
    specify "Set order preserved" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "ordered-attrs" defaultSpanArguments
      addAttribute s "a" (1 :: Int64)
      addAttribute s "b" (2 :: Int64)
      addAttribute s "c" (3 :: Int64)
      im <- unsafeReadSpan s
      hm <- readIORef (spanHot im)
      lookupAttribute (hotAttributes hm) "a" `shouldBe` Just (toAttribute (1 :: Int64))
      lookupAttribute (hotAttributes hm) "b" `shouldBe` Just (toAttribute (2 :: Int64))
      lookupAttribute (hotAttributes hm) "c" `shouldBe` Just (toAttribute (3 :: Int64))
    -- Trace API §Set attribute: primitive types
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#set-attributes
    specify "String type" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "create_root_span" defaultSpanArguments
      addAttribute s "string_type" ("" :: Text)

    -- Trace API §Set attribute: boolean
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#set-attributes
    specify "Boolean type" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "create_root_span" defaultSpanArguments
      addAttribute s "bool_type" True

    -- Trace API §Set attribute: double
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#set-attributes
    specify "Double floating-point type" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "create_root_span" defaultSpanArguments
      addAttribute s "attr" (1.0 :: Double)

    -- Trace API §Set attribute: integer
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#set-attributes
    specify "Signed int64 type" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "create_root_span" defaultSpanArguments
      addAttribute s "attr" (1 :: Int64)

    -- Trace API §Set attribute: array attributes
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#set-attributes
    specify "Array of primitives (homegeneous)" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "create_root_span" defaultSpanArguments
      addAttribute s "attr" [(1 :: Int64) .. 10]

    -- Trace API: UTF-8 keys and string attribute values
    -- https://opentelemetry.io/docs/specs/otel/common/#attribute-value-types
    specify "Unicode support for keys and string values" $ asIO $ do
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      let t = makeTracer tp "unicode-test" tracerOptions
      s <- createSpan t Context.empty "unicode_span" defaultSpanArguments
      addAttribute s "🚀" ("🚀" :: Text)
      im <- unsafeReadSpan s
      hm <- readIORef (spanHot im)
      lookupAttribute (hotAttributes hm) "🚀" `shouldBe` Just (toAttribute ("🚀" :: Text))

    -- Semantic conventions: source code attributes on span creation
    -- https://opentelemetry.io/docs/specs/semconv/general/attributes/#source-code-attributes
    specify "Source code attributes are added correctly" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- unsafeReadSpan =<< f t
      h <- readIORef (spanHot s)
      hotAttributes h `shouldSatisfy` \attrs ->
        (lookupAttribute attrs (unkey SC.code_function)) == Just (toAttribute @Text "f")
          && (lookupAttribute attrs (unkey SC.code_namespace)) == Just (toAttribute @Text "OpenTelemetry.TraceSpec")
          && isJust (lookupAttribute attrs (unkey SC.code_lineno))

    -- Implementation-specific: frozen CallStack disables automatic code.* attributes
    specify "Source code attributes are not added in the presence of frozen call stacks" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- unsafeReadSpan =<< g3 t
      h <- readIORef (spanHot s)
      hotAttributes h `shouldSatisfy` \attrs ->
        (lookupAttribute attrs (unkey SC.code_function)) == Nothing
          && (lookupAttribute attrs (unkey SC.code_namespace)) == Nothing
          && (lookupAttribute attrs (unkey SC.code_lineno)) == Nothing

    -- Semantic conventions: do not overwrite user-provided code.* attributes
    -- https://opentelemetry.io/docs/specs/semconv/general/attributes/#source-code-attributes
    specify "Source code attributes are not added if source attributes are already present" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- unsafeReadSpan =<< h t
      h <- readIORef (spanHot s)
      hotAttributes h `shouldSatisfy` \attrs ->
        (lookupAttribute attrs (unkey SC.code_function)) == Just (toAttribute @Text "something")
          && (lookupAttribute attrs (unkey SC.code_namespace)) == Nothing
          && (lookupAttribute attrs (unkey SC.code_lineno)) == Nothing

    -- Implementation-specific: callerAttributes through user wrapper frames
    specify "Source code attributes can be added for span creation wrappers" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- unsafeReadSpan =<< useSpanHelper t
      h <- readIORef (spanHot s)
      hotAttributes h `shouldSatisfy` \attrs ->
        (lookupAttribute attrs (unkey SC.code_function)) == Just (toAttribute @Text "useSpanHelper")

    -- Trace SDK §Span limits: attribute value length
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#span-limits
    specify "Attribute length limit is respected" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "test_span" defaultSpanArguments
      let
        longAttribute :: Text = "looooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooong"
        -- We set this limit in Spec.hs
        -- The long attribute should be truncated down to this length
        truncatedAttribute :: Text = Text.take 50 longAttribute
      addAttribute s "attr1" longAttribute
      addAttributes s (HM.singleton "attr2" (toAttribute longAttribute))
      im <- unsafeReadSpan s
      hm <- readIORef (spanHot im)

      lookupAttribute (hotAttributes hm) "attr1" `shouldBe` Just (toAttribute truncatedAttribute)
      lookupAttribute (hotAttributes hm) "attr2" `shouldBe` Just (toAttribute truncatedAttribute)

  describe "Span events" $ do
    -- Trace API §Add events
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#add-events
    specify "AddEvent" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "create_root_span" defaultSpanArguments
      addEvent s $
        NewEvent
          { newEventName = "EVENT"
          , newEventAttributes = mempty
          , newEventTimestamp = Nothing
          }
    -- Trace API §Add events: ordering preserved
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#add-events
    specify "Add order preserved" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "ordered-events" defaultSpanArguments
      addEvent s $ NewEvent {newEventName = "e1", newEventAttributes = mempty, newEventTimestamp = Nothing}
      addEvent s $ NewEvent {newEventName = "e2", newEventAttributes = mempty, newEventTimestamp = Nothing}
      addEvent s $ NewEvent {newEventName = "e3", newEventAttributes = mempty, newEventTimestamp = Nothing}
      im <- unsafeReadSpan s
      hm <- readIORef (spanHot im)
      let evs = appendOnlyBoundedCollectionValues (hotEvents hm)
      V.length evs `shouldBe` 3
      eventName (evs V.! 0) `shouldBe` "e1"
      eventName (evs V.! 1) `shouldBe` "e2"
      eventName (evs V.! 2) `shouldBe` "e3"
    -- Implementation-specific: concurrent addEvent on one span
    specify "Safe for concurrent calls" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "concurrent-events" defaultSpanArguments
      mapConcurrently_
        ( \i ->
            addEvent s $
              NewEvent
                { newEventName = "ce" <> Text.pack (show (i :: Int))
                , newEventAttributes = mempty
                , newEventTimestamp = Nothing
                }
        )
        [(1 :: Int) .. 10]
      im <- unsafeReadSpan s
      hm <- readIORef (spanHot im)
      appendOnlyBoundedCollectionSize (hotEvents hm) `shouldBe` 10

  describe "Span exceptions" $ do
    -- Trace API §Record exception
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#record-exception
    specify "inSpan records exception event on throw" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "exception-test" tracerOptions
      spanRef <- newIORef (error "span not set")
      handle (\(_ :: SomeException) -> pure ()) $ do
        inSpan' t "throwing-span" defaultSpanArguments $ \s -> do
          writeIORef spanRef s
          throwIO (userError "test exception")
      s <- unsafeReadSpan =<< readIORef spanRef
      hs <- readIORef (spanHot s)
      let events = appendOnlyBoundedCollectionValues (hotEvents hs)
      V.length events `shouldSatisfy` (>= 1)
      let ev = V.head events
      eventName ev `shouldBe` "exception"
      lookupAttribute (eventAttributes ev) (unkey SC.exception_type) `shouldSatisfy` isJust
      lookupAttribute (eventAttributes ev) (unkey SC.exception_message) `shouldSatisfy` isJust
    -- Trace API §Record exception (additional attributes)
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#record-exception
    specify "RecordException with extra parameters" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "rec-ex" defaultSpanArguments
      recordException
        s
        (HM.fromList [("http.status_code", toAttribute @Int 404)])
        Nothing
        (userError "extra attrs test")
      im <- unsafeReadSpan s
      hm <- readIORef (spanHot im)
      let evs = appendOnlyBoundedCollectionValues (hotEvents hm)
      V.length evs `shouldSatisfy` (>= 1)
      let ev = V.head evs
      eventName ev `shouldBe` "exception"
      lookupAttribute (eventAttributes ev) (unkey SC.exception_type) `shouldSatisfy` isJust
      lookupAttribute (eventAttributes ev) "http.status_code" `shouldBe` Just (toAttribute @Int 404)

  describe "SimpleProcessor" $ do
    -- Trace SDK §SimpleSpanProcessor
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#simple-span-processor
    it "exports spans synchronously on end" $ asIO $ do
      (processor, spansRef) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      let t = makeTracer tp "simple-test" tracerOptions
      s <- createSpan t Context.empty "test-span" defaultSpanArguments
      endSpan s Nothing
      spans <- readIORef spansRef
      length spans `shouldBe` 1
      case spans of
        (sp : _) -> do
          hot <- readIORef (spanHot sp)
          hotName hot `shouldBe` "test-span"
        [] -> expectationFailure "expected at least one exported span"

    -- Trace SDK §Shutdown: processors do not export after shutdown
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#shutdown
    it "stops processing after shutdown" $ asIO $ do
      exportedRef <- newIORef ([] :: [ImmutableSpan])
      let testExporter =
            SpanExporter
              { spanExporterExport = \batch -> do
                  let allSpans = concatMap V.toList (HM.elems batch)
                  atomicModifyIORef' exportedRef (\acc -> (acc ++ allSpans, ()))
                  pure Success
              , spanExporterShutdown = pure ShutdownSuccess
              , spanExporterForceFlush = pure FlushSuccess
              }
      processor <- simpleProcessor (SimpleProcessorConfig {spanExporter = testExporter, simpleSpanExportTimeoutMicros = 30_000_000})
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      let t = makeTracer tp "simple-test" tracerOptions
      _ <- shutdownTracerProvider tp Nothing
      s <- createSpan t Context.empty "after-shutdown" defaultSpanArguments
      endSpan s Nothing
      spans <- readIORef exportedRef
      length spans `shouldBe` 0

    -- Trace SDK §Shutdown: new spans are non-recording
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#shutdown
    it "createSpan returns non-recording span after shutdown" $ asIO $ do
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      let t = makeTracer tp "shutdown-test" tracerOptions
      _ <- shutdownTracerProvider tp Nothing
      s <- createSpan t Context.empty "after-shutdown-span" defaultSpanArguments
      recording <- isRecording s
      recording `shouldBe` False

    -- Trace SDK §SpanExporter: export after shutdown returns failure
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#spanexporter
    it "exporter returns Failure after shutdown" $ asIO $ do
      shutdownRef <- newIORef False
      let testExporter =
            SpanExporter
              { spanExporterExport = \_ -> do
                  isShutdown <- readIORef shutdownRef
                  if isShutdown
                    then pure $ Failure Nothing
                    else pure Success
              , spanExporterShutdown = atomicWriteIORef shutdownRef True >> pure ShutdownSuccess
              , spanExporterForceFlush = pure FlushSuccess
              }
      result1 <- spanExporterExport testExporter HM.empty
      case result1 of
        Success -> pure ()
        Failure _ -> expectationFailure "expected Success before shutdown"
      spanExporterShutdown testExporter
      result2 <- spanExporterExport testExporter HM.empty
      case result2 of
        Failure _ -> pure ()
        Success -> expectationFailure "expected Failure after shutdown"

  describe "BatchProcessor" $ do
    -- Trace SDK §BatchSpanProcessor: ForceFlush exports pending spans
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#batching-span-processor
    it "exports spans after forceFlush" $ asIO $ do
      exportedRef <- newIORef ([] :: [ImmutableSpan])
      let testExporter =
            SpanExporter
              { spanExporterExport = \batch -> do
                  let allSpans = concatMap V.toList (HM.elems batch)
                  atomicModifyIORef' exportedRef (\acc -> (acc ++ allSpans, ()))
                  pure Success
              , spanExporterShutdown = pure ShutdownSuccess
              , spanExporterForceFlush = pure FlushSuccess
              }
      batchProc <-
        batchProcessor
          (batchTimeoutConfig {scheduledDelayMillis = 60000})
          testExporter
      tp <- createTracerProvider [batchProc] emptyTracerProviderOptions
      let t = makeTracer tp "batch-test" tracerOptions
      s <- createSpan t Context.empty "batch-span" defaultSpanArguments
      endSpan s Nothing
      spansBeforeFlush <- readIORef exportedRef
      length spansBeforeFlush `shouldBe` 0
      _ <- forceFlushTracerProvider tp Nothing
      spansAfterFlush <- readIORef exportedRef
      length spansAfterFlush `shouldBe` 1
      case spansAfterFlush of
        (sp : _) -> do
          hot <- readIORef (spanHot sp)
          hotName hot `shouldBe` "batch-span"
        [] -> expectationFailure "expected at least one exported span after flush"

  describe "Processors" $ do
    -- Trace SDK §BatchSpanProcessor: bounded queue may drop spans
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#batching-span-processor
    it "batch span processor drops spans when queue is full" $ asIO $ do
      exportedRef <- newIORef ([] :: [ImmutableSpan])
      let testExporter =
            SpanExporter
              { spanExporterExport = \batch -> do
                  let allSpans = concatMap V.toList (HM.elems batch)
                  atomicModifyIORef' exportedRef (\acc -> (acc ++ allSpans, ()))
                  pure Success
              , spanExporterShutdown = pure ShutdownSuccess
              , spanExporterForceFlush = pure FlushSuccess
              }
          -- unagi-chan rounds up to next power of two, so requesting 8
          -- gives exactly 8 slots. We send 12 spans to guarantee some
          -- are dropped.
          config =
            batchTimeoutConfig
              { maxQueueSize = 8
              , scheduledDelayMillis = 60000
              , maxExportBatchSize = 100
              }
      batchProc <- batchProcessor config testExporter
      tp <- createTracerProvider [batchProc] emptyTracerProviderOptions
      let t = makeTracer tp "batch-queue-cap" tracerOptions
      forM_ [(1 :: Int) .. 12] $ \i -> do
        s <- createSpan t Context.empty ("q-" <> Text.pack (show i)) defaultSpanArguments
        endSpan s Nothing
      _ <- forceFlushTracerProvider tp Nothing
      spans <- readIORef exportedRef
      length spans `shouldSatisfy` (\n -> n >= 1 && n <= 8)

  describe "Sampling" $ do
    -- Trace SDK §Sampler: may return updated tracestate
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#sampler
    specify "Allow samplers to modify tracestate" $ asIO $ do
      let ts' = TraceState.insert (Key "ot-hs") (Value "sampler-wrote-this") TraceState.empty
          customSampler =
            CustomSampler "tracestate-tweak" $ \_ _ _ _ _scope ->
              pure $! SamplingDecision RecordAndSample mempty ts'
          opts = emptyTracerProviderOptions {tracerProviderOptionsSampler = customSampler}
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] opts
      let t = makeTracer tp "ts-sampler" tracerOptions
      s <- createSpan t Context.empty "ts-span" defaultSpanArguments
      sc <- getSpanContext s
      TraceState.lookup (Key "ot-hs") (traceState sc) `shouldBe` Just (Value "sampler-wrote-this")
    -- Trace SDK §ShouldSample: parent Context argument
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#shouldsample
    specify "ShouldSample gets full parent Context" $ asIO $ do
      ctxtRef <- newIORef Nothing
      let customSampler =
            CustomSampler "ctxt-capture" $ \ctxt _ _ _ _scope -> do
              writeIORef ctxtRef (Just ctxt)
              pure $! SamplingDecision RecordAndSample mempty TraceState.empty
          opts = emptyTracerProviderOptions {tracerProviderOptionsSampler = customSampler}
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] opts
      let t = makeTracer tp "ctxt-cap" tracerOptions
      parent <- createSpan t Context.empty "p" defaultSpanArguments
      let ctxt = Context.insertSpan parent mempty
      void $ createSpan t ctxt "c" defaultSpanArguments
      Just recorded <- readIORef ctxtRef
      case Context.lookupSpan recorded of
        Nothing -> expectationFailure "sampler should receive Context with parent span"
        Just sp -> do
          psc <- getSpanContext parent
          spsc <- getSpanContext sp
          psc `shouldBe` spsc
    -- Trace SDK §ShouldSample: instrumentation scope argument
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#shouldsample
    specify "ShouldSample gets InstrumentationLibrary" $ asIO $ do
      il <- pure $ instrumentationLibrary "il-sampler" "9.9.9"
      ilRef <- newIORef Nothing
      let customSampler =
            CustomSampler "il-check" $ \_ _ _ _ scope -> do
              writeIORef ilRef (Just scope)
              pure $! SamplingDecision RecordAndSample mempty TraceState.empty
          opts = emptyTracerProviderOptions {tracerProviderOptionsSampler = customSampler}
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] opts
      let t = makeTracer tp il tracerOptions
      void $ createSpan t Context.empty "il-span" defaultSpanArguments
      Just recorded <- readIORef ilRef
      recorded `shouldBe` il
      tracerName t `shouldBe` il

  -- Trace SDK §Behavior of the API in non-recording spans: new SpanId still allocated
  -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#behavior-of-the-api-in-non-recording-spans
  specify "New Span ID created also for non-recording spans" $ asIO $ do
    let opts =
          emptyTracerProviderOptions
            { tracerProviderOptionsSampler = alwaysOff
            , tracerProviderOptionsIdGenerator = defaultIdGenerator
            }
    (processor, _) <- inMemoryListExporter
    tp <- createTracerProvider [processor] opts
    let t = makeTracer tp "always-off" tracerOptions
    s1 <- createSpan t Context.empty "d1" defaultSpanArguments
    s2 <- createSpan t Context.empty "d2" defaultSpanArguments
    sc1 <- getSpanContext s1
    sc2 <- getSpanContext s2
    spanId sc1 `shouldNotBe` spanId sc2
    isEmptySpanId (spanId sc1) `shouldBe` False
    isEmptySpanId (spanId sc2) `shouldBe` False

  describe "Non-recording (Dropped) span" $ do
    -- Trace SDK §Behavior of the API in non-recording spans
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#behavior-of-the-api-in-non-recording-spans
    let mkDroppedSpan = do
          let opts =
                emptyTracerProviderOptions
                  { tracerProviderOptionsSampler = alwaysOff
                  , tracerProviderOptionsIdGenerator = defaultIdGenerator
                  }
          (processor, _) <- inMemoryListExporter
          tp <- createTracerProvider [processor] opts
          let t = makeTracer tp "always-off" tracerOptions
          createSpan t Context.empty "dropped" defaultSpanArguments

    -- Trace API §IsRecording false for dropped spans
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#isrecording
    specify "IsRecording is False" $ asIO $ do
      s <- mkDroppedSpan
      r <- isRecording s
      r `shouldBe` False

    -- Trace SDK §Behavior of the API in non-recording spans: attribute updates ignored
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#behavior-of-the-api-in-non-recording-spans
    specify "addAttribute is silently ignored" $ asIO $ do
      s <- mkDroppedSpan
      addAttribute s "key" (42 :: Int64)
      r <- isRecording s
      r `shouldBe` False

    -- Trace SDK §Behavior of the API in non-recording spans: events ignored
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#behavior-of-the-api-in-non-recording-spans
    specify "addEvent is silently ignored" $ asIO $ do
      s <- mkDroppedSpan
      addEvent s $
        NewEvent
          { newEventName = "ghost"
          , newEventAttributes = mempty
          , newEventTimestamp = Nothing
          }
      r <- isRecording s
      r `shouldBe` False

    -- Trace SDK §Behavior of the API in non-recording spans: setStatus ignored
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#behavior-of-the-api-in-non-recording-spans
    specify "setStatus is silently ignored" $ asIO $ do
      s <- mkDroppedSpan
      setStatus s (Error "should not exist")
      r <- isRecording s
      r `shouldBe` False

    -- Trace SDK §Behavior of the API in non-recording spans: updateName ignored
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#behavior-of-the-api-in-non-recording-spans
    specify "updateName is silently ignored" $ asIO $ do
      s <- mkDroppedSpan
      updateName s "new-name"
      r <- isRecording s
      r `shouldBe` False

    -- Trace SDK §Behavior of the API in non-recording spans: addLink ignored
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#behavior-of-the-api-in-non-recording-spans
    specify "addLink is silently ignored" $ asIO $ do
      s <- mkDroppedSpan
      tid <- newTraceId defaultIdGenerator
      sid <- newSpanId defaultIdGenerator
      let sc =
            SpanContext
              { traceFlags = defaultTraceFlags
              , isRemote = False
              , traceId = tid
              , spanId = sid
              , traceState = TraceState.empty
              }
      addLink s (NewLink {linkContext = sc, linkAttributes = mempty})
      r <- isRecording s
      r `shouldBe` False

    -- Trace SDK §Behavior of the API in non-recording spans: end does not call processors
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#behavior-of-the-api-in-non-recording-spans
    specify "endSpan does not invoke processors" $ asIO $ do
      callCount <- newAtomicCounter 0
      let countingProcessor =
            SpanProcessor
              { spanProcessorOnStart = \_ _ -> pure ()
              , spanProcessorOnEnd = \_ ->
                  void $ incrAtomicCounter callCount
              , spanProcessorShutdown = pure ShutdownSuccess
              , spanProcessorForceFlush = pure FlushSuccess
              }
      tp <- createTracerProvider [countingProcessor] (emptyTracerProviderOptions {tracerProviderOptionsSampler = alwaysOff})
      let t = makeTracer tp "always-off" tracerOptions
      s <- createSpan t Context.empty "dropped-no-proc" defaultSpanArguments
      endSpan s Nothing
      n <- readAtomicCounter callCount
      n `shouldBe` 0

  describe "Sampler tracestate propagation" $ do
    -- Trace SDK §Sampler: returned tracestate on new span
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#sampler
    specify "Sampler tracestate is set on created span" $ asIO $ do
      let ts' = TraceState.insert (Key "vendor") (Value "data") TraceState.empty
          tsSampler =
            CustomSampler "ts-writer" $ \_ _ _ _ _scope ->
              pure $! SamplingDecision RecordAndSample mempty ts'
          opts = emptyTracerProviderOptions {tracerProviderOptionsSampler = tsSampler}
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] opts
      let t = makeTracer tp "ts-writer" tracerOptions
      s <- createSpan t Context.empty "with-ts" defaultSpanArguments
      sc <- getSpanContext s
      traceState sc `shouldBe` ts'

    -- Trace API §TraceState propagation through parent Context
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#tracestate
    specify "Child sampler sees parent tracestate via Context" $ asIO $ do
      let ts' = TraceState.insert (Key "vendor") (Value "data") TraceState.empty
          rootSampler =
            CustomSampler "ts-root" $ \_ _ _ _ _scope ->
              pure $! SamplingDecision RecordAndSample mempty ts'
          childSampler =
            CustomSampler "ts-passthrough" $ \ctx _ _ _ _scope -> do
              msp <- sequence (getSpanContext <$> Context.lookupSpan ctx)
              let parentTs = maybe TraceState.empty traceState msp
              pure $! SamplingDecision RecordAndSample mempty parentTs
      (proc1, _) <- inMemoryListExporter
      tp1 <- createTracerProvider [proc1] (emptyTracerProviderOptions {tracerProviderOptionsSampler = rootSampler})
      let t1 = makeTracer tp1 "root" tracerOptions
      parent <- createSpan t1 Context.empty "parent" defaultSpanArguments
      parentSc <- getSpanContext parent
      traceState parentSc `shouldBe` ts'
      (proc2, _) <- inMemoryListExporter
      tp2 <- createTracerProvider [proc2] (emptyTracerProviderOptions {tracerProviderOptionsSampler = childSampler})
      let t2 = makeTracer tp2 "child" tracerOptions
          childCtx = Context.insertSpan parent Context.empty
      child <- createSpan t2 childCtx "child" defaultSpanArguments
      childSc <- getSpanContext child
      traceState childSc `shouldBe` ts'

  -- Trace SDK §Id generators (random, non-zero ids)
  -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#id-generators
  specify "IdGenerators" $ asIO $ do
    tids <- replicateM 20 (newTraceId defaultIdGenerator)
    sids <- replicateM 20 (newSpanId defaultIdGenerator)
    length (nub tids) `shouldBe` 20
    length (nub sids) `shouldBe` 20
    all (not . isEmptyTraceId) tids `shouldBe` True
    all (not . isEmptySpanId) sids `shouldBe` True

  describe "W3C Level 2 random flag" $ do
    -- W3C Trace Context Level 2: trace-flags random bit (R)
    -- https://www.w3.org/TR/trace-context-2/#random-trace-id-flag
    specify "root span with DefaultIdGenerator has random flag set" $ asIO $ do
      let opts =
            emptyTracerProviderOptions
              { tracerProviderOptionsSampler = alwaysOn
              , tracerProviderOptionsIdGenerator = defaultIdGenerator
              }
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] opts
      let t = makeTracer tp "random-flag-test" tracerOptions
      s <- createSpan t Context.empty "root" defaultSpanArguments
      sc <- getSpanContext s
      isRandom (traceFlags sc) `shouldBe` True
      isSampled (traceFlags sc) `shouldBe` True
      endSpan s Nothing

    -- Trace SDK §Id generators: custom generator may omit R flag semantics
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#id-generators
    specify "root span with CustomIdGenerator does NOT have random flag" $ asIO $ do
      let customGen = customIdGenerator (SBS.toShort . spanIdBytes <$> newSpanId defaultIdGenerator) (SBS.toShort . traceIdBytes <$> newTraceId defaultIdGenerator)
          opts =
            emptyTracerProviderOptions
              { tracerProviderOptionsSampler = alwaysOn
              , tracerProviderOptionsIdGenerator = customGen
              }
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] opts
      let t = makeTracer tp "custom-gen-test" tracerOptions
      s <- createSpan t Context.empty "root" defaultSpanArguments
      sc <- getSpanContext s
      isRandom (traceFlags sc) `shouldBe` False
      isSampled (traceFlags sc) `shouldBe` True
      endSpan s Nothing

    -- W3C Trace Context Level 2: R flag propagation on child spans
    -- https://www.w3.org/TR/trace-context-2/#random-trace-id-flag
    specify "child span inherits random flag from parent" $ asIO $ do
      let opts =
            emptyTracerProviderOptions
              { tracerProviderOptionsSampler = alwaysOn
              , tracerProviderOptionsIdGenerator = defaultIdGenerator
              }
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] opts
      let t = makeTracer tp "inherit-random" tracerOptions
      parent <- createSpan t Context.empty "parent" defaultSpanArguments
      parentSc <- getSpanContext parent
      isRandom (traceFlags parentSc) `shouldBe` True
      let childCtx = Context.insertSpan parent Context.empty
      child <- createSpan t childCtx "child" defaultSpanArguments
      childSc <- getSpanContext child
      isRandom (traceFlags childSc) `shouldBe` True
      traceId childSc `shouldBe` traceId parentSc
      endSpan child Nothing
      endSpan parent Nothing

    -- Trace SDK: R flag independent of sampling for locally generated root
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#id-generators
    specify "dropped (alwaysOff) root span with DefaultIdGenerator has random flag" $ asIO $ do
      let opts =
            emptyTracerProviderOptions
              { tracerProviderOptionsSampler = alwaysOff
              , tracerProviderOptionsIdGenerator = defaultIdGenerator
              }
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] opts
      let t = makeTracer tp "dropped-random" tracerOptions
      s <- createSpan t Context.empty "dropped-root" defaultSpanArguments
      sc <- getSpanContext s
      isRandom (traceFlags sc) `shouldBe` True
      isSampled (traceFlags sc) `shouldBe` False

  describe "SpanExporter result types" $ do
    -- Trace SDK §SpanExporter.Shutdown result
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#spanexporter
    specify "shutdown returns ShutdownSuccess" $ asIO $ do
      let exporter =
            SpanExporter
              { spanExporterExport = \_ -> pure Success
              , spanExporterShutdown = pure ShutdownSuccess
              , spanExporterForceFlush = pure FlushSuccess
              }
      spanExporterShutdown exporter `shouldReturn` ShutdownSuccess

    -- Trace SDK §SpanExporter.ForceFlush result
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#spanexporter
    specify "forceFlush returns FlushSuccess" $ asIO $ do
      let exporter =
            SpanExporter
              { spanExporterExport = \_ -> pure Success
              , spanExporterShutdown = pure ShutdownSuccess
              , spanExporterForceFlush = pure FlushSuccess
              }
      spanExporterForceFlush exporter `shouldReturn` FlushSuccess

    -- Trace SDK §SimpleSpanProcessor.Shutdown delegates to exporter
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#simple-span-processor
    specify "simple processor propagates exporter shutdown result" $ asIO $ do
      let exporter =
            SpanExporter
              { spanExporterExport = \_ -> pure Success
              , spanExporterShutdown = pure ShutdownSuccess
              , spanExporterForceFlush = pure FlushSuccess
              }
      proc <- simpleProcessor (SimpleProcessorConfig exporter 30_000_000)
      result <- spanProcessorShutdown proc
      result `shouldBe` ShutdownSuccess

    -- Trace SDK §SimpleSpanProcessor.ForceFlush delegates to exporter
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#simple-span-processor
    specify "simple processor propagates exporter flush result" $ asIO $ do
      let exporter =
            SpanExporter
              { spanExporterExport = \_ -> pure Success
              , spanExporterShutdown = pure ShutdownSuccess
              , spanExporterForceFlush = pure FlushSuccess
              }
      proc <- simpleProcessor (SimpleProcessorConfig exporter 30_000_000)
      result <- spanProcessorForceFlush proc
      result `shouldBe` FlushSuccess

  -- Trace SDK §Span limits (attributes, events, links combined)
  -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#span-limits
  specify "SpanLimits" $ asIO $ do
    let limits =
          SpanLimits
            { spanAttributeValueLengthLimit = Nothing
            , spanAttributeCountLimit = Just 1
            , eventCountLimit = Just 1
            , eventAttributeCountLimit = Nothing
            , linkCountLimit = Just 1
            , linkAttributeCountLimit = Nothing
            }
        opts = emptyTracerProviderOptions {tracerProviderOptionsSpanLimits = limits}
    (processor, _) <- inMemoryListExporter
    tp <- createTracerProvider [processor] opts
    let t = makeTracer tp "all-limits" tracerOptions
    link0 <- do
      tid <- newTraceId defaultIdGenerator
      sid <- newSpanId defaultIdGenerator
      let sc =
            SpanContext
              { traceFlags = defaultTraceFlags
              , isRemote = False
              , traceId = tid
              , spanId = sid
              , traceState = TraceState.empty
              }
      pure $ NewLink {linkContext = sc, linkAttributes = mempty}
    link1 <- do
      tid <- newTraceId defaultIdGenerator
      sid <- newSpanId defaultIdGenerator
      let sc =
            SpanContext
              { traceFlags = defaultTraceFlags
              , isRemote = False
              , traceId = tid
              , spanId = sid
              , traceState = TraceState.empty
              }
      pure $ NewLink {linkContext = sc, linkAttributes = mempty}
    s <-
      createSpan t Context.empty "combo" $
        defaultSpanArguments
          { links = [link0, link1]
          }
    addAttribute s "a1" (1 :: Int64)
    addAttribute s "a2" (2 :: Int64)
    addEvent s $ NewEvent {newEventName = "e1", newEventAttributes = mempty, newEventTimestamp = Nothing}
    addEvent s $ NewEvent {newEventName = "e2", newEventAttributes = mempty, newEventTimestamp = Nothing}
    im <- unsafeReadSpan s
    hm <- readIORef (spanHot im)
    getCount (hotAttributes hm) `shouldBe` 1
    appendOnlyBoundedCollectionSize (hotEvents hm) `shouldBe` 1
    appendOnlyBoundedCollectionSize (hotLinks hm) `shouldBe` 1
  -- Trace SDK §SpanProcessor.ForceFlush (built-in processors)
  -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#spanprocessor
  specify "Built-in Processors implement ForceFlush spec" $ asIO $ do
    exportedRef <- newIORef ([] :: [ImmutableSpan])
    let testExporter =
          SpanExporter
            { spanExporterExport = \batch -> do
                let allSpans = concatMap V.toList (HM.elems batch)
                atomicModifyIORef' exportedRef (\acc -> (acc ++ allSpans, ()))
                pure Success
            , spanExporterShutdown = pure ShutdownSuccess
            , spanExporterForceFlush = pure FlushSuccess
            }
    simpleProc <- simpleProcessor (SimpleProcessorConfig {spanExporter = testExporter, simpleSpanExportTimeoutMicros = 30_000_000})
    _ <- spanProcessorForceFlush simpleProc
    batchProc <-
      batchProcessor
        (batchTimeoutConfig {scheduledDelayMillis = 60000})
        testExporter
    _ <- spanProcessorForceFlush batchProc
    pure ()
  -- Trace SDK §BatchSpanProcessor.Shutdown idempotency
  -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#batching-span-processor
  specify "Batch processor shutdown is idempotent (no deadlock)" $ asIO $ do
    let testExporter =
          SpanExporter
            { spanExporterExport = \_ -> pure Success
            , spanExporterShutdown = pure ShutdownSuccess
            , spanExporterForceFlush = pure FlushSuccess
            }
    proc <- batchProcessor batchTimeoutConfig testExporter
    r1 <- spanProcessorShutdown proc
    r1 `shouldBe` ShutdownSuccess
    r2 <- spanProcessorShutdown proc
    r2 `shouldBe` ShutdownSuccess

  -- Trace SDK §BatchSpanProcessor: no export after processor shutdown
  -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#batching-span-processor
  specify "Batch processor OnEnd after shutdown does not export" $ asIO $ do
    exportedRef <- newIORef ([] :: [ImmutableSpan])
    let testExporter =
          SpanExporter
            { spanExporterExport = \batch -> do
                let allSpans = concatMap V.toList (HM.elems batch)
                atomicModifyIORef' exportedRef (\acc -> (acc ++ allSpans, ()))
                pure Success
            , spanExporterShutdown = pure ShutdownSuccess
            , spanExporterForceFlush = pure FlushSuccess
            }
    batchProc <-
      batchProcessor
        (batchTimeoutConfig {scheduledDelayMillis = 60000})
        testExporter
    tp <- createTracerProvider [batchProc] emptyTracerProviderOptions
    let t = makeTracer tp "batch-shutdown-onend" tracerOptions
    _ <- spanProcessorShutdown batchProc
    s <- createSpan t Context.empty "after-batch-shutdown" defaultSpanArguments
    endSpan s Nothing
    -- Give the batch processor a chance to flush (it shouldn't, since it's shut down)
    _ <- forceFlushTracerProvider tp Nothing
    spans <- readIORef exportedRef
    length spans `shouldBe` 0

  -- General SDK env: OTEL_BSP_MAX_QUEUE_SIZE default (BatchSpanProcessor)
  -- https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/
  specify "BSP default maxQueueSize is 2048" $ asIO $ do
    maxQueueSize batchTimeoutConfig `shouldBe` 2048

  -- Logs SDK §BatchLogRecordProcessor.Shutdown idempotency
  -- https://opentelemetry.io/docs/specs/otel/logs/sdk/#batchlogrecordprocessor
  specify "Batch log record processor shutdown is idempotent" $ asIO $ do
    testExporter <-
      mkLogRecordExporter
        LogRecordExporterArguments
          { logRecordExporterArgumentsExport = \_ -> pure Success
          , logRecordExporterArgumentsForceFlush = pure FlushSuccess
          , logRecordExporterArgumentsShutdown = pure ()
          }
    proc <-
      batchLogRecordProcessor
        (defaultBatchLogRecordProcessorConfig testExporter)
          { batchLogScheduledDelayMillis = 60000
          }
    r1 <- logRecordProcessorShutdown proc
    r1 `shouldBe` ShutdownSuccess
    r2 <- logRecordProcessorShutdown proc
    r2 `shouldBe` ShutdownSuccess

  describe "BSP config validation" $ do
    -- General SDK env: OTEL_BSP_MAX_EXPORT_BATCH_SIZE must not exceed queue size
    -- https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/
    specify "maxExportBatchSize is clamped to maxQueueSize via env" $ do
      bracket
        ( do
            savedQueue <- lookupEnv "OTEL_BSP_MAX_QUEUE_SIZE"
            savedBatch <- lookupEnv "OTEL_BSP_MAX_EXPORT_BATCH_SIZE"
            setEnv "OTEL_BSP_MAX_QUEUE_SIZE" "100"
            setEnv "OTEL_BSP_MAX_EXPORT_BATCH_SIZE" "500"
            pure (savedQueue, savedBatch)
        )
        ( \(savedQueue, savedBatch) -> do
            maybe (unsetEnv "OTEL_BSP_MAX_QUEUE_SIZE") (setEnv "OTEL_BSP_MAX_QUEUE_SIZE") savedQueue
            maybe (unsetEnv "OTEL_BSP_MAX_EXPORT_BATCH_SIZE") (setEnv "OTEL_BSP_MAX_EXPORT_BATCH_SIZE") savedBatch
        )
        $ \_ -> do
          conf <- detectBatchProcessorConfig
          maxExportBatchSize conf `shouldBe` 100
          maxQueueSize conf `shouldBe` 100

    -- General SDK env: valid BSP queue/batch size pair preserved
    -- https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/
    specify "maxExportBatchSize <= maxQueueSize is left alone" $ do
      bracket
        ( do
            savedQueue <- lookupEnv "OTEL_BSP_MAX_QUEUE_SIZE"
            savedBatch <- lookupEnv "OTEL_BSP_MAX_EXPORT_BATCH_SIZE"
            setEnv "OTEL_BSP_MAX_QUEUE_SIZE" "1000"
            setEnv "OTEL_BSP_MAX_EXPORT_BATCH_SIZE" "200"
            pure (savedQueue, savedBatch)
        )
        ( \(savedQueue, savedBatch) -> do
            maybe (unsetEnv "OTEL_BSP_MAX_QUEUE_SIZE") (setEnv "OTEL_BSP_MAX_QUEUE_SIZE") savedQueue
            maybe (unsetEnv "OTEL_BSP_MAX_EXPORT_BATCH_SIZE") (setEnv "OTEL_BSP_MAX_EXPORT_BATCH_SIZE") savedBatch
        )
        $ \_ -> do
          conf <- detectBatchProcessorConfig
          maxExportBatchSize conf `shouldBe` 200
          maxQueueSize conf `shouldBe` 1000

  describe "Simple span processor export serialization" $ do
    -- Trace SDK §SimpleSpanProcessor: export serialization (implementation detail)
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#simple-span-processor
    specify "concurrent endSpan calls do not overlap exports" $ asIO $ do
      activeExports <- newIORef (0 :: Int)
      maxConcurrent <- newIORef (0 :: Int)
      let serialExporter =
            SpanExporter
              { spanExporterExport = \_ -> do
                  n <- atomicModifyIORef' activeExports (\c -> (c + 1, c + 1))
                  atomicModifyIORef' maxConcurrent (\m -> (max m n, ()))
                  atomicModifyIORef' activeExports (\c -> (c - 1, ()))
                  pure Success
              , spanExporterShutdown = pure ShutdownSuccess
              , spanExporterForceFlush = pure FlushSuccess
              }
      processor <- simpleProcessor (SimpleProcessorConfig {spanExporter = serialExporter, simpleSpanExportTimeoutMicros = 30_000_000})
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      let t = makeTracer tp "serial-test" tracerOptions
      doneVar <- newEmptyMVar
      forM_ [(1 :: Int) .. 20] $ \_ -> forkIO $ do
        s <- createSpan t Context.empty "concurrent-span" defaultSpanArguments
        endSpan s Nothing
      forkIO $ do
        forM_ [(1 :: Int) .. 20] $ \_ -> do
          s <- createSpan t Context.empty "concurrent-span2" defaultSpanArguments
          endSpan s Nothing
        putMVar doneVar ()
      takeMVar doneVar
      _ <- forceFlushTracerProvider tp Nothing
      peak <- readIORef maxConcurrent
      peak `shouldBe` 1

  describe "service.name precedence" $ do
    -- Resource SDK / General SDK env: OTEL_SERVICE_NAME vs OTEL_RESOURCE_ATTRIBUTES
    -- https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/
    specify "OTEL_SERVICE_NAME takes precedence over OTEL_RESOURCE_ATTRIBUTES service.name" $ do
      bracket
        ( do
            savedSvcName <- lookupEnv "OTEL_SERVICE_NAME"
            savedResAttrs <- lookupEnv "OTEL_RESOURCE_ATTRIBUTES"
            setEnv "OTEL_SERVICE_NAME" "from-service-name-env"
            setEnv "OTEL_RESOURCE_ATTRIBUTES" "service.name=from-resource-attrs,other.key=val"
            pure (savedSvcName, savedResAttrs)
        )
        ( \(savedSvcName, savedResAttrs) -> do
            maybe (unsetEnv "OTEL_SERVICE_NAME") (setEnv "OTEL_SERVICE_NAME") savedSvcName
            maybe (unsetEnv "OTEL_RESOURCE_ATTRIBUTES") (setEnv "OTEL_RESOURCE_ATTRIBUTES") savedResAttrs
        )
        $ \_ -> do
          (_procs, opts) <- getTracerProviderInitializationOptions' (mempty :: Resource)
          let attrs = getMaterializedResourcesAttributes (tracerProviderOptionsResources opts)
          lookupAttribute attrs (unkey SC.service_name) `shouldBe` Just (toAttribute @Text "from-service-name-env")

    -- General SDK env: OTEL_SERVICE_NAME overrides configured Resource
    -- https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/
    specify "OTEL_SERVICE_NAME wins over user-supplied resource" $ do
      bracket
        ( do
            savedSvcName <- lookupEnv "OTEL_SERVICE_NAME"
            setEnv "OTEL_SERVICE_NAME" "env-wins"
            pure savedSvcName
        )
        (maybe (unsetEnv "OTEL_SERVICE_NAME") (setEnv "OTEL_SERVICE_NAME"))
        $ \_ -> do
          let userRs = mkResource [unkey SC.service_name .= ("user-supplied" :: Text)]
          (_procs, opts) <- getTracerProviderInitializationOptions' userRs
          let attrs = getMaterializedResourcesAttributes (tracerProviderOptionsResources opts)
          lookupAttribute attrs (unkey SC.service_name) `shouldBe` Just (toAttribute @Text "env-wins")

  describe "OTEL_SDK_DISABLED" $ do
    -- initializeGlobalTracerProvider: when OTEL_SDK_DISABLED=true, YAML from OTEL_CONFIG_FILE
    -- must be ignored (no processors from file). Covered by implementation; an automated test
    -- would need a committed fixture config and global provider isolation.

    -- General SDK env: OTEL_SDK_DISABLED (propagators still configured)
    -- https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/
    specify "still configures propagators when SDK is disabled" $ do
      bracket
        ( do
            savedDisabled <- lookupEnv "OTEL_SDK_DISABLED"
            savedPropagators <- lookupEnv "OTEL_PROPAGATORS"
            savedPropagator <- getGlobalTextMapPropagator
            setGlobalTextMapPropagator mempty
            setEnv "OTEL_SDK_DISABLED" "true"
            unsetEnv "OTEL_PROPAGATORS"
            pure (savedDisabled, savedPropagators, savedPropagator)
        )
        ( \(savedDisabled, savedPropagators, savedPropagator) -> do
            maybe (unsetEnv "OTEL_SDK_DISABLED") (setEnv "OTEL_SDK_DISABLED") savedDisabled
            maybe (unsetEnv "OTEL_PROPAGATORS") (setEnv "OTEL_PROPAGATORS") savedPropagators
            setGlobalTextMapPropagator savedPropagator
        )
        $ \_ -> do
          _ <- getTracerProviderInitializationOptions' (mempty :: Resource)
          prop <- getGlobalTextMapPropagator
          propagatorFields prop `shouldNotBe` []

    -- General SDK env: OTEL_SDK_DISABLED disables span processors
    -- https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/
    specify "OTEL_SDK_DISABLED=true produces a provider with no processors" $ do
      bracket
        ( do
            savedDisabled <- lookupEnv "OTEL_SDK_DISABLED"
            setEnv "OTEL_SDK_DISABLED" "true"
            pure savedDisabled
        )
        (maybe (unsetEnv "OTEL_SDK_DISABLED") (setEnv "OTEL_SDK_DISABLED"))
        $ \_ -> do
          (procs, _opts) <- getTracerProviderInitializationOptions' (mempty :: Resource)
          length procs `shouldBe` 0

  describe "Registry-based detection" $ do
    -- Implementation-specific: plugin registry for OTEL_TRACES_EXPORTER
    specify "detectExporters resolves a user-registered exporter factory" $ do
      exportCalledRef <- newIORef False
      let customFactory =
            pure
              SpanExporter
                { spanExporterExport = \_ -> writeIORef exportCalledRef True >> pure Success
                , spanExporterShutdown = pure ShutdownSuccess
                , spanExporterForceFlush = pure FlushSuccess
                }
      Registry.registerSpanExporterFactory "test-custom-exporter" customFactory
      bracket
        ( do
            saved <- lookupEnv "OTEL_TRACES_EXPORTER"
            setEnv "OTEL_TRACES_EXPORTER" "test-custom-exporter"
            pure saved
        )
        (maybe (unsetEnv "OTEL_TRACES_EXPORTER") (setEnv "OTEL_TRACES_EXPORTER"))
        $ \_ -> do
          (procs, _opts) <- getTracerProviderInitializationOptions' (mempty :: Resource)
          length procs `shouldBe` 1

    -- Propagators API + Implementation-specific: OTEL_PROPAGATORS registry
    -- https://opentelemetry.io/docs/specs/otel/context/api-propagators/
    specify "detectPropagators resolves a user-registered propagator" $ do
      let customProp =
            Propagator
              { propagatorFields = ["x-custom-test-header"]
              , extractor = \_ c -> pure c
              , injector = \_ hs -> pure hs
              }
      Registry.registerTextMapPropagator "test-custom-prop" customProp
      bracket
        ( do
            savedProp <- lookupEnv "OTEL_PROPAGATORS"
            savedGlobal <- getGlobalTextMapPropagator
            setEnv "OTEL_PROPAGATORS" "test-custom-prop"
            pure (savedProp, savedGlobal)
        )
        ( \(savedProp, savedGlobal) -> do
            maybe (unsetEnv "OTEL_PROPAGATORS") (setEnv "OTEL_PROPAGATORS") savedProp
            setGlobalTextMapPropagator savedGlobal
        )
        $ \_ -> do
          _ <- getTracerProviderInitializationOptions' (mempty :: Resource)
          globalProp <- getGlobalTextMapPropagator
          propagatorFields globalProp `shouldBe` ["x-custom-test-header"]

    -- Implementation-specific: registry overrides built-in exporter factories
    specify "user-registered exporter takes precedence over builtin" $ do
      userCalledRef <- newIORef False
      let userOtlpFactory =
            pure
              SpanExporter
                { spanExporterExport = \_ -> writeIORef userCalledRef True >> pure Success
                , spanExporterShutdown = pure ShutdownSuccess
                , spanExporterForceFlush = pure FlushSuccess
                }
      Registry.registerSpanExporterFactory "otlp" userOtlpFactory
      bracket
        ( do
            saved <- lookupEnv "OTEL_TRACES_EXPORTER"
            setEnv "OTEL_TRACES_EXPORTER" "otlp"
            pure saved
        )
        (maybe (unsetEnv "OTEL_TRACES_EXPORTER") (setEnv "OTEL_TRACES_EXPORTER"))
        $ \_ -> do
          (procs, _opts) <- getTracerProviderInitializationOptions' (mempty :: Resource)
          length procs `shouldBe` 1

    -- General SDK env: OTEL_TRACES_EXPORTER=none
    -- https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/
    specify "OTEL_TRACES_EXPORTER=none returns no processors regardless of registry" $ do
      Registry.registerSpanExporterFactory "test-ignored" (noopExporter "ignored")
      bracket
        ( do
            saved <- lookupEnv "OTEL_TRACES_EXPORTER"
            setEnv "OTEL_TRACES_EXPORTER" "none"
            pure saved
        )
        (maybe (unsetEnv "OTEL_TRACES_EXPORTER") (setEnv "OTEL_TRACES_EXPORTER"))
        $ \_ -> do
          (procs, _opts) <- getTracerProviderInitializationOptions' (mempty :: Resource)
          length procs `shouldBe` 0

    -- General SDK env: OTEL_PROPAGATORS=none
    -- https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/
    specify "OTEL_PROPAGATORS=none yields empty propagator fields" $ do
      bracket
        ( do
            savedProp <- lookupEnv "OTEL_PROPAGATORS"
            savedGlobal <- getGlobalTextMapPropagator
            setEnv "OTEL_PROPAGATORS" "none"
            pure (savedProp, savedGlobal)
        )
        ( \(savedProp, savedGlobal) -> do
            maybe (unsetEnv "OTEL_PROPAGATORS") (setEnv "OTEL_PROPAGATORS") savedProp
            setGlobalTextMapPropagator savedGlobal
        )
        $ \_ -> do
          _ <- getTracerProviderInitializationOptions' (mempty :: Resource)
          globalProp <- getGlobalTextMapPropagator
          propagatorFields globalProp `shouldBe` []

  -- Trace SDK §Span limits: attribute count cap
  -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#span-limits
  specify "Attribute Limits" $ asIO $ do
    let limits =
          defaultSpanLimits
            { spanAttributeCountLimit = Just 3
            }
        opts = emptyTracerProviderOptions {tracerProviderOptionsSpanLimits = limits}
    (processor, _) <- inMemoryListExporter
    tp <- createTracerProvider [processor] opts
    let t = makeTracer tp "attr-count-limit" tracerOptions
    s <- createSpan t Context.empty "attr-cap" defaultSpanArguments
    forM_ [(1 :: Int) .. 10] $ \i ->
      addAttribute s ("x" <> Text.pack (show i)) (fromIntegral i :: Int64)
    im <- unsafeReadSpan s
    hm <- readIORef (spanHot im)
    getCount (hotAttributes hm) `shouldBe` 3

#if !defined(mingw32_HOST_OS)
  describe "withTracerProvider" $ do
    -- Implementation-specific: signal-driven TracerProvider shutdown (process helper)
    it "SIGTERM triggers graceful shutdown via bracket cleanup" $ do
      exePath <- getExecutablePath
      markerPath <- newMarkerFile
      (_, Just childOut, _, ph) <- createProcess
        (proc exePath ["--signal-test-helper", markerPath])
          { std_out = CreatePipe
          , delegate_ctlc = False
          }

      ready <- hGetLine childOut
      ready `shouldBe` "READY"

      mPid <- getPid ph
      case mPid of
        Nothing -> expectationFailure "Could not get child PID"
        Just pid -> signalProcess sigTERM (fromIntegral pid)

      _exitCode <- waitForProcess ph
      hClose childOut

      contents <- readFile markerPath
      contents `shouldBe` "SHUTDOWN_COMPLETE"
      removeFile markerPath
#endif

{- ORMOLU_DISABLE -}
  describe "TracerProvider lifecycle" $ do
    -- Trace SDK §Shutdown TracerProvider: idempotent shutdown, subsequent spans non-recording
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#shutdown
    specify "double shutdown is safe; second call returns failure" $ do
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      r1 <- shutdownTracerProvider tp Nothing
      r1 `shouldBe` ShutdownSuccess
      r2 <- shutdownTracerProvider tp Nothing
      r2 `shouldBe` ShutdownFailure
      let t = makeTracer tp "double-shutdown" tracerOptions
      s <- createSpan t Context.empty "after-double-shutdown" defaultSpanArguments
      recording <- isRecording s
      recording `shouldBe` False

    -- Trace SDK §ForceFlush after Shutdown (must not hang)
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#forceflushtracerprovider
    specify "forceFlush after shutdown completes without hanging" $ asIO $ do
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      let t = makeTracer tp "flush-after-shutdown" tracerOptions
      s <- createSpan t Context.empty "s" defaultSpanArguments
      endSpan s Nothing
      _ <- shutdownTracerProvider tp Nothing
      void $ forceFlushTracerProvider tp Nothing

    -- OTel Trace SDK §TracerProvider: after Shutdown, ForceFlush SHOULD be a no-op
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#forceflushtracerprovider
    specify "forceFlush after shutdown returns FlushError" $ asIO $ do
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      _ <- shutdownTracerProvider tp Nothing
      result <- forceFlushTracerProvider tp Nothing
      result `shouldBe` FlushError

    -- Trace SDK §ForceFlush TracerProvider: timeout when exporter blocks
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#forceflushtracerprovider
    specify "forceFlush honors timeout with slow exporter" $ do
      blockVar <- newEmptyMVar
      let slowExporter =
            SpanExporter
              { spanExporterExport = \_ -> pure Success
              , spanExporterShutdown = pure ShutdownSuccess
              , spanExporterForceFlush = takeMVar blockVar >> pure FlushSuccess
              }
      slowProc <- simpleProcessor (SimpleProcessorConfig {spanExporter = slowExporter, simpleSpanExportTimeoutMicros = 30_000_000})
      tp <- createTracerProvider [slowProc] emptyTracerProviderOptions
      let t = makeTracer tp "slow-flush" tracerOptions
      s <- createSpan t Context.empty "slow" defaultSpanArguments
      endSpan s Nothing
      result <- forceFlushTracerProvider tp (Just 1000)
      putMVar blockVar ()
      result `shouldBe` FlushTimeout

    -- Trace SDK §Register Span Processors: invocation order
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#register-span-processor
    specify "multiple processors receive OnStart and OnEnd in registration order" $ do
      orderRef <- newIORef ([] :: [String])
      let mkProc label =
            SpanProcessor
              { spanProcessorOnStart = \_ _ ->
                  atomicModifyIORef' orderRef (\xs -> (xs ++ [label ++ "-start"], ()))
              , spanProcessorOnEnd = \_ ->
                  atomicModifyIORef' orderRef (\xs -> (xs ++ [label ++ "-end"], ()))
              , spanProcessorShutdown = pure ShutdownSuccess
              , spanProcessorForceFlush = pure FlushSuccess
              }
          p1 = mkProc "A"
          p2 = mkProc "B"
      tp <- createTracerProvider [p1, p2] emptyTracerProviderOptions
      let t = makeTracer tp "order-test" tracerOptions
      s <- createSpan t Context.empty "ordered" defaultSpanArguments
      endSpan s Nothing
      order <- readIORef orderRef
      order `shouldBe` ["A-start", "B-start", "A-end", "B-end"]

  describe "Parent-based sampling pipeline" $ do
    -- Trace SDK §Sampler / TraceFlags sampled: parent not sampled → child not recorded
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#sampler
    specify "non-sampled remote parent produces non-exported child" $ do
      exportedRef <- newIORef ([] :: [ImmutableSpan])
      let testExporter =
            SpanExporter
              { spanExporterExport = \batch -> do
                  let allSpans = concatMap V.toList (HM.elems batch)
                  atomicModifyIORef' exportedRef (\acc -> (acc ++ allSpans, ()))
                  pure Success
              , spanExporterShutdown = pure ShutdownSuccess
              , spanExporterForceFlush = pure FlushSuccess
              }
      processor <- simpleProcessor (SimpleProcessorConfig {spanExporter = testExporter, simpleSpanExportTimeoutMicros = 30_000_000})
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      let t = makeTracer tp "parent-based" tracerOptions
      tid <- newTraceId defaultIdGenerator
      sid <- newSpanId defaultIdGenerator
      let remoteSc =
            SpanContext
              { traceFlags = defaultTraceFlags
              , isRemote = True
              , traceId = tid
              , spanId = sid
              , traceState = TraceState.empty
              }
          parentCtx = Context.insertSpan (wrapSpanContext remoteSc) Context.empty
      child <- createSpan t parentCtx "child-of-unsampled" defaultSpanArguments
      endSpan child Nothing
      void $ forceFlushTracerProvider tp Nothing
      spans <- readIORef exportedRef
      length spans `shouldBe` 0
      recording <- isRecording child
      recording `shouldBe` False

  describe "Per-event and per-link attribute limits" $ do
    -- Trace SDK §Span limits: per-event attribute count
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#span-limits
    specify "eventAttributeCountLimit caps attributes on events" $ do
      let limits =
            defaultSpanLimits
              { eventAttributeCountLimit = Just 2
              }
          opts = emptyTracerProviderOptions {tracerProviderOptionsSpanLimits = limits}
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] opts
      let t = makeTracer tp "ev-attr-limit" tracerOptions
      s <- createSpan t Context.empty "many-event-attrs" defaultSpanArguments
      addEvent s $
        NewEvent
          { newEventName = "big-event"
          , newEventAttributes =
              HM.fromList
                [ ("a", toAttribute @Text "1")
                , ("b", toAttribute @Text "2")
                , ("c", toAttribute @Text "3")
                , ("d", toAttribute @Text "4")
                ]
          , newEventTimestamp = Nothing
          }
      im <- unsafeReadSpan s
      hm <- readIORef (spanHot im)
      let evs = appendOnlyBoundedCollectionValues (hotEvents hm)
      V.length evs `shouldBe` 1
      let ev = V.head evs
      getCount (eventAttributes ev) `shouldBe` 2

    -- Trace SDK §Span limits: per-link attribute count
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#span-limits
    specify "linkAttributeCountLimit caps attributes on links" $ do
      let limits =
            defaultSpanLimits
              { linkAttributeCountLimit = Just 1
              }
          opts = emptyTracerProviderOptions {tracerProviderOptionsSpanLimits = limits}
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] opts
      let t = makeTracer tp "link-attr-limit" tracerOptions
      tid <- newTraceId defaultIdGenerator
      sid <- newSpanId defaultIdGenerator
      let sc =
            SpanContext
              { traceFlags = defaultTraceFlags
              , isRemote = False
              , traceId = tid
              , spanId = sid
              , traceState = TraceState.empty
              }
          linkAttrs =
            HM.fromList
              [ ("x", toAttribute @Text "1")
              , ("y", toAttribute @Text "2")
              , ("z", toAttribute @Text "3")
              ]
      s <-
        createSpan t Context.empty "link-attrs" $
          defaultSpanArguments
            { links = [NewLink {linkContext = sc, linkAttributes = linkAttrs}]
            }
      im <- unsafeReadSpan s
      hm <- readIORef (spanHot im)
      let ls = appendOnlyBoundedCollectionValues (hotLinks hm)
      V.length ls `shouldBe` 1
      let lk = V.head ls
      getCount (frozenLinkAttributes lk) `shouldBe` 1

    -- Trace SDK §Span limits: attribute value length applies to event attributes
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#span-limits
    specify "spanAttributeValueLengthLimit truncates event attribute values" $ do
      let limits =
            defaultSpanLimits
              { spanAttributeValueLengthLimit = Just 5
              }
          opts = emptyTracerProviderOptions {tracerProviderOptionsSpanLimits = limits}
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] opts
      let t = makeTracer tp "ev-truncate" tracerOptions
      s <- createSpan t Context.empty "truncate-ev" defaultSpanArguments
      addEvent s $
        NewEvent
          { newEventName = "long-attrs"
          , newEventAttributes = HM.singleton "key" (toAttribute @Text "abcdefghij")
          , newEventTimestamp = Nothing
          }
      im <- unsafeReadSpan s
      hm <- readIORef (spanHot im)
      let evs = appendOnlyBoundedCollectionValues (hotEvents hm)
          ev = V.head evs
      lookupAttribute (eventAttributes ev) "key" `shouldBe` Just (toAttribute @Text "abcde")

  describe "Shutdown during active spans" $ do
    -- Implementation-specific: shutdown while spans still open (safety)
    specify "shutdown with in-flight span does not crash" $ asIO $ do
      (processor, _spansRef) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      let t = makeTracer tp "active-shutdown" tracerOptions
      s <- createSpan t Context.empty "in-flight" defaultSpanArguments
      _ <- shutdownTracerProvider tp Nothing
      endSpan s Nothing

    -- Implementation-specific: concurrent shutdown vs span creation
    specify "concurrent createSpan + shutdown does not crash" $ asIO $ do
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      let t = makeTracer tp "race-shutdown" tracerOptions
      gate <- newEmptyMVar
      a1 <- async $ do
        takeMVar gate
        mapConcurrently_
          ( \i -> do
              s <- createSpan t Context.empty ("r-" <> Text.pack (show (i :: Int))) defaultSpanArguments
              endSpan s Nothing
          )
          [1 .. 50]
      a2 <- async $ do
        takeMVar gate
        _ <- shutdownTracerProvider tp Nothing
        pure ()
      putMVar gate ()
      putMVar gate ()
      wait a1
      wait a2

  describe "detectSampler" $ do
    -- General SDK env: OTEL_TRACES_SAMPLER
    -- https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/
    let withSamplerEnv name mArg act = bracket
          ( do
              saved <- lookupEnv "OTEL_TRACES_SAMPLER"
              savedArg <- lookupEnv "OTEL_TRACES_SAMPLER_ARG"
              setEnv "OTEL_TRACES_SAMPLER" name
              maybe (unsetEnv "OTEL_TRACES_SAMPLER_ARG") (setEnv "OTEL_TRACES_SAMPLER_ARG") mArg
              pure (saved, savedArg)
          )
          ( \(saved, savedArg) -> do
              maybe (unsetEnv "OTEL_TRACES_SAMPLER") (setEnv "OTEL_TRACES_SAMPLER") saved
              maybe (unsetEnv "OTEL_TRACES_SAMPLER_ARG") (setEnv "OTEL_TRACES_SAMPLER_ARG") savedArg
          )
          (const act)

    specify "OTEL_TRACES_SAMPLER is case-insensitive (ALWAYS_OFF)" $
      withSamplerEnv "ALWAYS_OFF" Nothing $ do
        s <- detectSampler
        getDescription s `shouldBe` getDescription alwaysOff

    specify "OTEL_TRACES_SAMPLER is case-insensitive (Always_On)" $
      withSamplerEnv "Always_On" Nothing $ do
        s <- detectSampler
        getDescription s `shouldBe` "AlwaysOnSampler"

    specify "OTEL_TRACES_SAMPLER is case-insensitive (PARENTBASED_ALWAYS_OFF)" $
      withSamplerEnv "PARENTBASED_ALWAYS_OFF" Nothing $ do
        s <- detectSampler
        getDescription s `shouldBe` getDescription (parentBased (parentBasedOptions alwaysOff))

    specify "OTEL_TRACES_SAMPLER lowercase still works" $
      withSamplerEnv "always_off" Nothing $ do
        s <- detectSampler
        getDescription s `shouldBe` getDescription alwaysOff

  -- Trace SDK §Shutdown: processor must not accept spans after provider shutdown
  -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#shutdown
  specify "batch processor rejects spans after TracerProvider shutdown starts" $ do
    exportedRef <- newIORef ([] :: [ImmutableSpan])
    let testExporter =
          SpanExporter
            { spanExporterExport = \batch -> do
                let allSpans = concatMap V.toList (HM.elems batch)
                atomicModifyIORef' exportedRef (\acc -> (acc ++ allSpans, ()))
                pure Success
            , spanExporterShutdown = pure ShutdownSuccess
            , spanExporterForceFlush = pure FlushSuccess
            }
    batchProc <-
      batchProcessor
        (batchTimeoutConfig {scheduledDelayMillis = 60000})
        testExporter
    tp <- createTracerProvider [batchProc] emptyTracerProviderOptions
    let t = makeTracer tp "bsp-post-shutdown" tracerOptions
    _ <- shutdownTracerProvider tp Nothing
    s <- createSpan t Context.empty "after-bsp-shutdown" defaultSpanArguments
    endSpan s Nothing
    spans <- readIORef exportedRef
    length spans `shouldBe` 0

  describe "spanGetAttributes" $ do
    -- Implementation-specific: read current attributes from live Span
    specify "returns attributes from a recording span" $ asIO $ do
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      let t = makeTracer tp "attr-get" tracerOptions
      inSpan' t "get-attrs" defaultSpanArguments $ \s -> do
        addAttributes' s (attr "test.key" ("test-val" :: Text))
        attrs <- spanGetAttributes s
        lookupAttribute attrs "test.key" `shouldBe` Just (toAttribute ("test-val" :: Text))

    -- Trace API §Wrapping a SpanContext: no mutable attributes
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#wrapping-a-spancontext-into-a-span
    specify "returns empty for FrozenSpan" $ asIO $ do
      tid <- newTraceId defaultIdGenerator
      sid <- newSpanId defaultIdGenerator
      let sc =
            SpanContext
              { traceFlags = defaultTraceFlags
              , isRemote = True
              , traceState = TraceState.empty
              , spanId = sid
              , traceId = tid
              }
          s = wrapSpanContext sc
      attrs <- spanGetAttributes s
      getCount attrs `shouldBe` 0

  describe "spanIsRemote" $ do
    -- Trace API §SpanCreation: local parent → isRemote false
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#span-creation
    specify "returns False for locally created spans" $ asIO $ do
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      let t = makeTracer tp "remote-test" tracerOptions
      inSpan' t "local-span" defaultSpanArguments $ \s -> do
        remote <- spanIsRemote s
        remote `shouldBe` False

    -- Trace API §SpanContext isRemote on wrapped remote context
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#spancontext
    specify "returns True for FrozenSpan from remote context" $ asIO $ do
      tid <- newTraceId defaultIdGenerator
      sid <- newSpanId defaultIdGenerator
      let sc =
            SpanContext
              { traceFlags = defaultTraceFlags
              , isRemote = True
              , traceState = TraceState.empty
              , spanId = sid
              , traceId = tid
              }
          s = wrapSpanContext sc
      remote <- spanIsRemote s
      remote `shouldBe` True

    -- Trace API / SDK: isRemote for non-recording (dropped) span representation
    -- https://opentelemetry.io/docs/specs/otel/trace/sdk/#behavior-of-the-api-in-non-recording-spans
    specify "returns False for Dropped span" $ asIO $ do
      (processor, _) <- inMemoryListExporter
      let opts = emptyTracerProviderOptions
      tp <- createTracerProvider [processor] opts
      let t = makeTracer tp "dropped" tracerOptions
      s <- createSpan t Context.empty "droppable" defaultSpanArguments
      -- Dropped spans return False for isRemote
      droppedRemote <- spanIsRemote s
      droppedRemote `shouldBe` False

  describe "whenSpanIsRecording" $ do
    -- Implementation-specific: conditional work only on recording spans
    specify "executes action when span is recording" $ asIO $ do
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      let t = makeTracer tp "when-rec" tracerOptions
      ref <- newIORef False
      inSpan' t "recording" defaultSpanArguments $ \s -> do
        whenSpanIsRecording s (liftIO $ writeIORef ref True)
      readIORef ref `shouldReturn` True

    -- Implementation-specific: no-op helper for non-recording wrapped spans
    specify "skips action for FrozenSpan" $ asIO $ do
      tid <- newTraceId defaultIdGenerator
      sid <- newSpanId defaultIdGenerator
      let sc =
            SpanContext
              { traceFlags = defaultTraceFlags
              , isRemote = True
              , traceState = TraceState.empty
              , spanId = sid
              , traceId = tid
              }
          s = wrapSpanContext sc
      ref <- newIORef False
      whenSpanIsRecording s (liftIO $ writeIORef ref True)
      readIORef ref `shouldReturn` False

  describe "toImmutableSpan" $ do
    -- Implementation-specific: snapshot mutable span to immutable export shape
    specify "returns Right for a Span" $ asIO $ do
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      let t = makeTracer tp "imm" tracerOptions
      inSpan' t "to-imm" defaultSpanArguments $ \s -> do
        result <- toImmutableSpan s
        case result of
          Right _ -> pure ()
          Left _ -> expectationFailure "expected Right for live span"

    -- Implementation-specific: cannot snapshot a wrapped non-recording span as “live”
    specify "returns Left SpanFrozen for FrozenSpan" $ asIO $ do
      tid <- newTraceId defaultIdGenerator
      sid <- newSpanId defaultIdGenerator
      let sc =
            SpanContext
              { traceFlags = defaultTraceFlags
              , isRemote = True
              , traceState = TraceState.empty
              , spanId = sid
              , traceId = tid
              }
          s = wrapSpanContext sc
      result <- toImmutableSpan s
      case result of
        Left SpanFrozen -> pure ()
        _ -> expectationFailure "expected Left SpanFrozen"

  describe "traceFlagsFromWord8" $ do
    -- W3C Trace Context: trace-flags encoding (sampled bit)
    -- https://www.w3.org/TR/trace-context/#trace-flags
    specify "round-trips with traceFlagsValue" $ asIO $ do
      let flags = traceFlagsFromWord8 0x01
      traceFlagsValue flags `shouldBe` 0x01

    -- W3C Trace Context: sampled flag cleared
    -- https://www.w3.org/TR/trace-context/#sampled-flag
    specify "zero flags are not sampled" $ asIO $ do
      let flags = traceFlagsFromWord8 0x00
      isSampled flags `shouldBe` False

    -- W3C Trace Context: sampled flag set
    -- https://www.w3.org/TR/trace-context/#sampled-flag
    specify "flags with bit 0 set are sampled" $ asIO $ do
      let flags = traceFlagsFromWord8 0x01
      isSampled flags `shouldBe` True

  describe "getTracerProviderPropagators" $ do
    -- Trace SDK: propagators associated with TracerProvider
    -- https://opentelemetry.io/docs/specs/otel/context/api-propagators/
    specify "returns propagators from provider" $ asIO $ do
      let prop = Propagator {propagatorFields = ["test-prop"], extractor = \_ c -> pure c, injector = \_ p -> pure p}
          opts = emptyTracerProviderOptions {tracerProviderOptionsPropagators = prop}
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] opts
      let result = getTracerProviderPropagators tp
      propagatorFields result `shouldBe` ["test-prop"]

  describe "inSpan''" $ do
    -- Implementation-specific: inSpan variant returning a value
    specify "passes span arguments and returns result" $ asIO $ do
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      let t = makeTracer tp "inspanpp" tracerOptions
      result <- inSpan'' t "test-span" defaultSpanArguments $ \s -> do
        addAttributes' s (attr "x" (1 :: Int))
        pure (42 :: Int)
      result `shouldBe` 42

  describe "setGlobalErrorHandler" $ do
    -- Implementation-specific: SDK internal error logging hook
    specify "redirects SDK diagnostic output to custom handler" $ asIO $ do
      captured <- newIORef ([] :: [String])
      let handler msg = atomicModifyIORef' captured (\msgs -> (msg : msgs, ()))
      setGlobalErrorHandler handler
      otelLogWarning "test warning message"
      msgs <- readIORef captured
      length msgs `shouldSatisfy` (>= 1)
      case msgs of
        (m : _) -> m `shouldSatisfy` \x -> "test warning message" `isInfixOf` x
        [] -> expectationFailure "expected at least one captured message"

    -- Implementation-specific: retrieve global diagnostic handler
    specify "getGlobalErrorHandler retrieves the current handler" $ asIO $ do
      captured <- newIORef ([] :: [String])
      let handler msg = atomicModifyIORef' captured (\msgs -> (msg : msgs, ()))
      setGlobalErrorHandler handler
      retrieved <- getGlobalErrorHandler
      retrieved "direct call"
      msgs <- readIORef captured
      case msgs of
        (m : _) -> m `shouldBe` "direct call"
        [] -> expectationFailure "expected at least one captured message"
{- ORMOLU_ENABLE -}


f :: HasCallStack => Tracer -> IO Span
f tracer =
  createSpan tracer Context.empty "name" defaultSpanArguments


g :: HasCallStack => Tracer -> IO Span
-- block createSpan and callerAttributes from appearing in the call stack
g tracer = withFrozenCallStack $ createSpan tracer Context.empty "name" defaultSpanArguments


g2 :: HasCallStack => Tracer -> IO Span
g2 tracer = g tracer


-- Make a 3-deep call stack
g3 :: HasCallStack => Tracer -> IO Span
g3 tracer = g2 tracer


h :: HasCallStack => Tracer -> IO Span
h tracer =
  createSpan tracer Context.empty "name" (addAttributesToSpanArguments (HM.singleton (unkey SC.code_function) (toAttribute @Text "something")) defaultSpanArguments)


myInSpan :: HasCallStack => Tracer -> Text -> IO a -> IO (a, Span)
myInSpan tracer name act = inSpan' tracer name (addAttributesToSpanArguments callerAttributes defaultSpanArguments) $ \traceSpan -> do
  res <- act
  pure (res, traceSpan)


useSpanHelper :: HasCallStack => Tracer -> IO Span
useSpanHelper tracer = snd <$> myInSpan tracer "useSpanHelper" (pure ())


noopExporter :: String -> IO SpanExporter
noopExporter _tag =
  pure
    SpanExporter
      { spanExporterExport = \_ -> pure Success
      , spanExporterShutdown = pure ShutdownSuccess
      , spanExporterForceFlush = pure FlushSuccess
      }

#if !defined(mingw32_HOST_OS)
newMarkerFile :: IO FilePath
newMarkerFile = do
  let path = "/tmp/otel-sigterm-test-marker"
  writeFile path ""
  pure path
#endif
