{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -Wno-orphans #-}

import Control.DeepSeq (NFData)
import qualified Criterion.Main as C
import qualified Data.ByteString.Short as SB
import OpenTelemetry.Propagator.Datadog.Internal
import OpenTelemetry.Trace.Id (TraceId)
import qualified String


main :: IO ()
main =
  C.defaultMain
    [ C.bgroup
        "newTraceIdFromHeader"
        [ C.bench "new" $ C.nf newTraceIdFromHeader "1"
        , C.bench "old" $ C.nf String.newTraceIdFromHeader "1"
        ]
    , C.bgroup "newHeaderFromTraceId" $
        let value = SB.pack [0, 1, 2, 3, 4, 5, 6, 7, 8, 8, 10, 11, 12, 13, 14, 15]
        in [ C.bench "new" $ C.nf newHeaderFromTraceId value
           , C.bench "old" $ C.nf String.newHeaderFromTraceId value
           ]
    ]


instance NFData TraceId
