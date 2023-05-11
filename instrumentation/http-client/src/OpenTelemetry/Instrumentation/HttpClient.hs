{-# LANGUAGE OverloadedStrings #-}

{- | Offer a few options for HTTP instrumentation

- Add attributes via 'Request' and 'Response' to an existing span (Best)
- Use internals to instrument a particular callsite using modifyRequest, modifyResponse (Next best)
- Provide a middleware to pull from the thread-local state (okay)
- Modify the global manager to pull from the thread-local state (least good, can't be helped sometimes)
-}
module OpenTelemetry.Instrumentation.HttpClient (
  withResponse,
  httpLbs,
  httpNoBody,
  responseOpen,
  httpClientInstrumentationConfig,
  HttpClientInstrumentationConfig (..),
  module X,
) where

import Control.Monad.IO.Class (MonadIO (..))
import qualified Data.ByteString.Lazy as L
import GHC.Stack
import Network.HTTP.Client as X hiding (httpLbs, httpNoBody, responseOpen, withResponse)
import qualified Network.HTTP.Client as Client
import OpenTelemetry.Context.ThreadLocal
import OpenTelemetry.Instrumentation.HttpClient.Raw (
  HttpClientInstrumentationConfig (..),
  httpClientInstrumentationConfig,
  httpTracerProvider,
  instrumentRequest,
  instrumentResponse,
 )
import OpenTelemetry.Trace.Core (
  SpanArguments (kind),
  SpanKind (Client),
  addAttributesToSpanArguments,
  callerAttributes,
  defaultSpanArguments,
  inSpan'',
 )
import UnliftIO (MonadUnliftIO, askRunInIO)


spanArgs :: SpanArguments
spanArgs = defaultSpanArguments {kind = Client}


{- | Instrumented variant of @Network.HTTP.Client.withResponse@

 Perform a @Request@ using a connection acquired from the given @Manager@,
 and then provide the @Response@ to the given function. This function is
 fully exception safe, guaranteeing that the response will be closed when the
 inner function exits. It is defined as:

 > withResponse req man f = bracket (responseOpen req man) responseClose f

 It is recommended that you use this function in place of explicit calls to
 'responseOpen' and 'responseClose'.

 You will need to use functions such as 'brRead' to consume the response
 body.
-}
withResponse
  :: (MonadUnliftIO m, HasCallStack)
  => HttpClientInstrumentationConfig
  -> Client.Request
  -> Client.Manager
  -> (Client.Response Client.BodyReader -> m a)
  -> m a
withResponse httpConf req man f = do
  t <- httpTracerProvider
  inSpan'' t "withResponse" (addAttributesToSpanArguments callerAttributes spanArgs) $ \_wrSpan -> do
    ctxt <- getContext
    -- TODO would like to capture the req/resp time specifically
    -- inSpan "http.request" (defaultSpanArguments { startingKind = Client }) $ \httpReqSpan -> do
    req' <- instrumentRequest httpConf ctxt req
    runInIO <- askRunInIO
    liftIO $ Client.withResponse req' man $ \resp -> do
      _ <- instrumentResponse httpConf ctxt resp
      runInIO $ f resp


{- | A convenience wrapper around 'withResponse' which reads in the entire
 response body and immediately closes the connection. Note that this function
 performs fully strict I\/O, and only uses a lazy ByteString in its response
 for memory efficiency. If you are anticipating a large response body, you
 are encouraged to use 'withResponse' and 'brRead' instead.
-}
httpLbs :: (MonadUnliftIO m, HasCallStack) => HttpClientInstrumentationConfig -> Client.Request -> Client.Manager -> m (Client.Response L.ByteString)
httpLbs httpConf req man = do
  t <- httpTracerProvider
  inSpan'' t "httpLbs" (addAttributesToSpanArguments callerAttributes spanArgs) $ \_ -> do
    ctxt <- getContext
    req' <- instrumentRequest httpConf ctxt req
    resp <- liftIO $ Client.httpLbs req' man
    _ <- instrumentResponse httpConf ctxt resp
    pure resp


{- | A convenient wrapper around 'withResponse' which ignores the response
 body. This is useful, for example, when performing a HEAD request.
-}
httpNoBody :: (MonadUnliftIO m, HasCallStack) => HttpClientInstrumentationConfig -> Client.Request -> Client.Manager -> m (Client.Response ())
httpNoBody httpConf req man = do
  t <- httpTracerProvider
  inSpan'' t "httpNoBody" (addAttributesToSpanArguments callerAttributes spanArgs) $ \_ -> do
    ctxt <- getContext
    req' <- instrumentRequest httpConf ctxt req
    resp <- liftIO $ Client.httpNoBody req' man
    _ <- instrumentResponse httpConf ctxt resp
    pure resp


{- | The most low-level function for initiating an HTTP request.

 The first argument to this function gives a full specification
 on the request: the host to connect to, whether to use SSL,
 headers, etc. Please see 'Request' for full details.  The
 second argument specifies which 'Manager' should be used.

 This function then returns a 'Response' with a
 'BodyReader'.  The 'Response' contains the status code
 and headers that were sent back to us, and the
 'BodyReader' contains the body of the request.  Note
 that this 'BodyReader' allows you to have fully
 interleaved IO actions during your HTTP download, making it
 possible to download very large responses in constant memory.

 An important note: the response body returned by this function represents a
 live HTTP connection. As such, if you do not use the response body, an open
 socket will be retained indefinitely. You must be certain to call
 'responseClose' on this response to free up resources.

 This function automatically performs any necessary redirects, as specified
 by the 'redirectCount' setting.

 When implementing a (reverse) proxy using this function or relating
 functions, it's wise to remove Transfer-Encoding:, Content-Length:,
 Content-Encoding: and Accept-Encoding: from request and response
 headers to be relayed.
-}
responseOpen :: (MonadUnliftIO m, HasCallStack) => HttpClientInstrumentationConfig -> Client.Request -> Client.Manager -> m (Client.Response Client.BodyReader)
responseOpen httpConf req man = do
  t <- httpTracerProvider
  inSpan'' t "responseOpen" (addAttributesToSpanArguments callerAttributes spanArgs) $ \_ -> do
    ctxt <- getContext
    req' <- instrumentRequest httpConf ctxt req
    resp <- liftIO $ Client.responseOpen req' man
    _ <- instrumentResponse httpConf ctxt resp
    pure resp
