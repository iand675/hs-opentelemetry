{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

module OpenTelemetry.LogSpec (spec) where

import Data.Foldable (traverse_)
import Data.Functor (void)
import Data.IORef
import Data.Text (Text)
import OpenTelemetry.Attributes (Attributes, lookupAttribute)
import qualified OpenTelemetry.Exporter.InMemory.LogRecord as LogExporter
import qualified OpenTelemetry.Exporter.InMemory.Span as SpanExporter
import OpenTelemetry.Internal.Logs.Core
import OpenTelemetry.Internal.Logs.Types
import OpenTelemetry.Log
import OpenTelemetry.Resource
import OpenTelemetry.Trace
import Test.Hspec


pattern HostName :: Text
pattern HostName = "host.name"


pattern TelemetrySdkLanguage :: Text
pattern TelemetrySdkLanguage = "telemetry.sdk.language"


pattern ExampleName :: Text
pattern ExampleName = "example.name"


pattern ExampleCount :: Text
pattern ExampleCount = "example.count"


spec :: Spec
spec = describe "Log" $ do
  describe "LoggerProvider" $ do
    specify "Resource initialization prioritizes user override, then OTEL_RESOURCE_ATTRIBUTES env var" $ do
      let getInitialResourceAttrs :: Resource 'Nothing -> IO Attributes
          getInitialResourceAttrs resource = do
            opts <- snd <$> getLoggerProviderInitializationOptions' resource
            pure . getMaterializedResourcesAttributes $ loggerProviderOptionsResources opts
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

  describe "Logger" $ do
    specify "Emit log record outside of a span" $ do
      (processor, logsRef) <- LogExporter.inMemoryListExporter
      setGlobalLoggerProvider $ createLoggerProvider [processor] emptyLoggerProviderOptions
      provider <- getGlobalLoggerProvider
      let logger = makeLogger provider "woo"
      readIORef logsRef `shouldReturn` []
      void $ emitLogRecord logger emptyLogRecordArguments
      emittedLogs <- readIORef logsRef
      emittedLogs `shouldNotBe` []
      length emittedLogs `shouldBe` 1
      let [emittedLog] = emittedLogs
      logRecordTracingDetails emittedLog `shouldBe` Nothing

    specify "Emit log record within a span" $ do
      (logProcessor, logsRef) <- LogExporter.inMemoryListExporter
      (spanProcessor, spansRef) <- SpanExporter.inMemoryListExporter
      setGlobalLoggerProvider $ createLoggerProvider [logProcessor] emptyLoggerProviderOptions
      setGlobalTracerProvider =<< createTracerProvider [spanProcessor] emptyTracerProviderOptions
      loggerProvider <- getGlobalLoggerProvider
      tracerProvider <- getGlobalTracerProvider
      let tracer = makeTracer tracerProvider "woo" tracerOptions
          logger = makeLogger loggerProvider "woo"
      readIORef logsRef `shouldReturn` []
      void . inSpan tracer "mySpan" defaultSpanArguments $
        emitLogRecord logger emptyLogRecordArguments
      emittedLogs <- readIORef logsRef
      emittedLogs `shouldNotBe` []
      length emittedLogs `shouldBe` 1
      let [emittedLog] = emittedLogs
      emittedSpans <- readIORef spansRef
      length emittedSpans `shouldBe` 1
      let [emittedSpan] = emittedSpans
          SpanContext {..} = spanContext emittedSpan
      logRecordTracingDetails emittedLog `shouldBe` Just (traceId, spanId, traceFlags)
