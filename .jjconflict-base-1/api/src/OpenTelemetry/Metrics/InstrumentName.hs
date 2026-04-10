{-# LANGUAGE OverloadedStrings #-}

-- | Instrument name and unit validation (SDK applies this; API does not validate — see specification/metrics/api.md).
module OpenTelemetry.Metrics.InstrumentName (
  validateInstrumentName,
  validateInstrumentUnit,
) where

import Data.Char (isAscii)
import Data.Text (Text)
import qualified Data.Text as T


{- | @Nothing@ if valid; @Just err@ with a short English reason if invalid.
Implements the stable rules from specification/metrics/api.md (instrument name ABNF; ASCII only).
-}
validateInstrumentName :: Text -> Maybe Text
validateInstrumentName t
  | T.null t = Just "instrument name must not be empty"
  | T.length t > 255 = Just "instrument name exceeds 255 characters"
  | otherwise =
      let c0 = T.index t 0
      in if not (isAsciiAlpha c0)
          then Just "instrument name must start with an ASCII letter"
          else go 1
  where
    go :: Int -> Maybe Text
    go i
      | i >= T.length t = Nothing
      | otherwise =
          let c = T.index t i
          in if isValidChar c
              then go (i + 1)
              else Just "instrument name contains invalid characters"
    isAsciiAlpha c =
      isAscii c
        && ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z'))
    isAsciiDigit c = c >= '0' && c <= '9'
    isValidChar c =
      isAscii c
        && ( isAsciiAlpha c
              || isAsciiDigit c
              || c == '_'
              || c == '.'
              || c == '-'
              || c == '/'
           )


-- | Unit is optional; when present it must be ASCII and at most 63 code units (specification/metrics/api.md).
validateInstrumentUnit :: Text -> Maybe Text
validateInstrumentUnit u
  | T.null u = Nothing
  | T.length u > 63 = Just "instrument unit exceeds 63 characters"
  | otherwise =
      let step i
            | i >= T.length u = Nothing
            | otherwise =
                let c = T.index u i
                in if isAscii c then step (i + 1) else Just "instrument unit must be ASCII"
      in step 0
