{-# LANGUAGE OverloadedLists #-}
{-# LANGUAGE OverloadedStrings #-}

{- |
Module      : OpenTelemetry.Instrumentation.Cloudflare
Description : OpenTelemetry instrumentation for services behind Cloudflare.
Stability   : experimental

WAI 'Middleware' that captures Cloudflare-injected request headers as span
attributes. Designed to compose with
@hs-opentelemetry-instrumentation-wai@: the WAI middleware creates the
server span and the Cloudflare middleware enriches it.

Three groups of headers are supported:

  * __Core__ – always-present CF headers (ray id, connecting ip, country, …)
  * __Location__ – geo headers added by the \"Add visitor location headers\"
    Managed Transform (city, continent, lat\/lon, region, …)
  * __Bot Management__ – headers from Cloudflare Bot Management (bot score,
    verified bot, JA3\/JA4 fingerprints)

Key semantic mappings beyond raw @http.request.header.*@ attributes:

  * @CF-Connecting-IP@ \/ @True-Client-IP@ → @client.address@
  * @CF-Ray@ → @cloudflare.ray_id@
  * @CF-IPCountry@ → @cloudflare.client.geo.country_code@
  * @CF-Worker@ → @cloudflare.worker.upstream_zone@
  * @CF-Visitor@ → @cloudflare.visitor.scheme@ (parsed from JSON)
-}
module OpenTelemetry.Instrumentation.Cloudflare (
  -- * Configuration
  CloudflareConfig (..),
  defaultCloudflareConfig,

  -- * Middleware
  cloudflareInstrumentationMiddleware,
  cloudflareInstrumentationMiddleware',
) where

import Control.Applicative ((<|>))
import Control.Monad (forM_, when)
import qualified Data.ByteString as BS
import qualified Data.CaseInsensitive as CI
import qualified Data.HashMap.Strict as H
import qualified Data.List
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import Network.HTTP.Types.Header (HeaderName)
import Network.Wai
import OpenTelemetry.Attributes (ToAttribute (..))
import OpenTelemetry.Attributes.Key (unkey)
import OpenTelemetry.Context
import OpenTelemetry.Instrumentation.Wai (requestContext)
import qualified OpenTelemetry.SemanticConventions as SC
import OpenTelemetry.Trace.Core (Span, addAttribute, addAttributes)


-- | Configuration for the Cloudflare instrumentation middleware.
data CloudflareConfig = CloudflareConfig
  { cfgCaptureLocationHeaders :: !Bool
  {- ^ Capture geo-location headers injected by the \"Add visitor location
  headers\" Managed Transform (@cf-ipcity@, @cf-ipcontinent@,
  @cf-iplatitude@, @cf-iplongitude@, @cf-region@, @cf-region-code@,
  @cf-metro-code@, @cf-postal-code@, @cf-timezone@).

  Default: 'True'.
  -}
  , cfgCaptureBotHeaders :: !Bool
  {- ^ Capture Bot Management headers (@cf-bot-score@, @cf-verified-bot@,
  @cf-ja3-hash@, @cf-ja4@). These are only present on Enterprise plans
  with Bot Management enabled.

  Default: 'False'.
  -}
  , cfgSetClientAddress :: !Bool
  {- ^ Overwrite @client.address@ on the span with the value of
  @CF-Connecting-IP@ (falling back to @True-Client-IP@). The WAI
  middleware sets @client.address@ from 'Network.Wai.remoteHost', which
  is Cloudflare's edge IP when the origin is proxied.

  Default: 'True'.
  -}
  , cfgParseCfVisitor :: !Bool
  {- ^ Parse the @CF-Visitor@ header JSON (@{\"scheme\":\"https\"}@) and
  record @cloudflare.visitor.scheme@ instead of the raw header value.
  Falls back to the raw @http.request.header.cf-visitor@ attribute on
  parse failure.

  Default: 'True'.
  -}
  }
  deriving (Show, Eq)


{- | Sensible defaults: core + location headers captured, bot headers off,
@client.address@ override on, @CF-Visitor@ parsed.
-}
defaultCloudflareConfig :: CloudflareConfig
defaultCloudflareConfig =
  CloudflareConfig
    { cfgCaptureLocationHeaders = True
    , cfgCaptureBotHeaders = False
    , cfgSetClientAddress = True
    , cfgParseCfVisitor = True
    }


-- | Cloudflare instrumentation middleware using 'defaultCloudflareConfig'.
cloudflareInstrumentationMiddleware :: Middleware
cloudflareInstrumentationMiddleware = cloudflareInstrumentationMiddleware' defaultCloudflareConfig


-- | Cloudflare instrumentation middleware with explicit configuration.
cloudflareInstrumentationMiddleware' :: CloudflareConfig -> Middleware
cloudflareInstrumentationMiddleware' cfg app req sendResp = do
  forM_ (requestContext req) $ \ctxt ->
    forM_ (lookupSpan ctxt) $ \span_ -> do
      let hdrs = requestHeaders req
      captureRawHeaders span_ cfg hdrs
      captureSemanticAttributes span_ cfg hdrs

  app req sendResp


-------------------------------------------------------------------------------
-- Raw header capture
-------------------------------------------------------------------------------

{- | Record @http.request.header.*@ attributes for all configured header
groups. Builds a single 'H.HashMap' via fold.
-}
captureRawHeaders :: Span -> CloudflareConfig -> [(HeaderName, BS.ByteString)] -> IO ()
captureRawHeaders span_ cfg hdrs = do
  let active = activeHeaders cfg
      attrs =
        Data.List.foldl'
          ( \acc hn ->
              case Data.List.lookup hn hdrs of
                Nothing -> acc
                Just val -> H.insert (rawAttrKey hn) (toAttribute (T.decodeUtf8 val)) acc
          )
          H.empty
          active
  when (not (H.null attrs)) $
    addAttributes span_ attrs


rawAttrKey :: HeaderName -> Text
rawAttrKey hn = unkey (SC.http_request_header (T.decodeUtf8 (CI.foldedCase hn)))


activeHeaders :: CloudflareConfig -> [HeaderName]
activeHeaders cfg =
  coreHeaders
    <> (if cfgCaptureLocationHeaders cfg then locationHeaders else [])
    <> (if cfgCaptureBotHeaders cfg then botHeaders else [])


coreHeaders :: [HeaderName]
coreHeaders =
  [ "cf-connecting-ip"
  , "true-client-ip"
  , "cf-ray"
  , "cf-ipcountry"
  , "cf-worker"
  , "cf-visitor"
  , "cdn-loop"
  , "cf-ew-via"
  , "cf-connecting-ipv6"
  , "cf-connecting-o2o"
  ]


locationHeaders :: [HeaderName]
locationHeaders =
  [ "cf-ipcity"
  , "cf-ipcontinent"
  , "cf-iplongitude"
  , "cf-iplatitude"
  , "cf-region"
  , "cf-region-code"
  , "cf-metro-code"
  , "cf-postal-code"
  , "cf-timezone"
  ]


botHeaders :: [HeaderName]
botHeaders =
  [ "cf-bot-score"
  , "cf-verified-bot"
  , "cf-ja3-hash"
  , "cf-ja4"
  ]


-------------------------------------------------------------------------------
-- Semantic attribute mapping
-------------------------------------------------------------------------------

-- | Set well-known semantic attributes derived from Cloudflare headers.
captureSemanticAttributes :: Span -> CloudflareConfig -> [(HeaderName, BS.ByteString)] -> IO ()
captureSemanticAttributes span_ cfg hdrs = do
  let headerVal :: HeaderName -> Maybe Text
      headerVal hn = T.decodeUtf8 <$> Data.List.lookup hn hdrs

  when (cfgSetClientAddress cfg) $ do
    -- Prefer CF-Connecting-IP; fall back to True-Client-IP.
    let clientIp = headerVal "cf-connecting-ip" <|> headerVal "true-client-ip"
    forM_ clientIp $ \ip ->
      addAttribute span_ (unkey SC.client_address) ip

  forM_ (headerVal "cf-ray") $ \ray ->
    addAttribute span_ ("cloudflare.ray_id" :: Text) ray

  forM_ (headerVal "cf-ipcountry") $ \cc ->
    addAttribute span_ ("cloudflare.client.geo.country_code" :: Text) cc

  forM_ (headerVal "cf-worker") $ \wk ->
    addAttribute span_ ("cloudflare.worker.upstream_zone" :: Text) wk

  forM_ (headerVal "cf-visitor") $ \vis ->
    when (cfgParseCfVisitor cfg) $
      forM_ (parseCfVisitorScheme vis) $ \scheme ->
        addAttribute span_ ("cloudflare.visitor.scheme" :: Text) scheme


-------------------------------------------------------------------------------
-- CF-Visitor JSON parsing
-------------------------------------------------------------------------------

{- | Extract the @scheme@ value from the @CF-Visitor@ header, which has the
fixed format @{\"scheme\":\"https\"}@ (or @\"http\"@).
-}
parseCfVisitorScheme :: Text -> Maybe Text
parseCfVisitorScheme t =
  case T.stripPrefix "{\"scheme\":\"" (T.strip t) of
    Just rest -> case T.stripSuffix "\"}" rest of
      Just scheme
        | not (T.null scheme) && T.all (\c -> c /= '"' && c /= '\\') scheme ->
            Just scheme
      _ -> Nothing
    Nothing -> Nothing
