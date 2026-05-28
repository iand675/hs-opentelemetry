{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

module OpenTelemetry.TraceSpec where

import Control.Exception (IOException)
import Control.Monad
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
import OpenTelemetry.Attributes (AttributeLimits (..), Attributes, defaultAttributeLimits, getCount, lookupAttribute)
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Exporter.InMemory.Span (inMemoryListExporter)
import OpenTelemetry.Processor.Span (SpanProcessor (..))
import OpenTelemetry.Resource
import OpenTelemetry.Trace
import OpenTelemetry.Trace.Core
import OpenTelemetry.Trace.Id
import OpenTelemetry.Trace.Id.Generator.Default
import OpenTelemetry.Trace.Sampler
import qualified OpenTelemetry.Trace.TraceState as TraceState
import OpenTelemetry.Util (appendOnlyBoundedCollectionValues)
import Test.Hspec


asIO :: IO a -> IO a
asIO = id


immutableSpanStatus :: ImmutableSpan -> IO SpanStatus
immutableSpanStatus imm = hotStatus <$> readIORef (spanHot imm)


immutableSpanAttributes :: ImmutableSpan -> IO Attributes
immutableSpanAttributes imm = hotAttributes <$> readIORef (spanHot imm)


immutableSpanEvents :: ImmutableSpan -> IO (V.Vector Event)
immutableSpanEvents imm = do
  hot <- readIORef (spanHot imm)
  pure $ appendOnlyBoundedCollectionValues (hotEvents hot)


immutableSpanLinks :: ImmutableSpan -> IO (V.Vector Link)
immutableSpanLinks imm = do
  hot <- readIORef (spanHot imm)
  pure $ appendOnlyBoundedCollectionValues (hotLinks hot)


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

    specify "Shutdown" $ do
      (processor, ref) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions {tracerProviderOptionsIdGenerator = defaultIdGenerator}
      let tracer = makeTracer tp "test" tracerOptions
      s <- createSpan tracer Context.empty "shutdown_test" defaultSpanArguments
      endSpan s Nothing
      result <- shutdownTracerProvider tp Nothing
      result `shouldBe` ShutdownSuccess
      spans <- readIORef ref
      length spans `shouldBe` 1
      -- After shutdown, createSpan should return a Dropped span
      s2 <- createSpan tracer Context.empty "after_shutdown" defaultSpanArguments
      recording <- isRecording s2
      recording `shouldBe` False

    specify "ForceFlush" $ do
      (processor, ref) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions {tracerProviderOptionsIdGenerator = defaultIdGenerator}
      let tracer = makeTracer tp "test" tracerOptions
      s <- createSpan tracer Context.empty "flush_test" defaultSpanArguments
      endSpan s Nothing
      result <- forceFlushTracerProvider tp Nothing
      result `shouldBe` FlushSuccess
      spans <- readIORef ref
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
      let (Right sid) = bytesToSpanId "\1\0\0\0\0\0\0\1"
          (Right tid) = bytesToTraceId "\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1"
          sc =
            SpanContext
              { traceFlags = defaultTraceFlags
              , isRemote = True
              , traceState = TraceState.empty
              , spanId = sid
              , traceId = tid
              }
      OpenTelemetry.Trace.Core.isRemote sc `shouldBe` True
      OpenTelemetry.Trace.Core.isRemote (sc {isRemote = False}) `shouldBe` False

  describe "Span" $ do
    specify "Create root span" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      void $ createSpan t Context.empty "create_root_span" defaultSpanArguments

    specify "Create with default parent (active span)" $ do
      (processor, _ref) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions {tracerProviderOptionsIdGenerator = defaultIdGenerator}
      let tracer = makeTracer tp "test" tracerOptions
      parentSpan <- createSpan tracer Context.empty "parent" defaultSpanArguments
      let ctxt = Context.insertSpan parentSpan Context.empty
      childSpan <- createSpan tracer ctxt "child" defaultSpanArguments
      parentImm <- unsafeReadSpan parentSpan
      childImm <- unsafeReadSpan childSpan
      -- Child's parent should be present and match the parent span's context
      case spanParent childImm of
        Nothing -> expectationFailure "Child span should have a parent"
        Just p -> do
          parentSc <- getSpanContext p
          parentSc `shouldBe` spanContext parentImm

    specify "Create with parent from Context" $ do
      (processor, _ref) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions {tracerProviderOptionsIdGenerator = defaultIdGenerator}
      let tracer = makeTracer tp "test" tracerOptions
      parentSpan <- createSpan tracer Context.empty "parent" defaultSpanArguments
      let ctxtWithParent = Context.insertSpan parentSpan Context.empty
      childSpan <- createSpan tracer ctxtWithParent "child" defaultSpanArguments
      parentImm <- unsafeReadSpan parentSpan
      childImm <- unsafeReadSpan childSpan
      -- The child should share the parent's trace ID
      traceId (spanContext childImm) `shouldBe` traceId (spanContext parentImm)
      -- The child's parent span ID should be the parent's span ID
      case spanParent childImm of
        Nothing -> expectationFailure "Child span should have a parent"
        Just p -> do
          pSc <- getSpanContext p
          spanId pSc `shouldBe` spanId (spanContext parentImm)

    specify "Processor.OnStart receives parent Context" $ do
      ctxRef <- newIORef (Nothing :: Maybe Context.Context)
      let testProcessor =
            SpanProcessor
              { spanProcessorOnStart = \_imm ctx -> writeIORef ctxRef (Just ctx)
              , spanProcessorOnEnd = \_ -> pure ()
              , spanProcessorShutdown = pure ShutdownSuccess
              , spanProcessorForceFlush = pure FlushSuccess
              }
      tp <- createTracerProvider [testProcessor] emptyTracerProviderOptions {tracerProviderOptionsIdGenerator = defaultIdGenerator}
      let tracer = makeTracer tp "test" tracerOptions
      parentSpan <- createSpan tracer Context.empty "parent" defaultSpanArguments
      let ctxt = Context.insertSpan parentSpan Context.empty
      -- Reset the ref so we only see what the child's OnStart gets
      writeIORef ctxRef Nothing
      _childSpan <- createSpan tracer ctxt "child" defaultSpanArguments
      receivedCtx <- readIORef ctxRef
      case receivedCtx of
        Nothing -> expectationFailure "OnStart should receive context"
        Just ctx -> do
          let parentInCtx = Context.lookupSpan ctx
          case parentInCtx of
            Nothing -> expectationFailure "Context passed to OnStart should contain parent span"
            Just p -> do
              pSc <- getSpanContext p
              parentSc <- getSpanContext parentSpan
              pSc `shouldBe` parentSc

    specify "UpdateName" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "create_root_span" defaultSpanArguments
      updateName s "renamed_span"

    specify "User-defined start timestamp" $ do
      (processor, _ref) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions {tracerProviderOptionsIdGenerator = defaultIdGenerator}
      let tracer = makeTracer tp "test" tracerOptions
      userTs <- getTimestamp
      s <- createSpan tracer Context.empty "ts_test" defaultSpanArguments {startTime = Just userTs}
      imm <- unsafeReadSpan s
      spanStart imm `shouldBe` userTs

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
        immutableSpanStatus i `shouldReturn` Error "woo"
      setStatus s $ Ok
      do
        i <- unsafeReadSpan s
        immutableSpanStatus i `shouldReturn` Ok
      setStatus s $ Error "woo"
      do
        i <- unsafeReadSpan s
        immutableSpanStatus i `shouldReturn` Ok

    specify "events collection size limit" $ do
      (processor, _ref) <- inMemoryListExporter
      let limits = defaultSpanLimits {eventCountLimit = Just 3}
      tp <-
        createTracerProvider
          [processor]
          emptyTracerProviderOptions
            { tracerProviderOptionsIdGenerator = defaultIdGenerator
            , tracerProviderOptionsSpanLimits = limits
            }
      let tracer = makeTracer tp "test" tracerOptions
      s <- createSpan tracer Context.empty "limit_test" defaultSpanArguments
      -- Add 5 events but limit is 3
      forM_ [1 .. 5 :: Int] $ \i ->
        addEvent s $
          NewEvent
            { newEventName = Text.pack ("event_" <> show i)
            , newEventAttributes = HM.empty
            , newEventTimestamp = Nothing
            }
      imm <- unsafeReadSpan s
      evts <- immutableSpanEvents imm
      V.length evts `shouldBe` 3

    specify "attribute collection size limit" $ do
      (processor, _ref) <- inMemoryListExporter
      let limits = defaultSpanLimits {spanAttributeCountLimit = Just 5}
      tp <-
        createTracerProvider
          [processor]
          emptyTracerProviderOptions
            { tracerProviderOptionsIdGenerator = defaultIdGenerator
            , tracerProviderOptionsSpanLimits = limits
            , tracerProviderOptionsAttributeLimits = defaultAttributeLimits {attributeCountLimit = Just 5}
            }
      let tracer = makeTracer tp "test" tracerOptions
      s <- createSpan tracer Context.empty "limit_test" defaultSpanArguments
      -- Add many more attributes than the limit allows
      forM_ [1 .. 20 :: Int] $ \i ->
        addAttribute s (Text.pack ("attr_" <> show i)) (toAttribute i)
      imm <- unsafeReadSpan s
      attrs <- immutableSpanAttributes imm
      -- Total attribute count (including thread.id and any auto-added attrs)
      -- should not exceed the configured limit of 5
      getCount attrs `shouldSatisfy` (<= 5)

    specify "links collection size limit" $ do
      (processor, _ref) <- inMemoryListExporter
      let limits = defaultSpanLimits {linkCountLimit = Just 2}
      tp <-
        createTracerProvider
          [processor]
          emptyTracerProviderOptions
            { tracerProviderOptionsIdGenerator = defaultIdGenerator
            , tracerProviderOptionsSpanLimits = limits
            }
      let tracer = makeTracer tp "test" tracerOptions
      s <- createSpan tracer Context.empty "limit_test" defaultSpanArguments
      let (Right sid) = bytesToSpanId "\1\2\3\4\5\6\7\8"
          (Right tid) = bytesToTraceId "\1\2\3\4\5\6\7\8\9\10\11\12\13\14\15\16"
          linkSc =
            SpanContext
              { traceFlags = defaultTraceFlags
              , isRemote = False
              , traceState = TraceState.empty
              , spanId = sid
              , traceId = tid
              }
      -- Add 5 links but limit is 2
      forM_ [1 .. 5 :: Int] $ \_ ->
        addLink s $ NewLink {linkContext = linkSc, linkAttributes = HM.empty}
      imm <- unsafeReadSpan s
      lnks <- immutableSpanLinks imm
      V.length lnks `shouldBe` 2

  describe "Span attributes" $ do
    specify "SetAttribute" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "create_root_span" defaultSpanArguments
      addAttribute s "attr" (1.0 :: Double)

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
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "create_root_span" defaultSpanArguments
      addAttribute s "🚀" ("🚀" :: Text)
    -- TODO actually get attributes out

    specify "Source code attributes are added correctly" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      attrs <- immutableSpanAttributes =<< unsafeReadSpan =<< f t
      attrs `shouldSatisfy` \a ->
        (lookupAttribute a "code.function") == Just (toAttribute @Text "f")
          && (lookupAttribute a "code.namespace") == Just (toAttribute @Text "OpenTelemetry.TraceSpec")
          && isJust (lookupAttribute a "code.lineno")

    specify "Source code attributes are not added in the presence of frozen call stacks" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      attrs <- immutableSpanAttributes =<< unsafeReadSpan =<< g3 t
      attrs `shouldSatisfy` \a ->
        (lookupAttribute a "code.function") == Nothing
          && (lookupAttribute a "code.namespace") == Nothing
          && (lookupAttribute a "code.lineno") == Nothing

    specify "Source code attributes are not added if source attributes are already present" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      attrs <- immutableSpanAttributes =<< unsafeReadSpan =<< h t
      attrs `shouldSatisfy` \a ->
        (lookupAttribute a "code.function") == Just (toAttribute @Text "something")
          && (lookupAttribute a "code.namespace") == Nothing
          && (lookupAttribute a "code.lineno") == Nothing

    specify "Source code attributes can be added for span creation wrappers" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      attrs <- immutableSpanAttributes =<< unsafeReadSpan =<< useSpanHelper t
      attrs `shouldSatisfy` \a ->
        (lookupAttribute a "code.function") == Just (toAttribute @Text "useSpanHelper")

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
      s <- unsafeReadSpan s

      attrs <- immutableSpanAttributes s
      lookupAttribute attrs "attr1" `shouldBe` Just (toAttribute truncatedAttribute)
      lookupAttribute attrs "attr2" `shouldBe` Just (toAttribute truncatedAttribute)

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

  describe "Span exceptions" $ do
    specify "RecordException" $ do
      (processor, _ref) <- inMemoryListExporter
      tp <- createTracerProvider [processor] emptyTracerProviderOptions {tracerProviderOptionsIdGenerator = defaultIdGenerator}
      let tracer = makeTracer tp "test" tracerOptions
      s <- createSpan tracer Context.empty "exception_test" defaultSpanArguments
      let ex = userError "test error" :: IOException
      recordException s HM.empty Nothing ex
      imm <- unsafeReadSpan s
      evts <- immutableSpanEvents imm
      V.length evts `shouldSatisfy` (>= 1)
      let evt = V.head evts
      eventName evt `shouldBe` "exception"
      let evtAttrs = eventAttributes evt
      lookupAttribute evtAttrs "exception.message" `shouldSatisfy` isJust
      lookupAttribute evtAttrs "exception.type" `shouldSatisfy` isJust

  describe "Sampling" $ do
    specify "Allow samplers to modify tracestate" $ do
      (processor, _ref) <- inMemoryListExporter
      let customTs = TraceState.insert (TraceState.Key "custom_key") (TraceState.Value "custom_value") TraceState.empty
          sampler =
            CustomSampler "tracestate-modifier" $ \_ctx _tid _name _args _scope ->
              pure $ SamplingDecision RecordAndSample HM.empty customTs
      tp <-
        createTracerProvider
          [processor]
          emptyTracerProviderOptions
            { tracerProviderOptionsIdGenerator = defaultIdGenerator
            , tracerProviderOptionsSampler = sampler
            }
      let tracer = makeTracer tp "test" tracerOptions
      s <- createSpan tracer Context.empty "sampler_test" defaultSpanArguments
      sc <- getSpanContext s
      traceState sc `shouldBe` customTs

    specify "ShouldSample gets full parent Context" $ do
      receivedCtxRef <- newIORef (Nothing :: Maybe Context.Context)
      let sampler =
            CustomSampler "context-recorder" $ \ctx _tid _name _args _scope -> do
              writeIORef receivedCtxRef (Just ctx)
              pure $ SamplingDecision RecordAndSample HM.empty TraceState.empty
      (processor, _ref) <- inMemoryListExporter
      tp <-
        createTracerProvider
          [processor]
          emptyTracerProviderOptions
            { tracerProviderOptionsIdGenerator = defaultIdGenerator
            , tracerProviderOptionsSampler = sampler
            }
      let tracer = makeTracer tp "test" tracerOptions
      parentSpan <- createSpan tracer Context.empty "parent" defaultSpanArguments
      -- Reset the ref after the parent creation
      writeIORef receivedCtxRef Nothing
      let ctxt = Context.insertSpan parentSpan Context.empty
      _childSpan <- createSpan tracer ctxt "child" defaultSpanArguments
      receivedCtx <- readIORef receivedCtxRef
      case receivedCtx of
        Nothing -> expectationFailure "Sampler should have received a context"
        Just ctx -> do
          let spanInCtx = Context.lookupSpan ctx
          case spanInCtx of
            Nothing -> expectationFailure "Context passed to sampler should contain parent span"
            Just p -> do
              pSc <- getSpanContext p
              parentSc <- getSpanContext parentSpan
              pSc `shouldBe` parentSc

    specify "ShouldSample gets InstrumentationLibrary" $ do
      (processor, _ref) <- inMemoryListExporter
      receivedScopeRef <- newIORef (Nothing :: Maybe InstrumentationLibrary)
      let sampler =
            CustomSampler "scope-recorder" $ \_ctx _tid _name _args scope -> do
              writeIORef receivedScopeRef (Just scope)
              pure $ SamplingDecision RecordAndSample HM.empty TraceState.empty
      tp <-
        createTracerProvider
          [processor]
          emptyTracerProviderOptions
            { tracerProviderOptionsIdGenerator = defaultIdGenerator
            , tracerProviderOptionsSampler = sampler
            }
      let tracer = makeTracer tp "my-library" tracerOptions
      _s <- createSpan tracer Context.empty "scope_test" defaultSpanArguments
      receivedScope <- readIORef receivedScopeRef
      case receivedScope of
        Nothing -> expectationFailure "Sampler should have received InstrumentationLibrary"
        Just scope -> libraryName scope `shouldBe` "my-library"

  specify "New Span ID created also for non-recording spans" $ do
    (processor, _ref) <- inMemoryListExporter
    tp <-
      createTracerProvider
        [processor]
        emptyTracerProviderOptions
          { tracerProviderOptionsIdGenerator = defaultIdGenerator
          , tracerProviderOptionsSampler = alwaysOff
          }
    let tracer = makeTracer tp "test" tracerOptions
    spanIds <- forM [1 .. 5 :: Int] $ \_ -> do
      s <- createSpan tracer Context.empty "dropped" defaultSpanArguments
      sc <- getSpanContext s
      pure (spanId sc)
    -- All span IDs should be distinct even for non-recording (dropped) spans
    nub spanIds `shouldBe` spanIds


f :: (HasCallStack) => Tracer -> IO Span
f tracer =
  createSpan tracer Context.empty "name" defaultSpanArguments


g :: (HasCallStack) => Tracer -> IO Span
-- block createSpan and callerAttributes from appearing in the call stack
g tracer = withFrozenCallStack $ createSpan tracer Context.empty "name" defaultSpanArguments


g2 :: (HasCallStack) => Tracer -> IO Span
g2 tracer = g tracer


-- Make a 3-deep call stack
g3 :: (HasCallStack) => Tracer -> IO Span
g3 tracer = g2 tracer


h :: (HasCallStack) => Tracer -> IO Span
h tracer =
  createSpan tracer Context.empty "name" (addAttributesToSpanArguments (HM.singleton "code.function" "something") defaultSpanArguments)


myInSpan :: (HasCallStack) => Tracer -> Text -> IO a -> IO (a, Span)
myInSpan tracer name act = inSpan' tracer name (addAttributesToSpanArguments callerAttributes defaultSpanArguments) $ \traceSpan -> do
  res <- act
  pure (res, traceSpan)


useSpanHelper :: (HasCallStack) => Tracer -> IO Span
useSpanHelper tracer = snd <$> myInSpan tracer "useSpanHelper" (pure ())
