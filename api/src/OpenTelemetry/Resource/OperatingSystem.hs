{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  OpenTelemetry.Resource.OperatingSystem
-- Copyright   :  (c) Ian Duncan, 2021
-- License     :  BSD-3
-- Description :  Information about the operating system (OS) on which the process represented by this resource is running.
-- Maintainer  :  Ian Duncan
-- Stability   :  experimental
-- Portability :  non-portable (GHC extensions)
--
-- In case of virtualized environments, this is the operating system as it is observed by the process, i.e., the virtualized guest rather than the underlying host.
--
-----------------------------------------------------------------------------
module OpenTelemetry.Resource.OperatingSystem where
import Data.Text (Text)
import qualified Data.Text as T
import System.Info ( os )
import OpenTelemetry.Resource

-- | The operating system (OS) on which the process represented by this resource is running.
data OperatingSystem = OperatingSystem
  { osType :: Text
  -- ^ The operating system type.
  --
  -- MUST be one of the following or, if none of the listed values apply, a custom value:
  --
  -- +-----------------+---------------------------------------+
  -- | Value           | Description                           |
  -- +=================+=======================================+
  -- | @windows@       | Microsoft Windows                     |
  -- +-----------------+---------------------------------------+
  -- | @linux@         | Linux                                 |
  -- +-----------------+---------------------------------------+
  -- | @darwin@        | Apple Darwin                          |
  -- +-----------------+---------------------------------------+
  -- | @freebsd@       | FreeBSD                               |
  -- +-----------------+---------------------------------------+
  -- | @netbsd@        | NetBSD                                |
  -- +-----------------+---------------------------------------+
  -- | @openbsd@       | OpenBSD                               |
  -- +-----------------+---------------------------------------+
  -- | @dragonflybsd@  | DragonFly BSD                         |
  -- +-----------------+---------------------------------------+
  -- | @hpux@          | HP-UX (Hewlett Packard Unix)          |
  -- +-----------------+---------------------------------------+
  -- | @aix@           | AIX (Advanced Interactive eXecutive)  |
  -- +-----------------+---------------------------------------+
  -- | @solaris@       | Oracle Solaris                        |
  -- +-----------------+---------------------------------------+
  -- | @z_os@          | IBM z/OS                              |
  -- +-----------------+---------------------------------------+

  , osDescription :: Maybe Text
  -- ^ Human readable (not intended to be parsed) OS version information, like e.g. reported by @ver@ or @lsb_release -a@ commands.
  , osName :: Maybe Text
  -- ^ Human readable operating system name.
  , osVersion :: Maybe Text
  -- ^ The version string of the operating system as defined in
  }

-- | Retrieve any infomration able to be detected about the current operation system.
--
-- Currently only supports 'osType' detection, but PRs are welcome to support additional
-- details.
--
-- @since 0.0.1.0
getOperatingSystem :: IO OperatingSystem 
getOperatingSystem = pure $ OperatingSystem
  { osType = if os == "mingw32"
      then "windows"
      else T.pack os
  , osDescription = Nothing
  , osName = Nothing
  , osVersion = Nothing
  }

instance ToResource OperatingSystem where
  type ResourceSchema OperatingSystem = 'Nothing
  -- TODO ^ schema
  toResource OperatingSystem{..} = mkResource
    [ "os.type" .= osType
    , "os.description" .=? osDescription
    , "os.name" .=? osName
    , "os.version" .=? osVersion
    ]