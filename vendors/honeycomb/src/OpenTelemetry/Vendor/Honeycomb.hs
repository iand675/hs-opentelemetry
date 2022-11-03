{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TupleSections #-}
{-# LANGUAGE TypeApplications #-}
{-# OPTIONS_GHC -Wno-redundant-constraints #-}

{- | Vendor integration for Honeycomb.

   This lets you link to traces. You don't need this to send data to Honeycomb,
   for which @hs-opentelemetry-exporter-otlp@ is suitable.
-}
module OpenTelemetry.Vendor.Honeycomb (
  -- * Types
  HoneycombTeam (..),
  EnvironmentName (..),

  -- * Getting the Honeycomb target dataset/team name
  getOrInitializeHoneycombTargetInContext,
  getHoneycombTargetInContext,

  -- ** Detailed API
  getConfigPartsFromEnv,
  getHoneycombData,
  resolveHoneycombTarget,
  DatasetInfo (..),
  HoneycombTarget (..),

  -- * Making trace links
  makeDirectTraceLink,
  getHoneycombLink,
  getHoneycombLink',

  -- * Performing manual Honeycomb requests
  module Auth,
  module Config,
) where

import Control.Monad.Reader (MonadIO (..), MonadTrans (..), ReaderT (runReaderT), join)
import Control.Monad.Trans.Maybe (MaybeT (..))
import Data.ByteString (ByteString)
import qualified Data.ByteString.Char8 as BS8
import qualified Data.HashMap.Strict as HM
import Data.String (IsString)
import Data.Text (Text)
import qualified Data.Text as T
import Data.Text.Encoding (encodeUtf8)
import Data.Time.Clock
import Data.Time.Clock.POSIX
import Honeycomb.API.Auth as Auth
import Honeycomb.Config as Config
import Honeycomb.Types (DatasetName (..))
import OpenTelemetry.Attributes (
  Attribute (AttributeValue),
  PrimitiveAttribute (TextAttribute),
  lookupAttribute,
 )
import qualified OpenTelemetry.Baggage as Baggage
import OpenTelemetry.Context (lookupSpan)
import qualified OpenTelemetry.Context as Context
import qualified OpenTelemetry.Context.ThreadLocal as TLContext
import OpenTelemetry.Resource (
  getMaterializedResourcesAttributes,
 )
import OpenTelemetry.Trace.Core (
  TracerProvider,
  getGlobalTracerProvider,
  getSpanContext,
  getTracerProviderResources,
  isSampled,
  traceFlags,
  traceId,
 )
import OpenTelemetry.Trace.Id (Base (..), TraceId, traceIdBaseEncodedByteString)
import System.Environment (lookupEnv)
import System.IO.Unsafe (unsafePerformIO)
import System.Timeout (timeout)
import URI.ByteString (Query (..), httpNormalization, serializeQuery')
import Prelude


headerHoneycombApiKey :: Baggage.Token
headerHoneycombApiKey = [Baggage.token|x-honeycomb-team|]


headerHoneycombLegacyDataset :: Baggage.Token
headerHoneycombLegacyDataset = [Baggage.token|x-honeycomb-dataset|]


-- | Honeycomb team name; generally appears in the URL after @ui.honeycomb.io/@.
newtype HoneycombTeam = HoneycombTeam {unHoneycombTeam :: Text}
  deriving stock (Show, Eq)
  deriving newtype (IsString)


{- | Environment name in the Environments & Services data model (referred to as
 \"Current\" in this package).

 See https://docs.honeycomb.io/honeycomb-classic/ for more details.
-}
newtype EnvironmentName = EnvironmentName {unEnvironmentName :: Text}
  deriving stock (Show, Eq)
  deriving newtype (IsString)


{- | Gets the Honeycomb configuration from the environment.

    This does not do any HTTP.

 FIXME(jadel): This should ideally fetch this from the tracer provider, but
 it's nonobvious how to architect being able to do that (requires changes in
 hs-opentelemetry-api). For now let's take a Tracer such that we
 can fix it later, then do it the obvious way.
-}
getConfigPartsFromEnv :: (MonadIO m) => TracerProvider -> m (Maybe (Text, DatasetName))
getConfigPartsFromEnv _ = do
  mheaders <- liftIO $ lookupEnv "OTEL_EXPORTER_OTLP_HEADERS"
  pure $ getValues =<< mheaders
  where
    discardLeft (Left _) = Nothing
    discardLeft (Right a) = Just a

    getValues headers = do
      baggage <- discardLeft $ Baggage.decodeBaggageHeader (BS8.pack headers)
      token <- Baggage.value <$> (HM.lookup headerHoneycombApiKey $ Baggage.values baggage)
      let dataset = maybe "" Baggage.value (HM.lookup headerHoneycombLegacyDataset $ Baggage.values baggage)
      pure (token, DatasetName dataset)


{- | Gets the team name and environment name for the OTLP exporter using the API
 key from the environment.

 This calls Honeycomb.

 N.B. Use 'Config.config' to construct a config from 'getConfigPartsFromEnv'.

 N.B. The EnvironmentName will be Nothing if the API key is for a Honeycomb
 Classic instance.
-}
getHoneycombData :: MonadIO m => Config.Config -> m (HoneycombTeam, Maybe EnvironmentName)
getHoneycombData cfg = do
  auth <- runReaderT Auth.getAuth cfg
  let envSlug = Auth.slug . Auth.environment $ auth
      mEnvSlug = if T.null envSlug then Nothing else Just (EnvironmentName envSlug)

      team = HoneycombTeam . Auth.slug . Auth.team $ auth
  pure (team, mEnvSlug)


{- | Takes a 'Config.Config' and pokes around both Honeycomb HTTP API and the
 trace environment to figure out where events will land in Honeycomb.
-}
resolveHoneycombTarget :: (MonadIO m) => TracerProvider -> Config.Config -> m (Maybe HoneycombTarget)
resolveHoneycombTarget tracer cfg = do
  (team, mEnvName) <- getHoneycombData cfg
  let resources = getMaterializedResourcesAttributes . getTracerProviderResources $ tracer
  pure $
    HoneycombTarget team <$> case mEnvName of
      -- There is an env name -> Current-Honeycomb
      Just envName -> do
        AttributeValue (TextAttribute serviceName) <- lookupAttribute resources "service.name"
        pure $ Current envName (DatasetName serviceName)
      -- Honeycomb Classic
      Nothing -> do
        pure $ Classic (Config.defaultDataset cfg)


-- | Either a current-Honeycomb environment+dataset pair, or a Honeycomb Classic dataset
data DatasetInfo
  = Current EnvironmentName DatasetName
  | Classic DatasetName
  deriving stock (Show, Eq)


-- | A fully qualified Honeycomb dataset, possibly with environment.
data HoneycombTarget = HoneycombTarget
  { targetTeam :: HoneycombTeam
  , targetDataset :: DatasetInfo
  }
  deriving stock (Show, Eq)


{- | Formats a direct link to a trace.

See https://docs.honeycomb.io/api/direct-trace-links/ for more details.

The URLs generated will look like the following:

Honeycomb Current:


> https://ui.honeycomb.io/<team>/environments/<environment>/datasets/<dataset>/trace
>   ?trace_id=<traceId>
>   &trace_start_ts=<ts>
>   &trace_end_ts=<ts>

Honeycomb Classic:


> https://ui.honeycomb.io/<team>/datasets/<dataset>/trace
>   ?trace_id=<traceId>
>   &trace_start_ts=<ts>
>   &trace_end_ts=<ts>
-}
makeDirectTraceLink :: HoneycombTarget -> UTCTime -> TraceId -> ByteString
makeDirectTraceLink HoneycombTarget {..} timestamp traceId =
  case targetDataset of
    Current env ds ->
      teamPrefix
        <> "/environments/"
        <> (encodeUtf8 . unEnvironmentName $ env)
        <> "/datasets/"
        <> (encodeUtf8 . fromDatasetName $ ds)
        <> "/trace"
        <> query
    Classic ds -> teamPrefix <> "/datasets/" <> (encodeUtf8 . fromDatasetName $ ds) <> "/trace" <> query
  where
    -- XXX(jadel): I feel like there's not really any way to know what these
    -- actual values are, even if we are omniscient of the Haskell application.
    -- For instance, if someone else calls us, we simply don't know when the
    -- trace started. So it's kind of a fool's errand. Let's just give ± 1hr and
    -- call it a day.
    oneHour = secondsToNominalDiffTime 3600
    guessedStart = addUTCTime (-oneHour) timestamp
    guessedEnd = addUTCTime oneHour timestamp
    convertTimestamp = BS8.pack . show @Integer . truncate . nominalDiffTimeToSeconds . utcTimeToPOSIXSeconds

    teamPrefix = "https://ui.honeycomb.io/" <> encodeUtf8 (unHoneycombTeam targetTeam)
    query =
      serializeQuery' httpNormalization $
        Query
          [ ("trace_id", traceIdBaseEncodedByteString Base16 traceId)
          , ("trace_start_ts", convertTimestamp guessedStart)
          , ("trace_end_ts", convertTimestamp guessedEnd)
          ]


honeycombTargetKey :: Context.Key (Maybe HoneycombTarget)
honeycombTargetKey = unsafePerformIO $ Context.newKey "honeycombTarget"
{-# NOINLINE honeycombTargetKey #-}


{- | Gets or initializes the Honeycomb target in the thread-local
 'Context.Context'.

 This should be called inside the root span at application startup in order to
 ensure that this context is the parent of all child contexts in which you might
 want to get the target (for instance to generate Honeycomb links).
-}
getOrInitializeHoneycombTargetInContext ::
  MonadIO m =>
  -- | Timeout for the operation before assuming Honeycomb is inaccessible
  NominalDiffTime ->
  m (Maybe HoneycombTarget)
getOrInitializeHoneycombTargetInContext theTimeout = do
  mmTarget <- getHoneycombTargetInContext'
  case mmTarget of
    -- It was fetched before (and possibly was Nothing)
    Just t -> pure t
    -- It has not been fetched yet
    Nothing -> do
      mTarget <- join <$> liftIO (timeoutMicroseconds theTimeout getTarget)
      TLContext.adjustContext (Context.insert honeycombTargetKey mTarget)
      pure mTarget
  where
    microsecondsPerSecond = 1000 * 1000
    timeoutMicroseconds :: NominalDiffTime -> IO a -> IO (Maybe a)
    timeoutMicroseconds limit = timeout (truncate $ nominalDiffTimeToSeconds limit * microsecondsPerSecond)

    getTarget :: IO (Maybe HoneycombTarget)
    getTarget = runMaybeT $ do
      tracer <- lift getGlobalTracerProvider
      theConfig <- uncurry config <$> MaybeT (getConfigPartsFromEnv tracer)
      MaybeT $ resolveHoneycombTarget tracer theConfig


{- | Simple function to get the Honeycomb target out of the global context.

 At application startup, run 'getOrInitializeHoneycombTargetInContext' before
 calling this, or else you will get 'Nothing'.

 This is the right function for most use cases.
-}
getHoneycombTargetInContext :: MonadIO m => m (Maybe HoneycombTarget)
getHoneycombTargetInContext = do
  join <$> getHoneycombTargetInContext'


-- | Gets the thread-local context. The outer Maybe represents whether one has been set yet.
getHoneycombTargetInContext' :: MonadIO m => m (Maybe (Maybe HoneycombTarget))
getHoneycombTargetInContext' = do
  Context.lookup honeycombTargetKey <$> TLContext.getContext


{- | Gets a trace link for the current trace.

 Needs to have the thread-local target initialized; see
 'getOrInitializeHoneycombTargetInContext'.
-}
getHoneycombLink :: MonadIO m => m (Maybe ByteString)
getHoneycombLink = do
  mTarget <- getHoneycombTargetInContext
  case mTarget of
    Just target -> getHoneycombLink' target
    Nothing -> pure Nothing


-- | Gets a trace link for the current trace with an explicitly provided target.
getHoneycombLink' :: MonadIO m => HoneycombTarget -> m (Maybe ByteString)
getHoneycombLink' target = do
  theSpan <- lookupSpan <$> TLContext.getContext
  inTraceId <- traceIdForSpan theSpan
  time <- liftIO getCurrentTime

  pure $ makeDirectTraceLink target time <$> inTraceId
  where
    traceIdForSpan = \case
      Just s -> do
        spanCtx <- getSpanContext s
        -- if not sampled, it's not useful to give a link
        pure $
          if isSampled (traceFlags spanCtx)
            then Just $ traceId spanCtx
            else Nothing
      Nothing -> pure Nothing
