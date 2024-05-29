{- This file was auto-generated from opentelemetry/proto/trace/v1/trace.proto by the proto-lens-protoc program. -}
{-# LANGUAGE ScopedTypeVariables, DataKinds, TypeFamilies, UndecidableInstances, GeneralizedNewtypeDeriving, MultiParamTypeClasses, FlexibleContexts, FlexibleInstances, PatternSynonyms, MagicHash, NoImplicitPrelude, DataKinds, BangPatterns, TypeApplications, OverloadedStrings, DerivingStrategies#-}
{-# OPTIONS_GHC -Wno-unused-imports#-}
{-# OPTIONS_GHC -Wno-duplicate-exports#-}
{-# OPTIONS_GHC -Wno-dodgy-exports#-}
module Proto.Opentelemetry.Proto.Trace.V1.Trace (
        InstrumentationLibrarySpans(), ResourceSpans(), Span(),
        Span'Event(), Span'Link(), Span'SpanKind(..), Span'SpanKind(),
        Span'SpanKind'UnrecognizedValue, Status(),
        Status'DeprecatedStatusCode(..), Status'DeprecatedStatusCode(),
        Status'DeprecatedStatusCode'UnrecognizedValue,
        Status'StatusCode(..), Status'StatusCode(),
        Status'StatusCode'UnrecognizedValue, TracesData()
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
     
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.instrumentationLibrary' @:: Lens' InstrumentationLibrarySpans Proto.Opentelemetry.Proto.Common.V1.Common.InstrumentationLibrary@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.maybe'instrumentationLibrary' @:: Lens' InstrumentationLibrarySpans (Prelude.Maybe Proto.Opentelemetry.Proto.Common.V1.Common.InstrumentationLibrary)@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.spans' @:: Lens' InstrumentationLibrarySpans [Span]@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.vec'spans' @:: Lens' InstrumentationLibrarySpans (Data.Vector.Vector Span)@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.schemaUrl' @:: Lens' InstrumentationLibrarySpans Data.Text.Text@ -}
data InstrumentationLibrarySpans
  = InstrumentationLibrarySpans'_constructor {_InstrumentationLibrarySpans'instrumentationLibrary :: !(Prelude.Maybe Proto.Opentelemetry.Proto.Common.V1.Common.InstrumentationLibrary),
                                              _InstrumentationLibrarySpans'spans :: !(Data.Vector.Vector Span),
                                              _InstrumentationLibrarySpans'schemaUrl :: !Data.Text.Text,
                                              _InstrumentationLibrarySpans'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show InstrumentationLibrarySpans where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField InstrumentationLibrarySpans "instrumentationLibrary" Proto.Opentelemetry.Proto.Common.V1.Common.InstrumentationLibrary where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _InstrumentationLibrarySpans'instrumentationLibrary
           (\ x__ y__
              -> x__
                   {_InstrumentationLibrarySpans'instrumentationLibrary = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField InstrumentationLibrarySpans "maybe'instrumentationLibrary" (Prelude.Maybe Proto.Opentelemetry.Proto.Common.V1.Common.InstrumentationLibrary) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _InstrumentationLibrarySpans'instrumentationLibrary
           (\ x__ y__
              -> x__
                   {_InstrumentationLibrarySpans'instrumentationLibrary = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField InstrumentationLibrarySpans "spans" [Span] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _InstrumentationLibrarySpans'spans
           (\ x__ y__ -> x__ {_InstrumentationLibrarySpans'spans = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField InstrumentationLibrarySpans "vec'spans" (Data.Vector.Vector Span) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _InstrumentationLibrarySpans'spans
           (\ x__ y__ -> x__ {_InstrumentationLibrarySpans'spans = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField InstrumentationLibrarySpans "schemaUrl" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _InstrumentationLibrarySpans'schemaUrl
           (\ x__ y__ -> x__ {_InstrumentationLibrarySpans'schemaUrl = y__}))
        Prelude.id
instance Data.ProtoLens.Message InstrumentationLibrarySpans where
  messageName _
    = Data.Text.pack
        "opentelemetry.proto.trace.v1.InstrumentationLibrarySpans"
  packedMessageDescriptor _
    = "\n\
      \\ESCInstrumentationLibrarySpans\DC2n\n\
      \\ETBinstrumentation_library\CAN\SOH \SOH(\v25.opentelemetry.proto.common.v1.InstrumentationLibraryR\SYNinstrumentationLibrary\DC28\n\
      \\ENQspans\CAN\STX \ETX(\v2\".opentelemetry.proto.trace.v1.SpanR\ENQspans\DC2\GS\n\
      \\n\
      \schema_url\CAN\ETX \SOH(\tR\tschemaUrl"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        instrumentationLibrary__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "instrumentation_library"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Opentelemetry.Proto.Common.V1.Common.InstrumentationLibrary)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'instrumentationLibrary")) ::
              Data.ProtoLens.FieldDescriptor InstrumentationLibrarySpans
        spans__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "spans"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Span)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked (Data.ProtoLens.Field.field @"spans")) ::
              Data.ProtoLens.FieldDescriptor InstrumentationLibrarySpans
        schemaUrl__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "schema_url"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"schemaUrl")) ::
              Data.ProtoLens.FieldDescriptor InstrumentationLibrarySpans
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, instrumentationLibrary__field_descriptor),
           (Data.ProtoLens.Tag 2, spans__field_descriptor),
           (Data.ProtoLens.Tag 3, schemaUrl__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _InstrumentationLibrarySpans'_unknownFields
        (\ x__ y__
           -> x__ {_InstrumentationLibrarySpans'_unknownFields = y__})
  defMessage
    = InstrumentationLibrarySpans'_constructor
        {_InstrumentationLibrarySpans'instrumentationLibrary = Prelude.Nothing,
         _InstrumentationLibrarySpans'spans = Data.Vector.Generic.empty,
         _InstrumentationLibrarySpans'schemaUrl = Data.ProtoLens.fieldDefault,
         _InstrumentationLibrarySpans'_unknownFields = []}
  parseMessage
    = let
        loop ::
          InstrumentationLibrarySpans
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Span
             -> Data.ProtoLens.Encoding.Bytes.Parser InstrumentationLibrarySpans
        loop x mutable'spans
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'spans <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                        (Data.ProtoLens.Encoding.Growing.unsafeFreeze mutable'spans)
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
                              (Data.ProtoLens.Field.field @"vec'spans") frozen'spans x))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "instrumentation_library"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"instrumentationLibrary") y x)
                                  mutable'spans
                        18
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "spans"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'spans y)
                                loop x v
                        26
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do value <- do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                                       Data.ProtoLens.Encoding.Bytes.getBytes
                                                         (Prelude.fromIntegral len)
                                           Data.ProtoLens.Encoding.Bytes.runEither
                                             (case Data.Text.Encoding.decodeUtf8' value of
                                                (Prelude.Left err)
                                                  -> Prelude.Left (Prelude.show err)
                                                (Prelude.Right r) -> Prelude.Right r))
                                       "schema_url"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"schemaUrl") y x)
                                  mutable'spans
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'spans
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'spans <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                 Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'spans)
          "InstrumentationLibrarySpans"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view
                    (Data.ProtoLens.Field.field @"maybe'instrumentationLibrary") _x
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
                   (Lens.Family2.view (Data.ProtoLens.Field.field @"vec'spans") _x))
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
instance Control.DeepSeq.NFData InstrumentationLibrarySpans where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_InstrumentationLibrarySpans'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_InstrumentationLibrarySpans'instrumentationLibrary x__)
                (Control.DeepSeq.deepseq
                   (_InstrumentationLibrarySpans'spans x__)
                   (Control.DeepSeq.deepseq
                      (_InstrumentationLibrarySpans'schemaUrl x__) ())))
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.resource' @:: Lens' ResourceSpans Proto.Opentelemetry.Proto.Resource.V1.Resource.Resource@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.maybe'resource' @:: Lens' ResourceSpans (Prelude.Maybe Proto.Opentelemetry.Proto.Resource.V1.Resource.Resource)@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.instrumentationLibrarySpans' @:: Lens' ResourceSpans [InstrumentationLibrarySpans]@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.vec'instrumentationLibrarySpans' @:: Lens' ResourceSpans (Data.Vector.Vector InstrumentationLibrarySpans)@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.schemaUrl' @:: Lens' ResourceSpans Data.Text.Text@ -}
data ResourceSpans
  = ResourceSpans'_constructor {_ResourceSpans'resource :: !(Prelude.Maybe Proto.Opentelemetry.Proto.Resource.V1.Resource.Resource),
                                _ResourceSpans'instrumentationLibrarySpans :: !(Data.Vector.Vector InstrumentationLibrarySpans),
                                _ResourceSpans'schemaUrl :: !Data.Text.Text,
                                _ResourceSpans'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show ResourceSpans where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField ResourceSpans "resource" Proto.Opentelemetry.Proto.Resource.V1.Resource.Resource where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ResourceSpans'resource
           (\ x__ y__ -> x__ {_ResourceSpans'resource = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField ResourceSpans "maybe'resource" (Prelude.Maybe Proto.Opentelemetry.Proto.Resource.V1.Resource.Resource) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ResourceSpans'resource
           (\ x__ y__ -> x__ {_ResourceSpans'resource = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ResourceSpans "instrumentationLibrarySpans" [InstrumentationLibrarySpans] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ResourceSpans'instrumentationLibrarySpans
           (\ x__ y__
              -> x__ {_ResourceSpans'instrumentationLibrarySpans = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField ResourceSpans "vec'instrumentationLibrarySpans" (Data.Vector.Vector InstrumentationLibrarySpans) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ResourceSpans'instrumentationLibrarySpans
           (\ x__ y__
              -> x__ {_ResourceSpans'instrumentationLibrarySpans = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ResourceSpans "schemaUrl" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ResourceSpans'schemaUrl
           (\ x__ y__ -> x__ {_ResourceSpans'schemaUrl = y__}))
        Prelude.id
instance Data.ProtoLens.Message ResourceSpans where
  messageName _
    = Data.Text.pack "opentelemetry.proto.trace.v1.ResourceSpans"
  packedMessageDescriptor _
    = "\n\
      \\rResourceSpans\DC2E\n\
      \\bresource\CAN\SOH \SOH(\v2).opentelemetry.proto.resource.v1.ResourceR\bresource\DC2}\n\
      \\GSinstrumentation_library_spans\CAN\STX \ETX(\v29.opentelemetry.proto.trace.v1.InstrumentationLibrarySpansR\ESCinstrumentationLibrarySpans\DC2\GS\n\
      \\n\
      \schema_url\CAN\ETX \SOH(\tR\tschemaUrl"
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
              Data.ProtoLens.FieldDescriptor ResourceSpans
        instrumentationLibrarySpans__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "instrumentation_library_spans"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor InstrumentationLibrarySpans)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"instrumentationLibrarySpans")) ::
              Data.ProtoLens.FieldDescriptor ResourceSpans
        schemaUrl__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "schema_url"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"schemaUrl")) ::
              Data.ProtoLens.FieldDescriptor ResourceSpans
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, resource__field_descriptor),
           (Data.ProtoLens.Tag 2, 
            instrumentationLibrarySpans__field_descriptor),
           (Data.ProtoLens.Tag 3, schemaUrl__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _ResourceSpans'_unknownFields
        (\ x__ y__ -> x__ {_ResourceSpans'_unknownFields = y__})
  defMessage
    = ResourceSpans'_constructor
        {_ResourceSpans'resource = Prelude.Nothing,
         _ResourceSpans'instrumentationLibrarySpans = Data.Vector.Generic.empty,
         _ResourceSpans'schemaUrl = Data.ProtoLens.fieldDefault,
         _ResourceSpans'_unknownFields = []}
  parseMessage
    = let
        loop ::
          ResourceSpans
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld InstrumentationLibrarySpans
             -> Data.ProtoLens.Encoding.Bytes.Parser ResourceSpans
        loop x mutable'instrumentationLibrarySpans
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'instrumentationLibrarySpans <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                              (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                                 mutable'instrumentationLibrarySpans)
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
                              (Data.ProtoLens.Field.field @"vec'instrumentationLibrarySpans")
                              frozen'instrumentationLibrarySpans x))
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
                                  mutable'instrumentationLibrarySpans
                        18
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "instrumentation_library_spans"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append
                                          mutable'instrumentationLibrarySpans y)
                                loop x v
                        26
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do value <- do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                                       Data.ProtoLens.Encoding.Bytes.getBytes
                                                         (Prelude.fromIntegral len)
                                           Data.ProtoLens.Encoding.Bytes.runEither
                                             (case Data.Text.Encoding.decodeUtf8' value of
                                                (Prelude.Left err)
                                                  -> Prelude.Left (Prelude.show err)
                                                (Prelude.Right r) -> Prelude.Right r))
                                       "schema_url"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"schemaUrl") y x)
                                  mutable'instrumentationLibrarySpans
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'instrumentationLibrarySpans
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'instrumentationLibrarySpans <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                       Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'instrumentationLibrarySpans)
          "ResourceSpans"
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
                      (Data.ProtoLens.Field.field @"vec'instrumentationLibrarySpans")
                      _x))
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
instance Control.DeepSeq.NFData ResourceSpans where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_ResourceSpans'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_ResourceSpans'resource x__)
                (Control.DeepSeq.deepseq
                   (_ResourceSpans'instrumentationLibrarySpans x__)
                   (Control.DeepSeq.deepseq (_ResourceSpans'schemaUrl x__) ())))
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.traceId' @:: Lens' Span Data.ByteString.ByteString@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.spanId' @:: Lens' Span Data.ByteString.ByteString@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.traceState' @:: Lens' Span Data.Text.Text@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.parentSpanId' @:: Lens' Span Data.ByteString.ByteString@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.name' @:: Lens' Span Data.Text.Text@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.kind' @:: Lens' Span Span'SpanKind@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.startTimeUnixNano' @:: Lens' Span Data.Word.Word64@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.endTimeUnixNano' @:: Lens' Span Data.Word.Word64@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.attributes' @:: Lens' Span [Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue]@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.vec'attributes' @:: Lens' Span (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue)@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.droppedAttributesCount' @:: Lens' Span Data.Word.Word32@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.events' @:: Lens' Span [Span'Event]@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.vec'events' @:: Lens' Span (Data.Vector.Vector Span'Event)@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.droppedEventsCount' @:: Lens' Span Data.Word.Word32@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.links' @:: Lens' Span [Span'Link]@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.vec'links' @:: Lens' Span (Data.Vector.Vector Span'Link)@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.droppedLinksCount' @:: Lens' Span Data.Word.Word32@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.status' @:: Lens' Span Status@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.maybe'status' @:: Lens' Span (Prelude.Maybe Status)@ -}
data Span
  = Span'_constructor {_Span'traceId :: !Data.ByteString.ByteString,
                       _Span'spanId :: !Data.ByteString.ByteString,
                       _Span'traceState :: !Data.Text.Text,
                       _Span'parentSpanId :: !Data.ByteString.ByteString,
                       _Span'name :: !Data.Text.Text,
                       _Span'kind :: !Span'SpanKind,
                       _Span'startTimeUnixNano :: !Data.Word.Word64,
                       _Span'endTimeUnixNano :: !Data.Word.Word64,
                       _Span'attributes :: !(Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue),
                       _Span'droppedAttributesCount :: !Data.Word.Word32,
                       _Span'events :: !(Data.Vector.Vector Span'Event),
                       _Span'droppedEventsCount :: !Data.Word.Word32,
                       _Span'links :: !(Data.Vector.Vector Span'Link),
                       _Span'droppedLinksCount :: !Data.Word.Word32,
                       _Span'status :: !(Prelude.Maybe Status),
                       _Span'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show Span where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField Span "traceId" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Span'traceId (\ x__ y__ -> x__ {_Span'traceId = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Span "spanId" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Span'spanId (\ x__ y__ -> x__ {_Span'spanId = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Span "traceState" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Span'traceState (\ x__ y__ -> x__ {_Span'traceState = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Span "parentSpanId" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Span'parentSpanId (\ x__ y__ -> x__ {_Span'parentSpanId = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Span "name" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Span'name (\ x__ y__ -> x__ {_Span'name = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Span "kind" Span'SpanKind where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Span'kind (\ x__ y__ -> x__ {_Span'kind = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Span "startTimeUnixNano" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Span'startTimeUnixNano
           (\ x__ y__ -> x__ {_Span'startTimeUnixNano = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Span "endTimeUnixNano" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Span'endTimeUnixNano
           (\ x__ y__ -> x__ {_Span'endTimeUnixNano = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Span "attributes" [Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Span'attributes (\ x__ y__ -> x__ {_Span'attributes = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField Span "vec'attributes" (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Span'attributes (\ x__ y__ -> x__ {_Span'attributes = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Span "droppedAttributesCount" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Span'droppedAttributesCount
           (\ x__ y__ -> x__ {_Span'droppedAttributesCount = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Span "events" [Span'Event] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Span'events (\ x__ y__ -> x__ {_Span'events = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField Span "vec'events" (Data.Vector.Vector Span'Event) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Span'events (\ x__ y__ -> x__ {_Span'events = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Span "droppedEventsCount" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Span'droppedEventsCount
           (\ x__ y__ -> x__ {_Span'droppedEventsCount = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Span "links" [Span'Link] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Span'links (\ x__ y__ -> x__ {_Span'links = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField Span "vec'links" (Data.Vector.Vector Span'Link) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Span'links (\ x__ y__ -> x__ {_Span'links = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Span "droppedLinksCount" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Span'droppedLinksCount
           (\ x__ y__ -> x__ {_Span'droppedLinksCount = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Span "status" Status where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Span'status (\ x__ y__ -> x__ {_Span'status = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField Span "maybe'status" (Prelude.Maybe Status) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Span'status (\ x__ y__ -> x__ {_Span'status = y__}))
        Prelude.id
instance Data.ProtoLens.Message Span where
  messageName _ = Data.Text.pack "opentelemetry.proto.trace.v1.Span"
  packedMessageDescriptor _
    = "\n\
      \\EOTSpan\DC2\EM\n\
      \\btrace_id\CAN\SOH \SOH(\fR\atraceId\DC2\ETB\n\
      \\aspan_id\CAN\STX \SOH(\fR\ACKspanId\DC2\US\n\
      \\vtrace_state\CAN\ETX \SOH(\tR\n\
      \traceState\DC2$\n\
      \\SOparent_span_id\CAN\EOT \SOH(\fR\fparentSpanId\DC2\DC2\n\
      \\EOTname\CAN\ENQ \SOH(\tR\EOTname\DC2?\n\
      \\EOTkind\CAN\ACK \SOH(\SO2+.opentelemetry.proto.trace.v1.Span.SpanKindR\EOTkind\DC2/\n\
      \\DC4start_time_unix_nano\CAN\a \SOH(\ACKR\DC1startTimeUnixNano\DC2+\n\
      \\DC2end_time_unix_nano\CAN\b \SOH(\ACKR\SIendTimeUnixNano\DC2G\n\
      \\n\
      \attributes\CAN\t \ETX(\v2'.opentelemetry.proto.common.v1.KeyValueR\n\
      \attributes\DC28\n\
      \\CANdropped_attributes_count\CAN\n\
      \ \SOH(\rR\SYNdroppedAttributesCount\DC2@\n\
      \\ACKevents\CAN\v \ETX(\v2(.opentelemetry.proto.trace.v1.Span.EventR\ACKevents\DC20\n\
      \\DC4dropped_events_count\CAN\f \SOH(\rR\DC2droppedEventsCount\DC2=\n\
      \\ENQlinks\CAN\r \ETX(\v2'.opentelemetry.proto.trace.v1.Span.LinkR\ENQlinks\DC2.\n\
      \\DC3dropped_links_count\CAN\SO \SOH(\rR\DC1droppedLinksCount\DC2<\n\
      \\ACKstatus\CAN\SI \SOH(\v2$.opentelemetry.proto.trace.v1.StatusR\ACKstatus\SUB\196\SOH\n\
      \\ENQEvent\DC2$\n\
      \\SOtime_unix_nano\CAN\SOH \SOH(\ACKR\ftimeUnixNano\DC2\DC2\n\
      \\EOTname\CAN\STX \SOH(\tR\EOTname\DC2G\n\
      \\n\
      \attributes\CAN\ETX \ETX(\v2'.opentelemetry.proto.common.v1.KeyValueR\n\
      \attributes\DC28\n\
      \\CANdropped_attributes_count\CAN\EOT \SOH(\rR\SYNdroppedAttributesCount\SUB\222\SOH\n\
      \\EOTLink\DC2\EM\n\
      \\btrace_id\CAN\SOH \SOH(\fR\atraceId\DC2\ETB\n\
      \\aspan_id\CAN\STX \SOH(\fR\ACKspanId\DC2\US\n\
      \\vtrace_state\CAN\ETX \SOH(\tR\n\
      \traceState\DC2G\n\
      \\n\
      \attributes\CAN\EOT \ETX(\v2'.opentelemetry.proto.common.v1.KeyValueR\n\
      \attributes\DC28\n\
      \\CANdropped_attributes_count\CAN\ENQ \SOH(\rR\SYNdroppedAttributesCount\"\153\SOH\n\
      \\bSpanKind\DC2\EM\n\
      \\NAKSPAN_KIND_UNSPECIFIED\DLE\NUL\DC2\SYN\n\
      \\DC2SPAN_KIND_INTERNAL\DLE\SOH\DC2\DC4\n\
      \\DLESPAN_KIND_SERVER\DLE\STX\DC2\DC4\n\
      \\DLESPAN_KIND_CLIENT\DLE\ETX\DC2\SYN\n\
      \\DC2SPAN_KIND_PRODUCER\DLE\EOT\DC2\SYN\n\
      \\DC2SPAN_KIND_CONSUMER\DLE\ENQ"
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
              Data.ProtoLens.FieldDescriptor Span
        spanId__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "span_id"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"spanId")) ::
              Data.ProtoLens.FieldDescriptor Span
        traceState__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "trace_state"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"traceState")) ::
              Data.ProtoLens.FieldDescriptor Span
        parentSpanId__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "parent_span_id"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"parentSpanId")) ::
              Data.ProtoLens.FieldDescriptor Span
        name__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "name"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"name")) ::
              Data.ProtoLens.FieldDescriptor Span
        kind__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "kind"
              (Data.ProtoLens.ScalarField Data.ProtoLens.EnumField ::
                 Data.ProtoLens.FieldTypeDescriptor Span'SpanKind)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"kind")) ::
              Data.ProtoLens.FieldDescriptor Span
        startTimeUnixNano__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "start_time_unix_nano"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Fixed64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"startTimeUnixNano")) ::
              Data.ProtoLens.FieldDescriptor Span
        endTimeUnixNano__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "end_time_unix_nano"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Fixed64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"endTimeUnixNano")) ::
              Data.ProtoLens.FieldDescriptor Span
        attributes__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "attributes"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"attributes")) ::
              Data.ProtoLens.FieldDescriptor Span
        droppedAttributesCount__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "dropped_attributes_count"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"droppedAttributesCount")) ::
              Data.ProtoLens.FieldDescriptor Span
        events__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "events"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Span'Event)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked (Data.ProtoLens.Field.field @"events")) ::
              Data.ProtoLens.FieldDescriptor Span
        droppedEventsCount__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "dropped_events_count"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"droppedEventsCount")) ::
              Data.ProtoLens.FieldDescriptor Span
        links__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "links"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Span'Link)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked (Data.ProtoLens.Field.field @"links")) ::
              Data.ProtoLens.FieldDescriptor Span
        droppedLinksCount__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "dropped_links_count"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"droppedLinksCount")) ::
              Data.ProtoLens.FieldDescriptor Span
        status__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "status"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Status)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'status")) ::
              Data.ProtoLens.FieldDescriptor Span
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, traceId__field_descriptor),
           (Data.ProtoLens.Tag 2, spanId__field_descriptor),
           (Data.ProtoLens.Tag 3, traceState__field_descriptor),
           (Data.ProtoLens.Tag 4, parentSpanId__field_descriptor),
           (Data.ProtoLens.Tag 5, name__field_descriptor),
           (Data.ProtoLens.Tag 6, kind__field_descriptor),
           (Data.ProtoLens.Tag 7, startTimeUnixNano__field_descriptor),
           (Data.ProtoLens.Tag 8, endTimeUnixNano__field_descriptor),
           (Data.ProtoLens.Tag 9, attributes__field_descriptor),
           (Data.ProtoLens.Tag 10, droppedAttributesCount__field_descriptor),
           (Data.ProtoLens.Tag 11, events__field_descriptor),
           (Data.ProtoLens.Tag 12, droppedEventsCount__field_descriptor),
           (Data.ProtoLens.Tag 13, links__field_descriptor),
           (Data.ProtoLens.Tag 14, droppedLinksCount__field_descriptor),
           (Data.ProtoLens.Tag 15, status__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Span'_unknownFields
        (\ x__ y__ -> x__ {_Span'_unknownFields = y__})
  defMessage
    = Span'_constructor
        {_Span'traceId = Data.ProtoLens.fieldDefault,
         _Span'spanId = Data.ProtoLens.fieldDefault,
         _Span'traceState = Data.ProtoLens.fieldDefault,
         _Span'parentSpanId = Data.ProtoLens.fieldDefault,
         _Span'name = Data.ProtoLens.fieldDefault,
         _Span'kind = Data.ProtoLens.fieldDefault,
         _Span'startTimeUnixNano = Data.ProtoLens.fieldDefault,
         _Span'endTimeUnixNano = Data.ProtoLens.fieldDefault,
         _Span'attributes = Data.Vector.Generic.empty,
         _Span'droppedAttributesCount = Data.ProtoLens.fieldDefault,
         _Span'events = Data.Vector.Generic.empty,
         _Span'droppedEventsCount = Data.ProtoLens.fieldDefault,
         _Span'links = Data.Vector.Generic.empty,
         _Span'droppedLinksCount = Data.ProtoLens.fieldDefault,
         _Span'status = Prelude.Nothing, _Span'_unknownFields = []}
  parseMessage
    = let
        loop ::
          Span
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue
             -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Span'Event
                -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Span'Link
                   -> Data.ProtoLens.Encoding.Bytes.Parser Span
        loop x mutable'attributes mutable'events mutable'links
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'attributes <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                             (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                mutable'attributes)
                      frozen'events <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                         (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                            mutable'events)
                      frozen'links <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                        (Data.ProtoLens.Encoding.Growing.unsafeFreeze mutable'links)
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
                                 (Data.ProtoLens.Field.field @"vec'events") frozen'events
                                 (Lens.Family2.set
                                    (Data.ProtoLens.Field.field @"vec'links") frozen'links x))))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "trace_id"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"traceId") y x)
                                  mutable'attributes mutable'events mutable'links
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "span_id"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"spanId") y x)
                                  mutable'attributes mutable'events mutable'links
                        26
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do value <- do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                                       Data.ProtoLens.Encoding.Bytes.getBytes
                                                         (Prelude.fromIntegral len)
                                           Data.ProtoLens.Encoding.Bytes.runEither
                                             (case Data.Text.Encoding.decodeUtf8' value of
                                                (Prelude.Left err)
                                                  -> Prelude.Left (Prelude.show err)
                                                (Prelude.Right r) -> Prelude.Right r))
                                       "trace_state"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"traceState") y x)
                                  mutable'attributes mutable'events mutable'links
                        34
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "parent_span_id"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"parentSpanId") y x)
                                  mutable'attributes mutable'events mutable'links
                        42
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do value <- do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                                       Data.ProtoLens.Encoding.Bytes.getBytes
                                                         (Prelude.fromIntegral len)
                                           Data.ProtoLens.Encoding.Bytes.runEither
                                             (case Data.Text.Encoding.decodeUtf8' value of
                                                (Prelude.Left err)
                                                  -> Prelude.Left (Prelude.show err)
                                                (Prelude.Right r) -> Prelude.Right r))
                                       "name"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"name") y x)
                                  mutable'attributes mutable'events mutable'links
                        48
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.toEnum
                                          (Prelude.fmap
                                             Prelude.fromIntegral
                                             Data.ProtoLens.Encoding.Bytes.getVarInt))
                                       "kind"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"kind") y x)
                                  mutable'attributes mutable'events mutable'links
                        57
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getFixed64
                                       "start_time_unix_nano"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"startTimeUnixNano") y x)
                                  mutable'attributes mutable'events mutable'links
                        65
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getFixed64 "end_time_unix_nano"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"endTimeUnixNano") y x)
                                  mutable'attributes mutable'events mutable'links
                        74
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "attributes"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'attributes y)
                                loop x v mutable'events mutable'links
                        80
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "dropped_attributes_count"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"droppedAttributesCount") y x)
                                  mutable'attributes mutable'events mutable'links
                        90
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "events"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'events y)
                                loop x mutable'attributes v mutable'links
                        96
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "dropped_events_count"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"droppedEventsCount") y x)
                                  mutable'attributes mutable'events mutable'links
                        106
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "links"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'links y)
                                loop x mutable'attributes mutable'events v
                        112
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "dropped_links_count"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"droppedLinksCount") y x)
                                  mutable'attributes mutable'events mutable'links
                        122
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "status"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"status") y x)
                                  mutable'attributes mutable'events mutable'links
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'attributes mutable'events mutable'links
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'attributes <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                      Data.ProtoLens.Encoding.Growing.new
              mutable'events <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                  Data.ProtoLens.Encoding.Growing.new
              mutable'links <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                 Data.ProtoLens.Encoding.Growing.new
              loop
                Data.ProtoLens.defMessage mutable'attributes mutable'events
                mutable'links)
          "Span"
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
                ((Data.Monoid.<>)
                   (let
                      _v
                        = Lens.Family2.view (Data.ProtoLens.Field.field @"traceState") _x
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
                   ((Data.Monoid.<>)
                      (let
                         _v
                           = Lens.Family2.view (Data.ProtoLens.Field.field @"parentSpanId") _x
                       in
                         if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                             Data.Monoid.mempty
                         else
                             (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt 34)
                               ((\ bs
                                   -> (Data.Monoid.<>)
                                        (Data.ProtoLens.Encoding.Bytes.putVarInt
                                           (Prelude.fromIntegral (Data.ByteString.length bs)))
                                        (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                  _v))
                      ((Data.Monoid.<>)
                         (let _v = Lens.Family2.view (Data.ProtoLens.Field.field @"name") _x
                          in
                            if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                Data.Monoid.mempty
                            else
                                (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt 42)
                                  ((Prelude..)
                                     (\ bs
                                        -> (Data.Monoid.<>)
                                             (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                (Prelude.fromIntegral (Data.ByteString.length bs)))
                                             (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                     Data.Text.Encoding.encodeUtf8 _v))
                         ((Data.Monoid.<>)
                            (let _v = Lens.Family2.view (Data.ProtoLens.Field.field @"kind") _x
                             in
                               if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                   Data.Monoid.mempty
                               else
                                   (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt 48)
                                     ((Prelude..)
                                        ((Prelude..)
                                           Data.ProtoLens.Encoding.Bytes.putVarInt
                                           Prelude.fromIntegral)
                                        Prelude.fromEnum _v))
                            ((Data.Monoid.<>)
                               (let
                                  _v
                                    = Lens.Family2.view
                                        (Data.ProtoLens.Field.field @"startTimeUnixNano") _x
                                in
                                  if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                      Data.Monoid.mempty
                                  else
                                      (Data.Monoid.<>)
                                        (Data.ProtoLens.Encoding.Bytes.putVarInt 57)
                                        (Data.ProtoLens.Encoding.Bytes.putFixed64 _v))
                               ((Data.Monoid.<>)
                                  (let
                                     _v
                                       = Lens.Family2.view
                                           (Data.ProtoLens.Field.field @"endTimeUnixNano") _x
                                   in
                                     if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                         Data.Monoid.mempty
                                     else
                                         (Data.Monoid.<>)
                                           (Data.ProtoLens.Encoding.Bytes.putVarInt 65)
                                           (Data.ProtoLens.Encoding.Bytes.putFixed64 _v))
                                  ((Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                                        (\ _v
                                           -> (Data.Monoid.<>)
                                                (Data.ProtoLens.Encoding.Bytes.putVarInt 74)
                                                ((Prelude..)
                                                   (\ bs
                                                      -> (Data.Monoid.<>)
                                                           (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                              (Prelude.fromIntegral
                                                                 (Data.ByteString.length bs)))
                                                           (Data.ProtoLens.Encoding.Bytes.putBytes
                                                              bs))
                                                   Data.ProtoLens.encodeMessage _v))
                                        (Lens.Family2.view
                                           (Data.ProtoLens.Field.field @"vec'attributes") _x))
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
                                                 (Data.ProtoLens.Encoding.Bytes.putVarInt 80)
                                                 ((Prelude..)
                                                    Data.ProtoLens.Encoding.Bytes.putVarInt
                                                    Prelude.fromIntegral _v))
                                        ((Data.Monoid.<>)
                                           (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                                              (\ _v
                                                 -> (Data.Monoid.<>)
                                                      (Data.ProtoLens.Encoding.Bytes.putVarInt 90)
                                                      ((Prelude..)
                                                         (\ bs
                                                            -> (Data.Monoid.<>)
                                                                 (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                                    (Prelude.fromIntegral
                                                                       (Data.ByteString.length bs)))
                                                                 (Data.ProtoLens.Encoding.Bytes.putBytes
                                                                    bs))
                                                         Data.ProtoLens.encodeMessage _v))
                                              (Lens.Family2.view
                                                 (Data.ProtoLens.Field.field @"vec'events") _x))
                                           ((Data.Monoid.<>)
                                              (let
                                                 _v
                                                   = Lens.Family2.view
                                                       (Data.ProtoLens.Field.field
                                                          @"droppedEventsCount")
                                                       _x
                                               in
                                                 if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                                     Data.Monoid.mempty
                                                 else
                                                     (Data.Monoid.<>)
                                                       (Data.ProtoLens.Encoding.Bytes.putVarInt 96)
                                                       ((Prelude..)
                                                          Data.ProtoLens.Encoding.Bytes.putVarInt
                                                          Prelude.fromIntegral _v))
                                              ((Data.Monoid.<>)
                                                 (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                                                    (\ _v
                                                       -> (Data.Monoid.<>)
                                                            (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                               106)
                                                            ((Prelude..)
                                                               (\ bs
                                                                  -> (Data.Monoid.<>)
                                                                       (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                                          (Prelude.fromIntegral
                                                                             (Data.ByteString.length
                                                                                bs)))
                                                                       (Data.ProtoLens.Encoding.Bytes.putBytes
                                                                          bs))
                                                               Data.ProtoLens.encodeMessage _v))
                                                    (Lens.Family2.view
                                                       (Data.ProtoLens.Field.field @"vec'links")
                                                       _x))
                                                 ((Data.Monoid.<>)
                                                    (let
                                                       _v
                                                         = Lens.Family2.view
                                                             (Data.ProtoLens.Field.field
                                                                @"droppedLinksCount")
                                                             _x
                                                     in
                                                       if (Prelude.==)
                                                            _v Data.ProtoLens.fieldDefault then
                                                           Data.Monoid.mempty
                                                       else
                                                           (Data.Monoid.<>)
                                                             (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                                112)
                                                             ((Prelude..)
                                                                Data.ProtoLens.Encoding.Bytes.putVarInt
                                                                Prelude.fromIntegral _v))
                                                    ((Data.Monoid.<>)
                                                       (case
                                                            Lens.Family2.view
                                                              (Data.ProtoLens.Field.field
                                                                 @"maybe'status")
                                                              _x
                                                        of
                                                          Prelude.Nothing -> Data.Monoid.mempty
                                                          (Prelude.Just _v)
                                                            -> (Data.Monoid.<>)
                                                                 (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                                    122)
                                                                 ((Prelude..)
                                                                    (\ bs
                                                                       -> (Data.Monoid.<>)
                                                                            (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                                               (Prelude.fromIntegral
                                                                                  (Data.ByteString.length
                                                                                     bs)))
                                                                            (Data.ProtoLens.Encoding.Bytes.putBytes
                                                                               bs))
                                                                    Data.ProtoLens.encodeMessage
                                                                    _v))
                                                       (Data.ProtoLens.Encoding.Wire.buildFieldSet
                                                          (Lens.Family2.view
                                                             Data.ProtoLens.unknownFields
                                                             _x))))))))))))))))
instance Control.DeepSeq.NFData Span where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Span'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_Span'traceId x__)
                (Control.DeepSeq.deepseq
                   (_Span'spanId x__)
                   (Control.DeepSeq.deepseq
                      (_Span'traceState x__)
                      (Control.DeepSeq.deepseq
                         (_Span'parentSpanId x__)
                         (Control.DeepSeq.deepseq
                            (_Span'name x__)
                            (Control.DeepSeq.deepseq
                               (_Span'kind x__)
                               (Control.DeepSeq.deepseq
                                  (_Span'startTimeUnixNano x__)
                                  (Control.DeepSeq.deepseq
                                     (_Span'endTimeUnixNano x__)
                                     (Control.DeepSeq.deepseq
                                        (_Span'attributes x__)
                                        (Control.DeepSeq.deepseq
                                           (_Span'droppedAttributesCount x__)
                                           (Control.DeepSeq.deepseq
                                              (_Span'events x__)
                                              (Control.DeepSeq.deepseq
                                                 (_Span'droppedEventsCount x__)
                                                 (Control.DeepSeq.deepseq
                                                    (_Span'links x__)
                                                    (Control.DeepSeq.deepseq
                                                       (_Span'droppedLinksCount x__)
                                                       (Control.DeepSeq.deepseq
                                                          (_Span'status x__) ())))))))))))))))
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.timeUnixNano' @:: Lens' Span'Event Data.Word.Word64@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.name' @:: Lens' Span'Event Data.Text.Text@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.attributes' @:: Lens' Span'Event [Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue]@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.vec'attributes' @:: Lens' Span'Event (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue)@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.droppedAttributesCount' @:: Lens' Span'Event Data.Word.Word32@ -}
data Span'Event
  = Span'Event'_constructor {_Span'Event'timeUnixNano :: !Data.Word.Word64,
                             _Span'Event'name :: !Data.Text.Text,
                             _Span'Event'attributes :: !(Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue),
                             _Span'Event'droppedAttributesCount :: !Data.Word.Word32,
                             _Span'Event'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show Span'Event where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField Span'Event "timeUnixNano" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Span'Event'timeUnixNano
           (\ x__ y__ -> x__ {_Span'Event'timeUnixNano = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Span'Event "name" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Span'Event'name (\ x__ y__ -> x__ {_Span'Event'name = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Span'Event "attributes" [Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Span'Event'attributes
           (\ x__ y__ -> x__ {_Span'Event'attributes = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField Span'Event "vec'attributes" (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Span'Event'attributes
           (\ x__ y__ -> x__ {_Span'Event'attributes = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Span'Event "droppedAttributesCount" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Span'Event'droppedAttributesCount
           (\ x__ y__ -> x__ {_Span'Event'droppedAttributesCount = y__}))
        Prelude.id
instance Data.ProtoLens.Message Span'Event where
  messageName _
    = Data.Text.pack "opentelemetry.proto.trace.v1.Span.Event"
  packedMessageDescriptor _
    = "\n\
      \\ENQEvent\DC2$\n\
      \\SOtime_unix_nano\CAN\SOH \SOH(\ACKR\ftimeUnixNano\DC2\DC2\n\
      \\EOTname\CAN\STX \SOH(\tR\EOTname\DC2G\n\
      \\n\
      \attributes\CAN\ETX \ETX(\v2'.opentelemetry.proto.common.v1.KeyValueR\n\
      \attributes\DC28\n\
      \\CANdropped_attributes_count\CAN\EOT \SOH(\rR\SYNdroppedAttributesCount"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        timeUnixNano__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "time_unix_nano"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Fixed64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"timeUnixNano")) ::
              Data.ProtoLens.FieldDescriptor Span'Event
        name__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "name"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"name")) ::
              Data.ProtoLens.FieldDescriptor Span'Event
        attributes__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "attributes"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"attributes")) ::
              Data.ProtoLens.FieldDescriptor Span'Event
        droppedAttributesCount__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "dropped_attributes_count"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"droppedAttributesCount")) ::
              Data.ProtoLens.FieldDescriptor Span'Event
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, timeUnixNano__field_descriptor),
           (Data.ProtoLens.Tag 2, name__field_descriptor),
           (Data.ProtoLens.Tag 3, attributes__field_descriptor),
           (Data.ProtoLens.Tag 4, droppedAttributesCount__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Span'Event'_unknownFields
        (\ x__ y__ -> x__ {_Span'Event'_unknownFields = y__})
  defMessage
    = Span'Event'_constructor
        {_Span'Event'timeUnixNano = Data.ProtoLens.fieldDefault,
         _Span'Event'name = Data.ProtoLens.fieldDefault,
         _Span'Event'attributes = Data.Vector.Generic.empty,
         _Span'Event'droppedAttributesCount = Data.ProtoLens.fieldDefault,
         _Span'Event'_unknownFields = []}
  parseMessage
    = let
        loop ::
          Span'Event
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue
             -> Data.ProtoLens.Encoding.Bytes.Parser Span'Event
        loop x mutable'attributes
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'attributes <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                             (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                mutable'attributes)
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
                              x))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        9 -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getFixed64 "time_unix_nano"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"timeUnixNano") y x)
                                  mutable'attributes
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do value <- do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                                       Data.ProtoLens.Encoding.Bytes.getBytes
                                                         (Prelude.fromIntegral len)
                                           Data.ProtoLens.Encoding.Bytes.runEither
                                             (case Data.Text.Encoding.decodeUtf8' value of
                                                (Prelude.Left err)
                                                  -> Prelude.Left (Prelude.show err)
                                                (Prelude.Right r) -> Prelude.Right r))
                                       "name"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"name") y x)
                                  mutable'attributes
                        26
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "attributes"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'attributes y)
                                loop x v
                        32
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "dropped_attributes_count"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"droppedAttributesCount") y x)
                                  mutable'attributes
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'attributes
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'attributes <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                      Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'attributes)
          "Event"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v
                  = Lens.Family2.view (Data.ProtoLens.Field.field @"timeUnixNano") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 9)
                      (Data.ProtoLens.Encoding.Bytes.putFixed64 _v))
             ((Data.Monoid.<>)
                (let _v = Lens.Family2.view (Data.ProtoLens.Field.field @"name") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                         ((Prelude..)
                            (\ bs
                               -> (Data.Monoid.<>)
                                    (Data.ProtoLens.Encoding.Bytes.putVarInt
                                       (Prelude.fromIntegral (Data.ByteString.length bs)))
                                    (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                            Data.Text.Encoding.encodeUtf8 _v))
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
                               (Data.ProtoLens.Encoding.Bytes.putVarInt 32)
                               ((Prelude..)
                                  Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                      (Data.ProtoLens.Encoding.Wire.buildFieldSet
                         (Lens.Family2.view Data.ProtoLens.unknownFields _x)))))
instance Control.DeepSeq.NFData Span'Event where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Span'Event'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_Span'Event'timeUnixNano x__)
                (Control.DeepSeq.deepseq
                   (_Span'Event'name x__)
                   (Control.DeepSeq.deepseq
                      (_Span'Event'attributes x__)
                      (Control.DeepSeq.deepseq
                         (_Span'Event'droppedAttributesCount x__) ()))))
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.traceId' @:: Lens' Span'Link Data.ByteString.ByteString@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.spanId' @:: Lens' Span'Link Data.ByteString.ByteString@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.traceState' @:: Lens' Span'Link Data.Text.Text@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.attributes' @:: Lens' Span'Link [Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue]@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.vec'attributes' @:: Lens' Span'Link (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue)@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.droppedAttributesCount' @:: Lens' Span'Link Data.Word.Word32@ -}
data Span'Link
  = Span'Link'_constructor {_Span'Link'traceId :: !Data.ByteString.ByteString,
                            _Span'Link'spanId :: !Data.ByteString.ByteString,
                            _Span'Link'traceState :: !Data.Text.Text,
                            _Span'Link'attributes :: !(Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue),
                            _Span'Link'droppedAttributesCount :: !Data.Word.Word32,
                            _Span'Link'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show Span'Link where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField Span'Link "traceId" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Span'Link'traceId (\ x__ y__ -> x__ {_Span'Link'traceId = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Span'Link "spanId" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Span'Link'spanId (\ x__ y__ -> x__ {_Span'Link'spanId = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Span'Link "traceState" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Span'Link'traceState
           (\ x__ y__ -> x__ {_Span'Link'traceState = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Span'Link "attributes" [Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Span'Link'attributes
           (\ x__ y__ -> x__ {_Span'Link'attributes = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField Span'Link "vec'attributes" (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Span'Link'attributes
           (\ x__ y__ -> x__ {_Span'Link'attributes = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Span'Link "droppedAttributesCount" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Span'Link'droppedAttributesCount
           (\ x__ y__ -> x__ {_Span'Link'droppedAttributesCount = y__}))
        Prelude.id
instance Data.ProtoLens.Message Span'Link where
  messageName _
    = Data.Text.pack "opentelemetry.proto.trace.v1.Span.Link"
  packedMessageDescriptor _
    = "\n\
      \\EOTLink\DC2\EM\n\
      \\btrace_id\CAN\SOH \SOH(\fR\atraceId\DC2\ETB\n\
      \\aspan_id\CAN\STX \SOH(\fR\ACKspanId\DC2\US\n\
      \\vtrace_state\CAN\ETX \SOH(\tR\n\
      \traceState\DC2G\n\
      \\n\
      \attributes\CAN\EOT \ETX(\v2'.opentelemetry.proto.common.v1.KeyValueR\n\
      \attributes\DC28\n\
      \\CANdropped_attributes_count\CAN\ENQ \SOH(\rR\SYNdroppedAttributesCount"
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
              Data.ProtoLens.FieldDescriptor Span'Link
        spanId__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "span_id"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"spanId")) ::
              Data.ProtoLens.FieldDescriptor Span'Link
        traceState__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "trace_state"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"traceState")) ::
              Data.ProtoLens.FieldDescriptor Span'Link
        attributes__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "attributes"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"attributes")) ::
              Data.ProtoLens.FieldDescriptor Span'Link
        droppedAttributesCount__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "dropped_attributes_count"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"droppedAttributesCount")) ::
              Data.ProtoLens.FieldDescriptor Span'Link
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, traceId__field_descriptor),
           (Data.ProtoLens.Tag 2, spanId__field_descriptor),
           (Data.ProtoLens.Tag 3, traceState__field_descriptor),
           (Data.ProtoLens.Tag 4, attributes__field_descriptor),
           (Data.ProtoLens.Tag 5, droppedAttributesCount__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Span'Link'_unknownFields
        (\ x__ y__ -> x__ {_Span'Link'_unknownFields = y__})
  defMessage
    = Span'Link'_constructor
        {_Span'Link'traceId = Data.ProtoLens.fieldDefault,
         _Span'Link'spanId = Data.ProtoLens.fieldDefault,
         _Span'Link'traceState = Data.ProtoLens.fieldDefault,
         _Span'Link'attributes = Data.Vector.Generic.empty,
         _Span'Link'droppedAttributesCount = Data.ProtoLens.fieldDefault,
         _Span'Link'_unknownFields = []}
  parseMessage
    = let
        loop ::
          Span'Link
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue
             -> Data.ProtoLens.Encoding.Bytes.Parser Span'Link
        loop x mutable'attributes
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'attributes <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                             (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                mutable'attributes)
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
                              x))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "trace_id"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"traceId") y x)
                                  mutable'attributes
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "span_id"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"spanId") y x)
                                  mutable'attributes
                        26
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do value <- do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                                       Data.ProtoLens.Encoding.Bytes.getBytes
                                                         (Prelude.fromIntegral len)
                                           Data.ProtoLens.Encoding.Bytes.runEither
                                             (case Data.Text.Encoding.decodeUtf8' value of
                                                (Prelude.Left err)
                                                  -> Prelude.Left (Prelude.show err)
                                                (Prelude.Right r) -> Prelude.Right r))
                                       "trace_state"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"traceState") y x)
                                  mutable'attributes
                        34
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "attributes"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'attributes y)
                                loop x v
                        40
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "dropped_attributes_count"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"droppedAttributesCount") y x)
                                  mutable'attributes
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'attributes
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'attributes <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                      Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'attributes)
          "Link"
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
                ((Data.Monoid.<>)
                   (let
                      _v
                        = Lens.Family2.view (Data.ProtoLens.Field.field @"traceState") _x
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
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt 40)
                                  ((Prelude..)
                                     Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral
                                     _v))
                         (Data.ProtoLens.Encoding.Wire.buildFieldSet
                            (Lens.Family2.view Data.ProtoLens.unknownFields _x))))))
