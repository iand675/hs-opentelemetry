{-# LANGUAGE LambdaCase #-}

module OpenTelemetry.SemConvStabilityOptIn (
  getSemConvStabilityOptIn,
  SemConvStabilityOptIn (Stable, Both, Old),
) where

import System.Environment (lookupEnv)


data SemConvStabilityOptIn = Stable | Both | Old


getSemConvStabilityOptIn :: IO SemConvStabilityOptIn
getSemConvStabilityOptIn =
  ( \case
      Just "http" -> Stable
      Just "http/dup" -> Both
      _ -> Old
  )
    <$> lookupEnv "OTEL_SEMCONV_STABILITY_OPT_IN"