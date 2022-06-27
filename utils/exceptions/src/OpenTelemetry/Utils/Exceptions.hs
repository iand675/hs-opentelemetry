{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.Utils.Exceptions (inSpanM, inSpanM', inSpanM'') where


import Control.Monad.Catch (MonadMask, SomeException)
import qualified Control.Monad.Catch as MonadMask
import Data.Functor (($>))
import qualified Data.Text as T
import GHC.Stack (callStack, withFrozenCallStack, CallStack)
import GHC.Stack.Types (HasCallStack)
import Prelude hiding (log)
import qualified OpenTelemetry.Trace as Trace
import qualified OpenTelemetry.Trace.Core as TraceCore
import Data.Text (Text)
import qualified OpenTelemetry.Context.ThreadLocal as TraceCore.SpanContext
import OpenTelemetry.Context (insertSpan, lookupSpan, removeSpan)
import OpenTelemetry.Context.ThreadLocal (adjustContext)
import OpenTelemetry.Trace.Core (whenSpanIsRecording, ToAttribute (..), setStatus, recordException, endSpan)
import GHC.Exception (getCallStack, SrcLoc (..))
import Control.Monad (forM_)
import Control.Monad.IO.Class (MonadIO)

-- logS :: (Show a, WithLog env Message m) => Severity -> T.Text -> a -> m ()
-- logS sv prefix = withFrozenCallStack . log sv . (prefix <>) . T.pack . show

-- logDebugS, logInfoS, logErrorS :: (Show a, WithLog env Message m) => T.Text -> a -> m ()
-- logDebugS = withFrozenCallStack (logS Debug)
-- logInfoS = withFrozenCallStack (logS Info)
-- logErrorS = withFrozenCallStack (logS Error)

-- logM :: (Show a, Monad m, WithLog env Message m) => Severity -> T.Text -> m a -> m a
-- logM sv prefix ma = do
--   a <- ma
--   log sv . (prefix <>) . T.pack . show $ a
--   return a

-- logDebugM, logInfoM, logErrorM :: (Show a, Monad m, WithLog env Message m) => T.Text -> m a -> m a
-- logDebugM = withFrozenCallStack (logM Debug)
-- logInfoM = withFrozenCallStack (logM Info)
-- logErrorM = withFrozenCallStack (logM Error)

-- logEither :: (Monad m, WithLog env Message m, Show e, Show a) => T.Text -> Either e a -> m ()
-- logEither t = withFrozenCallStack (either (logErrorS t) (logInfoS t))

-- logErrorMaybe :: (Monad m, WithLog env Message m) => T.Text -> Maybe a -> m (Maybe a)
-- logErrorMaybe txt Nothing = withFrozenCallStack (logError txt $> Nothing)
-- logErrorMaybe _ mb = pure mb

-- logInfoIO :: HasCallStack => T.Text -> IO ()
-- logInfoIO txt =
--   let LogAction log_ = richMessageAction
--    in log_ $ Msg {msgSeverity = Info, msgStack = callStack, msgText = txt}

-- mbToEither :: e -> Maybe a -> Either e a
-- mbToEither _ (Just a) = Right a
-- mbToEither e Nothing = Left e

-- headV :: V.Vector a -> Maybe a
-- headV v = fst <$> V.uncons v

-- showTx :: (Show a) => a -> T.Text
-- showTx = T.pack . show

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
      _ <- MonadMask.uninterruptibleMask_ $ after Nothing x
      return y


-------------------------------------------------------------------
-- Adapted from Tracing library. We need to contribute this back.
-------------------------------------------------------------------

-- | The simplest function for annotating code with trace information.
--
-- @since 0.0.1.0
inSpanM
  :: (MonadIO m, MonadMask m, HasCallStack)
  => Trace.Tracer
  -> Text
  -- ^ The name of the span. This may be updated later via 'updateName'
  -> Trace.SpanArguments
  -- ^ Additional options for creating the span, such as 'SpanKind',
  -- span links, starting attributes, etc.
  -> m a
  -- ^ The action to perform. 'inSpan' will record the time spent on the
  -- action without forcing strict evaluation of the result. Any uncaught
  -- exceptions will be recorded and rethrown.
  -> m a
inSpanM t n args m = inSpanM'' t callStack n args (const m)

inSpanM'
  :: (MonadIO m, MonadMask m, HasCallStack)
  => Trace.Tracer
  -> Text
  -- ^ The name of the span. This may be updated later via 'updateName'
  -> Trace.SpanArguments
  -> (Trace.Span -> m a)
  -> m a
inSpanM' t = inSpanM'' t callStack

inSpanM''
  :: (MonadMask m, HasCallStack, MonadIO m)
  => Trace.Tracer
  -> CallStack
  -- ^ Record the location of the span in the codebase using the provided
  -- callstack for source location info.
  -> Text
  -- ^ The name of the span. This may be updated later via 'updateName'
  -> Trace.SpanArguments
  -> (Trace.Span -> m a)
  -> m a
inSpanM'' t cs n args f = do
  bracketError'
    (do
      ctx <- TraceCore.SpanContext.getContext
      s <- TraceCore.createSpanWithoutCallStack t ctx n args
      adjustContext (insertSpan s)
      whenSpanIsRecording s $ do
        case getCallStack cs of
          [] -> pure ()
          (fn, loc):_ -> do
            TraceCore.addAttributes s
              [ ("code.function", toAttribute $ T.pack fn)
              , ("code.namespace", toAttribute $ T.pack $ srcLocModule loc)
              , ("code.filepath", toAttribute $ T.pack $ srcLocFile loc)
              , ("code.lineno", toAttribute $ srcLocStartLine loc)
              , ("code.package", toAttribute $ T.pack $ srcLocPackage loc)
              ]
      pure (lookupSpan ctx, s)
    )
    (\e (parent, s) -> do
      forM_ e $ \(MonadMask.SomeException inner) -> do
        setStatus s $ Trace.Error $ T.pack $ MonadMask.displayException inner
        recordException s [] Nothing inner
      endSpan s Nothing
      adjustContext $ \ctx ->
        maybe (removeSpan ctx) (`insertSpan` ctx) parent
    )
    (\(_, s) -> f s)
