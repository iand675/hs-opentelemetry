{-# LANGUAGE OverloadedStrings #-}

{- |
Module      :  OpenTelemetry.Resource.Container.Detector
Copyright   :  (c) Ian Duncan, 2024
License     :  BSD-3
Description :  Auto-detect container resource attributes
Maintainer  :  Ian Duncan
Stability   :  experimental
Portability :  non-portable (GHC extensions)

Detects whether the process is running inside a container and extracts
the container ID and runtime. Works on Linux via the @\/proc@ filesystem;
returns an empty 'Container' on other platforms.

Container ID extraction supports both cgroup v1 and cgroup v2.

@since 0.1.0.2
-}
module OpenTelemetry.Resource.Container.Detector (
  detectContainer,
) where

import Data.Maybe (listToMaybe, mapMaybe)
import qualified Data.Text as T
import qualified Data.Text.IO as T
import OpenTelemetry.Resource.Container (Container (..))
import System.IO.Error (tryIOError)


-- | @since 0.0.1.0
detectContainer :: IO Container
detectContainer = do
  cid <- detectContainerId
  rt <- detectRuntime
  pure
    Container
      { containerName = Nothing
      , containerId = cid
      , containerRuntime = rt
      , containerImageName = Nothing
      , containerImageTag = Nothing
      , containerImageId = Nothing
      }


detectContainerId :: IO (Maybe T.Text)
detectContainerId = do
  v1 <- tryReadFile "/proc/self/cgroup"
  case v1 >>= parseCgroupV1Id of
    Just cid -> pure (Just cid)
    Nothing -> do
      mi <- tryReadFile "/proc/self/mountinfo"
      pure (mi >>= parseMountInfoId)


parseCgroupV1Id :: T.Text -> Maybe T.Text
parseCgroupV1Id contents =
  listToMaybe $ mapMaybe extractFromLine (T.lines contents)
  where
    extractFromLine line =
      case T.splitOn ":" line of
        [_, _, path] -> extractIdFromPath path
        _ -> Nothing

    extractIdFromPath path
      | T.null path = Nothing
      | path == "/" = Nothing
      | otherwise =
          let seg = T.takeWhileEnd (/= '/') path
          in if isHexId seg then Just seg else Nothing


parseMountInfoId :: T.Text -> Maybe T.Text
parseMountInfoId contents =
  listToMaybe $ mapMaybe extractFromLine (T.lines contents)
  where
    extractFromLine line =
      let parts = T.words line
      in case filter containsContainerId parts of
           (p : _) -> extractLastHexSegment p
           [] -> Nothing

    containsContainerId part =
      T.isInfixOf "/docker/containers/" part
        || T.isInfixOf "/containerd/" part
        || T.isInfixOf "/cri-o/" part
        || T.isInfixOf "/pods/" part

    extractLastHexSegment path =
      let seg = T.takeWhileEnd (/= '/') path
      in if isHexId seg then Just seg else Nothing


isHexId :: T.Text -> Bool
isHexId t =
  T.length t >= 12 && T.all isHexChar t
  where
    isHexChar c = (c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')


detectRuntime :: IO (Maybe T.Text)
detectRuntime = do
  dockerEnv <- tryReadFile "/.dockerenv"
  containerEnv <- tryReadFile "/run/.containerenv"
  cgroupContent <- tryReadFile "/proc/self/cgroup"
  pure $ case (dockerEnv, containerEnv, cgroupContent) of
    (Just _, _, _) -> Just "docker"
    (_, Just _, _) -> Just "podman"
    (_, _, Just cg)
      | T.isInfixOf "containerd" cg -> Just "containerd"
      | T.isInfixOf "cri-o" cg -> Just "cri-o"
      | T.isInfixOf "/docker/" cg -> Just "docker"
      | T.isInfixOf "/lxc/" cg -> Just "lxc"
    _ -> Nothing


tryReadFile :: FilePath -> IO (Maybe T.Text)
tryReadFile path = do
  result <- tryIOError (T.readFile path)
  pure $ case result of
    Right content | not (T.null content) -> Just content
    _ -> Nothing
