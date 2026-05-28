{- |
 Module      :  OpenTelemetry.Resource.FaaS
 Copyright   :  (c) Ian Duncan, 2026
 License     :  BSD-3
 Description :  Resource information about a "function as a service" aka "serverless function" instance
 Maintainer  :  Ian Duncan
 Stability   :  experimental
 Portability :  non-portable (GHC extensions)
-}
module OpenTelemetry.Resource.FaaS where

import Data.Text (Text)
import OpenTelemetry.Attributes.Key (unkey)
import OpenTelemetry.Resource
import qualified OpenTelemetry.SemanticConventions as SC


{- | A "function as a service" aka "serverless function" instance.

@since 0.0.1.0
-}
data FaaS = FaaS
  { faasName :: Text
  {- ^ The name of the single function that this runtime instance executes.

  This is the name of the function as configured/deployed on the FaaS platform and is usually different from the name of the callback function (which may be stored in the code.namespace/code.function span attributes).

  Examples: 'my-function'
  -}
  , faasCloudResourceId :: Maybe Text
  {- ^ The cloud resource ID (@cloud.resource_id@) of the function.

  Depending on the cloud provider, use:

  - AWS Lambda: The function ARN.
  - GCP: The URI of the resource
  - Azure: The Fully Qualified Resource ID.

  Examples: 'arn:aws:lambda:us-west-2:123456789012:function:my-function'
  -}
  , faasVersion :: Maybe Text
  {- ^ The immutable version of the function being executed.

  Depending on the cloud provider and platform, use:

  - AWS Lambda: The function version (an integer represented as a decimal string).
  - Google Cloud Run: The revision (i.e., the function name plus the revision suffix).
  - Google Cloud Functions: The value of the K_REVISION environment variable.
  - Azure Functions: Not applicable. Do not set this attribute.

  Examples: '26', 'pinkfroid-00002'
  -}
  , faasInstance :: Maybe Text
  {- ^ The execution environment ID as a string, that will be potentially reused for other invocations to the same function/function version.

  AWS Lambda: Use the (full) log stream name.

  Examples: '2021/06/28/[$LATEST]2f399eb14537447da05ab2a2e39309de'
  -}
  , faasMaxMemory :: Maybe Int
  {- ^ The amount of memory available to the serverless function converted to bytes.

  It's recommended to set this attribute since e.g. too little memory can easily stop a Java AWS Lambda function from working correctly. On AWS Lambda, the environment variable AWS_LAMBDA_FUNCTION_MEMORY_SIZE provides this information (which must be multiplied by 1,048,576).

  Examples: '134217728'
  -}
  }
  deriving (Show)


instance ToResource FaaS where
  toResource FaaS {..} =
    mkResourceWithSchema
      (Just semConvSchemaUrl)
      [ unkey SC.faas_name .= faasName
      , unkey SC.cloud_resourceId .=? faasCloudResourceId
      , unkey SC.faas_version .=? faasVersion
      , unkey SC.faas_instance .=? faasInstance
      , unkey SC.faas_maxMemory .=? faasMaxMemory
      ]
