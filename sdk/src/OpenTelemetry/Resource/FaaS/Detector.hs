{-# LANGUAGE OverloadedStrings #-}

{- |
Module      :  OpenTelemetry.Resource.FaaS.Detector
Copyright   :  (c) Ian Duncan, 2024
License     :  BSD-3
Description :  Auto-detect FaaS (serverless function) resource attributes
Maintainer  :  Ian Duncan
Stability   :  experimental
Portability :  non-portable (GHC extensions)

Detects FaaS resource attributes from environment variables set by
serverless platforms:

* __AWS Lambda__: @AWS_LAMBDA_FUNCTION_NAME@, @AWS_LAMBDA_FUNCTION_VERSION@,
  @AWS_LAMBDA_LOG_STREAM_NAME@, @AWS_LAMBDA_FUNCTION_MEMORY_SIZE@
* __GCP Cloud Functions__: @FUNCTION_TARGET@, @K_REVISION@, @FUNCTION_MEMORY_MB@
* __Azure Functions__: @FUNCTIONS_WORKER_RUNTIME@, @WEBSITE_SITE_NAME@

Returns 'Nothing' when not running in a recognized FaaS environment.

@since 0.1.0.2
-}
module OpenTelemetry.Resource.FaaS.Detector (
  detectFaaS,
) where

import qualified Data.Text as T
import OpenTelemetry.Resource.FaaS (FaaS (..))
import System.Environment (lookupEnv)
import Text.Read (readMaybe)


detectFaaS :: IO (Maybe FaaS)
detectFaaS = do
  mLambda <- detectLambda
  case mLambda of
    Just faas -> pure (Just faas)
    Nothing -> do
      mGcf <- detectGCF
      case mGcf of
        Just faas -> pure (Just faas)
        Nothing -> detectAzureFunctions


detectLambda :: IO (Maybe FaaS)
detectLambda = do
  mName <- lookupEnvText "AWS_LAMBDA_FUNCTION_NAME"
  case mName of
    Nothing -> pure Nothing
    Just name -> do
      mVersion <- lookupEnvText "AWS_LAMBDA_FUNCTION_VERSION"
      mLogStream <- lookupEnvText "AWS_LAMBDA_LOG_STREAM_NAME"
      mMemStr <- lookupEnv "AWS_LAMBDA_FUNCTION_MEMORY_SIZE"
      let mMem = mMemStr >>= readMaybe
      mRegion <- lookupEnvText "AWS_REGION"
      mAcctAndFn <- buildLambdaArn name mRegion
      pure $
        Just
          FaaS
            { faasName = name
            , faasId = mAcctAndFn
            , faasVersion = mVersion
            , faasInstance = mLogStream
            , faasMaxMemory = mMem
            }
  where
    buildLambdaArn name mRegion = do
      mAcct <- lookupEnvText "AWS_ACCOUNT_ID"
      pure $ do
        region <- mRegion
        acct <- mAcct
        Just $ "arn:aws:lambda:" <> region <> ":" <> acct <> ":function:" <> name


-- Google Cloud Functions
detectGCF :: IO (Maybe FaaS)
detectGCF = do
  mTarget <- lookupEnvText "FUNCTION_TARGET"
  case mTarget of
    Nothing -> pure Nothing
    Just target -> do
      mRevision <- lookupEnvText "K_REVISION"
      mMemStr <- lookupEnv "FUNCTION_MEMORY_MB"
      let mMem = mMemStr >>= readMaybe
      pure $
        Just
          FaaS
            { faasName = target
            , faasId = Nothing
            , faasVersion = mRevision
            , faasInstance = Nothing
            , faasMaxMemory = mMem
            }


detectAzureFunctions :: IO (Maybe FaaS)
detectAzureFunctions = do
  mRuntime <- lookupEnvText "FUNCTIONS_WORKER_RUNTIME"
  case mRuntime of
    Nothing -> pure Nothing
    Just _ -> do
      mName <- lookupEnvText "WEBSITE_SITE_NAME"
      case mName of
        Nothing -> pure Nothing
        Just name ->
          pure $
            Just
              FaaS
                { faasName = name
                , faasId = Nothing
                , faasVersion = Nothing
                , faasInstance = Nothing
                , faasMaxMemory = Nothing
                }


lookupEnvText :: String -> IO (Maybe T.Text)
lookupEnvText key = fmap (T.pack <$>) (lookupEnv key)
