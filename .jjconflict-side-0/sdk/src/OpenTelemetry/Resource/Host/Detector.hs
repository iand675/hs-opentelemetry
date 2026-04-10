{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

module OpenTelemetry.Resource.Host.Detector (
  detectHost,
  builtInHostDetectors,
  HostDetector,
) where

import Control.Monad
import qualified Data.Text as T
import Network.BSD
import OpenTelemetry.Resource.Host
import System.Info (arch)


adaptedArch :: T.Text
adaptedArch = case arch of
  "aarch64" -> "arm64"
  "arm" -> "arm32"
  "x86_64" -> "amd64"
  "i386" -> "x86"
  "ia64" -> "ia64"
  "powerpc" -> "ppc32"
  "powerpc64" -> "ppc64"
  "powerpc64le" -> "ppc64"
  other -> T.pack other


-- | Detect as much host information as possible
detectHost :: IO Host
detectHost = do
  mhost <- foldM go Nothing builtInHostDetectors
  pure $ case mhost of
    Nothing -> Host Nothing Nothing Nothing Nothing Nothing Nothing Nothing
    Just host -> host
  where
    go Nothing hostDetector = hostDetector
    go mhost@(Just _host) _ = pure mhost


{- | A set of detectors for e.g. AWS, GCP, and other cloud providers.

 Currently only emits hostName and hostArch. Additional detectors are
 welcome via PR.
-}
builtInHostDetectors :: [HostDetector]
builtInHostDetectors =
  [ -- TODO
    -- AWS support
    -- GCP support
    -- any other user contributed
    fallbackHostDetector
  ]


type HostDetector = IO (Maybe Host)


fallbackHostDetector :: HostDetector
fallbackHostDetector =
  Just <$> do
    let hostId = Nothing
        hostType = Nothing
        hostArch = Just adaptedArch
        hostImageName = Nothing
        hostImageId = Nothing
        hostImageVersion = Nothing
    hostName <- Just . T.pack <$> getHostName
    pure Host {..}
