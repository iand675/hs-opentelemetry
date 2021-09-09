{- | Offer a few options for HTTP instrumentation

- Add attributes via 'Request' and 'Response' to an existing span (Best)
- Use internals to instrument a particular callsite using modifyRequest, modifyResponse (Next best)
- Provide a middleware to pull from the thread-local state (okay)
- Modify the global manager to pull from the thread-local state (least good, can't be helped sometimes)
-}
module OpenTelemetry.Instrumentation.HttpClient where
import Control.Monad.IO.Class
import OpenTelemetry.Context (Context)
import OpenTelemetry.Context.Propagators
import OpenTelemetry.Trace
import Network.HTTP.Client
import Network.HTTP.Types
-- TODO, Manager really needs proper hooks for this.

instrumentRequest
  :: MonadIO m
  => Propagator Context RequestHeaders ResponseHeaders
  -> Context
  -> Request
  -> m Request
instrumentRequest p ctxt req = do
  hdrs <- inject p ctxt $ requestHeaders req
  pure $ req
    { requestHeaders = hdrs
    }


instrumentResponse
  :: MonadIO m
  => Propagator Context RequestHeaders ResponseHeaders
  -> Context
  -> Response a
  -> m Context
instrumentResponse p ctxt resp = do
  extract p (responseHeaders resp) ctxt