{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

import Control.Exception
import Control.Monad.IO.Unlift (MonadUnliftIO)
import Control.Monad.Reader
import qualified Data.Bifunctor
import Data.IORef
import Data.Maybe (isJust)
import qualified Data.Vector as V
import OpenTelemetry.Attributes (lookupAttribute)
-- Specs

import qualified OpenTelemetry.BaggageSpec as Baggage
import OpenTelemetry.Context
import qualified OpenTelemetry.Logs.CoreSpec as CoreSpec
import qualified OpenTelemetry.SemanticsConfigSpec as SemanticsConfigSpec
import OpenTelemetry.Trace.Core
import qualified OpenTelemetry.Trace.SamplerSpec as Sampler
import qualified OpenTelemetry.Trace.TraceFlagsSpec as TraceFlags
import OpenTelemetry.Util
import Test.Hspec
import qualified VectorBuilder.Vector as Builder


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
    isJust (lookupAttribute attrs "exception.type")
      && isJust (lookupAttribute attrs "exception.message")
      && isJust (lookupAttribute attrs "exception.stacktrace")


main :: IO ()
main = hspec $ do
  -- describe "inSpan" $ do
  --   it "records exceptions" $ do
  --     exceptionTest
  Baggage.spec
  Sampler.spec
  TraceFlags.spec
  SemanticsConfigSpec.spec
  CoreSpec.spec
