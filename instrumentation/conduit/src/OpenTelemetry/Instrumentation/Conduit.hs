module OpenTelemetry.Instrumentation.Conduit where
import Conduit
import OpenTelemetry.Context.ThreadLocal
import OpenTelemetry.Trace.Core hiding (getTracer)
import OpenTelemetry.Trace.Monad (MonadTracer(..))
import Data.Text (Text)
import Control.Exception (throwIO, SomeException)

inSpan
  :: (MonadTracer m, MonadResource m, MonadUnliftIO m) => Text
  -> SpanArguments
  -> (Span -> ConduitM i o m a)
  -> ConduitM i o m a
inSpan n args f = do
  t <- lift getTracer
  ctx <- lift getContext
  bracketP
    (createSpan t ctx n args)
    (`endSpan` Nothing) $ \span_ -> do
      catchC (f span_) $ \e -> do
        liftIO $ do
          recordException span_ [] Nothing (e :: SomeException)
          throwIO e
