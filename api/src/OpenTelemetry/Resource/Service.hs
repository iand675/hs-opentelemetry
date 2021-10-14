{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}
module OpenTelemetry.Resource.Service where
import Data.Text
import OpenTelemetry.Resource
import System.Environment (lookupEnv, getProgName)
import qualified Data.Text as T

data Service = Service
  { serviceName :: Text
  , serviceNamespace :: Maybe Text
  , serviceInstanceId :: Maybe Text
  , serviceVersion :: Maybe Text
  }

instance ToResource Service where
  type ResourceSchema Service = Nothing
  toResource Service{..} = mkResource
    [ "service.name" .= serviceName
    , "service.namespace" .=? serviceNamespace
    , "service.instance.id" .=? serviceInstanceId
    , "service.version" .=? serviceVersion
    ]

getService :: IO Service
getService = do
  mSvcName <- lookupEnv "OTEL_SERVICE_NAME"
  svcName <- case mSvcName of
    Nothing -> T.pack . ("unknown_service:" <>) <$> getProgName
    Just svcName -> pure $ T.pack svcName
  pure $ Service
    { serviceName = svcName
    , serviceNamespace = Nothing
    , serviceInstanceId = Nothing
    , serviceVersion = Nothing
    }