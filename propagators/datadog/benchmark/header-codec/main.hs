{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -Wno-orphans #-}

import Control.DeepSeq (NFData)
import qualified Criterion.Main as C
import qualified Data.ByteString as B
import qualified Data.ByteString.Short as SB
import OpenTelemetry.Internal.Trace.Id (TraceId (..), bytesToTraceId)
import OpenTelemetry.Propagator.Datadog.Internal
import qualified String


mkTid :: [Word] -> TraceId
mkTid bs = case bytesToTraceId (B.pack (map fromIntegral bs)) of
  Right t -> t
  Left _ -> error "bad trace id"


main :: IO ()
main =
  C.defaultMain
    [ C.bgroup
        "newTraceIdFromHeader"
        [ C.bench "new" $ C.nf newTraceIdFromHeader "1"
        , C.bench "old" $ C.nf String.newTraceIdFromHeader "1"
        ]
    , C.bgroup "newHeaderFromTraceId" $
        let bytes = [0, 1, 2, 3, 4, 5, 6, 7, 8, 8, 10, 11, 12, 13, 14, 15]
            newValue = mkTid bytes
            oldValue = SB.pack (map fromIntegral bytes)
        in [ C.bench "new" $ C.nf newHeaderFromTraceId newValue
           , C.bench "old" $ C.nf String.newHeaderFromTraceId oldValue
           ]
    ]


instance NFData TraceId
