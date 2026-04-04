module OpenTelemetry.Contrib.SpanTraversalsSpec where

import qualified OpenTelemetry.Attributes as A
import OpenTelemetry.Context (insertSpan)
import qualified OpenTelemetry.Context as Ctxt
import OpenTelemetry.Contrib.SpanTraversals (IterationInstruction (..), alterSpansUpwards)
import OpenTelemetry.Processor.Span (SpanProcessor (..))
import OpenTelemetry.Trace.Core
import OpenTelemetry.Trace.Id
import OpenTelemetry.Trace.TraceState as TraceState
import Test.Hspec


spec :: Spec
spec = describe "Contrib.SpanTraversals" $ do
  it "alterSpansUpwards on FrozenSpan returns initial state" $ do
    let (Right tid) = baseEncodedToTraceId Base16 "00000000000000000000000000000001"
        (Right sid) = baseEncodedToSpanId Base16 "000000000000000a"
        sc =
          SpanContext
            { traceFlags = defaultTraceFlags
            , isRemote = False
            , traceState = TraceState.empty
            , spanId = sid
            , traceId = tid
            }
        frozen = wrapSpanContext sc
    st <- alterSpansUpwards frozen (42 :: Int) $ \_ _ _ ->
      error "alterSpansUpwards FrozenSpan: step function must not run"
    st `shouldBe` 42

  it "alterSpansUpwards on Dropped returns initial state" $ do
    tp <- createTracerProvider [] emptyTracerProviderOptions
    let instrLib = InstrumentationLibrary "test" "1.0.0" "" A.emptyAttributes
        tracer = makeTracer tp instrLib tracerOptions
    dropped <- createSpanWithoutCallStack tracer Ctxt.empty "dropped" defaultSpanArguments
    st <- alterSpansUpwards dropped (7 :: Int) $ \_ _ _ ->
      error "alterSpansUpwards Dropped: step function must not run"
    st `shouldBe` 7

  it "alterSpansUpwards walks from child to root counting spans" $ do
    let dummyProcessor =
          SpanProcessor
            { spanProcessorOnStart = \_ _ -> pure ()
            , spanProcessorOnEnd = \_ -> pure ()
            , spanProcessorShutdown = error "SpanTraversalsSpec: shutdown not used"
            , spanProcessorForceFlush = pure ()
            }
    tp <- createTracerProvider [dummyProcessor] emptyTracerProviderOptions
    let instrLib = InstrumentationLibrary "test" "1.0.0" "" A.emptyAttributes
        tracer = makeTracer tp instrLib tracerOptions
    parent <- createSpanWithoutCallStack tracer Ctxt.empty "parent" defaultSpanArguments
    child <- createSpanWithoutCallStack tracer (insertSpan parent Ctxt.empty) "child" defaultSpanArguments
    count <-
      alterSpansUpwards child (0 :: Int) $ \st _imm _hot ->
        (Continue (st + 1), _hot)
    count `shouldBe` 2
