{-# LANGUAGE NumericUnderscores #-}
{-# LANGUAGE OverloadedStrings #-}

module RetrySpec (spec) where

import Control.Monad (forM_, replicateM)
import qualified Data.ByteString.Char8 as C
import Data.IORef
import Data.Time.Calendar (fromGregorian)
import Data.Time.Clock (UTCTime (..), addUTCTime, getCurrentTime)
import Data.Time.Format (defaultTimeLocale, formatTime)
import Network.HTTP.Types (status200, status429, status503)
import Network.HTTP.Types.Status (mkStatus)
import qualified Network.Wai as Wai
import Network.Wai.Handler.Warp (testWithApplication)
import OpenTelemetry.Exporter.OTLP.Internal.Config (isRetryableHttpStatus, parseRetryAfterMicrosAt)
import OpenTelemetry.Exporter.OTLP.Internal.Retry (jitteredBackoffMicros)
import System.Timeout (timeout)
import Test.Hspec
import TransportSpec (Signal (..), completedSuccessfully, completedWithFailure, newExport, respondWith)


spec :: Spec
spec = do
  describe "OTLP HTTP retry policy" $ do
    it "only classifies 429, 502, 503, and 504 as retryable errors" $
      [code | code <- [400 .. 599], isRetryableHttpStatus (mkStatus code "")] `shouldBe` [429, 502, 503, 504]

    it "jitter stays within the bounded exponential window" $
      forM_ [(0, 50_000, 100_000), (1, 100_000, 200_000), (5, 1_600_000, 3_200_000), (maxBound, 1_600_000, 3_200_000)] $ \(attempt, lo, hi) -> do
        delays <- replicateM 20 (jitteredBackoffMicros attempt)
        delays `shouldSatisfy` all (\delay -> delay >= lo && delay <= hi)

  describe "Retry-After parsing" $ do
    let now = UTCTime (fromGregorian 2026 10 31) 0
    it "accepts nonnegative delay-seconds including zero and surrounding whitespace" $ do
      parseRetryAfterMicrosAt now "0" `shouldBe` Just 0
      parseRetryAfterMicrosAt now "  2\t" `shouldBe` Just 2_000_000
    it "rejects malformed delays" $
      forM_ ["", "-1", "+1", "1.5", "not a date"] $ \header ->
        parseRetryAfterMicrosAt now header `shouldBe` Nothing
    it "parses IMF-fixdate, RFC 850, and asctime HTTP dates" $
      forM_ ["Sat, 31 Oct 2026 00:01:00 GMT", "Saturday, 31-Oct-26 00:01:00 GMT", "Sat Oct 31 00:01:00 2026"] $ \header ->
        parseRetryAfterMicrosAt now header `shouldBe` Just 60_000_000
    it "treats past dates as an immediate retry" $
      parseRetryAfterMicrosAt now "Fri, 30 Oct 2026 23:59:59 GMT" `shouldBe` Just 0
    it "clamps huge delays without overflowing into an immediate retry" $
      parseRetryAfterMicrosAt now "999999999999999999999999999999" `shouldBe` Just maxBound

  forM_ [Traces, Metrics, Logs] $ \signal ->
    describe (show signal <> " HTTP retry policy") $ do
      forM_ [429, 502, 503, 504] $ \code ->
        it ("retries HTTP " <> show code <> " and replays the same nonempty body") $ do
          bodies <- newIORef []
          let app req respond = do
                body <- Wai.strictRequestBody req
                n <- atomicModifyIORef' bodies (\xs -> (xs <> [body], length xs))
                respondWith (if n == 0 then mkStatus code "" else status200) [("Retry-After", "0")] req respond
          testWithApplication (pure app) $ \port -> do
            export <- newExport signal port (Just 1000)
            result <- timeout 1_500_000 export
            completedSuccessfully result `shouldBe` True
            sent <- readIORef bodies
            length sent `shouldBe` 2
            case sent of
              [first, second] -> do
                first `shouldNotBe` ""
                first `shouldBe` second
              _ -> expectationFailure "expected one retry"

      forM_ [400, 408, 500, 501, 505] $ \code ->
        it ("does not retry HTTP " <> show code <> ", even with Retry-After") $ do
          calls <- newIORef (0 :: Int)
          let app req respond = do
                atomicModifyIORef' calls (\n -> (n + 1, ()))
                respondWith (mkStatus code "") [("Retry-After", "0")] req respond
          testWithApplication (pure app) $ \port -> do
            export <- newExport signal port (Just 1000)
            result <- timeout 1_500_000 export
            completedWithFailure result `shouldBe` True
            readIORef calls `shouldReturn` 1

      it "honors an HTTP-date rather than falling back to a short retry" $ do
        calls <- newIORef (0 :: Int)
        now <- getCurrentTime
        let header = C.pack (formatTime defaultTimeLocale "%a, %d %b %Y %H:%M:%S GMT" (addUTCTime 60 now))
            app req respond = do
              n <- atomicModifyIORef' calls (\n -> (n + 1, n))
              respondWith (if n == 0 then status429 else status200) [("Retry-After", header)] req respond
        testWithApplication (pure app) $ \port -> do
          export <- newExport signal port (Just 300)
          result <- timeout 1_000_000 export
          completedWithFailure result `shouldBe` True
          readIORef calls `shouldReturn` 1

      it "caps Retry-After retries even when the batch timeout is disabled" $ do
        calls <- newIORef (0 :: Int)
        let app req respond = do
              atomicModifyIORef' calls (\n -> (n + 1, ()))
              respondWith status429 [("Retry-After", "0")] req respond
        testWithApplication (pure app) $ \port -> do
          export <- newExport signal port (Just 0)
          result <- timeout 1_000_000 export
          completedWithFailure result `shouldBe` True
          readIORef calls `shouldReturn` 6

      it "backs off and recovers when no Retry-After is supplied" $ do
        calls <- newIORef (0 :: Int)
        let app req respond = do
              n <- atomicModifyIORef' calls (\n -> (n + 1, n))
              respondWith (if n == 0 then status503 else status200) [] req respond
        testWithApplication (pure app) $ \port -> do
          export <- newExport signal port (Just 1000)
          result <- timeout 1_500_000 export
          completedSuccessfully result `shouldBe` True
          readIORef calls `shouldReturn` 2
