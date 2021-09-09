{-# LANGUAGE OverloadedStrings #-}
module OpenTelemetry.Instrumentation.Yesod where

import Control.Monad.Reader (asks, local)
import Data.Maybe (fromMaybe)
import Lens.Micro
import OpenTelemetry.Context (HasContext(..))
import qualified OpenTelemetry.Context as Context
import OpenTelemetry.Trace
import OpenTelemetry.Trace.Monad
import OpenTelemetry.Instrumentation.Wai
import Yesod.Core
import Yesod.Core.Types

handlerEnvL :: Lens' (HandlerData child site) (RunHandlerEnv child site)
handlerEnvL = lens handlerEnv (\h e -> h { handlerEnv = e })
{-# INLINE handlerEnvL #-}

rheSiteL :: Lens' (RunHandlerEnv child site) site
rheSiteL = lens rheSite (\rhe new -> rhe { rheSite = new })
{-# INLINE rheSiteL #-}

instance HasTracerProvider site => HasTracerProvider (RunHandlerEnv child site) where
  tracerProviderL = rheSiteL . tracerProviderL

instance HasTracerProvider site => HasTracerProvider (HandlerData child site) where
  tracerProviderL = handlerEnvL . tracerProviderL

instance HasContext site => HasContext (RunHandlerEnv child site) where
  contextL = rheSiteL . contextL

instance HasContext site => HasContext (HandlerData child site) where
  contextL = handlerEnvL . contextL

instance HasTracerProvider site => MonadTracerProvider (HandlerFor site) where
  getTracerProvider = asks (^. tracerProviderL)

instance (HasTracerProvider site) => MonadTracer (HandlerFor site) where
  getTracer = do
    tp <- getTracerProvider
    OpenTelemetry.Trace.getTracer tp "otel-instrumentation-yesod" tracerOptions

instance HasContext site => MonadGetContext (HandlerFor site) where
  getContext = asks (^. contextL)

instance HasContext site => MonadLocalContext (HandlerFor site) where
  localContext f = local (contextL %~ f)

instance MonadBracketError (HandlerFor site) where
  bracketError = bracketErrorUnliftIO

openTelemetryYesodMiddleware 
  :: (HasTracerProvider site, HasContext site, ToTypedContent res)
  => HandlerFor site res
  -> HandlerFor site res
openTelemetryYesodMiddleware m = do
  tracer <- OpenTelemetry.Trace.Monad.getTracer
  -- TODO, better handle case where wai middleware isn't installed?
  req <- waiRequest
  let mctxt = requestContext req
  localContext (<> fromMaybe Context.empty mctxt) $ do
    let args = emptySpanArguments
          { startingKind = maybe Server (const Internal) mctxt
          }
    inSpan "yesod.handler" args $ \s -> do
      localContext 
        (\c -> Context.insertSpan s (c <> fromMaybe Context.empty mctxt))
        m
