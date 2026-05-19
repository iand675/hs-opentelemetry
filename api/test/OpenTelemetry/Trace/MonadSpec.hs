{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module OpenTelemetry.Trace.MonadSpec where

import Control.Monad.IO.Class (MonadIO)
import Control.Monad.IO.Unlift (MonadUnliftIO)
import Control.Monad.Trans.Reader (ReaderT (..), ask, runReaderT)
import qualified OpenTelemetry.Attributes as A
import OpenTelemetry.Processor.Span (FlushResult (..), ShutdownResult (..), SpanProcessor (..))
import OpenTelemetry.Trace.Core
import qualified OpenTelemetry.Trace.Monad as TM
import Test.Hspec


newtype TestM a = TestM {runTestM :: ReaderT Tracer IO a}
  deriving newtype (Functor, Applicative, Monad, MonadIO, MonadUnliftIO)


instance TM.MonadTracer TestM where
  getTracer = TestM ask


spec :: Spec
spec = describe "Trace.Monad" $ do
  -- Trace API §Creating a Span: span lifecycle (start/end) via convenience API
  -- https://opentelemetry.io/docs/specs/otel/trace/api/#span-operations
  it "inSpan creates and ends a span without throwing" $ do
    t <- mkTracer
    runReaderT (runTestM $ TM.inSpan "monad-span" defaultSpanArguments $ pure ()) t

  -- Trace API §IsRecording: recording state visible to instrumentation
  -- https://opentelemetry.io/docs/specs/otel/trace/api/#isrecording
  it "inSpan' provides a recording span to the callback" $ do
    t <- mkTracer
    recording <-
      runReaderT
        ( runTestM $
            TM.inSpan' "monad-span-prime" defaultSpanArguments isRecording
        )
        t
    recording `shouldBe` True

  -- Trace API §Tracer: obtaining the active tracer (library pattern)
  -- https://opentelemetry.io/docs/specs/otel/trace/api/#tracer
  it "getTracer returns the tracer from the Reader environment" $ do
    t <- mkTracer
    tr <- runReaderT (runTestM TM.getTracer) t
    tracerName tr `shouldBe` tracerName t


mkTracer :: IO Tracer
mkTracer = do
  let dummyProcessor =
        SpanProcessor
          { spanProcessorOnStart = \_ _ -> pure ()
          , spanProcessorOnEnd = \_ -> pure ()
          , spanProcessorShutdown = pure ShutdownSuccess
          , spanProcessorForceFlush = pure FlushSuccess
          }
  tp <- createTracerProvider [dummyProcessor] emptyTracerProviderOptions
  let instrLib = InstrumentationLibrary "test" "1.0.0" "" A.emptyAttributes
  pure $ makeTracer tp instrLib tracerOptions
