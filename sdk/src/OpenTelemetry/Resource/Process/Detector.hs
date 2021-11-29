module OpenTelemetry.Resource.Process.Detector where

import qualified Data.Text as T
import System.Environment
    ( getArgs, getProgName, getExecutablePath )
import System.Posix.Process ( getProcessID )
import System.Posix.User (getEffectiveUserName)
import System.Info
import Data.Version
import OpenTelemetry.Resource.Process

-- | Create a 'Process' 'Resource' based off of the current process' knowledge
-- of itself.
--
-- @since 0.1.0.0
detectProcess :: IO Process
detectProcess = do
  Process <$>
    (Just . fromIntegral <$> getProcessID) <*>
    (Just . T.pack <$> getProgName) <*>
    (Just . T.pack <$> getExecutablePath) <*>
    pure Nothing <*>
    pure Nothing <*>
    (Just . map T.pack <$> getArgs) <*>
    (Just . T.pack <$> getEffectiveUserName)

-- | A 'ProcessRuntime' 'Resource' populated with the current process' knoweldge
-- of itself.
--
-- @since 0.0.1.0
detectProcessRuntime :: ProcessRuntime
detectProcessRuntime = ProcessRuntime
  { processRuntimeName = Just $ T.pack compilerName
  , processRuntimeVersion = Just $ T.pack $ showVersion compilerVersion
  , processRuntimeDescription = Nothing
  }