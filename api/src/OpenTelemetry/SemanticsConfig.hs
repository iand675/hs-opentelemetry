{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.SemanticsConfig (
  SemanticsOptions,
  useStableHttpSemantics,
  useOldHttpSemantics,
  getSemanticsOptions,
  getSemanticsOptions',
) where

import Control.Exception.Safe (throwIO, tryAny)
import qualified Data.HashSet as HS
import Data.Hashable (Hashable)
import Data.IORef (newIORef, readIORef, writeIORef)
import Data.Maybe (mapMaybe)
import qualified Data.Text as T
import GHC.Generics (Generic)
import System.Environment (lookupEnv)
import System.IO.Unsafe (unsafePerformIO)


data SemanticsOption
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
    envs = fmap T.strip . T.splitOn "," . T.pack $ env


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
