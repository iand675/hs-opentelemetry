{- This file was auto-generated from opentelemetry/proto/trace/v1/trace.proto by the proto-lens-protoc program. -}
{-# LANGUAGE BangPatterns #-}
{- This file was auto-generated from opentelemetry/proto/trace/v1/trace.proto by the proto-lens-protoc program. -}
{-# LANGUAGE DataKinds #-}
{- This file was auto-generated from opentelemetry/proto/trace/v1/trace.proto by the proto-lens-protoc program. -}
{-# LANGUAGE DerivingStrategies #-}
{- This file was auto-generated from opentelemetry/proto/trace/v1/trace.proto by the proto-lens-protoc program. -}
{-# LANGUAGE FlexibleContexts #-}
{- This file was auto-generated from opentelemetry/proto/trace/v1/trace.proto by the proto-lens-protoc program. -}
{-# LANGUAGE FlexibleInstances #-}
{- This file was auto-generated from opentelemetry/proto/trace/v1/trace.proto by the proto-lens-protoc program. -}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{- This file was auto-generated from opentelemetry/proto/trace/v1/trace.proto by the proto-lens-protoc program. -}
{-# LANGUAGE MagicHash #-}
{- This file was auto-generated from opentelemetry/proto/trace/v1/trace.proto by the proto-lens-protoc program. -}
{-# LANGUAGE MultiParamTypeClasses #-}
{- This file was auto-generated from opentelemetry/proto/trace/v1/trace.proto by the proto-lens-protoc program. -}
{-# LANGUAGE OverloadedStrings #-}
{- This file was auto-generated from opentelemetry/proto/trace/v1/trace.proto by the proto-lens-protoc program. -}
{-# LANGUAGE PatternSynonyms #-}
{- This file was auto-generated from opentelemetry/proto/trace/v1/trace.proto by the proto-lens-protoc program. -}
{-# LANGUAGE ScopedTypeVariables #-}
{- This file was auto-generated from opentelemetry/proto/trace/v1/trace.proto by the proto-lens-protoc program. -}
{-# LANGUAGE TypeApplications #-}
{- This file was auto-generated from opentelemetry/proto/trace/v1/trace.proto by the proto-lens-protoc program. -}
{-# LANGUAGE TypeFamilies #-}
{- This file was auto-generated from opentelemetry/proto/trace/v1/trace.proto by the proto-lens-protoc program. -}
{-# LANGUAGE UndecidableInstances #-}
{- This file was auto-generated from opentelemetry/proto/trace/v1/trace.proto by the proto-lens-protoc program. -}
{-# LANGUAGE NoImplicitPrelude #-}
{-# OPTIONS_GHC -Wno-dodgy-exports #-}
{-# OPTIONS_GHC -Wno-duplicate-exports #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module Proto.Opentelemetry.Proto.Trace.V1.Trace_Fields where

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
import qualified Proto.Opentelemetry.Proto.Common.V1.Common
import qualified Proto.Opentelemetry.Proto.Resource.V1.Resource


attributes
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "attributes" a
     )
  => Lens.Family2.LensLike' f s a
attributes = Data.ProtoLens.Field.field @"attributes"


code
  :: forall f s a
   . (Prelude.Functor f, Data.ProtoLens.Field.HasField s "code" a)
  => Lens.Family2.LensLike' f s a
code = Data.ProtoLens.Field.field @"code"


deprecatedCode
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "deprecatedCode" a
     )
  => Lens.Family2.LensLike' f s a
deprecatedCode = Data.ProtoLens.Field.field @"deprecatedCode"


droppedAttributesCount
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "droppedAttributesCount" a
     )
  => Lens.Family2.LensLike' f s a
droppedAttributesCount =
  Data.ProtoLens.Field.field @"droppedAttributesCount"


droppedEventsCount
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "droppedEventsCount" a
     )
  => Lens.Family2.LensLike' f s a
droppedEventsCount =
  Data.ProtoLens.Field.field @"droppedEventsCount"


droppedLinksCount
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "droppedLinksCount" a
     )
  => Lens.Family2.LensLike' f s a
droppedLinksCount = Data.ProtoLens.Field.field @"droppedLinksCount"


endTimeUnixNano
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "endTimeUnixNano" a
     )
  => Lens.Family2.LensLike' f s a
endTimeUnixNano = Data.ProtoLens.Field.field @"endTimeUnixNano"


events
  :: forall f s a
   . (Prelude.Functor f, Data.ProtoLens.Field.HasField s "events" a)
  => Lens.Family2.LensLike' f s a
events = Data.ProtoLens.Field.field @"events"


instrumentationLibrary
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "instrumentationLibrary" a
     )
  => Lens.Family2.LensLike' f s a
instrumentationLibrary =
  Data.ProtoLens.Field.field @"instrumentationLibrary"


instrumentationLibrarySpans
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "instrumentationLibrarySpans" a
     )
  => Lens.Family2.LensLike' f s a
instrumentationLibrarySpans =
  Data.ProtoLens.Field.field @"instrumentationLibrarySpans"


kind
  :: forall f s a
   . (Prelude.Functor f, Data.ProtoLens.Field.HasField s "kind" a)
  => Lens.Family2.LensLike' f s a
kind = Data.ProtoLens.Field.field @"kind"


links
  :: forall f s a
   . (Prelude.Functor f, Data.ProtoLens.Field.HasField s "links" a)
  => Lens.Family2.LensLike' f s a
links = Data.ProtoLens.Field.field @"links"


maybe'instrumentationLibrary
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "maybe'instrumentationLibrary" a
     )
  => Lens.Family2.LensLike' f s a
maybe'instrumentationLibrary =
  Data.ProtoLens.Field.field @"maybe'instrumentationLibrary"


maybe'resource
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "maybe'resource" a
     )
  => Lens.Family2.LensLike' f s a
maybe'resource = Data.ProtoLens.Field.field @"maybe'resource"


maybe'status
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "maybe'status" a
     )
  => Lens.Family2.LensLike' f s a
maybe'status = Data.ProtoLens.Field.field @"maybe'status"


message
  :: forall f s a
   . (Prelude.Functor f, Data.ProtoLens.Field.HasField s "message" a)
  => Lens.Family2.LensLike' f s a
message = Data.ProtoLens.Field.field @"message"


name
  :: forall f s a
   . (Prelude.Functor f, Data.ProtoLens.Field.HasField s "name" a)
  => Lens.Family2.LensLike' f s a
name = Data.ProtoLens.Field.field @"name"


parentSpanId
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "parentSpanId" a
     )
  => Lens.Family2.LensLike' f s a
parentSpanId = Data.ProtoLens.Field.field @"parentSpanId"


resource
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "resource" a
     )
  => Lens.Family2.LensLike' f s a
resource = Data.ProtoLens.Field.field @"resource"


resourceSpans
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "resourceSpans" a
     )
  => Lens.Family2.LensLike' f s a
resourceSpans = Data.ProtoLens.Field.field @"resourceSpans"


schemaUrl
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "schemaUrl" a
     )
  => Lens.Family2.LensLike' f s a
schemaUrl = Data.ProtoLens.Field.field @"schemaUrl"


spanId
  :: forall f s a
   . (Prelude.Functor f, Data.ProtoLens.Field.HasField s "spanId" a)
  => Lens.Family2.LensLike' f s a
spanId = Data.ProtoLens.Field.field @"spanId"


spans
  :: forall f s a
   . (Prelude.Functor f, Data.ProtoLens.Field.HasField s "spans" a)
  => Lens.Family2.LensLike' f s a
spans = Data.ProtoLens.Field.field @"spans"


startTimeUnixNano
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "startTimeUnixNano" a
     )
  => Lens.Family2.LensLike' f s a
