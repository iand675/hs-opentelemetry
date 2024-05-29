{- This file was auto-generated from opentelemetry/proto/trace/v1/trace_config.proto by the proto-lens-protoc program. -}
{-# LANGUAGE ScopedTypeVariables, DataKinds, TypeFamilies, UndecidableInstances, GeneralizedNewtypeDeriving, MultiParamTypeClasses, FlexibleContexts, FlexibleInstances, PatternSynonyms, MagicHash, NoImplicitPrelude, DataKinds, BangPatterns, TypeApplications, OverloadedStrings, DerivingStrategies#-}
{-# OPTIONS_GHC -Wno-unused-imports#-}
{-# OPTIONS_GHC -Wno-duplicate-exports#-}
{-# OPTIONS_GHC -Wno-dodgy-exports#-}
module Proto.Opentelemetry.Proto.Trace.V1.TraceConfig (
        ConstantSampler(), ConstantSampler'ConstantDecision(..),
        ConstantSampler'ConstantDecision(),
        ConstantSampler'ConstantDecision'UnrecognizedValue,
        RateLimitingSampler(), TraceConfig(), TraceConfig'Sampler(..),
        _TraceConfig'ConstantSampler, _TraceConfig'TraceIdRatioBased,
        _TraceConfig'RateLimitingSampler, TraceIdRatioBased()
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
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Trace.V1.TraceConfig_Fields.decision' @:: Lens' ConstantSampler ConstantSampler'ConstantDecision@ -}
data ConstantSampler
  = ConstantSampler'_constructor {_ConstantSampler'decision :: !ConstantSampler'ConstantDecision,
                                  _ConstantSampler'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show ConstantSampler where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField ConstantSampler "decision" ConstantSampler'ConstantDecision where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _ConstantSampler'decision
           (\ x__ y__ -> x__ {_ConstantSampler'decision = y__}))
        Prelude.id
instance Data.ProtoLens.Message ConstantSampler where
  messageName _
    = Data.Text.pack "opentelemetry.proto.trace.v1.ConstantSampler"
  packedMessageDescriptor _
    = "\n\
      \\SIConstantSampler\DC2Z\n\
      \\bdecision\CAN\SOH \SOH(\SO2>.opentelemetry.proto.trace.v1.ConstantSampler.ConstantDecisionR\bdecision\"D\n\
      \\DLEConstantDecision\DC2\SO\n\
      \\n\
      \ALWAYS_OFF\DLE\NUL\DC2\r\n\
      \\tALWAYS_ON\DLE\SOH\DC2\DC1\n\
      \\rALWAYS_PARENT\DLE\STX"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        decision__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "decision"
              (Data.ProtoLens.ScalarField Data.ProtoLens.EnumField ::
                 Data.ProtoLens.FieldTypeDescriptor ConstantSampler'ConstantDecision)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"decision")) ::
              Data.ProtoLens.FieldDescriptor ConstantSampler
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, decision__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _ConstantSampler'_unknownFields
        (\ x__ y__ -> x__ {_ConstantSampler'_unknownFields = y__})
  defMessage
    = ConstantSampler'_constructor
        {_ConstantSampler'decision = Data.ProtoLens.fieldDefault,
         _ConstantSampler'_unknownFields = []}
  parseMessage
    = let
        loop ::
          ConstantSampler
          -> Data.ProtoLens.Encoding.Bytes.Parser ConstantSampler
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
                                       "decision"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"decision") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "ConstantSampler"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v = Lens.Family2.view (Data.ProtoLens.Field.field @"decision") _x
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
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData ConstantSampler where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_ConstantSampler'_unknownFields x__)
             (Control.DeepSeq.deepseq (_ConstantSampler'decision x__) ())
newtype ConstantSampler'ConstantDecision'UnrecognizedValue
  = ConstantSampler'ConstantDecision'UnrecognizedValue Data.Int.Int32
  deriving stock (Prelude.Eq, Prelude.Ord, Prelude.Show)
data ConstantSampler'ConstantDecision
  = ConstantSampler'ALWAYS_OFF |
    ConstantSampler'ALWAYS_ON |
    ConstantSampler'ALWAYS_PARENT |
    ConstantSampler'ConstantDecision'Unrecognized !ConstantSampler'ConstantDecision'UnrecognizedValue
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
instance Data.ProtoLens.MessageEnum ConstantSampler'ConstantDecision where
  maybeToEnum 0 = Prelude.Just ConstantSampler'ALWAYS_OFF
  maybeToEnum 1 = Prelude.Just ConstantSampler'ALWAYS_ON
  maybeToEnum 2 = Prelude.Just ConstantSampler'ALWAYS_PARENT
  maybeToEnum k
    = Prelude.Just
        (ConstantSampler'ConstantDecision'Unrecognized
           (ConstantSampler'ConstantDecision'UnrecognizedValue
              (Prelude.fromIntegral k)))
  showEnum ConstantSampler'ALWAYS_OFF = "ALWAYS_OFF"
  showEnum ConstantSampler'ALWAYS_ON = "ALWAYS_ON"
  showEnum ConstantSampler'ALWAYS_PARENT = "ALWAYS_PARENT"
  showEnum
    (ConstantSampler'ConstantDecision'Unrecognized (ConstantSampler'ConstantDecision'UnrecognizedValue k))
    = Prelude.show k
  readEnum k
    | (Prelude.==) k "ALWAYS_OFF"
    = Prelude.Just ConstantSampler'ALWAYS_OFF
    | (Prelude.==) k "ALWAYS_ON"
    = Prelude.Just ConstantSampler'ALWAYS_ON
    | (Prelude.==) k "ALWAYS_PARENT"
    = Prelude.Just ConstantSampler'ALWAYS_PARENT
    | Prelude.otherwise
    = (Prelude.>>=) (Text.Read.readMaybe k) Data.ProtoLens.maybeToEnum
instance Prelude.Bounded ConstantSampler'ConstantDecision where
  minBound = ConstantSampler'ALWAYS_OFF
  maxBound = ConstantSampler'ALWAYS_PARENT
instance Prelude.Enum ConstantSampler'ConstantDecision where
  toEnum k__
    = Prelude.maybe
        (Prelude.error
           ((Prelude.++)
              "toEnum: unknown value for enum ConstantDecision: "
              (Prelude.show k__)))
        Prelude.id (Data.ProtoLens.maybeToEnum k__)
  fromEnum ConstantSampler'ALWAYS_OFF = 0
  fromEnum ConstantSampler'ALWAYS_ON = 1
  fromEnum ConstantSampler'ALWAYS_PARENT = 2
  fromEnum
    (ConstantSampler'ConstantDecision'Unrecognized (ConstantSampler'ConstantDecision'UnrecognizedValue k))
    = Prelude.fromIntegral k
  succ ConstantSampler'ALWAYS_PARENT
    = Prelude.error
        "ConstantSampler'ConstantDecision.succ: bad argument ConstantSampler'ALWAYS_PARENT. This value would be out of bounds."
  succ ConstantSampler'ALWAYS_OFF = ConstantSampler'ALWAYS_ON
  succ ConstantSampler'ALWAYS_ON = ConstantSampler'ALWAYS_PARENT
  succ (ConstantSampler'ConstantDecision'Unrecognized _)
    = Prelude.error
        "ConstantSampler'ConstantDecision.succ: bad argument: unrecognized value"
  pred ConstantSampler'ALWAYS_OFF
    = Prelude.error
        "ConstantSampler'ConstantDecision.pred: bad argument ConstantSampler'ALWAYS_OFF. This value would be out of bounds."
  pred ConstantSampler'ALWAYS_ON = ConstantSampler'ALWAYS_OFF
  pred ConstantSampler'ALWAYS_PARENT = ConstantSampler'ALWAYS_ON
  pred (ConstantSampler'ConstantDecision'Unrecognized _)
    = Prelude.error
        "ConstantSampler'ConstantDecision.pred: bad argument: unrecognized value"
  enumFrom = Data.ProtoLens.Message.Enum.messageEnumFrom
  enumFromTo = Data.ProtoLens.Message.Enum.messageEnumFromTo
  enumFromThen = Data.ProtoLens.Message.Enum.messageEnumFromThen
  enumFromThenTo = Data.ProtoLens.Message.Enum.messageEnumFromThenTo
instance Data.ProtoLens.FieldDefault ConstantSampler'ConstantDecision where
  fieldDefault = ConstantSampler'ALWAYS_OFF
instance Control.DeepSeq.NFData ConstantSampler'ConstantDecision where
  rnf x__ = Prelude.seq x__ ()
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Trace.V1.TraceConfig_Fields.qps' @:: Lens' RateLimitingSampler Data.Int.Int64@ -}
data RateLimitingSampler
  = RateLimitingSampler'_constructor {_RateLimitingSampler'qps :: !Data.Int.Int64,
                                      _RateLimitingSampler'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show RateLimitingSampler where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField RateLimitingSampler "qps" Data.Int.Int64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _RateLimitingSampler'qps
           (\ x__ y__ -> x__ {_RateLimitingSampler'qps = y__}))
        Prelude.id
instance Data.ProtoLens.Message RateLimitingSampler where
  messageName _
    = Data.Text.pack "opentelemetry.proto.trace.v1.RateLimitingSampler"
  packedMessageDescriptor _
    = "\n\
      \\DC3RateLimitingSampler\DC2\DLE\n\
      \\ETXqps\CAN\SOH \SOH(\ETXR\ETXqps"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        qps__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "qps"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"qps")) ::
              Data.ProtoLens.FieldDescriptor RateLimitingSampler
      in
        Data.Map.fromList [(Data.ProtoLens.Tag 1, qps__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _RateLimitingSampler'_unknownFields
        (\ x__ y__ -> x__ {_RateLimitingSampler'_unknownFields = y__})
  defMessage
    = RateLimitingSampler'_constructor
        {_RateLimitingSampler'qps = Data.ProtoLens.fieldDefault,
         _RateLimitingSampler'_unknownFields = []}
  parseMessage
    = let
        loop ::
          RateLimitingSampler
          -> Data.ProtoLens.Encoding.Bytes.Parser RateLimitingSampler
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
                                       "qps"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"qps") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "RateLimitingSampler"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let _v = Lens.Family2.view (Data.ProtoLens.Field.field @"qps") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 8)
                      ((Prelude..)
                         Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData RateLimitingSampler where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_RateLimitingSampler'_unknownFields x__)
             (Control.DeepSeq.deepseq (_RateLimitingSampler'qps x__) ())
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Trace.V1.TraceConfig_Fields.maxNumberOfAttributes' @:: Lens' TraceConfig Data.Int.Int64@
         * 'Proto.Opentelemetry.Proto.Trace.V1.TraceConfig_Fields.maxNumberOfTimedEvents' @:: Lens' TraceConfig Data.Int.Int64@
         * 'Proto.Opentelemetry.Proto.Trace.V1.TraceConfig_Fields.maxNumberOfAttributesPerTimedEvent' @:: Lens' TraceConfig Data.Int.Int64@
         * 'Proto.Opentelemetry.Proto.Trace.V1.TraceConfig_Fields.maxNumberOfLinks' @:: Lens' TraceConfig Data.Int.Int64@
         * 'Proto.Opentelemetry.Proto.Trace.V1.TraceConfig_Fields.maxNumberOfAttributesPerLink' @:: Lens' TraceConfig Data.Int.Int64@
         * 'Proto.Opentelemetry.Proto.Trace.V1.TraceConfig_Fields.maybe'sampler' @:: Lens' TraceConfig (Prelude.Maybe TraceConfig'Sampler)@
         * 'Proto.Opentelemetry.Proto.Trace.V1.TraceConfig_Fields.maybe'constantSampler' @:: Lens' TraceConfig (Prelude.Maybe ConstantSampler)@
         * 'Proto.Opentelemetry.Proto.Trace.V1.TraceConfig_Fields.constantSampler' @:: Lens' TraceConfig ConstantSampler@
         * 'Proto.Opentelemetry.Proto.Trace.V1.TraceConfig_Fields.maybe'traceIdRatioBased' @:: Lens' TraceConfig (Prelude.Maybe TraceIdRatioBased)@
         * 'Proto.Opentelemetry.Proto.Trace.V1.TraceConfig_Fields.traceIdRatioBased' @:: Lens' TraceConfig TraceIdRatioBased@
         * 'Proto.Opentelemetry.Proto.Trace.V1.TraceConfig_Fields.maybe'rateLimitingSampler' @:: Lens' TraceConfig (Prelude.Maybe RateLimitingSampler)@
         * 'Proto.Opentelemetry.Proto.Trace.V1.TraceConfig_Fields.rateLimitingSampler' @:: Lens' TraceConfig RateLimitingSampler@ -}
data TraceConfig
  = TraceConfig'_constructor {_TraceConfig'maxNumberOfAttributes :: !Data.Int.Int64,
                              _TraceConfig'maxNumberOfTimedEvents :: !Data.Int.Int64,
                              _TraceConfig'maxNumberOfAttributesPerTimedEvent :: !Data.Int.Int64,
                              _TraceConfig'maxNumberOfLinks :: !Data.Int.Int64,
                              _TraceConfig'maxNumberOfAttributesPerLink :: !Data.Int.Int64,
                              _TraceConfig'sampler :: !(Prelude.Maybe TraceConfig'Sampler),
                              _TraceConfig'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show TraceConfig where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
data TraceConfig'Sampler
  = TraceConfig'ConstantSampler !ConstantSampler |
    TraceConfig'TraceIdRatioBased !TraceIdRatioBased |
    TraceConfig'RateLimitingSampler !RateLimitingSampler
  deriving stock (Prelude.Show, Prelude.Eq, Prelude.Ord)
instance Data.ProtoLens.Field.HasField TraceConfig "maxNumberOfAttributes" Data.Int.Int64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TraceConfig'maxNumberOfAttributes
           (\ x__ y__ -> x__ {_TraceConfig'maxNumberOfAttributes = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField TraceConfig "maxNumberOfTimedEvents" Data.Int.Int64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TraceConfig'maxNumberOfTimedEvents
           (\ x__ y__ -> x__ {_TraceConfig'maxNumberOfTimedEvents = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField TraceConfig "maxNumberOfAttributesPerTimedEvent" Data.Int.Int64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TraceConfig'maxNumberOfAttributesPerTimedEvent
           (\ x__ y__
              -> x__ {_TraceConfig'maxNumberOfAttributesPerTimedEvent = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField TraceConfig "maxNumberOfLinks" Data.Int.Int64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TraceConfig'maxNumberOfLinks
           (\ x__ y__ -> x__ {_TraceConfig'maxNumberOfLinks = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField TraceConfig "maxNumberOfAttributesPerLink" Data.Int.Int64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TraceConfig'maxNumberOfAttributesPerLink
           (\ x__ y__
              -> x__ {_TraceConfig'maxNumberOfAttributesPerLink = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField TraceConfig "maybe'sampler" (Prelude.Maybe TraceConfig'Sampler) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TraceConfig'sampler
           (\ x__ y__ -> x__ {_TraceConfig'sampler = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField TraceConfig "maybe'constantSampler" (Prelude.Maybe ConstantSampler) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TraceConfig'sampler
           (\ x__ y__ -> x__ {_TraceConfig'sampler = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (TraceConfig'ConstantSampler x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap TraceConfig'ConstantSampler y__))
instance Data.ProtoLens.Field.HasField TraceConfig "constantSampler" ConstantSampler where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TraceConfig'sampler
           (\ x__ y__ -> x__ {_TraceConfig'sampler = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (TraceConfig'ConstantSampler x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap TraceConfig'ConstantSampler y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField TraceConfig "maybe'traceIdRatioBased" (Prelude.Maybe TraceIdRatioBased) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TraceConfig'sampler
           (\ x__ y__ -> x__ {_TraceConfig'sampler = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (TraceConfig'TraceIdRatioBased x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap TraceConfig'TraceIdRatioBased y__))
instance Data.ProtoLens.Field.HasField TraceConfig "traceIdRatioBased" TraceIdRatioBased where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TraceConfig'sampler
           (\ x__ y__ -> x__ {_TraceConfig'sampler = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (TraceConfig'TraceIdRatioBased x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap TraceConfig'TraceIdRatioBased y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField TraceConfig "maybe'rateLimitingSampler" (Prelude.Maybe RateLimitingSampler) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TraceConfig'sampler
           (\ x__ y__ -> x__ {_TraceConfig'sampler = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (TraceConfig'RateLimitingSampler x__val))
                     -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap TraceConfig'RateLimitingSampler y__))
instance Data.ProtoLens.Field.HasField TraceConfig "rateLimitingSampler" RateLimitingSampler where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TraceConfig'sampler
           (\ x__ y__ -> x__ {_TraceConfig'sampler = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (TraceConfig'RateLimitingSampler x__val))
                        -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap TraceConfig'RateLimitingSampler y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Message TraceConfig where
  messageName _
    = Data.Text.pack "opentelemetry.proto.trace.v1.TraceConfig"
  packedMessageDescriptor _
    = "\n\
      \\vTraceConfig\DC2Z\n\
      \\DLEconstant_sampler\CAN\SOH \SOH(\v2-.opentelemetry.proto.trace.v1.ConstantSamplerH\NULR\SIconstantSampler\DC2b\n\
      \\DC4trace_id_ratio_based\CAN\STX \SOH(\v2/.opentelemetry.proto.trace.v1.TraceIdRatioBasedH\NULR\DC1traceIdRatioBased\DC2g\n\
      \\NAKrate_limiting_sampler\CAN\ETX \SOH(\v21.opentelemetry.proto.trace.v1.RateLimitingSamplerH\NULR\DC3rateLimitingSampler\DC27\n\
      \\CANmax_number_of_attributes\CAN\EOT \SOH(\ETXR\NAKmaxNumberOfAttributes\DC2:\n\
      \\SUBmax_number_of_timed_events\CAN\ENQ \SOH(\ETXR\SYNmaxNumberOfTimedEvents\DC2T\n\
      \(max_number_of_attributes_per_timed_event\CAN\ACK \SOH(\ETXR\"maxNumberOfAttributesPerTimedEvent\DC2-\n\
      \\DC3max_number_of_links\CAN\a \SOH(\ETXR\DLEmaxNumberOfLinks\DC2G\n\
      \!max_number_of_attributes_per_link\CAN\b \SOH(\ETXR\FSmaxNumberOfAttributesPerLinkB\t\n\
      \\asampler"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        maxNumberOfAttributes__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "max_number_of_attributes"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"maxNumberOfAttributes")) ::
              Data.ProtoLens.FieldDescriptor TraceConfig
        maxNumberOfTimedEvents__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "max_number_of_timed_events"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"maxNumberOfTimedEvents")) ::
              Data.ProtoLens.FieldDescriptor TraceConfig
        maxNumberOfAttributesPerTimedEvent__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "max_number_of_attributes_per_timed_event"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field
                    @"maxNumberOfAttributesPerTimedEvent")) ::
              Data.ProtoLens.FieldDescriptor TraceConfig
        maxNumberOfLinks__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "max_number_of_links"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"maxNumberOfLinks")) ::
              Data.ProtoLens.FieldDescriptor TraceConfig
        maxNumberOfAttributesPerLink__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "max_number_of_attributes_per_link"
              (Data.ProtoLens.ScalarField Data.ProtoLens.Int64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Int.Int64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"maxNumberOfAttributesPerLink")) ::
              Data.ProtoLens.FieldDescriptor TraceConfig
        constantSampler__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "constant_sampler"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor ConstantSampler)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'constantSampler")) ::
              Data.ProtoLens.FieldDescriptor TraceConfig
        traceIdRatioBased__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "trace_id_ratio_based"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor TraceIdRatioBased)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'traceIdRatioBased")) ::
              Data.ProtoLens.FieldDescriptor TraceConfig
        rateLimitingSampler__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "rate_limiting_sampler"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor RateLimitingSampler)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'rateLimitingSampler")) ::
              Data.ProtoLens.FieldDescriptor TraceConfig
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 4, maxNumberOfAttributes__field_descriptor),
           (Data.ProtoLens.Tag 5, maxNumberOfTimedEvents__field_descriptor),
           (Data.ProtoLens.Tag 6, 
            maxNumberOfAttributesPerTimedEvent__field_descriptor),
           (Data.ProtoLens.Tag 7, maxNumberOfLinks__field_descriptor),
           (Data.ProtoLens.Tag 8, 
            maxNumberOfAttributesPerLink__field_descriptor),
           (Data.ProtoLens.Tag 1, constantSampler__field_descriptor),
           (Data.ProtoLens.Tag 2, traceIdRatioBased__field_descriptor),
           (Data.ProtoLens.Tag 3, rateLimitingSampler__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _TraceConfig'_unknownFields
        (\ x__ y__ -> x__ {_TraceConfig'_unknownFields = y__})
  defMessage
    = TraceConfig'_constructor
        {_TraceConfig'maxNumberOfAttributes = Data.ProtoLens.fieldDefault,
         _TraceConfig'maxNumberOfTimedEvents = Data.ProtoLens.fieldDefault,
         _TraceConfig'maxNumberOfAttributesPerTimedEvent = Data.ProtoLens.fieldDefault,
         _TraceConfig'maxNumberOfLinks = Data.ProtoLens.fieldDefault,
         _TraceConfig'maxNumberOfAttributesPerLink = Data.ProtoLens.fieldDefault,
         _TraceConfig'sampler = Prelude.Nothing,
         _TraceConfig'_unknownFields = []}
  parseMessage
    = let
        loop ::
          TraceConfig -> Data.ProtoLens.Encoding.Bytes.Parser TraceConfig
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
                        32
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "max_number_of_attributes"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"maxNumberOfAttributes") y x)
                        40
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "max_number_of_timed_events"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"maxNumberOfTimedEvents") y x)
                        48
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "max_number_of_attributes_per_timed_event"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field
                                        @"maxNumberOfAttributesPerTimedEvent")
                                     y x)
                        56
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "max_number_of_links"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"maxNumberOfLinks") y x)
                        64
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "max_number_of_attributes_per_link"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"maxNumberOfAttributesPerLink") y
                                     x)
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "constant_sampler"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"constantSampler") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "trace_id_ratio_based"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"traceIdRatioBased") y x)
                        26
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "rate_limiting_sampler"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"rateLimitingSampler") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "TraceConfig"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v
                  = Lens.Family2.view
                      (Data.ProtoLens.Field.field @"maxNumberOfAttributes") _x
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
                         (Data.ProtoLens.Field.field @"maxNumberOfTimedEvents") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 40)
                         ((Prelude..)
                            Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                ((Data.Monoid.<>)
                   (let
                      _v
                        = Lens.Family2.view
                            (Data.ProtoLens.Field.field @"maxNumberOfAttributesPerTimedEvent")
                            _x
                    in
                      if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                          Data.Monoid.mempty
                      else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 48)
                            ((Prelude..)
                               Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                   ((Data.Monoid.<>)
                      (let
                         _v
                           = Lens.Family2.view
                               (Data.ProtoLens.Field.field @"maxNumberOfLinks") _x
                       in
                         if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                             Data.Monoid.mempty
                         else
                             (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt 56)
                               ((Prelude..)
                                  Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
                      ((Data.Monoid.<>)
                         (let
                            _v
                              = Lens.Family2.view
                                  (Data.ProtoLens.Field.field @"maxNumberOfAttributesPerLink") _x
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
                                 Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'sampler") _x
                             of
                               Prelude.Nothing -> Data.Monoid.mempty
                               (Prelude.Just (TraceConfig'ConstantSampler v))
                                 -> (Data.Monoid.<>)
                                      (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                                      ((Prelude..)
                                         (\ bs
                                            -> (Data.Monoid.<>)
                                                 (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                    (Prelude.fromIntegral
                                                       (Data.ByteString.length bs)))
                                                 (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                         Data.ProtoLens.encodeMessage v)
                               (Prelude.Just (TraceConfig'TraceIdRatioBased v))
                                 -> (Data.Monoid.<>)
                                      (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                                      ((Prelude..)
                                         (\ bs
                                            -> (Data.Monoid.<>)
                                                 (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                    (Prelude.fromIntegral
                                                       (Data.ByteString.length bs)))
                                                 (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                         Data.ProtoLens.encodeMessage v)
                               (Prelude.Just (TraceConfig'RateLimitingSampler v))
                                 -> (Data.Monoid.<>)
                                      (Data.ProtoLens.Encoding.Bytes.putVarInt 26)
                                      ((Prelude..)
                                         (\ bs
                                            -> (Data.Monoid.<>)
                                                 (Data.ProtoLens.Encoding.Bytes.putVarInt
                                                    (Prelude.fromIntegral
                                                       (Data.ByteString.length bs)))
                                                 (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                         Data.ProtoLens.encodeMessage v))
                            (Data.ProtoLens.Encoding.Wire.buildFieldSet
                               (Lens.Family2.view Data.ProtoLens.unknownFields _x)))))))
instance Control.DeepSeq.NFData TraceConfig where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_TraceConfig'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_TraceConfig'maxNumberOfAttributes x__)
                (Control.DeepSeq.deepseq
                   (_TraceConfig'maxNumberOfTimedEvents x__)
                   (Control.DeepSeq.deepseq
                      (_TraceConfig'maxNumberOfAttributesPerTimedEvent x__)
                      (Control.DeepSeq.deepseq
                         (_TraceConfig'maxNumberOfLinks x__)
                         (Control.DeepSeq.deepseq
                            (_TraceConfig'maxNumberOfAttributesPerLink x__)
                            (Control.DeepSeq.deepseq (_TraceConfig'sampler x__) ()))))))
instance Control.DeepSeq.NFData TraceConfig'Sampler where
  rnf (TraceConfig'ConstantSampler x__) = Control.DeepSeq.rnf x__
  rnf (TraceConfig'TraceIdRatioBased x__) = Control.DeepSeq.rnf x__
  rnf (TraceConfig'RateLimitingSampler x__) = Control.DeepSeq.rnf x__
_TraceConfig'ConstantSampler ::
  Data.ProtoLens.Prism.Prism' TraceConfig'Sampler ConstantSampler
_TraceConfig'ConstantSampler
  = Data.ProtoLens.Prism.prism'
      TraceConfig'ConstantSampler
      (\ p__
         -> case p__ of
              (TraceConfig'ConstantSampler p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_TraceConfig'TraceIdRatioBased ::
  Data.ProtoLens.Prism.Prism' TraceConfig'Sampler TraceIdRatioBased
_TraceConfig'TraceIdRatioBased
  = Data.ProtoLens.Prism.prism'
      TraceConfig'TraceIdRatioBased
      (\ p__
         -> case p__ of
              (TraceConfig'TraceIdRatioBased p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_TraceConfig'RateLimitingSampler ::
  Data.ProtoLens.Prism.Prism' TraceConfig'Sampler RateLimitingSampler
_TraceConfig'RateLimitingSampler
  = Data.ProtoLens.Prism.prism'
      TraceConfig'RateLimitingSampler
      (\ p__
         -> case p__ of
              (TraceConfig'RateLimitingSampler p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
{- | Fields :
     
         * 'Proto.Opentelemetry.Proto.Trace.V1.TraceConfig_Fields.samplingRatio' @:: Lens' TraceIdRatioBased Prelude.Double@ -}
data TraceIdRatioBased
  = TraceIdRatioBased'_constructor {_TraceIdRatioBased'samplingRatio :: !Prelude.Double,
                                    _TraceIdRatioBased'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)
instance Prelude.Show TraceIdRatioBased where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Data.ProtoLens.Field.HasField TraceIdRatioBased "samplingRatio" Prelude.Double where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _TraceIdRatioBased'samplingRatio
           (\ x__ y__ -> x__ {_TraceIdRatioBased'samplingRatio = y__}))
        Prelude.id
instance Data.ProtoLens.Message TraceIdRatioBased where
  messageName _
    = Data.Text.pack "opentelemetry.proto.trace.v1.TraceIdRatioBased"
  packedMessageDescriptor _
    = "\n\
      \\DC1TraceIdRatioBased\DC2$\n\
      \\rsamplingRatio\CAN\SOH \SOH(\SOHR\rsamplingRatio"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        samplingRatio__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "samplingRatio"
              (Data.ProtoLens.ScalarField Data.ProtoLens.DoubleField ::
                 Data.ProtoLens.FieldTypeDescriptor Prelude.Double)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"samplingRatio")) ::
              Data.ProtoLens.FieldDescriptor TraceIdRatioBased
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, samplingRatio__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _TraceIdRatioBased'_unknownFields
        (\ x__ y__ -> x__ {_TraceIdRatioBased'_unknownFields = y__})
  defMessage
    = TraceIdRatioBased'_constructor
        {_TraceIdRatioBased'samplingRatio = Data.ProtoLens.fieldDefault,
         _TraceIdRatioBased'_unknownFields = []}
  parseMessage
    = let
        loop ::
          TraceIdRatioBased
          -> Data.ProtoLens.Encoding.Bytes.Parser TraceIdRatioBased
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
                                       "samplingRatio"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"samplingRatio") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "TraceIdRatioBased"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v
                  = Lens.Family2.view
                      (Data.ProtoLens.Field.field @"samplingRatio") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 9)
                      ((Prelude..)
                         Data.ProtoLens.Encoding.Bytes.putFixed64
                         Data.ProtoLens.Encoding.Bytes.doubleToWord _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData TraceIdRatioBased where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_TraceIdRatioBased'_unknownFields x__)
             (Control.DeepSeq.deepseq (_TraceIdRatioBased'samplingRatio x__) ())
packedFileDescriptor :: Data.ByteString.ByteString
packedFileDescriptor
  = "\n\
    \/opentelemetry/proto/trace/v1/trace_config.proto\DC2\FSopentelemetry.proto.trace.v1\"\132\ENQ\n\
    \\vTraceConfig\DC2Z\n\
    \\DLEconstant_sampler\CAN\SOH \SOH(\v2-.opentelemetry.proto.trace.v1.ConstantSamplerH\NULR\SIconstantSampler\DC2b\n\
    \\DC4trace_id_ratio_based\CAN\STX \SOH(\v2/.opentelemetry.proto.trace.v1.TraceIdRatioBasedH\NULR\DC1traceIdRatioBased\DC2g\n\
    \\NAKrate_limiting_sampler\CAN\ETX \SOH(\v21.opentelemetry.proto.trace.v1.RateLimitingSamplerH\NULR\DC3rateLimitingSampler\DC27\n\
    \\CANmax_number_of_attributes\CAN\EOT \SOH(\ETXR\NAKmaxNumberOfAttributes\DC2:\n\
    \\SUBmax_number_of_timed_events\CAN\ENQ \SOH(\ETXR\SYNmaxNumberOfTimedEvents\DC2T\n\
    \(max_number_of_attributes_per_timed_event\CAN\ACK \SOH(\ETXR\"maxNumberOfAttributesPerTimedEvent\DC2-\n\
    \\DC3max_number_of_links\CAN\a \SOH(\ETXR\DLEmaxNumberOfLinks\DC2G\n\
    \!max_number_of_attributes_per_link\CAN\b \SOH(\ETXR\FSmaxNumberOfAttributesPerLinkB\t\n\
    \\asampler\"\179\SOH\n\
    \\SIConstantSampler\DC2Z\n\
    \\bdecision\CAN\SOH \SOH(\SO2>.opentelemetry.proto.trace.v1.ConstantSampler.ConstantDecisionR\bdecision\"D\n\
    \\DLEConstantDecision\DC2\SO\n\
    \\n\
    \ALWAYS_OFF\DLE\NUL\DC2\r\n\
    \\tALWAYS_ON\DLE\SOH\DC2\DC1\n\
    \\rALWAYS_PARENT\DLE\STX\"9\n\
    \\DC1TraceIdRatioBased\DC2$\n\
    \\rsamplingRatio\CAN\SOH \SOH(\SOHR\rsamplingRatio\"'\n\
    \\DC3RateLimitingSampler\DC2\DLE\n\
    \\ETXqps\CAN\SOH \SOH(\ETXR\ETXqpsB~\n\
    \\USio.opentelemetry.proto.trace.v1B\DLETraceConfigProtoP\SOHZGgithub.com/open-telemetry/opentelemetry-proto/gen/go/collector/trace/v1J\139\DC4\n\
    \\ACK\DC2\EOT\SO\NULM\SOH\n\
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
    \\b\n\
    \\SOH\b\DC2\ETX\DC2\NUL\"\n\
    \\t\n\
    \\STX\b\n\
    \\DC2\ETX\DC2\NUL\"\n\
    \\b\n\
    \\SOH\b\DC2\ETX\DC3\NUL8\n\
    \\t\n\
    \\STX\b\SOH\DC2\ETX\DC3\NUL8\n\
    \\b\n\
    \\SOH\b\DC2\ETX\DC4\NUL1\n\
    \\t\n\
    \\STX\b\b\DC2\ETX\DC4\NUL1\n\
    \\b\n\
    \\SOH\b\DC2\ETX\NAK\NUL^\n\
    \\t\n\
    \\STX\b\v\DC2\ETX\NAK\NUL^\n\
    \\145\SOH\n\
    \\STX\EOT\NUL\DC2\EOT\EM\NUL2\SOH\SUB\132\SOH Global configuration of the trace service. All fields must be specified, or\n\
    \ the default (zero) values will be used for each type.\n\
    \\n\
    \\n\
    \\n\
    \\ETX\EOT\NUL\SOH\DC2\ETX\EM\b\DC3\n\
    \S\n\
    \\EOT\EOT\NUL\b\NUL\DC2\EOT\FS\STX\"\ETX\SUBE The global default sampler used to make decisions on span sampling.\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\NUL\b\NUL\SOH\DC2\ETX\FS\b\SI\n\
    \\v\n\
    \\EOT\EOT\NUL\STX\NUL\DC2\ETX\GS\EOT)\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\ACK\DC2\ETX\GS\EOT\DC3\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\SOH\DC2\ETX\GS\DC4$\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\ETX\DC2\ETX\GS'(\n\
    \\v\n\
    \\EOT\EOT\NUL\STX\SOH\DC2\ETX\US\EOT/\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\SOH\ACK\DC2\ETX\US\EOT\NAK\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\SOH\SOH\DC2\ETX\US\SYN*\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\SOH\ETX\DC2\ETX\US-.\n\
    \\v\n\
    \\EOT\EOT\NUL\STX\STX\DC2\ETX!\EOT2\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\STX\ACK\DC2\ETX!\EOT\ETB\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\STX\SOH\DC2\ETX!\CAN-\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\STX\ETX\DC2\ETX!01\n\
    \D\n\
    \\EOT\EOT\NUL\STX\ETX\DC2\ETX%\STX%\SUB7 The global default max number of attributes per span.\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\ETX\ENQ\DC2\ETX%\STX\a\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\ETX\SOH\DC2\ETX%\b \n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\ETX\ETX\DC2\ETX%#$\n\
    \K\n\
    \\EOT\EOT\NUL\STX\EOT\DC2\ETX(\STX&\SUB> The global default max number of annotation events per span.\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\EOT\ENQ\DC2\ETX(\STX\a\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\EOT\SOH\DC2\ETX(\b\"\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\EOT\ETX\DC2\ETX($%\n\
    \K\n\
    \\EOT\EOT\NUL\STX\ENQ\DC2\ETX+\STX5\SUB> The global default max number of attributes per timed event.\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\ENQ\ENQ\DC2\ETX+\STX\a\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\ENQ\SOH\DC2\ETX+\b0\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\ENQ\ETX\DC2\ETX+34\n\
    \F\n\
    \\EOT\EOT\NUL\STX\ACK\DC2\ETX.\STX \SUB9 The global default max number of link entries per span.\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\ACK\ENQ\DC2\ETX.\STX\a\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\ACK\SOH\DC2\ETX.\b\ESC\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\ACK\ETX\DC2\ETX.\RS\US\n\
    \D\n\
    \\EOT\EOT\NUL\STX\a\DC2\ETX1\STX.\SUB7 The global default max number of attributes per span.\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\a\ENQ\DC2\ETX1\STX\a\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\a\SOH\DC2\ETX1\b)\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\a\ETX\DC2\ETX1,-\n\
    \M\n\
    \\STX\EOT\SOH\DC2\EOT5\NUL@\SOH\SUBA Sampler that always makes a constant decision on span sampling.\n\
    \\n\
    \\n\
    \\n\
    \\ETX\EOT\SOH\SOH\DC2\ETX5\b\ETB\n\
    \\135\SOH\n\
    \\EOT\EOT\SOH\EOT\NUL\DC2\EOT:\STX>\ETX\SUBy How spans should be sampled:\n\
    \ - Always off\n\
    \ - Always on\n\
    \ - Always follow the parent Span's decision (off if no parent).\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\SOH\EOT\NUL\SOH\DC2\ETX:\a\ETB\n\
    \\r\n\
    \\ACK\EOT\SOH\EOT\NUL\STX\NUL\DC2\ETX;\EOT\DC3\n\
    \\SO\n\
    \\a\EOT\SOH\EOT\NUL\STX\NUL\SOH\DC2\ETX;\EOT\SO\n\
    \\SO\n\
    \\a\EOT\SOH\EOT\NUL\STX\NUL\STX\DC2\ETX;\DC1\DC2\n\
    \\r\n\
    \\ACK\EOT\SOH\EOT\NUL\STX\SOH\DC2\ETX<\EOT\DC2\n\
    \\SO\n\
    \\a\EOT\SOH\EOT\NUL\STX\SOH\SOH\DC2\ETX<\EOT\r\n\
    \\SO\n\
    \\a\EOT\SOH\EOT\NUL\STX\SOH\STX\DC2\ETX<\DLE\DC1\n\
    \\r\n\
    \\ACK\EOT\SOH\EOT\NUL\STX\STX\DC2\ETX=\EOT\SYN\n\
    \\SO\n\
    \\a\EOT\SOH\EOT\NUL\STX\STX\SOH\DC2\ETX=\EOT\DC1\n\
    \\SO\n\
    \\a\EOT\SOH\EOT\NUL\STX\STX\STX\DC2\ETX=\DC4\NAK\n\
    \\v\n\
    \\EOT\EOT\SOH\STX\NUL\DC2\ETX?\STX \n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\ACK\DC2\ETX?\STX\DC2\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\SOH\DC2\ETX?\DC3\ESC\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\ETX\DC2\ETX?\RS\US\n\
    \\152\SOH\n\
    \\STX\EOT\STX\DC2\EOTD\NULG\SOH\SUB\139\SOH Sampler that tries to uniformly sample traces with a given ratio.\n\
    \ The ratio of sampling a trace is equal to that of the specified ratio.\n\
    \\n\
    \\n\
    \\n\
    \\ETX\EOT\STX\SOH\DC2\ETXD\b\EM\n\
    \H\n\
    \\EOT\EOT\STX\STX\NUL\DC2\ETXF\STX\ESC\SUB; The desired ratio of sampling. Must be within [0.0, 1.0].\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\NUL\ENQ\DC2\ETXF\STX\b\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\NUL\SOH\DC2\ETXF\t\SYN\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\NUL\ETX\DC2\ETXF\EM\SUB\n\
    \G\n\
    \\STX\EOT\ETX\DC2\EOTJ\NULM\SOH\SUB; Sampler that tries to sample with a rate per time window.\n\
    \\n\
    \\n\
    \\n\
    \\ETX\EOT\ETX\SOH\DC2\ETXJ\b\ESC\n\
    \\US\n\
    \\EOT\EOT\ETX\STX\NUL\DC2\ETXL\STX\DLE\SUB\DC2 Rate per second.\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\ETX\STX\NUL\ENQ\DC2\ETXL\STX\a\n\
    \\f\n\
    \\ENQ\EOT\ETX\STX\NUL\SOH\DC2\ETXL\b\v\n\
    \\f\n\
    \\ENQ\EOT\ETX\STX\NUL\ETX\DC2\ETXL\SO\SIb\ACKproto3"