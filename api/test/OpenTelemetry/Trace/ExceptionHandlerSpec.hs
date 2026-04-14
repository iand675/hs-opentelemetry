{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

module OpenTelemetry.Trace.ExceptionHandlerSpec where

import Control.Exception (ErrorCall (..), Exception (..), IOException, SomeException, toException)
import qualified Data.HashMap.Strict as H
import Data.IORef (readIORef)
import Data.Text (Text)
import qualified Data.Text as T
import Data.Typeable (Typeable)
import qualified Data.Vector as V
import OpenTelemetry.Attributes (fromAttribute, lookupAttribute)
import OpenTelemetry.Context (empty)
import OpenTelemetry.Processor.Span (FlushResult (..), ShutdownResult (..), SpanProcessor (..))
import OpenTelemetry.Trace.Core (
  Event (..),
  ImmutableSpan (..),
  SpanHot (..),
  TracerOptions (..),
  TracerProviderOptions (..),
  createSpan,
  createTracerProvider,
  defaultSpanArguments,
  emptyTracerProviderOptions,
  instrumentationLibrary,
  makeTracer,
  recordException,
  tracerOptions,
  unsafeReadSpan,
 )
import OpenTelemetry.Trace.ExceptionHandler
import OpenTelemetry.Util (appendOnlyBoundedCollectionValues)
import System.Exit (ExitCode (..))
import Test.Hspec (Spec, describe, expectationFailure, it, shouldBe, shouldNotBe)


spec :: Spec
spec = describe "ExceptionHandler" $ do
  -- Implementation-specific: classify exceptions before Record Exception
  -- https://opentelemetry.io/docs/specs/otel/trace/api/#record-exception
  describe "ignoreExceptionType" $ do
    it "matches ExitSuccess as IgnoredException" $ do
      let r = ignoreExceptionType @ExitCode (toException ExitSuccess)
      fmap exceptionClassification r `shouldBe` Just IgnoredException
      fmap exceptionAdditionalAttributes r `shouldBe` Just H.empty

    it "matches ExitFailure as IgnoredException" $ do
      let r = ignoreExceptionType @ExitCode (toException (ExitFailure 1))
      fmap exceptionClassification r `shouldBe` Just IgnoredException

    it "does not match ErrorCall" $ do
      case ignoreExceptionType @ExitCode (toException (ErrorCall "boom")) of
        Nothing -> pure ()
        Just _ -> expectationFailure "expected Nothing"

  describe "ignoreExceptionMatching" $ do
    -- Implementation-specific: predicate-based exception filtering
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#record-exception
    it "matches only when predicate holds" $ do
      let h = ignoreExceptionMatching @ExitCode (== ExitSuccess)
      fmap exceptionClassification (h (toException ExitSuccess)) `shouldBe` Just IgnoredException
      case h (toException (ExitFailure 1)) of
        Nothing -> pure ()
        Just _ -> expectationFailure "expected Nothing"

  describe "recordExceptionType" $ do
    -- Implementation-specific: type-directed Record Exception classification
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#record-exception
    it "matches IOException as RecordedException" $ do
      let ioEx :: SomeException
          ioEx = toException (userError "io")
          r = recordExceptionType @IOException ioEx
      fmap exceptionClassification r `shouldBe` Just RecordedException

    it "does not match ErrorCall" $ do
      case recordExceptionType @IOException (toException (ErrorCall "e")) of
        Nothing -> pure ()
        Just _ -> expectationFailure "expected Nothing"

  describe "classifyException" $ do
    -- Implementation-specific: user-defined exception classification
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#record-exception
    it "dispatches on the lifted exception value" $ do
      let h =
            classifyException @ExitCode $ \e -> case e of
              ExitSuccess -> ExceptionResponse IgnoredException H.empty
              ExitFailure _ -> ExceptionResponse RecordedException H.empty
      fmap exceptionClassification (h (toException ExitSuccess)) `shouldBe` Just IgnoredException
      fmap exceptionClassification (h (toException (ExitFailure 1))) `shouldBe` Just RecordedException

  describe "exitSuccessHandler" $ do
    -- Implementation-specific: common Haskell process exit handling
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#record-exception
    it "ignores ExitSuccess only" $ do
      fmap exceptionClassification (exitSuccessHandler (toException ExitSuccess))
        `shouldBe` Just IgnoredException
      case exitSuccessHandler (toException (ExitFailure 1)) of
        Nothing -> pure ()
        Just _ -> expectationFailure "expected Nothing"

  describe "defaultExceptionResponse" $ do
    -- Implementation-specific: default when no handler matches
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#record-exception
    it "is ErrorException with no extra attributes" $ do
      exceptionClassification defaultExceptionResponse `shouldBe` ErrorException
      exceptionAdditionalAttributes defaultExceptionResponse `shouldBe` H.empty

  describe "resolveException" $ do
    -- Implementation-specific: tracer vs provider handler precedence
    -- https://opentelemetry.io/docs/specs/otel/trace/api/#record-exception
    it "uses tracer handlers before provider handlers" $ do
      let ioEx = toException (userError "probe") :: SomeException
      tp <-
        createTracerProvider [] $
          emptyTracerProviderOptions
            { tracerProviderOptionsExceptionHandlers = [ignoreExceptionType @IOException]
            }
      let tracer =
            makeTracer tp (instrumentationLibrary "test" "1") $
              tracerOptions {tracerExceptionHandlerOptions = [recordExceptionType @IOException]}
      exceptionClassification (resolveException tracer ioEx) `shouldBe` RecordedException

    it "falls through to provider when tracer handlers do not match" $ do
      let ioEx = toException (userError "probe") :: SomeException
      tp <-
        createTracerProvider [] $
          emptyTracerProviderOptions
            { tracerProviderOptionsExceptionHandlers = [ignoreExceptionType @IOException]
            }
      let tracer = makeTracer tp (instrumentationLibrary "test" "1") tracerOptions
      exceptionClassification (resolveException tracer ioEx) `shouldBe` IgnoredException

    it "uses default when no handler matches" $ do
      let ex = toException (ErrorCall "nope") :: SomeException
      tp <- createTracerProvider [] emptyTracerProviderOptions
      let tracer = makeTracer tp (instrumentationLibrary "test" "1") tracerOptions
      let got = resolveException tracer ex
      exceptionClassification got `shouldBe` exceptionClassification defaultExceptionResponse
      exceptionAdditionalAttributes got `shouldBe` exceptionAdditionalAttributes defaultExceptionResponse

  -- Trace API §Record Exception: record an exception on a span
  -- https://opentelemetry.io/docs/specs/otel/trace/api/#record-exception
  describe "recordException" $ do
    it "recordException uses displayException for exception.message" $ do
      -- OTel Semconv: exception.message SHOULD use displayException for human-readable output
      -- https://opentelemetry.io/docs/specs/semconv/exceptions/exceptions-spans/
      let ex = DisplayDiffersFromShow
      tp <- createTracerProvider [dummySpanProcessor] emptyTracerProviderOptions
      let tracer = makeTracer tp (instrumentationLibrary "test" "1") tracerOptions
      s <- createSpan tracer empty "span" defaultSpanArguments
      recordException s H.empty Nothing ex
      imm <- unsafeReadSpan s
      hot <- readIORef (spanHot imm)
      let evts = appendOnlyBoundedCollectionValues (hotEvents hot)
      V.length evts `shouldBe` 1
      let evt = V.head evts
      eventName evt `shouldBe` "exception"
      (lookupAttribute (eventAttributes evt) "exception.message" >>= fromAttribute @Text)
        `shouldBe` Just (T.pack (displayException ex))
      (lookupAttribute (eventAttributes evt) "exception.message" >>= fromAttribute @Text)
        `shouldNotBe` Just (T.pack (show ex))


data DisplayDiffersFromShow = DisplayDiffersFromShow
  deriving (Typeable)


instance Show DisplayDiffersFromShow where
  show _ = "ShowForm"


instance Exception DisplayDiffersFromShow where
  displayException _ = "DisplayForm"


dummySpanProcessor :: SpanProcessor
dummySpanProcessor =
  SpanProcessor
    { spanProcessorOnStart = \_ _ -> pure ()
    , spanProcessorOnEnd = \_ -> pure ()
    , spanProcessorShutdown = pure ShutdownSuccess
    , spanProcessorForceFlush = pure FlushSuccess
    }
