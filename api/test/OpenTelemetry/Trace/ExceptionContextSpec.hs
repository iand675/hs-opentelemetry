{-# LANGUAGE CPP #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

module OpenTelemetry.Trace.ExceptionContextSpec (spec) where

import Test.Hspec (Spec)


#if MIN_VERSION_base(4,20,0)
import qualified Control.Exception
import Control.Exception (ErrorCall (..), ExceptionWithContext (..), SomeException, toException)
import Control.Exception.Backtrace (collectBacktraces)
import Control.Exception.Context (addExceptionAnnotation, emptyExceptionContext)
import qualified Data.HashMap.Strict as H
import Data.Text (Text)
import qualified Data.Text as T
import GHC.Stack (HasCallStack)
import OpenTelemetry.Attributes (fromAttribute, lookupAttribute)
import OpenTelemetry.Context (empty)
import OpenTelemetry.Processor.Span (FlushResult (..), ShutdownResult (..), SpanProcessor (..))
import Data.IORef (readIORef)
import OpenTelemetry.Trace.Core (
  Event (..),
  ImmutableSpan (..),
  SpanHot (..),
  SpanStatus (..),
  createSpan,
  createTracerProvider,
  defaultSpanArguments,
  emptyTracerProviderOptions,
  instrumentationLibrary,
  makeTracer,
  recordErrorWithContext,
  recordExceptionWithContext,
  recordSomeException,
  tracerOptions,
  unsafeReadSpan,
 )
import Test.Hspec (describe, expectationFailure, it, shouldBe, shouldNotBe, shouldSatisfy)

import OpenTelemetry.Trace.ExceptionHandlerSpec.Helpers (dummySpanProcessor, getOnlyExceptionEvent)
#endif


spec :: Spec
#if MIN_VERSION_base(4,20,0)
spec = describe "ExceptionContext-aware stacktrace rendering" $ do
  it "leaves exception.stacktrace empty when no annotation is present" $ do
    let ex = toException (ErrorCall "no-stack")
    tp <- createTracerProvider [dummySpanProcessor] emptyTracerProviderOptions
    let tracer = makeTracer tp (instrumentationLibrary "test" "1") tracerOptions
    s <- createSpan tracer empty "span" defaultSpanArguments
    recordSomeException s H.empty Nothing ex
    evt <- getOnlyExceptionEvent s
    (lookupAttribute (eventAttributes evt) "exception.stacktrace" >>= fromAttribute @Text)
      `shouldBe` Just ""

  it "recordExceptionWithContext preserves the Backtraces in the attached context" $ do
    -- 'recordExceptionWithContext' should funnel the bundled context through
    -- the same renderer as 'recordSomeException'. Construct a context with
    -- a real 'Backtraces' annotation (so it actually gets rendered) and
    -- check the result is non-empty — the lossy 'recordException' path
    -- would have stripped this context.
    bts <- collectBacktraces
    let annotated =
          ExceptionWithContext
            (addExceptionAnnotation bts emptyExceptionContext)
            (ErrorCall "boom")
    tp <- createTracerProvider [dummySpanProcessor] emptyTracerProviderOptions
    let tracer = makeTracer tp (instrumentationLibrary "test" "1") tracerOptions
    s <- createSpan tracer empty "span" defaultSpanArguments
    recordExceptionWithContext s H.empty Nothing annotated
    evt <- getOnlyExceptionEvent s
    case lookupAttribute (eventAttributes evt) "exception.stacktrace" >>= fromAttribute @Text of
      Nothing -> expectationFailure "exception.stacktrace attribute missing"
      Just stack -> stack `shouldNotBe` ""

  it "recordErrorWithContext sets Error status and preserves the attached context" $ do
    bts <- collectBacktraces
    let annotated =
          ExceptionWithContext
            (addExceptionAnnotation bts emptyExceptionContext)
            (ErrorCall "boom")
    tp <- createTracerProvider [dummySpanProcessor] emptyTracerProviderOptions
    let tracer = makeTracer tp (instrumentationLibrary "test" "1") tracerOptions
    s <- createSpan tracer empty "span" defaultSpanArguments
    recordErrorWithContext s annotated
    imm <- unsafeReadSpan s
    hot <- readIORef (spanHot imm)
    hotStatus hot `shouldSatisfy` \case Error _ -> True; _ -> False
    evt <- getOnlyExceptionEvent s
    case lookupAttribute (eventAttributes evt) "exception.stacktrace" >>= fromAttribute @Text of
      Nothing -> expectationFailure "exception.stacktrace attribute missing"
      Just stack -> stack `shouldNotBe` ""

  it "captures Backtraces attached by the runtime to a thrown exception (base 4.20+)" $ do
    -- End-to-end: rely on the GHC runtime to attach a Backtraces annotation
    -- when an exception is thrown from inside an IO HasCallStack chain.
    -- This is the path real instrumented code exercises (via 'inSpan').
    caughtEx <-
      Control.Exception.try @SomeException ioStackLevelOne >>= \case
        Left e -> pure e
        Right () -> error "expected exception was not thrown"
    tp <- createTracerProvider [dummySpanProcessor] emptyTracerProviderOptions
    let tracer = makeTracer tp (instrumentationLibrary "test" "1") tracerOptions
    s <- createSpan tracer empty "span" defaultSpanArguments
    recordSomeException s H.empty Nothing caughtEx
    evt <- getOnlyExceptionEvent s
    case lookupAttribute (eventAttributes evt) "exception.stacktrace" >>= fromAttribute @Text of
      Nothing -> expectationFailure "exception.stacktrace attribute missing"
      Just stack -> do
        stack `shouldNotBe` ""
        -- The rendered Backtraces should have the HasCallStack header and
        -- mention each link in our chain — the "non-trivial" check.
        T.isInfixOf "HasCallStack" stack `shouldBe` True
        T.isInfixOf "ioStackLevelOne" stack `shouldBe` True
        T.isInfixOf "ioStackLevelTwo" stack `shouldBe` True
        T.isInfixOf "ExceptionContextSpec.hs" stack `shouldBe` True

#if MIN_VERSION_base(4,21,0)
  it "renders the WhileHandling chain when an exception is thrown during handling (base 4.21+)" $ do
    -- GHC 9.12+ attaches a WhileHandling annotation when an exception is
    -- thrown from inside another exception's handler. Our stack rendering
    -- recurses into it so the originating exception's stack is included.
    caughtEx <-
      Control.Exception.try @SomeException nestedThrowDuringHandling >>= \case
        Left e -> pure e
        Right () -> error "expected exception was not thrown"
    tp <- createTracerProvider [dummySpanProcessor] emptyTracerProviderOptions
    let tracer = makeTracer tp (instrumentationLibrary "test" "1") tracerOptions
    s <- createSpan tracer empty "span" defaultSpanArguments
    recordSomeException s H.empty Nothing caughtEx
    evt <- getOnlyExceptionEvent s
    case lookupAttribute (eventAttributes evt) "exception.stacktrace" >>= fromAttribute @Text of
      Nothing -> expectationFailure "exception.stacktrace attribute missing"
      Just stack -> do
        stack `shouldNotBe` ""
        -- The handler's own thrown exception (the outer one) should be
        -- there.
        T.isInfixOf "secondaryThrow" stack `shouldBe` True
        -- GHC's WhileHandling annotation renders as "While handling
        -- <displayException of inner>". The inner ErrorCall display is
        -- just its message, "original-boom".
        T.isInfixOf "While handling" stack `shouldBe` True
        T.isInfixOf "original-boom" stack `shouldBe` True
#endif


-- | IO chain that throws an exception via 'error'. The runtime attaches a
-- 'Backtraces' annotation populated from 'HasCallStack' on GHC 9.10+, which
-- is exactly the path real instrumented code exercises.
ioStackLevelOne :: (HasCallStack) => IO ()
ioStackLevelOne = ioStackLevelTwo
{-# NOINLINE ioStackLevelOne #-}


ioStackLevelTwo :: (HasCallStack) => IO ()
ioStackLevelTwo = error "boom"
{-# NOINLINE ioStackLevelTwo #-}


#if MIN_VERSION_base(4,21,0)
-- | Throw an exception, catch it, and throw a new one from the handler. On
-- base 4.21+ the runtime attaches a 'WhileHandling' annotation to the
-- secondary exception pointing back at the original.
nestedThrowDuringHandling :: (HasCallStack) => IO ()
nestedThrowDuringHandling =
  Control.Exception.catch originalThrow $ \(_ :: SomeException) -> secondaryThrow
{-# NOINLINE nestedThrowDuringHandling #-}


originalThrow :: (HasCallStack) => IO ()
originalThrow = error "original-boom"
{-# NOINLINE originalThrow #-}


secondaryThrow :: (HasCallStack) => IO ()
secondaryThrow = error "secondary-boom"
{-# NOINLINE secondaryThrow #-}
#endif

#else
spec = pure ()
#endif
