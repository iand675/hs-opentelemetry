{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.SemanticsConfig (
  SemanticsOptions (httpOption),
  HttpOption (..),
  getSemanticsOptions,
  getSemanticsOptions',
) where

import Control.Exception.Safe (throwIO, tryAny)
import Data.IORef (newIORef, readIORef, writeIORef)
import qualified Data.Text as T
import System.Environment (lookupEnv)
import System.IO.Unsafe (unsafePerformIO)


{- | This is a record that contains options for whether the new stable semantics conventions should be emitted.
Semantics conventions that have been declared stable:
- [http](https://opentelemetry.io/blog/2023/http-conventions-declared-stable/#migration-plan)
-}
data SemanticsOptions = SemanticsOptions {httpOption :: HttpOption}


-- | This option determines whether stable, old, or both kinds of http attributes are emitted.
data HttpOption
  = Stable
  | StableAndOld
  | Old
  deriving (Show, Eq)


-- | These are the default values emitted if OTEL_SEM_CONV_STABILITY_OPT_IN is unset or does not contain values for a specific category of option.
defaultOptions :: SemanticsOptions
defaultOptions = SemanticsOptions {httpOption = Old}


-- | Detects the presence of "http/dup" or "http" in OTEL_SEMCONV_STABILITY_OPT_IN or uses the default option if they are not there.
parseHttpOption :: (Foldable t) => t T.Text -> HttpOption
parseHttpOption envs
  | "http/dup" `elem` envs = StableAndOld
  | "http" `elem` envs = Stable
  | otherwise = httpOption defaultOptions


-- | Detects the presence of semantics options in OTEL_SEMCONV_STABILITY_OPT_IN or uses the defaultOptions if they are not present.
parseSemanticsOptions :: Maybe String -> SemanticsOptions
parseSemanticsOptions Nothing = defaultOptions
parseSemanticsOptions (Just env) = SemanticsOptions {..}
  where
    envs = fmap T.strip $ T.splitOn "," $ T.pack env
    httpOption = parseHttpOption envs


{- | Version of getSemanticsOptions that is not memoized. It is recommended to use getSemanticsOptions for efficiency purposes
unless it is necessary to retrieve the value of OTEL_SEMCONV_STABILITY_OPT_IN every time getSemanticsOptions' is called.
-}
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


{-  | Retrieves OTEL_SEMCONV_STABILITY_OPT_IN and parses it into SemanticsOptions.

This uses the [global IORef trick](https://www.parsonsmatt.org/2021/04/21/global_ioref_in_template_haskell.html)
to memoize the settings for efficiency. Note that getSemanticsOptions stores and returns the
value of the first time it was called and will not change when OTEL_SEMCONV_STABILITY_OPT_IN
is updated. Use getSemanticsOptions' to read OTEL_SEMCONV_STABILITY_OPT_IN every time the
function is called.
-}
getSemanticsOptions :: IO SemanticsOptions
getSemanticsOptions = unsafePerformIO $ memoize getSemanticsOptions'
{-# NOINLINE getSemanticsOptions #-}
