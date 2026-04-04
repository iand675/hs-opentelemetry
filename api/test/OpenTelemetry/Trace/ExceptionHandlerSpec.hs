{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

module OpenTelemetry.Trace.ExceptionHandlerSpec where

import Control.Exception (ErrorCall (..), IOException, SomeException, toException)
import qualified Data.HashMap.Strict as H
import OpenTelemetry.Trace.Core (
  TracerOptions (..),
  TracerProviderOptions (..),
  createTracerProvider,
  emptyTracerProviderOptions,
  instrumentationLibrary,
  makeTracer,
  tracerOptions,
 )
import OpenTelemetry.Trace.ExceptionHandler
import System.Exit (ExitCode (..))
import Test.Hspec (Spec, describe, expectationFailure, it, shouldBe)


spec :: Spec
spec = describe "ExceptionHandler" $ do
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
    it "matches only when predicate holds" $ do
      let h = ignoreExceptionMatching @ExitCode (== ExitSuccess)
      fmap exceptionClassification (h (toException ExitSuccess)) `shouldBe` Just IgnoredException
      case h (toException (ExitFailure 1)) of
        Nothing -> pure ()
        Just _ -> expectationFailure "expected Nothing"

  describe "recordExceptionType" $ do
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
    it "dispatches on the lifted exception value" $ do
      let h =
            classifyException @ExitCode $ \e -> case e of
              ExitSuccess -> ExceptionResponse IgnoredException H.empty
              ExitFailure _ -> ExceptionResponse RecordedException H.empty
      fmap exceptionClassification (h (toException ExitSuccess)) `shouldBe` Just IgnoredException
      fmap exceptionClassification (h (toException (ExitFailure 1))) `shouldBe` Just RecordedException

  describe "exitSuccessHandler" $ do
    it "ignores ExitSuccess only" $ do
      fmap exceptionClassification (exitSuccessHandler (toException ExitSuccess))
        `shouldBe` Just IgnoredException
      case exitSuccessHandler (toException (ExitFailure 1)) of
        Nothing -> pure ()
        Just _ -> expectationFailure "expected Nothing"

  describe "defaultExceptionResponse" $ do
    it "is ErrorException with no extra attributes" $ do
      exceptionClassification defaultExceptionResponse `shouldBe` ErrorException
      exceptionAdditionalAttributes defaultExceptionResponse `shouldBe` H.empty

  describe "resolveException" $ do
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
