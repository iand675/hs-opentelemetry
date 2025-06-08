{- HLINT ignore -}
{- This file was auto-generated from opentelemetry/proto/profiles/v1development/profiles.proto by the proto-lens-protoc program. -}
{-# LANGUAGE ScopedTypeVariables, DataKinds, TypeFamilies, UndecidableInstances, GeneralizedNewtypeDeriving, MultiParamTypeClasses, FlexibleContexts, FlexibleInstances, PatternSynonyms, MagicHash, NoImplicitPrelude, DataKinds, BangPatterns, TypeApplications, OverloadedStrings, DerivingStrategies#-}
{-# OPTIONS_GHC -Wno-unused-imports#-}
{-# OPTIONS_GHC -Wno-duplicate-exports#-}
{-# OPTIONS_GHC -Wno-dodgy-exports#-}
module Proto.Opentelemetry.Proto.Profiles.V1development.Profiles (
        AggregationTemporality(..), AggregationTemporality(),
        AggregationTemporality'UnrecognizedValue, AttributeUnit(),
        Function(), Line(), Link(), Location(), Mapping(), Profile(),
        ProfilesData(), ProfilesDictionary(), ResourceProfiles(), Sample(),
        ScopeProfiles(), ValueType()
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
newtype AggregationTemporality'UnrecognizedValue
  = AggregationTemporality'UnrecognizedValue Data.Int.Int32
  deriving stock (Prelude.Eq, Prelude.Ord, Prelude.Show)
data AggregationTemporality
  = AGGREGATION_TEMPORALITY_UNSPECIFIED |
    AGGREGATION_TEMPORALITY_DELTA |
    AGGREGATION_TEMPORALITY_CUMULATIVE |
    AggregationTemporality'Unrecognized !AggregationTemporality'UnrecognizedValue
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
instance Data.ProtoLens.MessageEnum AggregationTemporality where
  maybeToEnum 0 = Prelude.Just AGGREGATION_TEMPORALITY_UNSPECIFIED
  maybeToEnum 1 = Prelude.Just AGGREGATION_TEMPORALITY_DELTA
  maybeToEnum 2 = Prelude.Just AGGREGATION_TEMPORALITY_CUMULATIVE
  maybeToEnum k
    = Prelude.Just
        (AggregationTemporality'Unrecognized
           (AggregationTemporality'UnrecognizedValue
              (Prelude.fromIntegral k)))
  showEnum AGGREGATION_TEMPORALITY_UNSPECIFIED
    = "AGGREGATION_TEMPORALITY_UNSPECIFIED"
  showEnum AGGREGATION_TEMPORALITY_DELTA
    = "AGGREGATION_TEMPORALITY_DELTA"
  showEnum AGGREGATION_TEMPORALITY_CUMULATIVE
    = "AGGREGATION_TEMPORALITY_CUMULATIVE"
  showEnum
    (AggregationTemporality'Unrecognized (AggregationTemporality'UnrecognizedValue k))
    = Prelude.show k
  readEnum k
    | (Prelude.==) k "AGGREGATION_TEMPORALITY_UNSPECIFIED"
    = Prelude.Just AGGREGATION_TEMPORALITY_UNSPECIFIED
    | (Prelude.==) k "AGGREGATION_TEMPORALITY_DELTA"
    = Prelude.Just AGGREGATION_TEMPORALITY_DELTA
    | (Prelude.==) k "AGGREGATION_TEMPORALITY_CUMULATIVE"
    = Prelude.Just AGGREGATION_TEMPORALITY_CUMULATIVE
    | Prelude.otherwise
    = (Prelude.>>=) (Text.Read.readMaybe k) Data.ProtoLens.maybeToEnum
instance Prelude.Bounded AggregationTemporality where
  minBound = AGGREGATION_TEMPORALITY_UNSPECIFIED
  maxBound = AGGREGATION_TEMPORALITY_CUMULATIVE
instance Prelude.Enum AggregationTemporality where
  toEnum k__
    = Prelude.maybe
        (Prelude.error
           ((Prelude.++)
              "toEnum: unknown value for enum AggregationTemporality: "
              (Prelude.show k__)))
        Prelude.id (Data.ProtoLens.maybeToEnum k__)
  fromEnum AGGREGATION_TEMPORALITY_UNSPECIFIED = 0
  fromEnum AGGREGATION_TEMPORALITY_DELTA = 1
  fromEnum AGGREGATION_TEMPORALITY_CUMULATIVE = 2
  fromEnum
    (AggregationTemporality'Unrecognized (AggregationTemporality'UnrecognizedValue k))
    = Prelude.fromIntegral k
  succ AGGREGATION_TEMPORALITY_CUMULATIVE
    = Prelude.error
        "AggregationTemporality.succ: bad argument AGGREGATION_TEMPORALITY_CUMULATIVE. This value would be out of bounds."
  succ AGGREGATION_TEMPORALITY_UNSPECIFIED
    = AGGREGATION_TEMPORALITY_DELTA
  succ AGGREGATION_TEMPORALITY_DELTA
    = AGGREGATION_TEMPORALITY_CUMULATIVE
  succ (AggregationTemporality'Unrecognized _)
    = Prelude.error
        "AggregationTemporality.succ: bad argument: unrecognized value"
  pred AGGREGATION_TEMPORALITY_UNSPECIFIED
    = Prelude.error
        "AggregationTemporality.pred: bad argument AGGREGATION_TEMPORALITY_UNSPECIFIED. This value would be out of bounds."
  pred AGGREGATION_TEMPORALITY_DELTA
    = AGGREGATION_TEMPORALITY_UNSPECIFIED
  pred AGGREGATION_TEMPORALITY_CUMULATIVE
    = AGGREGATION_TEMPORALITY_DELTA
  pred (AggregationTemporality'Unrecognized _)
    = Prelude.error
        "AggregationTemporality.pred: bad argument: unrecognized value"
  enumFrom = Data.ProtoLens.Message.Enum.messageEnumFrom
  enumFromTo = Data.ProtoLens.Message.Enum.messageEnumFromTo
  enumFromThen = Data.ProtoLens.Message.Enum.messageEnumFromThen
  enumFromThenTo = Data.ProtoLens.Message.Enum.messageEnumFromThenTo
instance Data.ProtoLens.FieldDefault AggregationTemporality where
  fieldDefault = AGGREGATION_TEMPORALITY_UNSPECIFIED
instance Control.DeepSeq.NFData AggregationTemporality where
  rnf x__ = Prelude.seq x__ ()
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.attributeKeyStrindex' @:: Lens' AttributeUnit Data.Int.Int32@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.unitStrindex' @:: Lens' AttributeUnit Data.Int.Int32@ -}
data AttributeUnit
  = AttributeUnit'_constructor {_AttributeUnit'attributeKeyStrindex :: !Data.Int.Int32,
                                _AttributeUnit'unitStrindex :: !Data.Int.Int32,
                                _AttributeUnit'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show AttributeUnit where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField AttributeUnit "attributeKeyStrindex" Data.Int.Int32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AttributeUnit'attributeKeyStrindex
           (\ x__ y__ -> x__ {_AttributeUnit'attributeKeyStrindex = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField AttributeUnit "unitStrindex" Data.Int.Int32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _AttributeUnit'unitStrindex
           (\ x__ y__ -> x__ {_AttributeUnit'unitStrindex = y__}))
        Prelude.id
instance Data.ProtoLens.Message AttributeUnit where
  messageName _
    = Data.Text.pack
        "opentelemetry.proto.profiles.v1development.AttributeUnit"
  packedMessageDescriptor _
    = "\n\
      \\rAttributeUnit\DC24\n\
      \\SYNattribute_key_strindex\CAN\SOH \SOH(\ENQR\DC4attributeKeyStrindex\DC2#\n\
      \\runit_strindex\CAN\STX \SOH(\ENQR\funitStrindex"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        attributeKeyStrindex__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "attribute_key_strindex"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"attributeKeyStrindex")) ::
              Data.ProtoLens.FieldDescriptor AttributeUnit
        unitStrindex__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "unit_strindex"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"unitStrindex")) ::
              Data.ProtoLens.FieldDescriptor AttributeUnit
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, attributeKeyStrindex__field_descriptor),
           (Data.ProtoLens.Tag 2, unitStrindex__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _AttributeUnit'_unknownFields
        (\ x__ y__ -> x__ {_AttributeUnit'_unknownFields = y__})
  defMessage
    = AttributeUnit'_constructor
        {_AttributeUnit'attributeKeyStrindex = Data.ProtoLens.fieldDefault,
         _AttributeUnit'unitStrindex = Data.ProtoLens.fieldDefault,
         _AttributeUnit'_unknownFields = []}
  parseMessage
    = let
        loop ::
          AttributeUnit -> Data.ProtoLens.Encoding.Bytes.Parser AttributeUnit
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
                                       "attribute_key_strindex"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"attributeKeyStrindex") y x)
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
          (do loop Data.ProtoLens.defMessage) "AttributeUnit"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v
                  = Lens.Family2.view
                      (Data.ProtoLens.Field.field @"attributeKeyStrindex") _x
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
instance Control.DeepSeq.NFData AttributeUnit where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_AttributeUnit'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_AttributeUnit'attributeKeyStrindex x__)
                (Control.DeepSeq.deepseq (_AttributeUnit'unitStrindex x__) ()))
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
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.maybe'mappingIndex' @:: Lens' Location (Prelude.Maybe Data.Int.Int32)@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.address' @:: Lens' Location Data.Word.Word64@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.line' @:: Lens' Location [Line]@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.vec'line' @:: Lens' Location (Data.Vector.Vector Line)@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.isFolded' @:: Lens' Location Prelude.Bool@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.attributeIndices' @:: Lens' Location [Data.Int.Int32]@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.vec'attributeIndices' @:: Lens' Location (Data.Vector.Unboxed.Vector Data.Int.Int32)@ -}
data Location
  = Location'_constructor {_Location'mappingIndex :: !(Prelude.Maybe Data.Int.Int32),
                           _Location'address :: !Data.Word.Word64,
                           _Location'line :: !(Data.Vector.Vector Line),
                           _Location'isFolded :: !Prelude.Bool,
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
        (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault)
instance Data.ProtoLens.Field.HasField Location "maybe'mappingIndex" (Prelude.Maybe Data.Int.Int32) where
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
instance Data.ProtoLens.Field.HasField Location "line" [Line] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Location'line (\ x__ y__ -> x__ {_Location'line = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField Location "vec'line" (Data.Vector.Vector Line) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Location'line (\ x__ y__ -> x__ {_Location'line = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Location "isFolded" Prelude.Bool where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Location'isFolded (\ x__ y__ -> x__ {_Location'isFolded = y__}))
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
      \\bLocation\DC2(\n\
      \\rmapping_index\CAN\SOH \SOH(\ENQH\NULR\fmappingIndex\136\SOH\SOH\DC2\CAN\n\
      \\aaddress\CAN\STX \SOH(\EOTR\aaddress\DC2D\n\
      \\EOTline\CAN\ETX \ETX(\v20.opentelemetry.proto.profiles.v1development.LineR\EOTline\DC2\ESC\n\
      \\tis_folded\CAN\EOT \SOH(\bR\bisFolded\DC2+\n\
      \\DC1attribute_indices\CAN\ENQ \ETX(\ENQR\DLEattributeIndicesB\DLE\n\
      \\SO_mapping_index"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        mappingIndex__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "mapping_index"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int32)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'mappingIndex")) ::
              Data.ProtoLens.FieldDescriptor Location
        address__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "address"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"address")) ::
              Data.ProtoLens.FieldDescriptor Location
        line__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "line"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Line)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked (Data.ProtoLens.Field.field @"line")) ::
              Data.ProtoLens.FieldDescriptor Location
        isFolded__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "is_folded"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BoolField ::
                 Data.ProtoLens.FieldTypeDescriptor Prelude.Bool)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"isFolded")) ::
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
           (Data.ProtoLens.Tag 3, line__field_descriptor),
           (Data.ProtoLens.Tag 4, isFolded__field_descriptor),
           (Data.ProtoLens.Tag 5, attributeIndices__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Location'_unknownFields
        (\ x__ y__ -> x__ {_Location'_unknownFields = y__})
  defMessage
    = Location'_constructor
        {_Location'mappingIndex = Prelude.Nothing,
         _Location'address = Data.ProtoLens.fieldDefault,
         _Location'line = Data.Vector.Generic.empty,
         _Location'isFolded = Data.ProtoLens.fieldDefault,
         _Location'attributeIndices = Data.Vector.Generic.empty,
         _Location'_unknownFields = []}
  parseMessage
    = let
        loop ::
          Location
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Unboxed.Vector Data.ProtoLens.Encoding.Growing.RealWorld Data.Int.Int32
             -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Line
                -> Data.ProtoLens.Encoding.Bytes.Parser Location
        loop x mutable'attributeIndices mutable'line
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'attributeIndices <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                   (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                      mutable'attributeIndices)
                      frozen'line <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.unsafeFreeze mutable'line)
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
                                 (Data.ProtoLens.Field.field @"vec'line") frozen'line x)))
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
                                  mutable'attributeIndices mutable'line
                        16
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "address"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"address") y x)
                                  mutable'attributeIndices mutable'line
                        26
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "line"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'line y)
                                loop x mutable'attributeIndices v
                        32
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          ((Prelude./=) 0) Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "is_folded"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"isFolded") y x)
                                  mutable'attributeIndices mutable'line
                        40
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (Prelude.fmap
                                           Prelude.fromIntegral
                                           Data.ProtoLens.Encoding.Bytes.getVarInt)
                                        "attribute_indices"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append
                                          mutable'attributeIndices y)
                                loop x v mutable'line
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
                                loop x y mutable'line
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'attributeIndices mutable'line
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'attributeIndices <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                            Data.ProtoLens.Encoding.Growing.new
              mutable'line <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                Data.ProtoLens.Encoding.Growing.new
              loop
                Data.ProtoLens.defMessage mutable'attributeIndices mutable'line)
          "Location"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view
                    (Data.ProtoLens.Field.field @"maybe'mappingIndex") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just _v)
                  -> (Data.Monoid.<>)
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
                      (Lens.Family2.view (Data.ProtoLens.Field.field @"vec'line") _x))
                   ((Data.Monoid.<>)
                      (let
                         _v = Lens.Family2.view (Data.ProtoLens.Field.field @"isFolded") _x
                       in
                         if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                             Data.Monoid.mempty
                         else
                             (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt 32)
                               ((Prelude..)
                                  Data.ProtoLens.Encoding.Bytes.putVarInt
                                  (\ b -> if b then 1 else 0) _v))
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
                      (_Location'line x__)
                      (Control.DeepSeq.deepseq
                         (_Location'isFolded x__)
                         (Control.DeepSeq.deepseq (_Location'attributeIndices x__) ())))))
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.memoryStart' @:: Lens' Mapping Data.Word.Word64@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.memoryLimit' @:: Lens' Mapping Data.Word.Word64@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.fileOffset' @:: Lens' Mapping Data.Word.Word64@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.filenameStrindex' @:: Lens' Mapping Data.Int.Int32@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.attributeIndices' @:: Lens' Mapping [Data.Int.Int32]@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.vec'attributeIndices' @:: Lens' Mapping (Data.Vector.Unboxed.Vector Data.Int.Int32)@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.hasFunctions' @:: Lens' Mapping Prelude.Bool@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.hasFilenames' @:: Lens' Mapping Prelude.Bool@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.hasLineNumbers' @:: Lens' Mapping Prelude.Bool@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.hasInlineFrames' @:: Lens' Mapping Prelude.Bool@ -}
data Mapping
  = Mapping'_constructor {_Mapping'memoryStart :: !Data.Word.Word64,
                          _Mapping'memoryLimit :: !Data.Word.Word64,
                          _Mapping'fileOffset :: !Data.Word.Word64,
                          _Mapping'filenameStrindex :: !Data.Int.Int32,
                          _Mapping'attributeIndices :: !(Data.Vector.Unboxed.Vector Data.Int.Int32),
                          _Mapping'hasFunctions :: !Prelude.Bool,
                          _Mapping'hasFilenames :: !Prelude.Bool,
                          _Mapping'hasLineNumbers :: !Prelude.Bool,
                          _Mapping'hasInlineFrames :: !Prelude.Bool,
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
instance Data.ProtoLens.Field.HasField Mapping "hasFunctions" Prelude.Bool where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Mapping'hasFunctions
           (\ x__ y__ -> x__ {_Mapping'hasFunctions = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Mapping "hasFilenames" Prelude.Bool where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Mapping'hasFilenames
           (\ x__ y__ -> x__ {_Mapping'hasFilenames = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Mapping "hasLineNumbers" Prelude.Bool where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Mapping'hasLineNumbers
           (\ x__ y__ -> x__ {_Mapping'hasLineNumbers = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Mapping "hasInlineFrames" Prelude.Bool where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Mapping'hasInlineFrames
           (\ x__ y__ -> x__ {_Mapping'hasInlineFrames = y__}))
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
      \\DC1attribute_indices\CAN\ENQ \ETX(\ENQR\DLEattributeIndices\DC2#\n\
      \\rhas_functions\CAN\ACK \SOH(\bR\fhasFunctions\DC2#\n\
      \\rhas_filenames\CAN\a \SOH(\bR\fhasFilenames\DC2(\n\
      \\DLEhas_line_numbers\CAN\b \SOH(\bR\SOhasLineNumbers\DC2*\n\
      \\DC1has_inline_frames\CAN\t \SOH(\bR\SIhasInlineFrames"
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
        hasFunctions__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "has_functions"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BoolField ::
                 Data.ProtoLens.FieldTypeDescriptor Prelude.Bool)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"hasFunctions")) ::
              Data.ProtoLens.FieldDescriptor Mapping
        hasFilenames__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "has_filenames"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BoolField ::
                 Data.ProtoLens.FieldTypeDescriptor Prelude.Bool)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"hasFilenames")) ::
              Data.ProtoLens.FieldDescriptor Mapping
        hasLineNumbers__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "has_line_numbers"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BoolField ::
                 Data.ProtoLens.FieldTypeDescriptor Prelude.Bool)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"hasLineNumbers")) ::
              Data.ProtoLens.FieldDescriptor Mapping
        hasInlineFrames__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "has_inline_frames"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BoolField ::
                 Data.ProtoLens.FieldTypeDescriptor Prelude.Bool)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"hasInlineFrames")) ::
              Data.ProtoLens.FieldDescriptor Mapping
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, memoryStart__field_descriptor),
           (Data.ProtoLens.Tag 2, memoryLimit__field_descriptor),
           (Data.ProtoLens.Tag 3, fileOffset__field_descriptor),
           (Data.ProtoLens.Tag 4, filenameStrindex__field_descriptor),
           (Data.ProtoLens.Tag 5, attributeIndices__field_descriptor),
           (Data.ProtoLens.Tag 6, hasFunctions__field_descriptor),
           (Data.ProtoLens.Tag 7, hasFilenames__field_descriptor),
           (Data.ProtoLens.Tag 8, hasLineNumbers__field_descriptor),
           (Data.ProtoLens.Tag 9, hasInlineFrames__field_descriptor)]
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
         _Mapping'hasFunctions = Data.ProtoLens.fieldDefault,
         _Mapping'hasFilenames = Data.ProtoLens.fieldDefault,
         _Mapping'hasLineNumbers = Data.ProtoLens.fieldDefault,
         _Mapping'hasInlineFrames = Data.ProtoLens.fieldDefault,
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
                        48
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          ((Prelude./=) 0) Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "has_functions"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"hasFunctions") y x)
                                  mutable'attributeIndices
                        56
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          ((Prelude./=) 0) Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "has_filenames"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"hasFilenames") y x)
                                  mutable'attributeIndices
                        64
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          ((Prelude./=) 0) Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "has_line_numbers"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"hasLineNumbers") y x)
                                  mutable'attributeIndices
                        72
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          ((Prelude./=) 0) Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "has_inline_frames"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"hasInlineFrames") y x)
                                  mutable'attributeIndices
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
                         ((Data.Monoid.<>)
                            (let
                               _v
                                 = Lens.Family2.view (Data.ProtoLens.Field.field @"hasFunctions") _x
                             in
                               if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                   Data.Monoid.mempty
                               else
                                   (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt 48)
                                     ((Prelude..)
                                        Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (\ b -> if b then 1 else 0) _v))
                            ((Data.Monoid.<>)
                               (let
                                  _v
                                    = Lens.Family2.view
                                        (Data.ProtoLens.Field.field @"hasFilenames") _x
                                in
                                  if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                      Data.Monoid.mempty
                                  else
                                      (Data.Monoid.<>)
                                        (Data.ProtoLens.Encoding.Bytes.putVarInt 56)
                                        ((Prelude..)
                                           Data.ProtoLens.Encoding.Bytes.putVarInt
                                           (\ b -> if b then 1 else 0) _v))
                               ((Data.Monoid.<>)
                                  (let
                                     _v
                                       = Lens.Family2.view
                                           (Data.ProtoLens.Field.field @"hasLineNumbers") _x
                                   in
                                     if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                         Data.Monoid.mempty
                                     else
                                         (Data.Monoid.<>)
                                           (Data.ProtoLens.Encoding.Bytes.putVarInt 64)
                                           ((Prelude..)
                                              Data.ProtoLens.Encoding.Bytes.putVarInt
                                              (\ b -> if b then 1 else 0) _v))
                                  ((Data.Monoid.<>)
                                     (let
                                        _v
                                          = Lens.Family2.view
                                              (Data.ProtoLens.Field.field @"hasInlineFrames") _x
                                      in
                                        if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                            Data.Monoid.mempty
                                        else
                                            (Data.Monoid.<>)
                                              (Data.ProtoLens.Encoding.Bytes.putVarInt 72)
                                              ((Prelude..)
                                                 Data.ProtoLens.Encoding.Bytes.putVarInt
                                                 (\ b -> if b then 1 else 0) _v))
                                     (Data.ProtoLens.Encoding.Wire.buildFieldSet
                                        (Lens.Family2.view Data.ProtoLens.unknownFields _x))))))))))
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
                         (Control.DeepSeq.deepseq
                            (_Mapping'attributeIndices x__)
                            (Control.DeepSeq.deepseq
                               (_Mapping'hasFunctions x__)
                               (Control.DeepSeq.deepseq
                                  (_Mapping'hasFilenames x__)
                                  (Control.DeepSeq.deepseq
                                     (_Mapping'hasLineNumbers x__)
                                     (Control.DeepSeq.deepseq
                                        (_Mapping'hasInlineFrames x__) ())))))))))
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.sampleType' @:: Lens' Profile [ValueType]@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.vec'sampleType' @:: Lens' Profile (Data.Vector.Vector ValueType)@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.sample' @:: Lens' Profile [Sample]@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.vec'sample' @:: Lens' Profile (Data.Vector.Vector Sample)@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.locationIndices' @:: Lens' Profile [Data.Int.Int32]@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.vec'locationIndices' @:: Lens' Profile (Data.Vector.Unboxed.Vector Data.Int.Int32)@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.timeNanos' @:: Lens' Profile Data.Int.Int64@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.durationNanos' @:: Lens' Profile Data.Int.Int64@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.periodType' @:: Lens' Profile ValueType@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.maybe'periodType' @:: Lens' Profile (Prelude.Maybe ValueType)@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.period' @:: Lens' Profile Data.Int.Int64@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.commentStrindices' @:: Lens' Profile [Data.Int.Int32]@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.vec'commentStrindices' @:: Lens' Profile (Data.Vector.Unboxed.Vector Data.Int.Int32)@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.defaultSampleTypeIndex' @:: Lens' Profile Data.Int.Int32@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.profileId' @:: Lens' Profile Data.ByteString.ByteString@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.droppedAttributesCount' @:: Lens' Profile Data.Word.Word32@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.originalPayloadFormat' @:: Lens' Profile Data.Text.Text@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.originalPayload' @:: Lens' Profile Data.ByteString.ByteString@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.attributeIndices' @:: Lens' Profile [Data.Int.Int32]@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.vec'attributeIndices' @:: Lens' Profile (Data.Vector.Unboxed.Vector Data.Int.Int32)@ -}
data Profile
  = Profile'_constructor {_Profile'sampleType :: !(Data.Vector.Vector ValueType),
                          _Profile'sample :: !(Data.Vector.Vector Sample),
                          _Profile'locationIndices :: !(Data.Vector.Unboxed.Vector Data.Int.Int32),
                          _Profile'timeNanos :: !Data.Int.Int64,
                          _Profile'durationNanos :: !Data.Int.Int64,
                          _Profile'periodType :: !(Prelude.Maybe ValueType),
                          _Profile'period :: !Data.Int.Int64,
                          _Profile'commentStrindices :: !(Data.Vector.Unboxed.Vector Data.Int.Int32),
                          _Profile'defaultSampleTypeIndex :: !Data.Int.Int32,
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
instance Data.ProtoLens.Field.HasField Profile "sampleType" [ValueType] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Profile'sampleType (\ x__ y__ -> x__ {_Profile'sampleType = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField Profile "vec'sampleType" (Data.Vector.Vector ValueType) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Profile'sampleType (\ x__ y__ -> x__ {_Profile'sampleType = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Profile "sample" [Sample] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Profile'sample (\ x__ y__ -> x__ {_Profile'sample = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField Profile "vec'sample" (Data.Vector.Vector Sample) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Profile'sample (\ x__ y__ -> x__ {_Profile'sample = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Profile "locationIndices" [Data.Int.Int32] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Profile'locationIndices
           (\ x__ y__ -> x__ {_Profile'locationIndices = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField Profile "vec'locationIndices" (Data.Vector.Unboxed.Vector Data.Int.Int32) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Profile'locationIndices
           (\ x__ y__ -> x__ {_Profile'locationIndices = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Profile "timeNanos" Data.Int.Int64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Profile'timeNanos (\ x__ y__ -> x__ {_Profile'timeNanos = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Profile "durationNanos" Data.Int.Int64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Profile'durationNanos
           (\ x__ y__ -> x__ {_Profile'durationNanos = y__}))
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
instance Data.ProtoLens.Field.HasField Profile "commentStrindices" [Data.Int.Int32] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Profile'commentStrindices
           (\ x__ y__ -> x__ {_Profile'commentStrindices = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField Profile "vec'commentStrindices" (Data.Vector.Unboxed.Vector Data.Int.Int32) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Profile'commentStrindices
           (\ x__ y__ -> x__ {_Profile'commentStrindices = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Profile "defaultSampleTypeIndex" Data.Int.Int32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Profile'defaultSampleTypeIndex
           (\ x__ y__ -> x__ {_Profile'defaultSampleTypeIndex = y__}))
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
      \\vsample_type\CAN\SOH \ETX(\v25.opentelemetry.proto.profiles.v1development.ValueTypeR\n\
      \sampleType\DC2J\n\
      \\ACKsample\CAN\STX \ETX(\v22.opentelemetry.proto.profiles.v1development.SampleR\ACKsample\DC2)\n\
      \\DLElocation_indices\CAN\ETX \ETX(\ENQR\SIlocationIndices\DC2\GS\n\
      \\n\
      \time_nanos\CAN\EOT \SOH(\ETXR\ttimeNanos\DC2%\n\
      \\SOduration_nanos\CAN\ENQ \SOH(\ETXR\rdurationNanos\DC2V\n\
      \\vperiod_type\CAN\ACK \SOH(\v25.opentelemetry.proto.profiles.v1development.ValueTypeR\n\
      \periodType\DC2\SYN\n\
      \\ACKperiod\CAN\a \SOH(\ETXR\ACKperiod\DC2-\n\
      \\DC2comment_strindices\CAN\b \ETX(\ENQR\DC1commentStrindices\DC29\n\
      \\EMdefault_sample_type_index\CAN\t \SOH(\ENQR\SYNdefaultSampleTypeIndex\DC2\GS\n\
      \\n\
      \profile_id\CAN\n\
      \ \SOH(\fR\tprofileId\DC28\n\
      \\CANdropped_attributes_count\CAN\v \SOH(\rR\SYNdroppedAttributesCount\DC26\n\
      \\ETBoriginal_payload_format\CAN\f \SOH(\tR\NAKoriginalPayloadFormat\DC2)\n\
      \\DLEoriginal_payload\CAN\r \SOH(\fR\SIoriginalPayload\DC2+\n\
      \\DC1attribute_indices\CAN\SO \ETX(\ENQR\DLEattributeIndices"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        sampleType__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "sample_type"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor ValueType)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"sampleType")) ::
              Data.ProtoLens.FieldDescriptor Profile
        sample__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "sample"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Sample)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked (Data.ProtoLens.Field.field @"sample")) ::
              Data.ProtoLens.FieldDescriptor Profile
        locationIndices__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "location_indices"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int32)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Packed
                 (Data.ProtoLens.Field.field @"locationIndices")) ::
              Data.ProtoLens.FieldDescriptor Profile
        timeNanos__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "time_nanos"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"timeNanos")) ::
              Data.ProtoLens.FieldDescriptor Profile
        durationNanos__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "duration_nanos"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"durationNanos")) ::
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
        commentStrindices__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "comment_strindices"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int32)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Packed
                 (Data.ProtoLens.Field.field @"commentStrindices")) ::
              Data.ProtoLens.FieldDescriptor Profile
        defaultSampleTypeIndex__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "default_sample_type_index"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"defaultSampleTypeIndex")) ::
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
           (Data.ProtoLens.Tag 2, sample__field_descriptor),
           (Data.ProtoLens.Tag 3, locationIndices__field_descriptor),
           (Data.ProtoLens.Tag 4, timeNanos__field_descriptor),
           (Data.ProtoLens.Tag 5, durationNanos__field_descriptor),
           (Data.ProtoLens.Tag 6, periodType__field_descriptor),
           (Data.ProtoLens.Tag 7, period__field_descriptor),
           (Data.ProtoLens.Tag 8, commentStrindices__field_descriptor),
           (Data.ProtoLens.Tag 9, defaultSampleTypeIndex__field_descriptor),
           (Data.ProtoLens.Tag 10, profileId__field_descriptor),
           (Data.ProtoLens.Tag 11, droppedAttributesCount__field_descriptor),
           (Data.ProtoLens.Tag 12, originalPayloadFormat__field_descriptor),
           (Data.ProtoLens.Tag 13, originalPayload__field_descriptor),
           (Data.ProtoLens.Tag 14, attributeIndices__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Profile'_unknownFields
        (\ x__ y__ -> x__ {_Profile'_unknownFields = y__})
  defMessage
    = Profile'_constructor
        {_Profile'sampleType = Data.Vector.Generic.empty,
         _Profile'sample = Data.Vector.Generic.empty,
         _Profile'locationIndices = Data.Vector.Generic.empty,
         _Profile'timeNanos = Data.ProtoLens.fieldDefault,
         _Profile'durationNanos = Data.ProtoLens.fieldDefault,
         _Profile'periodType = Prelude.Nothing,
         _Profile'period = Data.ProtoLens.fieldDefault,
         _Profile'commentStrindices = Data.Vector.Generic.empty,
         _Profile'defaultSampleTypeIndex = Data.ProtoLens.fieldDefault,
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
             -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Unboxed.Vector Data.ProtoLens.Encoding.Growing.RealWorld Data.Int.Int32
                -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Unboxed.Vector Data.ProtoLens.Encoding.Growing.RealWorld Data.Int.Int32
                   -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Sample
                      -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld ValueType
                         -> Data.ProtoLens.Encoding.Bytes.Parser Profile
        loop
          x
          mutable'attributeIndices
          mutable'commentStrindices
          mutable'locationIndices
          mutable'sample
          mutable'sampleType
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'attributeIndices <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                   (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                      mutable'attributeIndices)
                      frozen'commentStrindices <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                    (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                       mutable'commentStrindices)
                      frozen'locationIndices <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                  (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                     mutable'locationIndices)
                      frozen'sample <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                         (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                            mutable'sample)
                      frozen'sampleType <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                             (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                mutable'sampleType)
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
                                 (Data.ProtoLens.Field.field @"vec'commentStrindices")
                                 frozen'commentStrindices
                                 (Lens.Family2.set
                                    (Data.ProtoLens.Field.field @"vec'locationIndices")
                                    frozen'locationIndices
                                    (Lens.Family2.set
                                       (Data.ProtoLens.Field.field @"vec'sample") frozen'sample
                                       (Lens.Family2.set
                                          (Data.ProtoLens.Field.field @"vec'sampleType")
                                          frozen'sampleType x))))))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "sample_type"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'sampleType y)
                                loop
                                  x mutable'attributeIndices mutable'commentStrindices
                                  mutable'locationIndices mutable'sample v
                        18
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "sample"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'sample y)
                                loop
                                  x mutable'attributeIndices mutable'commentStrindices
                                  mutable'locationIndices v mutable'sampleType
                        24
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (Prelude.fmap
                                           Prelude.fromIntegral
                                           Data.ProtoLens.Encoding.Bytes.getVarInt)
                                        "location_indices"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append
                                          mutable'locationIndices y)
                                loop
                                  x mutable'attributeIndices mutable'commentStrindices v
                                  mutable'sample mutable'sampleType
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
                                                                    "location_indices"
                                                            qs' <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                                     (Data.ProtoLens.Encoding.Growing.append
                                                                        qs q)
                                                            ploop qs'
                                            in ploop)
                                             mutable'locationIndices)
                                loop
                                  x mutable'attributeIndices mutable'commentStrindices y
                                  mutable'sample mutable'sampleType
                        32
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "time_nanos"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"timeNanos") y x)
                                  mutable'attributeIndices mutable'commentStrindices
                                  mutable'locationIndices mutable'sample mutable'sampleType
                        40
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "duration_nanos"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"durationNanos") y x)
                                  mutable'attributeIndices mutable'commentStrindices
                                  mutable'locationIndices mutable'sample mutable'sampleType
                        50
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "period_type"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"periodType") y x)
                                  mutable'attributeIndices mutable'commentStrindices
                                  mutable'locationIndices mutable'sample mutable'sampleType
                        56
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "period"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"period") y x)
                                  mutable'attributeIndices mutable'commentStrindices
                                  mutable'locationIndices mutable'sample mutable'sampleType
                        64
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (Prelude.fmap
                                           Prelude.fromIntegral
                                           Data.ProtoLens.Encoding.Bytes.getVarInt)
                                        "comment_strindices"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append
                                          mutable'commentStrindices y)
                                loop
                                  x mutable'attributeIndices v mutable'locationIndices
                                  mutable'sample mutable'sampleType
                        66
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
                                                                    "comment_strindices"
                                                            qs' <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                                     (Data.ProtoLens.Encoding.Growing.append
                                                                        qs q)
                                                            ploop qs'
                                            in ploop)
                                             mutable'commentStrindices)
                                loop
                                  x mutable'attributeIndices y mutable'locationIndices
                                  mutable'sample mutable'sampleType
                        72
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "default_sample_type_index"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"defaultSampleTypeIndex") y x)
                                  mutable'attributeIndices mutable'commentStrindices
                                  mutable'locationIndices mutable'sample mutable'sampleType
                        82
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "profile_id"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"profileId") y x)
                                  mutable'attributeIndices mutable'commentStrindices
                                  mutable'locationIndices mutable'sample mutable'sampleType
                        88
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "dropped_attributes_count"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"droppedAttributesCount") y x)
                                  mutable'attributeIndices mutable'commentStrindices
                                  mutable'locationIndices mutable'sample mutable'sampleType
                        98
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getText
                                             (Prelude.fromIntegral len))
                                       "original_payload_format"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"originalPayloadFormat") y x)
                                  mutable'attributeIndices mutable'commentStrindices
                                  mutable'locationIndices mutable'sample mutable'sampleType
                        106
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "original_payload"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"originalPayload") y x)
                                  mutable'attributeIndices mutable'commentStrindices
                                  mutable'locationIndices mutable'sample mutable'sampleType
                        112
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (Prelude.fmap
                                           Prelude.fromIntegral
                                           Data.ProtoLens.Encoding.Bytes.getVarInt)
                                        "attribute_indices"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append
                                          mutable'attributeIndices y)
                                loop
                                  x v mutable'commentStrindices mutable'locationIndices
                                  mutable'sample mutable'sampleType
                        114
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
                                loop
                                  x y mutable'commentStrindices mutable'locationIndices
                                  mutable'sample mutable'sampleType
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'attributeIndices mutable'commentStrindices
                                  mutable'locationIndices mutable'sample mutable'sampleType
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'attributeIndices <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                            Data.ProtoLens.Encoding.Growing.new
              mutable'commentStrindices <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                             Data.ProtoLens.Encoding.Growing.new
              mutable'locationIndices <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                           Data.ProtoLens.Encoding.Growing.new
              mutable'sample <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                  Data.ProtoLens.Encoding.Growing.new
              mutable'sampleType <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                      Data.ProtoLens.Encoding.Growing.new
              loop
                Data.ProtoLens.defMessage mutable'attributeIndices
                mutable'commentStrindices mutable'locationIndices mutable'sample
                mutable'sampleType)
          "Profile"
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
                   (Data.ProtoLens.Field.field @"vec'sampleType") _x))
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
                   (Lens.Family2.view (Data.ProtoLens.Field.field @"vec'sample") _x))
                ((Data.Monoid.<>)
                   (let
                      p = Lens.Family2.view
                            (Data.ProtoLens.Field.field @"vec'locationIndices") _x
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
                         _v = Lens.Family2.view (Data.ProtoLens.Field.field @"timeNanos") _x
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
                            _v
                              = Lens.Family2.view
                                  (Data.ProtoLens.Field.field @"durationNanos") _x
                          in
                            if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                Data.Monoid.mempty
                            else
                                (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt 40)
                                  ((Prelude..)
                                     Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral
                                     _v))
                         ((Data.Monoid.<>)
                            (case
                                 Lens.Family2.view
                                   (Data.ProtoLens.Field.field @"maybe'periodType") _x
                             of
                               Prelude.Nothing -> Data.Monoid.mempty
                               (Prelude.Just _v)
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
                            ((Data.Monoid.<>)
                               (let
                                  _v = Lens.Family2.view (Data.ProtoLens.Field.field @"period") _x
                                in
                                  if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                      Data.Monoid.mempty
                                  else
                                      (Data.Monoid.<>)
                                        (Data.ProtoLens.Encoding.Bytes.putVarInt 56)
                                        ((Prelude..)
                                           Data.ProtoLens.Encoding.Bytes.putVarInt
                                           Prelude.fromIntegral _v))
                               ((Data.Monoid.<>)
                                  (let
                                     p = Lens.Family2.view
                                           (Data.ProtoLens.Field.field @"vec'commentStrindices") _x
                                   in
                                     if Data.Vector.Generic.null p then
                                         Data.Monoid.mempty
                                     else
                                         (Data.Monoid.<>)
                                           (Data.ProtoLens.Encoding.Bytes.putVarInt 66)
                                           ((\ bs
                                               -> (Data.Monoid.<>)
                                                    (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                       (Prelude.fromIntegral
                                                          (Data.ByteString.length bs)))
                                                    (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                              (Data.ProtoLens.Encoding.Bytes.runBuilder
                                                 (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                                                    ((Prelude..)
                                                       Data.ProtoLens.Encoding.Bytes.putVarInt
                                                       Prelude.fromIntegral)
                                                    p))))
                                  ((Data.Monoid.<>)
                                     (let
                                        _v
                                          = Lens.Family2.view
                                              (Data.ProtoLens.Field.field @"defaultSampleTypeIndex")
                                              _x
                                      in
                                        if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                            Data.Monoid.mempty
                                        else
                                            (Data.Monoid.<>)
                                              (Data.ProtoLens.Encoding.Bytes.putVarInt 72)
                                              ((Prelude..)
                                                 Data.ProtoLens.Encoding.Bytes.putVarInt
                                                 Prelude.fromIntegral _v))
                                     ((Data.Monoid.<>)
                                        (let
                                           _v
                                             = Lens.Family2.view
                                                 (Data.ProtoLens.Field.field @"profileId") _x
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
                                              _v
                                                = Lens.Family2.view
                                                    (Data.ProtoLens.Field.field
                                                       @"droppedAttributesCount")
                                                    _x
                                            in
                                              if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                                  Data.Monoid.mempty
                                              else
                                                  (Data.Monoid.<>)
                                                    (Data.ProtoLens.Encoding.Bytes.putVarInt 88)
                                                    ((Prelude..)
                                                       Data.ProtoLens.Encoding.Bytes.putVarInt
                                                       Prelude.fromIntegral _v))
                                           ((Data.Monoid.<>)
                                              (let
                                                 _v
                                                   = Lens.Family2.view
                                                       (Data.ProtoLens.Field.field
                                                          @"originalPayloadFormat")
                                                       _x
                                               in
                                                 if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                                     Data.Monoid.mempty
                                                 else
                                                     (Data.Monoid.<>)
                                                       (Data.ProtoLens.Encoding.Bytes.putVarInt 98)
                                                       ((Prelude..)
                                                          (\ bs
                                                             -> (Data.Monoid.<>)
                                                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                                     (Prelude.fromIntegral
                                                                        (Data.ByteString.length
                                                                           bs)))
                                                                  (Data.ProtoLens.Encoding.Bytes.putBytes
                                                                     bs))
                                                          Data.Text.Encoding.encodeUtf8 _v))
                                              ((Data.Monoid.<>)
                                                 (let
                                                    _v
                                                      = Lens.Family2.view
                                                          (Data.ProtoLens.Field.field
                                                             @"originalPayload")
                                                          _x
                                                  in
                                                    if (Prelude.==)
                                                         _v Data.ProtoLens.fieldDefault then
                                                        Data.Monoid.mempty
                                                    else
                                                        (Data.Monoid.<>)
                                                          (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                             106)
                                                          ((\ bs
                                                              -> (Data.Monoid.<>)
                                                                   (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                                      (Prelude.fromIntegral
                                                                         (Data.ByteString.length
                                                                            bs)))
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
                                                             (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                                114)
                                                             ((\ bs
                                                                 -> (Data.Monoid.<>)
                                                                      (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                                         (Prelude.fromIntegral
                                                                            (Data.ByteString.length
                                                                               bs)))
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
                                                          Data.ProtoLens.unknownFields
                                                          _x)))))))))))))))
