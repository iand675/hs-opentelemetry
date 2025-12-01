{- HLINT ignore -}
{- This file was auto-generated from opentelemetry/proto/profiles/v1development/profiles.proto by the proto-lens-protoc program. -}
{-# LANGUAGE ScopedTypeVariables, DataKinds, TypeFamilies, UndecidableInstances, GeneralizedNewtypeDeriving, MultiParamTypeClasses, FlexibleContexts, FlexibleInstances, PatternSynonyms, MagicHash, NoImplicitPrelude, DataKinds, BangPatterns, TypeApplications, OverloadedStrings, DerivingStrategies#-}
{-# OPTIONS_GHC -Wno-unused-imports#-}
{-# OPTIONS_GHC -Wno-duplicate-exports#-}
{-# OPTIONS_GHC -Wno-dodgy-exports#-}
module Proto.Opentelemetry.Proto.Profiles.V1development.Profiles (
        Function(), KeyValueAndUnit(), Line(), Link(), Location(),
        Mapping(), Profile(), ProfilesData(), ProfilesDictionary(),
        ResourceProfiles(), Sample(), ScopeProfiles(), Stack(), ValueType()
    ) where
import qualified Data.ProtoLens.Runtime.Control.DeepSeq as Control.DeepSeq
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Prism as Data.ProtoLens.Prism
import qualified Data.ProtoLens.Runtime.Prelude as Prelude
import qualified Data.ProtoLens.Runtime.Data.Int as Data.Int
import qualified Data.ProtoLens.Runtime.Data.Monoid as Data.Monoid
import qualified Data.ProtoLens.Runtime.Data.Word as Data.Word
import qualified Data.ProtoLens.Runtime.Data.ProtoLens as Data.ProtoLens
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Encoding.Bytes as Data.ProtoLens.Encoding.Bytes
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Encoding.Growing as Data.ProtoLens.Encoding.Growing
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Encoding.Parser.Unsafe as Data.ProtoLens.Encoding.Parser.Unsafe
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Encoding.Wire as Data.ProtoLens.Encoding.Wire
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Field as Data.ProtoLens.Field
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Message.Enum as Data.ProtoLens.Message.Enum
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Service.Types as Data.ProtoLens.Service.Types
import qualified Data.ProtoLens.Runtime.Lens.Family2 as Lens.Family2
import qualified Data.ProtoLens.Runtime.Lens.Family2.Unchecked as Lens.Family2.Unchecked
import qualified Data.ProtoLens.Runtime.Data.Text as Data.Text
import qualified Data.ProtoLens.Runtime.Data.Map as Data.Map
import qualified Data.ProtoLens.Runtime.Data.ByteString as Data.ByteString
import qualified Data.ProtoLens.Runtime.Data.ByteString.Char8 as Data.ByteString.Char8
import qualified Data.ProtoLens.Runtime.Data.Text.Encoding as Data.Text.Encoding
import qualified Data.ProtoLens.Runtime.Data.Vector as Data.Vector
import qualified Data.ProtoLens.Runtime.Data.Vector.Generic as Data.Vector.Generic
import qualified Data.ProtoLens.Runtime.Data.Vector.Unboxed as Data.Vector.Unboxed
import qualified Data.ProtoLens.Runtime.Text.Read as Text.Read
import qualified Proto.Opentelemetry.Proto.Common.V1.Common
import qualified Proto.Opentelemetry.Proto.Resource.V1.Resource
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.nameStrindex' @:: Lens' Function Data.Int.Int32@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.systemNameStrindex' @:: Lens' Function Data.Int.Int32@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.filenameStrindex' @:: Lens' Function Data.Int.Int32@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.startLine' @:: Lens' Function Data.Int.Int64@ -}
data Function
  = Function'_constructor {_Function'nameStrindex :: !Data.Int.Int32,
                           _Function'systemNameStrindex :: !Data.Int.Int32,
                           _Function'filenameStrindex :: !Data.Int.Int32,
                           _Function'startLine :: !Data.Int.Int64,
                           _Function'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show Function where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField Function "nameStrindex" Data.Int.Int32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Function'nameStrindex
           (\ x__ y__ -> x__ {_Function'nameStrindex = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Function "systemNameStrindex" Data.Int.Int32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Function'systemNameStrindex
           (\ x__ y__ -> x__ {_Function'systemNameStrindex = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Function "filenameStrindex" Data.Int.Int32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Function'filenameStrindex
           (\ x__ y__ -> x__ {_Function'filenameStrindex = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Function "startLine" Data.Int.Int64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Function'startLine (\ x__ y__ -> x__ {_Function'startLine = y__}))
        Prelude.id
instance Data.ProtoLens.Message Function where
  messageName _
    = Data.Text.pack
        "opentelemetry.proto.profiles.v1development.Function"
  packedMessageDescriptor _
    = "\n\
      \\bFunction\DC2#\n\
      \\rname_strindex\CAN\SOH \SOH(\ENQR\fnameStrindex\DC20\n\
      \\DC4system_name_strindex\CAN\STX \SOH(\ENQR\DC2systemNameStrindex\DC2+\n\
      \\DC1filename_strindex\CAN\ETX \SOH(\ENQR\DLEfilenameStrindex\DC2\GS\n\
      \\n\
      \start_line\CAN\EOT \SOH(\ETXR\tstartLine"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        nameStrindex__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "name_strindex"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"nameStrindex")) ::
              Data.ProtoLens.FieldDescriptor Function
        systemNameStrindex__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "system_name_strindex"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"systemNameStrindex")) ::
              Data.ProtoLens.FieldDescriptor Function
        filenameStrindex__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "filename_strindex"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"filenameStrindex")) ::
              Data.ProtoLens.FieldDescriptor Function
        startLine__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "start_line"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"startLine")) ::
              Data.ProtoLens.FieldDescriptor Function
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, nameStrindex__field_descriptor),
           (Data.ProtoLens.Tag 2, systemNameStrindex__field_descriptor),
           (Data.ProtoLens.Tag 3, filenameStrindex__field_descriptor),
           (Data.ProtoLens.Tag 4, startLine__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Function'_unknownFields
        (\ x__ y__ -> x__ {_Function'_unknownFields = y__})
  defMessage
    = Function'_constructor
        {_Function'nameStrindex = Data.ProtoLens.fieldDefault,
         _Function'systemNameStrindex = Data.ProtoLens.fieldDefault,
         _Function'filenameStrindex = Data.ProtoLens.fieldDefault,
         _Function'startLine = Data.ProtoLens.fieldDefault,
         _Function'_unknownFields = []}
  parseMessage
    = let
        loop :: Function -> Data.ProtoLens.Encoding.Bytes.Parser Function
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        8 -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "name_strindex"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"nameStrindex") y x)
                        16
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "system_name_strindex"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"systemNameStrindex") y x)
                        24
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "filename_strindex"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"filenameStrindex") y x)
                        32
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "start_line"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"startLine") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "Function"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v
                  = Lens.Family2.view (Data.ProtoLens.Field.field @"nameStrindex") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 8)
                      ((Prelude..)
                         Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
             ((Data.Monoid.<>)
                (let
                   _v
                     = Lens.Family2.view
                         (Data.ProtoLens.Field.field @"systemNameStrindex") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                         ((Prelude..)
                            Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                ((Data.Monoid.<>)
                   (let
                      _v
                        = Lens.Family2.view
                            (Data.ProtoLens.Field.field @"filenameStrindex") _x
                    in
                      if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                          Data.Monoid.mempty
                      else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 24)
                            ((Prelude..)
                               Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                   ((Data.Monoid.<>)
                      (let
                         _v = Lens.Family2.view (Data.ProtoLens.Field.field @"startLine") _x
                       in
                         if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                             Data.Monoid.mempty
                         else
                             (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt 32)
                               ((Prelude..)
                                  Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                      (Data.ProtoLens.Encoding.Wire.buildFieldSet
                         (Lens.Family2.view Data.ProtoLens.unknownFields _x)))))
instance Control.DeepSeq.NFData Function where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Function'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_Function'nameStrindex x__)
                (Control.DeepSeq.deepseq
                   (_Function'systemNameStrindex x__)
                   (Control.DeepSeq.deepseq
                      (_Function'filenameStrindex x__)
                      (Control.DeepSeq.deepseq (_Function'startLine x__) ()))))
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.keyStrindex' @:: Lens' KeyValueAndUnit Data.Int.Int32@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.value' @:: Lens' KeyValueAndUnit Proto.Opentelemetry.Proto.Common.V1.Common.AnyValue@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.maybe'value' @:: Lens' KeyValueAndUnit (Prelude.Maybe Proto.Opentelemetry.Proto.Common.V1.Common.AnyValue)@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.unitStrindex' @:: Lens' KeyValueAndUnit Data.Int.Int32@ -}
data KeyValueAndUnit
  = KeyValueAndUnit'_constructor {_KeyValueAndUnit'keyStrindex :: !Data.Int.Int32,
                                  _KeyValueAndUnit'value :: !(Prelude.Maybe Proto.Opentelemetry.Proto.Common.V1.Common.AnyValue),
                                  _KeyValueAndUnit'unitStrindex :: !Data.Int.Int32,
                                  _KeyValueAndUnit'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show KeyValueAndUnit where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField KeyValueAndUnit "keyStrindex" Data.Int.Int32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _KeyValueAndUnit'keyStrindex
           (\ x__ y__ -> x__ {_KeyValueAndUnit'keyStrindex = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField KeyValueAndUnit "value" Proto.Opentelemetry.Proto.Common.V1.Common.AnyValue where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _KeyValueAndUnit'value
           (\ x__ y__ -> x__ {_KeyValueAndUnit'value = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField KeyValueAndUnit "maybe'value" (Prelude.Maybe Proto.Opentelemetry.Proto.Common.V1.Common.AnyValue) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _KeyValueAndUnit'value
           (\ x__ y__ -> x__ {_KeyValueAndUnit'value = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField KeyValueAndUnit "unitStrindex" Data.Int.Int32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _KeyValueAndUnit'unitStrindex
           (\ x__ y__ -> x__ {_KeyValueAndUnit'unitStrindex = y__}))
        Prelude.id
instance Data.ProtoLens.Message KeyValueAndUnit where
  messageName _
    = Data.Text.pack
        "opentelemetry.proto.profiles.v1development.KeyValueAndUnit"
  packedMessageDescriptor _
    = "\n\
      \\SIKeyValueAndUnit\DC2!\n\
      \\fkey_strindex\CAN\SOH \SOH(\ENQR\vkeyStrindex\DC2=\n\
      \\ENQvalue\CAN\STX \SOH(\v2'.opentelemetry.proto.common.v1.AnyValueR\ENQvalue\DC2#\n\
      \\runit_strindex\CAN\ETX \SOH(\ENQR\funitStrindex"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        keyStrindex__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "key_strindex"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"keyStrindex")) ::
              Data.ProtoLens.FieldDescriptor KeyValueAndUnit
        value__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "value"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Opentelemetry.Proto.Common.V1.Common.AnyValue)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'value")) ::
              Data.ProtoLens.FieldDescriptor KeyValueAndUnit
        unitStrindex__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "unit_strindex"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"unitStrindex")) ::
              Data.ProtoLens.FieldDescriptor KeyValueAndUnit
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, keyStrindex__field_descriptor),
           (Data.ProtoLens.Tag 2, value__field_descriptor),
           (Data.ProtoLens.Tag 3, unitStrindex__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _KeyValueAndUnit'_unknownFields
        (\ x__ y__ -> x__ {_KeyValueAndUnit'_unknownFields = y__})
  defMessage
    = KeyValueAndUnit'_constructor
        {_KeyValueAndUnit'keyStrindex = Data.ProtoLens.fieldDefault,
         _KeyValueAndUnit'value = Prelude.Nothing,
         _KeyValueAndUnit'unitStrindex = Data.ProtoLens.fieldDefault,
         _KeyValueAndUnit'_unknownFields = []}
  parseMessage
    = let
        loop ::
          KeyValueAndUnit
          -> Data.ProtoLens.Encoding.Bytes.Parser KeyValueAndUnit
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        8 -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "key_strindex"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"keyStrindex") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "value"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"value") y x)
                        24
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "unit_strindex"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"unitStrindex") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "KeyValueAndUnit"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v
                  = Lens.Family2.view (Data.ProtoLens.Field.field @"keyStrindex") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 8)
                      ((Prelude..)
                         Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
             ((Data.Monoid.<>)
                (case
                     Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'value") _x
                 of
                   Prelude.Nothing -> Data.Monoid.mempty
                   (Prelude.Just _v)
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage _v))
                ((Data.Monoid.<>)
                   (let
                      _v
                        = Lens.Family2.view (Data.ProtoLens.Field.field @"unitStrindex") _x
                    in
                      if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                          Data.Monoid.mempty
                      else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 24)
                            ((Prelude..)
                               Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                   (Data.ProtoLens.Encoding.Wire.buildFieldSet
                      (Lens.Family2.view Data.ProtoLens.unknownFields _x))))
instance Control.DeepSeq.NFData KeyValueAndUnit where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_KeyValueAndUnit'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_KeyValueAndUnit'keyStrindex x__)
                (Control.DeepSeq.deepseq
                   (_KeyValueAndUnit'value x__)
                   (Control.DeepSeq.deepseq (_KeyValueAndUnit'unitStrindex x__) ())))
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.functionIndex' @:: Lens' Line Data.Int.Int32@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.line' @:: Lens' Line Data.Int.Int64@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.column' @:: Lens' Line Data.Int.Int64@ -}
data Line
  = Line'_constructor {_Line'functionIndex :: !Data.Int.Int32,
                       _Line'line :: !Data.Int.Int64,
                       _Line'column :: !Data.Int.Int64,
                       _Line'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show Line where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField Line "functionIndex" Data.Int.Int32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Line'functionIndex (\ x__ y__ -> x__ {_Line'functionIndex = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Line "line" Data.Int.Int64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Line'line (\ x__ y__ -> x__ {_Line'line = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Line "column" Data.Int.Int64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Line'column (\ x__ y__ -> x__ {_Line'column = y__}))
        Prelude.id
instance Data.ProtoLens.Message Line where
  messageName _
    = Data.Text.pack "opentelemetry.proto.profiles.v1development.Line"
  packedMessageDescriptor _
    = "\n\
      \\EOTLine\DC2%\n\
      \\SOfunction_index\CAN\SOH \SOH(\ENQR\rfunctionIndex\DC2\DC2\n\
      \\EOTline\CAN\STX \SOH(\ETXR\EOTline\DC2\SYN\n\
      \\ACKcolumn\CAN\ETX \SOH(\ETXR\ACKcolumn"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        functionIndex__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "function_index"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"functionIndex")) ::
              Data.ProtoLens.FieldDescriptor Line
        line__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "line"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"line")) ::
              Data.ProtoLens.FieldDescriptor Line
        column__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "column"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"column")) ::
              Data.ProtoLens.FieldDescriptor Line
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, functionIndex__field_descriptor),
           (Data.ProtoLens.Tag 2, line__field_descriptor),
           (Data.ProtoLens.Tag 3, column__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Line'_unknownFields
        (\ x__ y__ -> x__ {_Line'_unknownFields = y__})
  defMessage
    = Line'_constructor
        {_Line'functionIndex = Data.ProtoLens.fieldDefault,
         _Line'line = Data.ProtoLens.fieldDefault,
         _Line'column = Data.ProtoLens.fieldDefault,
         _Line'_unknownFields = []}
  parseMessage
    = let
        loop :: Line -> Data.ProtoLens.Encoding.Bytes.Parser Line
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        8 -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "function_index"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"functionIndex") y x)
                        16
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "line"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"line") y x)
                        24
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "column"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"column") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "Line"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v
                  = Lens.Family2.view
                      (Data.ProtoLens.Field.field @"functionIndex") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 8)
                      ((Prelude..)
                         Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
             ((Data.Monoid.<>)
                (let _v = Lens.Family2.view (Data.ProtoLens.Field.field @"line") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                         ((Prelude..)
                            Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                ((Data.Monoid.<>)
                   (let
                      _v = Lens.Family2.view (Data.ProtoLens.Field.field @"column") _x
                    in
                      if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                          Data.Monoid.mempty
                      else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 24)
                            ((Prelude..)
                               Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                   (Data.ProtoLens.Encoding.Wire.buildFieldSet
                      (Lens.Family2.view Data.ProtoLens.unknownFields _x))))
instance Control.DeepSeq.NFData Line where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Line'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_Line'functionIndex x__)
                (Control.DeepSeq.deepseq
                   (_Line'line x__) (Control.DeepSeq.deepseq (_Line'column x__) ())))
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.traceId' @:: Lens' Link Data.ByteString.ByteString@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.spanId' @:: Lens' Link Data.ByteString.ByteString@ -}
data Link
  = Link'_constructor {_Link'traceId :: !Data.ByteString.ByteString,
                       _Link'spanId :: !Data.ByteString.ByteString,
                       _Link'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show Link where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField Link "traceId" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Link'traceId (\ x__ y__ -> x__ {_Link'traceId = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Link "spanId" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Link'spanId (\ x__ y__ -> x__ {_Link'spanId = y__}))
        Prelude.id
instance Data.ProtoLens.Message Link where
  messageName _
    = Data.Text.pack "opentelemetry.proto.profiles.v1development.Link"
  packedMessageDescriptor _
    = "\n\
      \\EOTLink\DC2\EM\n\
      \\btrace_id\CAN\SOH \SOH(\fR\atraceId\DC2\ETB\n\
      \\aspan_id\CAN\STX \SOH(\fR\ACKspanId"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        traceId__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "trace_id"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"traceId")) ::
              Data.ProtoLens.FieldDescriptor Link
        spanId__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "span_id"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"spanId")) ::
              Data.ProtoLens.FieldDescriptor Link
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, traceId__field_descriptor),
           (Data.ProtoLens.Tag 2, spanId__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Link'_unknownFields
        (\ x__ y__ -> x__ {_Link'_unknownFields = y__})
  defMessage
    = Link'_constructor
        {_Link'traceId = Data.ProtoLens.fieldDefault,
         _Link'spanId = Data.ProtoLens.fieldDefault,
         _Link'_unknownFields = []}
  parseMessage
    = let
        loop :: Link -> Data.ProtoLens.Encoding.Bytes.Parser Link
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "trace_id"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"traceId") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "span_id"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"spanId") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "Link"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v = Lens.Family2.view (Data.ProtoLens.Field.field @"traceId") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                      ((\ bs
                          -> (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt
                                  (Prelude.fromIntegral (Data.ByteString.length bs)))
                               (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                         _v))
             ((Data.Monoid.<>)
                (let
                   _v = Lens.Family2.view (Data.ProtoLens.Field.field @"spanId") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                         ((\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                            _v))
                (Data.ProtoLens.Encoding.Wire.buildFieldSet
                   (Lens.Family2.view Data.ProtoLens.unknownFields _x)))
instance Control.DeepSeq.NFData Link where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Link'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_Link'traceId x__)
                (Control.DeepSeq.deepseq (_Link'spanId x__) ()))
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.mappingIndex' @:: Lens' Location Data.Int.Int32@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.address' @:: Lens' Location Data.Word.Word64@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.lines' @:: Lens' Location [Line]@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.vec'lines' @:: Lens' Location (Data.Vector.Vector Line)@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.attributeIndices' @:: Lens' Location [Data.Int.Int32]@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.vec'attributeIndices' @:: Lens' Location (Data.Vector.Unboxed.Vector Data.Int.Int32)@ -}
data Location
  = Location'_constructor {_Location'mappingIndex :: !Data.Int.Int32,
                           _Location'address :: !Data.Word.Word64,
                           _Location'lines :: !(Data.Vector.Vector Line),
                           _Location'attributeIndices :: !(Data.Vector.Unboxed.Vector Data.Int.Int32),
                           _Location'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show Location where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField Location "mappingIndex" Data.Int.Int32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Location'mappingIndex
           (\ x__ y__ -> x__ {_Location'mappingIndex = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Location "address" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Location'address (\ x__ y__ -> x__ {_Location'address = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Location "lines" [Line] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Location'lines (\ x__ y__ -> x__ {_Location'lines = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField Location "vec'lines" (Data.Vector.Vector Line) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Location'lines (\ x__ y__ -> x__ {_Location'lines = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Location "attributeIndices" [Data.Int.Int32] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Location'attributeIndices
           (\ x__ y__ -> x__ {_Location'attributeIndices = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField Location "vec'attributeIndices" (Data.Vector.Unboxed.Vector Data.Int.Int32) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Location'attributeIndices
           (\ x__ y__ -> x__ {_Location'attributeIndices = y__}))
        Prelude.id
instance Data.ProtoLens.Message Location where
  messageName _
    = Data.Text.pack
        "opentelemetry.proto.profiles.v1development.Location"
  packedMessageDescriptor _
    = "\n\
      \\bLocation\DC2#\n\
      \\rmapping_index\CAN\SOH \SOH(\ENQR\fmappingIndex\DC2\CAN\n\
      \\aaddress\CAN\STX \SOH(\EOTR\aaddress\DC2F\n\
      \\ENQlines\CAN\ETX \ETX(\v20.opentelemetry.proto.profiles.v1development.LineR\ENQlines\DC2+\n\
      \\DC1attribute_indices\CAN\EOT \ETX(\ENQR\DLEattributeIndices"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        mappingIndex__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "mapping_index"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"mappingIndex")) ::
              Data.ProtoLens.FieldDescriptor Location
        address__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "address"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"address")) ::
              Data.ProtoLens.FieldDescriptor Location
        lines__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "lines"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Line)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked (Data.ProtoLens.Field.field @"lines")) ::
              Data.ProtoLens.FieldDescriptor Location
        attributeIndices__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "attribute_indices"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int32)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Packed
                 (Data.ProtoLens.Field.field @"attributeIndices")) ::
              Data.ProtoLens.FieldDescriptor Location
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, mappingIndex__field_descriptor),
           (Data.ProtoLens.Tag 2, address__field_descriptor),
           (Data.ProtoLens.Tag 3, lines__field_descriptor),
           (Data.ProtoLens.Tag 4, attributeIndices__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Location'_unknownFields
        (\ x__ y__ -> x__ {_Location'_unknownFields = y__})
  defMessage
    = Location'_constructor
        {_Location'mappingIndex = Data.ProtoLens.fieldDefault,
         _Location'address = Data.ProtoLens.fieldDefault,
         _Location'lines = Data.Vector.Generic.empty,
         _Location'attributeIndices = Data.Vector.Generic.empty,
         _Location'_unknownFields = []}
  parseMessage
    = let
        loop ::
          Location
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Unboxed.Vector Data.ProtoLens.Encoding.Growing.RealWorld Data.Int.Int32
             -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Line
                -> Data.ProtoLens.Encoding.Bytes.Parser Location
        loop x mutable'attributeIndices mutable'lines
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'attributeIndices <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                   (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                      mutable'attributeIndices)
                      frozen'lines <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                        (Data.ProtoLens.Encoding.Growing.unsafeFreeze mutable'lines)
                      (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t)
                           (Lens.Family2.set
                              (Data.ProtoLens.Field.field @"vec'attributeIndices")
                              frozen'attributeIndices
                              (Lens.Family2.set
                                 (Data.ProtoLens.Field.field @"vec'lines") frozen'lines x)))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        8 -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "mapping_index"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"mappingIndex") y x)
                                  mutable'attributeIndices mutable'lines
                        16
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "address"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"address") y x)
                                  mutable'attributeIndices mutable'lines
                        26
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "lines"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'lines y)
                                loop x mutable'attributeIndices v
                        32
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (Prelude.fmap
                                           Prelude.fromIntegral
                                           Data.ProtoLens.Encoding.Bytes.getVarInt)
                                        "attribute_indices"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append
                                          mutable'attributeIndices y)
                                loop x v mutable'lines
                        34
                          -> do y <- do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                        Data.ProtoLens.Encoding.Bytes.isolate
                                          (Prelude.fromIntegral len)
                                          ((let
                                              ploop qs
                                                = do packedEnd <- Data.ProtoLens.Encoding.Bytes.atEnd
                                                     if packedEnd then
                                                         Prelude.return qs
                                                     else
                                                         do !q <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                                                    (Prelude.fmap
                                                                       Prelude.fromIntegral
                                                                       Data.ProtoLens.Encoding.Bytes.getVarInt)
                                                                    "attribute_indices"
                                                            qs' <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                                     (Data.ProtoLens.Encoding.Growing.append
                                                                        qs q)
                                                            ploop qs'
                                            in ploop)
                                             mutable'attributeIndices)
                                loop x y mutable'lines
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'attributeIndices mutable'lines
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'attributeIndices <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                            Data.ProtoLens.Encoding.Growing.new
              mutable'lines <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                 Data.ProtoLens.Encoding.Growing.new
              loop
                Data.ProtoLens.defMessage mutable'attributeIndices mutable'lines)
          "Location"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v
                  = Lens.Family2.view (Data.ProtoLens.Field.field @"mappingIndex") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 8)
                      ((Prelude..)
                         Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
             ((Data.Monoid.<>)
                (let
                   _v = Lens.Family2.view (Data.ProtoLens.Field.field @"address") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt _v))
                ((Data.Monoid.<>)
                   (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                      (\ _v
                         -> (Data.Monoid.<>)
                              (Data.ProtoLens.Encoding.Bytes.putVarInt 26)
                              ((Prelude..)
                                 (\ bs
                                    -> (Data.Monoid.<>)
                                         (Data.ProtoLens.Encoding.Bytes.putVarInt
                                            (Prelude.fromIntegral (Data.ByteString.length bs)))
                                         (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                 Data.ProtoLens.encodeMessage _v))
                      (Lens.Family2.view (Data.ProtoLens.Field.field @"vec'lines") _x))
                   ((Data.Monoid.<>)
                      (let
                         p = Lens.Family2.view
                               (Data.ProtoLens.Field.field @"vec'attributeIndices") _x
                       in
                         if Data.Vector.Generic.null p then
                             Data.Monoid.mempty
                         else
                             (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt 34)
                               ((\ bs
                                   -> (Data.Monoid.<>)
                                        (Data.ProtoLens.Encoding.Bytes.putVarInt
                                           (Prelude.fromIntegral (Data.ByteString.length bs)))
                                        (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                  (Data.ProtoLens.Encoding.Bytes.runBuilder
                                     (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                                        ((Prelude..)
                                           Data.ProtoLens.Encoding.Bytes.putVarInt
                                           Prelude.fromIntegral)
                                        p))))
                      (Data.ProtoLens.Encoding.Wire.buildFieldSet
                         (Lens.Family2.view Data.ProtoLens.unknownFields _x)))))
instance Control.DeepSeq.NFData Location where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Location'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_Location'mappingIndex x__)
                (Control.DeepSeq.deepseq
                   (_Location'address x__)
                   (Control.DeepSeq.deepseq
                      (_Location'lines x__)
                      (Control.DeepSeq.deepseq (_Location'attributeIndices x__) ()))))
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.memoryStart' @:: Lens' Mapping Data.Word.Word64@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.memoryLimit' @:: Lens' Mapping Data.Word.Word64@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.fileOffset' @:: Lens' Mapping Data.Word.Word64@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.filenameStrindex' @:: Lens' Mapping Data.Int.Int32@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.attributeIndices' @:: Lens' Mapping [Data.Int.Int32]@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.vec'attributeIndices' @:: Lens' Mapping (Data.Vector.Unboxed.Vector Data.Int.Int32)@ -}
data Mapping
  = Mapping'_constructor {_Mapping'memoryStart :: !Data.Word.Word64,
                          _Mapping'memoryLimit :: !Data.Word.Word64,
                          _Mapping'fileOffset :: !Data.Word.Word64,
                          _Mapping'filenameStrindex :: !Data.Int.Int32,
                          _Mapping'attributeIndices :: !(Data.Vector.Unboxed.Vector Data.Int.Int32),
                          _Mapping'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show Mapping where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField Mapping "memoryStart" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Mapping'memoryStart
           (\ x__ y__ -> x__ {_Mapping'memoryStart = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Mapping "memoryLimit" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Mapping'memoryLimit
           (\ x__ y__ -> x__ {_Mapping'memoryLimit = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Mapping "fileOffset" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Mapping'fileOffset (\ x__ y__ -> x__ {_Mapping'fileOffset = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Mapping "filenameStrindex" Data.Int.Int32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Mapping'filenameStrindex
           (\ x__ y__ -> x__ {_Mapping'filenameStrindex = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Mapping "attributeIndices" [Data.Int.Int32] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Mapping'attributeIndices
           (\ x__ y__ -> x__ {_Mapping'attributeIndices = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField Mapping "vec'attributeIndices" (Data.Vector.Unboxed.Vector Data.Int.Int32) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Mapping'attributeIndices
           (\ x__ y__ -> x__ {_Mapping'attributeIndices = y__}))
        Prelude.id
instance Data.ProtoLens.Message Mapping where
  messageName _
    = Data.Text.pack
        "opentelemetry.proto.profiles.v1development.Mapping"
  packedMessageDescriptor _
    = "\n\
      \\aMapping\DC2!\n\
      \\fmemory_start\CAN\SOH \SOH(\EOTR\vmemoryStart\DC2!\n\
      \\fmemory_limit\CAN\STX \SOH(\EOTR\vmemoryLimit\DC2\US\n\
      \\vfile_offset\CAN\ETX \SOH(\EOTR\n\
      \fileOffset\DC2+\n\
      \\DC1filename_strindex\CAN\EOT \SOH(\ENQR\DLEfilenameStrindex\DC2+\n\
      \\DC1attribute_indices\CAN\ENQ \ETX(\ENQR\DLEattributeIndices"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        memoryStart__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "memory_start"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"memoryStart")) ::
              Data.ProtoLens.FieldDescriptor Mapping
        memoryLimit__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "memory_limit"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"memoryLimit")) ::
              Data.ProtoLens.FieldDescriptor Mapping
        fileOffset__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "file_offset"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"fileOffset")) ::
              Data.ProtoLens.FieldDescriptor Mapping
        filenameStrindex__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "filename_strindex"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"filenameStrindex")) ::
              Data.ProtoLens.FieldDescriptor Mapping
        attributeIndices__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "attribute_indices"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int32)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Packed
                 (Data.ProtoLens.Field.field @"attributeIndices")) ::
              Data.ProtoLens.FieldDescriptor Mapping
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, memoryStart__field_descriptor),
           (Data.ProtoLens.Tag 2, memoryLimit__field_descriptor),
           (Data.ProtoLens.Tag 3, fileOffset__field_descriptor),
           (Data.ProtoLens.Tag 4, filenameStrindex__field_descriptor),
           (Data.ProtoLens.Tag 5, attributeIndices__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Mapping'_unknownFields
        (\ x__ y__ -> x__ {_Mapping'_unknownFields = y__})
  defMessage
    = Mapping'_constructor
        {_Mapping'memoryStart = Data.ProtoLens.fieldDefault,
         _Mapping'memoryLimit = Data.ProtoLens.fieldDefault,
         _Mapping'fileOffset = Data.ProtoLens.fieldDefault,
         _Mapping'filenameStrindex = Data.ProtoLens.fieldDefault,
         _Mapping'attributeIndices = Data.Vector.Generic.empty,
         _Mapping'_unknownFields = []}
  parseMessage
    = let
        loop ::
          Mapping
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Unboxed.Vector Data.ProtoLens.Encoding.Growing.RealWorld Data.Int.Int32
             -> Data.ProtoLens.Encoding.Bytes.Parser Mapping
        loop x mutable'attributeIndices
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'attributeIndices <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                   (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                      mutable'attributeIndices)
                      (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t)
                           (Lens.Family2.set
                              (Data.ProtoLens.Field.field @"vec'attributeIndices")
                              frozen'attributeIndices x))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        8 -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "memory_start"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"memoryStart") y x)
                                  mutable'attributeIndices
                        16
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "memory_limit"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"memoryLimit") y x)
                                  mutable'attributeIndices
                        24
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "file_offset"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"fileOffset") y x)
                                  mutable'attributeIndices
                        32
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "filename_strindex"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"filenameStrindex") y x)
                                  mutable'attributeIndices
                        40
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (Prelude.fmap
                                           Prelude.fromIntegral
                                           Data.ProtoLens.Encoding.Bytes.getVarInt)
                                        "attribute_indices"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append
                                          mutable'attributeIndices y)
                                loop x v
                        42
                          -> do y <- do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                        Data.ProtoLens.Encoding.Bytes.isolate
                                          (Prelude.fromIntegral len)
                                          ((let
                                              ploop qs
                                                = do packedEnd <- Data.ProtoLens.Encoding.Bytes.atEnd
                                                     if packedEnd then
                                                         Prelude.return qs
                                                     else
                                                         do !q <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                                                    (Prelude.fmap
                                                                       Prelude.fromIntegral
                                                                       Data.ProtoLens.Encoding.Bytes.getVarInt)
                                                                    "attribute_indices"
                                                            qs' <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                                     (Data.ProtoLens.Encoding.Growing.append
                                                                        qs q)
                                                            ploop qs'
                                            in ploop)
                                             mutable'attributeIndices)
                                loop x y
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'attributeIndices
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'attributeIndices <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                            Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'attributeIndices)
          "Mapping"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v
                  = Lens.Family2.view (Data.ProtoLens.Field.field @"memoryStart") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 8)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt _v))
             ((Data.Monoid.<>)
                (let
                   _v
                     = Lens.Family2.view (Data.ProtoLens.Field.field @"memoryLimit") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt _v))
                ((Data.Monoid.<>)
                   (let
                      _v
                        = Lens.Family2.view (Data.ProtoLens.Field.field @"fileOffset") _x
                    in
                      if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                          Data.Monoid.mempty
                      else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 24)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt _v))
                   ((Data.Monoid.<>)
                      (let
                         _v
                           = Lens.Family2.view
                               (Data.ProtoLens.Field.field @"filenameStrindex") _x
                       in
                         if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                             Data.Monoid.mempty
                         else
                             (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt 32)
                               ((Prelude..)
                                  Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                      ((Data.Monoid.<>)
                         (let
                            p = Lens.Family2.view
                                  (Data.ProtoLens.Field.field @"vec'attributeIndices") _x
                          in
                            if Data.Vector.Generic.null p then
                                Data.Monoid.mempty
                            else
                                (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt 42)
                                  ((\ bs
                                      -> (Data.Monoid.<>)
                                           (Data.ProtoLens.Encoding.Bytes.putVarInt
                                              (Prelude.fromIntegral (Data.ByteString.length bs)))
                                           (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                     (Data.ProtoLens.Encoding.Bytes.runBuilder
                                        (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                                           ((Prelude..)
                                              Data.ProtoLens.Encoding.Bytes.putVarInt
                                              Prelude.fromIntegral)
                                           p))))
                         (Data.ProtoLens.Encoding.Wire.buildFieldSet
                            (Lens.Family2.view Data.ProtoLens.unknownFields _x))))))
instance Control.DeepSeq.NFData Mapping where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Mapping'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_Mapping'memoryStart x__)
                (Control.DeepSeq.deepseq
                   (_Mapping'memoryLimit x__)
                   (Control.DeepSeq.deepseq
                      (_Mapping'fileOffset x__)
                      (Control.DeepSeq.deepseq
                         (_Mapping'filenameStrindex x__)
                         (Control.DeepSeq.deepseq (_Mapping'attributeIndices x__) ())))))
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.sampleType' @:: Lens' Profile ValueType@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.maybe'sampleType' @:: Lens' Profile (Prelude.Maybe ValueType)@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.samples' @:: Lens' Profile [Sample]@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.vec'samples' @:: Lens' Profile (Data.Vector.Vector Sample)@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.timeUnixNano' @:: Lens' Profile Data.Word.Word64@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.durationNano' @:: Lens' Profile Data.Word.Word64@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.periodType' @:: Lens' Profile ValueType@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.maybe'periodType' @:: Lens' Profile (Prelude.Maybe ValueType)@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.period' @:: Lens' Profile Data.Int.Int64@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.profileId' @:: Lens' Profile Data.ByteString.ByteString@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.droppedAttributesCount' @:: Lens' Profile Data.Word.Word32@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.originalPayloadFormat' @:: Lens' Profile Data.Text.Text@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.originalPayload' @:: Lens' Profile Data.ByteString.ByteString@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.attributeIndices' @:: Lens' Profile [Data.Int.Int32]@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.vec'attributeIndices' @:: Lens' Profile (Data.Vector.Unboxed.Vector Data.Int.Int32)@ -}
data Profile
  = Profile'_constructor {_Profile'sampleType :: !(Prelude.Maybe ValueType),
                          _Profile'samples :: !(Data.Vector.Vector Sample),
                          _Profile'timeUnixNano :: !Data.Word.Word64,
                          _Profile'durationNano :: !Data.Word.Word64,
                          _Profile'periodType :: !(Prelude.Maybe ValueType),
                          _Profile'period :: !Data.Int.Int64,
                          _Profile'profileId :: !Data.ByteString.ByteString,
                          _Profile'droppedAttributesCount :: !Data.Word.Word32,
                          _Profile'originalPayloadFormat :: !Data.Text.Text,
                          _Profile'originalPayload :: !Data.ByteString.ByteString,
                          _Profile'attributeIndices :: !(Data.Vector.Unboxed.Vector Data.Int.Int32),
                          _Profile'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show Profile where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField Profile "sampleType" ValueType where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Profile'sampleType (\ x__ y__ -> x__ {_Profile'sampleType = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField Profile "maybe'sampleType" (Prelude.Maybe ValueType) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Profile'sampleType (\ x__ y__ -> x__ {_Profile'sampleType = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Profile "samples" [Sample] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Profile'samples (\ x__ y__ -> x__ {_Profile'samples = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField Profile "vec'samples" (Data.Vector.Vector Sample) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Profile'samples (\ x__ y__ -> x__ {_Profile'samples = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Profile "timeUnixNano" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Profile'timeUnixNano
           (\ x__ y__ -> x__ {_Profile'timeUnixNano = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Profile "durationNano" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Profile'durationNano
           (\ x__ y__ -> x__ {_Profile'durationNano = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Profile "periodType" ValueType where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Profile'periodType (\ x__ y__ -> x__ {_Profile'periodType = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField Profile "maybe'periodType" (Prelude.Maybe ValueType) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Profile'periodType (\ x__ y__ -> x__ {_Profile'periodType = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Profile "period" Data.Int.Int64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Profile'period (\ x__ y__ -> x__ {_Profile'period = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Profile "profileId" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Profile'profileId (\ x__ y__ -> x__ {_Profile'profileId = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Profile "droppedAttributesCount" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Profile'droppedAttributesCount
           (\ x__ y__ -> x__ {_Profile'droppedAttributesCount = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Profile "originalPayloadFormat" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Profile'originalPayloadFormat
           (\ x__ y__ -> x__ {_Profile'originalPayloadFormat = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Profile "originalPayload" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Profile'originalPayload
           (\ x__ y__ -> x__ {_Profile'originalPayload = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Profile "attributeIndices" [Data.Int.Int32] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Profile'attributeIndices
           (\ x__ y__ -> x__ {_Profile'attributeIndices = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField Profile "vec'attributeIndices" (Data.Vector.Unboxed.Vector Data.Int.Int32) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Profile'attributeIndices
           (\ x__ y__ -> x__ {_Profile'attributeIndices = y__}))
        Prelude.id
instance Data.ProtoLens.Message Profile where
  messageName _
    = Data.Text.pack
        "opentelemetry.proto.profiles.v1development.Profile"
  packedMessageDescriptor _
    = "\n\
      \\aProfile\DC2V\n\
      \\vsample_type\CAN\SOH \SOH(\v25.opentelemetry.proto.profiles.v1development.ValueTypeR\n\
      \sampleType\DC2L\n\
      \\asamples\CAN\STX \ETX(\v22.opentelemetry.proto.profiles.v1development.SampleR\asamples\DC2$\n\
      \\SOtime_unix_nano\CAN\ETX \SOH(\ACKR\ftimeUnixNano\DC2#\n\
      \\rduration_nano\CAN\EOT \SOH(\EOTR\fdurationNano\DC2V\n\
      \\vperiod_type\CAN\ENQ \SOH(\v25.opentelemetry.proto.profiles.v1development.ValueTypeR\n\
      \periodType\DC2\SYN\n\
      \\ACKperiod\CAN\ACK \SOH(\ETXR\ACKperiod\DC2\GS\n\
      \\n\
      \profile_id\CAN\a \SOH(\fR\tprofileId\DC28\n\
      \\CANdropped_attributes_count\CAN\b \SOH(\rR\SYNdroppedAttributesCount\DC26\n\
      \\ETBoriginal_payload_format\CAN\t \SOH(\tR\NAKoriginalPayloadFormat\DC2)\n\
      \\DLEoriginal_payload\CAN\n\
      \ \SOH(\fR\SIoriginalPayload\DC2+\n\
      \\DC1attribute_indices\CAN\v \ETX(\ENQR\DLEattributeIndices"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        sampleType__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "sample_type"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor ValueType)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'sampleType")) ::
              Data.ProtoLens.FieldDescriptor Profile
        samples__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "samples"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Sample)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked (Data.ProtoLens.Field.field @"samples")) ::
              Data.ProtoLens.FieldDescriptor Profile
        timeUnixNano__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "time_unix_nano"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Fixed64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"timeUnixNano")) ::
              Data.ProtoLens.FieldDescriptor Profile
        durationNano__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "duration_nano"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"durationNano")) ::
              Data.ProtoLens.FieldDescriptor Profile
        periodType__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "period_type"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor ValueType)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'periodType")) ::
              Data.ProtoLens.FieldDescriptor Profile
        period__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "period"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"period")) ::
              Data.ProtoLens.FieldDescriptor Profile
        profileId__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "profile_id"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"profileId")) ::
              Data.ProtoLens.FieldDescriptor Profile
        droppedAttributesCount__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "dropped_attributes_count"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"droppedAttributesCount")) ::
              Data.ProtoLens.FieldDescriptor Profile
        originalPayloadFormat__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "original_payload_format"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"originalPayloadFormat")) ::
              Data.ProtoLens.FieldDescriptor Profile
        originalPayload__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "original_payload"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"originalPayload")) ::
              Data.ProtoLens.FieldDescriptor Profile
        attributeIndices__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "attribute_indices"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int32)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Packed
                 (Data.ProtoLens.Field.field @"attributeIndices")) ::
              Data.ProtoLens.FieldDescriptor Profile
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, sampleType__field_descriptor),
           (Data.ProtoLens.Tag 2, samples__field_descriptor),
           (Data.ProtoLens.Tag 3, timeUnixNano__field_descriptor),
           (Data.ProtoLens.Tag 4, durationNano__field_descriptor),
           (Data.ProtoLens.Tag 5, periodType__field_descriptor),
           (Data.ProtoLens.Tag 6, period__field_descriptor),
           (Data.ProtoLens.Tag 7, profileId__field_descriptor),
           (Data.ProtoLens.Tag 8, droppedAttributesCount__field_descriptor),
           (Data.ProtoLens.Tag 9, originalPayloadFormat__field_descriptor),
           (Data.ProtoLens.Tag 10, originalPayload__field_descriptor),
           (Data.ProtoLens.Tag 11, attributeIndices__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Profile'_unknownFields
        (\ x__ y__ -> x__ {_Profile'_unknownFields = y__})
  defMessage
    = Profile'_constructor
        {_Profile'sampleType = Prelude.Nothing,
         _Profile'samples = Data.Vector.Generic.empty,
         _Profile'timeUnixNano = Data.ProtoLens.fieldDefault,
         _Profile'durationNano = Data.ProtoLens.fieldDefault,
         _Profile'periodType = Prelude.Nothing,
         _Profile'period = Data.ProtoLens.fieldDefault,
         _Profile'profileId = Data.ProtoLens.fieldDefault,
         _Profile'droppedAttributesCount = Data.ProtoLens.fieldDefault,
         _Profile'originalPayloadFormat = Data.ProtoLens.fieldDefault,
         _Profile'originalPayload = Data.ProtoLens.fieldDefault,
         _Profile'attributeIndices = Data.Vector.Generic.empty,
         _Profile'_unknownFields = []}
  parseMessage
    = let
        loop ::
          Profile
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Unboxed.Vector Data.ProtoLens.Encoding.Growing.RealWorld Data.Int.Int32
             -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Sample
                -> Data.ProtoLens.Encoding.Bytes.Parser Profile
        loop x mutable'attributeIndices mutable'samples
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'attributeIndices <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                   (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                      mutable'attributeIndices)
                      frozen'samples <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                          (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                             mutable'samples)
                      (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t)
                           (Lens.Family2.set
                              (Data.ProtoLens.Field.field @"vec'attributeIndices")
                              frozen'attributeIndices
                              (Lens.Family2.set
                                 (Data.ProtoLens.Field.field @"vec'samples") frozen'samples x)))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "sample_type"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"sampleType") y x)
                                  mutable'attributeIndices mutable'samples
                        18
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "samples"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'samples y)
                                loop x mutable'attributeIndices v
                        25
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getFixed64 "time_unix_nano"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"timeUnixNano") y x)
                                  mutable'attributeIndices mutable'samples
                        32
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "duration_nano"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"durationNano") y x)
                                  mutable'attributeIndices mutable'samples
                        42
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "period_type"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"periodType") y x)
                                  mutable'attributeIndices mutable'samples
                        48
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "period"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"period") y x)
                                  mutable'attributeIndices mutable'samples
                        58
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "profile_id"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"profileId") y x)
                                  mutable'attributeIndices mutable'samples
                        64
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "dropped_attributes_count"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"droppedAttributesCount") y x)
                                  mutable'attributeIndices mutable'samples
                        74
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getText
                                             (Prelude.fromIntegral len))
                                       "original_payload_format"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"originalPayloadFormat") y x)
                                  mutable'attributeIndices mutable'samples
                        82
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "original_payload"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"originalPayload") y x)
                                  mutable'attributeIndices mutable'samples
                        88
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (Prelude.fmap
                                           Prelude.fromIntegral
                                           Data.ProtoLens.Encoding.Bytes.getVarInt)
                                        "attribute_indices"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append
                                          mutable'attributeIndices y)
                                loop x v mutable'samples
                        90
                          -> do y <- do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                        Data.ProtoLens.Encoding.Bytes.isolate
                                          (Prelude.fromIntegral len)
                                          ((let
                                              ploop qs
                                                = do packedEnd <- Data.ProtoLens.Encoding.Bytes.atEnd
                                                     if packedEnd then
                                                         Prelude.return qs
                                                     else
                                                         do !q <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                                                    (Prelude.fmap
                                                                       Prelude.fromIntegral
                                                                       Data.ProtoLens.Encoding.Bytes.getVarInt)
                                                                    "attribute_indices"
                                                            qs' <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                                     (Data.ProtoLens.Encoding.Growing.append
                                                                        qs q)
                                                            ploop qs'
                                            in ploop)
                                             mutable'attributeIndices)
                                loop x y mutable'samples
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'attributeIndices mutable'samples
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'attributeIndices <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                            Data.ProtoLens.Encoding.Growing.new
              mutable'samples <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                   Data.ProtoLens.Encoding.Growing.new
              loop
                Data.ProtoLens.defMessage mutable'attributeIndices mutable'samples)
          "Profile"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view
                    (Data.ProtoLens.Field.field @"maybe'sampleType") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just _v)
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage _v))
             ((Data.Monoid.<>)
                (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                   (\ _v
                      -> (Data.Monoid.<>)
                           (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                           ((Prelude..)
                              (\ bs
                                 -> (Data.Monoid.<>)
                                      (Data.ProtoLens.Encoding.Bytes.putVarInt
                                         (Prelude.fromIntegral (Data.ByteString.length bs)))
                                      (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                              Data.ProtoLens.encodeMessage _v))
                   (Lens.Family2.view (Data.ProtoLens.Field.field @"vec'samples") _x))
                ((Data.Monoid.<>)
                   (let
                      _v
                        = Lens.Family2.view (Data.ProtoLens.Field.field @"timeUnixNano") _x
                    in
                      if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                          Data.Monoid.mempty
                      else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 25)
                            (Data.ProtoLens.Encoding.Bytes.putFixed64 _v))
                   ((Data.Monoid.<>)
                      (let
                         _v
                           = Lens.Family2.view (Data.ProtoLens.Field.field @"durationNano") _x
                       in
                         if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                             Data.Monoid.mempty
                         else
                             (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt 32)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt _v))
                      ((Data.Monoid.<>)
                         (case
                              Lens.Family2.view
                                (Data.ProtoLens.Field.field @"maybe'periodType") _x
                          of
                            Prelude.Nothing -> Data.Monoid.mempty
                            (Prelude.Just _v)
                              -> (Data.Monoid.<>)
                                   (Data.ProtoLens.Encoding.Bytes.putVarInt 42)
                                   ((Prelude..)
                                      (\ bs
                                         -> (Data.Monoid.<>)
                                              (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                 (Prelude.fromIntegral (Data.ByteString.length bs)))
                                              (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                      Data.ProtoLens.encodeMessage _v))
                         ((Data.Monoid.<>)
                            (let
                               _v = Lens.Family2.view (Data.ProtoLens.Field.field @"period") _x
                             in
                               if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                   Data.Monoid.mempty
                               else
                                   (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt 48)
                                     ((Prelude..)
                                        Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral
                                        _v))
                            ((Data.Monoid.<>)
                               (let
                                  _v
                                    = Lens.Family2.view (Data.ProtoLens.Field.field @"profileId") _x
                                in
                                  if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                      Data.Monoid.mempty
                                  else
                                      (Data.Monoid.<>)
                                        (Data.ProtoLens.Encoding.Bytes.putVarInt 58)
                                        ((\ bs
                                            -> (Data.Monoid.<>)
                                                 (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                    (Prelude.fromIntegral
                                                       (Data.ByteString.length bs)))
                                                 (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                           _v))
                               ((Data.Monoid.<>)
                                  (let
                                     _v
                                       = Lens.Family2.view
                                           (Data.ProtoLens.Field.field @"droppedAttributesCount") _x
                                   in
                                     if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                         Data.Monoid.mempty
                                     else
                                         (Data.Monoid.<>)
                                           (Data.ProtoLens.Encoding.Bytes.putVarInt 64)
                                           ((Prelude..)
                                              Data.ProtoLens.Encoding.Bytes.putVarInt
                                              Prelude.fromIntegral _v))
                                  ((Data.Monoid.<>)
                                     (let
                                        _v
                                          = Lens.Family2.view
                                              (Data.ProtoLens.Field.field @"originalPayloadFormat")
                                              _x
                                      in
                                        if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                            Data.Monoid.mempty
                                        else
                                            (Data.Monoid.<>)
                                              (Data.ProtoLens.Encoding.Bytes.putVarInt 74)
                                              ((Prelude..)
                                                 (\ bs
                                                    -> (Data.Monoid.<>)
                                                         (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                            (Prelude.fromIntegral
                                                               (Data.ByteString.length bs)))
                                                         (Data.ProtoLens.Encoding.Bytes.putBytes
                                                            bs))
                                                 Data.Text.Encoding.encodeUtf8 _v))
                                     ((Data.Monoid.<>)
                                        (let
                                           _v
                                             = Lens.Family2.view
                                                 (Data.ProtoLens.Field.field @"originalPayload") _x
                                         in
                                           if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                               Data.Monoid.mempty
                                           else
                                               (Data.Monoid.<>)
                                                 (Data.ProtoLens.Encoding.Bytes.putVarInt 82)
                                                 ((\ bs
                                                     -> (Data.Monoid.<>)
                                                          (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                             (Prelude.fromIntegral
                                                                (Data.ByteString.length bs)))
                                                          (Data.ProtoLens.Encoding.Bytes.putBytes
                                                             bs))
                                                    _v))
                                        ((Data.Monoid.<>)
                                           (let
                                              p = Lens.Family2.view
                                                    (Data.ProtoLens.Field.field
                                                       @"vec'attributeIndices")
                                                    _x
                                            in
                                              if Data.Vector.Generic.null p then
                                                  Data.Monoid.mempty
                                              else
                                                  (Data.Monoid.<>)
                                                    (Data.ProtoLens.Encoding.Bytes.putVarInt 90)
                                                    ((\ bs
                                                        -> (Data.Monoid.<>)
                                                             (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                                (Prelude.fromIntegral
                                                                   (Data.ByteString.length bs)))
                                                             (Data.ProtoLens.Encoding.Bytes.putBytes
                                                                bs))
                                                       (Data.ProtoLens.Encoding.Bytes.runBuilder
                                                          (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                                                             ((Prelude..)
                                                                Data.ProtoLens.Encoding.Bytes.putVarInt
                                                                Prelude.fromIntegral)
                                                             p))))
                                           (Data.ProtoLens.Encoding.Wire.buildFieldSet
                                              (Lens.Family2.view
                                                 Data.ProtoLens.unknownFields _x))))))))))))
instance Control.DeepSeq.NFData Profile where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Profile'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_Profile'sampleType x__)
                (Control.DeepSeq.deepseq
                   (_Profile'samples x__)
                   (Control.DeepSeq.deepseq
                      (_Profile'timeUnixNano x__)
                      (Control.DeepSeq.deepseq
                         (_Profile'durationNano x__)
                         (Control.DeepSeq.deepseq
                            (_Profile'periodType x__)
                            (Control.DeepSeq.deepseq
                               (_Profile'period x__)
                               (Control.DeepSeq.deepseq
                                  (_Profile'profileId x__)
                                  (Control.DeepSeq.deepseq
                                     (_Profile'droppedAttributesCount x__)
                                     (Control.DeepSeq.deepseq
                                        (_Profile'originalPayloadFormat x__)
                                        (Control.DeepSeq.deepseq
                                           (_Profile'originalPayload x__)
                                           (Control.DeepSeq.deepseq
                                              (_Profile'attributeIndices x__) ())))))))))))
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.resourceProfiles' @:: Lens' ProfilesData [ResourceProfiles]@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.vec'resourceProfiles' @:: Lens' ProfilesData (Data.Vector.Vector ResourceProfiles)@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.dictionary' @:: Lens' ProfilesData ProfilesDictionary@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.maybe'dictionary' @:: Lens' ProfilesData (Prelude.Maybe ProfilesDictionary)@ -}
data ProfilesData
  = ProfilesData'_constructor {_ProfilesData'resourceProfiles :: !(Data.Vector.Vector ResourceProfiles),
                               _ProfilesData'dictionary :: !(Prelude.Maybe ProfilesDictionary),
                               _ProfilesData'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show ProfilesData where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField ProfilesData "resourceProfiles" [ResourceProfiles] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ProfilesData'resourceProfiles
           (\ x__ y__ -> x__ {_ProfilesData'resourceProfiles = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField ProfilesData "vec'resourceProfiles" (Data.Vector.Vector ResourceProfiles) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ProfilesData'resourceProfiles
           (\ x__ y__ -> x__ {_ProfilesData'resourceProfiles = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ProfilesData "dictionary" ProfilesDictionary where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ProfilesData'dictionary
           (\ x__ y__ -> x__ {_ProfilesData'dictionary = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField ProfilesData "maybe'dictionary" (Prelude.Maybe ProfilesDictionary) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ProfilesData'dictionary
           (\ x__ y__ -> x__ {_ProfilesData'dictionary = y__}))
        Prelude.id
instance Data.ProtoLens.Message ProfilesData where
  messageName _
    = Data.Text.pack
        "opentelemetry.proto.profiles.v1development.ProfilesData"
  packedMessageDescriptor _
    = "\n\
      \\fProfilesData\DC2i\n\
      \\DC1resource_profiles\CAN\SOH \ETX(\v2<.opentelemetry.proto.profiles.v1development.ResourceProfilesR\DLEresourceProfiles\DC2^\n\
      \\n\
      \dictionary\CAN\STX \SOH(\v2>.opentelemetry.proto.profiles.v1development.ProfilesDictionaryR\n\
      \dictionary"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        resourceProfiles__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "resource_profiles"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor ResourceProfiles)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"resourceProfiles")) ::
              Data.ProtoLens.FieldDescriptor ProfilesData
        dictionary__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "dictionary"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor ProfilesDictionary)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'dictionary")) ::
              Data.ProtoLens.FieldDescriptor ProfilesData
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, resourceProfiles__field_descriptor),
           (Data.ProtoLens.Tag 2, dictionary__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _ProfilesData'_unknownFields
        (\ x__ y__ -> x__ {_ProfilesData'_unknownFields = y__})
  defMessage
    = ProfilesData'_constructor
        {_ProfilesData'resourceProfiles = Data.Vector.Generic.empty,
         _ProfilesData'dictionary = Prelude.Nothing,
         _ProfilesData'_unknownFields = []}
  parseMessage
    = let
        loop ::
          ProfilesData
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld ResourceProfiles
             -> Data.ProtoLens.Encoding.Bytes.Parser ProfilesData
        loop x mutable'resourceProfiles
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'resourceProfiles <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                   (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                      mutable'resourceProfiles)
                      (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t)
                           (Lens.Family2.set
                              (Data.ProtoLens.Field.field @"vec'resourceProfiles")
                              frozen'resourceProfiles x))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "resource_profiles"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append
                                          mutable'resourceProfiles y)
                                loop x v
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "dictionary"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"dictionary") y x)
                                  mutable'resourceProfiles
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'resourceProfiles
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'resourceProfiles <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                            Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'resourceProfiles)
          "ProfilesData"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                (\ _v
                   -> (Data.Monoid.<>)
                        (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                        ((Prelude..)
                           (\ bs
                              -> (Data.Monoid.<>)
                                   (Data.ProtoLens.Encoding.Bytes.putVarInt
                                      (Prelude.fromIntegral (Data.ByteString.length bs)))
                                   (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                           Data.ProtoLens.encodeMessage _v))
                (Lens.Family2.view
                   (Data.ProtoLens.Field.field @"vec'resourceProfiles") _x))
             ((Data.Monoid.<>)
                (case
                     Lens.Family2.view
                       (Data.ProtoLens.Field.field @"maybe'dictionary") _x
                 of
                   Prelude.Nothing -> Data.Monoid.mempty
                   (Prelude.Just _v)
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage _v))
                (Data.ProtoLens.Encoding.Wire.buildFieldSet
                   (Lens.Family2.view Data.ProtoLens.unknownFields _x)))
instance Control.DeepSeq.NFData ProfilesData where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_ProfilesData'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_ProfilesData'resourceProfiles x__)
                (Control.DeepSeq.deepseq (_ProfilesData'dictionary x__) ()))
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.mappingTable' @:: Lens' ProfilesDictionary [Mapping]@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.vec'mappingTable' @:: Lens' ProfilesDictionary (Data.Vector.Vector Mapping)@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.locationTable' @:: Lens' ProfilesDictionary [Location]@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.vec'locationTable' @:: Lens' ProfilesDictionary (Data.Vector.Vector Location)@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.functionTable' @:: Lens' ProfilesDictionary [Function]@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.vec'functionTable' @:: Lens' ProfilesDictionary (Data.Vector.Vector Function)@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.linkTable' @:: Lens' ProfilesDictionary [Link]@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.vec'linkTable' @:: Lens' ProfilesDictionary (Data.Vector.Vector Link)@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.stringTable' @:: Lens' ProfilesDictionary [Data.Text.Text]@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.vec'stringTable' @:: Lens' ProfilesDictionary (Data.Vector.Vector Data.Text.Text)@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.attributeTable' @:: Lens' ProfilesDictionary [KeyValueAndUnit]@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.vec'attributeTable' @:: Lens' ProfilesDictionary (Data.Vector.Vector KeyValueAndUnit)@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.stackTable' @:: Lens' ProfilesDictionary [Stack]@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.vec'stackTable' @:: Lens' ProfilesDictionary (Data.Vector.Vector Stack)@ -}
data ProfilesDictionary
  = ProfilesDictionary'_constructor {_ProfilesDictionary'mappingTable :: !(Data.Vector.Vector Mapping),
                                     _ProfilesDictionary'locationTable :: !(Data.Vector.Vector Location),
                                     _ProfilesDictionary'functionTable :: !(Data.Vector.Vector Function),
                                     _ProfilesDictionary'linkTable :: !(Data.Vector.Vector Link),
                                     _ProfilesDictionary'stringTable :: !(Data.Vector.Vector Data.Text.Text),
                                     _ProfilesDictionary'attributeTable :: !(Data.Vector.Vector KeyValueAndUnit),
                                     _ProfilesDictionary'stackTable :: !(Data.Vector.Vector Stack),
                                     _ProfilesDictionary'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show ProfilesDictionary where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField ProfilesDictionary "mappingTable" [Mapping] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ProfilesDictionary'mappingTable
           (\ x__ y__ -> x__ {_ProfilesDictionary'mappingTable = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField ProfilesDictionary "vec'mappingTable" (Data.Vector.Vector Mapping) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ProfilesDictionary'mappingTable
           (\ x__ y__ -> x__ {_ProfilesDictionary'mappingTable = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ProfilesDictionary "locationTable" [Location] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ProfilesDictionary'locationTable
           (\ x__ y__ -> x__ {_ProfilesDictionary'locationTable = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField ProfilesDictionary "vec'locationTable" (Data.Vector.Vector Location) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ProfilesDictionary'locationTable
           (\ x__ y__ -> x__ {_ProfilesDictionary'locationTable = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ProfilesDictionary "functionTable" [Function] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ProfilesDictionary'functionTable
           (\ x__ y__ -> x__ {_ProfilesDictionary'functionTable = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField ProfilesDictionary "vec'functionTable" (Data.Vector.Vector Function) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ProfilesDictionary'functionTable
           (\ x__ y__ -> x__ {_ProfilesDictionary'functionTable = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ProfilesDictionary "linkTable" [Link] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ProfilesDictionary'linkTable
           (\ x__ y__ -> x__ {_ProfilesDictionary'linkTable = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField ProfilesDictionary "vec'linkTable" (Data.Vector.Vector Link) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ProfilesDictionary'linkTable
           (\ x__ y__ -> x__ {_ProfilesDictionary'linkTable = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ProfilesDictionary "stringTable" [Data.Text.Text] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ProfilesDictionary'stringTable
           (\ x__ y__ -> x__ {_ProfilesDictionary'stringTable = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField ProfilesDictionary "vec'stringTable" (Data.Vector.Vector Data.Text.Text) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ProfilesDictionary'stringTable
           (\ x__ y__ -> x__ {_ProfilesDictionary'stringTable = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ProfilesDictionary "attributeTable" [KeyValueAndUnit] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ProfilesDictionary'attributeTable
           (\ x__ y__ -> x__ {_ProfilesDictionary'attributeTable = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField ProfilesDictionary "vec'attributeTable" (Data.Vector.Vector KeyValueAndUnit) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ProfilesDictionary'attributeTable
           (\ x__ y__ -> x__ {_ProfilesDictionary'attributeTable = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ProfilesDictionary "stackTable" [Stack] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ProfilesDictionary'stackTable
           (\ x__ y__ -> x__ {_ProfilesDictionary'stackTable = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField ProfilesDictionary "vec'stackTable" (Data.Vector.Vector Stack) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ProfilesDictionary'stackTable
           (\ x__ y__ -> x__ {_ProfilesDictionary'stackTable = y__}))
        Prelude.id
instance Data.ProtoLens.Message ProfilesDictionary where
  messageName _
    = Data.Text.pack
        "opentelemetry.proto.profiles.v1development.ProfilesDictionary"
  packedMessageDescriptor _
    = "\n\
      \\DC2ProfilesDictionary\DC2X\n\
      \\rmapping_table\CAN\SOH \ETX(\v23.opentelemetry.proto.profiles.v1development.MappingR\fmappingTable\DC2[\n\
      \\SOlocation_table\CAN\STX \ETX(\v24.opentelemetry.proto.profiles.v1development.LocationR\rlocationTable\DC2[\n\
      \\SOfunction_table\CAN\ETX \ETX(\v24.opentelemetry.proto.profiles.v1development.FunctionR\rfunctionTable\DC2O\n\
      \\n\
      \link_table\CAN\EOT \ETX(\v20.opentelemetry.proto.profiles.v1development.LinkR\tlinkTable\DC2!\n\
      \\fstring_table\CAN\ENQ \ETX(\tR\vstringTable\DC2d\n\
      \\SIattribute_table\CAN\ACK \ETX(\v2;.opentelemetry.proto.profiles.v1development.KeyValueAndUnitR\SOattributeTable\DC2R\n\
      \\vstack_table\CAN\a \ETX(\v21.opentelemetry.proto.profiles.v1development.StackR\n\
      \stackTable"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        mappingTable__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "mapping_table"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Mapping)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"mappingTable")) ::
              Data.ProtoLens.FieldDescriptor ProfilesDictionary
        locationTable__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "location_table"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Location)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"locationTable")) ::
              Data.ProtoLens.FieldDescriptor ProfilesDictionary
        functionTable__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "function_table"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Function)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"functionTable")) ::
              Data.ProtoLens.FieldDescriptor ProfilesDictionary
        linkTable__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "link_table"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Link)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"linkTable")) ::
              Data.ProtoLens.FieldDescriptor ProfilesDictionary
        stringTable__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "string_table"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"stringTable")) ::
              Data.ProtoLens.FieldDescriptor ProfilesDictionary
        attributeTable__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "attribute_table"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor KeyValueAndUnit)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"attributeTable")) ::
              Data.ProtoLens.FieldDescriptor ProfilesDictionary
        stackTable__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "stack_table"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Stack)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"stackTable")) ::
              Data.ProtoLens.FieldDescriptor ProfilesDictionary
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, mappingTable__field_descriptor),
           (Data.ProtoLens.Tag 2, locationTable__field_descriptor),
           (Data.ProtoLens.Tag 3, functionTable__field_descriptor),
           (Data.ProtoLens.Tag 4, linkTable__field_descriptor),
           (Data.ProtoLens.Tag 5, stringTable__field_descriptor),
           (Data.ProtoLens.Tag 6, attributeTable__field_descriptor),
           (Data.ProtoLens.Tag 7, stackTable__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _ProfilesDictionary'_unknownFields
        (\ x__ y__ -> x__ {_ProfilesDictionary'_unknownFields = y__})
  defMessage
    = ProfilesDictionary'_constructor
        {_ProfilesDictionary'mappingTable = Data.Vector.Generic.empty,
         _ProfilesDictionary'locationTable = Data.Vector.Generic.empty,
         _ProfilesDictionary'functionTable = Data.Vector.Generic.empty,
         _ProfilesDictionary'linkTable = Data.Vector.Generic.empty,
         _ProfilesDictionary'stringTable = Data.Vector.Generic.empty,
         _ProfilesDictionary'attributeTable = Data.Vector.Generic.empty,
         _ProfilesDictionary'stackTable = Data.Vector.Generic.empty,
         _ProfilesDictionary'_unknownFields = []}
  parseMessage
    = let
        loop ::
          ProfilesDictionary
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld KeyValueAndUnit
             -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Function
                -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Link
                   -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Location
                      -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Mapping
                         -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Stack
                            -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Data.Text.Text
                               -> Data.ProtoLens.Encoding.Bytes.Parser ProfilesDictionary
        loop
          x
          mutable'attributeTable
          mutable'functionTable
          mutable'linkTable
          mutable'locationTable
          mutable'mappingTable
          mutable'stackTable
          mutable'stringTable
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'attributeTable <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                 (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                    mutable'attributeTable)
                      frozen'functionTable <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                   mutable'functionTable)
                      frozen'linkTable <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                            (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                               mutable'linkTable)
                      frozen'locationTable <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                   mutable'locationTable)
                      frozen'mappingTable <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                               (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                  mutable'mappingTable)
                      frozen'stackTable <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                             (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                mutable'stackTable)
                      frozen'stringTable <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                              (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                 mutable'stringTable)
                      (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t)
                           (Lens.Family2.set
                              (Data.ProtoLens.Field.field @"vec'attributeTable")
                              frozen'attributeTable
                              (Lens.Family2.set
                                 (Data.ProtoLens.Field.field @"vec'functionTable")
                                 frozen'functionTable
                                 (Lens.Family2.set
                                    (Data.ProtoLens.Field.field @"vec'linkTable") frozen'linkTable
                                    (Lens.Family2.set
                                       (Data.ProtoLens.Field.field @"vec'locationTable")
                                       frozen'locationTable
                                       (Lens.Family2.set
                                          (Data.ProtoLens.Field.field @"vec'mappingTable")
                                          frozen'mappingTable
                                          (Lens.Family2.set
                                             (Data.ProtoLens.Field.field @"vec'stackTable")
                                             frozen'stackTable
                                             (Lens.Family2.set
                                                (Data.ProtoLens.Field.field @"vec'stringTable")
                                                frozen'stringTable x))))))))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "mapping_table"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append
                                          mutable'mappingTable y)
                                loop
                                  x mutable'attributeTable mutable'functionTable mutable'linkTable
                                  mutable'locationTable v mutable'stackTable mutable'stringTable
                        18
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "location_table"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append
                                          mutable'locationTable y)
                                loop
                                  x mutable'attributeTable mutable'functionTable mutable'linkTable v
                                  mutable'mappingTable mutable'stackTable mutable'stringTable
                        26
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "function_table"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append
                                          mutable'functionTable y)
                                loop
                                  x mutable'attributeTable v mutable'linkTable mutable'locationTable
                                  mutable'mappingTable mutable'stackTable mutable'stringTable
                        34
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "link_table"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'linkTable y)
                                loop
                                  x mutable'attributeTable mutable'functionTable v
                                  mutable'locationTable mutable'mappingTable mutable'stackTable
                                  mutable'stringTable
                        42
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.getText
                                              (Prelude.fromIntegral len))
                                        "string_table"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append
                                          mutable'stringTable y)
                                loop
                                  x mutable'attributeTable mutable'functionTable mutable'linkTable
                                  mutable'locationTable mutable'mappingTable mutable'stackTable v
                        50
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "attribute_table"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append
                                          mutable'attributeTable y)
                                loop
                                  x v mutable'functionTable mutable'linkTable mutable'locationTable
                                  mutable'mappingTable mutable'stackTable mutable'stringTable
                        58
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "stack_table"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'stackTable y)
                                loop
                                  x mutable'attributeTable mutable'functionTable mutable'linkTable
                                  mutable'locationTable mutable'mappingTable v mutable'stringTable
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'attributeTable mutable'functionTable mutable'linkTable
                                  mutable'locationTable mutable'mappingTable mutable'stackTable
                                  mutable'stringTable
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'attributeTable <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                          Data.ProtoLens.Encoding.Growing.new
              mutable'functionTable <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                         Data.ProtoLens.Encoding.Growing.new
              mutable'linkTable <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                     Data.ProtoLens.Encoding.Growing.new
              mutable'locationTable <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                         Data.ProtoLens.Encoding.Growing.new
              mutable'mappingTable <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                        Data.ProtoLens.Encoding.Growing.new
              mutable'stackTable <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                      Data.ProtoLens.Encoding.Growing.new
              mutable'stringTable <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       Data.ProtoLens.Encoding.Growing.new
              loop
                Data.ProtoLens.defMessage mutable'attributeTable
                mutable'functionTable mutable'linkTable mutable'locationTable
                mutable'mappingTable mutable'stackTable mutable'stringTable)
          "ProfilesDictionary"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                (\ _v
                   -> (Data.Monoid.<>)
                        (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                        ((Prelude..)
                           (\ bs
                              -> (Data.Monoid.<>)
                                   (Data.ProtoLens.Encoding.Bytes.putVarInt
                                      (Prelude.fromIntegral (Data.ByteString.length bs)))
                                   (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                           Data.ProtoLens.encodeMessage _v))
                (Lens.Family2.view
                   (Data.ProtoLens.Field.field @"vec'mappingTable") _x))
             ((Data.Monoid.<>)
                (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                   (\ _v
                      -> (Data.Monoid.<>)
                           (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                           ((Prelude..)
                              (\ bs
                                 -> (Data.Monoid.<>)
                                      (Data.ProtoLens.Encoding.Bytes.putVarInt
                                         (Prelude.fromIntegral (Data.ByteString.length bs)))
                                      (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                              Data.ProtoLens.encodeMessage _v))
                   (Lens.Family2.view
                      (Data.ProtoLens.Field.field @"vec'locationTable") _x))
                ((Data.Monoid.<>)
                   (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                      (\ _v
                         -> (Data.Monoid.<>)
                              (Data.ProtoLens.Encoding.Bytes.putVarInt 26)
                              ((Prelude..)
                                 (\ bs
                                    -> (Data.Monoid.<>)
                                         (Data.ProtoLens.Encoding.Bytes.putVarInt
                                            (Prelude.fromIntegral (Data.ByteString.length bs)))
                                         (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                 Data.ProtoLens.encodeMessage _v))
                      (Lens.Family2.view
                         (Data.ProtoLens.Field.field @"vec'functionTable") _x))
                   ((Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                         (\ _v
                            -> (Data.Monoid.<>)
                                 (Data.ProtoLens.Encoding.Bytes.putVarInt 34)
                                 ((Prelude..)
                                    (\ bs
                                       -> (Data.Monoid.<>)
                                            (Data.ProtoLens.Encoding.Bytes.putVarInt
                                               (Prelude.fromIntegral (Data.ByteString.length bs)))
                                            (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                    Data.ProtoLens.encodeMessage _v))
                         (Lens.Family2.view
                            (Data.ProtoLens.Field.field @"vec'linkTable") _x))
                      ((Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                            (\ _v
                               -> (Data.Monoid.<>)
                                    (Data.ProtoLens.Encoding.Bytes.putVarInt 42)
                                    ((Prelude..)
                                       (\ bs
                                          -> (Data.Monoid.<>)
                                               (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                  (Prelude.fromIntegral
                                                     (Data.ByteString.length bs)))
                                               (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                       Data.Text.Encoding.encodeUtf8 _v))
                            (Lens.Family2.view
                               (Data.ProtoLens.Field.field @"vec'stringTable") _x))
                         ((Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                               (\ _v
                                  -> (Data.Monoid.<>)
                                       (Data.ProtoLens.Encoding.Bytes.putVarInt 50)
                                       ((Prelude..)
                                          (\ bs
                                             -> (Data.Monoid.<>)
                                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                     (Prelude.fromIntegral
                                                        (Data.ByteString.length bs)))
                                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                          Data.ProtoLens.encodeMessage _v))
                               (Lens.Family2.view
                                  (Data.ProtoLens.Field.field @"vec'attributeTable") _x))
                            ((Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                                  (\ _v
                                     -> (Data.Monoid.<>)
                                          (Data.ProtoLens.Encoding.Bytes.putVarInt 58)
                                          ((Prelude..)
                                             (\ bs
                                                -> (Data.Monoid.<>)
                                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                        (Prelude.fromIntegral
                                                           (Data.ByteString.length bs)))
                                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                             Data.ProtoLens.encodeMessage _v))
                                  (Lens.Family2.view
                                     (Data.ProtoLens.Field.field @"vec'stackTable") _x))
                               (Data.ProtoLens.Encoding.Wire.buildFieldSet
                                  (Lens.Family2.view Data.ProtoLens.unknownFields _x))))))))
instance Control.DeepSeq.NFData ProfilesDictionary where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_ProfilesDictionary'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_ProfilesDictionary'mappingTable x__)
                (Control.DeepSeq.deepseq
                   (_ProfilesDictionary'locationTable x__)
                   (Control.DeepSeq.deepseq
                      (_ProfilesDictionary'functionTable x__)
                      (Control.DeepSeq.deepseq
                         (_ProfilesDictionary'linkTable x__)
                         (Control.DeepSeq.deepseq
                            (_ProfilesDictionary'stringTable x__)
                            (Control.DeepSeq.deepseq
                               (_ProfilesDictionary'attributeTable x__)
                               (Control.DeepSeq.deepseq
                                  (_ProfilesDictionary'stackTable x__) ())))))))
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.resource' @:: Lens' ResourceProfiles Proto.Opentelemetry.Proto.Resource.V1.Resource.Resource@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.maybe'resource' @:: Lens' ResourceProfiles (Prelude.Maybe Proto.Opentelemetry.Proto.Resource.V1.Resource.Resource)@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.scopeProfiles' @:: Lens' ResourceProfiles [ScopeProfiles]@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.vec'scopeProfiles' @:: Lens' ResourceProfiles (Data.Vector.Vector ScopeProfiles)@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.schemaUrl' @:: Lens' ResourceProfiles Data.Text.Text@ -}
data ResourceProfiles
  = ResourceProfiles'_constructor {_ResourceProfiles'resource :: !(Prelude.Maybe Proto.Opentelemetry.Proto.Resource.V1.Resource.Resource),
                                   _ResourceProfiles'scopeProfiles :: !(Data.Vector.Vector ScopeProfiles),
                                   _ResourceProfiles'schemaUrl :: !Data.Text.Text,
                                   _ResourceProfiles'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show ResourceProfiles where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField ResourceProfiles "resource" Proto.Opentelemetry.Proto.Resource.V1.Resource.Resource where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ResourceProfiles'resource
           (\ x__ y__ -> x__ {_ResourceProfiles'resource = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField ResourceProfiles "maybe'resource" (Prelude.Maybe Proto.Opentelemetry.Proto.Resource.V1.Resource.Resource) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ResourceProfiles'resource
           (\ x__ y__ -> x__ {_ResourceProfiles'resource = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ResourceProfiles "scopeProfiles" [ScopeProfiles] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ResourceProfiles'scopeProfiles
           (\ x__ y__ -> x__ {_ResourceProfiles'scopeProfiles = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField ResourceProfiles "vec'scopeProfiles" (Data.Vector.Vector ScopeProfiles) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ResourceProfiles'scopeProfiles
           (\ x__ y__ -> x__ {_ResourceProfiles'scopeProfiles = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ResourceProfiles "schemaUrl" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ResourceProfiles'schemaUrl
           (\ x__ y__ -> x__ {_ResourceProfiles'schemaUrl = y__}))
        Prelude.id
instance Data.ProtoLens.Message ResourceProfiles where
  messageName _
    = Data.Text.pack
        "opentelemetry.proto.profiles.v1development.ResourceProfiles"
  packedMessageDescriptor _
    = "\n\
      \\DLEResourceProfiles\DC2E\n\
      \\bresource\CAN\SOH \SOH(\v2).opentelemetry.proto.resource.v1.ResourceR\bresource\DC2`\n\
      \\SOscope_profiles\CAN\STX \ETX(\v29.opentelemetry.proto.profiles.v1development.ScopeProfilesR\rscopeProfiles\DC2\GS\n\
      \\n\
      \schema_url\CAN\ETX \SOH(\tR\tschemaUrlJ\ACK\b\232\a\DLE\233\a"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        resource__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "resource"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Opentelemetry.Proto.Resource.V1.Resource.Resource)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'resource")) ::
              Data.ProtoLens.FieldDescriptor ResourceProfiles
        scopeProfiles__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "scope_profiles"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor ScopeProfiles)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"scopeProfiles")) ::
              Data.ProtoLens.FieldDescriptor ResourceProfiles
        schemaUrl__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "schema_url"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"schemaUrl")) ::
              Data.ProtoLens.FieldDescriptor ResourceProfiles
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, resource__field_descriptor),
           (Data.ProtoLens.Tag 2, scopeProfiles__field_descriptor),
           (Data.ProtoLens.Tag 3, schemaUrl__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _ResourceProfiles'_unknownFields
        (\ x__ y__ -> x__ {_ResourceProfiles'_unknownFields = y__})
  defMessage
    = ResourceProfiles'_constructor
        {_ResourceProfiles'resource = Prelude.Nothing,
         _ResourceProfiles'scopeProfiles = Data.Vector.Generic.empty,
         _ResourceProfiles'schemaUrl = Data.ProtoLens.fieldDefault,
         _ResourceProfiles'_unknownFields = []}
  parseMessage
    = let
        loop ::
          ResourceProfiles
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld ScopeProfiles
             -> Data.ProtoLens.Encoding.Bytes.Parser ResourceProfiles
        loop x mutable'scopeProfiles
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'scopeProfiles <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                   mutable'scopeProfiles)
                      (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t)
                           (Lens.Family2.set
                              (Data.ProtoLens.Field.field @"vec'scopeProfiles")
                              frozen'scopeProfiles x))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "resource"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"resource") y x)
                                  mutable'scopeProfiles
                        18
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "scope_profiles"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append
                                          mutable'scopeProfiles y)
                                loop x v
                        26
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getText
                                             (Prelude.fromIntegral len))
                                       "schema_url"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"schemaUrl") y x)
                                  mutable'scopeProfiles
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'scopeProfiles
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'scopeProfiles <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                         Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'scopeProfiles)
          "ResourceProfiles"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'resource") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just _v)
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage _v))
             ((Data.Monoid.<>)
                (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                   (\ _v
                      -> (Data.Monoid.<>)
                           (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                           ((Prelude..)
                              (\ bs
                                 -> (Data.Monoid.<>)
                                      (Data.ProtoLens.Encoding.Bytes.putVarInt
                                         (Prelude.fromIntegral (Data.ByteString.length bs)))
                                      (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                              Data.ProtoLens.encodeMessage _v))
                   (Lens.Family2.view
                      (Data.ProtoLens.Field.field @"vec'scopeProfiles") _x))
                ((Data.Monoid.<>)
                   (let
                      _v = Lens.Family2.view (Data.ProtoLens.Field.field @"schemaUrl") _x
                    in
                      if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                          Data.Monoid.mempty
                      else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 26)
                            ((Prelude..)
                               (\ bs
                                  -> (Data.Monoid.<>)
                                       (Data.ProtoLens.Encoding.Bytes.putVarInt
                                          (Prelude.fromIntegral (Data.ByteString.length bs)))
                                       (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                               Data.Text.Encoding.encodeUtf8 _v))
                   (Data.ProtoLens.Encoding.Wire.buildFieldSet
                      (Lens.Family2.view Data.ProtoLens.unknownFields _x))))
instance Control.DeepSeq.NFData ResourceProfiles where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_ResourceProfiles'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_ResourceProfiles'resource x__)
                (Control.DeepSeq.deepseq
                   (_ResourceProfiles'scopeProfiles x__)
                   (Control.DeepSeq.deepseq (_ResourceProfiles'schemaUrl x__) ())))
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.stackIndex' @:: Lens' Sample Data.Int.Int32@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.values' @:: Lens' Sample [Data.Int.Int64]@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.vec'values' @:: Lens' Sample (Data.Vector.Unboxed.Vector Data.Int.Int64)@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.attributeIndices' @:: Lens' Sample [Data.Int.Int32]@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.vec'attributeIndices' @:: Lens' Sample (Data.Vector.Unboxed.Vector Data.Int.Int32)@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.linkIndex' @:: Lens' Sample Data.Int.Int32@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.timestampsUnixNano' @:: Lens' Sample [Data.Word.Word64]@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.vec'timestampsUnixNano' @:: Lens' Sample (Data.Vector.Unboxed.Vector Data.Word.Word64)@ -}
data Sample
  = Sample'_constructor {_Sample'stackIndex :: !Data.Int.Int32,
                         _Sample'values :: !(Data.Vector.Unboxed.Vector Data.Int.Int64),
                         _Sample'attributeIndices :: !(Data.Vector.Unboxed.Vector Data.Int.Int32),
                         _Sample'linkIndex :: !Data.Int.Int32,
                         _Sample'timestampsUnixNano :: !(Data.Vector.Unboxed.Vector Data.Word.Word64),
                         _Sample'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show Sample where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField Sample "stackIndex" Data.Int.Int32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Sample'stackIndex (\ x__ y__ -> x__ {_Sample'stackIndex = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Sample "values" [Data.Int.Int64] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Sample'values (\ x__ y__ -> x__ {_Sample'values = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField Sample "vec'values" (Data.Vector.Unboxed.Vector Data.Int.Int64) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Sample'values (\ x__ y__ -> x__ {_Sample'values = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Sample "attributeIndices" [Data.Int.Int32] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Sample'attributeIndices
           (\ x__ y__ -> x__ {_Sample'attributeIndices = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField Sample "vec'attributeIndices" (Data.Vector.Unboxed.Vector Data.Int.Int32) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Sample'attributeIndices
           (\ x__ y__ -> x__ {_Sample'attributeIndices = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Sample "linkIndex" Data.Int.Int32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Sample'linkIndex (\ x__ y__ -> x__ {_Sample'linkIndex = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Sample "timestampsUnixNano" [Data.Word.Word64] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Sample'timestampsUnixNano
           (\ x__ y__ -> x__ {_Sample'timestampsUnixNano = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField Sample "vec'timestampsUnixNano" (Data.Vector.Unboxed.Vector Data.Word.Word64) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Sample'timestampsUnixNano
           (\ x__ y__ -> x__ {_Sample'timestampsUnixNano = y__}))
        Prelude.id
instance Data.ProtoLens.Message Sample where
  messageName _
    = Data.Text.pack
        "opentelemetry.proto.profiles.v1development.Sample"
  packedMessageDescriptor _
    = "\n\
      \\ACKSample\DC2\US\n\
      \\vstack_index\CAN\SOH \SOH(\ENQR\n\
      \stackIndex\DC2\SYN\n\
      \\ACKvalues\CAN\STX \ETX(\ETXR\ACKvalues\DC2+\n\
      \\DC1attribute_indices\CAN\ETX \ETX(\ENQR\DLEattributeIndices\DC2\GS\n\
      \\n\
      \link_index\CAN\EOT \SOH(\ENQR\tlinkIndex\DC20\n\
      \\DC4timestamps_unix_nano\CAN\ENQ \ETX(\ACKR\DC2timestampsUnixNano"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        stackIndex__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "stack_index"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"stackIndex")) ::
              Data.ProtoLens.FieldDescriptor Sample
        values__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "values"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int64)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Packed (Data.ProtoLens.Field.field @"values")) ::
              Data.ProtoLens.FieldDescriptor Sample
        attributeIndices__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "attribute_indices"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int32)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Packed
                 (Data.ProtoLens.Field.field @"attributeIndices")) ::
              Data.ProtoLens.FieldDescriptor Sample
        linkIndex__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "link_index"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"linkIndex")) ::
              Data.ProtoLens.FieldDescriptor Sample
        timestampsUnixNano__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "timestamps_unix_nano"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Fixed64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Packed
                 (Data.ProtoLens.Field.field @"timestampsUnixNano")) ::
              Data.ProtoLens.FieldDescriptor Sample
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, stackIndex__field_descriptor),
           (Data.ProtoLens.Tag 2, values__field_descriptor),
           (Data.ProtoLens.Tag 3, attributeIndices__field_descriptor),
           (Data.ProtoLens.Tag 4, linkIndex__field_descriptor),
           (Data.ProtoLens.Tag 5, timestampsUnixNano__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Sample'_unknownFields
        (\ x__ y__ -> x__ {_Sample'_unknownFields = y__})
  defMessage
    = Sample'_constructor
        {_Sample'stackIndex = Data.ProtoLens.fieldDefault,
         _Sample'values = Data.Vector.Generic.empty,
         _Sample'attributeIndices = Data.Vector.Generic.empty,
         _Sample'linkIndex = Data.ProtoLens.fieldDefault,
         _Sample'timestampsUnixNano = Data.Vector.Generic.empty,
         _Sample'_unknownFields = []}
  parseMessage
    = let
        loop ::
          Sample
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Unboxed.Vector Data.ProtoLens.Encoding.Growing.RealWorld Data.Int.Int32
             -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Unboxed.Vector Data.ProtoLens.Encoding.Growing.RealWorld Data.Word.Word64
                -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Unboxed.Vector Data.ProtoLens.Encoding.Growing.RealWorld Data.Int.Int64
                   -> Data.ProtoLens.Encoding.Bytes.Parser Sample
        loop
          x
          mutable'attributeIndices
          mutable'timestampsUnixNano
          mutable'values
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'attributeIndices <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                   (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                      mutable'attributeIndices)
                      frozen'timestampsUnixNano <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                     (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                        mutable'timestampsUnixNano)
                      frozen'values <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                         (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                            mutable'values)
                      (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t)
                           (Lens.Family2.set
                              (Data.ProtoLens.Field.field @"vec'attributeIndices")
                              frozen'attributeIndices
                              (Lens.Family2.set
                                 (Data.ProtoLens.Field.field @"vec'timestampsUnixNano")
                                 frozen'timestampsUnixNano
                                 (Lens.Family2.set
                                    (Data.ProtoLens.Field.field @"vec'values") frozen'values x))))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        8 -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "stack_index"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"stackIndex") y x)
                                  mutable'attributeIndices mutable'timestampsUnixNano mutable'values
                        16
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (Prelude.fmap
                                           Prelude.fromIntegral
                                           Data.ProtoLens.Encoding.Bytes.getVarInt)
                                        "values"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'values y)
                                loop x mutable'attributeIndices mutable'timestampsUnixNano v
                        18
                          -> do y <- do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                        Data.ProtoLens.Encoding.Bytes.isolate
                                          (Prelude.fromIntegral len)
                                          ((let
                                              ploop qs
                                                = do packedEnd <- Data.ProtoLens.Encoding.Bytes.atEnd
                                                     if packedEnd then
                                                         Prelude.return qs
                                                     else
                                                         do !q <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                                                    (Prelude.fmap
                                                                       Prelude.fromIntegral
                                                                       Data.ProtoLens.Encoding.Bytes.getVarInt)
                                                                    "values"
                                                            qs' <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                                     (Data.ProtoLens.Encoding.Growing.append
                                                                        qs q)
                                                            ploop qs'
                                            in ploop)
                                             mutable'values)
                                loop x mutable'attributeIndices mutable'timestampsUnixNano y
                        24
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (Prelude.fmap
                                           Prelude.fromIntegral
                                           Data.ProtoLens.Encoding.Bytes.getVarInt)
                                        "attribute_indices"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append
                                          mutable'attributeIndices y)
                                loop x v mutable'timestampsUnixNano mutable'values
                        26
                          -> do y <- do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                        Data.ProtoLens.Encoding.Bytes.isolate
                                          (Prelude.fromIntegral len)
                                          ((let
                                              ploop qs
                                                = do packedEnd <- Data.ProtoLens.Encoding.Bytes.atEnd
                                                     if packedEnd then
                                                         Prelude.return qs
                                                     else
                                                         do !q <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                                                    (Prelude.fmap
                                                                       Prelude.fromIntegral
                                                                       Data.ProtoLens.Encoding.Bytes.getVarInt)
                                                                    "attribute_indices"
                                                            qs' <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                                     (Data.ProtoLens.Encoding.Growing.append
                                                                        qs q)
                                                            ploop qs'
                                            in ploop)
                                             mutable'attributeIndices)
                                loop x y mutable'timestampsUnixNano mutable'values
                        32
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "link_index"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"linkIndex") y x)
                                  mutable'attributeIndices mutable'timestampsUnixNano mutable'values
                        41
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        Data.ProtoLens.Encoding.Bytes.getFixed64
                                        "timestamps_unix_nano"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append
                                          mutable'timestampsUnixNano y)
                                loop x mutable'attributeIndices v mutable'values
                        42
                          -> do y <- do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                        Data.ProtoLens.Encoding.Bytes.isolate
                                          (Prelude.fromIntegral len)
                                          ((let
                                              ploop qs
                                                = do packedEnd <- Data.ProtoLens.Encoding.Bytes.atEnd
                                                     if packedEnd then
                                                         Prelude.return qs
                                                     else
                                                         do !q <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                                                    Data.ProtoLens.Encoding.Bytes.getFixed64
                                                                    "timestamps_unix_nano"
                                                            qs' <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                                     (Data.ProtoLens.Encoding.Growing.append
                                                                        qs q)
                                                            ploop qs'
                                            in ploop)
                                             mutable'timestampsUnixNano)
                                loop x mutable'attributeIndices y mutable'values
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'attributeIndices mutable'timestampsUnixNano mutable'values
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'attributeIndices <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                            Data.ProtoLens.Encoding.Growing.new
              mutable'timestampsUnixNano <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                              Data.ProtoLens.Encoding.Growing.new
              mutable'values <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                  Data.ProtoLens.Encoding.Growing.new
              loop
                Data.ProtoLens.defMessage mutable'attributeIndices
                mutable'timestampsUnixNano mutable'values)
          "Sample"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v
                  = Lens.Family2.view (Data.ProtoLens.Field.field @"stackIndex") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 8)
                      ((Prelude..)
                         Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
             ((Data.Monoid.<>)
                (let
                   p = Lens.Family2.view (Data.ProtoLens.Field.field @"vec'values") _x
                 in
                   if Data.Vector.Generic.null p then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                         ((\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                            (Data.ProtoLens.Encoding.Bytes.runBuilder
                               (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                                  ((Prelude..)
                                     Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral)
                                  p))))
                ((Data.Monoid.<>)
                   (let
                      p = Lens.Family2.view
                            (Data.ProtoLens.Field.field @"vec'attributeIndices") _x
                    in
                      if Data.Vector.Generic.null p then
                          Data.Monoid.mempty
                      else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 26)
                            ((\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                               (Data.ProtoLens.Encoding.Bytes.runBuilder
                                  (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                                     ((Prelude..)
                                        Data.ProtoLens.Encoding.Bytes.putVarInt
                                        Prelude.fromIntegral)
                                     p))))
                   ((Data.Monoid.<>)
                      (let
                         _v = Lens.Family2.view (Data.ProtoLens.Field.field @"linkIndex") _x
                       in
                         if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                             Data.Monoid.mempty
                         else
                             (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt 32)
                               ((Prelude..)
                                  Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                      ((Data.Monoid.<>)
                         (let
                            p = Lens.Family2.view
                                  (Data.ProtoLens.Field.field @"vec'timestampsUnixNano") _x
                          in
                            if Data.Vector.Generic.null p then
                                Data.Monoid.mempty
                            else
                                (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt 42)
                                  ((\ bs
                                      -> (Data.Monoid.<>)
                                           (Data.ProtoLens.Encoding.Bytes.putVarInt
                                              (Prelude.fromIntegral (Data.ByteString.length bs)))
                                           (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                     (Data.ProtoLens.Encoding.Bytes.runBuilder
                                        (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                                           Data.ProtoLens.Encoding.Bytes.putFixed64 p))))
                         (Data.ProtoLens.Encoding.Wire.buildFieldSet
                            (Lens.Family2.view Data.ProtoLens.unknownFields _x))))))
instance Control.DeepSeq.NFData Sample where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Sample'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_Sample'stackIndex x__)
                (Control.DeepSeq.deepseq
                   (_Sample'values x__)
                   (Control.DeepSeq.deepseq
                      (_Sample'attributeIndices x__)
                      (Control.DeepSeq.deepseq
                         (_Sample'linkIndex x__)
                         (Control.DeepSeq.deepseq (_Sample'timestampsUnixNano x__) ())))))
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.scope' @:: Lens' ScopeProfiles Proto.Opentelemetry.Proto.Common.V1.Common.InstrumentationScope@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.maybe'scope' @:: Lens' ScopeProfiles (Prelude.Maybe Proto.Opentelemetry.Proto.Common.V1.Common.InstrumentationScope)@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.profiles' @:: Lens' ScopeProfiles [Profile]@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.vec'profiles' @:: Lens' ScopeProfiles (Data.Vector.Vector Profile)@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.schemaUrl' @:: Lens' ScopeProfiles Data.Text.Text@ -}
data ScopeProfiles
  = ScopeProfiles'_constructor {_ScopeProfiles'scope :: !(Prelude.Maybe Proto.Opentelemetry.Proto.Common.V1.Common.InstrumentationScope),
                                _ScopeProfiles'profiles :: !(Data.Vector.Vector Profile),
                                _ScopeProfiles'schemaUrl :: !Data.Text.Text,
                                _ScopeProfiles'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show ScopeProfiles where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField ScopeProfiles "scope" Proto.Opentelemetry.Proto.Common.V1.Common.InstrumentationScope where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ScopeProfiles'scope
           (\ x__ y__ -> x__ {_ScopeProfiles'scope = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField ScopeProfiles "maybe'scope" (Prelude.Maybe Proto.Opentelemetry.Proto.Common.V1.Common.InstrumentationScope) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ScopeProfiles'scope
           (\ x__ y__ -> x__ {_ScopeProfiles'scope = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ScopeProfiles "profiles" [Profile] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ScopeProfiles'profiles
           (\ x__ y__ -> x__ {_ScopeProfiles'profiles = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField ScopeProfiles "vec'profiles" (Data.Vector.Vector Profile) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ScopeProfiles'profiles
           (\ x__ y__ -> x__ {_ScopeProfiles'profiles = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ScopeProfiles "schemaUrl" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ScopeProfiles'schemaUrl
           (\ x__ y__ -> x__ {_ScopeProfiles'schemaUrl = y__}))
        Prelude.id
instance Data.ProtoLens.Message ScopeProfiles where
  messageName _
    = Data.Text.pack
        "opentelemetry.proto.profiles.v1development.ScopeProfiles"
  packedMessageDescriptor _
    = "\n\
      \\rScopeProfiles\DC2I\n\
      \\ENQscope\CAN\SOH \SOH(\v23.opentelemetry.proto.common.v1.InstrumentationScopeR\ENQscope\DC2O\n\
      \\bprofiles\CAN\STX \ETX(\v23.opentelemetry.proto.profiles.v1development.ProfileR\bprofiles\DC2\GS\n\
      \\n\
      \schema_url\CAN\ETX \SOH(\tR\tschemaUrl"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        scope__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "scope"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Opentelemetry.Proto.Common.V1.Common.InstrumentationScope)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'scope")) ::
              Data.ProtoLens.FieldDescriptor ScopeProfiles
        profiles__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "profiles"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Profile)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"profiles")) ::
              Data.ProtoLens.FieldDescriptor ScopeProfiles
        schemaUrl__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "schema_url"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"schemaUrl")) ::
              Data.ProtoLens.FieldDescriptor ScopeProfiles
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, scope__field_descriptor),
           (Data.ProtoLens.Tag 2, profiles__field_descriptor),
           (Data.ProtoLens.Tag 3, schemaUrl__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _ScopeProfiles'_unknownFields
        (\ x__ y__ -> x__ {_ScopeProfiles'_unknownFields = y__})
  defMessage
    = ScopeProfiles'_constructor
        {_ScopeProfiles'scope = Prelude.Nothing,
         _ScopeProfiles'profiles = Data.Vector.Generic.empty,
         _ScopeProfiles'schemaUrl = Data.ProtoLens.fieldDefault,
         _ScopeProfiles'_unknownFields = []}
  parseMessage
    = let
        loop ::
          ScopeProfiles
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Profile
             -> Data.ProtoLens.Encoding.Bytes.Parser ScopeProfiles
        loop x mutable'profiles
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'profiles <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                           (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                              mutable'profiles)
                      (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t)
                           (Lens.Family2.set
                              (Data.ProtoLens.Field.field @"vec'profiles") frozen'profiles x))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "scope"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"scope") y x)
                                  mutable'profiles
                        18
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "profiles"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'profiles y)
                                loop x v
                        26
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getText
                                             (Prelude.fromIntegral len))
                                       "schema_url"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"schemaUrl") y x)
                                  mutable'profiles
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'profiles
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'profiles <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                    Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'profiles)
          "ScopeProfiles"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'scope") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just _v)
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage _v))
             ((Data.Monoid.<>)
                (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                   (\ _v
                      -> (Data.Monoid.<>)
                           (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                           ((Prelude..)
                              (\ bs
                                 -> (Data.Monoid.<>)
                                      (Data.ProtoLens.Encoding.Bytes.putVarInt
                                         (Prelude.fromIntegral (Data.ByteString.length bs)))
                                      (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                              Data.ProtoLens.encodeMessage _v))
                   (Lens.Family2.view
                      (Data.ProtoLens.Field.field @"vec'profiles") _x))
                ((Data.Monoid.<>)
                   (let
                      _v = Lens.Family2.view (Data.ProtoLens.Field.field @"schemaUrl") _x
                    in
                      if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                          Data.Monoid.mempty
                      else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 26)
                            ((Prelude..)
                               (\ bs
                                  -> (Data.Monoid.<>)
                                       (Data.ProtoLens.Encoding.Bytes.putVarInt
                                          (Prelude.fromIntegral (Data.ByteString.length bs)))
                                       (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                               Data.Text.Encoding.encodeUtf8 _v))
                   (Data.ProtoLens.Encoding.Wire.buildFieldSet
                      (Lens.Family2.view Data.ProtoLens.unknownFields _x))))
instance Control.DeepSeq.NFData ScopeProfiles where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_ScopeProfiles'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_ScopeProfiles'scope x__)
                (Control.DeepSeq.deepseq
                   (_ScopeProfiles'profiles x__)
                   (Control.DeepSeq.deepseq (_ScopeProfiles'schemaUrl x__) ())))
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.locationIndices' @:: Lens' Stack [Data.Int.Int32]@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.vec'locationIndices' @:: Lens' Stack (Data.Vector.Unboxed.Vector Data.Int.Int32)@ -}
data Stack
  = Stack'_constructor {_Stack'locationIndices :: !(Data.Vector.Unboxed.Vector Data.Int.Int32),
                        _Stack'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show Stack where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField Stack "locationIndices" [Data.Int.Int32] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Stack'locationIndices
           (\ x__ y__ -> x__ {_Stack'locationIndices = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField Stack "vec'locationIndices" (Data.Vector.Unboxed.Vector Data.Int.Int32) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Stack'locationIndices
           (\ x__ y__ -> x__ {_Stack'locationIndices = y__}))
        Prelude.id
instance Data.ProtoLens.Message Stack where
  messageName _
    = Data.Text.pack "opentelemetry.proto.profiles.v1development.Stack"
  packedMessageDescriptor _
    = "\n\
      \\ENQStack\DC2)\n\
      \\DLElocation_indices\CAN\SOH \ETX(\ENQR\SIlocationIndices"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        locationIndices__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "location_indices"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int32)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Packed
                 (Data.ProtoLens.Field.field @"locationIndices")) ::
              Data.ProtoLens.FieldDescriptor Stack
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, locationIndices__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Stack'_unknownFields
        (\ x__ y__ -> x__ {_Stack'_unknownFields = y__})
  defMessage
    = Stack'_constructor
        {_Stack'locationIndices = Data.Vector.Generic.empty,
         _Stack'_unknownFields = []}
  parseMessage
    = let
        loop ::
          Stack
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Unboxed.Vector Data.ProtoLens.Encoding.Growing.RealWorld Data.Int.Int32
             -> Data.ProtoLens.Encoding.Bytes.Parser Stack
        loop x mutable'locationIndices
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'locationIndices <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                  (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                     mutable'locationIndices)
                      (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t)
                           (Lens.Family2.set
                              (Data.ProtoLens.Field.field @"vec'locationIndices")
                              frozen'locationIndices x))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        8 -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (Prelude.fmap
                                           Prelude.fromIntegral
                                           Data.ProtoLens.Encoding.Bytes.getVarInt)
                                        "location_indices"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append
                                          mutable'locationIndices y)
                                loop x v
                        10
                          -> do y <- do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                        Data.ProtoLens.Encoding.Bytes.isolate
                                          (Prelude.fromIntegral len)
                                          ((let
                                              ploop qs
                                                = do packedEnd <- Data.ProtoLens.Encoding.Bytes.atEnd
                                                     if packedEnd then
                                                         Prelude.return qs
                                                     else
                                                         do !q <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                                                    (Prelude.fmap
                                                                       Prelude.fromIntegral
                                                                       Data.ProtoLens.Encoding.Bytes.getVarInt)
                                                                    "location_indices"
                                                            qs' <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                                     (Data.ProtoLens.Encoding.Growing.append
                                                                        qs q)
                                                            ploop qs'
                                            in ploop)
                                             mutable'locationIndices)
                                loop x y
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'locationIndices
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'locationIndices <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                           Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'locationIndices)
          "Stack"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                p = Lens.Family2.view
                      (Data.ProtoLens.Field.field @"vec'locationIndices") _x
              in
                if Data.Vector.Generic.null p then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                      ((\ bs
                          -> (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt
                                  (Prelude.fromIntegral (Data.ByteString.length bs)))
                               (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                         (Data.ProtoLens.Encoding.Bytes.runBuilder
                            (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                               ((Prelude..)
                                  Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral)
                               p))))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData Stack where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Stack'_unknownFields x__)
             (Control.DeepSeq.deepseq (_Stack'locationIndices x__) ())
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.typeStrindex' @:: Lens' ValueType Data.Int.Int32@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.unitStrindex' @:: Lens' ValueType Data.Int.Int32@ -}
data ValueType
  = ValueType'_constructor {_ValueType'typeStrindex :: !Data.Int.Int32,
                            _ValueType'unitStrindex :: !Data.Int.Int32,
                            _ValueType'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show ValueType where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField ValueType "typeStrindex" Data.Int.Int32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ValueType'typeStrindex
           (\ x__ y__ -> x__ {_ValueType'typeStrindex = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ValueType "unitStrindex" Data.Int.Int32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ValueType'unitStrindex
           (\ x__ y__ -> x__ {_ValueType'unitStrindex = y__}))
        Prelude.id
instance Data.ProtoLens.Message ValueType where
  messageName _
    = Data.Text.pack
        "opentelemetry.proto.profiles.v1development.ValueType"
  packedMessageDescriptor _
    = "\n\
      \\tValueType\DC2#\n\
      \\rtype_strindex\CAN\SOH \SOH(\ENQR\ftypeStrindex\DC2#\n\
      \\runit_strindex\CAN\STX \SOH(\ENQR\funitStrindex"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        typeStrindex__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "type_strindex"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"typeStrindex")) ::
              Data.ProtoLens.FieldDescriptor ValueType
        unitStrindex__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "unit_strindex"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"unitStrindex")) ::
              Data.ProtoLens.FieldDescriptor ValueType
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, typeStrindex__field_descriptor),
           (Data.ProtoLens.Tag 2, unitStrindex__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _ValueType'_unknownFields
        (\ x__ y__ -> x__ {_ValueType'_unknownFields = y__})
  defMessage
    = ValueType'_constructor
        {_ValueType'typeStrindex = Data.ProtoLens.fieldDefault,
         _ValueType'unitStrindex = Data.ProtoLens.fieldDefault,
         _ValueType'_unknownFields = []}
  parseMessage
    = let
        loop :: ValueType -> Data.ProtoLens.Encoding.Bytes.Parser ValueType
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        8 -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "type_strindex"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"typeStrindex") y x)
                        16
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "unit_strindex"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"unitStrindex") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "ValueType"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v
                  = Lens.Family2.view (Data.ProtoLens.Field.field @"typeStrindex") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 8)
                      ((Prelude..)
                         Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
             ((Data.Monoid.<>)
                (let
                   _v
                     = Lens.Family2.view (Data.ProtoLens.Field.field @"unitStrindex") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                         ((Prelude..)
                            Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                (Data.ProtoLens.Encoding.Wire.buildFieldSet
                   (Lens.Family2.view Data.ProtoLens.unknownFields _x)))
instance Control.DeepSeq.NFData ValueType where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_ValueType'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_ValueType'typeStrindex x__)
                (Control.DeepSeq.deepseq (_ValueType'unitStrindex x__) ()))
packedFileDescriptor :: Data.ByteString.ByteString
packedFileDescriptor
  = "\n\
    \9opentelemetry/proto/profiles/v1development/profiles.proto\DC2*opentelemetry.proto.profiles.v1development\SUB*opentelemetry/proto/common/v1/common.proto\SUB.opentelemetry/proto/resource/v1/resource.proto\"\214\EOT\n\
    \\DC2ProfilesDictionary\DC2X\n\
    \\rmapping_table\CAN\SOH \ETX(\v23.opentelemetry.proto.profiles.v1development.MappingR\fmappingTable\DC2[\n\
    \\SOlocation_table\CAN\STX \ETX(\v24.opentelemetry.proto.profiles.v1development.LocationR\rlocationTable\DC2[\n\
    \\SOfunction_table\CAN\ETX \ETX(\v24.opentelemetry.proto.profiles.v1development.FunctionR\rfunctionTable\DC2O\n\
    \\n\
    \link_table\CAN\EOT \ETX(\v20.opentelemetry.proto.profiles.v1development.LinkR\tlinkTable\DC2!\n\
    \\fstring_table\CAN\ENQ \ETX(\tR\vstringTable\DC2d\n\
    \\SIattribute_table\CAN\ACK \ETX(\v2;.opentelemetry.proto.profiles.v1development.KeyValueAndUnitR\SOattributeTable\DC2R\n\
    \\vstack_table\CAN\a \ETX(\v21.opentelemetry.proto.profiles.v1development.StackR\n\
    \stackTable\"\217\SOH\n\
    \\fProfilesData\DC2i\n\
    \\DC1resource_profiles\CAN\SOH \ETX(\v2<.opentelemetry.proto.profiles.v1development.ResourceProfilesR\DLEresourceProfiles\DC2^\n\
    \\n\
    \dictionary\CAN\STX \SOH(\v2>.opentelemetry.proto.profiles.v1development.ProfilesDictionaryR\n\
    \dictionary\"\226\SOH\n\
    \\DLEResourceProfiles\DC2E\n\
    \\bresource\CAN\SOH \SOH(\v2).opentelemetry.proto.resource.v1.ResourceR\bresource\DC2`\n\
    \\SOscope_profiles\CAN\STX \ETX(\v29.opentelemetry.proto.profiles.v1development.ScopeProfilesR\rscopeProfiles\DC2\GS\n\
    \\n\
    \schema_url\CAN\ETX \SOH(\tR\tschemaUrlJ\ACK\b\232\a\DLE\233\a\"\202\SOH\n\
    \\rScopeProfiles\DC2I\n\
    \\ENQscope\CAN\SOH \SOH(\v23.opentelemetry.proto.common.v1.InstrumentationScopeR\ENQscope\DC2O\n\
    \\bprofiles\CAN\STX \ETX(\v23.opentelemetry.proto.profiles.v1development.ProfileR\bprofiles\DC2\GS\n\
    \\n\
    \schema_url\CAN\ETX \SOH(\tR\tschemaUrl\"\211\EOT\n\
    \\aProfile\DC2V\n\
    \\vsample_type\CAN\SOH \SOH(\v25.opentelemetry.proto.profiles.v1development.ValueTypeR\n\
    \sampleType\DC2L\n\
    \\asamples\CAN\STX \ETX(\v22.opentelemetry.proto.profiles.v1development.SampleR\asamples\DC2$\n\
    \\SOtime_unix_nano\CAN\ETX \SOH(\ACKR\ftimeUnixNano\DC2#\n\
    \\rduration_nano\CAN\EOT \SOH(\EOTR\fdurationNano\DC2V\n\
    \\vperiod_type\CAN\ENQ \SOH(\v25.opentelemetry.proto.profiles.v1development.ValueTypeR\n\
    \periodType\DC2\SYN\n\
    \\ACKperiod\CAN\ACK \SOH(\ETXR\ACKperiod\DC2\GS\n\
    \\n\
    \profile_id\CAN\a \SOH(\fR\tprofileId\DC28\n\
    \\CANdropped_attributes_count\CAN\b \SOH(\rR\SYNdroppedAttributesCount\DC26\n\
    \\ETBoriginal_payload_format\CAN\t \SOH(\tR\NAKoriginalPayloadFormat\DC2)\n\
    \\DLEoriginal_payload\CAN\n\
    \ \SOH(\fR\SIoriginalPayload\DC2+\n\
    \\DC1attribute_indices\CAN\v \ETX(\ENQR\DLEattributeIndices\":\n\
    \\EOTLink\DC2\EM\n\
    \\btrace_id\CAN\SOH \SOH(\fR\atraceId\DC2\ETB\n\
    \\aspan_id\CAN\STX \SOH(\fR\ACKspanId\"U\n\
    \\tValueType\DC2#\n\
    \\rtype_strindex\CAN\SOH \SOH(\ENQR\ftypeStrindex\DC2#\n\
    \\runit_strindex\CAN\STX \SOH(\ENQR\funitStrindex\"\191\SOH\n\
    \\ACKSample\DC2\US\n\
    \\vstack_index\CAN\SOH \SOH(\ENQR\n\
    \stackIndex\DC2\SYN\n\
    \\ACKvalues\CAN\STX \ETX(\ETXR\ACKvalues\DC2+\n\
    \\DC1attribute_indices\CAN\ETX \ETX(\ENQR\DLEattributeIndices\DC2\GS\n\
    \\n\
    \link_index\CAN\EOT \SOH(\ENQR\tlinkIndex\DC20\n\
    \\DC4timestamps_unix_nano\CAN\ENQ \ETX(\ACKR\DC2timestampsUnixNano\"\202\SOH\n\
    \\aMapping\DC2!\n\
    \\fmemory_start\CAN\SOH \SOH(\EOTR\vmemoryStart\DC2!\n\
    \\fmemory_limit\CAN\STX \SOH(\EOTR\vmemoryLimit\DC2\US\n\
    \\vfile_offset\CAN\ETX \SOH(\EOTR\n\
    \fileOffset\DC2+\n\
    \\DC1filename_strindex\CAN\EOT \SOH(\ENQR\DLEfilenameStrindex\DC2+\n\
    \\DC1attribute_indices\CAN\ENQ \ETX(\ENQR\DLEattributeIndices\"2\n\
    \\ENQStack\DC2)\n\
    \\DLElocation_indices\CAN\SOH \ETX(\ENQR\SIlocationIndices\"\190\SOH\n\
    \\bLocation\DC2#\n\
    \\rmapping_index\CAN\SOH \SOH(\ENQR\fmappingIndex\DC2\CAN\n\
    \\aaddress\CAN\STX \SOH(\EOTR\aaddress\DC2F\n\
    \\ENQlines\CAN\ETX \ETX(\v20.opentelemetry.proto.profiles.v1development.LineR\ENQlines\DC2+\n\
    \\DC1attribute_indices\CAN\EOT \ETX(\ENQR\DLEattributeIndices\"Y\n\
    \\EOTLine\DC2%\n\
    \\SOfunction_index\CAN\SOH \SOH(\ENQR\rfunctionIndex\DC2\DC2\n\
    \\EOTline\CAN\STX \SOH(\ETXR\EOTline\DC2\SYN\n\
    \\ACKcolumn\CAN\ETX \SOH(\ETXR\ACKcolumn\"\173\SOH\n\
    \\bFunction\DC2#\n\
    \\rname_strindex\CAN\SOH \SOH(\ENQR\fnameStrindex\DC20\n\
    \\DC4system_name_strindex\CAN\STX \SOH(\ENQR\DC2systemNameStrindex\DC2+\n\
    \\DC1filename_strindex\CAN\ETX \SOH(\ENQR\DLEfilenameStrindex\DC2\GS\n\
    \\n\
    \start_line\CAN\EOT \SOH(\ETXR\tstartLine\"\152\SOH\n\
    \\SIKeyValueAndUnit\DC2!\n\
    \\fkey_strindex\CAN\SOH \SOH(\ENQR\vkeyStrindex\DC2=\n\
    \\ENQvalue\CAN\STX \SOH(\v2'.opentelemetry.proto.common.v1.AnyValueR\ENQvalue\DC2#\n\
    \\runit_strindex\CAN\ETX \SOH(\ENQR\funitStrindexB\164\SOH\n\
    \-io.opentelemetry.proto.profiles.v1developmentB\rProfilesProtoP\SOHZ5go.opentelemetry.io/proto/otlp/profiles/v1development\170\STX*OpenTelemetry.Proto.Profiles.V1DevelopmentJ\147\177\SOH\n\
    \\a\DC2\ENQ\RS\NUL\223\ETX\SOH\n\
    \\229\t\n\
    \\SOH\f\DC2\ETX\RS\NUL\DC22\218\t Copyright 2023, OpenTelemetry Authors\n\
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
    \ This file includes work covered by the following copyright and permission notices:\n\
    \\n\
    \ Copyright 2016 Google Inc. All Rights Reserved.\n\
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
    \\SOH\STX\DC2\ETX \NUL3\n\
    \\t\n\
    \\STX\ETX\NUL\DC2\ETX\"\NUL4\n\
    \\t\n\
    \\STX\ETX\SOH\DC2\ETX#\NUL8\n\
    \\b\n\
    \\SOH\b\DC2\ETX%\NULG\n\
    \\t\n\
    \\STX\b%\DC2\ETX%\NULG\n\
    \\b\n\
    \\SOH\b\DC2\ETX&\NUL\"\n\
    \\t\n\
    \\STX\b\n\
    \\DC2\ETX&\NUL\"\n\
    \\b\n\
    \\SOH\b\DC2\ETX'\NULF\n\
    \\t\n\
    \\STX\b\SOH\DC2\ETX'\NULF\n\
    \\b\n\
    \\SOH\b\DC2\ETX(\NUL.\n\
    \\t\n\
    \\STX\b\b\DC2\ETX(\NUL.\n\
    \\b\n\
    \\SOH\b\DC2\ETX)\NULL\n\
    \\t\n\
    \\STX\b\v\DC2\ETX)\NULL\n\
    \\233 \n\
    \\STX\EOT\NUL\DC2\ENQz\NUL\175\SOH\SOH\SUB\179\t ProfilesDictionary represents the profiles data shared across the\n\
    \ entire message being sent. The following applies to all fields in this\n\
    \ message:\n\
    \\n\
    \ - A dictionary is an array of dictionary items. Users of the dictionary\n\
    \   compactly reference the items using the index within the array.\n\
    \\n\
    \ - A dictionary MUST have a zero value encoded as the first element. This\n\
    \   allows for _index fields pointing into the dictionary to use a 0 pointer\n\
    \   value to indicate 'null' / 'not set'. Unless otherwise defined, a 'zero\n\
    \   value' message value is one with all default field values, so as to\n\
    \   minimize wire encoded size.\n\
    \\n\
    \ - There SHOULD NOT be dupes in a dictionary. The identity of dictionary\n\
    \   items is based on their value, recursively as needed. If a particular\n\
    \   implementation does emit duplicated items, it MUST NOT attempt to give them\n\
    \   meaning based on the index or order. A profile processor may remove\n\
    \   duplicate items and this MUST NOT have any observable effects for\n\
    \   consumers.\n\
    \\n\
    \ - There SHOULD NOT be orphaned (unreferenced) items in a dictionary. A\n\
    \   profile processor may remove (\"garbage-collect\") orphaned items and this\n\
    \   MUST NOT have any observable effects for consumers.\n\
    \\n\
    \2\165\ETB                Relationships Diagram\n\
    \\n\
    \ \226\148\140\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\144                      LEGEND\n\
    \ \226\148\130   ProfilesData   \226\148\130 \226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\144\n\
    \ \226\148\148\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\152      \226\148\130           \226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\150\182 embedded\n\
    \   \226\148\130                       \226\148\130\n\
    \   \226\148\130 1-n                   \226\148\130           \226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\150\183 referenced by index\n\
    \   \226\150\188                       \226\150\188\n\
    \ \226\148\140\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\144   \226\148\140\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\144\n\
    \ \226\148\130 ResourceProfiles \226\148\130   \226\148\130 ProfilesDictionary \226\148\130\n\
    \ \226\148\148\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\152   \226\148\148\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\152\n\
    \   \226\148\130\n\
    \   \226\148\130 1-n\n\
    \   \226\150\188\n\
    \ \226\148\140\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\144\n\
    \ \226\148\130  ScopeProfiles   \226\148\130\n\
    \ \226\148\148\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\152\n\
    \   \226\148\130\n\
    \   \226\148\130 1-n\n\
    \   \226\150\188\n\
    \ \226\148\140\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\144\n\
    \ \226\148\130      Profile     \226\148\130\n\
    \ \226\148\148\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\152\n\
    \   \226\148\130                                n-1\n\
    \   \226\148\130 1-n         \226\148\140\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\144\n\
    \   \226\150\188             \226\148\130                                       \226\150\189\n\
    \ \226\148\140\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\144   1-n   \226\148\140\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\144   \226\148\140\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\144\n\
    \ \226\148\130      Sample      \226\148\130 \226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\150\183 \226\148\130 KeyValueAndUnit \226\148\130   \226\148\130   Link   \226\148\130\n\
    \ \226\148\148\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\152         \226\148\148\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\152   \226\148\148\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\152\n\
    \   \226\148\130                              \226\150\179      \226\150\179\n\
    \   \226\148\130 n-1                          \226\148\130      \226\148\130 1-n\n\
    \   \226\150\189                              \226\148\130      \226\148\130\n\
    \ \226\148\140\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\144             \226\148\130      \226\148\130\n\
    \ \226\148\130      Stack       \226\148\130             \226\148\130      \226\148\130\n\
    \ \226\148\148\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\152             \226\148\130      \226\148\130\n\
    \   \226\148\130                     1-n      \226\148\130      \226\148\130\n\
    \   \226\148\130 1-n         \226\148\140\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\152      \226\148\130\n\
    \   \226\150\189             \226\148\130                       \226\148\130\n\
    \ \226\148\140\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\144   n-1   \226\148\140\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\144\n\
    \ \226\148\130     Location     \226\148\130 \226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\150\183 \226\148\130   Mapping   \226\148\130\n\
    \ \226\148\148\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\152         \226\148\148\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\152\n\
    \   \226\148\130\n\
    \   \226\148\130 1-n\n\
    \   \226\150\188\n\
    \ \226\148\140\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\144\n\
    \ \226\148\130       Line       \226\148\130\n\
    \ \226\148\148\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\152\n\
    \   \226\148\130\n\
    \   \226\148\130 1-1\n\
    \   \226\150\189\n\
    \ \226\148\140\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\144\n\
    \ \226\148\130     Function     \226\148\130\n\
    \ \226\148\148\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\152\n\
    \\n\
    \\n\
    \\n\
    \\n\
    \\ETX\EOT\NUL\SOH\DC2\ETXz\b\SUB\n\
    \\226\SOH\n\
    \\EOT\EOT\NUL\STX\NUL\DC2\ETX\DEL\STX%\SUB\212\SOH Mappings from address ranges to the image/binary/library mapped\n\
    \ into that address range referenced by locations via Location.mapping_index.\n\
    \\n\
    \ mapping_table[0] must always be zero value (Mapping{}) and present.\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\EOT\DC2\ETX\DEL\STX\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\ACK\DC2\ETX\DEL\v\DC2\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\SOH\DC2\ETX\DEL\DC3 \n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\ETX\DC2\ETX\DEL#$\n\
    \\148\SOH\n\
    \\EOT\EOT\NUL\STX\SOH\DC2\EOT\132\SOH\STX'\SUB\133\SOH Locations referenced by samples via Stack.location_indices.\n\
    \\n\
    \ location_table[0] must always be zero value (Location{}) and present.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\SOH\EOT\DC2\EOT\132\SOH\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\SOH\ACK\DC2\EOT\132\SOH\v\DC3\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\SOH\SOH\DC2\EOT\132\SOH\DC4\"\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\SOH\ETX\DC2\EOT\132\SOH%&\n\
    \\147\SOH\n\
    \\EOT\EOT\NUL\STX\STX\DC2\EOT\137\SOH\STX'\SUB\132\SOH Functions referenced by locations via Line.function_index.\n\
    \\n\
    \ function_table[0] must always be zero value (Function{}) and present.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\STX\EOT\DC2\EOT\137\SOH\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\STX\ACK\DC2\EOT\137\SOH\v\DC3\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\STX\SOH\DC2\EOT\137\SOH\DC4\"\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\STX\ETX\DC2\EOT\137\SOH%&\n\
    \\130\SOH\n\
    \\EOT\EOT\NUL\STX\ETX\DC2\EOT\142\SOH\STX\US\SUBt Links referenced by samples via Sample.link_index.\n\
    \\n\
    \ link_table[0] must always be zero value (Link{}) and present.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\ETX\EOT\DC2\EOT\142\SOH\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\ETX\ACK\DC2\EOT\142\SOH\v\SI\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\ETX\SOH\DC2\EOT\142\SOH\DLE\SUB\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\ETX\ETX\DC2\EOT\142\SOH\GS\RS\n\
    \{\n\
    \\EOT\EOT\NUL\STX\EOT\DC2\EOT\147\SOH\STX#\SUBm A common table for strings referenced by various messages.\n\
    \\n\
    \ string_table[0] must always be \"\" and present.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\EOT\EOT\DC2\EOT\147\SOH\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\EOT\ENQ\DC2\EOT\147\SOH\v\DC1\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\EOT\SOH\DC2\EOT\147\SOH\DC2\RS\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\EOT\ETX\DC2\EOT\147\SOH!\"\n\
    \\243\b\n\
    \\EOT\EOT\NUL\STX\ENQ\DC2\EOT\169\SOH\STX/\SUB\228\b A common table for attributes referenced by the Profile, Sample, Mapping\n\
    \ and Location messages below through attribute_indices field. Each entry is\n\
    \ a key/value pair with an optional unit. Since this is a dictionary table,\n\
    \ multiple entries with the same key may be present, unlike direct attribute\n\
    \ tables like Resource.attributes. The referencing attribute_indices fields,\n\
    \ though, do maintain the key uniqueness requirement.\n\
    \\n\
    \ It's recommended to use attributes for variables with bounded cardinality,\n\
    \ such as categorical variables\n\
    \ (https://en.wikipedia.org/wiki/Categorical_variable). Using an attribute of\n\
    \ a floating point type (e.g., CPU time) in a sample can quickly make every\n\
    \ attribute value unique, defeating the purpose of the dictionary and\n\
    \ impractically increasing the profile size.\n\
    \\n\
    \ Examples of attributes:\n\
    \     \"/http/user_agent\": \"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36\"\n\
    \     \"abc.com/myattribute\": true\n\
    \     \"allocation_size\": 128 bytes\n\
    \\n\
    \ attribute_table[0] must always be zero value (KeyValueAndUnit{}) and present.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\ENQ\EOT\DC2\EOT\169\SOH\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\ENQ\ACK\DC2\EOT\169\SOH\v\SUB\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\ENQ\SOH\DC2\EOT\169\SOH\ESC*\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\ENQ\ETX\DC2\EOT\169\SOH-.\n\
    \\134\SOH\n\
    \\EOT\EOT\NUL\STX\ACK\DC2\EOT\174\SOH\STX!\SUBx Stacks referenced by samples via Sample.stack_index.\n\
    \\n\
    \ stack_table[0] must always be zero value (Stack{}) and present.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\ACK\EOT\DC2\EOT\174\SOH\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\ACK\ACK\DC2\EOT\174\SOH\v\DLE\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\ACK\SOH\DC2\EOT\174\SOH\DC1\FS\n\
    \\r\n\
    \\ENQ\EOT\NUL\STX\ACK\ETX\DC2\EOT\174\SOH\US \n\
    \\212\ETX\n\
    \\STX\EOT\SOH\DC2\ACK\187\SOH\NUL\201\SOH\SOH\SUB\197\ETX ProfilesData represents the profiles data that can be stored in persistent storage,\n\
    \ OR can be embedded by other protocols that transfer OTLP profiles data but do not\n\
    \ implement the OTLP protocol.\n\
    \\n\
    \ The main difference between this message and collector protocol is that\n\
    \ in this message there will not be any \"control\" or \"metadata\" specific to\n\
    \ OTLP protocol.\n\
    \\n\
    \ When new fields are added into this message, the OTLP request MUST be updated\n\
    \ as well.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\SOH\SOH\DC2\EOT\187\SOH\b\DC4\n\
    \\157\EOT\n\
    \\EOT\EOT\SOH\STX\NUL\DC2\EOT\197\SOH\STX2\SUB\142\EOT An array of ResourceProfiles.\n\
    \ For data coming from an SDK profiler, this array will typically contain one\n\
    \ element. Host-level profilers will usually create one ResourceProfile per\n\
    \ container, as well as one additional ResourceProfile grouping all samples\n\
    \ from non-containerized processes.\n\
    \ Other resource groupings are possible as well and clarified via\n\
    \ Resource.attributes and semantic conventions.\n\
    \ Tools that visualize profiles should prefer displaying\n\
    \ resources_profiles[0].scope_profiles[0].profiles[0] by default.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\SOH\STX\NUL\EOT\DC2\EOT\197\SOH\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\SOH\STX\NUL\ACK\DC2\EOT\197\SOH\v\ESC\n\
    \\r\n\
    \\ENQ\EOT\SOH\STX\NUL\SOH\DC2\EOT\197\SOH\FS-\n\
    \\r\n\
    \\ENQ\EOT\SOH\STX\NUL\ETX\DC2\EOT\197\SOH01\n\
    \2\n\
    \\EOT\EOT\SOH\STX\SOH\DC2\EOT\200\SOH\STX$\SUB$ One instance of ProfilesDictionary\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\SOH\STX\SOH\ACK\DC2\EOT\200\SOH\STX\DC4\n\
    \\r\n\
    \\ENQ\EOT\SOH\STX\SOH\SOH\DC2\EOT\200\SOH\NAK\US\n\
    \\r\n\
    \\ENQ\EOT\SOH\STX\SOH\ETX\DC2\EOT\200\SOH\"#\n\
    \>\n\
    \\STX\EOT\STX\DC2\ACK\205\SOH\NUL\222\SOH\SOH\SUB0 A collection of ScopeProfiles from a Resource.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\STX\SOH\DC2\EOT\205\SOH\b\CAN\n\
    \\v\n\
    \\ETX\EOT\STX\t\DC2\EOT\206\SOH\STX\DLE\n\
    \\f\n\
    \\EOT\EOT\STX\t\NUL\DC2\EOT\206\SOH\v\SI\n\
    \\r\n\
    \\ENQ\EOT\STX\t\NUL\SOH\DC2\EOT\206\SOH\v\SI\n\
    \\r\n\
    \\ENQ\EOT\STX\t\NUL\STX\DC2\EOT\206\SOH\v\SI\n\
    \x\n\
    \\EOT\EOT\STX\STX\NUL\DC2\EOT\210\SOH\STX8\SUBj The resource for the profiles in this message.\n\
    \ If this field is not set then no resource info is known.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\STX\STX\NUL\ACK\DC2\EOT\210\SOH\STX*\n\
    \\r\n\
    \\ENQ\EOT\STX\STX\NUL\SOH\DC2\EOT\210\SOH+3\n\
    \\r\n\
    \\ENQ\EOT\STX\STX\NUL\ETX\DC2\EOT\210\SOH67\n\
    \G\n\
    \\EOT\EOT\STX\STX\SOH\DC2\EOT\213\SOH\STX,\SUB9 A list of ScopeProfiles that originate from a resource.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\STX\STX\SOH\EOT\DC2\EOT\213\SOH\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\STX\STX\SOH\ACK\DC2\EOT\213\SOH\v\CAN\n\
    \\r\n\
    \\ENQ\EOT\STX\STX\SOH\SOH\DC2\EOT\213\SOH\EM'\n\
    \\r\n\
    \\ENQ\EOT\STX\STX\SOH\ETX\DC2\EOT\213\SOH*+\n\
    \\239\ETX\n\
    \\EOT\EOT\STX\STX\STX\DC2\EOT\221\SOH\STX\CAN\SUB\224\ETX The Schema URL, if known. This is the identifier of the Schema that the resource data\n\
    \ is recorded in. Notably, the last part of the URL path is the version number of the\n\
    \ schema: http[s]://server[:port]/path/<version>. To learn more about Schema URL see\n\
    \ https://opentelemetry.io/docs/specs/otel/schemas/#schema-url\n\
    \ This schema_url applies to the data in the \"resource\" field. It does not apply\n\
    \ to the data in the \"scope_profiles\" field which have their own schema_url field.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\STX\STX\STX\ENQ\DC2\EOT\221\SOH\STX\b\n\
    \\r\n\
    \\ENQ\EOT\STX\STX\STX\SOH\DC2\EOT\221\SOH\t\DC3\n\
    \\r\n\
    \\ENQ\EOT\STX\STX\STX\ETX\DC2\EOT\221\SOH\SYN\ETB\n\
    \M\n\
    \\STX\EOT\ETX\DC2\ACK\225\SOH\NUL\241\SOH\SOH\SUB? A collection of Profiles produced by an InstrumentationScope.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\ETX\SOH\DC2\EOT\225\SOH\b\NAK\n\
    \\209\SOH\n\
    \\EOT\EOT\ETX\STX\NUL\DC2\EOT\229\SOH\STX?\SUB\194\SOH The instrumentation scope information for the profiles in this message.\n\
    \ Semantically when InstrumentationScope isn't set, it is equivalent with\n\
    \ an empty instrumentation scope name (unknown).\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\NUL\ACK\DC2\EOT\229\SOH\STX4\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\NUL\SOH\DC2\EOT\229\SOH5:\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\NUL\ETX\DC2\EOT\229\SOH=>\n\
    \P\n\
    \\EOT\EOT\ETX\STX\SOH\DC2\EOT\232\SOH\STX \SUBB A list of Profiles that originate from an instrumentation scope.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\SOH\EOT\DC2\EOT\232\SOH\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\SOH\ACK\DC2\EOT\232\SOH\v\DC2\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\SOH\SOH\DC2\EOT\232\SOH\DC3\ESC\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\SOH\ETX\DC2\EOT\232\SOH\RS\US\n\
    \\177\ETX\n\
    \\EOT\EOT\ETX\STX\STX\DC2\EOT\240\SOH\STX\CAN\SUB\162\ETX The Schema URL, if known. This is the identifier of the Schema that the profile data\n\
    \ is recorded in. Notably, the last part of the URL path is the version number of the\n\
    \ schema: http[s]://server[:port]/path/<version>. To learn more about Schema URL see\n\
    \ https://opentelemetry.io/docs/specs/otel/schemas/#schema-url\n\
    \ This schema_url applies to the data in the \"scope\" field and all profiles in the\n\
    \ \"profiles\" field.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\STX\ENQ\DC2\EOT\240\SOH\STX\b\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\STX\SOH\DC2\EOT\240\SOH\t\DC3\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\STX\ETX\DC2\EOT\240\SOH\SYN\ETB\n\
    \\132\v\n\
    \\STX\EOT\EOT\DC2\ACK\145\STX\NUL\207\STX\SOH\SUB\212\ETX Represents a complete profile, including sample types, samples, mappings to\n\
    \ binaries, stacks, locations, functions, string table, and additional\n\
    \ metadata. It modifies and annotates pprof Profile with OpenTelemetry\n\
    \ specific fields.\n\
    \\n\
    \ Note that whilst fields in this message retain the name and field id from pprof in most cases\n\
    \ for ease of understanding data migration, it is not intended that pprof:Profile and\n\
    \ OpenTelemetry:Profile encoding be wire compatible.\n\
    \2\158\a Profile is a common stacktrace profile format.\n\
    \\n\
    \ Measurements represented with this format should follow the\n\
    \ following conventions:\n\
    \\n\
    \ - Consumers should treat unset optional fields as if they had been\n\
    \   set with their default value.\n\
    \\n\
    \ - When possible, measurements should be stored in \"unsampled\" form\n\
    \   that is most useful to humans.  There should be enough\n\
    \   information present to determine the original sampled values.\n\
    \\n\
    \ - The profile is represented as a set of samples, where each sample\n\
    \   references a stack trace which is a list of locations, each belonging\n\
    \   to a mapping.\n\
    \ - There is a N->1 relationship from Stack.location_indices entries to\n\
    \   locations. For every Stack.location_indices entry there must be a\n\
    \   unique Location with that index.\n\
    \ - There is an optional N->1 relationship from locations to\n\
    \   mappings. For every nonzero Location.mapping_id there must be a\n\
    \   unique Mapping with that index.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\EOT\SOH\DC2\EOT\145\STX\b\SI\n\
    \\144\STX\n\
    \\EOT\EOT\EOT\STX\NUL\DC2\EOT\151\STX\STX\FS\SUB\129\STX The type and unit of all Sample.values in this profile.\n\
    \ For a cpu or off-cpu profile this might be:\n\
    \   [\"cpu\",\"nanoseconds\"] or [\"off_cpu\",\"nanoseconds\"]\n\
    \ For a heap profile, this might be:\n\
    \   [\"allocated_objects\",\"count\"] or [\"allocated_space\",\"bytes\"],\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\NUL\ACK\DC2\EOT\151\STX\STX\v\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\NUL\SOH\DC2\EOT\151\STX\f\ETB\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\NUL\ETX\DC2\EOT\151\STX\SUB\ESC\n\
    \<\n\
    \\EOT\EOT\EOT\STX\SOH\DC2\EOT\153\STX\STX\RS\SUB. The set of samples recorded in this profile.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\SOH\EOT\DC2\EOT\153\STX\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\SOH\ACK\DC2\EOT\153\STX\v\DC1\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\SOH\SOH\DC2\EOT\153\STX\DC2\EM\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\SOH\ETX\DC2\EOT\153\STX\FS\GS\n\
    \\173\SOH\n\
    \\EOT\EOT\EOT\STX\STX\DC2\EOT\159\STX\STX\GS\SUBE Time of collection (UTC) represented as nanoseconds past the epoch.\n\
    \2X The following fields 3-12 are informational, do not affect\n\
    \ interpretation of results.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\STX\ENQ\DC2\EOT\159\STX\STX\t\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\STX\SOH\DC2\EOT\159\STX\n\
    \\CAN\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\STX\ETX\DC2\EOT\159\STX\ESC\FS\n\
    \C\n\
    \\EOT\EOT\EOT\STX\ETX\DC2\EOT\161\STX\STX\ESC\SUB5 Duration of the profile, if a duration makes sense.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\ETX\ENQ\DC2\EOT\161\STX\STX\b\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\ETX\SOH\DC2\EOT\161\STX\t\SYN\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\ETX\ETX\DC2\EOT\161\STX\EM\SUB\n\
    \m\n\
    \\EOT\EOT\EOT\STX\EOT\DC2\EOT\164\STX\STX\FS\SUB_ The kind of events between sampled occurrences.\n\
    \ e.g [ \"cpu\",\"cycles\" ] or [ \"heap\",\"bytes\" ]\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\EOT\ACK\DC2\EOT\164\STX\STX\v\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\EOT\SOH\DC2\EOT\164\STX\f\ETB\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\EOT\ETX\DC2\EOT\164\STX\SUB\ESC\n\
    \A\n\
    \\EOT\EOT\EOT\STX\ENQ\DC2\EOT\166\STX\STX\DC3\SUB3 The number of events between sampled occurrences.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\ENQ\ENQ\DC2\EOT\166\STX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\ENQ\SOH\DC2\EOT\166\STX\b\SO\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\ENQ\ETX\DC2\EOT\166\STX\DC1\DC2\n\
    \\182\ETX\n\
    \\EOT\EOT\EOT\STX\ACK\DC2\EOT\174\STX\STX\ETB\SUB\167\ETX A globally unique identifier for a profile. The ID is a 16-byte array. An ID with\n\
    \ all zeroes is considered invalid. It may be used for deduplication and signal\n\
    \ correlation purposes. It is acceptable to treat two profiles with different values\n\
    \ in this field as not equal, even if they represented the same object at an earlier\n\
    \ time.\n\
    \ This field is optional; an ID may be assigned to an ID-less profile in a later step.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\ACK\ENQ\DC2\EOT\174\STX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\ACK\SOH\DC2\EOT\174\STX\b\DC2\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\ACK\ETX\DC2\EOT\174\STX\NAK\SYN\n\
    \\219\SOH\n\
    \\EOT\EOT\EOT\STX\a\DC2\EOT\179\STX\STX&\SUB\204\SOH The number of attributes that were discarded. Attributes\n\
    \ can be discarded because their keys are too long or because there are too many\n\
    \ attributes. If this value is 0, then no attributes were dropped.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\a\ENQ\DC2\EOT\179\STX\STX\b\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\a\SOH\DC2\EOT\179\STX\t!\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\a\ETX\DC2\EOT\179\STX$%\n\
    \\166\b\n\
    \\EOT\EOT\EOT\STX\b\DC2\EOT\200\STX\STX%\SUB\151\b The original payload format. See also original_payload. Optional, but the\n\
    \ format and the bytes must be set or unset together.\n\
    \\n\
    \ The allowed values for the format string are defined by the OpenTelemetry\n\
    \ specification. Some examples are \"jfr\", \"pprof\", \"linux_perf\".\n\
    \\n\
    \ The original payload may be optionally provided when the conversion to the\n\
    \ OLTP format was done from a different format with some loss of the fidelity\n\
    \ and the receiver may want to store the original payload to allow future\n\
    \ lossless export or reinterpretation. Some examples of the original format\n\
    \ are JFR (Java Flight Recorder), pprof, Linux perf.\n\
    \\n\
    \ Even when the original payload is in a format that is semantically close to\n\
    \ OTLP, such as pprof, a conversion may still be lossy in some cases (e.g. if\n\
    \ the pprof file contains custom extensions or conventions).\n\
    \\n\
    \ The original payload can be large in size, so including the original\n\
    \ payload should be configurable by the profiler or collector options. The\n\
    \ default behavior should be to not include the original payload.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\b\ENQ\DC2\EOT\200\STX\STX\b\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\b\SOH\DC2\EOT\200\STX\t \n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\b\ETX\DC2\EOT\200\STX#$\n\
    \\145\SOH\n\
    \\EOT\EOT\EOT\STX\t\DC2\EOT\203\STX\STX\RS\SUB\130\SOH The original payload bytes. See also original_payload_format. Optional, but\n\
    \ format and the bytes must be set or unset together.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\t\ENQ\DC2\EOT\203\STX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\t\SOH\DC2\EOT\203\STX\b\CAN\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\t\ETX\DC2\EOT\203\STX\ESC\GS\n\
    \G\n\
    \\EOT\EOT\EOT\STX\n\
    \\DC2\EOT\206\STX\STX(\SUB9 References to attributes in attribute_table. [optional]\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\n\
    \\EOT\DC2\EOT\206\STX\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\n\
    \\ENQ\DC2\EOT\206\STX\v\DLE\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\n\
    \\SOH\DC2\EOT\206\STX\DC1\"\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\n\
    \\ETX\DC2\EOT\206\STX%'\n\
    \\150\SOH\n\
    \\STX\EOT\ENQ\DC2\ACK\211\STX\NUL\218\STX\SOH\SUB\135\SOH A pointer from a profile Sample to a trace Span.\n\
    \ Connects a profile sample to a trace span, identified by unique trace and span IDs.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\ENQ\SOH\DC2\EOT\211\STX\b\f\n\
    \l\n\
    \\EOT\EOT\ENQ\STX\NUL\DC2\EOT\214\STX\STX\NAK\SUB^ A unique identifier of a trace that this linked span is part of. The ID is a\n\
    \ 16-byte array.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\NUL\ENQ\DC2\EOT\214\STX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\NUL\SOH\DC2\EOT\214\STX\b\DLE\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\NUL\ETX\DC2\EOT\214\STX\DC3\DC4\n\
    \S\n\
    \\EOT\EOT\ENQ\STX\SOH\DC2\EOT\217\STX\STX\DC4\SUBE A unique identifier for the linked span. The ID is an 8-byte array.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\SOH\ENQ\DC2\EOT\217\STX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\SOH\SOH\DC2\EOT\217\STX\b\SI\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\SOH\ETX\DC2\EOT\217\STX\DC2\DC3\n\
    \B\n\
    \\STX\EOT\ACK\DC2\ACK\221\STX\NUL\227\STX\SOH\SUB4 ValueType describes the type and units of a value.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\ACK\SOH\DC2\EOT\221\STX\b\DC1\n\
    \;\n\
    \\EOT\EOT\ACK\STX\NUL\DC2\EOT\223\STX\STX\SUB\SUB- Index into ProfilesDictionary.string_table.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ACK\STX\NUL\ENQ\DC2\EOT\223\STX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\ACK\STX\NUL\SOH\DC2\EOT\223\STX\b\NAK\n\
    \\r\n\
    \\ENQ\EOT\ACK\STX\NUL\ETX\DC2\EOT\223\STX\CAN\EM\n\
    \;\n\
    \\EOT\EOT\ACK\STX\SOH\DC2\EOT\226\STX\STX\SUB\SUB- Index into ProfilesDictionary.string_table.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ACK\STX\SOH\ENQ\DC2\EOT\226\STX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\ACK\STX\SOH\SOH\DC2\EOT\226\STX\b\NAK\n\
    \\r\n\
    \\ENQ\EOT\ACK\STX\SOH\ETX\DC2\EOT\226\STX\CAN\EM\n\
    \\224\a\n\
    \\STX\EOT\a\DC2\ACK\251\STX\NUL\138\ETX\SOH\SUB\209\a Each Sample records values encountered in some program context. The program\n\
    \ context is typically a stack trace, perhaps augmented with auxiliary\n\
    \ information like the thread-id, some indicator of a higher level request\n\
    \ being handled etc.\n\
    \\n\
    \ A Sample MUST have have at least one values or timestamps_unix_nano entry. If\n\
    \ both fields are populated, they MUST contain the same number of elements, and\n\
    \ the elements at the same index MUST refer to the same event.\n\
    \\n\
    \ Examples of different ways of representing a sample with the total value of 10:\n\
    \\n\
    \ Report of a stacktrace at 10 timestamps (consumers must assume the value is 1 for each point):\n\
    \    values: []\n\
    \    timestamps_unix_nano: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]\n\
    \\n\
    \ Report of a stacktrace with an aggregated value without timestamps:\n\
    \   values: [10]\n\
    \    timestamps_unix_nano: []\n\
    \\n\
    \ Report of a stacktrace at 4 timestamps where each point records a specific value:\n\
    \    values: [2, 2, 3, 3]\n\
    \    timestamps_unix_nano: [1, 2, 3, 4]\n\
    \\n\
    \\v\n\
    \\ETX\EOT\a\SOH\DC2\EOT\251\STX\b\SO\n\
    \E\n\
    \\EOT\EOT\a\STX\NUL\DC2\EOT\253\STX\STX\CAN\SUB7 Reference to stack in ProfilesDictionary.stack_table.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\a\STX\NUL\ENQ\DC2\EOT\253\STX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\a\STX\NUL\SOH\DC2\EOT\253\STX\b\DC3\n\
    \\r\n\
    \\ENQ\EOT\a\STX\NUL\ETX\DC2\EOT\253\STX\SYN\ETB\n\
    \R\n\
    \\EOT\EOT\a\STX\SOH\DC2\EOT\255\STX\STX\FS\SUBD The type and unit of each value is defined by Profile.sample_type.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\a\STX\SOH\EOT\DC2\EOT\255\STX\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\a\STX\SOH\ENQ\DC2\EOT\255\STX\v\DLE\n\
    \\r\n\
    \\ENQ\EOT\a\STX\SOH\SOH\DC2\EOT\255\STX\DC1\ETB\n\
    \\r\n\
    \\ENQ\EOT\a\STX\SOH\ETX\DC2\EOT\255\STX\SUB\ESC\n\
    \Z\n\
    \\EOT\EOT\a\STX\STX\DC2\EOT\129\ETX\STX'\SUBL References to attributes in ProfilesDictionary.attribute_table. [optional]\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\a\STX\STX\EOT\DC2\EOT\129\ETX\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\a\STX\STX\ENQ\DC2\EOT\129\ETX\v\DLE\n\
    \\r\n\
    \\ENQ\EOT\a\STX\STX\SOH\DC2\EOT\129\ETX\DC1\"\n\
    \\r\n\
    \\ENQ\EOT\a\STX\STX\ETX\DC2\EOT\129\ETX%&\n\
    \\177\SOH\n\
    \\EOT\EOT\a\STX\ETX\DC2\EOT\133\ETX\STX\ETB\SUB\162\SOH Reference to link in ProfilesDictionary.link_table. [optional]\n\
    \ It can be unset / set to 0 if no link exists, as link_table[0] is always a 'null' default value.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\a\STX\ETX\ENQ\DC2\EOT\133\ETX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\a\STX\ETX\SOH\DC2\EOT\133\ETX\b\DC2\n\
    \\r\n\
    \\ENQ\EOT\a\STX\ETX\ETX\DC2\EOT\133\ETX\NAK\SYN\n\
    \\140\SOH\n\
    \\EOT\EOT\a\STX\EOT\DC2\EOT\137\ETX\STX,\SUB~ Timestamps associated with Sample represented in nanoseconds. These\n\
    \ timestamps should fall within the Profile's time range.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\a\STX\EOT\EOT\DC2\EOT\137\ETX\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\a\STX\EOT\ENQ\DC2\EOT\137\ETX\v\DC2\n\
    \\r\n\
    \\ENQ\EOT\a\STX\EOT\SOH\DC2\EOT\137\ETX\DC3'\n\
    \\r\n\
    \\ENQ\EOT\a\STX\EOT\ETX\DC2\EOT\137\ETX*+\n\
    \\130\SOH\n\
    \\STX\EOT\b\DC2\ACK\142\ETX\NUL\155\ETX\SOH\SUBt Describes the mapping of a binary in memory, including its address range,\n\
    \ file offset, and metadata like build ID\n\
    \\n\
    \\v\n\
    \\ETX\EOT\b\SOH\DC2\EOT\142\ETX\b\SI\n\
    \K\n\
    \\EOT\EOT\b\STX\NUL\DC2\EOT\144\ETX\STX\SUB\SUB= Address at which the binary (or DLL) is loaded into memory.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\b\STX\NUL\ENQ\DC2\EOT\144\ETX\STX\b\n\
    \\r\n\
    \\ENQ\EOT\b\STX\NUL\SOH\DC2\EOT\144\ETX\t\NAK\n\
    \\r\n\
    \\ENQ\EOT\b\STX\NUL\ETX\DC2\EOT\144\ETX\CAN\EM\n\
    \H\n\
    \\EOT\EOT\b\STX\SOH\DC2\EOT\146\ETX\STX\SUB\SUB: The limit of the address range occupied by this mapping.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\b\STX\SOH\ENQ\DC2\EOT\146\ETX\STX\b\n\
    \\r\n\
    \\ENQ\EOT\b\STX\SOH\SOH\DC2\EOT\146\ETX\t\NAK\n\
    \\r\n\
    \\ENQ\EOT\b\STX\SOH\ETX\DC2\EOT\146\ETX\CAN\EM\n\
    \R\n\
    \\EOT\EOT\b\STX\STX\DC2\EOT\148\ETX\STX\EM\SUBD Offset in the binary that corresponds to the first mapped address.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\b\STX\STX\ENQ\DC2\EOT\148\ETX\STX\b\n\
    \\r\n\
    \\ENQ\EOT\b\STX\STX\SOH\DC2\EOT\148\ETX\t\DC4\n\
    \\r\n\
    \\ENQ\EOT\b\STX\STX\ETX\DC2\EOT\148\ETX\ETB\CAN\n\
    \\216\SOH\n\
    \\EOT\EOT\b\STX\ETX\DC2\EOT\152\ETX\STX\RS\SUB\154\SOH The object this entry is loaded from.  This can be a filename on\n\
    \ disk for the main binary and shared libraries, or virtual\n\
    \ abstractions like \"[vdso]\".\n\
    \\"- Index into ProfilesDictionary.string_table.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\b\STX\ETX\ENQ\DC2\EOT\152\ETX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\b\STX\ETX\SOH\DC2\EOT\152\ETX\b\EM\n\
    \\r\n\
    \\ENQ\EOT\b\STX\ETX\ETX\DC2\EOT\152\ETX\FS\GS\n\
    \Z\n\
    \\EOT\EOT\b\STX\EOT\DC2\EOT\154\ETX\STX'\SUBL References to attributes in ProfilesDictionary.attribute_table. [optional]\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\b\STX\EOT\EOT\DC2\EOT\154\ETX\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\b\STX\EOT\ENQ\DC2\EOT\154\ETX\v\DLE\n\
    \\r\n\
    \\ENQ\EOT\b\STX\EOT\SOH\DC2\EOT\154\ETX\DC1\"\n\
    \\r\n\
    \\ENQ\EOT\b\STX\EOT\ETX\DC2\EOT\154\ETX%&\n\
    \H\n\
    \\STX\EOT\t\DC2\ACK\158\ETX\NUL\162\ETX\SOH\SUB: A Stack represents a stack trace as a list of locations.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\t\SOH\DC2\EOT\158\ETX\b\r\n\
    \t\n\
    \\EOT\EOT\t\STX\NUL\DC2\EOT\161\ETX\STX&\SUBf References to locations in ProfilesDictionary.location_table.\n\
    \ The first location is the leaf frame.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\t\STX\NUL\EOT\DC2\EOT\161\ETX\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\t\STX\NUL\ENQ\DC2\EOT\161\ETX\v\DLE\n\
    \\r\n\
    \\ENQ\EOT\t\STX\NUL\SOH\DC2\EOT\161\ETX\DC1!\n\
    \\r\n\
    \\ENQ\EOT\t\STX\NUL\ETX\DC2\EOT\161\ETX$%\n\
    \D\n\
    \\STX\EOT\n\
    \\DC2\ACK\165\ETX\NUL\186\ETX\SOH\SUB6 Describes function and line table debug information.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\n\
    \\SOH\DC2\EOT\165\ETX\b\DLE\n\
    \\226\SOH\n\
    \\EOT\EOT\n\
    \\STX\NUL\DC2\EOT\169\ETX\STX\SUB\SUB\211\SOH Reference to mapping in ProfilesDictionary.mapping_table.\n\
    \ It can be unset / set to 0 if the mapping is unknown or not applicable for\n\
    \ this profile type, as mapping_table[0] is always a 'null' default mapping.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\NUL\ENQ\DC2\EOT\169\ETX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\NUL\SOH\DC2\EOT\169\ETX\b\NAK\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\NUL\ETX\DC2\EOT\169\ETX\CAN\EM\n\
    \\191\STX\n\
    \\EOT\EOT\n\
    \\STX\SOH\DC2\EOT\175\ETX\STX\NAK\SUB\176\STX The instruction address for this location, if available.  It\n\
    \ should be within [Mapping.memory_start...Mapping.memory_limit]\n\
    \ for the corresponding mapping. A non-leaf address may be in the\n\
    \ middle of a call instruction. It is up to display tools to find\n\
    \ the beginning of the instruction if necessary.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\SOH\ENQ\DC2\EOT\175\ETX\STX\b\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\SOH\SOH\DC2\EOT\175\ETX\t\DLE\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\SOH\ETX\DC2\EOT\175\ETX\DC3\DC4\n\
    \\163\STX\n\
    \\EOT\EOT\n\
    \\STX\STX\DC2\EOT\183\ETX\STX\SUB\SUB\148\STX Multiple line indicates this location has inlined functions,\n\
    \ where the last entry represents the caller into which the\n\
    \ preceding entries were inlined.\n\
    \\n\
    \ E.g., if memcpy() is inlined into printf:\n\
    \    lines[0].function_name == \"memcpy\"\n\
    \    lines[1].function_name == \"printf\"\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\STX\EOT\DC2\EOT\183\ETX\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\STX\ACK\DC2\EOT\183\ETX\v\SI\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\STX\SOH\DC2\EOT\183\ETX\DLE\NAK\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\STX\ETX\DC2\EOT\183\ETX\CAN\EM\n\
    \Z\n\
    \\EOT\EOT\n\
    \\STX\ETX\DC2\EOT\185\ETX\STX'\SUBL References to attributes in ProfilesDictionary.attribute_table. [optional]\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\ETX\EOT\DC2\EOT\185\ETX\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\ETX\ENQ\DC2\EOT\185\ETX\v\DLE\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\ETX\SOH\DC2\EOT\185\ETX\DC1\"\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\ETX\ETX\DC2\EOT\185\ETX%&\n\
    \O\n\
    \\STX\EOT\v\DC2\ACK\189\ETX\NUL\196\ETX\SOH\SUBA Details a specific line in a source code, linked to a function.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\v\SOH\DC2\EOT\189\ETX\b\f\n\
    \K\n\
    \\EOT\EOT\v\STX\NUL\DC2\EOT\191\ETX\STX\ESC\SUB= Reference to function in ProfilesDictionary.function_table.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\v\STX\NUL\ENQ\DC2\EOT\191\ETX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\v\STX\NUL\SOH\DC2\EOT\191\ETX\b\SYN\n\
    \\r\n\
    \\ENQ\EOT\v\STX\NUL\ETX\DC2\EOT\191\ETX\EM\SUB\n\
    \:\n\
    \\EOT\EOT\v\STX\SOH\DC2\EOT\193\ETX\STX\DC1\SUB, Line number in source code. 0 means unset.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\v\STX\SOH\ENQ\DC2\EOT\193\ETX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\v\STX\SOH\SOH\DC2\EOT\193\ETX\b\f\n\
    \\r\n\
    \\ENQ\EOT\v\STX\SOH\ETX\DC2\EOT\193\ETX\SI\DLE\n\
    \<\n\
    \\EOT\EOT\v\STX\STX\DC2\EOT\195\ETX\STX\DC3\SUB. Column number in source code. 0 means unset.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\v\STX\STX\ENQ\DC2\EOT\195\ETX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\v\STX\STX\SOH\DC2\EOT\195\ETX\b\SO\n\
    \\r\n\
    \\ENQ\EOT\v\STX\STX\ETX\DC2\EOT\195\ETX\DC1\DC2\n\
    \\139\SOH\n\
    \\STX\EOT\f\DC2\ACK\200\ETX\NUL\210\ETX\SOH\SUB} Describes a function, including its human-readable name, system name,\n\
    \ source file, and starting line number in the source.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\f\SOH\DC2\EOT\200\ETX\b\DLE\n\
    \A\n\
    \\EOT\EOT\f\STX\NUL\DC2\EOT\202\ETX\STX\SUB\SUB3 The function name. Empty string if not available.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\f\STX\NUL\ENQ\DC2\EOT\202\ETX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\f\STX\NUL\SOH\DC2\EOT\202\ETX\b\NAK\n\
    \\r\n\
    \\ENQ\EOT\f\STX\NUL\ETX\DC2\EOT\202\ETX\CAN\EM\n\
    \\135\SOH\n\
    \\EOT\EOT\f\STX\SOH\DC2\EOT\205\ETX\STX!\SUBy Function name, as identified by the system. For instance,\n\
    \ it can be a C++ mangled name. Empty string if not available.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\f\STX\SOH\ENQ\DC2\EOT\205\ETX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\f\STX\SOH\SOH\DC2\EOT\205\ETX\b\FS\n\
    \\r\n\
    \\ENQ\EOT\f\STX\SOH\ETX\DC2\EOT\205\ETX\US \n\
    \S\n\
    \\EOT\EOT\f\STX\STX\DC2\EOT\207\ETX\STX\RS\SUBE Source file containing the function. Empty string if not available.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\f\STX\STX\ENQ\DC2\EOT\207\ETX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\f\STX\STX\SOH\DC2\EOT\207\ETX\b\EM\n\
    \\r\n\
    \\ENQ\EOT\f\STX\STX\ETX\DC2\EOT\207\ETX\FS\GS\n\
    \:\n\
    \\EOT\EOT\f\STX\ETX\DC2\EOT\209\ETX\STX\ETB\SUB, Line number in source file. 0 means unset.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\f\STX\ETX\ENQ\DC2\EOT\209\ETX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\f\STX\ETX\SOH\DC2\EOT\209\ETX\b\DC2\n\
    \\r\n\
    \\ENQ\EOT\f\STX\ETX\ETX\DC2\EOT\209\ETX\NAK\SYN\n\
    \\241\SOH\n\
    \\STX\EOT\r\DC2\ACK\215\ETX\NUL\223\ETX\SOH\SUB\226\SOH A custom 'dictionary native' style of encoding attributes which is more convenient\n\
    \ for profiles than opentelemetry.proto.common.v1.KeyValue\n\
    \ Specifically, uses the string table for keys and allows optional unit information.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\r\SOH\DC2\EOT\215\ETX\b\ETB\n\
    \H\n\
    \\EOT\EOT\r\STX\NUL\DC2\EOT\217\ETX\STX\SUB\SUB: The index into the string table for the attribute's key.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\r\STX\NUL\ENQ\DC2\EOT\217\ETX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\r\STX\NUL\SOH\DC2\EOT\217\ETX\b\DC4\n\
    \\r\n\
    \\ENQ\EOT\r\STX\NUL\ETX\DC2\EOT\217\ETX\CAN\EM\n\
    \+\n\
    \\EOT\EOT\r\STX\SOH\DC2\EOT\219\ETX\STX3\SUB\GS The value of the attribute.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\r\STX\SOH\ACK\DC2\EOT\219\ETX\STX(\n\
    \\r\n\
    \\ENQ\EOT\r\STX\SOH\SOH\DC2\EOT\219\ETX).\n\
    \\r\n\
    \\ENQ\EOT\r\STX\SOH\ETX\DC2\EOT\219\ETX12\n\
    \\132\SOH\n\
    \\EOT\EOT\r\STX\STX\DC2\EOT\222\ETX\STX\SUB\SUBv The index into the string table for the attribute's unit.\n\
    \ zero indicates implicit (by semconv) or non-defined unit.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\r\STX\STX\ENQ\DC2\EOT\222\ETX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\r\STX\STX\SOH\DC2\EOT\222\ETX\b\NAK\n\
    \\r\n\
    \\ENQ\EOT\r\STX\STX\ETX\DC2\EOT\222\ETX\CAN\EMb\ACKproto3"