startTimeUnixNano = Data.ProtoLens.Field.field @"startTimeUnixNano"


status
  :: forall f s a
   . (Prelude.Functor f, Data.ProtoLens.Field.HasField s "status" a)
  => Lens.Family2.LensLike' f s a
status = Data.ProtoLens.Field.field @"status"


timeUnixNano
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "timeUnixNano" a
     )
  => Lens.Family2.LensLike' f s a
timeUnixNano = Data.ProtoLens.Field.field @"timeUnixNano"


traceId
  :: forall f s a
   . (Prelude.Functor f, Data.ProtoLens.Field.HasField s "traceId" a)
  => Lens.Family2.LensLike' f s a
traceId = Data.ProtoLens.Field.field @"traceId"


traceState
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "traceState" a
     )
  => Lens.Family2.LensLike' f s a
traceState = Data.ProtoLens.Field.field @"traceState"


vec'attributes
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "vec'attributes" a
     )
  => Lens.Family2.LensLike' f s a
vec'attributes = Data.ProtoLens.Field.field @"vec'attributes"


vec'events
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "vec'events" a
     )
  => Lens.Family2.LensLike' f s a
vec'events = Data.ProtoLens.Field.field @"vec'events"


vec'instrumentationLibrarySpans
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "vec'instrumentationLibrarySpans" a
     )
  => Lens.Family2.LensLike' f s a
vec'instrumentationLibrarySpans =
  Data.ProtoLens.Field.field @"vec'instrumentationLibrarySpans"


vec'links
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "vec'links" a
     )
  => Lens.Family2.LensLike' f s a
vec'links = Data.ProtoLens.Field.field @"vec'links"


vec'resourceSpans
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "vec'resourceSpans" a
     )
  => Lens.Family2.LensLike' f s a
vec'resourceSpans = Data.ProtoLens.Field.field @"vec'resourceSpans"


vec'spans
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "vec'spans" a
     )
  => Lens.Family2.LensLike' f s a
vec'spans = Data.ProtoLens.Field.field @"vec'spans"
