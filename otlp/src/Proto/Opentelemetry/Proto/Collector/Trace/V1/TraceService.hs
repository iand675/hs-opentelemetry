{- This file was auto-generated from opentelemetry/proto/collector/trace/v1/trace_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE BangPatterns #-}
{- This file was auto-generated from opentelemetry/proto/collector/trace/v1/trace_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE DataKinds #-}
{- This file was auto-generated from opentelemetry/proto/collector/trace/v1/trace_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE DerivingStrategies #-}
{- This file was auto-generated from opentelemetry/proto/collector/trace/v1/trace_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE FlexibleContexts #-}
{- This file was auto-generated from opentelemetry/proto/collector/trace/v1/trace_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE FlexibleInstances #-}
{- This file was auto-generated from opentelemetry/proto/collector/trace/v1/trace_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{- This file was auto-generated from opentelemetry/proto/collector/trace/v1/trace_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE MagicHash #-}
{- This file was auto-generated from opentelemetry/proto/collector/trace/v1/trace_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE MultiParamTypeClasses #-}
{- This file was auto-generated from opentelemetry/proto/collector/trace/v1/trace_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE OverloadedStrings #-}
{- This file was auto-generated from opentelemetry/proto/collector/trace/v1/trace_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE PatternSynonyms #-}
{- This file was auto-generated from opentelemetry/proto/collector/trace/v1/trace_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE ScopedTypeVariables #-}
{- This file was auto-generated from opentelemetry/proto/collector/trace/v1/trace_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE TypeApplications #-}
{- This file was auto-generated from opentelemetry/proto/collector/trace/v1/trace_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE TypeFamilies #-}
{- This file was auto-generated from opentelemetry/proto/collector/trace/v1/trace_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE UndecidableInstances #-}
{- This file was auto-generated from opentelemetry/proto/collector/trace/v1/trace_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE NoImplicitPrelude #-}
{-# OPTIONS_GHC -Wno-dodgy-exports #-}
{-# OPTIONS_GHC -Wno-duplicate-exports #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Proto.Opentelemetry.Proto.Collector.Trace.V1.TraceService (
  TraceService (..),
  ExportTraceServiceRequest (),
  ExportTraceServiceResponse (),
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
import qualified Proto.Opentelemetry.Proto.Trace.V1.Trace


{- | Fields :

         * 'Proto.Opentelemetry.Proto.Collector.Trace.V1.TraceService_Fields.resourceSpans' @:: Lens' ExportTraceServiceRequest [Proto.Opentelemetry.Proto.Trace.V1.Trace.ResourceSpans]@
         * 'Proto.Opentelemetry.Proto.Collector.Trace.V1.TraceService_Fields.vec'resourceSpans' @:: Lens' ExportTraceServiceRequest (Data.Vector.Vector Proto.Opentelemetry.Proto.Trace.V1.Trace.ResourceSpans)@
-}
data ExportTraceServiceRequest = ExportTraceServiceRequest'_constructor
  { _ExportTraceServiceRequest'resourceSpans :: !(Data.Vector.Vector Proto.Opentelemetry.Proto.Trace.V1.Trace.ResourceSpans)
  , _ExportTraceServiceRequest'_unknownFields :: !Data.ProtoLens.FieldSet
  }
  deriving stock (Prelude.Eq, Prelude.Ord)


instance Prelude.Show ExportTraceServiceRequest where
  showsPrec _ __x __s =
    Prelude.showChar
      '{'
      ( Prelude.showString
          (Data.ProtoLens.showMessageShort __x)
          (Prelude.showChar '}' __s)
      )


instance Data.ProtoLens.Field.HasField ExportTraceServiceRequest "resourceSpans" [Proto.Opentelemetry.Proto.Trace.V1.Trace.ResourceSpans] where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _ExportTraceServiceRequest'resourceSpans
          ( \x__ y__ ->
              x__ {_ExportTraceServiceRequest'resourceSpans = y__}
          )
      )
      ( Lens.Family2.Unchecked.lens
          Data.Vector.Generic.toList
          (\_ y__ -> Data.Vector.Generic.fromList y__)
      )


instance Data.ProtoLens.Field.HasField ExportTraceServiceRequest "vec'resourceSpans" (Data.Vector.Vector Proto.Opentelemetry.Proto.Trace.V1.Trace.ResourceSpans) where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _ExportTraceServiceRequest'resourceSpans
          ( \x__ y__ ->
              x__ {_ExportTraceServiceRequest'resourceSpans = y__}
          )
      )
      Prelude.id


instance Data.ProtoLens.Message ExportTraceServiceRequest where
  messageName _ =
    Data.Text.pack
      "opentelemetry.proto.collector.trace.v1.ExportTraceServiceRequest"
  packedMessageDescriptor _ =
    "\n\
    \\EMExportTraceServiceRequest\DC2R\n\
    \\SOresource_spans\CAN\SOH \ETX(\v2+.opentelemetry.proto.trace.v1.ResourceSpansR\rresourceSpans"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag =
    let resourceSpans__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "resource_spans"
            ( Data.ProtoLens.MessageField Data.ProtoLens.MessageType
                :: Data.ProtoLens.FieldTypeDescriptor Proto.Opentelemetry.Proto.Trace.V1.Trace.ResourceSpans
            )
            ( Data.ProtoLens.RepeatedField
                Data.ProtoLens.Unpacked
                (Data.ProtoLens.Field.field @"resourceSpans")
            )
            :: Data.ProtoLens.FieldDescriptor ExportTraceServiceRequest
     in Data.Map.fromList
          [(Data.ProtoLens.Tag 1, resourceSpans__field_descriptor)]
  unknownFields =
    Lens.Family2.Unchecked.lens
      _ExportTraceServiceRequest'_unknownFields
      ( \x__ y__ ->
          x__ {_ExportTraceServiceRequest'_unknownFields = y__}
      )
  defMessage =
    ExportTraceServiceRequest'_constructor
      { _ExportTraceServiceRequest'resourceSpans = Data.Vector.Generic.empty
      , _ExportTraceServiceRequest'_unknownFields = []
      }
  parseMessage =
    let loop
          :: ExportTraceServiceRequest
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Proto.Opentelemetry.Proto.Trace.V1.Trace.ResourceSpans
          -> Data.ProtoLens.Encoding.Bytes.Parser ExportTraceServiceRequest
        loop x mutable'resourceSpans =
          do
            end <- Data.ProtoLens.Encoding.Bytes.atEnd
            if end
              then do
                frozen'resourceSpans <-
                  Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                    ( Data.ProtoLens.Encoding.Growing.unsafeFreeze
                        mutable'resourceSpans
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
                          (Data.ProtoLens.Field.field @"vec'resourceSpans")
                          frozen'resourceSpans
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
                          "resource_spans"
                      v <-
                        Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                          ( Data.ProtoLens.Encoding.Growing.append
                              mutable'resourceSpans
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
                        mutable'resourceSpans
     in (Data.ProtoLens.Encoding.Bytes.<?>)
          ( do
              mutable'resourceSpans <-
                Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                  Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'resourceSpans
          )
          "ExportTraceServiceRequest"
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
                (Data.ProtoLens.Field.field @"vec'resourceSpans")
                _x
            )
        )
        ( Data.ProtoLens.Encoding.Wire.buildFieldSet
            (Lens.Family2.view Data.ProtoLens.unknownFields _x)
        )


instance Control.DeepSeq.NFData ExportTraceServiceRequest where
  rnf =
    \x__ ->
      Control.DeepSeq.deepseq
        (_ExportTraceServiceRequest'_unknownFields x__)
        ( Control.DeepSeq.deepseq
            (_ExportTraceServiceRequest'resourceSpans x__)
            ()
        )


-- | Fields :
data ExportTraceServiceResponse = ExportTraceServiceResponse'_constructor {_ExportTraceServiceResponse'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)


instance Prelude.Show ExportTraceServiceResponse where
  showsPrec _ __x __s =
    Prelude.showChar
      '{'
      ( Prelude.showString
          (Data.ProtoLens.showMessageShort __x)
          (Prelude.showChar '}' __s)
      )


instance Data.ProtoLens.Message ExportTraceServiceResponse where
  messageName _ =
    Data.Text.pack
      "opentelemetry.proto.collector.trace.v1.ExportTraceServiceResponse"
  packedMessageDescriptor _ =
    "\n\
    \\SUBExportTraceServiceResponse"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag = let in Data.Map.fromList []
  unknownFields =
    Lens.Family2.Unchecked.lens
      _ExportTraceServiceResponse'_unknownFields
      ( \x__ y__ ->
          x__ {_ExportTraceServiceResponse'_unknownFields = y__}
      )
  defMessage =
    ExportTraceServiceResponse'_constructor
      { _ExportTraceServiceResponse'_unknownFields = []
      }
  parseMessage =
    let loop
          :: ExportTraceServiceResponse
          -> Data.ProtoLens.Encoding.Bytes.Parser ExportTraceServiceResponse
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
          "ExportTraceServiceResponse"
  buildMessage =
    \_x ->
      Data.ProtoLens.Encoding.Wire.buildFieldSet
        (Lens.Family2.view Data.ProtoLens.unknownFields _x)


instance Control.DeepSeq.NFData ExportTraceServiceResponse where
  rnf =
    \x__ ->
      Control.DeepSeq.deepseq
        (_ExportTraceServiceResponse'_unknownFields x__)
        ()


data TraceService = TraceService {}


instance Data.ProtoLens.Service.Types.Service TraceService where
  type ServiceName TraceService = "TraceService"
  type ServicePackage TraceService = "opentelemetry.proto.collector.trace.v1"
  type ServiceMethods TraceService = '["export"]
  packedServiceDescriptor _ =
    "\n\
    \\fTraceService\DC2\145\SOH\n\
    \\ACKExport\DC2A.opentelemetry.proto.collector.trace.v1.ExportTraceServiceRequest\SUBB.opentelemetry.proto.collector.trace.v1.ExportTraceServiceResponse\"\NUL"


instance Data.ProtoLens.Service.Types.HasMethodImpl TraceService "export" where
  type MethodName TraceService "export" = "Export"
  type MethodInput TraceService "export" = ExportTraceServiceRequest
  type MethodOutput TraceService "export" = ExportTraceServiceResponse
  type MethodStreamingType TraceService "export" = 'Data.ProtoLens.Service.Types.NonStreaming


packedFileDescriptor :: Data.ByteString.ByteString
packedFileDescriptor =
  "\n\
  \:opentelemetry/proto/collector/trace/v1/trace_service.proto\DC2&opentelemetry.proto.collector.trace.v1\SUB(opentelemetry/proto/trace/v1/trace.proto\"o\n\
  \\EMExportTraceServiceRequest\DC2R\n\
  \\SOresource_spans\CAN\SOH \ETX(\v2+.opentelemetry.proto.trace.v1.ResourceSpansR\rresourceSpans\"\FS\n\
  \\SUBExportTraceServiceResponse2\162\SOH\n\
  \\fTraceService\DC2\145\SOH\n\
  \\ACKExport\DC2A.opentelemetry.proto.collector.trace.v1.ExportTraceServiceRequest\SUBB.opentelemetry.proto.collector.trace.v1.ExportTraceServiceResponse\"\NULB\137\SOH\n\
  \)io.opentelemetry.proto.collector.trace.v1B\DC1TraceServiceProtoP\SOHZGgithub.com/open-telemetry/opentelemetry-proto/gen/go/collector/trace/v1J\160\f\n\
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
  \\SOH\STX\DC2\ETX\DLE\NUL/\n\
  \\t\n\
  \\STX\ETX\NUL\DC2\ETX\DC2\NUL2\n\
  \\b\n\
  \\SOH\b\DC2\ETX\DC4\NUL\"\n\
  \\t\n\
  \\STX\b\n\
  \\DC2\ETX\DC4\NUL\"\n\
  \\b\n\
  \\SOH\b\DC2\ETX\NAK\NULB\n\
  \\t\n\
  \\STX\b\SOH\DC2\ETX\NAK\NULB\n\
  \\b\n\
  \\SOH\b\DC2\ETX\SYN\NUL2\n\
  \\t\n\
  \\STX\b\b\DC2\ETX\SYN\NUL2\n\
  \\b\n\
  \\SOH\b\DC2\ETX\ETB\NUL^\n\
  \\t\n\
  \\STX\b\v\DC2\ETX\ETB\NUL^\n\
  \\245\SOH\n\
  \\STX\ACK\NUL\DC2\EOT\FS\NUL \SOH\SUB\232\SOH Service that can be used to push spans between one Application instrumented with\n\
  \ OpenTelemetry and a collector, or between a collector and a central collector (in this\n\
  \ case spans are sent/received to/from multiple Applications).\n\
  \\n\
  \\n\
  \\n\
  \\ETX\ACK\NUL\SOH\DC2\ETX\FS\b\DC4\n\
  \y\n\
  \\EOT\ACK\NUL\STX\NUL\DC2\ETX\US\STXO\SUBl For performance reasons, it is recommended to keep this RPC\n\
  \ alive for the entire life of the application.\n\
  \\n\
  \\f\n\
  \\ENQ\ACK\NUL\STX\NUL\SOH\DC2\ETX\US\ACK\f\n\
  \\f\n\
  \\ENQ\ACK\NUL\STX\NUL\STX\DC2\ETX\US\r&\n\
  \\f\n\
  \\ENQ\ACK\NUL\STX\NUL\ETX\DC2\ETX\US1K\n\
  \\n\
  \\n\
  \\STX\EOT\NUL\DC2\EOT\"\NUL)\SOH\n\
  \\n\
  \\n\
  \\ETX\EOT\NUL\SOH\DC2\ETX\"\b!\n\
  \\208\STX\n\
  \\EOT\EOT\NUL\STX\NUL\DC2\ETX(\STXI\SUB\194\STX An array of ResourceSpans.\n\
  \ For data coming from a single resource this array will typically contain one\n\
  \ element. Intermediary nodes (such as OpenTelemetry Collector) that receive\n\
  \ data from multiple origins typically batch the data before forwarding further and\n\
  \ in that case this array will contain multiple elements.\n\
  \\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\NUL\EOT\DC2\ETX(\STX\n\
  \\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\NUL\ACK\DC2\ETX(\v5\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\NUL\SOH\DC2\ETX(6D\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\NUL\ETX\DC2\ETX(GH\n\
  \\n\
  \\n\
  \\STX\EOT\SOH\DC2\EOT+\NUL,\SOH\n\
  \\n\
  \\n\
  \\ETX\EOT\SOH\SOH\DC2\ETX+\b\"b\ACKproto3"
