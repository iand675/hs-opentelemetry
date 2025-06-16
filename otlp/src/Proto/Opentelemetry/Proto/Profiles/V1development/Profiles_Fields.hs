{- HLINT ignore -}
{- This file was auto-generated from opentelemetry/proto/profiles/v1development/profiles.proto by the proto-lens-protoc program. -}
{-# LANGUAGE ScopedTypeVariables, DataKinds, TypeFamilies, UndecidableInstances, GeneralizedNewtypeDeriving, MultiParamTypeClasses, FlexibleContexts, FlexibleInstances, PatternSynonyms, MagicHash, NoImplicitPrelude, DataKinds, BangPatterns, TypeApplications, OverloadedStrings, DerivingStrategies#-}
{-# OPTIONS_GHC -Wno-unused-imports#-}
{-# OPTIONS_GHC -Wno-duplicate-exports#-}
{-# OPTIONS_GHC -Wno-dodgy-exports#-}
module Proto.Opentelemetry.Proto.Profiles.V1development.Profiles_Fields where
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
address ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "address" a) =>
  Lens.Family2.LensLike' f s a
address = Data.ProtoLens.Field.field @"address"
aggregationTemporality ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "aggregationTemporality" a) =>
  Lens.Family2.LensLike' f s a
aggregationTemporality
  = Data.ProtoLens.Field.field @"aggregationTemporality"
attributeIndices ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "attributeIndices" a) =>
  Lens.Family2.LensLike' f s a
attributeIndices = Data.ProtoLens.Field.field @"attributeIndices"
attributeKeyStrindex ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "attributeKeyStrindex" a) =>
  Lens.Family2.LensLike' f s a
attributeKeyStrindex
  = Data.ProtoLens.Field.field @"attributeKeyStrindex"
attributeTable ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "attributeTable" a) =>
  Lens.Family2.LensLike' f s a
attributeTable = Data.ProtoLens.Field.field @"attributeTable"
attributeUnits ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "attributeUnits" a) =>
  Lens.Family2.LensLike' f s a
attributeUnits = Data.ProtoLens.Field.field @"attributeUnits"
column ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "column" a) =>
  Lens.Family2.LensLike' f s a
column = Data.ProtoLens.Field.field @"column"
commentStrindices ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "commentStrindices" a) =>
  Lens.Family2.LensLike' f s a
commentStrindices = Data.ProtoLens.Field.field @"commentStrindices"
defaultSampleTypeIndex ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "defaultSampleTypeIndex" a) =>
  Lens.Family2.LensLike' f s a
defaultSampleTypeIndex
  = Data.ProtoLens.Field.field @"defaultSampleTypeIndex"
dictionary ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "dictionary" a) =>
  Lens.Family2.LensLike' f s a
dictionary = Data.ProtoLens.Field.field @"dictionary"
droppedAttributesCount ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "droppedAttributesCount" a) =>
  Lens.Family2.LensLike' f s a
droppedAttributesCount
  = Data.ProtoLens.Field.field @"droppedAttributesCount"
durationNanos ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "durationNanos" a) =>
  Lens.Family2.LensLike' f s a
durationNanos = Data.ProtoLens.Field.field @"durationNanos"
fileOffset ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "fileOffset" a) =>
  Lens.Family2.LensLike' f s a
fileOffset = Data.ProtoLens.Field.field @"fileOffset"
filenameStrindex ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "filenameStrindex" a) =>
  Lens.Family2.LensLike' f s a
filenameStrindex = Data.ProtoLens.Field.field @"filenameStrindex"
functionIndex ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "functionIndex" a) =>
  Lens.Family2.LensLike' f s a
functionIndex = Data.ProtoLens.Field.field @"functionIndex"
functionTable ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "functionTable" a) =>
  Lens.Family2.LensLike' f s a
functionTable = Data.ProtoLens.Field.field @"functionTable"
hasFilenames ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "hasFilenames" a) =>
  Lens.Family2.LensLike' f s a
hasFilenames = Data.ProtoLens.Field.field @"hasFilenames"
hasFunctions ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "hasFunctions" a) =>
  Lens.Family2.LensLike' f s a
hasFunctions = Data.ProtoLens.Field.field @"hasFunctions"
hasInlineFrames ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "hasInlineFrames" a) =>
  Lens.Family2.LensLike' f s a
hasInlineFrames = Data.ProtoLens.Field.field @"hasInlineFrames"
hasLineNumbers ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "hasLineNumbers" a) =>
  Lens.Family2.LensLike' f s a
hasLineNumbers = Data.ProtoLens.Field.field @"hasLineNumbers"
isFolded ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "isFolded" a) =>
  Lens.Family2.LensLike' f s a
isFolded = Data.ProtoLens.Field.field @"isFolded"
line ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "line" a) =>
  Lens.Family2.LensLike' f s a
line = Data.ProtoLens.Field.field @"line"
linkIndex ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "linkIndex" a) =>
  Lens.Family2.LensLike' f s a
