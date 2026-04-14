{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import Conduit
import Control.Exception (SomeException, throwIO, try)
import Control.Monad.IO.Class (liftIO)
import Data.IORef
import qualified Data.Vector as V
import OpenTelemetry.Exporter.InMemory.Span (inMemoryListExporter)
import OpenTelemetry.Instrumentation.Conduit (inSpan)
import OpenTelemetry.Trace.Core (Event (..))
import OpenTelemetry.Trace.Core hiding (inSpan)
import OpenTelemetry.Util (appendOnlyBoundedCollectionValues)
import System.IO.Error (userError)
import Test.Hspec


main :: IO ()
main = hspec spec


withTracer :: (Tracer -> IO a) -> IO ([ImmutableSpan], a)
withTracer action = do
  (processor, ref) <- inMemoryListExporter
  tp <- createTracerProvider [processor] emptyTracerProviderOptions
  let tracer = makeTracer tp "test-conduit" tracerOptions
  result <- action tracer
  _ <- shutdownTracerProvider tp Nothing
  spans <- readIORef ref
  pure (spans, result)


firstSpan :: [ImmutableSpan] -> ImmutableSpan
firstSpan (s : _) = s
firstSpan [] = error "No spans recorded"


spec :: Spec
spec = describe "Conduit instrumentation" $ do
  it "creates a span wrapping a conduit pipeline" $ do
    (spans, result) <- withTracer $ \t ->
      runConduitRes $
        inSpan t "process-items" defaultSpanArguments $ \_s ->
          yieldMany [1 :: Int, 2, 3] .| sinkList
    result `shouldBe` [1, 2, 3]
    hot <- readIORef (spanHot (firstSpan spans))
    hotName hot `shouldBe` "process-items"

  it "records exception on conduit failure" $ do
    (spans, result) <- withTracer $ \t -> do
      r <- try $
        runConduitRes $
          inSpan t "failing-conduit" defaultSpanArguments $ \_s ->
            yieldMany [1 :: Int, 2, 3] .| mapMC (\_ -> liftIO $ throwIO $ userError "conduit-boom") .| sinkList
      pure (r :: Either SomeException [Int])
    case result of
      Left _ -> pure ()
      Right _ -> expectationFailure "expected exception"
    hot <- readIORef (spanHot (firstSpan spans))
    let events = V.toList $ appendOnlyBoundedCollectionValues $ hotEvents hot
    any (\e -> eventName e == "exception") events `shouldBe` True
