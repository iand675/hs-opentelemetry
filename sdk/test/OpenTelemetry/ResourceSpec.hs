{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.ResourceSpec where

import qualified Data.HashMap.Strict as HM
import Data.Maybe (isJust)
import Data.Text (Text)
import OpenTelemetry.Attributes (getAttributeMap, lookupAttribute, toAttribute)
import OpenTelemetry.Resource
import OpenTelemetry.Trace (TracerProviderOptions (..), getTracerProviderInitializationOptions')
import Test.Hspec


spec :: Spec
spec = describe "Resource" $ do
  specify "Create from Attributes" $ do
    let r :: Resource
        r =
          mkResource
            [ "app.id" .= ("my-app" :: Text)
            , "app.version" .= (2 :: Int)
            ]
        mat = materializeResources r
        attrs = getMaterializedResourcesAttributes mat
    lookupAttribute attrs "app.id" `shouldBe` Just (toAttribute ("my-app" :: Text))
    lookupAttribute attrs "app.version" `shouldBe` Just (toAttribute (2 :: Int))
    HM.lookup "app.id" (getAttributeMap attrs) `shouldBe` lookupAttribute attrs "app.id"

  specify "Create empty" $ do
    let mat = materializeResources (mempty :: Resource)
        attrs = getMaterializedResourcesAttributes mat
    HM.null (getAttributeMap attrs) `shouldBe` True

  specify "Merge (v2)" $ do
    let left :: Resource
        left =
          mkResource
            [ "shared" .= ("from-left" :: Text)
            , "only-left" .= (1 :: Int)
            ]
        right :: Resource
        right =
          mkResource
            [ "shared" .= ("from-right" :: Text)
            , "only-right" .= (2 :: Int)
            ]
        merged = left <> right
        mat = materializeResources merged
        attrs = getMaterializedResourcesAttributes mat
    lookupAttribute attrs "shared" `shouldBe` Just (toAttribute ("from-left" :: Text))
    lookupAttribute attrs "only-left" `shouldBe` Just (toAttribute (1 :: Int))
    lookupAttribute attrs "only-right" `shouldBe` Just (toAttribute (2 :: Int))

  specify "Retrieve attributes" $ do
    let r :: Resource
        r = mkResource ["k.str" .= ("v" :: Text), "k.int" .= (99 :: Int)]
        mat = materializeResources r
        attrs = getMaterializedResourcesAttributes mat
    lookupAttribute attrs "k.str" `shouldBe` Just (toAttribute ("v" :: Text))
    HM.size (getAttributeMap attrs) `shouldBe` 2

  specify "Default value for service.name" $ do
    (_processors, opts) <- getTracerProviderInitializationOptions' mempty
    let attrs = getMaterializedResourcesAttributes (tracerProviderOptionsResources opts)
    isJust (lookupAttribute attrs "service.name") `shouldBe` True
