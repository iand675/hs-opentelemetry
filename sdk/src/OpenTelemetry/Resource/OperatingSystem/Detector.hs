{-# LANGUAGE CPP #-}
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
to populate 'osName', 'osVersion', 'osDescription', and 'osBuildId' (from
@BUILD_ID@ when present). On macOS (Darwin), reads
@\/System\/Library\/CoreServices\/SystemVersion.plist@ for product name, version,
and build. On other platforms, falls back to 'System.Info.os'.

@since 0.0.1.0
-}
module OpenTelemetry.Resource.OperatingSystem.Detector (
  detectOperatingSystem,
) where

#ifndef darwin_HOST_OS
import Data.Maybe (mapMaybe)
#endif
import qualified Data.Text as T
import qualified Data.Text.IO as T
import OpenTelemetry.Resource.OperatingSystem
import System.IO.Error (tryIOError)
import System.Info (os)


{- | Retrieve information about the current operating system.

On Darwin, reads @\/System\/Library\/CoreServices\/SystemVersion.plist@ for
@ProductName@, @ProductVersion@, and @ProductBuildVersion@. On failure, returns
minimal defaults with 'osType' from 'System.Info.os'.

On other Unix-like hosts, reads @\/etc\/os-release@ (with fallback) for name,
version, description (@PRETTY_NAME@), and build id (@BUILD_ID@ when present).

@since 0.0.1.0
-}
detectOperatingSystem :: IO OperatingSystem
#ifdef darwin_HOST_OS
detectOperatingSystem = detectMacOS
#else
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
      , osBuildId = lookupField "BUILD_ID" release
      }
#endif


#ifdef darwin_HOST_OS
-- | Read macOS version metadata from @SystemVersion.plist@; on any failure or
-- missing keys, use 'Nothing' for those fields and fall back to a minimal
-- 'OperatingSystem' when the file cannot be read.
detectMacOS :: IO OperatingSystem
detectMacOS = do
  mContent <- tryReadFile "/System/Library/CoreServices/SystemVersion.plist"
  case mContent of
    Nothing -> pure darwinFallbackOperatingSystem
    Just content ->
      let pName = lookupPlistString "ProductName" content
          pVersion = lookupPlistString "ProductVersion" content
          pBuild = lookupPlistString "ProductBuildVersion" content
          descr =
            case (pName, pVersion) of
              (Just n, Just v) -> Just (n <> " " <> v)
              (Just n, Nothing) -> Just n
              _ -> Nothing
       in pure $
            OperatingSystem
              { osType = "darwin"
              , osDescription = descr
              , osName = pName
              , osVersion = pVersion
              , osBuildId = pBuild
              }


darwinFallbackOperatingSystem :: OperatingSystem
darwinFallbackOperatingSystem =
  OperatingSystem
    { osType = T.pack os
    , osDescription = Nothing
    , osName = Nothing
    , osVersion = Nothing
    , osBuildId = Nothing
    }


lookupPlistString :: T.Text -> T.Text -> Maybe T.Text
lookupPlistString keyName content = go (T.lines content)
  where
    keyPat = "<key>" <> keyName <> "</key>"
    go [] = Nothing
    go (l : ls)
      | keyPat `T.isInfixOf` l =
          case ls of
            (next : _) -> parsePlistStringLine next
            [] -> Nothing
      | otherwise = go ls


parsePlistStringLine :: T.Text -> Maybe T.Text
parsePlistStringLine line =
  case T.stripPrefix "<string>" (T.strip line) of
    Nothing -> Nothing
    Just rest ->
      case T.breakOn "</string>" rest of
        (val, suff)
          | not (T.null suff) ->
              let v = T.strip val
               in if T.null v then Nothing else Just v
        _ -> Nothing

#endif


#ifndef darwin_HOST_OS
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
#endif


tryReadFile :: FilePath -> IO (Maybe T.Text)
tryReadFile path = do
  result <- tryIOError (T.readFile path)
  pure $ case result of
    Right content | not (T.null content) -> Just content
    _ -> Nothing
