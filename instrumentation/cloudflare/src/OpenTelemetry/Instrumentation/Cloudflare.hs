{-# LANGUAGE OverloadedStrings #-}
module OpenTelemetry.Instrumentation.Cloudflare where

import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import Network.Wai
import OpenTelemetry.Attributes (PrimitiveAttribute(..), ToAttribute (..))
import OpenTelemetry.Context
import OpenTelemetry.Instrumentation.Wai (requestContext)
import OpenTelemetry.Trace.Core (addAttributes)
import Control.Monad (forM_)
import Data.Maybe
import qualified Data.List
import qualified Data.CaseInsensitive as CI

cloudflareInstrumentationMiddleware :: Middleware
cloudflareInstrumentationMiddleware app req sendResp = do
  let mCtxt = requestContext req
  forM_ mCtxt $ \ctxt -> do
    forM_ (lookupSpan ctxt) $ \span_ -> do
      addAttributes span_ $ concatMap
        (\hn -> case Data.List.lookup hn $ requestHeaders req of
            Nothing -> []
            Just val -> 
              [ ("http.request.header." <> T.decodeUtf8 (CI.foldedCase hn)
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
      -- CF-Visitor
      , "cf-ipcountry"
      -- CDN-Loop
      , "cf-worker"
      ]