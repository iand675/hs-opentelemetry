{-# LANGUAGE CPP #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TypeApplications #-}

-- |
-- Module      : OpenTelemetry.Resource.Host.Detector
-- Description : Resource detector for host attributes. Auto-detects hostname and architecture from the runtime environment.
-- Stability   : experimental
--
module OpenTelemetry.Resource.Host.Detector (
  detectHost,
  builtInHostDetectors,
  HostDetector,
) where

import Control.Exception (SomeException, try)
import Control.Monad
import qualified Data.Text as T
import Network.BSD
import OpenTelemetry.Resource.Host
import System.Info (arch)

#if defined(linux_HOST_OS)
import qualified Data.Text.IO as TIO
#elif defined(darwin_HOST_OS)
import System.Process (readProcess)
#endif

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


#if defined(darwin_HOST_OS)
-- | Parse @\"IOPlatformUUID\" = \"…\"@ from @ioreg@ output (see OpenTelemetry host.id for macOS).
parseIOPlatformUUID :: T.Text -> Maybe T.Text
parseIOPlatformUUID txt = do
  line <- findIOPlatformUUIDLine txt
  parseUUIDFromLine line

findIOPlatformUUIDLine :: T.Text -> Maybe T.Text
findIOPlatformUUIDLine t = go (T.lines t)
  where
    go [] = Nothing
    go (l : ls) =
      if "IOPlatformUUID" `T.isInfixOf` l
        then Just l
        else go ls

parseUUIDFromLine :: T.Text -> Maybe T.Text
parseUUIDFromLine line = do
  let (_, rest) = T.breakOn "\" = \"" line
  guard $ not (T.null rest)
  let afterEq = T.drop (T.length "\" = \"") rest
  let (uuid, _) = T.breakOn "\"" afterEq
  guard $ not (T.null uuid)
  Just uuid
#endif


-- | Best-effort @host.id@: @\/etc\/machine-id@ on Linux, @ioreg@ @IOPlatformUUID@ on Darwin; @Nothing@ elsewhere or on failure.
detectHostId :: IO (Maybe T.Text)
#if defined(linux_HOST_OS)
detectHostId = do
  er <-
    try @SomeException $
      do
        content <- TIO.readFile "/etc/machine-id"
        let tid = T.strip content
        pure $ if T.null tid then Nothing else Just tid
  pure $ either (const Nothing) id er
#elif defined(darwin_HOST_OS)
detectHostId = do
  er <-
    try @SomeException $
      do
        out <- readProcess "ioreg" ["-rd1", "-c", "IOPlatformExpertDevice"] ""
        pure $ parseIOPlatformUUID (T.pack out)
  pure $ either (const Nothing) id er
#else
detectHostId = pure Nothing
#endif


-- | Detect as much host information as possible
detectHost :: IO Host
detectHost = do
  mhost <- foldM go Nothing builtInHostDetectors
  pure $ case mhost of
    Nothing -> Host Nothing Nothing Nothing Nothing Nothing Nothing Nothing Nothing Nothing
    Just host -> host
  where
    go Nothing hostDetector = hostDetector
    go mhost@(Just _host) _ = pure mhost


{- | Built-in host detectors.

Cloud-specific host attributes (@host.type@, @host.image.id@, etc.) may be
refined by IMDS resource detectors (AWS EC2, GCP Compute, Azure VM). This
detector supplies @host.name@, @host.arch@, and on Linux\/macOS a non-cloud
@host.id@ when available.
-}
builtInHostDetectors :: [HostDetector]
builtInHostDetectors =
  [fallbackHostDetector]


type HostDetector = IO (Maybe Host)


fallbackHostDetector :: HostDetector
fallbackHostDetector =
  Just <$> do
    hostId <- detectHostId
    let hostType = Nothing
        hostArch = Just adaptedArch
        hostImageName = Nothing
        hostImageId = Nothing
        hostImageVersion = Nothing
        hostIp = Nothing
        hostMac = Nothing
    hostName <- Just . T.pack <$> getHostName
    pure Host {..}
