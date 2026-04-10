{- |
Module      : OpenTelemetry.Platform
Description : Windows-specific platform utilities for the OpenTelemetry SDK.
Stability   : experimental
-}
module OpenTelemetry.Platform where

import qualified Data.Text as T


tryGetUser :: IO (Maybe T.Text)
tryGetUser = pure Nothing
