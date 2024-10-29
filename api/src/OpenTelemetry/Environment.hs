module OpenTelemetry.Environment (
  lookupBooleanEnv,
) where

import qualified Data.Char as C
import System.Environment (lookupEnv)


{- | Does the given value of an environment variable correspond to "true" according
to [the OpenTelemetry specification](https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/#boolean-value)?
-}
isTrue :: String -> Bool
isTrue = ("true" ==) . map C.toLower


lookupBooleanEnv :: String -> IO Bool
lookupBooleanEnv = fmap (maybe False isTrue) . lookupEnv
