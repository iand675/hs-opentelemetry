{- This file was auto-generated from opentelemetry/proto/metrics/v1/metrics.proto by the proto-lens-protoc program. -}
{-# LANGUAGE ScopedTypeVariables, DataKinds, TypeFamilies, UndecidableInstances, GeneralizedNewtypeDeriving, MultiParamTypeClasses, FlexibleContexts, FlexibleInstances, PatternSynonyms, MagicHash, NoImplicitPrelude, DataKinds, BangPatterns, TypeApplications, OverloadedStrings, DerivingStrategies#-}
{-# OPTIONS_GHC -Wno-unused-imports#-}
{-# OPTIONS_GHC -Wno-duplicate-exports#-}
{-# OPTIONS_GHC -Wno-dodgy-exports#-}
module Proto.Opentelemetry.Proto.Metrics.V1.Metrics (
        AggregationTemporality(..), AggregationTemporality(),
        AggregationTemporality'UnrecognizedValue, DataPointFlags(..),
        DataPointFlags(), DataPointFlags'UnrecognizedValue, Exemplar(),
        Exemplar'Value(..), _Exemplar'AsDouble, _Exemplar'AsInt,
        ExponentialHistogram(), ExponentialHistogramDataPoint(),
        ExponentialHistogramDataPoint'Buckets(), Gauge(), Histogram(),
        HistogramDataPoint(), InstrumentationLibraryMetrics(),
        IntDataPoint(), IntExemplar(), IntGauge(), IntHistogram(),
        IntHistogramDataPoint(), IntSum(), Metric(), Metric'Data(..),
        _Metric'IntGauge, _Metric'Gauge, _Metric'IntSum, _Metric'Sum,
        _Metric'IntHistogram, _Metric'Histogram,
        _Metric'ExponentialHistogram, _Metric'Summary, MetricsData(),
        NumberDataPoint(), NumberDataPoint'Value(..),
        _NumberDataPoint'AsDouble, _NumberDataPoint'AsInt,
        ResourceMetrics(), Sum(), Summary(), SummaryDataPoint(),
        SummaryDataPoint'ValueAtQuantile()
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
newtype DataPointFlags'UnrecognizedValue
  = DataPointFlags'UnrecognizedValue Data.Int.Int32
  deriving stock (Prelude.Eq, Prelude.Ord, Prelude.Show)
data DataPointFlags
  = FLAG_NONE |
    FLAG_NO_RECORDED_VALUE |
    DataPointFlags'Unrecognized !DataPointFlags'UnrecognizedValue
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
instance Data.ProtoLens.MessageEnum DataPointFlags where
  maybeToEnum 0 = Prelude.Just FLAG_NONE
  maybeToEnum 1 = Prelude.Just FLAG_NO_RECORDED_VALUE
  maybeToEnum k
    = Prelude.Just
        (DataPointFlags'Unrecognized
           (DataPointFlags'UnrecognizedValue (Prelude.fromIntegral k)))
  showEnum FLAG_NONE = "FLAG_NONE"
  showEnum FLAG_NO_RECORDED_VALUE = "FLAG_NO_RECORDED_VALUE"
  showEnum
    (DataPointFlags'Unrecognized (DataPointFlags'UnrecognizedValue k))
    = Prelude.show k
  readEnum k
    | (Prelude.==) k "FLAG_NONE" = Prelude.Just FLAG_NONE
    | (Prelude.==) k "FLAG_NO_RECORDED_VALUE"
    = Prelude.Just FLAG_NO_RECORDED_VALUE
    | Prelude.otherwise
    = (Prelude.>>=) (Text.Read.readMaybe k) Data.ProtoLens.maybeToEnum
instance Prelude.Bounded DataPointFlags where
  minBound = FLAG_NONE
  maxBound = FLAG_NO_RECORDED_VALUE
instance Prelude.Enum DataPointFlags where
  toEnum k__
    = Prelude.maybe
        (Prelude.error
           ((Prelude.++)
              "toEnum: unknown value for enum DataPointFlags: "
              (Prelude.show k__)))
        Prelude.id (Data.ProtoLens.maybeToEnum k__)
  fromEnum FLAG_NONE = 0
  fromEnum FLAG_NO_RECORDED_VALUE = 1
  fromEnum
    (DataPointFlags'Unrecognized (DataPointFlags'UnrecognizedValue k))
    = Prelude.fromIntegral k
  succ FLAG_NO_RECORDED_VALUE
    = Prelude.error
        "DataPointFlags.succ: bad argument FLAG_NO_RECORDED_VALUE. This value would be out of bounds."
  succ FLAG_NONE = FLAG_NO_RECORDED_VALUE
  succ (DataPointFlags'Unrecognized _)
    = Prelude.error
        "DataPointFlags.succ: bad argument: unrecognized value"
  pred FLAG_NONE
    = Prelude.error
        "DataPointFlags.pred: bad argument FLAG_NONE. This value would be out of bounds."
  pred FLAG_NO_RECORDED_VALUE = FLAG_NONE
  pred (DataPointFlags'Unrecognized _)
    = Prelude.error
        "DataPointFlags.pred: bad argument: unrecognized value"
  enumFrom = Data.ProtoLens.Message.Enum.messageEnumFrom
  enumFromTo = Data.ProtoLens.Message.Enum.messageEnumFromTo
  enumFromThen = Data.ProtoLens.Message.Enum.messageEnumFromThen
  enumFromThenTo = Data.ProtoLens.Message.Enum.messageEnumFromThenTo
instance Data.ProtoLens.FieldDefault DataPointFlags where
  fieldDefault = FLAG_NONE
instance Control.DeepSeq.NFData DataPointFlags where
  rnf x__ = Prelude.seq x__ ()
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.filteredAttributes' @:: Lens' Exemplar [Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue]@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.vec'filteredAttributes' @:: Lens' Exemplar (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.filteredLabels' @:: Lens' Exemplar [Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue]@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.vec'filteredLabels' @:: Lens' Exemplar (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.timeUnixNano' @:: Lens' Exemplar Data.Word.Word64@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.spanId' @:: Lens' Exemplar Data.ByteString.ByteString@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.traceId' @:: Lens' Exemplar Data.ByteString.ByteString@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.maybe'value' @:: Lens' Exemplar (Prelude.Maybe Exemplar'Value)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.maybe'asDouble' @:: Lens' Exemplar (Prelude.Maybe Prelude.Double)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.asDouble' @:: Lens' Exemplar Prelude.Double@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.maybe'asInt' @:: Lens' Exemplar (Prelude.Maybe Data.Int.Int64)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.asInt' @:: Lens' Exemplar Data.Int.Int64@ -}
data Exemplar
  = Exemplar'_constructor {_Exemplar'filteredAttributes :: !(Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue),
                           _Exemplar'filteredLabels :: !(Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue),
                           _Exemplar'timeUnixNano :: !Data.Word.Word64,
                           _Exemplar'spanId :: !Data.ByteString.ByteString,
                           _Exemplar'traceId :: !Data.ByteString.ByteString,
                           _Exemplar'value :: !(Prelude.Maybe Exemplar'Value),
                           _Exemplar'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show Exemplar where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
data Exemplar'Value
  = Exemplar'AsDouble !Prelude.Double |
    Exemplar'AsInt !Data.Int.Int64
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
instance Data.ProtoLens.Field.HasField Exemplar "filteredAttributes" [Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Exemplar'filteredAttributes
           (\ x__ y__ -> x__ {_Exemplar'filteredAttributes = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField Exemplar "vec'filteredAttributes" (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Exemplar'filteredAttributes
           (\ x__ y__ -> x__ {_Exemplar'filteredAttributes = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Exemplar "filteredLabels" [Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Exemplar'filteredLabels
           (\ x__ y__ -> x__ {_Exemplar'filteredLabels = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField Exemplar "vec'filteredLabels" (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Exemplar'filteredLabels
           (\ x__ y__ -> x__ {_Exemplar'filteredLabels = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Exemplar "timeUnixNano" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Exemplar'timeUnixNano
           (\ x__ y__ -> x__ {_Exemplar'timeUnixNano = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Exemplar "spanId" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Exemplar'spanId (\ x__ y__ -> x__ {_Exemplar'spanId = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Exemplar "traceId" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Exemplar'traceId (\ x__ y__ -> x__ {_Exemplar'traceId = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Exemplar "maybe'value" (Prelude.Maybe Exemplar'Value) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Exemplar'value (\ x__ y__ -> x__ {_Exemplar'value = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Exemplar "maybe'asDouble" (Prelude.Maybe Prelude.Double) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Exemplar'value (\ x__ y__ -> x__ {_Exemplar'value = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (Exemplar'AsDouble x__val)) -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap Exemplar'AsDouble y__))
instance Data.ProtoLens.Field.HasField Exemplar "asDouble" Prelude.Double where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Exemplar'value (\ x__ y__ -> x__ {_Exemplar'value = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (Exemplar'AsDouble x__val)) -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap Exemplar'AsDouble y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault))
instance Data.ProtoLens.Field.HasField Exemplar "maybe'asInt" (Prelude.Maybe Data.Int.Int64) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Exemplar'value (\ x__ y__ -> x__ {_Exemplar'value = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (Exemplar'AsInt x__val)) -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap Exemplar'AsInt y__))
instance Data.ProtoLens.Field.HasField Exemplar "asInt" Data.Int.Int64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Exemplar'value (\ x__ y__ -> x__ {_Exemplar'value = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (Exemplar'AsInt x__val)) -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap Exemplar'AsInt y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault))
instance Data.ProtoLens.Message Exemplar where
  messageName _
    = Data.Text.pack "opentelemetry.proto.metrics.v1.Exemplar"
  packedMessageDescriptor _
    = "\n\
      \\bExemplar\DC2X\n\
      \\DC3filtered_attributes\CAN\a \ETX(\v2'.opentelemetry.proto.common.v1.KeyValueR\DC2filteredAttributes\DC2Z\n\
      \\SIfiltered_labels\CAN\SOH \ETX(\v2-.opentelemetry.proto.common.v1.StringKeyValueR\SOfilteredLabelsB\STX\CAN\SOH\DC2$\n\
      \\SOtime_unix_nano\CAN\STX \SOH(\ACKR\ftimeUnixNano\DC2\GS\n\
      \\tas_double\CAN\ETX \SOH(\SOHH\NULR\basDouble\DC2\ETB\n\
      \\ACKas_int\CAN\ACK \SOH(\DLEH\NULR\ENQasInt\DC2\ETB\n\
      \\aspan_id\CAN\EOT \SOH(\fR\ACKspanId\DC2\EM\n\
      \\btrace_id\CAN\ENQ \SOH(\fR\atraceIdB\a\n\
      \\ENQvalue"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        filteredAttributes__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "filtered_attributes"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"filteredAttributes")) ::
              Data.ProtoLens.FieldDescriptor Exemplar
        filteredLabels__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "filtered_labels"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"filteredLabels")) ::
              Data.ProtoLens.FieldDescriptor Exemplar
        timeUnixNano__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "time_unix_nano"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Fixed64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"timeUnixNano")) ::
              Data.ProtoLens.FieldDescriptor Exemplar
        spanId__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "span_id"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"spanId")) ::
              Data.ProtoLens.FieldDescriptor Exemplar
        traceId__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "trace_id"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"traceId")) ::
              Data.ProtoLens.FieldDescriptor Exemplar
        asDouble__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "as_double"
              (Data.ProtoLens.ScalarField Data.ProtoLens.DoubleField ::
                 Data.ProtoLens.FieldTypeDescriptor Prelude.Double)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'asDouble")) ::
              Data.ProtoLens.FieldDescriptor Exemplar
        asInt__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "as_int"
              (Data.ProtoLens.ScalarField Data.ProtoLens.SFixed64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int64)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'asInt")) ::
              Data.ProtoLens.FieldDescriptor Exemplar
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 7, filteredAttributes__field_descriptor),
           (Data.ProtoLens.Tag 1, filteredLabels__field_descriptor),
           (Data.ProtoLens.Tag 2, timeUnixNano__field_descriptor),
           (Data.ProtoLens.Tag 4, spanId__field_descriptor),
           (Data.ProtoLens.Tag 5, traceId__field_descriptor),
           (Data.ProtoLens.Tag 3, asDouble__field_descriptor),
           (Data.ProtoLens.Tag 6, asInt__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Exemplar'_unknownFields
        (\ x__ y__ -> x__ {_Exemplar'_unknownFields = y__})
  defMessage
    = Exemplar'_constructor
        {_Exemplar'filteredAttributes = Data.Vector.Generic.empty,
         _Exemplar'filteredLabels = Data.Vector.Generic.empty,
         _Exemplar'timeUnixNano = Data.ProtoLens.fieldDefault,
         _Exemplar'spanId = Data.ProtoLens.fieldDefault,
         _Exemplar'traceId = Data.ProtoLens.fieldDefault,
         _Exemplar'value = Prelude.Nothing, _Exemplar'_unknownFields = []}
  parseMessage
    = let
        loop ::
          Exemplar
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue
             -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue
                -> Data.ProtoLens.Encoding.Bytes.Parser Exemplar
        loop x mutable'filteredAttributes mutable'filteredLabels
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'filteredAttributes <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                     (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                        mutable'filteredAttributes)
                      frozen'filteredLabels <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                 (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                    mutable'filteredLabels)
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
                              (Data.ProtoLens.Field.field @"vec'filteredAttributes")
                              frozen'filteredAttributes
                              (Lens.Family2.set
                                 (Data.ProtoLens.Field.field @"vec'filteredLabels")
                                 frozen'filteredLabels x)))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        58
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "filtered_attributes"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append
                                          mutable'filteredAttributes y)
                                loop x v mutable'filteredLabels
                        10
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "filtered_labels"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append
                                          mutable'filteredLabels y)
                                loop x mutable'filteredAttributes v
                        17
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getFixed64 "time_unix_nano"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"timeUnixNano") y x)
                                  mutable'filteredAttributes mutable'filteredLabels
                        34
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "span_id"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"spanId") y x)
                                  mutable'filteredAttributes mutable'filteredLabels
                        42
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "trace_id"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"traceId") y x)
                                  mutable'filteredAttributes mutable'filteredLabels
                        25
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Data.ProtoLens.Encoding.Bytes.wordToDouble
                                          Data.ProtoLens.Encoding.Bytes.getFixed64)
                                       "as_double"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"asDouble") y x)
                                  mutable'filteredAttributes mutable'filteredLabels
                        49
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getFixed64)
                                       "as_int"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"asInt") y x)
                                  mutable'filteredAttributes mutable'filteredLabels
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'filteredAttributes mutable'filteredLabels
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'filteredAttributes <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                              Data.ProtoLens.Encoding.Growing.new
              mutable'filteredLabels <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                          Data.ProtoLens.Encoding.Growing.new
              loop
                Data.ProtoLens.defMessage mutable'filteredAttributes
                mutable'filteredLabels)
          "Exemplar"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                (\ _v
                   -> (Data.Monoid.<>)
                        (Data.ProtoLens.Encoding.Bytes.putVarInt 58)
                        ((Prelude..)
                           (\ bs
                              -> (Data.Monoid.<>)
                                   (Data.ProtoLens.Encoding.Bytes.putVarInt
                                      (Prelude.fromIntegral (Data.ByteString.length bs)))
                                   (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                           Data.ProtoLens.encodeMessage _v))
                (Lens.Family2.view
                   (Data.ProtoLens.Field.field @"vec'filteredAttributes") _x))
             ((Data.Monoid.<>)
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
                      (Data.ProtoLens.Field.field @"vec'filteredLabels") _x))
                ((Data.Monoid.<>)
                   (let
                      _v
                        = Lens.Family2.view (Data.ProtoLens.Field.field @"timeUnixNano") _x
                    in
                      if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                          Data.Monoid.mempty
                      else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 17)
                            (Data.ProtoLens.Encoding.Bytes.putFixed64 _v))
                   ((Data.Monoid.<>)
                      (let
                         _v = Lens.Family2.view (Data.ProtoLens.Field.field @"spanId") _x
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
                         (let
                            _v = Lens.Family2.view (Data.ProtoLens.Field.field @"traceId") _x
                          in
                            if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                Data.Monoid.mempty
                            else
                                (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt 42)
                                  ((\ bs
                                      -> (Data.Monoid.<>)
                                           (Data.ProtoLens.Encoding.Bytes.putVarInt
                                              (Prelude.fromIntegral (Data.ByteString.length bs)))
                                           (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                     _v))
                         ((Data.Monoid.<>)
                            (case
                                 Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'value") _x
                             of
                               Prelude.Nothing -> Data.Monoid.mempty
                               (Prelude.Just (Exemplar'AsDouble v))
                                 -> (Data.Monoid.<>)
                                      (Data.ProtoLens.Encoding.Bytes.putVarInt 25)
                                      ((Prelude..)
                                         Data.ProtoLens.Encoding.Bytes.putFixed64
                                         Data.ProtoLens.Encoding.Bytes.doubleToWord v)
                               (Prelude.Just (Exemplar'AsInt v))
                                 -> (Data.Monoid.<>)
                                      (Data.ProtoLens.Encoding.Bytes.putVarInt 49)
                                      ((Prelude..)
                                         Data.ProtoLens.Encoding.Bytes.putFixed64
                                         Prelude.fromIntegral v))
                            (Data.ProtoLens.Encoding.Wire.buildFieldSet
                               (Lens.Family2.view Data.ProtoLens.unknownFields _x)))))))
instance Control.DeepSeq.NFData Exemplar where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Exemplar'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_Exemplar'filteredAttributes x__)
                (Control.DeepSeq.deepseq
                   (_Exemplar'filteredLabels x__)
                   (Control.DeepSeq.deepseq
                      (_Exemplar'timeUnixNano x__)
                      (Control.DeepSeq.deepseq
                         (_Exemplar'spanId x__)
                         (Control.DeepSeq.deepseq
                            (_Exemplar'traceId x__)
                            (Control.DeepSeq.deepseq (_Exemplar'value x__) ()))))))
instance Control.DeepSeq.NFData Exemplar'Value where
  rnf (Exemplar'AsDouble x__) = Control.DeepSeq.rnf x__
  rnf (Exemplar'AsInt x__) = Control.DeepSeq.rnf x__
_Exemplar'AsDouble ::
  Data.ProtoLens.Prism.Prism' Exemplar'Value Prelude.Double
_Exemplar'AsDouble
  = Data.ProtoLens.Prism.prism'
      Exemplar'AsDouble
      (\ p__
         -> case p__ of
              (Exemplar'AsDouble p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_Exemplar'AsInt ::
  Data.ProtoLens.Prism.Prism' Exemplar'Value Data.Int.Int64
_Exemplar'AsInt
  = Data.ProtoLens.Prism.prism'
      Exemplar'AsInt
      (\ p__
         -> case p__ of
              (Exemplar'AsInt p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.dataPoints' @:: Lens' ExponentialHistogram [ExponentialHistogramDataPoint]@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.vec'dataPoints' @:: Lens' ExponentialHistogram (Data.Vector.Vector ExponentialHistogramDataPoint)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.aggregationTemporality' @:: Lens' ExponentialHistogram AggregationTemporality@ -}
data ExponentialHistogram
  = ExponentialHistogram'_constructor {_ExponentialHistogram'dataPoints :: !(Data.Vector.Vector ExponentialHistogramDataPoint),
                                       _ExponentialHistogram'aggregationTemporality :: !AggregationTemporality,
                                       _ExponentialHistogram'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show ExponentialHistogram where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField ExponentialHistogram "dataPoints" [ExponentialHistogramDataPoint] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ExponentialHistogram'dataPoints
           (\ x__ y__ -> x__ {_ExponentialHistogram'dataPoints = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField ExponentialHistogram "vec'dataPoints" (Data.Vector.Vector ExponentialHistogramDataPoint) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ExponentialHistogram'dataPoints
           (\ x__ y__ -> x__ {_ExponentialHistogram'dataPoints = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ExponentialHistogram "aggregationTemporality" AggregationTemporality where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ExponentialHistogram'aggregationTemporality
           (\ x__ y__
              -> x__ {_ExponentialHistogram'aggregationTemporality = y__}))
        Prelude.id
instance Data.ProtoLens.Message ExponentialHistogram where
  messageName _
    = Data.Text.pack
        "opentelemetry.proto.metrics.v1.ExponentialHistogram"
  packedMessageDescriptor _
    = "\n\
      \\DC4ExponentialHistogram\DC2^\n\
      \\vdata_points\CAN\SOH \ETX(\v2=.opentelemetry.proto.metrics.v1.ExponentialHistogramDataPointR\n\
      \dataPoints\DC2o\n\
      \\ETBaggregation_temporality\CAN\STX \SOH(\SO26.opentelemetry.proto.metrics.v1.AggregationTemporalityR\SYNaggregationTemporality"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        dataPoints__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "data_points"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor ExponentialHistogramDataPoint)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"dataPoints")) ::
              Data.ProtoLens.FieldDescriptor ExponentialHistogram
        aggregationTemporality__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "aggregation_temporality"
              (Data.ProtoLens.ScalarField Data.ProtoLens.EnumField ::
                 Data.ProtoLens.FieldTypeDescriptor AggregationTemporality)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"aggregationTemporality")) ::
              Data.ProtoLens.FieldDescriptor ExponentialHistogram
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, dataPoints__field_descriptor),
           (Data.ProtoLens.Tag 2, aggregationTemporality__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _ExponentialHistogram'_unknownFields
        (\ x__ y__ -> x__ {_ExponentialHistogram'_unknownFields = y__})
  defMessage
    = ExponentialHistogram'_constructor
        {_ExponentialHistogram'dataPoints = Data.Vector.Generic.empty,
         _ExponentialHistogram'aggregationTemporality = Data.ProtoLens.fieldDefault,
         _ExponentialHistogram'_unknownFields = []}
  parseMessage
    = let
        loop ::
          ExponentialHistogram
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld ExponentialHistogramDataPoint
             -> Data.ProtoLens.Encoding.Bytes.Parser ExponentialHistogram
        loop x mutable'dataPoints
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'dataPoints <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                             (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                mutable'dataPoints)
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
                              (Data.ProtoLens.Field.field @"vec'dataPoints") frozen'dataPoints
                              x))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "data_points"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'dataPoints y)
                                loop x v
                        16
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
                                  mutable'dataPoints
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'dataPoints
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'dataPoints <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                      Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'dataPoints)
          "ExponentialHistogram"
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
                   (Data.ProtoLens.Field.field @"vec'dataPoints") _x))
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
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                         ((Prelude..)
                            ((Prelude..)
                               Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral)
                            Prelude.fromEnum _v))
                (Data.ProtoLens.Encoding.Wire.buildFieldSet
                   (Lens.Family2.view Data.ProtoLens.unknownFields _x)))
instance Control.DeepSeq.NFData ExponentialHistogram where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_ExponentialHistogram'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_ExponentialHistogram'dataPoints x__)
                (Control.DeepSeq.deepseq
                   (_ExponentialHistogram'aggregationTemporality x__) ()))
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.attributes' @:: Lens' ExponentialHistogramDataPoint [Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue]@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.vec'attributes' @:: Lens' ExponentialHistogramDataPoint (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.startTimeUnixNano' @:: Lens' ExponentialHistogramDataPoint Data.Word.Word64@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.timeUnixNano' @:: Lens' ExponentialHistogramDataPoint Data.Word.Word64@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.count' @:: Lens' ExponentialHistogramDataPoint Data.Word.Word64@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.sum' @:: Lens' ExponentialHistogramDataPoint Prelude.Double@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.scale' @:: Lens' ExponentialHistogramDataPoint Data.Int.Int32@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.zeroCount' @:: Lens' ExponentialHistogramDataPoint Data.Word.Word64@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.positive' @:: Lens' ExponentialHistogramDataPoint ExponentialHistogramDataPoint'Buckets@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.maybe'positive' @:: Lens' ExponentialHistogramDataPoint (Prelude.Maybe ExponentialHistogramDataPoint'Buckets)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.negative' @:: Lens' ExponentialHistogramDataPoint ExponentialHistogramDataPoint'Buckets@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.maybe'negative' @:: Lens' ExponentialHistogramDataPoint (Prelude.Maybe ExponentialHistogramDataPoint'Buckets)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.flags' @:: Lens' ExponentialHistogramDataPoint Data.Word.Word32@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.exemplars' @:: Lens' ExponentialHistogramDataPoint [Exemplar]@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.vec'exemplars' @:: Lens' ExponentialHistogramDataPoint (Data.Vector.Vector Exemplar)@ -}
data ExponentialHistogramDataPoint
  = ExponentialHistogramDataPoint'_constructor {_ExponentialHistogramDataPoint'attributes :: !(Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue),
                                                _ExponentialHistogramDataPoint'startTimeUnixNano :: !Data.Word.Word64,
                                                _ExponentialHistogramDataPoint'timeUnixNano :: !Data.Word.Word64,
                                                _ExponentialHistogramDataPoint'count :: !Data.Word.Word64,
                                                _ExponentialHistogramDataPoint'sum :: !Prelude.Double,
                                                _ExponentialHistogramDataPoint'scale :: !Data.Int.Int32,
                                                _ExponentialHistogramDataPoint'zeroCount :: !Data.Word.Word64,
                                                _ExponentialHistogramDataPoint'positive :: !(Prelude.Maybe ExponentialHistogramDataPoint'Buckets),
                                                _ExponentialHistogramDataPoint'negative :: !(Prelude.Maybe ExponentialHistogramDataPoint'Buckets),
                                                _ExponentialHistogramDataPoint'flags :: !Data.Word.Word32,
                                                _ExponentialHistogramDataPoint'exemplars :: !(Data.Vector.Vector Exemplar),
                                                _ExponentialHistogramDataPoint'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show ExponentialHistogramDataPoint where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField ExponentialHistogramDataPoint "attributes" [Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ExponentialHistogramDataPoint'attributes
           (\ x__ y__
              -> x__ {_ExponentialHistogramDataPoint'attributes = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField ExponentialHistogramDataPoint "vec'attributes" (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ExponentialHistogramDataPoint'attributes
           (\ x__ y__
              -> x__ {_ExponentialHistogramDataPoint'attributes = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ExponentialHistogramDataPoint "startTimeUnixNano" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ExponentialHistogramDataPoint'startTimeUnixNano
           (\ x__ y__
              -> x__ {_ExponentialHistogramDataPoint'startTimeUnixNano = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ExponentialHistogramDataPoint "timeUnixNano" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ExponentialHistogramDataPoint'timeUnixNano
           (\ x__ y__
              -> x__ {_ExponentialHistogramDataPoint'timeUnixNano = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ExponentialHistogramDataPoint "count" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ExponentialHistogramDataPoint'count
           (\ x__ y__ -> x__ {_ExponentialHistogramDataPoint'count = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ExponentialHistogramDataPoint "sum" Prelude.Double where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ExponentialHistogramDataPoint'sum
           (\ x__ y__ -> x__ {_ExponentialHistogramDataPoint'sum = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ExponentialHistogramDataPoint "scale" Data.Int.Int32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ExponentialHistogramDataPoint'scale
           (\ x__ y__ -> x__ {_ExponentialHistogramDataPoint'scale = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ExponentialHistogramDataPoint "zeroCount" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ExponentialHistogramDataPoint'zeroCount
           (\ x__ y__
              -> x__ {_ExponentialHistogramDataPoint'zeroCount = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ExponentialHistogramDataPoint "positive" ExponentialHistogramDataPoint'Buckets where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ExponentialHistogramDataPoint'positive
           (\ x__ y__ -> x__ {_ExponentialHistogramDataPoint'positive = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField ExponentialHistogramDataPoint "maybe'positive" (Prelude.Maybe ExponentialHistogramDataPoint'Buckets) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ExponentialHistogramDataPoint'positive
           (\ x__ y__ -> x__ {_ExponentialHistogramDataPoint'positive = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ExponentialHistogramDataPoint "negative" ExponentialHistogramDataPoint'Buckets where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ExponentialHistogramDataPoint'negative
           (\ x__ y__ -> x__ {_ExponentialHistogramDataPoint'negative = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField ExponentialHistogramDataPoint "maybe'negative" (Prelude.Maybe ExponentialHistogramDataPoint'Buckets) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ExponentialHistogramDataPoint'negative
           (\ x__ y__ -> x__ {_ExponentialHistogramDataPoint'negative = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ExponentialHistogramDataPoint "flags" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ExponentialHistogramDataPoint'flags
           (\ x__ y__ -> x__ {_ExponentialHistogramDataPoint'flags = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ExponentialHistogramDataPoint "exemplars" [Exemplar] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ExponentialHistogramDataPoint'exemplars
           (\ x__ y__
              -> x__ {_ExponentialHistogramDataPoint'exemplars = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField ExponentialHistogramDataPoint "vec'exemplars" (Data.Vector.Vector Exemplar) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ExponentialHistogramDataPoint'exemplars
           (\ x__ y__
              -> x__ {_ExponentialHistogramDataPoint'exemplars = y__}))
        Prelude.id
instance Data.ProtoLens.Message ExponentialHistogramDataPoint where
  messageName _
    = Data.Text.pack
        "opentelemetry.proto.metrics.v1.ExponentialHistogramDataPoint"
  packedMessageDescriptor _
    = "\n\
      \\GSExponentialHistogramDataPoint\DC2G\n\
      \\n\
      \attributes\CAN\SOH \ETX(\v2'.opentelemetry.proto.common.v1.KeyValueR\n\
      \attributes\DC2/\n\
      \\DC4start_time_unix_nano\CAN\STX \SOH(\ACKR\DC1startTimeUnixNano\DC2$\n\
      \\SOtime_unix_nano\CAN\ETX \SOH(\ACKR\ftimeUnixNano\DC2\DC4\n\
      \\ENQcount\CAN\EOT \SOH(\ACKR\ENQcount\DC2\DLE\n\
      \\ETXsum\CAN\ENQ \SOH(\SOHR\ETXsum\DC2\DC4\n\
      \\ENQscale\CAN\ACK \SOH(\DC1R\ENQscale\DC2\GS\n\
      \\n\
      \zero_count\CAN\a \SOH(\ACKR\tzeroCount\DC2a\n\
      \\bpositive\CAN\b \SOH(\v2E.opentelemetry.proto.metrics.v1.ExponentialHistogramDataPoint.BucketsR\bpositive\DC2a\n\
      \\bnegative\CAN\t \SOH(\v2E.opentelemetry.proto.metrics.v1.ExponentialHistogramDataPoint.BucketsR\bnegative\DC2\DC4\n\
      \\ENQflags\CAN\n\
      \ \SOH(\rR\ENQflags\DC2F\n\
      \\texemplars\CAN\v \ETX(\v2(.opentelemetry.proto.metrics.v1.ExemplarR\texemplars\SUBF\n\
      \\aBuckets\DC2\SYN\n\
      \\ACKoffset\CAN\SOH \SOH(\DC1R\ACKoffset\DC2#\n\
      \\rbucket_counts\CAN\STX \ETX(\EOTR\fbucketCounts"
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
              Data.ProtoLens.FieldDescriptor ExponentialHistogramDataPoint
        startTimeUnixNano__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "start_time_unix_nano"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Fixed64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"startTimeUnixNano")) ::
              Data.ProtoLens.FieldDescriptor ExponentialHistogramDataPoint
        timeUnixNano__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "time_unix_nano"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Fixed64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"timeUnixNano")) ::
              Data.ProtoLens.FieldDescriptor ExponentialHistogramDataPoint
        count__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "count"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Fixed64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"count")) ::
              Data.ProtoLens.FieldDescriptor ExponentialHistogramDataPoint
        sum__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "sum"
              (Data.ProtoLens.ScalarField Data.ProtoLens.DoubleField ::
                 Data.ProtoLens.FieldTypeDescriptor Prelude.Double)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"sum")) ::
              Data.ProtoLens.FieldDescriptor ExponentialHistogramDataPoint
        scale__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "scale"
              (Data.ProtoLens.ScalarField Data.ProtoLens.SInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"scale")) ::
              Data.ProtoLens.FieldDescriptor ExponentialHistogramDataPoint
        zeroCount__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "zero_count"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Fixed64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"zeroCount")) ::
              Data.ProtoLens.FieldDescriptor ExponentialHistogramDataPoint
        positive__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "positive"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor ExponentialHistogramDataPoint'Buckets)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'positive")) ::
              Data.ProtoLens.FieldDescriptor ExponentialHistogramDataPoint
        negative__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "negative"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor ExponentialHistogramDataPoint'Buckets)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'negative")) ::
              Data.ProtoLens.FieldDescriptor ExponentialHistogramDataPoint
        flags__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "flags"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"flags")) ::
              Data.ProtoLens.FieldDescriptor ExponentialHistogramDataPoint
        exemplars__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "exemplars"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Exemplar)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"exemplars")) ::
              Data.ProtoLens.FieldDescriptor ExponentialHistogramDataPoint
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, attributes__field_descriptor),
           (Data.ProtoLens.Tag 2, startTimeUnixNano__field_descriptor),
           (Data.ProtoLens.Tag 3, timeUnixNano__field_descriptor),
           (Data.ProtoLens.Tag 4, count__field_descriptor),
           (Data.ProtoLens.Tag 5, sum__field_descriptor),
           (Data.ProtoLens.Tag 6, scale__field_descriptor),
           (Data.ProtoLens.Tag 7, zeroCount__field_descriptor),
           (Data.ProtoLens.Tag 8, positive__field_descriptor),
           (Data.ProtoLens.Tag 9, negative__field_descriptor),
           (Data.ProtoLens.Tag 10, flags__field_descriptor),
           (Data.ProtoLens.Tag 11, exemplars__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _ExponentialHistogramDataPoint'_unknownFields
        (\ x__ y__
           -> x__ {_ExponentialHistogramDataPoint'_unknownFields = y__})
  defMessage
    = ExponentialHistogramDataPoint'_constructor
        {_ExponentialHistogramDataPoint'attributes = Data.Vector.Generic.empty,
         _ExponentialHistogramDataPoint'startTimeUnixNano = Data.ProtoLens.fieldDefault,
         _ExponentialHistogramDataPoint'timeUnixNano = Data.ProtoLens.fieldDefault,
         _ExponentialHistogramDataPoint'count = Data.ProtoLens.fieldDefault,
         _ExponentialHistogramDataPoint'sum = Data.ProtoLens.fieldDefault,
         _ExponentialHistogramDataPoint'scale = Data.ProtoLens.fieldDefault,
         _ExponentialHistogramDataPoint'zeroCount = Data.ProtoLens.fieldDefault,
         _ExponentialHistogramDataPoint'positive = Prelude.Nothing,
         _ExponentialHistogramDataPoint'negative = Prelude.Nothing,
         _ExponentialHistogramDataPoint'flags = Data.ProtoLens.fieldDefault,
         _ExponentialHistogramDataPoint'exemplars = Data.Vector.Generic.empty,
         _ExponentialHistogramDataPoint'_unknownFields = []}
  parseMessage
    = let
        loop ::
          ExponentialHistogramDataPoint
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue
             -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Exemplar
                -> Data.ProtoLens.Encoding.Bytes.Parser ExponentialHistogramDataPoint
        loop x mutable'attributes mutable'exemplars
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'attributes <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                             (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                mutable'attributes)
                      frozen'exemplars <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                            (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                               mutable'exemplars)
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
                                 (Data.ProtoLens.Field.field @"vec'exemplars") frozen'exemplars x)))
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
                                loop x v mutable'exemplars
                        17
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getFixed64
                                       "start_time_unix_nano"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"startTimeUnixNano") y x)
                                  mutable'attributes mutable'exemplars
                        25
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getFixed64 "time_unix_nano"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"timeUnixNano") y x)
                                  mutable'attributes mutable'exemplars
                        33
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getFixed64 "count"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"count") y x)
                                  mutable'attributes mutable'exemplars
                        41
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Data.ProtoLens.Encoding.Bytes.wordToDouble
                                          Data.ProtoLens.Encoding.Bytes.getFixed64)
                                       "sum"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"sum") y x)
                                  mutable'attributes mutable'exemplars
                        48
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Data.ProtoLens.Encoding.Bytes.wordToSignedInt32
                                          (Prelude.fmap
                                             Prelude.fromIntegral
                                             Data.ProtoLens.Encoding.Bytes.getVarInt))
                                       "scale"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"scale") y x)
                                  mutable'attributes mutable'exemplars
                        57
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getFixed64 "zero_count"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"zeroCount") y x)
                                  mutable'attributes mutable'exemplars
                        66
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "positive"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"positive") y x)
                                  mutable'attributes mutable'exemplars
                        74
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "negative"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"negative") y x)
                                  mutable'attributes mutable'exemplars
                        80
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "flags"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"flags") y x)
                                  mutable'attributes mutable'exemplars
                        90
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "exemplars"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'exemplars y)
                                loop x mutable'attributes v
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'attributes mutable'exemplars
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'attributes <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                      Data.ProtoLens.Encoding.Growing.new
              mutable'exemplars <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                     Data.ProtoLens.Encoding.Growing.new
              loop
                Data.ProtoLens.defMessage mutable'attributes mutable'exemplars)
          "ExponentialHistogramDataPoint"
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
                         (Data.ProtoLens.Field.field @"startTimeUnixNano") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 17)
                         (Data.ProtoLens.Encoding.Bytes.putFixed64 _v))
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
                         _v = Lens.Family2.view (Data.ProtoLens.Field.field @"count") _x
                       in
                         if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                             Data.Monoid.mempty
                         else
                             (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt 33)
                               (Data.ProtoLens.Encoding.Bytes.putFixed64 _v))
                      ((Data.Monoid.<>)
                         (let _v = Lens.Family2.view (Data.ProtoLens.Field.field @"sum") _x
                          in
                            if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                Data.Monoid.mempty
                            else
                                (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt 41)
                                  ((Prelude..)
                                     Data.ProtoLens.Encoding.Bytes.putFixed64
                                     Data.ProtoLens.Encoding.Bytes.doubleToWord _v))
                         ((Data.Monoid.<>)
                            (let
                               _v = Lens.Family2.view (Data.ProtoLens.Field.field @"scale") _x
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
                                        Data.ProtoLens.Encoding.Bytes.signedInt32ToWord _v))
                            ((Data.Monoid.<>)
                               (let
                                  _v
                                    = Lens.Family2.view (Data.ProtoLens.Field.field @"zeroCount") _x
                                in
                                  if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                      Data.Monoid.mempty
                                  else
                                      (Data.Monoid.<>)
                                        (Data.ProtoLens.Encoding.Bytes.putVarInt 57)
                                        (Data.ProtoLens.Encoding.Bytes.putFixed64 _v))
                               ((Data.Monoid.<>)
                                  (case
                                       Lens.Family2.view
                                         (Data.ProtoLens.Field.field @"maybe'positive") _x
                                   of
                                     Prelude.Nothing -> Data.Monoid.mempty
                                     (Prelude.Just _v)
                                       -> (Data.Monoid.<>)
                                            (Data.ProtoLens.Encoding.Bytes.putVarInt 66)
                                            ((Prelude..)
                                               (\ bs
                                                  -> (Data.Monoid.<>)
                                                       (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                          (Prelude.fromIntegral
                                                             (Data.ByteString.length bs)))
                                                       (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                               Data.ProtoLens.encodeMessage _v))
                                  ((Data.Monoid.<>)
                                     (case
                                          Lens.Family2.view
                                            (Data.ProtoLens.Field.field @"maybe'negative") _x
                                      of
                                        Prelude.Nothing -> Data.Monoid.mempty
                                        (Prelude.Just _v)
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
                                     ((Data.Monoid.<>)
                                        (let
                                           _v
                                             = Lens.Family2.view
                                                 (Data.ProtoLens.Field.field @"flags") _x
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
                                                 (Data.ProtoLens.Field.field @"vec'exemplars") _x))
                                           (Data.ProtoLens.Encoding.Wire.buildFieldSet
                                              (Lens.Family2.view
                                                 Data.ProtoLens.unknownFields _x))))))))))))
