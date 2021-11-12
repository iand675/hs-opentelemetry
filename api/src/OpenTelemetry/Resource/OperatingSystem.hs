{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}
module OpenTelemetry.Resource.OperatingSystem where
import Data.Text (Text)
import qualified Data.Text as T
import System.Info ( os )
import OpenTelemetry.Resource

{-
os.type MUST be one of the following or, if none of the listed values apply, a custom value:

Value	Description
windows	Microsoft Windows
linux	Linux
darwin	Apple Darwin
freebsd	FreeBSD
netbsd	NetBSD
openbsd	OpenBSD
dragonflybsd	DragonFly BSD
hpux	HP-UX (Hewlett Packard Unix)
aix	AIX (Advanced Interactive eXecutive)
solaris	Oracle Solaris
z_os	IBM z/OS
-}
data OperatingSystem = OperatingSystem
  { osType :: Text
  , osDescription :: Maybe Text
  , osName :: Maybe Text
  , osVersion :: Maybe Text
  }

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