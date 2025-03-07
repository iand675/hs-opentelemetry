{-# LANGUAGE OverloadedStrings #-}
import Data.Text (Text)
import Data.Foldable
import Data.Maybe
import qualified Data.Map.Strict as M
import qualified Data.Text.Encoding as T
import qualified Hedgehog.Gen as Gen
import qualified Hedgehog.Range as Range
import Network.HTTP.Types (urlDecode)
import OpenTelemetry.Trace.Core
import Test.Hspec
import Test.Hspec.Hedgehog
import SqlCommenter

textValGen :: Gen Text
textValGen = Gen.text (Range.linear 1 400) Gen.unicode

main :: IO ()
main = hspec $ do
  specify "Does not add comment if the query already has a comment" $ do
    let queries =
          [ "SELECT * FROM table -- noodle"
          , "SELECT * FROM table -- noodle\n"
          , "SELECT * FROM table /* noodle\n  poodle\n*/"
          ]
        someAttrs = M.fromList [("foo", "bar")]
    for_ queries $ \query -> do
      sqlCommenter query someAttrs `shouldBe` query
  specify "Does not add comment if the attributes are empty" $ do
    let query = "SELECT * FROM table"
    sqlCommenter query M.empty `shouldBe` query
  specify "Text builder optimized URL encoding round-trips" $ do
    hedgehog $ do
      t <- forAll textValGen
      t === (T.decodeUtf8 $ urlDecode True $ T.encodeUtf8 $ SqlCommenter.urlEncode t)
  specify "Span attributes are picked up from thread-local context" $ do
    tp <- createTracerProvider [] emptyTracerProviderOptions
    let t = makeTracer tp (InstrumentationLibrary "test" "test") tracerOptions
    inSpan t "test" defaultSpanArguments $ do
      attrs <- getSqlCommenterAttributesWithTraceData
      M.lookup "traceparent" attrs `shouldSatisfy` isJust
      M.lookup "tracestate" attrs `shouldSatisfy` isJust
  specify "Parsing a queries reads attributes from the first comment" $ do
    let query1 = "SELECT * FROM table -- foo='bar'\n-- bar='baz'"
        query2 = "SELECT * FROM table /* noodle='poodle',wibble='wobble'*/ /* foo='bar' */"
    parseFirstSqlComment query1 `shouldBe` M.fromList [("foo", "bar")]
    parseFirstSqlComment query2 `shouldBe` M.fromList [("noodle", "poodle"), ("wibble", "wobble")]
  specify "Parsing a query decodes encoded bytes" $ do
    hedgehog $ do
      let attrList = M.fromList <$> Gen.list (Range.linear 0 30) ((,) <$> textValGen <*> textValGen)
      kvs <- forAll attrList
      kvs === parseFirstSqlComment (sqlCommenter "" kvs)
