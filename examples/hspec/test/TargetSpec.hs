module TargetSpec where

import Test.Hspec
import TestTarget


spec = describe "adds two" $ do
  it "adds 2 to 2" $ do
    addTwo 2 `shouldBe` 4
