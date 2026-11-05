{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE NumericUnderscores #-}

-- | Shared OTLP/HTTP retry policy. The caller supplies the overall batch timeout.
module OpenTelemetry.Exporter.OTLP.Internal.Retry (
  sendHttpRequestWithRetry,
  jitteredBackoffMicros,
) where

import Control.Concurrent (threadDelay)
import Control.Exception (SomeException (..), try)
import Data.Bits (shiftL)
import Network.HTTP.Client
import Network.HTTP.Simple (httpBS)
import Network.HTTP.Types.Header (hRetryAfter)
import Network.HTTP.Types.Status (statusCode)
import OpenTelemetry.Exporter.OTLP.Internal.Config (isRetryableHttpStatus, parseRetryAfterMicros)
import OpenTelemetry.Internal.Common.Types (ExportResult (..))
import System.Random (randomRIO)


{- | Send a request with at most five retries, including server-directed retries.

Only the OTLP retryable HTTP codes and transient transport failures are retried.
The request body is reused. Async exceptions are never caught here, so both the
batch deadline and an earlier caller cancellation can interrupt requests/waits.
-}
sendHttpRequestWithRetry :: Request -> IO ExportResult
sendHttpRequestWithRetry req = send 0
  where
    send retries = do
      response <- try (httpBS req)
      case response of
        Left (HttpExceptionRequest _ err)
          | isRetryableException err -> retry retries Nothing
        Left err -> pure (Failure (Just (SomeException err)))
        Right resp
          | isRetryableHttpStatus (responseStatus resp) -> do
              delay <- maybe (pure Nothing) parseRetryAfterMicros (lookup hRetryAfter (responseHeaders resp))
              retry retries delay
          | statusCode (responseStatus resp) >= 300 -> pure (Failure Nothing)
          | otherwise -> pure Success

    retry retries serverDelay
      | retries >= 5 = pure (Failure Nothing)
      | otherwise = do
          delay <- maybe (jitteredBackoffMicros retries) pure serverDelay
          threadDelay delay
          send (retries + 1)


isRetryableException :: HttpExceptionContent -> Bool
isRetryableException = \case
  ResponseTimeout -> True
  ConnectionTimeout -> True
  ConnectionFailure _ -> True
  ConnectionClosed -> True
  _ -> False


{- | Equal jitter: choose between half and all of the exponential delay.
The cap prevents overflow even if this helper is called with a large count.
-}
jitteredBackoffMicros :: Int -> IO Int
jitteredBackoffMicros retries = randomRIO (ceilingDelay `div` 2, ceilingDelay)
  where
    ceilingDelay = 100_000 `shiftL` max 0 (min 5 retries)
