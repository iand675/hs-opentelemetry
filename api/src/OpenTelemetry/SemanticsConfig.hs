{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.SemanticsConfig (
  SemanticsOptions (httpOption),
  getSemanticsOptions,
  getSemanticsOptions',
) where

import Control.Exception.Safe (throwIO, tryAny)
import Data.IORef (newIORef, readIORef, writeIORef)
import qualified Data.Text as T
import System.Environment (lookupEnv)
import System.IO.Unsafe (unsafePerformIO)


data SemanticsOptions = SemanticsOptions {httpOption :: HttpOption}


data HttpOption
  = Stable
  | StableAndOld
  | Old
  deriving (Show, Eq)


defaultOptions :: SemanticsOptions
defaultOptions = SemanticsOptions {httpOption = Old}


parseHttpOption :: (Foldable t) => t T.Text -> HttpOption
parseHttpOption envs
  | "http/dup" `elem` envs = StableAndOld
  | "http" `elem` envs = Stable
  | otherwise = Old


parseSemanticsOptions :: Maybe String -> SemanticsOptions
parseSemanticsOptions Nothing = defaultOptions
parseSemanticsOptions (Just env) = SemanticsOptions {..}
  where
    envs = fmap T.strip $ T.splitOn "," $ T.pack env
    httpOption = parseHttpOption envs


{- data SemanticsOption
  = HttpStableSemantics
  | HttpOldAndStableSemantics
  deriving (Show, Eq, Generic)

instance Hashable SemanticsOption

newtype SemanticsOptions = SemanticsOptions (HS.HashSet SemanticsOption)

semanticsOptionIsSet :: SemanticsOption -> SemanticsOptions -> Bool
semanticsOptionIsSet option (SemanticsOptions options) = HS.member option options

useStableHttpSemantics :: SemanticsOptions -> Bool
useStableHttpSemantics options =
  semanticsOptionIsSet HttpStableSemantics options
    || semanticsOptionIsSet HttpOldAndStableSemantics options

useOldHttpSemantics :: SemanticsOptions -> Bool
useOldHttpSemantics options =
  semanticsOptionIsSet HttpOldAndStableSemantics options
    || not (semanticsOptionIsSet HttpStableSemantics options)

parseSemanticsOption :: T.Text -> Maybe SemanticsOption
parseSemanticsOption "http/dup" = Just HttpOldAndStableSemantics
parseSemanticsOption "http" = Just HttpStableSemantics
parseSemanticsOption _ = Nothing

parseSemanticsOptions :: Maybe String -> SemanticsOptions
parseSemanticsOptions Nothing = SemanticsOptions HS.empty
parseSemanticsOptions (Just env) = SemanticsOptions $ HS.fromList $ mapMaybe parseSemanticsOption envs
  where
    envs = fmap T.strip . T.splitOn "," . T.pack $ env -}

getSemanticsOptions' :: IO SemanticsOptions
getSemanticsOptions' = parseSemanticsOptions <$> lookupEnv "OTEL_SEMCONV_STABILITY_OPT_IN"


{- | Create a new memoized IO action using an 'IORef' under the surface. Note that
the action may be run in multiple threads simultaneously, so this may not be
thread safe (depending on the underlying action). For the sake of reading an environment
variable and parsing some stuff, we don't have to be concerned about thread-safety.
-}
memoize :: IO a -> IO (IO a)
memoize action = do
  ref <- newIORef Nothing
  pure $ do
    mres <- readIORef ref
    res <- case mres of
      Just res -> pure res
      Nothing -> do
        res <- tryAny action
        writeIORef ref $ Just res
        pure res
    either throwIO pure res


-- This uses the global IORef trick:
-- https://www.parsonsmatt.org/2021/04/21/global_ioref_in_template_haskell.html
getSemanticsOptions :: IO SemanticsOptions
getSemanticsOptions = unsafePerformIO $ memoize getSemanticsOptions
{-# NOINLINE getSemanticsOptions #-}
