{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.SemConvStabilityOptIn (
  getSemConvStabilityOptIn,
  SemConvStabilityOptIn (Stable, Both, Old),
) where

import qualified Data.Text as T
import System.Environment (lookupEnv)


data SemConvStabilityOptIn = Stable | Both | Old deriving (Show, Eq)


parseSemConvStabilityOptIn :: Maybe String -> SemConvStabilityOptIn
parseSemConvStabilityOptIn Nothing = Old
parseSemConvStabilityOptIn (Just env)
  | "http/dup" `elem` envs = Both
  | "http" `elem` envs = Stable
  | otherwise = Old
  where
    envs = fmap T.strip . T.splitOn "," . T.pack $ env


getSemConvStabilityOptIn :: IO SemConvStabilityOptIn
getSemConvStabilityOptIn = parseSemConvStabilityOptIn <$> lookupEnv "OTEL_SEMCONV_STABILITY_OPT_IN"
