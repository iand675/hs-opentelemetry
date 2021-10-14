module OpenTelemetry.Resource.DeploymentEnvironment where
import Data.Text (Text)

newtype DeploymentEnvironment = DeploymentEnvironment
  { deploymentEnvironment :: Maybe Text
  }