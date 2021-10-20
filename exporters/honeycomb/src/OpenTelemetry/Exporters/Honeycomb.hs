{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE NumericUnderscores #-}
module OpenTelemetry.Exporters.Honeycomb
  ( makeHoneycombExporter
  , Config(..)
  , config
  , initializeHoneycomb
  ) where

import Chronos (Time(..))
import Data.Aeson (toJSON, ToJSON(..), Value(..))
import Data.Coerce
import qualified Data.HashMap.Strict as H
import Data.Text (Text)
import Honeycomb
import OpenTelemetry.Trace.SpanExporter
import OpenTelemetry.Trace (ImmutableSpan (..), SpanContext (spanId, traceId), getSpanContext, Event (..), Link(..))
import OpenTelemetry.Resource
import OpenTelemetry.Trace.Id (Base(Base16), spanIdBaseEncodedText, traceIdBaseEncodedText)
import qualified Torsor
import GHC.IO
import System.Clock (TimeSpec(..))
import Honeycomb.Config
import Data.Foldable (toList)

makeHoneycombExporter :: HoneycombClient -> SpanExporter
makeHoneycombExporter c = SpanExporter
  { export = \fs -> do
      let events = concatMap (makeEvents c) $ concatMap toList $ toList fs
      mapM_ (send c) events
      pure Success
  , shutdown = shutdownHoneycomb c
  }

newtype HoneycombFormattedAttribute = HoneycombFormattedAttribute Attribute

primitiveAttributeToJSON :: PrimitiveAttribute -> Value
primitiveAttributeToJSON (TextAttribute v) = toJSON v
primitiveAttributeToJSON (BoolAttribute v) = toJSON v
primitiveAttributeToJSON (DoubleAttribute v) = toJSON v
primitiveAttributeToJSON (IntAttribute v) = toJSON v

instance ToJSON HoneycombFormattedAttribute where
  toJSON (HoneycombFormattedAttribute (AttributeValue a)) = primitiveAttributeToJSON a
  toJSON (HoneycombFormattedAttribute (AttributeArray a)) = toJSON $ fmap primitiveAttributeToJSON a

makeEvents :: HoneycombClient -> ImmutableSpan -> [Honeycomb.Event]
makeEvents client ImmutableSpan{..} =
  concat [[spanEvent], eventEvents, linkEvents]
  where
    spanTime = Just $ clockTimeToChronosTime spanStart
    spanEvent = event
      { fields = fields
      , timestamp = spanTime
      }
    attrFields = H.fromList . map (\(k, v) -> (k, toJSON $ HoneycombFormattedAttribute v))
    unsafeParentId = case spanParent of
      Nothing -> Nothing
      Just s -> Just $ spanId $ unsafeDupablePerformIO (getSpanContext s :: IO SpanContext)

    encodedSpanId = spanIdBaseEncodedText Base16 $ spanId spanContext
    encodedTraceId = traceIdBaseEncodedText Base16 $ traceId spanContext

    fields =
      H.insert "name" (toJSON spanName) $
      H.insert "trace.span_id" (toJSON encodedSpanId) $
      H.insert "trace.parent_id" (toJSON (spanIdBaseEncodedText Base16 <$> unsafeParentId)) $
      H.insert "trace.trace_id" (toJSON encodedTraceId) $
      H.insert "duration_ms" (toJSON $ durationMs spanStart spanEnd) $
      attrFields spanAttributes

    eventEvents = map eventToEvent spanEvents
      where
        eventToEvent e = event
          { timestamp = Just $ clockTimeToChronosTime (eventTimestamp e)
          , fields = 
              H.insert "name" (toJSON $ eventName e) $
              H.insert "meta.annotation_type" (String "span_event") $
              H.insert "trace.parent_id" (toJSON encodedSpanId) $
              H.insert "trace.trace_id" (toJSON encodedTraceId) $
              attrFields (eventAttributes e)
          }

    linkEvents = map linkToEvent spanLinks
      where
        linkToEvent l = event
          { timestamp = spanTime 
          , fields =
              H.insert "meta.annotation_type" (String "link") $
              H.insert "trace.parent_id" (toJSON encodedSpanId) $
              H.insert "trace.trace_id" (toJSON encodedTraceId) $
              H.insert "trace.link.span_id" (toJSON $ spanIdBaseEncodedText Base16 $ spanId $ linkContext l) $
              H.insert "trace.link.trace_id" (toJSON $ traceIdBaseEncodedText Base16 $ traceId $ linkContext l) $
              attrFields (linkAttributes l)
          }

clockTimeToChronosTime :: TimeSpec -> Time
clockTimeToChronosTime TimeSpec{..} = Time ((sec * 1_000_000_000) + nsec)

durationMs :: TimeSpec -> Maybe TimeSpec -> Maybe Double
durationMs start mEnd = do
  end <- mEnd
  let ts = end - start
  pure (fromIntegral (sec ts) * 1_000 + (fromIntegral (nsec ts) / 1_000_000))