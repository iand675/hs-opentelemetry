module OpenTelemetry.Resource.FaaS where
import Data.Text (Text)

data FaaS = FaaS
  { faasName :: Text
  , faasId :: Maybe Text
  , faasVersion :: Maybe Text
  , faasInstance :: Maybe Text
  , faasMaxMemory :: Maybe Int
  }