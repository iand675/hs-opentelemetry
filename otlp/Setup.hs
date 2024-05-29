import Data.ProtoLens.Setup
import System.FilePath.Glob


main = do
  protoFiles <- glob "proto/**/*/*.proto"
  generateProtos "proto" "src" protoFiles