instance Control.DeepSeq.NFData ExponentialHistogramDataPoint where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_ExponentialHistogramDataPoint'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_ExponentialHistogramDataPoint'attributes x__)
                (Control.DeepSeq.deepseq
                   (_ExponentialHistogramDataPoint'startTimeUnixNano x__)
                   (Control.DeepSeq.deepseq
                      (_ExponentialHistogramDataPoint'timeUnixNano x__)
                      (Control.DeepSeq.deepseq
                         (_ExponentialHistogramDataPoint'count x__)
                         (Control.DeepSeq.deepseq
                            (_ExponentialHistogramDataPoint'sum x__)
                            (Control.DeepSeq.deepseq
                               (_ExponentialHistogramDataPoint'scale x__)
                               (Control.DeepSeq.deepseq
                                  (_ExponentialHistogramDataPoint'zeroCount x__)
                                  (Control.DeepSeq.deepseq
                                     (_ExponentialHistogramDataPoint'positive x__)
                                     (Control.DeepSeq.deepseq
                                        (_ExponentialHistogramDataPoint'negative x__)
                                        (Control.DeepSeq.deepseq
                                           (_ExponentialHistogramDataPoint'flags x__)
                                           (Control.DeepSeq.deepseq
                                              (_ExponentialHistogramDataPoint'exemplars x__)
                                              ())))))))))))
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.offset' @:: Lens' ExponentialHistogramDataPoint'Buckets Data.Int.Int32@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.bucketCounts' @:: Lens' ExponentialHistogramDataPoint'Buckets [Data.Word.Word64]@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.vec'bucketCounts' @:: Lens' ExponentialHistogramDataPoint'Buckets (Data.Vector.Unboxed.Vector Data.Word.Word64)@ -}
data ExponentialHistogramDataPoint'Buckets
  = ExponentialHistogramDataPoint'Buckets'_constructor {_ExponentialHistogramDataPoint'Buckets'offset :: !Data.Int.Int32,
                                                        _ExponentialHistogramDataPoint'Buckets'bucketCounts :: !(Data.Vector.Unboxed.Vector Data.Word.Word64),
                                                        _ExponentialHistogramDataPoint'Buckets'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show ExponentialHistogramDataPoint'Buckets where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField ExponentialHistogramDataPoint'Buckets "offset" Data.Int.Int32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ExponentialHistogramDataPoint'Buckets'offset
           (\ x__ y__
              -> x__ {_ExponentialHistogramDataPoint'Buckets'offset = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ExponentialHistogramDataPoint'Buckets "bucketCounts" [Data.Word.Word64] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ExponentialHistogramDataPoint'Buckets'bucketCounts
           (\ x__ y__
              -> x__
                   {_ExponentialHistogramDataPoint'Buckets'bucketCounts = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField ExponentialHistogramDataPoint'Buckets "vec'bucketCounts" (Data.Vector.Unboxed.Vector Data.Word.Word64) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ExponentialHistogramDataPoint'Buckets'bucketCounts
           (\ x__ y__
              -> x__
                   {_ExponentialHistogramDataPoint'Buckets'bucketCounts = y__}))
        Prelude.id
instance Data.ProtoLens.Message ExponentialHistogramDataPoint'Buckets where
  messageName _
    = Data.Text.pack
        "opentelemetry.proto.metrics.v1.ExponentialHistogramDataPoint.Buckets"
  packedMessageDescriptor _
    = "\n\
      \\aBuckets\DC2\SYN\n\
      \\ACKoffset\CAN\SOH \SOH(\DC1R\ACKoffset\DC2#\n\
      \\rbucket_counts\CAN\STX \ETX(\EOTR\fbucketCounts"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        offset__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "offset"
              (Data.ProtoLens.ScalarField Data.ProtoLens.SInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"offset")) ::
              Data.ProtoLens.FieldDescriptor ExponentialHistogramDataPoint'Buckets
        bucketCounts__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "bucket_counts"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Packed
                 (Data.ProtoLens.Field.field @"bucketCounts")) ::
              Data.ProtoLens.FieldDescriptor ExponentialHistogramDataPoint'Buckets
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, offset__field_descriptor),
           (Data.ProtoLens.Tag 2, bucketCounts__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _ExponentialHistogramDataPoint'Buckets'_unknownFields
        (\ x__ y__
           -> x__
                {_ExponentialHistogramDataPoint'Buckets'_unknownFields = y__})
  defMessage
    = ExponentialHistogramDataPoint'Buckets'_constructor
        {_ExponentialHistogramDataPoint'Buckets'offset = Data.ProtoLens.fieldDefault,
         _ExponentialHistogramDataPoint'Buckets'bucketCounts = Data.Vector.Generic.empty,
         _ExponentialHistogramDataPoint'Buckets'_unknownFields = []}
  parseMessage
    = let
        loop ::
          ExponentialHistogramDataPoint'Buckets
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Unboxed.Vector Data.ProtoLens.Encoding.Growing.RealWorld Data.Word.Word64
             -> Data.ProtoLens.Encoding.Bytes.Parser ExponentialHistogramDataPoint'Buckets
        loop x mutable'bucketCounts
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'bucketCounts <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                               (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                  mutable'bucketCounts)
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
                              (Data.ProtoLens.Field.field @"vec'bucketCounts")
                              frozen'bucketCounts x))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        8 -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Data.ProtoLens.Encoding.Bytes.wordToSignedInt32
                                          (Prelude.fmap
                                             Prelude.fromIntegral
                                             Data.ProtoLens.Encoding.Bytes.getVarInt))
                                       "offset"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"offset") y x)
                                  mutable'bucketCounts
                        16
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        Data.ProtoLens.Encoding.Bytes.getVarInt "bucket_counts"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append
                                          mutable'bucketCounts y)
                                loop x v
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
                                                                    Data.ProtoLens.Encoding.Bytes.getVarInt
                                                                    "bucket_counts"
                                                            qs' <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                                     (Data.ProtoLens.Encoding.Growing.append
                                                                        qs q)
                                                            ploop qs'
                                            in ploop)
                                             mutable'bucketCounts)
                                loop x y
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'bucketCounts
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'bucketCounts <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                        Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'bucketCounts)
          "Buckets"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v = Lens.Family2.view (Data.ProtoLens.Field.field @"offset") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 8)
                      ((Prelude..)
                         ((Prelude..)
                            Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral)
                         Data.ProtoLens.Encoding.Bytes.signedInt32ToWord _v))
             ((Data.Monoid.<>)
                (let
                   p = Lens.Family2.view
                         (Data.ProtoLens.Field.field @"vec'bucketCounts") _x
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
                                  Data.ProtoLens.Encoding.Bytes.putVarInt p))))
                (Data.ProtoLens.Encoding.Wire.buildFieldSet
                   (Lens.Family2.view Data.ProtoLens.unknownFields _x)))
instance Control.DeepSeq.NFData ExponentialHistogramDataPoint'Buckets where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_ExponentialHistogramDataPoint'Buckets'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_ExponentialHistogramDataPoint'Buckets'offset x__)
                (Control.DeepSeq.deepseq
                   (_ExponentialHistogramDataPoint'Buckets'bucketCounts x__) ()))
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.dataPoints' @:: Lens' Gauge [NumberDataPoint]@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.vec'dataPoints' @:: Lens' Gauge (Data.Vector.Vector NumberDataPoint)@ -}
data Gauge
  = Gauge'_constructor {_Gauge'dataPoints :: !(Data.Vector.Vector NumberDataPoint),
                        _Gauge'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show Gauge where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField Gauge "dataPoints" [NumberDataPoint] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Gauge'dataPoints (\ x__ y__ -> x__ {_Gauge'dataPoints = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField Gauge "vec'dataPoints" (Data.Vector.Vector NumberDataPoint) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Gauge'dataPoints (\ x__ y__ -> x__ {_Gauge'dataPoints = y__}))
        Prelude.id
instance Data.ProtoLens.Message Gauge where
  messageName _
    = Data.Text.pack "opentelemetry.proto.metrics.v1.Gauge"
  packedMessageDescriptor _
    = "\n\
      \\ENQGauge\DC2P\n\
      \\vdata_points\CAN\SOH \ETX(\v2/.opentelemetry.proto.metrics.v1.NumberDataPointR\n\
      \dataPoints"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        dataPoints__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "data_points"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor NumberDataPoint)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"dataPoints")) ::
              Data.ProtoLens.FieldDescriptor Gauge
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, dataPoints__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Gauge'_unknownFields
        (\ x__ y__ -> x__ {_Gauge'_unknownFields = y__})
  defMessage
    = Gauge'_constructor
        {_Gauge'dataPoints = Data.Vector.Generic.empty,
         _Gauge'_unknownFields = []}
  parseMessage
    = let
        loop ::
          Gauge
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld NumberDataPoint
             -> Data.ProtoLens.Encoding.Bytes.Parser Gauge
        loop x mutable'dataPoints
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'dataPoints <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                             (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                mutable'dataPoints)
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
                              (Data.ProtoLens.Field.field @"vec'dataPoints") frozen'dataPoints
                              x))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "data_points"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'dataPoints y)
                                loop x v
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'dataPoints
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'dataPoints <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                      Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'dataPoints)
          "Gauge"
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
                   (Data.ProtoLens.Field.field @"vec'dataPoints") _x))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData Gauge where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Gauge'_unknownFields x__)
             (Control.DeepSeq.deepseq (_Gauge'dataPoints x__) ())
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.dataPoints' @:: Lens' Histogram [HistogramDataPoint]@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.vec'dataPoints' @:: Lens' Histogram (Data.Vector.Vector HistogramDataPoint)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.aggregationTemporality' @:: Lens' Histogram AggregationTemporality@ -}
data Histogram
  = Histogram'_constructor {_Histogram'dataPoints :: !(Data.Vector.Vector HistogramDataPoint),
                            _Histogram'aggregationTemporality :: !AggregationTemporality,
                            _Histogram'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show Histogram where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField Histogram "dataPoints" [HistogramDataPoint] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Histogram'dataPoints
           (\ x__ y__ -> x__ {_Histogram'dataPoints = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField Histogram "vec'dataPoints" (Data.Vector.Vector HistogramDataPoint) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Histogram'dataPoints
           (\ x__ y__ -> x__ {_Histogram'dataPoints = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Histogram "aggregationTemporality" AggregationTemporality where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Histogram'aggregationTemporality
           (\ x__ y__ -> x__ {_Histogram'aggregationTemporality = y__}))
        Prelude.id
instance Data.ProtoLens.Message Histogram where
  messageName _
    = Data.Text.pack "opentelemetry.proto.metrics.v1.Histogram"
  packedMessageDescriptor _
    = "\n\
      \\tHistogram\DC2S\n\
      \\vdata_points\CAN\SOH \ETX(\v22.opentelemetry.proto.metrics.v1.HistogramDataPointR\n\
      \dataPoints\DC2o\n\
      \\ETBaggregation_temporality\CAN\STX \SOH(\SO26.opentelemetry.proto.metrics.v1.AggregationTemporalityR\SYNaggregationTemporality"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        dataPoints__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "data_points"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor HistogramDataPoint)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"dataPoints")) ::
              Data.ProtoLens.FieldDescriptor Histogram
        aggregationTemporality__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "aggregation_temporality"
              (Data.ProtoLens.ScalarField Data.ProtoLens.EnumField ::
                 Data.ProtoLens.FieldTypeDescriptor AggregationTemporality)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"aggregationTemporality")) ::
              Data.ProtoLens.FieldDescriptor Histogram
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, dataPoints__field_descriptor),
           (Data.ProtoLens.Tag 2, aggregationTemporality__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Histogram'_unknownFields
        (\ x__ y__ -> x__ {_Histogram'_unknownFields = y__})
  defMessage
    = Histogram'_constructor
        {_Histogram'dataPoints = Data.Vector.Generic.empty,
         _Histogram'aggregationTemporality = Data.ProtoLens.fieldDefault,
         _Histogram'_unknownFields = []}
  parseMessage
    = let
        loop ::
          Histogram
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld HistogramDataPoint
             -> Data.ProtoLens.Encoding.Bytes.Parser Histogram
        loop x mutable'dataPoints
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'dataPoints <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                             (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                mutable'dataPoints)
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
                              (Data.ProtoLens.Field.field @"vec'dataPoints") frozen'dataPoints
                              x))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "data_points"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'dataPoints y)
                                loop x v
                        16
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
                                  mutable'dataPoints
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'dataPoints
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'dataPoints <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                      Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'dataPoints)
          "Histogram"
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
                   (Data.ProtoLens.Field.field @"vec'dataPoints") _x))
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
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                         ((Prelude..)
                            ((Prelude..)
                               Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral)
                            Prelude.fromEnum _v))
                (Data.ProtoLens.Encoding.Wire.buildFieldSet
                   (Lens.Family2.view Data.ProtoLens.unknownFields _x)))
instance Control.DeepSeq.NFData Histogram where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Histogram'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_Histogram'dataPoints x__)
                (Control.DeepSeq.deepseq
                   (_Histogram'aggregationTemporality x__) ()))
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.attributes' @:: Lens' HistogramDataPoint [Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue]@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.vec'attributes' @:: Lens' HistogramDataPoint (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.labels' @:: Lens' HistogramDataPoint [Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue]@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.vec'labels' @:: Lens' HistogramDataPoint (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.startTimeUnixNano' @:: Lens' HistogramDataPoint Data.Word.Word64@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.timeUnixNano' @:: Lens' HistogramDataPoint Data.Word.Word64@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.count' @:: Lens' HistogramDataPoint Data.Word.Word64@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.sum' @:: Lens' HistogramDataPoint Prelude.Double@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.bucketCounts' @:: Lens' HistogramDataPoint [Data.Word.Word64]@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.vec'bucketCounts' @:: Lens' HistogramDataPoint (Data.Vector.Unboxed.Vector Data.Word.Word64)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.explicitBounds' @:: Lens' HistogramDataPoint [Prelude.Double]@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.vec'explicitBounds' @:: Lens' HistogramDataPoint (Data.Vector.Unboxed.Vector Prelude.Double)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.exemplars' @:: Lens' HistogramDataPoint [Exemplar]@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.vec'exemplars' @:: Lens' HistogramDataPoint (Data.Vector.Vector Exemplar)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.flags' @:: Lens' HistogramDataPoint Data.Word.Word32@ -}
data HistogramDataPoint
  = HistogramDataPoint'_constructor {_HistogramDataPoint'attributes :: !(Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue),
                                     _HistogramDataPoint'labels :: !(Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue),
                                     _HistogramDataPoint'startTimeUnixNano :: !Data.Word.Word64,
                                     _HistogramDataPoint'timeUnixNano :: !Data.Word.Word64,
                                     _HistogramDataPoint'count :: !Data.Word.Word64,
                                     _HistogramDataPoint'sum :: !Prelude.Double,
                                     _HistogramDataPoint'bucketCounts :: !(Data.Vector.Unboxed.Vector Data.Word.Word64),
                                     _HistogramDataPoint'explicitBounds :: !(Data.Vector.Unboxed.Vector Prelude.Double),
                                     _HistogramDataPoint'exemplars :: !(Data.Vector.Vector Exemplar),
                                     _HistogramDataPoint'flags :: !Data.Word.Word32,
                                     _HistogramDataPoint'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show HistogramDataPoint where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField HistogramDataPoint "attributes" [Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _HistogramDataPoint'attributes
           (\ x__ y__ -> x__ {_HistogramDataPoint'attributes = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField HistogramDataPoint "vec'attributes" (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _HistogramDataPoint'attributes
           (\ x__ y__ -> x__ {_HistogramDataPoint'attributes = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField HistogramDataPoint "labels" [Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _HistogramDataPoint'labels
           (\ x__ y__ -> x__ {_HistogramDataPoint'labels = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField HistogramDataPoint "vec'labels" (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _HistogramDataPoint'labels
           (\ x__ y__ -> x__ {_HistogramDataPoint'labels = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField HistogramDataPoint "startTimeUnixNano" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _HistogramDataPoint'startTimeUnixNano
           (\ x__ y__ -> x__ {_HistogramDataPoint'startTimeUnixNano = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField HistogramDataPoint "timeUnixNano" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _HistogramDataPoint'timeUnixNano
           (\ x__ y__ -> x__ {_HistogramDataPoint'timeUnixNano = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField HistogramDataPoint "count" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _HistogramDataPoint'count
           (\ x__ y__ -> x__ {_HistogramDataPoint'count = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField HistogramDataPoint "sum" Prelude.Double where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _HistogramDataPoint'sum
           (\ x__ y__ -> x__ {_HistogramDataPoint'sum = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField HistogramDataPoint "bucketCounts" [Data.Word.Word64] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _HistogramDataPoint'bucketCounts
           (\ x__ y__ -> x__ {_HistogramDataPoint'bucketCounts = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField HistogramDataPoint "vec'bucketCounts" (Data.Vector.Unboxed.Vector Data.Word.Word64) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _HistogramDataPoint'bucketCounts
           (\ x__ y__ -> x__ {_HistogramDataPoint'bucketCounts = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField HistogramDataPoint "explicitBounds" [Prelude.Double] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _HistogramDataPoint'explicitBounds
           (\ x__ y__ -> x__ {_HistogramDataPoint'explicitBounds = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField HistogramDataPoint "vec'explicitBounds" (Data.Vector.Unboxed.Vector Prelude.Double) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _HistogramDataPoint'explicitBounds
           (\ x__ y__ -> x__ {_HistogramDataPoint'explicitBounds = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField HistogramDataPoint "exemplars" [Exemplar] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _HistogramDataPoint'exemplars
           (\ x__ y__ -> x__ {_HistogramDataPoint'exemplars = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField HistogramDataPoint "vec'exemplars" (Data.Vector.Vector Exemplar) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _HistogramDataPoint'exemplars
           (\ x__ y__ -> x__ {_HistogramDataPoint'exemplars = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField HistogramDataPoint "flags" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _HistogramDataPoint'flags
           (\ x__ y__ -> x__ {_HistogramDataPoint'flags = y__}))
        Prelude.id
instance Data.ProtoLens.Message HistogramDataPoint where
  messageName _
    = Data.Text.pack
        "opentelemetry.proto.metrics.v1.HistogramDataPoint"
  packedMessageDescriptor _
    = "\n\
      \\DC2HistogramDataPoint\DC2G\n\
      \\n\
      \attributes\CAN\t \ETX(\v2'.opentelemetry.proto.common.v1.KeyValueR\n\
      \attributes\DC2I\n\
      \\ACKlabels\CAN\SOH \ETX(\v2-.opentelemetry.proto.common.v1.StringKeyValueR\ACKlabelsB\STX\CAN\SOH\DC2/\n\
      \\DC4start_time_unix_nano\CAN\STX \SOH(\ACKR\DC1startTimeUnixNano\DC2$\n\
      \\SOtime_unix_nano\CAN\ETX \SOH(\ACKR\ftimeUnixNano\DC2\DC4\n\
      \\ENQcount\CAN\EOT \SOH(\ACKR\ENQcount\DC2\DLE\n\
      \\ETXsum\CAN\ENQ \SOH(\SOHR\ETXsum\DC2#\n\
      \\rbucket_counts\CAN\ACK \ETX(\ACKR\fbucketCounts\DC2'\n\
      \\SIexplicit_bounds\CAN\a \ETX(\SOHR\SOexplicitBounds\DC2F\n\
      \\texemplars\CAN\b \ETX(\v2(.opentelemetry.proto.metrics.v1.ExemplarR\texemplars\DC2\DC4\n\
      \\ENQflags\CAN\n\
      \ \SOH(\rR\ENQflags"
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
              Data.ProtoLens.FieldDescriptor HistogramDataPoint
        labels__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "labels"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked (Data.ProtoLens.Field.field @"labels")) ::
              Data.ProtoLens.FieldDescriptor HistogramDataPoint
        startTimeUnixNano__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "start_time_unix_nano"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Fixed64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"startTimeUnixNano")) ::
              Data.ProtoLens.FieldDescriptor HistogramDataPoint
        timeUnixNano__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "time_unix_nano"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Fixed64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"timeUnixNano")) ::
              Data.ProtoLens.FieldDescriptor HistogramDataPoint
        count__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "count"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Fixed64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"count")) ::
              Data.ProtoLens.FieldDescriptor HistogramDataPoint
        sum__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "sum"
              (Data.ProtoLens.ScalarField Data.ProtoLens.DoubleField ::
                 Data.ProtoLens.FieldTypeDescriptor Prelude.Double)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"sum")) ::
              Data.ProtoLens.FieldDescriptor HistogramDataPoint
        bucketCounts__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "bucket_counts"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Fixed64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Packed
                 (Data.ProtoLens.Field.field @"bucketCounts")) ::
              Data.ProtoLens.FieldDescriptor HistogramDataPoint
        explicitBounds__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "explicit_bounds"
              (Data.ProtoLens.ScalarField Data.ProtoLens.DoubleField ::
                 Data.ProtoLens.FieldTypeDescriptor Prelude.Double)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Packed
                 (Data.ProtoLens.Field.field @"explicitBounds")) ::
              Data.ProtoLens.FieldDescriptor HistogramDataPoint
        exemplars__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "exemplars"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Exemplar)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"exemplars")) ::
              Data.ProtoLens.FieldDescriptor HistogramDataPoint
        flags__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "flags"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"flags")) ::
              Data.ProtoLens.FieldDescriptor HistogramDataPoint
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 9, attributes__field_descriptor),
           (Data.ProtoLens.Tag 1, labels__field_descriptor),
           (Data.ProtoLens.Tag 2, startTimeUnixNano__field_descriptor),
           (Data.ProtoLens.Tag 3, timeUnixNano__field_descriptor),
           (Data.ProtoLens.Tag 4, count__field_descriptor),
           (Data.ProtoLens.Tag 5, sum__field_descriptor),
           (Data.ProtoLens.Tag 6, bucketCounts__field_descriptor),
           (Data.ProtoLens.Tag 7, explicitBounds__field_descriptor),
           (Data.ProtoLens.Tag 8, exemplars__field_descriptor),
           (Data.ProtoLens.Tag 10, flags__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _HistogramDataPoint'_unknownFields
        (\ x__ y__ -> x__ {_HistogramDataPoint'_unknownFields = y__})
  defMessage
    = HistogramDataPoint'_constructor
        {_HistogramDataPoint'attributes = Data.Vector.Generic.empty,
         _HistogramDataPoint'labels = Data.Vector.Generic.empty,
         _HistogramDataPoint'startTimeUnixNano = Data.ProtoLens.fieldDefault,
         _HistogramDataPoint'timeUnixNano = Data.ProtoLens.fieldDefault,
         _HistogramDataPoint'count = Data.ProtoLens.fieldDefault,
         _HistogramDataPoint'sum = Data.ProtoLens.fieldDefault,
         _HistogramDataPoint'bucketCounts = Data.Vector.Generic.empty,
         _HistogramDataPoint'explicitBounds = Data.Vector.Generic.empty,
         _HistogramDataPoint'exemplars = Data.Vector.Generic.empty,
         _HistogramDataPoint'flags = Data.ProtoLens.fieldDefault,
         _HistogramDataPoint'_unknownFields = []}
  parseMessage
    = let
        loop ::
          HistogramDataPoint
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue
             -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Unboxed.Vector Data.ProtoLens.Encoding.Growing.RealWorld Data.Word.Word64
                -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Exemplar
                   -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Unboxed.Vector Data.ProtoLens.Encoding.Growing.RealWorld Prelude.Double
                      -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue
                         -> Data.ProtoLens.Encoding.Bytes.Parser HistogramDataPoint
        loop
          x
          mutable'attributes
          mutable'bucketCounts
          mutable'exemplars
          mutable'explicitBounds
          mutable'labels
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'attributes <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                             (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                mutable'attributes)
                      frozen'bucketCounts <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                               (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                  mutable'bucketCounts)
                      frozen'exemplars <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                            (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                               mutable'exemplars)
                      frozen'explicitBounds <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                 (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                    mutable'explicitBounds)
                      frozen'labels <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                         (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                            mutable'labels)
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
                                 (Data.ProtoLens.Field.field @"vec'bucketCounts")
                                 frozen'bucketCounts
                                 (Lens.Family2.set
                                    (Data.ProtoLens.Field.field @"vec'exemplars") frozen'exemplars
                                    (Lens.Family2.set
                                       (Data.ProtoLens.Field.field @"vec'explicitBounds")
                                       frozen'explicitBounds
                                       (Lens.Family2.set
                                          (Data.ProtoLens.Field.field @"vec'labels") frozen'labels
                                          x))))))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        74
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "attributes"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'attributes y)
                                loop
                                  x v mutable'bucketCounts mutable'exemplars mutable'explicitBounds
                                  mutable'labels
                        10
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "labels"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'labels y)
                                loop
                                  x mutable'attributes mutable'bucketCounts mutable'exemplars
                                  mutable'explicitBounds v
                        17
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getFixed64
                                       "start_time_unix_nano"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"startTimeUnixNano") y x)
                                  mutable'attributes mutable'bucketCounts mutable'exemplars
                                  mutable'explicitBounds mutable'labels
                        25
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getFixed64 "time_unix_nano"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"timeUnixNano") y x)
                                  mutable'attributes mutable'bucketCounts mutable'exemplars
                                  mutable'explicitBounds mutable'labels
                        33
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getFixed64 "count"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"count") y x)
                                  mutable'attributes mutable'bucketCounts mutable'exemplars
                                  mutable'explicitBounds mutable'labels
                        41
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Data.ProtoLens.Encoding.Bytes.wordToDouble
                                          Data.ProtoLens.Encoding.Bytes.getFixed64)
                                       "sum"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"sum") y x)
                                  mutable'attributes mutable'bucketCounts mutable'exemplars
                                  mutable'explicitBounds mutable'labels
                        49
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        Data.ProtoLens.Encoding.Bytes.getFixed64 "bucket_counts"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append
                                          mutable'bucketCounts y)
                                loop
                                  x mutable'attributes v mutable'exemplars mutable'explicitBounds
                                  mutable'labels
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
                                                                    Data.ProtoLens.Encoding.Bytes.getFixed64
                                                                    "bucket_counts"
                                                            qs' <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                                     (Data.ProtoLens.Encoding.Growing.append
                                                                        qs q)
                                                            ploop qs'
                                            in ploop)
                                             mutable'bucketCounts)
                                loop
                                  x mutable'attributes y mutable'exemplars mutable'explicitBounds
                                  mutable'labels
                        57
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (Prelude.fmap
                                           Data.ProtoLens.Encoding.Bytes.wordToDouble
                                           Data.ProtoLens.Encoding.Bytes.getFixed64)
                                        "explicit_bounds"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append
                                          mutable'explicitBounds y)
                                loop
                                  x mutable'attributes mutable'bucketCounts mutable'exemplars v
                                  mutable'labels
                        58
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
                                                                       Data.ProtoLens.Encoding.Bytes.wordToDouble
                                                                       Data.ProtoLens.Encoding.Bytes.getFixed64)
                                                                    "explicit_bounds"
                                                            qs' <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                                     (Data.ProtoLens.Encoding.Growing.append
                                                                        qs q)
                                                            ploop qs'
                                            in ploop)
                                             mutable'explicitBounds)
                                loop
                                  x mutable'attributes mutable'bucketCounts mutable'exemplars y
                                  mutable'labels
                        66
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "exemplars"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'exemplars y)
                                loop
                                  x mutable'attributes mutable'bucketCounts v mutable'explicitBounds
                                  mutable'labels
                        80
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "flags"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"flags") y x)
                                  mutable'attributes mutable'bucketCounts mutable'exemplars
                                  mutable'explicitBounds mutable'labels
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'attributes mutable'bucketCounts mutable'exemplars
                                  mutable'explicitBounds mutable'labels
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'attributes <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                      Data.ProtoLens.Encoding.Growing.new
              mutable'bucketCounts <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                        Data.ProtoLens.Encoding.Growing.new
              mutable'exemplars <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                     Data.ProtoLens.Encoding.Growing.new
              mutable'explicitBounds <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                          Data.ProtoLens.Encoding.Growing.new
              mutable'labels <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                  Data.ProtoLens.Encoding.Growing.new
              loop
                Data.ProtoLens.defMessage mutable'attributes mutable'bucketCounts
                mutable'exemplars mutable'explicitBounds mutable'labels)
          "HistogramDataPoint"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                (\ _v
                   -> (Data.Monoid.<>)
                        (Data.ProtoLens.Encoding.Bytes.putVarInt 74)
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
                   (Lens.Family2.view (Data.ProtoLens.Field.field @"vec'labels") _x))
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
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 17)
                            (Data.ProtoLens.Encoding.Bytes.putFixed64 _v))
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
                            _v = Lens.Family2.view (Data.ProtoLens.Field.field @"count") _x
                          in
                            if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                Data.Monoid.mempty
                            else
                                (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt 33)
                                  (Data.ProtoLens.Encoding.Bytes.putFixed64 _v))
                         ((Data.Monoid.<>)
                            (let _v = Lens.Family2.view (Data.ProtoLens.Field.field @"sum") _x
                             in
                               if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                   Data.Monoid.mempty
                               else
                                   (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt 41)
                                     ((Prelude..)
                                        Data.ProtoLens.Encoding.Bytes.putFixed64
                                        Data.ProtoLens.Encoding.Bytes.doubleToWord _v))
                            ((Data.Monoid.<>)
                               (let
                                  p = Lens.Family2.view
                                        (Data.ProtoLens.Field.field @"vec'bucketCounts") _x
                                in
                                  if Data.Vector.Generic.null p then
                                      Data.Monoid.mempty
                                  else
                                      (Data.Monoid.<>)
                                        (Data.ProtoLens.Encoding.Bytes.putVarInt 50)
                                        ((\ bs
                                            -> (Data.Monoid.<>)
                                                 (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                    (Prelude.fromIntegral
                                                       (Data.ByteString.length bs)))
                                                 (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                           (Data.ProtoLens.Encoding.Bytes.runBuilder
                                              (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                                                 Data.ProtoLens.Encoding.Bytes.putFixed64 p))))
                               ((Data.Monoid.<>)
                                  (let
                                     p = Lens.Family2.view
                                           (Data.ProtoLens.Field.field @"vec'explicitBounds") _x
                                   in
                                     if Data.Vector.Generic.null p then
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
                                              (Data.ProtoLens.Encoding.Bytes.runBuilder
                                                 (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                                                    ((Prelude..)
                                                       Data.ProtoLens.Encoding.Bytes.putFixed64
                                                       Data.ProtoLens.Encoding.Bytes.doubleToWord)
                                                    p))))
                                  ((Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                                        (\ _v
                                           -> (Data.Monoid.<>)
                                                (Data.ProtoLens.Encoding.Bytes.putVarInt 66)
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
                                           (Data.ProtoLens.Field.field @"vec'exemplars") _x))
                                     ((Data.Monoid.<>)
                                        (let
                                           _v
                                             = Lens.Family2.view
                                                 (Data.ProtoLens.Field.field @"flags") _x
                                         in
                                           if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                               Data.Monoid.mempty
                                           else
                                               (Data.Monoid.<>)
                                                 (Data.ProtoLens.Encoding.Bytes.putVarInt 80)
                                                 ((Prelude..)
                                                    Data.ProtoLens.Encoding.Bytes.putVarInt
                                                    Prelude.fromIntegral _v))
                                        (Data.ProtoLens.Encoding.Wire.buildFieldSet
                                           (Lens.Family2.view
                                              Data.ProtoLens.unknownFields _x)))))))))))
