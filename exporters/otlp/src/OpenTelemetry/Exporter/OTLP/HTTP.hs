{-# LANGUAGE DeriveDataTypeable #-}

{- | Shared OTLP/HTTP response policy. Limits apply to decompressed bytes,
including chunked responses. Bodies are discarded incrementally, never
buffered in full. An oversized response is a non-retryable export failure.
-}
module OpenTelemetry.Exporter.OTLP.HTTP (
  defaultMaxResponseBytes,
  ResponseTooLarge (..),
  httpWithResponseLimit,
) where

import Control.Exception (Exception, throwIO)
import Control.Monad.IO.Class (liftIO)
import qualified Data.ByteString as BS
import Data.Conduit (await)
import Data.Typeable (Typeable)
import Network.HTTP.Client (Request, Response)
import Network.HTTP.Simple (httpSink)


-- | Four MiB, the OTLP-recommended default.
defaultMaxResponseBytes :: Int
defaultMaxResponseBytes = 4 * 1024 * 1024


newtype ResponseTooLarge = ResponseTooLarge Int deriving (Show, Typeable)


instance Exception ResponseTooLarge


{- | Read at most the supplied number of decompressed response bytes. Zero
accepts only an empty body; negative limits are invalid. httpSink closes the
response on failure. The exception deliberately is not an HttpException, so
transport retry loops cannot mistake it for a transient connection failure.
-}
httpWithResponseLimit :: Int -> Request -> IO (Response ())
httpWithResponseLimit limit request
  | limit < 0 = throwIO (userError "OTLP response size limit must be non-negative")
  | otherwise = httpSink request $ \response -> drain limit >> pure response
  where
    drain remaining = do
      chunk <- await
      case chunk of
        Nothing -> pure ()
        Just bytes
          | BS.length bytes > remaining -> liftIO $ throwIO (ResponseTooLarge limit)
          | otherwise -> drain (remaining - BS.length bytes)
