{-# LANGUAGE LambdaCase #-}

module OpenTelemetry.Settings (
  Settings,
  semConvStabilityOptIn,
  defaultSettings,
  SemConvStabilityOptIn (Stable, Both, Old),
) where

import System.Environment (lookupEnv)


data SemConvStabilityOptIn = Stable | Both | Old


data Settings = Settings
  { semConvStabilityOptIn :: SemConvStabilityOptIn
  }


defaultSettings :: IO Settings
defaultSettings = do
  semConvStabilityOptIn <-
    ( \case
        Just "http" -> Stable
        Just "http/dup" -> Both
        _ -> Old
      )
      <$> lookupEnv "OTEL_SEMCONV_STABILITY_OPT_IN"
  return Settings {..}