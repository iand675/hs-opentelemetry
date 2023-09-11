{- This file was auto-generated from opentelemetry/proto/common/v1/common.proto by the proto-lens-protoc program. -}
{-# LANGUAGE BangPatterns #-}
{- This file was auto-generated from opentelemetry/proto/common/v1/common.proto by the proto-lens-protoc program. -}
{-# LANGUAGE DataKinds #-}
{- This file was auto-generated from opentelemetry/proto/common/v1/common.proto by the proto-lens-protoc program. -}
{-# LANGUAGE DerivingStrategies #-}
{- This file was auto-generated from opentelemetry/proto/common/v1/common.proto by the proto-lens-protoc program. -}
{-# LANGUAGE FlexibleContexts #-}
{- This file was auto-generated from opentelemetry/proto/common/v1/common.proto by the proto-lens-protoc program. -}
{-# LANGUAGE FlexibleInstances #-}
{- This file was auto-generated from opentelemetry/proto/common/v1/common.proto by the proto-lens-protoc program. -}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{- This file was auto-generated from opentelemetry/proto/common/v1/common.proto by the proto-lens-protoc program. -}
{-# LANGUAGE MagicHash #-}
{- This file was auto-generated from opentelemetry/proto/common/v1/common.proto by the proto-lens-protoc program. -}
{-# LANGUAGE MultiParamTypeClasses #-}
{- This file was auto-generated from opentelemetry/proto/common/v1/common.proto by the proto-lens-protoc program. -}
{-# LANGUAGE OverloadedStrings #-}
{- This file was auto-generated from opentelemetry/proto/common/v1/common.proto by the proto-lens-protoc program. -}
{-# LANGUAGE PatternSynonyms #-}
{- This file was auto-generated from opentelemetry/proto/common/v1/common.proto by the proto-lens-protoc program. -}
{-# LANGUAGE ScopedTypeVariables #-}
{- This file was auto-generated from opentelemetry/proto/common/v1/common.proto by the proto-lens-protoc program. -}
{-# LANGUAGE TypeApplications #-}
{- This file was auto-generated from opentelemetry/proto/common/v1/common.proto by the proto-lens-protoc program. -}
{-# LANGUAGE TypeFamilies #-}
{- This file was auto-generated from opentelemetry/proto/common/v1/common.proto by the proto-lens-protoc program. -}
{-# LANGUAGE UndecidableInstances #-}
{- This file was auto-generated from opentelemetry/proto/common/v1/common.proto by the proto-lens-protoc program. -}
{-# LANGUAGE NoImplicitPrelude #-}
{-# OPTIONS_GHC -Wno-dodgy-exports #-}
{-# OPTIONS_GHC -Wno-duplicate-exports #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Proto.Opentelemetry.Proto.Common.V1.Common (
  AnyValue (),
  AnyValue'Value (..),
  _AnyValue'StringValue,
  _AnyValue'BoolValue,
  _AnyValue'IntValue,
  _AnyValue'DoubleValue,
  _AnyValue'ArrayValue,
  _AnyValue'KvlistValue,
  _AnyValue'BytesValue,
  ArrayValue (),
  InstrumentationLibrary (),
  KeyValue (),
  KeyValueList (),
  StringKeyValue (),
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


{- | Fields :

         * 'Proto.Opentelemetry.Proto.Common.V1.Common_Fields.maybe'value' @:: Lens' AnyValue (Prelude.Maybe AnyValue'Value)@
         * 'Proto.Opentelemetry.Proto.Common.V1.Common_Fields.maybe'stringValue' @:: Lens' AnyValue (Prelude.Maybe Data.Text.Text)@
         * 'Proto.Opentelemetry.Proto.Common.V1.Common_Fields.stringValue' @:: Lens' AnyValue Data.Text.Text@
         * 'Proto.Opentelemetry.Proto.Common.V1.Common_Fields.maybe'boolValue' @:: Lens' AnyValue (Prelude.Maybe Prelude.Bool)@
         * 'Proto.Opentelemetry.Proto.Common.V1.Common_Fields.boolValue' @:: Lens' AnyValue Prelude.Bool@
         * 'Proto.Opentelemetry.Proto.Common.V1.Common_Fields.maybe'intValue' @:: Lens' AnyValue (Prelude.Maybe Data.Int.Int64)@
         * 'Proto.Opentelemetry.Proto.Common.V1.Common_Fields.intValue' @:: Lens' AnyValue Data.Int.Int64@
         * 'Proto.Opentelemetry.Proto.Common.V1.Common_Fields.maybe'doubleValue' @:: Lens' AnyValue (Prelude.Maybe Prelude.Double)@
         * 'Proto.Opentelemetry.Proto.Common.V1.Common_Fields.doubleValue' @:: Lens' AnyValue Prelude.Double@
         * 'Proto.Opentelemetry.Proto.Common.V1.Common_Fields.maybe'arrayValue' @:: Lens' AnyValue (Prelude.Maybe ArrayValue)@
         * 'Proto.Opentelemetry.Proto.Common.V1.Common_Fields.arrayValue' @:: Lens' AnyValue ArrayValue@
         * 'Proto.Opentelemetry.Proto.Common.V1.Common_Fields.maybe'kvlistValue' @:: Lens' AnyValue (Prelude.Maybe KeyValueList)@
         * 'Proto.Opentelemetry.Proto.Common.V1.Common_Fields.kvlistValue' @:: Lens' AnyValue KeyValueList@
         * 'Proto.Opentelemetry.Proto.Common.V1.Common_Fields.maybe'bytesValue' @:: Lens' AnyValue (Prelude.Maybe Data.ByteString.ByteString)@
         * 'Proto.Opentelemetry.Proto.Common.V1.Common_Fields.bytesValue' @:: Lens' AnyValue Data.ByteString.ByteString@
-}
data AnyValue = AnyValue'_constructor
  { _AnyValue'value :: !(Prelude.Maybe AnyValue'Value)
  , _AnyValue'_unknownFields :: !Data.ProtoLens.FieldSet
  }
  deriving stock (Prelude.Eq, Prelude.Ord)


instance Prelude.Show AnyValue where
  showsPrec _ __x __s =
    Prelude.showChar
      '{'
      ( Prelude.showString
          (Data.ProtoLens.showMessageShort __x)
          (Prelude.showChar '}' __s)
      )


data AnyValue'Value
  = AnyValue'StringValue !Data.Text.Text
  | AnyValue'BoolValue !Prelude.Bool
  | AnyValue'IntValue !Data.Int.Int64
  | AnyValue'DoubleValue !Prelude.Double
  | AnyValue'ArrayValue !ArrayValue
  | AnyValue'KvlistValue !KeyValueList
  | AnyValue'BytesValue !Data.ByteString.ByteString
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)


instance Data.ProtoLens.Field.HasField AnyValue "maybe'value" (Prelude.Maybe AnyValue'Value) where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _AnyValue'value
          (\x__ y__ -> x__ {_AnyValue'value = y__})
      )
      Prelude.id


instance Data.ProtoLens.Field.HasField AnyValue "maybe'stringValue" (Prelude.Maybe Data.Text.Text) where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _AnyValue'value
          (\x__ y__ -> x__ {_AnyValue'value = y__})
      )
      ( Lens.Family2.Unchecked.lens
          ( \x__ ->
              case x__ of
                (Prelude.Just (AnyValue'StringValue x__val)) -> Prelude.Just x__val
                _otherwise -> Prelude.Nothing
          )
          (\_ y__ -> Prelude.fmap AnyValue'StringValue y__)
      )


instance Data.ProtoLens.Field.HasField AnyValue "stringValue" Data.Text.Text where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _AnyValue'value
          (\x__ y__ -> x__ {_AnyValue'value = y__})
      )
      ( (Prelude..)
          ( Lens.Family2.Unchecked.lens
              ( \x__ ->
                  case x__ of
                    (Prelude.Just (AnyValue'StringValue x__val)) -> Prelude.Just x__val
                    _otherwise -> Prelude.Nothing
              )
              (\_ y__ -> Prelude.fmap AnyValue'StringValue y__)
          )
          (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault)
      )


instance Data.ProtoLens.Field.HasField AnyValue "maybe'boolValue" (Prelude.Maybe Prelude.Bool) where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _AnyValue'value
          (\x__ y__ -> x__ {_AnyValue'value = y__})
      )
      ( Lens.Family2.Unchecked.lens
          ( \x__ ->
              case x__ of
                (Prelude.Just (AnyValue'BoolValue x__val)) -> Prelude.Just x__val
                _otherwise -> Prelude.Nothing
          )
          (\_ y__ -> Prelude.fmap AnyValue'BoolValue y__)
      )


instance Data.ProtoLens.Field.HasField AnyValue "boolValue" Prelude.Bool where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _AnyValue'value
          (\x__ y__ -> x__ {_AnyValue'value = y__})
      )
      ( (Prelude..)
          ( Lens.Family2.Unchecked.lens
              ( \x__ ->
                  case x__ of
                    (Prelude.Just (AnyValue'BoolValue x__val)) -> Prelude.Just x__val
                    _otherwise -> Prelude.Nothing
              )
              (\_ y__ -> Prelude.fmap AnyValue'BoolValue y__)
          )
          (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault)
      )


instance Data.ProtoLens.Field.HasField AnyValue "maybe'intValue" (Prelude.Maybe Data.Int.Int64) where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _AnyValue'value
          (\x__ y__ -> x__ {_AnyValue'value = y__})
      )
      ( Lens.Family2.Unchecked.lens
          ( \x__ ->
              case x__ of
                (Prelude.Just (AnyValue'IntValue x__val)) -> Prelude.Just x__val
                _otherwise -> Prelude.Nothing
          )
          (\_ y__ -> Prelude.fmap AnyValue'IntValue y__)
      )


instance Data.ProtoLens.Field.HasField AnyValue "intValue" Data.Int.Int64 where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _AnyValue'value
          (\x__ y__ -> x__ {_AnyValue'value = y__})
      )
      ( (Prelude..)
          ( Lens.Family2.Unchecked.lens
              ( \x__ ->
                  case x__ of
                    (Prelude.Just (AnyValue'IntValue x__val)) -> Prelude.Just x__val
                    _otherwise -> Prelude.Nothing
              )
              (\_ y__ -> Prelude.fmap AnyValue'IntValue y__)
          )
          (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault)
      )


instance Data.ProtoLens.Field.HasField AnyValue "maybe'doubleValue" (Prelude.Maybe Prelude.Double) where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _AnyValue'value
          (\x__ y__ -> x__ {_AnyValue'value = y__})
      )
      ( Lens.Family2.Unchecked.lens
          ( \x__ ->
              case x__ of
                (Prelude.Just (AnyValue'DoubleValue x__val)) -> Prelude.Just x__val
                _otherwise -> Prelude.Nothing
          )
          (\_ y__ -> Prelude.fmap AnyValue'DoubleValue y__)
      )


instance Data.ProtoLens.Field.HasField AnyValue "doubleValue" Prelude.Double where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _AnyValue'value
          (\x__ y__ -> x__ {_AnyValue'value = y__})
      )
      ( (Prelude..)
          ( Lens.Family2.Unchecked.lens
              ( \x__ ->
                  case x__ of
                    (Prelude.Just (AnyValue'DoubleValue x__val)) -> Prelude.Just x__val
                    _otherwise -> Prelude.Nothing
              )
              (\_ y__ -> Prelude.fmap AnyValue'DoubleValue y__)
          )
          (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault)
      )


instance Data.ProtoLens.Field.HasField AnyValue "maybe'arrayValue" (Prelude.Maybe ArrayValue) where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _AnyValue'value
          (\x__ y__ -> x__ {_AnyValue'value = y__})
      )
      ( Lens.Family2.Unchecked.lens
          ( \x__ ->
              case x__ of
                (Prelude.Just (AnyValue'ArrayValue x__val)) -> Prelude.Just x__val
                _otherwise -> Prelude.Nothing
          )
          (\_ y__ -> Prelude.fmap AnyValue'ArrayValue y__)
      )


instance Data.ProtoLens.Field.HasField AnyValue "arrayValue" ArrayValue where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _AnyValue'value
          (\x__ y__ -> x__ {_AnyValue'value = y__})
      )
      ( (Prelude..)
          ( Lens.Family2.Unchecked.lens
              ( \x__ ->
                  case x__ of
                    (Prelude.Just (AnyValue'ArrayValue x__val)) -> Prelude.Just x__val
                    _otherwise -> Prelude.Nothing
              )
              (\_ y__ -> Prelude.fmap AnyValue'ArrayValue y__)
          )
          (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
      )


instance Data.ProtoLens.Field.HasField AnyValue "maybe'kvlistValue" (Prelude.Maybe KeyValueList) where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _AnyValue'value
          (\x__ y__ -> x__ {_AnyValue'value = y__})
      )
      ( Lens.Family2.Unchecked.lens
          ( \x__ ->
              case x__ of
                (Prelude.Just (AnyValue'KvlistValue x__val)) -> Prelude.Just x__val
                _otherwise -> Prelude.Nothing
          )
          (\_ y__ -> Prelude.fmap AnyValue'KvlistValue y__)
      )


instance Data.ProtoLens.Field.HasField AnyValue "kvlistValue" KeyValueList where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _AnyValue'value
          (\x__ y__ -> x__ {_AnyValue'value = y__})
      )
      ( (Prelude..)
          ( Lens.Family2.Unchecked.lens
              ( \x__ ->
                  case x__ of
                    (Prelude.Just (AnyValue'KvlistValue x__val)) -> Prelude.Just x__val
                    _otherwise -> Prelude.Nothing
              )
              (\_ y__ -> Prelude.fmap AnyValue'KvlistValue y__)
          )
          (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
      )


instance Data.ProtoLens.Field.HasField AnyValue "maybe'bytesValue" (Prelude.Maybe Data.ByteString.ByteString) where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _AnyValue'value
          (\x__ y__ -> x__ {_AnyValue'value = y__})
      )
      ( Lens.Family2.Unchecked.lens
          ( \x__ ->
              case x__ of
                (Prelude.Just (AnyValue'BytesValue x__val)) -> Prelude.Just x__val
                _otherwise -> Prelude.Nothing
          )
          (\_ y__ -> Prelude.fmap AnyValue'BytesValue y__)
      )


instance Data.ProtoLens.Field.HasField AnyValue "bytesValue" Data.ByteString.ByteString where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _AnyValue'value
          (\x__ y__ -> x__ {_AnyValue'value = y__})
      )
      ( (Prelude..)
          ( Lens.Family2.Unchecked.lens
              ( \x__ ->
                  case x__ of
                    (Prelude.Just (AnyValue'BytesValue x__val)) -> Prelude.Just x__val
                    _otherwise -> Prelude.Nothing
              )
              (\_ y__ -> Prelude.fmap AnyValue'BytesValue y__)
          )
          (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault)
      )


instance Data.ProtoLens.Message AnyValue where
  messageName _ =
    Data.Text.pack "opentelemetry.proto.common.v1.AnyValue"
  packedMessageDescriptor _ =
    "\n\
    \\bAnyValue\DC2#\n\
    \\fstring_value\CAN\SOH \SOH(\tH\NULR\vstringValue\DC2\US\n\
    \\n\
    \bool_value\CAN\STX \SOH(\bH\NULR\tboolValue\DC2\GS\n\
    \\tint_value\CAN\ETX \SOH(\ETXH\NULR\bintValue\DC2#\n\
    \\fdouble_value\CAN\EOT \SOH(\SOHH\NULR\vdoubleValue\DC2L\n\
    \\varray_value\CAN\ENQ \SOH(\v2).opentelemetry.proto.common.v1.ArrayValueH\NULR\n\
    \arrayValue\DC2P\n\
    \\fkvlist_value\CAN\ACK \SOH(\v2+.opentelemetry.proto.common.v1.KeyValueListH\NULR\vkvlistValue\DC2!\n\
    \\vbytes_value\CAN\a \SOH(\fH\NULR\n\
    \bytesValueB\a\n\
    \\ENQvalue"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag =
    let stringValue__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "string_value"
            ( Data.ProtoLens.ScalarField Data.ProtoLens.StringField
                :: Data.ProtoLens.FieldTypeDescriptor Data.Text.Text
            )
            ( Data.ProtoLens.OptionalField
                (Data.ProtoLens.Field.field @"maybe'stringValue")
            )
            :: Data.ProtoLens.FieldDescriptor AnyValue
        boolValue__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "bool_value"
            ( Data.ProtoLens.ScalarField Data.ProtoLens.BoolField
                :: Data.ProtoLens.FieldTypeDescriptor Prelude.Bool
            )
            ( Data.ProtoLens.OptionalField
                (Data.ProtoLens.Field.field @"maybe'boolValue")
            )
            :: Data.ProtoLens.FieldDescriptor AnyValue
        intValue__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "int_value"
            ( Data.ProtoLens.ScalarField Data.ProtoLens.Int64Field
                :: Data.ProtoLens.FieldTypeDescriptor Data.Int.Int64
            )
            ( Data.ProtoLens.OptionalField
                (Data.ProtoLens.Field.field @"maybe'intValue")
            )
            :: Data.ProtoLens.FieldDescriptor AnyValue
        doubleValue__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "double_value"
            ( Data.ProtoLens.ScalarField Data.ProtoLens.DoubleField
                :: Data.ProtoLens.FieldTypeDescriptor Prelude.Double
            )
            ( Data.ProtoLens.OptionalField
                (Data.ProtoLens.Field.field @"maybe'doubleValue")
            )
            :: Data.ProtoLens.FieldDescriptor AnyValue
        arrayValue__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "array_value"
            ( Data.ProtoLens.MessageField Data.ProtoLens.MessageType
                :: Data.ProtoLens.FieldTypeDescriptor ArrayValue
            )
            ( Data.ProtoLens.OptionalField
                (Data.ProtoLens.Field.field @"maybe'arrayValue")
            )
            :: Data.ProtoLens.FieldDescriptor AnyValue
        kvlistValue__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "kvlist_value"
            ( Data.ProtoLens.MessageField Data.ProtoLens.MessageType
                :: Data.ProtoLens.FieldTypeDescriptor KeyValueList
            )
            ( Data.ProtoLens.OptionalField
                (Data.ProtoLens.Field.field @"maybe'kvlistValue")
            )
            :: Data.ProtoLens.FieldDescriptor AnyValue
        bytesValue__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "bytes_value"
            ( Data.ProtoLens.ScalarField Data.ProtoLens.BytesField
                :: Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString
            )
            ( Data.ProtoLens.OptionalField
                (Data.ProtoLens.Field.field @"maybe'bytesValue")
            )
            :: Data.ProtoLens.FieldDescriptor AnyValue
     in Data.Map.fromList
          [ (Data.ProtoLens.Tag 1, stringValue__field_descriptor)
          , (Data.ProtoLens.Tag 2, boolValue__field_descriptor)
          , (Data.ProtoLens.Tag 3, intValue__field_descriptor)
          , (Data.ProtoLens.Tag 4, doubleValue__field_descriptor)
          , (Data.ProtoLens.Tag 5, arrayValue__field_descriptor)
          , (Data.ProtoLens.Tag 6, kvlistValue__field_descriptor)
          , (Data.ProtoLens.Tag 7, bytesValue__field_descriptor)
          ]
  unknownFields =
    Lens.Family2.Unchecked.lens
      _AnyValue'_unknownFields
      (\x__ y__ -> x__ {_AnyValue'_unknownFields = y__})
  defMessage =
    AnyValue'_constructor
      { _AnyValue'value = Prelude.Nothing
      , _AnyValue'_unknownFields = []
      }
  parseMessage =
    let loop :: AnyValue -> Data.ProtoLens.Encoding.Bytes.Parser AnyValue
        loop x =
          do
            end <- Data.ProtoLens.Encoding.Bytes.atEnd
            if end
              then do
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
                      x
                  )
              else do
                tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                case tag of
                  10 ->
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
                          "string_value"
                      loop
                        (Lens.Family2.set (Data.ProtoLens.Field.field @"stringValue") y x)
                  16 ->
                    do
                      y <-
                        (Data.ProtoLens.Encoding.Bytes.<?>)
                          ( Prelude.fmap
                              ((Prelude./=) 0)
                              Data.ProtoLens.Encoding.Bytes.getVarInt
                          )
                          "bool_value"
                      loop
                        (Lens.Family2.set (Data.ProtoLens.Field.field @"boolValue") y x)
                  24 ->
                    do
                      y <-
                        (Data.ProtoLens.Encoding.Bytes.<?>)
                          ( Prelude.fmap
                              Prelude.fromIntegral
                              Data.ProtoLens.Encoding.Bytes.getVarInt
                          )
                          "int_value"
                      loop
                        (Lens.Family2.set (Data.ProtoLens.Field.field @"intValue") y x)
                  33 ->
                    do
                      y <-
                        (Data.ProtoLens.Encoding.Bytes.<?>)
                          ( Prelude.fmap
                              Data.ProtoLens.Encoding.Bytes.wordToDouble
                              Data.ProtoLens.Encoding.Bytes.getFixed64
                          )
                          "double_value"
                      loop
                        (Lens.Family2.set (Data.ProtoLens.Field.field @"doubleValue") y x)
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
                          "array_value"
                      loop
                        (Lens.Family2.set (Data.ProtoLens.Field.field @"arrayValue") y x)
                  50 ->
                    do
                      y <-
                        (Data.ProtoLens.Encoding.Bytes.<?>)
                          ( do
                              len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                              Data.ProtoLens.Encoding.Bytes.isolate
                                (Prelude.fromIntegral len)
                                Data.ProtoLens.parseMessage
                          )
                          "kvlist_value"
                      loop
                        (Lens.Family2.set (Data.ProtoLens.Field.field @"kvlistValue") y x)
                  58 ->
                    do
                      y <-
                        (Data.ProtoLens.Encoding.Bytes.<?>)
                          ( do
                              len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                              Data.ProtoLens.Encoding.Bytes.getBytes
                                (Prelude.fromIntegral len)
                          )
                          "bytes_value"
                      loop
                        (Lens.Family2.set (Data.ProtoLens.Field.field @"bytesValue") y x)
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
     in (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage)
          "AnyValue"
  buildMessage =
    \_x ->
      (Data.Monoid.<>)
        ( case Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'value") _x of
            Prelude.Nothing -> Data.Monoid.mempty
            (Prelude.Just (AnyValue'StringValue v)) ->
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
                    Data.Text.Encoding.encodeUtf8
                    v
                )
            (Prelude.Just (AnyValue'BoolValue v)) ->
              (Data.Monoid.<>)
                (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                ( (Prelude..)
                    Data.ProtoLens.Encoding.Bytes.putVarInt
                    (\b -> if b then 1 else 0)
                    v
                )
            (Prelude.Just (AnyValue'IntValue v)) ->
              (Data.Monoid.<>)
                (Data.ProtoLens.Encoding.Bytes.putVarInt 24)
                ( (Prelude..)
                    Data.ProtoLens.Encoding.Bytes.putVarInt
                    Prelude.fromIntegral
                    v
                )
            (Prelude.Just (AnyValue'DoubleValue v)) ->
              (Data.Monoid.<>)
                (Data.ProtoLens.Encoding.Bytes.putVarInt 33)
                ( (Prelude..)
                    Data.ProtoLens.Encoding.Bytes.putFixed64
                    Data.ProtoLens.Encoding.Bytes.doubleToWord
                    v
                )
            (Prelude.Just (AnyValue'ArrayValue v)) ->
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
                    v
                )
            (Prelude.Just (AnyValue'KvlistValue v)) ->
              (Data.Monoid.<>)
                (Data.ProtoLens.Encoding.Bytes.putVarInt 50)
                ( (Prelude..)
                    ( \bs ->
                        (Data.Monoid.<>)
                          ( Data.ProtoLens.Encoding.Bytes.putVarInt
                              (Prelude.fromIntegral (Data.ByteString.length bs))
                          )
                          (Data.ProtoLens.Encoding.Bytes.putBytes bs)
                    )
                    Data.ProtoLens.encodeMessage
                    v
                )
            (Prelude.Just (AnyValue'BytesValue v)) ->
              (Data.Monoid.<>)
                (Data.ProtoLens.Encoding.Bytes.putVarInt 58)
                ( ( \bs ->
                      (Data.Monoid.<>)
                        ( Data.ProtoLens.Encoding.Bytes.putVarInt
                            (Prelude.fromIntegral (Data.ByteString.length bs))
                        )
                        (Data.ProtoLens.Encoding.Bytes.putBytes bs)
                  )
                    v
                )
        )
        ( Data.ProtoLens.Encoding.Wire.buildFieldSet
            (Lens.Family2.view Data.ProtoLens.unknownFields _x)
        )


instance Control.DeepSeq.NFData AnyValue where
  rnf =
    \x__ ->
      Control.DeepSeq.deepseq
        (_AnyValue'_unknownFields x__)
        (Control.DeepSeq.deepseq (_AnyValue'value x__) ())


instance Control.DeepSeq.NFData AnyValue'Value where
  rnf (AnyValue'StringValue x__) = Control.DeepSeq.rnf x__
  rnf (AnyValue'BoolValue x__) = Control.DeepSeq.rnf x__
  rnf (AnyValue'IntValue x__) = Control.DeepSeq.rnf x__
  rnf (AnyValue'DoubleValue x__) = Control.DeepSeq.rnf x__
  rnf (AnyValue'ArrayValue x__) = Control.DeepSeq.rnf x__
  rnf (AnyValue'KvlistValue x__) = Control.DeepSeq.rnf x__
  rnf (AnyValue'BytesValue x__) = Control.DeepSeq.rnf x__


_AnyValue'StringValue
  :: Data.ProtoLens.Prism.Prism' AnyValue'Value Data.Text.Text
_AnyValue'StringValue =
  Data.ProtoLens.Prism.prism'
    AnyValue'StringValue
    ( \p__ ->
        case p__ of
          (AnyValue'StringValue p__val) -> Prelude.Just p__val
          _otherwise -> Prelude.Nothing
    )


_AnyValue'BoolValue
  :: Data.ProtoLens.Prism.Prism' AnyValue'Value Prelude.Bool
_AnyValue'BoolValue =
  Data.ProtoLens.Prism.prism'
    AnyValue'BoolValue
    ( \p__ ->
        case p__ of
          (AnyValue'BoolValue p__val) -> Prelude.Just p__val
          _otherwise -> Prelude.Nothing
    )


_AnyValue'IntValue
  :: Data.ProtoLens.Prism.Prism' AnyValue'Value Data.Int.Int64
_AnyValue'IntValue =
  Data.ProtoLens.Prism.prism'
    AnyValue'IntValue
    ( \p__ ->
        case p__ of
          (AnyValue'IntValue p__val) -> Prelude.Just p__val
          _otherwise -> Prelude.Nothing
    )


_AnyValue'DoubleValue
  :: Data.ProtoLens.Prism.Prism' AnyValue'Value Prelude.Double
_AnyValue'DoubleValue =
  Data.ProtoLens.Prism.prism'
    AnyValue'DoubleValue
    ( \p__ ->
        case p__ of
          (AnyValue'DoubleValue p__val) -> Prelude.Just p__val
          _otherwise -> Prelude.Nothing
    )


_AnyValue'ArrayValue
  :: Data.ProtoLens.Prism.Prism' AnyValue'Value ArrayValue
_AnyValue'ArrayValue =
  Data.ProtoLens.Prism.prism'
    AnyValue'ArrayValue
    ( \p__ ->
        case p__ of
          (AnyValue'ArrayValue p__val) -> Prelude.Just p__val
          _otherwise -> Prelude.Nothing
    )


_AnyValue'KvlistValue
  :: Data.ProtoLens.Prism.Prism' AnyValue'Value KeyValueList
_AnyValue'KvlistValue =
  Data.ProtoLens.Prism.prism'
    AnyValue'KvlistValue
    ( \p__ ->
        case p__ of
          (AnyValue'KvlistValue p__val) -> Prelude.Just p__val
          _otherwise -> Prelude.Nothing
    )


_AnyValue'BytesValue
  :: Data.ProtoLens.Prism.Prism' AnyValue'Value Data.ByteString.ByteString
_AnyValue'BytesValue =
  Data.ProtoLens.Prism.prism'
    AnyValue'BytesValue
    ( \p__ ->
        case p__ of
          (AnyValue'BytesValue p__val) -> Prelude.Just p__val
          _otherwise -> Prelude.Nothing
    )


{- | Fields :

         * 'Proto.Opentelemetry.Proto.Common.V1.Common_Fields.values' @:: Lens' ArrayValue [AnyValue]@
         * 'Proto.Opentelemetry.Proto.Common.V1.Common_Fields.vec'values' @:: Lens' ArrayValue (Data.Vector.Vector AnyValue)@
-}
data ArrayValue = ArrayValue'_constructor
  { _ArrayValue'values :: !(Data.Vector.Vector AnyValue)
  , _ArrayValue'_unknownFields :: !Data.ProtoLens.FieldSet
  }
  deriving stock (Prelude.Eq, Prelude.Ord)


instance Prelude.Show ArrayValue where
  showsPrec _ __x __s =
    Prelude.showChar
      '{'
      ( Prelude.showString
          (Data.ProtoLens.showMessageShort __x)
          (Prelude.showChar '}' __s)
      )


instance Data.ProtoLens.Field.HasField ArrayValue "values" [AnyValue] where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _ArrayValue'values
          (\x__ y__ -> x__ {_ArrayValue'values = y__})
      )
      ( Lens.Family2.Unchecked.lens
          Data.Vector.Generic.toList
          (\_ y__ -> Data.Vector.Generic.fromList y__)
      )


instance Data.ProtoLens.Field.HasField ArrayValue "vec'values" (Data.Vector.Vector AnyValue) where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _ArrayValue'values
          (\x__ y__ -> x__ {_ArrayValue'values = y__})
      )
      Prelude.id


instance Data.ProtoLens.Message ArrayValue where
  messageName _ =
    Data.Text.pack "opentelemetry.proto.common.v1.ArrayValue"
  packedMessageDescriptor _ =
    "\n\
    \\n\
    \ArrayValue\DC2?\n\
    \\ACKvalues\CAN\SOH \ETX(\v2'.opentelemetry.proto.common.v1.AnyValueR\ACKvalues"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag =
    let values__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "values"
            ( Data.ProtoLens.MessageField Data.ProtoLens.MessageType
                :: Data.ProtoLens.FieldTypeDescriptor AnyValue
            )
            ( Data.ProtoLens.RepeatedField
                Data.ProtoLens.Unpacked
                (Data.ProtoLens.Field.field @"values")
            )
            :: Data.ProtoLens.FieldDescriptor ArrayValue
     in Data.Map.fromList
          [(Data.ProtoLens.Tag 1, values__field_descriptor)]
  unknownFields =
    Lens.Family2.Unchecked.lens
      _ArrayValue'_unknownFields
      (\x__ y__ -> x__ {_ArrayValue'_unknownFields = y__})
  defMessage =
    ArrayValue'_constructor
      { _ArrayValue'values = Data.Vector.Generic.empty
      , _ArrayValue'_unknownFields = []
      }
  parseMessage =
    let loop
          :: ArrayValue
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld AnyValue
          -> Data.ProtoLens.Encoding.Bytes.Parser ArrayValue
        loop x mutable'values =
          do
            end <- Data.ProtoLens.Encoding.Bytes.atEnd
            if end
              then do
                frozen'values <-
                  Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                    ( Data.ProtoLens.Encoding.Growing.unsafeFreeze
                        mutable'values
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
                          (Data.ProtoLens.Field.field @"vec'values")
                          frozen'values
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
                          "values"
                      v <-
                        Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                          (Data.ProtoLens.Encoding.Growing.append mutable'values y)
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
                        mutable'values
     in (Data.ProtoLens.Encoding.Bytes.<?>)
          ( do
              mutable'values <-
                Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                  Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'values
          )
          "ArrayValue"
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
            (Lens.Family2.view (Data.ProtoLens.Field.field @"vec'values") _x)
        )
        ( Data.ProtoLens.Encoding.Wire.buildFieldSet
            (Lens.Family2.view Data.ProtoLens.unknownFields _x)
        )


instance Control.DeepSeq.NFData ArrayValue where
  rnf =
    \x__ ->
      Control.DeepSeq.deepseq
        (_ArrayValue'_unknownFields x__)
        (Control.DeepSeq.deepseq (_ArrayValue'values x__) ())


{- | Fields :

         * 'Proto.Opentelemetry.Proto.Common.V1.Common_Fields.name' @:: Lens' InstrumentationLibrary Data.Text.Text@
         * 'Proto.Opentelemetry.Proto.Common.V1.Common_Fields.version' @:: Lens' InstrumentationLibrary Data.Text.Text@
-}
data InstrumentationLibrary = InstrumentationLibrary'_constructor
  { _InstrumentationLibrary'name :: !Data.Text.Text
  , _InstrumentationLibrary'version :: !Data.Text.Text
  , _InstrumentationLibrary'_unknownFields :: !Data.ProtoLens.FieldSet
  }
  deriving stock (Prelude.Eq, Prelude.Ord)


instance Prelude.Show InstrumentationLibrary where
  showsPrec _ __x __s =
    Prelude.showChar
      '{'
      ( Prelude.showString
          (Data.ProtoLens.showMessageShort __x)
          (Prelude.showChar '}' __s)
      )


instance Data.ProtoLens.Field.HasField InstrumentationLibrary "name" Data.Text.Text where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _InstrumentationLibrary'name
          (\x__ y__ -> x__ {_InstrumentationLibrary'name = y__})
      )
      Prelude.id


instance Data.ProtoLens.Field.HasField InstrumentationLibrary "version" Data.Text.Text where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _InstrumentationLibrary'version
          (\x__ y__ -> x__ {_InstrumentationLibrary'version = y__})
      )
      Prelude.id


instance Data.ProtoLens.Message InstrumentationLibrary where
  messageName _ =
    Data.Text.pack
      "opentelemetry.proto.common.v1.InstrumentationLibrary"
  packedMessageDescriptor _ =
    "\n\
    \\SYNInstrumentationLibrary\DC2\DC2\n\
    \\EOTname\CAN\SOH \SOH(\tR\EOTname\DC2\CAN\n\
    \\aversion\CAN\STX \SOH(\tR\aversion"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag =
    let name__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "name"
            ( Data.ProtoLens.ScalarField Data.ProtoLens.StringField
                :: Data.ProtoLens.FieldTypeDescriptor Data.Text.Text
            )
            ( Data.ProtoLens.PlainField
                Data.ProtoLens.Optional
                (Data.ProtoLens.Field.field @"name")
            )
            :: Data.ProtoLens.FieldDescriptor InstrumentationLibrary
        version__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "version"
            ( Data.ProtoLens.ScalarField Data.ProtoLens.StringField
                :: Data.ProtoLens.FieldTypeDescriptor Data.Text.Text
            )
            ( Data.ProtoLens.PlainField
                Data.ProtoLens.Optional
                (Data.ProtoLens.Field.field @"version")
            )
            :: Data.ProtoLens.FieldDescriptor InstrumentationLibrary
     in Data.Map.fromList
          [ (Data.ProtoLens.Tag 1, name__field_descriptor)
          , (Data.ProtoLens.Tag 2, version__field_descriptor)
          ]
  unknownFields =
    Lens.Family2.Unchecked.lens
      _InstrumentationLibrary'_unknownFields
      (\x__ y__ -> x__ {_InstrumentationLibrary'_unknownFields = y__})
  defMessage =
    InstrumentationLibrary'_constructor
      { _InstrumentationLibrary'name = Data.ProtoLens.fieldDefault
      , _InstrumentationLibrary'version = Data.ProtoLens.fieldDefault
      , _InstrumentationLibrary'_unknownFields = []
      }
  parseMessage =
    let loop
          :: InstrumentationLibrary
          -> Data.ProtoLens.Encoding.Bytes.Parser InstrumentationLibrary
        loop x =
          do
            end <- Data.ProtoLens.Encoding.Bytes.atEnd
            if end
              then do
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
                      x
                  )
              else do
                tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                case tag of
                  10 ->
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
                      loop (Lens.Family2.set (Data.ProtoLens.Field.field @"name") y x)
                  18 ->
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
                          "version"
                      loop (Lens.Family2.set (Data.ProtoLens.Field.field @"version") y x)
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
     in (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage)
          "InstrumentationLibrary"
  buildMessage =
    \_x ->
      (Data.Monoid.<>)
        ( let _v = Lens.Family2.view (Data.ProtoLens.Field.field @"name") _x
           in if (Prelude.==) _v Data.ProtoLens.fieldDefault
                then Data.Monoid.mempty
                else
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
                        Data.Text.Encoding.encodeUtf8
                        _v
                    )
        )
        ( (Data.Monoid.<>)
            ( let _v = Lens.Family2.view (Data.ProtoLens.Field.field @"version") _x
               in if (Prelude.==) _v Data.ProtoLens.fieldDefault
                    then Data.Monoid.mempty
                    else
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
                            Data.Text.Encoding.encodeUtf8
                            _v
                        )
            )
            ( Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x)
            )
        )


instance Control.DeepSeq.NFData InstrumentationLibrary where
  rnf =
    \x__ ->
      Control.DeepSeq.deepseq
        (_InstrumentationLibrary'_unknownFields x__)
        ( Control.DeepSeq.deepseq
            (_InstrumentationLibrary'name x__)
            (Control.DeepSeq.deepseq (_InstrumentationLibrary'version x__) ())
        )


{- | Fields :

         * 'Proto.Opentelemetry.Proto.Common.V1.Common_Fields.key' @:: Lens' KeyValue Data.Text.Text@
         * 'Proto.Opentelemetry.Proto.Common.V1.Common_Fields.value' @:: Lens' KeyValue AnyValue@
         * 'Proto.Opentelemetry.Proto.Common.V1.Common_Fields.maybe'value' @:: Lens' KeyValue (Prelude.Maybe AnyValue)@
-}
data KeyValue = KeyValue'_constructor
  { _KeyValue'key :: !Data.Text.Text
  , _KeyValue'value :: !(Prelude.Maybe AnyValue)
  , _KeyValue'_unknownFields :: !Data.ProtoLens.FieldSet
  }
  deriving stock (Prelude.Eq, Prelude.Ord)


instance Prelude.Show KeyValue where
  showsPrec _ __x __s =
    Prelude.showChar
      '{'
      ( Prelude.showString
          (Data.ProtoLens.showMessageShort __x)
          (Prelude.showChar '}' __s)
      )


instance Data.ProtoLens.Field.HasField KeyValue "key" Data.Text.Text where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _KeyValue'key
          (\x__ y__ -> x__ {_KeyValue'key = y__})
      )
      Prelude.id


instance Data.ProtoLens.Field.HasField KeyValue "value" AnyValue where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _KeyValue'value
          (\x__ y__ -> x__ {_KeyValue'value = y__})
      )
      (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)


instance Data.ProtoLens.Field.HasField KeyValue "maybe'value" (Prelude.Maybe AnyValue) where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _KeyValue'value
          (\x__ y__ -> x__ {_KeyValue'value = y__})
      )
      Prelude.id


instance Data.ProtoLens.Message KeyValue where
  messageName _ =
    Data.Text.pack "opentelemetry.proto.common.v1.KeyValue"
  packedMessageDescriptor _ =
    "\n\
    \\bKeyValue\DC2\DLE\n\
    \\ETXkey\CAN\SOH \SOH(\tR\ETXkey\DC2=\n\
    \\ENQvalue\CAN\STX \SOH(\v2'.opentelemetry.proto.common.v1.AnyValueR\ENQvalue"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag =
    let key__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "key"
            ( Data.ProtoLens.ScalarField Data.ProtoLens.StringField
                :: Data.ProtoLens.FieldTypeDescriptor Data.Text.Text
            )
            ( Data.ProtoLens.PlainField
                Data.ProtoLens.Optional
                (Data.ProtoLens.Field.field @"key")
            )
            :: Data.ProtoLens.FieldDescriptor KeyValue
        value__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "value"
            ( Data.ProtoLens.MessageField Data.ProtoLens.MessageType
                :: Data.ProtoLens.FieldTypeDescriptor AnyValue
            )
            ( Data.ProtoLens.OptionalField
                (Data.ProtoLens.Field.field @"maybe'value")
            )
            :: Data.ProtoLens.FieldDescriptor KeyValue
     in Data.Map.fromList
          [ (Data.ProtoLens.Tag 1, key__field_descriptor)
          , (Data.ProtoLens.Tag 2, value__field_descriptor)
          ]
  unknownFields =
    Lens.Family2.Unchecked.lens
      _KeyValue'_unknownFields
      (\x__ y__ -> x__ {_KeyValue'_unknownFields = y__})
  defMessage =
    KeyValue'_constructor
      { _KeyValue'key = Data.ProtoLens.fieldDefault
      , _KeyValue'value = Prelude.Nothing
      , _KeyValue'_unknownFields = []
      }
  parseMessage =
    let loop :: KeyValue -> Data.ProtoLens.Encoding.Bytes.Parser KeyValue
        loop x =
          do
            end <- Data.ProtoLens.Encoding.Bytes.atEnd
            if end
              then do
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
                      x
                  )
              else do
                tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                case tag of
                  10 ->
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
                          "key"
                      loop (Lens.Family2.set (Data.ProtoLens.Field.field @"key") y x)
                  18 ->
                    do
                      y <-
                        (Data.ProtoLens.Encoding.Bytes.<?>)
                          ( do
                              len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                              Data.ProtoLens.Encoding.Bytes.isolate
                                (Prelude.fromIntegral len)
                                Data.ProtoLens.parseMessage
                          )
                          "value"
                      loop (Lens.Family2.set (Data.ProtoLens.Field.field @"value") y x)
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
     in (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage)
          "KeyValue"
  buildMessage =
    \_x ->
      (Data.Monoid.<>)
        ( let _v = Lens.Family2.view (Data.ProtoLens.Field.field @"key") _x
           in if (Prelude.==) _v Data.ProtoLens.fieldDefault
                then Data.Monoid.mempty
                else
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
                        Data.Text.Encoding.encodeUtf8
                        _v
                    )
        )
        ( (Data.Monoid.<>)
            ( case Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'value") _x of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just _v) ->
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
            ( Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x)
            )
        )


instance Control.DeepSeq.NFData KeyValue where
  rnf =
    \x__ ->
      Control.DeepSeq.deepseq
        (_KeyValue'_unknownFields x__)
        ( Control.DeepSeq.deepseq
            (_KeyValue'key x__)
            (Control.DeepSeq.deepseq (_KeyValue'value x__) ())
        )


{- | Fields :

         * 'Proto.Opentelemetry.Proto.Common.V1.Common_Fields.values' @:: Lens' KeyValueList [KeyValue]@
         * 'Proto.Opentelemetry.Proto.Common.V1.Common_Fields.vec'values' @:: Lens' KeyValueList (Data.Vector.Vector KeyValue)@
-}
data KeyValueList = KeyValueList'_constructor
  { _KeyValueList'values :: !(Data.Vector.Vector KeyValue)
  , _KeyValueList'_unknownFields :: !Data.ProtoLens.FieldSet
  }
  deriving stock (Prelude.Eq, Prelude.Ord)


instance Prelude.Show KeyValueList where
  showsPrec _ __x __s =
    Prelude.showChar
      '{'
      ( Prelude.showString
          (Data.ProtoLens.showMessageShort __x)
          (Prelude.showChar '}' __s)
      )


instance Data.ProtoLens.Field.HasField KeyValueList "values" [KeyValue] where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _KeyValueList'values
          (\x__ y__ -> x__ {_KeyValueList'values = y__})
      )
      ( Lens.Family2.Unchecked.lens
          Data.Vector.Generic.toList
          (\_ y__ -> Data.Vector.Generic.fromList y__)
      )


instance Data.ProtoLens.Field.HasField KeyValueList "vec'values" (Data.Vector.Vector KeyValue) where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _KeyValueList'values
          (\x__ y__ -> x__ {_KeyValueList'values = y__})
      )
      Prelude.id


instance Data.ProtoLens.Message KeyValueList where
  messageName _ =
    Data.Text.pack "opentelemetry.proto.common.v1.KeyValueList"
  packedMessageDescriptor _ =
    "\n\
    \\fKeyValueList\DC2?\n\
    \\ACKvalues\CAN\SOH \ETX(\v2'.opentelemetry.proto.common.v1.KeyValueR\ACKvalues"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag =
    let values__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "values"
            ( Data.ProtoLens.MessageField Data.ProtoLens.MessageType
                :: Data.ProtoLens.FieldTypeDescriptor KeyValue
            )
            ( Data.ProtoLens.RepeatedField
                Data.ProtoLens.Unpacked
                (Data.ProtoLens.Field.field @"values")
            )
            :: Data.ProtoLens.FieldDescriptor KeyValueList
     in Data.Map.fromList
          [(Data.ProtoLens.Tag 1, values__field_descriptor)]
  unknownFields =
    Lens.Family2.Unchecked.lens
      _KeyValueList'_unknownFields
      (\x__ y__ -> x__ {_KeyValueList'_unknownFields = y__})
  defMessage =
    KeyValueList'_constructor
      { _KeyValueList'values = Data.Vector.Generic.empty
      , _KeyValueList'_unknownFields = []
      }
  parseMessage =
    let loop
          :: KeyValueList
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld KeyValue
          -> Data.ProtoLens.Encoding.Bytes.Parser KeyValueList
        loop x mutable'values =
          do
            end <- Data.ProtoLens.Encoding.Bytes.atEnd
            if end
              then do
                frozen'values <-
                  Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                    ( Data.ProtoLens.Encoding.Growing.unsafeFreeze
                        mutable'values
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
                          (Data.ProtoLens.Field.field @"vec'values")
                          frozen'values
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
                          "values"
                      v <-
                        Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                          (Data.ProtoLens.Encoding.Growing.append mutable'values y)
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
                        mutable'values
     in (Data.ProtoLens.Encoding.Bytes.<?>)
          ( do
              mutable'values <-
                Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                  Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'values
          )
          "KeyValueList"
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
            (Lens.Family2.view (Data.ProtoLens.Field.field @"vec'values") _x)
        )
        ( Data.ProtoLens.Encoding.Wire.buildFieldSet
            (Lens.Family2.view Data.ProtoLens.unknownFields _x)
        )


instance Control.DeepSeq.NFData KeyValueList where
  rnf =
    \x__ ->
      Control.DeepSeq.deepseq
        (_KeyValueList'_unknownFields x__)
        (Control.DeepSeq.deepseq (_KeyValueList'values x__) ())


{- | Fields :

         * 'Proto.Opentelemetry.Proto.Common.V1.Common_Fields.key' @:: Lens' StringKeyValue Data.Text.Text@
         * 'Proto.Opentelemetry.Proto.Common.V1.Common_Fields.value' @:: Lens' StringKeyValue Data.Text.Text@
-}
data StringKeyValue = StringKeyValue'_constructor
  { _StringKeyValue'key :: !Data.Text.Text
  , _StringKeyValue'value :: !Data.Text.Text
  , _StringKeyValue'_unknownFields :: !Data.ProtoLens.FieldSet
  }
  deriving stock (Prelude.Eq, Prelude.Ord)


instance Prelude.Show StringKeyValue where
  showsPrec _ __x __s =
    Prelude.showChar
      '{'
      ( Prelude.showString
          (Data.ProtoLens.showMessageShort __x)
          (Prelude.showChar '}' __s)
      )


instance Data.ProtoLens.Field.HasField StringKeyValue "key" Data.Text.Text where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _StringKeyValue'key
          (\x__ y__ -> x__ {_StringKeyValue'key = y__})
      )
      Prelude.id


instance Data.ProtoLens.Field.HasField StringKeyValue "value" Data.Text.Text where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _StringKeyValue'value
          (\x__ y__ -> x__ {_StringKeyValue'value = y__})
      )
      Prelude.id


instance Data.ProtoLens.Message StringKeyValue where
  messageName _ =
    Data.Text.pack "opentelemetry.proto.common.v1.StringKeyValue"
  packedMessageDescriptor _ =
    "\n\
    \\SOStringKeyValue\DC2\DLE\n\
    \\ETXkey\CAN\SOH \SOH(\tR\ETXkey\DC2\DC4\n\
    \\ENQvalue\CAN\STX \SOH(\tR\ENQvalue:\STX\CAN\SOH"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag =
    let key__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "key"
            ( Data.ProtoLens.ScalarField Data.ProtoLens.StringField
                :: Data.ProtoLens.FieldTypeDescriptor Data.Text.Text
            )
            ( Data.ProtoLens.PlainField
                Data.ProtoLens.Optional
                (Data.ProtoLens.Field.field @"key")
            )
            :: Data.ProtoLens.FieldDescriptor StringKeyValue
        value__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "value"
            ( Data.ProtoLens.ScalarField Data.ProtoLens.StringField
                :: Data.ProtoLens.FieldTypeDescriptor Data.Text.Text
            )
            ( Data.ProtoLens.PlainField
                Data.ProtoLens.Optional
                (Data.ProtoLens.Field.field @"value")
            )
            :: Data.ProtoLens.FieldDescriptor StringKeyValue
     in Data.Map.fromList
          [ (Data.ProtoLens.Tag 1, key__field_descriptor)
          , (Data.ProtoLens.Tag 2, value__field_descriptor)
          ]
  unknownFields =
    Lens.Family2.Unchecked.lens
      _StringKeyValue'_unknownFields
      (\x__ y__ -> x__ {_StringKeyValue'_unknownFields = y__})
  defMessage =
    StringKeyValue'_constructor
      { _StringKeyValue'key = Data.ProtoLens.fieldDefault
      , _StringKeyValue'value = Data.ProtoLens.fieldDefault
      , _StringKeyValue'_unknownFields = []
      }
  parseMessage =
    let loop
          :: StringKeyValue
          -> Data.ProtoLens.Encoding.Bytes.Parser StringKeyValue
        loop x =
          do
            end <- Data.ProtoLens.Encoding.Bytes.atEnd
            if end
              then do
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
                      x
                  )
              else do
                tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                case tag of
                  10 ->
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
                          "key"
                      loop (Lens.Family2.set (Data.ProtoLens.Field.field @"key") y x)
                  18 ->
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
                          "value"
                      loop (Lens.Family2.set (Data.ProtoLens.Field.field @"value") y x)
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
     in (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage)
          "StringKeyValue"
  buildMessage =
    \_x ->
      (Data.Monoid.<>)
        ( let _v = Lens.Family2.view (Data.ProtoLens.Field.field @"key") _x
           in if (Prelude.==) _v Data.ProtoLens.fieldDefault
                then Data.Monoid.mempty
                else
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
                        Data.Text.Encoding.encodeUtf8
                        _v
                    )
        )
        ( (Data.Monoid.<>)
            ( let _v = Lens.Family2.view (Data.ProtoLens.Field.field @"value") _x
               in if (Prelude.==) _v Data.ProtoLens.fieldDefault
                    then Data.Monoid.mempty
                    else
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
                            Data.Text.Encoding.encodeUtf8
                            _v
                        )
            )
            ( Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x)
            )
        )


instance Control.DeepSeq.NFData StringKeyValue where
  rnf =
    \x__ ->
      Control.DeepSeq.deepseq
        (_StringKeyValue'_unknownFields x__)
        ( Control.DeepSeq.deepseq
            (_StringKeyValue'key x__)
            (Control.DeepSeq.deepseq (_StringKeyValue'value x__) ())
        )


packedFileDescriptor :: Data.ByteString.ByteString
packedFileDescriptor =
  "\n\
  \*opentelemetry/proto/common/v1/common.proto\DC2\GSopentelemetry.proto.common.v1\"\224\STX\n\
  \\bAnyValue\DC2#\n\
  \\fstring_value\CAN\SOH \SOH(\tH\NULR\vstringValue\DC2\US\n\
  \\n\
  \bool_value\CAN\STX \SOH(\bH\NULR\tboolValue\DC2\GS\n\
  \\tint_value\CAN\ETX \SOH(\ETXH\NULR\bintValue\DC2#\n\
  \\fdouble_value\CAN\EOT \SOH(\SOHH\NULR\vdoubleValue\DC2L\n\
  \\varray_value\CAN\ENQ \SOH(\v2).opentelemetry.proto.common.v1.ArrayValueH\NULR\n\
  \arrayValue\DC2P\n\
  \\fkvlist_value\CAN\ACK \SOH(\v2+.opentelemetry.proto.common.v1.KeyValueListH\NULR\vkvlistValue\DC2!\n\
  \\vbytes_value\CAN\a \SOH(\fH\NULR\n\
  \bytesValueB\a\n\
  \\ENQvalue\"M\n\
  \\n\
  \ArrayValue\DC2?\n\
  \\ACKvalues\CAN\SOH \ETX(\v2'.opentelemetry.proto.common.v1.AnyValueR\ACKvalues\"O\n\
  \\fKeyValueList\DC2?\n\
  \\ACKvalues\CAN\SOH \ETX(\v2'.opentelemetry.proto.common.v1.KeyValueR\ACKvalues\"[\n\
  \\bKeyValue\DC2\DLE\n\
  \\ETXkey\CAN\SOH \SOH(\tR\ETXkey\DC2=\n\
  \\ENQvalue\CAN\STX \SOH(\v2'.opentelemetry.proto.common.v1.AnyValueR\ENQvalue\"<\n\
  \\SOStringKeyValue\DC2\DLE\n\
  \\ETXkey\CAN\SOH \SOH(\tR\ETXkey\DC2\DC4\n\
  \\ENQvalue\CAN\STX \SOH(\tR\ENQvalue:\STX\CAN\SOH\"F\n\
  \\SYNInstrumentationLibrary\DC2\DC2\n\
  \\EOTname\CAN\SOH \SOH(\tR\EOTname\DC2\CAN\n\
  \\aversion\CAN\STX \SOH(\tR\aversionBq\n\
  \ io.opentelemetry.proto.common.v1B\vCommonProtoP\SOHZ>github.com/open-telemetry/opentelemetry-proto/gen/go/common/v1J\164\EM\n\
  \\ACK\DC2\EOT\SO\NULP\SOH\n\
  \\200\EOT\n\
  \\SOH\f\DC2\ETX\SO\NUL\DC22\189\EOT Copyright 2019, OpenTelemetry Authors\n\
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
  \\SOH\STX\DC2\ETX\DLE\NUL&\n\
  \\b\n\
  \\SOH\b\DC2\ETX\DC2\NUL\"\n\
  \\t\n\
  \\STX\b\n\
  \\DC2\ETX\DC2\NUL\"\n\
  \\b\n\
  \\SOH\b\DC2\ETX\DC3\NUL9\n\
  \\t\n\
  \\STX\b\SOH\DC2\ETX\DC3\NUL9\n\
  \\b\n\
  \\SOH\b\DC2\ETX\DC4\NUL,\n\
  \\t\n\
  \\STX\b\b\DC2\ETX\DC4\NUL,\n\
  \\b\n\
  \\SOH\b\DC2\ETX\NAK\NULU\n\
  \\t\n\
  \\STX\b\v\DC2\ETX\NAK\NULU\n\
  \\238\SOH\n\
  \\STX\EOT\NUL\DC2\EOT\SUB\NUL&\SOH\SUB\225\SOH AnyValue is used to represent any type of attribute value. AnyValue may contain a\n\
  \ primitive value such as a string or integer or it may contain an arbitrary nested\n\
  \ object containing arrays, key-value lists and primitives.\n\
  \\n\
  \\n\
  \\n\
  \\ETX\EOT\NUL\SOH\DC2\ETX\SUB\b\DLE\n\
  \\158\SOH\n\
  \\EOT\EOT\NUL\b\NUL\DC2\EOT\GS\STX%\ETX\SUB\143\SOH The value is one of the listed fields. It is valid for all values to be unspecified\n\
  \ in which case this AnyValue is considered to be \"empty\".\n\
  \\n\
  \\f\n\
  \\ENQ\EOT\NUL\b\NUL\SOH\DC2\ETX\GS\b\r\n\
  \\v\n\
  \\EOT\EOT\NUL\STX\NUL\DC2\ETX\RS\EOT\FS\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\NUL\ENQ\DC2\ETX\RS\EOT\n\
  \\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\NUL\SOH\DC2\ETX\RS\v\ETB\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\NUL\ETX\DC2\ETX\RS\SUB\ESC\n\
  \\v\n\
  \\EOT\EOT\NUL\STX\SOH\DC2\ETX\US\EOT\CAN\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\SOH\ENQ\DC2\ETX\US\EOT\b\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\SOH\SOH\DC2\ETX\US\t\DC3\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\SOH\ETX\DC2\ETX\US\SYN\ETB\n\
  \\v\n\
  \\EOT\EOT\NUL\STX\STX\DC2\ETX \EOT\CAN\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\STX\ENQ\DC2\ETX \EOT\t\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\STX\SOH\DC2\ETX \n\
  \\DC3\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\STX\ETX\DC2\ETX \SYN\ETB\n\
  \\v\n\
  \\EOT\EOT\NUL\STX\ETX\DC2\ETX!\EOT\FS\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\ETX\ENQ\DC2\ETX!\EOT\n\
  \\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\ETX\SOH\DC2\ETX!\v\ETB\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\ETX\ETX\DC2\ETX!\SUB\ESC\n\
  \\v\n\
  \\EOT\EOT\NUL\STX\EOT\DC2\ETX\"\EOT\US\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\EOT\ACK\DC2\ETX\"\EOT\SO\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\EOT\SOH\DC2\ETX\"\SI\SUB\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\EOT\ETX\DC2\ETX\"\GS\RS\n\
  \\v\n\
  \\EOT\EOT\NUL\STX\ENQ\DC2\ETX#\EOT\"\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\ENQ\ACK\DC2\ETX#\EOT\DLE\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\ENQ\SOH\DC2\ETX#\DC1\GS\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\ENQ\ETX\DC2\ETX# !\n\
  \\v\n\
  \\EOT\EOT\NUL\STX\ACK\DC2\ETX$\EOT\SUB\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\ACK\ENQ\DC2\ETX$\EOT\t\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\ACK\SOH\DC2\ETX$\n\
  \\NAK\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\ACK\ETX\DC2\ETX$\CAN\EM\n\
  \\146\SOH\n\
  \\STX\EOT\SOH\DC2\EOT*\NUL-\SOH\SUB\133\SOH ArrayValue is a list of AnyValue messages. We need ArrayValue as a message\n\
  \ since oneof in AnyValue does not allow repeated fields.\n\
  \\n\
  \\n\
  \\n\
  \\ETX\EOT\SOH\SOH\DC2\ETX*\b\DC2\n\
  \L\n\
  \\EOT\EOT\SOH\STX\NUL\DC2\ETX,\STX\US\SUB? Array of values. The array may be empty (contain 0 elements).\n\
  \\n\
  \\f\n\
  \\ENQ\EOT\SOH\STX\NUL\EOT\DC2\ETX,\STX\n\
  \\n\
  \\f\n\
  \\ENQ\EOT\SOH\STX\NUL\ACK\DC2\ETX,\v\DC3\n\
  \\f\n\
  \\ENQ\EOT\SOH\STX\NUL\SOH\DC2\ETX,\DC4\SUB\n\
  \\f\n\
  \\ENQ\EOT\SOH\STX\NUL\ETX\DC2\ETX,\GS\RS\n\
  \\251\STX\n\
  \\STX\EOT\STX\DC2\EOT4\NUL8\SOH\SUB\238\STX KeyValueList is a list of KeyValue messages. We need KeyValueList as a message\n\
  \ since `oneof` in AnyValue does not allow repeated fields. Everywhere else where we need\n\
  \ a list of KeyValue messages (e.g. in Span) we use `repeated KeyValue` directly to\n\
  \ avoid unnecessary extra wrapping (which slows down the protocol). The 2 approaches\n\
  \ are semantically equivalent.\n\
  \\n\
  \\n\
  \\n\
  \\ETX\EOT\STX\SOH\DC2\ETX4\b\DC4\n\
  \s\n\
  \\EOT\EOT\STX\STX\NUL\DC2\ETX7\STX\US\SUBf A collection of key/value pairs of key-value pairs. The list may be empty (may\n\
  \ contain 0 elements).\n\
  \\n\
  \\f\n\
  \\ENQ\EOT\STX\STX\NUL\EOT\DC2\ETX7\STX\n\
  \\n\
  \\f\n\
  \\ENQ\EOT\STX\STX\NUL\ACK\DC2\ETX7\v\DC3\n\
  \\f\n\
  \\ENQ\EOT\STX\STX\NUL\SOH\DC2\ETX7\DC4\SUB\n\
  \\f\n\
  \\ENQ\EOT\STX\STX\NUL\ETX\DC2\ETX7\GS\RS\n\
  \h\n\
  \\STX\EOT\ETX\DC2\EOT<\NUL?\SOH\SUB\\ KeyValue is a key-value pair that is used to store Span attributes, Link\n\
  \ attributes, etc.\n\
  \\n\
  \\n\
  \\n\
  \\ETX\EOT\ETX\SOH\DC2\ETX<\b\DLE\n\
  \\v\n\
  \\EOT\EOT\ETX\STX\NUL\DC2\ETX=\STX\DC1\n\
  \\f\n\
  \\ENQ\EOT\ETX\STX\NUL\ENQ\DC2\ETX=\STX\b\n\
  \\f\n\
  \\ENQ\EOT\ETX\STX\NUL\SOH\DC2\ETX=\t\f\n\
  \\f\n\
  \\ENQ\EOT\ETX\STX\NUL\ETX\DC2\ETX=\SI\DLE\n\
  \\v\n\
  \\EOT\EOT\ETX\STX\SOH\DC2\ETX>\STX\NAK\n\
  \\f\n\
  \\ENQ\EOT\ETX\STX\SOH\ACK\DC2\ETX>\STX\n\
  \\n\
  \\f\n\
  \\ENQ\EOT\ETX\STX\SOH\SOH\DC2\ETX>\v\DLE\n\
  \\f\n\
  \\ENQ\EOT\ETX\STX\SOH\ETX\DC2\ETX>\DC3\DC4\n\
  \\149\SOH\n\
  \\STX\EOT\EOT\DC2\EOTC\NULH\SOH\SUB\136\SOH StringKeyValue is a pair of key/value strings. This is the simpler (and faster) version\n\
  \ of KeyValue that only supports string values.\n\
  \\n\
  \\n\
  \\n\
  \\ETX\EOT\EOT\SOH\DC2\ETXC\b\SYN\n\
  \\n\
  \\n\
  \\ETX\EOT\EOT\a\DC2\ETXD\STX\ESC\n\
  \\v\n\
  \\EOT\EOT\EOT\a\ETX\DC2\ETXD\STX\ESC\n\
  \\v\n\
  \\EOT\EOT\EOT\STX\NUL\DC2\ETXF\STX\DC1\n\
  \\f\n\
  \\ENQ\EOT\EOT\STX\NUL\ENQ\DC2\ETXF\STX\b\n\
  \\f\n\
  \\ENQ\EOT\EOT\STX\NUL\SOH\DC2\ETXF\t\f\n\
  \\f\n\
  \\ENQ\EOT\EOT\STX\NUL\ETX\DC2\ETXF\SI\DLE\n\
  \\v\n\
  \\EOT\EOT\EOT\STX\SOH\DC2\ETXG\STX\DC3\n\
  \\f\n\
  \\ENQ\EOT\EOT\STX\SOH\ENQ\DC2\ETXG\STX\b\n\
  \\f\n\
  \\ENQ\EOT\EOT\STX\SOH\SOH\DC2\ETXG\t\SO\n\
  \\f\n\
  \\ENQ\EOT\EOT\STX\SOH\ETX\DC2\ETXG\DC1\DC2\n\
  \\151\SOH\n\
  \\STX\EOT\ENQ\DC2\EOTL\NULP\SOH\SUB\138\SOH InstrumentationLibrary is a message representing the instrumentation library information\n\
  \ such as the fully qualified name and version. \n\
  \\n\
  \\n\
  \\n\
  \\ETX\EOT\ENQ\SOH\DC2\ETXL\b\RS\n\
  \P\n\
  \\EOT\EOT\ENQ\STX\NUL\DC2\ETXN\STX\DC2\SUBC An empty instrumentation library name means the name is unknown. \n\
  \\n\
  \\f\n\
  \\ENQ\EOT\ENQ\STX\NUL\ENQ\DC2\ETXN\STX\b\n\
  \\f\n\
  \\ENQ\EOT\ENQ\STX\NUL\SOH\DC2\ETXN\t\r\n\
  \\f\n\
  \\ENQ\EOT\ENQ\STX\NUL\ETX\DC2\ETXN\DLE\DC1\n\
  \\v\n\
  \\EOT\EOT\ENQ\STX\SOH\DC2\ETXO\STX\NAK\n\
  \\f\n\
  \\ENQ\EOT\ENQ\STX\SOH\ENQ\DC2\ETXO\STX\b\n\
  \\f\n\
  \\ENQ\EOT\ENQ\STX\SOH\SOH\DC2\ETXO\t\DLE\n\
  \\f\n\
  \\ENQ\EOT\ENQ\STX\SOH\ETX\DC2\ETXO\DC3\DC4b\ACKproto3"
