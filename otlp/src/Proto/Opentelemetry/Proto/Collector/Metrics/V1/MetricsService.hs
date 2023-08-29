{- This file was auto-generated from opentelemetry/proto/collector/metrics/v1/metrics_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE BangPatterns #-}
{- This file was auto-generated from opentelemetry/proto/collector/metrics/v1/metrics_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE DataKinds #-}
{- This file was auto-generated from opentelemetry/proto/collector/metrics/v1/metrics_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE DerivingStrategies #-}
{- This file was auto-generated from opentelemetry/proto/collector/metrics/v1/metrics_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE FlexibleContexts #-}
{- This file was auto-generated from opentelemetry/proto/collector/metrics/v1/metrics_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE FlexibleInstances #-}
{- This file was auto-generated from opentelemetry/proto/collector/metrics/v1/metrics_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{- This file was auto-generated from opentelemetry/proto/collector/metrics/v1/metrics_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE MagicHash #-}
{- This file was auto-generated from opentelemetry/proto/collector/metrics/v1/metrics_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE MultiParamTypeClasses #-}
{- This file was auto-generated from opentelemetry/proto/collector/metrics/v1/metrics_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE OverloadedStrings #-}
{- This file was auto-generated from opentelemetry/proto/collector/metrics/v1/metrics_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE PatternSynonyms #-}
{- This file was auto-generated from opentelemetry/proto/collector/metrics/v1/metrics_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE ScopedTypeVariables #-}
{- This file was auto-generated from opentelemetry/proto/collector/metrics/v1/metrics_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE TypeApplications #-}
{- This file was auto-generated from opentelemetry/proto/collector/metrics/v1/metrics_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE TypeFamilies #-}
{- This file was auto-generated from opentelemetry/proto/collector/metrics/v1/metrics_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE UndecidableInstances #-}
{- This file was auto-generated from opentelemetry/proto/collector/metrics/v1/metrics_service.proto by the proto-lens-protoc program. -}
{-# LANGUAGE NoImplicitPrelude #-}
{-# OPTIONS_GHC -Wno-dodgy-exports #-}
{-# OPTIONS_GHC -Wno-duplicate-exports #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Proto.Opentelemetry.Proto.Collector.Metrics.V1.MetricsService (
  MetricsService (..),
  ExportMetricsServiceRequest (),
  ExportMetricsServiceResponse (),
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
import qualified Proto.Opentelemetry.Proto.Metrics.V1.Metrics


{- | Fields :

         * 'Proto.Opentelemetry.Proto.Collector.Metrics.V1.MetricsService_Fields.resourceMetrics' @:: Lens' ExportMetricsServiceRequest [Proto.Opentelemetry.Proto.Metrics.V1.Metrics.ResourceMetrics]@
         * 'Proto.Opentelemetry.Proto.Collector.Metrics.V1.MetricsService_Fields.vec'resourceMetrics' @:: Lens' ExportMetricsServiceRequest (Data.Vector.Vector Proto.Opentelemetry.Proto.Metrics.V1.Metrics.ResourceMetrics)@
-}
data ExportMetricsServiceRequest = ExportMetricsServiceRequest'_constructor
  { _ExportMetricsServiceRequest'resourceMetrics :: !(Data.Vector.Vector Proto.Opentelemetry.Proto.Metrics.V1.Metrics.ResourceMetrics)
  , _ExportMetricsServiceRequest'_unknownFields :: !Data.ProtoLens.FieldSet
  }
  deriving stock (Prelude.Eq, Prelude.Ord)


instance Prelude.Show ExportMetricsServiceRequest where
  showsPrec _ __x __s =
    Prelude.showChar
      '{'
      ( Prelude.showString
          (Data.ProtoLens.showMessageShort __x)
          (Prelude.showChar '}' __s)
      )


instance Data.ProtoLens.Field.HasField ExportMetricsServiceRequest "resourceMetrics" [Proto.Opentelemetry.Proto.Metrics.V1.Metrics.ResourceMetrics] where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _ExportMetricsServiceRequest'resourceMetrics
          ( \x__ y__ ->
              x__ {_ExportMetricsServiceRequest'resourceMetrics = y__}
          )
      )
      ( Lens.Family2.Unchecked.lens
          Data.Vector.Generic.toList
          (\_ y__ -> Data.Vector.Generic.fromList y__)
      )


instance Data.ProtoLens.Field.HasField ExportMetricsServiceRequest "vec'resourceMetrics" (Data.Vector.Vector Proto.Opentelemetry.Proto.Metrics.V1.Metrics.ResourceMetrics) where
  fieldOf _ =
    (Prelude..)
      ( Lens.Family2.Unchecked.lens
          _ExportMetricsServiceRequest'resourceMetrics
          ( \x__ y__ ->
              x__ {_ExportMetricsServiceRequest'resourceMetrics = y__}
          )
      )
      Prelude.id


instance Data.ProtoLens.Message ExportMetricsServiceRequest where
  messageName _ =
    Data.Text.pack
      "opentelemetry.proto.collector.metrics.v1.ExportMetricsServiceRequest"
  packedMessageDescriptor _ =
    "\n\
    \\ESCExportMetricsServiceRequest\DC2Z\n\
    \\DLEresource_metrics\CAN\SOH \ETX(\v2/.opentelemetry.proto.metrics.v1.ResourceMetricsR\SIresourceMetrics"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag =
    let resourceMetrics__field_descriptor =
          Data.ProtoLens.FieldDescriptor
            "resource_metrics"
            ( Data.ProtoLens.MessageField Data.ProtoLens.MessageType
                :: Data.ProtoLens.FieldTypeDescriptor Proto.Opentelemetry.Proto.Metrics.V1.Metrics.ResourceMetrics
            )
            ( Data.ProtoLens.RepeatedField
                Data.ProtoLens.Unpacked
                (Data.ProtoLens.Field.field @"resourceMetrics")
            )
            :: Data.ProtoLens.FieldDescriptor ExportMetricsServiceRequest
     in Data.Map.fromList
          [(Data.ProtoLens.Tag 1, resourceMetrics__field_descriptor)]
  unknownFields =
    Lens.Family2.Unchecked.lens
      _ExportMetricsServiceRequest'_unknownFields
      ( \x__ y__ ->
          x__ {_ExportMetricsServiceRequest'_unknownFields = y__}
      )
  defMessage =
    ExportMetricsServiceRequest'_constructor
      { _ExportMetricsServiceRequest'resourceMetrics = Data.Vector.Generic.empty
      , _ExportMetricsServiceRequest'_unknownFields = []
      }
  parseMessage =
    let loop
          :: ExportMetricsServiceRequest
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Proto.Opentelemetry.Proto.Metrics.V1.Metrics.ResourceMetrics
          -> Data.ProtoLens.Encoding.Bytes.Parser ExportMetricsServiceRequest
        loop x mutable'resourceMetrics =
          do
            end <- Data.ProtoLens.Encoding.Bytes.atEnd
            if end
              then do
                frozen'resourceMetrics <-
                  Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                    ( Data.ProtoLens.Encoding.Growing.unsafeFreeze
                        mutable'resourceMetrics
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
                          (Data.ProtoLens.Field.field @"vec'resourceMetrics")
                          frozen'resourceMetrics
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
                          "resource_metrics"
                      v <-
                        Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                          ( Data.ProtoLens.Encoding.Growing.append
                              mutable'resourceMetrics
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
                        mutable'resourceMetrics
     in (Data.ProtoLens.Encoding.Bytes.<?>)
          ( do
              mutable'resourceMetrics <-
                Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                  Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'resourceMetrics
          )
          "ExportMetricsServiceRequest"
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
                (Data.ProtoLens.Field.field @"vec'resourceMetrics")
                _x
            )
        )
        ( Data.ProtoLens.Encoding.Wire.buildFieldSet
            (Lens.Family2.view Data.ProtoLens.unknownFields _x)
        )


instance Control.DeepSeq.NFData ExportMetricsServiceRequest where
  rnf =
    \x__ ->
      Control.DeepSeq.deepseq
        (_ExportMetricsServiceRequest'_unknownFields x__)
        ( Control.DeepSeq.deepseq
            (_ExportMetricsServiceRequest'resourceMetrics x__)
            ()
        )


-- | Fields :
data ExportMetricsServiceResponse = ExportMetricsServiceResponse'_constructor {_ExportMetricsServiceResponse'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord)


instance Prelude.Show ExportMetricsServiceResponse where
  showsPrec _ __x __s =
    Prelude.showChar
      '{'
      ( Prelude.showString
          (Data.ProtoLens.showMessageShort __x)
          (Prelude.showChar '}' __s)
      )


instance Data.ProtoLens.Message ExportMetricsServiceResponse where
  messageName _ =
    Data.Text.pack
      "opentelemetry.proto.collector.metrics.v1.ExportMetricsServiceResponse"
  packedMessageDescriptor _ =
    "\n\
    \\FSExportMetricsServiceResponse"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag = let in Data.Map.fromList []
  unknownFields =
    Lens.Family2.Unchecked.lens
      _ExportMetricsServiceResponse'_unknownFields
      ( \x__ y__ ->
          x__ {_ExportMetricsServiceResponse'_unknownFields = y__}
      )
  defMessage =
    ExportMetricsServiceResponse'_constructor
      { _ExportMetricsServiceResponse'_unknownFields = []
      }
  parseMessage =
    let loop
          :: ExportMetricsServiceResponse
          -> Data.ProtoLens.Encoding.Bytes.Parser ExportMetricsServiceResponse
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
          "ExportMetricsServiceResponse"
  buildMessage =
    \_x ->
      Data.ProtoLens.Encoding.Wire.buildFieldSet
        (Lens.Family2.view Data.ProtoLens.unknownFields _x)


instance Control.DeepSeq.NFData ExportMetricsServiceResponse where
  rnf =
    \x__ ->
      Control.DeepSeq.deepseq
        (_ExportMetricsServiceResponse'_unknownFields x__)
        ()


data MetricsService = MetricsService {}


instance Data.ProtoLens.Service.Types.Service MetricsService where
  type ServiceName MetricsService = "MetricsService"
  type ServicePackage MetricsService = "opentelemetry.proto.collector.metrics.v1"
  type ServiceMethods MetricsService = '["export"]
  packedServiceDescriptor _ =
    "\n\
    \\SOMetricsService\DC2\153\SOH\n\
    \\ACKExport\DC2E.opentelemetry.proto.collector.metrics.v1.ExportMetricsServiceRequest\SUBF.opentelemetry.proto.collector.metrics.v1.ExportMetricsServiceResponse\"\NUL"


instance Data.ProtoLens.Service.Types.HasMethodImpl MetricsService "export" where
  type MethodName MetricsService "export" = "Export"
  type MethodInput MetricsService "export" = ExportMetricsServiceRequest
  type MethodOutput MetricsService "export" = ExportMetricsServiceResponse
  type MethodStreamingType MetricsService "export" = 'Data.ProtoLens.Service.Types.NonStreaming


packedFileDescriptor :: Data.ByteString.ByteString
packedFileDescriptor =
  "\n\
  \>opentelemetry/proto/collector/metrics/v1/metrics_service.proto\DC2(opentelemetry.proto.collector.metrics.v1\SUB,opentelemetry/proto/metrics/v1/metrics.proto\"y\n\
  \\ESCExportMetricsServiceRequest\DC2Z\n\
  \\DLEresource_metrics\CAN\SOH \ETX(\v2/.opentelemetry.proto.metrics.v1.ResourceMetricsR\SIresourceMetrics\"\RS\n\
  \\FSExportMetricsServiceResponse2\172\SOH\n\
  \\SOMetricsService\DC2\153\SOH\n\
  \\ACKExport\DC2E.opentelemetry.proto.collector.metrics.v1.ExportMetricsServiceRequest\SUBF.opentelemetry.proto.collector.metrics.v1.ExportMetricsServiceResponse\"\NULB\143\SOH\n\
  \+io.opentelemetry.proto.collector.metrics.v1B\DC3MetricsServiceProtoP\SOHZIgithub.com/open-telemetry/opentelemetry-proto/gen/go/collector/metrics/v1J\223\v\n\
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
  \\SOH\STX\DC2\ETX\DLE\NUL1\n\
  \\t\n\
  \\STX\ETX\NUL\DC2\ETX\DC2\NUL6\n\
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
  \\SOH\b\DC2\ETX\SYN\NUL4\n\
  \\t\n\
  \\STX\b\b\DC2\ETX\SYN\NUL4\n\
  \\b\n\
  \\SOH\b\DC2\ETX\ETB\NUL`\n\
  \\t\n\
  \\STX\b\v\DC2\ETX\ETB\NUL`\n\
  \\178\SOH\n\
  \\STX\ACK\NUL\DC2\EOT\FS\NUL \SOH\SUB\165\SOH Service that can be used to push metrics between one Application\n\
  \ instrumented with OpenTelemetry and a collector, or between a collector and a\n\
  \ central collector.\n\
  \\n\
  \\n\
  \\n\
  \\ETX\ACK\NUL\SOH\DC2\ETX\FS\b\SYN\n\
  \y\n\
  \\EOT\ACK\NUL\STX\NUL\DC2\ETX\US\STXS\SUBl For performance reasons, it is recommended to keep this RPC\n\
  \ alive for the entire life of the application.\n\
  \\n\
  \\f\n\
  \\ENQ\ACK\NUL\STX\NUL\SOH\DC2\ETX\US\ACK\f\n\
  \\f\n\
  \\ENQ\ACK\NUL\STX\NUL\STX\DC2\ETX\US\r(\n\
  \\f\n\
  \\ENQ\ACK\NUL\STX\NUL\ETX\DC2\ETX\US3O\n\
  \\n\
  \\n\
  \\STX\EOT\NUL\DC2\EOT\"\NUL)\SOH\n\
  \\n\
  \\n\
  \\ETX\EOT\NUL\SOH\DC2\ETX\"\b#\n\
  \\210\STX\n\
  \\EOT\EOT\NUL\STX\NUL\DC2\ETX(\STXO\SUB\196\STX An array of ResourceMetrics.\n\
  \ For data coming from a single resource this array will typically contain one\n\
  \ element. Intermediary nodes (such as OpenTelemetry Collector) that receive\n\
  \ data from multiple origins typically batch the data before forwarding further and\n\
  \ in that case this array will contain multiple elements.\n\
  \\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\NUL\EOT\DC2\ETX(\STX\n\
  \\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\NUL\ACK\DC2\ETX(\v9\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\NUL\SOH\DC2\ETX(:J\n\
  \\f\n\
  \\ENQ\EOT\NUL\STX\NUL\ETX\DC2\ETX(MN\n\
  \\n\
  \\n\
  \\STX\EOT\SOH\DC2\EOT+\NUL,\SOH\n\
  \\n\
  \\n\
  \\ETX\EOT\SOH\SOH\DC2\ETX+\b$b\ACKproto3"
