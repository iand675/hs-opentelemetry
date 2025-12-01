{- HLINT ignore -}
{- This file was auto-generated from opentelemetry/proto/resource/v1/resource.proto by the proto-lens-protoc program. -}
{-# LANGUAGE ScopedTypeVariables, DataKinds, TypeFamilies, UndecidableInstances, GeneralizedNewtypeDeriving, MultiParamTypeClasses, FlexibleContexts, FlexibleInstances, PatternSynonyms, MagicHash, NoImplicitPrelude, DataKinds, BangPatterns, TypeApplications, OverloadedStrings, DerivingStrategies#-}
{-# OPTIONS_GHC -Wno-unused-imports#-}
{-# OPTIONS_GHC -Wno-duplicate-exports#-}
{-# OPTIONS_GHC -Wno-dodgy-exports#-}
module Proto.Opentelemetry.Proto.Resource.V1.Resource (
        Resource()
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
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Resource.V1.Resource_Fields.attributes' @:: Lens' Resource [Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue]@
         * 'Proto.Opentelemetry.Proto.Resource.V1.Resource_Fields.vec'attributes' @:: Lens' Resource (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue)@
         * 'Proto.Opentelemetry.Proto.Resource.V1.Resource_Fields.droppedAttributesCount' @:: Lens' Resource Data.Word.Word32@
         * 'Proto.Opentelemetry.Proto.Resource.V1.Resource_Fields.entityRefs' @:: Lens' Resource [Proto.Opentelemetry.Proto.Common.V1.Common.EntityRef]@
         * 'Proto.Opentelemetry.Proto.Resource.V1.Resource_Fields.vec'entityRefs' @:: Lens' Resource (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.EntityRef)@ -}
data Resource
  = Resource'_constructor {_Resource'attributes :: !(Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue),
                           _Resource'droppedAttributesCount :: !Data.Word.Word32,
                           _Resource'entityRefs :: !(Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.EntityRef),
                           _Resource'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show Resource where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField Resource "attributes" [Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Resource'attributes
           (\ x__ y__ -> x__ {_Resource'attributes = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField Resource "vec'attributes" (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Resource'attributes
           (\ x__ y__ -> x__ {_Resource'attributes = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Resource "droppedAttributesCount" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Resource'droppedAttributesCount
           (\ x__ y__ -> x__ {_Resource'droppedAttributesCount = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Resource "entityRefs" [Proto.Opentelemetry.Proto.Common.V1.Common.EntityRef] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Resource'entityRefs
           (\ x__ y__ -> x__ {_Resource'entityRefs = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField Resource "vec'entityRefs" (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.EntityRef) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Resource'entityRefs
           (\ x__ y__ -> x__ {_Resource'entityRefs = y__}))
        Prelude.id
instance Data.ProtoLens.Message Resource where
  messageName _
    = Data.Text.pack "opentelemetry.proto.resource.v1.Resource"
  packedMessageDescriptor _
    = "\n\
      \\bResource\DC2G\n\
      \\n\
      \attributes\CAN\SOH \ETX(\v2'.opentelemetry.proto.common.v1.KeyValueR\n\
      \attributes\DC28\n\
      \\CANdropped_attributes_count\CAN\STX \SOH(\rR\SYNdroppedAttributesCount\DC2I\n\
      \\ventity_refs\CAN\ETX \ETX(\v2(.opentelemetry.proto.common.v1.EntityRefR\n\
      \entityRefs"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        attributes__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "attributes"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"attributes")) ::
              Data.ProtoLens.FieldDescriptor Resource
        droppedAttributesCount__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "dropped_attributes_count"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"droppedAttributesCount")) ::
              Data.ProtoLens.FieldDescriptor Resource
        entityRefs__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "entity_refs"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Opentelemetry.Proto.Common.V1.Common.EntityRef)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"entityRefs")) ::
              Data.ProtoLens.FieldDescriptor Resource
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, attributes__field_descriptor),
           (Data.ProtoLens.Tag 2, droppedAttributesCount__field_descriptor),
           (Data.ProtoLens.Tag 3, entityRefs__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Resource'_unknownFields
        (\ x__ y__ -> x__ {_Resource'_unknownFields = y__})
  defMessage
    = Resource'_constructor
        {_Resource'attributes = Data.Vector.Generic.empty,
         _Resource'droppedAttributesCount = Data.ProtoLens.fieldDefault,
         _Resource'entityRefs = Data.Vector.Generic.empty,
         _Resource'_unknownFields = []}
  parseMessage
    = let
        loop ::
          Resource
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue
             -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Proto.Opentelemetry.Proto.Common.V1.Common.EntityRef
                -> Data.ProtoLens.Encoding.Bytes.Parser Resource
        loop x mutable'attributes mutable'entityRefs
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'attributes <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                             (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                mutable'attributes)
                      frozen'entityRefs <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                             (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                mutable'entityRefs)
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
                              (Data.ProtoLens.Field.field @"vec'attributes") frozen'attributes
                              (Lens.Family2.set
                                 (Data.ProtoLens.Field.field @"vec'entityRefs") frozen'entityRefs
                                 x)))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "attributes"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'attributes y)
                                loop x v mutable'entityRefs
                        16
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "dropped_attributes_count"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"droppedAttributesCount") y x)
                                  mutable'attributes mutable'entityRefs
                        26
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "entity_refs"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'entityRefs y)
                                loop x mutable'attributes v
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'attributes mutable'entityRefs
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'attributes <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                      Data.ProtoLens.Encoding.Growing.new
              mutable'entityRefs <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                      Data.ProtoLens.Encoding.Growing.new
              loop
                Data.ProtoLens.defMessage mutable'attributes mutable'entityRefs)
          "Resource"
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
                   (Data.ProtoLens.Field.field @"vec'attributes") _x))
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
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                         ((Prelude..)
                            Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
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
                         (Data.ProtoLens.Field.field @"vec'entityRefs") _x))
                   (Data.ProtoLens.Encoding.Wire.buildFieldSet
                      (Lens.Family2.view Data.ProtoLens.unknownFields _x))))
