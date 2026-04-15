module OpenTelemetry.Resource.Service.Detector where

import qualified Data.Text as T
import OpenTelemetry.Resource.Service
import System.Environment (getProgName, lookupEnv)


{- | Detect a service name using the 'OTEL_SERVICE_NAME' environment
 variable. Otherwise, populates the name with 'unknown_service:process_name'.

 @service.instance.id@ is NOT auto-generated. The attribute is still
 experimental in semantic conventions, and no major SDK (Java, Go, Python)
 enables auto-generation by default — Java moved it to an opt-in incubator
 package, Go gates it behind a feature flag, and Python hasn\'t merged it at
 all. A random UUID per init also inflates metric cardinality and breaks
 cross-restart correlation. Users who want it can set it explicitly via
 resource attributes or environment configuration.
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
      , serviceCriticality = Nothing
      }
