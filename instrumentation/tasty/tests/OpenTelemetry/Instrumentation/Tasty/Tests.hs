{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedLists #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE PatternSynonyms #-}

module OpenTelemetry.Instrumentation.Tasty.Tests (tests) where

import Control.Concurrent (newEmptyMVar, putMVar, takeMVar)
import Control.Concurrent.Async (async)
import Control.Exception (bracket)
import Data.Functor (void)
import Data.IORef (atomicModifyIORef, newIORef, readIORef)
import Data.Map (Map)
import Data.Map qualified as Map
import Data.Maybe (fromMaybe)
import Data.Set qualified as Set
import Data.Text (Text)
import OpenTelemetry.Instrumentation.Tasty (instrumentTestTree)
import OpenTelemetry.Processor.Span (ShutdownResult (ShutdownSuccess), SpanProcessor, spanProcessorForceFlush, spanProcessorOnEnd, spanProcessorOnStart, spanProcessorShutdown, pattern SpanProcessor)
import OpenTelemetry.Trace (ImmutableSpan (ImmutableSpan, spanName, spanParent), createTracerProvider, defaultSpanArguments, emptyTracerProviderOptions, getGlobalTracerProvider, inSpan, makeTracer, setGlobalTracerProvider, shutdownTracerProvider, tracerOptions)
import OpenTelemetry.Trace.Core (unsafeReadSpan)
import Test.Tasty (DependencyType (AllFinish), TestTree, sequentialTestGroup, testGroup, withResource)
import Test.Tasty.HUnit (testCase, (@?=))
import Test.Tasty.Ingredients (tryIngredients)
import Test.Tasty.Ingredients.Basic (Quiet (Quiet), consoleTestReporter)
import Test.Tasty.Options (setOption)


tests :: TestTree
-- each of these tests sets and tears down the global tracer provider,
-- so they have to run sequentially
tests =
  sequentialTestGroup
    "OpenTelemetry.Instrumentation.Tasty"
    AllFinish
    [ basic
    , simpleNesting
    , branching
    , testWithSpan
    , parallelism
    , resources
    ]


basic :: TestTree
basic = testCase "basic" $ do
  (_, trees) <- spanTrees $ do
    testTree <- instrumentTestTree $ testCase "hello" $ pure ()
    runTests $ testTree
  trees @?= [Leaf "hello"]


simpleNesting :: TestTree
simpleNesting = testCase "nested groups make a simple tree" $ do
  (_, trees) <- spanTrees $ do
    testTree <-
      instrumentTestTree $
        testGroup
          "g1"
          [ testGroup "g2" [testCase "t1" (pure ())]
          ]
    runTests $ testTree
  trees @?= [Branch "g1" [Branch "g2" [Leaf "t1"]]]


branching :: TestTree
branching = testCase "nested groups make a branching tree" $ do
  (_, trees) <- spanTrees $ do
    testTree <-
      instrumentTestTree $
        testGroup
          "g1"
          [ testGroup "g2" [testCase "t1" (pure ()), testCase "t2" (pure ())]
          , testGroup "g3" [testCase "t3" (pure ())]
          ]
    runTests $ testTree
  trees @?= [Branch "g1" [Branch "g2" [Leaf "t1", Leaf "t2"], Branch "g3" [Leaf "t3"]]]


testWithSpan :: TestTree
testWithSpan = testCase "test that has a span itself" $ do
  (_, trees) <- spanTrees $ do
    testTree <- instrumentTestTree $ testCase "hello" $ do
      tp <- getGlobalTracerProvider
      let tracer = makeTracer tp "test" tracerOptions
      inSpan tracer "inner" defaultSpanArguments $ pure ()
    runTests $ testTree
  trees @?= [Branch "hello" [Leaf "inner"]]


parallelism :: TestTree
parallelism = testCase "parallelism works" $ do
  block <- newEmptyMVar
  (_, trees) <- spanTrees $ do
    testTree <-
      instrumentTestTree $
        testGroup
          "g1"
          -- Force t1 to wait for t2 before it can even begin, so we
          -- should definitely not start the span for t1 until then
          [ testGroup
              "g2"
              [ withResource (takeMVar block) (const $ pure ()) $ \_ ->
                  testCase "t1" (pure ())
              ]
          , testGroup "g3" [testCase "t2" (putMVar block ())]
          ]
    runTests $ testTree
  trees @?= [Branch "g1" [Branch "g2" [Leaf "acquire", Leaf "t1", Leaf "release"], Branch "g3" [Leaf "t2"]]]


resources :: TestTree
resources = testCase "spans for resource setup and teardown" $ do
  (_, trees) <- spanTrees $ do
    tp <- getGlobalTracerProvider
    let tracer = makeTracer tp "test" tracerOptions
    let acquire = inSpan tracer "myAcquire" defaultSpanArguments $ pure ()
    let release _ = inSpan tracer "myRelease" defaultSpanArguments $ pure ()
    testTree <- instrumentTestTree $ withResource acquire release $ \_ -> testCase "hello" $ pure ()
    runTests $ testTree
  trees @?= [Leaf "hello", Branch "acquire" [Leaf "myAcquire"], Branch "release" [Leaf "myRelease"]]


data Tree a = Branch a (Set.Set (Tree a)) | Leaf a
  deriving stock (Show, Eq, Ord)


spanTrees :: IO a -> IO (a, Set.Set (Tree Text))
spanTrees act = do
  (processor, readSpans) <- recordingProcessor
  res <- bracket (setup processor) shutdownTracerProvider $ \_ -> do
    act
  spans <- readSpans
  trees <- spansToTrees spans
  pure (res, Set.fromList trees)
  where
    setup processor = do
      tp <- createTracerProvider [processor] emptyTracerProviderOptions
      setGlobalTracerProvider tp
      pure tp


toChildMap :: [ImmutableSpan] -> ([Text], Map Text [Text]) -> IO ([Text], Map Text [Text])
toChildMap [] acc = pure acc
toChildMap (ImmutableSpan {spanParent, spanName} : spans) (accRoots, accChildren) = case spanParent of
  Just parent -> do
    ImmutableSpan {spanName = parentName} <- unsafeReadSpan parent
    let existingChildren = fromMaybe mempty $ Map.lookup parentName accChildren
    toChildMap spans (accRoots, Map.insert parentName (existingChildren ++ [spanName]) accChildren)
  Nothing -> toChildMap spans (spanName : accRoots, accChildren)


toTree :: (Ord a) => Map a [a] -> a -> Tree a
toTree childMap node = case Map.lookup node childMap of
  Nothing -> Leaf node
  Just children ->
    if null children
      then Leaf node
      else Branch node $ Set.fromList $ fmap (toTree childMap) children


spansToTrees :: [ImmutableSpan] -> IO [Tree Text]
spansToTrees spans = do
  (roots, childMap) <- toChildMap spans mempty
  let trees = fmap (toTree childMap) roots
  pure trees


recordingProcessor :: IO (SpanProcessor, IO [ImmutableSpan])
recordingProcessor = do
  spans <- newIORef []

  let processor =
        SpanProcessor
          { spanProcessorOnStart = mempty
          , spanProcessorOnEnd = \spanRef -> do
              immutableSpan <- readIORef spanRef
              atomicModifyIORef spans $ \soFar -> (soFar ++ [immutableSpan], ())
          , spanProcessorShutdown = async $ pure ShutdownSuccess
          , spanProcessorForceFlush = mempty
          }

  setGlobalTracerProvider
    =<< createTracerProvider [processor] emptyTracerProviderOptions

  pure (processor, readIORef spans)


runTests :: TestTree -> IO ()
runTests t = case tryIngredients [consoleTestReporter] (setOption (Quiet True) mempty) t of
  Just act -> void act
  Nothing -> error "no ingredient"
