module OpenTelemetry.Resource.Service.Detector where

import qualified Data.Text as T
import OpenTelemetry.Resource.Service
import System.Environment (getProgName, lookupEnv)


{- | Detect a service name using the 'OTEL_SERVICE_NAME' environment
 variable. Otherwise, populates the name with 'unknown_service:process_name'.
-}
detectService :: IO Service
detectService = do
  mSvcName <- lookupEnv "OTEL_SERVICE_NAME"
  svcName <- case mSvcName of
    Nothing -> T.pack . ("unknown_service:" <>) <$> getProgName
    Just svcName -> pure $ T.pack svcName
  pure $
    Service
      { serviceName = svcName
      , serviceNamespace = Nothing
      , serviceInstanceId = Nothing
      , serviceVersion = Nothing
      }
