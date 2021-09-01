{-# LANGUAGE RecordWildCards #-}
module OpenTelemetry.Trace.SpanProcessors.Simple
  ( SimpleProcessorConfig(..)
  , simpleProcessor
  ) where

import Control.Exception
import Control.Concurrent.Async
import Control.Concurrent.Chan.Unagi
import Control.Monad
import Data.Functor.Identity
import OpenTelemetry.Trace.SpanProcessor
import OpenTelemetry.Trace.Types (Span)
import qualified OpenTelemetry.Trace.SpanExporter as Exporter

newtype SimpleProcessorConfig = SimpleProcessorConfig
  { exporter :: Exporter.SpanExporter
  }

simpleProcessor :: SimpleProcessorConfig -> IO SpanProcessor
simpleProcessor SimpleProcessorConfig{..} = do
  (inChan, outChan) <- newChan :: IO (InChan Span, OutChan Span)
  exportWorker <- async $ forever $ do
    -- TODO, masking vs bracket here, not sure what's the right choice
    span <- readChanOnException outChan (>>= writeChan inChan)
    mask_ (exporter `Exporter.export` Identity span)

  pure $ SpanProcessor
    { onStart = \_ _ -> pure ()
    , onEnd = writeChan inChan 
    , shutdown = async $ mask $ \restore -> do
        cancel exportWorker
        -- TODO handle timeouts
        restore (shutdownProcessor outChan `finally` Exporter.shutdown exporter)
        pure ShutdownSuccess
    , forceFlush = pure ()
    }

  where
    shutdownProcessor outChan = do
      (Element m, _) <- tryReadChan outChan
      mSpan <- m
      case mSpan of 
        Nothing -> pure ()
        Just span -> do
          exporter `Exporter.export` Identity span
          shutdownProcessor outChan

