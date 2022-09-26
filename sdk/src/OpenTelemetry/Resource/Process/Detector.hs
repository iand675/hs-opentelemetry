module OpenTelemetry.Resource.Process.Detector where

import Control.Exception (throwIO, try)
import qualified Data.Text as T
import Data.Version
import OpenTelemetry.Resource.Process
import System.Environment (
  getArgs,
  getExecutablePath,
  getProgName,
 )
import System.IO.Error
import System.Info
import System.Posix.Process (getProcessID)
import System.Posix.User (getEffectiveUserName)


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


tryGetUser :: IO (Maybe T.Text)
tryGetUser = do
  eResult <- try getEffectiveUserName
  case eResult of
    Left err ->
      if isDoesNotExistError err
        then pure Nothing
        else throwIO err
    Right ok -> pure $ Just $ T.pack ok


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