instance Control.DeepSeq.NFData Span'Link where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Span'Link'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_Span'Link'traceId x__)
                (Control.DeepSeq.deepseq
                   (_Span'Link'spanId x__)
                   (Control.DeepSeq.deepseq
                      (_Span'Link'traceState x__)
                      (Control.DeepSeq.deepseq
                         (_Span'Link'attributes x__)
                         (Control.DeepSeq.deepseq
                            (_Span'Link'droppedAttributesCount x__) ())))))
newtype Span'SpanKind'UnrecognizedValue
  = Span'SpanKind'UnrecognizedValue Data.Int.Int32
  deriving stock (Prelude.Eq, Prelude.Ord, Prelude.Show)
data Span'SpanKind
  = Span'SPAN_KIND_UNSPECIFIED |
    Span'SPAN_KIND_INTERNAL |
    Span'SPAN_KIND_SERVER |
    Span'SPAN_KIND_CLIENT |
    Span'SPAN_KIND_PRODUCER |
    Span'SPAN_KIND_CONSUMER |
    Span'SpanKind'Unrecognized !Span'SpanKind'UnrecognizedValue
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
instance Data.ProtoLens.MessageEnum Span'SpanKind where
  maybeToEnum 0 = Prelude.Just Span'SPAN_KIND_UNSPECIFIED
  maybeToEnum 1 = Prelude.Just Span'SPAN_KIND_INTERNAL
  maybeToEnum 2 = Prelude.Just Span'SPAN_KIND_SERVER
  maybeToEnum 3 = Prelude.Just Span'SPAN_KIND_CLIENT
  maybeToEnum 4 = Prelude.Just Span'SPAN_KIND_PRODUCER
  maybeToEnum 5 = Prelude.Just Span'SPAN_KIND_CONSUMER
  maybeToEnum k
    = Prelude.Just
        (Span'SpanKind'Unrecognized
           (Span'SpanKind'UnrecognizedValue (Prelude.fromIntegral k)))
  showEnum Span'SPAN_KIND_UNSPECIFIED = "SPAN_KIND_UNSPECIFIED"
  showEnum Span'SPAN_KIND_INTERNAL = "SPAN_KIND_INTERNAL"
  showEnum Span'SPAN_KIND_SERVER = "SPAN_KIND_SERVER"
  showEnum Span'SPAN_KIND_CLIENT = "SPAN_KIND_CLIENT"
  showEnum Span'SPAN_KIND_PRODUCER = "SPAN_KIND_PRODUCER"
  showEnum Span'SPAN_KIND_CONSUMER = "SPAN_KIND_CONSUMER"
  showEnum
    (Span'SpanKind'Unrecognized (Span'SpanKind'UnrecognizedValue k))
    = Prelude.show k
  readEnum k
    | (Prelude.==) k "SPAN_KIND_UNSPECIFIED"
    = Prelude.Just Span'SPAN_KIND_UNSPECIFIED
    | (Prelude.==) k "SPAN_KIND_INTERNAL"
    = Prelude.Just Span'SPAN_KIND_INTERNAL
    | (Prelude.==) k "SPAN_KIND_SERVER"
    = Prelude.Just Span'SPAN_KIND_SERVER
    | (Prelude.==) k "SPAN_KIND_CLIENT"
    = Prelude.Just Span'SPAN_KIND_CLIENT
    | (Prelude.==) k "SPAN_KIND_PRODUCER"
    = Prelude.Just Span'SPAN_KIND_PRODUCER
    | (Prelude.==) k "SPAN_KIND_CONSUMER"
    = Prelude.Just Span'SPAN_KIND_CONSUMER
    | Prelude.otherwise
    = (Prelude.>>=) (Text.Read.readMaybe k) Data.ProtoLens.maybeToEnum
