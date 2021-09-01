module OpenTelemetry.Context.Class where

-- class Monad m => MonadContext m where
--   type ContextGetResult m
--   askContext :: m (ContextGetResult m)
--   localContext :: (ContextGetResult m -> ContextGetResult m) -> m a -> m a

-- class MonadContext m => MonadAttachContext m where
--   attachContext :: Context -> m ()

-- class (MonadContext m, ContextGetResult m ~ Maybe Context) => MonadDetachContext m where
--   detachContext :: m (Maybe Context)