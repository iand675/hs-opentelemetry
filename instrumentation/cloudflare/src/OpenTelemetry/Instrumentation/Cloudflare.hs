{-# LANGUAGE OverloadedLists #-}
{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.Instrumentation.Cloudflare where

import Control.Monad (forM_)
import qualified Data.CaseInsensitive as CI
import qualified Data.HashMap.Strict as H
import qualified Data.List
import Data.Maybe
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import Network.Wai
import OpenTelemetry.Attributes (PrimitiveAttribute (..), ToAttribute (..))
import OpenTelemetry.Attributes.Key (unkey)
import OpenTelemetry.Context
import OpenTelemetry.Instrumentation.Wai (requestContext)
import qualified OpenTelemetry.SemanticConventions as SC
import OpenTelemetry.Trace.Core (addAttributes)


cloudflareInstrumentationMiddleware :: Middleware
cloudflareInstrumentationMiddleware app req sendResp = do
  let mCtxt = requestContext req
  forM_ mCtxt $ \ctxt -> do
    forM_ (lookupSpan ctxt) $ \span_ -> do
      addAttributes span_ $
        H.unions $
          fmap
            ( \hn -> case Data.List.lookup hn $ requestHeaders req of
                Nothing -> []
                Just val ->
                  [
                    ( unkey (SC.http_request_header (T.decodeUtf8 (CI.foldedCase hn)))
                    , toAttribute $ T.decodeUtf8 val
                    )
                  ]
            )
            headers
  app req sendResp
  where
    headers =
      [ "cf-connecting-ip"
      , "true-client-ip"
      , "cf-ray"
      , -- CF-Visitor
        "cf-ipcountry"
      , -- CDN-Loop
        "cf-worker"
      ]
