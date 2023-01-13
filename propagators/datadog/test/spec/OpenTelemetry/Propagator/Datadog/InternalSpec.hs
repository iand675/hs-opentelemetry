{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE OverloadedStrings #-}

module OpenTelemetry.Propagator.Datadog.InternalSpec where

import qualified Data.ByteString.Char8 as BC
import Data.ByteString.Short (ShortByteString)
import qualified Data.ByteString.Short as SB
import Data.Word (Word64)
import Hexdump (simpleHex)
import OpenTelemetry.Propagator.Datadog.Internal
import qualified String
import Test.Hspec
import Test.QuickCheck


spec :: Spec
spec = do
  context "newTraceIdFromHeader" $ do
    it "is equal to the old implementation" $
      property $ \x -> do
        let x' = BC.pack $ show (x :: Word64)
        HexString (newTraceIdFromHeader x')
          `shouldBe` HexString (String.newTraceIdFromHeader x')

  context "newSpanIdFromHeader" $ do
    it "is equal to the old implementation" $
      property $ \x -> do
        let x' = BC.pack $ show (x :: Word64)
        HexString (newSpanIdFromHeader x')
          `shouldBe` HexString (String.newSpanIdFromHeader x')

  context "newHeaderFromTraceId" $ do
    it "is equal to the old implementation" $
      property $ \(x1, x2, x3, x4, x5, x6, x7, x8, x9, (x10, x11, x12, x13, x14, x15, x16)) -> do
        let x' = SB.pack [x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16]
        newHeaderFromTraceId x'
          `shouldBe` String.newHeaderFromTraceId x'

  context "newHeaderFromSpanId" $ do
    it "is equal to the old implementation" $
      property $ \(x1, x2, x3, x4, x5, x6, x7, x8) -> do
        let x' = SB.pack [x1, x2, x3, x4, x5, x6, x7, x8]
        newHeaderFromSpanId x'
          `shouldBe` String.newHeaderFromSpanId x'

  context "composition of newTraceIdFromHeader and newHeaderFromTraceId" $ do
    it "is identical" $
      property $ \(x1, x2, x3, x4, x5, x6, x7, x8) -> do
        let x' = SB.pack $ replicate 8 0 ++ [x1, x2, x3, x4, x5, x6, x7, x8]
        HexString (newTraceIdFromHeader $ newHeaderFromTraceId x') `shouldBe` HexString x'

  context "composition of newHeaderFromTraceId and newTraceIdFromHeader" $ do
    it "is identical" $
      property $ \x -> do
        let x' = BC.pack $ show (x :: Word64)
        newHeaderFromTraceId (newTraceIdFromHeader x') `shouldBe` x'

  context "composition of newSpanIdFromHeader and newHeaderFromSpanId" $ do
    it "is identical" $
      property $ \(x1, x2, x3, x4, x5, x6, x7, x8) -> do
        let x' = SB.pack [x1, x2, x3, x4, x5, x6, x7, x8]
        newSpanIdFromHeader (newHeaderFromSpanId x') `shouldBe` x'

  context "composition of newHeaderFromSpanId and newSpanIdFromHeader" $ do
    it "is identical" $
      property $ \x -> do
        let x' = BC.pack $ show (x :: Word64)
        newHeaderFromSpanId (newSpanIdFromHeader x') `shouldBe` x'


newtype HexString = HexString ShortByteString deriving (Eq)


instance Show HexString where
  show (HexString s) = simpleHex $ SB.fromShort s
