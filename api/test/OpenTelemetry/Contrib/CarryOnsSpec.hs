{-# LANGUAGE TypeApplications #-}

module OpenTelemetry.Contrib.CarryOnsSpec where

import Control.Concurrent.Async (async)
import Control.Exception (bracket_)
import Control.Monad (void)
import qualified Data.HashMap.Strict as HM
import Data.IORef
import Data.Maybe (fromMaybe)
import Data.Text (Text)
import OpenTelemetry.Attributes (lookupAttribute, toAttribute)
import qualified OpenTelemetry.Attributes as A
import qualified OpenTelemetry.Context as Ctxt
import OpenTelemetry.Context.ThreadLocal (attachContext, detachContext)
import OpenTelemetry.Contrib.CarryOns (alterCarryOns, withCarryOnProcessor)
import OpenTelemetry.Processor.Span (ShutdownResult (..), SpanProcessor (..))
import OpenTelemetry.Common (OptionalTimestamp (..))
import OpenTelemetry.Trace.Core
import OpenTelemetry.Trace.Id
import OpenTelemetry.Trace.TraceState as TraceState
import OpenTelemetry.Util (emptyAppendOnlyBoundedCollection)
import Test.Hspec


spec :: Spec
spec = describe "Contrib.CarryOns" $ do
  it "alterCarryOns with id does not throw" $
    bracket_
      (void $ attachContext Ctxt.empty)
      (void detachContext)
      (alterCarryOns id)

  it "withCarryOnProcessor delegates onStart to the inner processor" $ do
    started <- newIORef False
    let inner =
          SpanProcessor
            { spanProcessorOnStart = \_ _ -> writeIORef started True
            , spanProcessorOnEnd = \_ -> pure ()
            , spanProcessorShutdown = async (pure ShutdownSuccess)
            , spanProcessorForceFlush = pure ()
            }
        wrapped = withCarryOnProcessor inner
    imm <- newMinimalSpan
    spanProcessorOnStart wrapped imm Ctxt.empty
    readIORef started `shouldReturn` True

  it "withCarryOnProcessor adds carry-on attributes when onEnd runs"
    $ bracket_
      (void $ attachContext Ctxt.empty)
      (void detachContext)
    $ do
      captured <- newIORef Nothing
      let inner =
            SpanProcessor
              { spanProcessorOnStart = \_ _ -> pure ()
              , spanProcessorOnEnd = \imm -> do
                  hot <- readIORef (spanHot imm)
                  writeIORef captured (Just $ hotAttributes hot)
              , spanProcessorShutdown = async (pure ShutdownSuccess)
              , spanProcessorForceFlush = pure ()
              }
          wrapped = withCarryOnProcessor inner
      alterCarryOns (HM.insert "carry.on.key" (toAttribute @Text "carry-on-value"))
      imm <- newMinimalSpan
      spanProcessorOnEnd wrapped imm
      mAttrs <- readIORef captured
      case mAttrs of
        Nothing -> expectationFailure "expected onEnd to capture span attributes"
        Just attrs ->
          lookupAttribute attrs "carry.on.key" `shouldSatisfy` maybe False (const True)

  it "withCarryOnProcessor skips attribute merge when carry-ons are empty but still calls inner onEnd" $ do
    ends <- newIORef (0 :: Int)
    let inner =
          SpanProcessor
            { spanProcessorOnStart = \_ _ -> pure ()
            , spanProcessorOnEnd = \_ -> modifyIORef' ends (+ 1)
            , spanProcessorShutdown = async (pure ShutdownSuccess)
            , spanProcessorForceFlush = pure ()
            }
        wrapped = withCarryOnProcessor inner
    bracket_
      (void $ attachContext Ctxt.empty)
      (void detachContext)
      $ do
        imm <- newMinimalSpan
        spanProcessorOnEnd wrapped imm
    readIORef ends `shouldReturn` 1


{- | Minimal ImmutableSpan for exercising 'SpanProcessor' hooks without relying on
'createSpan' / 'endSpan' wiring in this test module.
-}
newMinimalSpan :: IO ImmutableSpan
newMinimalSpan = do
  let dummyProcessor =
        SpanProcessor
          { spanProcessorOnStart = \_ _ -> pure ()
          , spanProcessorOnEnd = \_ -> pure ()
          , spanProcessorShutdown = async (pure ShutdownSuccess)
          , spanProcessorForceFlush = pure ()
          }
  tp <- createTracerProvider [dummyProcessor] emptyTracerProviderOptions
  let instrLib = InstrumentationLibrary "test" "1.0.0" "" A.emptyAttributes
      tracer = makeTracer tp instrLib tracerOptions
      limits = defaultSpanLimits
      emptyLinks = emptyAppendOnlyBoundedCollection $ fromMaybe 128 (linkCountLimit limits)
      emptyEv = emptyAppendOnlyBoundedCollection $ fromMaybe 128 (eventCountLimit limits)
      (Right tid) = baseEncodedToTraceId Base16 "aabbccdd00000000000000000000eeff"
      (Right sid) = baseEncodedToSpanId Base16 "0000000000cc00dd"
      sc =
        SpanContext
          { traceFlags = defaultTraceFlags
          , isRemote = False
          , traceState = TraceState.empty
          , spanId = sid
          , traceId = tid
          }
  st <- getTimestamp
  hotRef <- newIORef $ SpanHot
    { hotName = "carry-on-test"
    , hotEnd = NoTimestamp
    , hotAttributes = A.emptyAttributes
    , hotLinks = emptyLinks
    , hotEvents = emptyEv
    , hotStatus = Unset
    }
  pure $ ImmutableSpan
    { spanContext = sc
    , spanKind = Internal
    , spanStart = st
    , spanParent = Nothing
    , spanTracer = tracer
    , spanHot = hotRef
    }
