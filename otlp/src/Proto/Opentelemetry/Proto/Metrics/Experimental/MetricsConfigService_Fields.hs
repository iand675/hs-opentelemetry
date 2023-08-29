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

module Proto.Opentelemetry.Proto.Metrics.Experimental.MetricsConfigService_Fields where

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
import qualified Proto.Opentelemetry.Proto.Resource.V1.Resource


equals
  :: forall f s a
   . (Prelude.Functor f, Data.ProtoLens.Field.HasField s "equals" a)
  => Lens.Family2.LensLike' f s a
equals = Data.ProtoLens.Field.field @"equals"


exclusionPatterns
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "exclusionPatterns" a
     )
  => Lens.Family2.LensLike' f s a
exclusionPatterns = Data.ProtoLens.Field.field @"exclusionPatterns"


fingerprint
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "fingerprint" a
     )
  => Lens.Family2.LensLike' f s a
fingerprint = Data.ProtoLens.Field.field @"fingerprint"


inclusionPatterns
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "inclusionPatterns" a
     )
  => Lens.Family2.LensLike' f s a
inclusionPatterns = Data.ProtoLens.Field.field @"inclusionPatterns"


lastKnownFingerprint
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "lastKnownFingerprint" a
     )
  => Lens.Family2.LensLike' f s a
lastKnownFingerprint =
  Data.ProtoLens.Field.field @"lastKnownFingerprint"


maybe'equals
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "maybe'equals" a
     )
  => Lens.Family2.LensLike' f s a
maybe'equals = Data.ProtoLens.Field.field @"maybe'equals"


maybe'match
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "maybe'match" a
     )
  => Lens.Family2.LensLike' f s a
maybe'match = Data.ProtoLens.Field.field @"maybe'match"


maybe'resource
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "maybe'resource" a
     )
  => Lens.Family2.LensLike' f s a
maybe'resource = Data.ProtoLens.Field.field @"maybe'resource"


maybe'startsWith
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "maybe'startsWith" a
     )
  => Lens.Family2.LensLike' f s a
maybe'startsWith = Data.ProtoLens.Field.field @"maybe'startsWith"


periodSec
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "periodSec" a
     )
  => Lens.Family2.LensLike' f s a
periodSec = Data.ProtoLens.Field.field @"periodSec"


resource
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "resource" a
     )
  => Lens.Family2.LensLike' f s a
resource = Data.ProtoLens.Field.field @"resource"


schedules
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "schedules" a
     )
  => Lens.Family2.LensLike' f s a
schedules = Data.ProtoLens.Field.field @"schedules"


startsWith
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "startsWith" a
     )
  => Lens.Family2.LensLike' f s a
startsWith = Data.ProtoLens.Field.field @"startsWith"


suggestedWaitTimeSec
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "suggestedWaitTimeSec" a
     )
  => Lens.Family2.LensLike' f s a
suggestedWaitTimeSec =
  Data.ProtoLens.Field.field @"suggestedWaitTimeSec"


vec'exclusionPatterns
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "vec'exclusionPatterns" a
     )
  => Lens.Family2.LensLike' f s a
vec'exclusionPatterns =
  Data.ProtoLens.Field.field @"vec'exclusionPatterns"


vec'inclusionPatterns
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "vec'inclusionPatterns" a
     )
  => Lens.Family2.LensLike' f s a
vec'inclusionPatterns =
  Data.ProtoLens.Field.field @"vec'inclusionPatterns"


vec'schedules
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "vec'schedules" a
     )
  => Lens.Family2.LensLike' f s a
vec'schedules = Data.ProtoLens.Field.field @"vec'schedules"
