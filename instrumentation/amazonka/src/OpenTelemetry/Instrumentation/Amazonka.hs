{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

{- |
Module      :  OpenTelemetry.Instrumentation.Amazonka
Copyright   :  (c) Ian Duncan, 2024
License     :  BSD-3
Description :  OpenTelemetry instrumentation for the Amazonka AWS SDK
Maintainer  :  Ian Duncan
Stability   :  experimental
Portability :  non-portable (GHC extensions)

Provides automatic tracing for all AWS API calls made through the Amazonka
SDK. Installs hooks on an Amazonka 'Env' that create OTel spans per
@send@\/@sendEither@ call, following the
<https://opentelemetry.io/docs/specs/semconv/cloud-providers/aws-sdk/ OTel AWS SDK semantic conventions>.

@
import Amazonka
import OpenTelemetry.Instrumentation.Amazonka ('instrumentEnv')

main :: IO ()
main = 'OpenTelemetry.Trace.withTracerProvider' $ \\tp -> do
  let tracer = 'OpenTelemetry.Trace.Core.makeTracer' tp "my-app" 'OpenTelemetry.Trace.Core.tracerOptions'
  env <- newEnv discover
  let tracedEnv = 'instrumentEnv' tracer env
  runResourceT $ send tracedEnv someRequest
@

Each @send@ call produces a span named @\"Service.Operation\"@ (e.g.,
@\"S3.GetObject\"@, @\"DynamoDB.PutItem\"@) with standard RPC and AWS
attributes.

@since 0.1.0.0
-}
module OpenTelemetry.Instrumentation.Amazonka (
  instrumentEnv,
  instrumentHooks,
) where

import Amazonka.Env (Env, Env' (..))
import Amazonka.Env.Hooks (Finality (..), Hook, Hook_, Hooks (..))
import qualified Amazonka.Types as AWS
import Control.Applicative ((<|>))
import qualified Data.HashMap.Strict as HM
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import Data.Typeable (Proxy (..), Typeable, tyConName, typeRep, typeRepTyCon)
import qualified Network.HTTP.Client as HTTP
import qualified Network.HTTP.Types.Status as HTTP
import OpenTelemetry.Attributes (toAttribute)
import OpenTelemetry.Context (insertSpan, lookupSpan)
import OpenTelemetry.Context.ThreadLocal (getAndAdjustContext)
import OpenTelemetry.Trace.Core (
  Span,
  SpanArguments (..),
  SpanKind (Client),
  SpanStatus (Error),
  Tracer,
  addAttributes,
  createSpanWithoutCallStack,
  defaultSpanArguments,
  endSpan,
  getContext,
  setStatus,
 )


{- | Add OpenTelemetry tracing hooks to an Amazonka 'Env'.

All subsequent @send@ and @sendEither@ calls through the returned 'Env'
will automatically create spans with AWS SDK semantic convention attributes.

The tracing hooks compose with any existing hooks on the 'Env' — they do
not replace them.

@since 0.1.0.0
-}
instrumentEnv :: Tracer -> Env -> Env
instrumentEnv tracer env =
  env {hooks = instrumentHooks tracer (hooks env)}


{- | Install tracing hooks on an Amazonka 'Hooks' value.

Lower-level than 'instrumentEnv' — use this if you need fine-grained
control over hook composition.

@since 0.1.0.0
-}
instrumentHooks :: Tracer -> Hooks -> Hooks
instrumentHooks tracer baseHooks =
  baseHooks
    { configuredRequest = tracingConfiguredRequest tracer (configuredRequest baseHooks)
    , clientResponse = tracingClientResponse (clientResponse baseHooks)
    , response = tracingResponse (response baseHooks)
    , error = tracingError (error baseHooks)
    }


tracingConfiguredRequest
  :: forall a
   . (AWS.AWSRequest a, Typeable a)
  => Tracer
  -> Hook (AWS.Request a)
  -> Hook (AWS.Request a)
tracingConfiguredRequest tracer baseHook env req = do
  let svcAbbrev = TE.decodeUtf8 $ AWS.toBS (AWS.abbrev (AWS.service req))
      opName = T.pack $ tyConName $ typeRepTyCon $ typeRep (Proxy @a)
      spanName = svcAbbrev <> "." <> opName
      region = AWS.fromRegion (Amazonka.Env.region env)
      endpoint_ = AWS.endpoint (AWS.service req) (Amazonka.Env.region env)
      host = TE.decodeUtf8 (AWS.host endpoint_)

  ctx <- getContext
  span <-
    createSpanWithoutCallStack tracer ctx spanName $
      defaultSpanArguments
        { kind = Client
        , attributes =
            HM.fromList
              [ ("rpc.system", toAttribute ("aws-api" :: T.Text))
              , ("rpc.service", toAttribute svcAbbrev)
              , ("rpc.method", toAttribute opName)
              , ("cloud.region", toAttribute region)
              , ("server.address", toAttribute host)
              ]
        }

  _ <- getAndAdjustContext (insertSpan span)
  baseHook env req


tracingClientResponse
  :: forall a
   . (AWS.AWSRequest a, Typeable a)
  => Hook_ (AWS.Request a, AWS.ClientResponse ())
  -> Hook_ (AWS.Request a, AWS.ClientResponse ())
tracingClientResponse baseHook env arg@(_req, resp) = do
  ctx <- getContext
  case lookupSpan ctx of
    Just span -> do
      let sc = HTTP.statusCode (HTTP.responseStatus resp)
          mReqId = requestIdFromHeaders (HTTP.responseHeaders resp)
          attrs =
            HM.fromList $
              ("http.response.status_code", toAttribute sc)
                : case mReqId of
                    Just reqId -> [("aws.request_id", toAttribute reqId)]
                    Nothing -> []
      addAttributes span attrs
    Nothing -> pure ()
  baseHook env arg


tracingResponse
  :: forall a
   . (AWS.AWSRequest a, Typeable a)
  => Hook_ (AWS.Request a, AWS.ClientResponse (AWS.AWSResponse a))
  -> Hook_ (AWS.Request a, AWS.ClientResponse (AWS.AWSResponse a))
tracingResponse baseHook env arg = do
  ctx <- getContext
  case lookupSpan ctx of
    Just span -> endSpan span Nothing
    Nothing -> pure ()
  baseHook env arg


tracingError
  :: forall a
   . (AWS.AWSRequest a, Typeable a)
  => Hook_ (Finality, AWS.Request a, AWS.Error)
  -> Hook_ (Finality, AWS.Request a, AWS.Error)
tracingError baseHook env arg@(finality, _req, err) = do
  case finality of
    Final -> do
      ctx <- getContext
      case lookupSpan ctx of
        Just span -> do
          let errDesc = describeError err
              attrs =
                HM.fromList $
                  ("error.type", toAttribute errDesc)
                    : case extractServiceRequestId err of
                        Just reqId -> [("aws.request_id", toAttribute reqId)]
                        Nothing -> []
          addAttributes span attrs
          setStatus span (Error errDesc)
          endSpan span Nothing
        Nothing -> pure ()
    NotFinal -> pure ()
  baseHook env arg


requestIdFromHeaders :: [HTTP.Header] -> Maybe T.Text
requestIdFromHeaders headers =
  fmap TE.decodeUtf8 (lookup "x-amzn-requestid" headers)
    <|> fmap TE.decodeUtf8 (lookup "x-amz-request-id" headers)


extractServiceRequestId :: AWS.Error -> Maybe T.Text
extractServiceRequestId (AWS.ServiceError svcErr) =
  AWS.fromRequestId <$> AWS.requestId svcErr
extractServiceRequestId _ = Nothing


describeError :: AWS.Error -> T.Text
describeError (AWS.TransportError _) = "transport_error"
describeError (AWS.SerializeError serr) =
  T.pack (AWS.message (serr :: AWS.SerializeError))
describeError (AWS.ServiceError svcErr) =
  let AWS.ErrorCode code = AWS.code svcErr
  in code
