{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TupleSections #-}
{-# LANGUAGE TypeApplications #-}
{-# OPTIONS_GHC -Wno-redundant-constraints #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

{- | Vendor integration for Honeycomb.

   This lets you link to traces. You don't need this to send data to Honeycomb,
   for which @hs-opentelemetry-exporter-otlp@ is suitable.
-}
module OpenTelemetry.Vendor.Honeycomb
  ( HoneycombTeam (..),
    EnvironmentName (..),
    getConfigPartsFromEnv,
    getHoneycombData,
    resolveHoneycombTarget,
    DatasetInfo (..),
    HoneycombTarget (..),
    makeDirectTraceLink,
    getHoneycombLink,
    module Auth,
    module Config,
  )
where

import Control.Monad.Reader (MonadIO (..), ReaderT (runReaderT))
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
import OpenTelemetry.Attributes
  ( Attribute (AttributeValue),
    PrimitiveAttribute (TextAttribute),
    lookupAttribute,
  )
import qualified OpenTelemetry.Baggage as Baggage
import OpenTelemetry.Context (lookupSpan)
import OpenTelemetry.Context.ThreadLocal (getContext)
import OpenTelemetry.Resource
  ( getMaterializedResourcesAttributes,
  )
import OpenTelemetry.Trace.Core
  ( TracerProvider,
    getSpanContext,
    getTracerProviderResources,
    isSampled,
    traceFlags,
    traceId,
  )
import OpenTelemetry.Trace.Id (Base (..), TraceId, traceIdBaseEncodedByteString)
import System.Environment (lookupEnv)
import URI.ByteString (Query (..), httpNormalization, serializeQuery')
import Prelude


headerHoneycombApiKey :: Baggage.Token
headerHoneycombApiKey = [Baggage.token|x-honeycomb-team|]


headerHoneycombLegacyDataset :: Baggage.Token
headerHoneycombLegacyDataset = [Baggage.token|x-honeycomb-dataset|]


newtype HoneycombTeam = HoneycombTeam {unHoneycombTeam :: Text}
  deriving stock (Show, Eq)
  deriving newtype (IsString)


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


data DatasetInfo
  = Current EnvironmentName DatasetName
  | Classic DatasetName
  deriving stock (Show, Eq)


-- | Context of which Honeycomb dataset we're sending events to.
data HoneycombTarget = HoneycombTarget
  { targetTeam :: HoneycombTeam
  , targetDataset :: DatasetInfo
  }
  deriving stock (Show, Eq)


{- | See https://docs.honeycomb.io/api/direct-trace-links/

 "http://ui.honeycomb.io/<team>/datasets/<dataset>/trace
    ?trace_id=<traceId>&trace_start_ts=<ts>&trace_end_ts=<ts>"
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
    guessedStart = addUTCTime oneHour timestamp
    guessedEnd = addUTCTime (-oneHour) timestamp
    convertTimestamp = BS8.pack . show @Integer . truncate . nominalDiffTimeToSeconds . utcTimeToPOSIXSeconds

    teamPrefix = "https://ui.honeycomb.io/" <> encodeUtf8 (unHoneycombTeam targetTeam)
    query =
      serializeQuery' httpNormalization $
        Query
          [ ("trace_id", traceIdBaseEncodedByteString Base16 traceId)
          , ("trace_start_ts", convertTimestamp guessedStart)
          , ("trace_end_ts", convertTimestamp guessedEnd)
          ]


-- | Gets a trace link for the current trace.
getHoneycombLink :: MonadIO m => HoneycombTarget -> m (Maybe ByteString)
getHoneycombLink target = do
  theSpan <- lookupSpan <$> getContext
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
