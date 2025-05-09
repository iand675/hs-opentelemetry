module OpenTelemetry.Resource.Process.Detector where

import qualified Data.Text as T
import Data.Version
import OpenTelemetry.Platform (tryGetUser)
import OpenTelemetry.Resource.Process
import System.Environment (
  getArgs,
  getExecutablePath,
  getProgName,
 )
import System.Info
import System.PosixCompat.Process (getProcessID)


{- | Create a 'Process' 'Resource' based off of the current process' knowledge
 of itself.

 @since 0.1.0.0
-}
detectProcess :: IO Process
detectProcess = do
  Process
    <$> (Just . fromIntegral <$> getProcessID)
    <*> (Just . T.pack <$> getProgName)
    <*> (Just . T.pack <$> getExecutablePath)
    <*> pure Nothing
    <*> pure Nothing
    <*> (Just . map T.pack <$> getArgs)
    <*> tryGetUser


{- | A 'ProcessRuntime' 'Resource' populated with the current process' knoweldge
 of itself.

 @since 0.0.1.0
-}
detectProcessRuntime :: ProcessRuntime
detectProcessRuntime =
  ProcessRuntime
    { processRuntimeName = Just $ T.pack compilerName
    , processRuntimeVersion = Just $ T.pack $ showVersion compilerVersion
    , processRuntimeDescription = Nothing
    }
