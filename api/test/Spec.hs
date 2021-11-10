{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
import Test.Hspec
import OpenTelemetry.Trace (getGlobalTracerProvider, tracerOptions, emptySpanArguments, Tracer, getTracer, ImmutableSpan (spanAttributes, spanStatus), unsafeReadSpan, SpanStatus (Error))
import Control.Monad.Reader
import OpenTelemetry.Context
import Control.Exception
import OpenTelemetry.Trace.Monad (inSpan, MonadGetContext (..), MonadTracer (..), MonadLocalContext (..), MonadBracketError, bracketError, bracketErrorUnliftIO)
import qualified Data.Bifunctor
import Control.Monad.IO.Unlift (MonadUnliftIO)
import Data.IORef
import Data.Maybe (isJust)

newtype TestTraceMonad a = TestTraceMonad (ReaderT (Tracer, Context) IO a)
  deriving newtype (Functor, Applicative, Monad, MonadIO, MonadUnliftIO)

instance MonadBracketError TestTraceMonad where
  bracketError = bracketErrorUnliftIO

instance MonadGetContext TestTraceMonad where
  getContext = TestTraceMonad $ asks snd

instance MonadLocalContext TestTraceMonad where
  localContext f (TestTraceMonad m) = TestTraceMonad $ local
    (Data.Bifunctor.second f)
    m
instance MonadTracer TestTraceMonad where
  getTracer = TestTraceMonad $ asks fst

newtype TestException = TestException String
  deriving (Show)

instance Exception TestException

runTestTraceMonad :: Tracer -> Context -> TestTraceMonad a -> IO a
runTestTraceMonad t c (TestTraceMonad m) = runReaderT m (t, c)

exceptionTest :: IO ()
exceptionTest = do
  tp <- getGlobalTracerProvider
  t <- OpenTelemetry.Trace.getTracer tp "test" tracerOptions
  spanToCheck <- newIORef undefined
  handle (\(TestException _) -> pure ()) $ do
    runTestTraceMonad t empty $ do
      inSpan "test" emptySpanArguments $ \span -> do
        liftIO $ writeIORef spanToCheck span
        throw $ TestException "wow"
        pure ()
  spanState <- unsafeReadSpan =<< readIORef spanToCheck
  print $ spanAttributes spanState
  spanAttributes spanState `shouldSatisfy` \attrs -> 
    isJust (Prelude.lookup "exception.type" attrs) &&
    isJust (Prelude.lookup "exception.message" attrs) &&
    isJust (Prelude.lookup "exception.stacktrace" attrs)

main :: IO ()
main = hspec $ do
  describe "inSpan" $ do
    it "records exceptions" $ do
      exceptionTest
