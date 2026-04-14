module OpenTelemetry.Resource.Detector.Internal (
  lookupEnvText,
  firstEnv,
) where

import qualified Data.Text as T
import System.Environment (lookupEnv)


-- | Like 'lookupEnv' but returns 'T.Text' instead of 'String'.
lookupEnvText :: String -> IO (Maybe T.Text)
lookupEnvText key = fmap (T.pack <$>) (lookupEnv key)


-- | Return the value of the first environment variable that is set.
firstEnv :: [String] -> IO (Maybe T.Text)
firstEnv [] = pure Nothing
firstEnv (k : ks) = do
  mVal <- lookupEnvText k
  case mVal of
    Just v -> pure (Just v)
    Nothing -> firstEnv ks
