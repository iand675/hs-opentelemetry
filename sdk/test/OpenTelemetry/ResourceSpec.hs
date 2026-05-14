{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}

module OpenTelemetry.ResourceSpec where

import Data.Text (Text)
import OpenTelemetry.Attributes (ToAttribute (..), getCount, lookupAttribute)
import OpenTelemetry.Resource
import Test.Hspec


spec :: Spec
spec = describe "Resource" $ do
  specify "Create from Attributes" $ do
    let res =
          mkResource @'Nothing
            [ "service.name" .= ("my-service" :: Text)
            , "service.version" .= ("1.0.0" :: Text)
            ]
        materialized = materializeResources res
        attrs = getMaterializedResourcesAttributes materialized
    lookupAttribute attrs "service.name" `shouldBe` Just (toAttribute @Text "my-service")
    lookupAttribute attrs "service.version" `shouldBe` Just (toAttribute @Text "1.0.0")

  specify "Create empty" $ do
    let res = mkResource @'Nothing []
        materialized = materializeResources res
        attrs = getMaterializedResourcesAttributes materialized
    getCount attrs `shouldBe` 0
    materialized `shouldBe` emptyMaterializedResources

  specify "Merge (v2)" $ do
    let old =
          mkResource @'Nothing
            [ "host.name" .= ("host-a" :: Text)
            , "region" .= ("us-east-1" :: Text)
            ]
        new =
          mkResource @'Nothing
            [ "host.name" .= ("host-b" :: Text)
            , "service.name" .= ("svc" :: Text)
            ]
        merged = mergeResources new old
        materialized = materializeResources merged
        attrs = getMaterializedResourcesAttributes materialized
    -- The updating (new/left) resource's values take precedence
    lookupAttribute attrs "host.name" `shouldBe` Just (toAttribute @Text "host-b")
    -- Attributes unique to old resource are preserved
    lookupAttribute attrs "region" `shouldBe` Just (toAttribute @Text "us-east-1")
    -- Attributes unique to new resource are preserved
    lookupAttribute attrs "service.name" `shouldBe` Just (toAttribute @Text "svc")

  specify "Retrieve attributes" $ do
    let res =
          mkResource @'Nothing
            [ "key1" .= ("value1" :: Text)
            , "key2" .= (42 :: Int)
            ]
        materialized = materializeResources res
        attrs = getMaterializedResourcesAttributes materialized
    lookupAttribute attrs "key1" `shouldBe` Just (toAttribute @Text "value1")
    lookupAttribute attrs "key2" `shouldBe` Just (toAttribute @Int 42)
    lookupAttribute attrs "nonexistent" `shouldBe` Nothing

  specify "Default value for service.name" $ do
    -- Per the OTel spec, if service.name is not provided, the default is "unknown_service"
    let res = mkResource @'Nothing []
        materialized = materializeResources res
        attrs = getMaterializedResourcesAttributes materialized
    -- An empty resource should NOT have service.name set automatically
    -- (that is the SDK/TracerProvider's responsibility, not mkResource's)
    -- But when the SDK sets it, the default should be "unknown_service"
    -- We verify the empty resource has no service.name
    lookupAttribute attrs "service.name" `shouldBe` Nothing

    -- When a user explicitly provides service.name, it should be preserved
    let resWithName =
          mkResource @'Nothing
            [ "service.name" .= ("my-app" :: Text)
            ]
        materializedWithName = materializeResources resWithName
        attrsWithName = getMaterializedResourcesAttributes materializedWithName
    lookupAttribute attrsWithName "service.name" `shouldBe` Just (toAttribute @Text "my-app")
