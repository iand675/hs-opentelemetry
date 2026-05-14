{-# LANGUAGE ExplicitForAll #-}

module OpenTelemetry.Environment.Detect where

import qualified Data.ByteString.Char8 as ByteString
import qualified Data.HashMap.Strict as HashMap
import Data.Maybe (fromMaybe)
import Data.Text (Text)
import qualified Data.Text.Encoding as Text
import OpenTelemetry.Attributes
import OpenTelemetry.Baggage (decodeBaggageHeader)
import qualified OpenTelemetry.Baggage as Baggage
import System.Environment (lookupEnv)
import Text.Read (readMaybe)


readEnvDefault :: forall a. (Read a) => String -> a -> IO a
readEnvDefault k defaultValue =
  fromMaybe defaultValue . (>>= readMaybe) <$> lookupEnv k


readEnv :: forall a. (Read a) => String -> IO (Maybe a)
readEnv k = (>>= readMaybe) <$> lookupEnv k


detectAttributeLimits :: IO AttributeLimits
detectAttributeLimits =
  AttributeLimits
    <$> readEnvDefault "OTEL_ATTRIBUTE_COUNT_LIMIT" (attributeCountLimit defaultAttributeLimits)
    <*> ((>>= readMaybe) <$> lookupEnv "OTEL_ATTRIBUTE_VALUE_LENGTH_LIMIT")


detectResourceAttributes :: IO [(Text, Attribute)]
detectResourceAttributes = do
  mEnv <- lookupEnv "OTEL_RESOURCE_ATTRIBUTES"
  case mEnv of
    Nothing -> pure []
    Just envVar -> case decodeBaggageHeader $ ByteString.pack envVar of
      Left err -> do
        -- TODO logError
        putStrLn err
        pure []
      Right ok ->
        pure $
          map (\(k, v) -> (Text.decodeUtf8 $ Baggage.tokenValue k, toAttribute $ Baggage.value v)) $
            HashMap.toList $
              Baggage.values ok
