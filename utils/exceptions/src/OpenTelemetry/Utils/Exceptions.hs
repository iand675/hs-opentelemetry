{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module OpenTelemetry.Utils.Exceptions (inSpanM, inSpanM', inSpanM'') where

import Control.Monad (forM_)
import Control.Monad.Catch (MonadMask, SomeException)
import qualified Control.Monad.Catch as MonadMask
import Control.Monad.IO.Class (MonadIO)
import Data.Text (Text)
import qualified Data.Text as T
import GHC.Exception (SrcLoc (..), getCallStack)
import GHC.Stack (CallStack, callStack)
import GHC.Stack.Types (HasCallStack)

import OpenTelemetry.Context (insertSpan, lookupSpan, removeSpan)
import OpenTelemetry.Context.ThreadLocal (adjustContext)
import qualified OpenTelemetry.Context.ThreadLocal as TraceCore.SpanContext
import qualified OpenTelemetry.Trace as Trace
import OpenTelemetry.Trace.Core (ToAttribute (..), endSpan, recordException, setStatus, whenSpanIsRecording)
import qualified OpenTelemetry.Trace.Core as TraceCore

bracketError' :: MonadMask m => m a -> (Maybe SomeException -> a -> m b) -> (a -> m c) -> m c
bracketError' before after thing = MonadMask.mask $ \restore -> do
  x <- before
  res1 <- MonadMask.try $ restore $ thing x
  case res1 of
    Left (e1 :: SomeException) -> do
      -- explicitly ignore exceptions from after. We know that
      -- no async exceptions were thrown there, so therefore
      -- the stronger exception must come from thing
      --
      -- https://github.com/fpco/safe-exceptions/issues/2
      _ :: Either SomeException b <-
        MonadMask.try $ MonadMask.uninterruptibleMask_ $ after (Just e1) x
      MonadMask.throwM e1
    Right y -> do
      MonadMask.uninterruptibleMask_ $ after Nothing x
      return y

-- | The simplest function for annotating code with trace information.
inSpanM ::
  (MonadIO m, MonadMask m, HasCallStack) =>
  Trace.Tracer ->
  -- | The name of the span. This may be updated later via 'updateName'
  Text ->
  -- | Additional options for creating the span, such as 'SpanKind',
  -- span links, starting attributes, etc.
  Trace.SpanArguments ->
  -- | The action to perform. 'inSpan' will record the time spent on the
  -- action without forcing strict evaluation of the result. Any uncaught
  -- exceptions will be recorded and rethrown.
  m a ->
  m a
inSpanM t n args m = inSpanM'' t callStack n args (const m)

inSpanM' ::
  (MonadIO m, MonadMask m, HasCallStack) =>
  Trace.Tracer ->
  -- | The name of the span. This may be updated later via 'updateName'
  Text ->
  Trace.SpanArguments ->
  (Trace.Span -> m a) ->
  m a
inSpanM' t = inSpanM'' t callStack

inSpanM'' ::
  (MonadMask m, HasCallStack, MonadIO m) =>
  Trace.Tracer ->
  -- | Record the location of the span in the codebase using the provided
  -- callstack for source location info.
  CallStack ->
  -- | The name of the span. This may be updated later via 'updateName'
  Text ->
  Trace.SpanArguments ->
  (Trace.Span -> m a) ->
  m a
inSpanM'' t cs n args f = bracketError' before after (f . snd)
  where
    before = do
      ctx <- TraceCore.SpanContext.getContext
      s <- TraceCore.createSpanWithoutCallStack t ctx n args
      adjustContext (insertSpan s)
      whenSpanIsRecording s $ do
        case getCallStack cs of
          [] -> pure ()
          (fn, loc) : _ -> do
            TraceCore.addAttributes
              s
              [ ("code.function", toAttribute $ T.pack fn),
                ("code.namespace", toAttribute $ T.pack $ srcLocModule loc),
                ("code.filepath", toAttribute $ T.pack $ srcLocFile loc),
                ("code.lineno", toAttribute $ srcLocStartLine loc),
                ("code.package", toAttribute $ T.pack $ srcLocPackage loc)
              ]
      pure (lookupSpan ctx, s)

    after e (parent, s) = do
      forM_ e $ \(MonadMask.SomeException inner) -> do
        setStatus s $ Trace.Error $ T.pack $ MonadMask.displayException inner
        recordException s [] Nothing inner
      endSpan s Nothing
      adjustContext $ \ctx ->
        maybe (removeSpan ctx) (`insertSpan` ctx) parent