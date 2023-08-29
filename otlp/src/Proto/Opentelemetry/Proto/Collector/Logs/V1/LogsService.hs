{- This file was auto-generated from opentelemetry/proto/collector/logs/v1/logs_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE BangPatterns #-}
{- This file was auto-generated from opentelemetry/proto/collector/logs/v1/logs_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE DataKinds #-}
{- This file was auto-generated from opentelemetry/proto/collector/logs/v1/logs_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE DerivingStrategies #-}
{- This file was auto-generated from opentelemetry/proto/collector/logs/v1/logs_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE FlexibleContexts #-}
{- This file was auto-generated from opentelemetry/proto/collector/logs/v1/logs_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE FlexibleInstances #-}
{- This file was auto-generated from opentelemetry/proto/collector/logs/v1/logs_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{- This file was auto-generated from opentelemetry/proto/collector/logs/v1/logs_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE MagicHash #-}
{- This file was auto-generated from opentelemetry/proto/collector/logs/v1/logs_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE MultiParamTypeClasses #-}
{- This file was auto-generated from opentelemetry/proto/collector/logs/v1/logs_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE OverloadedStrings #-}
{- This file was auto-generated from opentelemetry/proto/collector/logs/v1/logs_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE PatternSynonyms #-}
{- This file was auto-generated from opentelemetry/proto/collector/logs/v1/logs_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE ScopedTypeVariables #-}
{- This file was auto-generated from opentelemetry/proto/collector/logs/v1/logs_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE TypeApplications #-}
{- This file was auto-generated from opentelemetry/proto/collector/logs/v1/logs_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE TypeFamilies #-}
{- This file was auto-generated from opentelemetry/proto/collector/logs/v1/logs_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE UndecidableInstances #-}
{- This file was auto-generated from opentelemetry/proto/collector/logs/v1/logs_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE NoImplicitPrelude #-}
{-# OPTIONS_GHC -Wno-dodgy-exports #-}
{-# OPTIONS_GHC -Wno-duplicate-exports #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Proto.Opentelemetry.Proto.Collector.Logs.V1.LogsService (
  LogsService (..),
  ExportLogsServiceRequest (),
  ExportLogsServiceResponse (),
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
import qualified Proto.Opentelemetry.Proto.Logs.V1.Logs


{- | Fields :

         * 'Proto.Opentelemetry.Proto.Collector.Logs.V1.LogsService_Fields.resourceLogs' @:: Lens' ExportLogsServiceRequest [Proto.Opentelemetry.Proto.Logs.V1.Logs.ResourceLogs]@
         * 'Proto.Opentelemetry.Proto.Collector.Logs.V1.LogsService_Fields.vec'resourceLogs' @:: Lens' ExportLogsServiceRequest (Data.Vector.Vector Proto.Opentelemetry.Proto.Logs.V1.Logs.ResourceLogs)@
-}
data ExportLogsServiceRequest = ExportLogsServiceRequest'_constructor
  { _ExportLogsServiceRequest'resourceLogs :: !(Data.Vector.Vector Proto.Opentelemetry.Proto.Logs.V1.Logs.ResourceLogs)
  , _ExportLogsServiceRequest'_unknownFields :: !Data.ProtoLens.FieldSet
  }
  deriving stock (Prelude.Eq, Prelude.Ord)


instance Prelude.Show ExportLogsServiceRequest where
  showsPrec _ __x __s =
    Prelude.showChar
      '{'
      ( Prelude.showString
          (Data.ProtoLens.showMessageShort __x)
          (Prelude.showChar '}' __s)
      )


instance Data.ProtoLens.Field.HasField ExportLogsServiceRequest "resourceLogs" [Proto.Opentelemetry.Proto.Logs.V1.Logs.ResourceLogs] where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _ExportLogsServiceRequest'resourceLogs
          (\x__ y__ -> x__ {_ExportLogsServiceRequest'resourceLogs = y__})
      )
      ( Lens.Family2.Unchecked.lens
          Data.Vector.Generic.toList
          (\_ y__ -> Data.Vector.Generic.fromList y__)
      )


instance Data.ProtoLens.Field.HasField ExportLogsServiceRequest "vec'resourceLogs" (Data.Vector.Vector Proto.Opentelemetry.Proto.Logs.V1.Logs.ResourceLogs) where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _ExportLogsServiceRequest'resourceLogs
          (\x__ y__ -> x__ {_ExportLogsServiceRequest'resourceLogs = y__})
      )
      Prelude.id


instance Data.ProtoLens.Message ExportLogsServiceRequest where
  messageName _ =
    Data.Text.pack
      "opentelemetry.proto.collector.logs.v1.ExportLogsServiceRequest"
  packedMessageDescriptor _ =
    "\n\
    \\CANExportLogsServiceRequest\DC2N\n\
    \\rresource_logs\CAN\SOH \ETX(\v2).opentelemetry.proto.logs.v1.ResourceLogsR\fresourceLogs"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag =
    let resourceLogs__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "resource_logs"
            ( Data.ProtoLens.MessageField Data.ProtoLens.MessageType
                :: Data.ProtoLens.FieldTypeDescriptor Proto.Opentelemetry.Proto.Logs.V1.Logs.ResourceLogs
            )
            ( Data.ProtoLens.RepeatedField
                Data.ProtoLens.Unpacked
                (Data.ProtoLens.Field.field @"resourceLogs")
            )
            :: Data.ProtoLens.FieldDescriptor ExportLogsServiceRequest
     in Data.Map.fromList
          [(Data.ProtoLens.Tag 1, resourceLogs__field_descriptor)]
  unknownFields =
    Lens.Family2.Unchecked.lens
      _ExportLogsServiceRequest'_unknownFields
      (\x__ y__ -> x__ {_ExportLogsServiceRequest'_unknownFields = y__})
  defMessage =
    ExportLogsServiceRequest'_constructor
      { _ExportLogsServiceRequest'resourceLogs = Data.Vector.Generic.empty
      , _ExportLogsServiceRequest'_unknownFields = []
      }
  parseMessage =
    let loop
          :: ExportLogsServiceRequest
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Proto.Opentelemetry.Proto.Logs.V1.Logs.ResourceLogs
          -> Data.ProtoLens.Encoding.Bytes.Parser ExportLogsServiceRequest
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
          "ExportLogsServiceRequest"
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


instance Control.DeepSeq.NFData ExportLogsServiceRequest where
  rnf =
    \x__ ->
      Control.DeepSeq.deepseq
        (_ExportLogsServiceRequest'_unknownFields x__)
        ( Control.DeepSeq.deepseq
            (_ExportLogsServiceRequest'resourceLogs x__)
            ()
        )


-- | Fields :
data ExportLogsServiceResponse = ExportLogsServiceResponse'_constructor {_ExportLogsServiceResponse'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)


instance Prelude.Show ExportLogsServiceResponse where
  showsPrec _ __x __s =
    Prelude.showChar
      '{'
      ( Prelude.showString
          (Data.ProtoLens.showMessageShort __x)
          (Prelude.showChar '}' __s)
      )


instance Data.ProtoLens.Message ExportLogsServiceResponse where
  messageName _ =
    Data.Text.pack
      "opentelemetry.proto.collector.logs.v1.ExportLogsServiceResponse"
  packedMessageDescriptor _ =
    "\n\
    \\EMExportLogsServiceResponse"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag = let in Data.Map.fromList []
  unknownFields =
    Lens.Family2.Unchecked.lens
      _ExportLogsServiceResponse'_unknownFields
      ( \x__ y__ ->
          x__ {_ExportLogsServiceResponse'_unknownFields = y__}
      )
  defMessage =
    ExportLogsServiceResponse'_constructor
      { _ExportLogsServiceResponse'_unknownFields = []
      }
  parseMessage =
    let loop
          :: ExportLogsServiceResponse
          -> Data.ProtoLens.Encoding.Bytes.Parser ExportLogsServiceResponse
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
          "ExportLogsServiceResponse"
  buildMessage =
    \_x ->
      Data.ProtoLens.Encoding.Wire.buildFieldSet
        (Lens.Family2.view Data.ProtoLens.unknownFields _x)


instance Control.DeepSeq.NFData ExportLogsServiceResponse where
  rnf =
    \x__ ->
      Control.DeepSeq.deepseq
        (_ExportLogsServiceResponse'_unknownFields x__)
        ()


data LogsService = LogsService {}


instance Data.ProtoLens.Service.Types.Service LogsService where
  type ServiceName LogsService = "LogsService"
  type ServicePackage LogsService = "opentelemetry.proto.collector.logs.v1"
  type ServiceMethods LogsService = '["export"]
  packedServiceDescriptor _ =
    "\n\
    \\vLogsService\DC2\141\SOH\n\
    \\ACKExport\DC2?.opentelemetry.proto.collector.logs.v1.ExportLogsServiceRequest\SUB@.opentelemetry.proto.collector.logs.v1.ExportLogsServiceResponse\"\NUL"


instance Data.ProtoLens.Service.Types.HasMethodImpl LogsService "export" where
  type MethodName LogsService "export" = "Export"
  type MethodInput LogsService "export" = ExportLogsServiceRequest
  type MethodOutput LogsService "export" = ExportLogsServiceResponse
  type MethodStreamingType LogsService "export" = 'Data.ProtoLens.Service.Types.NonStreaming


packedFileDescriptor :: Data.ByteString.ByteString
packedFileDescriptor =
  "\n\
  \8opentelemetry/proto/collector/logs/v1/logs_service.proto\DC2%opentelemetry.proto.collector.logs.v1\SUB&opentelemetry/proto/logs/v1/logs.proto\"j\n\
  \\CANExportLogsServiceRequest\DC2N\n\
  \\rresource_logs\CAN\SOH \ETX(\v2).opentelemetry.proto.logs.v1.ResourceLogsR\fresourceLogs\"\ESC\n\
  \\EMExportLogsServiceResponse2\157\SOH\n\
  \\vLogsService\DC2\141\SOH\n\
  \\ACKExport\DC2?.opentelemetry.proto.collector.logs.v1.ExportLogsServiceRequest\SUB@.opentelemetry.proto.collector.logs.v1.ExportLogsServiceResponse\"\NULB\134\SOH\n\
  \(io.opentelemetry.proto.collector.logs.v1B\DLELogsServiceProtoP\SOHZFgithub.com/open-telemetry/opentelemetry-proto/gen/go/collector/logs/v1J\144\r\n\
  \\ACK\DC2\EOT\SO\NUL/\SOH\n\
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
  \y\n\
  \\SOH\STX\DC2\ETX\DC3\NUL.2o NOTE: This proto is experimental and is subject to change at this point.\n\
  \ Please do not use it at the moment.\n\
  \\n\
  \\t\n\
  \\STX\ETX\NUL\DC2\ETX\NAK\NUL0\n\
  \\b\n\
  \\SOH\b\DC2\ETX\ETB\NUL\"\n\
  \\t\n\
  \\STX\b\n\
  \\DC2\ETX\ETB\NUL\"\n\
  \\b\n\
  \\SOH\b\DC2\ETX\CAN\NULA\n\
  \\t\n\
  \\STX\b\SOH\DC2\ETX\CAN\NULA\n\
  \\b\n\
  \\SOH\b\DC2\ETX\EM\NUL1\n\
  \\t\n\
  \\STX\b\b\DC2\ETX\EM\NUL1\n\
  \\b\n\
  \\SOH\b\DC2\ETX\SUB\NUL]\n\
  \\t\n\
  \\STX\b\v\DC2\ETX\SUB\NUL]\n\
  \\245\SOH\n\
  \\STX\ACK\NUL\DC2\EOT\US\NUL#\SOH\SUB\232\SOH Service that can be used to push logs between one Application instrumented with\n\
  \ OpenTelemetry and an collector, or between an collector and a central collector (in this\n\
  \ case logs are sent/received to/from multiple Applications).\n\
  \\n\
  \\n\
  \\n\
  \\ETX\ACK\NUL\SOH\DC2\ETX\US\b\DC3\n\
  \y\n\
  \\EOT\ACK\NUL\STX\NUL\DC2\ETX\"\STXM\SUBl For performance reasons, it is recommended to keep this RPC\n\
  \ alive for the entire life of the application.\n\
  \\n\
  \\f\n\
  \\ENQ\ACK\NUL\STX\NUL\SOH\DC2\ETX\"\ACK\f\n\
  \\f\n\
  \\ENQ\ACK\NUL\STX\NUL\STX\DC2\ETX\"\r%\n\
  \\f\n\
  \\ENQ\ACK\NUL\STX\NUL\ETX\DC2\ETX\"0I\n\
  \\n\
  \\n\
  \\STX\EOT\NUL\DC2\EOT%\NUL,\SOH\n\
  \\n\
  \\n\
  \\ETX\EOT\NUL\SOH\DC2\ETX%\b \n\
  \\207\STX\n\
  \\EOT\EOT\NUL\STX\NUL\DC2\ETX+\STXF\SUB\193\STX An array of ResourceLogs.\n\
  \ For data coming from a single resource this array will typically contain one\n\
  \ element. Intermediary nodes (such as OpenTelemetry Collector) that receive\n\
  \ data from multiple origins typically batch the data before forwarding further and\n\
  \ in that case this array will contain multiple elements.\n\
  \\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\NUL\EOT\DC2\ETX+\STX\n\
  \\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\NUL\ACK\DC2\ETX+\v3\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\NUL\SOH\DC2\ETX+4A\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\NUL\ETX\DC2\ETX+DE\n\
  \\n\
  \\n\
  \\STX\EOT\SOH\DC2\EOT.\NUL/\SOH\n\
  \\n\
  \\n\
  \\ETX\EOT\SOH\SOH\DC2\ETX.\b!b\ACKproto3"
