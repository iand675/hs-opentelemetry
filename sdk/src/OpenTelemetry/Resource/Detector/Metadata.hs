{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}

{- |
Module      :  OpenTelemetry.Resource.Detector.Metadata
Copyright   :  (c) Ian Duncan, 2024
License     :  BSD-3
Description :  Shared HTTP utilities for metadata-based resource detectors
Maintainer  :  Ian Duncan
Stability   :  experimental

Low-level helpers for querying instance metadata services (AWS IMDS, GCP
metadata server, ECS task metadata, etc.).

All HTTP requests use a 2-second response timeout. On any failure
(timeout, connection refused, non-200 status, parse error), functions
return 'Nothing' rather than throwing.

@since 0.1.0.2
-}
module OpenTelemetry.Resource.Detector.Metadata (
  MetadataClient,
  newMetadataClient,
  newTlsMetadataClient,
  fetchText,
  fetchJSON,
  fetchTextWithHeaders,
  fetchJSONWithHeaders,
  putForText,
) where

import Control.Exception (SomeException, try)
import Data.Aeson (FromJSON, eitherDecode)
import qualified Data.ByteString.Lazy as BL
import qualified Data.CaseInsensitive as CI
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import Data.X509.CertificateStore (makeCertificateStore)
import Data.X509.File (readSignedObject)
import Network.Connection (TLSSettings (..))
import Network.HTTP.Client (
  Manager,
  Request (..),
  Response (..),
  defaultManagerSettings,
  httpLbs,
  managerResponseTimeout,
  newManager,
  parseRequest,
  responseTimeoutMicro,
 )
import Network.HTTP.Client.TLS (mkManagerSettings)
import Network.HTTP.Types.Status (statusCode)
import qualified Network.TLS as TLS


{- | Opaque handle holding an HTTP 'Manager' configured with short timeouts
suitable for metadata service queries.
-}
newtype MetadataClient = MetadataClient Manager


{- | Create a 'MetadataClient' with a 2-second response timeout.
Safe to share across multiple detector calls within a single
detection run.
-}
newMetadataClient :: IO MetadataClient
newMetadataClient =
  MetadataClient
    <$> newManager
      defaultManagerSettings
        { managerResponseTimeout = responseTimeoutMicro 2000000
        }


{- | Create a 'MetadataClient' that validates TLS using a specific CA
certificate file (PEM or DER). Returns 'Nothing' if the CA cert cannot
be loaded.

Used by the EKS detector to make HTTPS calls to the in-cluster
Kubernetes API server using the service account CA at
@\/var\/run\/secrets\/kubernetes.io\/serviceaccount\/ca.crt@.

@since 0.1.0.2
-}
newTlsMetadataClient :: FilePath -> String -> IO (Maybe MetadataClient)
newTlsMetadataClient caCertPath hostname = do
  result <- try @SomeException $ do
    certs <- readSignedObject caCertPath
    let caStore = makeCertificateStore certs
        base = TLS.defaultParamsClient hostname ""
        shared = TLS.clientShared base
        params = base {TLS.clientShared = shared {TLS.sharedCAStore = caStore}}
        tlsSettings = TLSSettings params
        settings =
          (mkManagerSettings tlsSettings Nothing)
            { managerResponseTimeout = responseTimeoutMicro 2000000
            }
    mgr <- newManager settings
    pure (MetadataClient mgr)
  pure $ case result of
    Left _ -> Nothing
    Right v -> Just v


{- | Fetch a URL via GET and return the response body as 'Text',
or 'Nothing' on any failure.
-}
fetchText :: MetadataClient -> String -> IO (Maybe Text)
fetchText client url = fetchTextWithHeaders client url []


-- | Fetch via GET with extra request headers.
fetchTextWithHeaders
  :: MetadataClient
  -> String
  -> [(Text, Text)]
  -> IO (Maybe Text)
fetchTextWithHeaders (MetadataClient mgr) url extraHeaders = do
  result <- try @SomeException $ do
    req0 <- parseRequest url
    let req =
          req0
            { requestHeaders =
                requestHeaders req0
                  ++ fmap (\(k, v) -> (CI.mk (TE.encodeUtf8 k), TE.encodeUtf8 v)) extraHeaders
            }
    resp <- httpLbs req mgr
    if statusCode (responseStatus resp) == 200
      then pure $ Just $ T.strip $ TE.decodeUtf8 $ BL.toStrict $ responseBody resp
      else pure Nothing
  pure $ case result of
    Left _ -> Nothing
    Right v -> v


{- | Issue a PUT request with extra headers and return the response body
as 'Text'. Used by IMDSv2 token acquisition.
-}
putForText
  :: MetadataClient
  -> String
  -> [(Text, Text)]
  -> IO (Maybe Text)
putForText (MetadataClient mgr) url extraHeaders = do
  result <- try @SomeException $ do
    req0 <- parseRequest url
    let req =
          req0
            { method = "PUT"
            , requestHeaders =
                requestHeaders req0
                  ++ fmap (\(k, v) -> (CI.mk (TE.encodeUtf8 k), TE.encodeUtf8 v)) extraHeaders
            }
    resp <- httpLbs req mgr
    if statusCode (responseStatus resp) == 200
      then pure $ Just $ T.strip $ TE.decodeUtf8 $ BL.toStrict $ responseBody resp
      else pure Nothing
  pure $ case result of
    Left _ -> Nothing
    Right v -> v


-- | Fetch a URL via GET, parse the response as JSON, or return 'Nothing'.
fetchJSON :: (FromJSON a) => MetadataClient -> String -> IO (Maybe a)
fetchJSON client url = fetchJSONWithHeaders client url []


-- | Fetch via GET with extra headers, parse the response as JSON.
fetchJSONWithHeaders
  :: (FromJSON a)
  => MetadataClient
  -> String
  -> [(Text, Text)]
  -> IO (Maybe a)
fetchJSONWithHeaders (MetadataClient mgr) url extraHeaders = do
  result <- try @SomeException $ do
    req0 <- parseRequest url
    let req =
          req0
            { requestHeaders =
                requestHeaders req0
                  ++ fmap (\(k, v) -> (CI.mk (TE.encodeUtf8 k), TE.encodeUtf8 v)) extraHeaders
            }
    resp <- httpLbs req mgr
    if statusCode (responseStatus resp) == 200
      then pure $ case eitherDecode (responseBody resp) of
        Left _ -> Nothing
        Right v -> Just v
      else pure Nothing
  pure $ case result of
    Left _ -> Nothing
    Right v -> v
