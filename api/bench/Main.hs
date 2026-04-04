{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import Control.Concurrent.MVar
import Control.Monad (void)
import qualified Data.HashMap.Strict as H
import qualified Data.Text as T
import OpenTelemetry.Attributes (defaultAttributeLimits, emptyAttributes)
import qualified OpenTelemetry.Attributes as A
import OpenTelemetry.Context (empty, insertSpan, lookupSpan)
import OpenTelemetry.Context.ThreadLocal (adjustContext, attachContext, getContext)
import OpenTelemetry.Internal.AtomicCounter
import OpenTelemetry.Processor.Span (SpanProcessor (..))
import OpenTelemetry.Trace.Core
import Test.Tasty.Bench


main :: IO ()
main = do
  noopTp <- createTracerProvider [] emptyTracerProviderOptions
  let noopTracer = makeTracer noopTp (InstrumentationLibrary "bench" "1.0" "" emptyAttributes) tracerOptions

  dummyProcessor <- mkCountingProcessor
  activeTp <- createTracerProvider [dummyProcessor] emptyTracerProviderOptions
  let activeTracer = makeTracer activeTp (InstrumentationLibrary "bench" "1.0" "" emptyAttributes) tracerOptions

  defaultMain
    [ bgroup
        "createSpan"
        [ bench "no-op (no processors)" $
            whnfIO $
              createSpan noopTracer empty "bench-span" defaultSpanArguments
        , bench "active (with processor)" $
            whnfIO $
              createSpan activeTracer empty "bench-span" defaultSpanArguments
        , bench "active + parent context" $ whnfIO $ do
            parent <- createSpan activeTracer empty "parent" defaultSpanArguments
            let ctx = insertSpan parent empty
            createSpan activeTracer ctx "child" defaultSpanArguments
        ]
    , bgroup
        "endSpan"
        [ bench "no-op span" $ whnfIO $ do
            s <- createSpan noopTracer empty "s" defaultSpanArguments
            endSpan s Nothing
        , bench "active span" $ whnfIO $ do
            s <- createSpan activeTracer empty "s" defaultSpanArguments
            endSpan s Nothing
        ]
    , bgroup
        "isRecording"
        [ bench "Dropped" $ whnfIO $ do
            s <- createSpan noopTracer empty "s" defaultSpanArguments
            isRecording s
        , bench "live Span" $ whnfIO $ do
            s <- createSpan activeTracer empty "s" defaultSpanArguments
            isRecording s
        ]
    , bgroup
        "addAttribute"
        [ bench "on Dropped span" $ whnfIO $ do
            s <- createSpan noopTracer empty "s" defaultSpanArguments
            addAttribute s "key" ("value" :: T.Text)
        , bench "on live span (1 attr)" $ whnfIO $ do
            s <- createSpan activeTracer empty "s" defaultSpanArguments
            addAttribute s "key" ("value" :: T.Text)
        , bench "on live span (10 attrs sequential)" $ whnfIO $ do
            s <- createSpan activeTracer empty "s" defaultSpanArguments
            addAttribute s "k1" ("v" :: T.Text)
            addAttribute s "k2" ("v" :: T.Text)
            addAttribute s "k3" ("v" :: T.Text)
            addAttribute s "k4" ("v" :: T.Text)
            addAttribute s "k5" ("v" :: T.Text)
            addAttribute s "k6" ("v" :: T.Text)
            addAttribute s "k7" ("v" :: T.Text)
            addAttribute s "k8" ("v" :: T.Text)
            addAttribute s "k9" ("v" :: T.Text)
            addAttribute s "k10" ("v" :: T.Text)
        ]
    , bgroup
        "addAttributes-batch"
        [ bench "H.fromList 10 attrs" $ whnfIO $ do
            s <- createSpan activeTracer empty "s" defaultSpanArguments
            addAttributes s $
              H.fromList
                [ ("k1", "v")
                , ("k2", "v")
                , ("k3", "v")
                , ("k4", "v")
                , ("k5", "v")
                , ("k6", "v")
                , ("k7", "v")
                , ("k8", "v")
                , ("k9", "v")
                , ("k10", "v")
                ]
        , bench "AttrsBuilder 10 attrs" $ whnfIO $ do
            s <- createSpan activeTracer empty "s" defaultSpanArguments
            addAttributes' s $
              A.attr "k1" ("v" :: T.Text)
                <> A.attr "k2" ("v" :: T.Text)
                <> A.attr "k3" ("v" :: T.Text)
                <> A.attr "k4" ("v" :: T.Text)
                <> A.attr "k5" ("v" :: T.Text)
                <> A.attr "k6" ("v" :: T.Text)
                <> A.attr "k7" ("v" :: T.Text)
                <> A.attr "k8" ("v" :: T.Text)
                <> A.attr "k9" ("v" :: T.Text)
                <> A.attr "k10" ("v" :: T.Text)
        , bench "H.fromList 3 attrs" $ whnfIO $ do
            s <- createSpan activeTracer empty "s" defaultSpanArguments
            addAttributes s $
              H.fromList
                [ ("method", A.toAttribute ("GET" :: T.Text))
                , ("url", A.toAttribute ("https://example.com/api" :: T.Text))
                , ("status", A.toAttribute (200 :: Int))
                ]
        , bench "AttrsBuilder 3 attrs" $ whnfIO $ do
            s <- createSpan activeTracer empty "s" defaultSpanArguments
            addAttributes' s $
              A.attr "method" ("GET" :: T.Text)
                <> A.attr "url" ("https://example.com/api" :: T.Text)
                <> A.attr "status" (200 :: Int)
        ]
    , bgroup
        "Attributes-pure"
        [ bench "addAttribute x1" $
            whnf
              (\a -> A.addAttribute defaultAttributeLimits a "key" ("val" :: T.Text))
              emptyAttributes
        , bench "addAttribute x10 (same key)" $
            whnf
              ( \a ->
                  let go !acc i =
                        if i > (10 :: Int)
                          then acc
                          else go (A.addAttribute defaultAttributeLimits acc "key" ("val" :: T.Text)) (i + 1)
                  in go a 1
              )
              emptyAttributes
        , bench "addAttribute x10 (distinct keys)" $
            whnf
              ( \a ->
                  let go !acc i =
                        if i > (10 :: Int)
                          then acc
                          else go (A.addAttribute defaultAttributeLimits acc (T.pack $ "key" <> show i) ("val" :: T.Text)) (i + 1)
                  in go a 1
              )
              emptyAttributes
        , bench "addAttributes (HashMap) x5" $
            whnf
              ( \a ->
                  A.addAttributes
                    defaultAttributeLimits
                    a
                    (H.fromList [("k1", "v1"), ("k2", "v2"), ("k3", "v3"), ("k4", "v4"), ("k5", "v5")] :: H.HashMap T.Text A.Attribute)
              )
              emptyAttributes
        , bench "addAttributesFromBuilder x5" $
            whnf
              ( \a ->
                  A.addAttributesFromBuilder
                    defaultAttributeLimits
                    a
                    ( A.attr "k1" ("v1" :: T.Text)
                        <> A.attr "k2" ("v2" :: T.Text)
                        <> A.attr "k3" ("v3" :: T.Text)
                        <> A.attr "k4" ("v4" :: T.Text)
                        <> A.attr "k5" ("v5" :: T.Text)
                    )
              )
              emptyAttributes
        ]
    , bgroup
        "context"
        [ bench "getContext" $ whnfIO getContext
        , bench "attachContext + getContext" $ whnfIO $ do
            void $ attachContext empty
            getContext
        , bench "adjustContext (insertSpan)" $ whnfIO $ do
            s <- createSpan noopTracer empty "s" defaultSpanArguments
            adjustContext (insertSpan s)
        , bench "lookupSpan" $ whnf lookupSpan empty
        ]
    , bgroup
        "inSpan"
        [ bench "no-op tracer" $
            whnfIO $
              inSpan noopTracer "bench" defaultSpanArguments (pure ())
        , bench "active tracer" $
            whnfIO $
              inSpan activeTracer "bench" defaultSpanArguments (pure ())
        , bench "no-op (skip callerAttributes)" $
            whnfIO $
              inSpan'' noopTracer "bench" defaultSpanArguments (const $ pure ())
        , bench "active (skip callerAttributes)" $
            whnfIO $
              inSpan'' activeTracer "bench" defaultSpanArguments (const $ pure ())
        ]
    , bgroup
        "getSpanContext"
        [ bench "Dropped" $ whnfIO $ do
            s <- createSpan noopTracer empty "s" defaultSpanArguments
            getSpanContext s
        , bench "live Span" $ whnfIO $ do
            s <- createSpan activeTracer empty "s" defaultSpanArguments
            getSpanContext s
        ]
    , bgroup "realistic" $
        let httpSpan tracer = inSpan'' tracer "GET /api/users" defaultSpanArguments $ \s -> do
              addAttribute s ("http.method" :: T.Text) ("GET" :: T.Text)
              addAttribute s ("http.url" :: T.Text) ("https://example.com/api/users" :: T.Text)
              addAttribute s ("http.status_code" :: T.Text) (200 :: Int)
              pure ()
            dbSpan tracer = inSpan'' tracer "SELECT users" defaultSpanArguments {kind = Client} $ \s -> do
              addAttribute s ("db.system" :: T.Text) ("postgresql" :: T.Text)
              addAttribute s ("db.statement" :: T.Text) ("SELECT * FROM users WHERE id = $1" :: T.Text)
              addAttribute s ("db.name" :: T.Text) ("mydb" :: T.Text)
              addAttribute s ("db.operation" :: T.Text) ("SELECT" :: T.Text)
              addAttribute s ("db.sql.table" :: T.Text) ("users" :: T.Text)
              pure ()
            spanWithEvents tracer = inSpan'' tracer "process" defaultSpanArguments $ \s -> do
              addEvent
                s
                NewEvent
                  { newEventName = "item.processed"
                  , newEventAttributes = H.fromList [("item.id", A.toAttribute ("abc" :: T.Text))]
                  , newEventTimestamp = Nothing
                  }
              addEvent
                s
                NewEvent
                  { newEventName = "item.validated"
                  , newEventAttributes = H.fromList [("valid", A.toAttribute True)]
                  , newEventTimestamp = Nothing
                  }
              pure ()
            nestedSpans tracer = inSpan'' tracer "parent" defaultSpanArguments $ \_ ->
              inSpan'' tracer "child" defaultSpanArguments $ \_ ->
                inSpan'' tracer "grandchild" defaultSpanArguments $ \_ ->
                  pure ()
            heavySpan tracer = inSpan'' tracer "heavy" defaultSpanArguments $ \s -> do
              addAttribute s ("k1" :: T.Text) ("v" :: T.Text)
              addAttribute s ("k2" :: T.Text) ("v" :: T.Text)
              addAttribute s ("k3" :: T.Text) ("v" :: T.Text)
              addAttribute s ("k4" :: T.Text) ("v" :: T.Text)
              addAttribute s ("k5" :: T.Text) ("v" :: T.Text)
              setStatus s (Error "something broke")
              addEvent
                s
                NewEvent
                  { newEventName = "exception"
                  , newEventAttributes =
                      H.fromList
                        [ ("exception.type", A.toAttribute ("IOException" :: T.Text))
                        , ("exception.message", A.toAttribute ("file not found" :: T.Text))
                        ]
                  , newEventTimestamp = Nothing
                  }
              pure ()
            bareSpan tracer = inSpan'' tracer "bare" defaultSpanArguments $ \_ -> pure ()
        in [ bench "bare span (create+end only)" $ whnfIO $ bareSpan activeTracer
           , bench "HTTP span (3 attrs)" $ whnfIO $ httpSpan activeTracer
           , bench "DB span (5 attrs)" $ whnfIO $ dbSpan activeTracer
           , bench "span + 2 events" $ whnfIO $ spanWithEvents activeTracer
           , bench "3-deep nested spans" $ whnfIO $ nestedSpans activeTracer
           , bench "heavy span (5 attrs + status + event)" $ whnfIO $ heavySpan activeTracer
           , bench "getSpanContext (live, isolated)" $ whnfIO $ do
              s <- createSpan activeTracer empty "s" defaultSpanArguments
              getSpanContext s
           ]
    ]


mkCountingProcessor :: IO SpanProcessor
mkCountingProcessor = do
  ref <- newAtomicCounter 0
  pure
    SpanProcessor
      { spanProcessorOnStart = \_ _ -> pure ()
      , spanProcessorOnEnd = \_ -> void $ incrAtomicCounter ref
      , spanProcessorShutdown = newEmptyMVar >>= readMVar
      , spanProcessorForceFlush = pure ()
      }
