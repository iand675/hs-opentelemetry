{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
import Test.Hspec
import OpenTelemetry.Attributes (lookupAttribute)
import OpenTelemetry.Trace.Core
import Control.Monad.Reader
import OpenTelemetry.Context
import Control.Exception
import qualified Data.Bifunctor
import Control.Monad.IO.Unlift (MonadUnliftIO)
import Data.IORef
import Data.Maybe (isJust)
import qualified Data.Vector as V
import qualified VectorBuilder.Vector as Builder
-- Specs
import qualified OpenTelemetry.Trace.TraceFlagsSpec as TraceFlags
import qualified OpenTelemetry.Trace.SamplerSpec as Sampler
import OpenTelemetry.Util

newtype TestException = TestException String
  deriving (Show)

instance Exception TestException

exceptionTest :: IO ()
exceptionTest = do
  tp <- getGlobalTracerProvider
  t <- OpenTelemetry.Trace.Core.getTracer tp "test" tracerOptions
  spanToCheck <- newIORef undefined
  handle (\(TestException _) -> pure ()) $ do
    inSpan' t "test" defaultSpanArguments $ \span -> do
      liftIO $ writeIORef spanToCheck span
      throw $ TestException "wow"
  spanState <- unsafeReadSpan =<< readIORef spanToCheck
  let ev = V.head $ appendOnlyBoundedCollectionValues $ spanEvents spanState
  eventName ev `shouldBe` "exception"
  eventAttributes ev `shouldSatisfy` \attrs -> 
    isJust (lookupAttribute attrs "exception.type") &&
    isJust (lookupAttribute attrs "exception.message") &&
    isJust (lookupAttribute attrs "exception.stacktrace")

main :: IO ()
main = hspec $ do
  -- describe "inSpan" $ do
  --   it "records exceptions" $ do
  --     exceptionTest
  Sampler.spec
  TraceFlags.spec
