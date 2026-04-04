{-# LANGUAGE CPP #-}
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
import qualified Data.ByteString as BS
import Data.Foldable (traverse_)
import qualified Data.HashMap.Strict as HM
import Data.IORef
import Data.Int
import Data.List (nub)
import Data.Maybe (isJust)
import Data.Text (Text)
import qualified Data.Text as Text
import qualified Data.Vector as V
import GHC.Stack (withFrozenCallStack)
import OpenTelemetry.Attributes (AttributeLimits (..), Attributes, defaultAttributeLimits, getCount, lookupAttribute, toAttribute)
import OpenTelemetry.Common (timestampToOptional)
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Context.ThreadLocal (attachContext, getContext)
import OpenTelemetry.Exporter.InMemory.Span (inMemoryListExporter)
import OpenTelemetry.Exporter.LogRecord (LogRecordExporterArguments (..), mkLogRecordExporter)
import OpenTelemetry.Exporter.Span (ExportResult (..), SpanExporter (..))
import OpenTelemetry.Internal.AtomicCounter
import OpenTelemetry.Internal.Common.Types (FlushResult (..), ShutdownResult (..))
import OpenTelemetry.Internal.Logs.Types (LogRecordProcessor (..))
import OpenTelemetry.Processor.Batch.LogRecord (BatchLogRecordProcessorConfig (..), batchLogRecordProcessor, defaultBatchLogRecordProcessorConfig)
import OpenTelemetry.Processor.Batch.Span (BatchTimeoutConfig (..), batchProcessor, batchTimeoutConfig)
import OpenTelemetry.Processor.Simple.Span (SimpleProcessorConfig (..), simpleProcessor)
import OpenTelemetry.Processor.Span (SpanProcessor (..))
import OpenTelemetry.Propagator (Propagator (..), getGlobalTextMapPropagator, setGlobalTextMapPropagator)
import qualified OpenTelemetry.Registry as Registry
import OpenTelemetry.Resource
import OpenTelemetry.Trace
import OpenTelemetry.Trace.Core
import OpenTelemetry.Trace.Id
import OpenTelemetry.Trace.Id.Generator
import OpenTelemetry.Trace.Id.Generator.Default
import OpenTelemetry.Trace.Sampler (Sampler (..), SamplingResult (..), alwaysOff)
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


pattern HostName :: Text
pattern HostName = "host.name"


pattern TelemetrySdkLanguage :: Text
pattern TelemetrySdkLanguage = "telemetry.sdk.language"


pattern ExampleName :: Text
pattern ExampleName = "example.name"


pattern ExampleCount :: Text
pattern ExampleCount = "example.count"


spec :: Spec
spec = describe "Trace" $ do
  describe "TracerProvider" $ do
    specify "Create TracerProvider" $ do
      void (createTracerProvider [] (emptyTracerProviderOptions :: TracerProviderOptions) :: IO TracerProvider)
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
    specify "Shutdown" $ asIO $ do
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      shutdownTracerProvider tp
    specify "ForceFlush" $ asIO $ do
      exportedRef <- newIORef ([] :: [ImmutableSpan])
      let testExporter =
            SpanExporter
              { spanExporterExport = \batch -> do
                  let allSpans = concatMap V.toList (HM.elems batch)
                  atomicModifyIORef' exportedRef (\acc -> (acc ++ allSpans, ()))
                  pure Success
              , spanExporterShutdown = pure ()
              , spanExporterForceFlush = pure ()
              }
      processor <- simpleProcessor (SimpleProcessorConfig testExporter)
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      let t = makeTracer tp "ff-tp" tracerOptions
      s <- createSpan t Context.empty "ff-span" defaultSpanArguments
      endSpan s Nothing
      _ <- forceFlushTracerProvider tp Nothing
      spans <- readIORef exportedRef
      length spans `shouldBe` 1
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
        [ (HostName, toAttribute @Text "env_host_name")
        , (TelemetrySdkLanguage, toAttribute @Text "haskell")
        , (ExampleName, toAttribute @Text "env_example_name")
        , -- OTEL_RESOURCE_ATTRIBUTES uses Baggage format, where attribute values are always text
          (ExampleCount, toAttribute @Text "42")
        ]
      attrsFromUser <-
        getInitialResourceAttrs $
          mkResource
            [ HostName .= toAttribute @Text "user_host_name"
            , TelemetrySdkLanguage .= toAttribute @Text "GHC2021"
            , ExampleCount .= toAttribute @Int 11
            ]
      traverse_
        (attrsFromUser `shouldHaveAttrPair`)
        [ (HostName, toAttribute @Text "user_host_name")
        , (TelemetrySdkLanguage, toAttribute @Text "GHC2021")
        , -- No user override for "example.name", so the value from OTEL_RESOURCES_ATTRIBUTES shines through
          (ExampleName, toAttribute @Text "env_example_name")
        , (ExampleCount, toAttribute @Int 11)
        ]

  describe "Trace / Context interaction" $ do
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
    specify "Create a new span" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      void $ createSpan t Context.empty "create_root_span" defaultSpanArguments
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
    specify "Mark Span active" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "mark-active" defaultSpanArguments
      void $ attachContext (Context.insertSpan s mempty)
      ctxt <- getContext
      case Context.lookupSpan ctxt of
        Nothing -> expectationFailure "expected span after attachContext"
        Just active -> do
          sc <- getSpanContext s
          ac <- getSpanContext active
          sc `shouldBe` ac
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
    specify "Conforms to the W3C TraceContext spec" $ do
      t <- newTraceId defaultIdGenerator
      s <- newSpanId defaultIdGenerator
      BS.length (traceIdBytes t) `shouldBe` 16
      BS.length (spanIdBytes s) `shouldBe` 8
  describe "Span" $ do
    specify "Create root span" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      void $ createSpan t Context.empty "create_root_span" defaultSpanArguments
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
    specify "Processor.OnStart receives parent Context" $ asIO $ do
      onStartCtxtRef <- newIORef Nothing
      let processor =
            SpanProcessor
              { spanProcessorOnStart = \_ ctxt ->
                  writeIORef onStartCtxtRef (Just ctxt)
              , spanProcessorOnEnd = \_ -> pure ()
              , spanProcessorShutdown = async $ pure ShutdownSuccess
              , spanProcessorForceFlush = pure ()
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
    specify "UpdateName" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "create_root_span" defaultSpanArguments
      updateName s "renamed_span"
    specify "User-defined start timestamp" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      ts <- getTimestamp
      s <-
        createSpan t Context.empty "timed" $
          defaultSpanArguments {startTime = Just ts}
      im <- unsafeReadSpan s
      spanStart im `shouldBe` ts
    specify "End" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "create_root_span" defaultSpanArguments
      endSpan s Nothing
    specify "End with timestamp" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      ts <- getTimestamp
      s <- createSpan t Context.empty "create_root_span" defaultSpanArguments
      endSpan s (Just ts)
    specify "IsRecording" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "create_root_span" defaultSpanArguments
      recording <- isRecording s
      recording `shouldBe` True

    specify "IsRecording becomes false after End" $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "create_root_span" defaultSpanArguments
      endSpan s Nothing
      recording <- isRecording s
      recording `shouldBe` False

    specify "Set status with StatusCode (Unset, Ok, Error)" $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "create_root_span" defaultSpanArguments

      setStatus s $ Error "woo"
      do
        i <- unsafeReadSpan s
        h <- readIORef (spanHot i)
        hotStatus h `shouldBe` Error "woo"
      setStatus s $ Ok
      do
        i <- unsafeReadSpan s
        h <- readIORef (spanHot i)
        hotStatus h `shouldBe` Ok
      setStatus s $ Error "woo"
      do
        i <- unsafeReadSpan s
        h <- readIORef (spanHot i)
        hotStatus h `shouldBe` Ok

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

    specify "SetStatus: Error overwrites Error (last-writer-wins)" $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "status_error_over_error" defaultSpanArguments
      setStatus s (Error "first")
      setStatus s (Error "second")
      i <- unsafeReadSpan s
      h <- readIORef (spanHot i)
      hotStatus h `shouldBe` Error "second"

    specify "SetStatus: Ok is final, Error cannot override" $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "status_ok_final" defaultSpanArguments
      setStatus s Ok
      setStatus s (Error "should be ignored")
      i <- unsafeReadSpan s
      h <- readIORef (spanHot i)
      hotStatus h `shouldBe` Ok

    specify "SetStatus: Ok is final, Unset cannot override" $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "status_ok_final2" defaultSpanArguments
      setStatus s Ok
      setStatus s Unset
      i <- unsafeReadSpan s
      h <- readIORef (spanHot i)
      hotStatus h `shouldBe` Ok

    specify "SetStatus: setting Unset is always ignored" $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "status_unset_ignored" defaultSpanArguments
      setStatus s (Error "err")
      setStatus s Unset
      i <- unsafeReadSpan s
      h <- readIORef (spanHot i)
      hotStatus h `shouldBe` Error "err"

    specify "SetStatus: Ok overwrites Error" $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "status_ok_over_error" defaultSpanArguments
      setStatus s (Error "e")
      setStatus s Ok
      i <- unsafeReadSpan s
      h <- readIORef (spanHot i)
      hotStatus h `shouldBe` Ok

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

    specify "addAttribute is no-op after End" $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "attr_after_end" defaultSpanArguments
      endSpan s Nothing
      addAttribute s "should.not.exist" (42 :: Int64)
      i <- unsafeReadSpan s
      hi <- readIORef (spanHot i)
      lookupAttribute (hotAttributes hi) "should.not.exist" `shouldBe` Nothing

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

    specify "updateName is no-op after End" $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "original_name" defaultSpanArguments
      endSpan s Nothing
      updateName s "changed_name"
      i <- unsafeReadSpan s
      hi <- readIORef (spanHot i)
      hotName hi `shouldBe` "original_name"

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

    specify "endSpan calls processors exactly once" $ do
      callCount <- newAtomicCounter 0
      let countingProcessor =
            SpanProcessor
              { spanProcessorOnStart = \_ _ -> pure ()
              , spanProcessorOnEnd = \_ ->
                  void $ incrAtomicCounter callCount
              , spanProcessorShutdown = async $ pure ShutdownSuccess
              , spanProcessorForceFlush = pure ()
              }
      tp <- createTracerProvider [countingProcessor] emptyTracerProviderOptions
      let t = makeTracer tp "woo" tracerOptions
      s <- createSpan t Context.empty "proc_once" defaultSpanArguments
      endSpan s Nothing
      endSpan s Nothing
      endSpan s Nothing
      n <- readAtomicCounter callCount
      n `shouldBe` 1

    specify "Ord SpanStatus: Ok > Error > Unset" $ do
      compare Unset (Error "x") `shouldBe` LT
      compare Unset Ok `shouldBe` LT
      compare (Error "x") Unset `shouldBe` GT
      compare (Error "x") Ok `shouldBe` LT
      compare Ok Unset `shouldBe` GT
      compare Ok (Error "x") `shouldBe` GT

    specify "Ord SpanStatus: Error/Error is EQ (lawful)" $ do
      compare (Error "a") (Error "b") `shouldBe` EQ
      compare (Error "b") (Error "a") `shouldBe` EQ
      (Error "a" <= Error "b") `shouldBe` True
      (Error "b" <= Error "a") `shouldBe` True

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
    specify "SetAttribute" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "create_root_span" defaultSpanArguments
      addAttribute s "attr" (1.0 :: Double)

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
    specify "String type" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "create_root_span" defaultSpanArguments
      addAttribute s "string_type" ("" :: Text)

    specify "Boolean type" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "create_root_span" defaultSpanArguments
      addAttribute s "bool_type" True

    specify "Double floating-point type" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "create_root_span" defaultSpanArguments
      addAttribute s "attr" (1.0 :: Double)

    specify "Signed int64 type" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "create_root_span" defaultSpanArguments
      addAttribute s "attr" (1 :: Int64)

    specify "Array of primitives (homegeneous)" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "create_root_span" defaultSpanArguments
      addAttribute s "attr" [(1 :: Int64) .. 10]

    specify "Unicode support for keys and string values" $ asIO $ do
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      let t = makeTracer tp "unicode-test" tracerOptions
      s <- createSpan t Context.empty "unicode_span" defaultSpanArguments
      addAttribute s "🚀" ("🚀" :: Text)
      im <- unsafeReadSpan s
      hm <- readIORef (spanHot im)
      lookupAttribute (hotAttributes hm) "🚀" `shouldBe` Just (toAttribute ("🚀" :: Text))

    specify "Source code attributes are added correctly" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- unsafeReadSpan =<< f t
      h <- readIORef (spanHot s)
      hotAttributes h `shouldSatisfy` \attrs ->
        (lookupAttribute attrs "code.function") == Just (toAttribute @Text "f")
          && (lookupAttribute attrs "code.namespace") == Just (toAttribute @Text "OpenTelemetry.TraceSpec")
          && isJust (lookupAttribute attrs "code.lineno")

    specify "Source code attributes are not added in the presence of frozen call stacks" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- unsafeReadSpan =<< g3 t
      h <- readIORef (spanHot s)
      hotAttributes h `shouldSatisfy` \attrs ->
        (lookupAttribute attrs "code.function") == Nothing
          && (lookupAttribute attrs "code.namespace") == Nothing
          && (lookupAttribute attrs "code.lineno") == Nothing

    specify "Source code attributes are not added if source attributes are already present" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- unsafeReadSpan =<< h t
      h <- readIORef (spanHot s)
      hotAttributes h `shouldSatisfy` \attrs ->
        (lookupAttribute attrs "code.function") == Just (toAttribute @Text "something")
          && (lookupAttribute attrs "code.namespace") == Nothing
          && (lookupAttribute attrs "code.lineno") == Nothing

    specify "Source code attributes can be added for span creation wrappers" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- unsafeReadSpan =<< useSpanHelper t
      h <- readIORef (spanHot s)
      hotAttributes h `shouldSatisfy` \attrs ->
        (lookupAttribute attrs "code.function") == Just (toAttribute @Text "useSpanHelper")

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
      lookupAttribute (eventAttributes ev) "exception.type" `shouldSatisfy` isJust
      lookupAttribute (eventAttributes ev) "exception.message" `shouldSatisfy` isJust
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
      lookupAttribute (eventAttributes ev) "exception.type" `shouldSatisfy` isJust
      lookupAttribute (eventAttributes ev) "http.status_code" `shouldBe` Just (toAttribute @Int 404)

  describe "SimpleProcessor" $ do
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

    it "stops processing after shutdown" $ asIO $ do
      exportedRef <- newIORef ([] :: [ImmutableSpan])
      let testExporter =
            SpanExporter
              { spanExporterExport = \batch -> do
                  let allSpans = concatMap V.toList (HM.elems batch)
                  atomicModifyIORef' exportedRef (\acc -> (acc ++ allSpans, ()))
                  pure Success
              , spanExporterShutdown = pure ()
              , spanExporterForceFlush = pure ()
              }
      processor <- simpleProcessor (SimpleProcessorConfig testExporter)
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      let t = makeTracer tp "simple-test" tracerOptions
      shutdownTracerProvider tp
      s <- createSpan t Context.empty "after-shutdown" defaultSpanArguments
      endSpan s Nothing
      spans <- readIORef exportedRef
      length spans `shouldBe` 0

    it "createSpan returns non-recording span after shutdown" $ asIO $ do
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      let t = makeTracer tp "shutdown-test" tracerOptions
      shutdownTracerProvider tp
      s <- createSpan t Context.empty "after-shutdown-span" defaultSpanArguments
      recording <- isRecording s
      recording `shouldBe` False

    it "exporter returns Failure after shutdown" $ asIO $ do
      shutdownRef <- newIORef False
      let testExporter =
            SpanExporter
              { spanExporterExport = \_ -> do
                  isShutdown <- readIORef shutdownRef
                  if isShutdown
                    then pure $ Failure Nothing
                    else pure Success
              , spanExporterShutdown = atomicWriteIORef shutdownRef True
              , spanExporterForceFlush = pure ()
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
    it "exports spans after forceFlush" $ asIO $ do
      exportedRef <- newIORef ([] :: [ImmutableSpan])
      let testExporter =
            SpanExporter
              { spanExporterExport = \batch -> do
                  let allSpans = concatMap V.toList (HM.elems batch)
                  atomicModifyIORef' exportedRef (\acc -> (acc ++ allSpans, ()))
                  pure Success
              , spanExporterShutdown = pure ()
              , spanExporterForceFlush = pure ()
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
    it "batch span processor drops spans when queue is full" $ asIO $ do
      exportedRef <- newIORef ([] :: [ImmutableSpan])
      let testExporter =
            SpanExporter
              { spanExporterExport = \batch -> do
                  let allSpans = concatMap V.toList (HM.elems batch)
                  atomicModifyIORef' exportedRef (\acc -> (acc ++ allSpans, ()))
                  pure Success
              , spanExporterShutdown = pure ()
              , spanExporterForceFlush = pure ()
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
    specify "Allow samplers to modify tracestate" $ asIO $ do
      let ts' = TraceState.insert (Key "ot-hs") (Value "sampler-wrote-this") TraceState.empty
          customSampler =
            Sampler
              { getDescription = "tracestate-tweak"
              , shouldSample = \_ _ _ _ -> pure (RecordAndSample, mempty, ts')
              }
          opts = emptyTracerProviderOptions {tracerProviderOptionsSampler = customSampler}
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] opts
      let t = makeTracer tp "ts-sampler" tracerOptions
      s <- createSpan t Context.empty "ts-span" defaultSpanArguments
      sc <- getSpanContext s
      TraceState.lookup (Key "ot-hs") (traceState sc) `shouldBe` Just (Value "sampler-wrote-this")
    specify "ShouldSample gets full parent Context" $ asIO $ do
      ctxtRef <- newIORef Nothing
      let customSampler =
            Sampler
              { getDescription = "ctxt-capture"
              , shouldSample = \ctxt _ _ _ -> do
                  writeIORef ctxtRef (Just ctxt)
                  pure (RecordAndSample, mempty, TraceState.empty)
              }
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
    specify "ShouldSample gets InstrumentationLibrary" $ asIO $ do
      il <- pure $ instrumentationLibrary "il-sampler" "9.9.9"
      ilRef <- newIORef Nothing
      let customSampler =
            Sampler
              { getDescription = "il-check"
              , shouldSample = \_ _ _ _ -> do
                  writeIORef ilRef (Just il)
                  pure (RecordAndSample, mempty, TraceState.empty)
              }
          opts = emptyTracerProviderOptions {tracerProviderOptionsSampler = customSampler}
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] opts
      let t = makeTracer tp il tracerOptions
      void $ createSpan t Context.empty "il-span" defaultSpanArguments
      Just recorded <- readIORef ilRef
      recorded `shouldBe` il
      tracerName t `shouldBe` il

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

    specify "IsRecording is False" $ asIO $ do
      s <- mkDroppedSpan
      r <- isRecording s
      r `shouldBe` False

    specify "addAttribute is silently ignored" $ asIO $ do
      s <- mkDroppedSpan
      addAttribute s "key" (42 :: Int64)
      r <- isRecording s
      r `shouldBe` False

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

    specify "setStatus is silently ignored" $ asIO $ do
      s <- mkDroppedSpan
      setStatus s (Error "should not exist")
      r <- isRecording s
      r `shouldBe` False

    specify "updateName is silently ignored" $ asIO $ do
      s <- mkDroppedSpan
      updateName s "new-name"
      r <- isRecording s
      r `shouldBe` False

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

    specify "endSpan does not invoke processors" $ asIO $ do
      callCount <- newAtomicCounter 0
      let countingProcessor =
            SpanProcessor
              { spanProcessorOnStart = \_ _ -> pure ()
              , spanProcessorOnEnd = \_ ->
                  void $ incrAtomicCounter callCount
              , spanProcessorShutdown = async $ pure ShutdownSuccess
              , spanProcessorForceFlush = pure ()
              }
      tp <- createTracerProvider [countingProcessor] (emptyTracerProviderOptions {tracerProviderOptionsSampler = alwaysOff})
      let t = makeTracer tp "always-off" tracerOptions
      s <- createSpan t Context.empty "dropped-no-proc" defaultSpanArguments
      endSpan s Nothing
      n <- readAtomicCounter callCount
      n `shouldBe` 0

  describe "Sampler tracestate propagation" $ do
    specify "Sampler tracestate is set on created span" $ asIO $ do
      let ts' = TraceState.insert (Key "vendor") (Value "data") TraceState.empty
          tsSampler =
            Sampler
              { getDescription = "ts-writer"
              , shouldSample = \_ _ _ _ -> pure (RecordAndSample, mempty, ts')
              }
          opts = emptyTracerProviderOptions {tracerProviderOptionsSampler = tsSampler}
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] opts
      let t = makeTracer tp "ts-writer" tracerOptions
      s <- createSpan t Context.empty "with-ts" defaultSpanArguments
      sc <- getSpanContext s
      traceState sc `shouldBe` ts'

    specify "Child sampler sees parent tracestate via Context" $ asIO $ do
      let ts' = TraceState.insert (Key "vendor") (Value "data") TraceState.empty
          rootSampler =
            Sampler
              { getDescription = "ts-root"
              , shouldSample = \_ _ _ _ -> pure (RecordAndSample, mempty, ts')
              }
          childSampler =
            Sampler
              { getDescription = "ts-passthrough"
              , shouldSample = \ctx _ _ _ -> do
                  msp <- sequence (getSpanContext <$> Context.lookupSpan ctx)
                  let parentTs = maybe TraceState.empty traceState msp
                  pure (RecordAndSample, mempty, parentTs)
              }
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

  specify "IdGenerators" $ asIO $ do
    tids <- replicateM 20 (newTraceId defaultIdGenerator)
    sids <- replicateM 20 (newSpanId defaultIdGenerator)
    length (nub tids) `shouldBe` 20
    length (nub sids) `shouldBe` 20
    all (not . isEmptyTraceId) tids `shouldBe` True
    all (not . isEmptySpanId) sids `shouldBe` True
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
  specify "Built-in Processors implement ForceFlush spec" $ asIO $ do
    exportedRef <- newIORef ([] :: [ImmutableSpan])
    let testExporter =
          SpanExporter
            { spanExporterExport = \batch -> do
                let allSpans = concatMap V.toList (HM.elems batch)
                atomicModifyIORef' exportedRef (\acc -> (acc ++ allSpans, ()))
                pure Success
            , spanExporterShutdown = pure ()
            , spanExporterForceFlush = pure ()
            }
    simpleProc <- simpleProcessor (SimpleProcessorConfig testExporter)
    spanProcessorForceFlush simpleProc
    batchProc <-
      batchProcessor
        (batchTimeoutConfig {scheduledDelayMillis = 60000})
        testExporter
    spanProcessorForceFlush batchProc
  specify "Batch processor shutdown is idempotent (no deadlock)" $ asIO $ do
    let testExporter =
          SpanExporter
            { spanExporterExport = \_ -> pure Success
            , spanExporterShutdown = pure ()
            , spanExporterForceFlush = pure ()
            }
    proc <- batchProcessor batchTimeoutConfig testExporter
    r1 <- spanProcessorShutdown proc >>= wait
    r1 `shouldBe` ShutdownSuccess
    r2 <- spanProcessorShutdown proc >>= wait
    r2 `shouldBe` ShutdownSuccess

  specify "Batch processor OnEnd after shutdown does not export" $ asIO $ do
    exportedRef <- newIORef ([] :: [ImmutableSpan])
    let testExporter =
          SpanExporter
            { spanExporterExport = \batch -> do
                let allSpans = concatMap V.toList (HM.elems batch)
                atomicModifyIORef' exportedRef (\acc -> (acc ++ allSpans, ()))
                pure Success
            , spanExporterShutdown = pure ()
            , spanExporterForceFlush = pure ()
            }
    batchProc <-
      batchProcessor
        (batchTimeoutConfig {scheduledDelayMillis = 60000})
        testExporter
    tp <- createTracerProvider [batchProc] emptyTracerProviderOptions
    let t = makeTracer tp "batch-shutdown-onend" tracerOptions
    _ <- spanProcessorShutdown batchProc >>= wait
    s <- createSpan t Context.empty "after-batch-shutdown" defaultSpanArguments
    endSpan s Nothing
    -- Give the batch processor a chance to flush (it shouldn't, since it's shut down)
    _ <- forceFlushTracerProvider tp Nothing
    spans <- readIORef exportedRef
    length spans `shouldBe` 0

  specify "BSP default maxQueueSize is 2048" $ asIO $ do
    maxQueueSize batchTimeoutConfig `shouldBe` 2048

  specify "Batch log record processor shutdown is idempotent" $ asIO $ do
    testExporter <-
      mkLogRecordExporter
        LogRecordExporterArguments
          { logRecordExporterArgumentsExport = \_ -> pure Success
          , logRecordExporterArgumentsForceFlush = pure ()
          , logRecordExporterArgumentsShutdown = pure ()
          }
    proc <-
      batchLogRecordProcessor
        (defaultBatchLogRecordProcessorConfig testExporter)
          { batchLogScheduledDelayMillis = 60000
          }
    r1 <- logRecordProcessorShutdown proc >>= wait
    r1 `shouldBe` ShutdownSuccess
    r2 <- logRecordProcessorShutdown proc >>= wait
    r2 `shouldBe` ShutdownSuccess

  describe "service.name precedence" $ do
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
          lookupAttribute attrs "service.name" `shouldBe` Just (toAttribute @Text "from-service-name-env")

    specify "OTEL_SERVICE_NAME wins over user-supplied resource" $ do
      bracket
        ( do
            savedSvcName <- lookupEnv "OTEL_SERVICE_NAME"
            setEnv "OTEL_SERVICE_NAME" "env-wins"
            pure savedSvcName
        )
        (maybe (unsetEnv "OTEL_SERVICE_NAME") (setEnv "OTEL_SERVICE_NAME"))
        $ \_ -> do
          let userRs = mkResource ["service.name" .= toAttribute @Text "user-supplied"]
          (_procs, opts) <- getTracerProviderInitializationOptions' userRs
          let attrs = getMaterializedResourcesAttributes (tracerProviderOptionsResources opts)
          lookupAttribute attrs "service.name" `shouldBe` Just (toAttribute @Text "env-wins")

  describe "OTEL_SDK_DISABLED" $ do
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

  describe "Registry-based detection" $ do
    specify "detectExporters resolves a user-registered exporter factory" $ do
      exportCalledRef <- newIORef False
      let customFactory =
            pure
              SpanExporter
                { spanExporterExport = \_ -> writeIORef exportCalledRef True >> pure Success
                , spanExporterShutdown = pure ()
                , spanExporterForceFlush = pure ()
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

    specify "user-registered exporter takes precedence over builtin" $ do
      userCalledRef <- newIORef False
      let userOtlpFactory =
            pure
              SpanExporter
                { spanExporterExport = \_ -> writeIORef userCalledRef True >> pure Success
                , spanExporterShutdown = pure ()
                , spanExporterForceFlush = pure ()
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
    specify "double shutdown is safe and idempotent" $ do
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      shutdownTracerProvider tp
      shutdownTracerProvider tp
      let t = makeTracer tp "double-shutdown" tracerOptions
      s <- createSpan t Context.empty "after-double-shutdown" defaultSpanArguments
      recording <- isRecording s
      recording `shouldBe` False

    specify "forceFlush after shutdown completes without hanging" $ asIO $ do
      (processor, _) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      let t = makeTracer tp "flush-after-shutdown" tracerOptions
      s <- createSpan t Context.empty "s" defaultSpanArguments
      endSpan s Nothing
      shutdownTracerProvider tp
      void $ forceFlushTracerProvider tp Nothing

    specify "forceFlush honors timeout with slow exporter" $ do
      blockVar <- newEmptyMVar
      let slowExporter =
            SpanExporter
              { spanExporterExport = \_ -> pure Success
              , spanExporterShutdown = pure ()
              , spanExporterForceFlush = takeMVar blockVar
              }
      slowProc <- simpleProcessor (SimpleProcessorConfig slowExporter)
      tp <- createTracerProvider [slowProc] emptyTracerProviderOptions
      let t = makeTracer tp "slow-flush" tracerOptions
      s <- createSpan t Context.empty "slow" defaultSpanArguments
      endSpan s Nothing
      result <- forceFlushTracerProvider tp (Just 1000)
      putMVar blockVar ()
      result `shouldBe` FlushTimeout

    specify "multiple processors receive OnStart and OnEnd in registration order" $ do
      orderRef <- newIORef ([] :: [String])
      let mkProc label =
            SpanProcessor
              { spanProcessorOnStart = \_ _ ->
                  atomicModifyIORef' orderRef (\xs -> (xs ++ [label ++ "-start"], ()))
              , spanProcessorOnEnd = \_ ->
                  atomicModifyIORef' orderRef (\xs -> (xs ++ [label ++ "-end"], ()))
              , spanProcessorShutdown = async $ pure ShutdownSuccess
              , spanProcessorForceFlush = pure ()
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
    specify "non-sampled remote parent produces non-exported child" $ do
      exportedRef <- newIORef ([] :: [ImmutableSpan])
      let testExporter =
            SpanExporter
              { spanExporterExport = \batch -> do
                  let allSpans = concatMap V.toList (HM.elems batch)
                  atomicModifyIORef' exportedRef (\acc -> (acc ++ allSpans, ()))
                  pure Success
              , spanExporterShutdown = pure ()
              , spanExporterForceFlush = pure ()
              }
      processor <- simpleProcessor (SimpleProcessorConfig testExporter)
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
    specify "shutdown with in-flight span does not crash" $ asIO $ do
      (processor, _spansRef) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      let t = makeTracer tp "active-shutdown" tracerOptions
      s <- createSpan t Context.empty "in-flight" defaultSpanArguments
      shutdownTracerProvider tp
      endSpan s Nothing

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
        shutdownTracerProvider tp
      putMVar gate ()
      putMVar gate ()
      wait a1
      wait a2

  specify "batch processor rejects spans after TracerProvider shutdown starts" $ do
    exportedRef <- newIORef ([] :: [ImmutableSpan])
    let testExporter =
          SpanExporter
            { spanExporterExport = \batch -> do
                let allSpans = concatMap V.toList (HM.elems batch)
                atomicModifyIORef' exportedRef (\acc -> (acc ++ allSpans, ()))
                pure Success
            , spanExporterShutdown = pure ()
            , spanExporterForceFlush = pure ()
            }
    batchProc <-
      batchProcessor
        (batchTimeoutConfig {scheduledDelayMillis = 60000})
        testExporter
    tp <- createTracerProvider [batchProc] emptyTracerProviderOptions
    let t = makeTracer tp "bsp-post-shutdown" tracerOptions
    shutdownTracerProvider tp
    s <- createSpan t Context.empty "after-bsp-shutdown" defaultSpanArguments
    endSpan s Nothing
    spans <- readIORef exportedRef
    length spans `shouldBe` 0
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
  createSpan tracer Context.empty "name" (addAttributesToSpanArguments (HM.singleton "code.function" "something") defaultSpanArguments)


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
      , spanExporterShutdown = pure ()
      , spanExporterForceFlush = pure ()
      }

#if !defined(mingw32_HOST_OS)
newMarkerFile :: IO FilePath
newMarkerFile = do
  let path = "/tmp/otel-sigterm-test-marker"
  writeFile path ""
  pure path
#endif
