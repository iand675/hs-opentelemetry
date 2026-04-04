{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}

{- |
Module      :  OpenTelemetry.Instrumentation.Gogol
Copyright   :  (c) Ian Duncan, 2024
License     :  BSD-3
Description :  OpenTelemetry instrumentation for the Gogol Google Cloud SDK
Maintainer  :  Ian Duncan
Stability   :  experimental
Portability :  non-portable (GHC extensions)

Tracing wrappers for Gogol Google Cloud API calls. Unlike Amazonka, Gogol
does not have a hooks API, so instrumentation is provided as wrapper
functions that take the underlying @send@ as a parameter.

@
import Gogol
import OpenTelemetry.Instrumentation.Gogol ('tracedSend')

-- Instead of: send req
-- Write:
result <- runGoogle env $ 'tracedSend' tracer send req
@

Each call produces a span named @\"ServiceId.Operation\"@ (e.g.,
@\"storage.ObjectsGet\"@, @\"compute.InstancesList\"@) with standard RPC
attributes.

@since 0.1.0.0
-}
module OpenTelemetry.Instrumentation.Gogol (
  tracedSend,
  tracedSendEither,
) where

import Control.Exception (SomeException)
import Control.Monad.Catch (MonadCatch, catch, throwM)
import Control.Monad.IO.Class (MonadIO, liftIO)
import Control.Monad.Trans.Resource (MonadResource)
import qualified Data.HashMap.Strict as HM
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import Data.Typeable (Proxy (..), Typeable, tyConName, typeRep, typeRepTyCon)
import qualified Gogol.Types as G
import qualified Network.HTTP.Types.Status as HTTP
import OpenTelemetry.Attributes (toAttribute)
import OpenTelemetry.Context (insertSpan)
import OpenTelemetry.Context.ThreadLocal (getAndAdjustContext, getContext)
import OpenTelemetry.Trace.Core (
  Span,
  SpanArguments (..),
  SpanKind (Client),
  SpanStatus (..),
  Tracer,
  addAttributes,
  createSpanWithoutCallStack,
  defaultSpanArguments,
  endSpan,
  setStatus,
 )


{- | Traced version of Gogol's @send@. Creates a client span for each
Google API call with RPC semantic convention attributes.

The span is named @\"ServiceId.TypeName\"@ — e.g., @\"storage.ObjectsGet\"@.

@since 0.1.0.0
-}
tracedSend
  :: forall a m
   . (MonadResource m, MonadIO m, MonadCatch m, G.GoogleRequest a, Typeable a)
  => Tracer
  -> (a -> m (G.Rs a))
  -> a
  -> m (G.Rs a)
tracedSend tracer sendFn req = do
  s <- liftIO $ startSpan tracer req
  result <-
    sendFn req `catch` \(e :: SomeException) -> do
      liftIO $ do
        let errText = T.pack (show e)
        addAttributes s $ HM.fromList [("error.type", toAttribute errText)]
        setStatus s (Error errText)
        endSpan s Nothing
      throwM e
  liftIO $ endSpan s Nothing
  pure result


{- | Traced version of Gogol's @sendEither@. Preserves the 'Either'
result, recording errors on the span without throwing.

@since 0.1.0.0
-}
tracedSendEither
  :: forall a m
   . (MonadResource m, MonadIO m, MonadCatch m, G.GoogleRequest a, Typeable a)
  => Tracer
  -> (a -> m (Either G.Error (G.Rs a)))
  -> a
  -> m (Either G.Error (G.Rs a))
tracedSendEither tracer sendFn req = do
  s <- liftIO $ startSpan tracer req
  result <- sendFn req
  liftIO $ case result of
    Right _ -> endSpan s Nothing
    Left err -> do
      recordError s err
      endSpan s Nothing
  pure result


startSpan
  :: forall a
   . (G.GoogleRequest a, Typeable a)
  => Tracer
  -> a
  -> IO Span
startSpan tracer req = do
  let client = G.requestClient req
      svc = G._cliService client
      G.ServiceId svcId = G._svcId svc
      opName = T.pack $ tyConName $ typeRepTyCon $ typeRep (Proxy @a)
      spanName = svcId <> "." <> opName
      host = TE.decodeUtf8 (G._svcHost svc)

  ctx <- getContext
  s <-
    createSpanWithoutCallStack tracer ctx spanName $
      defaultSpanArguments
        { kind = Client
        , attributes =
            HM.fromList
              [ ("rpc.system", toAttribute ("gcp-api" :: T.Text))
              , ("rpc.service", toAttribute svcId)
              , ("rpc.method", toAttribute opName)
              , ("server.address", toAttribute host)
              , ("cloud.provider", toAttribute ("gcp" :: T.Text))
              ]
        }

  _ <- getAndAdjustContext (insertSpan s)
  pure s


recordError :: Span -> G.Error -> IO ()
recordError s err = do
  let errDesc = describeError err
      statusAttr sc = [("http.response.status_code", toAttribute (HTTP.statusCode sc))]
      attrs = case err of
        G.ServiceError svcErr -> statusAttr (G._serviceStatus svcErr)
        G.SerializeError serr -> statusAttr (G._serializeStatus serr)
        G.TransportError _ -> []
  addAttributes s $ HM.fromList $ ("error.type", toAttribute errDesc) : attrs
  setStatus s (Error errDesc)


describeError :: G.Error -> T.Text
describeError (G.TransportError _) = "transport_error"
describeError (G.SerializeError serr) = T.pack (G._serializeMessage serr)
describeError (G.ServiceError svcErr) =
  "http_" <> T.pack (show (HTTP.statusCode (G._serviceStatus svcErr)))
