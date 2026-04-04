{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module OpenTelemetry.Trace.MonadSpec where

import Control.Monad.IO.Class (MonadIO)
import Control.Monad.IO.Unlift (MonadUnliftIO)
import Control.Monad.Trans.Reader (ReaderT (..), ask, runReaderT)
import qualified OpenTelemetry.Attributes as A
import OpenTelemetry.Processor.Span (SpanProcessor (..))
import OpenTelemetry.Trace.Core
import qualified OpenTelemetry.Trace.Monad as TM
import Test.Hspec


newtype TestM a = TestM {runTestM :: ReaderT Tracer IO a}
  deriving newtype (Functor, Applicative, Monad, MonadIO, MonadUnliftIO)


instance TM.MonadTracer TestM where
  getTracer = TestM ask


spec :: Spec
spec = describe "Trace.Monad" $ do
  it "inSpan creates and ends a span without throwing" $ do
    t <- mkTracer
    runReaderT (runTestM $ TM.inSpan "monad-span" defaultSpanArguments $ pure ()) t

  it "inSpan' provides a recording span to the callback" $ do
    t <- mkTracer
    recording <-
      runReaderT
        ( runTestM $
            TM.inSpan' "monad-span-prime" defaultSpanArguments isRecording
        )
        t
    recording `shouldBe` True

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
          , spanProcessorShutdown = error "MonadSpec: shutdown not used"
          , spanProcessorForceFlush = pure ()
          }
  tp <- createTracerProvider [dummyProcessor] emptyTracerProviderOptions
  let instrLib = InstrumentationLibrary "test" "1.0.0" "" A.emptyAttributes
  pure $ makeTracer tp instrLib tracerOptions
