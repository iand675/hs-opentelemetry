module OpenTelemetry.Resource.Cloud where
import Data.Text (Text)

data Cloud = Cloud
  { cloudProvider :: Maybe Text
  , cloudAccountId :: Maybe Text
  , cloudRegion :: Maybe Text
  , cloudAvailabilityZone :: Maybe Text
  , cloudPlatform :: Maybe Text
  }
