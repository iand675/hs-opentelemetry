module OpenTelemetry.Instrumentation.Conduit where
import Conduit
import OpenTelemetry.Context.ThreadLocal
import OpenTelemetry.Trace.Core hiding (getTracer)
import Data.Text (Text)
import Control.Exception (throwIO, SomeException)

inSpan
  :: (MonadResource m, MonadUnliftIO m) => Tracer
  -> Text
  -> SpanArguments
  -> (Span -> ConduitM i o m a)
  -> ConduitM i o m a
inSpan t n args f = do
  ctx <- lift getContext
  bracketP
    (createSpan t ctx n args)
    (`endSpan` Nothing) $ \span_ -> do
      catchC (f span_) $ \e -> do
        liftIO $ do
          recordException span_ [] Nothing (e :: SomeException)
          throwIO e
