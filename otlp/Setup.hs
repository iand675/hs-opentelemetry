import Data.ProtoLens.Setup
import System.FilePath.Glob


main = defaultMainGeneratingProtos "proto"

-- protoFiles <- glob "proto/**/*/*.proto"
-- generateProtos "proto" "." protoFiles

-- defaultMainGeneratingProtos "proto"
