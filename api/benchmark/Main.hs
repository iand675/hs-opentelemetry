{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import qualified Criterion.Main as C
import qualified Data.HashMap.Strict as H
import Data.Maybe (fromMaybe)
import qualified Data.Text as T
import OpenTelemetry.Attributes (Attribute, Attributes, defaultAttributeLimits, emptyAttributes, toAttribute)
import qualified OpenTelemetry.Attributes as Attributes
import OpenTelemetry.Baggage (Baggage, Token, decodeBaggageHeader, element, encodeBaggageHeader, insert, mkToken)
import qualified OpenTelemetry.Baggage as Baggage
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Trace.Core (
  SpanArguments (..),
  Tracer,
  createSpanWithoutCallStack,
  createTracerProvider,
  defaultSpanArguments,
  emptyTracerProviderOptions,
  endSpan,
  inSpan'',
  makeTracer,
  tracerOptions,
 )


main :: IO ()
main = do
  tracer <- mkDroppedTracer

  let smallAttrs = mkAttributeMap 8
      mediumAttrs = mkAttributeMap 64
      largeAttrs = mkAttributeMap 256

      baggageSmall = mkBaggage 4
      baggageMedium = mkBaggage 32
      baggageLarge = mkBaggage 128

      encodedSmall = encodeBaggageHeader baggageSmall
      encodedMedium = encodeBaggageHeader baggageMedium
      encodedLarge = encodeBaggageHeader baggageLarge

      spanArgs = defaultSpanArguments {attributes = mediumAttrs}

  C.defaultMain
    [ C.bgroup
        "attributes"
        [ C.bench "addAttributes-8" $ C.whnf (Attributes.addAttributes defaultAttributeLimits emptyAttributes) smallAttrs
        , C.bench "addAttributes-64" $ C.whnf (Attributes.addAttributes defaultAttributeLimits emptyAttributes) mediumAttrs
        , C.bench "addAttributes-256" $ C.whnf (Attributes.addAttributes defaultAttributeLimits emptyAttributes) largeAttrs
        ]
    , C.bgroup
        "baggage"
        [ C.bench "encode-4" $ C.whnf encodeBaggageHeader baggageSmall
        , C.bench "encode-32" $ C.whnf encodeBaggageHeader baggageMedium
        , C.bench "encode-128" $ C.whnf encodeBaggageHeader baggageLarge
        , C.bench "decode-4" $ C.whnf (decodedOk decodeBaggageHeader) encodedSmall
        , C.bench "decode-32" $ C.whnf (decodedOk decodeBaggageHeader) encodedMedium
        , C.bench "decode-128" $ C.whnf (decodedOk decodeBaggageHeader) encodedLarge
        ]
    , C.bgroup
        "span-lifecycle"
        [ C.bench "createSpanWithoutCallStack+dropped" $ C.nfIO $ do
            s <- createSpanWithoutCallStack tracer Context.empty "bench.create" spanArgs
            endSpan s Nothing
        , C.bench "inSpan''+dropped" $ C.nfIO $ do
            inSpan'' tracer "bench.inSpan" spanArgs (const $ pure ())
        ]
    ]


mkDroppedTracer :: IO Tracer
mkDroppedTracer = do
  tp <- createTracerProvider [] emptyTracerProviderOptions
  pure $ makeTracer tp "benchmark.api" tracerOptions


mkAttributeMap :: Int -> H.HashMap T.Text Attribute
mkAttributeMap n =
  H.fromList
    [ (T.pack ("bench.attr." <> show i), toAttribute i)
    | i <- [1 .. n]
    ]


mkBaggage :: Int -> Baggage
mkBaggage n =
  foldl
    (\acc i -> insert (mkTokenUnsafe (T.pack ("key" <> show i))) (element $ T.pack ("value" <> show i)) acc)
    Baggage.empty
    [1 .. n]


mkTokenUnsafe :: T.Text -> Token
mkTokenUnsafe t = fromMaybe (error "invalid benchmark token") (mkToken t)


decodedOk :: (b -> Either c a) -> b -> Bool
decodedOk decoder input = case decoder input of
  Left _ -> False
  Right x -> x `seq` True
