-----------------------------------------------------------------------------
-- |
-- Module      :  OpenTelemetry.Resource.Cloud
-- Copyright   :  (c) Ian Duncan, 2021
-- License     :  BSD-3
--
-- Maintainer  :  Ian Duncan
-- Stability   :  experimental
-- Portability :  non-portable (GHC extensions)
--
-----------------------------------------------------------------------------
module OpenTelemetry.Resource.Cloud where
import Data.Text (Text)

data Cloud = Cloud
  { cloudProvider :: Maybe Text
  , cloudAccountId :: Maybe Text
  , cloudRegion :: Maybe Text
  , cloudAvailabilityZone :: Maybe Text
  , cloudPlatform :: Maybe Text
  }
