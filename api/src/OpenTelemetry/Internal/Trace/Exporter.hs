{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE ExistentialQuantification #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE StrictData #-}

module OpenTelemetry.Internal.Trace.Exporter (
  SpanExporter (..),
  MaterializedResourceSpans (..),
  MaterializedScopeSpans (..),
  MaterializedSpan (..),
  materializeResourceSpans,
) where

import Control.Monad ((<=<))
import Control.Monad.IO.Class (MonadIO)
import Data.ByteString (ByteString)
import Data.Functor ((<&>))
import Data.HashMap.Strict (HashMap)
import qualified Data.HashMap.Strict as H
import Data.Maybe (fromMaybe, listToMaybe)
import Data.Text (Text)
import Data.Vector (Vector)
import qualified Data.Vector as V
import Data.Word (Word32)
import OpenTelemetry.Attributes (Attributes, getCount)
import OpenTelemetry.Common (Timestamp)
import OpenTelemetry.Internal.Common.Types (ExportResult, InstrumentationLibrary)
import OpenTelemetry.Internal.Trace.Id (spanIdBytes)
import OpenTelemetry.Internal.Trace.Types (Event, ImmutableSpan (..), Link, SpanContext (..), SpanKind, SpanStatus, getSpanContext)
import OpenTelemetry.Resource (MaterializedResources)
import OpenTelemetry.Trace.Core (getTracerProviderResources, getTracerTracerProvider)
import OpenTelemetry.Util (appendOnlyBoundedCollectionDroppedElementCount, appendOnlyBoundedCollectionValues)


data SpanExporter = SpanExporter
  { spanExporterExport :: Vector MaterializedResourceSpans -> IO ExportResult
  , spanExporterShutdown :: IO ()
  }


{- |
A read-only representation of a resource span.

Only processors and exporters should use rely on this interface.
-}
data MaterializedResourceSpans = MaterializedResourceSpans
  { materializedResource :: !(Maybe MaterializedResources)
  , materializedScopeSpans :: !(Vector MaterializedScopeSpans)
  }


{- |
A read-only representation of a scope span.

Only processors and exporters should use rely on this interface.
-}
data MaterializedScopeSpans = MaterializedScopeSpans
  { materializedScope :: !(Maybe InstrumentationLibrary)
  , materializedSpans :: !(Vector MaterializedSpan)
  }


{- |
A read-only representation of a 'Span'.

Only processors and exporters should use rely on this interface.
-}
data MaterializedSpan = MaterializedSpan
  { materializedContext :: !SpanContext
  , materializedParentSpanId :: !ByteString
  , materializedName :: !Text
  , materializedKind :: !SpanKind
  , materializedStartTimeUnixNano :: !Timestamp
  , materializedEndTimeUnixNano :: !Timestamp
  , materializedAttributes :: !Attributes
  , materializedDroppedAttributesCount :: !Word32
  , materializedEvents :: !(Vector Event)
  , materializedDroppedEventsCount :: !Word32
  , materializedLinks :: !(Vector Link)
  , materializedDroppedLinksCount :: !Word32
  , materializedStatus :: !(Maybe SpanStatus)
  }


materializeResourceSpans
  :: (MonadIO m)
  => HashMap InstrumentationLibrary (Vector ImmutableSpan)
  -> m (Vector MaterializedResourceSpans)
materializeResourceSpans completedSpans = do
  traverse (uncurry materializeScopeSpans) spanGroupList <&> \scopeSpans ->
    V.singleton
      MaterializedResourceSpans
        { materializedResource = firstResource
        , materializedScopeSpans = V.fromList scopeSpans
        }
  where
    spanGroupList :: [(InstrumentationLibrary, Vector ImmutableSpan)]
    spanGroupList = H.toList completedSpans

    -- TODO: This won't work if multiple TracerProviders are exporting to a
    --       single OTLP exporter with different resources.
    firstResource :: Maybe MaterializedResources
    firstResource = getTracerProviderResources . getTracerTracerProvider . spanTracer <$> firstCompletedSpan
      where
        firstCompletedSpan :: Maybe ImmutableSpan
        firstCompletedSpan = (V.!? 0) . snd =<< listToMaybe spanGroupList


materializeScopeSpans
  :: (MonadIO m)
  => InstrumentationLibrary
  -> Vector ImmutableSpan
  -> m MaterializedScopeSpans
materializeScopeSpans instrumentationLibrary completedSpans =
  traverse materializeSpan completedSpans <&> \spans ->
    MaterializedScopeSpans
      { materializedScope = Just instrumentationLibrary
      , materializedSpans = spans
      }


materializeSpan
  :: (MonadIO m)
  => ImmutableSpan
  -> m MaterializedSpan
materializeSpan completedSpan = do
  parentSpanId <-
    maybe (pure mempty) (pure . spanIdBytes . spanId <=< getSpanContext) (spanParent completedSpan)
  pure
    MaterializedSpan
      { materializedContext = spanContext completedSpan
      , materializedParentSpanId = parentSpanId
      , materializedName = spanName completedSpan
      , materializedKind = spanKind completedSpan
      , materializedStartTimeUnixNano = spanStart completedSpan
      , materializedEndTimeUnixNano = fromMaybe (spanStart completedSpan) (spanEnd completedSpan)
      , materializedAttributes = spanAttributes completedSpan
      , materializedDroppedAttributesCount = fromIntegral . getCount $ spanAttributes completedSpan
      , materializedEvents = appendOnlyBoundedCollectionValues $ spanEvents completedSpan
      , materializedDroppedEventsCount = fromIntegral . appendOnlyBoundedCollectionDroppedElementCount $ spanEvents completedSpan
      , materializedLinks = appendOnlyBoundedCollectionValues $ spanLinks completedSpan
      , materializedDroppedLinksCount = fromIntegral . appendOnlyBoundedCollectionDroppedElementCount $ spanLinks completedSpan
      , materializedStatus = Just (spanStatus completedSpan)
      }
