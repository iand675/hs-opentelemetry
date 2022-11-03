module Main where

import qualified Spec
import Test.Hspec
import Test.Hspec.Runner (defaultConfig, hspecWith)
import Prelude


-- FIXME(jadel): use the hs-opentelemetry-instrumentation-hspec example
main :: IO ()
main = do
  putStrLn "Begin tests"
  runTests


runTests :: IO ()
runTests = do
  hspecWith
    defaultConfig
    $ parallel Spec.spec
  putStrLn "Done"
