{-# LANGUAGE OverloadedStrings #-}

module Main where

import qualified Data.HashMap.Strict as H
import OpenTelemetry.Attributes (Attribute (..))
import OpenTelemetry.Attributes.Attribute (PrimitiveAttribute (..))
import OpenTelemetry.Attributes.Key (unkey)
import qualified OpenTelemetry.SemanticConventions as SC
import OpenTelemetry.Instrumentation.Persistent
import OpenTelemetry.SemanticsConfig (StabilityOpt (..))
import Test.Hspec


main :: IO ()
main = hspec spec


spec :: Spec
spec = do
  describe "extractSqlOperation" $ do
    it "extracts SELECT" $
      extractSqlOperation "SELECT * FROM users" `shouldBe` Just "SELECT"

    it "extracts INSERT" $
      extractSqlOperation "INSERT INTO users (name) VALUES (?)" `shouldBe` Just "INSERT"

    it "extracts UPDATE" $
      extractSqlOperation "UPDATE users SET name = ? WHERE id = ?" `shouldBe` Just "UPDATE"

    it "extracts DELETE" $
      extractSqlOperation "DELETE FROM users WHERE id = ?" `shouldBe` Just "DELETE"

    it "handles leading whitespace" $
      extractSqlOperation "  \n\t SELECT 1" `shouldBe` Just "SELECT"

    it "returns Nothing for bare parenthesized subquery" $
      extractSqlOperation "(SELECT 1)" `shouldBe` Nothing

    it "uppercases mixed-case keywords" $
      extractSqlOperation "select * from t" `shouldBe` Just "SELECT"

    it "returns Nothing for empty string" $
      extractSqlOperation "" `shouldBe` Nothing

    it "returns Nothing for whitespace only" $
      extractSqlOperation "   \n\t  " `shouldBe` Nothing

    it "extracts WITH (CTE)" $
      extractSqlOperation "WITH cte AS (SELECT 1) SELECT * FROM cte" `shouldBe` Just "WITH"

    it "extracts BEGIN" $
      extractSqlOperation "BEGIN" `shouldBe` Just "BEGIN"

    it "extracts COMMIT" $
      extractSqlOperation "COMMIT" `shouldBe` Just "COMMIT"

  describe "dbSpanName" $ do
    it "combines operation and namespace" $
      dbSpanName (Just "SELECT") (Just "mydb") `shouldBe` "SELECT mydb"

    it "uses operation alone when no namespace" $
      dbSpanName (Just "INSERT") Nothing `shouldBe` "INSERT"

    it "uses namespace alone when no operation" $
      dbSpanName Nothing (Just "mydb") `shouldBe` "mydb"

    it "falls back to DB when both missing" $
      dbSpanName Nothing Nothing `shouldBe` "DB"

  describe "lookupDbNamespace" $ do
    let stableAttrs = H.fromList [(unkey SC.db_namespace, AttributeValue (TextAttribute "stabledb"))]
        oldAttrs = H.fromList [(unkey SC.db_name, AttributeValue (TextAttribute "olddb"))]
        bothAttrs =
          H.fromList
            [ (unkey SC.db_namespace, AttributeValue (TextAttribute "stabledb"))
            , (unkey SC.db_name, AttributeValue (TextAttribute "olddb"))
            ]
        emptyAttrs = H.empty

    it "reads db.namespace in Stable mode" $
      lookupDbNamespace Stable stableAttrs `shouldBe` Just "stabledb"

    it "returns Nothing for db.name in Stable mode" $
      lookupDbNamespace Stable oldAttrs `shouldBe` Nothing

    it "reads db.namespace in StableAndOld mode (prefers stable)" $
      lookupDbNamespace StableAndOld bothAttrs `shouldBe` Just "stabledb"

    it "falls back to db.name in StableAndOld mode" $
      lookupDbNamespace StableAndOld oldAttrs `shouldBe` Just "olddb"

    it "reads db.name in Old mode" $
      lookupDbNamespace Old oldAttrs `shouldBe` Just "olddb"

    it "returns Nothing for db.namespace in Old mode" $
      lookupDbNamespace Old stableAttrs `shouldBe` Nothing

    it "returns Nothing when attrs empty" $
      lookupDbNamespace Stable emptyAttrs `shouldBe` Nothing
