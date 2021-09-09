{-# LANGUAGE OverloadedStrings #-}
module OpenTelemetry.Instrumentation.Wai 
  ( newOpenTelemetryWaiMiddleware
  , requestContext
  ) where

import Data.Maybe
import qualified Data.Vault.Lazy as Vault
import Network.HTTP.Types
import Network.Wai
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Context.ThreadLocal
import OpenTelemetry.Context.Propagators
import OpenTelemetry.Trace
import System.IO.Unsafe

newOpenTelemetryWaiMiddleware 
  :: TracerProvider 
  -- TODO propagator parameter 
  -> Propagator Context.Context RequestHeaders ResponseHeaders
  -> IO Middleware
newOpenTelemetryWaiMiddleware tp propagator = do
  waiTracer <- getTracer 
    tp
    "opentelemetry-instrumentation-wai" 
    (TracerOptions Nothing)
  pure $ middleware waiTracer
  where
    middleware :: Tracer -> Middleware
    middleware tracer app req sendResp = do
      -- TODO baggage, span context
      ctxt <- extract propagator (requestHeaders req) Context.empty
      requestSpan <- createSpan tracer (Just ctxt) "http.server" $ emptySpanArguments
        { startingKind = Server
        }
      -- TODO, don't like attaching and also putting it in the request vault, users can do
      -- this or it can be a separate middleware
      -- attachContext $ Context.insertSpan requestSpan ctxt
      let req' = req 
            { vault = Vault.insert 
                contextKey 
                (Context.insertSpan requestSpan ctxt) 
                (vault req) 
            }
      app req' $ \resp -> do
        ctxt' <- fromMaybe Context.empty <$> detachContext
        hs <- inject propagator (Context.insertSpan requestSpan ctxt') []
        -- injecting the span here, but is that actually useful??
        let resp' = mapResponseHeaders (hs ++) resp
        -- TODO need to propagate baggage
        respReceived <- sendResp resp'
        ts <- getTimestamp
        -- TODO Annotate results here
        endSpan requestSpan (Just ts)
        pure respReceived

contextKey :: Vault.Key Context.Context
contextKey = unsafePerformIO Vault.newKey
{-# NOINLINE contextKey #-}

requestContext :: Request -> Maybe Context.Context
requestContext = 
  Vault.lookup contextKey . 
  vault