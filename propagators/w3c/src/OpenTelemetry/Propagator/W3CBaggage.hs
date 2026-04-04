{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

module OpenTelemetry.Propagator.W3CBaggage (
  w3cBaggagePropagator,
  decodeBaggage,
  encodeBaggage,

  -- * Registry integration
  registerW3CBaggagePropagator,
) where

import Data.ByteString (ByteString)
import qualified Data.Text.Encoding as TE
import qualified OpenTelemetry.Baggage as Baggage
import OpenTelemetry.Context (Context, insertBaggage, lookupBaggage)
import OpenTelemetry.Propagator
import OpenTelemetry.Registry (registerTextMapPropagator)


decodeBaggage :: ByteString -> Maybe Baggage.Baggage
decodeBaggage bs = case Baggage.decodeBaggageHeader bs of
  Left _ -> Nothing
  Right b -> Just b


encodeBaggage :: Baggage.Baggage -> ByteString
encodeBaggage = Baggage.encodeBaggageHeader


w3cBaggagePropagator :: Propagator Context TextMap TextMap
w3cBaggagePropagator = Propagator {..}
  where
    propagatorFields = ["baggage"]

    extractor tm c = case textMapLookup "baggage" tm of
      Nothing -> pure c
      Just baggageText -> case decodeBaggage (TE.encodeUtf8 baggageText) of
        Nothing -> pure c
        Just baggage -> pure $! insertBaggage baggage c

    injector c tm = do
      case lookupBaggage c of
        Nothing -> pure tm
        Just baggage -> pure $! textMapInsert "baggage" (TE.decodeUtf8 $ encodeBaggage baggage) tm


{- | Register the W3C Baggage propagator under the name @\"baggage\"@
in the global registry.

@since 0.1.0.0
-}
registerW3CBaggagePropagator :: IO ()
registerW3CBaggagePropagator =
  registerTextMapPropagator "baggage" w3cBaggagePropagator
