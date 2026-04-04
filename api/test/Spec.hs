{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

import Control.Exception
import Data.IORef
import Data.Maybe (isJust)
import qualified Data.Vector as V
import OpenTelemetry.Attributes (lookupAttribute)

import qualified OpenTelemetry.AttributesSpec as Attributes
import qualified OpenTelemetry.BaggageSpec as Baggage
import OpenTelemetry.Context
import qualified OpenTelemetry.Context.EnvironmentSpec as ContextEnvironment
import qualified OpenTelemetry.Contrib.CarryOnsSpec as CarryOns
import qualified OpenTelemetry.Contrib.SpanTraversalsSpec as SpanTraversals
import qualified OpenTelemetry.EnvironmentSpec as Environment
import qualified OpenTelemetry.InstrumentationLibrarySpec as InstrumentationLibrary
import qualified OpenTelemetry.Logs.CoreSpec as CoreSpec
import qualified OpenTelemetry.MetricsSpec as MetricsSpec
import qualified OpenTelemetry.RegistrySpec as Registry
import qualified OpenTelemetry.ResourceSpec as Resource
import qualified OpenTelemetry.SemanticsConfigSpec as SemanticsConfigSpec
import OpenTelemetry.Trace.Core
import qualified OpenTelemetry.Trace.ExceptionHandlerSpec as ExceptionHandler
import qualified OpenTelemetry.Trace.MonadSpec as TraceMonad
import qualified OpenTelemetry.Trace.SamplerSpec as Sampler
import qualified OpenTelemetry.Trace.TraceFlagsSpec as TraceFlags
import qualified OpenTelemetry.Trace.TracerSpec as Tracer
import qualified OpenTelemetry.Trace.UtilsSpec as Utils
import OpenTelemetry.Util
import Test.Hspec


newtype TestException = TestException String
  deriving (Show)


instance Exception TestException


exceptionTest :: IO ()
exceptionTest = do
  tp <- getGlobalTracerProvider
  let t = OpenTelemetry.Trace.Core.makeTracer tp "test" tracerOptions
  spanToCheck <- newIORef undefined
  handle (\(TestException _) -> pure ()) $ do
    inSpan' t "test" defaultSpanArguments $ \span -> do
      writeIORef spanToCheck span
      throw $ TestException "wow"
  spanState <- unsafeReadSpan =<< readIORef spanToCheck
  hot <- readIORef (spanHot spanState)
  let ev = V.head $ appendOnlyBoundedCollectionValues $ hotEvents hot
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
  Attributes.spec
  Baggage.spec
  ContextEnvironment.spec
  CarryOns.spec
  SpanTraversals.spec
  Environment.spec
  Resource.spec
  InstrumentationLibrary.spec
  ExceptionHandler.spec
  TraceMonad.spec
  Sampler.spec
  TraceFlags.spec
  Tracer.spec
  Utils.spec
  SemanticsConfigSpec.spec
  CoreSpec.spec
  MetricsSpec.spec
  Registry.spec
