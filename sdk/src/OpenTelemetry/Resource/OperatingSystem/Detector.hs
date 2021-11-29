{-# LANGUAGE OverloadedStrings #-}
module OpenTelemetry.Resource.OperatingSystem.Detector where
import OpenTelemetry.Resource.OperatingSystem
import qualified Data.Text as T
import System.Info ( os )

-- | Retrieve any infomration able to be detected about the current operation system.
--
-- Currently only supports 'osType' detection, but PRs are welcome to support additional
-- details.
--
-- @since 0.0.1.0
detectOperatingSystem :: IO OperatingSystem 
detectOperatingSystem = pure $ OperatingSystem
  { osType = if os == "mingw32"
      then "windows"
      else T.pack os
  , osDescription = Nothing
  , osName = Nothing
  , osVersion = Nothing
  }