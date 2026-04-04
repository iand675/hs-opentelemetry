{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.RegistrySpec where

import qualified Data.HashMap.Strict as H
import Data.IORef (newIORef, readIORef, writeIORef)
import Data.Maybe (isJust, isNothing)
import OpenTelemetry.Exporter.Span (SpanExporter (..))
import OpenTelemetry.Internal.Common.Types (ExportResult (..))
import OpenTelemetry.Registry
import Test.Hspec


noopExporter :: String -> IO SpanExporter
noopExporter tag = do
  ref <- newIORef tag
  pure
    SpanExporter
      { spanExporterExport = \_ -> readIORef ref >> pure Success
      , spanExporterShutdown = pure ()
      , spanExporterForceFlush = pure ()
      }


assertJust :: String -> Maybe a -> IO a
assertJust msg Nothing = expectationFailure msg >> error "unreachable"
assertJust _ (Just a) = pure a


spec :: Spec
spec = do
  describe "OpenTelemetry.Registry" $ do
    describe "Span Exporter Registry" $ do
      it "stores a factory that can be looked up by name" $ do
        registerSpanExporterFactory "reg-test-store" (noopExporter "a")
        result <- lookupSpanExporterFactory "reg-test-store"
        isJust result `shouldBe` True

      it "returns Nothing for unregistered names" $ do
        result <- lookupSpanExporterFactory "no-such-exporter-xyz"
        isNothing result `shouldBe` True

      it "replaces an existing entry on re-registration" $ do
        ref <- newIORef ("" :: String)
        registerSpanExporterFactory "reg-test-replace" $ do
          writeIORef ref "first"
          noopExporter "first"
        registerSpanExporterFactory "reg-test-replace" $ do
          writeIORef ref "second"
          noopExporter "second"
        factory <- assertJust "expected factory" =<< lookupSpanExporterFactory "reg-test-replace"
        _ <- factory
        readIORef ref `shouldReturn` "second"

      it "registerIfAbsent inserts when key is absent and returns True" $ do
        inserted <- registerSpanExporterFactoryIfAbsent "reg-test-absent-new" (noopExporter "first")
        inserted `shouldBe` True
        isJust <$> lookupSpanExporterFactory "reg-test-absent-new" >>= (`shouldBe` True)

      it "registerIfAbsent returns False and preserves original when key exists" $ do
        ref <- newIORef ("" :: String)
        registerSpanExporterFactory "reg-test-absent-dup" $ do
          writeIORef ref "original"
          noopExporter "original"
        inserted <- registerSpanExporterFactoryIfAbsent "reg-test-absent-dup" $ do
          writeIORef ref "replacement"
          noopExporter "replacement"
        inserted `shouldBe` False
        factory <- assertJust "expected factory" =<< lookupSpanExporterFactory "reg-test-absent-dup"
        _ <- factory
        readIORef ref `shouldReturn` "original"

      it "registeredSpanExporterFactories includes all registered entries" $ do
        registerSpanExporterFactory "reg-test-all-a" (noopExporter "a")
        registerSpanExporterFactory "reg-test-all-b" (noopExporter "b")
        allFactories <- registeredSpanExporterFactories
        H.member "reg-test-all-a" allFactories `shouldBe` True
        H.member "reg-test-all-b" allFactories `shouldBe` True

      it "registered factory produces a working exporter" $ do
        registerSpanExporterFactory "reg-test-works" (noopExporter "works")
        factory <- assertJust "expected factory" =<< lookupSpanExporterFactory "reg-test-works"
        exporter <- factory
        result <- spanExporterExport exporter H.empty
        case result of
          Success -> pure ()
          _ -> expectationFailure "expected export Success"

    describe "Text Map Propagator Registry" $ do
      it "stores a propagator that can be looked up by name" $ do
        registerTextMapPropagator "reg-test-prop-store" mempty
        isJust <$> lookupRegisteredTextMapPropagator "reg-test-prop-store" >>= (`shouldBe` True)

      it "returns Nothing for unregistered names" $ do
        isNothing <$> lookupRegisteredTextMapPropagator "no-such-propagator-xyz" >>= (`shouldBe` True)

      it "registerIfAbsent inserts when key is absent and returns True" $ do
        inserted <- registerTextMapPropagatorIfAbsent "reg-test-prop-absent" mempty
        inserted `shouldBe` True

      it "registerIfAbsent returns False when key exists" $ do
        registerTextMapPropagator "reg-test-prop-dup" mempty
        inserted <- registerTextMapPropagatorIfAbsent "reg-test-prop-dup" mempty
        inserted `shouldBe` False

      it "registeredTextMapPropagators includes all registered entries" $ do
        registerTextMapPropagator "reg-test-prop-x" mempty
        registerTextMapPropagator "reg-test-prop-y" mempty
        allProps <- registeredTextMapPropagators
        H.member "reg-test-prop-x" allProps `shouldBe` True
        H.member "reg-test-prop-y" allProps `shouldBe` True
