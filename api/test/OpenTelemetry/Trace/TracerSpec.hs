module OpenTelemetry.Trace.TracerSpec where

import qualified OpenTelemetry.Attributes as A
import OpenTelemetry.Processor.Span (SpanProcessor (..))
import OpenTelemetry.Trace.Core
import OpenTelemetry.Trace.Sampler
import Test.Hspec


spec :: Spec
spec = describe "Tracer" $ do
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
              , spanProcessorShutdown = error "not implemented in test"
              , spanProcessorForceFlush = pure ()
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
              , spanProcessorShutdown = error "not implemented in test"
              , spanProcessorForceFlush = pure ()
              }
          dummyProcessor2 =
            SpanProcessor
              { spanProcessorOnStart = \_ _ -> pure ()
              , spanProcessorOnEnd = \_ -> pure ()
              , spanProcessorShutdown = error "not implemented in test"
              , spanProcessorForceFlush = pure ()
              }
      tp <- createTracerProvider [dummyProcessor1, dummyProcessor2] emptyTracerProviderOptions
      let instrLib = InstrumentationLibrary "test" "1.0.0" "" A.emptyAttributes
          tracer = makeTracer tp instrLib tracerOptions
      tracerIsEnabled tracer `shouldBe` True
