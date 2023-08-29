{- This file was auto-generated from opentelemetry/proto/logs/v1/logs.proto by the proto-lens-protoc program. -}
{-# LANGUAGE BangPatterns #-}
{- This file was auto-generated from opentelemetry/proto/logs/v1/logs.proto by the proto-lens-protoc program. -}
{-# LANGUAGE DataKinds #-}
{- This file was auto-generated from opentelemetry/proto/logs/v1/logs.proto by the proto-lens-protoc program. -}
{-# LANGUAGE DerivingStrategies #-}
{- This file was auto-generated from opentelemetry/proto/logs/v1/logs.proto by the proto-lens-protoc program. -}
{-# LANGUAGE FlexibleContexts #-}
{- This file was auto-generated from opentelemetry/proto/logs/v1/logs.proto by the proto-lens-protoc program. -}
{-# LANGUAGE FlexibleInstances #-}
{- This file was auto-generated from opentelemetry/proto/logs/v1/logs.proto by the proto-lens-protoc program. -}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{- This file was auto-generated from opentelemetry/proto/logs/v1/logs.proto by the proto-lens-protoc program. -}
{-# LANGUAGE MagicHash #-}
{- This file was auto-generated from opentelemetry/proto/logs/v1/logs.proto by the proto-lens-protoc program. -}
{-# LANGUAGE MultiParamTypeClasses #-}
{- This file was auto-generated from opentelemetry/proto/logs/v1/logs.proto by the proto-lens-protoc program. -}
{-# LANGUAGE OverloadedStrings #-}
{- This file was auto-generated from opentelemetry/proto/logs/v1/logs.proto by the proto-lens-protoc program. -}
{-# LANGUAGE PatternSynonyms #-}
{- This file was auto-generated from opentelemetry/proto/logs/v1/logs.proto by the proto-lens-protoc program. -}
{-# LANGUAGE ScopedTypeVariables #-}
{- This file was auto-generated from opentelemetry/proto/logs/v1/logs.proto by the proto-lens-protoc program. -}
{-# LANGUAGE TypeApplications #-}
{- This file was auto-generated from opentelemetry/proto/logs/v1/logs.proto by the proto-lens-protoc program. -}
{-# LANGUAGE TypeFamilies #-}
{- This file was auto-generated from opentelemetry/proto/logs/v1/logs.proto by the proto-lens-protoc program. -}
{-# LANGUAGE UndecidableInstances #-}
{- This file was auto-generated from opentelemetry/proto/logs/v1/logs.proto by the proto-lens-protoc program. -}
{-# LANGUAGE NoImplicitPrelude #-}
{-# OPTIONS_GHC -Wno-dodgy-exports #-}
{-# OPTIONS_GHC -Wno-duplicate-exports #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Proto.Opentelemetry.Proto.Logs.V1.Logs (
  InstrumentationLibraryLogs (),
  LogRecord (),
  LogRecordFlags (..),
  LogRecordFlags (),
  LogRecordFlags'UnrecognizedValue,
  LogsData (),
  ResourceLogs (),
  SeverityNumber (..),
  SeverityNumber (),
  SeverityNumber'UnrecognizedValue,
) where

import qualified Data.ProtoLens.Runtime.Control.DeepSeq as Control.DeepSeq
import qualified Data.ProtoLens.Runtime.Data.ByteString as Data.ByteString
import qualified Data.ProtoLens.Runtime.Data.ByteString.Char8 as Data.ByteString.Char8
import qualified Data.ProtoLens.Runtime.Data.Int as Data.Int
import qualified Data.ProtoLens.Runtime.Data.Map as Data.Map
import qualified Data.ProtoLens.Runtime.Data.Monoid as Data.Monoid
import qualified Data.ProtoLens.Runtime.Data.ProtoLens as Data.ProtoLens
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Encoding.Bytes as Data.ProtoLens.Encoding.Bytes
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Encoding.Growing as Data.ProtoLens.Encoding.Growing
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Encoding.Parser.Unsafe as Data.ProtoLens.Encoding.Parser.Unsafe
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Encoding.Wire as Data.ProtoLens.Encoding.Wire
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Field as Data.ProtoLens.Field
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Message.Enum as Data.ProtoLens.Message.Enum
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Prism as Data.ProtoLens.Prism
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Service.Types as Data.ProtoLens.Service.Types
import qualified Data.ProtoLens.Runtime.Data.Text as Data.Text
import qualified Data.ProtoLens.Runtime.Data.Text.Encoding as Data.Text.Encoding
import qualified Data.ProtoLens.Runtime.Data.Vector as Data.Vector
import qualified Data.ProtoLens.Runtime.Data.Vector.Generic as Data.Vector.Generic
import qualified Data.ProtoLens.Runtime.Data.Vector.Unboxed as Data.Vector.Unboxed
import qualified Data.ProtoLens.Runtime.Data.Word as Data.Word
import qualified Data.ProtoLens.Runtime.Lens.Family2 as Lens.Family2
import qualified Data.ProtoLens.Runtime.Lens.Family2.Unchecked as Lens.Family2.Unchecked
import qualified Data.ProtoLens.Runtime.Prelude as Prelude
import qualified Data.ProtoLens.Runtime.Text.Read as Text.Read
import qualified Proto.Opentelemetry.Proto.Common.V1.Common
import qualified Proto.Opentelemetry.Proto.Resource.V1.Resource


{- | Fields :

         * 'Proto.Opentelemetry.Proto.Logs.V1.Logs_Fields.instrumentationLibrary' @:: Lens' InstrumentationLibraryLogs Proto.Opentelemetry.Proto.Common.V1.Common.InstrumentationLibrary@
         * 'Proto.Opentelemetry.Proto.Logs.V1.Logs_Fields.maybe'instrumentationLibrary' @:: Lens' InstrumentationLibraryLogs (Prelude.Maybe Proto.Opentelemetry.Proto.Common.V1.Common.InstrumentationLibrary)@
         * 'Proto.Opentelemetry.Proto.Logs.V1.Logs_Fields.logs' @:: Lens' InstrumentationLibraryLogs [LogRecord]@
         * 'Proto.Opentelemetry.Proto.Logs.V1.Logs_Fields.vec'logs' @:: Lens' InstrumentationLibraryLogs (Data.Vector.Vector LogRecord)@
         * 'Proto.Opentelemetry.Proto.Logs.V1.Logs_Fields.schemaUrl' @:: Lens' InstrumentationLibraryLogs Data.Text.Text@
-}
data InstrumentationLibraryLogs = InstrumentationLibraryLogs'_constructor
  { _InstrumentationLibraryLogs'instrumentationLibrary :: !(Prelude.Maybe Proto.Opentelemetry.Proto.Common.V1.Common.InstrumentationLibrary)
  , _InstrumentationLibraryLogs'logs :: !(Data.Vector.Vector LogRecord)
  , _InstrumentationLibraryLogs'schemaUrl :: !Data.Text.Text
  , _InstrumentationLibraryLogs'_unknownFields :: !Data.ProtoLens.FieldSet
  }
  deriving stock (Prelude.Eq, Prelude.Ord)


instance Prelude.Show InstrumentationLibraryLogs where
  showsPrec _ __x __s =
    Prelude.showChar
      '{'
      ( Prelude.showString
          (Data.ProtoLens.showMessageShort __x)
          (Prelude.showChar '}' __s)
      )


instance Data.ProtoLens.Field.HasField InstrumentationLibraryLogs "instrumentationLibrary" Proto.Opentelemetry.Proto.Common.V1.Common.InstrumentationLibrary where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _InstrumentationLibraryLogs'instrumentationLibrary
          ( \x__ y__ ->
              x__ {_InstrumentationLibraryLogs'instrumentationLibrary = y__}
          )
      )
      (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)


instance Data.ProtoLens.Field.HasField InstrumentationLibraryLogs "maybe'instrumentationLibrary" (Prelude.Maybe Proto.Opentelemetry.Proto.Common.V1.Common.InstrumentationLibrary) where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _InstrumentationLibraryLogs'instrumentationLibrary
          ( \x__ y__ ->
              x__ {_InstrumentationLibraryLogs'instrumentationLibrary = y__}
          )
      )
      Prelude.id


instance Data.ProtoLens.Field.HasField InstrumentationLibraryLogs "logs" [LogRecord] where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _InstrumentationLibraryLogs'logs
          (\x__ y__ -> x__ {_InstrumentationLibraryLogs'logs = y__})
      )
      ( Lens.Family2.Unchecked.lens
          Data.Vector.Generic.toList
          (\_ y__ -> Data.Vector.Generic.fromList y__)
      )


instance Data.ProtoLens.Field.HasField InstrumentationLibraryLogs "vec'logs" (Data.Vector.Vector LogRecord) where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _InstrumentationLibraryLogs'logs
          (\x__ y__ -> x__ {_InstrumentationLibraryLogs'logs = y__})
      )
      Prelude.id


instance Data.ProtoLens.Field.HasField InstrumentationLibraryLogs "schemaUrl" Data.Text.Text where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _InstrumentationLibraryLogs'schemaUrl
          (\x__ y__ -> x__ {_InstrumentationLibraryLogs'schemaUrl = y__})
      )
      Prelude.id


instance Data.ProtoLens.Message InstrumentationLibraryLogs where
  messageName _ =
    Data.Text.pack
      "opentelemetry.proto.logs.v1.InstrumentationLibraryLogs"
  packedMessageDescriptor _ =
    "\n\
    \\SUBInstrumentationLibraryLogs\DC2n\n\
    \\ETBinstrumentation_library\CAN\SOH \SOH(\v25.opentelemetry.proto.common.v1.InstrumentationLibraryR\SYNinstrumentationLibrary\DC2:\n\
    \\EOTlogs\CAN\STX \ETX(\v2&.opentelemetry.proto.logs.v1.LogRecordR\EOTlogs\DC2\GS\n\
    \\n\
    \schema_url\CAN\ETX \SOH(\tR\tschemaUrl"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag =
    let instrumentationLibrary__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "instrumentation_library"
            ( Data.ProtoLens.MessageField Data.ProtoLens.MessageType
                :: Data.ProtoLens.FieldTypeDescriptor Proto.Opentelemetry.Proto.Common.V1.Common.InstrumentationLibrary
            )
            ( Data.ProtoLens.OptionalField
                (Data.ProtoLens.Field.field @"maybe'instrumentationLibrary")
            )
            :: Data.ProtoLens.FieldDescriptor InstrumentationLibraryLogs
        logs__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "logs"
            ( Data.ProtoLens.MessageField Data.ProtoLens.MessageType
                :: Data.ProtoLens.FieldTypeDescriptor LogRecord
            )
            ( Data.ProtoLens.RepeatedField
                Data.ProtoLens.Unpacked
                (Data.ProtoLens.Field.field @"logs")
            )
            :: Data.ProtoLens.FieldDescriptor InstrumentationLibraryLogs
        schemaUrl__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "schema_url"
            ( Data.ProtoLens.ScalarField Data.ProtoLens.StringField
                :: Data.ProtoLens.FieldTypeDescriptor Data.Text.Text
            )
            ( Data.ProtoLens.PlainField
                Data.ProtoLens.Optional
                (Data.ProtoLens.Field.field @"schemaUrl")
            )
            :: Data.ProtoLens.FieldDescriptor InstrumentationLibraryLogs
     in Data.Map.fromList
          [ (Data.ProtoLens.Tag 1, instrumentationLibrary__field_descriptor)
          , (Data.ProtoLens.Tag 2, logs__field_descriptor)
          , (Data.ProtoLens.Tag 3, schemaUrl__field_descriptor)
          ]
  unknownFields =
    Lens.Family2.Unchecked.lens
      _InstrumentationLibraryLogs'_unknownFields
      ( \x__ y__ ->
          x__ {_InstrumentationLibraryLogs'_unknownFields = y__}
      )
  defMessage =
    InstrumentationLibraryLogs'_constructor
      { _InstrumentationLibraryLogs'instrumentationLibrary = Prelude.Nothing
      , _InstrumentationLibraryLogs'logs = Data.Vector.Generic.empty
      , _InstrumentationLibraryLogs'schemaUrl = Data.ProtoLens.fieldDefault
      , _InstrumentationLibraryLogs'_unknownFields = []
      }
  parseMessage =
    let loop
          :: InstrumentationLibraryLogs
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld LogRecord
          -> Data.ProtoLens.Encoding.Bytes.Parser InstrumentationLibraryLogs
        loop x mutable'logs =
          do
            end <- Data.ProtoLens.Encoding.Bytes.atEnd
            if end
              then do
                frozen'logs <-
                  Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                    (Data.ProtoLens.Encoding.Growing.unsafeFreeze mutable'logs)
                ( let missing = []
                   in if Prelude.null missing
                        then Prelude.return ()
                        else
                          Prelude.fail
                            ( (Prelude.++)
                                "Missing required fields: "
                                (Prelude.show (missing :: [Prelude.String]))
                            )
                  )
                Prelude.return
                  ( Lens.Family2.over
                      Data.ProtoLens.unknownFields
                      (\ !t -> Prelude.reverse t)
                      ( Lens.Family2.set
                          (Data.ProtoLens.Field.field @"vec'logs")
                          frozen'logs
                          x
                      )
                  )
              else do
                tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                case tag of
                  10 ->
                    do
                      y <-
                        (Data.ProtoLens.Encoding.Bytes.<?>)
                          ( do
                              len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                              Data.ProtoLens.Encoding.Bytes.isolate
                                (Prelude.fromIntegral len)
                                Data.ProtoLens.parseMessage
                          )
                          "instrumentation_library"
                      loop
                        ( Lens.Family2.set
                            (Data.ProtoLens.Field.field @"instrumentationLibrary")
                            y
                            x
                        )
                        mutable'logs
                  18 ->
                    do
                      !y <-
                        (Data.ProtoLens.Encoding.Bytes.<?>)
                          ( do
                              len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                              Data.ProtoLens.Encoding.Bytes.isolate
                                (Prelude.fromIntegral len)
                                Data.ProtoLens.parseMessage
                          )
                          "logs"
                      v <-
                        Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                          (Data.ProtoLens.Encoding.Growing.append mutable'logs y)
                      loop x v
                  26 ->
                    do
                      y <-
                        (Data.ProtoLens.Encoding.Bytes.<?>)
                          ( do
                              value <- do
                                len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                Data.ProtoLens.Encoding.Bytes.getBytes
                                  (Prelude.fromIntegral len)
                              Data.ProtoLens.Encoding.Bytes.runEither
                                ( case Data.Text.Encoding.decodeUtf8' value of
                                    (Prelude.Left err) ->
                                      Prelude.Left (Prelude.show err)
                                    (Prelude.Right r) -> Prelude.Right r
                                )
                          )
                          "schema_url"
                      loop
                        (Lens.Family2.set (Data.ProtoLens.Field.field @"schemaUrl") y x)
                        mutable'logs
                  wire ->
                    do
                      !y <-
                        Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                          wire
                      loop
                        ( Lens.Family2.over
                            Data.ProtoLens.unknownFields
                            (\ !t -> (:) y t)
                            x
                        )
                        mutable'logs
     in (Data.ProtoLens.Encoding.Bytes.<?>)
          ( do
              mutable'logs <-
                Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                  Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'logs
          )
          "InstrumentationLibraryLogs"
  buildMessage =
    \_x ->
      (Data.Monoid.<>)
        ( case Lens.Family2.view
            (Data.ProtoLens.Field.field @"maybe'instrumentationLibrary")
            _x of
            Prelude.Nothing -> Data.Monoid.mempty
            (Prelude.Just _v) ->
              (Data.Monoid.<>)
                (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                ( (Prelude..)
                    ( \bs ->
                        (Data.Monoid.<>)
                          ( Data.ProtoLens.Encoding.Bytes.putVarInt
                              (Prelude.fromIntegral (Data.ByteString.length bs))
                          )
                          (Data.ProtoLens.Encoding.Bytes.putBytes bs)
                    )
                    Data.ProtoLens.encodeMessage
                    _v
                )
        )
        ( (Data.Monoid.<>)
            ( Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                ( \_v ->
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                      ( (Prelude..)
                          ( \bs ->
                              (Data.Monoid.<>)
                                ( Data.ProtoLens.Encoding.Bytes.putVarInt
                                    (Prelude.fromIntegral (Data.ByteString.length bs))
                                )
                                (Data.ProtoLens.Encoding.Bytes.putBytes bs)
                          )
                          Data.ProtoLens.encodeMessage
                          _v
                      )
                )
                (Lens.Family2.view (Data.ProtoLens.Field.field @"vec'logs") _x)
            )
            ( (Data.Monoid.<>)
                ( let _v = Lens.Family2.view (Data.ProtoLens.Field.field @"schemaUrl") _x
                   in if (Prelude.==) _v Data.ProtoLens.fieldDefault
                        then Data.Monoid.mempty
                        else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 26)
                            ( (Prelude..)
                                ( \bs ->
                                    (Data.Monoid.<>)
                                      ( Data.ProtoLens.Encoding.Bytes.putVarInt
                                          (Prelude.fromIntegral (Data.ByteString.length bs))
                                      )
                                      (Data.ProtoLens.Encoding.Bytes.putBytes bs)
                                )
                                Data.Text.Encoding.encodeUtf8
                                _v
                            )
                )
                ( Data.ProtoLens.Encoding.Wire.buildFieldSet
                    (Lens.Family2.view Data.ProtoLens.unknownFields _x)
                )
            )
        )


instance Control.DeepSeq.NFData InstrumentationLibraryLogs where
  rnf =
    \x__ ->
      Control.DeepSeq.deepseq
        (_InstrumentationLibraryLogs'_unknownFields x__)
        ( Control.DeepSeq.deepseq
            (_InstrumentationLibraryLogs'instrumentationLibrary x__)
            ( Control.DeepSeq.deepseq
                (_InstrumentationLibraryLogs'logs x__)
                ( Control.DeepSeq.deepseq
                    (_InstrumentationLibraryLogs'schemaUrl x__)
                    ()
                )
            )
        )


{- | Fields :

         * 'Proto.Opentelemetry.Proto.Logs.V1.Logs_Fields.timeUnixNano' @:: Lens' LogRecord Data.Word.Word64@
         * 'Proto.Opentelemetry.Proto.Logs.V1.Logs_Fields.severityNumber' @:: Lens' LogRecord SeverityNumber@
         * 'Proto.Opentelemetry.Proto.Logs.V1.Logs_Fields.severityText' @:: Lens' LogRecord Data.Text.Text@
         * 'Proto.Opentelemetry.Proto.Logs.V1.Logs_Fields.name' @:: Lens' LogRecord Data.Text.Text@
         * 'Proto.Opentelemetry.Proto.Logs.V1.Logs_Fields.body' @:: Lens' LogRecord Proto.Opentelemetry.Proto.Common.V1.Common.AnyValue@
         * 'Proto.Opentelemetry.Proto.Logs.V1.Logs_Fields.maybe'body' @:: Lens' LogRecord (Prelude.Maybe Proto.Opentelemetry.Proto.Common.V1.Common.AnyValue)@
         * 'Proto.Opentelemetry.Proto.Logs.V1.Logs_Fields.attributes' @:: Lens' LogRecord [Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue]@
         * 'Proto.Opentelemetry.Proto.Logs.V1.Logs_Fields.vec'attributes' @:: Lens' LogRecord (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue)@
         * 'Proto.Opentelemetry.Proto.Logs.V1.Logs_Fields.droppedAttributesCount' @:: Lens' LogRecord Data.Word.Word32@
         * 'Proto.Opentelemetry.Proto.Logs.V1.Logs_Fields.flags' @:: Lens' LogRecord Data.Word.Word32@
         * 'Proto.Opentelemetry.Proto.Logs.V1.Logs_Fields.traceId' @:: Lens' LogRecord Data.ByteString.ByteString@
         * 'Proto.Opentelemetry.Proto.Logs.V1.Logs_Fields.spanId' @:: Lens' LogRecord Data.ByteString.ByteString@
-}
data LogRecord = LogRecord'_constructor
  { _LogRecord'timeUnixNano :: !Data.Word.Word64
  , _LogRecord'severityNumber :: !SeverityNumber
  , _LogRecord'severityText :: !Data.Text.Text
  , _LogRecord'name :: !Data.Text.Text
  , _LogRecord'body :: !(Prelude.Maybe Proto.Opentelemetry.Proto.Common.V1.Common.AnyValue)
  , _LogRecord'attributes :: !(Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue)
  , _LogRecord'droppedAttributesCount :: !Data.Word.Word32
  , _LogRecord'flags :: !Data.Word.Word32
  , _LogRecord'traceId :: !Data.ByteString.ByteString
  , _LogRecord'spanId :: !Data.ByteString.ByteString
  , _LogRecord'_unknownFields :: !Data.ProtoLens.FieldSet
  }
  deriving stock (Prelude.Eq, Prelude.Ord)


instance Prelude.Show LogRecord where
  showsPrec _ __x __s =
    Prelude.showChar
      '{'
      ( Prelude.showString
          (Data.ProtoLens.showMessageShort __x)
          (Prelude.showChar '}' __s)
      )


instance Data.ProtoLens.Field.HasField LogRecord "timeUnixNano" Data.Word.Word64 where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _LogRecord'timeUnixNano
          (\x__ y__ -> x__ {_LogRecord'timeUnixNano = y__})
      )
      Prelude.id


instance Data.ProtoLens.Field.HasField LogRecord "severityNumber" SeverityNumber where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _LogRecord'severityNumber
          (\x__ y__ -> x__ {_LogRecord'severityNumber = y__})
      )
      Prelude.id


instance Data.ProtoLens.Field.HasField LogRecord "severityText" Data.Text.Text where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _LogRecord'severityText
          (\x__ y__ -> x__ {_LogRecord'severityText = y__})
      )
      Prelude.id


instance Data.ProtoLens.Field.HasField LogRecord "name" Data.Text.Text where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _LogRecord'name
          (\x__ y__ -> x__ {_LogRecord'name = y__})
      )
      Prelude.id


instance Data.ProtoLens.Field.HasField LogRecord "body" Proto.Opentelemetry.Proto.Common.V1.Common.AnyValue where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _LogRecord'body
          (\x__ y__ -> x__ {_LogRecord'body = y__})
      )
      (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)


instance Data.ProtoLens.Field.HasField LogRecord "maybe'body" (Prelude.Maybe Proto.Opentelemetry.Proto.Common.V1.Common.AnyValue) where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _LogRecord'body
          (\x__ y__ -> x__ {_LogRecord'body = y__})
      )
      Prelude.id


instance Data.ProtoLens.Field.HasField LogRecord "attributes" [Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue] where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _LogRecord'attributes
          (\x__ y__ -> x__ {_LogRecord'attributes = y__})
      )
      ( Lens.Family2.Unchecked.lens
          Data.Vector.Generic.toList
          (\_ y__ -> Data.Vector.Generic.fromList y__)
      )


instance Data.ProtoLens.Field.HasField LogRecord "vec'attributes" (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue) where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _LogRecord'attributes
          (\x__ y__ -> x__ {_LogRecord'attributes = y__})
      )
      Prelude.id


instance Data.ProtoLens.Field.HasField LogRecord "droppedAttributesCount" Data.Word.Word32 where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _LogRecord'droppedAttributesCount
          (\x__ y__ -> x__ {_LogRecord'droppedAttributesCount = y__})
      )
      Prelude.id


instance Data.ProtoLens.Field.HasField LogRecord "flags" Data.Word.Word32 where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _LogRecord'flags
          (\x__ y__ -> x__ {_LogRecord'flags = y__})
      )
      Prelude.id


instance Data.ProtoLens.Field.HasField LogRecord "traceId" Data.ByteString.ByteString where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _LogRecord'traceId
          (\x__ y__ -> x__ {_LogRecord'traceId = y__})
      )
      Prelude.id


instance Data.ProtoLens.Field.HasField LogRecord "spanId" Data.ByteString.ByteString where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _LogRecord'spanId
          (\x__ y__ -> x__ {_LogRecord'spanId = y__})
      )
      Prelude.id


instance Data.ProtoLens.Message LogRecord where
  messageName _ =
    Data.Text.pack "opentelemetry.proto.logs.v1.LogRecord"
  packedMessageDescriptor _ =
    "\n\
    \\tLogRecord\DC2$\n\
    \\SOtime_unix_nano\CAN\SOH \SOH(\ACKR\ftimeUnixNano\DC2T\n\
    \\SIseverity_number\CAN\STX \SOH(\SO2+.opentelemetry.proto.logs.v1.SeverityNumberR\SOseverityNumber\DC2#\n\
    \\rseverity_text\CAN\ETX \SOH(\tR\fseverityText\DC2\DC2\n\
    \\EOTname\CAN\EOT \SOH(\tR\EOTname\DC2;\n\
    \\EOTbody\CAN\ENQ \SOH(\v2'.opentelemetry.proto.common.v1.AnyValueR\EOTbody\DC2G\n\
    \\n\
    \attributes\CAN\ACK \ETX(\v2'.opentelemetry.proto.common.v1.KeyValueR\n\
    \attributes\DC28\n\
    \\CANdropped_attributes_count\CAN\a \SOH(\rR\SYNdroppedAttributesCount\DC2\DC4\n\
    \\ENQflags\CAN\b \SOH(\aR\ENQflags\DC2\EM\n\
    \\btrace_id\CAN\t \SOH(\fR\atraceId\DC2\ETB\n\
    \\aspan_id\CAN\n\
    \ \SOH(\fR\ACKspanId"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag =
    let timeUnixNano__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "time_unix_nano"
            ( Data.ProtoLens.ScalarField Data.ProtoLens.Fixed64Field
                :: Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64
            )
            ( Data.ProtoLens.PlainField
                Data.ProtoLens.Optional
                (Data.ProtoLens.Field.field @"timeUnixNano")
            )
            :: Data.ProtoLens.FieldDescriptor LogRecord
        severityNumber__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "severity_number"
            ( Data.ProtoLens.ScalarField Data.ProtoLens.EnumField
                :: Data.ProtoLens.FieldTypeDescriptor SeverityNumber
            )
            ( Data.ProtoLens.PlainField
                Data.ProtoLens.Optional
                (Data.ProtoLens.Field.field @"severityNumber")
            )
            :: Data.ProtoLens.FieldDescriptor LogRecord
        severityText__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "severity_text"
            ( Data.ProtoLens.ScalarField Data.ProtoLens.StringField
                :: Data.ProtoLens.FieldTypeDescriptor Data.Text.Text
            )
            ( Data.ProtoLens.PlainField
                Data.ProtoLens.Optional
                (Data.ProtoLens.Field.field @"severityText")
            )
            :: Data.ProtoLens.FieldDescriptor LogRecord
        name__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "name"
            ( Data.ProtoLens.ScalarField Data.ProtoLens.StringField
                :: Data.ProtoLens.FieldTypeDescriptor Data.Text.Text
            )
            ( Data.ProtoLens.PlainField
                Data.ProtoLens.Optional
                (Data.ProtoLens.Field.field @"name")
            )
            :: Data.ProtoLens.FieldDescriptor LogRecord
        body__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "body"
            ( Data.ProtoLens.MessageField Data.ProtoLens.MessageType
                :: Data.ProtoLens.FieldTypeDescriptor Proto.Opentelemetry.Proto.Common.V1.Common.AnyValue
            )
            ( Data.ProtoLens.OptionalField
                (Data.ProtoLens.Field.field @"maybe'body")
            )
            :: Data.ProtoLens.FieldDescriptor LogRecord
        attributes__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "attributes"
            ( Data.ProtoLens.MessageField Data.ProtoLens.MessageType
                :: Data.ProtoLens.FieldTypeDescriptor Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue
            )
            ( Data.ProtoLens.RepeatedField
                Data.ProtoLens.Unpacked
                (Data.ProtoLens.Field.field @"attributes")
            )
            :: Data.ProtoLens.FieldDescriptor LogRecord
        droppedAttributesCount__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "dropped_attributes_count"
            ( Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field
                :: Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32
            )
            ( Data.ProtoLens.PlainField
                Data.ProtoLens.Optional
                (Data.ProtoLens.Field.field @"droppedAttributesCount")
            )
            :: Data.ProtoLens.FieldDescriptor LogRecord
        flags__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "flags"
            ( Data.ProtoLens.ScalarField Data.ProtoLens.Fixed32Field
                :: Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32
            )
            ( Data.ProtoLens.PlainField
                Data.ProtoLens.Optional
                (Data.ProtoLens.Field.field @"flags")
            )
            :: Data.ProtoLens.FieldDescriptor LogRecord
        traceId__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "trace_id"
            ( Data.ProtoLens.ScalarField Data.ProtoLens.BytesField
                :: Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString
            )
            ( Data.ProtoLens.PlainField
                Data.ProtoLens.Optional
                (Data.ProtoLens.Field.field @"traceId")
            )
            :: Data.ProtoLens.FieldDescriptor LogRecord
        spanId__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "span_id"
            ( Data.ProtoLens.ScalarField Data.ProtoLens.BytesField
                :: Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString
            )
            ( Data.ProtoLens.PlainField
                Data.ProtoLens.Optional
                (Data.ProtoLens.Field.field @"spanId")
            )
            :: Data.ProtoLens.FieldDescriptor LogRecord
     in Data.Map.fromList
          [ (Data.ProtoLens.Tag 1, timeUnixNano__field_descriptor)
          , (Data.ProtoLens.Tag 2, severityNumber__field_descriptor)
          , (Data.ProtoLens.Tag 3, severityText__field_descriptor)
          , (Data.ProtoLens.Tag 4, name__field_descriptor)
          , (Data.ProtoLens.Tag 5, body__field_descriptor)
          , (Data.ProtoLens.Tag 6, attributes__field_descriptor)
          , (Data.ProtoLens.Tag 7, droppedAttributesCount__field_descriptor)
          , (Data.ProtoLens.Tag 8, flags__field_descriptor)
          , (Data.ProtoLens.Tag 9, traceId__field_descriptor)
          , (Data.ProtoLens.Tag 10, spanId__field_descriptor)
          ]
  unknownFields =
    Lens.Family2.Unchecked.lens
      _LogRecord'_unknownFields
      (\x__ y__ -> x__ {_LogRecord'_unknownFields = y__})
  defMessage =
    LogRecord'_constructor
      { _LogRecord'timeUnixNano = Data.ProtoLens.fieldDefault
      , _LogRecord'severityNumber = Data.ProtoLens.fieldDefault
      , _LogRecord'severityText = Data.ProtoLens.fieldDefault
      , _LogRecord'name = Data.ProtoLens.fieldDefault
      , _LogRecord'body = Prelude.Nothing
      , _LogRecord'attributes = Data.Vector.Generic.empty
      , _LogRecord'droppedAttributesCount = Data.ProtoLens.fieldDefault
      , _LogRecord'flags = Data.ProtoLens.fieldDefault
      , _LogRecord'traceId = Data.ProtoLens.fieldDefault
      , _LogRecord'spanId = Data.ProtoLens.fieldDefault
      , _LogRecord'_unknownFields = []
      }
  parseMessage =
    let loop
          :: LogRecord
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue
          -> Data.ProtoLens.Encoding.Bytes.Parser LogRecord
        loop x mutable'attributes =
          do
            end <- Data.ProtoLens.Encoding.Bytes.atEnd
            if end
              then do
                frozen'attributes <-
                  Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                    ( Data.ProtoLens.Encoding.Growing.unsafeFreeze
                        mutable'attributes
                    )
                ( let missing = []
                   in if Prelude.null missing
                        then Prelude.return ()
                        else
                          Prelude.fail
                            ( (Prelude.++)
                                "Missing required fields: "
                                (Prelude.show (missing :: [Prelude.String]))
                            )
                  )
                Prelude.return
                  ( Lens.Family2.over
                      Data.ProtoLens.unknownFields
                      (\ !t -> Prelude.reverse t)
                      ( Lens.Family2.set
                          (Data.ProtoLens.Field.field @"vec'attributes")
                          frozen'attributes
                          x
                      )
                  )
              else do
                tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                case tag of
                  9 -> do
                    y <-
                      (Data.ProtoLens.Encoding.Bytes.<?>)
                        Data.ProtoLens.Encoding.Bytes.getFixed64
                        "time_unix_nano"
                    loop
                      ( Lens.Family2.set
                          (Data.ProtoLens.Field.field @"timeUnixNano")
                          y
                          x
                      )
                      mutable'attributes
                  16 ->
                    do
                      y <-
                        (Data.ProtoLens.Encoding.Bytes.<?>)
                          ( Prelude.fmap
                              Prelude.toEnum
                              ( Prelude.fmap
                                  Prelude.fromIntegral
                                  Data.ProtoLens.Encoding.Bytes.getVarInt
                              )
                          )
                          "severity_number"
                      loop
                        ( Lens.Family2.set
                            (Data.ProtoLens.Field.field @"severityNumber")
                            y
                            x
                        )
                        mutable'attributes
                  26 ->
                    do
                      y <-
                        (Data.ProtoLens.Encoding.Bytes.<?>)
                          ( do
                              value <- do
                                len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                Data.ProtoLens.Encoding.Bytes.getBytes
                                  (Prelude.fromIntegral len)
                              Data.ProtoLens.Encoding.Bytes.runEither
                                ( case Data.Text.Encoding.decodeUtf8' value of
                                    (Prelude.Left err) ->
                                      Prelude.Left (Prelude.show err)
                                    (Prelude.Right r) -> Prelude.Right r
                                )
                          )
                          "severity_text"
                      loop
                        ( Lens.Family2.set
                            (Data.ProtoLens.Field.field @"severityText")
                            y
                            x
                        )
                        mutable'attributes
                  34 ->
                    do
                      y <-
                        (Data.ProtoLens.Encoding.Bytes.<?>)
                          ( do
                              value <- do
                                len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                Data.ProtoLens.Encoding.Bytes.getBytes
                                  (Prelude.fromIntegral len)
                              Data.ProtoLens.Encoding.Bytes.runEither
                                ( case Data.Text.Encoding.decodeUtf8' value of
                                    (Prelude.Left err) ->
                                      Prelude.Left (Prelude.show err)
                                    (Prelude.Right r) -> Prelude.Right r
                                )
                          )
                          "name"
                      loop
                        (Lens.Family2.set (Data.ProtoLens.Field.field @"name") y x)
                        mutable'attributes
                  42 ->
                    do
                      y <-
                        (Data.ProtoLens.Encoding.Bytes.<?>)
                          ( do
                              len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                              Data.ProtoLens.Encoding.Bytes.isolate
                                (Prelude.fromIntegral len)
                                Data.ProtoLens.parseMessage
                          )
                          "body"
                      loop
                        (Lens.Family2.set (Data.ProtoLens.Field.field @"body") y x)
                        mutable'attributes
                  50 ->
                    do
                      !y <-
                        (Data.ProtoLens.Encoding.Bytes.<?>)
                          ( do
                              len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                              Data.ProtoLens.Encoding.Bytes.isolate
                                (Prelude.fromIntegral len)
                                Data.ProtoLens.parseMessage
                          )
                          "attributes"
                      v <-
                        Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                          (Data.ProtoLens.Encoding.Growing.append mutable'attributes y)
                      loop x v
                  56 ->
                    do
                      y <-
                        (Data.ProtoLens.Encoding.Bytes.<?>)
                          ( Prelude.fmap
                              Prelude.fromIntegral
                              Data.ProtoLens.Encoding.Bytes.getVarInt
                          )
                          "dropped_attributes_count"
                      loop
                        ( Lens.Family2.set
                            (Data.ProtoLens.Field.field @"droppedAttributesCount")
                            y
                            x
                        )
                        mutable'attributes
                  69 ->
                    do
                      y <-
                        (Data.ProtoLens.Encoding.Bytes.<?>)
                          Data.ProtoLens.Encoding.Bytes.getFixed32
                          "flags"
                      loop
                        (Lens.Family2.set (Data.ProtoLens.Field.field @"flags") y x)
                        mutable'attributes
                  74 ->
                    do
                      y <-
                        (Data.ProtoLens.Encoding.Bytes.<?>)
                          ( do
                              len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                              Data.ProtoLens.Encoding.Bytes.getBytes
                                (Prelude.fromIntegral len)
                          )
                          "trace_id"
                      loop
                        (Lens.Family2.set (Data.ProtoLens.Field.field @"traceId") y x)
                        mutable'attributes
                  82 ->
                    do
                      y <-
                        (Data.ProtoLens.Encoding.Bytes.<?>)
                          ( do
                              len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                              Data.ProtoLens.Encoding.Bytes.getBytes
                                (Prelude.fromIntegral len)
                          )
                          "span_id"
                      loop
                        (Lens.Family2.set (Data.ProtoLens.Field.field @"spanId") y x)
                        mutable'attributes
                  wire ->
                    do
                      !y <-
                        Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                          wire
                      loop
                        ( Lens.Family2.over
                            Data.ProtoLens.unknownFields
                            (\ !t -> (:) y t)
                            x
                        )
                        mutable'attributes
     in (Data.ProtoLens.Encoding.Bytes.<?>)
          ( do
              mutable'attributes <-
                Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                  Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'attributes
          )
          "LogRecord"
  buildMessage =
    \_x ->
      (Data.Monoid.<>)
        ( let _v =
                Lens.Family2.view (Data.ProtoLens.Field.field @"timeUnixNano") _x
           in if (Prelude.==) _v Data.ProtoLens.fieldDefault
                then Data.Monoid.mempty
                else
                  (Data.Monoid.<>)
                    (Data.ProtoLens.Encoding.Bytes.putVarInt 9)
                    (Data.ProtoLens.Encoding.Bytes.putFixed64 _v)
        )
        ( (Data.Monoid.<>)
            ( let _v =
                    Lens.Family2.view
                      (Data.ProtoLens.Field.field @"severityNumber")
                      _x
               in if (Prelude.==) _v Data.ProtoLens.fieldDefault
                    then Data.Monoid.mempty
                    else
                      (Data.Monoid.<>)
                        (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                        ( (Prelude..)
                            ( (Prelude..)
                                Data.ProtoLens.Encoding.Bytes.putVarInt
                                Prelude.fromIntegral
                            )
                            Prelude.fromEnum
                            _v
                        )
            )
            ( (Data.Monoid.<>)
                ( let _v =
                        Lens.Family2.view (Data.ProtoLens.Field.field @"severityText") _x
                   in if (Prelude.==) _v Data.ProtoLens.fieldDefault
                        then Data.Monoid.mempty
                        else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 26)
                            ( (Prelude..)
                                ( \bs ->
                                    (Data.Monoid.<>)
                                      ( Data.ProtoLens.Encoding.Bytes.putVarInt
                                          (Prelude.fromIntegral (Data.ByteString.length bs))
                                      )
                                      (Data.ProtoLens.Encoding.Bytes.putBytes bs)
                                )
                                Data.Text.Encoding.encodeUtf8
                                _v
                            )
                )
                ( (Data.Monoid.<>)
                    ( let _v = Lens.Family2.view (Data.ProtoLens.Field.field @"name") _x
                       in if (Prelude.==) _v Data.ProtoLens.fieldDefault
                            then Data.Monoid.mempty
                            else
                              (Data.Monoid.<>)
                                (Data.ProtoLens.Encoding.Bytes.putVarInt 34)
                                ( (Prelude..)
                                    ( \bs ->
                                        (Data.Monoid.<>)
                                          ( Data.ProtoLens.Encoding.Bytes.putVarInt
                                              (Prelude.fromIntegral (Data.ByteString.length bs))
                                          )
                                          (Data.ProtoLens.Encoding.Bytes.putBytes bs)
                                    )
                                    Data.Text.Encoding.encodeUtf8
                                    _v
                                )
                    )
                    ( (Data.Monoid.<>)
                        ( case Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'body") _x of
                            Prelude.Nothing -> Data.Monoid.mempty
                            (Prelude.Just _v) ->
                              (Data.Monoid.<>)
                                (Data.ProtoLens.Encoding.Bytes.putVarInt 42)
                                ( (Prelude..)
                                    ( \bs ->
                                        (Data.Monoid.<>)
                                          ( Data.ProtoLens.Encoding.Bytes.putVarInt
                                              (Prelude.fromIntegral (Data.ByteString.length bs))
                                          )
                                          (Data.ProtoLens.Encoding.Bytes.putBytes bs)
                                    )
                                    Data.ProtoLens.encodeMessage
                                    _v
                                )
                        )
                        ( (Data.Monoid.<>)
                            ( Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                                ( \_v ->
                                    (Data.Monoid.<>)
                                      (Data.ProtoLens.Encoding.Bytes.putVarInt 50)
                                      ( (Prelude..)
                                          ( \bs ->
                                              (Data.Monoid.<>)
                                                ( Data.ProtoLens.Encoding.Bytes.putVarInt
                                                    ( Prelude.fromIntegral
                                                        (Data.ByteString.length bs)
                                                    )
                                                )
                                                (Data.ProtoLens.Encoding.Bytes.putBytes bs)
                                          )
                                          Data.ProtoLens.encodeMessage
                                          _v
                                      )
                                )
                                ( Lens.Family2.view
                                    (Data.ProtoLens.Field.field @"vec'attributes")
                                    _x
                                )
                            )
                            ( (Data.Monoid.<>)
                                ( let _v =
                                        Lens.Family2.view
                                          (Data.ProtoLens.Field.field @"droppedAttributesCount")
                                          _x
                                   in if (Prelude.==) _v Data.ProtoLens.fieldDefault
                                        then Data.Monoid.mempty
                                        else
                                          (Data.Monoid.<>)
                                            (Data.ProtoLens.Encoding.Bytes.putVarInt 56)
                                            ( (Prelude..)
                                                Data.ProtoLens.Encoding.Bytes.putVarInt
                                                Prelude.fromIntegral
                                                _v
                                            )
                                )
                                ( (Data.Monoid.<>)
                                    ( let _v = Lens.Family2.view (Data.ProtoLens.Field.field @"flags") _x
                                       in if (Prelude.==) _v Data.ProtoLens.fieldDefault
                                            then Data.Monoid.mempty
                                            else
                                              (Data.Monoid.<>)
                                                (Data.ProtoLens.Encoding.Bytes.putVarInt 69)
                                                (Data.ProtoLens.Encoding.Bytes.putFixed32 _v)
                                    )
                                    ( (Data.Monoid.<>)
                                        ( let _v =
                                                Lens.Family2.view
                                                  (Data.ProtoLens.Field.field @"traceId")
                                                  _x
                                           in if (Prelude.==) _v Data.ProtoLens.fieldDefault
                                                then Data.Monoid.mempty
                                                else
                                                  (Data.Monoid.<>)
                                                    (Data.ProtoLens.Encoding.Bytes.putVarInt 74)
                                                    ( ( \bs ->
                                                          (Data.Monoid.<>)
                                                            ( Data.ProtoLens.Encoding.Bytes.putVarInt
                                                                ( Prelude.fromIntegral
                                                                    (Data.ByteString.length bs)
                                                                )
                                                            )
                                                            (Data.ProtoLens.Encoding.Bytes.putBytes bs)
                                                      )
                                                        _v
                                                    )
                                        )
                                        ( (Data.Monoid.<>)
                                            ( let _v =
                                                    Lens.Family2.view
                                                      (Data.ProtoLens.Field.field @"spanId")
                                                      _x
                                               in if (Prelude.==) _v Data.ProtoLens.fieldDefault
                                                    then Data.Monoid.mempty
                                                    else
                                                      (Data.Monoid.<>)
                                                        (Data.ProtoLens.Encoding.Bytes.putVarInt 82)
                                                        ( ( \bs ->
                                                              (Data.Monoid.<>)
                                                                ( Data.ProtoLens.Encoding.Bytes.putVarInt
                                                                    ( Prelude.fromIntegral
                                                                        (Data.ByteString.length bs)
                                                                    )
                                                                )
                                                                ( Data.ProtoLens.Encoding.Bytes.putBytes
                                                                    bs
                                                                )
                                                          )
                                                            _v
                                                        )
                                            )
                                            ( Data.ProtoLens.Encoding.Wire.buildFieldSet
                                                ( Lens.Family2.view
                                                    Data.ProtoLens.unknownFields
                                                    _x
                                                )
                                            )
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )


instance Control.DeepSeq.NFData LogRecord where
  rnf =
    \x__ ->
      Control.DeepSeq.deepseq
        (_LogRecord'_unknownFields x__)
        ( Control.DeepSeq.deepseq
            (_LogRecord'timeUnixNano x__)
            ( Control.DeepSeq.deepseq
                (_LogRecord'severityNumber x__)
                ( Control.DeepSeq.deepseq
                    (_LogRecord'severityText x__)
                    ( Control.DeepSeq.deepseq
                        (_LogRecord'name x__)
                        ( Control.DeepSeq.deepseq
                            (_LogRecord'body x__)
                            ( Control.DeepSeq.deepseq
                                (_LogRecord'attributes x__)
                                ( Control.DeepSeq.deepseq
                                    (_LogRecord'droppedAttributesCount x__)
                                    ( Control.DeepSeq.deepseq
                                        (_LogRecord'flags x__)
                                        ( Control.DeepSeq.deepseq
                                            (_LogRecord'traceId x__)
                                            ( Control.DeepSeq.deepseq
                                                (_LogRecord'spanId x__)
                                                ()
                                            )
                                        )
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )


newtype LogRecordFlags'UnrecognizedValue
  = LogRecordFlags'UnrecognizedValue Data.Int.Int32
  deriving stock (Prelude.Eq, Prelude.Ord, Prelude.Show)


data LogRecordFlags
  = LOG_RECORD_FLAG_UNSPECIFIED
  | LOG_RECORD_FLAG_TRACE_FLAGS_MASK
  | LogRecordFlags'Unrecognized !LogRecordFlags'UnrecognizedValue
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)


instance Data.ProtoLens.MessageEnum LogRecordFlags where
  maybeToEnum 0 = Prelude.Just LOG_RECORD_FLAG_UNSPECIFIED
  maybeToEnum 255 = Prelude.Just LOG_RECORD_FLAG_TRACE_FLAGS_MASK
  maybeToEnum k =
    Prelude.Just
      ( LogRecordFlags'Unrecognized
          (LogRecordFlags'UnrecognizedValue (Prelude.fromIntegral k))
      )
  showEnum LOG_RECORD_FLAG_UNSPECIFIED =
    "LOG_RECORD_FLAG_UNSPECIFIED"
  showEnum LOG_RECORD_FLAG_TRACE_FLAGS_MASK =
    "LOG_RECORD_FLAG_TRACE_FLAGS_MASK"
  showEnum
    (LogRecordFlags'Unrecognized (LogRecordFlags'UnrecognizedValue k)) =
      Prelude.show k
  readEnum k
    | (Prelude.==) k "LOG_RECORD_FLAG_UNSPECIFIED" =
        Prelude.Just LOG_RECORD_FLAG_UNSPECIFIED
    | (Prelude.==) k "LOG_RECORD_FLAG_TRACE_FLAGS_MASK" =
        Prelude.Just LOG_RECORD_FLAG_TRACE_FLAGS_MASK
    | Prelude.otherwise =
        (Prelude.>>=) (Text.Read.readMaybe k) Data.ProtoLens.maybeToEnum


instance Prelude.Bounded LogRecordFlags where
  minBound = LOG_RECORD_FLAG_UNSPECIFIED
  maxBound = LOG_RECORD_FLAG_TRACE_FLAGS_MASK


instance Prelude.Enum LogRecordFlags where
  toEnum k__ =
    Prelude.maybe
      ( Prelude.error
          ( (Prelude.++)
              "toEnum: unknown value for enum LogRecordFlags: "
              (Prelude.show k__)
          )
      )
      Prelude.id
      (Data.ProtoLens.maybeToEnum k__)
  fromEnum LOG_RECORD_FLAG_UNSPECIFIED = 0
  fromEnum LOG_RECORD_FLAG_TRACE_FLAGS_MASK = 255
  fromEnum
    (LogRecordFlags'Unrecognized (LogRecordFlags'UnrecognizedValue k)) =
      Prelude.fromIntegral k
  succ LOG_RECORD_FLAG_TRACE_FLAGS_MASK =
    Prelude.error
      "LogRecordFlags.succ: bad argument LOG_RECORD_FLAG_TRACE_FLAGS_MASK. This value would be out of bounds."
  succ LOG_RECORD_FLAG_UNSPECIFIED = LOG_RECORD_FLAG_TRACE_FLAGS_MASK
  succ (LogRecordFlags'Unrecognized _) =
    Prelude.error
      "LogRecordFlags.succ: bad argument: unrecognized value"
  pred LOG_RECORD_FLAG_UNSPECIFIED =
    Prelude.error
      "LogRecordFlags.pred: bad argument LOG_RECORD_FLAG_UNSPECIFIED. This value would be out of bounds."
  pred LOG_RECORD_FLAG_TRACE_FLAGS_MASK = LOG_RECORD_FLAG_UNSPECIFIED
  pred (LogRecordFlags'Unrecognized _) =
    Prelude.error
      "LogRecordFlags.pred: bad argument: unrecognized value"
  enumFrom = Data.ProtoLens.Message.Enum.messageEnumFrom
  enumFromTo = Data.ProtoLens.Message.Enum.messageEnumFromTo
  enumFromThen = Data.ProtoLens.Message.Enum.messageEnumFromThen
  enumFromThenTo = Data.ProtoLens.Message.Enum.messageEnumFromThenTo


instance Data.ProtoLens.FieldDefault LogRecordFlags where
  fieldDefault = LOG_RECORD_FLAG_UNSPECIFIED


instance Control.DeepSeq.NFData LogRecordFlags where
  rnf x__ = Prelude.seq x__ ()


{- | Fields :

         * 'Proto.Opentelemetry.Proto.Logs.V1.Logs_Fields.resourceLogs' @:: Lens' LogsData [ResourceLogs]@
         * 'Proto.Opentelemetry.Proto.Logs.V1.Logs_Fields.vec'resourceLogs' @:: Lens' LogsData (Data.Vector.Vector ResourceLogs)@
-}
data LogsData = LogsData'_constructor
  { _LogsData'resourceLogs :: !(Data.Vector.Vector ResourceLogs)
  , _LogsData'_unknownFields :: !Data.ProtoLens.FieldSet
  }
  deriving stock (Prelude.Eq, Prelude.Ord)


instance Prelude.Show LogsData where
  showsPrec _ __x __s =
    Prelude.showChar
      '{'
      ( Prelude.showString
          (Data.ProtoLens.showMessageShort __x)
          (Prelude.showChar '}' __s)
      )


instance Data.ProtoLens.Field.HasField LogsData "resourceLogs" [ResourceLogs] where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _LogsData'resourceLogs
          (\x__ y__ -> x__ {_LogsData'resourceLogs = y__})
      )
      ( Lens.Family2.Unchecked.lens
          Data.Vector.Generic.toList
          (\_ y__ -> Data.Vector.Generic.fromList y__)
      )


instance Data.ProtoLens.Field.HasField LogsData "vec'resourceLogs" (Data.Vector.Vector ResourceLogs) where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _LogsData'resourceLogs
          (\x__ y__ -> x__ {_LogsData'resourceLogs = y__})
      )
      Prelude.id


instance Data.ProtoLens.Message LogsData where
  messageName _ =
    Data.Text.pack "opentelemetry.proto.logs.v1.LogsData"
  packedMessageDescriptor _ =
    "\n\
    \\bLogsData\DC2N\n\
    \\rresource_logs\CAN\SOH \ETX(\v2).opentelemetry.proto.logs.v1.ResourceLogsR\fresourceLogs"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag =
    let resourceLogs__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "resource_logs"
            ( Data.ProtoLens.MessageField Data.ProtoLens.MessageType
                :: Data.ProtoLens.FieldTypeDescriptor ResourceLogs
            )
            ( Data.ProtoLens.RepeatedField
                Data.ProtoLens.Unpacked
                (Data.ProtoLens.Field.field @"resourceLogs")
            )
            :: Data.ProtoLens.FieldDescriptor LogsData
     in Data.Map.fromList
          [(Data.ProtoLens.Tag 1, resourceLogs__field_descriptor)]
  unknownFields =
    Lens.Family2.Unchecked.lens
      _LogsData'_unknownFields
      (\x__ y__ -> x__ {_LogsData'_unknownFields = y__})
  defMessage =
    LogsData'_constructor
      { _LogsData'resourceLogs = Data.Vector.Generic.empty
      , _LogsData'_unknownFields = []
      }
  parseMessage =
    let loop
          :: LogsData
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld ResourceLogs
          -> Data.ProtoLens.Encoding.Bytes.Parser LogsData
        loop x mutable'resourceLogs =
          do
            end <- Data.ProtoLens.Encoding.Bytes.atEnd
            if end
              then do
                frozen'resourceLogs <-
                  Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                    ( Data.ProtoLens.Encoding.Growing.unsafeFreeze
                        mutable'resourceLogs
                    )
                ( let missing = []
                   in if Prelude.null missing
                        then Prelude.return ()
                        else
                          Prelude.fail
                            ( (Prelude.++)
                                "Missing required fields: "
                                (Prelude.show (missing :: [Prelude.String]))
                            )
                  )
                Prelude.return
                  ( Lens.Family2.over
                      Data.ProtoLens.unknownFields
                      (\ !t -> Prelude.reverse t)
                      ( Lens.Family2.set
                          (Data.ProtoLens.Field.field @"vec'resourceLogs")
                          frozen'resourceLogs
                          x
                      )
                  )
              else do
                tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                case tag of
                  10 ->
                    do
                      !y <-
                        (Data.ProtoLens.Encoding.Bytes.<?>)
                          ( do
                              len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                              Data.ProtoLens.Encoding.Bytes.isolate
                                (Prelude.fromIntegral len)
                                Data.ProtoLens.parseMessage
                          )
                          "resource_logs"
                      v <-
                        Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                          ( Data.ProtoLens.Encoding.Growing.append
                              mutable'resourceLogs
                              y
                          )
                      loop x v
                  wire ->
                    do
                      !y <-
                        Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                          wire
                      loop
                        ( Lens.Family2.over
                            Data.ProtoLens.unknownFields
                            (\ !t -> (:) y t)
                            x
                        )
                        mutable'resourceLogs
     in (Data.ProtoLens.Encoding.Bytes.<?>)
          ( do
              mutable'resourceLogs <-
                Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                  Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'resourceLogs
          )
          "LogsData"
  buildMessage =
    \_x ->
      (Data.Monoid.<>)
        ( Data.ProtoLens.Encoding.Bytes.foldMapBuilder
            ( \_v ->
                (Data.Monoid.<>)
                  (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                  ( (Prelude..)
                      ( \bs ->
                          (Data.Monoid.<>)
                            ( Data.ProtoLens.Encoding.Bytes.putVarInt
                                (Prelude.fromIntegral (Data.ByteString.length bs))
                            )
                            (Data.ProtoLens.Encoding.Bytes.putBytes bs)
                      )
                      Data.ProtoLens.encodeMessage
                      _v
                  )
            )
            ( Lens.Family2.view
                (Data.ProtoLens.Field.field @"vec'resourceLogs")
                _x
            )
        )
        ( Data.ProtoLens.Encoding.Wire.buildFieldSet
            (Lens.Family2.view Data.ProtoLens.unknownFields _x)
        )


instance Control.DeepSeq.NFData LogsData where
  rnf =
    \x__ ->
      Control.DeepSeq.deepseq
        (_LogsData'_unknownFields x__)
        (Control.DeepSeq.deepseq (_LogsData'resourceLogs x__) ())


{- | Fields :

         * 'Proto.Opentelemetry.Proto.Logs.V1.Logs_Fields.resource' @:: Lens' ResourceLogs Proto.Opentelemetry.Proto.Resource.V1.Resource.Resource@
         * 'Proto.Opentelemetry.Proto.Logs.V1.Logs_Fields.maybe'resource' @:: Lens' ResourceLogs (Prelude.Maybe Proto.Opentelemetry.Proto.Resource.V1.Resource.Resource)@
         * 'Proto.Opentelemetry.Proto.Logs.V1.Logs_Fields.instrumentationLibraryLogs' @:: Lens' ResourceLogs [InstrumentationLibraryLogs]@
         * 'Proto.Opentelemetry.Proto.Logs.V1.Logs_Fields.vec'instrumentationLibraryLogs' @:: Lens' ResourceLogs (Data.Vector.Vector InstrumentationLibraryLogs)@
         * 'Proto.Opentelemetry.Proto.Logs.V1.Logs_Fields.schemaUrl' @:: Lens' ResourceLogs Data.Text.Text@
-}
data ResourceLogs = ResourceLogs'_constructor
  { _ResourceLogs'resource :: !(Prelude.Maybe Proto.Opentelemetry.Proto.Resource.V1.Resource.Resource)
  , _ResourceLogs'instrumentationLibraryLogs :: !(Data.Vector.Vector InstrumentationLibraryLogs)
  , _ResourceLogs'schemaUrl :: !Data.Text.Text
  , _ResourceLogs'_unknownFields :: !Data.ProtoLens.FieldSet
  }
  deriving stock (Prelude.Eq, Prelude.Ord)


instance Prelude.Show ResourceLogs where
  showsPrec _ __x __s =
    Prelude.showChar
      '{'
      ( Prelude.showString
          (Data.ProtoLens.showMessageShort __x)
          (Prelude.showChar '}' __s)
      )


instance Data.ProtoLens.Field.HasField ResourceLogs "resource" Proto.Opentelemetry.Proto.Resource.V1.Resource.Resource where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _ResourceLogs'resource
          (\x__ y__ -> x__ {_ResourceLogs'resource = y__})
      )
      (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)


instance Data.ProtoLens.Field.HasField ResourceLogs "maybe'resource" (Prelude.Maybe Proto.Opentelemetry.Proto.Resource.V1.Resource.Resource) where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _ResourceLogs'resource
          (\x__ y__ -> x__ {_ResourceLogs'resource = y__})
      )
      Prelude.id


instance Data.ProtoLens.Field.HasField ResourceLogs "instrumentationLibraryLogs" [InstrumentationLibraryLogs] where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _ResourceLogs'instrumentationLibraryLogs
          ( \x__ y__ ->
              x__ {_ResourceLogs'instrumentationLibraryLogs = y__}
          )
      )
      ( Lens.Family2.Unchecked.lens
          Data.Vector.Generic.toList
          (\_ y__ -> Data.Vector.Generic.fromList y__)
      )


instance Data.ProtoLens.Field.HasField ResourceLogs "vec'instrumentationLibraryLogs" (Data.Vector.Vector InstrumentationLibraryLogs) where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _ResourceLogs'instrumentationLibraryLogs
          ( \x__ y__ ->
              x__ {_ResourceLogs'instrumentationLibraryLogs = y__}
          )
      )
      Prelude.id


instance Data.ProtoLens.Field.HasField ResourceLogs "schemaUrl" Data.Text.Text where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _ResourceLogs'schemaUrl
          (\x__ y__ -> x__ {_ResourceLogs'schemaUrl = y__})
      )
      Prelude.id


instance Data.ProtoLens.Message ResourceLogs where
  messageName _ =
    Data.Text.pack "opentelemetry.proto.logs.v1.ResourceLogs"
  packedMessageDescriptor _ =
    "\n\
    \\fResourceLogs\DC2E\n\
    \\bresource\CAN\SOH \SOH(\v2).opentelemetry.proto.resource.v1.ResourceR\bresource\DC2y\n\
    \\FSinstrumentation_library_logs\CAN\STX \ETX(\v27.opentelemetry.proto.logs.v1.InstrumentationLibraryLogsR\SUBinstrumentationLibraryLogs\DC2\GS\n\
    \\n\
    \schema_url\CAN\ETX \SOH(\tR\tschemaUrl"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag =
    let resource__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "resource"
            ( Data.ProtoLens.MessageField Data.ProtoLens.MessageType
                :: Data.ProtoLens.FieldTypeDescriptor Proto.Opentelemetry.Proto.Resource.V1.Resource.Resource
            )
            ( Data.ProtoLens.OptionalField
                (Data.ProtoLens.Field.field @"maybe'resource")
            )
            :: Data.ProtoLens.FieldDescriptor ResourceLogs
        instrumentationLibraryLogs__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "instrumentation_library_logs"
            ( Data.ProtoLens.MessageField Data.ProtoLens.MessageType
                :: Data.ProtoLens.FieldTypeDescriptor InstrumentationLibraryLogs
            )
            ( Data.ProtoLens.RepeatedField
                Data.ProtoLens.Unpacked
                (Data.ProtoLens.Field.field @"instrumentationLibraryLogs")
            )
            :: Data.ProtoLens.FieldDescriptor ResourceLogs
        schemaUrl__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "schema_url"
            ( Data.ProtoLens.ScalarField Data.ProtoLens.StringField
                :: Data.ProtoLens.FieldTypeDescriptor Data.Text.Text
            )
            ( Data.ProtoLens.PlainField
                Data.ProtoLens.Optional
                (Data.ProtoLens.Field.field @"schemaUrl")
            )
            :: Data.ProtoLens.FieldDescriptor ResourceLogs
     in Data.Map.fromList
          [ (Data.ProtoLens.Tag 1, resource__field_descriptor)
          ,
            ( Data.ProtoLens.Tag 2
            , instrumentationLibraryLogs__field_descriptor
            )
          , (Data.ProtoLens.Tag 3, schemaUrl__field_descriptor)
          ]
  unknownFields =
    Lens.Family2.Unchecked.lens
      _ResourceLogs'_unknownFields
      (\x__ y__ -> x__ {_ResourceLogs'_unknownFields = y__})
  defMessage =
    ResourceLogs'_constructor
      { _ResourceLogs'resource = Prelude.Nothing
      , _ResourceLogs'instrumentationLibraryLogs = Data.Vector.Generic.empty
      , _ResourceLogs'schemaUrl = Data.ProtoLens.fieldDefault
      , _ResourceLogs'_unknownFields = []
      }
  parseMessage =
    let loop
          :: ResourceLogs
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld InstrumentationLibraryLogs
          -> Data.ProtoLens.Encoding.Bytes.Parser ResourceLogs
        loop x mutable'instrumentationLibraryLogs =
          do
            end <- Data.ProtoLens.Encoding.Bytes.atEnd
            if end
              then do
                frozen'instrumentationLibraryLogs <-
                  Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                    ( Data.ProtoLens.Encoding.Growing.unsafeFreeze
                        mutable'instrumentationLibraryLogs
                    )
                ( let missing = []
                   in if Prelude.null missing
                        then Prelude.return ()
                        else
                          Prelude.fail
                            ( (Prelude.++)
                                "Missing required fields: "
                                (Prelude.show (missing :: [Prelude.String]))
                            )
                  )
                Prelude.return
                  ( Lens.Family2.over
                      Data.ProtoLens.unknownFields
                      (\ !t -> Prelude.reverse t)
                      ( Lens.Family2.set
                          (Data.ProtoLens.Field.field @"vec'instrumentationLibraryLogs")
                          frozen'instrumentationLibraryLogs
                          x
                      )
                  )
              else do
                tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                case tag of
                  10 ->
                    do
                      y <-
                        (Data.ProtoLens.Encoding.Bytes.<?>)
                          ( do
                              len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                              Data.ProtoLens.Encoding.Bytes.isolate
                                (Prelude.fromIntegral len)
                                Data.ProtoLens.parseMessage
                          )
                          "resource"
                      loop
                        (Lens.Family2.set (Data.ProtoLens.Field.field @"resource") y x)
                        mutable'instrumentationLibraryLogs
                  18 ->
                    do
                      !y <-
                        (Data.ProtoLens.Encoding.Bytes.<?>)
                          ( do
                              len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                              Data.ProtoLens.Encoding.Bytes.isolate
                                (Prelude.fromIntegral len)
                                Data.ProtoLens.parseMessage
                          )
                          "instrumentation_library_logs"
                      v <-
                        Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                          ( Data.ProtoLens.Encoding.Growing.append
                              mutable'instrumentationLibraryLogs
                              y
                          )
                      loop x v
                  26 ->
                    do
                      y <-
                        (Data.ProtoLens.Encoding.Bytes.<?>)
                          ( do
                              value <- do
                                len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                Data.ProtoLens.Encoding.Bytes.getBytes
                                  (Prelude.fromIntegral len)
                              Data.ProtoLens.Encoding.Bytes.runEither
                                ( case Data.Text.Encoding.decodeUtf8' value of
                                    (Prelude.Left err) ->
                                      Prelude.Left (Prelude.show err)
                                    (Prelude.Right r) -> Prelude.Right r
                                )
                          )
                          "schema_url"
                      loop
                        (Lens.Family2.set (Data.ProtoLens.Field.field @"schemaUrl") y x)
                        mutable'instrumentationLibraryLogs
                  wire ->
                    do
                      !y <-
                        Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                          wire
                      loop
                        ( Lens.Family2.over
                            Data.ProtoLens.unknownFields
                            (\ !t -> (:) y t)
                            x
                        )
                        mutable'instrumentationLibraryLogs
     in (Data.ProtoLens.Encoding.Bytes.<?>)
          ( do
              mutable'instrumentationLibraryLogs <-
                Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                  Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'instrumentationLibraryLogs
          )
          "ResourceLogs"
  buildMessage =
    \_x ->
      (Data.Monoid.<>)
        ( case Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'resource") _x of
            Prelude.Nothing -> Data.Monoid.mempty
            (Prelude.Just _v) ->
              (Data.Monoid.<>)
                (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                ( (Prelude..)
                    ( \bs ->
                        (Data.Monoid.<>)
                          ( Data.ProtoLens.Encoding.Bytes.putVarInt
                              (Prelude.fromIntegral (Data.ByteString.length bs))
                          )
                          (Data.ProtoLens.Encoding.Bytes.putBytes bs)
                    )
                    Data.ProtoLens.encodeMessage
                    _v
                )
        )
        ( (Data.Monoid.<>)
            ( Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                ( \_v ->
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                      ( (Prelude..)
                          ( \bs ->
                              (Data.Monoid.<>)
                                ( Data.ProtoLens.Encoding.Bytes.putVarInt
                                    (Prelude.fromIntegral (Data.ByteString.length bs))
                                )
                                (Data.ProtoLens.Encoding.Bytes.putBytes bs)
                          )
                          Data.ProtoLens.encodeMessage
                          _v
                      )
                )
                ( Lens.Family2.view
                    (Data.ProtoLens.Field.field @"vec'instrumentationLibraryLogs")
                    _x
                )
            )
            ( (Data.Monoid.<>)
                ( let _v = Lens.Family2.view (Data.ProtoLens.Field.field @"schemaUrl") _x
                   in if (Prelude.==) _v Data.ProtoLens.fieldDefault
                        then Data.Monoid.mempty
                        else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 26)
                            ( (Prelude..)
                                ( \bs ->
                                    (Data.Monoid.<>)
                                      ( Data.ProtoLens.Encoding.Bytes.putVarInt
                                          (Prelude.fromIntegral (Data.ByteString.length bs))
                                      )
                                      (Data.ProtoLens.Encoding.Bytes.putBytes bs)
                                )
                                Data.Text.Encoding.encodeUtf8
                                _v
                            )
                )
                ( Data.ProtoLens.Encoding.Wire.buildFieldSet
                    (Lens.Family2.view Data.ProtoLens.unknownFields _x)
                )
            )
        )


instance Control.DeepSeq.NFData ResourceLogs where
  rnf =
    \x__ ->
      Control.DeepSeq.deepseq
        (_ResourceLogs'_unknownFields x__)
        ( Control.DeepSeq.deepseq
            (_ResourceLogs'resource x__)
            ( Control.DeepSeq.deepseq
                (_ResourceLogs'instrumentationLibraryLogs x__)
                (Control.DeepSeq.deepseq (_ResourceLogs'schemaUrl x__) ())
            )
        )


newtype SeverityNumber'UnrecognizedValue
  = SeverityNumber'UnrecognizedValue Data.Int.Int32
  deriving stock (Prelude.Eq, Prelude.Ord, Prelude.Show)


data SeverityNumber
  = SEVERITY_NUMBER_UNSPECIFIED
  | SEVERITY_NUMBER_TRACE
  | SEVERITY_NUMBER_TRACE2
  | SEVERITY_NUMBER_TRACE3
  | SEVERITY_NUMBER_TRACE4
  | SEVERITY_NUMBER_DEBUG
  | SEVERITY_NUMBER_DEBUG2
  | SEVERITY_NUMBER_DEBUG3
  | SEVERITY_NUMBER_DEBUG4
  | SEVERITY_NUMBER_INFO
  | SEVERITY_NUMBER_INFO2
  | SEVERITY_NUMBER_INFO3
  | SEVERITY_NUMBER_INFO4
  | SEVERITY_NUMBER_WARN
  | SEVERITY_NUMBER_WARN2
  | SEVERITY_NUMBER_WARN3
  | SEVERITY_NUMBER_WARN4
  | SEVERITY_NUMBER_ERROR
  | SEVERITY_NUMBER_ERROR2
  | SEVERITY_NUMBER_ERROR3
  | SEVERITY_NUMBER_ERROR4
  | SEVERITY_NUMBER_FATAL
  | SEVERITY_NUMBER_FATAL2
  | SEVERITY_NUMBER_FATAL3
  | SEVERITY_NUMBER_FATAL4
  | SeverityNumber'Unrecognized !SeverityNumber'UnrecognizedValue
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)


instance Data.ProtoLens.MessageEnum SeverityNumber where
  maybeToEnum 0 = Prelude.Just SEVERITY_NUMBER_UNSPECIFIED
  maybeToEnum 1 = Prelude.Just SEVERITY_NUMBER_TRACE
  maybeToEnum 2 = Prelude.Just SEVERITY_NUMBER_TRACE2
  maybeToEnum 3 = Prelude.Just SEVERITY_NUMBER_TRACE3
  maybeToEnum 4 = Prelude.Just SEVERITY_NUMBER_TRACE4
  maybeToEnum 5 = Prelude.Just SEVERITY_NUMBER_DEBUG
  maybeToEnum 6 = Prelude.Just SEVERITY_NUMBER_DEBUG2
  maybeToEnum 7 = Prelude.Just SEVERITY_NUMBER_DEBUG3
  maybeToEnum 8 = Prelude.Just SEVERITY_NUMBER_DEBUG4
  maybeToEnum 9 = Prelude.Just SEVERITY_NUMBER_INFO
  maybeToEnum 10 = Prelude.Just SEVERITY_NUMBER_INFO2
  maybeToEnum 11 = Prelude.Just SEVERITY_NUMBER_INFO3
  maybeToEnum 12 = Prelude.Just SEVERITY_NUMBER_INFO4
  maybeToEnum 13 = Prelude.Just SEVERITY_NUMBER_WARN
  maybeToEnum 14 = Prelude.Just SEVERITY_NUMBER_WARN2
  maybeToEnum 15 = Prelude.Just SEVERITY_NUMBER_WARN3
  maybeToEnum 16 = Prelude.Just SEVERITY_NUMBER_WARN4
  maybeToEnum 17 = Prelude.Just SEVERITY_NUMBER_ERROR
  maybeToEnum 18 = Prelude.Just SEVERITY_NUMBER_ERROR2
  maybeToEnum 19 = Prelude.Just SEVERITY_NUMBER_ERROR3
  maybeToEnum 20 = Prelude.Just SEVERITY_NUMBER_ERROR4
  maybeToEnum 21 = Prelude.Just SEVERITY_NUMBER_FATAL
  maybeToEnum 22 = Prelude.Just SEVERITY_NUMBER_FATAL2
  maybeToEnum 23 = Prelude.Just SEVERITY_NUMBER_FATAL3
  maybeToEnum 24 = Prelude.Just SEVERITY_NUMBER_FATAL4
  maybeToEnum k =
    Prelude.Just
      ( SeverityNumber'Unrecognized
          (SeverityNumber'UnrecognizedValue (Prelude.fromIntegral k))
      )
  showEnum SEVERITY_NUMBER_UNSPECIFIED =
    "SEVERITY_NUMBER_UNSPECIFIED"
  showEnum SEVERITY_NUMBER_TRACE = "SEVERITY_NUMBER_TRACE"
  showEnum SEVERITY_NUMBER_TRACE2 = "SEVERITY_NUMBER_TRACE2"
  showEnum SEVERITY_NUMBER_TRACE3 = "SEVERITY_NUMBER_TRACE3"
  showEnum SEVERITY_NUMBER_TRACE4 = "SEVERITY_NUMBER_TRACE4"
  showEnum SEVERITY_NUMBER_DEBUG = "SEVERITY_NUMBER_DEBUG"
  showEnum SEVERITY_NUMBER_DEBUG2 = "SEVERITY_NUMBER_DEBUG2"
  showEnum SEVERITY_NUMBER_DEBUG3 = "SEVERITY_NUMBER_DEBUG3"
  showEnum SEVERITY_NUMBER_DEBUG4 = "SEVERITY_NUMBER_DEBUG4"
  showEnum SEVERITY_NUMBER_INFO = "SEVERITY_NUMBER_INFO"
  showEnum SEVERITY_NUMBER_INFO2 = "SEVERITY_NUMBER_INFO2"
  showEnum SEVERITY_NUMBER_INFO3 = "SEVERITY_NUMBER_INFO3"
  showEnum SEVERITY_NUMBER_INFO4 = "SEVERITY_NUMBER_INFO4"
  showEnum SEVERITY_NUMBER_WARN = "SEVERITY_NUMBER_WARN"
  showEnum SEVERITY_NUMBER_WARN2 = "SEVERITY_NUMBER_WARN2"
  showEnum SEVERITY_NUMBER_WARN3 = "SEVERITY_NUMBER_WARN3"
  showEnum SEVERITY_NUMBER_WARN4 = "SEVERITY_NUMBER_WARN4"
  showEnum SEVERITY_NUMBER_ERROR = "SEVERITY_NUMBER_ERROR"
  showEnum SEVERITY_NUMBER_ERROR2 = "SEVERITY_NUMBER_ERROR2"
  showEnum SEVERITY_NUMBER_ERROR3 = "SEVERITY_NUMBER_ERROR3"
  showEnum SEVERITY_NUMBER_ERROR4 = "SEVERITY_NUMBER_ERROR4"
  showEnum SEVERITY_NUMBER_FATAL = "SEVERITY_NUMBER_FATAL"
  showEnum SEVERITY_NUMBER_FATAL2 = "SEVERITY_NUMBER_FATAL2"
  showEnum SEVERITY_NUMBER_FATAL3 = "SEVERITY_NUMBER_FATAL3"
  showEnum SEVERITY_NUMBER_FATAL4 = "SEVERITY_NUMBER_FATAL4"
  showEnum
    (SeverityNumber'Unrecognized (SeverityNumber'UnrecognizedValue k)) =
      Prelude.show k
  readEnum k
    | (Prelude.==) k "SEVERITY_NUMBER_UNSPECIFIED" =
        Prelude.Just SEVERITY_NUMBER_UNSPECIFIED
    | (Prelude.==) k "SEVERITY_NUMBER_TRACE" =
        Prelude.Just SEVERITY_NUMBER_TRACE
    | (Prelude.==) k "SEVERITY_NUMBER_TRACE2" =
        Prelude.Just SEVERITY_NUMBER_TRACE2
    | (Prelude.==) k "SEVERITY_NUMBER_TRACE3" =
        Prelude.Just SEVERITY_NUMBER_TRACE3
    | (Prelude.==) k "SEVERITY_NUMBER_TRACE4" =
        Prelude.Just SEVERITY_NUMBER_TRACE4
    | (Prelude.==) k "SEVERITY_NUMBER_DEBUG" =
        Prelude.Just SEVERITY_NUMBER_DEBUG
    | (Prelude.==) k "SEVERITY_NUMBER_DEBUG2" =
        Prelude.Just SEVERITY_NUMBER_DEBUG2
    | (Prelude.==) k "SEVERITY_NUMBER_DEBUG3" =
        Prelude.Just SEVERITY_NUMBER_DEBUG3
    | (Prelude.==) k "SEVERITY_NUMBER_DEBUG4" =
        Prelude.Just SEVERITY_NUMBER_DEBUG4
    | (Prelude.==) k "SEVERITY_NUMBER_INFO" =
        Prelude.Just SEVERITY_NUMBER_INFO
    | (Prelude.==) k "SEVERITY_NUMBER_INFO2" =
        Prelude.Just SEVERITY_NUMBER_INFO2
    | (Prelude.==) k "SEVERITY_NUMBER_INFO3" =
        Prelude.Just SEVERITY_NUMBER_INFO3
    | (Prelude.==) k "SEVERITY_NUMBER_INFO4" =
        Prelude.Just SEVERITY_NUMBER_INFO4
    | (Prelude.==) k "SEVERITY_NUMBER_WARN" =
        Prelude.Just SEVERITY_NUMBER_WARN
    | (Prelude.==) k "SEVERITY_NUMBER_WARN2" =
        Prelude.Just SEVERITY_NUMBER_WARN2
    | (Prelude.==) k "SEVERITY_NUMBER_WARN3" =
        Prelude.Just SEVERITY_NUMBER_WARN3
    | (Prelude.==) k "SEVERITY_NUMBER_WARN4" =
        Prelude.Just SEVERITY_NUMBER_WARN4
    | (Prelude.==) k "SEVERITY_NUMBER_ERROR" =
        Prelude.Just SEVERITY_NUMBER_ERROR
    | (Prelude.==) k "SEVERITY_NUMBER_ERROR2" =
        Prelude.Just SEVERITY_NUMBER_ERROR2
    | (Prelude.==) k "SEVERITY_NUMBER_ERROR3" =
        Prelude.Just SEVERITY_NUMBER_ERROR3
    | (Prelude.==) k "SEVERITY_NUMBER_ERROR4" =
        Prelude.Just SEVERITY_NUMBER_ERROR4
    | (Prelude.==) k "SEVERITY_NUMBER_FATAL" =
        Prelude.Just SEVERITY_NUMBER_FATAL
    | (Prelude.==) k "SEVERITY_NUMBER_FATAL2" =
        Prelude.Just SEVERITY_NUMBER_FATAL2
    | (Prelude.==) k "SEVERITY_NUMBER_FATAL3" =
        Prelude.Just SEVERITY_NUMBER_FATAL3
    | (Prelude.==) k "SEVERITY_NUMBER_FATAL4" =
        Prelude.Just SEVERITY_NUMBER_FATAL4
    | Prelude.otherwise =
        (Prelude.>>=) (Text.Read.readMaybe k) Data.ProtoLens.maybeToEnum


instance Prelude.Bounded SeverityNumber where
  minBound = SEVERITY_NUMBER_UNSPECIFIED
  maxBound = SEVERITY_NUMBER_FATAL4


instance Prelude.Enum SeverityNumber where
  toEnum k__ =
    Prelude.maybe
      ( Prelude.error
          ( (Prelude.++)
              "toEnum: unknown value for enum SeverityNumber: "
              (Prelude.show k__)
          )
      )
      Prelude.id
      (Data.ProtoLens.maybeToEnum k__)
  fromEnum SEVERITY_NUMBER_UNSPECIFIED = 0
  fromEnum SEVERITY_NUMBER_TRACE = 1
  fromEnum SEVERITY_NUMBER_TRACE2 = 2
  fromEnum SEVERITY_NUMBER_TRACE3 = 3
  fromEnum SEVERITY_NUMBER_TRACE4 = 4
  fromEnum SEVERITY_NUMBER_DEBUG = 5
  fromEnum SEVERITY_NUMBER_DEBUG2 = 6
  fromEnum SEVERITY_NUMBER_DEBUG3 = 7
  fromEnum SEVERITY_NUMBER_DEBUG4 = 8
  fromEnum SEVERITY_NUMBER_INFO = 9
  fromEnum SEVERITY_NUMBER_INFO2 = 10
  fromEnum SEVERITY_NUMBER_INFO3 = 11
  fromEnum SEVERITY_NUMBER_INFO4 = 12
  fromEnum SEVERITY_NUMBER_WARN = 13
  fromEnum SEVERITY_NUMBER_WARN2 = 14
  fromEnum SEVERITY_NUMBER_WARN3 = 15
  fromEnum SEVERITY_NUMBER_WARN4 = 16
  fromEnum SEVERITY_NUMBER_ERROR = 17
  fromEnum SEVERITY_NUMBER_ERROR2 = 18
  fromEnum SEVERITY_NUMBER_ERROR3 = 19
  fromEnum SEVERITY_NUMBER_ERROR4 = 20
  fromEnum SEVERITY_NUMBER_FATAL = 21
  fromEnum SEVERITY_NUMBER_FATAL2 = 22
  fromEnum SEVERITY_NUMBER_FATAL3 = 23
  fromEnum SEVERITY_NUMBER_FATAL4 = 24
  fromEnum
    (SeverityNumber'Unrecognized (SeverityNumber'UnrecognizedValue k)) =
      Prelude.fromIntegral k
  succ SEVERITY_NUMBER_FATAL4 =
    Prelude.error
      "SeverityNumber.succ: bad argument SEVERITY_NUMBER_FATAL4. This value would be out of bounds."
  succ SEVERITY_NUMBER_UNSPECIFIED = SEVERITY_NUMBER_TRACE
  succ SEVERITY_NUMBER_TRACE = SEVERITY_NUMBER_TRACE2
  succ SEVERITY_NUMBER_TRACE2 = SEVERITY_NUMBER_TRACE3
  succ SEVERITY_NUMBER_TRACE3 = SEVERITY_NUMBER_TRACE4
  succ SEVERITY_NUMBER_TRACE4 = SEVERITY_NUMBER_DEBUG
  succ SEVERITY_NUMBER_DEBUG = SEVERITY_NUMBER_DEBUG2
  succ SEVERITY_NUMBER_DEBUG2 = SEVERITY_NUMBER_DEBUG3
  succ SEVERITY_NUMBER_DEBUG3 = SEVERITY_NUMBER_DEBUG4
  succ SEVERITY_NUMBER_DEBUG4 = SEVERITY_NUMBER_INFO
  succ SEVERITY_NUMBER_INFO = SEVERITY_NUMBER_INFO2
  succ SEVERITY_NUMBER_INFO2 = SEVERITY_NUMBER_INFO3
  succ SEVERITY_NUMBER_INFO3 = SEVERITY_NUMBER_INFO4
  succ SEVERITY_NUMBER_INFO4 = SEVERITY_NUMBER_WARN
  succ SEVERITY_NUMBER_WARN = SEVERITY_NUMBER_WARN2
  succ SEVERITY_NUMBER_WARN2 = SEVERITY_NUMBER_WARN3
  succ SEVERITY_NUMBER_WARN3 = SEVERITY_NUMBER_WARN4
  succ SEVERITY_NUMBER_WARN4 = SEVERITY_NUMBER_ERROR
  succ SEVERITY_NUMBER_ERROR = SEVERITY_NUMBER_ERROR2
  succ SEVERITY_NUMBER_ERROR2 = SEVERITY_NUMBER_ERROR3
  succ SEVERITY_NUMBER_ERROR3 = SEVERITY_NUMBER_ERROR4
  succ SEVERITY_NUMBER_ERROR4 = SEVERITY_NUMBER_FATAL
  succ SEVERITY_NUMBER_FATAL = SEVERITY_NUMBER_FATAL2
  succ SEVERITY_NUMBER_FATAL2 = SEVERITY_NUMBER_FATAL3
  succ SEVERITY_NUMBER_FATAL3 = SEVERITY_NUMBER_FATAL4
  succ (SeverityNumber'Unrecognized _) =
    Prelude.error
      "SeverityNumber.succ: bad argument: unrecognized value"
  pred SEVERITY_NUMBER_UNSPECIFIED =
    Prelude.error
      "SeverityNumber.pred: bad argument SEVERITY_NUMBER_UNSPECIFIED. This value would be out of bounds."
  pred SEVERITY_NUMBER_TRACE = SEVERITY_NUMBER_UNSPECIFIED
  pred SEVERITY_NUMBER_TRACE2 = SEVERITY_NUMBER_TRACE
  pred SEVERITY_NUMBER_TRACE3 = SEVERITY_NUMBER_TRACE2
  pred SEVERITY_NUMBER_TRACE4 = SEVERITY_NUMBER_TRACE3
  pred SEVERITY_NUMBER_DEBUG = SEVERITY_NUMBER_TRACE4
  pred SEVERITY_NUMBER_DEBUG2 = SEVERITY_NUMBER_DEBUG
  pred SEVERITY_NUMBER_DEBUG3 = SEVERITY_NUMBER_DEBUG2
  pred SEVERITY_NUMBER_DEBUG4 = SEVERITY_NUMBER_DEBUG3
  pred SEVERITY_NUMBER_INFO = SEVERITY_NUMBER_DEBUG4
  pred SEVERITY_NUMBER_INFO2 = SEVERITY_NUMBER_INFO
  pred SEVERITY_NUMBER_INFO3 = SEVERITY_NUMBER_INFO2
  pred SEVERITY_NUMBER_INFO4 = SEVERITY_NUMBER_INFO3
  pred SEVERITY_NUMBER_WARN = SEVERITY_NUMBER_INFO4
  pred SEVERITY_NUMBER_WARN2 = SEVERITY_NUMBER_WARN
  pred SEVERITY_NUMBER_WARN3 = SEVERITY_NUMBER_WARN2
  pred SEVERITY_NUMBER_WARN4 = SEVERITY_NUMBER_WARN3
  pred SEVERITY_NUMBER_ERROR = SEVERITY_NUMBER_WARN4
  pred SEVERITY_NUMBER_ERROR2 = SEVERITY_NUMBER_ERROR
  pred SEVERITY_NUMBER_ERROR3 = SEVERITY_NUMBER_ERROR2
  pred SEVERITY_NUMBER_ERROR4 = SEVERITY_NUMBER_ERROR3
  pred SEVERITY_NUMBER_FATAL = SEVERITY_NUMBER_ERROR4
  pred SEVERITY_NUMBER_FATAL2 = SEVERITY_NUMBER_FATAL
  pred SEVERITY_NUMBER_FATAL3 = SEVERITY_NUMBER_FATAL2
  pred SEVERITY_NUMBER_FATAL4 = SEVERITY_NUMBER_FATAL3
  pred (SeverityNumber'Unrecognized _) =
    Prelude.error
      "SeverityNumber.pred: bad argument: unrecognized value"
  enumFrom = Data.ProtoLens.Message.Enum.messageEnumFrom
  enumFromTo = Data.ProtoLens.Message.Enum.messageEnumFromTo
  enumFromThen = Data.ProtoLens.Message.Enum.messageEnumFromThen
  enumFromThenTo = Data.ProtoLens.Message.Enum.messageEnumFromThenTo


instance Data.ProtoLens.FieldDefault SeverityNumber where
  fieldDefault = SEVERITY_NUMBER_UNSPECIFIED


instance Control.DeepSeq.NFData SeverityNumber where
  rnf x__ = Prelude.seq x__ ()


packedFileDescriptor :: Data.ByteString.ByteString
packedFileDescriptor =
  "\n\
  \&opentelemetry/proto/logs/v1/logs.proto\DC2\ESCopentelemetry.proto.logs.v1\SUB*opentelemetry/proto/common/v1/common.proto\SUB.opentelemetry/proto/resource/v1/resource.proto\"Z\n\
  \\bLogsData\DC2N\n\
  \\rresource_logs\CAN\SOH \ETX(\v2).opentelemetry.proto.logs.v1.ResourceLogsR\fresourceLogs\"\239\SOH\n\
  \\fResourceLogs\DC2E\n\
  \\bresource\CAN\SOH \SOH(\v2).opentelemetry.proto.resource.v1.ResourceR\bresource\DC2y\n\
  \\FSinstrumentation_library_logs\CAN\STX \ETX(\v27.opentelemetry.proto.logs.v1.InstrumentationLibraryLogsR\SUBinstrumentationLibraryLogs\DC2\GS\n\
  \\n\
  \schema_url\CAN\ETX \SOH(\tR\tschemaUrl\"\231\SOH\n\
  \\SUBInstrumentationLibraryLogs\DC2n\n\
  \\ETBinstrumentation_library\CAN\SOH \SOH(\v25.opentelemetry.proto.common.v1.InstrumentationLibraryR\SYNinstrumentationLibrary\DC2:\n\
  \\EOTlogs\CAN\STX \ETX(\v2&.opentelemetry.proto.logs.v1.LogRecordR\EOTlogs\DC2\GS\n\
  \\n\
  \schema_url\CAN\ETX \SOH(\tR\tschemaUrl\"\202\ETX\n\
  \\tLogRecord\DC2$\n\
  \\SOtime_unix_nano\CAN\SOH \SOH(\ACKR\ftimeUnixNano\DC2T\n\
  \\SIseverity_number\CAN\STX \SOH(\SO2+.opentelemetry.proto.logs.v1.SeverityNumberR\SOseverityNumber\DC2#\n\
  \\rseverity_text\CAN\ETX \SOH(\tR\fseverityText\DC2\DC2\n\
  \\EOTname\CAN\EOT \SOH(\tR\EOTname\DC2;\n\
  \\EOTbody\CAN\ENQ \SOH(\v2'.opentelemetry.proto.common.v1.AnyValueR\EOTbody\DC2G\n\
  \\n\
  \attributes\CAN\ACK \ETX(\v2'.opentelemetry.proto.common.v1.KeyValueR\n\
  \attributes\DC28\n\
  \\CANdropped_attributes_count\CAN\a \SOH(\rR\SYNdroppedAttributesCount\DC2\DC4\n\
  \\ENQflags\CAN\b \SOH(\aR\ENQflags\DC2\EM\n\
  \\btrace_id\CAN\t \SOH(\fR\atraceId\DC2\ETB\n\
  \\aspan_id\CAN\n\
  \ \SOH(\fR\ACKspanId*\195\ENQ\n\
  \\SOSeverityNumber\DC2\US\n\
  \\ESCSEVERITY_NUMBER_UNSPECIFIED\DLE\NUL\DC2\EM\n\
  \\NAKSEVERITY_NUMBER_TRACE\DLE\SOH\DC2\SUB\n\
  \\SYNSEVERITY_NUMBER_TRACE2\DLE\STX\DC2\SUB\n\
  \\SYNSEVERITY_NUMBER_TRACE3\DLE\ETX\DC2\SUB\n\
  \\SYNSEVERITY_NUMBER_TRACE4\DLE\EOT\DC2\EM\n\
  \\NAKSEVERITY_NUMBER_DEBUG\DLE\ENQ\DC2\SUB\n\
  \\SYNSEVERITY_NUMBER_DEBUG2\DLE\ACK\DC2\SUB\n\
  \\SYNSEVERITY_NUMBER_DEBUG3\DLE\a\DC2\SUB\n\
  \\SYNSEVERITY_NUMBER_DEBUG4\DLE\b\DC2\CAN\n\
  \\DC4SEVERITY_NUMBER_INFO\DLE\t\DC2\EM\n\
  \\NAKSEVERITY_NUMBER_INFO2\DLE\n\
  \\DC2\EM\n\
  \\NAKSEVERITY_NUMBER_INFO3\DLE\v\DC2\EM\n\
  \\NAKSEVERITY_NUMBER_INFO4\DLE\f\DC2\CAN\n\
  \\DC4SEVERITY_NUMBER_WARN\DLE\r\DC2\EM\n\
  \\NAKSEVERITY_NUMBER_WARN2\DLE\SO\DC2\EM\n\
  \\NAKSEVERITY_NUMBER_WARN3\DLE\SI\DC2\EM\n\
  \\NAKSEVERITY_NUMBER_WARN4\DLE\DLE\DC2\EM\n\
  \\NAKSEVERITY_NUMBER_ERROR\DLE\DC1\DC2\SUB\n\
  \\SYNSEVERITY_NUMBER_ERROR2\DLE\DC2\DC2\SUB\n\
  \\SYNSEVERITY_NUMBER_ERROR3\DLE\DC3\DC2\SUB\n\
  \\SYNSEVERITY_NUMBER_ERROR4\DLE\DC4\DC2\EM\n\
  \\NAKSEVERITY_NUMBER_FATAL\DLE\NAK\DC2\SUB\n\
  \\SYNSEVERITY_NUMBER_FATAL2\DLE\SYN\DC2\SUB\n\
  \\SYNSEVERITY_NUMBER_FATAL3\DLE\ETB\DC2\SUB\n\
  \\SYNSEVERITY_NUMBER_FATAL4\DLE\CAN*X\n\
  \\SOLogRecordFlags\DC2\US\n\
  \\ESCLOG_RECORD_FLAG_UNSPECIFIED\DLE\NUL\DC2%\n\
  \ LOG_RECORD_FLAG_TRACE_FLAGS_MASK\DLE\255\SOHBk\n\
  \\RSio.opentelemetry.proto.logs.v1B\tLogsProtoP\SOHZ<github.com/open-telemetry/opentelemetry-proto/gen/go/logs/v1J\147\&4\n\
  \\a\DC2\ENQ\SO\NUL\158\SOH\SOH\n\
  \\200\EOT\n\
  \\SOH\f\DC2\ETX\SO\NUL\DC22\189\EOT Copyright 2020, OpenTelemetry Authors\n\
  \\n\
  \ Licensed under the Apache License, Version 2.0 (the \"License\");\n\
  \ you may not use this file except in compliance with the License.\n\
  \ You may obtain a copy of the License at\n\
  \\n\
  \     http://www.apache.org/licenses/LICENSE-2.0\n\
  \\n\
  \ Unless required by applicable law or agreed to in writing, software\n\
  \ distributed under the License is distributed on an \"AS IS\" BASIS,\n\
  \ WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n\
  \ See the License for the specific language governing permissions and\n\
  \ limitations under the License.\n\
  \\n\
  \\b\n\
  \\SOH\STX\DC2\ETX\DLE\NUL$\n\
  \\t\n\
  \\STX\ETX\NUL\DC2\ETX\DC2\NUL4\n\
  \\t\n\
  \\STX\ETX\SOH\DC2\ETX\DC3\NUL8\n\
  \\b\n\
  \\SOH\b\DC2\ETX\NAK\NUL\"\n\
  \\t\n\
  \\STX\b\n\
  \\DC2\ETX\NAK\NUL\"\n\
  \\b\n\
  \\SOH\b\DC2\ETX\SYN\NUL7\n\
  \\t\n\
  \\STX\b\SOH\DC2\ETX\SYN\NUL7\n\
  \\b\n\
  \\SOH\b\DC2\ETX\ETB\NUL*\n\
  \\t\n\
  \\STX\b\b\DC2\ETX\ETB\NUL*\n\
  \\b\n\
  \\SOH\b\DC2\ETX\CAN\NULS\n\
  \\t\n\
  \\STX\b\v\DC2\ETX\CAN\NULS\n\
  \\200\ETX\n\
  \\STX\EOT\NUL\DC2\EOT$\NUL+\SOH\SUB\187\ETX LogsData represents the logs data that can be stored in a persistent storage,\n\
  \ OR can be embedded by other protocols that transfer OTLP logs data but do not\n\
  \ implement the OTLP protocol.\n\
  \\n\
  \ The main difference between this message and collector protocol is that\n\
  \ in this message there will not be any \"control\" or \"metadata\" specific to\n\
  \ OTLP protocol.\n\
  \\n\
  \ When new fields are added into this message, the OTLP request MUST be updated\n\
  \ as well.\n\
  \\n\
  \\n\
  \\n\
  \\ETX\EOT\NUL\SOH\DC2\ETX$\b\DLE\n\
  \\173\STX\n\
  \\EOT\EOT\NUL\STX\NUL\DC2\ETX*\STX*\SUB\159\STX An array of ResourceLogs.\n\
  \ For data coming from a single resource this array will typically contain\n\
  \ one element. Intermediary nodes that receive data from multiple origins\n\
  \ typically batch the data before forwarding further and in that case this\n\
  \ array will contain multiple elements.\n\
  \\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\NUL\EOT\DC2\ETX*\STX\n\
  \\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\NUL\ACK\DC2\ETX*\v\ETB\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\NUL\SOH\DC2\ETX*\CAN%\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\NUL\ETX\DC2\ETX*()\n\
  \I\n\
  \\STX\EOT\SOH\DC2\EOT.\NUL:\SOH\SUB= A collection of InstrumentationLibraryLogs from a Resource.\n\
  \\n\
  \\n\
  \\n\
  \\ETX\EOT\SOH\SOH\DC2\ETX.\b\DC4\n\
  \r\n\
  \\EOT\EOT\SOH\STX\NUL\DC2\ETX1\STX8\SUBe The resource for the logs in this message.\n\
  \ If this field is not set then resource info is unknown.\n\
  \\n\
  \\f\n\
  \\ENQ\EOT\SOH\STX\NUL\ACK\DC2\ETX1\STX*\n\
  \\f\n\
  \\ENQ\EOT\SOH\STX\NUL\SOH\DC2\ETX1+3\n\
  \\f\n\
  \\ENQ\EOT\SOH\STX\NUL\ETX\DC2\ETX167\n\
  \S\n\
  \\EOT\EOT\SOH\STX\SOH\DC2\ETX4\STXG\SUBF A list of InstrumentationLibraryLogs that originate from a resource.\n\
  \\n\
  \\f\n\
  \\ENQ\EOT\SOH\STX\SOH\EOT\DC2\ETX4\STX\n\
  \\n\
  \\f\n\
  \\ENQ\EOT\SOH\STX\SOH\ACK\DC2\ETX4\v%\n\
  \\f\n\
  \\ENQ\EOT\SOH\STX\SOH\SOH\DC2\ETX4&B\n\
  \\f\n\
  \\ENQ\EOT\SOH\STX\SOH\ETX\DC2\ETX4EF\n\
  \\191\SOH\n\
  \\EOT\EOT\SOH\STX\STX\DC2\ETX9\STX\CAN\SUB\177\SOH This schema_url applies to the data in the \"resource\" field. It does not apply\n\
  \ to the data in the \"instrumentation_library_logs\" field which have their own\n\
  \ schema_url field.\n\
  \\n\
  \\f\n\
  \\ENQ\EOT\SOH\STX\STX\ENQ\DC2\ETX9\STX\b\n\
  \\f\n\
  \\ENQ\EOT\SOH\STX\STX\SOH\DC2\ETX9\t\DC3\n\
  \\f\n\
  \\ENQ\EOT\SOH\STX\STX\ETX\DC2\ETX9\SYN\ETB\n\
  \I\n\
  \\STX\EOT\STX\DC2\EOT=\NULH\SOH\SUB= A collection of Logs produced by an InstrumentationLibrary.\n\
  \\n\
  \\n\
  \\n\
  \\ETX\EOT\STX\SOH\DC2\ETX=\b\"\n\
  \\210\SOH\n\
  \\EOT\EOT\STX\STX\NUL\DC2\ETXA\STXS\SUB\196\SOH The instrumentation library information for the logs in this message.\n\
  \ Semantically when InstrumentationLibrary isn't set, it is equivalent with\n\
  \ an empty instrumentation library name (unknown).\n\
  \\n\
  \\f\n\
  \\ENQ\EOT\STX\STX\NUL\ACK\DC2\ETXA\STX6\n\
  \\f\n\
  \\ENQ\EOT\STX\STX\NUL\SOH\DC2\ETXA7N\n\
  \\f\n\
  \\ENQ\EOT\STX\STX\NUL\ETX\DC2\ETXAQR\n\
  \%\n\
  \\EOT\EOT\STX\STX\SOH\DC2\ETXD\STX\RS\SUB\CAN A list of log records.\n\
  \\n\
  \\f\n\
  \\ENQ\EOT\STX\STX\SOH\EOT\DC2\ETXD\STX\n\
  \\n\
  \\f\n\
  \\ENQ\EOT\STX\STX\SOH\ACK\DC2\ETXD\v\DC4\n\
  \\f\n\
  \\ENQ\EOT\STX\STX\SOH\SOH\DC2\ETXD\NAK\EM\n\
  \\f\n\
  \\ENQ\EOT\STX\STX\SOH\ETX\DC2\ETXD\FS\GS\n\
  \G\n\
  \\EOT\EOT\STX\STX\STX\DC2\ETXG\STX\CAN\SUB: This schema_url applies to all logs in the \"logs\" field.\n\
  \\n\
  \\f\n\
  \\ENQ\EOT\STX\STX\STX\ENQ\DC2\ETXG\STX\b\n\
  \\f\n\
  \\ENQ\EOT\STX\STX\STX\SOH\DC2\ETXG\t\DC3\n\
  \\f\n\
  \\ENQ\EOT\STX\STX\STX\ETX\DC2\ETXG\SYN\ETB\n\
  \;\n\
  \\STX\ENQ\NUL\DC2\EOTK\NULf\SOH\SUB/ Possible values for LogRecord.SeverityNumber.\n\
  \\n\
  \\n\
  \\n\
  \\ETX\ENQ\NUL\SOH\DC2\ETXK\ENQ\DC3\n\
  \N\n\
  \\EOT\ENQ\NUL\STX\NUL\DC2\ETXM\STX\"\SUBA UNSPECIFIED is the default SeverityNumber, it MUST NOT be used.\n\
  \\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\NUL\SOH\DC2\ETXM\STX\GS\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\NUL\STX\DC2\ETXM !\n\
  \\v\n\
  \\EOT\ENQ\NUL\STX\SOH\DC2\ETXN\STX\GS\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\SOH\SOH\DC2\ETXN\STX\ETB\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\SOH\STX\DC2\ETXN\ESC\FS\n\
  \\v\n\
  \\EOT\ENQ\NUL\STX\STX\DC2\ETXO\STX\GS\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\STX\SOH\DC2\ETXO\STX\CAN\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\STX\STX\DC2\ETXO\ESC\FS\n\
  \\v\n\
  \\EOT\ENQ\NUL\STX\ETX\DC2\ETXP\STX\GS\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\ETX\SOH\DC2\ETXP\STX\CAN\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\ETX\STX\DC2\ETXP\ESC\FS\n\
  \\v\n\
  \\EOT\ENQ\NUL\STX\EOT\DC2\ETXQ\STX\GS\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\EOT\SOH\DC2\ETXQ\STX\CAN\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\EOT\STX\DC2\ETXQ\ESC\FS\n\
  \\v\n\
  \\EOT\ENQ\NUL\STX\ENQ\DC2\ETXR\STX\GS\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\ENQ\SOH\DC2\ETXR\STX\ETB\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\ENQ\STX\DC2\ETXR\ESC\FS\n\
  \\v\n\
  \\EOT\ENQ\NUL\STX\ACK\DC2\ETXS\STX\GS\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\ACK\SOH\DC2\ETXS\STX\CAN\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\ACK\STX\DC2\ETXS\ESC\FS\n\
  \\v\n\
  \\EOT\ENQ\NUL\STX\a\DC2\ETXT\STX\GS\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\a\SOH\DC2\ETXT\STX\CAN\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\a\STX\DC2\ETXT\ESC\FS\n\
  \\v\n\
  \\EOT\ENQ\NUL\STX\b\DC2\ETXU\STX\GS\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\b\SOH\DC2\ETXU\STX\CAN\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\b\STX\DC2\ETXU\ESC\FS\n\
  \\v\n\
  \\EOT\ENQ\NUL\STX\t\DC2\ETXV\STX\GS\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\t\SOH\DC2\ETXV\STX\SYN\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\t\STX\DC2\ETXV\ESC\FS\n\
  \\v\n\
  \\EOT\ENQ\NUL\STX\n\
  \\DC2\ETXW\STX\RS\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\n\
  \\SOH\DC2\ETXW\STX\ETB\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\n\
  \\STX\DC2\ETXW\ESC\GS\n\
  \\v\n\
  \\EOT\ENQ\NUL\STX\v\DC2\ETXX\STX\RS\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\v\SOH\DC2\ETXX\STX\ETB\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\v\STX\DC2\ETXX\ESC\GS\n\
  \\v\n\
  \\EOT\ENQ\NUL\STX\f\DC2\ETXY\STX\RS\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\f\SOH\DC2\ETXY\STX\ETB\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\f\STX\DC2\ETXY\ESC\GS\n\
  \\v\n\
  \\EOT\ENQ\NUL\STX\r\DC2\ETXZ\STX\RS\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\r\SOH\DC2\ETXZ\STX\SYN\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\r\STX\DC2\ETXZ\ESC\GS\n\
  \\v\n\
  \\EOT\ENQ\NUL\STX\SO\DC2\ETX[\STX\RS\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\SO\SOH\DC2\ETX[\STX\ETB\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\SO\STX\DC2\ETX[\ESC\GS\n\
  \\v\n\
  \\EOT\ENQ\NUL\STX\SI\DC2\ETX\\\STX\RS\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\SI\SOH\DC2\ETX\\\STX\ETB\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\SI\STX\DC2\ETX\\\ESC\GS\n\
  \\v\n\
  \\EOT\ENQ\NUL\STX\DLE\DC2\ETX]\STX\RS\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\DLE\SOH\DC2\ETX]\STX\ETB\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\DLE\STX\DC2\ETX]\ESC\GS\n\
  \\v\n\
  \\EOT\ENQ\NUL\STX\DC1\DC2\ETX^\STX\RS\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\DC1\SOH\DC2\ETX^\STX\ETB\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\DC1\STX\DC2\ETX^\ESC\GS\n\
  \\v\n\
  \\EOT\ENQ\NUL\STX\DC2\DC2\ETX_\STX\RS\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\DC2\SOH\DC2\ETX_\STX\CAN\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\DC2\STX\DC2\ETX_\ESC\GS\n\
  \\v\n\
  \\EOT\ENQ\NUL\STX\DC3\DC2\ETX`\STX\RS\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\DC3\SOH\DC2\ETX`\STX\CAN\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\DC3\STX\DC2\ETX`\ESC\GS\n\
  \\v\n\
  \\EOT\ENQ\NUL\STX\DC4\DC2\ETXa\STX\RS\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\DC4\SOH\DC2\ETXa\STX\CAN\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\DC4\STX\DC2\ETXa\ESC\GS\n\
  \\v\n\
  \\EOT\ENQ\NUL\STX\NAK\DC2\ETXb\STX\RS\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\NAK\SOH\DC2\ETXb\STX\ETB\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\NAK\STX\DC2\ETXb\ESC\GS\n\
  \\v\n\
  \\EOT\ENQ\NUL\STX\SYN\DC2\ETXc\STX\RS\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\SYN\SOH\DC2\ETXc\STX\CAN\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\SYN\STX\DC2\ETXc\ESC\GS\n\
  \\v\n\
  \\EOT\ENQ\NUL\STX\ETB\DC2\ETXd\STX\RS\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\ETB\SOH\DC2\ETXd\STX\CAN\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\ETB\STX\DC2\ETXd\ESC\GS\n\
  \\v\n\
  \\EOT\ENQ\NUL\STX\CAN\DC2\ETXe\STX\RS\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\CAN\SOH\DC2\ETXe\STX\CAN\n\
  \\f\n\
  \\ENQ\ENQ\NUL\STX\CAN\STX\DC2\ETXe\ESC\GS\n\
  \.\n\
  \\STX\ENQ\SOH\DC2\EOTi\NULl\SOH\SUB\" Masks for LogRecord.flags field.\n\
  \\n\
  \\n\
  \\n\
  \\ETX\ENQ\SOH\SOH\DC2\ETXi\ENQ\DC3\n\
  \\v\n\
  \\EOT\ENQ\SOH\STX\NUL\DC2\ETXj\STX\"\n\
  \\f\n\
  \\ENQ\ENQ\SOH\STX\NUL\SOH\DC2\ETXj\STX\GS\n\
  \\f\n\
  \\ENQ\ENQ\SOH\STX\NUL\STX\DC2\ETXj !\n\
  \\v\n\
  \\EOT\ENQ\SOH\STX\SOH\DC2\ETXk\STX0\n\
  \\f\n\
  \\ENQ\ENQ\SOH\STX\SOH\SOH\DC2\ETXk\STX\"\n\
  \\f\n\
  \\ENQ\ENQ\SOH\STX\SOH\STX\DC2\ETXk%/\n\
  \\155\SOH\n\
  \\STX\EOT\ETX\DC2\ENQp\NUL\158\SOH\SOH\SUB\141\SOH A log record according to OpenTelemetry Log Data Model:\n\
  \ https://github.com/open-telemetry/oteps/blob/main/text/logs/0097-log-data-model.md\n\
  \\n\
  \\n\
  \\n\
  \\ETX\EOT\ETX\SOH\DC2\ETXp\b\DC1\n\
  \\198\SOH\n\
  \\EOT\EOT\ETX\STX\NUL\DC2\ETXt\STX\GS\SUB\184\SOH time_unix_nano is the time when the event occurred.\n\
  \ Value is UNIX Epoch time in nanoseconds since 00:00:00 UTC on 1 January 1970.\n\
  \ Value of 0 indicates unknown or missing timestamp.\n\
  \\n\
  \\f\n\
  \\ENQ\EOT\ETX\STX\NUL\ENQ\DC2\ETXt\STX\t\n\
  \\f\n\
  \\ENQ\EOT\ETX\STX\NUL\SOH\DC2\ETXt\n\
  \\CAN\n\
  \\f\n\
  \\ENQ\EOT\ETX\STX\NUL\ETX\DC2\ETXt\ESC\FS\n\
  \n\n\
  \\EOT\EOT\ETX\STX\SOH\DC2\ETXx\STX%\SUBa Numerical value of the severity, normalized to values described in Log Data Model.\n\
  \ [Optional].\n\
  \\n\
  \\f\n\
  \\ENQ\EOT\ETX\STX\SOH\ACK\DC2\ETXx\STX\DLE\n\
  \\f\n\
  \\ENQ\EOT\ETX\STX\SOH\SOH\DC2\ETXx\DC1 \n\
  \\f\n\
  \\ENQ\EOT\ETX\STX\SOH\ETX\DC2\ETXx#$\n\
  \\137\SOH\n\
  \\EOT\EOT\ETX\STX\STX\DC2\ETX|\STX\ESC\SUB| The severity text (also known as log level). The original string representation as\n\
  \ it is known at the source. [Optional].\n\
  \\n\
  \\f\n\
  \\ENQ\EOT\ETX\STX\STX\ENQ\DC2\ETX|\STX\b\n\
  \\f\n\
  \\ENQ\EOT\ETX\STX\STX\SOH\DC2\ETX|\t\SYN\n\
  \\f\n\
  \\ENQ\EOT\ETX\STX\STX\ETX\DC2\ETX|\EM\SUB\n\
  \\232\SOH\n\
  \\EOT\EOT\ETX\STX\ETX\DC2\EOT\129\SOH\STX\DC2\SUB\217\SOH Short event identifier that does not contain varying parts. Name describes\n\
  \ what happened (e.g. \"ProcessStarted\"). Recommended to be no longer than 50\n\
  \ characters. Not guaranteed to be unique in any way. [Optional].\n\
  \\n\
  \\r\n\
  \\ENQ\EOT\ETX\STX\ETX\ENQ\DC2\EOT\129\SOH\STX\b\n\
  \\r\n\
  \\ENQ\EOT\ETX\STX\ETX\SOH\DC2\EOT\129\SOH\t\r\n\
  \\r\n\
  \\ENQ\EOT\ETX\STX\ETX\ETX\DC2\EOT\129\SOH\DLE\DC1\n\
  \\135\STX\n\
  \\EOT\EOT\ETX\STX\EOT\DC2\EOT\134\SOH\STX2\SUB\248\SOH A value containing the body of the log record. Can be for example a human-readable\n\
  \ string message (including multi-line) describing the event in a free form or it can\n\
  \ be a structured data composed of arrays and maps of other values. [Optional].\n\
  \\n\
  \\r\n\
  \\ENQ\EOT\ETX\STX\EOT\ACK\DC2\EOT\134\SOH\STX(\n\
  \\r\n\
  \\ENQ\EOT\ETX\STX\EOT\SOH\DC2\EOT\134\SOH)-\n\
  \\r\n\
  \\ENQ\EOT\ETX\STX\EOT\ETX\DC2\EOT\134\SOH01\n\
  \^\n\
  \\EOT\EOT\ETX\STX\ENQ\DC2\EOT\137\SOH\STXA\SUBP Additional attributes that describe the specific event occurrence. [Optional].\n\
  \\n\
  \\r\n\
  \\ENQ\EOT\ETX\STX\ENQ\EOT\DC2\EOT\137\SOH\STX\n\
  \\n\
  \\r\n\
  \\ENQ\EOT\ETX\STX\ENQ\ACK\DC2\EOT\137\SOH\v1\n\
  \\r\n\
  \\ENQ\EOT\ETX\STX\ENQ\SOH\DC2\EOT\137\SOH2<\n\
  \\r\n\
  \\ENQ\EOT\ETX\STX\ENQ\ETX\DC2\EOT\137\SOH?@\n\
  \\f\n\
  \\EOT\EOT\ETX\STX\ACK\DC2\EOT\138\SOH\STX&\n\
  \\r\n\
  \\ENQ\EOT\ETX\STX\ACK\ENQ\DC2\EOT\138\SOH\STX\b\n\
  \\r\n\
  \\ENQ\EOT\ETX\STX\ACK\SOH\DC2\EOT\138\SOH\t!\n\
  \\r\n\
  \\ENQ\EOT\ETX\STX\ACK\ETX\DC2\EOT\138\SOH$%\n\
  \\238\STX\n\
  \\EOT\EOT\ETX\STX\a\DC2\EOT\145\SOH\STX\DC4\SUB\223\STX Flags, a bit field. 8 least significant bits are the trace flags as\n\
  \ defined in W3C Trace Context specification. 24 most significant bits are reserved\n\
  \ and must be set to 0. Readers must not assume that 24 most significant bits\n\
  \ will be zero and must correctly mask the bits when reading 8-bit trace flag (use\n\
  \ flags & TRACE_FLAGS_MASK). [Optional].\n\
  \\n\
  \\r\n\
  \\ENQ\EOT\ETX\STX\a\ENQ\DC2\EOT\145\SOH\STX\t\n\
  \\r\n\
  \\ENQ\EOT\ETX\STX\a\SOH\DC2\EOT\145\SOH\n\
  \\SI\n\
  \\r\n\
  \\ENQ\EOT\ETX\STX\a\ETX\DC2\EOT\145\SOH\DC2\DC3\n\
  \\151\STX\n\
  \\EOT\EOT\ETX\STX\b\DC2\EOT\151\SOH\STX\NAK\SUB\136\STX A unique identifier for a trace. All logs from the same trace share\n\
  \ the same `trace_id`. The ID is a 16-byte array. An ID with all zeroes\n\
  \ is considered invalid. Can be set for logs that are part of request processing\n\
  \ and have an assigned trace id. [Optional].\n\
  \\n\
  \\r\n\
  \\ENQ\EOT\ETX\STX\b\ENQ\DC2\EOT\151\SOH\STX\a\n\
  \\r\n\
  \\ENQ\EOT\ETX\STX\b\SOH\DC2\EOT\151\SOH\b\DLE\n\
  \\r\n\
  \\ENQ\EOT\ETX\STX\b\ETX\DC2\EOT\151\SOH\DC3\DC4\n\
  \\179\STX\n\
  \\EOT\EOT\ETX\STX\t\DC2\EOT\157\SOH\STX\NAK\SUB\164\STX A unique identifier for a span within a trace, assigned when the span\n\
  \ is created. The ID is an 8-byte array. An ID with all zeroes is considered\n\
  \ invalid. Can be set for logs that are part of a particular processing span.\n\
  \ If span_id is present trace_id SHOULD be also present. [Optional].\n\
  \\n\
  \\r\n\
  \\ENQ\EOT\ETX\STX\t\ENQ\DC2\EOT\157\SOH\STX\a\n\
  \\r\n\
  \\ENQ\EOT\ETX\STX\t\SOH\DC2\EOT\157\SOH\b\SI\n\
  \\r\n\
  \\ENQ\EOT\ETX\STX\t\ETX\DC2\EOT\157\SOH\DC2\DC4b\ACKproto3"