instance Control.DeepSeq.NFData HistogramDataPoint where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_HistogramDataPoint'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_HistogramDataPoint'attributes x__)
                (Control.DeepSeq.deepseq
                   (_HistogramDataPoint'labels x__)
                   (Control.DeepSeq.deepseq
                      (_HistogramDataPoint'startTimeUnixNano x__)
                      (Control.DeepSeq.deepseq
                         (_HistogramDataPoint'timeUnixNano x__)
                         (Control.DeepSeq.deepseq
                            (_HistogramDataPoint'count x__)
                            (Control.DeepSeq.deepseq
                               (_HistogramDataPoint'sum x__)
                               (Control.DeepSeq.deepseq
                                  (_HistogramDataPoint'bucketCounts x__)
                                  (Control.DeepSeq.deepseq
                                     (_HistogramDataPoint'explicitBounds x__)
                                     (Control.DeepSeq.deepseq
                                        (_HistogramDataPoint'exemplars x__)
                                        (Control.DeepSeq.deepseq
                                           (_HistogramDataPoint'flags x__) ()))))))))))
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.instrumentationLibrary' @:: Lens' InstrumentationLibraryMetrics Proto.Opentelemetry.Proto.Common.V1.Common.InstrumentationLibrary@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.maybe'instrumentationLibrary' @:: Lens' InstrumentationLibraryMetrics (Prelude.Maybe Proto.Opentelemetry.Proto.Common.V1.Common.InstrumentationLibrary)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.metrics' @:: Lens' InstrumentationLibraryMetrics [Metric]@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.vec'metrics' @:: Lens' InstrumentationLibraryMetrics (Data.Vector.Vector Metric)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.schemaUrl' @:: Lens' InstrumentationLibraryMetrics Data.Text.Text@ -}
data InstrumentationLibraryMetrics
  = InstrumentationLibraryMetrics'_constructor {_InstrumentationLibraryMetrics'instrumentationLibrary :: !(Prelude.Maybe Proto.Opentelemetry.Proto.Common.V1.Common.InstrumentationLibrary),
                                                _InstrumentationLibraryMetrics'metrics :: !(Data.Vector.Vector Metric),
                                                _InstrumentationLibraryMetrics'schemaUrl :: !Data.Text.Text,
                                                _InstrumentationLibraryMetrics'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show InstrumentationLibraryMetrics where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField InstrumentationLibraryMetrics "instrumentationLibrary" Proto.Opentelemetry.Proto.Common.V1.Common.InstrumentationLibrary where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _InstrumentationLibraryMetrics'instrumentationLibrary
           (\ x__ y__
              -> x__
                   {_InstrumentationLibraryMetrics'instrumentationLibrary = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField InstrumentationLibraryMetrics "maybe'instrumentationLibrary" (Prelude.Maybe Proto.Opentelemetry.Proto.Common.V1.Common.InstrumentationLibrary) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _InstrumentationLibraryMetrics'instrumentationLibrary
           (\ x__ y__
              -> x__
                   {_InstrumentationLibraryMetrics'instrumentationLibrary = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField InstrumentationLibraryMetrics "metrics" [Metric] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _InstrumentationLibraryMetrics'metrics
           (\ x__ y__ -> x__ {_InstrumentationLibraryMetrics'metrics = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField InstrumentationLibraryMetrics "vec'metrics" (Data.Vector.Vector Metric) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _InstrumentationLibraryMetrics'metrics
           (\ x__ y__ -> x__ {_InstrumentationLibraryMetrics'metrics = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField InstrumentationLibraryMetrics "schemaUrl" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _InstrumentationLibraryMetrics'schemaUrl
           (\ x__ y__
              -> x__ {_InstrumentationLibraryMetrics'schemaUrl = y__}))
        Prelude.id
instance Data.ProtoLens.Message InstrumentationLibraryMetrics where
  messageName _
    = Data.Text.pack
        "opentelemetry.proto.metrics.v1.InstrumentationLibraryMetrics"
  packedMessageDescriptor _
    = "\n\
      \\GSInstrumentationLibraryMetrics\DC2n\n\
      \\ETBinstrumentation_library\CAN\SOH \SOH(\v25.opentelemetry.proto.common.v1.InstrumentationLibraryR\SYNinstrumentationLibrary\DC2@\n\
      \\ametrics\CAN\STX \ETX(\v2&.opentelemetry.proto.metrics.v1.MetricR\ametrics\DC2\GS\n\
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
              Data.ProtoLens.FieldDescriptor InstrumentationLibraryMetrics
        metrics__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "metrics"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Metric)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked (Data.ProtoLens.Field.field @"metrics")) ::
              Data.ProtoLens.FieldDescriptor InstrumentationLibraryMetrics
        schemaUrl__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "schema_url"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"schemaUrl")) ::
              Data.ProtoLens.FieldDescriptor InstrumentationLibraryMetrics
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, instrumentationLibrary__field_descriptor),
           (Data.ProtoLens.Tag 2, metrics__field_descriptor),
           (Data.ProtoLens.Tag 3, schemaUrl__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _InstrumentationLibraryMetrics'_unknownFields
        (\ x__ y__
           -> x__ {_InstrumentationLibraryMetrics'_unknownFields = y__})
  defMessage
    = InstrumentationLibraryMetrics'_constructor
        {_InstrumentationLibraryMetrics'instrumentationLibrary = Prelude.Nothing,
         _InstrumentationLibraryMetrics'metrics = Data.Vector.Generic.empty,
         _InstrumentationLibraryMetrics'schemaUrl = Data.ProtoLens.fieldDefault,
         _InstrumentationLibraryMetrics'_unknownFields = []}
  parseMessage
    = let
        loop ::
          InstrumentationLibraryMetrics
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Metric
             -> Data.ProtoLens.Encoding.Bytes.Parser InstrumentationLibraryMetrics
        loop x mutable'metrics
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'metrics <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                          (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                             mutable'metrics)
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
                              (Data.ProtoLens.Field.field @"vec'metrics") frozen'metrics x))
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
                                  mutable'metrics
                        18
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "metrics"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'metrics y)
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
                                  mutable'metrics
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'metrics
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'metrics <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                   Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'metrics)
          "InstrumentationLibraryMetrics"
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
                   (Lens.Family2.view (Data.ProtoLens.Field.field @"vec'metrics") _x))
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
instance Control.DeepSeq.NFData InstrumentationLibraryMetrics where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_InstrumentationLibraryMetrics'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_InstrumentationLibraryMetrics'instrumentationLibrary x__)
                (Control.DeepSeq.deepseq
                   (_InstrumentationLibraryMetrics'metrics x__)
                   (Control.DeepSeq.deepseq
                      (_InstrumentationLibraryMetrics'schemaUrl x__) ())))
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.labels' @:: Lens' IntDataPoint [Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue]@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.vec'labels' @:: Lens' IntDataPoint (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.startTimeUnixNano' @:: Lens' IntDataPoint Data.Word.Word64@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.timeUnixNano' @:: Lens' IntDataPoint Data.Word.Word64@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.value' @:: Lens' IntDataPoint Data.Int.Int64@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.exemplars' @:: Lens' IntDataPoint [IntExemplar]@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.vec'exemplars' @:: Lens' IntDataPoint (Data.Vector.Vector IntExemplar)@ -}
data IntDataPoint
  = IntDataPoint'_constructor {_IntDataPoint'labels :: !(Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue),
                               _IntDataPoint'startTimeUnixNano :: !Data.Word.Word64,
                               _IntDataPoint'timeUnixNano :: !Data.Word.Word64,
                               _IntDataPoint'value :: !Data.Int.Int64,
                               _IntDataPoint'exemplars :: !(Data.Vector.Vector IntExemplar),
                               _IntDataPoint'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show IntDataPoint where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField IntDataPoint "labels" [Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _IntDataPoint'labels
           (\ x__ y__ -> x__ {_IntDataPoint'labels = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField IntDataPoint "vec'labels" (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _IntDataPoint'labels
           (\ x__ y__ -> x__ {_IntDataPoint'labels = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField IntDataPoint "startTimeUnixNano" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _IntDataPoint'startTimeUnixNano
           (\ x__ y__ -> x__ {_IntDataPoint'startTimeUnixNano = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField IntDataPoint "timeUnixNano" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _IntDataPoint'timeUnixNano
           (\ x__ y__ -> x__ {_IntDataPoint'timeUnixNano = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField IntDataPoint "value" Data.Int.Int64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _IntDataPoint'value (\ x__ y__ -> x__ {_IntDataPoint'value = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField IntDataPoint "exemplars" [IntExemplar] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _IntDataPoint'exemplars
           (\ x__ y__ -> x__ {_IntDataPoint'exemplars = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField IntDataPoint "vec'exemplars" (Data.Vector.Vector IntExemplar) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _IntDataPoint'exemplars
           (\ x__ y__ -> x__ {_IntDataPoint'exemplars = y__}))
        Prelude.id
instance Data.ProtoLens.Message IntDataPoint where
  messageName _
    = Data.Text.pack "opentelemetry.proto.metrics.v1.IntDataPoint"
  packedMessageDescriptor _
    = "\n\
      \\fIntDataPoint\DC2E\n\
      \\ACKlabels\CAN\SOH \ETX(\v2-.opentelemetry.proto.common.v1.StringKeyValueR\ACKlabels\DC2/\n\
      \\DC4start_time_unix_nano\CAN\STX \SOH(\ACKR\DC1startTimeUnixNano\DC2$\n\
      \\SOtime_unix_nano\CAN\ETX \SOH(\ACKR\ftimeUnixNano\DC2\DC4\n\
      \\ENQvalue\CAN\EOT \SOH(\DLER\ENQvalue\DC2I\n\
      \\texemplars\CAN\ENQ \ETX(\v2+.opentelemetry.proto.metrics.v1.IntExemplarR\texemplars:\STX\CAN\SOH"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        labels__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "labels"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked (Data.ProtoLens.Field.field @"labels")) ::
              Data.ProtoLens.FieldDescriptor IntDataPoint
        startTimeUnixNano__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "start_time_unix_nano"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Fixed64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"startTimeUnixNano")) ::
              Data.ProtoLens.FieldDescriptor IntDataPoint
        timeUnixNano__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "time_unix_nano"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Fixed64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"timeUnixNano")) ::
              Data.ProtoLens.FieldDescriptor IntDataPoint
        value__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "value"
              (Data.ProtoLens.ScalarField Data.ProtoLens.SFixed64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"value")) ::
              Data.ProtoLens.FieldDescriptor IntDataPoint
        exemplars__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "exemplars"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor IntExemplar)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"exemplars")) ::
              Data.ProtoLens.FieldDescriptor IntDataPoint
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, labels__field_descriptor),
           (Data.ProtoLens.Tag 2, startTimeUnixNano__field_descriptor),
           (Data.ProtoLens.Tag 3, timeUnixNano__field_descriptor),
           (Data.ProtoLens.Tag 4, value__field_descriptor),
           (Data.ProtoLens.Tag 5, exemplars__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _IntDataPoint'_unknownFields
        (\ x__ y__ -> x__ {_IntDataPoint'_unknownFields = y__})
  defMessage
    = IntDataPoint'_constructor
        {_IntDataPoint'labels = Data.Vector.Generic.empty,
         _IntDataPoint'startTimeUnixNano = Data.ProtoLens.fieldDefault,
         _IntDataPoint'timeUnixNano = Data.ProtoLens.fieldDefault,
         _IntDataPoint'value = Data.ProtoLens.fieldDefault,
         _IntDataPoint'exemplars = Data.Vector.Generic.empty,
         _IntDataPoint'_unknownFields = []}
  parseMessage
    = let
        loop ::
          IntDataPoint
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld IntExemplar
             -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue
                -> Data.ProtoLens.Encoding.Bytes.Parser IntDataPoint
        loop x mutable'exemplars mutable'labels
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'exemplars <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                            (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                               mutable'exemplars)
                      frozen'labels <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                         (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                            mutable'labels)
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
                              (Data.ProtoLens.Field.field @"vec'exemplars") frozen'exemplars
                              (Lens.Family2.set
                                 (Data.ProtoLens.Field.field @"vec'labels") frozen'labels x)))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "labels"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'labels y)
                                loop x mutable'exemplars v
                        17
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getFixed64
                                       "start_time_unix_nano"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"startTimeUnixNano") y x)
                                  mutable'exemplars mutable'labels
                        25
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getFixed64 "time_unix_nano"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"timeUnixNano") y x)
                                  mutable'exemplars mutable'labels
                        33
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getFixed64)
                                       "value"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"value") y x)
                                  mutable'exemplars mutable'labels
                        42
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "exemplars"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'exemplars y)
                                loop x v mutable'labels
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'exemplars mutable'labels
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'exemplars <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                     Data.ProtoLens.Encoding.Growing.new
              mutable'labels <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                  Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'exemplars mutable'labels)
          "IntDataPoint"
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
                (Lens.Family2.view (Data.ProtoLens.Field.field @"vec'labels") _x))
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
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 17)
                         (Data.ProtoLens.Encoding.Bytes.putFixed64 _v))
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
                         _v = Lens.Family2.view (Data.ProtoLens.Field.field @"value") _x
                       in
                         if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                             Data.Monoid.mempty
                         else
                             (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt 33)
                               ((Prelude..)
                                  Data.ProtoLens.Encoding.Bytes.putFixed64 Prelude.fromIntegral _v))
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
                                       Data.ProtoLens.encodeMessage _v))
                            (Lens.Family2.view
                               (Data.ProtoLens.Field.field @"vec'exemplars") _x))
                         (Data.ProtoLens.Encoding.Wire.buildFieldSet
                            (Lens.Family2.view Data.ProtoLens.unknownFields _x))))))
instance Control.DeepSeq.NFData IntDataPoint where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_IntDataPoint'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_IntDataPoint'labels x__)
                (Control.DeepSeq.deepseq
                   (_IntDataPoint'startTimeUnixNano x__)
                   (Control.DeepSeq.deepseq
                      (_IntDataPoint'timeUnixNano x__)
                      (Control.DeepSeq.deepseq
                         (_IntDataPoint'value x__)
                         (Control.DeepSeq.deepseq (_IntDataPoint'exemplars x__) ())))))
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.filteredLabels' @:: Lens' IntExemplar [Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue]@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.vec'filteredLabels' @:: Lens' IntExemplar (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.timeUnixNano' @:: Lens' IntExemplar Data.Word.Word64@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.value' @:: Lens' IntExemplar Data.Int.Int64@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.spanId' @:: Lens' IntExemplar Data.ByteString.ByteString@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.traceId' @:: Lens' IntExemplar Data.ByteString.ByteString@ -}
data IntExemplar
  = IntExemplar'_constructor {_IntExemplar'filteredLabels :: !(Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue),
                              _IntExemplar'timeUnixNano :: !Data.Word.Word64,
                              _IntExemplar'value :: !Data.Int.Int64,
                              _IntExemplar'spanId :: !Data.ByteString.ByteString,
                              _IntExemplar'traceId :: !Data.ByteString.ByteString,
                              _IntExemplar'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show IntExemplar where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField IntExemplar "filteredLabels" [Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _IntExemplar'filteredLabels
           (\ x__ y__ -> x__ {_IntExemplar'filteredLabels = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField IntExemplar "vec'filteredLabels" (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _IntExemplar'filteredLabels
           (\ x__ y__ -> x__ {_IntExemplar'filteredLabels = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField IntExemplar "timeUnixNano" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _IntExemplar'timeUnixNano
           (\ x__ y__ -> x__ {_IntExemplar'timeUnixNano = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField IntExemplar "value" Data.Int.Int64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _IntExemplar'value (\ x__ y__ -> x__ {_IntExemplar'value = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField IntExemplar "spanId" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _IntExemplar'spanId (\ x__ y__ -> x__ {_IntExemplar'spanId = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField IntExemplar "traceId" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _IntExemplar'traceId
           (\ x__ y__ -> x__ {_IntExemplar'traceId = y__}))
        Prelude.id
instance Data.ProtoLens.Message IntExemplar where
  messageName _
    = Data.Text.pack "opentelemetry.proto.metrics.v1.IntExemplar"
  packedMessageDescriptor _
    = "\n\
      \\vIntExemplar\DC2V\n\
      \\SIfiltered_labels\CAN\SOH \ETX(\v2-.opentelemetry.proto.common.v1.StringKeyValueR\SOfilteredLabels\DC2$\n\
      \\SOtime_unix_nano\CAN\STX \SOH(\ACKR\ftimeUnixNano\DC2\DC4\n\
      \\ENQvalue\CAN\ETX \SOH(\DLER\ENQvalue\DC2\ETB\n\
      \\aspan_id\CAN\EOT \SOH(\fR\ACKspanId\DC2\EM\n\
      \\btrace_id\CAN\ENQ \SOH(\fR\atraceId:\STX\CAN\SOH"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        filteredLabels__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "filtered_labels"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"filteredLabels")) ::
              Data.ProtoLens.FieldDescriptor IntExemplar
        timeUnixNano__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "time_unix_nano"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Fixed64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"timeUnixNano")) ::
              Data.ProtoLens.FieldDescriptor IntExemplar
        value__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "value"
              (Data.ProtoLens.ScalarField Data.ProtoLens.SFixed64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"value")) ::
              Data.ProtoLens.FieldDescriptor IntExemplar
        spanId__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "span_id"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"spanId")) ::
              Data.ProtoLens.FieldDescriptor IntExemplar
        traceId__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "trace_id"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"traceId")) ::
              Data.ProtoLens.FieldDescriptor IntExemplar
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, filteredLabels__field_descriptor),
           (Data.ProtoLens.Tag 2, timeUnixNano__field_descriptor),
           (Data.ProtoLens.Tag 3, value__field_descriptor),
           (Data.ProtoLens.Tag 4, spanId__field_descriptor),
           (Data.ProtoLens.Tag 5, traceId__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _IntExemplar'_unknownFields
        (\ x__ y__ -> x__ {_IntExemplar'_unknownFields = y__})
  defMessage
    = IntExemplar'_constructor
        {_IntExemplar'filteredLabels = Data.Vector.Generic.empty,
         _IntExemplar'timeUnixNano = Data.ProtoLens.fieldDefault,
         _IntExemplar'value = Data.ProtoLens.fieldDefault,
         _IntExemplar'spanId = Data.ProtoLens.fieldDefault,
         _IntExemplar'traceId = Data.ProtoLens.fieldDefault,
         _IntExemplar'_unknownFields = []}
  parseMessage
    = let
        loop ::
          IntExemplar
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue
             -> Data.ProtoLens.Encoding.Bytes.Parser IntExemplar
        loop x mutable'filteredLabels
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'filteredLabels <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                 (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                    mutable'filteredLabels)
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
                              (Data.ProtoLens.Field.field @"vec'filteredLabels")
                              frozen'filteredLabels x))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "filtered_labels"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append
                                          mutable'filteredLabels y)
                                loop x v
                        17
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getFixed64 "time_unix_nano"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"timeUnixNano") y x)
                                  mutable'filteredLabels
                        25
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getFixed64)
                                       "value"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"value") y x)
                                  mutable'filteredLabels
                        34
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "span_id"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"spanId") y x)
                                  mutable'filteredLabels
                        42
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "trace_id"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"traceId") y x)
                                  mutable'filteredLabels
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'filteredLabels
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'filteredLabels <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                          Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'filteredLabels)
          "IntExemplar"
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
                   (Data.ProtoLens.Field.field @"vec'filteredLabels") _x))
             ((Data.Monoid.<>)
                (let
                   _v
                     = Lens.Family2.view (Data.ProtoLens.Field.field @"timeUnixNano") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 17)
                         (Data.ProtoLens.Encoding.Bytes.putFixed64 _v))
                ((Data.Monoid.<>)
                   (let
                      _v = Lens.Family2.view (Data.ProtoLens.Field.field @"value") _x
                    in
                      if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                          Data.Monoid.mempty
                      else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 25)
                            ((Prelude..)
                               Data.ProtoLens.Encoding.Bytes.putFixed64 Prelude.fromIntegral _v))
                   ((Data.Monoid.<>)
                      (let
                         _v = Lens.Family2.view (Data.ProtoLens.Field.field @"spanId") _x
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
                         (let
                            _v = Lens.Family2.view (Data.ProtoLens.Field.field @"traceId") _x
                          in
                            if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                Data.Monoid.mempty
                            else
                                (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt 42)
                                  ((\ bs
                                      -> (Data.Monoid.<>)
                                           (Data.ProtoLens.Encoding.Bytes.putVarInt
                                              (Prelude.fromIntegral (Data.ByteString.length bs)))
                                           (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                     _v))
                         (Data.ProtoLens.Encoding.Wire.buildFieldSet
                            (Lens.Family2.view Data.ProtoLens.unknownFields _x))))))
instance Control.DeepSeq.NFData IntExemplar where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_IntExemplar'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_IntExemplar'filteredLabels x__)
                (Control.DeepSeq.deepseq
                   (_IntExemplar'timeUnixNano x__)
                   (Control.DeepSeq.deepseq
                      (_IntExemplar'value x__)
                      (Control.DeepSeq.deepseq
                         (_IntExemplar'spanId x__)
                         (Control.DeepSeq.deepseq (_IntExemplar'traceId x__) ())))))
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.dataPoints' @:: Lens' IntGauge [IntDataPoint]@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.vec'dataPoints' @:: Lens' IntGauge (Data.Vector.Vector IntDataPoint)@ -}
data IntGauge
  = IntGauge'_constructor {_IntGauge'dataPoints :: !(Data.Vector.Vector IntDataPoint),
                           _IntGauge'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show IntGauge where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField IntGauge "dataPoints" [IntDataPoint] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _IntGauge'dataPoints
           (\ x__ y__ -> x__ {_IntGauge'dataPoints = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField IntGauge "vec'dataPoints" (Data.Vector.Vector IntDataPoint) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _IntGauge'dataPoints
           (\ x__ y__ -> x__ {_IntGauge'dataPoints = y__}))
        Prelude.id
instance Data.ProtoLens.Message IntGauge where
  messageName _
    = Data.Text.pack "opentelemetry.proto.metrics.v1.IntGauge"
  packedMessageDescriptor _
    = "\n\
      \\bIntGauge\DC2M\n\
      \\vdata_points\CAN\SOH \ETX(\v2,.opentelemetry.proto.metrics.v1.IntDataPointR\n\
      \dataPoints:\STX\CAN\SOH"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        dataPoints__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "data_points"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor IntDataPoint)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"dataPoints")) ::
              Data.ProtoLens.FieldDescriptor IntGauge
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, dataPoints__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _IntGauge'_unknownFields
        (\ x__ y__ -> x__ {_IntGauge'_unknownFields = y__})
  defMessage
    = IntGauge'_constructor
        {_IntGauge'dataPoints = Data.Vector.Generic.empty,
         _IntGauge'_unknownFields = []}
  parseMessage
    = let
        loop ::
          IntGauge
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld IntDataPoint
             -> Data.ProtoLens.Encoding.Bytes.Parser IntGauge
        loop x mutable'dataPoints
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'dataPoints <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                             (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                mutable'dataPoints)
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
                              (Data.ProtoLens.Field.field @"vec'dataPoints") frozen'dataPoints
                              x))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "data_points"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'dataPoints y)
                                loop x v
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'dataPoints
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'dataPoints <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                      Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'dataPoints)
          "IntGauge"
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
                   (Data.ProtoLens.Field.field @"vec'dataPoints") _x))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData IntGauge where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_IntGauge'_unknownFields x__)
             (Control.DeepSeq.deepseq (_IntGauge'dataPoints x__) ())
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.dataPoints' @:: Lens' IntHistogram [IntHistogramDataPoint]@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.vec'dataPoints' @:: Lens' IntHistogram (Data.Vector.Vector IntHistogramDataPoint)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.aggregationTemporality' @:: Lens' IntHistogram AggregationTemporality@ -}
data IntHistogram
  = IntHistogram'_constructor {_IntHistogram'dataPoints :: !(Data.Vector.Vector IntHistogramDataPoint),
                               _IntHistogram'aggregationTemporality :: !AggregationTemporality,
                               _IntHistogram'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show IntHistogram where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField IntHistogram "dataPoints" [IntHistogramDataPoint] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _IntHistogram'dataPoints
           (\ x__ y__ -> x__ {_IntHistogram'dataPoints = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField IntHistogram "vec'dataPoints" (Data.Vector.Vector IntHistogramDataPoint) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _IntHistogram'dataPoints
           (\ x__ y__ -> x__ {_IntHistogram'dataPoints = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField IntHistogram "aggregationTemporality" AggregationTemporality where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _IntHistogram'aggregationTemporality
           (\ x__ y__ -> x__ {_IntHistogram'aggregationTemporality = y__}))
        Prelude.id
instance Data.ProtoLens.Message IntHistogram where
  messageName _
    = Data.Text.pack "opentelemetry.proto.metrics.v1.IntHistogram"
  packedMessageDescriptor _
    = "\n\
      \\fIntHistogram\DC2V\n\
      \\vdata_points\CAN\SOH \ETX(\v25.opentelemetry.proto.metrics.v1.IntHistogramDataPointR\n\
      \dataPoints\DC2o\n\
      \\ETBaggregation_temporality\CAN\STX \SOH(\SO26.opentelemetry.proto.metrics.v1.AggregationTemporalityR\SYNaggregationTemporality:\STX\CAN\SOH"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        dataPoints__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "data_points"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor IntHistogramDataPoint)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"dataPoints")) ::
              Data.ProtoLens.FieldDescriptor IntHistogram
        aggregationTemporality__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "aggregation_temporality"
              (Data.ProtoLens.ScalarField Data.ProtoLens.EnumField ::
                 Data.ProtoLens.FieldTypeDescriptor AggregationTemporality)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"aggregationTemporality")) ::
              Data.ProtoLens.FieldDescriptor IntHistogram
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, dataPoints__field_descriptor),
           (Data.ProtoLens.Tag 2, aggregationTemporality__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _IntHistogram'_unknownFields
        (\ x__ y__ -> x__ {_IntHistogram'_unknownFields = y__})
  defMessage
    = IntHistogram'_constructor
        {_IntHistogram'dataPoints = Data.Vector.Generic.empty,
         _IntHistogram'aggregationTemporality = Data.ProtoLens.fieldDefault,
         _IntHistogram'_unknownFields = []}
  parseMessage
    = let
        loop ::
          IntHistogram
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld IntHistogramDataPoint
             -> Data.ProtoLens.Encoding.Bytes.Parser IntHistogram
        loop x mutable'dataPoints
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'dataPoints <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                             (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                mutable'dataPoints)
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
                              (Data.ProtoLens.Field.field @"vec'dataPoints") frozen'dataPoints
                              x))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "data_points"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'dataPoints y)
                                loop x v
                        16
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
                                  mutable'dataPoints
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'dataPoints
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'dataPoints <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                      Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'dataPoints)
          "IntHistogram"
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
                   (Data.ProtoLens.Field.field @"vec'dataPoints") _x))
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
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                         ((Prelude..)
                            ((Prelude..)
                               Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral)
                            Prelude.fromEnum _v))
                (Data.ProtoLens.Encoding.Wire.buildFieldSet
                   (Lens.Family2.view Data.ProtoLens.unknownFields _x)))
instance Control.DeepSeq.NFData IntHistogram where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_IntHistogram'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_IntHistogram'dataPoints x__)
                (Control.DeepSeq.deepseq
                   (_IntHistogram'aggregationTemporality x__) ()))
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.labels' @:: Lens' IntHistogramDataPoint [Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue]@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.vec'labels' @:: Lens' IntHistogramDataPoint (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.startTimeUnixNano' @:: Lens' IntHistogramDataPoint Data.Word.Word64@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.timeUnixNano' @:: Lens' IntHistogramDataPoint Data.Word.Word64@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.count' @:: Lens' IntHistogramDataPoint Data.Word.Word64@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.sum' @:: Lens' IntHistogramDataPoint Data.Int.Int64@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.bucketCounts' @:: Lens' IntHistogramDataPoint [Data.Word.Word64]@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.vec'bucketCounts' @:: Lens' IntHistogramDataPoint (Data.Vector.Unboxed.Vector Data.Word.Word64)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.explicitBounds' @:: Lens' IntHistogramDataPoint [Prelude.Double]@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.vec'explicitBounds' @:: Lens' IntHistogramDataPoint (Data.Vector.Unboxed.Vector Prelude.Double)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.exemplars' @:: Lens' IntHistogramDataPoint [IntExemplar]@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.vec'exemplars' @:: Lens' IntHistogramDataPoint (Data.Vector.Vector IntExemplar)@ -}
data IntHistogramDataPoint
  = IntHistogramDataPoint'_constructor {_IntHistogramDataPoint'labels :: !(Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue),
                                        _IntHistogramDataPoint'startTimeUnixNano :: !Data.Word.Word64,
                                        _IntHistogramDataPoint'timeUnixNano :: !Data.Word.Word64,
                                        _IntHistogramDataPoint'count :: !Data.Word.Word64,
                                        _IntHistogramDataPoint'sum :: !Data.Int.Int64,
                                        _IntHistogramDataPoint'bucketCounts :: !(Data.Vector.Unboxed.Vector Data.Word.Word64),
                                        _IntHistogramDataPoint'explicitBounds :: !(Data.Vector.Unboxed.Vector Prelude.Double),
                                        _IntHistogramDataPoint'exemplars :: !(Data.Vector.Vector IntExemplar),
                                        _IntHistogramDataPoint'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show IntHistogramDataPoint where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField IntHistogramDataPoint "labels" [Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _IntHistogramDataPoint'labels
           (\ x__ y__ -> x__ {_IntHistogramDataPoint'labels = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField IntHistogramDataPoint "vec'labels" (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _IntHistogramDataPoint'labels
           (\ x__ y__ -> x__ {_IntHistogramDataPoint'labels = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField IntHistogramDataPoint "startTimeUnixNano" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _IntHistogramDataPoint'startTimeUnixNano
           (\ x__ y__
              -> x__ {_IntHistogramDataPoint'startTimeUnixNano = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField IntHistogramDataPoint "timeUnixNano" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _IntHistogramDataPoint'timeUnixNano
           (\ x__ y__ -> x__ {_IntHistogramDataPoint'timeUnixNano = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField IntHistogramDataPoint "count" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _IntHistogramDataPoint'count
           (\ x__ y__ -> x__ {_IntHistogramDataPoint'count = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField IntHistogramDataPoint "sum" Data.Int.Int64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _IntHistogramDataPoint'sum
           (\ x__ y__ -> x__ {_IntHistogramDataPoint'sum = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField IntHistogramDataPoint "bucketCounts" [Data.Word.Word64] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _IntHistogramDataPoint'bucketCounts
           (\ x__ y__ -> x__ {_IntHistogramDataPoint'bucketCounts = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField IntHistogramDataPoint "vec'bucketCounts" (Data.Vector.Unboxed.Vector Data.Word.Word64) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _IntHistogramDataPoint'bucketCounts
           (\ x__ y__ -> x__ {_IntHistogramDataPoint'bucketCounts = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField IntHistogramDataPoint "explicitBounds" [Prelude.Double] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _IntHistogramDataPoint'explicitBounds
           (\ x__ y__ -> x__ {_IntHistogramDataPoint'explicitBounds = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField IntHistogramDataPoint "vec'explicitBounds" (Data.Vector.Unboxed.Vector Prelude.Double) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _IntHistogramDataPoint'explicitBounds
           (\ x__ y__ -> x__ {_IntHistogramDataPoint'explicitBounds = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField IntHistogramDataPoint "exemplars" [IntExemplar] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _IntHistogramDataPoint'exemplars
           (\ x__ y__ -> x__ {_IntHistogramDataPoint'exemplars = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField IntHistogramDataPoint "vec'exemplars" (Data.Vector.Vector IntExemplar) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _IntHistogramDataPoint'exemplars
           (\ x__ y__ -> x__ {_IntHistogramDataPoint'exemplars = y__}))
        Prelude.id
instance Data.ProtoLens.Message IntHistogramDataPoint where
  messageName _
    = Data.Text.pack
        "opentelemetry.proto.metrics.v1.IntHistogramDataPoint"
  packedMessageDescriptor _
    = "\n\
      \\NAKIntHistogramDataPoint\DC2E\n\
      \\ACKlabels\CAN\SOH \ETX(\v2-.opentelemetry.proto.common.v1.StringKeyValueR\ACKlabels\DC2/\n\
      \\DC4start_time_unix_nano\CAN\STX \SOH(\ACKR\DC1startTimeUnixNano\DC2$\n\
      \\SOtime_unix_nano\CAN\ETX \SOH(\ACKR\ftimeUnixNano\DC2\DC4\n\
      \\ENQcount\CAN\EOT \SOH(\ACKR\ENQcount\DC2\DLE\n\
      \\ETXsum\CAN\ENQ \SOH(\DLER\ETXsum\DC2#\n\
      \\rbucket_counts\CAN\ACK \ETX(\ACKR\fbucketCounts\DC2'\n\
      \\SIexplicit_bounds\CAN\a \ETX(\SOHR\SOexplicitBounds\DC2I\n\
      \\texemplars\CAN\b \ETX(\v2+.opentelemetry.proto.metrics.v1.IntExemplarR\texemplars:\STX\CAN\SOH"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        labels__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "labels"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked (Data.ProtoLens.Field.field @"labels")) ::
              Data.ProtoLens.FieldDescriptor IntHistogramDataPoint
        startTimeUnixNano__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "start_time_unix_nano"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Fixed64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"startTimeUnixNano")) ::
              Data.ProtoLens.FieldDescriptor IntHistogramDataPoint
        timeUnixNano__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "time_unix_nano"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Fixed64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"timeUnixNano")) ::
              Data.ProtoLens.FieldDescriptor IntHistogramDataPoint
        count__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "count"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Fixed64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"count")) ::
              Data.ProtoLens.FieldDescriptor IntHistogramDataPoint
        sum__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "sum"
              (Data.ProtoLens.ScalarField Data.ProtoLens.SFixed64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"sum")) ::
              Data.ProtoLens.FieldDescriptor IntHistogramDataPoint
        bucketCounts__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "bucket_counts"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Fixed64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Packed
                 (Data.ProtoLens.Field.field @"bucketCounts")) ::
              Data.ProtoLens.FieldDescriptor IntHistogramDataPoint
        explicitBounds__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "explicit_bounds"
              (Data.ProtoLens.ScalarField Data.ProtoLens.DoubleField ::
                 Data.ProtoLens.FieldTypeDescriptor Prelude.Double)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Packed
                 (Data.ProtoLens.Field.field @"explicitBounds")) ::
              Data.ProtoLens.FieldDescriptor IntHistogramDataPoint
        exemplars__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "exemplars"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor IntExemplar)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"exemplars")) ::
              Data.ProtoLens.FieldDescriptor IntHistogramDataPoint
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, labels__field_descriptor),
           (Data.ProtoLens.Tag 2, startTimeUnixNano__field_descriptor),
           (Data.ProtoLens.Tag 3, timeUnixNano__field_descriptor),
           (Data.ProtoLens.Tag 4, count__field_descriptor),
           (Data.ProtoLens.Tag 5, sum__field_descriptor),
           (Data.ProtoLens.Tag 6, bucketCounts__field_descriptor),
           (Data.ProtoLens.Tag 7, explicitBounds__field_descriptor),
           (Data.ProtoLens.Tag 8, exemplars__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _IntHistogramDataPoint'_unknownFields
        (\ x__ y__ -> x__ {_IntHistogramDataPoint'_unknownFields = y__})
  defMessage
    = IntHistogramDataPoint'_constructor
        {_IntHistogramDataPoint'labels = Data.Vector.Generic.empty,
         _IntHistogramDataPoint'startTimeUnixNano = Data.ProtoLens.fieldDefault,
         _IntHistogramDataPoint'timeUnixNano = Data.ProtoLens.fieldDefault,
         _IntHistogramDataPoint'count = Data.ProtoLens.fieldDefault,
         _IntHistogramDataPoint'sum = Data.ProtoLens.fieldDefault,
         _IntHistogramDataPoint'bucketCounts = Data.Vector.Generic.empty,
         _IntHistogramDataPoint'explicitBounds = Data.Vector.Generic.empty,
         _IntHistogramDataPoint'exemplars = Data.Vector.Generic.empty,
         _IntHistogramDataPoint'_unknownFields = []}
  parseMessage
    = let
        loop ::
          IntHistogramDataPoint
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Unboxed.Vector Data.ProtoLens.Encoding.Growing.RealWorld Data.Word.Word64
             -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld IntExemplar
                -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Unboxed.Vector Data.ProtoLens.Encoding.Growing.RealWorld Prelude.Double
                   -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue
                      -> Data.ProtoLens.Encoding.Bytes.Parser IntHistogramDataPoint
        loop
          x
          mutable'bucketCounts
          mutable'exemplars
          mutable'explicitBounds
          mutable'labels
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'bucketCounts <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                               (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                  mutable'bucketCounts)
                      frozen'exemplars <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                            (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                               mutable'exemplars)
                      frozen'explicitBounds <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                 (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                    mutable'explicitBounds)
                      frozen'labels <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                         (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                            mutable'labels)
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
                              (Data.ProtoLens.Field.field @"vec'bucketCounts")
                              frozen'bucketCounts
                              (Lens.Family2.set
                                 (Data.ProtoLens.Field.field @"vec'exemplars") frozen'exemplars
                                 (Lens.Family2.set
                                    (Data.ProtoLens.Field.field @"vec'explicitBounds")
                                    frozen'explicitBounds
                                    (Lens.Family2.set
                                       (Data.ProtoLens.Field.field @"vec'labels") frozen'labels
                                       x)))))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "labels"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'labels y)
                                loop
                                  x mutable'bucketCounts mutable'exemplars mutable'explicitBounds v
                        17
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getFixed64
                                       "start_time_unix_nano"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"startTimeUnixNano") y x)
                                  mutable'bucketCounts mutable'exemplars mutable'explicitBounds
                                  mutable'labels
                        25
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getFixed64 "time_unix_nano"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"timeUnixNano") y x)
                                  mutable'bucketCounts mutable'exemplars mutable'explicitBounds
                                  mutable'labels
                        33
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getFixed64 "count"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"count") y x)
                                  mutable'bucketCounts mutable'exemplars mutable'explicitBounds
                                  mutable'labels
                        41
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getFixed64)
                                       "sum"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"sum") y x)
                                  mutable'bucketCounts mutable'exemplars mutable'explicitBounds
                                  mutable'labels
                        49
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        Data.ProtoLens.Encoding.Bytes.getFixed64 "bucket_counts"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append
                                          mutable'bucketCounts y)
                                loop x v mutable'exemplars mutable'explicitBounds mutable'labels
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
                                                                    Data.ProtoLens.Encoding.Bytes.getFixed64
                                                                    "bucket_counts"
                                                            qs' <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                                     (Data.ProtoLens.Encoding.Growing.append
                                                                        qs q)
                                                            ploop qs'
                                            in ploop)
                                             mutable'bucketCounts)
                                loop x y mutable'exemplars mutable'explicitBounds mutable'labels
                        57
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (Prelude.fmap
                                           Data.ProtoLens.Encoding.Bytes.wordToDouble
                                           Data.ProtoLens.Encoding.Bytes.getFixed64)
                                        "explicit_bounds"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append
                                          mutable'explicitBounds y)
                                loop x mutable'bucketCounts mutable'exemplars v mutable'labels
                        58
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
                                                                       Data.ProtoLens.Encoding.Bytes.wordToDouble
                                                                       Data.ProtoLens.Encoding.Bytes.getFixed64)
                                                                    "explicit_bounds"
                                                            qs' <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                                     (Data.ProtoLens.Encoding.Growing.append
                                                                        qs q)
                                                            ploop qs'
                                            in ploop)
                                             mutable'explicitBounds)
                                loop x mutable'bucketCounts mutable'exemplars y mutable'labels
                        66
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "exemplars"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'exemplars y)
                                loop x mutable'bucketCounts v mutable'explicitBounds mutable'labels
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'bucketCounts mutable'exemplars mutable'explicitBounds
                                  mutable'labels
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'bucketCounts <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                        Data.ProtoLens.Encoding.Growing.new
              mutable'exemplars <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                     Data.ProtoLens.Encoding.Growing.new
              mutable'explicitBounds <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                          Data.ProtoLens.Encoding.Growing.new
              mutable'labels <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                  Data.ProtoLens.Encoding.Growing.new
              loop
                Data.ProtoLens.defMessage mutable'bucketCounts mutable'exemplars
                mutable'explicitBounds mutable'labels)
          "IntHistogramDataPoint"
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
                (Lens.Family2.view (Data.ProtoLens.Field.field @"vec'labels") _x))
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
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 17)
                         (Data.ProtoLens.Encoding.Bytes.putFixed64 _v))
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
                         _v = Lens.Family2.view (Data.ProtoLens.Field.field @"count") _x
                       in
                         if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                             Data.Monoid.mempty
                         else
                             (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt 33)
                               (Data.ProtoLens.Encoding.Bytes.putFixed64 _v))
                      ((Data.Monoid.<>)
                         (let _v = Lens.Family2.view (Data.ProtoLens.Field.field @"sum") _x
                          in
                            if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                Data.Monoid.mempty
                            else
                                (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt 41)
                                  ((Prelude..)
                                     Data.ProtoLens.Encoding.Bytes.putFixed64 Prelude.fromIntegral
                                     _v))
                         ((Data.Monoid.<>)
                            (let
                               p = Lens.Family2.view
                                     (Data.ProtoLens.Field.field @"vec'bucketCounts") _x
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
                                              Data.ProtoLens.Encoding.Bytes.putFixed64 p))))
                            ((Data.Monoid.<>)
                               (let
                                  p = Lens.Family2.view
                                        (Data.ProtoLens.Field.field @"vec'explicitBounds") _x
                                in
                                  if Data.Vector.Generic.null p then
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
                                           (Data.ProtoLens.Encoding.Bytes.runBuilder
                                              (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                                                 ((Prelude..)
                                                    Data.ProtoLens.Encoding.Bytes.putFixed64
                                                    Data.ProtoLens.Encoding.Bytes.doubleToWord)
                                                 p))))
                               ((Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                                     (\ _v
                                        -> (Data.Monoid.<>)
                                             (Data.ProtoLens.Encoding.Bytes.putVarInt 66)
                                             ((Prelude..)
                                                (\ bs
                                                   -> (Data.Monoid.<>)
                                                        (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                           (Prelude.fromIntegral
                                                              (Data.ByteString.length bs)))
                                                        (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                                Data.ProtoLens.encodeMessage _v))
                                     (Lens.Family2.view
                                        (Data.ProtoLens.Field.field @"vec'exemplars") _x))
                                  (Data.ProtoLens.Encoding.Wire.buildFieldSet
                                     (Lens.Family2.view Data.ProtoLens.unknownFields _x)))))))))
