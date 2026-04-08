{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module OpenTelemetry.Trace.UtilsSpec where

import qualified Data.HashMap.Strict as H
import Data.IORef
import Data.Text (Text)
import qualified Data.Vector as V
import OpenTelemetry.Attributes (lookupAttribute)
import qualified OpenTelemetry.Attributes as A
import OpenTelemetry.Context (empty, insertSpan)
import OpenTelemetry.Context.ThreadLocal (attachContext)
import OpenTelemetry.Processor.Span (FlushResult (..), ShutdownResult (..), SpanProcessor (..))
import OpenTelemetry.Trace.Core
import OpenTelemetry.Util (appendOnlyBoundedCollectionValues)
import System.IO.Error (userError)
import Test.Hspec


dummyProcessor :: SpanProcessor
dummyProcessor =
  SpanProcessor
    { spanProcessorOnStart = \_ _ -> pure ()
    , spanProcessorOnEnd = \_ -> pure ()
    , spanProcessorShutdown = pure ShutdownSuccess
    , spanProcessorForceFlush = pure FlushSuccess
    }


withTracer :: (Tracer -> IO a) -> IO a
withTracer f = do
  tp <- createTracerProvider [dummyProcessor] emptyTracerProviderOptions
  let lib = InstrumentationLibrary "test" "1.0.0" "" A.emptyAttributes
      t = makeTracer tp lib tracerOptions
  f t


spec :: Spec
spec = describe "Trace utilities" $ do
  -- Trace API §Span Kind: SpanKind values
  -- https://opentelemetry.io/docs/specs/otel/trace/api/#spankind
  describe "SpanKind Eq" $ do
    it "compares equal SpanKinds" $ do
      Server `shouldBe` Server
      Client `shouldBe` Client
      Producer `shouldBe` Producer
      Consumer `shouldBe` Consumer
      Internal `shouldBe` Internal

    it "distinguishes different SpanKinds" $ do
      Client `shouldNotBe` Server
      Producer `shouldNotBe` Consumer
      Internal `shouldNotBe` Client

  -- Context API §Context interactions with OTel: active context (thread-local helper)
  -- https://opentelemetry.io/docs/specs/otel/context/
  describe "getActiveSpan" $ do
    it "returns Nothing when no span is active" $ do
      _ <- attachContext empty
      result <- getActiveSpan
      result `shouldSatisfy` \x -> case x of Nothing -> True; Just _ -> False

    it "returns the active span from thread-local context" $ withTracer $ \t -> do
      s <- createSpan t empty "test-span" defaultSpanArguments
      _ <- attachContext (insertSpan s empty)
      result <- getActiveSpan
      case result of
        Nothing -> expectationFailure "expected an active span"
        Just activeSpan -> do
          activeSc <- getSpanContext activeSpan
          expectedSc <- getSpanContext s
          spanId activeSc `shouldBe` spanId expectedSc

  describe "withActiveSpan" $ do
    it "does nothing when there is no active span" $ do
      _ <- attachContext empty
      ref <- newIORef False
      withActiveSpan $ \_ -> writeIORef ref True
      readIORef ref `shouldReturn` False

    it "runs the action with the active span" $ withTracer $ \t -> do
      s <- createSpan t empty "test-span" defaultSpanArguments
      _ <- attachContext (insertSpan s empty)
      ref <- newIORef False
      withActiveSpan $ \_ -> writeIORef ref True
      readIORef ref `shouldReturn` True

  describe "getActiveSpanContext" $ do
    it "returns Nothing when no span is active" $ do
      _ <- attachContext empty
      result <- getActiveSpanContext
      result `shouldSatisfy` \x -> case x of Nothing -> True; Just _ -> False

    it "returns the active SpanContext" $ withTracer $ \t -> do
      s <- createSpan t empty "test-span" defaultSpanArguments
      expectedSc <- getSpanContext s
      _ <- attachContext (insertSpan s empty)
      result <- getActiveSpanContext
      case result of
        Nothing -> expectationFailure "expected a SpanContext"
        Just sc -> do
          traceId sc `shouldBe` traceId expectedSc
          spanId sc `shouldBe` spanId expectedSc

  -- Trace API §Add Events: event name and attributes
  -- https://opentelemetry.io/docs/specs/otel/trace/api/#add-events
  describe "newEvent" $ do
    it "creates an event with just a name" $ do
      let e = newEvent "my-event"
      newEventName e `shouldBe` "my-event"
      newEventAttributes e `shouldBe` H.empty
      newEventTimestamp e `shouldBe` Nothing

  describe "newEventWith" $ do
    it "creates an event with name and attributes" $ do
      let attrs = H.fromList [("key" :: Text, A.toAttribute ("val" :: Text))]
          e = newEventWith "my-event" attrs
      newEventName e `shouldBe` "my-event"
      newEventAttributes e `shouldBe` attrs

  -- Trace API §Record exception: exception event and span status
  -- https://opentelemetry.io/docs/specs/otel/trace/api/#record-exception
  describe "recordError" $ do
    it "sets span status to Error and records exception event" $ withTracer $ \t -> do
      s <- createSpan t empty "test-span" defaultSpanArguments
      let err = userError "something broke"
      recordError s err
      endSpan s Nothing
      is <- unsafeReadSpan s
      hot <- readIORef (spanHot is)
      case hotStatus hot of
        Error _ -> pure ()
        other -> expectationFailure $ "expected Error status, got " <> show other
      let evts = appendOnlyBoundedCollectionValues (hotEvents hot)
      V.length evts `shouldBe` 1
      let evt = V.head evts
      eventName evt `shouldBe` "exception"
      lookupAttribute (eventAttributes evt) "exception.type" `shouldSatisfy` \x -> x /= Nothing
      lookupAttribute (eventAttributes evt) "exception.message" `shouldSatisfy` \x -> x /= Nothing