linkIndex = Data.ProtoLens.Field.field @"linkIndex"
linkTable ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "linkTable" a) =>
  Lens.Family2.LensLike' f s a
linkTable = Data.ProtoLens.Field.field @"linkTable"
locationIndices ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "locationIndices" a) =>
  Lens.Family2.LensLike' f s a
locationIndices = Data.ProtoLens.Field.field @"locationIndices"
locationTable ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "locationTable" a) =>
  Lens.Family2.LensLike' f s a
locationTable = Data.ProtoLens.Field.field @"locationTable"
locationsLength ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "locationsLength" a) =>
  Lens.Family2.LensLike' f s a
locationsLength = Data.ProtoLens.Field.field @"locationsLength"
locationsStartIndex ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "locationsStartIndex" a) =>
  Lens.Family2.LensLike' f s a
locationsStartIndex
  = Data.ProtoLens.Field.field @"locationsStartIndex"
mappingIndex ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "mappingIndex" a) =>
  Lens.Family2.LensLike' f s a
mappingIndex = Data.ProtoLens.Field.field @"mappingIndex"
mappingTable ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "mappingTable" a) =>
  Lens.Family2.LensLike' f s a
mappingTable = Data.ProtoLens.Field.field @"mappingTable"
maybe'dictionary ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'dictionary" a) =>
  Lens.Family2.LensLike' f s a
maybe'dictionary = Data.ProtoLens.Field.field @"maybe'dictionary"
maybe'linkIndex ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'linkIndex" a) =>
  Lens.Family2.LensLike' f s a
maybe'linkIndex = Data.ProtoLens.Field.field @"maybe'linkIndex"
maybe'mappingIndex ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'mappingIndex" a) =>
  Lens.Family2.LensLike' f s a
maybe'mappingIndex
  = Data.ProtoLens.Field.field @"maybe'mappingIndex"
maybe'periodType ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'periodType" a) =>
  Lens.Family2.LensLike' f s a
maybe'periodType = Data.ProtoLens.Field.field @"maybe'periodType"
maybe'resource ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'resource" a) =>
  Lens.Family2.LensLike' f s a
maybe'resource = Data.ProtoLens.Field.field @"maybe'resource"
maybe'scope ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'scope" a) =>
  Lens.Family2.LensLike' f s a
maybe'scope = Data.ProtoLens.Field.field @"maybe'scope"
memoryLimit ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "memoryLimit" a) =>
  Lens.Family2.LensLike' f s a
memoryLimit = Data.ProtoLens.Field.field @"memoryLimit"
memoryStart ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "memoryStart" a) =>
  Lens.Family2.LensLike' f s a
memoryStart = Data.ProtoLens.Field.field @"memoryStart"
nameStrindex ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "nameStrindex" a) =>
  Lens.Family2.LensLike' f s a
nameStrindex = Data.ProtoLens.Field.field @"nameStrindex"
originalPayload ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "originalPayload" a) =>
  Lens.Family2.LensLike' f s a
originalPayload = Data.ProtoLens.Field.field @"originalPayload"
originalPayloadFormat ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "originalPayloadFormat" a) =>
  Lens.Family2.LensLike' f s a
originalPayloadFormat
  = Data.ProtoLens.Field.field @"originalPayloadFormat"
period ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "period" a) =>
  Lens.Family2.LensLike' f s a
period = Data.ProtoLens.Field.field @"period"
periodType ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "periodType" a) =>
  Lens.Family2.LensLike' f s a
periodType = Data.ProtoLens.Field.field @"periodType"
profileId ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "profileId" a) =>
  Lens.Family2.LensLike' f s a
profileId = Data.ProtoLens.Field.field @"profileId"
profiles ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "profiles" a) =>
  Lens.Family2.LensLike' f s a
profiles = Data.ProtoLens.Field.field @"profiles"
resource ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "resource" a) =>
  Lens.Family2.LensLike' f s a
resource = Data.ProtoLens.Field.field @"resource"
resourceProfiles ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "resourceProfiles" a) =>
  Lens.Family2.LensLike' f s a
resourceProfiles = Data.ProtoLens.Field.field @"resourceProfiles"
sample ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "sample" a) =>
  Lens.Family2.LensLike' f s a
sample = Data.ProtoLens.Field.field @"sample"
sampleType ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "sampleType" a) =>
  Lens.Family2.LensLike' f s a
sampleType = Data.ProtoLens.Field.field @"sampleType"
schemaUrl ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "schemaUrl" a) =>
  Lens.Family2.LensLike' f s a
schemaUrl = Data.ProtoLens.Field.field @"schemaUrl"
scope ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "scope" a) =>
  Lens.Family2.LensLike' f s a
scope = Data.ProtoLens.Field.field @"scope"
scopeProfiles ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "scopeProfiles" a) =>
  Lens.Family2.LensLike' f s a
scopeProfiles = Data.ProtoLens.Field.field @"scopeProfiles"
spanId ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "spanId" a) =>
  Lens.Family2.LensLike' f s a
