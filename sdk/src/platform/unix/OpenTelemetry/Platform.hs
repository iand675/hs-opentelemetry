module OpenTelemetry.Platform where

import Control.Exception (throwIO, try)
import qualified Data.Text as T
import System.IO.Error (isDoesNotExistError)
import System.Posix.User (getEffectiveUserName)


tryGetUser :: IO (Maybe T.Text)
tryGetUser = do
  eResult <- try getEffectiveUserName
  case eResult of
    Left err ->
      if isDoesNotExistError err
        then pure Nothing
        else throwIO err
    Right ok -> pure $ Just $ T.pack ok
