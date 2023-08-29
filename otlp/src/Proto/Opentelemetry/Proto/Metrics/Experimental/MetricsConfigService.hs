{- This file was auto-generated from opentelemetry/proto/metrics/experimental/metrics_config_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE BangPatterns #-}
{- This file was auto-generated from opentelemetry/proto/metrics/experimental/metrics_config_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE DataKinds #-}
{- This file was auto-generated from opentelemetry/proto/metrics/experimental/metrics_config_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE DerivingStrategies #-}
{- This file was auto-generated from opentelemetry/proto/metrics/experimental/metrics_config_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE FlexibleContexts #-}
{- This file was auto-generated from opentelemetry/proto/metrics/experimental/metrics_config_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE FlexibleInstances #-}
{- This file was auto-generated from opentelemetry/proto/metrics/experimental/metrics_config_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{- This file was auto-generated from opentelemetry/proto/metrics/experimental/metrics_config_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE MagicHash #-}
{- This file was auto-generated from opentelemetry/proto/metrics/experimental/metrics_config_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE MultiParamTypeClasses #-}
{- This file was auto-generated from opentelemetry/proto/metrics/experimental/metrics_config_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE OverloadedStrings #-}
{- This file was auto-generated from opentelemetry/proto/metrics/experimental/metrics_config_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE PatternSynonyms #-}
{- This file was auto-generated from opentelemetry/proto/metrics/experimental/metrics_config_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE ScopedTypeVariables #-}
{- This file was auto-generated from opentelemetry/proto/metrics/experimental/metrics_config_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE TypeApplications #-}
{- This file was auto-generated from opentelemetry/proto/metrics/experimental/metrics_config_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE TypeFamilies #-}
{- This file was auto-generated from opentelemetry/proto/metrics/experimental/metrics_config_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE UndecidableInstances #-}
{- This file was auto-generated from opentelemetry/proto/metrics/experimental/metrics_config_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE NoImplicitPrelude #-}
{-# OPTIONS_GHC -Wno-dodgy-exports #-}
{-# OPTIONS_GHC -Wno-duplicate-exports #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Proto.Opentelemetry.Proto.Metrics.Experimental.MetricsConfigService (
  MetricConfig (..),
  MetricConfigRequest (),
  MetricConfigResponse (),
  MetricConfigResponse'Schedule (),
  MetricConfigResponse'Schedule'Pattern (),
  MetricConfigResponse'Schedule'Pattern'Match (..),
  _MetricConfigResponse'Schedule'Pattern'Equals,
  _MetricConfigResponse'Schedule'Pattern'StartsWith,
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
import qualified Proto.Opentelemetry.Proto.Resource.V1.Resource


{- | Fields :

         * 'Proto.Opentelemetry.Proto.Metrics.Experimental.MetricsConfigService_Fields.resource' @:: Lens' MetricConfigRequest Proto.Opentelemetry.Proto.Resource.V1.Resource.Resource@
         * 'Proto.Opentelemetry.Proto.Metrics.Experimental.MetricsConfigService_Fields.maybe'resource' @:: Lens' MetricConfigRequest (Prelude.Maybe Proto.Opentelemetry.Proto.Resource.V1.Resource.Resource)@
         * 'Proto.Opentelemetry.Proto.Metrics.Experimental.MetricsConfigService_Fields.lastKnownFingerprint' @:: Lens' MetricConfigRequest Data.ByteString.ByteString@
-}
data MetricConfigRequest = MetricConfigRequest'_constructor
  { _MetricConfigRequest'resource :: !(Prelude.Maybe Proto.Opentelemetry.Proto.Resource.V1.Resource.Resource)
  , _MetricConfigRequest'lastKnownFingerprint :: !Data.ByteString.ByteString
  , _MetricConfigRequest'_unknownFields :: !Data.ProtoLens.FieldSet
  }
  deriving stock (Prelude.Eq, Prelude.Ord)


instance Prelude.Show MetricConfigRequest where
  showsPrec _ __x __s =
    Prelude.showChar
      '{'
      ( Prelude.showString
          (Data.ProtoLens.showMessageShort __x)
          (Prelude.showChar '}' __s)
      )


instance Data.ProtoLens.Field.HasField MetricConfigRequest "resource" Proto.Opentelemetry.Proto.Resource.V1.Resource.Resource where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _MetricConfigRequest'resource
          (\x__ y__ -> x__ {_MetricConfigRequest'resource = y__})
      )
      (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)


instance Data.ProtoLens.Field.HasField MetricConfigRequest "maybe'resource" (Prelude.Maybe Proto.Opentelemetry.Proto.Resource.V1.Resource.Resource) where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _MetricConfigRequest'resource
          (\x__ y__ -> x__ {_MetricConfigRequest'resource = y__})
      )
      Prelude.id


instance Data.ProtoLens.Field.HasField MetricConfigRequest "lastKnownFingerprint" Data.ByteString.ByteString where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _MetricConfigRequest'lastKnownFingerprint
          ( \x__ y__ ->
              x__ {_MetricConfigRequest'lastKnownFingerprint = y__}
          )
      )
      Prelude.id


instance Data.ProtoLens.Message MetricConfigRequest where
  messageName _ =
    Data.Text.pack
      "opentelemetry.proto.metrics.experimental.MetricConfigRequest"
  packedMessageDescriptor _ =
    "\n\
    \\DC3MetricConfigRequest\DC2E\n\
    \\bresource\CAN\SOH \SOH(\v2).opentelemetry.proto.resource.v1.ResourceR\bresource\DC24\n\
    \\SYNlast_known_fingerprint\CAN\STX \SOH(\fR\DC4lastKnownFingerprint"
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
            :: Data.ProtoLens.FieldDescriptor MetricConfigRequest
        lastKnownFingerprint__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "last_known_fingerprint"
            ( Data.ProtoLens.ScalarField Data.ProtoLens.BytesField
                :: Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString
            )
            ( Data.ProtoLens.PlainField
                Data.ProtoLens.Optional
                (Data.ProtoLens.Field.field @"lastKnownFingerprint")
            )
            :: Data.ProtoLens.FieldDescriptor MetricConfigRequest
     in Data.Map.fromList
          [ (Data.ProtoLens.Tag 1, resource__field_descriptor)
          , (Data.ProtoLens.Tag 2, lastKnownFingerprint__field_descriptor)
          ]
  unknownFields =
    Lens.Family2.Unchecked.lens
      _MetricConfigRequest'_unknownFields
      (\x__ y__ -> x__ {_MetricConfigRequest'_unknownFields = y__})
  defMessage =
    MetricConfigRequest'_constructor
      { _MetricConfigRequest'resource = Prelude.Nothing
      , _MetricConfigRequest'lastKnownFingerprint = Data.ProtoLens.fieldDefault
      , _MetricConfigRequest'_unknownFields = []
      }
  parseMessage =
    let loop
          :: MetricConfigRequest
          -> Data.ProtoLens.Encoding.Bytes.Parser MetricConfigRequest
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
                              len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                              Data.ProtoLens.Encoding.Bytes.isolate
                                (Prelude.fromIntegral len)
                                Data.ProtoLens.parseMessage
                          )
                          "resource"
                      loop
                        (Lens.Family2.set (Data.ProtoLens.Field.field @"resource") y x)
                  18 ->
                    do
                      y <-
                        (Data.ProtoLens.Encoding.Bytes.<?>)
                          ( do
                              len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                              Data.ProtoLens.Encoding.Bytes.getBytes
                                (Prelude.fromIntegral len)
                          )
                          "last_known_fingerprint"
                      loop
                        ( Lens.Family2.set
                            (Data.ProtoLens.Field.field @"lastKnownFingerprint")
                            y
                            x
                        )
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
          "MetricConfigRequest"
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
            ( let _v =
                    Lens.Family2.view
                      (Data.ProtoLens.Field.field @"lastKnownFingerprint")
                      _x
               in if (Prelude.==) _v Data.ProtoLens.fieldDefault
                    then Data.Monoid.mempty
                    else
                      (Data.Monoid.<>)
                        (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                        ( ( \bs ->
                              (Data.Monoid.<>)
                                ( Data.ProtoLens.Encoding.Bytes.putVarInt
                                    (Prelude.fromIntegral (Data.ByteString.length bs))
                                )
                                (Data.ProtoLens.Encoding.Bytes.putBytes bs)
                          )
                            _v
                        )
            )
            ( Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x)
            )
        )


instance Control.DeepSeq.NFData MetricConfigRequest where
  rnf =
    \x__ ->
      Control.DeepSeq.deepseq
        (_MetricConfigRequest'_unknownFields x__)
        ( Control.DeepSeq.deepseq
            (_MetricConfigRequest'resource x__)
            ( Control.DeepSeq.deepseq
                (_MetricConfigRequest'lastKnownFingerprint x__)
                ()
            )
        )


{- | Fields :

         * 'Proto.Opentelemetry.Proto.Metrics.Experimental.MetricsConfigService_Fields.fingerprint' @:: Lens' MetricConfigResponse Data.ByteString.ByteString@
         * 'Proto.Opentelemetry.Proto.Metrics.Experimental.MetricsConfigService_Fields.schedules' @:: Lens' MetricConfigResponse [MetricConfigResponse'Schedule]@
         * 'Proto.Opentelemetry.Proto.Metrics.Experimental.MetricsConfigService_Fields.vec'schedules' @:: Lens' MetricConfigResponse (Data.Vector.Vector MetricConfigResponse'Schedule)@
         * 'Proto.Opentelemetry.Proto.Metrics.Experimental.MetricsConfigService_Fields.suggestedWaitTimeSec' @:: Lens' MetricConfigResponse Data.Int.Int32@
-}
data MetricConfigResponse = MetricConfigResponse'_constructor
  { _MetricConfigResponse'fingerprint :: !Data.ByteString.ByteString
  , _MetricConfigResponse'schedules :: !(Data.Vector.Vector MetricConfigResponse'Schedule)
  , _MetricConfigResponse'suggestedWaitTimeSec :: !Data.Int.Int32
  , _MetricConfigResponse'_unknownFields :: !Data.ProtoLens.FieldSet
  }
  deriving stock (Prelude.Eq, Prelude.Ord)


instance Prelude.Show MetricConfigResponse where
  showsPrec _ __x __s =
    Prelude.showChar
      '{'
      ( Prelude.showString
          (Data.ProtoLens.showMessageShort __x)
          (Prelude.showChar '}' __s)
      )


instance Data.ProtoLens.Field.HasField MetricConfigResponse "fingerprint" Data.ByteString.ByteString where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _MetricConfigResponse'fingerprint
          (\x__ y__ -> x__ {_MetricConfigResponse'fingerprint = y__})
      )
      Prelude.id


instance Data.ProtoLens.Field.HasField MetricConfigResponse "schedules" [MetricConfigResponse'Schedule] where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _MetricConfigResponse'schedules
          (\x__ y__ -> x__ {_MetricConfigResponse'schedules = y__})
      )
      ( Lens.Family2.Unchecked.lens
          Data.Vector.Generic.toList
          (\_ y__ -> Data.Vector.Generic.fromList y__)
      )


instance Data.ProtoLens.Field.HasField MetricConfigResponse "vec'schedules" (Data.Vector.Vector MetricConfigResponse'Schedule) where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _MetricConfigResponse'schedules
          (\x__ y__ -> x__ {_MetricConfigResponse'schedules = y__})
      )
      Prelude.id


instance Data.ProtoLens.Field.HasField MetricConfigResponse "suggestedWaitTimeSec" Data.Int.Int32 where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _MetricConfigResponse'suggestedWaitTimeSec
          ( \x__ y__ ->
              x__ {_MetricConfigResponse'suggestedWaitTimeSec = y__}
          )
      )
      Prelude.id


instance Data.ProtoLens.Message MetricConfigResponse where
  messageName _ =
    Data.Text.pack
      "opentelemetry.proto.metrics.experimental.MetricConfigResponse"
  packedMessageDescriptor _ =
    "\n\
    \\DC4MetricConfigResponse\DC2 \n\
    \\vfingerprint\CAN\SOH \SOH(\fR\vfingerprint\DC2e\n\
    \\tschedules\CAN\STX \ETX(\v2G.opentelemetry.proto.metrics.experimental.MetricConfigResponse.ScheduleR\tschedules\DC25\n\
    \\ETBsuggested_wait_time_sec\CAN\ETX \SOH(\ENQR\DC4suggestedWaitTimeSec\SUB\250\STX\n\
    \\bSchedule\DC2~\n\
    \\DC2exclusion_patterns\CAN\SOH \ETX(\v2O.opentelemetry.proto.metrics.experimental.MetricConfigResponse.Schedule.PatternR\DC1exclusionPatterns\DC2~\n\
    \\DC2inclusion_patterns\CAN\STX \ETX(\v2O.opentelemetry.proto.metrics.experimental.MetricConfigResponse.Schedule.PatternR\DC1inclusionPatterns\DC2\GS\n\
    \\n\
    \period_sec\CAN\ETX \SOH(\ENQR\tperiodSec\SUBO\n\
    \\aPattern\DC2\CAN\n\
    \\ACKequals\CAN\SOH \SOH(\tH\NULR\ACKequals\DC2!\n\
    \\vstarts_with\CAN\STX \SOH(\tH\NULR\n\
    \startsWithB\a\n\
    \\ENQmatch"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag =
    let fingerprint__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "fingerprint"
            ( Data.ProtoLens.ScalarField Data.ProtoLens.BytesField
                :: Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString
            )
            ( Data.ProtoLens.PlainField
                Data.ProtoLens.Optional
                (Data.ProtoLens.Field.field @"fingerprint")
            )
            :: Data.ProtoLens.FieldDescriptor MetricConfigResponse
        schedules__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "schedules"
            ( Data.ProtoLens.MessageField Data.ProtoLens.MessageType
                :: Data.ProtoLens.FieldTypeDescriptor MetricConfigResponse'Schedule
            )
            ( Data.ProtoLens.RepeatedField
                Data.ProtoLens.Unpacked
                (Data.ProtoLens.Field.field @"schedules")
            )
            :: Data.ProtoLens.FieldDescriptor MetricConfigResponse
        suggestedWaitTimeSec__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "suggested_wait_time_sec"
            ( Data.ProtoLens.ScalarField Data.ProtoLens.Int32Field
                :: Data.ProtoLens.FieldTypeDescriptor Data.Int.Int32
            )
            ( Data.ProtoLens.PlainField
                Data.ProtoLens.Optional
                (Data.ProtoLens.Field.field @"suggestedWaitTimeSec")
            )
            :: Data.ProtoLens.FieldDescriptor MetricConfigResponse
     in Data.Map.fromList
          [ (Data.ProtoLens.Tag 1, fingerprint__field_descriptor)
          , (Data.ProtoLens.Tag 2, schedules__field_descriptor)
          , (Data.ProtoLens.Tag 3, suggestedWaitTimeSec__field_descriptor)
          ]
  unknownFields =
    Lens.Family2.Unchecked.lens
      _MetricConfigResponse'_unknownFields
      (\x__ y__ -> x__ {_MetricConfigResponse'_unknownFields = y__})
  defMessage =
    MetricConfigResponse'_constructor
      { _MetricConfigResponse'fingerprint = Data.ProtoLens.fieldDefault
      , _MetricConfigResponse'schedules = Data.Vector.Generic.empty
      , _MetricConfigResponse'suggestedWaitTimeSec = Data.ProtoLens.fieldDefault
      , _MetricConfigResponse'_unknownFields = []
      }
  parseMessage =
    let loop
          :: MetricConfigResponse
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld MetricConfigResponse'Schedule
          -> Data.ProtoLens.Encoding.Bytes.Parser MetricConfigResponse
        loop x mutable'schedules =
          do
            end <- Data.ProtoLens.Encoding.Bytes.atEnd
            if end
              then do
                frozen'schedules <-
                  Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                    ( Data.ProtoLens.Encoding.Growing.unsafeFreeze
                        mutable'schedules
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
                          (Data.ProtoLens.Field.field @"vec'schedules")
                          frozen'schedules
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
                              Data.ProtoLens.Encoding.Bytes.getBytes
                                (Prelude.fromIntegral len)
                          )
                          "fingerprint"
                      loop
                        (Lens.Family2.set (Data.ProtoLens.Field.field @"fingerprint") y x)
                        mutable'schedules
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
                          "schedules"
                      v <-
                        Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                          (Data.ProtoLens.Encoding.Growing.append mutable'schedules y)
                      loop x v
                  24 ->
                    do
                      y <-
                        (Data.ProtoLens.Encoding.Bytes.<?>)
                          ( Prelude.fmap
                              Prelude.fromIntegral
                              Data.ProtoLens.Encoding.Bytes.getVarInt
                          )
                          "suggested_wait_time_sec"
                      loop
                        ( Lens.Family2.set
                            (Data.ProtoLens.Field.field @"suggestedWaitTimeSec")
                            y
                            x
                        )
                        mutable'schedules
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
                        mutable'schedules
     in (Data.ProtoLens.Encoding.Bytes.<?>)
          ( do
              mutable'schedules <-
                Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                  Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'schedules
          )
          "MetricConfigResponse"
  buildMessage =
    \_x ->
      (Data.Monoid.<>)
        ( let _v =
                Lens.Family2.view (Data.ProtoLens.Field.field @"fingerprint") _x
           in if (Prelude.==) _v Data.ProtoLens.fieldDefault
                then Data.Monoid.mempty
                else
                  (Data.Monoid.<>)
                    (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                    ( ( \bs ->
                          (Data.Monoid.<>)
                            ( Data.ProtoLens.Encoding.Bytes.putVarInt
                                (Prelude.fromIntegral (Data.ByteString.length bs))
                            )
                            (Data.ProtoLens.Encoding.Bytes.putBytes bs)
                      )
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
                    (Data.ProtoLens.Field.field @"vec'schedules")
                    _x
                )
            )
            ( (Data.Monoid.<>)
                ( let _v =
                        Lens.Family2.view
                          (Data.ProtoLens.Field.field @"suggestedWaitTimeSec")
                          _x
                   in if (Prelude.==) _v Data.ProtoLens.fieldDefault
                        then Data.Monoid.mempty
                        else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 24)
                            ( (Prelude..)
                                Data.ProtoLens.Encoding.Bytes.putVarInt
                                Prelude.fromIntegral
                                _v
                            )
                )
                ( Data.ProtoLens.Encoding.Wire.buildFieldSet
                    (Lens.Family2.view Data.ProtoLens.unknownFields _x)
                )
            )
        )


instance Control.DeepSeq.NFData MetricConfigResponse where
  rnf =
    \x__ ->
      Control.DeepSeq.deepseq
        (_MetricConfigResponse'_unknownFields x__)
        ( Control.DeepSeq.deepseq
            (_MetricConfigResponse'fingerprint x__)
            ( Control.DeepSeq.deepseq
                (_MetricConfigResponse'schedules x__)
                ( Control.DeepSeq.deepseq
                    (_MetricConfigResponse'suggestedWaitTimeSec x__)
                    ()
                )
            )
        )


{- | Fields :

         * 'Proto.Opentelemetry.Proto.Metrics.Experimental.MetricsConfigService_Fields.exclusionPatterns' @:: Lens' MetricConfigResponse'Schedule [MetricConfigResponse'Schedule'Pattern]@
         * 'Proto.Opentelemetry.Proto.Metrics.Experimental.MetricsConfigService_Fields.vec'exclusionPatterns' @:: Lens' MetricConfigResponse'Schedule (Data.Vector.Vector MetricConfigResponse'Schedule'Pattern)@
         * 'Proto.Opentelemetry.Proto.Metrics.Experimental.MetricsConfigService_Fields.inclusionPatterns' @:: Lens' MetricConfigResponse'Schedule [MetricConfigResponse'Schedule'Pattern]@
         * 'Proto.Opentelemetry.Proto.Metrics.Experimental.MetricsConfigService_Fields.vec'inclusionPatterns' @:: Lens' MetricConfigResponse'Schedule (Data.Vector.Vector MetricConfigResponse'Schedule'Pattern)@
         * 'Proto.Opentelemetry.Proto.Metrics.Experimental.MetricsConfigService_Fields.periodSec' @:: Lens' MetricConfigResponse'Schedule Data.Int.Int32@
-}
data MetricConfigResponse'Schedule = MetricConfigResponse'Schedule'_constructor
  { _MetricConfigResponse'Schedule'exclusionPatterns :: !(Data.Vector.Vector MetricConfigResponse'Schedule'Pattern)
  , _MetricConfigResponse'Schedule'inclusionPatterns :: !(Data.Vector.Vector MetricConfigResponse'Schedule'Pattern)
  , _MetricConfigResponse'Schedule'periodSec :: !Data.Int.Int32
  , _MetricConfigResponse'Schedule'_unknownFields :: !Data.ProtoLens.FieldSet
  }
  deriving stock (Prelude.Eq, Prelude.Ord)


instance Prelude.Show MetricConfigResponse'Schedule where
  showsPrec _ __x __s =
    Prelude.showChar
      '{'
      ( Prelude.showString
          (Data.ProtoLens.showMessageShort __x)
          (Prelude.showChar '}' __s)
      )


instance Data.ProtoLens.Field.HasField MetricConfigResponse'Schedule "exclusionPatterns" [MetricConfigResponse'Schedule'Pattern] where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _MetricConfigResponse'Schedule'exclusionPatterns
          ( \x__ y__ ->
              x__ {_MetricConfigResponse'Schedule'exclusionPatterns = y__}
          )
      )
      ( Lens.Family2.Unchecked.lens
          Data.Vector.Generic.toList
          (\_ y__ -> Data.Vector.Generic.fromList y__)
      )


instance Data.ProtoLens.Field.HasField MetricConfigResponse'Schedule "vec'exclusionPatterns" (Data.Vector.Vector MetricConfigResponse'Schedule'Pattern) where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _MetricConfigResponse'Schedule'exclusionPatterns
          ( \x__ y__ ->
              x__ {_MetricConfigResponse'Schedule'exclusionPatterns = y__}
          )
      )
      Prelude.id


instance Data.ProtoLens.Field.HasField MetricConfigResponse'Schedule "inclusionPatterns" [MetricConfigResponse'Schedule'Pattern] where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _MetricConfigResponse'Schedule'inclusionPatterns
          ( \x__ y__ ->
              x__ {_MetricConfigResponse'Schedule'inclusionPatterns = y__}
          )
      )
      ( Lens.Family2.Unchecked.lens
          Data.Vector.Generic.toList
          (\_ y__ -> Data.Vector.Generic.fromList y__)
      )


instance Data.ProtoLens.Field.HasField MetricConfigResponse'Schedule "vec'inclusionPatterns" (Data.Vector.Vector MetricConfigResponse'Schedule'Pattern) where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _MetricConfigResponse'Schedule'inclusionPatterns
          ( \x__ y__ ->
              x__ {_MetricConfigResponse'Schedule'inclusionPatterns = y__}
          )
      )
      Prelude.id


instance Data.ProtoLens.Field.HasField MetricConfigResponse'Schedule "periodSec" Data.Int.Int32 where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _MetricConfigResponse'Schedule'periodSec
          ( \x__ y__ ->
              x__ {_MetricConfigResponse'Schedule'periodSec = y__}
          )
      )
      Prelude.id


instance Data.ProtoLens.Message MetricConfigResponse'Schedule where
  messageName _ =
    Data.Text.pack
      "opentelemetry.proto.metrics.experimental.MetricConfigResponse.Schedule"
  packedMessageDescriptor _ =
    "\n\
    \\bSchedule\DC2~\n\
    \\DC2exclusion_patterns\CAN\SOH \ETX(\v2O.opentelemetry.proto.metrics.experimental.MetricConfigResponse.Schedule.PatternR\DC1exclusionPatterns\DC2~\n\
    \\DC2inclusion_patterns\CAN\STX \ETX(\v2O.opentelemetry.proto.metrics.experimental.MetricConfigResponse.Schedule.PatternR\DC1inclusionPatterns\DC2\GS\n\
    \\n\
    \period_sec\CAN\ETX \SOH(\ENQR\tperiodSec\SUBO\n\
    \\aPattern\DC2\CAN\n\
    \\ACKequals\CAN\SOH \SOH(\tH\NULR\ACKequals\DC2!\n\
    \\vstarts_with\CAN\STX \SOH(\tH\NULR\n\
    \startsWithB\a\n\
    \\ENQmatch"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag =
    let exclusionPatterns__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "exclusion_patterns"
            ( Data.ProtoLens.MessageField Data.ProtoLens.MessageType
                :: Data.ProtoLens.FieldTypeDescriptor MetricConfigResponse'Schedule'Pattern
            )
            ( Data.ProtoLens.RepeatedField
                Data.ProtoLens.Unpacked
                (Data.ProtoLens.Field.field @"exclusionPatterns")
            )
            :: Data.ProtoLens.FieldDescriptor MetricConfigResponse'Schedule
        inclusionPatterns__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "inclusion_patterns"
            ( Data.ProtoLens.MessageField Data.ProtoLens.MessageType
                :: Data.ProtoLens.FieldTypeDescriptor MetricConfigResponse'Schedule'Pattern
            )
            ( Data.ProtoLens.RepeatedField
                Data.ProtoLens.Unpacked
                (Data.ProtoLens.Field.field @"inclusionPatterns")
            )
            :: Data.ProtoLens.FieldDescriptor MetricConfigResponse'Schedule
        periodSec__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "period_sec"
            ( Data.ProtoLens.ScalarField Data.ProtoLens.Int32Field
                :: Data.ProtoLens.FieldTypeDescriptor Data.Int.Int32
            )
            ( Data.ProtoLens.PlainField
                Data.ProtoLens.Optional
                (Data.ProtoLens.Field.field @"periodSec")
            )
            :: Data.ProtoLens.FieldDescriptor MetricConfigResponse'Schedule
     in Data.Map.fromList
          [ (Data.ProtoLens.Tag 1, exclusionPatterns__field_descriptor)
          , (Data.ProtoLens.Tag 2, inclusionPatterns__field_descriptor)
          , (Data.ProtoLens.Tag 3, periodSec__field_descriptor)
          ]
  unknownFields =
    Lens.Family2.Unchecked.lens
      _MetricConfigResponse'Schedule'_unknownFields
      ( \x__ y__ ->
          x__ {_MetricConfigResponse'Schedule'_unknownFields = y__}
      )
  defMessage =
    MetricConfigResponse'Schedule'_constructor
      { _MetricConfigResponse'Schedule'exclusionPatterns = Data.Vector.Generic.empty
      , _MetricConfigResponse'Schedule'inclusionPatterns = Data.Vector.Generic.empty
      , _MetricConfigResponse'Schedule'periodSec = Data.ProtoLens.fieldDefault
      , _MetricConfigResponse'Schedule'_unknownFields = []
      }
  parseMessage =
    let loop
          :: MetricConfigResponse'Schedule
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld MetricConfigResponse'Schedule'Pattern
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld MetricConfigResponse'Schedule'Pattern
          -> Data.ProtoLens.Encoding.Bytes.Parser MetricConfigResponse'Schedule
        loop x mutable'exclusionPatterns mutable'inclusionPatterns =
          do
            end <- Data.ProtoLens.Encoding.Bytes.atEnd
            if end
              then do
                frozen'exclusionPatterns <-
                  Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                    ( Data.ProtoLens.Encoding.Growing.unsafeFreeze
                        mutable'exclusionPatterns
                    )
                frozen'inclusionPatterns <-
                  Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                    ( Data.ProtoLens.Encoding.Growing.unsafeFreeze
                        mutable'inclusionPatterns
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
                          (Data.ProtoLens.Field.field @"vec'exclusionPatterns")
                          frozen'exclusionPatterns
                          ( Lens.Family2.set
                              (Data.ProtoLens.Field.field @"vec'inclusionPatterns")
                              frozen'inclusionPatterns
                              x
                          )
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
                          "exclusion_patterns"
                      v <-
                        Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                          ( Data.ProtoLens.Encoding.Growing.append
                              mutable'exclusionPatterns
                              y
                          )
                      loop x v mutable'inclusionPatterns
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
                          "inclusion_patterns"
                      v <-
                        Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                          ( Data.ProtoLens.Encoding.Growing.append
                              mutable'inclusionPatterns
                              y
                          )
                      loop x mutable'exclusionPatterns v
                  24 ->
                    do
                      y <-
                        (Data.ProtoLens.Encoding.Bytes.<?>)
                          ( Prelude.fmap
                              Prelude.fromIntegral
                              Data.ProtoLens.Encoding.Bytes.getVarInt
                          )
                          "period_sec"
                      loop
                        (Lens.Family2.set (Data.ProtoLens.Field.field @"periodSec") y x)
                        mutable'exclusionPatterns
                        mutable'inclusionPatterns
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
                        mutable'exclusionPatterns
                        mutable'inclusionPatterns
     in (Data.ProtoLens.Encoding.Bytes.<?>)
          ( do
              mutable'exclusionPatterns <-
                Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                  Data.ProtoLens.Encoding.Growing.new
              mutable'inclusionPatterns <-
                Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                  Data.ProtoLens.Encoding.Growing.new
              loop
                Data.ProtoLens.defMessage
                mutable'exclusionPatterns
                mutable'inclusionPatterns
          )
          "Schedule"
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
                (Data.ProtoLens.Field.field @"vec'exclusionPatterns")
                _x
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
                    (Data.ProtoLens.Field.field @"vec'inclusionPatterns")
                    _x
                )
            )
            ( (Data.Monoid.<>)
                ( let _v = Lens.Family2.view (Data.ProtoLens.Field.field @"periodSec") _x
                   in if (Prelude.==) _v Data.ProtoLens.fieldDefault
                        then Data.Monoid.mempty
                        else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 24)
                            ( (Prelude..)
                                Data.ProtoLens.Encoding.Bytes.putVarInt
                                Prelude.fromIntegral
                                _v
                            )
                )
                ( Data.ProtoLens.Encoding.Wire.buildFieldSet
                    (Lens.Family2.view Data.ProtoLens.unknownFields _x)
                )
            )
        )


instance Control.DeepSeq.NFData MetricConfigResponse'Schedule where
  rnf =
    \x__ ->
      Control.DeepSeq.deepseq
        (_MetricConfigResponse'Schedule'_unknownFields x__)
        ( Control.DeepSeq.deepseq
            (_MetricConfigResponse'Schedule'exclusionPatterns x__)
            ( Control.DeepSeq.deepseq
                (_MetricConfigResponse'Schedule'inclusionPatterns x__)
                ( Control.DeepSeq.deepseq
                    (_MetricConfigResponse'Schedule'periodSec x__)
                    ()
                )
            )
        )


{- | Fields :

         * 'Proto.Opentelemetry.Proto.Metrics.Experimental.MetricsConfigService_Fields.maybe'match' @:: Lens' MetricConfigResponse'Schedule'Pattern (Prelude.Maybe MetricConfigResponse'Schedule'Pattern'Match)@
         * 'Proto.Opentelemetry.Proto.Metrics.Experimental.MetricsConfigService_Fields.maybe'equals' @:: Lens' MetricConfigResponse'Schedule'Pattern (Prelude.Maybe Data.Text.Text)@
         * 'Proto.Opentelemetry.Proto.Metrics.Experimental.MetricsConfigService_Fields.equals' @:: Lens' MetricConfigResponse'Schedule'Pattern Data.Text.Text@
         * 'Proto.Opentelemetry.Proto.Metrics.Experimental.MetricsConfigService_Fields.maybe'startsWith' @:: Lens' MetricConfigResponse'Schedule'Pattern (Prelude.Maybe Data.Text.Text)@
         * 'Proto.Opentelemetry.Proto.Metrics.Experimental.MetricsConfigService_Fields.startsWith' @:: Lens' MetricConfigResponse'Schedule'Pattern Data.Text.Text@
-}
data MetricConfigResponse'Schedule'Pattern = MetricConfigResponse'Schedule'Pattern'_constructor
  { _MetricConfigResponse'Schedule'Pattern'match :: !(Prelude.Maybe MetricConfigResponse'Schedule'Pattern'Match)
  , _MetricConfigResponse'Schedule'Pattern'_unknownFields :: !Data.ProtoLens.FieldSet
  }
  deriving stock (Prelude.Eq, Prelude.Ord)


instance Prelude.Show MetricConfigResponse'Schedule'Pattern where
  showsPrec _ __x __s =
    Prelude.showChar
      '{'
      ( Prelude.showString
          (Data.ProtoLens.showMessageShort __x)
          (Prelude.showChar '}' __s)
      )


data MetricConfigResponse'Schedule'Pattern'Match
  = MetricConfigResponse'Schedule'Pattern'Equals !Data.Text.Text
  | MetricConfigResponse'Schedule'Pattern'StartsWith !Data.Text.Text
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)


instance Data.ProtoLens.Field.HasField MetricConfigResponse'Schedule'Pattern "maybe'match" (Prelude.Maybe MetricConfigResponse'Schedule'Pattern'Match) where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _MetricConfigResponse'Schedule'Pattern'match
          ( \x__ y__ ->
              x__ {_MetricConfigResponse'Schedule'Pattern'match = y__}
          )
      )
      Prelude.id


instance Data.ProtoLens.Field.HasField MetricConfigResponse'Schedule'Pattern "maybe'equals" (Prelude.Maybe Data.Text.Text) where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _MetricConfigResponse'Schedule'Pattern'match
          ( \x__ y__ ->
              x__ {_MetricConfigResponse'Schedule'Pattern'match = y__}
          )
      )
      ( Lens.Family2.Unchecked.lens
          ( \x__ ->
              case x__ of
                (Prelude.Just (MetricConfigResponse'Schedule'Pattern'Equals x__val)) ->
                  Prelude.Just x__val
                _otherwise -> Prelude.Nothing
          )
          ( \_ y__ ->
              Prelude.fmap MetricConfigResponse'Schedule'Pattern'Equals y__
          )
      )


instance Data.ProtoLens.Field.HasField MetricConfigResponse'Schedule'Pattern "equals" Data.Text.Text where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _MetricConfigResponse'Schedule'Pattern'match
          ( \x__ y__ ->
              x__ {_MetricConfigResponse'Schedule'Pattern'match = y__}
          )
      )
      ( (Prelude..)
          ( Lens.Family2.Unchecked.lens
              ( \x__ ->
                  case x__ of
                    (Prelude.Just (MetricConfigResponse'Schedule'Pattern'Equals x__val)) ->
                      Prelude.Just x__val
                    _otherwise -> Prelude.Nothing
              )
              ( \_ y__ ->
                  Prelude.fmap MetricConfigResponse'Schedule'Pattern'Equals y__
              )
          )
          (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault)
      )


instance Data.ProtoLens.Field.HasField MetricConfigResponse'Schedule'Pattern "maybe'startsWith" (Prelude.Maybe Data.Text.Text) where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _MetricConfigResponse'Schedule'Pattern'match
          ( \x__ y__ ->
              x__ {_MetricConfigResponse'Schedule'Pattern'match = y__}
          )
      )
      ( Lens.Family2.Unchecked.lens
          ( \x__ ->
              case x__ of
                (Prelude.Just (MetricConfigResponse'Schedule'Pattern'StartsWith x__val)) ->
                  Prelude.Just x__val
                _otherwise -> Prelude.Nothing
          )
          ( \_ y__ ->
              Prelude.fmap
                MetricConfigResponse'Schedule'Pattern'StartsWith
                y__
          )
      )


instance Data.ProtoLens.Field.HasField MetricConfigResponse'Schedule'Pattern "startsWith" Data.Text.Text where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _MetricConfigResponse'Schedule'Pattern'match
          ( \x__ y__ ->
              x__ {_MetricConfigResponse'Schedule'Pattern'match = y__}
          )
      )
      ( (Prelude..)
          ( Lens.Family2.Unchecked.lens
              ( \x__ ->
                  case x__ of
                    (Prelude.Just (MetricConfigResponse'Schedule'Pattern'StartsWith x__val)) ->
                      Prelude.Just x__val
                    _otherwise -> Prelude.Nothing
              )
              ( \_ y__ ->
                  Prelude.fmap
                    MetricConfigResponse'Schedule'Pattern'StartsWith
                    y__
              )
          )
          (Data.ProtoLens.maybeLens Data.ProtoLens.fieldDefault)
      )


instance Data.ProtoLens.Message MetricConfigResponse'Schedule'Pattern where
  messageName _ =
    Data.Text.pack
      "opentelemetry.proto.metrics.experimental.MetricConfigResponse.Schedule.Pattern"
  packedMessageDescriptor _ =
    "\n\
    \\aPattern\DC2\CAN\n\
    \\ACKequals\CAN\SOH \SOH(\tH\NULR\ACKequals\DC2!\n\
    \\vstarts_with\CAN\STX \SOH(\tH\NULR\n\
    \startsWithB\a\n\
    \\ENQmatch"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag =
    let equals__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "equals"
            ( Data.ProtoLens.ScalarField Data.ProtoLens.StringField
                :: Data.ProtoLens.FieldTypeDescriptor Data.Text.Text
            )
            ( Data.ProtoLens.OptionalField
                (Data.ProtoLens.Field.field @"maybe'equals")
            )
            :: Data.ProtoLens.FieldDescriptor MetricConfigResponse'Schedule'Pattern
        startsWith__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "starts_with"
            ( Data.ProtoLens.ScalarField Data.ProtoLens.StringField
                :: Data.ProtoLens.FieldTypeDescriptor Data.Text.Text
            )
            ( Data.ProtoLens.OptionalField
                (Data.ProtoLens.Field.field @"maybe'startsWith")
            )
            :: Data.ProtoLens.FieldDescriptor MetricConfigResponse'Schedule'Pattern
     in Data.Map.fromList
          [ (Data.ProtoLens.Tag 1, equals__field_descriptor)
          , (Data.ProtoLens.Tag 2, startsWith__field_descriptor)
          ]
  unknownFields =
    Lens.Family2.Unchecked.lens
      _MetricConfigResponse'Schedule'Pattern'_unknownFields
      ( \x__ y__ ->
          x__
            { _MetricConfigResponse'Schedule'Pattern'_unknownFields = y__
            }
      )
  defMessage =
    MetricConfigResponse'Schedule'Pattern'_constructor
      { _MetricConfigResponse'Schedule'Pattern'match = Prelude.Nothing
      , _MetricConfigResponse'Schedule'Pattern'_unknownFields = []
      }
  parseMessage =
    let loop
          :: MetricConfigResponse'Schedule'Pattern
          -> Data.ProtoLens.Encoding.Bytes.Parser MetricConfigResponse'Schedule'Pattern
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
                          "equals"
                      loop (Lens.Family2.set (Data.ProtoLens.Field.field @"equals") y x)
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
                          "starts_with"
                      loop
                        (Lens.Family2.set (Data.ProtoLens.Field.field @"startsWith") y x)
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
          "Pattern"
  buildMessage =
    \_x ->
      (Data.Monoid.<>)
        ( case Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'match") _x of
            Prelude.Nothing -> Data.Monoid.mempty
            (Prelude.Just (MetricConfigResponse'Schedule'Pattern'Equals v)) ->
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
            (Prelude.Just (MetricConfigResponse'Schedule'Pattern'StartsWith v)) ->
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
                    v
                )
        )
        ( Data.ProtoLens.Encoding.Wire.buildFieldSet
            (Lens.Family2.view Data.ProtoLens.unknownFields _x)
        )


instance Control.DeepSeq.NFData MetricConfigResponse'Schedule'Pattern where
  rnf =
    \x__ ->
      Control.DeepSeq.deepseq
        (_MetricConfigResponse'Schedule'Pattern'_unknownFields x__)
        ( Control.DeepSeq.deepseq
            (_MetricConfigResponse'Schedule'Pattern'match x__)
            ()
        )


instance Control.DeepSeq.NFData MetricConfigResponse'Schedule'Pattern'Match where
  rnf (MetricConfigResponse'Schedule'Pattern'Equals x__) =
    Control.DeepSeq.rnf x__
  rnf (MetricConfigResponse'Schedule'Pattern'StartsWith x__) =
    Control.DeepSeq.rnf x__


_MetricConfigResponse'Schedule'Pattern'Equals
  :: Data.ProtoLens.Prism.Prism' MetricConfigResponse'Schedule'Pattern'Match Data.Text.Text
_MetricConfigResponse'Schedule'Pattern'Equals =
  Data.ProtoLens.Prism.prism'
    MetricConfigResponse'Schedule'Pattern'Equals
    ( \p__ ->
        case p__ of
          (MetricConfigResponse'Schedule'Pattern'Equals p__val) ->
            Prelude.Just p__val
          _otherwise -> Prelude.Nothing
    )


_MetricConfigResponse'Schedule'Pattern'StartsWith
  :: Data.ProtoLens.Prism.Prism' MetricConfigResponse'Schedule'Pattern'Match Data.Text.Text
_MetricConfigResponse'Schedule'Pattern'StartsWith =
  Data.ProtoLens.Prism.prism'
    MetricConfigResponse'Schedule'Pattern'StartsWith
    ( \p__ ->
        case p__ of
          (MetricConfigResponse'Schedule'Pattern'StartsWith p__val) ->
            Prelude.Just p__val
          _otherwise -> Prelude.Nothing
    )


data MetricConfig = MetricConfig {}


instance Data.ProtoLens.Service.Types.Service MetricConfig where
  type ServiceName MetricConfig = "MetricConfig"
  type ServicePackage MetricConfig = "opentelemetry.proto.metrics.experimental"
  type ServiceMethods MetricConfig = '["getMetricConfig"]
  packedServiceDescriptor _ =
    "\n\
    \\fMetricConfig\DC2\144\SOH\n\
    \\SIGetMetricConfig\DC2=.opentelemetry.proto.metrics.experimental.MetricConfigRequest\SUB>.opentelemetry.proto.metrics.experimental.MetricConfigResponse"


instance Data.ProtoLens.Service.Types.HasMethodImpl MetricConfig "getMetricConfig" where
  type MethodName MetricConfig "getMetricConfig" = "GetMetricConfig"
  type MethodInput MetricConfig "getMetricConfig" = MetricConfigRequest
  type MethodOutput MetricConfig "getMetricConfig" = MetricConfigResponse
  type MethodStreamingType MetricConfig "getMetricConfig" = 'Data.ProtoLens.Service.Types.NonStreaming


packedFileDescriptor :: Data.ByteString.ByteString
packedFileDescriptor =
  "\n\
  \Eopentelemetry/proto/metrics/experimental/metrics_config_service.proto\DC2(opentelemetry.proto.metrics.experimental\SUB.opentelemetry/proto/resource/v1/resource.proto\"\146\SOH\n\
  \\DC3MetricConfigRequest\DC2E\n\
  \\bresource\CAN\SOH \SOH(\v2).opentelemetry.proto.resource.v1.ResourceR\bresource\DC24\n\
  \\SYNlast_known_fingerprint\CAN\STX \SOH(\fR\DC4lastKnownFingerprint\"\211\EOT\n\
  \\DC4MetricConfigResponse\DC2 \n\
  \\vfingerprint\CAN\SOH \SOH(\fR\vfingerprint\DC2e\n\
  \\tschedules\CAN\STX \ETX(\v2G.opentelemetry.proto.metrics.experimental.MetricConfigResponse.ScheduleR\tschedules\DC25\n\
  \\ETBsuggested_wait_time_sec\CAN\ETX \SOH(\ENQR\DC4suggestedWaitTimeSec\SUB\250\STX\n\
  \\bSchedule\DC2~\n\
  \\DC2exclusion_patterns\CAN\SOH \ETX(\v2O.opentelemetry.proto.metrics.experimental.MetricConfigResponse.Schedule.PatternR\DC1exclusionPatterns\DC2~\n\
  \\DC2inclusion_patterns\CAN\STX \ETX(\v2O.opentelemetry.proto.metrics.experimental.MetricConfigResponse.Schedule.PatternR\DC1inclusionPatterns\DC2\GS\n\
  \\n\
  \period_sec\CAN\ETX \SOH(\ENQR\tperiodSec\SUBO\n\
  \\aPattern\DC2\CAN\n\
  \\ACKequals\CAN\SOH \SOH(\tH\NULR\ACKequals\DC2!\n\
  \\vstarts_with\CAN\STX \SOH(\tH\NULR\n\
  \startsWithB\a\n\
  \\ENQmatch2\161\SOH\n\
  \\fMetricConfig\DC2\144\SOH\n\
  \\SIGetMetricConfig\DC2=.opentelemetry.proto.metrics.experimental.MetricConfigRequest\SUB>.opentelemetry.proto.metrics.experimental.MetricConfigResponseB\148\SOH\n\
  \+io.opentelemetry.proto.metrics.experimentalB\CANMetricConfigServiceProtoP\SOHZIgithub.com/open-telemetry/opentelemetry-proto/gen/go/metrics/experimentalJ\182!\n\
  \\ACK\DC2\EOT\SO\NULe\SOH\n\
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
  \\SOH\STX\DC2\ETX\DLE\NUL1\n\
  \\t\n\
  \\STX\ETX\NUL\DC2\ETX\DC2\NUL8\n\
  \\b\n\
  \\SOH\b\DC2\ETX\DC4\NUL\"\n\
  \\t\n\
  \\STX\b\n\
  \\DC2\ETX\DC4\NUL\"\n\
  \\b\n\
  \\SOH\b\DC2\ETX\NAK\NULD\n\
  \\t\n\
  \\STX\b\SOH\DC2\ETX\NAK\NULD\n\
  \\b\n\
  \\SOH\b\DC2\ETX\SYN\NUL9\n\
  \\t\n\
  \\STX\b\b\DC2\ETX\SYN\NUL9\n\
  \\b\n\
  \\SOH\b\DC2\ETX\ETB\NUL`\n\
  \\t\n\
  \\STX\b\v\DC2\ETX\ETB\NUL`\n\
  \\154\ETX\n\
  \\STX\ACK\NUL\DC2\EOT\US\NUL!\SOH\SUB\141\ETX MetricConfig is a service that enables updating metric schedules, trace\n\
  \ parameters, and other configurations on the SDK without having to restart the\n\
  \ instrumented application. The collector can also serve as the configuration\n\
  \ service, acting as a bridge between third-party configuration services and\n\
  \ the SDK, piping updated configs from a third-party source to an instrumented\n\
  \ application.\n\
  \\n\
  \\n\
  \\n\
  \\ETX\ACK\NUL\SOH\DC2\ETX\US\b\DC4\n\
  \\v\n\
  \\EOT\ACK\NUL\STX\NUL\DC2\ETX \STXK\n\
  \\f\n\
  \\ENQ\ACK\NUL\STX\NUL\SOH\DC2\ETX \ACK\NAK\n\
  \\f\n\
  \\ENQ\ACK\NUL\STX\NUL\STX\DC2\ETX \ETB*\n\
  \\f\n\
  \\ENQ\ACK\NUL\STX\NUL\ETX\DC2\ETX 5I\n\
  \\n\
  \\n\
  \\STX\EOT\NUL\DC2\EOT#\NUL+\SOH\n\
  \\n\
  \\n\
  \\ETX\EOT\NUL\SOH\DC2\ETX#\b\ESC\n\
  \Q\n\
  \\EOT\EOT\NUL\STX\NUL\DC2\ETX&\STX8\SUBD Required. The resource for which configuration should be returned.\n\
  \\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\NUL\ACK\DC2\ETX&\STX*\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\NUL\SOH\DC2\ETX&+3\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\NUL\ETX\DC2\ETX&67\n\
  \\150\SOH\n\
  \\EOT\EOT\NUL\STX\SOH\DC2\ETX*\STX#\SUB\136\SOH Optional. The value of MetricConfigResponse.fingerprint for the last\n\
  \ configuration that the caller received and successfully applied.\n\
  \\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\SOH\ENQ\DC2\ETX*\STX\a\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\SOH\SOH\DC2\ETX*\b\RS\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\SOH\ETX\DC2\ETX*!\"\n\
  \\n\
  \\n\
  \\STX\EOT\SOH\DC2\EOT-\NULe\SOH\n\
  \\n\
  \\n\
  \\ETX\EOT\SOH\SOH\DC2\ETX-\b\FS\n\
  \\171\ACK\n\
  \\EOT\EOT\SOH\STX\NUL\DC2\ETX<\STX\CAN\SUB\157\ACK Optional. The fingerprint associated with this MetricConfigResponse. Each\n\
  \ change in configs yields a different fingerprint. The resource SHOULD copy\n\
  \ this value to MetricConfigRequest.last_known_fingerprint for the next\n\
  \ configuration request. If there are no changes between fingerprint and\n\
  \ MetricConfigRequest.last_known_fingerprint, then all other fields besides\n\
  \ fingerprint in the response are optional, or the same as the last update if\n\
  \ present.\n\
  \\n\
  \ The exact mechanics of generating the fingerprint is up to the\n\
  \ implementation. However, a fingerprint must be deterministically determined\n\
  \ by the configurations -- the same configuration will generate the same\n\
  \ fingerprint on any instance of an implementation. Hence using a timestamp is\n\
  \ unacceptable, but a deterministic hash is fine.\n\
  \\n\
  \\f\n\
  \\ENQ\EOT\SOH\STX\NUL\ENQ\DC2\ETX<\STX\a\n\
  \\f\n\
  \\ENQ\EOT\SOH\STX\NUL\SOH\DC2\ETX<\b\DC3\n\
  \\f\n\
  \\ENQ\EOT\SOH\STX\NUL\ETX\DC2\ETX<\SYN\ETB\n\
  \\213\SOH\n\
  \\EOT\EOT\SOH\ETX\NUL\DC2\EOTA\STXW\ETX\SUB\198\SOH A Schedule is used to apply a particular scheduling configuration to\n\
  \ a metric. If a metric name matches a schedule's patterns, then the metric\n\
  \ adopts the configuration specified by the schedule.\n\
  \\n\
  \\f\n\
  \\ENQ\EOT\SOH\ETX\NUL\SOH\DC2\ETXA\n\
  \\DC2\n\
  \\201\SOH\n\
  \\ACK\EOT\SOH\ETX\NUL\ETX\NUL\DC2\EOTF\EOTK\ENQ\SUB\184\SOH A light-weight pattern that can match 1 or more\n\
  \ metrics, for which this schedule will apply. The string is used to\n\
  \ match against metric names. It should not exceed 100k characters.\n\
  \\n\
  \\SO\n\
  \\a\EOT\SOH\ETX\NUL\ETX\NUL\SOH\DC2\ETXF\f\DC3\n\
  \\DLE\n\
  \\b\EOT\SOH\ETX\NUL\ETX\NUL\b\NUL\DC2\EOTG\ACKJ\a\n\
  \\DLE\n\
  \\t\EOT\SOH\ETX\NUL\ETX\NUL\b\NUL\SOH\DC2\ETXG\f\DC1\n\
  \2\n\
  \\b\EOT\SOH\ETX\NUL\ETX\NUL\STX\NUL\DC2\ETXH\b\SUB\"! matches the metric name exactly\n\
  \\n\
  \\DLE\n\
  \\t\EOT\SOH\ETX\NUL\ETX\NUL\STX\NUL\ENQ\DC2\ETXH\b\SO\n\
  \\DLE\n\
  \\t\EOT\SOH\ETX\NUL\ETX\NUL\STX\NUL\SOH\DC2\ETXH\SI\NAK\n\
  \\DLE\n\
  \\t\EOT\SOH\ETX\NUL\ETX\NUL\STX\NUL\ETX\DC2\ETXH\CAN\EM\n\
  \1\n\
  \\b\EOT\SOH\ETX\NUL\ETX\NUL\STX\SOH\DC2\ETXI\b\US\"  prefix-matches the metric name\n\
  \\n\
  \\DLE\n\
  \\t\EOT\SOH\ETX\NUL\ETX\NUL\STX\SOH\ENQ\DC2\ETXI\b\SO\n\
  \\DLE\n\
  \\t\EOT\SOH\ETX\NUL\ETX\NUL\STX\SOH\SOH\DC2\ETXI\SI\SUB\n\
  \\DLE\n\
  \\t\EOT\SOH\ETX\NUL\ETX\NUL\STX\SOH\ETX\DC2\ETXI\GS\RS\n\
  \\233\SOH\n\
  \\ACK\EOT\SOH\ETX\NUL\STX\NUL\DC2\ETXQ\EOT,\SUB\217\SOH Metrics with names that match a rule in the inclusion_patterns are\n\
  \ targeted by this schedule. Metrics that match the exclusion_patterns\n\
  \ are not targeted for this schedule, even if they match an inclusion\n\
  \ pattern.\n\
  \\n\
  \\SO\n\
  \\a\EOT\SOH\ETX\NUL\STX\NUL\EOT\DC2\ETXQ\EOT\f\n\
  \\SO\n\
  \\a\EOT\SOH\ETX\NUL\STX\NUL\ACK\DC2\ETXQ\r\DC4\n\
  \\SO\n\
  \\a\EOT\SOH\ETX\NUL\STX\NUL\SOH\DC2\ETXQ\NAK'\n\
  \\SO\n\
  \\a\EOT\SOH\ETX\NUL\STX\NUL\ETX\DC2\ETXQ*+\n\
  \\r\n\
  \\ACK\EOT\SOH\ETX\NUL\STX\SOH\DC2\ETXR\EOT,\n\
  \\SO\n\
  \\a\EOT\SOH\ETX\NUL\STX\SOH\EOT\DC2\ETXR\EOT\f\n\
  \\SO\n\
  \\a\EOT\SOH\ETX\NUL\STX\SOH\ACK\DC2\ETXR\r\DC4\n\
  \\SO\n\
  \\a\EOT\SOH\ETX\NUL\STX\SOH\SOH\DC2\ETXR\NAK'\n\
  \\SO\n\
  \\a\EOT\SOH\ETX\NUL\STX\SOH\ETX\DC2\ETXR*+\n\
  \p\n\
  \\ACK\EOT\SOH\ETX\NUL\STX\STX\DC2\ETXV\EOT\EM\SUBa Describes the collection period for each metric in seconds.\n\
  \ A period of 0 means to not export.\n\
  \\n\
  \\SO\n\
  \\a\EOT\SOH\ETX\NUL\STX\STX\ENQ\DC2\ETXV\EOT\t\n\
  \\SO\n\
  \\a\EOT\SOH\ETX\NUL\STX\STX\SOH\DC2\ETXV\n\
  \\DC4\n\
  \\SO\n\
  \\a\EOT\SOH\ETX\NUL\STX\STX\ETX\DC2\ETXV\ETB\CAN\n\
  \\148\ETX\n\
  \\EOT\EOT\SOH\STX\SOH\DC2\ETX`\STX\"\SUB\134\ETX A single metric may match multiple schedules. In such cases, the schedule\n\
  \ that specifies the smallest period is applied.\n\
  \\n\
  \ Note, for optimization purposes, it is recommended to use as few schedules\n\
  \ as possible to capture all required metric updates. Where you can be\n\
  \ conservative, do take full advantage of the inclusion/exclusion patterns to\n\
  \ capture as much of your targeted metrics.\n\
  \\n\
  \\f\n\
  \\ENQ\EOT\SOH\STX\SOH\EOT\DC2\ETX`\STX\n\
  \\n\
  \\f\n\
  \\ENQ\EOT\SOH\STX\SOH\ACK\DC2\ETX`\v\DC3\n\
  \\f\n\
  \\ENQ\EOT\SOH\STX\SOH\SOH\DC2\ETX`\DC4\GS\n\
  \\f\n\
  \\ENQ\EOT\SOH\STX\SOH\ETX\DC2\ETX` !\n\
  \\128\SOH\n\
  \\EOT\EOT\SOH\STX\STX\DC2\ETXd\STX$\SUBs Optional. The client is suggested to wait this long (in seconds) before\n\
  \ pinging the configuration service again.\n\
  \\n\
  \\f\n\
  \\ENQ\EOT\SOH\STX\STX\ENQ\DC2\ETXd\STX\a\n\
  \\f\n\
  \\ENQ\EOT\SOH\STX\STX\SOH\DC2\ETXd\b\US\n\
  \\f\n\
  \\ENQ\EOT\SOH\STX\STX\ETX\DC2\ETXd\"#b\ACKproto3"
