{-# LANGUAGE CPP #-}

{- |
 Module      :  OpenTelemetry.Resource.Process
 Copyright   :  (c) Ian Duncan, 2021
 License     :  BSD-3
 Description :  Standard resources and detectors for system processes
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)
-}
module OpenTelemetry.Resource.Process where

import Data.Text (Text)
import OpenTelemetry.Attributes.Key (unkey)
import OpenTelemetry.Resource
import qualified OpenTelemetry.SemanticConventions as SC


{- |  An operating system process.

@since 0.0.1.0
-}
data Process = Process
  { processPid :: Maybe Int
  -- ^ Process identifier (PID).
  --
  -- Example: @1234@
  , processExecutableName :: Maybe Text
  -- ^ The name of the process executable. On Linux based systems, can be set to the @Name@ in @proc/[pid]/status@. On Windows, can be set to the base name of @GetProcessImageFileNameW@.
  --
  -- Example: @otelcol@
  , processExecutablePath :: Maybe Text
  -- ^ The full path to the process executable. On Linux based systems, can be set to the target of @proc/[pid]/exe@. On Windows, can be set to the result of @GetProcessImageFileNameW@.
  --
  -- Example: @/usr/bin/cmd/otelcol@
  , processCommand :: Maybe Text
  -- ^ The command used to launch the process (i.e. the command name). On Linux based systems, can be set to the zeroth string in @proc/[pid]/cmdline@. On Windows, can be set to the first parameter extracted from @GetCommandLineW@.
  --
  -- Example: @cmd/otelcol@
  , processCommandLine :: Maybe Text
  -- ^ The full command used to launch the process as a single string representing the full command. On Windows, can be set to the result of @GetCommandLineW@. Do not set this if you have to assemble it just for monitoring; use @process.command_args@ instead.
  --
  -- Example: @C:\cmd\otecol --config="my directory\config.yaml"@
  , processCommandArgs :: Maybe [Text]
  -- ^ All the command arguments (including the command/executable itself) as received by the process. On Linux-based systems (and some other Unixoid systems supporting procfs), can be set according to the list of null-delimited strings extracted from @proc/[pid]/cmdline@. For libc-based executables, this would be the full argv vector passed to main.
  --
  -- Example: @[cmd/otecol, --config=config.yaml]@
  , processOwner :: Maybe Text
  -- ^ The username of the user that owns the process.
  --
  -- Example: @root@
  }


instance ToResource Process where
  toResource Process {..} =
    mkResourceWithSchema
      (Just semConvSchemaUrl)
      [ unkey SC.process_pid .=? processPid
      , unkey SC.process_executable_name .=? processExecutableName
      , unkey SC.process_executable_path .=? processExecutablePath
      , unkey SC.process_command .=? processCommand
      , unkey SC.process_commandLine .=? processCommandLine
      , unkey SC.process_commandArgs .=? processCommandArgs
      , unkey SC.process_owner .=? processOwner
      ]


{- | The single (language) runtime instance which is monitored.

@since 0.0.1.0
-}
data ProcessRuntime = ProcessRuntime
  { processRuntimeName :: Maybe Text
  -- ^ The name of the runtime of this process. For compiled native binaries, this SHOULD be the name of the compiler.
  --
  -- Example: @OpenJDK Runtime Environment@
  , processRuntimeVersion :: Maybe Text
  -- ^ The version of the runtime of this process, as returned by the runtime without modification.
  --
  -- Example: @14.0.2@
  , processRuntimeDescription :: Maybe Text
  -- ^ An additional description about the runtime of the process, for example a specific vendor customization of the runtime environment.
  --
  -- Example: @Eclipse OpenJ9 Eclipse OpenJ9 VM openj9-0.21.0@
  }


instance ToResource ProcessRuntime where
  toResource ProcessRuntime {..} =
    mkResourceWithSchema
      (Just semConvSchemaUrl)
      [ unkey SC.process_runtime_name .=? processRuntimeName
      , unkey SC.process_runtime_version .=? processRuntimeVersion
      , unkey SC.process_runtime_description .=? processRuntimeDescription
      ]
