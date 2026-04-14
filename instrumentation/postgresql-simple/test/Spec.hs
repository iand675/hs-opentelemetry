{-# LANGUAGE OverloadedStrings #-}

module Main where

import qualified Data.ByteString.Char8 as C
import OpenTelemetry.Instrumentation.PostgresqlSimple (extractOperationName)
import Test.Hspec


main :: IO ()
main = hspec spec


spec :: Spec
spec = do
  describe "extractOperationName" $ do
    it "extracts SELECT" $
      extractOperationName "SELECT * FROM users WHERE id = ?" `shouldBe` Just "SELECT"

    it "extracts INSERT" $
      extractOperationName "INSERT INTO users (name, email) VALUES (?, ?)" `shouldBe` Just "INSERT"

    it "extracts UPDATE" $
      extractOperationName "UPDATE users SET active = true WHERE id = ?" `shouldBe` Just "UPDATE"

    it "extracts DELETE" $
      extractOperationName "DELETE FROM users WHERE expired = true" `shouldBe` Just "DELETE"

    it "handles leading whitespace and newlines" $
      extractOperationName "  \n\t  SELECT 1" `shouldBe` Just "SELECT"

    it "uppercases mixed-case keywords" $
      extractOperationName "select * from t" `shouldBe` Just "SELECT"

    it "returns Nothing for bare parenthesized subquery" $
      extractOperationName "(SELECT 1)" `shouldBe` Nothing

    it "returns Nothing for empty input" $
      extractOperationName C.empty `shouldBe` Nothing

    it "returns Nothing for whitespace only" $
      extractOperationName "   \t\n  " `shouldBe` Nothing

    it "extracts CREATE" $
      extractOperationName "CREATE TABLE IF NOT EXISTS foo (id INT)" `shouldBe` Just "CREATE"

    it "extracts ALTER" $
      extractOperationName "ALTER TABLE users ADD COLUMN age INT" `shouldBe` Just "ALTER"

    it "extracts DROP" $
      extractOperationName "DROP TABLE IF EXISTS temp_data" `shouldBe` Just "DROP"

    it "extracts EXPLAIN" $
      extractOperationName "EXPLAIN ANALYZE SELECT * FROM users" `shouldBe` Just "EXPLAIN"
