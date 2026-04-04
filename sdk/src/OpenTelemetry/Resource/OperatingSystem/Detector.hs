{-# LANGUAGE OverloadedStrings #-}

{- |
Module      :  OpenTelemetry.Resource.OperatingSystem.Detector
Copyright   :  (c) Ian Duncan, 2021
License     :  BSD-3
Maintainer  :  Ian Duncan
Stability   :  experimental
Portability :  non-portable (GHC extensions)

Detect information about the current system's OS.

On Linux, reads @\/etc\/os-release@ (or @\/usr\/lib\/os-release@ as fallback)
to populate 'osName', 'osVersion', and 'osDescription'. On other platforms,
falls back to 'System.Info.os'.

@since 0.0.1.0
-}
module OpenTelemetry.Resource.OperatingSystem.Detector (
  detectOperatingSystem,
) where

import Data.Maybe (mapMaybe)
import qualified Data.Text as T
import qualified Data.Text.IO as T
import OpenTelemetry.Resource.OperatingSystem
import System.IO.Error (tryIOError)
import System.Info (os)


{- | Retrieve information about the current operating system.

On Linux, reads @\/etc\/os-release@ for name, version, and description
(the @PRETTY_NAME@ field). On macOS, attempts @\/System\/Library\/CoreServices\/SystemVersion.plist@
but falls back to 'System.Info.os' if unavailable.

@since 0.0.1.0
-}
detectOperatingSystem :: IO OperatingSystem
detectOperatingSystem = do
  release <- readOsRelease
  pure $
    OperatingSystem
      { osType =
          if os == "mingw32"
            then "windows"
            else T.pack os
      , osDescription = lookupField "PRETTY_NAME" release
      , osName = lookupField "NAME" release
      , osVersion = lookupField "VERSION_ID" release
      }


readOsRelease :: IO [(T.Text, T.Text)]
readOsRelease = do
  primary <- tryReadFile "/etc/os-release"
  case primary of
    Just content -> pure (parseOsRelease content)
    Nothing -> do
      fallback <- tryReadFile "/usr/lib/os-release"
      pure $ case fallback of
        Just content -> parseOsRelease content
        Nothing -> []


parseOsRelease :: T.Text -> [(T.Text, T.Text)]
parseOsRelease = mapMaybe parseLine . T.lines
  where
    parseLine line
      | T.null line = Nothing
      | T.isPrefixOf "#" line = Nothing
      | otherwise =
          case T.breakOn "=" line of
            (key, rest)
              | T.null rest -> Nothing
              | otherwise -> Just (key, unquote (T.drop 1 rest))
    unquote val
      | T.length val >= 2
      , (T.head val == '"' && T.last val == '"')
          || (T.head val == '\'' && T.last val == '\'') =
          T.init (T.tail val)
      | otherwise = val


lookupField :: T.Text -> [(T.Text, T.Text)] -> Maybe T.Text
lookupField key fields =
  case filter (\(k, _) -> k == key) fields of
    ((_, v) : _) -> if T.null v then Nothing else Just v
    [] -> Nothing


tryReadFile :: FilePath -> IO (Maybe T.Text)
tryReadFile path = do
  result <- tryIOError (T.readFile path)
  pure $ case result of
    Right content | not (T.null content) -> Just content
    _ -> Nothing
