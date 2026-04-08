{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}

-- |
-- Module      : OpenTelemetry.SemanticsConfig
-- Description : Configuration for semantic convention stability opt-in. Controls which attribute naming conventions are used.
-- Stability   : experimental
--
-- Values are typically derived from @OTEL_SEMCONV_STABILITY_OPT_IN@ via
-- 'getSemanticsOptions' and queried per signal area with 'lookupStability'.
module OpenTelemetry.SemanticsConfig (
  SemanticsOptions,
  StabilityOpt (..),
  HttpOption,
  lookupStability,

  -- * Well-known stability keys
  httpOption,
  databaseOption,
  codeOption,

  -- * Reading from the environment
  getSemanticsOptions,
  getSemanticsOptions',
) where

import Control.Exception (SomeException, throwIO, try)
import qualified Data.HashSet as Set
import Data.IORef (newIORef, readIORef, writeIORef)
import qualified Data.Text as T
import System.Environment (lookupEnv)
import System.IO.Unsafe (unsafePerformIO)


{- | Parsed representation of @OTEL_SEMCONV_STABILITY_OPT_IN@.

This is opaque: use 'lookupStability' with any signal key (e.g. @"http"@,
@"database"@, @"messaging"@) to query whether stable, old, or both conventions
should be emitted. Well-known accessors 'httpOption' and 'databaseOption' are
provided for convenience; third-party instrumentation libraries can query
arbitrary keys without modifying this module.

@since 0.4.0.0
-}
newtype SemanticsOptions = SemanticsOptions (Set.HashSet T.Text)


{- | Stability setting for a particular semantic convention area.

* 'Stable': emit only the new stable conventions.
* 'StableAndOld': emit both old and stable conventions (migration/dup mode).
* 'Old': emit only the legacy conventions (default when unset).

@since 0.4.0.0
-}
data StabilityOpt
  = Stable
  | StableAndOld
  | Old
  deriving (Show, Eq)


-- | Backward-compatible alias.
--
-- @since 0.4.0.0
type HttpOption = StabilityOpt


{- | Look up the stability setting for an arbitrary signal key.

Given a key like @"http"@, @"database"@, @"messaging"@, etc., returns:

* 'StableAndOld' if @\<key\>\/dup@ is present in the env var
* 'Stable' if @\<key\>@ is present
* 'Old' otherwise

@
opts <- getSemanticsOptions
case lookupStability "messaging" opts of
  Stable      -> emitStableAttrs
  StableAndOld -> emitStableAttrs >> emitOldAttrs
  Old         -> emitOldAttrs
@
@since 0.4.0.0
-}
lookupStability :: T.Text -> SemanticsOptions -> StabilityOpt
lookupStability key (SemanticsOptions vals)
  | (key <> "/dup") `Set.member` vals = StableAndOld
  | key `Set.member` vals = Stable
  | otherwise = Old


-- | Stability setting for HTTP semantic conventions (@"http"@ / @"http\/dup"@).
--
-- @since 0.4.0.0
httpOption :: SemanticsOptions -> StabilityOpt
httpOption = lookupStability "http"


-- | Stability setting for database semantic conventions (@"database"@ / @"database\/dup"@).
--
-- @since 0.4.0.0
databaseOption :: SemanticsOptions -> StabilityOpt
databaseOption = lookupStability "database"


-- | Stability setting for code source-location conventions (@"code"@ / @"code\/dup"@).
--
-- Controls whether @code.function.name@, @code.file.path@, @code.line.number@ (stable)
-- or @code.function@, @code.namespace@, @code.filepath@, @code.lineno@ (legacy) are emitted.
--
-- @since 0.5.0.0
codeOption :: SemanticsOptions -> StabilityOpt
codeOption = lookupStability "code"


parseSemanticsOptions :: Maybe String -> SemanticsOptions
parseSemanticsOptions Nothing = SemanticsOptions Set.empty
parseSemanticsOptions (Just env) =
  SemanticsOptions $ Set.fromList $ fmap T.strip $ T.splitOn "," $ T.pack env


{- | Version of 'getSemanticsOptions' that is not memoized. It is recommended to
use 'getSemanticsOptions' for efficiency purposes unless it is necessary to
retrieve the value of @OTEL_SEMCONV_STABILITY_OPT_IN@ every time
'getSemanticsOptions'' is called.

@since 0.4.0.0
-}
getSemanticsOptions' :: IO SemanticsOptions
getSemanticsOptions' = parseSemanticsOptions <$> lookupEnv "OTEL_SEMCONV_STABILITY_OPT_IN"


memoize :: IO a -> IO (IO a)
memoize action = do
  ref <- newIORef Nothing
  pure $ do
    mres <- readIORef ref
    res <- case mres of
      Just res -> pure res
      Nothing -> do
        res <- try @SomeException action
        writeIORef ref $ Just res
        pure res
    either throwIO pure res


{- | Retrieves @OTEL_SEMCONV_STABILITY_OPT_IN@ and parses it into 'SemanticsOptions'.

This uses the
[global IORef trick](https://www.parsonsmatt.org/2021/04/21/global_ioref_in_template_haskell.html)
to memoize the settings for efficiency. Note that 'getSemanticsOptions' stores
and returns the value of the first time it was called and will not change when
@OTEL_SEMCONV_STABILITY_OPT_IN@ is updated. Use 'getSemanticsOptions'' to read
the env var every time the function is called.

@since 0.4.0.0
-}
getSemanticsOptions :: IO SemanticsOptions
getSemanticsOptions = unsafePerformIO $ memoize getSemanticsOptions'
{-# NOINLINE getSemanticsOptions #-}
