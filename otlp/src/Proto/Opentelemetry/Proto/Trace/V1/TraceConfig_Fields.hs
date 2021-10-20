{- This file was auto-generated from opentelemetry/proto/trace/v1/trace_config.proto by the proto-lens-protoc program. -}
{-# LANGUAGE ScopedTypeVariables, DataKinds, TypeFamilies, UndecidableInstances, GeneralizedNewtypeDeriving, MultiParamTypeClasses, FlexibleContexts, FlexibleInstances, PatternSynonyms, MagicHash, NoImplicitPrelude, DataKinds, BangPatterns, TypeApplications, OverloadedStrings, DerivingStrategies#-}
{-# OPTIONS_GHC -Wno-unused-imports#-}
{-# OPTIONS_GHC -Wno-duplicate-exports#-}
{-# OPTIONS_GHC -Wno-dodgy-exports#-}
module Proto.Opentelemetry.Proto.Trace.V1.TraceConfig_Fields where
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
constantSampler ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "constantSampler" a) =>
  Lens.Family2.LensLike' f s a
constantSampler = Data.ProtoLens.Field.field @"constantSampler"
decision ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "decision" a) =>
  Lens.Family2.LensLike' f s a
decision = Data.ProtoLens.Field.field @"decision"
maxNumberOfAttributes ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maxNumberOfAttributes" a) =>
  Lens.Family2.LensLike' f s a
maxNumberOfAttributes
  = Data.ProtoLens.Field.field @"maxNumberOfAttributes"
maxNumberOfAttributesPerLink ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maxNumberOfAttributesPerLink" a) =>
  Lens.Family2.LensLike' f s a
maxNumberOfAttributesPerLink
  = Data.ProtoLens.Field.field @"maxNumberOfAttributesPerLink"
maxNumberOfAttributesPerTimedEvent ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maxNumberOfAttributesPerTimedEvent" a) =>
  Lens.Family2.LensLike' f s a
maxNumberOfAttributesPerTimedEvent
  = Data.ProtoLens.Field.field @"maxNumberOfAttributesPerTimedEvent"
maxNumberOfLinks ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maxNumberOfLinks" a) =>
  Lens.Family2.LensLike' f s a
maxNumberOfLinks = Data.ProtoLens.Field.field @"maxNumberOfLinks"
maxNumberOfTimedEvents ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maxNumberOfTimedEvents" a) =>
  Lens.Family2.LensLike' f s a
maxNumberOfTimedEvents
  = Data.ProtoLens.Field.field @"maxNumberOfTimedEvents"
maybe'constantSampler ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'constantSampler" a) =>
  Lens.Family2.LensLike' f s a
maybe'constantSampler
  = Data.ProtoLens.Field.field @"maybe'constantSampler"
maybe'rateLimitingSampler ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'rateLimitingSampler" a) =>
  Lens.Family2.LensLike' f s a
maybe'rateLimitingSampler
  = Data.ProtoLens.Field.field @"maybe'rateLimitingSampler"
maybe'sampler ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'sampler" a) =>
  Lens.Family2.LensLike' f s a
maybe'sampler = Data.ProtoLens.Field.field @"maybe'sampler"
maybe'traceIdRatioBased ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'traceIdRatioBased" a) =>
  Lens.Family2.LensLike' f s a
maybe'traceIdRatioBased
  = Data.ProtoLens.Field.field @"maybe'traceIdRatioBased"
qps ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "qps" a) =>
  Lens.Family2.LensLike' f s a
qps = Data.ProtoLens.Field.field @"qps"
rateLimitingSampler ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "rateLimitingSampler" a) =>
  Lens.Family2.LensLike' f s a
rateLimitingSampler
  = Data.ProtoLens.Field.field @"rateLimitingSampler"
samplingRatio ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "samplingRatio" a) =>
  Lens.Family2.LensLike' f s a
samplingRatio = Data.ProtoLens.Field.field @"samplingRatio"
traceIdRatioBased ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "traceIdRatioBased" a) =>
  Lens.Family2.LensLike' f s a
traceIdRatioBased = Data.ProtoLens.Field.field @"traceIdRatioBased"