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

module Proto.Opentelemetry.Proto.Collector.Metrics.V1.MetricsService_Fields where

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
import qualified Proto.Opentelemetry.Proto.Metrics.V1.Metrics


resourceMetrics
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "resourceMetrics" a
     )
  => Lens.Family2.LensLike' f s a
resourceMetrics = Data.ProtoLens.Field.field @"resourceMetrics"


vec'resourceMetrics
  :: forall f s a
   . ( Prelude.Functor f
     , Data.ProtoLens.Field.HasField s "vec'resourceMetrics" a
     )
  => Lens.Family2.LensLike' f s a
vec'resourceMetrics =
  Data.ProtoLens.Field.field @"vec'resourceMetrics"
