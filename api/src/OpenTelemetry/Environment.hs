module OpenTelemetry.Environment (
  isTrue,
) where

import qualified Data.CaseInsensitive as CI


-- Have a look here for the specification.
-- https://opentelemetry.io/docs/specs/otel/configuration/sdk-environment-variables/#boolean-value

isTrue :: String -> Bool
isTrue = ("true" ==) . CI.mk
