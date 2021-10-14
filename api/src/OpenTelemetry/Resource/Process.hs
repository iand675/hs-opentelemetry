{-# LANGUAGE  CPP #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}
module OpenTelemetry.Resource.Process where
import Data.Text (Text)
import qualified Data.Text as T
import System.Environment
    ( getArgs, getProgName, getExecutablePath )
import System.Posix.Process ( getProcessID )
import System.Posix.User (getEffectiveUserName)
import System.Info
import Data.Version
import OpenTelemetry.Resource

data Process = Process
  { processPid :: Maybe Int
  , processExecutableName :: Maybe Text
  , processExecutablePath :: Maybe Text
  , processCommand :: Maybe Text
  , processCommandLine :: Maybe Text
  , processCommandArgs :: Maybe [Text]
  , processOwner :: Maybe Text
  }

instance ToResource Process where
  type ResourceSchema Process = Nothing
  toResource Process{..} = mkResource
    [ "process.pid" .=? processPid
    , "process.executable.name" .=? processExecutableName
    , "process.executable.path" .=? processExecutablePath
    , "process.command" .=? processCommand
    , "process.command_line" .=? processCommandLine
    , "process.command_args" .=? processCommandArgs
    , "process.owner" .=? processOwner
    ]

data ProcessRuntime = ProcessRuntime
  { processRuntimeName :: Maybe Text
  , processRuntimeVersion :: Maybe Text
  , processRuntimeDescription :: Maybe Text
  }

instance ToResource ProcessRuntime where
  type ResourceSchema ProcessRuntime = Nothing
  toResource ProcessRuntime{..} = mkResource
    [ "process.runtime.name" .=? processRuntimeName
    , "process.runtime.version" .=? processRuntimeVersion
    , "process.runtime.description" .=? processRuntimeDescription
    ]

getProcess :: IO Process
getProcess = do
  Process <$>
    (Just . fromIntegral <$> getProcessID) <*>
    (Just . T.pack <$> getProgName) <*>
    (Just . T.pack <$> getExecutablePath) <*>
    pure Nothing <*>
    pure Nothing <*>
    (Just . map T.pack <$> getArgs) <*>
    (Just . T.pack <$> getEffectiveUserName)

currentProcessRuntime :: ProcessRuntime
currentProcessRuntime = ProcessRuntime
  { processRuntimeName = Just $ T.pack compilerName
  , processRuntimeVersion = Just $ T.pack $ showVersion compilerVersion
  , processRuntimeDescription = Nothing
  }
