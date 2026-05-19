module OpenTelemetry.Trace.TracerSpec where

import qualified OpenTelemetry.Attributes as A
import OpenTelemetry.Context (empty, insertSpan)
import OpenTelemetry.Processor.Span (FlushResult (..), ShutdownResult (..), SpanProcessor (..))
import OpenTelemetry.Trace.Core
import OpenTelemetry.Trace.Id (Base (Base16), baseEncodedToSpanId, baseEncodedToTraceId)
import OpenTelemetry.Trace.Sampler
import qualified OpenTelemetry.Trace.TraceState as TraceState
import Test.Hspec


dummyProcessor :: SpanProcessor
dummyProcessor =
  SpanProcessor
    { spanProcessorOnStart = \_ _ -> pure ()
    , spanProcessorOnEnd = \_ -> pure ()
    , spanProcessorShutdown = pure ShutdownSuccess
    , spanProcessorForceFlush = pure FlushSuccess
    }


parentSpanContextWithTraceState :: TraceState.TraceState -> SpanContext
parentSpanContextWithTraceState parentTs =
  let (Right tId) = baseEncodedToTraceId Base16 "00000000000000000000000000000001"
      (Right pSId) = baseEncodedToSpanId Base16 "000000000000000a"
  in SpanContext
       { traceFlags = setSampled defaultTraceFlags
       , isRemote = False
       , traceId = tId
       , spanId = pSId
       , traceState = parentTs
       }


spec :: Spec
spec = describe "Tracer" $ do
  -- Trace API §Tracer: whether a tracer will produce spans (SDK wiring)
  -- https://opentelemetry.io/docs/specs/otel/trace/api/#tracer
  describe "tracerIsEnabled" $ do
    it "returns False when TracerProvider has no processors" $ do
      tp <- createTracerProvider [] emptyTracerProviderOptions
      let instrLib = InstrumentationLibrary "test" "1.0.0" "" A.emptyAttributes
          tracer = makeTracer tp instrLib tracerOptions
      tracerIsEnabled tracer `shouldBe` False

    it "returns True when TracerProvider has at least one processor" $ do
      let dummyProcessor =
            SpanProcessor
              { spanProcessorOnStart = \_ _ -> pure ()
              , spanProcessorOnEnd = \_ -> pure ()
              , spanProcessorShutdown = pure ShutdownSuccess
              , spanProcessorForceFlush = pure FlushSuccess
              }
      tp <- createTracerProvider [dummyProcessor] emptyTracerProviderOptions
      let instrLib = InstrumentationLibrary "test" "1.0.0" "" A.emptyAttributes
          tracer = makeTracer tp instrLib tracerOptions
      tracerIsEnabled tracer `shouldBe` True

    it "returns True when TracerProvider has multiple processors" $ do
      let dummyProcessor1 =
            SpanProcessor
              { spanProcessorOnStart = \_ _ -> pure ()
              , spanProcessorOnEnd = \_ -> pure ()
              , spanProcessorShutdown = pure ShutdownSuccess
              , spanProcessorForceFlush = pure FlushSuccess
              }
          dummyProcessor2 =
            SpanProcessor
              { spanProcessorOnStart = \_ _ -> pure ()
              , spanProcessorOnEnd = \_ -> pure ()
              , spanProcessorShutdown = pure ShutdownSuccess
              , spanProcessorForceFlush = pure FlushSuccess
              }
      tp <- createTracerProvider [dummyProcessor1, dummyProcessor2] emptyTracerProviderOptions
      let instrLib = InstrumentationLibrary "test" "1.0.0" "" A.emptyAttributes
          tracer = makeTracer tp instrLib tracerOptions
      tracerIsEnabled tracer `shouldBe` True

  -- Trace API §SpanContext: TraceState is part of immutable span context; child inherits parent TraceState
  -- https://opentelemetry.io/docs/specs/otel/trace/api/#spancontext
  describe "TraceState inheritance (regression: Dropped child must not reset traceState)" $ do
    it "inherits parent TraceState when TracerProvider has no processors (FrozenSpan parent)" $ do
      let parentTs =
            TraceState.insert (TraceState.Key "vendor") (TraceState.Value "value") TraceState.empty
          parentSpan = wrapSpanContext $ parentSpanContextWithTraceState parentTs
          ctx = insertSpan parentSpan empty
      tp <- createTracerProvider [] emptyTracerProviderOptions
      let instrLib = InstrumentationLibrary "test" "1.0.0" "" A.emptyAttributes
          t = makeTracer tp instrLib tracerOptions
      child <- createSpan t ctx "child" defaultSpanArguments
      childCtx <- getSpanContext child
      traceState childCtx `shouldBe` parentTs

    it "inherits parent TraceState when parent is Dropped but TracerProvider has processors" $ do
      let parentTs =
            TraceState.insert (TraceState.Key "vendor") (TraceState.Value "value") TraceState.empty
          parentSpan = wrapDroppedContext $ parentSpanContextWithTraceState parentTs
          ctx = insertSpan parentSpan empty
      tp <- createTracerProvider [dummyProcessor] emptyTracerProviderOptions
      let instrLib = InstrumentationLibrary "test" "1.0.0" "" A.emptyAttributes
          t = makeTracer tp instrLib tracerOptions
      child <- createSpan t ctx "child" defaultSpanArguments
      childCtx <- getSpanContext child
      traceState childCtx `shouldBe` parentTs
