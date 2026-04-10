{-# LANGUAGE OverloadedStrings #-}

{- | Declarative SDK configuration via OTEL_CONFIG_FILE.
See: https://opentelemetry.io/docs/specs/otel/configuration/sdk/

Usage:

@
import OpenTelemetry.Configuration

main :: IO ()
main = do
  result <- initializeFromConfigFile
  case result of
    Nothing -> pure () -- OTEL_CONFIG_FILE not set, use default initialization
    Just components -> do
      -- Use otelTracerProvider, otelMeterProvider, etc.
      otelShutdown components
@

Or from a specific file:

@
components <- initializeFromFile "config.yaml"
@
-}
module OpenTelemetry.Configuration (
  -- * Initialization
  initializeFromConfigFile,
  initializeFromFile,
  initializeFromText,

  -- * Components
  OTelComponents (..),

  -- * Configuration model
  OTelConfiguration (..),
  emptyConfiguration,

  -- * Parsing
  parseConfigFile,
  parseConfigBytes,
  ConfigParseError (..),

  -- * Creation
  createFromConfig,
) where

import Control.Applicative ((<|>))
import Data.Text (Text)
import OpenTelemetry.Configuration.Create
import OpenTelemetry.Configuration.Parse
import OpenTelemetry.Configuration.Types
import OpenTelemetry.Internal.Logging (otelLogDebug)
import System.Environment (lookupEnv)


{- | Check for a declarative config file and initialize from it if set.

Checks @OTEL_EXPERIMENTAL_CONFIG_FILE@ first (per the evolving
<https://opentelemetry.io/docs/specs/otel/configuration/file-configuration/ file configuration spec>),
then falls back to @OTEL_CONFIG_FILE@ for backward compatibility.
Returns @Nothing@ if neither env var is set.

@since 0.1.0.0
-}
initializeFromConfigFile :: IO (Maybe OTelComponents)
initializeFromConfigFile = do
  mPath <- lookupEnv "OTEL_EXPERIMENTAL_CONFIG_FILE"
  mPathLegacy <- lookupEnv "OTEL_CONFIG_FILE"
  case mPath <|> mPathLegacy of
    Nothing -> do
      otelLogDebug "OTEL_EXPERIMENTAL_CONFIG_FILE / OTEL_CONFIG_FILE not set, skipping file-based configuration"
      pure Nothing
    Just path -> Just <$> initializeFromFile path


-- | Parse and create SDK components from a YAML configuration file.
--
-- @since 0.1.0.0
initializeFromFile :: FilePath -> IO OTelComponents
initializeFromFile path = do
  result <- parseConfigFile path
  case result of
    Left err -> error $ "Failed to parse OTEL config file " <> path <> ": " <> show err
    Right cfg -> createFromConfig cfg


-- | Parse and create SDK components from YAML text content.
--
-- @since 0.1.0.0
initializeFromText :: Text -> IO OTelComponents
initializeFromText content = do
  result <- parseConfigBytes content
  case result of
    Left err -> error $ "Failed to parse OTEL config: " <> show err
    Right cfg -> createFromConfig cfg
