{-# LANGUAGE OverloadedStrings #-}

{- |
Module      :  OpenTelemetry.Resource.Detector.Heroku
Copyright   :  (c) Ian Duncan, 2024
License     :  BSD-3
Description :  Detect Heroku dyno resource attributes from environment
Maintainer  :  Ian Duncan
Stability   :  experimental

Reads Heroku dyno metadata from environment variables to populate
resource attributes per the
<https://opentelemetry.io/docs/specs/semconv/resource/cloud-provider/heroku/ Heroku semantic conventions>.

Returns an empty 'Resource' if not running on Heroku (i.e.
@HEROKU_APP_ID@ is not set).

Populates: @cloud.provider@, @heroku.app.id@, @heroku.release.commit@,
@heroku.release.creation_timestamp@, @service.name@,
@service.version@, @service.instance.id@.

@since 0.1.0.2
-}
module OpenTelemetry.Resource.Detector.Heroku (
  detectHeroku,
) where

import Data.Text (Text)
import qualified Data.Text as T
import OpenTelemetry.Resource (Resource, mkResource, (.=), (.=?))
import System.Environment (lookupEnv)


{- | Detect Heroku dyno attributes from environment variables.
Returns an empty resource if @HEROKU_APP_ID@ is not set.
-}
detectHeroku :: IO Resource
detectHeroku = do
  mAppId <- lookupText "HEROKU_APP_ID"
  case mAppId of
    Nothing -> pure $ mkResource []
    Just appId -> do
      mAppName <- lookupText "HEROKU_APP_NAME"
      mDynoId <- lookupText "HEROKU_DYNO_ID"
      mReleaseVersion <- lookupText "HEROKU_RELEASE_VERSION"
      mSlugCommit <- lookupText "HEROKU_SLUG_COMMIT"
      mReleaseCreated <- lookupText "HEROKU_RELEASE_CREATED_AT"
      pure $
        mkResource
          [ "cloud.provider" .= ("heroku" :: Text)
          , "heroku.app.id" .= appId
          , "heroku.release.commit" .=? mSlugCommit
          , "heroku.release.creation_timestamp" .=? mReleaseCreated
          , "service.name" .=? mAppName
          , "service.version" .=? mReleaseVersion
          , "service.instance.id" .=? mDynoId
          ]


lookupText :: String -> IO (Maybe Text)
lookupText k = fmap T.pack <$> lookupEnv k
