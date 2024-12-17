{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

module OpenTelemetry.TraceSpec where

import Control.Monad
import Data.Foldable (traverse_)
import qualified Data.HashMap.Strict as HM
import Data.IORef
import Data.Int
import Data.Text (Text)
import qualified Data.Text as Text
import GHC.Stack (withFrozenCallStack)
import OpenTelemetry.Attributes (AttributeLimits (..), Attributes, defaultAttributeLimits, lookupAttribute)
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Resource
import OpenTelemetry.Trace
import OpenTelemetry.Trace.Core
import OpenTelemetry.Trace.Id
import OpenTelemetry.Trace.Id.Generator
import OpenTelemetry.Trace.Id.Generator.Default
import qualified OpenTelemetry.Trace.TraceState as TraceState
import System.Clock
import Test.Hspec


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
    -- TODO make these tests do something meaningful with makeTracer
    -- specify "Get a Tracer" $ asIO $ do
    --   p <- getGlobalTracerProvider
    --   void $ getTracer p "woo" tracerOptions
    -- specify "Get a Tracer with schema_url" $ asIO $ do
    --   p <- getGlobalTracerProvider
    --   void $ getTracer p "woo" (tracerOptions { tracerSchema = Just "https://woo.com" })
    specify "Safe for concurrent calls" pending
    specify "Shutdown" pending
    specify "ForceFlush" pending
    specify "Resource initialization prioritizes user override, then OTEL_RESOURCE_ATTRIBUTES env var" $ do
      let getInitialResourceAttrs :: Resource 'Nothing -> IO Attributes
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
          mkResource @'Nothing
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
    specify "Get active new span" pending
    specify "Mark Span active" pending
    specify "Safe for concurrent calls" pending
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
    specify "IsRemote" pending
    specify "Conforms to the W3C TraceContext spec" pending
  describe "Span" $ do
    specify "Create root span" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      void $ createSpan t Context.empty "create_root_span" defaultSpanArguments
    specify "Create with default parent (active span)" pending
    specify "Create with parent from Context" pending
    -- specify "No explict parent from Span/SpanContext allowed" pending
    specify "Processor.OnStart receives parent Context" pending
    specify "UpdateName" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "create_root_span" defaultSpanArguments
      updateName s "renamed_span"
    specify "User-defined start timestamp" pending
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
      ts <- getTime Realtime
      s <- createSpan t Context.empty "create_root_span" defaultSpanArguments
      recording <- isRecording s
      recording `shouldBe` True

    specify "IsRecording becomes false after End" $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      ts <- getTime Realtime
      s <- createSpan t Context.empty "create_root_span" defaultSpanArguments
      endSpan s Nothing
      recording <- isRecording s
      recording `shouldBe` False

    specify "Set status with StatusCode (Unset, Ok, Error)" $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      ts <- getTime Realtime
      s <- createSpan t Context.empty "create_root_span" defaultSpanArguments

      setStatus s $ Error "woo"
      do
        i <- unsafeReadSpan s
        spanStatus i `shouldBe` Error "woo"
      setStatus s $ Ok
      do
        i <- unsafeReadSpan s
        spanStatus i `shouldBe` Ok
      setStatus s $ Error "woo"
      do
        i <- unsafeReadSpan s
        spanStatus i `shouldBe` Ok

    specify "Safe for concurrent calls" pending
    specify "events collection size limit" pending
    specify "attribute collection size limit" pending
    specify "links collection size limit" pending

  describe "Span attributes" $ do
    specify "SetAttribute" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- createSpan t Context.empty "create_root_span" defaultSpanArguments
      addAttribute s "attr" (1.0 :: Double)

    specify "Set order preserved" pending
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
      s <- unsafeReadSpan =<< f t
      spanAttributes s `shouldSatisfy` \attrs ->
        (lookupAttribute attrs "code.function") == Just (toAttribute @Text "f")
          && (lookupAttribute attrs "code.namespace") == Just (toAttribute @Text "OpenTelemetry.TraceSpec")
          && (lookupAttribute attrs "code.lineno") == Just (toAttribute @Int 323)

    specify "Source code attributes are not added in the presence of frozen call stacks" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- unsafeReadSpan =<< g3 t
      spanAttributes s `shouldSatisfy` \attrs ->
        (lookupAttribute attrs "code.function") == Nothing
          && (lookupAttribute attrs "code.namespace") == Nothing
          && (lookupAttribute attrs "code.lineno") == Nothing

    specify "Source code attributes are not added if source attributes are already present" $ asIO $ do
      p <- getGlobalTracerProvider
      let t = makeTracer p "woo" tracerOptions
      s <- unsafeReadSpan =<< h t
      spanAttributes s `shouldSatisfy` \attrs ->
        (lookupAttribute attrs "code.function") == Just (toAttribute @Text "something")
          && (lookupAttribute attrs "code.namespace") == Nothing
          && (lookupAttribute attrs "code.lineno") == Nothing

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

      lookupAttribute (spanAttributes s) "attr1" `shouldBe` Just (toAttribute truncatedAttribute)
      lookupAttribute (spanAttributes s) "attr2" `shouldBe` Just (toAttribute truncatedAttribute)

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
    specify "Add order preserved" pending
    specify "Safe for concurrent calls" pending

  describe "Span exceptions" $ do
    specify "RecordException" pending
    specify "RecordException with extra parameters" pending

  describe "Sampling" $ do
    specify "Allow samplers to modify tracestate" pending
    specify "ShouldSample gets full parent Context" pending
    specify "ShouldSample gets InstrumentationLibrary" pending

  specify "New Span ID created also for non-recording spans" pending
  specify "IdGenerators" pending
  specify "SpanLimits" pending
  specify "Built-in Processors implement ForceFlush spec" pending
  specify "Attribute Limits" pending


f :: HasCallStack => Tracer -> IO Span
f tracer =
  createSpan tracer Context.empty "name" defaultSpanArguments


helper :: HasCallStack => Tracer -> IO Span
helper tracer =
  createSpan tracer Context.empty "name" defaultSpanArguments


g :: HasCallStack => Tracer -> IO Span
-- block createSpan and callerAttributes from appearing in the call stack
g tracer = withFrozenCallStack $ helper tracer


g2 :: HasCallStack => Tracer -> IO Span
g2 tracer = g tracer


-- Make a 3-deep call stack
g3 :: HasCallStack => Tracer -> IO Span
g3 tracer = g2 tracer


h :: HasCallStack => Tracer -> IO Span
h tracer =
  createSpan tracer Context.empty "name" (addAttributesToSpanArguments (HM.singleton "code.function" "something") defaultSpanArguments)