instance Control.DeepSeq.NFData Profile where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Profile'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_Profile'sampleType x__)
                (Control.DeepSeq.deepseq
                   (_Profile'sample x__)
                   (Control.DeepSeq.deepseq
                      (_Profile'locationIndices x__)
                      (Control.DeepSeq.deepseq
                         (_Profile'timeNanos x__)
                         (Control.DeepSeq.deepseq
                            (_Profile'durationNanos x__)
                            (Control.DeepSeq.deepseq
                               (_Profile'periodType x__)
                               (Control.DeepSeq.deepseq
                                  (_Profile'period x__)
                                  (Control.DeepSeq.deepseq
                                     (_Profile'commentStrindices x__)
                                     (Control.DeepSeq.deepseq
                                        (_Profile'defaultSampleTypeIndex x__)
                                        (Control.DeepSeq.deepseq
                                           (_Profile'profileId x__)
                                           (Control.DeepSeq.deepseq
                                              (_Profile'droppedAttributesCount x__)
                                              (Control.DeepSeq.deepseq
                                                 (_Profile'originalPayloadFormat x__)
                                                 (Control.DeepSeq.deepseq
                                                    (_Profile'originalPayload x__)
                                                    (Control.DeepSeq.deepseq
                                                       (_Profile'attributeIndices x__)
                                                       ()))))))))))))))
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
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.attributeTable' @:: Lens' ProfilesDictionary [Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue]@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.vec'attributeTable' @:: Lens' ProfilesDictionary (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue)@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.attributeUnits' @:: Lens' ProfilesDictionary [AttributeUnit]@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.vec'attributeUnits' @:: Lens' ProfilesDictionary (Data.Vector.Vector AttributeUnit)@ -}
data ProfilesDictionary
  = ProfilesDictionary'_constructor {_ProfilesDictionary'mappingTable :: !(Data.Vector.Vector Mapping),
                                     _ProfilesDictionary'locationTable :: !(Data.Vector.Vector Location),
                                     _ProfilesDictionary'functionTable :: !(Data.Vector.Vector Function),
                                     _ProfilesDictionary'linkTable :: !(Data.Vector.Vector Link),
                                     _ProfilesDictionary'stringTable :: !(Data.Vector.Vector Data.Text.Text),
                                     _ProfilesDictionary'attributeTable :: !(Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue),
                                     _ProfilesDictionary'attributeUnits :: !(Data.Vector.Vector AttributeUnit),
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
instance Data.ProtoLens.Field.HasField ProfilesDictionary "attributeTable" [Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ProfilesDictionary'attributeTable
           (\ x__ y__ -> x__ {_ProfilesDictionary'attributeTable = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField ProfilesDictionary "vec'attributeTable" (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ProfilesDictionary'attributeTable
           (\ x__ y__ -> x__ {_ProfilesDictionary'attributeTable = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ProfilesDictionary "attributeUnits" [AttributeUnit] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ProfilesDictionary'attributeUnits
           (\ x__ y__ -> x__ {_ProfilesDictionary'attributeUnits = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField ProfilesDictionary "vec'attributeUnits" (Data.Vector.Vector AttributeUnit) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ProfilesDictionary'attributeUnits
           (\ x__ y__ -> x__ {_ProfilesDictionary'attributeUnits = y__}))
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
      \\fstring_table\CAN\ENQ \ETX(\tR\vstringTable\DC2P\n\
      \\SIattribute_table\CAN\ACK \ETX(\v2'.opentelemetry.proto.common.v1.KeyValueR\SOattributeTable\DC2b\n\
      \\SIattribute_units\CAN\a \ETX(\v29.opentelemetry.proto.profiles.v1development.AttributeUnitR\SOattributeUnits"
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
                 Data.ProtoLens.FieldTypeDescriptor Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"attributeTable")) ::
              Data.ProtoLens.FieldDescriptor ProfilesDictionary
        attributeUnits__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "attribute_units"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor AttributeUnit)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"attributeUnits")) ::
              Data.ProtoLens.FieldDescriptor ProfilesDictionary
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, mappingTable__field_descriptor),
           (Data.ProtoLens.Tag 2, locationTable__field_descriptor),
           (Data.ProtoLens.Tag 3, functionTable__field_descriptor),
           (Data.ProtoLens.Tag 4, linkTable__field_descriptor),
           (Data.ProtoLens.Tag 5, stringTable__field_descriptor),
           (Data.ProtoLens.Tag 6, attributeTable__field_descriptor),
           (Data.ProtoLens.Tag 7, attributeUnits__field_descriptor)]
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
         _ProfilesDictionary'attributeUnits = Data.Vector.Generic.empty,
         _ProfilesDictionary'_unknownFields = []}
  parseMessage
    = let
        loop ::
          ProfilesDictionary
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue
             -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld AttributeUnit
                -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Function
                   -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Link
                      -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Location
                         -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Mapping
                            -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Data.Text.Text
                               -> Data.ProtoLens.Encoding.Bytes.Parser ProfilesDictionary
        loop
          x
          mutable'attributeTable
          mutable'attributeUnits
          mutable'functionTable
          mutable'linkTable
          mutable'locationTable
          mutable'mappingTable
          mutable'stringTable
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'attributeTable <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                 (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                    mutable'attributeTable)
                      frozen'attributeUnits <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                 (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                    mutable'attributeUnits)
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
                                 (Data.ProtoLens.Field.field @"vec'attributeUnits")
                                 frozen'attributeUnits
                                 (Lens.Family2.set
                                    (Data.ProtoLens.Field.field @"vec'functionTable")
                                    frozen'functionTable
                                    (Lens.Family2.set
                                       (Data.ProtoLens.Field.field @"vec'linkTable")
                                       frozen'linkTable
                                       (Lens.Family2.set
                                          (Data.ProtoLens.Field.field @"vec'locationTable")
                                          frozen'locationTable
                                          (Lens.Family2.set
                                             (Data.ProtoLens.Field.field @"vec'mappingTable")
                                             frozen'mappingTable
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
                                  x mutable'attributeTable mutable'attributeUnits
                                  mutable'functionTable mutable'linkTable mutable'locationTable v
                                  mutable'stringTable
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
                                  x mutable'attributeTable mutable'attributeUnits
                                  mutable'functionTable mutable'linkTable v mutable'mappingTable
                                  mutable'stringTable
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
                                  x mutable'attributeTable mutable'attributeUnits v
                                  mutable'linkTable mutable'locationTable mutable'mappingTable
                                  mutable'stringTable
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
                                  x mutable'attributeTable mutable'attributeUnits
                                  mutable'functionTable v mutable'locationTable mutable'mappingTable
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
                                  x mutable'attributeTable mutable'attributeUnits
                                  mutable'functionTable mutable'linkTable mutable'locationTable
                                  mutable'mappingTable v
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
                                  x v mutable'attributeUnits mutable'functionTable mutable'linkTable
                                  mutable'locationTable mutable'mappingTable mutable'stringTable
                        58
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "attribute_units"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append
                                          mutable'attributeUnits y)
                                loop
                                  x mutable'attributeTable v mutable'functionTable mutable'linkTable
                                  mutable'locationTable mutable'mappingTable mutable'stringTable
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'attributeTable mutable'attributeUnits
                                  mutable'functionTable mutable'linkTable mutable'locationTable
                                  mutable'mappingTable mutable'stringTable
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'attributeTable <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                          Data.ProtoLens.Encoding.Growing.new
              mutable'attributeUnits <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                          Data.ProtoLens.Encoding.Growing.new
              mutable'functionTable <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                         Data.ProtoLens.Encoding.Growing.new
              mutable'linkTable <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                     Data.ProtoLens.Encoding.Growing.new
              mutable'locationTable <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                         Data.ProtoLens.Encoding.Growing.new
              mutable'mappingTable <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                        Data.ProtoLens.Encoding.Growing.new
              mutable'stringTable <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       Data.ProtoLens.Encoding.Growing.new
              loop
                Data.ProtoLens.defMessage mutable'attributeTable
                mutable'attributeUnits mutable'functionTable mutable'linkTable
                mutable'locationTable mutable'mappingTable mutable'stringTable)
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
                                     (Data.ProtoLens.Field.field @"vec'attributeUnits") _x))
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
                                  (_ProfilesDictionary'attributeUnits x__) ())))))))
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
     
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.locationsStartIndex' @:: Lens' Sample Data.Int.Int32@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.locationsLength' @:: Lens' Sample Data.Int.Int32@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.value' @:: Lens' Sample [Data.Int.Int64]@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.vec'value' @:: Lens' Sample (Data.Vector.Unboxed.Vector Data.Int.Int64)@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.attributeIndices' @:: Lens' Sample [Data.Int.Int32]@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.vec'attributeIndices' @:: Lens' Sample (Data.Vector.Unboxed.Vector Data.Int.Int32)@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.linkIndex' @:: Lens' Sample Data.Int.Int32@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.maybe'linkIndex' @:: Lens' Sample (Prelude.Maybe Data.Int.Int32)@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.timestampsUnixNano' @:: Lens' Sample [Data.Word.Word64]@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.vec'timestampsUnixNano' @:: Lens' Sample (Data.Vector.Unboxed.Vector Data.Word.Word64)@ -}
data Sample
  = Sample'_constructor {_Sample'locationsStartIndex :: !Data.Int.Int32,
                         _Sample'locationsLength :: !Data.Int.Int32,
                         _Sample'value :: !(Data.Vector.Unboxed.Vector Data.Int.Int64),
                         _Sample'attributeIndices :: !(Data.Vector.Unboxed.Vector Data.Int.Int32),
                         _Sample'linkIndex :: !(Prelude.Maybe Data.Int.Int32),
                         _Sample'timestampsUnixNano :: !(Data.Vector.Unboxed.Vector Data.Word.Word64),
                         _Sample'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show Sample where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField Sample "locationsStartIndex" Data.Int.Int32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Sample'locationsStartIndex
           (\ x__ y__ -> x__ {_Sample'locationsStartIndex = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Sample "locationsLength" Data.Int.Int32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Sample'locationsLength
           (\ x__ y__ -> x__ {_Sample'locationsLength = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Sample "value" [Data.Int.Int64] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Sample'value (\ x__ y__ -> x__ {_Sample'value = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField Sample "vec'value" (Data.Vector.Unboxed.Vector Data.Int.Int64) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Sample'value (\ x__ y__ -> x__ {_Sample'value = y__}))
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
        (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault)
instance Data.ProtoLens.Field.HasField Sample "maybe'linkIndex" (Prelude.Maybe Data.Int.Int32) where
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
      \\ACKSample\DC22\n\
      \\NAKlocations_start_index\CAN\SOH \SOH(\ENQR\DC3locationsStartIndex\DC2)\n\
      \\DLElocations_length\CAN\STX \SOH(\ENQR\SIlocationsLength\DC2\DC4\n\
      \\ENQvalue\CAN\ETX \ETX(\ETXR\ENQvalue\DC2+\n\
      \\DC1attribute_indices\CAN\EOT \ETX(\ENQR\DLEattributeIndices\DC2\"\n\
      \\n\
      \link_index\CAN\ENQ \SOH(\ENQH\NULR\tlinkIndex\136\SOH\SOH\DC20\n\
      \\DC4timestamps_unix_nano\CAN\ACK \ETX(\EOTR\DC2timestampsUnixNanoB\r\n\
      \\v_link_index"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        locationsStartIndex__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "locations_start_index"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"locationsStartIndex")) ::
              Data.ProtoLens.FieldDescriptor Sample
        locationsLength__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "locations_length"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"locationsLength")) ::
              Data.ProtoLens.FieldDescriptor Sample
        value__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "value"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int64)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Packed (Data.ProtoLens.Field.field @"value")) ::
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
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'linkIndex")) ::
              Data.ProtoLens.FieldDescriptor Sample
        timestampsUnixNano__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "timestamps_unix_nano"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Packed
                 (Data.ProtoLens.Field.field @"timestampsUnixNano")) ::
              Data.ProtoLens.FieldDescriptor Sample
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, locationsStartIndex__field_descriptor),
           (Data.ProtoLens.Tag 2, locationsLength__field_descriptor),
           (Data.ProtoLens.Tag 3, value__field_descriptor),
           (Data.ProtoLens.Tag 4, attributeIndices__field_descriptor),
           (Data.ProtoLens.Tag 5, linkIndex__field_descriptor),
           (Data.ProtoLens.Tag 6, timestampsUnixNano__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Sample'_unknownFields
        (\ x__ y__ -> x__ {_Sample'_unknownFields = y__})
  defMessage
    = Sample'_constructor
        {_Sample'locationsStartIndex = Data.ProtoLens.fieldDefault,
         _Sample'locationsLength = Data.ProtoLens.fieldDefault,
         _Sample'value = Data.Vector.Generic.empty,
         _Sample'attributeIndices = Data.Vector.Generic.empty,
         _Sample'linkIndex = Prelude.Nothing,
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
          mutable'value
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'attributeIndices <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                   (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                      mutable'attributeIndices)
                      frozen'timestampsUnixNano <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                     (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                        mutable'timestampsUnixNano)
                      frozen'value <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                        (Data.ProtoLens.Encoding.Growing.unsafeFreeze mutable'value)
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
                                    (Data.ProtoLens.Field.field @"vec'value") frozen'value x))))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        8 -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "locations_start_index"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"locationsStartIndex") y x)
                                  mutable'attributeIndices mutable'timestampsUnixNano mutable'value
                        16
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "locations_length"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"locationsLength") y x)
                                  mutable'attributeIndices mutable'timestampsUnixNano mutable'value
                        24
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (Prelude.fmap
                                           Prelude.fromIntegral
                                           Data.ProtoLens.Encoding.Bytes.getVarInt)
                                        "value"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'value y)
                                loop x mutable'attributeIndices mutable'timestampsUnixNano v
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
                                                                    "value"
                                                            qs' <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                                     (Data.ProtoLens.Encoding.Growing.append
                                                                        qs q)
                                                            ploop qs'
                                            in ploop)
                                             mutable'value)
                                loop x mutable'attributeIndices mutable'timestampsUnixNano y
                        32
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (Prelude.fmap
                                           Prelude.fromIntegral
                                           Data.ProtoLens.Encoding.Bytes.getVarInt)
                                        "attribute_indices"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append
                                          mutable'attributeIndices y)
                                loop x v mutable'timestampsUnixNano mutable'value
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
                                loop x y mutable'timestampsUnixNano mutable'value
                        40
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "link_index"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"linkIndex") y x)
                                  mutable'attributeIndices mutable'timestampsUnixNano mutable'value
                        48
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        Data.ProtoLens.Encoding.Bytes.getVarInt
                                        "timestamps_unix_nano"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append
                                          mutable'timestampsUnixNano y)
                                loop x mutable'attributeIndices v mutable'value
                        50
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
                                                                    Data.ProtoLens.Encoding.Bytes.getVarInt
                                                                    "timestamps_unix_nano"
                                                            qs' <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                                     (Data.ProtoLens.Encoding.Growing.append
                                                                        qs q)
                                                            ploop qs'
                                            in ploop)
                                             mutable'timestampsUnixNano)
                                loop x mutable'attributeIndices y mutable'value
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'attributeIndices mutable'timestampsUnixNano mutable'value
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'attributeIndices <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                            Data.ProtoLens.Encoding.Growing.new
              mutable'timestampsUnixNano <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                              Data.ProtoLens.Encoding.Growing.new
              mutable'value <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                 Data.ProtoLens.Encoding.Growing.new
              loop
                Data.ProtoLens.defMessage mutable'attributeIndices
                mutable'timestampsUnixNano mutable'value)
          "Sample"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v
                  = Lens.Family2.view
                      (Data.ProtoLens.Field.field @"locationsStartIndex") _x
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
                         (Data.ProtoLens.Field.field @"locationsLength") _x
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
                      p = Lens.Family2.view (Data.ProtoLens.Field.field @"vec'value") _x
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
                      ((Data.Monoid.<>)
                         (case
                              Lens.Family2.view
                                (Data.ProtoLens.Field.field @"maybe'linkIndex") _x
                          of
                            Prelude.Nothing -> Data.Monoid.mempty
                            (Prelude.Just _v)
                              -> (Data.Monoid.<>)
                                   (Data.ProtoLens.Encoding.Bytes.putVarInt 40)
                                   ((Prelude..)
                                      Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral
                                      _v))
                         ((Data.Monoid.<>)
                            (let
                               p = Lens.Family2.view
                                     (Data.ProtoLens.Field.field @"vec'timestampsUnixNano") _x
                             in
                               if Data.Vector.Generic.null p then
                                   Data.Monoid.mempty
                               else
                                   (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt 50)
                                     ((\ bs
                                         -> (Data.Monoid.<>)
                                              (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                 (Prelude.fromIntegral (Data.ByteString.length bs)))
                                              (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                        (Data.ProtoLens.Encoding.Bytes.runBuilder
                                           (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                                              Data.ProtoLens.Encoding.Bytes.putVarInt p))))
                            (Data.ProtoLens.Encoding.Wire.buildFieldSet
                               (Lens.Family2.view Data.ProtoLens.unknownFields _x)))))))
instance Control.DeepSeq.NFData Sample where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Sample'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_Sample'locationsStartIndex x__)
                (Control.DeepSeq.deepseq
                   (_Sample'locationsLength x__)
                   (Control.DeepSeq.deepseq
                      (_Sample'value x__)
                      (Control.DeepSeq.deepseq
                         (_Sample'attributeIndices x__)
                         (Control.DeepSeq.deepseq
                            (_Sample'linkIndex x__)
                            (Control.DeepSeq.deepseq (_Sample'timestampsUnixNano x__) ()))))))
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
     
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.typeStrindex' @:: Lens' ValueType Data.Int.Int32@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.unitStrindex' @:: Lens' ValueType Data.Int.Int32@
         * 'Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields.aggregationTemporality' @:: Lens' ValueType AggregationTemporality@ -}
data ValueType
  = ValueType'_constructor {_ValueType'typeStrindex :: !Data.Int.Int32,
                            _ValueType'unitStrindex :: !Data.Int.Int32,
                            _ValueType'aggregationTemporality :: !AggregationTemporality,
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
instance Data.ProtoLens.Field.HasField ValueType "aggregationTemporality" AggregationTemporality where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ValueType'aggregationTemporality
           (\ x__ y__ -> x__ {_ValueType'aggregationTemporality = y__}))
        Prelude.id
instance Data.ProtoLens.Message ValueType where
  messageName _
    = Data.Text.pack
        "opentelemetry.proto.profiles.v1development.ValueType"
  packedMessageDescriptor _
    = "\n\
      \\tValueType\DC2#\n\
      \\rtype_strindex\CAN\SOH \SOH(\ENQR\ftypeStrindex\DC2#\n\
      \\runit_strindex\CAN\STX \SOH(\ENQR\funitStrindex\DC2{\n\
      \\ETBaggregation_temporality\CAN\ETX \SOH(\SO2B.opentelemetry.proto.profiles.v1development.AggregationTemporalityR\SYNaggregationTemporality"
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
        aggregationTemporality__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "aggregation_temporality"
              (Data.ProtoLens.ScalarField Data.ProtoLens.EnumField ::
                 Data.ProtoLens.FieldTypeDescriptor AggregationTemporality)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"aggregationTemporality")) ::
              Data.ProtoLens.FieldDescriptor ValueType
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, typeStrindex__field_descriptor),
           (Data.ProtoLens.Tag 2, unitStrindex__field_descriptor),
           (Data.ProtoLens.Tag 3, aggregationTemporality__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _ValueType'_unknownFields
        (\ x__ y__ -> x__ {_ValueType'_unknownFields = y__})
  defMessage
    = ValueType'_constructor
        {_ValueType'typeStrindex = Data.ProtoLens.fieldDefault,
         _ValueType'unitStrindex = Data.ProtoLens.fieldDefault,
         _ValueType'aggregationTemporality = Data.ProtoLens.fieldDefault,
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
                        24
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.toEnum
                                          (Prelude.fmap
                                             Prelude.fromIntegral
                                             Data.ProtoLens.Encoding.Bytes.getVarInt))
                                       "aggregation_temporality"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"aggregationTemporality") y x)
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
                ((Data.Monoid.<>)
                   (let
                      _v
                        = Lens.Family2.view
                            (Data.ProtoLens.Field.field @"aggregationTemporality") _x
                    in
                      if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                          Data.Monoid.mempty
                      else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 24)
                            ((Prelude..)
                               ((Prelude..)
                                  Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral)
                               Prelude.fromEnum _v))
                   (Data.ProtoLens.Encoding.Wire.buildFieldSet
                      (Lens.Family2.view Data.ProtoLens.unknownFields _x))))
instance Control.DeepSeq.NFData ValueType where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_ValueType'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_ValueType'typeStrindex x__)
                (Control.DeepSeq.deepseq
                   (_ValueType'unitStrindex x__)
                   (Control.DeepSeq.deepseq
                      (_ValueType'aggregationTemporality x__) ())))
packedFileDescriptor :: Data.ByteString.ByteString
packedFileDescriptor
  = "\n\
    \9opentelemetry/proto/profiles/v1development/profiles.proto\DC2*opentelemetry.proto.profiles.v1development\SUB*opentelemetry/proto/common/v1/common.proto\SUB.opentelemetry/proto/resource/v1/resource.proto\"\210\EOT\n\
    \\DC2ProfilesDictionary\DC2X\n\
    \\rmapping_table\CAN\SOH \ETX(\v23.opentelemetry.proto.profiles.v1development.MappingR\fmappingTable\DC2[\n\
    \\SOlocation_table\CAN\STX \ETX(\v24.opentelemetry.proto.profiles.v1development.LocationR\rlocationTable\DC2[\n\
    \\SOfunction_table\CAN\ETX \ETX(\v24.opentelemetry.proto.profiles.v1development.FunctionR\rfunctionTable\DC2O\n\
    \\n\
    \link_table\CAN\EOT \ETX(\v20.opentelemetry.proto.profiles.v1development.LinkR\tlinkTable\DC2!\n\
    \\fstring_table\CAN\ENQ \ETX(\tR\vstringTable\DC2P\n\
    \\SIattribute_table\CAN\ACK \ETX(\v2'.opentelemetry.proto.common.v1.KeyValueR\SOattributeTable\DC2b\n\
    \\SIattribute_units\CAN\a \ETX(\v29.opentelemetry.proto.profiles.v1development.AttributeUnitR\SOattributeUnits\"\217\SOH\n\
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
    \schema_url\CAN\ETX \SOH(\tR\tschemaUrl\"\225\ENQ\n\
    \\aProfile\DC2V\n\
    \\vsample_type\CAN\SOH \ETX(\v25.opentelemetry.proto.profiles.v1development.ValueTypeR\n\
    \sampleType\DC2J\n\
    \\ACKsample\CAN\STX \ETX(\v22.opentelemetry.proto.profiles.v1development.SampleR\ACKsample\DC2)\n\
    \\DLElocation_indices\CAN\ETX \ETX(\ENQR\SIlocationIndices\DC2\GS\n\
    \\n\
    \time_nanos\CAN\EOT \SOH(\ETXR\ttimeNanos\DC2%\n\
    \\SOduration_nanos\CAN\ENQ \SOH(\ETXR\rdurationNanos\DC2V\n\
    \\vperiod_type\CAN\ACK \SOH(\v25.opentelemetry.proto.profiles.v1development.ValueTypeR\n\
    \periodType\DC2\SYN\n\
    \\ACKperiod\CAN\a \SOH(\ETXR\ACKperiod\DC2-\n\
    \\DC2comment_strindices\CAN\b \ETX(\ENQR\DC1commentStrindices\DC29\n\
    \\EMdefault_sample_type_index\CAN\t \SOH(\ENQR\SYNdefaultSampleTypeIndex\DC2\GS\n\
    \\n\
    \profile_id\CAN\n\
    \ \SOH(\fR\tprofileId\DC28\n\
    \\CANdropped_attributes_count\CAN\v \SOH(\rR\SYNdroppedAttributesCount\DC26\n\
    \\ETBoriginal_payload_format\CAN\f \SOH(\tR\NAKoriginalPayloadFormat\DC2)\n\
    \\DLEoriginal_payload\CAN\r \SOH(\fR\SIoriginalPayload\DC2+\n\
    \\DC1attribute_indices\CAN\SO \ETX(\ENQR\DLEattributeIndices\"j\n\
    \\rAttributeUnit\DC24\n\
    \\SYNattribute_key_strindex\CAN\SOH \SOH(\ENQR\DC4attributeKeyStrindex\DC2#\n\
    \\runit_strindex\CAN\STX \SOH(\ENQR\funitStrindex\":\n\
    \\EOTLink\DC2\EM\n\
    \\btrace_id\CAN\SOH \SOH(\fR\atraceId\DC2\ETB\n\
    \\aspan_id\CAN\STX \SOH(\fR\ACKspanId\"\210\SOH\n\
    \\tValueType\DC2#\n\
    \\rtype_strindex\CAN\SOH \SOH(\ENQR\ftypeStrindex\DC2#\n\
    \\runit_strindex\CAN\STX \SOH(\ENQR\funitStrindex\DC2{\n\
    \\ETBaggregation_temporality\CAN\ETX \SOH(\SO2B.opentelemetry.proto.profiles.v1development.AggregationTemporalityR\SYNaggregationTemporality\"\143\STX\n\
    \\ACKSample\DC22\n\
    \\NAKlocations_start_index\CAN\SOH \SOH(\ENQR\DC3locationsStartIndex\DC2)\n\
    \\DLElocations_length\CAN\STX \SOH(\ENQR\SIlocationsLength\DC2\DC4\n\
    \\ENQvalue\CAN\ETX \ETX(\ETXR\ENQvalue\DC2+\n\
    \\DC1attribute_indices\CAN\EOT \ETX(\ENQR\DLEattributeIndices\DC2\"\n\
    \\n\
    \link_index\CAN\ENQ \SOH(\ENQH\NULR\tlinkIndex\136\SOH\SOH\DC20\n\
    \\DC4timestamps_unix_nano\CAN\ACK \ETX(\EOTR\DC2timestampsUnixNanoB\r\n\
    \\v_link_index\"\234\STX\n\
    \\aMapping\DC2!\n\
    \\fmemory_start\CAN\SOH \SOH(\EOTR\vmemoryStart\DC2!\n\
    \\fmemory_limit\CAN\STX \SOH(\EOTR\vmemoryLimit\DC2\US\n\
    \\vfile_offset\CAN\ETX \SOH(\EOTR\n\
    \fileOffset\DC2+\n\
    \\DC1filename_strindex\CAN\EOT \SOH(\ENQR\DLEfilenameStrindex\DC2+\n\
    \\DC1attribute_indices\CAN\ENQ \ETX(\ENQR\DLEattributeIndices\DC2#\n\
    \\rhas_functions\CAN\ACK \SOH(\bR\fhasFunctions\DC2#\n\
    \\rhas_filenames\CAN\a \SOH(\bR\fhasFilenames\DC2(\n\
    \\DLEhas_line_numbers\CAN\b \SOH(\bR\SOhasLineNumbers\DC2*\n\
    \\DC1has_inline_frames\CAN\t \SOH(\bR\SIhasInlineFrames\"\240\SOH\n\
    \\bLocation\DC2(\n\
    \\rmapping_index\CAN\SOH \SOH(\ENQH\NULR\fmappingIndex\136\SOH\SOH\DC2\CAN\n\
    \\aaddress\CAN\STX \SOH(\EOTR\aaddress\DC2D\n\
    \\EOTline\CAN\ETX \ETX(\v20.opentelemetry.proto.profiles.v1development.LineR\EOTline\DC2\ESC\n\
    \\tis_folded\CAN\EOT \SOH(\bR\bisFolded\DC2+\n\
    \\DC1attribute_indices\CAN\ENQ \ETX(\ENQR\DLEattributeIndicesB\DLE\n\
    \\SO_mapping_index\"Y\n\
    \\EOTLine\DC2%\n\
    \\SOfunction_index\CAN\SOH \SOH(\ENQR\rfunctionIndex\DC2\DC2\n\
    \\EOTline\CAN\STX \SOH(\ETXR\EOTline\DC2\SYN\n\
    \\ACKcolumn\CAN\ETX \SOH(\ETXR\ACKcolumn\"\173\SOH\n\
    \\bFunction\DC2#\n\
    \\rname_strindex\CAN\SOH \SOH(\ENQR\fnameStrindex\DC20\n\
    \\DC4system_name_strindex\CAN\STX \SOH(\ENQR\DC2systemNameStrindex\DC2+\n\
    \\DC1filename_strindex\CAN\ETX \SOH(\ENQR\DLEfilenameStrindex\DC2\GS\n\
    \\n\
    \start_line\CAN\EOT \SOH(\ETXR\tstartLine*\140\SOH\n\
    \\SYNAggregationTemporality\DC2'\n\
    \#AGGREGATION_TEMPORALITY_UNSPECIFIED\DLE\NUL\DC2!\n\
    \\GSAGGREGATION_TEMPORALITY_DELTA\DLE\SOH\DC2&\n\
    \\"AGGREGATION_TEMPORALITY_CUMULATIVE\DLE\STXB\164\SOH\n\
    \-io.opentelemetry.proto.profiles.v1developmentB\rProfilesProtoP\SOHZ5go.opentelemetry.io/proto/otlp/profiles/v1development\170\STX*OpenTelemetry.Proto.Profiles.V1DevelopmentJ\131\184\SOH\n\
    \\a\DC2\ENQ\RS\NUL\230\ETX\SOH\n\
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
    \\156\NAK\n\
    \\STX\EOT\NUL\DC2\EOT^\NULu\SOH\SUB_ ProfilesDictionary represents the profiles data shared across the\n\
    \ entire message being sent.\n\
    \2\174\DC4                Relationships Diagram\n\
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
    \   \226\148\130 1-1\n\
    \   \226\150\188\n\
    \ \226\148\140\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\144\n\
    \ \226\148\130      Profile     \226\148\130\n\
    \ \226\148\148\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\152\n\
    \   \226\148\130                                n-1\n\
    \   \226\148\130 1-n         \226\148\140\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\144\n\
    \   \226\150\188             \226\148\130                                       \226\150\189\n\
    \ \226\148\140\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\144   1-n   \226\148\140\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\144      \226\148\140\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\144\n\
    \ \226\148\130      Sample      \226\148\130 \226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\150\183 \226\148\130   KeyValue   \226\148\130      \226\148\130   Link   \226\148\130\n\
    \ \226\148\148\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\152         \226\148\148\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\152      \226\148\148\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\152\n\
    \   \226\148\130                    1-n       \226\150\179      \226\150\179\n\
    \   \226\148\130 1-n        \226\148\140\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\152      \226\148\130 1-n\n\
    \   \226\150\189            \226\148\130                        \226\148\130\n\
    \ \226\148\140\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\144   n-1   \226\148\140\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\144\n\
    \ \226\148\130     Location     \226\148\130 \226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\150\183 \226\148\130   Mapping    \226\148\130\n\
    \ \226\148\148\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\152         \226\148\148\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\128\226\148\152\n\
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
    \\ETX\EOT\NUL\SOH\DC2\ETX^\b\SUB\n\
    \\156\SOH\n\
    \\EOT\EOT\NUL\STX\NUL\DC2\ETXa\STX%\SUB\142\SOH Mappings from address ranges to the image/binary/library mapped\n\
    \ into that address range referenced by locations via Location.mapping_index.\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\EOT\DC2\ETXa\STX\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\ACK\DC2\ETXa\v\DC2\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\SOH\DC2\ETXa\DC3 \n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\ETX\DC2\ETXa#$\n\
    \L\n\
    \\EOT\EOT\NUL\STX\SOH\DC2\ETXd\STX'\SUB? Locations referenced by samples via Profile.location_indices.\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\SOH\EOT\DC2\ETXd\STX\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\SOH\ACK\DC2\ETXd\v\DC3\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\SOH\SOH\DC2\ETXd\DC4\"\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\SOH\ETX\DC2\ETXd%&\n\
    \I\n\
    \\EOT\EOT\NUL\STX\STX\DC2\ETXg\STX'\SUB< Functions referenced by locations via Line.function_index.\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\STX\EOT\DC2\ETXg\STX\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\STX\ACK\DC2\ETXg\v\DC3\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\STX\SOH\DC2\ETXg\DC4\"\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\STX\ETX\DC2\ETXg%&\n\
    \A\n\
    \\EOT\EOT\NUL\STX\ETX\DC2\ETXj\STX\US\SUB4 Links referenced by samples via Sample.link_index.\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\ETX\EOT\DC2\ETXj\STX\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\ETX\ACK\DC2\ETXj\v\SI\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\ETX\SOH\DC2\ETXj\DLE\SUB\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\ETX\ETX\DC2\ETXj\GS\RS\n\
    \m\n\
    \\EOT\EOT\NUL\STX\EOT\DC2\ETXn\STX#\SUB` A common table for strings referenced by various messages.\n\
    \ string_table[0] must always be \"\".\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\EOT\EOT\DC2\ETXn\STX\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\EOT\ENQ\DC2\ETXn\v\DC1\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\EOT\SOH\DC2\ETXn\DC2\RS\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\EOT\ETX\DC2\ETXn!\"\n\
    \L\n\
    \\EOT\EOT\NUL\STX\ENQ\DC2\ETXq\STXF\SUB? A common table for attributes referenced by various messages.\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\ENQ\EOT\DC2\ETXq\STX\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\ENQ\ACK\DC2\ETXq\v1\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\ENQ\SOH\DC2\ETXq2A\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\ENQ\ETX\DC2\ETXqDE\n\
    \E\n\
    \\EOT\EOT\NUL\STX\ACK\DC2\ETXt\STX-\SUB8 Represents a mapping between Attribute Keys and Units.\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\ACK\EOT\DC2\ETXt\STX\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\ACK\ACK\DC2\ETXt\v\CAN\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\ACK\SOH\DC2\ETXt\EM(\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\ACK\ETX\DC2\ETXt+,\n\
    \\212\ETX\n\
    \\STX\EOT\SOH\DC2\ACK\129\SOH\NUL\141\SOH\SOH\SUB\197\ETX ProfilesData represents the profiles data that can be stored in persistent storage,\n\
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
    \\ETX\EOT\SOH\SOH\DC2\EOT\129\SOH\b\DC4\n\
    \\164\ETX\n\
    \\EOT\EOT\SOH\STX\NUL\DC2\EOT\137\SOH\STX2\SUB\149\ETX An array of ResourceProfiles.\n\
    \ For data coming from an SDK profiler, this array will typically contain one\n\
    \ element. Host-level profilers will usually create one ResourceProfile per\n\
    \ container, as well as one additional ResourceProfile grouping all samples\n\
    \ from non-containerized processes.\n\
    \ Other resource groupings are possible as well and clarified via\n\
    \ Resource.attributes and semantic conventions.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\SOH\STX\NUL\EOT\DC2\EOT\137\SOH\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\SOH\STX\NUL\ACK\DC2\EOT\137\SOH\v\ESC\n\
    \\r\n\
    \\ENQ\EOT\SOH\STX\NUL\SOH\DC2\EOT\137\SOH\FS-\n\
    \\r\n\
    \\ENQ\EOT\SOH\STX\NUL\ETX\DC2\EOT\137\SOH01\n\
    \2\n\
    \\EOT\EOT\SOH\STX\SOH\DC2\EOT\140\SOH\STX$\SUB$ One instance of ProfilesDictionary\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\SOH\STX\SOH\ACK\DC2\EOT\140\SOH\STX\DC4\n\
    \\r\n\
    \\ENQ\EOT\SOH\STX\SOH\SOH\DC2\EOT\140\SOH\NAK\US\n\
    \\r\n\
    \\ENQ\EOT\SOH\STX\SOH\ETX\DC2\EOT\140\SOH\"#\n\
    \>\n\
    \\STX\EOT\STX\DC2\ACK\145\SOH\NUL\162\SOH\SOH\SUB0 A collection of ScopeProfiles from a Resource.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\STX\SOH\DC2\EOT\145\SOH\b\CAN\n\
    \\v\n\
    \\ETX\EOT\STX\t\DC2\EOT\146\SOH\STX\DLE\n\
    \\f\n\
    \\EOT\EOT\STX\t\NUL\DC2\EOT\146\SOH\v\SI\n\
    \\r\n\
    \\ENQ\EOT\STX\t\NUL\SOH\DC2\EOT\146\SOH\v\SI\n\
    \\r\n\
    \\ENQ\EOT\STX\t\NUL\STX\DC2\EOT\146\SOH\v\SI\n\
    \x\n\
    \\EOT\EOT\STX\STX\NUL\DC2\EOT\150\SOH\STX8\SUBj The resource for the profiles in this message.\n\
    \ If this field is not set then no resource info is known.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\STX\STX\NUL\ACK\DC2\EOT\150\SOH\STX*\n\
    \\r\n\
    \\ENQ\EOT\STX\STX\NUL\SOH\DC2\EOT\150\SOH+3\n\
    \\r\n\
    \\ENQ\EOT\STX\STX\NUL\ETX\DC2\EOT\150\SOH67\n\
    \G\n\
    \\EOT\EOT\STX\STX\SOH\DC2\EOT\153\SOH\STX,\SUB9 A list of ScopeProfiles that originate from a resource.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\STX\STX\SOH\EOT\DC2\EOT\153\SOH\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\STX\STX\SOH\ACK\DC2\EOT\153\SOH\v\CAN\n\
    \\r\n\
    \\ENQ\EOT\STX\STX\SOH\SOH\DC2\EOT\153\SOH\EM'\n\
    \\r\n\
    \\ENQ\EOT\STX\STX\SOH\ETX\DC2\EOT\153\SOH*+\n\
    \\239\ETX\n\
    \\EOT\EOT\STX\STX\STX\DC2\EOT\161\SOH\STX\CAN\SUB\224\ETX The Schema URL, if known. This is the identifier of the Schema that the resource data\n\
    \ is recorded in. Notably, the last part of the URL path is the version number of the\n\
    \ schema: http[s]://server[:port]/path/<version>. To learn more about Schema URL see\n\
    \ https://opentelemetry.io/docs/specs/otel/schemas/#schema-url\n\
    \ This schema_url applies to the data in the \"resource\" field. It does not apply\n\
    \ to the data in the \"scope_profiles\" field which have their own schema_url field.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\STX\STX\STX\ENQ\DC2\EOT\161\SOH\STX\b\n\
    \\r\n\
    \\ENQ\EOT\STX\STX\STX\SOH\DC2\EOT\161\SOH\t\DC3\n\
    \\r\n\
    \\ENQ\EOT\STX\STX\STX\ETX\DC2\EOT\161\SOH\SYN\ETB\n\
    \M\n\
    \\STX\EOT\ETX\DC2\ACK\165\SOH\NUL\180\SOH\SOH\SUB? A collection of Profiles produced by an InstrumentationScope.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\ETX\SOH\DC2\EOT\165\SOH\b\NAK\n\
    \\209\SOH\n\
    \\EOT\EOT\ETX\STX\NUL\DC2\EOT\169\SOH\STX?\SUB\194\SOH The instrumentation scope information for the profiles in this message.\n\
    \ Semantically when InstrumentationScope isn't set, it is equivalent with\n\
    \ an empty instrumentation scope name (unknown).\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\NUL\ACK\DC2\EOT\169\SOH\STX4\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\NUL\SOH\DC2\EOT\169\SOH5:\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\NUL\ETX\DC2\EOT\169\SOH=>\n\
    \P\n\
    \\EOT\EOT\ETX\STX\SOH\DC2\EOT\172\SOH\STX \SUBB A list of Profiles that originate from an instrumentation scope.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\SOH\EOT\DC2\EOT\172\SOH\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\SOH\ACK\DC2\EOT\172\SOH\v\DC2\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\SOH\SOH\DC2\EOT\172\SOH\DC3\ESC\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\SOH\ETX\DC2\EOT\172\SOH\RS\US\n\
    \\142\ETX\n\
    \\EOT\EOT\ETX\STX\STX\DC2\EOT\179\SOH\STX\CAN\SUB\255\STX The Schema URL, if known. This is the identifier of the Schema that the profile data\n\
    \ is recorded in. Notably, the last part of the URL path is the version number of the\n\
    \ schema: http[s]://server[:port]/path/<version>. To learn more about Schema URL see\n\
    \ https://opentelemetry.io/docs/specs/otel/schemas/#schema-url\n\
    \ This schema_url applies to all profiles in the \"profiles\" field.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\STX\ENQ\DC2\EOT\179\SOH\STX\b\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\STX\SOH\DC2\EOT\179\SOH\t\DC3\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\STX\ETX\DC2\EOT\179\SOH\SYN\ETB\n\
    \\172\v\n\
    \\STX\EOT\EOT\DC2\ACK\213\SOH\NUL\158\STX\SOH\SUB\203\ETX Represents a complete profile, including sample types, samples,\n\
    \ mappings to binaries, locations, functions, string table, and additional metadata.\n\
    \ It modifies and annotates pprof Profile with OpenTelemetry specific fields.\n\
    \\n\
    \ Note that whilst fields in this message retain the name and field id from pprof in most cases\n\
    \ for ease of understanding data migration, it is not intended that pprof:Profile and\n\
    \ OpenTelemetry:Profile encoding be wire compatible.\n\
    \2\207\a Profile is a common stacktrace profile format.\n\
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
    \ - On-disk, the serialized proto must be gzip-compressed.\n\
    \\n\
    \ - The profile is represented as a set of samples, where each sample\n\
    \   references a sequence of locations, and where each location belongs\n\
    \   to a mapping.\n\
    \ - There is a N->1 relationship from sample.location_id entries to\n\
    \   locations. For every sample.location_id entry there must be a\n\
    \   unique Location with that index.\n\
    \ - There is an optional N->1 relationship from locations to\n\
    \   mappings. For every nonzero Location.mapping_id there must be a\n\
    \   unique Mapping with that index.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\EOT\SOH\DC2\EOT\213\SOH\b\SI\n\
    \\177\ETX\n\
    \\EOT\EOT\EOT\STX\NUL\DC2\EOT\222\SOH\STX%\SUB\162\ETX A description of the samples associated with each Sample.value.\n\
    \ For a cpu profile this might be:\n\
    \   [[\"cpu\",\"nanoseconds\"]] or [[\"wall\",\"seconds\"]] or [[\"syscall\",\"count\"]]\n\
    \ For a heap profile, this might be:\n\
    \   [[\"allocations\",\"count\"], [\"space\",\"bytes\"]],\n\
    \ If one of the values represents the number of events represented\n\
    \ by the sample, by convention it should be at index 0 and use\n\
    \ sample_type.unit == \"count\".\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\NUL\EOT\DC2\EOT\222\SOH\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\NUL\ACK\DC2\EOT\222\SOH\v\DC4\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\NUL\SOH\DC2\EOT\222\SOH\NAK \n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\NUL\ETX\DC2\EOT\222\SOH#$\n\
    \<\n\
    \\EOT\EOT\EOT\STX\SOH\DC2\EOT\224\SOH\STX\GS\SUB. The set of samples recorded in this profile.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\SOH\EOT\DC2\EOT\224\SOH\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\SOH\ACK\DC2\EOT\224\SOH\v\DC1\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\SOH\SOH\DC2\EOT\224\SOH\DC2\CAN\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\SOH\ETX\DC2\EOT\224\SOH\ESC\FS\n\
    \M\n\
    \\EOT\EOT\EOT\STX\STX\DC2\EOT\227\SOH\STX&\SUB? References to locations in ProfilesDictionary.location_table.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\STX\EOT\DC2\EOT\227\SOH\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\STX\ENQ\DC2\EOT\227\SOH\v\DLE\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\STX\SOH\DC2\EOT\227\SOH\DC1!\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\STX\ETX\DC2\EOT\227\SOH$%\n\
    \\173\SOH\n\
    \\EOT\EOT\EOT\STX\ETX\DC2\EOT\233\SOH\STX\ETB\SUBE Time of collection (UTC) represented as nanoseconds past the epoch.\n\
    \2X The following fields 4-14 are informational, do not affect\n\
    \ interpretation of results.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\ETX\ENQ\DC2\EOT\233\SOH\STX\a\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\ETX\SOH\DC2\EOT\233\SOH\b\DC2\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\ETX\ETX\DC2\EOT\233\SOH\NAK\SYN\n\
    \C\n\
    \\EOT\EOT\EOT\STX\EOT\DC2\EOT\235\SOH\STX\ESC\SUB5 Duration of the profile, if a duration makes sense.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\EOT\ENQ\DC2\EOT\235\SOH\STX\a\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\EOT\SOH\DC2\EOT\235\SOH\b\SYN\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\EOT\ETX\DC2\EOT\235\SOH\EM\SUB\n\
    \m\n\
    \\EOT\EOT\EOT\STX\ENQ\DC2\EOT\238\SOH\STX\FS\SUB_ The kind of events between sampled occurrences.\n\
    \ e.g [ \"cpu\",\"cycles\" ] or [ \"heap\",\"bytes\" ]\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\ENQ\ACK\DC2\EOT\238\SOH\STX\v\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\ENQ\SOH\DC2\EOT\238\SOH\f\ETB\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\ENQ\ETX\DC2\EOT\238\SOH\SUB\ESC\n\
    \A\n\
    \\EOT\EOT\EOT\STX\ACK\DC2\EOT\240\SOH\STX\DC3\SUB3 The number of events between sampled occurrences.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\ACK\ENQ\DC2\EOT\240\SOH\STX\a\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\ACK\SOH\DC2\EOT\240\SOH\b\SO\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\ACK\ETX\DC2\EOT\240\SOH\DC1\DC2\n\
    \\245\STX\n\
    \\EOT\EOT\EOT\STX\a\DC2\EOT\246\SOH\STX(\SUB\181\STX Free-form text associated with the profile. The text is displayed as is\n\
    \ to the user by the tools that read profiles (e.g. by pprof). This field\n\
    \ should not be used to store any machine-readable information, it is only\n\
    \ for human-friendly content. The profile must stay functional if this field\n\
    \ is cleaned.\n\
    \\"/ Indices into ProfilesDictionary.string_table.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\a\EOT\DC2\EOT\246\SOH\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\a\ENQ\DC2\EOT\246\SOH\v\DLE\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\a\SOH\DC2\EOT\246\SOH\DC1#\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\a\ETX\DC2\EOT\246\SOH&'\n\
    \L\n\
    \\EOT\EOT\EOT\STX\b\DC2\EOT\248\SOH\STX&\SUB> Index into the sample_type array to the default sample type.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\b\ENQ\DC2\EOT\248\SOH\STX\a\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\b\SOH\DC2\EOT\248\SOH\b!\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\b\ETX\DC2\EOT\248\SOH$%\n\
    \\159\SOH\n\
    \\EOT\EOT\EOT\STX\t\DC2\EOT\254\SOH\STX\CAN\SUB\144\SOH A globally unique identifier for a profile. The ID is a 16-byte array. An ID with\n\
    \ all zeroes is considered invalid.\n\
    \\n\
    \ This field is required.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\t\ENQ\DC2\EOT\254\SOH\STX\a\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\t\SOH\DC2\EOT\254\SOH\b\DC2\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\t\ETX\DC2\EOT\254\SOH\NAK\ETB\n\
    \\247\SOH\n\
    \\EOT\EOT\EOT\STX\n\
    \\DC2\EOT\131\STX\STX'\SUB\232\SOH dropped_attributes_count is the number of attributes that were discarded. Attributes\n\
    \ can be discarded because their keys are too long or because there are too many\n\
    \ attributes. If this value is 0, then no attributes were dropped.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\n\
    \\ENQ\DC2\EOT\131\STX\STX\b\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\n\
    \\SOH\DC2\EOT\131\STX\t!\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\n\
    \\ETX\DC2\EOT\131\STX$&\n\
    \\151\SOH\n\
    \\EOT\EOT\EOT\STX\v\DC2\EOT\134\STX\STX&\SUB\136\SOH Specifies format of the original payload. Common values are defined in semantic conventions. [required if original_payload is present]\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\v\ENQ\DC2\EOT\134\STX\STX\b\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\v\SOH\DC2\EOT\134\STX\t \n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\v\ETX\DC2\EOT\134\STX#%\n\
    \\232\EOT\n\
    \\EOT\EOT\EOT\STX\f\DC2\EOT\142\STX\STX\RS\SUB\217\EOT Original payload can be stored in this field. This can be useful for users who want to get the original payload.\n\
    \ Formats such as JFR are highly extensible and can contain more information than what is defined in this spec.\n\
    \ Inclusion of original payload should be configurable by the user. Default behavior should be to not include the original payload.\n\
    \ If the original payload is in pprof format, it SHOULD not be included in this field.\n\
    \ The field is optional, however if it is present then equivalent converted data should be populated in other fields\n\
    \ of this message as far as is practicable.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\f\ENQ\DC2\EOT\142\STX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\f\SOH\DC2\EOT\142\STX\b\CAN\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\f\ETX\DC2\EOT\142\STX\ESC\GS\n\
    \\243\ENQ\n\
    \\EOT\EOT\EOT\STX\r\DC2\EOT\157\STX\STX(\SUB\228\ENQ References to attributes in attribute_table. [optional]\n\
    \ It is a collection of key/value pairs. Note, global attributes\n\
    \ like server name can be set using the resource API. Examples of attributes:\n\
    \\n\
    \     \"/http/user_agent\": \"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36\"\n\
    \     \"/http/server_latency\": 300\n\
    \     \"abc.com/myattribute\": true\n\
    \     \"abc.com/score\": 10.239\n\
    \\n\
    \ The OpenTelemetry API specification further restricts the allowed value types:\n\
    \ https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/common/README.md#attribute\n\
    \ Attribute keys MUST be unique (it is not allowed to have more than one\n\
    \ attribute with the same key).\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\r\EOT\DC2\EOT\157\STX\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\r\ENQ\DC2\EOT\157\STX\v\DLE\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\r\SOH\DC2\EOT\157\STX\DC1\"\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\r\ETX\DC2\EOT\157\STX%'\n\
    \F\n\
    \\STX\EOT\ENQ\DC2\ACK\161\STX\NUL\166\STX\SOH\SUB8 Represents a mapping between Attribute Keys and Units.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\ENQ\SOH\DC2\EOT\161\STX\b\NAK\n\
    \(\n\
    \\EOT\EOT\ENQ\STX\NUL\DC2\EOT\163\STX\STX#\SUB\SUB Index into string table.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\NUL\ENQ\DC2\EOT\163\STX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\NUL\SOH\DC2\EOT\163\STX\b\RS\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\NUL\ETX\DC2\EOT\163\STX!\"\n\
    \(\n\
    \\EOT\EOT\ENQ\STX\SOH\DC2\EOT\165\STX\STX\SUB\SUB\SUB Index into string table.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\SOH\ENQ\DC2\EOT\165\STX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\SOH\SOH\DC2\EOT\165\STX\b\NAK\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\SOH\ETX\DC2\EOT\165\STX\CAN\EM\n\
    \\150\SOH\n\
    \\STX\EOT\ACK\DC2\ACK\170\STX\NUL\177\STX\SOH\SUB\135\SOH A pointer from a profile Sample to a trace Span.\n\
    \ Connects a profile sample to a trace span, identified by unique trace and span IDs.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\ACK\SOH\DC2\EOT\170\STX\b\f\n\
    \l\n\
    \\EOT\EOT\ACK\STX\NUL\DC2\EOT\173\STX\STX\NAK\SUB^ A unique identifier of a trace that this linked span is part of. The ID is a\n\
    \ 16-byte array.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ACK\STX\NUL\ENQ\DC2\EOT\173\STX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\ACK\STX\NUL\SOH\DC2\EOT\173\STX\b\DLE\n\
    \\r\n\
    \\ENQ\EOT\ACK\STX\NUL\ETX\DC2\EOT\173\STX\DC3\DC4\n\
    \S\n\
    \\EOT\EOT\ACK\STX\SOH\DC2\EOT\176\STX\STX\DC4\SUBE A unique identifier for the linked span. The ID is an 8-byte array.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ACK\STX\SOH\ENQ\DC2\EOT\176\STX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\ACK\STX\SOH\SOH\DC2\EOT\176\STX\b\SI\n\
    \\r\n\
    \\ENQ\EOT\ACK\STX\SOH\ETX\DC2\EOT\176\STX\DC2\DC3\n\
    \\156\SOH\n\
    \\STX\ENQ\NUL\DC2\ACK\181\STX\NUL\245\STX\SOH\SUB\141\SOH Specifies the method of aggregating metric values, either DELTA (change since last report)\n\
    \ or CUMULATIVE (total since a fixed start time).\n\
    \\n\
    \\v\n\
    \\ETX\ENQ\NUL\SOH\DC2\EOT\181\STX\ENQ\ESC\n\
    \W\n\
    \\EOT\ENQ\NUL\STX\NUL\DC2\EOT\183\STX\STX*\SUBI UNSPECIFIED is the default AggregationTemporality, it MUST not be used. \n\
    \\r\n\
    \\ENQ\ENQ\NUL\STX\NUL\SOH\DC2\EOT\183\STX\STX%\n\
    \\r\n\
    \\ENQ\ENQ\NUL\STX\NUL\STX\DC2\EOT\183\STX()\n\
    \\172\t\n\
    \\EOT\ENQ\NUL\STX\SOH\DC2\EOT\209\STX\STX$\SUB\157\t* DELTA is an AggregationTemporality for a profiler which reports\n\
    \changes since last report time. Successive metrics contain aggregation of\n\
    \values from continuous and non-overlapping intervals.\n\
    \\n\
    \The values for a DELTA metric are based only on the time interval\n\
    \associated with one measurement cycle. There is no dependency on\n\
    \previous measurements like is the case for CUMULATIVE metrics.\n\
    \\n\
    \For example, consider a system measuring the number of requests that\n\
    \it receives and reports the sum of these requests every second as a\n\
    \DELTA metric:\n\
    \\n\
    \1. The system starts receiving at time=t_0.\n\
    \2. A request is received, the system measures 1 request.\n\
    \3. A request is received, the system measures 1 request.\n\
    \4. A request is received, the system measures 1 request.\n\
    \5. The 1 second collection cycle ends. A metric is exported for the\n\
    \number of requests received over the interval of time t_0 to\n\
    \t_0+1 with a value of 3.\n\
    \6. A request is received, the system measures 1 request.\n\
    \7. A request is received, the system measures 1 request.\n\
    \8. The 1 second collection cycle ends. A metric is exported for the\n\
    \number of requests received over the interval of time t_0+1 to\n\
    \t_0+2 with a value of 2. \n\
    \\r\n\
    \\ENQ\ENQ\NUL\STX\SOH\SOH\DC2\EOT\209\STX\STX\US\n\
    \\r\n\
    \\ENQ\ENQ\NUL\STX\SOH\STX\DC2\EOT\209\STX\"#\n\
    \\178\r\n\
    \\EOT\ENQ\NUL\STX\STX\DC2\EOT\244\STX\STX)\SUB\163\r* CUMULATIVE is an AggregationTemporality for a profiler which\n\
    \reports changes since a fixed start time. This means that current values\n\
    \of a CUMULATIVE metric depend on all previous measurements since the\n\
    \start time. Because of this, the sender is required to retain this state\n\
    \in some form. If this state is lost or invalidated, the CUMULATIVE metric\n\
    \values MUST be reset and a new fixed start time following the last\n\
    \reported measurement time sent MUST be used.\n\
    \\n\
    \For example, consider a system measuring the number of requests that\n\
    \it receives and reports the sum of these requests every second as a\n\
    \CUMULATIVE metric:\n\
    \\n\
    \1. The system starts receiving at time=t_0.\n\
    \2. A request is received, the system measures 1 request.\n\
    \3. A request is received, the system measures 1 request.\n\
    \4. A request is received, the system measures 1 request.\n\
    \5. The 1 second collection cycle ends. A metric is exported for the\n\
    \number of requests received over the interval of time t_0 to\n\
    \t_0+1 with a value of 3.\n\
    \6. A request is received, the system measures 1 request.\n\
    \7. A request is received, the system measures 1 request.\n\
    \8. The 1 second collection cycle ends. A metric is exported for the\n\
    \number of requests received over the interval of time t_0 to\n\
    \t_0+2 with a value of 5.\n\
    \9. The system experiences a fault and loses state.\n\
    \10. The system recovers and resumes receiving at time=t_1.\n\
    \11. A request is received, the system measures 1 request.\n\
    \12. The 1 second collection cycle ends. A metric is exported for the\n\
    \number of requests received over the interval of time t_1 to\n\
    \t_1+1 with a value of 1.\n\
    \\n\
    \Note: Even though, when reporting changes since last report time, using\n\
    \CUMULATIVE is valid, it is not recommended. \n\
    \\r\n\
    \\ENQ\ENQ\NUL\STX\STX\SOH\DC2\EOT\244\STX\STX$\n\
    \\r\n\
    \\ENQ\ENQ\NUL\STX\STX\STX\DC2\EOT\244\STX'(\n\
    \l\n\
    \\STX\EOT\a\DC2\ACK\248\STX\NUL\253\STX\SOH\SUB^ ValueType describes the type and units of a value, with an optional aggregation temporality.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\a\SOH\DC2\EOT\248\STX\b\DC1\n\
    \;\n\
    \\EOT\EOT\a\STX\NUL\DC2\EOT\249\STX\STX\SUB\"- Index into ProfilesDictionary.string_table.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\a\STX\NUL\ENQ\DC2\EOT\249\STX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\a\STX\NUL\SOH\DC2\EOT\249\STX\b\NAK\n\
    \\r\n\
    \\ENQ\EOT\a\STX\NUL\ETX\DC2\EOT\249\STX\CAN\EM\n\
    \;\n\
    \\EOT\EOT\a\STX\SOH\DC2\EOT\250\STX\STX\SUB\"- Index into ProfilesDictionary.string_table.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\a\STX\SOH\ENQ\DC2\EOT\250\STX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\a\STX\SOH\SOH\DC2\EOT\250\STX\b\NAK\n\
    \\r\n\
    \\ENQ\EOT\a\STX\SOH\ETX\DC2\EOT\250\STX\CAN\EM\n\
    \\f\n\
    \\EOT\EOT\a\STX\STX\DC2\EOT\252\STX\STX5\n\
    \\r\n\
    \\ENQ\EOT\a\STX\STX\ACK\DC2\EOT\252\STX\STX\CAN\n\
    \\r\n\
    \\ENQ\EOT\a\STX\STX\SOH\DC2\EOT\252\STX\EM0\n\
    \\r\n\
    \\ENQ\EOT\a\STX\STX\ETX\DC2\EOT\252\STX34\n\
    \\128\STX\n\
    \\STX\EOT\b\DC2\ACK\131\ETX\NUL\153\ETX\SOH\SUB\241\SOH Each Sample records values encountered in some program\n\
    \ context. The program context is typically a stack trace, perhaps\n\
    \ augmented with auxiliary information like the thread-id, some\n\
    \ indicator of a higher level request being handled etc.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\b\SOH\DC2\EOT\131\ETX\b\SO\n\
    \\128\SOH\n\
    \\EOT\EOT\b\STX\NUL\DC2\EOT\133\ETX\STX\"\SUBr locations_start_index along with locations_length refers to to a slice of locations in Profile.location_indices.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\b\STX\NUL\ENQ\DC2\EOT\133\ETX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\b\STX\NUL\SOH\DC2\EOT\133\ETX\b\GS\n\
    \\r\n\
    \\ENQ\EOT\b\STX\NUL\ETX\DC2\EOT\133\ETX !\n\
    \\154\SOH\n\
    \\EOT\EOT\b\STX\SOH\DC2\EOT\136\ETX\STX\GS\SUB\139\SOH locations_length along with locations_start_index refers to a slice of locations in Profile.location_indices.\n\
    \ Supersedes location_index.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\b\STX\SOH\ENQ\DC2\EOT\136\ETX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\b\STX\SOH\SOH\DC2\EOT\136\ETX\b\CAN\n\
    \\r\n\
    \\ENQ\EOT\b\STX\SOH\ETX\DC2\EOT\136\ETX\ESC\FS\n\
    \\231\STX\n\
    \\EOT\EOT\b\STX\STX\DC2\EOT\143\ETX\STX\ESC\SUB\216\STX The type and unit of each value is defined by the corresponding\n\
    \ entry in Profile.sample_type. All samples must have the same\n\
    \ number of values, the same as the length of Profile.sample_type.\n\
    \ When aggregating multiple samples into a single sample, the\n\
    \ result has a list of values that is the element-wise sum of the\n\
    \ lists of the originals.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\b\STX\STX\EOT\DC2\EOT\143\ETX\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\b\STX\STX\ENQ\DC2\EOT\143\ETX\v\DLE\n\
    \\r\n\
    \\ENQ\EOT\b\STX\STX\SOH\DC2\EOT\143\ETX\DC1\SYN\n\
    \\r\n\
    \\ENQ\EOT\b\STX\STX\ETX\DC2\EOT\143\ETX\EM\SUB\n\
    \Z\n\
    \\EOT\EOT\b\STX\ETX\DC2\EOT\145\ETX\STX'\SUBL References to attributes in ProfilesDictionary.attribute_table. [optional]\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\b\STX\ETX\EOT\DC2\EOT\145\ETX\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\b\STX\ETX\ENQ\DC2\EOT\145\ETX\v\DLE\n\
    \\r\n\
    \\ENQ\EOT\b\STX\ETX\SOH\DC2\EOT\145\ETX\DC1\"\n\
    \\r\n\
    \\ENQ\EOT\b\STX\ETX\ETX\DC2\EOT\145\ETX%&\n\
    \N\n\
    \\EOT\EOT\b\STX\EOT\DC2\EOT\148\ETX\STX \SUB@ Reference to link in ProfilesDictionary.link_table. [optional]\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\b\STX\EOT\EOT\DC2\EOT\148\ETX\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\b\STX\EOT\ENQ\DC2\EOT\148\ETX\v\DLE\n\
    \\r\n\
    \\ENQ\EOT\b\STX\EOT\SOH\DC2\EOT\148\ETX\DC1\ESC\n\
    \\r\n\
    \\ENQ\EOT\b\STX\EOT\ETX\DC2\EOT\148\ETX\RS\US\n\
    \\161\SOH\n\
    \\EOT\EOT\b\STX\ENQ\DC2\EOT\152\ETX\STX+\SUB\146\SOH Timestamps associated with Sample represented in nanoseconds. These timestamps are expected\n\
    \ to fall within the Profile's time range. [optional]\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\b\STX\ENQ\EOT\DC2\EOT\152\ETX\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\b\STX\ENQ\ENQ\DC2\EOT\152\ETX\v\DC1\n\
    \\r\n\
    \\ENQ\EOT\b\STX\ENQ\SOH\DC2\EOT\152\ETX\DC2&\n\
    \\r\n\
    \\ENQ\EOT\b\STX\ENQ\ETX\DC2\EOT\152\ETX)*\n\
    \\130\SOH\n\
    \\STX\EOT\t\DC2\ACK\157\ETX\NUL\175\ETX\SOH\SUBt Describes the mapping of a binary in memory, including its address range,\n\
    \ file offset, and metadata like build ID\n\
    \\n\
    \\v\n\
    \\ETX\EOT\t\SOH\DC2\EOT\157\ETX\b\SI\n\
    \K\n\
    \\EOT\EOT\t\STX\NUL\DC2\EOT\159\ETX\STX\SUB\SUB= Address at which the binary (or DLL) is loaded into memory.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\t\STX\NUL\ENQ\DC2\EOT\159\ETX\STX\b\n\
    \\r\n\
    \\ENQ\EOT\t\STX\NUL\SOH\DC2\EOT\159\ETX\t\NAK\n\
    \\r\n\
    \\ENQ\EOT\t\STX\NUL\ETX\DC2\EOT\159\ETX\CAN\EM\n\
    \H\n\
    \\EOT\EOT\t\STX\SOH\DC2\EOT\161\ETX\STX\SUB\SUB: The limit of the address range occupied by this mapping.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\t\STX\SOH\ENQ\DC2\EOT\161\ETX\STX\b\n\
    \\r\n\
    \\ENQ\EOT\t\STX\SOH\SOH\DC2\EOT\161\ETX\t\NAK\n\
    \\r\n\
    \\ENQ\EOT\t\STX\SOH\ETX\DC2\EOT\161\ETX\CAN\EM\n\
    \R\n\
    \\EOT\EOT\t\STX\STX\DC2\EOT\163\ETX\STX\EM\SUBD Offset in the binary that corresponds to the first mapped address.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\t\STX\STX\ENQ\DC2\EOT\163\ETX\STX\b\n\
    \\r\n\
    \\ENQ\EOT\t\STX\STX\SOH\DC2\EOT\163\ETX\t\DC4\n\
    \\r\n\
    \\ENQ\EOT\t\STX\STX\ETX\DC2\EOT\163\ETX\ETB\CAN\n\
    \\216\SOH\n\
    \\EOT\EOT\t\STX\ETX\DC2\EOT\167\ETX\STX\RS\SUB\154\SOH The object this entry is loaded from.  This can be a filename on\n\
    \ disk for the main binary and shared libraries, or virtual\n\
    \ abstractions like \"[vdso]\".\n\
    \\"- Index into ProfilesDictionary.string_table.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\t\STX\ETX\ENQ\DC2\EOT\167\ETX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\t\STX\ETX\SOH\DC2\EOT\167\ETX\b\EM\n\
    \\r\n\
    \\ENQ\EOT\t\STX\ETX\ETX\DC2\EOT\167\ETX\FS\GS\n\
    \Z\n\
    \\EOT\EOT\t\STX\EOT\DC2\EOT\169\ETX\STX'\SUBL References to attributes in ProfilesDictionary.attribute_table. [optional]\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\t\STX\EOT\EOT\DC2\EOT\169\ETX\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\t\STX\EOT\ENQ\DC2\EOT\169\ETX\v\DLE\n\
    \\r\n\
    \\ENQ\EOT\t\STX\EOT\SOH\DC2\EOT\169\ETX\DC1\"\n\
    \\r\n\
    \\ENQ\EOT\t\STX\EOT\ETX\DC2\EOT\169\ETX%&\n\
    \N\n\
    \\EOT\EOT\t\STX\ENQ\DC2\EOT\171\ETX\STX\EM\SUB@ The following fields indicate the resolution of symbolic info.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\t\STX\ENQ\ENQ\DC2\EOT\171\ETX\STX\ACK\n\
    \\r\n\
    \\ENQ\EOT\t\STX\ENQ\SOH\DC2\EOT\171\ETX\a\DC4\n\
    \\r\n\
    \\ENQ\EOT\t\STX\ENQ\ETX\DC2\EOT\171\ETX\ETB\CAN\n\
    \\f\n\
    \\EOT\EOT\t\STX\ACK\DC2\EOT\172\ETX\STX\EM\n\
    \\r\n\
    \\ENQ\EOT\t\STX\ACK\ENQ\DC2\EOT\172\ETX\STX\ACK\n\
    \\r\n\
    \\ENQ\EOT\t\STX\ACK\SOH\DC2\EOT\172\ETX\a\DC4\n\
    \\r\n\
    \\ENQ\EOT\t\STX\ACK\ETX\DC2\EOT\172\ETX\ETB\CAN\n\
    \\f\n\
    \\EOT\EOT\t\STX\a\DC2\EOT\173\ETX\STX\FS\n\
    \\r\n\
    \\ENQ\EOT\t\STX\a\ENQ\DC2\EOT\173\ETX\STX\ACK\n\
    \\r\n\
    \\ENQ\EOT\t\STX\a\SOH\DC2\EOT\173\ETX\a\ETB\n\
    \\r\n\
    \\ENQ\EOT\t\STX\a\ETX\DC2\EOT\173\ETX\SUB\ESC\n\
    \\f\n\
    \\EOT\EOT\t\STX\b\DC2\EOT\174\ETX\STX\GS\n\
    \\r\n\
    \\ENQ\EOT\t\STX\b\ENQ\DC2\EOT\174\ETX\STX\ACK\n\
    \\r\n\
    \\ENQ\EOT\t\STX\b\SOH\DC2\EOT\174\ETX\a\CAN\n\
    \\r\n\
    \\ENQ\EOT\t\STX\b\ETX\DC2\EOT\174\ETX\ESC\FS\n\
    \D\n\
    \\STX\EOT\n\
    \\DC2\ACK\178\ETX\NUL\206\ETX\SOH\SUB6 Describes function and line table debug information.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\n\
    \\SOH\DC2\EOT\178\ETX\b\DLE\n\
    \\159\SOH\n\
    \\EOT\EOT\n\
    \\STX\NUL\DC2\EOT\182\ETX\STX#\SUB\144\SOH Reference to mapping in ProfilesDictionary.mapping_table.\n\
    \ It can be unset if the mapping is unknown or not applicable for\n\
    \ this profile type.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\NUL\EOT\DC2\EOT\182\ETX\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\NUL\ENQ\DC2\EOT\182\ETX\v\DLE\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\NUL\SOH\DC2\EOT\182\ETX\DC1\RS\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\NUL\ETX\DC2\EOT\182\ETX!\"\n\
    \\191\STX\n\
    \\EOT\EOT\n\
    \\STX\SOH\DC2\EOT\188\ETX\STX\NAK\SUB\176\STX The instruction address for this location, if available.  It\n\
    \ should be within [Mapping.memory_start...Mapping.memory_limit]\n\
    \ for the corresponding mapping. A non-leaf address may be in the\n\
    \ middle of a call instruction. It is up to display tools to find\n\
    \ the beginning of the instruction if necessary.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\SOH\ENQ\DC2\EOT\188\ETX\STX\b\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\SOH\SOH\DC2\EOT\188\ETX\t\DLE\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\SOH\ETX\DC2\EOT\188\ETX\DC3\DC4\n\
    \\161\STX\n\
    \\EOT\EOT\n\
    \\STX\STX\DC2\EOT\196\ETX\STX\EM\SUB\146\STX Multiple line indicates this location has inlined functions,\n\
    \ where the last entry represents the caller into which the\n\
    \ preceding entries were inlined.\n\
    \\n\
    \ E.g., if memcpy() is inlined into printf:\n\
    \    line[0].function_name == \"memcpy\"\n\
    \    line[1].function_name == \"printf\"\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\STX\EOT\DC2\EOT\196\ETX\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\STX\ACK\DC2\EOT\196\ETX\v\SI\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\STX\SOH\DC2\EOT\196\ETX\DLE\DC4\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\STX\ETX\DC2\EOT\196\ETX\ETB\CAN\n\
    \\189\STX\n\
    \\EOT\EOT\n\
    \\STX\ETX\DC2\EOT\202\ETX\STX\NAK\SUB\174\STX Provides an indication that multiple symbols map to this location's\n\
    \ address, for example due to identical code folding by the linker. In that\n\
    \ case the line information above represents one of the multiple\n\
    \ symbols. This field must be recomputed when the symbolization state of the\n\
    \ profile changes.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\ETX\ENQ\DC2\EOT\202\ETX\STX\ACK\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\ETX\SOH\DC2\EOT\202\ETX\a\DLE\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\ETX\ETX\DC2\EOT\202\ETX\DC3\DC4\n\
    \Z\n\
    \\EOT\EOT\n\
    \\STX\EOT\DC2\EOT\205\ETX\STX'\SUBL References to attributes in ProfilesDictionary.attribute_table. [optional]\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\EOT\EOT\DC2\EOT\205\ETX\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\EOT\ENQ\DC2\EOT\205\ETX\v\DLE\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\EOT\SOH\DC2\EOT\205\ETX\DC1\"\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\EOT\ETX\DC2\EOT\205\ETX%&\n\
    \O\n\
    \\STX\EOT\v\DC2\ACK\209\ETX\NUL\216\ETX\SOH\SUBA Details a specific line in a source code, linked to a function.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\v\SOH\DC2\EOT\209\ETX\b\f\n\
    \K\n\
    \\EOT\EOT\v\STX\NUL\DC2\EOT\211\ETX\STX\ESC\SUB= Reference to function in ProfilesDictionary.function_table.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\v\STX\NUL\ENQ\DC2\EOT\211\ETX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\v\STX\NUL\SOH\DC2\EOT\211\ETX\b\SYN\n\
    \\r\n\
    \\ENQ\EOT\v\STX\NUL\ETX\DC2\EOT\211\ETX\EM\SUB\n\
    \:\n\
    \\EOT\EOT\v\STX\SOH\DC2\EOT\213\ETX\STX\DC1\SUB, Line number in source code. 0 means unset.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\v\STX\SOH\ENQ\DC2\EOT\213\ETX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\v\STX\SOH\SOH\DC2\EOT\213\ETX\b\f\n\
    \\r\n\
    \\ENQ\EOT\v\STX\SOH\ETX\DC2\EOT\213\ETX\SI\DLE\n\
    \<\n\
    \\EOT\EOT\v\STX\STX\DC2\EOT\215\ETX\STX\DC3\SUB. Column number in source code. 0 means unset.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\v\STX\STX\ENQ\DC2\EOT\215\ETX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\v\STX\STX\SOH\DC2\EOT\215\ETX\b\SO\n\
    \\r\n\
    \\ENQ\EOT\v\STX\STX\ETX\DC2\EOT\215\ETX\DC1\DC2\n\
    \\139\SOH\n\
    \\STX\EOT\f\DC2\ACK\220\ETX\NUL\230\ETX\SOH\SUB} Describes a function, including its human-readable name, system name,\n\
    \ source file, and starting line number in the source.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\f\SOH\DC2\EOT\220\ETX\b\DLE\n\
    \=\n\
    \\EOT\EOT\f\STX\NUL\DC2\EOT\222\ETX\STX\SUB\SUB/ Function name. Empty string if not available.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\f\STX\NUL\ENQ\DC2\EOT\222\ETX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\f\STX\NUL\SOH\DC2\EOT\222\ETX\b\NAK\n\
    \\r\n\
    \\ENQ\EOT\f\STX\NUL\ETX\DC2\EOT\222\ETX\CAN\EM\n\
    \\135\SOH\n\
    \\EOT\EOT\f\STX\SOH\DC2\EOT\225\ETX\STX!\SUBy Function name, as identified by the system. For instance,\n\
    \ it can be a C++ mangled name. Empty string if not available.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\f\STX\SOH\ENQ\DC2\EOT\225\ETX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\f\STX\SOH\SOH\DC2\EOT\225\ETX\b\FS\n\
    \\r\n\
    \\ENQ\EOT\f\STX\SOH\ETX\DC2\EOT\225\ETX\US \n\
    \S\n\
    \\EOT\EOT\f\STX\STX\DC2\EOT\227\ETX\STX\RS\SUBE Source file containing the function. Empty string if not available.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\f\STX\STX\ENQ\DC2\EOT\227\ETX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\f\STX\STX\SOH\DC2\EOT\227\ETX\b\EM\n\
    \\r\n\
    \\ENQ\EOT\f\STX\STX\ETX\DC2\EOT\227\ETX\FS\GS\n\
    \:\n\
    \\EOT\EOT\f\STX\ETX\DC2\EOT\229\ETX\STX\ETB\SUB, Line number in source file. 0 means unset.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\f\STX\ETX\ENQ\DC2\EOT\229\ETX\STX\a\n\
    \\r\n\
    \\ENQ\EOT\f\STX\ETX\SOH\DC2\EOT\229\ETX\b\DC2\n\
    \\r\n\
    \\ENQ\EOT\f\STX\ETX\ETX\DC2\EOT\229\ETX\NAK\SYNb\ACKproto3"