{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

{- |
Module      : OpenTelemetry.Instrumentation.Katip
Copyright   : (c) Ian Duncan, 2021-2026
License     : BSD-3
Description : Bridge Katip structured logging to OpenTelemetry Logs
Stability   : experimental

Provides a Katip 'K.Scribe' that forwards structured log items to the
OpenTelemetry Logs pipeline. Because Katip items carry rich structured data
(JSON payloads, namespaces, thread IDs, source locations), the bridge
preserves all of it as OTel log record attributes.

* __Trace correlation is automatic__: log records emitted inside an
  'OpenTelemetry.Trace.Core.inSpan' block carry the active trace\/span IDs.

* __Structured payloads preserved__: the 'K.LogItem' payload is serialized
  to JSON and stored under @log.payload.*@ attributes.

* __Severity mapping__: Katip 'K.Severity' maps naturally to OTel severity
  (DebugS→Debug, InfoS→Info, WarningS→Warn, ErrorS→Error,
  CriticalS→Fatal, etc.).

= Usage

@
import qualified Katip as K
import OpenTelemetry.Log.Core
import OpenTelemetry.Instrumentation.Katip

main :: IO ()
main = do
  lp <- getGlobalLoggerProvider
  let logger = makeLogger lp (instrumentationLibrary \"my-app\" \"1.0.0\")
  scribe <- makeOTelScribe logger (K.permitItem K.InfoS) K.V2
  le <- K.registerScribe \"otel\" scribe K.defaultScribeSettings =<< K.initLogEnv \"MyApp\" \"production\"
  K.runKatipContextT le () \"main\" $ do
    K.logTM K.InfoS \"Hello from Katip via OTel!\"
@

@since 0.1.0.0
-}
module OpenTelemetry.Instrumentation.Katip (
  makeOTelScribe,
  katipSeverity,
) where

import Control.Monad (void)
import Data.Aeson (Value (..))
import qualified Data.Aeson.Key as Key
import qualified Data.Aeson.KeyMap as KM
import qualified Data.HashMap.Strict as H
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.Lazy as TL
import qualified Data.Text.Lazy.Builder as TLB
import qualified Katip as K
import qualified Katip.Core as KC
import Language.Haskell.TH.Syntax (Loc (..))
import OpenTelemetry.Internal.Common.Types (AnyValue (..), ToValue (..))
import OpenTelemetry.Internal.Log.Types (
  LogRecordArguments (..),
  SeverityNumber (..),
  emptyLogRecordArguments,
 )
import OpenTelemetry.Log.Core (Logger, emitLogRecord)


{- | Create a Katip 'K.Scribe' that forwards log items to OTel.

@minSev@ is the minimum severity to forward (e.g. @K.InfoS@).
@verb@ controls how much of the 'K.LogItem' payload is serialized
into attributes.

@since 0.1.0.0
-}
makeOTelScribe
  :: Logger
  -> K.Severity
  -> K.Verbosity
  -> IO K.Scribe
makeOTelScribe logger minSev verb =
  pure $
    K.Scribe
      { K.liPush = \item -> do
          permitted <- K.permitItem minSev item
          if permitted
            then emitItem logger verb item
            else pure ()
      , K.scribeFinalizer = pure ()
      , K.scribePermitItem = K.permitItem minSev
      }


emitItem :: (K.LogItem a) => Logger -> K.Verbosity -> K.Item a -> IO ()
emitItem logger verb item = do
  let bodyText = TL.toStrict (TLB.toLazyText (KC.unLogStr (KC._itemMessage item)))
      (sevNum, sevText) = katipSeverity (KC._itemSeverity item)
      attrs = itemAttributes verb item
      args =
        emptyLogRecordArguments
          { severityText = Just sevText
          , severityNumber = Just sevNum
          , body = toValue bodyText
          , attributes = attrs
          }
  void $ emitLogRecord logger args


{- | Map Katip 'K.Severity' to OTel 'SeverityNumber' and short text.

@since 0.1.0.0
-}
katipSeverity :: K.Severity -> (SeverityNumber, Text)
katipSeverity K.DebugS = (Debug, "DEBUG")
katipSeverity K.InfoS = (Info, "INFO")
katipSeverity K.NoticeS = (Info2, "NOTICE")
katipSeverity K.WarningS = (Warn, "WARN")
katipSeverity K.ErrorS = (Error, "ERROR")
katipSeverity K.CriticalS = (Fatal, "CRITICAL")
katipSeverity K.AlertS = (Fatal2, "ALERT")
katipSeverity K.EmergencyS = (Fatal4, "EMERGENCY")


itemAttributes :: (K.LogItem a) => K.Verbosity -> K.Item a -> H.HashMap Text AnyValue
itemAttributes verb item =
  let KC.Namespace ns = KC._itemNamespace item
      base =
        H.fromList $
          concat
            [ [("katip.namespace", toValue (T.intercalate "." ns))]
            , [("thread.id", toValue (KC.getThreadIdText (KC._itemThread item)))]
            , [("server.address", toValue (T.pack (KC._itemHost item)))]
            , [("process.pid", toValue (T.pack (show (KC._itemProcess item))))]
            , maybe [] locAttrs (KC._itemLoc item)
            ]
      payloadAttrs = aesonToAttributes (K.itemJson verb item)
  in H.union base payloadAttrs
  where
    locAttrs loc =
      [ ("code.filepath", toValue (T.pack (loc_filename loc)))
      , ("code.function.name", toValue (T.pack (loc_package loc) <> ":" <> T.pack (loc_module loc)))
      , ("code.lineno", IntValue (fromIntegral (fst (loc_start loc))))
      ]


aesonToAttributes :: Value -> H.HashMap Text AnyValue
aesonToAttributes (Object obj) =
  H.fromList (map (\(k, v) -> ("log.payload." <> Key.toText k, aesonToAnyValue v)) (KM.toList obj))
aesonToAttributes _ = H.empty


aesonToAnyValue :: Value -> AnyValue
aesonToAnyValue (String t) = TextValue t
aesonToAnyValue (Number n) = DoubleValue (realToFrac n)
aesonToAnyValue (Bool b) = BoolValue b
aesonToAnyValue Null = NullValue
aesonToAnyValue (Array arr) = ArrayValue (map aesonToAnyValue (foldr (:) [] arr))
aesonToAnyValue (Object obj) =
  HashMapValue (H.fromList (map (\(k, v) -> (Key.toText k, aesonToAnyValue v)) (KM.toList obj)))