instance Control.DeepSeq.NFData Resource where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Resource'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_Resource'attributes x__)
                (Control.DeepSeq.deepseq
                   (_Resource'droppedAttributesCount x__)
                   (Control.DeepSeq.deepseq (_Resource'entityRefs x__) ())))
packedFileDescriptor :: Data.ByteString.ByteString
packedFileDescriptor
  = "\n\
    \.opentelemetry/proto/resource/v1/resource.proto\DC2\USopentelemetry.proto.resource.v1\SUB*opentelemetry/proto/common/v1/common.proto\"\216\SOH\n\
    \\bResource\DC2G\n\
    \\n\
    \attributes\CAN\SOH \ETX(\v2'.opentelemetry.proto.common.v1.KeyValueR\n\
    \attributes\DC28\n\
    \\CANdropped_attributes_count\CAN\STX \SOH(\rR\SYNdroppedAttributesCount\DC2I\n\
    \\ventity_refs\CAN\ETX \ETX(\v2(.opentelemetry.proto.common.v1.EntityRefR\n\
    \entityRefsB\131\SOH\n\
    \\"io.opentelemetry.proto.resource.v1B\rResourceProtoP\SOHZ*go.opentelemetry.io/proto/otlp/resource/v1\170\STX\USOpenTelemetry.Proto.Resource.V1J\158\v\n\
    \\ACK\DC2\EOT\SO\NUL,\SOH\n\
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
    \\SOH\STX\DC2\ETX\DLE\NUL(\n\
    \\t\n\
    \\STX\ETX\NUL\DC2\ETX\DC2\NUL4\n\
    \\b\n\
    \\SOH\b\DC2\ETX\DC4\NUL<\n\
    \\t\n\
    \\STX\b%\DC2\ETX\DC4\NUL<\n\
    \\b\n\
    \\SOH\b\DC2\ETX\NAK\NUL\"\n\
    \\t\n\
    \\STX\b\n\
    \\DC2\ETX\NAK\NUL\"\n\
    \\b\n\
    \\SOH\b\DC2\ETX\SYN\NUL;\n\
    \\t\n\
    \\STX\b\SOH\DC2\ETX\SYN\NUL;\n\
    \\b\n\
    \\SOH\b\DC2\ETX\ETB\NUL.\n\
    \\t\n\
    \\STX\b\b\DC2\ETX\ETB\NUL.\n\
    \\b\n\
    \\SOH\b\DC2\ETX\CAN\NULA\n\
    \\t\n\
    \\STX\b\v\DC2\ETX\CAN\NULA\n\
    \#\n\
    \\STX\EOT\NUL\DC2\EOT\ESC\NUL,\SOH\SUB\ETB Resource information.\n\
    \\n\
    \\n\
    \\n\
    \\ETX\EOT\NUL\SOH\DC2\ETX\ESC\b\DLE\n\
    \\242\SOH\n\
    \\EOT\EOT\NUL\STX\NUL\DC2\ETX \STXA\SUB\228\SOH Set of attributes that describe the resource.\n\
    \ Attribute keys MUST be unique (it is not allowed to have more than one\n\
    \ attribute with the same key).\n\
    \ The behavior of software that receives duplicated keys can be unpredictable.\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\EOT\DC2\ETX \STX\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\ACK\DC2\ETX \v1\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\SOH\DC2\ETX 2<\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\ETX\DC2\ETX ?@\n\
    \e\n\
    \\EOT\EOT\NUL\STX\SOH\DC2\ETX$\STX&\SUBX The number of dropped attributes. If the value is 0, then\n\
    \ no attributes were dropped.\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\SOH\ENQ\DC2\ETX$\STX\b\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\SOH\SOH\DC2\ETX$\t!\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\SOH\ETX\DC2\ETX$$%\n\
    \\163\SOH\n\
    \\EOT\EOT\NUL\STX\STX\DC2\ETX+\STXC\SUB\149\SOH Set of entities that participate in this Resource.\n\
    \\n\
    \ Note: keys in the references MUST exist in attributes of this message.\n\
    \\n\
    \ Status: [Development]\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\STX\EOT\DC2\ETX+\STX\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\STX\ACK\DC2\ETX+\v2\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\STX\SOH\DC2\ETX+3>\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\STX\ETX\DC2\ETX+ABb\ACKproto3"