spanId = Data.ProtoLens.Field.field @"spanId"
startLine ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "startLine" a) =>
  Lens.Family2.LensLike' f s a
startLine = Data.ProtoLens.Field.field @"startLine"
stringTable ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "stringTable" a) =>
  Lens.Family2.LensLike' f s a
stringTable = Data.ProtoLens.Field.field @"stringTable"
systemNameStrindex ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "systemNameStrindex" a) =>
  Lens.Family2.LensLike' f s a
systemNameStrindex
  = Data.ProtoLens.Field.field @"systemNameStrindex"
timeNanos ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "timeNanos" a) =>
  Lens.Family2.LensLike' f s a
timeNanos = Data.ProtoLens.Field.field @"timeNanos"
timestampsUnixNano ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "timestampsUnixNano" a) =>
  Lens.Family2.LensLike' f s a
timestampsUnixNano
  = Data.ProtoLens.Field.field @"timestampsUnixNano"
traceId ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "traceId" a) =>
  Lens.Family2.LensLike' f s a
traceId = Data.ProtoLens.Field.field @"traceId"
typeStrindex ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "typeStrindex" a) =>
  Lens.Family2.LensLike' f s a
typeStrindex = Data.ProtoLens.Field.field @"typeStrindex"
unitStrindex ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "unitStrindex" a) =>
  Lens.Family2.LensLike' f s a
unitStrindex = Data.ProtoLens.Field.field @"unitStrindex"
value ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "value" a) =>
  Lens.Family2.LensLike' f s a
value = Data.ProtoLens.Field.field @"value"
vec'attributeIndices ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "vec'attributeIndices" a) =>
  Lens.Family2.LensLike' f s a
vec'attributeIndices
  = Data.ProtoLens.Field.field @"vec'attributeIndices"
vec'attributeTable ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "vec'attributeTable" a) =>
  Lens.Family2.LensLike' f s a
vec'attributeTable
  = Data.ProtoLens.Field.field @"vec'attributeTable"
vec'attributeUnits ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "vec'attributeUnits" a) =>
  Lens.Family2.LensLike' f s a
vec'attributeUnits
  = Data.ProtoLens.Field.field @"vec'attributeUnits"
vec'commentStrindices ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "vec'commentStrindices" a) =>
  Lens.Family2.LensLike' f s a
vec'commentStrindices
  = Data.ProtoLens.Field.field @"vec'commentStrindices"
vec'functionTable ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "vec'functionTable" a) =>
  Lens.Family2.LensLike' f s a
vec'functionTable = Data.ProtoLens.Field.field @"vec'functionTable"
vec'line ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "vec'line" a) =>
  Lens.Family2.LensLike' f s a
vec'line = Data.ProtoLens.Field.field @"vec'line"
vec'linkTable ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "vec'linkTable" a) =>
  Lens.Family2.LensLike' f s a
vec'linkTable = Data.ProtoLens.Field.field @"vec'linkTable"
vec'locationIndices ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "vec'locationIndices" a) =>
  Lens.Family2.LensLike' f s a
vec'locationIndices
  = Data.ProtoLens.Field.field @"vec'locationIndices"
vec'locationTable ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "vec'locationTable" a) =>
  Lens.Family2.LensLike' f s a
vec'locationTable = Data.ProtoLens.Field.field @"vec'locationTable"
vec'mappingTable ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "vec'mappingTable" a) =>
  Lens.Family2.LensLike' f s a
vec'mappingTable = Data.ProtoLens.Field.field @"vec'mappingTable"
vec'profiles ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "vec'profiles" a) =>
  Lens.Family2.LensLike' f s a
vec'profiles = Data.ProtoLens.Field.field @"vec'profiles"
vec'resourceProfiles ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "vec'resourceProfiles" a) =>
  Lens.Family2.LensLike' f s a
vec'resourceProfiles
  = Data.ProtoLens.Field.field @"vec'resourceProfiles"
vec'sample ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "vec'sample" a) =>
  Lens.Family2.LensLike' f s a
vec'sample = Data.ProtoLens.Field.field @"vec'sample"
vec'sampleType ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "vec'sampleType" a) =>
  Lens.Family2.LensLike' f s a
vec'sampleType = Data.ProtoLens.Field.field @"vec'sampleType"
vec'scopeProfiles ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "vec'scopeProfiles" a) =>
  Lens.Family2.LensLike' f s a
vec'scopeProfiles = Data.ProtoLens.Field.field @"vec'scopeProfiles"
vec'stringTable ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "vec'stringTable" a) =>
  Lens.Family2.LensLike' f s a
vec'stringTable = Data.ProtoLens.Field.field @"vec'stringTable"
vec'timestampsUnixNano ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "vec'timestampsUnixNano" a) =>
  Lens.Family2.LensLike' f s a
vec'timestampsUnixNano
  = Data.ProtoLens.Field.field @"vec'timestampsUnixNano"
vec'value ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "vec'value" a) =>
  Lens.Family2.LensLike' f s a
vec'value = Data.ProtoLens.Field.field @"vec'value"