instance Prelude.Bounded Span'SpanKind where
  minBound = Span'SPAN_KIND_UNSPECIFIED
  maxBound = Span'SPAN_KIND_CONSUMER
instance Prelude.Enum Span'SpanKind where
  toEnum k__
    = Prelude.maybe
        (Prelude.error
           ((Prelude.++)
              "toEnum: unknown value for enum SpanKind: " (Prelude.show k__)))
        Prelude.id (Data.ProtoLens.maybeToEnum k__)
  fromEnum Span'SPAN_KIND_UNSPECIFIED = 0
  fromEnum Span'SPAN_KIND_INTERNAL = 1
  fromEnum Span'SPAN_KIND_SERVER = 2
  fromEnum Span'SPAN_KIND_CLIENT = 3
  fromEnum Span'SPAN_KIND_PRODUCER = 4
  fromEnum Span'SPAN_KIND_CONSUMER = 5
  fromEnum
    (Span'SpanKind'Unrecognized (Span'SpanKind'UnrecognizedValue k))
    = Prelude.fromIntegral k
  succ Span'SPAN_KIND_CONSUMER
    = Prelude.error
        "Span'SpanKind.succ: bad argument Span'SPAN_KIND_CONSUMER. This value would be out of bounds."
  succ Span'SPAN_KIND_UNSPECIFIED = Span'SPAN_KIND_INTERNAL
  succ Span'SPAN_KIND_INTERNAL = Span'SPAN_KIND_SERVER
  succ Span'SPAN_KIND_SERVER = Span'SPAN_KIND_CLIENT
  succ Span'SPAN_KIND_CLIENT = Span'SPAN_KIND_PRODUCER
  succ Span'SPAN_KIND_PRODUCER = Span'SPAN_KIND_CONSUMER
  succ (Span'SpanKind'Unrecognized _)
    = Prelude.error
        "Span'SpanKind.succ: bad argument: unrecognized value"
  pred Span'SPAN_KIND_UNSPECIFIED
    = Prelude.error
        "Span'SpanKind.pred: bad argument Span'SPAN_KIND_UNSPECIFIED. This value would be out of bounds."
  pred Span'SPAN_KIND_INTERNAL = Span'SPAN_KIND_UNSPECIFIED
  pred Span'SPAN_KIND_SERVER = Span'SPAN_KIND_INTERNAL
  pred Span'SPAN_KIND_CLIENT = Span'SPAN_KIND_SERVER
  pred Span'SPAN_KIND_PRODUCER = Span'SPAN_KIND_CLIENT
  pred Span'SPAN_KIND_CONSUMER = Span'SPAN_KIND_PRODUCER
  pred (Span'SpanKind'Unrecognized _)
    = Prelude.error
        "Span'SpanKind.pred: bad argument: unrecognized value"
  enumFrom = Data.ProtoLens.Message.Enum.messageEnumFrom
  enumFromTo = Data.ProtoLens.Message.Enum.messageEnumFromTo
  enumFromThen = Data.ProtoLens.Message.Enum.messageEnumFromThen
  enumFromThenTo = Data.ProtoLens.Message.Enum.messageEnumFromThenTo
