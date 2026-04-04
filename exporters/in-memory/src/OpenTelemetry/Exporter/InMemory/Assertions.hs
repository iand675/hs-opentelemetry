{-# LANGUAGE OverloadedStrings #-}

{- | Testing assertion helpers built on top of in-memory exporters.

Import this module in your test suite alongside 'OpenTelemetry.Exporter.InMemory'
to get ergonomic span/metric/log assertions without writing manual IORef reads and
list searches.

@
(proc, spansRef) <- inMemoryListExporter
-- ... run instrumented code ...
span <- assertSpanNamed spansRef "my-operation"
assertSpanAttribute span "http.method" (AttributeValue (TextAttribute "GET"))
@
-}
module OpenTelemetry.Exporter.InMemory.Assertions (
  -- * Span assertions
  getSpans,
  assertSpanNamed,
  assertSpanCount,
  assertNoSpans,
  assertSpanAttribute,
  assertSpanHasParent,
  assertSpanStatus,

  -- * Metric assertions
  getMetricExports,
  assertMetricNamed,
  assertMetricCount,
  assertNoMetrics,

  -- * Log assertions
  getLogRecords,
  assertLogCount,
  assertNoLogs,
) where

import Control.Exception (throwIO)
import Control.Monad (unless)
import Control.Monad.IO.Class (MonadIO, liftIO)
import Data.IORef (IORef, readIORef)
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Vector as V
import OpenTelemetry.Attributes (Attribute, lookupAttribute)
import OpenTelemetry.Exporter.Metric (
  MetricExport (..),
  ResourceMetricsExport (..),
  ScopeMetricsExport (..),
 )
import OpenTelemetry.Logs.Core (ReadableLogRecord)
import OpenTelemetry.Trace.Core (
  ImmutableSpan (..),
  SpanHot (..),
  SpanStatus (..),
 )


-- Spans

-- | Read all spans currently in the in-memory exporter.
getSpans :: (MonadIO m) => IORef [ImmutableSpan] -> m [ImmutableSpan]
getSpans = liftIO . readIORef


{- | Find the first span with the given name. Throws if not found.
When multiple spans share a name, returns the most recently ended one
(the in-memory list exporter prepends).
-}
assertSpanNamed :: (MonadIO m) => IORef [ImmutableSpan] -> Text -> m ImmutableSpan
assertSpanNamed ref name = liftIO $ do
  spans <- readIORef ref
  result <- findByName name spans
  case result of
    Nothing -> do
      names <- mapM (\s -> hotName <$> readIORef (spanHot s)) spans
      throwIO $ userError $ "Expected span named " <> show name <> " but found: [" <> T.unpack (T.intercalate ", " names) <> "]"
    Just s -> pure s


-- | Assert the total number of exported spans.
assertSpanCount :: (MonadIO m) => IORef [ImmutableSpan] -> Int -> m ()
assertSpanCount ref expected = liftIO $ do
  spans <- readIORef ref
  let actual = length spans
  unless (actual == expected) $
    throwIO $
      userError $
        "Expected " <> show expected <> " spans but found " <> show actual


-- | Assert no spans have been exported.
assertNoSpans :: (MonadIO m) => IORef [ImmutableSpan] -> m ()
assertNoSpans ref = assertSpanCount ref 0


-- | Assert a span has a specific attribute value.
assertSpanAttribute :: (MonadIO m) => ImmutableSpan -> Text -> Attribute -> m ()
assertSpanAttribute span_ key expected = liftIO $ do
  hot <- readIORef (spanHot span_)
  let actual = lookupAttribute (hotAttributes hot) key
      name = hotName hot
  case actual of
    Nothing ->
      throwIO $ userError $ "Span " <> show name <> " missing attribute " <> show key
    Just v ->
      unless (v == expected) $
        throwIO $
          userError $
            "Span " <> show name <> " attribute " <> show key <> ": expected " <> show expected <> " but got " <> show v


-- | Assert a span has a parent span.
assertSpanHasParent :: (MonadIO m) => ImmutableSpan -> m ()
assertSpanHasParent span_ = liftIO $ do
  case spanParent span_ of
    Nothing -> do
      name <- hotName <$> readIORef (spanHot span_)
      throwIO $ userError $ "Span " <> show name <> " has no parent"
    Just _ -> pure ()


-- | Assert a span's status.
assertSpanStatus :: (MonadIO m) => ImmutableSpan -> SpanStatus -> m ()
assertSpanStatus span_ expected = liftIO $ do
  hot <- readIORef (spanHot span_)
  let actual = hotStatus hot
      name = hotName hot
  unless (actual == expected) $
    throwIO $
      userError $
        "Span " <> show name <> " status: expected " <> show expected <> " but got " <> show actual


-- Metrics

-- | Read all metric export batches.
getMetricExports :: (MonadIO m) => IORef [ResourceMetricsExport] -> m [ResourceMetricsExport]
getMetricExports = liftIO . readIORef


-- | Find the first metric with the given name across all exports.
assertMetricNamed :: (MonadIO m) => IORef [ResourceMetricsExport] -> Text -> m MetricExport
assertMetricNamed ref name = liftIO $ do
  batches <- readIORef ref
  case findMetricByName name batches of
    Nothing ->
      throwIO $ userError $ "Expected metric named " <> show name <> " but not found in exports"
    Just m -> pure m


-- | Assert the total number of distinct metric names across all exports.
assertMetricCount :: (MonadIO m) => IORef [ResourceMetricsExport] -> Int -> m ()
assertMetricCount ref expected = liftIO $ do
  batches <- readIORef ref
  let actual = length (allMetrics batches)
  unless (actual == expected) $
    throwIO $
      userError $
        "Expected " <> show expected <> " metrics but found " <> show actual


-- | Assert no metrics have been exported.
assertNoMetrics :: (MonadIO m) => IORef [ResourceMetricsExport] -> m ()
assertNoMetrics ref = assertMetricCount ref 0


-- Logs

-- | Read all exported log records.
getLogRecords :: (MonadIO m) => IORef [ReadableLogRecord] -> m [ReadableLogRecord]
getLogRecords = liftIO . readIORef


-- | Assert the total number of exported log records.
assertLogCount :: (MonadIO m) => IORef [ReadableLogRecord] -> Int -> m ()
assertLogCount ref expected = liftIO $ do
  logs <- readIORef ref
  let actual = length logs
  unless (actual == expected) $
    throwIO $
      userError $
        "Expected " <> show expected <> " log records but found " <> show actual


-- | Assert no log records have been exported.
assertNoLogs :: (MonadIO m) => IORef [ReadableLogRecord] -> m ()
assertNoLogs ref = assertLogCount ref 0


-- Internal helpers

findByName :: Text -> [ImmutableSpan] -> IO (Maybe ImmutableSpan)
findByName _ [] = pure Nothing
findByName name (s : rest) = do
  n <- hotName <$> readIORef (spanHot s)
  if n == name then pure (Just s) else findByName name rest


metricExportName :: MetricExport -> Text
metricExportName (MetricExportSum n _ _ _ _ _ _ _) = n
metricExportName (MetricExportHistogram n _ _ _ _ _) = n
metricExportName (MetricExportExponentialHistogram n _ _ _ _ _) = n
metricExportName (MetricExportGauge n _ _ _ _ _) = n


findMetricByName :: Text -> [ResourceMetricsExport] -> Maybe MetricExport
findMetricByName name batches = go (allMetrics batches)
  where
    go [] = Nothing
    go (m : rest)
      | metricExportName m == name = Just m
      | otherwise = go rest


allMetrics :: [ResourceMetricsExport] -> [MetricExport]
allMetrics = concatMap extractMetrics
  where
    extractMetrics (ResourceMetricsExport _ scopes) =
      concatMap (\(ScopeMetricsExport _ ms) -> V.toList ms) (V.toList scopes)
