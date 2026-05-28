{-# LANGUAGE OverloadedStrings #-}

-----------------------------------------------------------------------------

-----------------------------------------------------------------------------

{- |
 Module      :  OpenTelemetry.Resource.OperatingSystem.Detector
 Copyright   :  (c) Ian Duncan, 2021
 License     :  BSD-3
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)

 Detect information about the current system's OS.
-}
module OpenTelemetry.Resource.OperatingSystem.Detector (
  detectOperatingSystem,
) where

import Control.Exception (try)
import Data.Maybe (mapMaybe)
import qualified Data.Text as T
import qualified Data.Text.IO as T
import OpenTelemetry.Resource.OperatingSystem
import System.IO.Error (tryIOError)
import System.Info (os)
import System.Process (readProcess)


{- | Retrieve any information able to be detected about the current operating system.

 Detects 'osType', 'osName', 'osVersion', and 'osDescription' on macOS and Linux.
 On other platforms, only 'osType' is populated.

 @since 0.0.1.0
-}
detectOperatingSystem :: IO OperatingSystem
detectOperatingSystem = do
  let osTypeVal =
        if os == "mingw32"
          then "windows"
          else T.pack os
  (name, ver, desc) <- detectOsDetails osTypeVal
  pure
    OperatingSystem
      { osType = osTypeVal
      , osDescription = desc
      , osName = name
      , osVersion = ver
      , osBuildId = Nothing
      }


detectOsDetails :: T.Text -> IO (Maybe T.Text, Maybe T.Text, Maybe T.Text)
detectOsDetails "darwin" = do
  name <- tryShellCommand "sw_vers" ["-productName"]
  ver <- tryShellCommand "sw_vers" ["-productVersion"]
  let desc = case (name, ver) of
        (Just n, Just v) -> Just (n <> " " <> v)
        _ -> Nothing
  pure (name, ver, desc)
detectOsDetails "linux" = do
  osRelease <- tryReadOsRelease
  case osRelease of
    Nothing -> pure (Nothing, Nothing, Nothing)
    Just content ->
      let fields = parseOsRelease content
          name = lookup "NAME" fields
          ver = lookup "VERSION_ID" fields
          desc = lookup "PRETTY_NAME" fields
      in pure (name, ver, desc)
detectOsDetails "windows" =
  pure (Just "Windows", Nothing, Nothing)
detectOsDetails _ =
  pure (Nothing, Nothing, Nothing)


tryShellCommand :: String -> [String] -> IO (Maybe T.Text)
tryShellCommand cmd args = do
  result <- try (readProcess cmd args "") :: IO (Either IOError String)
  pure $ case result of
    Right output ->
      let trimmed = T.strip (T.pack output)
      in if T.null trimmed then Nothing else Just trimmed
    Left _ -> Nothing


tryReadOsRelease :: IO (Maybe T.Text)
tryReadOsRelease = do
  result <- tryIOError (T.readFile "/etc/os-release")
  pure $ case result of
    Right content | not (T.null content) -> Just content
    _ -> Nothing


parseOsRelease :: T.Text -> [(T.Text, T.Text)]
parseOsRelease content =
  mapMaybe parseLine (T.lines content)
  where
    parseLine line =
      case T.break (== '=') line of
        (key, rest)
          | not (T.null rest) ->
              Just (key, stripQuotes (T.drop 1 rest))
        _ -> Nothing
    stripQuotes t =
      case T.uncons t of
        Just ('"', rest) -> maybe rest fst (T.unsnoc rest)
        _ -> t