instance Data.ProtoLens.FieldDefault Span'SpanKind where
  fieldDefault = Span'SPAN_KIND_UNSPECIFIED
instance Control.DeepSeq.NFData Span'SpanKind where
  rnf x__ = Prelude.seq x__ ()
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.deprecatedCode' @:: Lens' Status Status'DeprecatedStatusCode@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.message' @:: Lens' Status Data.Text.Text@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.code' @:: Lens' Status Status'StatusCode@ -}
data Status
  = Status'_constructor {_Status'deprecatedCode :: !Status'DeprecatedStatusCode,
                         _Status'message :: !Data.Text.Text,
                         _Status'code :: !Status'StatusCode,
                         _Status'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show Status where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField Status "deprecatedCode" Status'DeprecatedStatusCode where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Status'deprecatedCode
           (\ x__ y__ -> x__ {_Status'deprecatedCode = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Status "message" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Status'message (\ x__ y__ -> x__ {_Status'message = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Status "code" Status'StatusCode where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Status'code (\ x__ y__ -> x__ {_Status'code = y__}))
        Prelude.id
instance Data.ProtoLens.Message Status where
  messageName _
    = Data.Text.pack "opentelemetry.proto.trace.v1.Status"
  packedMessageDescriptor _
    = "\n\
      \\ACKStatus\DC2f\n\
      \\SIdeprecated_code\CAN\SOH \SOH(\SO29.opentelemetry.proto.trace.v1.Status.DeprecatedStatusCodeR\SOdeprecatedCodeB\STX\CAN\SOH\DC2\CAN\n\
      \\amessage\CAN\STX \SOH(\tR\amessage\DC2C\n\
      \\EOTcode\CAN\ETX \SOH(\SO2/.opentelemetry.proto.trace.v1.Status.StatusCodeR\EOTcode\"\218\ENQ\n\
      \\DC4DeprecatedStatusCode\DC2\GS\n\
      \\EMDEPRECATED_STATUS_CODE_OK\DLE\NUL\DC2$\n\
      \ DEPRECATED_STATUS_CODE_CANCELLED\DLE\SOH\DC2(\n\
      \$DEPRECATED_STATUS_CODE_UNKNOWN_ERROR\DLE\STX\DC2+\n\
      \'DEPRECATED_STATUS_CODE_INVALID_ARGUMENT\DLE\ETX\DC2,\n\
      \(DEPRECATED_STATUS_CODE_DEADLINE_EXCEEDED\DLE\EOT\DC2$\n\
      \ DEPRECATED_STATUS_CODE_NOT_FOUND\DLE\ENQ\DC2)\n\
      \%DEPRECATED_STATUS_CODE_ALREADY_EXISTS\DLE\ACK\DC2,\n\
      \(DEPRECATED_STATUS_CODE_PERMISSION_DENIED\DLE\a\DC2-\n\
      \)DEPRECATED_STATUS_CODE_RESOURCE_EXHAUSTED\DLE\b\DC2.\n\
      \*DEPRECATED_STATUS_CODE_FAILED_PRECONDITION\DLE\t\DC2\"\n\
      \\RSDEPRECATED_STATUS_CODE_ABORTED\DLE\n\
      \\DC2'\n\
      \#DEPRECATED_STATUS_CODE_OUT_OF_RANGE\DLE\v\DC2(\n\
      \$DEPRECATED_STATUS_CODE_UNIMPLEMENTED\DLE\f\DC2)\n\
      \%DEPRECATED_STATUS_CODE_INTERNAL_ERROR\DLE\r\DC2&\n\
      \\"DEPRECATED_STATUS_CODE_UNAVAILABLE\DLE\SO\DC2$\n\
      \ DEPRECATED_STATUS_CODE_DATA_LOSS\DLE\SI\DC2*\n\
      \&DEPRECATED_STATUS_CODE_UNAUTHENTICATED\DLE\DLE\"N\n\
      \\n\
      \StatusCode\DC2\NAK\n\
      \\DC1STATUS_CODE_UNSET\DLE\NUL\DC2\DC2\n\
      \\SOSTATUS_CODE_OK\DLE\SOH\DC2\NAK\n\
      \\DC1STATUS_CODE_ERROR\DLE\STX"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        deprecatedCode__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "deprecated_code"
              (Data.ProtoLens.ScalarField Data.ProtoLens.EnumField ::
                 Data.ProtoLens.FieldTypeDescriptor Status'DeprecatedStatusCode)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"deprecatedCode")) ::
              Data.ProtoLens.FieldDescriptor Status
        message__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "message"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"message")) ::
              Data.ProtoLens.FieldDescriptor Status
        code__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "code"
              (Data.ProtoLens.ScalarField Data.ProtoLens.EnumField ::
                 Data.ProtoLens.FieldTypeDescriptor Status'StatusCode)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"code")) ::
              Data.ProtoLens.FieldDescriptor Status
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, deprecatedCode__field_descriptor),
           (Data.ProtoLens.Tag 2, message__field_descriptor),
           (Data.ProtoLens.Tag 3, code__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Status'_unknownFields
        (\ x__ y__ -> x__ {_Status'_unknownFields = y__})
  defMessage
    = Status'_constructor
        {_Status'deprecatedCode = Data.ProtoLens.fieldDefault,
         _Status'message = Data.ProtoLens.fieldDefault,
         _Status'code = Data.ProtoLens.fieldDefault,
         _Status'_unknownFields = []}
  parseMessage
    = let
        loop :: Status -> Data.ProtoLens.Encoding.Bytes.Parser Status
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
                                          Prelude.toEnum
                                          (Prelude.fmap
                                             Prelude.fromIntegral
                                             Data.ProtoLens.Encoding.Bytes.getVarInt))
                                       "deprecated_code"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"deprecatedCode") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do value <- do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                                       Data.ProtoLens.Encoding.Bytes.getBytes
                                                         (Prelude.fromIntegral len)
                                           Data.ProtoLens.Encoding.Bytes.runEither
                                             (case Data.Text.Encoding.decodeUtf8' value of
                                                (Prelude.Left err)
                                                  -> Prelude.Left (Prelude.show err)
                                                (Prelude.Right r) -> Prelude.Right r))
                                       "message"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"message") y x)
                        24
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.toEnum
                                          (Prelude.fmap
                                             Prelude.fromIntegral
                                             Data.ProtoLens.Encoding.Bytes.getVarInt))
                                       "code"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"code") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "Status"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v
                  = Lens.Family2.view
                      (Data.ProtoLens.Field.field @"deprecatedCode") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 8)
                      ((Prelude..)
                         ((Prelude..)
                            Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral)
                         Prelude.fromEnum _v))
             ((Data.Monoid.<>)
                (let
                   _v = Lens.Family2.view (Data.ProtoLens.Field.field @"message") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                         ((Prelude..)
                            (\ bs
                               -> (Data.Monoid.<>)
                                    (Data.ProtoLens.Encoding.Bytes.putVarInt
                                       (Prelude.fromIntegral (Data.ByteString.length bs)))
                                    (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                            Data.Text.Encoding.encodeUtf8 _v))
                ((Data.Monoid.<>)
                   (let _v = Lens.Family2.view (Data.ProtoLens.Field.field @"code") _x
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
instance Control.DeepSeq.NFData Status where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Status'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_Status'deprecatedCode x__)
                (Control.DeepSeq.deepseq
                   (_Status'message x__)
                   (Control.DeepSeq.deepseq (_Status'code x__) ())))
newtype Status'DeprecatedStatusCode'UnrecognizedValue
  = Status'DeprecatedStatusCode'UnrecognizedValue Data.Int.Int32
  deriving stock (Prelude.Eq, Prelude.Ord, Prelude.Show)
data Status'DeprecatedStatusCode
  = Status'DEPRECATED_STATUS_CODE_OK |
    Status'DEPRECATED_STATUS_CODE_CANCELLED |
    Status'DEPRECATED_STATUS_CODE_UNKNOWN_ERROR |
    Status'DEPRECATED_STATUS_CODE_INVALID_ARGUMENT |
    Status'DEPRECATED_STATUS_CODE_DEADLINE_EXCEEDED |
    Status'DEPRECATED_STATUS_CODE_NOT_FOUND |
    Status'DEPRECATED_STATUS_CODE_ALREADY_EXISTS |
    Status'DEPRECATED_STATUS_CODE_PERMISSION_DENIED |
    Status'DEPRECATED_STATUS_CODE_RESOURCE_EXHAUSTED |
    Status'DEPRECATED_STATUS_CODE_FAILED_PRECONDITION |
    Status'DEPRECATED_STATUS_CODE_ABORTED |
    Status'DEPRECATED_STATUS_CODE_OUT_OF_RANGE |
    Status'DEPRECATED_STATUS_CODE_UNIMPLEMENTED |
    Status'DEPRECATED_STATUS_CODE_INTERNAL_ERROR |
    Status'DEPRECATED_STATUS_CODE_UNAVAILABLE |
    Status'DEPRECATED_STATUS_CODE_DATA_LOSS |
    Status'DEPRECATED_STATUS_CODE_UNAUTHENTICATED |
    Status'DeprecatedStatusCode'Unrecognized !Status'DeprecatedStatusCode'UnrecognizedValue
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
instance Data.ProtoLens.MessageEnum Status'DeprecatedStatusCode where
  maybeToEnum 0 = Prelude.Just Status'DEPRECATED_STATUS_CODE_OK
  maybeToEnum 1
    = Prelude.Just Status'DEPRECATED_STATUS_CODE_CANCELLED
  maybeToEnum 2
    = Prelude.Just Status'DEPRECATED_STATUS_CODE_UNKNOWN_ERROR
  maybeToEnum 3
    = Prelude.Just Status'DEPRECATED_STATUS_CODE_INVALID_ARGUMENT
  maybeToEnum 4
    = Prelude.Just Status'DEPRECATED_STATUS_CODE_DEADLINE_EXCEEDED
  maybeToEnum 5
    = Prelude.Just Status'DEPRECATED_STATUS_CODE_NOT_FOUND
  maybeToEnum 6
    = Prelude.Just Status'DEPRECATED_STATUS_CODE_ALREADY_EXISTS
  maybeToEnum 7
    = Prelude.Just Status'DEPRECATED_STATUS_CODE_PERMISSION_DENIED
  maybeToEnum 8
    = Prelude.Just Status'DEPRECATED_STATUS_CODE_RESOURCE_EXHAUSTED
  maybeToEnum 9
    = Prelude.Just Status'DEPRECATED_STATUS_CODE_FAILED_PRECONDITION
  maybeToEnum 10 = Prelude.Just Status'DEPRECATED_STATUS_CODE_ABORTED
  maybeToEnum 11
    = Prelude.Just Status'DEPRECATED_STATUS_CODE_OUT_OF_RANGE
  maybeToEnum 12
    = Prelude.Just Status'DEPRECATED_STATUS_CODE_UNIMPLEMENTED
  maybeToEnum 13
    = Prelude.Just Status'DEPRECATED_STATUS_CODE_INTERNAL_ERROR
  maybeToEnum 14
    = Prelude.Just Status'DEPRECATED_STATUS_CODE_UNAVAILABLE
  maybeToEnum 15
    = Prelude.Just Status'DEPRECATED_STATUS_CODE_DATA_LOSS
  maybeToEnum 16
    = Prelude.Just Status'DEPRECATED_STATUS_CODE_UNAUTHENTICATED
  maybeToEnum k
    = Prelude.Just
        (Status'DeprecatedStatusCode'Unrecognized
           (Status'DeprecatedStatusCode'UnrecognizedValue
              (Prelude.fromIntegral k)))
  showEnum Status'DEPRECATED_STATUS_CODE_OK
    = "DEPRECATED_STATUS_CODE_OK"
  showEnum Status'DEPRECATED_STATUS_CODE_CANCELLED
    = "DEPRECATED_STATUS_CODE_CANCELLED"
  showEnum Status'DEPRECATED_STATUS_CODE_UNKNOWN_ERROR
    = "DEPRECATED_STATUS_CODE_UNKNOWN_ERROR"
  showEnum Status'DEPRECATED_STATUS_CODE_INVALID_ARGUMENT
    = "DEPRECATED_STATUS_CODE_INVALID_ARGUMENT"
  showEnum Status'DEPRECATED_STATUS_CODE_DEADLINE_EXCEEDED
    = "DEPRECATED_STATUS_CODE_DEADLINE_EXCEEDED"
  showEnum Status'DEPRECATED_STATUS_CODE_NOT_FOUND
    = "DEPRECATED_STATUS_CODE_NOT_FOUND"
  showEnum Status'DEPRECATED_STATUS_CODE_ALREADY_EXISTS
    = "DEPRECATED_STATUS_CODE_ALREADY_EXISTS"
  showEnum Status'DEPRECATED_STATUS_CODE_PERMISSION_DENIED
    = "DEPRECATED_STATUS_CODE_PERMISSION_DENIED"
  showEnum Status'DEPRECATED_STATUS_CODE_RESOURCE_EXHAUSTED
    = "DEPRECATED_STATUS_CODE_RESOURCE_EXHAUSTED"
  showEnum Status'DEPRECATED_STATUS_CODE_FAILED_PRECONDITION
    = "DEPRECATED_STATUS_CODE_FAILED_PRECONDITION"
  showEnum Status'DEPRECATED_STATUS_CODE_ABORTED
    = "DEPRECATED_STATUS_CODE_ABORTED"
  showEnum Status'DEPRECATED_STATUS_CODE_OUT_OF_RANGE
    = "DEPRECATED_STATUS_CODE_OUT_OF_RANGE"
  showEnum Status'DEPRECATED_STATUS_CODE_UNIMPLEMENTED
    = "DEPRECATED_STATUS_CODE_UNIMPLEMENTED"
  showEnum Status'DEPRECATED_STATUS_CODE_INTERNAL_ERROR
    = "DEPRECATED_STATUS_CODE_INTERNAL_ERROR"
  showEnum Status'DEPRECATED_STATUS_CODE_UNAVAILABLE
    = "DEPRECATED_STATUS_CODE_UNAVAILABLE"
  showEnum Status'DEPRECATED_STATUS_CODE_DATA_LOSS
    = "DEPRECATED_STATUS_CODE_DATA_LOSS"
  showEnum Status'DEPRECATED_STATUS_CODE_UNAUTHENTICATED
    = "DEPRECATED_STATUS_CODE_UNAUTHENTICATED"
  showEnum
    (Status'DeprecatedStatusCode'Unrecognized (Status'DeprecatedStatusCode'UnrecognizedValue k))
    = Prelude.show k
  readEnum k
    | (Prelude.==) k "DEPRECATED_STATUS_CODE_OK"
    = Prelude.Just Status'DEPRECATED_STATUS_CODE_OK
    | (Prelude.==) k "DEPRECATED_STATUS_CODE_CANCELLED"
    = Prelude.Just Status'DEPRECATED_STATUS_CODE_CANCELLED
    | (Prelude.==) k "DEPRECATED_STATUS_CODE_UNKNOWN_ERROR"
    = Prelude.Just Status'DEPRECATED_STATUS_CODE_UNKNOWN_ERROR
    | (Prelude.==) k "DEPRECATED_STATUS_CODE_INVALID_ARGUMENT"
    = Prelude.Just Status'DEPRECATED_STATUS_CODE_INVALID_ARGUMENT
    | (Prelude.==) k "DEPRECATED_STATUS_CODE_DEADLINE_EXCEEDED"
    = Prelude.Just Status'DEPRECATED_STATUS_CODE_DEADLINE_EXCEEDED
    | (Prelude.==) k "DEPRECATED_STATUS_CODE_NOT_FOUND"
    = Prelude.Just Status'DEPRECATED_STATUS_CODE_NOT_FOUND
    | (Prelude.==) k "DEPRECATED_STATUS_CODE_ALREADY_EXISTS"
    = Prelude.Just Status'DEPRECATED_STATUS_CODE_ALREADY_EXISTS
    | (Prelude.==) k "DEPRECATED_STATUS_CODE_PERMISSION_DENIED"
    = Prelude.Just Status'DEPRECATED_STATUS_CODE_PERMISSION_DENIED
    | (Prelude.==) k "DEPRECATED_STATUS_CODE_RESOURCE_EXHAUSTED"
    = Prelude.Just Status'DEPRECATED_STATUS_CODE_RESOURCE_EXHAUSTED
    | (Prelude.==) k "DEPRECATED_STATUS_CODE_FAILED_PRECONDITION"
    = Prelude.Just Status'DEPRECATED_STATUS_CODE_FAILED_PRECONDITION
    | (Prelude.==) k "DEPRECATED_STATUS_CODE_ABORTED"
    = Prelude.Just Status'DEPRECATED_STATUS_CODE_ABORTED
    | (Prelude.==) k "DEPRECATED_STATUS_CODE_OUT_OF_RANGE"
    = Prelude.Just Status'DEPRECATED_STATUS_CODE_OUT_OF_RANGE
    | (Prelude.==) k "DEPRECATED_STATUS_CODE_UNIMPLEMENTED"
    = Prelude.Just Status'DEPRECATED_STATUS_CODE_UNIMPLEMENTED
    | (Prelude.==) k "DEPRECATED_STATUS_CODE_INTERNAL_ERROR"
    = Prelude.Just Status'DEPRECATED_STATUS_CODE_INTERNAL_ERROR
    | (Prelude.==) k "DEPRECATED_STATUS_CODE_UNAVAILABLE"
    = Prelude.Just Status'DEPRECATED_STATUS_CODE_UNAVAILABLE
    | (Prelude.==) k "DEPRECATED_STATUS_CODE_DATA_LOSS"
    = Prelude.Just Status'DEPRECATED_STATUS_CODE_DATA_LOSS
    | (Prelude.==) k "DEPRECATED_STATUS_CODE_UNAUTHENTICATED"
    = Prelude.Just Status'DEPRECATED_STATUS_CODE_UNAUTHENTICATED
    | Prelude.otherwise
    = (Prelude.>>=) (Text.Read.readMaybe k) Data.ProtoLens.maybeToEnum
instance Prelude.Bounded Status'DeprecatedStatusCode where
  minBound = Status'DEPRECATED_STATUS_CODE_OK
  maxBound = Status'DEPRECATED_STATUS_CODE_UNAUTHENTICATED
instance Prelude.Enum Status'DeprecatedStatusCode where
  toEnum k__
    = Prelude.maybe
        (Prelude.error
           ((Prelude.++)
              "toEnum: unknown value for enum DeprecatedStatusCode: "
              (Prelude.show k__)))
        Prelude.id (Data.ProtoLens.maybeToEnum k__)
  fromEnum Status'DEPRECATED_STATUS_CODE_OK = 0
  fromEnum Status'DEPRECATED_STATUS_CODE_CANCELLED = 1
  fromEnum Status'DEPRECATED_STATUS_CODE_UNKNOWN_ERROR = 2
  fromEnum Status'DEPRECATED_STATUS_CODE_INVALID_ARGUMENT = 3
  fromEnum Status'DEPRECATED_STATUS_CODE_DEADLINE_EXCEEDED = 4
  fromEnum Status'DEPRECATED_STATUS_CODE_NOT_FOUND = 5
  fromEnum Status'DEPRECATED_STATUS_CODE_ALREADY_EXISTS = 6
  fromEnum Status'DEPRECATED_STATUS_CODE_PERMISSION_DENIED = 7
  fromEnum Status'DEPRECATED_STATUS_CODE_RESOURCE_EXHAUSTED = 8
  fromEnum Status'DEPRECATED_STATUS_CODE_FAILED_PRECONDITION = 9
  fromEnum Status'DEPRECATED_STATUS_CODE_ABORTED = 10
  fromEnum Status'DEPRECATED_STATUS_CODE_OUT_OF_RANGE = 11
  fromEnum Status'DEPRECATED_STATUS_CODE_UNIMPLEMENTED = 12
  fromEnum Status'DEPRECATED_STATUS_CODE_INTERNAL_ERROR = 13
  fromEnum Status'DEPRECATED_STATUS_CODE_UNAVAILABLE = 14
  fromEnum Status'DEPRECATED_STATUS_CODE_DATA_LOSS = 15
  fromEnum Status'DEPRECATED_STATUS_CODE_UNAUTHENTICATED = 16
  fromEnum
    (Status'DeprecatedStatusCode'Unrecognized (Status'DeprecatedStatusCode'UnrecognizedValue k))
    = Prelude.fromIntegral k
  succ Status'DEPRECATED_STATUS_CODE_UNAUTHENTICATED
    = Prelude.error
        "Status'DeprecatedStatusCode.succ: bad argument Status'DEPRECATED_STATUS_CODE_UNAUTHENTICATED. This value would be out of bounds."
  succ Status'DEPRECATED_STATUS_CODE_OK
    = Status'DEPRECATED_STATUS_CODE_CANCELLED
  succ Status'DEPRECATED_STATUS_CODE_CANCELLED
    = Status'DEPRECATED_STATUS_CODE_UNKNOWN_ERROR
  succ Status'DEPRECATED_STATUS_CODE_UNKNOWN_ERROR
    = Status'DEPRECATED_STATUS_CODE_INVALID_ARGUMENT
  succ Status'DEPRECATED_STATUS_CODE_INVALID_ARGUMENT
    = Status'DEPRECATED_STATUS_CODE_DEADLINE_EXCEEDED
  succ Status'DEPRECATED_STATUS_CODE_DEADLINE_EXCEEDED
    = Status'DEPRECATED_STATUS_CODE_NOT_FOUND
  succ Status'DEPRECATED_STATUS_CODE_NOT_FOUND
    = Status'DEPRECATED_STATUS_CODE_ALREADY_EXISTS
  succ Status'DEPRECATED_STATUS_CODE_ALREADY_EXISTS
    = Status'DEPRECATED_STATUS_CODE_PERMISSION_DENIED
  succ Status'DEPRECATED_STATUS_CODE_PERMISSION_DENIED
    = Status'DEPRECATED_STATUS_CODE_RESOURCE_EXHAUSTED
  succ Status'DEPRECATED_STATUS_CODE_RESOURCE_EXHAUSTED
    = Status'DEPRECATED_STATUS_CODE_FAILED_PRECONDITION
  succ Status'DEPRECATED_STATUS_CODE_FAILED_PRECONDITION
    = Status'DEPRECATED_STATUS_CODE_ABORTED
  succ Status'DEPRECATED_STATUS_CODE_ABORTED
    = Status'DEPRECATED_STATUS_CODE_OUT_OF_RANGE
  succ Status'DEPRECATED_STATUS_CODE_OUT_OF_RANGE
    = Status'DEPRECATED_STATUS_CODE_UNIMPLEMENTED
  succ Status'DEPRECATED_STATUS_CODE_UNIMPLEMENTED
    = Status'DEPRECATED_STATUS_CODE_INTERNAL_ERROR
  succ Status'DEPRECATED_STATUS_CODE_INTERNAL_ERROR
    = Status'DEPRECATED_STATUS_CODE_UNAVAILABLE
  succ Status'DEPRECATED_STATUS_CODE_UNAVAILABLE
    = Status'DEPRECATED_STATUS_CODE_DATA_LOSS
  succ Status'DEPRECATED_STATUS_CODE_DATA_LOSS
    = Status'DEPRECATED_STATUS_CODE_UNAUTHENTICATED
  succ (Status'DeprecatedStatusCode'Unrecognized _)
    = Prelude.error
        "Status'DeprecatedStatusCode.succ: bad argument: unrecognized value"
  pred Status'DEPRECATED_STATUS_CODE_OK
    = Prelude.error
        "Status'DeprecatedStatusCode.pred: bad argument Status'DEPRECATED_STATUS_CODE_OK. This value would be out of bounds."
  pred Status'DEPRECATED_STATUS_CODE_CANCELLED
    = Status'DEPRECATED_STATUS_CODE_OK
  pred Status'DEPRECATED_STATUS_CODE_UNKNOWN_ERROR
    = Status'DEPRECATED_STATUS_CODE_CANCELLED
  pred Status'DEPRECATED_STATUS_CODE_INVALID_ARGUMENT
    = Status'DEPRECATED_STATUS_CODE_UNKNOWN_ERROR
  pred Status'DEPRECATED_STATUS_CODE_DEADLINE_EXCEEDED
    = Status'DEPRECATED_STATUS_CODE_INVALID_ARGUMENT
  pred Status'DEPRECATED_STATUS_CODE_NOT_FOUND
    = Status'DEPRECATED_STATUS_CODE_DEADLINE_EXCEEDED
  pred Status'DEPRECATED_STATUS_CODE_ALREADY_EXISTS
    = Status'DEPRECATED_STATUS_CODE_NOT_FOUND
  pred Status'DEPRECATED_STATUS_CODE_PERMISSION_DENIED
    = Status'DEPRECATED_STATUS_CODE_ALREADY_EXISTS
  pred Status'DEPRECATED_STATUS_CODE_RESOURCE_EXHAUSTED
    = Status'DEPRECATED_STATUS_CODE_PERMISSION_DENIED
  pred Status'DEPRECATED_STATUS_CODE_FAILED_PRECONDITION
    = Status'DEPRECATED_STATUS_CODE_RESOURCE_EXHAUSTED
  pred Status'DEPRECATED_STATUS_CODE_ABORTED
    = Status'DEPRECATED_STATUS_CODE_FAILED_PRECONDITION
  pred Status'DEPRECATED_STATUS_CODE_OUT_OF_RANGE
    = Status'DEPRECATED_STATUS_CODE_ABORTED
  pred Status'DEPRECATED_STATUS_CODE_UNIMPLEMENTED
    = Status'DEPRECATED_STATUS_CODE_OUT_OF_RANGE
  pred Status'DEPRECATED_STATUS_CODE_INTERNAL_ERROR
    = Status'DEPRECATED_STATUS_CODE_UNIMPLEMENTED
  pred Status'DEPRECATED_STATUS_CODE_UNAVAILABLE
    = Status'DEPRECATED_STATUS_CODE_INTERNAL_ERROR
  pred Status'DEPRECATED_STATUS_CODE_DATA_LOSS
    = Status'DEPRECATED_STATUS_CODE_UNAVAILABLE
  pred Status'DEPRECATED_STATUS_CODE_UNAUTHENTICATED
    = Status'DEPRECATED_STATUS_CODE_DATA_LOSS
  pred (Status'DeprecatedStatusCode'Unrecognized _)
    = Prelude.error
        "Status'DeprecatedStatusCode.pred: bad argument: unrecognized value"
  enumFrom = Data.ProtoLens.Message.Enum.messageEnumFrom
  enumFromTo = Data.ProtoLens.Message.Enum.messageEnumFromTo
  enumFromThen = Data.ProtoLens.Message.Enum.messageEnumFromThen
  enumFromThenTo = Data.ProtoLens.Message.Enum.messageEnumFromThenTo
instance Data.ProtoLens.FieldDefault Status'DeprecatedStatusCode where
  fieldDefault = Status'DEPRECATED_STATUS_CODE_OK
instance Control.DeepSeq.NFData Status'DeprecatedStatusCode where
  rnf x__ = Prelude.seq x__ ()
newtype Status'StatusCode'UnrecognizedValue
  = Status'StatusCode'UnrecognizedValue Data.Int.Int32
  deriving stock (Prelude.Eq, Prelude.Ord, Prelude.Show)
data Status'StatusCode
  = Status'STATUS_CODE_UNSET |
    Status'STATUS_CODE_OK |
    Status'STATUS_CODE_ERROR |
    Status'StatusCode'Unrecognized !Status'StatusCode'UnrecognizedValue
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
instance Data.ProtoLens.MessageEnum Status'StatusCode where
  maybeToEnum 0 = Prelude.Just Status'STATUS_CODE_UNSET
  maybeToEnum 1 = Prelude.Just Status'STATUS_CODE_OK
  maybeToEnum 2 = Prelude.Just Status'STATUS_CODE_ERROR
  maybeToEnum k
    = Prelude.Just
        (Status'StatusCode'Unrecognized
           (Status'StatusCode'UnrecognizedValue (Prelude.fromIntegral k)))
  showEnum Status'STATUS_CODE_UNSET = "STATUS_CODE_UNSET"
  showEnum Status'STATUS_CODE_OK = "STATUS_CODE_OK"
  showEnum Status'STATUS_CODE_ERROR = "STATUS_CODE_ERROR"
  showEnum
    (Status'StatusCode'Unrecognized (Status'StatusCode'UnrecognizedValue k))
    = Prelude.show k
  readEnum k
    | (Prelude.==) k "STATUS_CODE_UNSET"
    = Prelude.Just Status'STATUS_CODE_UNSET
    | (Prelude.==) k "STATUS_CODE_OK"
    = Prelude.Just Status'STATUS_CODE_OK
    | (Prelude.==) k "STATUS_CODE_ERROR"
    = Prelude.Just Status'STATUS_CODE_ERROR
    | Prelude.otherwise
    = (Prelude.>>=) (Text.Read.readMaybe k) Data.ProtoLens.maybeToEnum
instance Prelude.Bounded Status'StatusCode where
  minBound = Status'STATUS_CODE_UNSET
  maxBound = Status'STATUS_CODE_ERROR
instance Prelude.Enum Status'StatusCode where
  toEnum k__
    = Prelude.maybe
        (Prelude.error
           ((Prelude.++)
              "toEnum: unknown value for enum StatusCode: " (Prelude.show k__)))
        Prelude.id (Data.ProtoLens.maybeToEnum k__)
  fromEnum Status'STATUS_CODE_UNSET = 0
  fromEnum Status'STATUS_CODE_OK = 1
  fromEnum Status'STATUS_CODE_ERROR = 2
  fromEnum
    (Status'StatusCode'Unrecognized (Status'StatusCode'UnrecognizedValue k))
    = Prelude.fromIntegral k
  succ Status'STATUS_CODE_ERROR
    = Prelude.error
        "Status'StatusCode.succ: bad argument Status'STATUS_CODE_ERROR. This value would be out of bounds."
  succ Status'STATUS_CODE_UNSET = Status'STATUS_CODE_OK
  succ Status'STATUS_CODE_OK = Status'STATUS_CODE_ERROR
  succ (Status'StatusCode'Unrecognized _)
    = Prelude.error
        "Status'StatusCode.succ: bad argument: unrecognized value"
  pred Status'STATUS_CODE_UNSET
    = Prelude.error
        "Status'StatusCode.pred: bad argument Status'STATUS_CODE_UNSET. This value would be out of bounds."
  pred Status'STATUS_CODE_OK = Status'STATUS_CODE_UNSET
  pred Status'STATUS_CODE_ERROR = Status'STATUS_CODE_OK
  pred (Status'StatusCode'Unrecognized _)
    = Prelude.error
        "Status'StatusCode.pred: bad argument: unrecognized value"
  enumFrom = Data.ProtoLens.Message.Enum.messageEnumFrom
  enumFromTo = Data.ProtoLens.Message.Enum.messageEnumFromTo
  enumFromThen = Data.ProtoLens.Message.Enum.messageEnumFromThen
  enumFromThenTo = Data.ProtoLens.Message.Enum.messageEnumFromThenTo
instance Data.ProtoLens.FieldDefault Status'StatusCode where
  fieldDefault = Status'STATUS_CODE_UNSET
instance Control.DeepSeq.NFData Status'StatusCode where
  rnf x__ = Prelude.seq x__ ()
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.resourceSpans' @:: Lens' TracesData [ResourceSpans]@
         * 'Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields.vec'resourceSpans' @:: Lens' TracesData (Data.Vector.Vector ResourceSpans)@ -}
data TracesData
  = TracesData'_constructor {_TracesData'resourceSpans :: !(Data.Vector.Vector ResourceSpans),
                             _TracesData'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show TracesData where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField TracesData "resourceSpans" [ResourceSpans] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TracesData'resourceSpans
           (\ x__ y__ -> x__ {_TracesData'resourceSpans = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField TracesData "vec'resourceSpans" (Data.Vector.Vector ResourceSpans) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TracesData'resourceSpans
           (\ x__ y__ -> x__ {_TracesData'resourceSpans = y__}))
        Prelude.id
instance Data.ProtoLens.Message TracesData where
  messageName _
    = Data.Text.pack "opentelemetry.proto.trace.v1.TracesData"
  packedMessageDescriptor _
    = "\n\
      \\n\
      \TracesData\DC2R\n\
      \\SOresource_spans\CAN\SOH \ETX(\v2+.opentelemetry.proto.trace.v1.ResourceSpansR\rresourceSpans"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        resourceSpans__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "resource_spans"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor ResourceSpans)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"resourceSpans")) ::
              Data.ProtoLens.FieldDescriptor TracesData
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, resourceSpans__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _TracesData'_unknownFields
        (\ x__ y__ -> x__ {_TracesData'_unknownFields = y__})
  defMessage
    = TracesData'_constructor
        {_TracesData'resourceSpans = Data.Vector.Generic.empty,
         _TracesData'_unknownFields = []}
  parseMessage
    = let
        loop ::
          TracesData
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld ResourceSpans
             -> Data.ProtoLens.Encoding.Bytes.Parser TracesData
        loop x mutable'resourceSpans
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'resourceSpans <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                   mutable'resourceSpans)
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
                              (Data.ProtoLens.Field.field @"vec'resourceSpans")
                              frozen'resourceSpans x))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "resource_spans"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append
                                          mutable'resourceSpans y)
                                loop x v
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'resourceSpans
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'resourceSpans <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                         Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'resourceSpans)
          "TracesData"
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
                   (Data.ProtoLens.Field.field @"vec'resourceSpans") _x))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData TracesData where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_TracesData'_unknownFields x__)
             (Control.DeepSeq.deepseq (_TracesData'resourceSpans x__) ())
packedFileDescriptor :: Data.ByteString.ByteString
packedFileDescriptor
  = "\n\
    \(opentelemetry/proto/trace/v1/trace.proto\DC2\FSopentelemetry.proto.trace.v1\SUB*opentelemetry/proto/common/v1/common.proto\SUB.opentelemetry/proto/resource/v1/resource.proto\"`\n\
    \\n\
    \TracesData\DC2R\n\
    \\SOresource_spans\CAN\SOH \ETX(\v2+.opentelemetry.proto.trace.v1.ResourceSpansR\rresourceSpans\"\244\SOH\n\
    \\rResourceSpans\DC2E\n\
    \\bresource\CAN\SOH \SOH(\v2).opentelemetry.proto.resource.v1.ResourceR\bresource\DC2}\n\
    \\GSinstrumentation_library_spans\CAN\STX \ETX(\v29.opentelemetry.proto.trace.v1.InstrumentationLibrarySpansR\ESCinstrumentationLibrarySpans\DC2\GS\n\
    \\n\
    \schema_url\CAN\ETX \SOH(\tR\tschemaUrl\"\230\SOH\n\
    \\ESCInstrumentationLibrarySpans\DC2n\n\
    \\ETBinstrumentation_library\CAN\SOH \SOH(\v25.opentelemetry.proto.common.v1.InstrumentationLibraryR\SYNinstrumentationLibrary\DC28\n\
    \\ENQspans\CAN\STX \ETX(\v2\".opentelemetry.proto.trace.v1.SpanR\ENQspans\DC2\GS\n\
    \\n\
    \schema_url\CAN\ETX \SOH(\tR\tschemaUrl\"\156\n\
    \\n\
    \\EOTSpan\DC2\EM\n\
    \\btrace_id\CAN\SOH \SOH(\fR\atraceId\DC2\ETB\n\
    \\aspan_id\CAN\STX \SOH(\fR\ACKspanId\DC2\US\n\
    \\vtrace_state\CAN\ETX \SOH(\tR\n\
    \traceState\DC2$\n\
    \\SOparent_span_id\CAN\EOT \SOH(\fR\fparentSpanId\DC2\DC2\n\
    \\EOTname\CAN\ENQ \SOH(\tR\EOTname\DC2?\n\
    \\EOTkind\CAN\ACK \SOH(\SO2+.opentelemetry.proto.trace.v1.Span.SpanKindR\EOTkind\DC2/\n\
    \\DC4start_time_unix_nano\CAN\a \SOH(\ACKR\DC1startTimeUnixNano\DC2+\n\
    \\DC2end_time_unix_nano\CAN\b \SOH(\ACKR\SIendTimeUnixNano\DC2G\n\
    \\n\
    \attributes\CAN\t \ETX(\v2'.opentelemetry.proto.common.v1.KeyValueR\n\
    \attributes\DC28\n\
    \\CANdropped_attributes_count\CAN\n\
    \ \SOH(\rR\SYNdroppedAttributesCount\DC2@\n\
    \\ACKevents\CAN\v \ETX(\v2(.opentelemetry.proto.trace.v1.Span.EventR\ACKevents\DC20\n\
    \\DC4dropped_events_count\CAN\f \SOH(\rR\DC2droppedEventsCount\DC2=\n\
    \\ENQlinks\CAN\r \ETX(\v2'.opentelemetry.proto.trace.v1.Span.LinkR\ENQlinks\DC2.\n\
    \\DC3dropped_links_count\CAN\SO \SOH(\rR\DC1droppedLinksCount\DC2<\n\
    \\ACKstatus\CAN\SI \SOH(\v2$.opentelemetry.proto.trace.v1.StatusR\ACKstatus\SUB\196\SOH\n\
    \\ENQEvent\DC2$\n\
    \\SOtime_unix_nano\CAN\SOH \SOH(\ACKR\ftimeUnixNano\DC2\DC2\n\
    \\EOTname\CAN\STX \SOH(\tR\EOTname\DC2G\n\
    \\n\
    \attributes\CAN\ETX \ETX(\v2'.opentelemetry.proto.common.v1.KeyValueR\n\
    \attributes\DC28\n\
    \\CANdropped_attributes_count\CAN\EOT \SOH(\rR\SYNdroppedAttributesCount\SUB\222\SOH\n\
    \\EOTLink\DC2\EM\n\
    \\btrace_id\CAN\SOH \SOH(\fR\atraceId\DC2\ETB\n\
    \\aspan_id\CAN\STX \SOH(\fR\ACKspanId\DC2\US\n\
    \\vtrace_state\CAN\ETX \SOH(\tR\n\
    \traceState\DC2G\n\
    \\n\
    \attributes\CAN\EOT \ETX(\v2'.opentelemetry.proto.common.v1.KeyValueR\n\
    \attributes\DC28\n\
    \\CANdropped_attributes_count\CAN\ENQ \SOH(\rR\SYNdroppedAttributesCount\"\153\SOH\n\
    \\bSpanKind\DC2\EM\n\
    \\NAKSPAN_KIND_UNSPECIFIED\DLE\NUL\DC2\SYN\n\
    \\DC2SPAN_KIND_INTERNAL\DLE\SOH\DC2\DC4\n\
    \\DLESPAN_KIND_SERVER\DLE\STX\DC2\DC4\n\
    \\DLESPAN_KIND_CLIENT\DLE\ETX\DC2\SYN\n\
    \\DC2SPAN_KIND_PRODUCER\DLE\EOT\DC2\SYN\n\
    \\DC2SPAN_KIND_CONSUMER\DLE\ENQ\"\252\a\n\
    \\ACKStatus\DC2f\n\
    \\SIdeprecated_code\CAN\SOH \SOH(\SO29.opentelemetry.proto.trace.v1.Status.DeprecatedStatusCodeR\SOdeprecatedCodeB\STX\CAN\SOH\DC2\CAN\n\
    \\amessage\CAN\STX \SOH(\tR\amessage\DC2C\n\
    \\EOTcode\CAN\ETX \SOH(\SO2/.opentelemetry.proto.trace.v1.Status.StatusCodeR\EOTcode\"\218\ENQ\n\
    \\DC4DeprecatedStatusCode\DC2\GS\n\
    \\EMDEPRECATED_STATUS_CODE_OK\DLE\NUL\DC2$\n\
    \ DEPRECATED_STATUS_CODE_CANCELLED\DLE\SOH\DC2(\n\
    \$DEPRECATED_STATUS_CODE_UNKNOWN_ERROR\DLE\STX\DC2+\n\
    \'DEPRECATED_STATUS_CODE_INVALID_ARGUMENT\DLE\ETX\DC2,\n\
    \(DEPRECATED_STATUS_CODE_DEADLINE_EXCEEDED\DLE\EOT\DC2$\n\
    \ DEPRECATED_STATUS_CODE_NOT_FOUND\DLE\ENQ\DC2)\n\
    \%DEPRECATED_STATUS_CODE_ALREADY_EXISTS\DLE\ACK\DC2,\n\
    \(DEPRECATED_STATUS_CODE_PERMISSION_DENIED\DLE\a\DC2-\n\
    \)DEPRECATED_STATUS_CODE_RESOURCE_EXHAUSTED\DLE\b\DC2.\n\
    \*DEPRECATED_STATUS_CODE_FAILED_PRECONDITION\DLE\t\DC2\"\n\
    \\RSDEPRECATED_STATUS_CODE_ABORTED\DLE\n\
    \\DC2'\n\
    \#DEPRECATED_STATUS_CODE_OUT_OF_RANGE\DLE\v\DC2(\n\
    \$DEPRECATED_STATUS_CODE_UNIMPLEMENTED\DLE\f\DC2)\n\
    \%DEPRECATED_STATUS_CODE_INTERNAL_ERROR\DLE\r\DC2&\n\
    \\"DEPRECATED_STATUS_CODE_UNAVAILABLE\DLE\SO\DC2$\n\
    \ DEPRECATED_STATUS_CODE_DATA_LOSS\DLE\SI\DC2*\n\
    \&DEPRECATED_STATUS_CODE_UNAUTHENTICATED\DLE\DLE\"N\n\
    \\n\
    \StatusCode\DC2\NAK\n\
    \\DC1STATUS_CODE_UNSET\DLE\NUL\DC2\DC2\n\
    \\SOSTATUS_CODE_OK\DLE\SOH\DC2\NAK\n\
    \\DC1STATUS_CODE_ERROR\DLE\STXBn\n\
    \\USio.opentelemetry.proto.trace.v1B\n\
    \TraceProtoP\SOHZ=github.com/open-telemetry/opentelemetry-proto/gen/go/trace/v1J\146x\n\
    \\a\DC2\ENQ\SO\NUL\214\STX\SOH\n\
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
    \\SOH\STX\DC2\ETX\DLE\NUL%\n\
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
    \\SOH\b\DC2\ETX\SYN\NUL8\n\
    \\t\n\
    \\STX\b\SOH\DC2\ETX\SYN\NUL8\n\
    \\b\n\
    \\SOH\b\DC2\ETX\ETB\NUL+\n\
    \\t\n\
    \\STX\b\b\DC2\ETX\ETB\NUL+\n\
    \\b\n\
    \\SOH\b\DC2\ETX\CAN\NULT\n\
    \\t\n\
    \\STX\b\v\DC2\ETX\CAN\NULT\n\
    \\206\ETX\n\
    \\STX\EOT\NUL\DC2\EOT$\NUL+\SOH\SUB\193\ETX TracesData represents the traces data that can be stored in a persistent storage,\n\
    \ OR can be embedded by other protocols that transfer OTLP traces data but do\n\
    \ not implement the OTLP protocol.\n\
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
    \\ETX\EOT\NUL\SOH\DC2\ETX$\b\DC2\n\
    \\174\STX\n\
    \\EOT\EOT\NUL\STX\NUL\DC2\ETX*\STX,\SUB\160\STX An array of ResourceSpans.\n\
    \ For data coming from a single resource this array will typically contain\n\
    \ one element. Intermediary nodes that receive data from multiple origins\n\
    \ typically batch the data before forwarding further and in that case this\n\
    \ array will contain multiple elements.\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\EOT\DC2\ETX*\STX\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\ACK\DC2\ETX*\v\CAN\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\SOH\DC2\ETX*\EM'\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\ETX\DC2\ETX**+\n\
    \J\n\
    \\STX\EOT\SOH\DC2\EOT.\NUL:\SOH\SUB> A collection of InstrumentationLibrarySpans from a Resource.\n\
    \\n\
    \\n\
    \\n\
    \\ETX\EOT\SOH\SOH\DC2\ETX.\b\NAK\n\
    \t\n\
    \\EOT\EOT\SOH\STX\NUL\DC2\ETX1\STX8\SUBg The resource for the spans in this message.\n\
    \ If this field is not set then no resource info is known.\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\ACK\DC2\ETX1\STX*\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\SOH\DC2\ETX1+3\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\ETX\DC2\ETX167\n\
    \T\n\
    \\EOT\EOT\SOH\STX\SOH\DC2\ETX4\STXI\SUBG A list of InstrumentationLibrarySpans that originate from a resource.\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\SOH\EOT\DC2\ETX4\STX\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\SOH\ACK\DC2\ETX4\v&\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\SOH\SOH\DC2\ETX4'D\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\SOH\ETX\DC2\ETX4GH\n\
    \\192\SOH\n\
    \\EOT\EOT\SOH\STX\STX\DC2\ETX9\STX\CAN\SUB\178\SOH This schema_url applies to the data in the \"resource\" field. It does not apply\n\
    \ to the data in the \"instrumentation_library_spans\" field which have their own\n\
    \ schema_url field.\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\STX\ENQ\DC2\ETX9\STX\b\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\STX\SOH\DC2\ETX9\t\DC3\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\STX\ETX\DC2\ETX9\SYN\ETB\n\
    \J\n\
    \\STX\EOT\STX\DC2\EOT=\NULH\SOH\SUB> A collection of Spans produced by an InstrumentationLibrary.\n\
    \\n\
    \\n\
    \\n\
    \\ETX\EOT\STX\SOH\DC2\ETX=\b#\n\
    \\211\SOH\n\
    \\EOT\EOT\STX\STX\NUL\DC2\ETXA\STXS\SUB\197\SOH The instrumentation library information for the spans in this message.\n\
    \ Semantically when InstrumentationLibrary isn't set, it is equivalent with\n\
    \ an empty instrumentation library name (unknown).\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\NUL\ACK\DC2\ETXA\STX6\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\NUL\SOH\DC2\ETXA7N\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\NUL\ETX\DC2\ETXAQR\n\
    \N\n\
    \\EOT\EOT\STX\STX\SOH\DC2\ETXD\STX\SUB\SUBA A list of Spans that originate from an instrumentation library.\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\SOH\EOT\DC2\ETXD\STX\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\SOH\ACK\DC2\ETXD\v\SI\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\SOH\SOH\DC2\ETXD\DLE\NAK\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\SOH\ETX\DC2\ETXD\CAN\EM\n\
    \Y\n\
    \\EOT\EOT\STX\STX\STX\DC2\ETXG\STX\CAN\SUBL This schema_url applies to all spans and span events in the \"spans\" field.\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\STX\ENQ\DC2\ETXG\STX\b\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\STX\SOH\DC2\ETXG\t\DC3\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\STX\ETX\DC2\ETXG\SYN\ETB\n\
    \\136\EOT\n\
    \\STX\EOT\ETX\DC2\ENQS\NUL\253\SOH\SOH\SUB\250\ETX Span represents a single operation within a trace. Spans can be\n\
    \ nested to form a trace tree. Spans may also be linked to other spans\n\
    \ from the same or different trace and form graphs. Often, a trace\n\
    \ contains a root span that describes the end-to-end latency, and one\n\
    \ or more subspans for its sub-operations. A trace can also contain\n\
    \ multiple root spans, or none at all. Spans do not need to be\n\
    \ contiguous - there may be gaps or overlaps between spans in a trace.\n\
    \\n\
    \ The next available field id is 17.\n\
    \\n\
    \\n\
    \\n\
    \\ETX\EOT\ETX\SOH\DC2\ETXS\b\f\n\
    \\205\STX\n\
    \\EOT\EOT\ETX\STX\NUL\DC2\ETX\\\STX\NAK\SUB\191\STX A unique identifier for a trace. All spans from the same trace share\n\
    \ the same `trace_id`. The ID is a 16-byte array. An ID with all zeroes\n\
    \ is considered invalid.\n\
    \\n\
    \ This field is semantically required. Receiver should generate new\n\
    \ random trace_id if empty or invalid trace_id was received.\n\
    \\n\
    \ This field is required.\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\ETX\STX\NUL\ENQ\DC2\ETX\\\STX\a\n\
    \\f\n\
    \\ENQ\EOT\ETX\STX\NUL\SOH\DC2\ETX\\\b\DLE\n\
    \\f\n\
    \\ENQ\EOT\ETX\STX\NUL\ETX\DC2\ETX\\\DC3\DC4\n\
    \\195\STX\n\
    \\EOT\EOT\ETX\STX\SOH\DC2\ETXf\STX\DC4\SUB\181\STX A unique identifier for a span within a trace, assigned when the span\n\
    \ is created. The ID is an 8-byte array. An ID with all zeroes is considered\n\
    \ invalid.\n\
    \\n\
    \ This field is semantically required. Receiver should generate new\n\
    \ random span_id if empty or invalid span_id was received.\n\
    \\n\
    \ This field is required.\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\ETX\STX\SOH\ENQ\DC2\ETXf\STX\a\n\
    \\f\n\
    \\ENQ\EOT\ETX\STX\SOH\SOH\DC2\ETXf\b\SI\n\
    \\f\n\
    \\ENQ\EOT\ETX\STX\SOH\ETX\DC2\ETXf\DC2\DC3\n\
    \\175\STX\n\
    \\EOT\EOT\ETX\STX\STX\DC2\ETXk\STX\EM\SUB\161\STX trace_state conveys information about request position in multiple distributed tracing graphs.\n\
    \ It is a trace_state in w3c-trace-context format: https://www.w3.org/TR/trace-context/#tracestate-header\n\
    \ See also https://github.com/w3c/distributed-tracing for more details about this field.\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\ETX\STX\STX\ENQ\DC2\ETXk\STX\b\n\
    \\f\n\
    \\ENQ\EOT\ETX\STX\STX\SOH\DC2\ETXk\t\DC4\n\
    \\f\n\
    \\ENQ\EOT\ETX\STX\STX\ETX\DC2\ETXk\ETB\CAN\n\
    \\139\SOH\n\
    \\EOT\EOT\ETX\STX\ETX\DC2\ETXo\STX\ESC\SUB~ The `span_id` of this span's parent span. If this is a root span, then this\n\
    \ field must be empty. The ID is an 8-byte array.\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\ETX\STX\ETX\ENQ\DC2\ETXo\STX\a\n\
    \\f\n\
    \\ENQ\EOT\ETX\STX\ETX\SOH\DC2\ETXo\b\SYN\n\
    \\f\n\
    \\ENQ\EOT\ETX\STX\ETX\ETX\DC2\ETXo\EM\SUB\n\
    \\218\ETX\n\
    \\EOT\EOT\ETX\STX\EOT\DC2\ETX|\STX\DC2\SUB\204\ETX A description of the span's operation.\n\
    \\n\
    \ For example, the name can be a qualified method name or a file name\n\
    \ and a line number where the operation is called. A best practice is to use\n\
    \ the same display name at the same call point in an application.\n\
    \ This makes it easier to correlate spans in different traces.\n\
    \\n\
    \ This field is semantically required to be set to non-empty string.\n\
    \ Empty value is equivalent to an unknown span name.\n\
    \\n\
    \ This field is required.\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\ETX\STX\EOT\ENQ\DC2\ETX|\STX\b\n\
    \\f\n\
    \\ENQ\EOT\ETX\STX\EOT\SOH\DC2\ETX|\t\r\n\
    \\f\n\
    \\ENQ\EOT\ETX\STX\EOT\ETX\DC2\ETX|\DLE\DC1\n\
    \\155\SOH\n\
    \\EOT\EOT\ETX\EOT\NUL\DC2\ACK\128\SOH\STX\154\SOH\ETX\SUB\138\SOH SpanKind is the type of span. Can be used to specify additional relationships between spans\n\
    \ in addition to a parent/child relationship.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETX\EOT\NUL\SOH\DC2\EOT\128\SOH\a\SI\n\
    \\133\SOH\n\
    \\ACK\EOT\ETX\EOT\NUL\STX\NUL\DC2\EOT\131\SOH\EOT\RS\SUBu Unspecified. Do NOT use as default.\n\
    \ Implementations MAY assume SpanKind to be INTERNAL when receiving UNSPECIFIED.\n\
    \\n\
    \\SI\n\
    \\a\EOT\ETX\EOT\NUL\STX\NUL\SOH\DC2\EOT\131\SOH\EOT\EM\n\
    \\SI\n\
    \\a\EOT\ETX\EOT\NUL\STX\NUL\STX\DC2\EOT\131\SOH\FS\GS\n\
    \\170\SOH\n\
    \\ACK\EOT\ETX\EOT\NUL\STX\SOH\DC2\EOT\135\SOH\EOT\ESC\SUB\153\SOH Indicates that the span represents an internal operation within an application,\n\
    \ as opposed to an operation happening at the boundaries. Default value.\n\
    \\n\
    \\SI\n\
    \\a\EOT\ETX\EOT\NUL\STX\SOH\SOH\DC2\EOT\135\SOH\EOT\SYN\n\
    \\SI\n\
    \\a\EOT\ETX\EOT\NUL\STX\SOH\STX\DC2\EOT\135\SOH\EM\SUB\n\
    \q\n\
    \\ACK\EOT\ETX\EOT\NUL\STX\STX\DC2\EOT\139\SOH\EOT\EM\SUBa Indicates that the span covers server-side handling of an RPC or other\n\
    \ remote network request.\n\
    \\n\
    \\SI\n\
    \\a\EOT\ETX\EOT\NUL\STX\STX\SOH\DC2\EOT\139\SOH\EOT\DC4\n\
    \\SI\n\
    \\a\EOT\ETX\EOT\NUL\STX\STX\STX\DC2\EOT\139\SOH\ETB\CAN\n\
    \U\n\
    \\ACK\EOT\ETX\EOT\NUL\STX\ETX\DC2\EOT\142\SOH\EOT\EM\SUBE Indicates that the span describes a request to some remote service.\n\
    \\n\
    \\SI\n\
    \\a\EOT\ETX\EOT\NUL\STX\ETX\SOH\DC2\EOT\142\SOH\EOT\DC4\n\
    \\SI\n\
    \\a\EOT\ETX\EOT\NUL\STX\ETX\STX\DC2\EOT\142\SOH\ETB\CAN\n\
    \\232\STX\n\
    \\ACK\EOT\ETX\EOT\NUL\STX\EOT\DC2\EOT\148\SOH\EOT\ESC\SUB\215\STX Indicates that the span describes a producer sending a message to a broker.\n\
    \ Unlike CLIENT and SERVER, there is often no direct critical path latency relationship\n\
    \ between producer and consumer spans. A PRODUCER span ends when the message was accepted\n\
    \ by the broker while the logical processing of the message might span a much longer time.\n\
    \\n\
    \\SI\n\
    \\a\EOT\ETX\EOT\NUL\STX\EOT\SOH\DC2\EOT\148\SOH\EOT\SYN\n\
    \\SI\n\
    \\a\EOT\ETX\EOT\NUL\STX\EOT\STX\DC2\EOT\148\SOH\EM\SUB\n\
    \\219\SOH\n\
    \\ACK\EOT\ETX\EOT\NUL\STX\ENQ\DC2\EOT\153\SOH\EOT\ESC\SUB\202\SOH Indicates that the span describes consumer receiving a message from a broker.\n\
    \ Like the PRODUCER kind, there is often no direct critical path latency relationship\n\
    \ between producer and consumer spans.\n\
    \\n\
    \\SI\n\
    \\a\EOT\ETX\EOT\NUL\STX\ENQ\SOH\DC2\EOT\153\SOH\EOT\SYN\n\
    \\SI\n\
    \\a\EOT\ETX\EOT\NUL\STX\ENQ\STX\DC2\EOT\153\SOH\EM\SUB\n\
    \\245\SOH\n\
    \\EOT\EOT\ETX\STX\ENQ\DC2\EOT\159\SOH\STX\DC4\SUB\230\SOH Distinguishes between spans generated in a particular context. For example,\n\
    \ two spans with the same name may be distinguished using `CLIENT` (caller)\n\
    \ and `SERVER` (callee) to identify queueing latency associated with the span.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\ENQ\ACK\DC2\EOT\159\SOH\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\ENQ\SOH\DC2\EOT\159\SOH\v\SI\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\ENQ\ETX\DC2\EOT\159\SOH\DC2\DC3\n\
    \\166\ETX\n\
    \\EOT\EOT\ETX\STX\ACK\DC2\EOT\167\SOH\STX#\SUB\151\ETX start_time_unix_nano is the start time of the span. On the client side, this is the time\n\
    \ kept by the local machine where the span execution starts. On the server side, this\n\
    \ is the time when the server's application handler starts running.\n\
    \ Value is UNIX Epoch time in nanoseconds since 00:00:00 UTC on 1 January 1970.\n\
    \\n\
    \ This field is semantically required and it is expected that end_time >= start_time.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\ACK\ENQ\DC2\EOT\167\SOH\STX\t\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\ACK\SOH\DC2\EOT\167\SOH\n\
    \\RS\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\ACK\ETX\DC2\EOT\167\SOH!\"\n\
    \\157\ETX\n\
    \\EOT\EOT\ETX\STX\a\DC2\EOT\175\SOH\STX!\SUB\142\ETX end_time_unix_nano is the end time of the span. On the client side, this is the time\n\
    \ kept by the local machine where the span execution ends. On the server side, this\n\
    \ is the time when the server application handler stops running.\n\
    \ Value is UNIX Epoch time in nanoseconds since 00:00:00 UTC on 1 January 1970.\n\
    \\n\
    \ This field is semantically required and it is expected that end_time >= start_time.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\a\ENQ\DC2\EOT\175\SOH\STX\t\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\a\SOH\DC2\EOT\175\SOH\n\
    \\FS\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\a\ETX\DC2\EOT\175\SOH\US \n\
    \\220\EOT\n\
    \\EOT\EOT\ETX\STX\b\DC2\EOT\187\SOH\STXA\SUB\205\EOT attributes is a collection of key/value pairs. Note, global attributes\n\
    \ like server name can be set using the resource API. Examples of attributes:\n\
    \\n\
    \     \"/http/user_agent\": \"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36\"\n\
    \     \"/http/server_latency\": 300\n\
    \     \"abc.com/myattribute\": true\n\
    \     \"abc.com/score\": 10.239\n\
    \\n\
    \ The OpenTelemetry API specification further restricts the allowed value types:\n\
    \ https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/common/common.md#attributes\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\b\EOT\DC2\EOT\187\SOH\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\b\ACK\DC2\EOT\187\SOH\v1\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\b\SOH\DC2\EOT\187\SOH2<\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\b\ETX\DC2\EOT\187\SOH?@\n\
    \\247\SOH\n\
    \\EOT\EOT\ETX\STX\t\DC2\EOT\192\SOH\STX'\SUB\232\SOH dropped_attributes_count is the number of attributes that were discarded. Attributes\n\
    \ can be discarded because their keys are too long or because there are too many\n\
    \ attributes. If this value is 0, then no attributes were dropped.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\t\ENQ\DC2\EOT\192\SOH\STX\b\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\t\SOH\DC2\EOT\192\SOH\t!\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\t\ETX\DC2\EOT\192\SOH$&\n\
    \\132\SOH\n\
    \\EOT\EOT\ETX\ETX\NUL\DC2\ACK\196\SOH\STX\210\SOH\ETX\SUBt Event is a time-stamped annotation of the span, consisting of user-supplied\n\
    \ text description and key-value pairs.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETX\ETX\NUL\SOH\DC2\EOT\196\SOH\n\
    \\SI\n\
    \@\n\
    \\ACK\EOT\ETX\ETX\NUL\STX\NUL\DC2\EOT\198\SOH\EOT\US\SUB0 time_unix_nano is the time the event occurred.\n\
    \\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\NUL\STX\NUL\ENQ\DC2\EOT\198\SOH\EOT\v\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\NUL\STX\NUL\SOH\DC2\EOT\198\SOH\f\SUB\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\NUL\STX\NUL\ETX\DC2\EOT\198\SOH\GS\RS\n\
    \h\n\
    \\ACK\EOT\ETX\ETX\NUL\STX\SOH\DC2\EOT\202\SOH\EOT\DC4\SUBX name of the event.\n\
    \ This field is semantically required to be set to non-empty string.\n\
    \\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\NUL\STX\SOH\ENQ\DC2\EOT\202\SOH\EOT\n\
    \\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\NUL\STX\SOH\SOH\DC2\EOT\202\SOH\v\SI\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\NUL\STX\SOH\ETX\DC2\EOT\202\SOH\DC2\DC3\n\
    \W\n\
    \\ACK\EOT\ETX\ETX\NUL\STX\STX\DC2\EOT\205\SOH\EOTC\SUBG attributes is a collection of attribute key/value pairs on the event.\n\
    \\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\NUL\STX\STX\EOT\DC2\EOT\205\SOH\EOT\f\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\NUL\STX\STX\ACK\DC2\EOT\205\SOH\r3\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\NUL\STX\STX\SOH\DC2\EOT\205\SOH4>\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\NUL\STX\STX\ETX\DC2\EOT\205\SOHAB\n\
    \\132\SOH\n\
    \\ACK\EOT\ETX\ETX\NUL\STX\ETX\DC2\EOT\209\SOH\EOT(\SUBt dropped_attributes_count is the number of dropped attributes. If the value is 0,\n\
    \ then no attributes were dropped.\n\
    \\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\NUL\STX\ETX\ENQ\DC2\EOT\209\SOH\EOT\n\
    \\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\NUL\STX\ETX\SOH\DC2\EOT\209\SOH\v#\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\NUL\STX\ETX\ETX\DC2\EOT\209\SOH&'\n\
    \6\n\
    \\EOT\EOT\ETX\STX\n\
    \\DC2\EOT\213\SOH\STX\GS\SUB( events is a collection of Event items.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\n\
    \\EOT\DC2\EOT\213\SOH\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\n\
    \\ACK\DC2\EOT\213\SOH\v\DLE\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\n\
    \\SOH\DC2\EOT\213\SOH\DC1\ETB\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\n\
    \\ETX\DC2\EOT\213\SOH\SUB\FS\n\
    \v\n\
    \\EOT\EOT\ETX\STX\v\DC2\EOT\217\SOH\STX#\SUBh dropped_events_count is the number of dropped events. If the value is 0, then no\n\
    \ events were dropped.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\v\ENQ\DC2\EOT\217\SOH\STX\b\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\v\SOH\DC2\EOT\217\SOH\t\GS\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\v\ETX\DC2\EOT\217\SOH \"\n\
    \\182\STX\n\
    \\EOT\EOT\ETX\ETX\SOH\DC2\ACK\223\SOH\STX\240\SOH\ETX\SUB\165\STX A pointer from the current span to another span in the same trace or in a\n\
    \ different trace. For example, this can be used in batching operations,\n\
    \ where a single batch handler processes multiple requests from different\n\
    \ traces or when the handler receives a request from a different project.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETX\ETX\SOH\SOH\DC2\EOT\223\SOH\n\
    \\SO\n\
    \n\n\
    \\ACK\EOT\ETX\ETX\SOH\STX\NUL\DC2\EOT\226\SOH\EOT\ETB\SUB^ A unique identifier of a trace that this linked span is part of. The ID is a\n\
    \ 16-byte array.\n\
    \\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\SOH\STX\NUL\ENQ\DC2\EOT\226\SOH\EOT\t\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\SOH\STX\NUL\SOH\DC2\EOT\226\SOH\n\
    \\DC2\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\SOH\STX\NUL\ETX\DC2\EOT\226\SOH\NAK\SYN\n\
    \U\n\
    \\ACK\EOT\ETX\ETX\SOH\STX\SOH\DC2\EOT\229\SOH\EOT\SYN\SUBE A unique identifier for the linked span. The ID is an 8-byte array.\n\
    \\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\SOH\STX\SOH\ENQ\DC2\EOT\229\SOH\EOT\t\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\SOH\STX\SOH\SOH\DC2\EOT\229\SOH\n\
    \\DC1\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\SOH\STX\SOH\ETX\DC2\EOT\229\SOH\DC4\NAK\n\
    \;\n\
    \\ACK\EOT\ETX\ETX\SOH\STX\STX\DC2\EOT\232\SOH\EOT\ESC\SUB+ The trace_state associated with the link.\n\
    \\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\SOH\STX\STX\ENQ\DC2\EOT\232\SOH\EOT\n\
    \\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\SOH\STX\STX\SOH\DC2\EOT\232\SOH\v\SYN\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\SOH\STX\STX\ETX\DC2\EOT\232\SOH\EM\SUB\n\
    \V\n\
    \\ACK\EOT\ETX\ETX\SOH\STX\ETX\DC2\EOT\235\SOH\EOTC\SUBF attributes is a collection of attribute key/value pairs on the link.\n\
    \\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\SOH\STX\ETX\EOT\DC2\EOT\235\SOH\EOT\f\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\SOH\STX\ETX\ACK\DC2\EOT\235\SOH\r3\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\SOH\STX\ETX\SOH\DC2\EOT\235\SOH4>\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\SOH\STX\ETX\ETX\DC2\EOT\235\SOHAB\n\
    \\132\SOH\n\
    \\ACK\EOT\ETX\ETX\SOH\STX\EOT\DC2\EOT\239\SOH\EOT(\SUBt dropped_attributes_count is the number of dropped attributes. If the value is 0,\n\
    \ then no attributes were dropped.\n\
    \\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\SOH\STX\EOT\ENQ\DC2\EOT\239\SOH\EOT\n\
    \\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\SOH\STX\EOT\SOH\DC2\EOT\239\SOH\v#\n\
    \\SI\n\
    \\a\EOT\ETX\ETX\SOH\STX\EOT\ETX\DC2\EOT\239\SOH&'\n\
    \~\n\
    \\EOT\EOT\ETX\STX\f\DC2\EOT\244\SOH\STX\ESC\SUBp links is a collection of Links, which are references from this span to a span\n\
    \ in the same or different trace.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\f\EOT\DC2\EOT\244\SOH\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\f\ACK\DC2\EOT\244\SOH\v\SI\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\f\SOH\DC2\EOT\244\SOH\DLE\NAK\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\f\ETX\DC2\EOT\244\SOH\CAN\SUB\n\
    \\153\SOH\n\
    \\EOT\EOT\ETX\STX\r\DC2\EOT\248\SOH\STX\"\SUB\138\SOH dropped_links_count is the number of dropped links after the maximum size was\n\
    \ enforced. If this value is 0, then no links were dropped.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\r\ENQ\DC2\EOT\248\SOH\STX\b\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\r\SOH\DC2\EOT\248\SOH\t\FS\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\r\ETX\DC2\EOT\248\SOH\US!\n\
    \\173\SOH\n\
    \\EOT\EOT\ETX\STX\SO\DC2\EOT\252\SOH\STX\NAK\SUB\158\SOH An optional final status for this span. Semantically when Status isn't set, it means\n\
    \ span's status code is unset, i.e. assume STATUS_CODE_UNSET (code = 0).\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\SO\ACK\DC2\EOT\252\SOH\STX\b\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\SO\SOH\DC2\EOT\252\SOH\t\SI\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\SO\ETX\DC2\EOT\252\SOH\DC2\DC4\n\
    \\145\SO\n\
    \\STX\EOT\EOT\DC2\ACK\129\STX\NUL\214\STX\SOH\SUB\139\SOH The Status type defines a logical error model that is suitable for different\n\
    \ programming environments, including REST APIs and RPC APIs.\n\
    \\"\244\f IMPORTANT: Backward compatibility notes:\n\
    \\n\
    \ To ensure any pair of senders and receivers continues to correctly signal and\n\
    \ interpret erroneous situations, the senders and receivers MUST follow these rules:\n\
    \\n\
    \ 1. Old senders and receivers that are not aware of `code` field will continue using\n\
    \ the `deprecated_code` field to signal and interpret erroneous situation.\n\
    \\n\
    \ 2. New senders, which are aware of the `code` field MUST set both the\n\
    \ `deprecated_code` and `code` fields according to the following rules:\n\
    \\n\
    \   if code==STATUS_CODE_UNSET then `deprecated_code` MUST be\n\
    \   set to DEPRECATED_STATUS_CODE_OK.\n\
    \\n\
    \   if code==STATUS_CODE_OK then `deprecated_code` MUST be\n\
    \   set to DEPRECATED_STATUS_CODE_OK.\n\
    \\n\
    \   if code==STATUS_CODE_ERROR then `deprecated_code` MUST be\n\
    \   set to DEPRECATED_STATUS_CODE_UNKNOWN_ERROR.\n\
    \\n\
    \ These rules allow old receivers to correctly interpret data received from new senders.\n\
    \\n\
    \ 3. New receivers MUST look at both the `code` and `deprecated_code` fields in order\n\
    \ to interpret the overall status:\n\
    \\n\
    \   If code==STATUS_CODE_UNSET then the value of `deprecated_code` is the\n\
    \   carrier of the overall status according to these rules:\n\
    \\n\
    \     if deprecated_code==DEPRECATED_STATUS_CODE_OK then the receiver MUST interpret\n\
    \     the overall status to be STATUS_CODE_UNSET.\n\
    \\n\
    \     if deprecated_code!=DEPRECATED_STATUS_CODE_OK then the receiver MUST interpret\n\
    \     the overall status to be STATUS_CODE_ERROR.\n\
    \\n\
    \   If code!=STATUS_CODE_UNSET then the value of `deprecated_code` MUST be\n\
    \   ignored, the `code` field is the sole carrier of the status.\n\
    \\n\
    \ These rules allow new receivers to correctly interpret data received from old senders.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\EOT\SOH\DC2\EOT\129\STX\b\SO\n\
    \\SO\n\
    \\EOT\EOT\EOT\EOT\NUL\DC2\ACK\169\STX\STX\187\STX\ETX\n\
    \\r\n\
    \\ENQ\EOT\EOT\EOT\NUL\SOH\DC2\EOT\169\STX\a\ESC\n\
    \\SO\n\
    \\ACK\EOT\EOT\EOT\NUL\STX\NUL\DC2\EOT\170\STX\EOT3\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\NUL\STX\NUL\SOH\DC2\EOT\170\STX\EOT\GS\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\NUL\STX\NUL\STX\DC2\EOT\170\STX12\n\
    \\SO\n\
    \\ACK\EOT\EOT\EOT\NUL\STX\SOH\DC2\EOT\171\STX\EOT3\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\NUL\STX\SOH\SOH\DC2\EOT\171\STX\EOT$\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\NUL\STX\SOH\STX\DC2\EOT\171\STX12\n\
    \\SO\n\
    \\ACK\EOT\EOT\EOT\NUL\STX\STX\DC2\EOT\172\STX\EOT3\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\NUL\STX\STX\SOH\DC2\EOT\172\STX\EOT(\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\NUL\STX\STX\STX\DC2\EOT\172\STX12\n\
    \\SO\n\
    \\ACK\EOT\EOT\EOT\NUL\STX\ETX\DC2\EOT\173\STX\EOT3\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\NUL\STX\ETX\SOH\DC2\EOT\173\STX\EOT+\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\NUL\STX\ETX\STX\DC2\EOT\173\STX12\n\
    \\SO\n\
    \\ACK\EOT\EOT\EOT\NUL\STX\EOT\DC2\EOT\174\STX\EOT3\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\NUL\STX\EOT\SOH\DC2\EOT\174\STX\EOT,\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\NUL\STX\EOT\STX\DC2\EOT\174\STX12\n\
    \\SO\n\
    \\ACK\EOT\EOT\EOT\NUL\STX\ENQ\DC2\EOT\175\STX\EOT3\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\NUL\STX\ENQ\SOH\DC2\EOT\175\STX\EOT$\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\NUL\STX\ENQ\STX\DC2\EOT\175\STX12\n\
    \\SO\n\
    \\ACK\EOT\EOT\EOT\NUL\STX\ACK\DC2\EOT\176\STX\EOT3\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\NUL\STX\ACK\SOH\DC2\EOT\176\STX\EOT)\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\NUL\STX\ACK\STX\DC2\EOT\176\STX12\n\
    \\SO\n\
    \\ACK\EOT\EOT\EOT\NUL\STX\a\DC2\EOT\177\STX\EOT3\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\NUL\STX\a\SOH\DC2\EOT\177\STX\EOT,\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\NUL\STX\a\STX\DC2\EOT\177\STX12\n\
    \\SO\n\
    \\ACK\EOT\EOT\EOT\NUL\STX\b\DC2\EOT\178\STX\EOT3\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\NUL\STX\b\SOH\DC2\EOT\178\STX\EOT-\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\NUL\STX\b\STX\DC2\EOT\178\STX12\n\
    \\SO\n\
    \\ACK\EOT\EOT\EOT\NUL\STX\t\DC2\EOT\179\STX\EOT3\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\NUL\STX\t\SOH\DC2\EOT\179\STX\EOT.\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\NUL\STX\t\STX\DC2\EOT\179\STX12\n\
    \\SO\n\
    \\ACK\EOT\EOT\EOT\NUL\STX\n\
    \\DC2\EOT\180\STX\EOT4\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\NUL\STX\n\
    \\SOH\DC2\EOT\180\STX\EOT\"\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\NUL\STX\n\
    \\STX\DC2\EOT\180\STX13\n\
    \\SO\n\
    \\ACK\EOT\EOT\EOT\NUL\STX\v\DC2\EOT\181\STX\EOT4\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\NUL\STX\v\SOH\DC2\EOT\181\STX\EOT'\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\NUL\STX\v\STX\DC2\EOT\181\STX13\n\
    \\SO\n\
    \\ACK\EOT\EOT\EOT\NUL\STX\f\DC2\EOT\182\STX\EOT4\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\NUL\STX\f\SOH\DC2\EOT\182\STX\EOT(\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\NUL\STX\f\STX\DC2\EOT\182\STX13\n\
    \\SO\n\
    \\ACK\EOT\EOT\EOT\NUL\STX\r\DC2\EOT\183\STX\EOT4\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\NUL\STX\r\SOH\DC2\EOT\183\STX\EOT)\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\NUL\STX\r\STX\DC2\EOT\183\STX13\n\
    \\SO\n\
    \\ACK\EOT\EOT\EOT\NUL\STX\SO\DC2\EOT\184\STX\EOT4\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\NUL\STX\SO\SOH\DC2\EOT\184\STX\EOT&\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\NUL\STX\SO\STX\DC2\EOT\184\STX13\n\
    \\SO\n\
    \\ACK\EOT\EOT\EOT\NUL\STX\SI\DC2\EOT\185\STX\EOT4\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\NUL\STX\SI\SOH\DC2\EOT\185\STX\EOT$\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\NUL\STX\SI\STX\DC2\EOT\185\STX13\n\
    \\SO\n\
    \\ACK\EOT\EOT\EOT\NUL\STX\DLE\DC2\EOT\186\STX\EOT4\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\NUL\STX\DLE\SOH\DC2\EOT\186\STX\EOT*\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\NUL\STX\DLE\STX\DC2\EOT\186\STX13\n\
    \\131\ETX\n\
    \\EOT\EOT\EOT\STX\NUL\DC2\EOT\195\STX\STX=\SUB\244\STX The deprecated status code. This is an optional field.\n\
    \\n\
    \ This field is deprecated and is replaced by the `code` field below. See backward\n\
    \ compatibility notes below. According to our stability guarantees this field\n\
    \ will be removed in 12 months, on Oct 22, 2021. All usage of old senders and\n\
    \ receivers that do not understand the `code` field MUST be phased out by then.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\NUL\ACK\DC2\EOT\195\STX\STX\SYN\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\NUL\SOH\DC2\EOT\195\STX\ETB&\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\NUL\ETX\DC2\EOT\195\STX)*\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\NUL\b\DC2\EOT\195\STX+<\n\
    \\SO\n\
    \\ACK\EOT\EOT\STX\NUL\b\ETX\DC2\EOT\195\STX,;\n\
    \@\n\
    \\EOT\EOT\EOT\STX\SOH\DC2\EOT\198\STX\STX\NAK\SUB2 A developer-facing human readable error message.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\SOH\ENQ\DC2\EOT\198\STX\STX\b\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\SOH\SOH\DC2\EOT\198\STX\t\DLE\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\SOH\ETX\DC2\EOT\198\STX\DC3\DC4\n\
    \\167\SOH\n\
    \\EOT\EOT\EOT\EOT\SOH\DC2\ACK\202\STX\STX\210\STX\ETX\SUB\150\SOH For the semantics of status codes see\n\
    \ https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/trace/api.md#set-status\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\EOT\SOH\SOH\DC2\EOT\202\STX\a\DC1\n\
    \%\n\
    \\ACK\EOT\EOT\EOT\SOH\STX\NUL\DC2\EOT\204\STX\EOT(\SUB\NAK The default status.\n\
    \\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\SOH\STX\NUL\SOH\DC2\EOT\204\STX\EOT\NAK\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\SOH\STX\NUL\STX\DC2\EOT\204\STX&'\n\
    \w\n\
    \\ACK\EOT\EOT\EOT\SOH\STX\SOH\DC2\EOT\207\STX\EOT(\SUBg The Span has been validated by an Application developers or Operator to have\n\
    \ completed successfully.\n\
    \\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\SOH\STX\SOH\SOH\DC2\EOT\207\STX\EOT\DC2\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\SOH\STX\SOH\STX\DC2\EOT\207\STX&'\n\
    \-\n\
    \\ACK\EOT\EOT\EOT\SOH\STX\STX\DC2\EOT\209\STX\EOT(\SUB\GS The Span contains an error.\n\
    \\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\SOH\STX\STX\SOH\DC2\EOT\209\STX\EOT\NAK\n\
    \\SI\n\
    \\a\EOT\EOT\EOT\SOH\STX\STX\STX\DC2\EOT\209\STX&'\n\
    \ \n\
    \\EOT\EOT\EOT\STX\STX\DC2\EOT\213\STX\STX\SYN\SUB\DC2 The status code.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\STX\ACK\DC2\EOT\213\STX\STX\f\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\STX\SOH\DC2\EOT\213\STX\r\DC1\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\STX\ETX\DC2\EOT\213\STX\DC4\NAKb\ACKproto3"