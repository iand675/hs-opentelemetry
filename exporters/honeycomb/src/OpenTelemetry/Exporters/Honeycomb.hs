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
import OpenTelemetry.Trace (ImmutableSpan (..), SpanContext (spanId, traceId), getSpanContext)
import OpenTelemetry.Resource
import OpenTelemetry.Trace.Id (Base(Base16), spanIdBaseEncodedText, traceIdBaseEncodedText)
import qualified Torsor
import GHC.IO
import System.Clock (TimeSpec(..))
import Honeycomb.Config

makeHoneycombExporter :: HoneycombClient -> Text {- ^ service name -} -> SpanExporter
makeHoneycombExporter c t = SpanExporter
  { export = \fs -> do
      let events = concatMap (makeEvents c t) fs
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

makeEvents :: HoneycombClient -> Text -> ImmutableSpan -> [Event]
makeEvents client svcName ImmutableSpan{..} = 
  concat [[spanEvent], eventEvents, linkEvents]
  where
    spanEvent = event
      { fields = fields
      , timestamp = Just $ clockTimeToChronosTime spanStart
      }
    attrFields = H.fromList $ map (\(k, v) -> (k, toJSON $ HoneycombFormattedAttribute v)) spanAttributes
    unsafeParentId = case spanParent of
      Nothing -> Nothing 
      Just s -> Just $ spanId $ unsafeDupablePerformIO (getSpanContext s :: IO SpanContext)

    fields = 
      H.insert "name" (toJSON spanName) $ 
      H.insert "service_name" (toJSON svcName) $
      H.insert "trace.span_id" (toJSON $ spanIdBaseEncodedText Base16 $ spanId spanContext) $
      H.insert "trace.parent_id" (toJSON (spanIdBaseEncodedText Base16 <$> unsafeParentId)) $
      H.insert "trace.trace_id" (toJSON $ traceIdBaseEncodedText Base16 $ traceId spanContext) $
      H.insert "duration_ms" (toJSON $ durationMs spanStart spanEnd) $
      attrFields

    eventEvents = []
    linkEvents = []

clockTimeToChronosTime :: TimeSpec -> Time
clockTimeToChronosTime TimeSpec{..} = Time ((sec * 1_000_000_000) + nsec)

durationMs :: TimeSpec -> Maybe TimeSpec -> Maybe Double
durationMs start mEnd = do
  end <- mEnd
  let ts = end - start
  pure (fromIntegral (sec ts) * 1_000 + (fromIntegral (nsec ts) / 1_000_000))