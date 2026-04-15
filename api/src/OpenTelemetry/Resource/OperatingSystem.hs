{- |
 Module      :  OpenTelemetry.Resource.OperatingSystem
 Copyright   :  (c) Ian Duncan, 2021
 License     :  BSD-3
 Description :  Information about the operating system (OS) on which the process represented by this resource is running.
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)

 In case of virtualized environments, this is the operating system as it is observed by the process, i.e., the virtualized guest rather than the underlying host.
-}
module OpenTelemetry.Resource.OperatingSystem where

import Data.Text (Text)
import OpenTelemetry.Attributes.Key (unkey)
import OpenTelemetry.Resource
import qualified OpenTelemetry.SemanticConventions as SC


{- | The operating system (OS) on which the process represented by this resource is running.

@since 0.0.1.0
-}
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
  , osBuildId :: Maybe Text
  -- ^ Unique identifier for a particular build or compilation of the operating system.
  }


instance ToResource OperatingSystem where
  toResource OperatingSystem {..} =
    mkResourceWithSchema
      (Just semConvSchemaUrl)
      [ unkey SC.os_type .= osType
      , unkey SC.os_description .=? osDescription
      , unkey SC.os_name .=? osName
      , unkey SC.os_version .=? osVersion
      , unkey SC.os_buildId .=? osBuildId
      ]