instance Control.DeepSeq.NFData IntHistogramDataPoint where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_IntHistogramDataPoint'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_IntHistogramDataPoint'labels x__)
                (Control.DeepSeq.deepseq
                   (_IntHistogramDataPoint'startTimeUnixNano x__)
                   (Control.DeepSeq.deepseq
                      (_IntHistogramDataPoint'timeUnixNano x__)
                      (Control.DeepSeq.deepseq
                         (_IntHistogramDataPoint'count x__)
                         (Control.DeepSeq.deepseq
                            (_IntHistogramDataPoint'sum x__)
                            (Control.DeepSeq.deepseq
                               (_IntHistogramDataPoint'bucketCounts x__)
                               (Control.DeepSeq.deepseq
                                  (_IntHistogramDataPoint'explicitBounds x__)
                                  (Control.DeepSeq.deepseq
                                     (_IntHistogramDataPoint'exemplars x__) ()))))))))
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.dataPoints' @:: Lens' IntSum [IntDataPoint]@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.vec'dataPoints' @:: Lens' IntSum (Data.Vector.Vector IntDataPoint)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.aggregationTemporality' @:: Lens' IntSum AggregationTemporality@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.isMonotonic' @:: Lens' IntSum Prelude.Bool@ -}
data IntSum
  = IntSum'_constructor {_IntSum'dataPoints :: !(Data.Vector.Vector IntDataPoint),
                         _IntSum'aggregationTemporality :: !AggregationTemporality,
                         _IntSum'isMonotonic :: !Prelude.Bool,
                         _IntSum'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show IntSum where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField IntSum "dataPoints" [IntDataPoint] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _IntSum'dataPoints (\ x__ y__ -> x__ {_IntSum'dataPoints = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField IntSum "vec'dataPoints" (Data.Vector.Vector IntDataPoint) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _IntSum'dataPoints (\ x__ y__ -> x__ {_IntSum'dataPoints = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField IntSum "aggregationTemporality" AggregationTemporality where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _IntSum'aggregationTemporality
           (\ x__ y__ -> x__ {_IntSum'aggregationTemporality = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField IntSum "isMonotonic" Prelude.Bool where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _IntSum'isMonotonic (\ x__ y__ -> x__ {_IntSum'isMonotonic = y__}))
        Prelude.id
instance Data.ProtoLens.Message IntSum where
  messageName _
    = Data.Text.pack "opentelemetry.proto.metrics.v1.IntSum"
  packedMessageDescriptor _
    = "\n\
      \\ACKIntSum\DC2M\n\
      \\vdata_points\CAN\SOH \ETX(\v2,.opentelemetry.proto.metrics.v1.IntDataPointR\n\
      \dataPoints\DC2o\n\
      \\ETBaggregation_temporality\CAN\STX \SOH(\SO26.opentelemetry.proto.metrics.v1.AggregationTemporalityR\SYNaggregationTemporality\DC2!\n\
      \\fis_monotonic\CAN\ETX \SOH(\bR\visMonotonic:\STX\CAN\SOH"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        dataPoints__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "data_points"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor IntDataPoint)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"dataPoints")) ::
              Data.ProtoLens.FieldDescriptor IntSum
        aggregationTemporality__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "aggregation_temporality"
              (Data.ProtoLens.ScalarField Data.ProtoLens.EnumField ::
                 Data.ProtoLens.FieldTypeDescriptor AggregationTemporality)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"aggregationTemporality")) ::
              Data.ProtoLens.FieldDescriptor IntSum
        isMonotonic__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "is_monotonic"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BoolField ::
                 Data.ProtoLens.FieldTypeDescriptor Prelude.Bool)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"isMonotonic")) ::
              Data.ProtoLens.FieldDescriptor IntSum
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, dataPoints__field_descriptor),
           (Data.ProtoLens.Tag 2, aggregationTemporality__field_descriptor),
           (Data.ProtoLens.Tag 3, isMonotonic__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _IntSum'_unknownFields
        (\ x__ y__ -> x__ {_IntSum'_unknownFields = y__})
  defMessage
    = IntSum'_constructor
        {_IntSum'dataPoints = Data.Vector.Generic.empty,
         _IntSum'aggregationTemporality = Data.ProtoLens.fieldDefault,
         _IntSum'isMonotonic = Data.ProtoLens.fieldDefault,
         _IntSum'_unknownFields = []}
  parseMessage
    = let
        loop ::
          IntSum
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld IntDataPoint
             -> Data.ProtoLens.Encoding.Bytes.Parser IntSum
        loop x mutable'dataPoints
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'dataPoints <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                             (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                mutable'dataPoints)
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
                              (Data.ProtoLens.Field.field @"vec'dataPoints") frozen'dataPoints
                              x))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "data_points"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'dataPoints y)
                                loop x v
                        16
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
                                  mutable'dataPoints
                        24
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          ((Prelude./=) 0) Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "is_monotonic"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"isMonotonic") y x)
                                  mutable'dataPoints
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'dataPoints
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'dataPoints <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                      Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'dataPoints)
          "IntSum"
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
                   (Data.ProtoLens.Field.field @"vec'dataPoints") _x))
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
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                         ((Prelude..)
                            ((Prelude..)
                               Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral)
                            Prelude.fromEnum _v))
                ((Data.Monoid.<>)
                   (let
                      _v
                        = Lens.Family2.view (Data.ProtoLens.Field.field @"isMonotonic") _x
                    in
                      if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                          Data.Monoid.mempty
                      else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 24)
                            ((Prelude..)
                               Data.ProtoLens.Encoding.Bytes.putVarInt (\ b -> if b then 1 else 0)
                               _v))
                   (Data.ProtoLens.Encoding.Wire.buildFieldSet
                      (Lens.Family2.view Data.ProtoLens.unknownFields _x))))
instance Control.DeepSeq.NFData IntSum where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_IntSum'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_IntSum'dataPoints x__)
                (Control.DeepSeq.deepseq
                   (_IntSum'aggregationTemporality x__)
                   (Control.DeepSeq.deepseq (_IntSum'isMonotonic x__) ())))
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.name' @:: Lens' Metric Data.Text.Text@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.description' @:: Lens' Metric Data.Text.Text@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.unit' @:: Lens' Metric Data.Text.Text@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.maybe'data'' @:: Lens' Metric (Prelude.Maybe Metric'Data)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.maybe'intGauge' @:: Lens' Metric (Prelude.Maybe IntGauge)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.intGauge' @:: Lens' Metric IntGauge@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.maybe'gauge' @:: Lens' Metric (Prelude.Maybe Gauge)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.gauge' @:: Lens' Metric Gauge@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.maybe'intSum' @:: Lens' Metric (Prelude.Maybe IntSum)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.intSum' @:: Lens' Metric IntSum@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.maybe'sum' @:: Lens' Metric (Prelude.Maybe Sum)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.sum' @:: Lens' Metric Sum@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.maybe'intHistogram' @:: Lens' Metric (Prelude.Maybe IntHistogram)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.intHistogram' @:: Lens' Metric IntHistogram@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.maybe'histogram' @:: Lens' Metric (Prelude.Maybe Histogram)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.histogram' @:: Lens' Metric Histogram@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.maybe'exponentialHistogram' @:: Lens' Metric (Prelude.Maybe ExponentialHistogram)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.exponentialHistogram' @:: Lens' Metric ExponentialHistogram@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.maybe'summary' @:: Lens' Metric (Prelude.Maybe Summary)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.summary' @:: Lens' Metric Summary@ -}
data Metric
  = Metric'_constructor {_Metric'name :: !Data.Text.Text,
                         _Metric'description :: !Data.Text.Text,
                         _Metric'unit :: !Data.Text.Text,
                         _Metric'data' :: !(Prelude.Maybe Metric'Data),
                         _Metric'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show Metric where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
data Metric'Data
  = Metric'IntGauge !IntGauge |
    Metric'Gauge !Gauge |
    Metric'IntSum !IntSum |
    Metric'Sum !Sum |
    Metric'IntHistogram !IntHistogram |
    Metric'Histogram !Histogram |
    Metric'ExponentialHistogram !ExponentialHistogram |
    Metric'Summary !Summary
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
instance Data.ProtoLens.Field.HasField Metric "name" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Metric'name (\ x__ y__ -> x__ {_Metric'name = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Metric "description" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Metric'description (\ x__ y__ -> x__ {_Metric'description = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Metric "unit" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Metric'unit (\ x__ y__ -> x__ {_Metric'unit = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Metric "maybe'data'" (Prelude.Maybe Metric'Data) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Metric'data' (\ x__ y__ -> x__ {_Metric'data' = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Metric "maybe'intGauge" (Prelude.Maybe IntGauge) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Metric'data' (\ x__ y__ -> x__ {_Metric'data' = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (Metric'IntGauge x__val)) -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap Metric'IntGauge y__))
instance Data.ProtoLens.Field.HasField Metric "intGauge" IntGauge where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Metric'data' (\ x__ y__ -> x__ {_Metric'data' = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (Metric'IntGauge x__val)) -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap Metric'IntGauge y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField Metric "maybe'gauge" (Prelude.Maybe Gauge) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Metric'data' (\ x__ y__ -> x__ {_Metric'data' = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (Metric'Gauge x__val)) -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap Metric'Gauge y__))
instance Data.ProtoLens.Field.HasField Metric "gauge" Gauge where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Metric'data' (\ x__ y__ -> x__ {_Metric'data' = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (Metric'Gauge x__val)) -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap Metric'Gauge y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField Metric "maybe'intSum" (Prelude.Maybe IntSum) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Metric'data' (\ x__ y__ -> x__ {_Metric'data' = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (Metric'IntSum x__val)) -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap Metric'IntSum y__))
instance Data.ProtoLens.Field.HasField Metric "intSum" IntSum where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Metric'data' (\ x__ y__ -> x__ {_Metric'data' = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (Metric'IntSum x__val)) -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap Metric'IntSum y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField Metric "maybe'sum" (Prelude.Maybe Sum) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Metric'data' (\ x__ y__ -> x__ {_Metric'data' = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (Metric'Sum x__val)) -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap Metric'Sum y__))
instance Data.ProtoLens.Field.HasField Metric "sum" Sum where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Metric'data' (\ x__ y__ -> x__ {_Metric'data' = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (Metric'Sum x__val)) -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap Metric'Sum y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField Metric "maybe'intHistogram" (Prelude.Maybe IntHistogram) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Metric'data' (\ x__ y__ -> x__ {_Metric'data' = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (Metric'IntHistogram x__val)) -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap Metric'IntHistogram y__))
instance Data.ProtoLens.Field.HasField Metric "intHistogram" IntHistogram where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Metric'data' (\ x__ y__ -> x__ {_Metric'data' = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (Metric'IntHistogram x__val)) -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap Metric'IntHistogram y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField Metric "maybe'histogram" (Prelude.Maybe Histogram) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Metric'data' (\ x__ y__ -> x__ {_Metric'data' = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (Metric'Histogram x__val)) -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap Metric'Histogram y__))
instance Data.ProtoLens.Field.HasField Metric "histogram" Histogram where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Metric'data' (\ x__ y__ -> x__ {_Metric'data' = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (Metric'Histogram x__val)) -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap Metric'Histogram y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField Metric "maybe'exponentialHistogram" (Prelude.Maybe ExponentialHistogram) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Metric'data' (\ x__ y__ -> x__ {_Metric'data' = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (Metric'ExponentialHistogram x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap Metric'ExponentialHistogram y__))
instance Data.ProtoLens.Field.HasField Metric "exponentialHistogram" ExponentialHistogram where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Metric'data' (\ x__ y__ -> x__ {_Metric'data' = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (Metric'ExponentialHistogram x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap Metric'ExponentialHistogram y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField Metric "maybe'summary" (Prelude.Maybe Summary) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Metric'data' (\ x__ y__ -> x__ {_Metric'data' = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (Metric'Summary x__val)) -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap Metric'Summary y__))
instance Data.ProtoLens.Field.HasField Metric "summary" Summary where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Metric'data' (\ x__ y__ -> x__ {_Metric'data' = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (Metric'Summary x__val)) -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap Metric'Summary y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Message Metric where
  messageName _
    = Data.Text.pack "opentelemetry.proto.metrics.v1.Metric"
  packedMessageDescriptor _
    = "\n\
      \\ACKMetric\DC2\DC2\n\
      \\EOTname\CAN\SOH \SOH(\tR\EOTname\DC2 \n\
      \\vdescription\CAN\STX \SOH(\tR\vdescription\DC2\DC2\n\
      \\EOTunit\CAN\ETX \SOH(\tR\EOTunit\DC2K\n\
      \\tint_gauge\CAN\EOT \SOH(\v2(.opentelemetry.proto.metrics.v1.IntGaugeH\NULR\bintGaugeB\STX\CAN\SOH\DC2=\n\
      \\ENQgauge\CAN\ENQ \SOH(\v2%.opentelemetry.proto.metrics.v1.GaugeH\NULR\ENQgauge\DC2E\n\
      \\aint_sum\CAN\ACK \SOH(\v2&.opentelemetry.proto.metrics.v1.IntSumH\NULR\ACKintSumB\STX\CAN\SOH\DC27\n\
      \\ETXsum\CAN\a \SOH(\v2#.opentelemetry.proto.metrics.v1.SumH\NULR\ETXsum\DC2W\n\
      \\rint_histogram\CAN\b \SOH(\v2,.opentelemetry.proto.metrics.v1.IntHistogramH\NULR\fintHistogramB\STX\CAN\SOH\DC2I\n\
      \\thistogram\CAN\t \SOH(\v2).opentelemetry.proto.metrics.v1.HistogramH\NULR\thistogram\DC2k\n\
      \\NAKexponential_histogram\CAN\n\
      \ \SOH(\v24.opentelemetry.proto.metrics.v1.ExponentialHistogramH\NULR\DC4exponentialHistogram\DC2C\n\
      \\asummary\CAN\v \SOH(\v2'.opentelemetry.proto.metrics.v1.SummaryH\NULR\asummaryB\ACK\n\
      \\EOTdata"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        name__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "name"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"name")) ::
              Data.ProtoLens.FieldDescriptor Metric
        description__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "description"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"description")) ::
              Data.ProtoLens.FieldDescriptor Metric
        unit__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "unit"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"unit")) ::
              Data.ProtoLens.FieldDescriptor Metric
        intGauge__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "int_gauge"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor IntGauge)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'intGauge")) ::
              Data.ProtoLens.FieldDescriptor Metric
        gauge__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "gauge"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Gauge)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'gauge")) ::
              Data.ProtoLens.FieldDescriptor Metric
        intSum__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "int_sum"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor IntSum)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'intSum")) ::
              Data.ProtoLens.FieldDescriptor Metric
        sum__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "sum"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Sum)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'sum")) ::
              Data.ProtoLens.FieldDescriptor Metric
        intHistogram__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "int_histogram"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor IntHistogram)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'intHistogram")) ::
              Data.ProtoLens.FieldDescriptor Metric
        histogram__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "histogram"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Histogram)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'histogram")) ::
              Data.ProtoLens.FieldDescriptor Metric
        exponentialHistogram__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "exponential_histogram"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor ExponentialHistogram)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'exponentialHistogram")) ::
              Data.ProtoLens.FieldDescriptor Metric
        summary__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "summary"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Summary)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'summary")) ::
              Data.ProtoLens.FieldDescriptor Metric
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, name__field_descriptor),
           (Data.ProtoLens.Tag 2, description__field_descriptor),
           (Data.ProtoLens.Tag 3, unit__field_descriptor),
           (Data.ProtoLens.Tag 4, intGauge__field_descriptor),
           (Data.ProtoLens.Tag 5, gauge__field_descriptor),
           (Data.ProtoLens.Tag 6, intSum__field_descriptor),
           (Data.ProtoLens.Tag 7, sum__field_descriptor),
           (Data.ProtoLens.Tag 8, intHistogram__field_descriptor),
           (Data.ProtoLens.Tag 9, histogram__field_descriptor),
           (Data.ProtoLens.Tag 10, exponentialHistogram__field_descriptor),
           (Data.ProtoLens.Tag 11, summary__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Metric'_unknownFields
        (\ x__ y__ -> x__ {_Metric'_unknownFields = y__})
  defMessage
    = Metric'_constructor
        {_Metric'name = Data.ProtoLens.fieldDefault,
         _Metric'description = Data.ProtoLens.fieldDefault,
         _Metric'unit = Data.ProtoLens.fieldDefault,
         _Metric'data' = Prelude.Nothing, _Metric'_unknownFields = []}
  parseMessage
    = let
        loop :: Metric -> Data.ProtoLens.Encoding.Bytes.Parser Metric
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
                                       (do value <- do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                                       Data.ProtoLens.Encoding.Bytes.getBytes
                                                         (Prelude.fromIntegral len)
                                           Data.ProtoLens.Encoding.Bytes.runEither
                                             (case Data.Text.Encoding.decodeUtf8' value of
                                                (Prelude.Left err)
                                                  -> Prelude.Left (Prelude.show err)
                                                (Prelude.Right r) -> Prelude.Right r))
                                       "name"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"name") y x)
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
                                       "description"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"description") y x)
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
                                       "unit"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"unit") y x)
                        34
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "int_gauge"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"intGauge") y x)
                        42
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "gauge"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"gauge") y x)
                        50
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "int_sum"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"intSum") y x)
                        58
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "sum"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"sum") y x)
                        66
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "int_histogram"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"intHistogram") y x)
                        74
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "histogram"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"histogram") y x)
                        82
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "exponential_histogram"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"exponentialHistogram") y x)
                        90
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "summary"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"summary") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "Metric"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let _v = Lens.Family2.view (Data.ProtoLens.Field.field @"name") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
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
                     = Lens.Family2.view (Data.ProtoLens.Field.field @"description") _x
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
                   (let _v = Lens.Family2.view (Data.ProtoLens.Field.field @"unit") _x
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
                      (case
                           Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'data'") _x
                       of
                         Prelude.Nothing -> Data.Monoid.mempty
                         (Prelude.Just (Metric'IntGauge v))
                           -> (Data.Monoid.<>)
                                (Data.ProtoLens.Encoding.Bytes.putVarInt 34)
                                ((Prelude..)
                                   (\ bs
                                      -> (Data.Monoid.<>)
                                           (Data.ProtoLens.Encoding.Bytes.putVarInt
                                              (Prelude.fromIntegral (Data.ByteString.length bs)))
                                           (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                   Data.ProtoLens.encodeMessage v)
                         (Prelude.Just (Metric'Gauge v))
                           -> (Data.Monoid.<>)
                                (Data.ProtoLens.Encoding.Bytes.putVarInt 42)
                                ((Prelude..)
                                   (\ bs
                                      -> (Data.Monoid.<>)
                                           (Data.ProtoLens.Encoding.Bytes.putVarInt
                                              (Prelude.fromIntegral (Data.ByteString.length bs)))
                                           (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                   Data.ProtoLens.encodeMessage v)
                         (Prelude.Just (Metric'IntSum v))
                           -> (Data.Monoid.<>)
                                (Data.ProtoLens.Encoding.Bytes.putVarInt 50)
                                ((Prelude..)
                                   (\ bs
                                      -> (Data.Monoid.<>)
                                           (Data.ProtoLens.Encoding.Bytes.putVarInt
                                              (Prelude.fromIntegral (Data.ByteString.length bs)))
                                           (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                   Data.ProtoLens.encodeMessage v)
                         (Prelude.Just (Metric'Sum v))
                           -> (Data.Monoid.<>)
                                (Data.ProtoLens.Encoding.Bytes.putVarInt 58)
                                ((Prelude..)
                                   (\ bs
                                      -> (Data.Monoid.<>)
                                           (Data.ProtoLens.Encoding.Bytes.putVarInt
                                              (Prelude.fromIntegral (Data.ByteString.length bs)))
                                           (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                   Data.ProtoLens.encodeMessage v)
                         (Prelude.Just (Metric'IntHistogram v))
                           -> (Data.Monoid.<>)
                                (Data.ProtoLens.Encoding.Bytes.putVarInt 66)
                                ((Prelude..)
                                   (\ bs
                                      -> (Data.Monoid.<>)
                                           (Data.ProtoLens.Encoding.Bytes.putVarInt
                                              (Prelude.fromIntegral (Data.ByteString.length bs)))
                                           (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                   Data.ProtoLens.encodeMessage v)
                         (Prelude.Just (Metric'Histogram v))
                           -> (Data.Monoid.<>)
                                (Data.ProtoLens.Encoding.Bytes.putVarInt 74)
                                ((Prelude..)
                                   (\ bs
                                      -> (Data.Monoid.<>)
                                           (Data.ProtoLens.Encoding.Bytes.putVarInt
                                              (Prelude.fromIntegral (Data.ByteString.length bs)))
                                           (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                   Data.ProtoLens.encodeMessage v)
                         (Prelude.Just (Metric'ExponentialHistogram v))
                           -> (Data.Monoid.<>)
                                (Data.ProtoLens.Encoding.Bytes.putVarInt 82)
                                ((Prelude..)
                                   (\ bs
                                      -> (Data.Monoid.<>)
                                           (Data.ProtoLens.Encoding.Bytes.putVarInt
                                              (Prelude.fromIntegral (Data.ByteString.length bs)))
                                           (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                   Data.ProtoLens.encodeMessage v)
                         (Prelude.Just (Metric'Summary v))
                           -> (Data.Monoid.<>)
                                (Data.ProtoLens.Encoding.Bytes.putVarInt 90)
                                ((Prelude..)
                                   (\ bs
                                      -> (Data.Monoid.<>)
                                           (Data.ProtoLens.Encoding.Bytes.putVarInt
                                              (Prelude.fromIntegral (Data.ByteString.length bs)))
                                           (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                   Data.ProtoLens.encodeMessage v))
                      (Data.ProtoLens.Encoding.Wire.buildFieldSet
                         (Lens.Family2.view Data.ProtoLens.unknownFields _x)))))
instance Control.DeepSeq.NFData Metric where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Metric'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_Metric'name x__)
                (Control.DeepSeq.deepseq
                   (_Metric'description x__)
                   (Control.DeepSeq.deepseq
                      (_Metric'unit x__)
                      (Control.DeepSeq.deepseq (_Metric'data' x__) ()))))
instance Control.DeepSeq.NFData Metric'Data where
  rnf (Metric'IntGauge x__) = Control.DeepSeq.rnf x__
  rnf (Metric'Gauge x__) = Control.DeepSeq.rnf x__
  rnf (Metric'IntSum x__) = Control.DeepSeq.rnf x__
  rnf (Metric'Sum x__) = Control.DeepSeq.rnf x__
  rnf (Metric'IntHistogram x__) = Control.DeepSeq.rnf x__
  rnf (Metric'Histogram x__) = Control.DeepSeq.rnf x__
  rnf (Metric'ExponentialHistogram x__) = Control.DeepSeq.rnf x__
  rnf (Metric'Summary x__) = Control.DeepSeq.rnf x__
_Metric'IntGauge ::
  Data.ProtoLens.Prism.Prism' Metric'Data IntGauge
_Metric'IntGauge
  = Data.ProtoLens.Prism.prism'
      Metric'IntGauge
      (\ p__
         -> case p__ of
              (Metric'IntGauge p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_Metric'Gauge :: Data.ProtoLens.Prism.Prism' Metric'Data Gauge
_Metric'Gauge
  = Data.ProtoLens.Prism.prism'
      Metric'Gauge
      (\ p__
         -> case p__ of
              (Metric'Gauge p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_Metric'IntSum :: Data.ProtoLens.Prism.Prism' Metric'Data IntSum
_Metric'IntSum
  = Data.ProtoLens.Prism.prism'
      Metric'IntSum
      (\ p__
         -> case p__ of
              (Metric'IntSum p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_Metric'Sum :: Data.ProtoLens.Prism.Prism' Metric'Data Sum
_Metric'Sum
  = Data.ProtoLens.Prism.prism'
      Metric'Sum
      (\ p__
         -> case p__ of
              (Metric'Sum p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_Metric'IntHistogram ::
  Data.ProtoLens.Prism.Prism' Metric'Data IntHistogram
_Metric'IntHistogram
  = Data.ProtoLens.Prism.prism'
      Metric'IntHistogram
      (\ p__
         -> case p__ of
              (Metric'IntHistogram p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_Metric'Histogram ::
  Data.ProtoLens.Prism.Prism' Metric'Data Histogram
_Metric'Histogram
  = Data.ProtoLens.Prism.prism'
      Metric'Histogram
      (\ p__
         -> case p__ of
              (Metric'Histogram p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_Metric'ExponentialHistogram ::
  Data.ProtoLens.Prism.Prism' Metric'Data ExponentialHistogram
_Metric'ExponentialHistogram
  = Data.ProtoLens.Prism.prism'
      Metric'ExponentialHistogram
      (\ p__
         -> case p__ of
              (Metric'ExponentialHistogram p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_Metric'Summary :: Data.ProtoLens.Prism.Prism' Metric'Data Summary
_Metric'Summary
  = Data.ProtoLens.Prism.prism'
      Metric'Summary
      (\ p__
         -> case p__ of
              (Metric'Summary p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.resourceMetrics' @:: Lens' MetricsData [ResourceMetrics]@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.vec'resourceMetrics' @:: Lens' MetricsData (Data.Vector.Vector ResourceMetrics)@ -}
data MetricsData
  = MetricsData'_constructor {_MetricsData'resourceMetrics :: !(Data.Vector.Vector ResourceMetrics),
                              _MetricsData'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show MetricsData where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField MetricsData "resourceMetrics" [ResourceMetrics] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _MetricsData'resourceMetrics
           (\ x__ y__ -> x__ {_MetricsData'resourceMetrics = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField MetricsData "vec'resourceMetrics" (Data.Vector.Vector ResourceMetrics) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _MetricsData'resourceMetrics
           (\ x__ y__ -> x__ {_MetricsData'resourceMetrics = y__}))
        Prelude.id
instance Data.ProtoLens.Message MetricsData where
  messageName _
    = Data.Text.pack "opentelemetry.proto.metrics.v1.MetricsData"
  packedMessageDescriptor _
    = "\n\
      \\vMetricsData\DC2Z\n\
      \\DLEresource_metrics\CAN\SOH \ETX(\v2/.opentelemetry.proto.metrics.v1.ResourceMetricsR\SIresourceMetrics"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        resourceMetrics__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "resource_metrics"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor ResourceMetrics)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"resourceMetrics")) ::
              Data.ProtoLens.FieldDescriptor MetricsData
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, resourceMetrics__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _MetricsData'_unknownFields
        (\ x__ y__ -> x__ {_MetricsData'_unknownFields = y__})
  defMessage
    = MetricsData'_constructor
        {_MetricsData'resourceMetrics = Data.Vector.Generic.empty,
         _MetricsData'_unknownFields = []}
  parseMessage
    = let
        loop ::
          MetricsData
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld ResourceMetrics
             -> Data.ProtoLens.Encoding.Bytes.Parser MetricsData
        loop x mutable'resourceMetrics
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'resourceMetrics <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                  (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                     mutable'resourceMetrics)
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
                              (Data.ProtoLens.Field.field @"vec'resourceMetrics")
                              frozen'resourceMetrics x))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "resource_metrics"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append
                                          mutable'resourceMetrics y)
                                loop x v
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'resourceMetrics
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'resourceMetrics <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                           Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'resourceMetrics)
          "MetricsData"
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
                   (Data.ProtoLens.Field.field @"vec'resourceMetrics") _x))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData MetricsData where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_MetricsData'_unknownFields x__)
             (Control.DeepSeq.deepseq (_MetricsData'resourceMetrics x__) ())
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.attributes' @:: Lens' NumberDataPoint [Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue]@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.vec'attributes' @:: Lens' NumberDataPoint (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.labels' @:: Lens' NumberDataPoint [Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue]@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.vec'labels' @:: Lens' NumberDataPoint (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.startTimeUnixNano' @:: Lens' NumberDataPoint Data.Word.Word64@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.timeUnixNano' @:: Lens' NumberDataPoint Data.Word.Word64@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.exemplars' @:: Lens' NumberDataPoint [Exemplar]@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.vec'exemplars' @:: Lens' NumberDataPoint (Data.Vector.Vector Exemplar)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.flags' @:: Lens' NumberDataPoint Data.Word.Word32@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.maybe'value' @:: Lens' NumberDataPoint (Prelude.Maybe NumberDataPoint'Value)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.maybe'asDouble' @:: Lens' NumberDataPoint (Prelude.Maybe Prelude.Double)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.asDouble' @:: Lens' NumberDataPoint Prelude.Double@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.maybe'asInt' @:: Lens' NumberDataPoint (Prelude.Maybe Data.Int.Int64)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.asInt' @:: Lens' NumberDataPoint Data.Int.Int64@ -}
data NumberDataPoint
  = NumberDataPoint'_constructor {_NumberDataPoint'attributes :: !(Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue),
                                  _NumberDataPoint'labels :: !(Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue),
                                  _NumberDataPoint'startTimeUnixNano :: !Data.Word.Word64,
                                  _NumberDataPoint'timeUnixNano :: !Data.Word.Word64,
                                  _NumberDataPoint'exemplars :: !(Data.Vector.Vector Exemplar),
                                  _NumberDataPoint'flags :: !Data.Word.Word32,
                                  _NumberDataPoint'value :: !(Prelude.Maybe NumberDataPoint'Value),
                                  _NumberDataPoint'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show NumberDataPoint where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
data NumberDataPoint'Value
  = NumberDataPoint'AsDouble !Prelude.Double |
    NumberDataPoint'AsInt !Data.Int.Int64
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
instance Data.ProtoLens.Field.HasField NumberDataPoint "attributes" [Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _NumberDataPoint'attributes
           (\ x__ y__ -> x__ {_NumberDataPoint'attributes = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField NumberDataPoint "vec'attributes" (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _NumberDataPoint'attributes
           (\ x__ y__ -> x__ {_NumberDataPoint'attributes = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField NumberDataPoint "labels" [Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _NumberDataPoint'labels
           (\ x__ y__ -> x__ {_NumberDataPoint'labels = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField NumberDataPoint "vec'labels" (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _NumberDataPoint'labels
           (\ x__ y__ -> x__ {_NumberDataPoint'labels = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField NumberDataPoint "startTimeUnixNano" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _NumberDataPoint'startTimeUnixNano
           (\ x__ y__ -> x__ {_NumberDataPoint'startTimeUnixNano = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField NumberDataPoint "timeUnixNano" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _NumberDataPoint'timeUnixNano
           (\ x__ y__ -> x__ {_NumberDataPoint'timeUnixNano = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField NumberDataPoint "exemplars" [Exemplar] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _NumberDataPoint'exemplars
           (\ x__ y__ -> x__ {_NumberDataPoint'exemplars = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField NumberDataPoint "vec'exemplars" (Data.Vector.Vector Exemplar) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _NumberDataPoint'exemplars
           (\ x__ y__ -> x__ {_NumberDataPoint'exemplars = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField NumberDataPoint "flags" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _NumberDataPoint'flags
           (\ x__ y__ -> x__ {_NumberDataPoint'flags = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField NumberDataPoint "maybe'value" (Prelude.Maybe NumberDataPoint'Value) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _NumberDataPoint'value
           (\ x__ y__ -> x__ {_NumberDataPoint'value = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField NumberDataPoint "maybe'asDouble" (Prelude.Maybe Prelude.Double) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _NumberDataPoint'value
           (\ x__ y__ -> x__ {_NumberDataPoint'value = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (NumberDataPoint'AsDouble x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap NumberDataPoint'AsDouble y__))
instance Data.ProtoLens.Field.HasField NumberDataPoint "asDouble" Prelude.Double where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _NumberDataPoint'value
           (\ x__ y__ -> x__ {_NumberDataPoint'value = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (NumberDataPoint'AsDouble x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap NumberDataPoint'AsDouble y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault))
instance Data.ProtoLens.Field.HasField NumberDataPoint "maybe'asInt" (Prelude.Maybe Data.Int.Int64) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _NumberDataPoint'value
           (\ x__ y__ -> x__ {_NumberDataPoint'value = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (NumberDataPoint'AsInt x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap NumberDataPoint'AsInt y__))
instance Data.ProtoLens.Field.HasField NumberDataPoint "asInt" Data.Int.Int64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _NumberDataPoint'value
           (\ x__ y__ -> x__ {_NumberDataPoint'value = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (NumberDataPoint'AsInt x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap NumberDataPoint'AsInt y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault))
instance Data.ProtoLens.Message NumberDataPoint where
  messageName _
    = Data.Text.pack "opentelemetry.proto.metrics.v1.NumberDataPoint"
  packedMessageDescriptor _
    = "\n\
      \\SINumberDataPoint\DC2G\n\
      \\n\
      \attributes\CAN\a \ETX(\v2'.opentelemetry.proto.common.v1.KeyValueR\n\
      \attributes\DC2I\n\
      \\ACKlabels\CAN\SOH \ETX(\v2-.opentelemetry.proto.common.v1.StringKeyValueR\ACKlabelsB\STX\CAN\SOH\DC2/\n\
      \\DC4start_time_unix_nano\CAN\STX \SOH(\ACKR\DC1startTimeUnixNano\DC2$\n\
      \\SOtime_unix_nano\CAN\ETX \SOH(\ACKR\ftimeUnixNano\DC2\GS\n\
      \\tas_double\CAN\EOT \SOH(\SOHH\NULR\basDouble\DC2\ETB\n\
      \\ACKas_int\CAN\ACK \SOH(\DLEH\NULR\ENQasInt\DC2F\n\
      \\texemplars\CAN\ENQ \ETX(\v2(.opentelemetry.proto.metrics.v1.ExemplarR\texemplars\DC2\DC4\n\
      \\ENQflags\CAN\b \SOH(\rR\ENQflagsB\a\n\
      \\ENQvalue"
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
              Data.ProtoLens.FieldDescriptor NumberDataPoint
        labels__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "labels"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked (Data.ProtoLens.Field.field @"labels")) ::
              Data.ProtoLens.FieldDescriptor NumberDataPoint
        startTimeUnixNano__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "start_time_unix_nano"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Fixed64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"startTimeUnixNano")) ::
              Data.ProtoLens.FieldDescriptor NumberDataPoint
        timeUnixNano__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "time_unix_nano"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Fixed64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"timeUnixNano")) ::
              Data.ProtoLens.FieldDescriptor NumberDataPoint
        exemplars__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "exemplars"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Exemplar)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"exemplars")) ::
              Data.ProtoLens.FieldDescriptor NumberDataPoint
        flags__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "flags"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"flags")) ::
              Data.ProtoLens.FieldDescriptor NumberDataPoint
        asDouble__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "as_double"
              (Data.ProtoLens.ScalarField Data.ProtoLens.DoubleField ::
                 Data.ProtoLens.FieldTypeDescriptor Prelude.Double)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'asDouble")) ::
              Data.ProtoLens.FieldDescriptor NumberDataPoint
        asInt__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "as_int"
              (Data.ProtoLens.ScalarField Data.ProtoLens.SFixed64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int64)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'asInt")) ::
              Data.ProtoLens.FieldDescriptor NumberDataPoint
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 7, attributes__field_descriptor),
           (Data.ProtoLens.Tag 1, labels__field_descriptor),
           (Data.ProtoLens.Tag 2, startTimeUnixNano__field_descriptor),
           (Data.ProtoLens.Tag 3, timeUnixNano__field_descriptor),
           (Data.ProtoLens.Tag 5, exemplars__field_descriptor),
           (Data.ProtoLens.Tag 8, flags__field_descriptor),
           (Data.ProtoLens.Tag 4, asDouble__field_descriptor),
           (Data.ProtoLens.Tag 6, asInt__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _NumberDataPoint'_unknownFields
        (\ x__ y__ -> x__ {_NumberDataPoint'_unknownFields = y__})
  defMessage
    = NumberDataPoint'_constructor
        {_NumberDataPoint'attributes = Data.Vector.Generic.empty,
         _NumberDataPoint'labels = Data.Vector.Generic.empty,
         _NumberDataPoint'startTimeUnixNano = Data.ProtoLens.fieldDefault,
         _NumberDataPoint'timeUnixNano = Data.ProtoLens.fieldDefault,
         _NumberDataPoint'exemplars = Data.Vector.Generic.empty,
         _NumberDataPoint'flags = Data.ProtoLens.fieldDefault,
         _NumberDataPoint'value = Prelude.Nothing,
         _NumberDataPoint'_unknownFields = []}
  parseMessage
    = let
        loop ::
          NumberDataPoint
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue
             -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Exemplar
                -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue
                   -> Data.ProtoLens.Encoding.Bytes.Parser NumberDataPoint
        loop x mutable'attributes mutable'exemplars mutable'labels
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'attributes <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                             (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                mutable'attributes)
                      frozen'exemplars <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                            (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                               mutable'exemplars)
                      frozen'labels <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                         (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                            mutable'labels)
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
                                 (Data.ProtoLens.Field.field @"vec'exemplars") frozen'exemplars
                                 (Lens.Family2.set
                                    (Data.ProtoLens.Field.field @"vec'labels") frozen'labels x))))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        58
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "attributes"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'attributes y)
                                loop x v mutable'exemplars mutable'labels
                        10
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "labels"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'labels y)
                                loop x mutable'attributes mutable'exemplars v
                        17
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getFixed64
                                       "start_time_unix_nano"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"startTimeUnixNano") y x)
                                  mutable'attributes mutable'exemplars mutable'labels
                        25
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getFixed64 "time_unix_nano"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"timeUnixNano") y x)
                                  mutable'attributes mutable'exemplars mutable'labels
                        42
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "exemplars"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'exemplars y)
                                loop x mutable'attributes v mutable'labels
                        64
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "flags"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"flags") y x)
                                  mutable'attributes mutable'exemplars mutable'labels
                        33
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Data.ProtoLens.Encoding.Bytes.wordToDouble
                                          Data.ProtoLens.Encoding.Bytes.getFixed64)
                                       "as_double"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"asDouble") y x)
                                  mutable'attributes mutable'exemplars mutable'labels
                        49
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getFixed64)
                                       "as_int"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"asInt") y x)
                                  mutable'attributes mutable'exemplars mutable'labels
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'attributes mutable'exemplars mutable'labels
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'attributes <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                      Data.ProtoLens.Encoding.Growing.new
              mutable'exemplars <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                     Data.ProtoLens.Encoding.Growing.new
              mutable'labels <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                  Data.ProtoLens.Encoding.Growing.new
              loop
                Data.ProtoLens.defMessage mutable'attributes mutable'exemplars
                mutable'labels)
          "NumberDataPoint"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                (\ _v
                   -> (Data.Monoid.<>)
                        (Data.ProtoLens.Encoding.Bytes.putVarInt 58)
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
                   (Lens.Family2.view (Data.ProtoLens.Field.field @"vec'labels") _x))
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
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 17)
                            (Data.ProtoLens.Encoding.Bytes.putFixed64 _v))
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
                                       Data.ProtoLens.encodeMessage _v))
                            (Lens.Family2.view
                               (Data.ProtoLens.Field.field @"vec'exemplars") _x))
                         ((Data.Monoid.<>)
                            (let
                               _v = Lens.Family2.view (Data.ProtoLens.Field.field @"flags") _x
                             in
                               if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                   Data.Monoid.mempty
                               else
                                   (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt 64)
                                     ((Prelude..)
                                        Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral
                                        _v))
                            ((Data.Monoid.<>)
                               (case
                                    Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'value") _x
                                of
                                  Prelude.Nothing -> Data.Monoid.mempty
                                  (Prelude.Just (NumberDataPoint'AsDouble v))
                                    -> (Data.Monoid.<>)
                                         (Data.ProtoLens.Encoding.Bytes.putVarInt 33)
                                         ((Prelude..)
                                            Data.ProtoLens.Encoding.Bytes.putFixed64
                                            Data.ProtoLens.Encoding.Bytes.doubleToWord v)
                                  (Prelude.Just (NumberDataPoint'AsInt v))
                                    -> (Data.Monoid.<>)
                                         (Data.ProtoLens.Encoding.Bytes.putVarInt 49)
                                         ((Prelude..)
                                            Data.ProtoLens.Encoding.Bytes.putFixed64
                                            Prelude.fromIntegral v))
                               (Data.ProtoLens.Encoding.Wire.buildFieldSet
                                  (Lens.Family2.view Data.ProtoLens.unknownFields _x))))))))
instance Control.DeepSeq.NFData NumberDataPoint where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_NumberDataPoint'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_NumberDataPoint'attributes x__)
                (Control.DeepSeq.deepseq
                   (_NumberDataPoint'labels x__)
                   (Control.DeepSeq.deepseq
                      (_NumberDataPoint'startTimeUnixNano x__)
                      (Control.DeepSeq.deepseq
                         (_NumberDataPoint'timeUnixNano x__)
                         (Control.DeepSeq.deepseq
                            (_NumberDataPoint'exemplars x__)
                            (Control.DeepSeq.deepseq
                               (_NumberDataPoint'flags x__)
                               (Control.DeepSeq.deepseq (_NumberDataPoint'value x__) ())))))))
instance Control.DeepSeq.NFData NumberDataPoint'Value where
  rnf (NumberDataPoint'AsDouble x__) = Control.DeepSeq.rnf x__
  rnf (NumberDataPoint'AsInt x__) = Control.DeepSeq.rnf x__
_NumberDataPoint'AsDouble ::
  Data.ProtoLens.Prism.Prism' NumberDataPoint'Value Prelude.Double
_NumberDataPoint'AsDouble
  = Data.ProtoLens.Prism.prism'
      NumberDataPoint'AsDouble
      (\ p__
         -> case p__ of
              (NumberDataPoint'AsDouble p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_NumberDataPoint'AsInt ::
  Data.ProtoLens.Prism.Prism' NumberDataPoint'Value Data.Int.Int64
_NumberDataPoint'AsInt
  = Data.ProtoLens.Prism.prism'
      NumberDataPoint'AsInt
      (\ p__
         -> case p__ of
              (NumberDataPoint'AsInt p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.resource' @:: Lens' ResourceMetrics Proto.Opentelemetry.Proto.Resource.V1.Resource.Resource@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.maybe'resource' @:: Lens' ResourceMetrics (Prelude.Maybe Proto.Opentelemetry.Proto.Resource.V1.Resource.Resource)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.instrumentationLibraryMetrics' @:: Lens' ResourceMetrics [InstrumentationLibraryMetrics]@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.vec'instrumentationLibraryMetrics' @:: Lens' ResourceMetrics (Data.Vector.Vector InstrumentationLibraryMetrics)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.schemaUrl' @:: Lens' ResourceMetrics Data.Text.Text@ -}
data ResourceMetrics
  = ResourceMetrics'_constructor {_ResourceMetrics'resource :: !(Prelude.Maybe Proto.Opentelemetry.Proto.Resource.V1.Resource.Resource),
                                  _ResourceMetrics'instrumentationLibraryMetrics :: !(Data.Vector.Vector InstrumentationLibraryMetrics),
                                  _ResourceMetrics'schemaUrl :: !Data.Text.Text,
                                  _ResourceMetrics'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show ResourceMetrics where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField ResourceMetrics "resource" Proto.Opentelemetry.Proto.Resource.V1.Resource.Resource where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ResourceMetrics'resource
           (\ x__ y__ -> x__ {_ResourceMetrics'resource = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField ResourceMetrics "maybe'resource" (Prelude.Maybe Proto.Opentelemetry.Proto.Resource.V1.Resource.Resource) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ResourceMetrics'resource
           (\ x__ y__ -> x__ {_ResourceMetrics'resource = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ResourceMetrics "instrumentationLibraryMetrics" [InstrumentationLibraryMetrics] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ResourceMetrics'instrumentationLibraryMetrics
           (\ x__ y__
              -> x__ {_ResourceMetrics'instrumentationLibraryMetrics = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField ResourceMetrics "vec'instrumentationLibraryMetrics" (Data.Vector.Vector InstrumentationLibraryMetrics) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ResourceMetrics'instrumentationLibraryMetrics
           (\ x__ y__
              -> x__ {_ResourceMetrics'instrumentationLibraryMetrics = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField ResourceMetrics "schemaUrl" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ResourceMetrics'schemaUrl
           (\ x__ y__ -> x__ {_ResourceMetrics'schemaUrl = y__}))
        Prelude.id
instance Data.ProtoLens.Message ResourceMetrics where
  messageName _
    = Data.Text.pack "opentelemetry.proto.metrics.v1.ResourceMetrics"
  packedMessageDescriptor _
    = "\n\
      \\SIResourceMetrics\DC2E\n\
      \\bresource\CAN\SOH \SOH(\v2).opentelemetry.proto.resource.v1.ResourceR\bresource\DC2\133\SOH\n\
      \\USinstrumentation_library_metrics\CAN\STX \ETX(\v2=.opentelemetry.proto.metrics.v1.InstrumentationLibraryMetricsR\GSinstrumentationLibraryMetrics\DC2\GS\n\
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
              Data.ProtoLens.FieldDescriptor ResourceMetrics
        instrumentationLibraryMetrics__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "instrumentation_library_metrics"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor InstrumentationLibraryMetrics)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"instrumentationLibraryMetrics")) ::
              Data.ProtoLens.FieldDescriptor ResourceMetrics
        schemaUrl__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "schema_url"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"schemaUrl")) ::
              Data.ProtoLens.FieldDescriptor ResourceMetrics
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, resource__field_descriptor),
           (Data.ProtoLens.Tag 2, 
            instrumentationLibraryMetrics__field_descriptor),
           (Data.ProtoLens.Tag 3, schemaUrl__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _ResourceMetrics'_unknownFields
        (\ x__ y__ -> x__ {_ResourceMetrics'_unknownFields = y__})
  defMessage
    = ResourceMetrics'_constructor
        {_ResourceMetrics'resource = Prelude.Nothing,
         _ResourceMetrics'instrumentationLibraryMetrics = Data.Vector.Generic.empty,
         _ResourceMetrics'schemaUrl = Data.ProtoLens.fieldDefault,
         _ResourceMetrics'_unknownFields = []}
  parseMessage
    = let
        loop ::
          ResourceMetrics
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld InstrumentationLibraryMetrics
             -> Data.ProtoLens.Encoding.Bytes.Parser ResourceMetrics
        loop x mutable'instrumentationLibraryMetrics
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'instrumentationLibraryMetrics <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                                (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                                   mutable'instrumentationLibraryMetrics)
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
                              (Data.ProtoLens.Field.field @"vec'instrumentationLibraryMetrics")
                              frozen'instrumentationLibraryMetrics x))
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
                                  mutable'instrumentationLibraryMetrics
                        18
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "instrumentation_library_metrics"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append
                                          mutable'instrumentationLibraryMetrics y)
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
                                  mutable'instrumentationLibraryMetrics
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'instrumentationLibraryMetrics
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'instrumentationLibraryMetrics <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                         Data.ProtoLens.Encoding.Growing.new
              loop
                Data.ProtoLens.defMessage mutable'instrumentationLibraryMetrics)
          "ResourceMetrics"
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
                      (Data.ProtoLens.Field.field @"vec'instrumentationLibraryMetrics")
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
instance Control.DeepSeq.NFData ResourceMetrics where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_ResourceMetrics'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_ResourceMetrics'resource x__)
                (Control.DeepSeq.deepseq
                   (_ResourceMetrics'instrumentationLibraryMetrics x__)
                   (Control.DeepSeq.deepseq (_ResourceMetrics'schemaUrl x__) ())))
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.dataPoints' @:: Lens' Sum [NumberDataPoint]@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.vec'dataPoints' @:: Lens' Sum (Data.Vector.Vector NumberDataPoint)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.aggregationTemporality' @:: Lens' Sum AggregationTemporality@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.isMonotonic' @:: Lens' Sum Prelude.Bool@ -}
data Sum
  = Sum'_constructor {_Sum'dataPoints :: !(Data.Vector.Vector NumberDataPoint),
                      _Sum'aggregationTemporality :: !AggregationTemporality,
                      _Sum'isMonotonic :: !Prelude.Bool,
                      _Sum'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show Sum where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField Sum "dataPoints" [NumberDataPoint] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Sum'dataPoints (\ x__ y__ -> x__ {_Sum'dataPoints = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField Sum "vec'dataPoints" (Data.Vector.Vector NumberDataPoint) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Sum'dataPoints (\ x__ y__ -> x__ {_Sum'dataPoints = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Sum "aggregationTemporality" AggregationTemporality where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Sum'aggregationTemporality
           (\ x__ y__ -> x__ {_Sum'aggregationTemporality = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Sum "isMonotonic" Prelude.Bool where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Sum'isMonotonic (\ x__ y__ -> x__ {_Sum'isMonotonic = y__}))
        Prelude.id
instance Data.ProtoLens.Message Sum where
  messageName _ = Data.Text.pack "opentelemetry.proto.metrics.v1.Sum"
  packedMessageDescriptor _
    = "\n\
      \\ETXSum\DC2P\n\
      \\vdata_points\CAN\SOH \ETX(\v2/.opentelemetry.proto.metrics.v1.NumberDataPointR\n\
      \dataPoints\DC2o\n\
      \\ETBaggregation_temporality\CAN\STX \SOH(\SO26.opentelemetry.proto.metrics.v1.AggregationTemporalityR\SYNaggregationTemporality\DC2!\n\
      \\fis_monotonic\CAN\ETX \SOH(\bR\visMonotonic"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        dataPoints__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "data_points"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor NumberDataPoint)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"dataPoints")) ::
              Data.ProtoLens.FieldDescriptor Sum
        aggregationTemporality__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "aggregation_temporality"
              (Data.ProtoLens.ScalarField Data.ProtoLens.EnumField ::
                 Data.ProtoLens.FieldTypeDescriptor AggregationTemporality)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"aggregationTemporality")) ::
              Data.ProtoLens.FieldDescriptor Sum
        isMonotonic__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "is_monotonic"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BoolField ::
                 Data.ProtoLens.FieldTypeDescriptor Prelude.Bool)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"isMonotonic")) ::
              Data.ProtoLens.FieldDescriptor Sum
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, dataPoints__field_descriptor),
           (Data.ProtoLens.Tag 2, aggregationTemporality__field_descriptor),
           (Data.ProtoLens.Tag 3, isMonotonic__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Sum'_unknownFields (\ x__ y__ -> x__ {_Sum'_unknownFields = y__})
  defMessage
    = Sum'_constructor
        {_Sum'dataPoints = Data.Vector.Generic.empty,
         _Sum'aggregationTemporality = Data.ProtoLens.fieldDefault,
         _Sum'isMonotonic = Data.ProtoLens.fieldDefault,
         _Sum'_unknownFields = []}
  parseMessage
    = let
        loop ::
          Sum
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld NumberDataPoint
             -> Data.ProtoLens.Encoding.Bytes.Parser Sum
        loop x mutable'dataPoints
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'dataPoints <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                             (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                mutable'dataPoints)
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
                              (Data.ProtoLens.Field.field @"vec'dataPoints") frozen'dataPoints
                              x))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "data_points"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'dataPoints y)
                                loop x v
                        16
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
                                  mutable'dataPoints
                        24
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          ((Prelude./=) 0) Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "is_monotonic"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"isMonotonic") y x)
                                  mutable'dataPoints
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'dataPoints
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'dataPoints <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                      Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'dataPoints)
          "Sum"
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
                   (Data.ProtoLens.Field.field @"vec'dataPoints") _x))
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
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                         ((Prelude..)
                            ((Prelude..)
                               Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral)
                            Prelude.fromEnum _v))
                ((Data.Monoid.<>)
                   (let
                      _v
                        = Lens.Family2.view (Data.ProtoLens.Field.field @"isMonotonic") _x
                    in
                      if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                          Data.Monoid.mempty
                      else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 24)
                            ((Prelude..)
                               Data.ProtoLens.Encoding.Bytes.putVarInt (\ b -> if b then 1 else 0)
                               _v))
                   (Data.ProtoLens.Encoding.Wire.buildFieldSet
                      (Lens.Family2.view Data.ProtoLens.unknownFields _x))))
instance Control.DeepSeq.NFData Sum where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Sum'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_Sum'dataPoints x__)
                (Control.DeepSeq.deepseq
                   (_Sum'aggregationTemporality x__)
                   (Control.DeepSeq.deepseq (_Sum'isMonotonic x__) ())))
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.dataPoints' @:: Lens' Summary [SummaryDataPoint]@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.vec'dataPoints' @:: Lens' Summary (Data.Vector.Vector SummaryDataPoint)@ -}
data Summary
  = Summary'_constructor {_Summary'dataPoints :: !(Data.Vector.Vector SummaryDataPoint),
                          _Summary'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show Summary where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField Summary "dataPoints" [SummaryDataPoint] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Summary'dataPoints (\ x__ y__ -> x__ {_Summary'dataPoints = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField Summary "vec'dataPoints" (Data.Vector.Vector SummaryDataPoint) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Summary'dataPoints (\ x__ y__ -> x__ {_Summary'dataPoints = y__}))
        Prelude.id
instance Data.ProtoLens.Message Summary where
  messageName _
    = Data.Text.pack "opentelemetry.proto.metrics.v1.Summary"
  packedMessageDescriptor _
    = "\n\
      \\aSummary\DC2Q\n\
      \\vdata_points\CAN\SOH \ETX(\v20.opentelemetry.proto.metrics.v1.SummaryDataPointR\n\
      \dataPoints"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        dataPoints__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "data_points"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor SummaryDataPoint)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"dataPoints")) ::
              Data.ProtoLens.FieldDescriptor Summary
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, dataPoints__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Summary'_unknownFields
        (\ x__ y__ -> x__ {_Summary'_unknownFields = y__})
  defMessage
    = Summary'_constructor
        {_Summary'dataPoints = Data.Vector.Generic.empty,
         _Summary'_unknownFields = []}
  parseMessage
    = let
        loop ::
          Summary
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld SummaryDataPoint
             -> Data.ProtoLens.Encoding.Bytes.Parser Summary
        loop x mutable'dataPoints
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'dataPoints <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                             (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                mutable'dataPoints)
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
                              (Data.ProtoLens.Field.field @"vec'dataPoints") frozen'dataPoints
                              x))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "data_points"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'dataPoints y)
                                loop x v
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'dataPoints
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'dataPoints <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                      Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'dataPoints)
          "Summary"
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
                   (Data.ProtoLens.Field.field @"vec'dataPoints") _x))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData Summary where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Summary'_unknownFields x__)
             (Control.DeepSeq.deepseq (_Summary'dataPoints x__) ())
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.attributes' @:: Lens' SummaryDataPoint [Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue]@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.vec'attributes' @:: Lens' SummaryDataPoint (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.labels' @:: Lens' SummaryDataPoint [Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue]@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.vec'labels' @:: Lens' SummaryDataPoint (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.startTimeUnixNano' @:: Lens' SummaryDataPoint Data.Word.Word64@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.timeUnixNano' @:: Lens' SummaryDataPoint Data.Word.Word64@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.count' @:: Lens' SummaryDataPoint Data.Word.Word64@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.sum' @:: Lens' SummaryDataPoint Prelude.Double@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.quantileValues' @:: Lens' SummaryDataPoint [SummaryDataPoint'ValueAtQuantile]@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.vec'quantileValues' @:: Lens' SummaryDataPoint (Data.Vector.Vector SummaryDataPoint'ValueAtQuantile)@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.flags' @:: Lens' SummaryDataPoint Data.Word.Word32@ -}
data SummaryDataPoint
  = SummaryDataPoint'_constructor {_SummaryDataPoint'attributes :: !(Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue),
                                   _SummaryDataPoint'labels :: !(Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue),
                                   _SummaryDataPoint'startTimeUnixNano :: !Data.Word.Word64,
                                   _SummaryDataPoint'timeUnixNano :: !Data.Word.Word64,
                                   _SummaryDataPoint'count :: !Data.Word.Word64,
                                   _SummaryDataPoint'sum :: !Prelude.Double,
                                   _SummaryDataPoint'quantileValues :: !(Data.Vector.Vector SummaryDataPoint'ValueAtQuantile),
                                   _SummaryDataPoint'flags :: !Data.Word.Word32,
                                   _SummaryDataPoint'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show SummaryDataPoint where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField SummaryDataPoint "attributes" [Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _SummaryDataPoint'attributes
           (\ x__ y__ -> x__ {_SummaryDataPoint'attributes = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField SummaryDataPoint "vec'attributes" (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _SummaryDataPoint'attributes
           (\ x__ y__ -> x__ {_SummaryDataPoint'attributes = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField SummaryDataPoint "labels" [Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _SummaryDataPoint'labels
           (\ x__ y__ -> x__ {_SummaryDataPoint'labels = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField SummaryDataPoint "vec'labels" (Data.Vector.Vector Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _SummaryDataPoint'labels
           (\ x__ y__ -> x__ {_SummaryDataPoint'labels = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField SummaryDataPoint "startTimeUnixNano" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _SummaryDataPoint'startTimeUnixNano
           (\ x__ y__ -> x__ {_SummaryDataPoint'startTimeUnixNano = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField SummaryDataPoint "timeUnixNano" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _SummaryDataPoint'timeUnixNano
           (\ x__ y__ -> x__ {_SummaryDataPoint'timeUnixNano = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField SummaryDataPoint "count" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _SummaryDataPoint'count
           (\ x__ y__ -> x__ {_SummaryDataPoint'count = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField SummaryDataPoint "sum" Prelude.Double where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _SummaryDataPoint'sum
           (\ x__ y__ -> x__ {_SummaryDataPoint'sum = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField SummaryDataPoint "quantileValues" [SummaryDataPoint'ValueAtQuantile] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _SummaryDataPoint'quantileValues
           (\ x__ y__ -> x__ {_SummaryDataPoint'quantileValues = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField SummaryDataPoint "vec'quantileValues" (Data.Vector.Vector SummaryDataPoint'ValueAtQuantile) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _SummaryDataPoint'quantileValues
           (\ x__ y__ -> x__ {_SummaryDataPoint'quantileValues = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField SummaryDataPoint "flags" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _SummaryDataPoint'flags
           (\ x__ y__ -> x__ {_SummaryDataPoint'flags = y__}))
        Prelude.id
instance Data.ProtoLens.Message SummaryDataPoint where
  messageName _
    = Data.Text.pack "opentelemetry.proto.metrics.v1.SummaryDataPoint"
  packedMessageDescriptor _
    = "\n\
      \\DLESummaryDataPoint\DC2G\n\
      \\n\
      \attributes\CAN\a \ETX(\v2'.opentelemetry.proto.common.v1.KeyValueR\n\
      \attributes\DC2I\n\
      \\ACKlabels\CAN\SOH \ETX(\v2-.opentelemetry.proto.common.v1.StringKeyValueR\ACKlabelsB\STX\CAN\SOH\DC2/\n\
      \\DC4start_time_unix_nano\CAN\STX \SOH(\ACKR\DC1startTimeUnixNano\DC2$\n\
      \\SOtime_unix_nano\CAN\ETX \SOH(\ACKR\ftimeUnixNano\DC2\DC4\n\
      \\ENQcount\CAN\EOT \SOH(\ACKR\ENQcount\DC2\DLE\n\
      \\ETXsum\CAN\ENQ \SOH(\SOHR\ETXsum\DC2i\n\
      \\SIquantile_values\CAN\ACK \ETX(\v2@.opentelemetry.proto.metrics.v1.SummaryDataPoint.ValueAtQuantileR\SOquantileValues\DC2\DC4\n\
      \\ENQflags\CAN\b \SOH(\rR\ENQflags\SUBC\n\
      \\SIValueAtQuantile\DC2\SUB\n\
      \\bquantile\CAN\SOH \SOH(\SOHR\bquantile\DC2\DC4\n\
      \\ENQvalue\CAN\STX \SOH(\SOHR\ENQvalue"
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
              Data.ProtoLens.FieldDescriptor SummaryDataPoint
        labels__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "labels"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked (Data.ProtoLens.Field.field @"labels")) ::
              Data.ProtoLens.FieldDescriptor SummaryDataPoint
        startTimeUnixNano__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "start_time_unix_nano"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Fixed64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"startTimeUnixNano")) ::
              Data.ProtoLens.FieldDescriptor SummaryDataPoint
        timeUnixNano__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "time_unix_nano"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Fixed64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"timeUnixNano")) ::
              Data.ProtoLens.FieldDescriptor SummaryDataPoint
        count__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "count"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Fixed64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"count")) ::
              Data.ProtoLens.FieldDescriptor SummaryDataPoint
        sum__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "sum"
              (Data.ProtoLens.ScalarField Data.ProtoLens.DoubleField ::
                 Data.ProtoLens.FieldTypeDescriptor Prelude.Double)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"sum")) ::
              Data.ProtoLens.FieldDescriptor SummaryDataPoint
        quantileValues__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "quantile_values"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor SummaryDataPoint'ValueAtQuantile)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"quantileValues")) ::
              Data.ProtoLens.FieldDescriptor SummaryDataPoint
        flags__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "flags"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"flags")) ::
              Data.ProtoLens.FieldDescriptor SummaryDataPoint
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 7, attributes__field_descriptor),
           (Data.ProtoLens.Tag 1, labels__field_descriptor),
           (Data.ProtoLens.Tag 2, startTimeUnixNano__field_descriptor),
           (Data.ProtoLens.Tag 3, timeUnixNano__field_descriptor),
           (Data.ProtoLens.Tag 4, count__field_descriptor),
           (Data.ProtoLens.Tag 5, sum__field_descriptor),
           (Data.ProtoLens.Tag 6, quantileValues__field_descriptor),
           (Data.ProtoLens.Tag 8, flags__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _SummaryDataPoint'_unknownFields
        (\ x__ y__ -> x__ {_SummaryDataPoint'_unknownFields = y__})
  defMessage
    = SummaryDataPoint'_constructor
        {_SummaryDataPoint'attributes = Data.Vector.Generic.empty,
         _SummaryDataPoint'labels = Data.Vector.Generic.empty,
         _SummaryDataPoint'startTimeUnixNano = Data.ProtoLens.fieldDefault,
         _SummaryDataPoint'timeUnixNano = Data.ProtoLens.fieldDefault,
         _SummaryDataPoint'count = Data.ProtoLens.fieldDefault,
         _SummaryDataPoint'sum = Data.ProtoLens.fieldDefault,
         _SummaryDataPoint'quantileValues = Data.Vector.Generic.empty,
         _SummaryDataPoint'flags = Data.ProtoLens.fieldDefault,
         _SummaryDataPoint'_unknownFields = []}
  parseMessage
    = let
        loop ::
          SummaryDataPoint
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Proto.Opentelemetry.Proto.Common.V1.Common.KeyValue
             -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Proto.Opentelemetry.Proto.Common.V1.Common.StringKeyValue
                -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld SummaryDataPoint'ValueAtQuantile
                   -> Data.ProtoLens.Encoding.Bytes.Parser SummaryDataPoint
        loop x mutable'attributes mutable'labels mutable'quantileValues
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'attributes <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                             (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                mutable'attributes)
                      frozen'labels <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                         (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                            mutable'labels)
                      frozen'quantileValues <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                 (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                    mutable'quantileValues)
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
                                 (Data.ProtoLens.Field.field @"vec'labels") frozen'labels
                                 (Lens.Family2.set
                                    (Data.ProtoLens.Field.field @"vec'quantileValues")
                                    frozen'quantileValues x))))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        58
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "attributes"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'attributes y)
                                loop x v mutable'labels mutable'quantileValues
                        10
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "labels"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'labels y)
                                loop x mutable'attributes v mutable'quantileValues
                        17
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getFixed64
                                       "start_time_unix_nano"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"startTimeUnixNano") y x)
                                  mutable'attributes mutable'labels mutable'quantileValues
                        25
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getFixed64 "time_unix_nano"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"timeUnixNano") y x)
                                  mutable'attributes mutable'labels mutable'quantileValues
                        33
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getFixed64 "count"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"count") y x)
                                  mutable'attributes mutable'labels mutable'quantileValues
                        41
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Data.ProtoLens.Encoding.Bytes.wordToDouble
                                          Data.ProtoLens.Encoding.Bytes.getFixed64)
                                       "sum"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"sum") y x)
                                  mutable'attributes mutable'labels mutable'quantileValues
                        50
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "quantile_values"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append
                                          mutable'quantileValues y)
                                loop x mutable'attributes mutable'labels v
                        64
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "flags"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"flags") y x)
                                  mutable'attributes mutable'labels mutable'quantileValues
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'attributes mutable'labels mutable'quantileValues
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'attributes <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                      Data.ProtoLens.Encoding.Growing.new
              mutable'labels <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                  Data.ProtoLens.Encoding.Growing.new
              mutable'quantileValues <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                          Data.ProtoLens.Encoding.Growing.new
              loop
                Data.ProtoLens.defMessage mutable'attributes mutable'labels
                mutable'quantileValues)
          "SummaryDataPoint"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                (\ _v
                   -> (Data.Monoid.<>)
                        (Data.ProtoLens.Encoding.Bytes.putVarInt 58)
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
                   (Lens.Family2.view (Data.ProtoLens.Field.field @"vec'labels") _x))
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
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 17)
                            (Data.ProtoLens.Encoding.Bytes.putFixed64 _v))
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
                            _v = Lens.Family2.view (Data.ProtoLens.Field.field @"count") _x
                          in
                            if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                Data.Monoid.mempty
                            else
                                (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt 33)
                                  (Data.ProtoLens.Encoding.Bytes.putFixed64 _v))
                         ((Data.Monoid.<>)
                            (let _v = Lens.Family2.view (Data.ProtoLens.Field.field @"sum") _x
                             in
                               if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                   Data.Monoid.mempty
                               else
                                   (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt 41)
                                     ((Prelude..)
                                        Data.ProtoLens.Encoding.Bytes.putFixed64
                                        Data.ProtoLens.Encoding.Bytes.doubleToWord _v))
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
                                     (Data.ProtoLens.Field.field @"vec'quantileValues") _x))
                               ((Data.Monoid.<>)
                                  (let
                                     _v = Lens.Family2.view (Data.ProtoLens.Field.field @"flags") _x
                                   in
                                     if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                                         Data.Monoid.mempty
                                     else
                                         (Data.Monoid.<>)
                                           (Data.ProtoLens.Encoding.Bytes.putVarInt 64)
                                           ((Prelude..)
                                              Data.ProtoLens.Encoding.Bytes.putVarInt
                                              Prelude.fromIntegral _v))
                                  (Data.ProtoLens.Encoding.Wire.buildFieldSet
                                     (Lens.Family2.view Data.ProtoLens.unknownFields _x)))))))))
instance Control.DeepSeq.NFData SummaryDataPoint where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_SummaryDataPoint'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_SummaryDataPoint'attributes x__)
                (Control.DeepSeq.deepseq
                   (_SummaryDataPoint'labels x__)
                   (Control.DeepSeq.deepseq
                      (_SummaryDataPoint'startTimeUnixNano x__)
                      (Control.DeepSeq.deepseq
                         (_SummaryDataPoint'timeUnixNano x__)
                         (Control.DeepSeq.deepseq
                            (_SummaryDataPoint'count x__)
                            (Control.DeepSeq.deepseq
                               (_SummaryDataPoint'sum x__)
                               (Control.DeepSeq.deepseq
                                  (_SummaryDataPoint'quantileValues x__)
                                  (Control.DeepSeq.deepseq (_SummaryDataPoint'flags x__) ()))))))))
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.quantile' @:: Lens' SummaryDataPoint'ValueAtQuantile Prelude.Double@
         * 'Proto.Opentelemetry.Proto.Metrics.V1.Metrics_Fields.value' @:: Lens' SummaryDataPoint'ValueAtQuantile Prelude.Double@ -}
data SummaryDataPoint'ValueAtQuantile
  = SummaryDataPoint'ValueAtQuantile'_constructor {_SummaryDataPoint'ValueAtQuantile'quantile :: !Prelude.Double,
                                                   _SummaryDataPoint'ValueAtQuantile'value :: !Prelude.Double,
                                                   _SummaryDataPoint'ValueAtQuantile'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show SummaryDataPoint'ValueAtQuantile where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField SummaryDataPoint'ValueAtQuantile "quantile" Prelude.Double where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _SummaryDataPoint'ValueAtQuantile'quantile
           (\ x__ y__
              -> x__ {_SummaryDataPoint'ValueAtQuantile'quantile = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField SummaryDataPoint'ValueAtQuantile "value" Prelude.Double where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _SummaryDataPoint'ValueAtQuantile'value
           (\ x__ y__ -> x__ {_SummaryDataPoint'ValueAtQuantile'value = y__}))
        Prelude.id
instance Data.ProtoLens.Message SummaryDataPoint'ValueAtQuantile where
  messageName _
    = Data.Text.pack
        "opentelemetry.proto.metrics.v1.SummaryDataPoint.ValueAtQuantile"
  packedMessageDescriptor _
    = "\n\
      \\SIValueAtQuantile\DC2\SUB\n\
      \\bquantile\CAN\SOH \SOH(\SOHR\bquantile\DC2\DC4\n\
      \\ENQvalue\CAN\STX \SOH(\SOHR\ENQvalue"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        quantile__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "quantile"
              (Data.ProtoLens.ScalarField Data.ProtoLens.DoubleField ::
                 Data.ProtoLens.FieldTypeDescriptor Prelude.Double)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"quantile")) ::
              Data.ProtoLens.FieldDescriptor SummaryDataPoint'ValueAtQuantile
        value__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "value"
              (Data.ProtoLens.ScalarField Data.ProtoLens.DoubleField ::
                 Data.ProtoLens.FieldTypeDescriptor Prelude.Double)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"value")) ::
              Data.ProtoLens.FieldDescriptor SummaryDataPoint'ValueAtQuantile
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, quantile__field_descriptor),
           (Data.ProtoLens.Tag 2, value__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _SummaryDataPoint'ValueAtQuantile'_unknownFields
        (\ x__ y__
           -> x__ {_SummaryDataPoint'ValueAtQuantile'_unknownFields = y__})
  defMessage
    = SummaryDataPoint'ValueAtQuantile'_constructor
        {_SummaryDataPoint'ValueAtQuantile'quantile = Data.ProtoLens.fieldDefault,
         _SummaryDataPoint'ValueAtQuantile'value = Data.ProtoLens.fieldDefault,
         _SummaryDataPoint'ValueAtQuantile'_unknownFields = []}
  parseMessage
    = let
        loop ::
          SummaryDataPoint'ValueAtQuantile
          -> Data.ProtoLens.Encoding.Bytes.Parser SummaryDataPoint'ValueAtQuantile
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
                        9 -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Data.ProtoLens.Encoding.Bytes.wordToDouble
                                          Data.ProtoLens.Encoding.Bytes.getFixed64)
                                       "quantile"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"quantile") y x)
                        17
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Data.ProtoLens.Encoding.Bytes.wordToDouble
                                          Data.ProtoLens.Encoding.Bytes.getFixed64)
                                       "value"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"value") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "ValueAtQuantile"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v = Lens.Family2.view (Data.ProtoLens.Field.field @"quantile") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 9)
                      ((Prelude..)
                         Data.ProtoLens.Encoding.Bytes.putFixed64
                         Data.ProtoLens.Encoding.Bytes.doubleToWord _v))
             ((Data.Monoid.<>)
                (let
                   _v = Lens.Family2.view (Data.ProtoLens.Field.field @"value") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 17)
                         ((Prelude..)
                            Data.ProtoLens.Encoding.Bytes.putFixed64
                            Data.ProtoLens.Encoding.Bytes.doubleToWord _v))
                (Data.ProtoLens.Encoding.Wire.buildFieldSet
                   (Lens.Family2.view Data.ProtoLens.unknownFields _x)))
instance Control.DeepSeq.NFData SummaryDataPoint'ValueAtQuantile where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_SummaryDataPoint'ValueAtQuantile'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_SummaryDataPoint'ValueAtQuantile'quantile x__)
                (Control.DeepSeq.deepseq
                   (_SummaryDataPoint'ValueAtQuantile'value x__) ()))
packedFileDescriptor :: Data.ByteString.ByteString
packedFileDescriptor
  = "\n\
    \,opentelemetry/proto/metrics/v1/metrics.proto\DC2\RSopentelemetry.proto.metrics.v1\SUB*opentelemetry/proto/common/v1/common.proto\SUB.opentelemetry/proto/resource/v1/resource.proto\"i\n\
    \\vMetricsData\DC2Z\n\
    \\DLEresource_metrics\CAN\SOH \ETX(\v2/.opentelemetry.proto.metrics.v1.ResourceMetricsR\SIresourceMetrics\"\255\SOH\n\
    \\SIResourceMetrics\DC2E\n\
    \\bresource\CAN\SOH \SOH(\v2).opentelemetry.proto.resource.v1.ResourceR\bresource\DC2\133\SOH\n\
    \\USinstrumentation_library_metrics\CAN\STX \ETX(\v2=.opentelemetry.proto.metrics.v1.InstrumentationLibraryMetricsR\GSinstrumentationLibraryMetrics\DC2\GS\n\
    \\n\
    \schema_url\CAN\ETX \SOH(\tR\tschemaUrl\"\240\SOH\n\
    \\GSInstrumentationLibraryMetrics\DC2n\n\
    \\ETBinstrumentation_library\CAN\SOH \SOH(\v25.opentelemetry.proto.common.v1.InstrumentationLibraryR\SYNinstrumentationLibrary\DC2@\n\
    \\ametrics\CAN\STX \ETX(\v2&.opentelemetry.proto.metrics.v1.MetricR\ametrics\DC2\GS\n\
    \\n\
    \schema_url\CAN\ETX \SOH(\tR\tschemaUrl\"\188\ENQ\n\
    \\ACKMetric\DC2\DC2\n\
    \\EOTname\CAN\SOH \SOH(\tR\EOTname\DC2 \n\
    \\vdescription\CAN\STX \SOH(\tR\vdescription\DC2\DC2\n\
    \\EOTunit\CAN\ETX \SOH(\tR\EOTunit\DC2K\n\
    \\tint_gauge\CAN\EOT \SOH(\v2(.opentelemetry.proto.metrics.v1.IntGaugeH\NULR\bintGaugeB\STX\CAN\SOH\DC2=\n\
    \\ENQgauge\CAN\ENQ \SOH(\v2%.opentelemetry.proto.metrics.v1.GaugeH\NULR\ENQgauge\DC2E\n\
    \\aint_sum\CAN\ACK \SOH(\v2&.opentelemetry.proto.metrics.v1.IntSumH\NULR\ACKintSumB\STX\CAN\SOH\DC27\n\
    \\ETXsum\CAN\a \SOH(\v2#.opentelemetry.proto.metrics.v1.SumH\NULR\ETXsum\DC2W\n\
    \\rint_histogram\CAN\b \SOH(\v2,.opentelemetry.proto.metrics.v1.IntHistogramH\NULR\fintHistogramB\STX\CAN\SOH\DC2I\n\
    \\thistogram\CAN\t \SOH(\v2).opentelemetry.proto.metrics.v1.HistogramH\NULR\thistogram\DC2k\n\
    \\NAKexponential_histogram\CAN\n\
    \ \SOH(\v24.opentelemetry.proto.metrics.v1.ExponentialHistogramH\NULR\DC4exponentialHistogram\DC2C\n\
    \\asummary\CAN\v \SOH(\v2'.opentelemetry.proto.metrics.v1.SummaryH\NULR\asummaryB\ACK\n\
    \\EOTdata\"Y\n\
    \\ENQGauge\DC2P\n\
    \\vdata_points\CAN\SOH \ETX(\v2/.opentelemetry.proto.metrics.v1.NumberDataPointR\n\
    \dataPoints\"\235\SOH\n\
    \\ETXSum\DC2P\n\
    \\vdata_points\CAN\SOH \ETX(\v2/.opentelemetry.proto.metrics.v1.NumberDataPointR\n\
    \dataPoints\DC2o\n\
    \\ETBaggregation_temporality\CAN\STX \SOH(\SO26.opentelemetry.proto.metrics.v1.AggregationTemporalityR\SYNaggregationTemporality\DC2!\n\
    \\fis_monotonic\CAN\ETX \SOH(\bR\visMonotonic\"\209\SOH\n\
    \\tHistogram\DC2S\n\
    \\vdata_points\CAN\SOH \ETX(\v22.opentelemetry.proto.metrics.v1.HistogramDataPointR\n\
    \dataPoints\DC2o\n\
    \\ETBaggregation_temporality\CAN\STX \SOH(\SO26.opentelemetry.proto.metrics.v1.AggregationTemporalityR\SYNaggregationTemporality\"\231\SOH\n\
    \\DC4ExponentialHistogram\DC2^\n\
    \\vdata_points\CAN\SOH \ETX(\v2=.opentelemetry.proto.metrics.v1.ExponentialHistogramDataPointR\n\
    \dataPoints\DC2o\n\
    \\ETBaggregation_temporality\CAN\STX \SOH(\SO26.opentelemetry.proto.metrics.v1.AggregationTemporalityR\SYNaggregationTemporality\"\\\n\
    \\aSummary\DC2Q\n\
    \\vdata_points\CAN\SOH \ETX(\v20.opentelemetry.proto.metrics.v1.SummaryDataPointR\n\
    \dataPoints\"\155\ETX\n\
    \\SINumberDataPoint\DC2G\n\
    \\n\
    \attributes\CAN\a \ETX(\v2'.opentelemetry.proto.common.v1.KeyValueR\n\
    \attributes\DC2I\n\
    \\ACKlabels\CAN\SOH \ETX(\v2-.opentelemetry.proto.common.v1.StringKeyValueR\ACKlabelsB\STX\CAN\SOH\DC2/\n\
    \\DC4start_time_unix_nano\CAN\STX \SOH(\ACKR\DC1startTimeUnixNano\DC2$\n\
    \\SOtime_unix_nano\CAN\ETX \SOH(\ACKR\ftimeUnixNano\DC2\GS\n\
    \\tas_double\CAN\EOT \SOH(\SOHH\NULR\basDouble\DC2\ETB\n\
    \\ACKas_int\CAN\ACK \SOH(\DLEH\NULR\ENQasInt\DC2F\n\
    \\texemplars\CAN\ENQ \ETX(\v2(.opentelemetry.proto.metrics.v1.ExemplarR\texemplars\DC2\DC4\n\
    \\ENQflags\CAN\b \SOH(\rR\ENQflagsB\a\n\
    \\ENQvalue\"\211\ETX\n\
    \\DC2HistogramDataPoint\DC2G\n\
    \\n\
    \attributes\CAN\t \ETX(\v2'.opentelemetry.proto.common.v1.KeyValueR\n\
    \attributes\DC2I\n\
    \\ACKlabels\CAN\SOH \ETX(\v2-.opentelemetry.proto.common.v1.StringKeyValueR\ACKlabelsB\STX\CAN\SOH\DC2/\n\
    \\DC4start_time_unix_nano\CAN\STX \SOH(\ACKR\DC1startTimeUnixNano\DC2$\n\
    \\SOtime_unix_nano\CAN\ETX \SOH(\ACKR\ftimeUnixNano\DC2\DC4\n\
    \\ENQcount\CAN\EOT \SOH(\ACKR\ENQcount\DC2\DLE\n\
    \\ETXsum\CAN\ENQ \SOH(\SOHR\ETXsum\DC2#\n\
    \\rbucket_counts\CAN\ACK \ETX(\ACKR\fbucketCounts\DC2'\n\
    \\SIexplicit_bounds\CAN\a \ETX(\SOHR\SOexplicitBounds\DC2F\n\
    \\texemplars\CAN\b \ETX(\v2(.opentelemetry.proto.metrics.v1.ExemplarR\texemplars\DC2\DC4\n\
    \\ENQflags\CAN\n\
    \ \SOH(\rR\ENQflags\"\136\ENQ\n\
    \\GSExponentialHistogramDataPoint\DC2G\n\
    \\n\
    \attributes\CAN\SOH \ETX(\v2'.opentelemetry.proto.common.v1.KeyValueR\n\
    \attributes\DC2/\n\
    \\DC4start_time_unix_nano\CAN\STX \SOH(\ACKR\DC1startTimeUnixNano\DC2$\n\
    \\SOtime_unix_nano\CAN\ETX \SOH(\ACKR\ftimeUnixNano\DC2\DC4\n\
    \\ENQcount\CAN\EOT \SOH(\ACKR\ENQcount\DC2\DLE\n\
    \\ETXsum\CAN\ENQ \SOH(\SOHR\ETXsum\DC2\DC4\n\
    \\ENQscale\CAN\ACK \SOH(\DC1R\ENQscale\DC2\GS\n\
    \\n\
    \zero_count\CAN\a \SOH(\ACKR\tzeroCount\DC2a\n\
    \\bpositive\CAN\b \SOH(\v2E.opentelemetry.proto.metrics.v1.ExponentialHistogramDataPoint.BucketsR\bpositive\DC2a\n\
    \\bnegative\CAN\t \SOH(\v2E.opentelemetry.proto.metrics.v1.ExponentialHistogramDataPoint.BucketsR\bnegative\DC2\DC4\n\
    \\ENQflags\CAN\n\
    \ \SOH(\rR\ENQflags\DC2F\n\
    \\texemplars\CAN\v \ETX(\v2(.opentelemetry.proto.metrics.v1.ExemplarR\texemplars\SUBF\n\
    \\aBuckets\DC2\SYN\n\
    \\ACKoffset\CAN\SOH \SOH(\DC1R\ACKoffset\DC2#\n\
    \\rbucket_counts\CAN\STX \ETX(\EOTR\fbucketCounts\"\235\ETX\n\
    \\DLESummaryDataPoint\DC2G\n\
    \\n\
    \attributes\CAN\a \ETX(\v2'.opentelemetry.proto.common.v1.KeyValueR\n\
    \attributes\DC2I\n\
    \\ACKlabels\CAN\SOH \ETX(\v2-.opentelemetry.proto.common.v1.StringKeyValueR\ACKlabelsB\STX\CAN\SOH\DC2/\n\
    \\DC4start_time_unix_nano\CAN\STX \SOH(\ACKR\DC1startTimeUnixNano\DC2$\n\
    \\SOtime_unix_nano\CAN\ETX \SOH(\ACKR\ftimeUnixNano\DC2\DC4\n\
    \\ENQcount\CAN\EOT \SOH(\ACKR\ENQcount\DC2\DLE\n\
    \\ETXsum\CAN\ENQ \SOH(\SOHR\ETXsum\DC2i\n\
    \\SIquantile_values\CAN\ACK \ETX(\v2@.opentelemetry.proto.metrics.v1.SummaryDataPoint.ValueAtQuantileR\SOquantileValues\DC2\DC4\n\
    \\ENQflags\CAN\b \SOH(\rR\ENQflags\SUBC\n\
    \\SIValueAtQuantile\DC2\SUB\n\
    \\bquantile\CAN\SOH \SOH(\SOHR\bquantile\DC2\DC4\n\
    \\ENQvalue\CAN\STX \SOH(\SOHR\ENQvalue\"\219\STX\n\
    \\bExemplar\DC2X\n\
    \\DC3filtered_attributes\CAN\a \ETX(\v2'.opentelemetry.proto.common.v1.KeyValueR\DC2filteredAttributes\DC2Z\n\
    \\SIfiltered_labels\CAN\SOH \ETX(\v2-.opentelemetry.proto.common.v1.StringKeyValueR\SOfilteredLabelsB\STX\CAN\SOH\DC2$\n\
    \\SOtime_unix_nano\CAN\STX \SOH(\ACKR\ftimeUnixNano\DC2\GS\n\
    \\tas_double\CAN\ETX \SOH(\SOHH\NULR\basDouble\DC2\ETB\n\
    \\ACKas_int\CAN\ACK \SOH(\DLEH\NULR\ENQasInt\DC2\ETB\n\
    \\aspan_id\CAN\EOT \SOH(\fR\ACKspanId\DC2\EM\n\
    \\btrace_id\CAN\ENQ \SOH(\fR\atraceIdB\a\n\
    \\ENQvalue\"\145\STX\n\
    \\fIntDataPoint\DC2E\n\
    \\ACKlabels\CAN\SOH \ETX(\v2-.opentelemetry.proto.common.v1.StringKeyValueR\ACKlabels\DC2/\n\
    \\DC4start_time_unix_nano\CAN\STX \SOH(\ACKR\DC1startTimeUnixNano\DC2$\n\
    \\SOtime_unix_nano\CAN\ETX \SOH(\ACKR\ftimeUnixNano\DC2\DC4\n\
    \\ENQvalue\CAN\EOT \SOH(\DLER\ENQvalue\DC2I\n\
    \\texemplars\CAN\ENQ \ETX(\v2+.opentelemetry.proto.metrics.v1.IntExemplarR\texemplars:\STX\CAN\SOH\"]\n\
    \\bIntGauge\DC2M\n\
    \\vdata_points\CAN\SOH \ETX(\v2,.opentelemetry.proto.metrics.v1.IntDataPointR\n\
    \dataPoints:\STX\CAN\SOH\"\239\SOH\n\
    \\ACKIntSum\DC2M\n\
    \\vdata_points\CAN\SOH \ETX(\v2,.opentelemetry.proto.metrics.v1.IntDataPointR\n\
    \dataPoints\DC2o\n\
    \\ETBaggregation_temporality\CAN\STX \SOH(\SO26.opentelemetry.proto.metrics.v1.AggregationTemporalityR\SYNaggregationTemporality\DC2!\n\
    \\fis_monotonic\CAN\ETX \SOH(\bR\visMonotonic:\STX\CAN\SOH\"\250\STX\n\
    \\NAKIntHistogramDataPoint\DC2E\n\
    \\ACKlabels\CAN\SOH \ETX(\v2-.opentelemetry.proto.common.v1.StringKeyValueR\ACKlabels\DC2/\n\
    \\DC4start_time_unix_nano\CAN\STX \SOH(\ACKR\DC1startTimeUnixNano\DC2$\n\
    \\SOtime_unix_nano\CAN\ETX \SOH(\ACKR\ftimeUnixNano\DC2\DC4\n\
    \\ENQcount\CAN\EOT \SOH(\ACKR\ENQcount\DC2\DLE\n\
    \\ETXsum\CAN\ENQ \SOH(\DLER\ETXsum\DC2#\n\
    \\rbucket_counts\CAN\ACK \ETX(\ACKR\fbucketCounts\DC2'\n\
    \\SIexplicit_bounds\CAN\a \ETX(\SOHR\SOexplicitBounds\DC2I\n\
    \\texemplars\CAN\b \ETX(\v2+.opentelemetry.proto.metrics.v1.IntExemplarR\texemplars:\STX\CAN\SOH\"\219\SOH\n\
    \\fIntHistogram\DC2V\n\
    \\vdata_points\CAN\SOH \ETX(\v25.opentelemetry.proto.metrics.v1.IntHistogramDataPointR\n\
    \dataPoints\DC2o\n\
    \\ETBaggregation_temporality\CAN\STX \SOH(\SO26.opentelemetry.proto.metrics.v1.AggregationTemporalityR\SYNaggregationTemporality:\STX\CAN\SOH\"\217\SOH\n\
    \\vIntExemplar\DC2V\n\
    \\SIfiltered_labels\CAN\SOH \ETX(\v2-.opentelemetry.proto.common.v1.StringKeyValueR\SOfilteredLabels\DC2$\n\
    \\SOtime_unix_nano\CAN\STX \SOH(\ACKR\ftimeUnixNano\DC2\DC4\n\
    \\ENQvalue\CAN\ETX \SOH(\DLER\ENQvalue\DC2\ETB\n\
    \\aspan_id\CAN\EOT \SOH(\fR\ACKspanId\DC2\EM\n\
    \\btrace_id\CAN\ENQ \SOH(\fR\atraceId:\STX\CAN\SOH*\140\SOH\n\
    \\SYNAggregationTemporality\DC2'\n\
    \#AGGREGATION_TEMPORALITY_UNSPECIFIED\DLE\NUL\DC2!\n\
    \\GSAGGREGATION_TEMPORALITY_DELTA\DLE\SOH\DC2&\n\
    \\"AGGREGATION_TEMPORALITY_CUMULATIVE\DLE\STX*;\n\
    \\SODataPointFlags\DC2\r\n\
    \\tFLAG_NONE\DLE\NUL\DC2\SUB\n\
    \\SYNFLAG_NO_RECORDED_VALUE\DLE\SOHBt\n\
    \!io.opentelemetry.proto.metrics.v1B\fMetricsProtoP\SOHZ?github.com/open-telemetry/opentelemetry-proto/gen/go/metrics/v1J\201\160\STX\n\
    \\a\DC2\ENQ\SO\NUL\207\ACK\SOH\n\
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
    \\SOH\STX\DC2\ETX\DLE\NUL'\n\
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
    \\SOH\b\DC2\ETX\SYN\NUL:\n\
    \\t\n\
    \\STX\b\SOH\DC2\ETX\SYN\NUL:\n\
    \\b\n\
    \\SOH\b\DC2\ETX\ETB\NUL-\n\
    \\t\n\
    \\STX\b\b\DC2\ETX\ETB\NUL-\n\
    \\b\n\
    \\SOH\b\DC2\ETX\CAN\NULV\n\
    \\t\n\
    \\STX\b\v\DC2\ETX\CAN\NULV\n\
    \\209\ETX\n\
    \\STX\EOT\NUL\DC2\EOT$\NUL+\SOH\SUB\196\ETX MetricsData represents the metrics data that can be stored in a persistent\n\
    \ storage, OR can be embedded by other protocols that transfer OTLP metrics\n\
    \ data but do not implement the OTLP protocol.\n\
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
    \\ETX\EOT\NUL\SOH\DC2\ETX$\b\DC3\n\
    \\176\STX\n\
    \\EOT\EOT\NUL\STX\NUL\DC2\ETX*\STX0\SUB\162\STX An array of ResourceMetrics.\n\
    \ For data coming from a single resource this array will typically contain\n\
    \ one element. Intermediary nodes that receive data from multiple origins\n\
    \ typically batch the data before forwarding further and in that case this\n\
    \ array will contain multiple elements.\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\EOT\DC2\ETX*\STX\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\ACK\DC2\ETX*\v\SUB\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\SOH\DC2\ETX*\ESC+\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\ETX\DC2\ETX*./\n\
    \L\n\
    \\STX\EOT\SOH\DC2\EOT.\NUL:\SOH\SUB@ A collection of InstrumentationLibraryMetrics from a Resource.\n\
    \\n\
    \\n\
    \\n\
    \\ETX\EOT\SOH\SOH\DC2\ETX.\b\ETB\n\
    \v\n\
    \\EOT\EOT\SOH\STX\NUL\DC2\ETX1\STX8\SUBi The resource for the metrics in this message.\n\
    \ If this field is not set then no resource info is known.\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\ACK\DC2\ETX1\STX*\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\SOH\DC2\ETX1+3\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\ETX\DC2\ETX167\n\
    \@\n\
    \\EOT\EOT\SOH\STX\SOH\DC2\ETX4\STXM\SUB3 A list of metrics that originate from a resource.\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\SOH\EOT\DC2\ETX4\STX\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\SOH\ACK\DC2\ETX4\v(\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\SOH\SOH\DC2\ETX4)H\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\SOH\ETX\DC2\ETX4KL\n\
    \\194\SOH\n\
    \\EOT\EOT\SOH\STX\STX\DC2\ETX9\STX\CAN\SUB\180\SOH This schema_url applies to the data in the \"resource\" field. It does not apply\n\
    \ to the data in the \"instrumentation_library_metrics\" field which have their own\n\
    \ schema_url field.\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\STX\ENQ\DC2\ETX9\STX\b\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\STX\SOH\DC2\ETX9\t\DC3\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\STX\ETX\DC2\ETX9\SYN\ETB\n\
    \L\n\
    \\STX\EOT\STX\DC2\EOT=\NULH\SOH\SUB@ A collection of Metrics produced by an InstrumentationLibrary.\n\
    \\n\
    \\n\
    \\n\
    \\ETX\EOT\STX\SOH\DC2\ETX=\b%\n\
    \\213\SOH\n\
    \\EOT\EOT\STX\STX\NUL\DC2\ETXA\STXS\SUB\199\SOH The instrumentation library information for the metrics in this message.\n\
    \ Semantically when InstrumentationLibrary isn't set, it is equivalent with\n\
    \ an empty instrumentation library name (unknown).\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\NUL\ACK\DC2\ETXA\STX6\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\NUL\SOH\DC2\ETXA7N\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\NUL\ETX\DC2\ETXAQR\n\
    \P\n\
    \\EOT\EOT\STX\STX\SOH\DC2\ETXD\STX\RS\SUBC A list of metrics that originate from an instrumentation library.\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\SOH\EOT\DC2\ETXD\STX\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\SOH\ACK\DC2\ETXD\v\DC1\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\SOH\SOH\DC2\ETXD\DC2\EM\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\SOH\ETX\DC2\ETXD\FS\GS\n\
    \M\n\
    \\EOT\EOT\STX\STX\STX\DC2\ETXG\STX\CAN\SUB@ This schema_url applies to all metrics in the \"metrics\" field.\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\STX\ENQ\DC2\ETXG\STX\b\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\STX\SOH\DC2\ETXG\t\DC3\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\STX\ETX\DC2\ETXG\SYN\ETB\n\
    \\174\GS\n\
    \\STX\EOT\ETX\DC2\ACK\159\SOH\NUL\200\SOH\SOH\SUB\159\GS Defines a Metric which has one or more timeseries.  The following is a\n\
    \ brief summary of the Metric data model.  For more details, see:\n\
    \\n\
    \   https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/metrics/datamodel.md\n\
    \\n\
    \\n\
    \ The data model and relation between entities is shown in the\n\
    \ diagram below. Here, \"DataPoint\" is the term used to refer to any\n\
    \ one of the specific data point value types, and \"points\" is the term used\n\
    \ to refer to any one of the lists of points contained in the Metric.\n\
    \\n\
    \ - Metric is composed of a metadata and data.\n\
    \ - Metadata part contains a name, description, unit.\n\
    \ - Data is one of the possible types (Sum, Gauge, Histogram, Summary).\n\
    \ - DataPoint contains timestamps, attributes, and one of the possible value type\n\
    \   fields.\n\
    \\n\
    \     Metric\n\
    \  +------------+\n\
    \  |name        |\n\
    \  |description |\n\
    \  |unit        |     +------------------------------------+\n\
    \  |data        |---> |Gauge, Sum, Histogram, Summary, ... |\n\
    \  +------------+     +------------------------------------+\n\
    \\n\
    \    Data [One of Gauge, Sum, Histogram, Summary, ...]\n\
    \  +-----------+\n\
    \  |...        |  // Metadata about the Data.\n\
    \  |points     |--+\n\
    \  +-----------+  |\n\
    \                 |      +---------------------------+\n\
    \                 |      |DataPoint 1                |\n\
    \                 v      |+------+------+   +------+ |\n\
    \              +-----+   ||label |label |...|label | |\n\
    \              |  1  |-->||value1|value2|...|valueN| |\n\
    \              +-----+   |+------+------+   +------+ |\n\
    \              |  .  |   |+-----+                    |\n\
    \              |  .  |   ||value|                    |\n\
    \              |  .  |   |+-----+                    |\n\
    \              |  .  |   +---------------------------+\n\
    \              |  .  |                   .\n\
    \              |  .  |                   .\n\
    \              |  .  |                   .\n\
    \              |  .  |   +---------------------------+\n\
    \              |  .  |   |DataPoint M                |\n\
    \              +-----+   |+------+------+   +------+ |\n\
    \              |  M  |-->||label |label |...|label | |\n\
    \              +-----+   ||value1|value2|...|valueN| |\n\
    \                        |+------+------+   +------+ |\n\
    \                        |+-----+                    |\n\
    \                        ||value|                    |\n\
    \                        |+-----+                    |\n\
    \                        +---------------------------+\n\
    \\n\
    \ Each distinct type of DataPoint represents the output of a specific\n\
    \ aggregation function, the result of applying the DataPoint's\n\
    \ associated function of to one or more measurements.\n\
    \\n\
    \ All DataPoint types have three common fields:\n\
    \ - Attributes includes key-value pairs associated with the data point\n\
    \ - TimeUnixNano is required, set to the end time of the aggregation\n\
    \ - StartTimeUnixNano is optional, but strongly encouraged for DataPoints\n\
    \   having an AggregationTemporality field, as discussed below.\n\
    \\n\
    \ Both TimeUnixNano and StartTimeUnixNano values are expressed as\n\
    \ UNIX Epoch time in nanoseconds since 00:00:00 UTC on 1 January 1970.\n\
    \\n\
    \ # TimeUnixNano\n\
    \\n\
    \ This field is required, having consistent interpretation across\n\
    \ DataPoint types.  TimeUnixNano is the moment corresponding to when\n\
    \ the data point's aggregate value was captured.\n\
    \\n\
    \ Data points with the 0 value for TimeUnixNano SHOULD be rejected\n\
    \ by consumers.\n\
    \\n\
    \ # StartTimeUnixNano\n\
    \\n\
    \ StartTimeUnixNano in general allows detecting when a sequence of\n\
    \ observations is unbroken.  This field indicates to consumers the\n\
    \ start time for points with cumulative and delta\n\
    \ AggregationTemporality, and it should be included whenever possible\n\
    \ to support correct rate calculation.  Although it may be omitted\n\
    \ when the start time is truly unknown, setting StartTimeUnixNano is\n\
    \ strongly encouraged.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\ETX\SOH\DC2\EOT\159\SOH\b\SO\n\
    \U\n\
    \\EOT\EOT\ETX\STX\NUL\DC2\EOT\161\SOH\STX\DC2\SUBG name of the metric, including its DNS name prefix. It must be unique.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\NUL\ENQ\DC2\EOT\161\SOH\STX\b\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\NUL\SOH\DC2\EOT\161\SOH\t\r\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\NUL\ETX\DC2\EOT\161\SOH\DLE\DC1\n\
    \N\n\
    \\EOT\EOT\ETX\STX\SOH\DC2\EOT\164\SOH\STX\EM\SUB@ description of the metric, which can be used in documentation.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\SOH\ENQ\DC2\EOT\164\SOH\STX\b\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\SOH\SOH\DC2\EOT\164\SOH\t\DC4\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\SOH\ETX\DC2\EOT\164\SOH\ETB\CAN\n\
    \\129\SOH\n\
    \\EOT\EOT\ETX\STX\STX\DC2\EOT\168\SOH\STX\DC2\SUBs unit in which the metric value is reported. Follows the format\n\
    \ described by http://unitsofmeasure.org/ucum.html.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\STX\ENQ\DC2\EOT\168\SOH\STX\b\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\STX\SOH\DC2\EOT\168\SOH\t\r\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\STX\ETX\DC2\EOT\168\SOH\DLE\DC1\n\
    \\215\SOH\n\
    \\EOT\EOT\ETX\b\NUL\DC2\ACK\173\SOH\STX\199\SOH\ETX\SUB\198\SOH Data determines the aggregation type (if any) of the metric, what is the\n\
    \ reported value type for the data points, as well as the relatationship to\n\
    \ the time interval over which they are reported.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETX\b\NUL\SOH\DC2\EOT\173\SOH\b\f\n\
    \\242\ETX\n\
    \\EOT\EOT\ETX\STX\ETX\DC2\EOT\182\SOH\EOT/\SUB\227\ETX IntGauge and IntSum are deprecated and will be removed soon.\n\
    \ 1. Old senders and receivers that are not aware of this change will\n\
    \ continue using the `int_gauge` and `int_sum` fields.\n\
    \ 2. New senders, which are aware of this change MUST send only `gauge`\n\
    \ and `sum` fields.\n\
    \ 3. New receivers, which are aware of this change MUST convert these into\n\
    \ `gauge` and `sum` by using the provided as_int field in the oneof values.\n\
    \ This field will be removed in ~3 months, on July 1, 2021.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\ETX\ACK\DC2\EOT\182\SOH\EOT\f\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\ETX\SOH\DC2\EOT\182\SOH\r\SYN\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\ETX\ETX\DC2\EOT\182\SOH\EM\SUB\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\ETX\b\DC2\EOT\182\SOH\ESC.\n\
    \\SO\n\
    \\ACK\EOT\ETX\STX\ETX\b\ETX\DC2\EOT\182\SOH\FS-\n\
    \\f\n\
    \\EOT\EOT\ETX\STX\EOT\DC2\EOT\183\SOH\EOT\DC4\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\EOT\ACK\DC2\EOT\183\SOH\EOT\t\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\EOT\SOH\DC2\EOT\183\SOH\n\
    \\SI\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\EOT\ETX\DC2\EOT\183\SOH\DC2\DC3\n\
    \I\n\
    \\EOT\EOT\ETX\STX\ENQ\DC2\EOT\185\SOH\EOT+\SUB; This field will be removed in ~3 months, on July 1, 2021.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\ENQ\ACK\DC2\EOT\185\SOH\EOT\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\ENQ\SOH\DC2\EOT\185\SOH\v\DC2\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\ENQ\ETX\DC2\EOT\185\SOH\NAK\SYN\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\ENQ\b\DC2\EOT\185\SOH\ETB*\n\
    \\SO\n\
    \\ACK\EOT\ETX\STX\ENQ\b\ETX\DC2\EOT\185\SOH\CAN)\n\
    \\f\n\
    \\EOT\EOT\ETX\STX\ACK\DC2\EOT\186\SOH\EOT\DLE\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\ACK\ACK\DC2\EOT\186\SOH\EOT\a\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\ACK\SOH\DC2\EOT\186\SOH\b\v\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\ACK\ETX\DC2\EOT\186\SOH\SO\SI\n\
    \\196\ETX\n\
    \\EOT\EOT\ETX\STX\a\DC2\EOT\195\SOH\EOT7\SUB\181\ETX IntHistogram is deprecated and will be removed soon.\n\
    \ 1. Old senders and receivers that are not aware of this change will\n\
    \ continue using the `int_histogram` field.\n\
    \ 2. New senders, which are aware of this change MUST send only `histogram`.\n\
    \ 3. New receivers, which are aware of this change MUST convert this into\n\
    \ `histogram` by simply converting all int64 values into float.\n\
    \ This field will be removed in ~3 months, on July 1, 2021.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\a\ACK\DC2\EOT\195\SOH\EOT\DLE\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\a\SOH\DC2\EOT\195\SOH\DC1\RS\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\a\ETX\DC2\EOT\195\SOH!\"\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\a\b\DC2\EOT\195\SOH#6\n\
    \\SO\n\
    \\ACK\EOT\ETX\STX\a\b\ETX\DC2\EOT\195\SOH$5\n\
    \\f\n\
    \\EOT\EOT\ETX\STX\b\DC2\EOT\196\SOH\EOT\FS\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\b\ACK\DC2\EOT\196\SOH\EOT\r\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\b\SOH\DC2\EOT\196\SOH\SO\ETB\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\b\ETX\DC2\EOT\196\SOH\SUB\ESC\n\
    \\f\n\
    \\EOT\EOT\ETX\STX\t\DC2\EOT\197\SOH\EOT4\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\t\ACK\DC2\EOT\197\SOH\EOT\CAN\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\t\SOH\DC2\EOT\197\SOH\EM.\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\t\ETX\DC2\EOT\197\SOH13\n\
    \\f\n\
    \\EOT\EOT\ETX\STX\n\
    \\DC2\EOT\198\SOH\EOT\EM\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\n\
    \\ACK\DC2\EOT\198\SOH\EOT\v\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\n\
    \\SOH\DC2\EOT\198\SOH\f\DC3\n\
    \\r\n\
    \\ENQ\EOT\ETX\STX\n\
    \\ETX\DC2\EOT\198\SOH\SYN\CAN\n\
    \\247\ETX\n\
    \\STX\EOT\EOT\DC2\ACK\211\SOH\NUL\213\SOH\SOH\SUB\232\ETX Gauge represents the type of a scalar metric that always exports the\n\
    \ \"current value\" for every data point. It should be used for an \"unknown\"\n\
    \ aggregation.\n\
    \\n\
    \ A Gauge does not support different aggregation temporalities. Given the\n\
    \ aggregation is unknown, points cannot be combined using the same\n\
    \ aggregation, regardless of aggregation temporalities. Therefore,\n\
    \ AggregationTemporality is not included. Consequently, this also means\n\
    \ \"StartTimeUnixNano\" is ignored for all data points.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\EOT\SOH\DC2\EOT\211\SOH\b\r\n\
    \\f\n\
    \\EOT\EOT\EOT\STX\NUL\DC2\EOT\212\SOH\STX+\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\NUL\EOT\DC2\EOT\212\SOH\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\NUL\ACK\DC2\EOT\212\SOH\v\SUB\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\NUL\SOH\DC2\EOT\212\SOH\ESC&\n\
    \\r\n\
    \\ENQ\EOT\EOT\STX\NUL\ETX\DC2\EOT\212\SOH)*\n\
    \\138\SOH\n\
    \\STX\EOT\ENQ\DC2\ACK\217\SOH\NUL\226\SOH\SOH\SUB| Sum represents the type of a scalar metric that is calculated as a sum of all\n\
    \ reported measurements over a time interval.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\ENQ\SOH\DC2\EOT\217\SOH\b\v\n\
    \\f\n\
    \\EOT\EOT\ENQ\STX\NUL\DC2\EOT\218\SOH\STX+\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\NUL\EOT\DC2\EOT\218\SOH\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\NUL\ACK\DC2\EOT\218\SOH\v\SUB\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\NUL\SOH\DC2\EOT\218\SOH\ESC&\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\NUL\ETX\DC2\EOT\218\SOH)*\n\
    \\163\SOH\n\
    \\EOT\EOT\ENQ\STX\SOH\DC2\EOT\222\SOH\STX5\SUB\148\SOH aggregation_temporality describes if the aggregator reports delta changes\n\
    \ since last report time, or cumulative changes since a fixed start time.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\SOH\ACK\DC2\EOT\222\SOH\STX\CAN\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\SOH\SOH\DC2\EOT\222\SOH\EM0\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\SOH\ETX\DC2\EOT\222\SOH34\n\
    \:\n\
    \\EOT\EOT\ENQ\STX\STX\DC2\EOT\225\SOH\STX\CAN\SUB, If \"true\" means that the sum is monotonic.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\STX\ENQ\DC2\EOT\225\SOH\STX\ACK\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\STX\SOH\DC2\EOT\225\SOH\a\DC3\n\
    \\r\n\
    \\ENQ\EOT\ENQ\STX\STX\ETX\DC2\EOT\225\SOH\SYN\ETB\n\
    \\159\SOH\n\
    \\STX\EOT\ACK\DC2\ACK\230\SOH\NUL\236\SOH\SOH\SUB\144\SOH Histogram represents the type of a metric that is calculated by aggregating\n\
    \ as a Histogram of all reported measurements over a time interval.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\ACK\SOH\DC2\EOT\230\SOH\b\DC1\n\
    \\f\n\
    \\EOT\EOT\ACK\STX\NUL\DC2\EOT\231\SOH\STX.\n\
    \\r\n\
    \\ENQ\EOT\ACK\STX\NUL\EOT\DC2\EOT\231\SOH\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ACK\STX\NUL\ACK\DC2\EOT\231\SOH\v\GS\n\
    \\r\n\
    \\ENQ\EOT\ACK\STX\NUL\SOH\DC2\EOT\231\SOH\RS)\n\
    \\r\n\
    \\ENQ\EOT\ACK\STX\NUL\ETX\DC2\EOT\231\SOH,-\n\
    \\163\SOH\n\
    \\EOT\EOT\ACK\STX\SOH\DC2\EOT\235\SOH\STX5\SUB\148\SOH aggregation_temporality describes if the aggregator reports delta changes\n\
    \ since last report time, or cumulative changes since a fixed start time.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\ACK\STX\SOH\ACK\DC2\EOT\235\SOH\STX\CAN\n\
    \\r\n\
    \\ENQ\EOT\ACK\STX\SOH\SOH\DC2\EOT\235\SOH\EM0\n\
    \\r\n\
    \\ENQ\EOT\ACK\STX\SOH\ETX\DC2\EOT\235\SOH34\n\
    \\188\SOH\n\
    \\STX\EOT\a\DC2\ACK\240\SOH\NUL\246\SOH\SOH\SUB\173\SOH ExponentialHistogram represents the type of a metric that is calculated by aggregating\n\
    \ as a ExponentialHistogram of all reported double measurements over a time interval.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\a\SOH\DC2\EOT\240\SOH\b\FS\n\
    \\f\n\
    \\EOT\EOT\a\STX\NUL\DC2\EOT\241\SOH\STX9\n\
    \\r\n\
    \\ENQ\EOT\a\STX\NUL\EOT\DC2\EOT\241\SOH\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\a\STX\NUL\ACK\DC2\EOT\241\SOH\v(\n\
    \\r\n\
    \\ENQ\EOT\a\STX\NUL\SOH\DC2\EOT\241\SOH)4\n\
    \\r\n\
    \\ENQ\EOT\a\STX\NUL\ETX\DC2\EOT\241\SOH78\n\
    \\163\SOH\n\
    \\EOT\EOT\a\STX\SOH\DC2\EOT\245\SOH\STX5\SUB\148\SOH aggregation_temporality describes if the aggregator reports delta changes\n\
    \ since last report time, or cumulative changes since a fixed start time.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\a\STX\SOH\ACK\DC2\EOT\245\SOH\STX\CAN\n\
    \\r\n\
    \\ENQ\EOT\a\STX\SOH\SOH\DC2\EOT\245\SOH\EM0\n\
    \\r\n\
    \\ENQ\EOT\a\STX\SOH\ETX\DC2\EOT\245\SOH34\n\
    \\229\ETX\n\
    \\STX\EOT\b\DC2\ACK\254\SOH\NUL\128\STX\SOH\SUB\214\ETX Summary metric data are used to convey quantile summaries,\n\
    \ a Prometheus (see: https://prometheus.io/docs/concepts/metric_types/#summary)\n\
    \ and OpenMetrics (see: https://github.com/OpenObservability/OpenMetrics/blob/4dbf6075567ab43296eed941037c12951faafb92/protos/prometheus.proto#L45)\n\
    \ data type. These data points cannot always be merged in a meaningful way.\n\
    \ While they can be useful in some applications, histogram data points are\n\
    \ recommended for new applications.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\b\SOH\DC2\EOT\254\SOH\b\SI\n\
    \\f\n\
    \\EOT\EOT\b\STX\NUL\DC2\EOT\255\SOH\STX,\n\
    \\r\n\
    \\ENQ\EOT\b\STX\NUL\EOT\DC2\EOT\255\SOH\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\b\STX\NUL\ACK\DC2\EOT\255\SOH\v\ESC\n\
    \\r\n\
    \\ENQ\EOT\b\STX\NUL\SOH\DC2\EOT\255\SOH\FS'\n\
    \\r\n\
    \\ENQ\EOT\b\STX\NUL\ETX\DC2\EOT\255\SOH*+\n\
    \\190\SOH\n\
    \\STX\ENQ\NUL\DC2\ACK\133\STX\NUL\199\STX\SOH\SUB\175\SOH AggregationTemporality defines how a metric aggregator reports aggregated\n\
    \ values. It describes how those values relate to the time interval over\n\
    \ which they are aggregated.\n\
    \\n\
    \\v\n\
    \\ETX\ENQ\NUL\SOH\DC2\EOT\133\STX\ENQ\ESC\n\
    \W\n\
    \\EOT\ENQ\NUL\STX\NUL\DC2\EOT\135\STX\STX*\SUBI UNSPECIFIED is the default AggregationTemporality, it MUST not be used.\n\
    \\n\
    \\r\n\
    \\ENQ\ENQ\NUL\STX\NUL\SOH\DC2\EOT\135\STX\STX%\n\
    \\r\n\
    \\ENQ\ENQ\NUL\STX\NUL\STX\DC2\EOT\135\STX()\n\
    \\236\t\n\
    \\EOT\ENQ\NUL\STX\SOH\DC2\EOT\161\STX\STX$\SUB\221\t DELTA is an AggregationTemporality for a metric aggregator which reports\n\
    \ changes since last report time. Successive metrics contain aggregation of\n\
    \ values from continuous and non-overlapping intervals.\n\
    \\n\
    \ The values for a DELTA metric are based only on the time interval\n\
    \ associated with one measurement cycle. There is no dependency on\n\
    \ previous measurements like is the case for CUMULATIVE metrics.\n\
    \\n\
    \ For example, consider a system measuring the number of requests that\n\
    \ it receives and reports the sum of these requests every second as a\n\
    \ DELTA metric:\n\
    \\n\
    \   1. The system starts receiving at time=t_0.\n\
    \   2. A request is received, the system measures 1 request.\n\
    \   3. A request is received, the system measures 1 request.\n\
    \   4. A request is received, the system measures 1 request.\n\
    \   5. The 1 second collection cycle ends. A metric is exported for the\n\
    \      number of requests received over the interval of time t_0 to\n\
    \      t_0+1 with a value of 3.\n\
    \   6. A request is received, the system measures 1 request.\n\
    \   7. A request is received, the system measures 1 request.\n\
    \   8. The 1 second collection cycle ends. A metric is exported for the\n\
    \      number of requests received over the interval of time t_0+1 to\n\
    \      t_0+2 with a value of 2.\n\
    \\n\
    \\r\n\
    \\ENQ\ENQ\NUL\STX\SOH\SOH\DC2\EOT\161\STX\STX\US\n\
    \\r\n\
    \\ENQ\ENQ\NUL\STX\SOH\STX\DC2\EOT\161\STX\"#\n\
    \\147\SI\n\
    \\EOT\ENQ\NUL\STX\STX\DC2\EOT\198\STX\STX)\SUB\132\SI CUMULATIVE is an AggregationTemporality for a metric aggregator which\n\
    \ reports changes since a fixed start time. This means that current values\n\
    \ of a CUMULATIVE metric depend on all previous measurements since the\n\
    \ start time. Because of this, the sender is required to retain this state\n\
    \ in some form. If this state is lost or invalidated, the CUMULATIVE metric\n\
    \ values MUST be reset and a new fixed start time following the last\n\
    \ reported measurement time sent MUST be used.\n\
    \\n\
    \ For example, consider a system measuring the number of requests that\n\
    \ it receives and reports the sum of these requests every second as a\n\
    \ CUMULATIVE metric:\n\
    \\n\
    \   1. The system starts receiving at time=t_0.\n\
    \   2. A request is received, the system measures 1 request.\n\
    \   3. A request is received, the system measures 1 request.\n\
    \   4. A request is received, the system measures 1 request.\n\
    \   5. The 1 second collection cycle ends. A metric is exported for the\n\
    \      number of requests received over the interval of time t_0 to\n\
    \      t_0+1 with a value of 3.\n\
    \   6. A request is received, the system measures 1 request.\n\
    \   7. A request is received, the system measures 1 request.\n\
    \   8. The 1 second collection cycle ends. A metric is exported for the\n\
    \      number of requests received over the interval of time t_0 to\n\
    \      t_0+2 with a value of 5.\n\
    \   9. The system experiences a fault and loses state.\n\
    \   10. The system recovers and resumes receiving at time=t_1.\n\
    \   11. A request is received, the system measures 1 request.\n\
    \   12. The 1 second collection cycle ends. A metric is exported for the\n\
    \      number of requests received over the interval of time t_1 to\n\
    \      t_0+1 with a value of 1.\n\
    \\n\
    \ Note: Even though, when reporting changes since last report time, using\n\
    \ CUMULATIVE is valid, it is not recommended. This may cause problems for\n\
    \ systems that do not use start_time to determine when the aggregation\n\
    \ value was reset (e.g. Prometheus).\n\
    \\n\
    \\r\n\
    \\ENQ\ENQ\NUL\STX\STX\SOH\DC2\EOT\198\STX\STX$\n\
    \\r\n\
    \\ENQ\ENQ\NUL\STX\STX\STX\DC2\EOT\198\STX'(\n\
    \\241\STX\n\
    \\STX\ENQ\SOH\DC2\ACK\208\STX\NUL\217\STX\SOH\SUB\226\STX DataPointFlags is defined as a protobuf 'uint32' type and is to be used as a\n\
    \ bit-field representing 32 distinct boolean flags.  Each flag defined in this\n\
    \ enum is a bit-mask.  To test the presence of a single flag in the flags of\n\
    \ a data point, for example, use an expression like:\n\
    \\n\
    \   (point.flags & FLAG_NO_RECORDED_VALUE) == FLAG_NO_RECORDED_VALUE\n\
    \\n\
    \\n\
    \\v\n\
    \\ETX\ENQ\SOH\SOH\DC2\EOT\208\STX\ENQ\DC3\n\
    \\f\n\
    \\EOT\ENQ\SOH\STX\NUL\DC2\EOT\209\STX\STX\DLE\n\
    \\r\n\
    \\ENQ\ENQ\SOH\STX\NUL\SOH\DC2\EOT\209\STX\STX\v\n\
    \\r\n\
    \\ENQ\ENQ\SOH\STX\NUL\STX\DC2\EOT\209\STX\SO\SI\n\
    \\203\SOH\n\
    \\EOT\ENQ\SOH\STX\SOH\DC2\EOT\214\STX\STX\GS\SUB\188\SOH This DataPoint is valid but has no recorded value.  This value\n\
    \ SHOULD be used to reflect explicitly missing data in a series, as\n\
    \ for an equivalent to the Prometheus \"staleness marker\".\n\
    \\n\
    \\r\n\
    \\ENQ\ENQ\SOH\STX\SOH\SOH\DC2\EOT\214\STX\STX\CAN\n\
    \\r\n\
    \\ENQ\ENQ\SOH\STX\SOH\STX\DC2\EOT\214\STX\ESC\FS\n\
    \\129\SOH\n\
    \\STX\EOT\t\DC2\ACK\221\STX\NUL\135\ETX\SOH\SUBs NumberDataPoint is a single data point in a timeseries that describes the\n\
    \ time-varying scalar value of a metric.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\t\SOH\DC2\EOT\221\STX\b\ETB\n\
    \\161\SOH\n\
    \\EOT\EOT\t\STX\NUL\DC2\EOT\224\STX\STXA\SUB\146\SOH The set of key/value pairs that uniquely identify the timeseries from\n\
    \ where this point belongs. The list may be empty (may contain 0 elements).\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\t\STX\NUL\EOT\DC2\EOT\224\STX\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\t\STX\NUL\ACK\DC2\EOT\224\STX\v1\n\
    \\r\n\
    \\ENQ\EOT\t\STX\NUL\SOH\DC2\EOT\224\STX2<\n\
    \\r\n\
    \\ENQ\EOT\t\STX\NUL\ETX\DC2\EOT\224\STX?@\n\
    \\182\ETX\n\
    \\EOT\EOT\t\STX\SOH\DC2\EOT\234\STX\STXW\SUB\167\ETX Labels is deprecated and will be removed soon.\n\
    \ 1. Old senders and receivers that are not aware of this change will\n\
    \ continue using the `labels` field.\n\
    \ 2. New senders, which are aware of this change MUST send only `attributes`.\n\
    \ 3. New receivers, which are aware of this change MUST convert this into\n\
    \ `labels` by simply converting all int64 values into float.\n\
    \\n\
    \ This field will be removed in ~3 months, on July 1, 2021.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\t\STX\SOH\EOT\DC2\EOT\234\STX\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\t\STX\SOH\ACK\DC2\EOT\234\STX\v7\n\
    \\r\n\
    \\ENQ\EOT\t\STX\SOH\SOH\DC2\EOT\234\STX8>\n\
    \\r\n\
    \\ENQ\EOT\t\STX\SOH\ETX\DC2\EOT\234\STXAB\n\
    \\r\n\
    \\ENQ\EOT\t\STX\SOH\b\DC2\EOT\234\STXCV\n\
    \\SO\n\
    \\ACK\EOT\t\STX\SOH\b\ETX\DC2\EOT\234\STXDU\n\
    \\197\SOH\n\
    \\EOT\EOT\t\STX\STX\DC2\EOT\241\STX\STX#\SUB\182\SOH StartTimeUnixNano is optional but strongly encouraged, see the\n\
    \ the detailed comments above Metric.\n\
    \\n\
    \ Value is UNIX Epoch time in nanoseconds since 00:00:00 UTC on 1 January\n\
    \ 1970.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\t\STX\STX\ENQ\DC2\EOT\241\STX\STX\t\n\
    \\r\n\
    \\ENQ\EOT\t\STX\STX\SOH\DC2\EOT\241\STX\n\
    \\RS\n\
    \\r\n\
    \\ENQ\EOT\t\STX\STX\ETX\DC2\EOT\241\STX!\"\n\
    \\163\SOH\n\
    \\EOT\EOT\t\STX\ETX\DC2\EOT\247\STX\STX\GS\SUB\148\SOH TimeUnixNano is required, see the detailed comments above Metric.\n\
    \\n\
    \ Value is UNIX Epoch time in nanoseconds since 00:00:00 UTC on 1 January\n\
    \ 1970.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\t\STX\ETX\ENQ\DC2\EOT\247\STX\STX\t\n\
    \\r\n\
    \\ENQ\EOT\t\STX\ETX\SOH\DC2\EOT\247\STX\n\
    \\CAN\n\
    \\r\n\
    \\ENQ\EOT\t\STX\ETX\ETX\DC2\EOT\247\STX\ESC\FS\n\
    \\141\SOH\n\
    \\EOT\EOT\t\b\NUL\DC2\ACK\251\STX\STX\254\STX\ETX\SUB} The value itself.  A point is considered invalid when one of the recognized\n\
    \ value fields is not present inside this oneof.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\t\b\NUL\SOH\DC2\EOT\251\STX\b\r\n\
    \\f\n\
    \\EOT\EOT\t\STX\EOT\DC2\EOT\252\STX\EOT\EM\n\
    \\r\n\
    \\ENQ\EOT\t\STX\EOT\ENQ\DC2\EOT\252\STX\EOT\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\t\STX\EOT\SOH\DC2\EOT\252\STX\v\DC4\n\
    \\r\n\
    \\ENQ\EOT\t\STX\EOT\ETX\DC2\EOT\252\STX\ETB\CAN\n\
    \\f\n\
    \\EOT\EOT\t\STX\ENQ\DC2\EOT\253\STX\EOT\CAN\n\
    \\r\n\
    \\ENQ\EOT\t\STX\ENQ\ENQ\DC2\EOT\253\STX\EOT\f\n\
    \\r\n\
    \\ENQ\EOT\t\STX\ENQ\SOH\DC2\EOT\253\STX\r\DC3\n\
    \\r\n\
    \\ENQ\EOT\t\STX\ENQ\ETX\DC2\EOT\253\STX\SYN\ETB\n\
    \o\n\
    \\EOT\EOT\t\STX\ACK\DC2\EOT\130\ETX\STX\"\SUBa (Optional) List of exemplars collected from\n\
    \ measurements that were used to form the data point\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\t\STX\ACK\EOT\DC2\EOT\130\ETX\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\t\STX\ACK\ACK\DC2\EOT\130\ETX\v\DC3\n\
    \\r\n\
    \\ENQ\EOT\t\STX\ACK\SOH\DC2\EOT\130\ETX\DC4\GS\n\
    \\r\n\
    \\ENQ\EOT\t\STX\ACK\ETX\DC2\EOT\130\ETX !\n\
    \}\n\
    \\EOT\EOT\t\STX\a\DC2\EOT\134\ETX\STX\DC3\SUBo Flags that apply to this specific data point.  See DataPointFlags\n\
    \ for the available flags and their meaning.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\t\STX\a\ENQ\DC2\EOT\134\ETX\STX\b\n\
    \\r\n\
    \\ENQ\EOT\t\STX\a\SOH\DC2\EOT\134\ETX\t\SO\n\
    \\r\n\
    \\ENQ\EOT\t\STX\a\ETX\DC2\EOT\134\ETX\DC1\DC2\n\
    \\196\EOT\n\
    \\STX\EOT\n\
    \\DC2\ACK\147\ETX\NUL\221\ETX\SOH\SUB\181\EOT HistogramDataPoint is a single data point in a timeseries that describes the\n\
    \ time-varying values of a Histogram. A Histogram contains summary statistics\n\
    \ for a population of values, it may optionally contain the distribution of\n\
    \ those values across a set of buckets.\n\
    \\n\
    \ If the histogram contains the distribution of values, then both\n\
    \ \"explicit_bounds\" and \"bucket counts\" fields must be defined.\n\
    \ If the histogram does not contain the distribution of values, then both\n\
    \ \"explicit_bounds\" and \"bucket_counts\" must be omitted and only \"count\" and\n\
    \ \"sum\" are known.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\n\
    \\SOH\DC2\EOT\147\ETX\b\SUB\n\
    \\161\SOH\n\
    \\EOT\EOT\n\
    \\STX\NUL\DC2\EOT\150\ETX\STXA\SUB\146\SOH The set of key/value pairs that uniquely identify the timeseries from\n\
    \ where this point belongs. The list may be empty (may contain 0 elements).\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\NUL\EOT\DC2\EOT\150\ETX\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\NUL\ACK\DC2\EOT\150\ETX\v1\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\NUL\SOH\DC2\EOT\150\ETX2<\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\NUL\ETX\DC2\EOT\150\ETX?@\n\
    \\182\ETX\n\
    \\EOT\EOT\n\
    \\STX\SOH\DC2\EOT\160\ETX\STXW\SUB\167\ETX Labels is deprecated and will be removed soon.\n\
    \ 1. Old senders and receivers that are not aware of this change will\n\
    \ continue using the `labels` field.\n\
    \ 2. New senders, which are aware of this change MUST send only `attributes`.\n\
    \ 3. New receivers, which are aware of this change MUST convert this into\n\
    \ `labels` by simply converting all int64 values into float.\n\
    \\n\
    \ This field will be removed in ~3 months, on July 1, 2021.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\SOH\EOT\DC2\EOT\160\ETX\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\SOH\ACK\DC2\EOT\160\ETX\v7\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\SOH\SOH\DC2\EOT\160\ETX8>\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\SOH\ETX\DC2\EOT\160\ETXAB\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\SOH\b\DC2\EOT\160\ETXCV\n\
    \\SO\n\
    \\ACK\EOT\n\
    \\STX\SOH\b\ETX\DC2\EOT\160\ETXDU\n\
    \\197\SOH\n\
    \\EOT\EOT\n\
    \\STX\STX\DC2\EOT\167\ETX\STX#\SUB\182\SOH StartTimeUnixNano is optional but strongly encouraged, see the\n\
    \ the detailed comments above Metric.\n\
    \\n\
    \ Value is UNIX Epoch time in nanoseconds since 00:00:00 UTC on 1 January\n\
    \ 1970.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\STX\ENQ\DC2\EOT\167\ETX\STX\t\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\STX\SOH\DC2\EOT\167\ETX\n\
    \\RS\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\STX\ETX\DC2\EOT\167\ETX!\"\n\
    \\163\SOH\n\
    \\EOT\EOT\n\
    \\STX\ETX\DC2\EOT\173\ETX\STX\GS\SUB\148\SOH TimeUnixNano is required, see the detailed comments above Metric.\n\
    \\n\
    \ Value is UNIX Epoch time in nanoseconds since 00:00:00 UTC on 1 January\n\
    \ 1970.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\ETX\ENQ\DC2\EOT\173\ETX\STX\t\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\ETX\SOH\DC2\EOT\173\ETX\n\
    \\CAN\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\ETX\ETX\DC2\EOT\173\ETX\ESC\FS\n\
    \\186\SOH\n\
    \\EOT\EOT\n\
    \\STX\EOT\DC2\EOT\178\ETX\STX\DC4\SUB\171\SOH count is the number of values in the population. Must be non-negative. This\n\
    \ value must be equal to the sum of the \"count\" fields in buckets if a\n\
    \ histogram is provided.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\EOT\ENQ\DC2\EOT\178\ETX\STX\t\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\EOT\SOH\DC2\EOT\178\ETX\n\
    \\SI\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\EOT\ETX\DC2\EOT\178\ETX\DC2\DC3\n\
    \\245\ETX\n\
    \\EOT\EOT\n\
    \\STX\ENQ\DC2\EOT\188\ETX\STX\DC1\SUB\230\ETX sum of the values in the population. If count is zero then this field\n\
    \ must be zero.\n\
    \\n\
    \ Note: Sum should only be filled out when measuring non-negative discrete\n\
    \ events, and is assumed to be monotonic over the values of these events.\n\
    \ Negative events *can* be recorded, but sum should not be filled out when\n\
    \ doing so.  This is specifically to enforce compatibility w/ OpenMetrics,\n\
    \ see: https://github.com/OpenObservability/OpenMetrics/blob/main/specification/OpenMetrics.md#histogram\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\ENQ\ENQ\DC2\EOT\188\ETX\STX\b\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\ENQ\SOH\DC2\EOT\188\ETX\t\f\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\ENQ\ETX\DC2\EOT\188\ETX\SI\DLE\n\
    \\178\STX\n\
    \\EOT\EOT\n\
    \\STX\ACK\DC2\EOT\197\ETX\STX%\SUB\163\STX bucket_counts is an optional field contains the count values of histogram\n\
    \ for each bucket.\n\
    \\n\
    \ The sum of the bucket_counts must equal the value in the count field.\n\
    \\n\
    \ The number of elements in bucket_counts array must be by one greater than\n\
    \ the number of elements in explicit_bounds array.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\ACK\EOT\DC2\EOT\197\ETX\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\ACK\ENQ\DC2\EOT\197\ETX\v\DC2\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\ACK\SOH\DC2\EOT\197\ETX\DC3 \n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\ACK\ETX\DC2\EOT\197\ETX#$\n\
    \\215\EOT\n\
    \\EOT\EOT\n\
    \\STX\a\DC2\EOT\212\ETX\STX&\SUB\200\EOT explicit_bounds specifies buckets with explicitly defined bounds for values.\n\
    \\n\
    \ The boundaries for bucket at index i are:\n\
    \\n\
    \ (-infinity, explicit_bounds[i]] for i == 0\n\
    \ (explicit_bounds[i-1], explicit_bounds[i]] for 0 < i < size(explicit_bounds)\n\
    \ (explicit_bounds[i-1], +infinity) for i == size(explicit_bounds)\n\
    \\n\
    \ The values in the explicit_bounds array must be strictly increasing.\n\
    \\n\
    \ Histogram buckets are inclusive of their upper boundary, except the last\n\
    \ bucket where the boundary is at infinity. This format is intentionally\n\
    \ compatible with the OpenMetrics histogram definition.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\a\EOT\DC2\EOT\212\ETX\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\a\ENQ\DC2\EOT\212\ETX\v\DC1\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\a\SOH\DC2\EOT\212\ETX\DC2!\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\a\ETX\DC2\EOT\212\ETX$%\n\
    \o\n\
    \\EOT\EOT\n\
    \\STX\b\DC2\EOT\216\ETX\STX\"\SUBa (Optional) List of exemplars collected from\n\
    \ measurements that were used to form the data point\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\b\EOT\DC2\EOT\216\ETX\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\b\ACK\DC2\EOT\216\ETX\v\DC3\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\b\SOH\DC2\EOT\216\ETX\DC4\GS\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\b\ETX\DC2\EOT\216\ETX !\n\
    \}\n\
    \\EOT\EOT\n\
    \\STX\t\DC2\EOT\220\ETX\STX\DC4\SUBo Flags that apply to this specific data point.  See DataPointFlags\n\
    \ for the available flags and their meaning.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\t\ENQ\DC2\EOT\220\ETX\STX\b\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\t\SOH\DC2\EOT\220\ETX\t\SO\n\
    \\r\n\
    \\ENQ\EOT\n\
    \\STX\t\ETX\DC2\EOT\220\ETX\DC1\DC3\n\
    \\207\STX\n\
    \\STX\EOT\v\DC2\ACK\228\ETX\NUL\193\EOT\SOH\SUB\192\STX ExponentialHistogramDataPoint is a single data point in a timeseries that describes the\n\
    \ time-varying values of a ExponentialHistogram of double values. A ExponentialHistogram contains\n\
    \ summary statistics for a population of values, it may optionally contain the\n\
    \ distribution of those values across a set of buckets.\n\
    \\n\
    \\n\
    \\v\n\
    \\ETX\EOT\v\SOH\DC2\EOT\228\ETX\b%\n\
    \\161\SOH\n\
    \\EOT\EOT\v\STX\NUL\DC2\EOT\231\ETX\STXA\SUB\146\SOH The set of key/value pairs that uniquely identify the timeseries from\n\
    \ where this point belongs. The list may be empty (may contain 0 elements).\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\v\STX\NUL\EOT\DC2\EOT\231\ETX\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\v\STX\NUL\ACK\DC2\EOT\231\ETX\v1\n\
    \\r\n\
    \\ENQ\EOT\v\STX\NUL\SOH\DC2\EOT\231\ETX2<\n\
    \\r\n\
    \\ENQ\EOT\v\STX\NUL\ETX\DC2\EOT\231\ETX?@\n\
    \\197\SOH\n\
    \\EOT\EOT\v\STX\SOH\DC2\EOT\238\ETX\STX#\SUB\182\SOH StartTimeUnixNano is optional but strongly encouraged, see the\n\
    \ the detailed comments above Metric.\n\
    \\n\
    \ Value is UNIX Epoch time in nanoseconds since 00:00:00 UTC on 1 January\n\
    \ 1970.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\v\STX\SOH\ENQ\DC2\EOT\238\ETX\STX\t\n\
    \\r\n\
    \\ENQ\EOT\v\STX\SOH\SOH\DC2\EOT\238\ETX\n\
    \\RS\n\
    \\r\n\
    \\ENQ\EOT\v\STX\SOH\ETX\DC2\EOT\238\ETX!\"\n\
    \\163\SOH\n\
    \\EOT\EOT\v\STX\STX\DC2\EOT\244\ETX\STX\GS\SUB\148\SOH TimeUnixNano is required, see the detailed comments above Metric.\n\
    \\n\
    \ Value is UNIX Epoch time in nanoseconds since 00:00:00 UTC on 1 January\n\
    \ 1970.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\v\STX\STX\ENQ\DC2\EOT\244\ETX\STX\t\n\
    \\r\n\
    \\ENQ\EOT\v\STX\STX\SOH\DC2\EOT\244\ETX\n\
    \\CAN\n\
    \\r\n\
    \\ENQ\EOT\v\STX\STX\ETX\DC2\EOT\244\ETX\ESC\FS\n\
    \\221\SOH\n\
    \\EOT\EOT\v\STX\ETX\DC2\EOT\249\ETX\STX\DC4\SUB\206\SOH count is the number of values in the population. Must be\n\
    \ non-negative. This value must be equal to the sum of the \"bucket_counts\"\n\
    \ values in the positive and negative Buckets plus the \"zero_count\" field.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\v\STX\ETX\ENQ\DC2\EOT\249\ETX\STX\t\n\
    \\r\n\
    \\ENQ\EOT\v\STX\ETX\SOH\DC2\EOT\249\ETX\n\
    \\SI\n\
    \\r\n\
    \\ENQ\EOT\v\STX\ETX\ETX\DC2\EOT\249\ETX\DC2\DC3\n\
    \\245\ETX\n\
    \\EOT\EOT\v\STX\EOT\DC2\EOT\131\EOT\STX\DC1\SUB\230\ETX sum of the values in the population. If count is zero then this field\n\
    \ must be zero.\n\
    \\n\
    \ Note: Sum should only be filled out when measuring non-negative discrete\n\
    \ events, and is assumed to be monotonic over the values of these events.\n\
    \ Negative events *can* be recorded, but sum should not be filled out when\n\
    \ doing so.  This is specifically to enforce compatibility w/ OpenMetrics,\n\
    \ see: https://github.com/OpenObservability/OpenMetrics/blob/main/specification/OpenMetrics.md#histogram\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\v\STX\EOT\ENQ\DC2\EOT\131\EOT\STX\b\n\
    \\r\n\
    \\ENQ\EOT\v\STX\EOT\SOH\DC2\EOT\131\EOT\t\f\n\
    \\r\n\
    \\ENQ\EOT\v\STX\EOT\ETX\DC2\EOT\131\EOT\SI\DLE\n\
    \\226\EOT\n\
    \\EOT\EOT\v\STX\ENQ\DC2\EOT\148\EOT\STX\DC3\SUB\211\EOT scale describes the resolution of the histogram.  Boundaries are\n\
    \ located at powers of the base, where:\n\
    \\n\
    \   base = (2^(2^-scale))\n\
    \\n\
    \ The histogram bucket identified by `index`, a signed integer,\n\
    \ contains values that are greater than or equal to (base^index) and\n\
    \ less than (base^(index+1)).\n\
    \\n\
    \ The positive and negative ranges of the histogram are expressed\n\
    \ separately.  Negative values are mapped by their absolute value\n\
    \ into the negative range using the same scale as the positive range.\n\
    \\n\
    \ scale is not restricted by the protocol, as the permissible\n\
    \ values depend on the range of the data.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\v\STX\ENQ\ENQ\DC2\EOT\148\EOT\STX\b\n\
    \\r\n\
    \\ENQ\EOT\v\STX\ENQ\SOH\DC2\EOT\148\EOT\t\SO\n\
    \\r\n\
    \\ENQ\EOT\v\STX\ENQ\ETX\DC2\EOT\148\EOT\DC1\DC2\n\
    \\170\ETX\n\
    \\EOT\EOT\v\STX\ACK\DC2\EOT\158\EOT\STX\EM\SUB\155\ETX zero_count is the count of values that are either exactly zero or\n\
    \ within the region considered zero by the instrumentation at the\n\
    \ tolerated degree of precision.  This bucket stores values that\n\
    \ cannot be expressed using the standard exponential formula as\n\
    \ well as values that have been rounded to zero.\n\
    \\n\
    \ Implementations MAY consider the zero bucket to have probability\n\
    \ mass equal to (zero_count / count).\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\v\STX\ACK\ENQ\DC2\EOT\158\EOT\STX\t\n\
    \\r\n\
    \\ENQ\EOT\v\STX\ACK\SOH\DC2\EOT\158\EOT\n\
    \\DC4\n\
    \\r\n\
    \\ENQ\EOT\v\STX\ACK\ETX\DC2\EOT\158\EOT\ETB\CAN\n\
    \Q\n\
    \\EOT\EOT\v\STX\a\DC2\EOT\161\EOT\STX\ETB\SUBC positive carries the positive range of exponential bucket counts.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\v\STX\a\ACK\DC2\EOT\161\EOT\STX\t\n\
    \\r\n\
    \\ENQ\EOT\v\STX\a\SOH\DC2\EOT\161\EOT\n\
    \\DC2\n\
    \\r\n\
    \\ENQ\EOT\v\STX\a\ETX\DC2\EOT\161\EOT\NAK\SYN\n\
    \Q\n\
    \\EOT\EOT\v\STX\b\DC2\EOT\164\EOT\STX\ETB\SUBC negative carries the negative range of exponential bucket counts.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\v\STX\b\ACK\DC2\EOT\164\EOT\STX\t\n\
    \\r\n\
    \\ENQ\EOT\v\STX\b\SOH\DC2\EOT\164\EOT\n\
    \\DC2\n\
    \\r\n\
    \\ENQ\EOT\v\STX\b\ETX\DC2\EOT\164\EOT\NAK\SYN\n\
    \_\n\
    \\EOT\EOT\v\ETX\NUL\DC2\ACK\168\EOT\STX\184\EOT\ETX\SUBO Buckets are a set of bucket counts, encoded in a contiguous array\n\
    \ of counts.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\v\ETX\NUL\SOH\DC2\EOT\168\EOT\n\
    \\DC1\n\
    \\162\SOH\n\
    \\ACK\EOT\v\ETX\NUL\STX\NUL\DC2\EOT\172\EOT\EOT\SYN\SUB\145\SOH Offset is the bucket index of the first entry in the bucket_counts array.\n\
    \ \n\
    \ Note: This uses a varint encoding as a simple form of compression.\n\
    \\n\
    \\SI\n\
    \\a\EOT\v\ETX\NUL\STX\NUL\ENQ\DC2\EOT\172\EOT\EOT\n\
    \\n\
    \\SI\n\
    \\a\EOT\v\ETX\NUL\STX\NUL\SOH\DC2\EOT\172\EOT\v\DC1\n\
    \\SI\n\
    \\a\EOT\v\ETX\NUL\STX\NUL\ETX\DC2\EOT\172\EOT\DC4\NAK\n\
    \\158\ETX\n\
    \\ACK\EOT\v\ETX\NUL\STX\SOH\DC2\EOT\183\EOT\EOT&\SUB\141\ETX Count is an array of counts, where count[i] carries the count\n\
    \ of the bucket at index (offset+i).  count[i] is the count of\n\
    \ values greater than or equal to base^(offset+i) and less than\n\
    \ base^(offset+i+1).\n\
    \\n\
    \ Note: By contrast, the explicit HistogramDataPoint uses\n\
    \ fixed64.  This field is expected to have many buckets,\n\
    \ especially zeros, so uint64 has been selected to ensure\n\
    \ varint encoding.\n\
    \\n\
    \\SI\n\
    \\a\EOT\v\ETX\NUL\STX\SOH\EOT\DC2\EOT\183\EOT\EOT\f\n\
    \\SI\n\
    \\a\EOT\v\ETX\NUL\STX\SOH\ENQ\DC2\EOT\183\EOT\r\DC3\n\
    \\SI\n\
    \\a\EOT\v\ETX\NUL\STX\SOH\SOH\DC2\EOT\183\EOT\DC4!\n\
    \\SI\n\
    \\a\EOT\v\ETX\NUL\STX\SOH\ETX\DC2\EOT\183\EOT$%\n\
    \}\n\
    \\EOT\EOT\v\STX\t\DC2\EOT\188\EOT\STX\DC4\SUBo Flags that apply to this specific data point.  See DataPointFlags\n\
    \ for the available flags and their meaning.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\v\STX\t\ENQ\DC2\EOT\188\EOT\STX\b\n\
    \\r\n\
    \\ENQ\EOT\v\STX\t\SOH\DC2\EOT\188\EOT\t\SO\n\
    \\r\n\
    \\ENQ\EOT\v\STX\t\ETX\DC2\EOT\188\EOT\DC1\DC3\n\
    \o\n\
    \\EOT\EOT\v\STX\n\
    \\DC2\EOT\192\EOT\STX#\SUBa (Optional) List of exemplars collected from\n\
    \ measurements that were used to form the data point\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\v\STX\n\
    \\EOT\DC2\EOT\192\EOT\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\v\STX\n\
    \\ACK\DC2\EOT\192\EOT\v\DC3\n\
    \\r\n\
    \\ENQ\EOT\v\STX\n\
    \\SOH\DC2\EOT\192\EOT\DC4\GS\n\
    \\r\n\
    \\ENQ\EOT\v\STX\n\
    \\ETX\DC2\EOT\192\EOT \"\n\
    \\132\SOH\n\
    \\STX\EOT\f\DC2\ACK\197\EOT\NUL\136\ENQ\SOH\SUBv SummaryDataPoint is a single data point in a timeseries that describes the\n\
    \ time-varying values of a Summary metric.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\f\SOH\DC2\EOT\197\EOT\b\CAN\n\
    \\161\SOH\n\
    \\EOT\EOT\f\STX\NUL\DC2\EOT\200\EOT\STXA\SUB\146\SOH The set of key/value pairs that uniquely identify the timeseries from\n\
    \ where this point belongs. The list may be empty (may contain 0 elements).\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\f\STX\NUL\EOT\DC2\EOT\200\EOT\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\f\STX\NUL\ACK\DC2\EOT\200\EOT\v1\n\
    \\r\n\
    \\ENQ\EOT\f\STX\NUL\SOH\DC2\EOT\200\EOT2<\n\
    \\r\n\
    \\ENQ\EOT\f\STX\NUL\ETX\DC2\EOT\200\EOT?@\n\
    \\182\ETX\n\
    \\EOT\EOT\f\STX\SOH\DC2\EOT\210\EOT\STXW\SUB\167\ETX Labels is deprecated and will be removed soon.\n\
    \ 1. Old senders and receivers that are not aware of this change will\n\
    \ continue using the `labels` field.\n\
    \ 2. New senders, which are aware of this change MUST send only `attributes`.\n\
    \ 3. New receivers, which are aware of this change MUST convert this into\n\
    \ `labels` by simply converting all int64 values into float.\n\
    \\n\
    \ This field will be removed in ~3 months, on July 1, 2021.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\f\STX\SOH\EOT\DC2\EOT\210\EOT\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\f\STX\SOH\ACK\DC2\EOT\210\EOT\v7\n\
    \\r\n\
    \\ENQ\EOT\f\STX\SOH\SOH\DC2\EOT\210\EOT8>\n\
    \\r\n\
    \\ENQ\EOT\f\STX\SOH\ETX\DC2\EOT\210\EOTAB\n\
    \\r\n\
    \\ENQ\EOT\f\STX\SOH\b\DC2\EOT\210\EOTCV\n\
    \\SO\n\
    \\ACK\EOT\f\STX\SOH\b\ETX\DC2\EOT\210\EOTDU\n\
    \\197\SOH\n\
    \\EOT\EOT\f\STX\STX\DC2\EOT\217\EOT\STX#\SUB\182\SOH StartTimeUnixNano is optional but strongly encouraged, see the\n\
    \ the detailed comments above Metric.\n\
    \\n\
    \ Value is UNIX Epoch time in nanoseconds since 00:00:00 UTC on 1 January\n\
    \ 1970.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\f\STX\STX\ENQ\DC2\EOT\217\EOT\STX\t\n\
    \\r\n\
    \\ENQ\EOT\f\STX\STX\SOH\DC2\EOT\217\EOT\n\
    \\RS\n\
    \\r\n\
    \\ENQ\EOT\f\STX\STX\ETX\DC2\EOT\217\EOT!\"\n\
    \\163\SOH\n\
    \\EOT\EOT\f\STX\ETX\DC2\EOT\223\EOT\STX\GS\SUB\148\SOH TimeUnixNano is required, see the detailed comments above Metric.\n\
    \\n\
    \ Value is UNIX Epoch time in nanoseconds since 00:00:00 UTC on 1 January\n\
    \ 1970.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\f\STX\ETX\ENQ\DC2\EOT\223\EOT\STX\t\n\
    \\r\n\
    \\ENQ\EOT\f\STX\ETX\SOH\DC2\EOT\223\EOT\n\
    \\CAN\n\
    \\r\n\
    \\ENQ\EOT\f\STX\ETX\ETX\DC2\EOT\223\EOT\ESC\FS\n\
    \V\n\
    \\EOT\EOT\f\STX\EOT\DC2\EOT\226\EOT\STX\DC4\SUBH count is the number of values in the population. Must be non-negative.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\f\STX\EOT\ENQ\DC2\EOT\226\EOT\STX\t\n\
    \\r\n\
    \\ENQ\EOT\f\STX\EOT\SOH\DC2\EOT\226\EOT\n\
    \\SI\n\
    \\r\n\
    \\ENQ\EOT\f\STX\EOT\ETX\DC2\EOT\226\EOT\DC2\DC3\n\
    \\243\ETX\n\
    \\EOT\EOT\f\STX\ENQ\DC2\EOT\236\EOT\STX\DC1\SUB\228\ETX sum of the values in the population. If count is zero then this field\n\
    \ must be zero.\n\
    \\n\
    \ Note: Sum should only be filled out when measuring non-negative discrete\n\
    \ events, and is assumed to be monotonic over the values of these events.\n\
    \ Negative events *can* be recorded, but sum should not be filled out when\n\
    \ doing so.  This is specifically to enforce compatibility w/ OpenMetrics,\n\
    \ see: https://github.com/OpenObservability/OpenMetrics/blob/main/specification/OpenMetrics.md#summary\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\f\STX\ENQ\ENQ\DC2\EOT\236\EOT\STX\b\n\
    \\r\n\
    \\ENQ\EOT\f\STX\ENQ\SOH\DC2\EOT\236\EOT\t\f\n\
    \\r\n\
    \\ENQ\EOT\f\STX\ENQ\ETX\DC2\EOT\236\EOT\SI\DLE\n\
    \\253\STX\n\
    \\EOT\EOT\f\ETX\NUL\DC2\ACK\246\EOT\STX\255\EOT\ETX\SUB\236\STX Represents the value at a given quantile of a distribution.\n\
    \\n\
    \ To record Min and Max values following conventions are used:\n\
    \ - The 1.0 quantile is equivalent to the maximum value observed.\n\
    \ - The 0.0 quantile is equivalent to the minimum value observed.\n\
    \\n\
    \ See the following issue for more context:\n\
    \ https://github.com/open-telemetry/opentelemetry-proto/issues/125\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\f\ETX\NUL\SOH\DC2\EOT\246\EOT\n\
    \\EM\n\
    \V\n\
    \\ACK\EOT\f\ETX\NUL\STX\NUL\DC2\EOT\249\EOT\EOT\CAN\SUBF The quantile of a distribution. Must be in the interval\n\
    \ [0.0, 1.0].\n\
    \\n\
    \\SI\n\
    \\a\EOT\f\ETX\NUL\STX\NUL\ENQ\DC2\EOT\249\EOT\EOT\n\
    \\n\
    \\SI\n\
    \\a\EOT\f\ETX\NUL\STX\NUL\SOH\DC2\EOT\249\EOT\v\DC3\n\
    \\SI\n\
    \\a\EOT\f\ETX\NUL\STX\NUL\ETX\DC2\EOT\249\EOT\SYN\ETB\n\
    \l\n\
    \\ACK\EOT\f\ETX\NUL\STX\SOH\DC2\EOT\254\EOT\EOT\NAK\SUB\\ The value at the given quantile of a distribution.\n\
    \\n\
    \ Quantile values must NOT be negative.\n\
    \\n\
    \\SI\n\
    \\a\EOT\f\ETX\NUL\STX\SOH\ENQ\DC2\EOT\254\EOT\EOT\n\
    \\n\
    \\SI\n\
    \\a\EOT\f\ETX\NUL\STX\SOH\SOH\DC2\EOT\254\EOT\v\DLE\n\
    \\SI\n\
    \\a\EOT\f\ETX\NUL\STX\SOH\ETX\DC2\EOT\254\EOT\DC3\DC4\n\
    \\167\SOH\n\
    \\EOT\EOT\f\STX\ACK\DC2\EOT\131\ENQ\STX/\SUB\152\SOH (Optional) list of values at different quantiles of the distribution calculated\n\
    \ from the current snapshot. The quantiles must be strictly increasing.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\f\STX\ACK\EOT\DC2\EOT\131\ENQ\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\f\STX\ACK\ACK\DC2\EOT\131\ENQ\v\SUB\n\
    \\r\n\
    \\ENQ\EOT\f\STX\ACK\SOH\DC2\EOT\131\ENQ\ESC*\n\
    \\r\n\
    \\ENQ\EOT\f\STX\ACK\ETX\DC2\EOT\131\ENQ-.\n\
    \}\n\
    \\EOT\EOT\f\STX\a\DC2\EOT\135\ENQ\STX\DC3\SUBo Flags that apply to this specific data point.  See DataPointFlags\n\
    \ for the available flags and their meaning.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\f\STX\a\ENQ\DC2\EOT\135\ENQ\STX\b\n\
    \\r\n\
    \\ENQ\EOT\f\STX\a\SOH\DC2\EOT\135\ENQ\t\SO\n\
    \\r\n\
    \\ENQ\EOT\f\STX\a\ETX\DC2\EOT\135\ENQ\DC1\DC2\n\
    \\135\STX\n\
    \\STX\EOT\r\DC2\ACK\142\ENQ\NUL\182\ENQ\SOH\SUB\248\SOH A representation of an exemplar, which is a sample input measurement.\n\
    \ Exemplars also hold information about the environment when the measurement\n\
    \ was recorded, for example the span and trace ID of the active span when the\n\
    \ exemplar was recorded.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\r\SOH\DC2\EOT\142\ENQ\b\DLE\n\
    \\217\SOH\n\
    \\EOT\EOT\r\STX\NUL\DC2\EOT\146\ENQ\STXJ\SUB\202\SOH The set of key/value pairs that were filtered out by the aggregator, but\n\
    \ recorded alongside the original measurement. Only key/value pairs that were\n\
    \ filtered out by the aggregator should be included\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\r\STX\NUL\EOT\DC2\EOT\146\ENQ\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\r\STX\NUL\ACK\DC2\EOT\146\ENQ\v1\n\
    \\r\n\
    \\ENQ\EOT\r\STX\NUL\SOH\DC2\EOT\146\ENQ2E\n\
    \\r\n\
    \\ENQ\EOT\r\STX\NUL\ETX\DC2\EOT\146\ENQHI\n\
    \\210\ETX\n\
    \\EOT\EOT\r\STX\SOH\DC2\EOT\157\ENQ\STX`\SUB\195\ETX Labels is deprecated and will be removed soon.\n\
    \ 1. Old senders and receivers that are not aware of this change will\n\
    \ continue using the `filtered_labels` field.\n\
    \ 2. New senders, which are aware of this change MUST send only\n\
    \ `filtered_attributes`.\n\
    \ 3. New receivers, which are aware of this change MUST convert this into\n\
    \ `filtered_labels` by simply converting all int64 values into float.\n\
    \\n\
    \ This field will be removed in ~3 months, on July 1, 2021.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\r\STX\SOH\EOT\DC2\EOT\157\ENQ\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\r\STX\SOH\ACK\DC2\EOT\157\ENQ\v7\n\
    \\r\n\
    \\ENQ\EOT\r\STX\SOH\SOH\DC2\EOT\157\ENQ8G\n\
    \\r\n\
    \\ENQ\EOT\r\STX\SOH\ETX\DC2\EOT\157\ENQJK\n\
    \\r\n\
    \\ENQ\EOT\r\STX\SOH\b\DC2\EOT\157\ENQL_\n\
    \\SO\n\
    \\ACK\EOT\r\STX\SOH\b\ETX\DC2\EOT\157\ENQM^\n\
    \\162\SOH\n\
    \\EOT\EOT\r\STX\STX\DC2\EOT\163\ENQ\STX\GS\SUB\147\SOH time_unix_nano is the exact time when this exemplar was recorded\n\
    \\n\
    \ Value is UNIX Epoch time in nanoseconds since 00:00:00 UTC on 1 January\n\
    \ 1970.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\r\STX\STX\ENQ\DC2\EOT\163\ENQ\STX\t\n\
    \\r\n\
    \\ENQ\EOT\r\STX\STX\SOH\DC2\EOT\163\ENQ\n\
    \\CAN\n\
    \\r\n\
    \\ENQ\EOT\r\STX\STX\ETX\DC2\EOT\163\ENQ\ESC\FS\n\
    \\176\SOH\n\
    \\EOT\EOT\r\b\NUL\DC2\ACK\168\ENQ\STX\171\ENQ\ETX\SUB\159\SOH The value of the measurement that was recorded. An exemplar is\n\
    \ considered invalid when one of the recognized value fields is not present\n\
    \ inside this oneof.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\r\b\NUL\SOH\DC2\EOT\168\ENQ\b\r\n\
    \\f\n\
    \\EOT\EOT\r\STX\ETX\DC2\EOT\169\ENQ\EOT\EM\n\
    \\r\n\
    \\ENQ\EOT\r\STX\ETX\ENQ\DC2\EOT\169\ENQ\EOT\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\r\STX\ETX\SOH\DC2\EOT\169\ENQ\v\DC4\n\
    \\r\n\
    \\ENQ\EOT\r\STX\ETX\ETX\DC2\EOT\169\ENQ\ETB\CAN\n\
    \\f\n\
    \\EOT\EOT\r\STX\EOT\DC2\EOT\170\ENQ\EOT\CAN\n\
    \\r\n\
    \\ENQ\EOT\r\STX\EOT\ENQ\DC2\EOT\170\ENQ\EOT\f\n\
    \\r\n\
    \\ENQ\EOT\r\STX\EOT\SOH\DC2\EOT\170\ENQ\r\DC3\n\
    \\r\n\
    \\ENQ\EOT\r\STX\EOT\ETX\DC2\EOT\170\ENQ\SYN\ETB\n\
    \\165\SOH\n\
    \\EOT\EOT\r\STX\ENQ\DC2\EOT\176\ENQ\STX\DC4\SUB\150\SOH (Optional) Span ID of the exemplar trace.\n\
    \ span_id may be missing if the measurement is not recorded inside a trace\n\
    \ or if the trace is not sampled.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\r\STX\ENQ\ENQ\DC2\EOT\176\ENQ\STX\a\n\
    \\r\n\
    \\ENQ\EOT\r\STX\ENQ\SOH\DC2\EOT\176\ENQ\b\SI\n\
    \\r\n\
    \\ENQ\EOT\r\STX\ENQ\ETX\DC2\EOT\176\ENQ\DC2\DC3\n\
    \\167\SOH\n\
    \\EOT\EOT\r\STX\ACK\DC2\EOT\181\ENQ\STX\NAK\SUB\152\SOH (Optional) Trace ID of the exemplar trace.\n\
    \ trace_id may be missing if the measurement is not recorded inside a trace\n\
    \ or if the trace is not sampled.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\r\STX\ACK\ENQ\DC2\EOT\181\ENQ\STX\a\n\
    \\r\n\
    \\ENQ\EOT\r\STX\ACK\SOH\DC2\EOT\181\ENQ\b\DLE\n\
    \\r\n\
    \\ENQ\EOT\r\STX\ACK\ETX\DC2\EOT\181\ENQ\DC3\DC4\n\
    \\DEL\n\
    \\STX\EOT\SO\DC2\ACK\189\ENQ\NUL\214\ENQ\SOH\SUBC IntDataPoint is deprecated. Use integer value in NumberDataPoint.\n\
    \2,\n\
    \ Move deprecated messages below this line\n\
    \\n\
    \\n\
    \\v\n\
    \\ETX\EOT\SO\SOH\DC2\EOT\189\ENQ\b\DC4\n\
    \\v\n\
    \\ETX\EOT\SO\a\DC2\EOT\190\ENQ\STX\ESC\n\
    \\f\n\
    \\EOT\EOT\SO\a\ETX\DC2\EOT\190\ENQ\STX\ESC\n\
    \I\n\
    \\EOT\EOT\SO\STX\NUL\DC2\EOT\193\ENQ\STXC\SUB; The set of labels that uniquely identify this timeseries.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\SO\STX\NUL\EOT\DC2\EOT\193\ENQ\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\SO\STX\NUL\ACK\DC2\EOT\193\ENQ\v7\n\
    \\r\n\
    \\ENQ\EOT\SO\STX\NUL\SOH\DC2\EOT\193\ENQ8>\n\
    \\r\n\
    \\ENQ\EOT\SO\STX\NUL\ETX\DC2\EOT\193\ENQAB\n\
    \\197\SOH\n\
    \\EOT\EOT\SO\STX\SOH\DC2\EOT\200\ENQ\STX#\SUB\182\SOH StartTimeUnixNano is optional but strongly encouraged, see the\n\
    \ the detailed comments above Metric.\n\
    \\n\
    \ Value is UNIX Epoch time in nanoseconds since 00:00:00 UTC on 1 January\n\
    \ 1970.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\SO\STX\SOH\ENQ\DC2\EOT\200\ENQ\STX\t\n\
    \\r\n\
    \\ENQ\EOT\SO\STX\SOH\SOH\DC2\EOT\200\ENQ\n\
    \\RS\n\
    \\r\n\
    \\ENQ\EOT\SO\STX\SOH\ETX\DC2\EOT\200\ENQ!\"\n\
    \\163\SOH\n\
    \\EOT\EOT\SO\STX\STX\DC2\EOT\206\ENQ\STX\GS\SUB\148\SOH TimeUnixNano is required, see the detailed comments above Metric.\n\
    \\n\
    \ Value is UNIX Epoch time in nanoseconds since 00:00:00 UTC on 1 January\n\
    \ 1970.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\SO\STX\STX\ENQ\DC2\EOT\206\ENQ\STX\t\n\
    \\r\n\
    \\ENQ\EOT\SO\STX\STX\SOH\DC2\EOT\206\ENQ\n\
    \\CAN\n\
    \\r\n\
    \\ENQ\EOT\SO\STX\STX\ETX\DC2\EOT\206\ENQ\ESC\FS\n\
    \\GS\n\
    \\EOT\EOT\SO\STX\ETX\DC2\EOT\209\ENQ\STX\NAK\SUB\SI value itself.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\SO\STX\ETX\ENQ\DC2\EOT\209\ENQ\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\SO\STX\ETX\SOH\DC2\EOT\209\ENQ\v\DLE\n\
    \\r\n\
    \\ENQ\EOT\SO\STX\ETX\ETX\DC2\EOT\209\ENQ\DC3\DC4\n\
    \o\n\
    \\EOT\EOT\SO\STX\EOT\DC2\EOT\213\ENQ\STX%\SUBa (Optional) List of exemplars collected from\n\
    \ measurements that were used to form the data point\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\SO\STX\EOT\EOT\DC2\EOT\213\ENQ\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\SO\STX\EOT\ACK\DC2\EOT\213\ENQ\v\SYN\n\
    \\r\n\
    \\ENQ\EOT\SO\STX\EOT\SOH\DC2\EOT\213\ENQ\ETB \n\
    \\r\n\
    \\ENQ\EOT\SO\STX\EOT\ETX\DC2\EOT\213\ENQ#$\n\
    \\\\n\
    \\STX\EOT\SI\DC2\ACK\217\ENQ\NUL\221\ENQ\SOH\SUBN IntGauge is deprecated.  Use Gauge with an integer value in NumberDataPoint.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\SI\SOH\DC2\EOT\217\ENQ\b\DLE\n\
    \\v\n\
    \\ETX\EOT\SI\a\DC2\EOT\218\ENQ\STX\ESC\n\
    \\f\n\
    \\EOT\EOT\SI\a\ETX\DC2\EOT\218\ENQ\STX\ESC\n\
    \\f\n\
    \\EOT\EOT\SI\STX\NUL\DC2\EOT\220\ENQ\STX(\n\
    \\r\n\
    \\ENQ\EOT\SI\STX\NUL\EOT\DC2\EOT\220\ENQ\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\SI\STX\NUL\ACK\DC2\EOT\220\ENQ\v\ETB\n\
    \\r\n\
    \\ENQ\EOT\SI\STX\NUL\SOH\DC2\EOT\220\ENQ\CAN#\n\
    \\r\n\
    \\ENQ\EOT\SI\STX\NUL\ETX\DC2\EOT\220\ENQ&'\n\
    \X\n\
    \\STX\EOT\DLE\DC2\ACK\224\ENQ\NUL\235\ENQ\SOH\SUBJ IntSum is deprecated.  Use Sum with an integer value in NumberDataPoint.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\DLE\SOH\DC2\EOT\224\ENQ\b\SO\n\
    \\v\n\
    \\ETX\EOT\DLE\a\DC2\EOT\225\ENQ\STX\ESC\n\
    \\f\n\
    \\EOT\EOT\DLE\a\ETX\DC2\EOT\225\ENQ\STX\ESC\n\
    \\f\n\
    \\EOT\EOT\DLE\STX\NUL\DC2\EOT\227\ENQ\STX(\n\
    \\r\n\
    \\ENQ\EOT\DLE\STX\NUL\EOT\DC2\EOT\227\ENQ\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DLE\STX\NUL\ACK\DC2\EOT\227\ENQ\v\ETB\n\
    \\r\n\
    \\ENQ\EOT\DLE\STX\NUL\SOH\DC2\EOT\227\ENQ\CAN#\n\
    \\r\n\
    \\ENQ\EOT\DLE\STX\NUL\ETX\DC2\EOT\227\ENQ&'\n\
    \\163\SOH\n\
    \\EOT\EOT\DLE\STX\SOH\DC2\EOT\231\ENQ\STX5\SUB\148\SOH aggregation_temporality describes if the aggregator reports delta changes\n\
    \ since last report time, or cumulative changes since a fixed start time.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DLE\STX\SOH\ACK\DC2\EOT\231\ENQ\STX\CAN\n\
    \\r\n\
    \\ENQ\EOT\DLE\STX\SOH\SOH\DC2\EOT\231\ENQ\EM0\n\
    \\r\n\
    \\ENQ\EOT\DLE\STX\SOH\ETX\DC2\EOT\231\ENQ34\n\
    \:\n\
    \\EOT\EOT\DLE\STX\STX\DC2\EOT\234\ENQ\STX\CAN\SUB, If \"true\" means that the sum is monotonic.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DLE\STX\STX\ENQ\DC2\EOT\234\ENQ\STX\ACK\n\
    \\r\n\
    \\ENQ\EOT\DLE\STX\STX\SOH\DC2\EOT\234\ENQ\a\DC3\n\
    \\r\n\
    \\ENQ\EOT\DLE\STX\STX\ETX\DC2\EOT\234\ENQ\SYN\ETB\n\
    \L\n\
    \\STX\EOT\DC1\DC2\ACK\238\ENQ\NUL\166\ACK\SOH\SUB> IntHistogramDataPoint is deprecated; use HistogramDataPoint.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\DC1\SOH\DC2\EOT\238\ENQ\b\GS\n\
    \\v\n\
    \\ETX\EOT\DC1\a\DC2\EOT\239\ENQ\STX\ESC\n\
    \\f\n\
    \\EOT\EOT\DC1\a\ETX\DC2\EOT\239\ENQ\STX\ESC\n\
    \I\n\
    \\EOT\EOT\DC1\STX\NUL\DC2\EOT\242\ENQ\STXC\SUB; The set of labels that uniquely identify this timeseries.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\NUL\EOT\DC2\EOT\242\ENQ\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\NUL\ACK\DC2\EOT\242\ENQ\v7\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\NUL\SOH\DC2\EOT\242\ENQ8>\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\NUL\ETX\DC2\EOT\242\ENQAB\n\
    \\197\SOH\n\
    \\EOT\EOT\DC1\STX\SOH\DC2\EOT\249\ENQ\STX#\SUB\182\SOH StartTimeUnixNano is optional but strongly encouraged, see the\n\
    \ the detailed comments above Metric.\n\
    \\n\
    \ Value is UNIX Epoch time in nanoseconds since 00:00:00 UTC on 1 January\n\
    \ 1970.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\SOH\ENQ\DC2\EOT\249\ENQ\STX\t\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\SOH\SOH\DC2\EOT\249\ENQ\n\
    \\RS\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\SOH\ETX\DC2\EOT\249\ENQ!\"\n\
    \\163\SOH\n\
    \\EOT\EOT\DC1\STX\STX\DC2\EOT\255\ENQ\STX\GS\SUB\148\SOH TimeUnixNano is required, see the detailed comments above Metric.\n\
    \\n\
    \ Value is UNIX Epoch time in nanoseconds since 00:00:00 UTC on 1 January\n\
    \ 1970.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\STX\ENQ\DC2\EOT\255\ENQ\STX\t\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\STX\SOH\DC2\EOT\255\ENQ\n\
    \\CAN\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\STX\ETX\DC2\EOT\255\ENQ\ESC\FS\n\
    \\186\SOH\n\
    \\EOT\EOT\DC1\STX\ETX\DC2\EOT\132\ACK\STX\DC4\SUB\171\SOH count is the number of values in the population. Must be non-negative. This\n\
    \ value must be equal to the sum of the \"count\" fields in buckets if a\n\
    \ histogram is provided.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\ETX\ENQ\DC2\EOT\132\ACK\STX\t\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\ETX\SOH\DC2\EOT\132\ACK\n\
    \\SI\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\ETX\ETX\DC2\EOT\132\ACK\DC2\DC3\n\
    \\197\SOH\n\
    \\EOT\EOT\DC1\STX\EOT\DC2\EOT\137\ACK\STX\DC3\SUB\182\SOH sum of the values in the population. If count is zero then this field\n\
    \ must be zero. This value must be equal to the sum of the \"sum\" fields in\n\
    \ buckets if a histogram is provided.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\EOT\ENQ\DC2\EOT\137\ACK\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\EOT\SOH\DC2\EOT\137\ACK\v\SO\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\EOT\ETX\DC2\EOT\137\ACK\DC1\DC2\n\
    \\178\STX\n\
    \\EOT\EOT\DC1\STX\ENQ\DC2\EOT\146\ACK\STX%\SUB\163\STX bucket_counts is an optional field contains the count values of histogram\n\
    \ for each bucket.\n\
    \\n\
    \ The sum of the bucket_counts must equal the value in the count field.\n\
    \\n\
    \ The number of elements in bucket_counts array must be by one greater than\n\
    \ the number of elements in explicit_bounds array.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\ENQ\EOT\DC2\EOT\146\ACK\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\ENQ\ENQ\DC2\EOT\146\ACK\v\DC2\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\ENQ\SOH\DC2\EOT\146\ACK\DC3 \n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\ENQ\ETX\DC2\EOT\146\ACK#$\n\
    \\215\EOT\n\
    \\EOT\EOT\DC1\STX\ACK\DC2\EOT\161\ACK\STX&\SUB\200\EOT explicit_bounds specifies buckets with explicitly defined bounds for values.\n\
    \\n\
    \ The boundaries for bucket at index i are:\n\
    \\n\
    \ (-infinity, explicit_bounds[i]] for i == 0\n\
    \ (explicit_bounds[i-1], explicit_bounds[i]] for 0 < i < size(explicit_bounds)\n\
    \ (explicit_bounds[i-1], +infinity) for i == size(explicit_bounds)\n\
    \\n\
    \ The values in the explicit_bounds array must be strictly increasing.\n\
    \\n\
    \ Histogram buckets are inclusive of their upper boundary, except the last\n\
    \ bucket where the boundary is at infinity. This format is intentionally\n\
    \ compatible with the OpenMetrics histogram definition.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\ACK\EOT\DC2\EOT\161\ACK\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\ACK\ENQ\DC2\EOT\161\ACK\v\DC1\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\ACK\SOH\DC2\EOT\161\ACK\DC2!\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\ACK\ETX\DC2\EOT\161\ACK$%\n\
    \o\n\
    \\EOT\EOT\DC1\STX\a\DC2\EOT\165\ACK\STX%\SUBa (Optional) List of exemplars collected from\n\
    \ measurements that were used to form the data point\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\a\EOT\DC2\EOT\165\ACK\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\a\ACK\DC2\EOT\165\ACK\v\SYN\n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\a\SOH\DC2\EOT\165\ACK\ETB \n\
    \\r\n\
    \\ENQ\EOT\DC1\STX\a\ETX\DC2\EOT\165\ACK#$\n\
    \i\n\
    \\STX\EOT\DC2\DC2\ACK\170\ACK\NUL\178\ACK\SOH\SUB[ IntHistogram is deprecated, replaced by Histogram points using double-\n\
    \ valued exemplars.\n\
    \\n\
    \\v\n\
    \\ETX\EOT\DC2\SOH\DC2\EOT\170\ACK\b\DC4\n\
    \\v\n\
    \\ETX\EOT\DC2\a\DC2\EOT\171\ACK\STX\ESC\n\
    \\f\n\
    \\EOT\EOT\DC2\a\ETX\DC2\EOT\171\ACK\STX\ESC\n\
    \\f\n\
    \\EOT\EOT\DC2\STX\NUL\DC2\EOT\173\ACK\STX1\n\
    \\r\n\
    \\ENQ\EOT\DC2\STX\NUL\EOT\DC2\EOT\173\ACK\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DC2\STX\NUL\ACK\DC2\EOT\173\ACK\v \n\
    \\r\n\
    \\ENQ\EOT\DC2\STX\NUL\SOH\DC2\EOT\173\ACK!,\n\
    \\r\n\
    \\ENQ\EOT\DC2\STX\NUL\ETX\DC2\EOT\173\ACK/0\n\
    \\163\SOH\n\
    \\EOT\EOT\DC2\STX\SOH\DC2\EOT\177\ACK\STX5\SUB\148\SOH aggregation_temporality describes if the aggregator reports delta changes\n\
    \ since last report time, or cumulative changes since a fixed start time.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DC2\STX\SOH\ACK\DC2\EOT\177\ACK\STX\CAN\n\
    \\r\n\
    \\ENQ\EOT\DC2\STX\SOH\SOH\DC2\EOT\177\ACK\EM0\n\
    \\r\n\
    \\ENQ\EOT\DC2\STX\SOH\ETX\DC2\EOT\177\ACK34\n\
    \M\n\
    \\STX\EOT\DC3\DC2\ACK\181\ACK\NUL\207\ACK\SOH\SUB? IntExemplar is deprecated. Use Exemplar with as_int for value\n\
    \\n\
    \\v\n\
    \\ETX\EOT\DC3\SOH\DC2\EOT\181\ACK\b\DC3\n\
    \\v\n\
    \\ETX\EOT\DC3\a\DC2\EOT\182\ACK\STX\ESC\n\
    \\f\n\
    \\EOT\EOT\DC3\a\ETX\DC2\EOT\182\ACK\STX\ESC\n\
    \\199\SOH\n\
    \\EOT\EOT\DC3\STX\NUL\DC2\EOT\187\ACK\STXL\SUB\184\SOH The set of labels that were filtered out by the aggregator, but recorded\n\
    \ alongside the original measurement. Only labels that were filtered out\n\
    \ by the aggregator should be included\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DC3\STX\NUL\EOT\DC2\EOT\187\ACK\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DC3\STX\NUL\ACK\DC2\EOT\187\ACK\v7\n\
    \\r\n\
    \\ENQ\EOT\DC3\STX\NUL\SOH\DC2\EOT\187\ACK8G\n\
    \\r\n\
    \\ENQ\EOT\DC3\STX\NUL\ETX\DC2\EOT\187\ACKJK\n\
    \\162\SOH\n\
    \\EOT\EOT\DC3\STX\SOH\DC2\EOT\193\ACK\STX\GS\SUB\147\SOH time_unix_nano is the exact time when this exemplar was recorded\n\
    \\n\
    \ Value is UNIX Epoch time in nanoseconds since 00:00:00 UTC on 1 January\n\
    \ 1970.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DC3\STX\SOH\ENQ\DC2\EOT\193\ACK\STX\t\n\
    \\r\n\
    \\ENQ\EOT\DC3\STX\SOH\SOH\DC2\EOT\193\ACK\n\
    \\CAN\n\
    \\r\n\
    \\ENQ\EOT\DC3\STX\SOH\ETX\DC2\EOT\193\ACK\ESC\FS\n\
    \I\n\
    \\EOT\EOT\DC3\STX\STX\DC2\EOT\196\ACK\STX\NAK\SUB; Numerical int value of the measurement that was recorded.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DC3\STX\STX\ENQ\DC2\EOT\196\ACK\STX\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DC3\STX\STX\SOH\DC2\EOT\196\ACK\v\DLE\n\
    \\r\n\
    \\ENQ\EOT\DC3\STX\STX\ETX\DC2\EOT\196\ACK\DC3\DC4\n\
    \\165\SOH\n\
    \\EOT\EOT\DC3\STX\ETX\DC2\EOT\201\ACK\STX\DC4\SUB\150\SOH (Optional) Span ID of the exemplar trace.\n\
    \ span_id may be missing if the measurement is not recorded inside a trace\n\
    \ or if the trace is not sampled.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DC3\STX\ETX\ENQ\DC2\EOT\201\ACK\STX\a\n\
    \\r\n\
    \\ENQ\EOT\DC3\STX\ETX\SOH\DC2\EOT\201\ACK\b\SI\n\
    \\r\n\
    \\ENQ\EOT\DC3\STX\ETX\ETX\DC2\EOT\201\ACK\DC2\DC3\n\
    \\167\SOH\n\
    \\EOT\EOT\DC3\STX\EOT\DC2\EOT\206\ACK\STX\NAK\SUB\152\SOH (Optional) Trace ID of the exemplar trace.\n\
    \ trace_id may be missing if the measurement is not recorded inside a trace\n\
    \ or if the trace is not sampled.\n\
    \\n\
    \\r\n\
    \\ENQ\EOT\DC3\STX\EOT\ENQ\DC2\EOT\206\ACK\STX\a\n\
    \\r\n\
    \\ENQ\EOT\DC3\STX\EOT\SOH\DC2\EOT\206\ACK\b\DLE\n\
    \\r\n\
    \\ENQ\EOT\DC3\STX\EOT\ETX\DC2\EOT\206\ACK\DC3\DC4b\ACKproto3"