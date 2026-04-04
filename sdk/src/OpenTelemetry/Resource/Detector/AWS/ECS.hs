{-# LANGUAGE OverloadedStrings #-}

{- |
Module      :  OpenTelemetry.Resource.Detector.AWS.ECS
Copyright   :  (c) Ian Duncan, 2024
License     :  BSD-3
Description :  Detect ECS task and container resource attributes
Maintainer  :  Ian Duncan
Stability   :  experimental

Queries the ECS container metadata endpoint (v4) to populate resource
attributes for services running on Amazon ECS (both EC2 and Fargate
launch types).

Returns an empty 'Resource' if @ECS_CONTAINER_METADATA_URI_V4@ is not set.

Populates: @cloud.provider@, @cloud.platform@, @cloud.region@,
@cloud.account_id@, @cloud.availability_zone@, @aws.ecs.task.arn@,
@aws.ecs.task.family@, @aws.ecs.task.revision@, @aws.ecs.cluster.arn@,
@aws.ecs.launchtype@, @container.id@, @container.name@,
@aws.ecs.container.arn@, @aws.log.group.names@, @aws.log.stream.names@.

@since 0.1.0.2
-}
module OpenTelemetry.Resource.Detector.AWS.ECS (
  detectECS,
  detectECSSelf,
) where

import Data.Aeson (FromJSON (..), withObject, (.:), (.:?))
import Data.Text (Text)
import qualified Data.Text as T
import OpenTelemetry.Attributes (Attribute)
import OpenTelemetry.Resource (Resource, mkResource, (.=), (.=?))
import OpenTelemetry.Resource.Detector.Metadata
import System.Environment (lookupEnv)


{- | Self-contained ECS detector suitable for the resource detector registry.
Creates its own 'MetadataClient'. Returns an empty resource if
@ECS_CONTAINER_METADATA_URI_V4@ is not set.
-}
detectECSSelf :: IO Resource
detectECSSelf = do
  client <- newMetadataClient
  detectECS client


{- | Detect ECS task metadata from the container metadata endpoint.
Returns an empty resource if not running on ECS.
-}
detectECS :: MetadataClient -> IO Resource
detectECS client = do
  mUri <- lookupEnv "ECS_CONTAINER_METADATA_URI_V4"
  case mUri of
    Nothing -> pure $ mkResource []
    Just uri -> do
      mTask <- fetchJSON client (uri ++ "/task") :: IO (Maybe TaskMetadata)
      mContainer <- fetchJSON client uri :: IO (Maybe ContainerMetadata)
      case mTask of
        Nothing -> pure $ mkResource []
        Just task -> do
          let arnParts = T.splitOn ":" (taskArn task)
              mRegion = safeIndex arnParts 3
              mAcctId = safeIndex arnParts 4
              cluster = normalizeArn (taskCluster task) arnParts "cluster"
              mAz = taskAvailabilityZone task
              launchType = T.toLower <$> taskLaunchType task

              containerAttrs :: [Maybe (Text, Attribute)]
              containerAttrs = case mContainer of
                Nothing -> []
                Just c ->
                  [ "container.name" .= containerName c
                  , "container.id" .=? containerDockerId c
                  , "aws.ecs.container.arn" .=? containerArn c
                  ]
                    ++ logAttrs c

          pure $
            mkResource $
              [ "cloud.provider" .= ("aws" :: Text)
              , "cloud.platform" .= ("aws_ecs" :: Text)
              , "cloud.region" .=? mRegion
              , "cloud.account.id" .=? mAcctId
              , "cloud.availability_zone" .=? mAz
              , "aws.ecs.task.arn" .= taskArn task
              , "aws.ecs.task.family" .= taskFamily task
              , "aws.ecs.task.revision" .= taskRevision task
              , "aws.ecs.cluster.arn" .= cluster
              , "aws.ecs.launchtype" .=? launchType
              ]
                ++ containerAttrs


logAttrs :: ContainerMetadata -> [Maybe (Text, Attribute)]
logAttrs c = case containerLogDriver c of
  Just "awslogs" -> case containerLogOptions c of
    Just opts ->
      [ "aws.log.group.names" .=? logGroup opts
      , "aws.log.stream.names" .=? logStream opts
      ]
    Nothing -> []
  _ -> []


-- JSON types for ECS metadata endpoint responses

data TaskMetadata = TaskMetadata
  { taskArn :: !Text
  , taskFamily :: !Text
  , taskRevision :: !Text
  , taskCluster :: !Text
  , taskAvailabilityZone :: !(Maybe Text)
  , taskLaunchType :: !(Maybe Text)
  }


instance FromJSON TaskMetadata where
  parseJSON = withObject "TaskMetadata" $ \o ->
    TaskMetadata
      <$> o .: "TaskARN"
      <*> o .: "Family"
      <*> o .: "Revision"
      <*> o .: "Cluster"
      <*> o .:? "AvailabilityZone"
      <*> o .:? "LaunchType"


data ContainerMetadata = ContainerMetadata
  { containerDockerId :: !(Maybe Text)
  , containerName :: !Text
  , containerArn :: !(Maybe Text)
  , containerLogDriver :: !(Maybe Text)
  , containerLogOptions :: !(Maybe LogOptions)
  }


instance FromJSON ContainerMetadata where
  parseJSON = withObject "ContainerMetadata" $ \o ->
    ContainerMetadata
      <$> o .:? "DockerId"
      <*> o .: "Name"
      <*> o .:? "ContainerARN"
      <*> o .:? "LogDriver"
      <*> o .:? "LogOptions"


data LogOptions = LogOptions
  { logGroup :: !(Maybe Text)
  , logStream :: !(Maybe Text)
  , _logRegion :: !(Maybe Text)
  }


instance FromJSON LogOptions where
  parseJSON = withObject "LogOptions" $ \o ->
    LogOptions
      <$> o .:? "awslogs-group"
      <*> o .:? "awslogs-stream"
      <*> o .:? "awslogs-region"


normalizeArn :: Text -> [Text] -> Text -> Text
normalizeArn val arnParts suffix
  | "arn:" `T.isPrefixOf` val = val
  | length arnParts >= 5 =
      let base = T.intercalate ":" (take 5 arnParts)
      in base <> ":" <> suffix <> "/" <> val
  | otherwise = val


safeIndex :: [a] -> Int -> Maybe a
safeIndex xs i
  | i < length xs = Just (xs !! i)
  | otherwise = Nothing
