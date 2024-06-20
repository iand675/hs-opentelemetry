module OpenTelemetry.Platform where

import qualified Data.Text as T


tryGetUser :: IO (Maybe T.Text)
tryGetUser = pure Nothing
