{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.SemConvStabilityOptIn (
  getSemConvStabilityOptIn,
  SemConvStabilityOptIn (Stable, Both, Old),
) where

import qualified Data.Text as T
import System.Environment (lookupEnv)


data SemConvStabilityOptIn = Stable | Both | Old deriving (Show, Eq)


getSemConvStabilityOptIn :: IO SemConvStabilityOptIn
getSemConvStabilityOptIn = do
  menv <- lookupEnv "OTEL_SEMCONV_STABILITY_OPT_IN"
  let menvs = fmap T.strip . T.splitOn "," . T.pack <$> menv
  pure $ case menvs of
    Nothing -> Old
    Just envs ->
      if "http/dup" `elem` envs
        then Both
        else
          if "http" `elem` envs
            then Stable
            else Old
