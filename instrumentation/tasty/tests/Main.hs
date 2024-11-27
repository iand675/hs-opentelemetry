{-# LANGUAGE ImportQualifiedPost #-}

module Main (main) where

import OpenTelemetry.Instrumentation.Tasty.Tests qualified
import Test.Tasty (TestTree, defaultMain, testGroup)


main :: IO ()
main = defaultMain tests


tests :: TestTree
tests =
  testGroup "Tasty instrumentation" $
    [OpenTelemetry.Instrumentation.Tasty.Tests.tests]
