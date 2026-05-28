module OpenTelemetry.Resource.Process.Detector where

import qualified Data.Text as T
import qualified Data.Text.IO as T
import Data.Time.Clock (getCurrentTime)
import Data.Time.Format.ISO8601 (iso8601Show)
import Data.Version
import OpenTelemetry.Platform (tryGetParentProcessID, tryGetUser)
import OpenTelemetry.Resource.Process
import System.Directory (getCurrentDirectory)
import System.Environment (
  getArgs,
  getExecutablePath,
  getProgName,
 )
import System.IO (hIsTerminalDevice, stdin)
import System.IO.Error (tryIOError)
import System.Info
import System.PosixCompat.Process (getProcessID)


{- | Create a 'Process' 'Resource' based off of the current process' knowledge
 of itself.

 @since 0.1.0.0
-}
detectProcess :: IO Process
detectProcess = do
  progName <- getProgName
  args <- getArgs
  now <- getCurrentTime
  let allArgs = progName : args
  ppid <- tryGetParentProcessID
  cwd <- Just . T.pack <$> getCurrentDirectory
  interactive <- Just <$> hIsTerminalDevice stdin
  cgroup <- detectLinuxCgroup
  Process
    <$> (Just . fromIntegral <$> getProcessID)
    <*> pure (Just (T.pack progName))
    <*> (Just . T.pack <$> getExecutablePath)
    <*> pure (Just (T.pack progName))
    <*> pure Nothing
    <*> pure (Just (fmap T.pack allArgs))
    <*> tryGetUser
    <*> pure (Just (T.pack (iso8601Show now)))
    <*> pure (Just (length allArgs))
    <*> pure ppid
    <*> pure cwd
    <*> pure interactive
    <*> pure (Just (T.pack progName))
    <*> pure cgroup


detectLinuxCgroup :: IO (Maybe T.Text)
detectLinuxCgroup = do
  result <- tryIOError (T.readFile "/proc/self/cgroup")
  pure $ case result of
    Right content
      | not (T.null content) ->
          case T.lines content of
            (firstLine : _) -> Just (T.strip firstLine)
            _ -> Nothing
    _ -> Nothing


{- | A 'ProcessRuntime' 'Resource' populated with the current process' knoweldge
 of itself.

 @since 0.0.1.0
-}
detectProcessRuntime :: ProcessRuntime
detectProcessRuntime =
  ProcessRuntime
    { processRuntimeName = Just $ T.pack compilerName
    , processRuntimeVersion = Just $ T.pack $ showVersion compilerVersion
    , processRuntimeDescription =
        Just $ T.pack $ compilerName <> " " <> showVersion compilerVersion
    }
