{-# LANGUAGE CPP #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE GeneralisedNewtypeDeriving #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}
{-# OPTIONS_GHC -Wall #-}
{-# OPTIONS_GHC -Wcompat #-}
{-# OPTIONS_GHC -Widentities #-}
{-# OPTIONS_GHC -Wincomplete-record-updates #-}
{-# OPTIONS_GHC -Wincomplete-uni-patterns #-}
{-# OPTIONS_GHC -Wmissing-deriving-strategies #-}
{-# OPTIONS_GHC -Wmissing-export-lists #-}
{-# OPTIONS_GHC -Wmissing-exported-signatures #-}
{-# OPTIONS_GHC -Wmissing-home-modules #-}
{-# OPTIONS_GHC -Wmissing-import-lists #-}
{-# OPTIONS_GHC -Wmonomorphism-restriction #-}
{-# OPTIONS_GHC -Wno-name-shadowing #-}
{-# OPTIONS_GHC -Wredundant-constraints #-}
{-# OPTIONS_GHC -Wunused-packages #-}


#if __GLASGOW_HASKELL__ >= 901
{-# OPTIONS_GHC -Winvalid-haddock #-}
#endif

#if __GLASGOW_HASKELL__ >= 902
{-# OPTIONS_GHC -Wmissing-kind-signatures #-}
{-# OPTIONS_GHC -Woperator-whitespace #-}
{-# OPTIONS_GHC -Wredundant-bang-patterns #-}
#endif

module Main (main) where

import Control.Applicative (Alternative ((<|>)))
import Control.Monad (when)
import qualified Data.Aeson as Json
import qualified Data.Char as Char
import Data.Foldable (Foldable (fold))
import Data.Functor ((<&>))
import Data.Int (Int64)
import qualified Data.List as List
import Data.Maybe (fromMaybe)
import Data.Text (Text)
import qualified Data.Text as Text
import Data.Traversable (for)
import Data.Vector (Vector)
import qualified Data.Vector as Vector
import qualified Data.Yaml as Yaml
import Distribution.Simple (Args, defaultMainWithHooks, simpleUserHooks)
import qualified Distribution.Simple
import Distribution.Simple.Setup (BuildFlags)
import Distribution.Types.HookedBuildInfo (HookedBuildInfo, emptyHookedBuildInfo)
import System.Directory (createDirectoryIfMissing)
import System.FilePath ((</>))
import qualified System.FilePath.Glob as Glob
import System.IO (IOMode (WriteMode), hPutStrLn, hSetNewlineMode, noNewlineTranslation, stderr, withFile)
import Prelude (
  Applicative (pure, (<*>)),
  Bool (False, True),
  Eq,
  FilePath,
  Functor (fmap),
  IO,
  Int,
  Maybe (Just, Nothing),
  MonadFail (fail),
  Monoid (mempty),
  Ord,
  Read,
  Semigroup ((<>)),
  Show (show),
  String,
  Traversable (traverse),
  floor,
  maybe,
  ($),
  (++),
  (.),
  (<$>),
 )
import qualified Prelude


#if MIN_VERSION_aeson(2,0,0)
import qualified Data.Aeson.KeyMap as JsonMap
#else
import qualified Data.HashMap.Strict as JsonMap
#endif

#if MIN_VERSION_text(2,1,0)
import qualified Data.Text.IO.Utf8 as TextIO
#else
import qualified Data.Text.IO as TextIO
#endif


newtype Model
  = Model Groups
  deriving stock (Show, Read, Eq, Ord)


instance Json.FromJSON Model where
  parseJSON (Json.Object o) = Model <$> o Json..: "groups"
  parseJSON _ = fail "expected an object"


newtype Groups
  = Groups (Vector Semconv)
  deriving stock (Show, Read, Eq, Ord)
  deriving newtype (Json.FromJSON)


data Semconv = Semconv
  { id :: Text
  , typ :: Convtype
  , brief :: Brief
  , note :: Maybe Note
  , prefix :: Maybe Prefix
  , extends :: Maybe Extends
  , stability :: Maybe Stability
  , deprecated :: Maybe Deprecated
  , attributes :: Vector Attribute
  -- ^ The spec says non-empty, but maybe empty actually.
  , constraints :: Vector Constraint
  , specificfields :: Maybe Specificfields
  }
  deriving stock (Show, Read, Eq, Ord)


instance Json.FromJSON Semconv where
  parseJSON (Json.Object o) = do
    (typ, spacificfields) <-
      case JsonMap.lookup "type" o of
        Just "span" -> pure (SpanType, Nothing)
        Just "resource" -> do
          specificfields <-
            Spanfields <$> (fromMaybe mempty <$> o Json..:? "events") <*> o Json..:? "span_kind"
          pure (ResourceType, Just specificfields)
        Just "event" -> do
          specificfields <- Eventfields <$> o Json..:? "name"
          pure (EventType, Just specificfields)
        Just "metric" -> do
          specificfields <- Metricfields <$> o Json..: "metric_name" <*> o Json..: "instrument" <*> o Json..: "unit"
          pure (MetricType, Just specificfields)
        Just "metric_group" -> pure (MetricGroupType, Nothing)
        Just "scope" -> pure (ScopeType, Nothing)
        Just "attribute_group" -> pure (AttributeGroupType, Nothing)
        Nothing -> pure (SpanType, Nothing)
        _ -> fail "expected a string with value of \"span\", \"resource\", \"event\", \"metric\", \"metric_group\", \"scope\", or \"attribute_group\""
    Semconv
      <$> o Json..: "id"
      <*> pure typ
      <*> o Json..: "brief"
      <*> o Json..:? "note"
      <*> o Json..:? "prefix"
      <*> o Json..:? "extends"
      <*> o Json..:? "stability"
      <*> o Json..:? "deprecated"
      <*> (fromMaybe mempty <$> o Json..:? "attributes")
      <*> (fromMaybe mempty <$> o Json..:? "constraints")
      <*> pure spacificfields
  parseJSON _ = fail "expected an object"


type Id = Text


data Convtype
  = SpanType
  | ResourceType
  | EventType
  | MetricType
  | MetricGroupType
  | ScopeType
  | AttributeGroupType
  deriving stock (Show, Read, Eq, Ord, Prelude.Enum)


type Note = Text


type Brief = Text


type Prefix = Text


type Extends = Text


data Stability = Deprecated | Experimental | Stable deriving stock (Show, Read, Eq, Ord, Prelude.Enum)


instance Json.FromJSON Stability where
  parseJSON (Json.String "deprecated") = pure Deprecated
  parseJSON (Json.String "experimental") = pure Experimental
  parseJSON (Json.String "stable") = pure Stable
  parseJSON _ = fail "expected a string with value of \"deprecated\", \"experimental\", or \"stable\""


type Deprecated = Text


data Attribute
  = AttributeDef
      { defFields :: AttributeDefFields
      , tag :: Maybe Tag
      , stability :: Maybe Stability
      , deprecated :: Maybe Deprecated
      , requirementLevel :: Maybe RequirementLevel
      , samplingRelevant :: Maybe SamplingRelevant
      , note :: Maybe Note
      }
  | AttributeRef
      { refFields :: AttributeRefFields
      , tag :: Maybe Tag
      , stability :: Maybe Stability
      , deprecated :: Maybe Deprecated
      , requirementLevel :: Maybe RequirementLevel
      , samplingRelevant :: Maybe SamplingRelevant
      , note :: Maybe Note
      }
  deriving stock (Show, Read, Eq, Ord)


instance Json.FromJSON Attribute where
  parseJSON (Json.Object o) =
    case (JsonMap.lookup "id" o, JsonMap.lookup "ref" o) of
      (Just id_, Nothing) ->
        AttributeDef
          <$> ( AttributeDefFields
                  <$> Json.parseJSON id_
                  <*> o Json..: "type"
                  <*> o Json..: "brief"
                  <*> (fromMaybe mempty <$> o Json..:? "examples")
              )
          <*> o Json..:? "tag"
          <*> o Json..:? "stability"
          <*> o Json..:? "deprecated"
          <*> o Json..:? "requirement_level"
          <*> o Json..:? "sampling_relevant"
          <*> o Json..:? "note"
      (Nothing, Just ref) ->
        AttributeRef
          <$> ( AttributeRefFields
                  <$> Json.parseJSON ref
                  <*> o Json..:? "brief"
                  <*> (fromMaybe mempty <$> o Json..:? "examples")
              )
          <*> o Json..:? "tag"
          <*> o Json..:? "stability"
          <*> o Json..:? "deprecated"
          <*> o Json..:? "requirement_level"
          <*> o Json..:? "sampling_relevant"
          <*> o Json..:? "note"
      (Just _, Just _) -> fail "expected either an object with a field of \"id\" or \"ref\""
      (Nothing, Nothing) -> fail "expected an object with a field of \"id\" or \"ref\""
  parseJSON _ = fail "expected an object"


data AttributeDefFields = AttributeDefFields
  { id :: Id
  , typ :: Type
  , brief :: Brief
  , examples :: OneOrSome Example
  -- ^ The spec says non-empty, but maybe empty actually.
  }
  deriving stock (Show, Read, Eq, Ord)


data AttributeRefFields = AttributeRefFields
  { ref :: Id
  , brief :: Maybe Brief
  , examples :: OneOrSome Example
  }
  deriving stock (Show, Read, Eq, Ord)


data Type
  = TypeSimple SimpleType
  | TypeTemplate SimpleType
  | TypeEnum Enum
  deriving stock (Show, Read, Eq, Ord)


instance Json.FromJSON Type where
  parseJSON (Json.String "string") = pure $ TypeSimple StringType
  parseJSON (Json.String "int") = pure $ TypeSimple IntType
  parseJSON (Json.String "double") = pure $ TypeSimple DoubleType
  parseJSON (Json.String "boolean") = pure $ TypeSimple BooleanType
  parseJSON (Json.String "string[]") = pure $ TypeSimple StringArrayType
  parseJSON (Json.String "int[]") = pure $ TypeSimple IntArrayType
  parseJSON (Json.String "double[]") = pure $ TypeSimple DoubleArrayType
  parseJSON (Json.String "boolean[]") = pure $ TypeSimple BooleanArrayType
  parseJSON (Json.String "template[string]") = pure $ TypeTemplate StringType
  parseJSON (Json.String "template[int]") = pure $ TypeTemplate IntType
  parseJSON (Json.String "template[double]") = pure $ TypeTemplate DoubleType
  parseJSON (Json.String "template[boolean]") = pure $ TypeTemplate BooleanType
  parseJSON (Json.String "template[string[]]") = pure $ TypeTemplate StringArrayType
  parseJSON (Json.String "template[int[]]") = pure $ TypeTemplate IntArrayType
  parseJSON (Json.String "template[double[]]") = pure $ TypeTemplate DoubleArrayType
  parseJSON (Json.String "template[boolean[]]") = pure $ TypeTemplate BooleanArrayType
  parseJSON (Json.Object o) = TypeEnum <$> Json.parseJSON (Json.Object o)
  parseJSON _ = fail "expected a string with specific values or an object"


data SimpleType
  = StringType
  | IntType
  | DoubleType
  | BooleanType
  | StringArrayType
  | IntArrayType
  | DoubleArrayType
  | BooleanArrayType
  deriving stock (Show, Read, Eq, Ord, Prelude.Enum)


data Enum = Enum
  { allowCustomValues :: Maybe Bool
  , members :: Vector Member
  -- ^ non-empty
  }
  deriving stock (Show, Read, Eq, Ord)


instance Json.FromJSON Enum where
  parseJSON (Json.Object o) =
    Enum
      <$> o Json..:? "allow_custom_values"
      <*> o Json..: "members"
  parseJSON _ = fail "expected an object"


data Member = Member
  { id :: Id
  , value :: Value
  , brief :: Maybe Brief
  , note :: Maybe Note
  }
  deriving stock (Show, Read, Eq, Ord)


instance Json.FromJSON Member where
  parseJSON (Json.Object o) =
    Member
      <$> o Json..: "id"
      <*> o Json..: "value"
      <*> o Json..:? "brief"
      <*> o Json..:? "note"
  parseJSON _ = fail "expected an object"


data Value
  = StringValue Text
  | IntValue Int64
  | BooleanValue Bool
  deriving stock (Show, Read, Eq, Ord)


instance Json.FromJSON Value where
  parseJSON (Json.String s) = pure $ StringValue s
  parseJSON (Json.Number n) = pure $ IntValue $ floor n
  parseJSON (Json.Bool b) = pure $ BooleanValue b
  parseJSON _ = fail "expected a string, number, or boolean"


data RequirementLevel
  = Required
  | ConditionallyRequired Text
  | Recommended (Maybe Text)
  | OptIn
  deriving stock (Show, Read, Eq, Ord)


instance Json.FromJSON RequirementLevel where
  parseJSON (Json.String "required") = pure Required
  parseJSON (Json.String "recommended") = pure $ Recommended Nothing
  parseJSON (Json.Object o) =
    ConditionallyRequired <$> o Json..: "conditionally_required"
      <|> Recommended . Just <$> o Json..: "recommended"
  parseJSON (Json.String "opt_in") = pure OptIn
  parseJSON _ = fail "expected a string with value of \"required\", \"recommended\", or \"opt_in\", or an object with a field of \"conditionally_required\" or \"recommended\""


type SamplingRelevant = Bool


newtype Example = Example Text deriving stock (Show, Read, Eq, Ord)


instance Json.FromJSON Example where
  parseJSON o@(Json.String _) = Example <$> Json.parseJSON o
  parseJSON (Json.Number n) = pure $ Example $ Text.pack $ show n
  parseJSON (Json.Bool True) = pure $ Example "true"
  parseJSON (Json.Bool False) = pure $ Example "false"
  parseJSON _ = fail "expected a string, number, or boolean"


type Tag = Text


data Constraint
  = -- | non-empty
    AnyOf (Vector Id)
  | Include Id
  deriving stock (Show, Read, Eq, Ord)


instance Json.FromJSON Constraint where
  parseJSON (Json.Object o) =
    AnyOf <$> o Json..: "any_of" <|> Include <$> o Json..: "include"
  parseJSON _ = fail "expected an object"


data Specificfields
  = Spanfields {events :: Vector Id, spanKind :: Maybe SpanKind}
  | Eventfields {name :: Maybe Name}
  | Metricfields {metricName :: MetricName, instrument :: Instrument, unit :: Unit}
  deriving stock (Show, Read, Eq, Ord)


data SpanKind
  = ClientKind
  | ServerKind
  | ProducerKind
  | ConsumerKind
  | InternalKind
  deriving stock (Show, Read, Eq, Ord, Prelude.Enum)


instance Json.FromJSON SpanKind where
  parseJSON (Json.String "client") = pure ClientKind
  parseJSON (Json.String "server") = pure ServerKind
  parseJSON (Json.String "producer") = pure ProducerKind
  parseJSON (Json.String "consumer") = pure ConsumerKind
  parseJSON (Json.String "internal") = pure InternalKind
  parseJSON _ = fail "expected a string with value of \"client\", \"server\", \"producer\", \"consumer\", or \"internal\""


type Name = Text


type MetricName = Text


data Instrument
  = Counter
  | Histogram
  | Gauge
  | Updowncounter
  deriving stock (Show, Read, Eq, Ord, Prelude.Enum)


instance Json.FromJSON Instrument where
  parseJSON (Json.String "counter") = pure Counter
  parseJSON (Json.String "histogram") = pure Histogram
  parseJSON (Json.String "gauge") = pure Gauge
  parseJSON (Json.String "updowncounter") = pure Updowncounter
  parseJSON _ = fail "expected a string with value of \"counter\", \"histogram\", \"gauge\", or \"updowncounter\""


type Unit = Text


newtype OneOrSome a
  = OneOrSome (Vector a)
  deriving stock (Show, Read, Eq, Ord)
  deriving newtype (Semigroup, Monoid)


instance Json.FromJSON a => Json.FromJSON (OneOrSome a) where
  parseJSON (Json.Array a) = OneOrSome <$> traverse Json.parseJSON a
  parseJSON o = OneOrSome . Vector.singleton <$> Json.parseJSON o


main :: IO ()
main = defaultMainWithHooks simpleUserHooks {Distribution.Simple.preBuild = preBuild}


preBuild :: Args -> BuildFlags -> IO HookedBuildInfo
preBuild _ _ = do
  let
    yamlPattern = Glob.compile "model/model/**/*.y*ml"
    targetDirectory :: FilePath
    targetDirectory = "gen/OpenTelemetry/"
    targetFile = targetDirectory </> "SemanticConventions.hs"
  yamlFiles <- Glob.globDir1 yamlPattern "."
  when (List.null yamlFiles) $ fail "no YAML files found"
  models <-
    for yamlFiles $ \yamlFile -> do
      printLog $ "processing " ++ yamlFile
      Yaml.decodeFileThrow yamlFile :: IO Model
  createDirectoryIfMissing True targetDirectory
  withFile targetFile WriteMode $ \targetHandle -> do
    hSetNewlineMode targetHandle noNewlineTranslation
    let
      (exports, bodies) =
        Vector.unzip $ do
          Model (Groups semconvs) <- Vector.fromList models
          Semconv {id, prefix, attributes, brief, note, stability, deprecated} <- semconvs
          let
            id' = convertId id
            body =
              comment
                <$> fold
                  [ if Text.null brief then [] else [convertMarkupFromMarkdownToHaddock brief]
                  , fieldLine stability $ ("Stability: " <>) . convertStability
                  , fieldLine deprecated $ ("Deprecated: " <>)
                  , fieldLines note $ \n ->
                      [ "==== Note"
                      , convertMarkupFromMarkdownToHaddock n
                      ]
                  ]
            (exports, headers, bodies) =
              Vector.unzip3 $
                attributes <&> \attribute ->
                  case attribute of
                    AttributeDef {defFields = AttributeDefFields {id, typ, brief}, stability, deprecated, requirementLevel, note} ->
                      let
                        (id', hid) =
                          case prefix of
                            Nothing -> (id, convertId id)
                            Just p -> (p <> "." <> id, convertId p <> "_" <> convertId id)
                      in
                        ( [hid <> ","]
                        , comment
                            <$> fold
                              [ ["- '" <> hid <> "'"]
                              , fieldLine stability $ indent 1 . ("Stability: " <>) . convertStability
                              , fieldLine deprecated $ indent 1 . ("Deprecated: " <>)
                              , fieldLine requirementLevel $ indent 1 . ("Requirement level: " <>) . convertRequirementLevel
                              , [""]
                              ]
                        , fold
                            [
                              [ "-- |"
                              , comment $ convertMarkupFromMarkdownToHaddock brief
                              ]
                            , fieldLines note $ \n -> comment <$> ["==== Note", convertMarkupFromMarkdownToHaddock n]
                            ,
                              [ hid <> " :: " <> convertType typ
                              , hid <> " = " <> convertIdToKey typ id'
                              ]
                            ]
                        )
                    AttributeRef {refFields = AttributeRefFields {ref, brief}, stability, deprecated, requirementLevel, note} ->
                      let href = convertId ref
                      in ( []
                         , comment
                            <$> fold
                              [ ["- '" <> href <> "'"]
                              , fieldLine brief $ indent 1 . convertMarkupFromMarkdownToHaddock
                              , fieldLine stability $ indent 1 . ("Stability: " <>) . convertStability
                              , fieldLine deprecated $ indent 1 . ("Deprecated: " <>)
                              , fieldLine requirementLevel $ indent 1 . ("Requirement level: " <>) . convertRequirementLevel
                              , fieldLines note $ \n ->
                                  [ indent 1 $ "==== Note"
                                  , indent 1 $ convertMarkupFromMarkdownToHaddock n
                                  ]
                              , [""]
                              ]
                         , []
                         )
          Vector.cons
            (
              [ "-- * " <> id
              , "-- $" <> id'
              , ""
              ]
            , fold
                [ ["-- $" <> id']
                , body
                , ["--"]
                , if Vector.null headers
                    then []
                    else
                      ["-- === Attributes"]
                        ++ fold (Vector.toList headers)
                ]
            )
            $ Vector.zip exports bodies
    TextIO.hPutStrLn targetHandle $
      Text.unlines $
        fold
          [
            [ "{-# LANGUAGE DerivingStrategies #-}"
            , "{-# LANGUAGE DeriveGeneric #-}"
            , "{-# LANGUAGE OverloadedStrings #-}"
            , "-- | This module is OpenTelemetry Semantic Conventions for Haskell."
            , "-- This is automatically generated"
            , "-- based on [semantic-conventions](https://github.com/open-telemetry/semantic-conventions/) v1.24."
            , "--"
            , "-- This module's version A.B.X.Y means that A.B is the version of the original semantic-conventions,"
            , "-- and X.Y is the version of this module."
            , "module OpenTelemetry.SemanticConventions ("
            ]
          , fold exports
          ,
            [ ") where"
            , "import Data.Text (Text)"
            , "import Data.Int (Int64)"
            , "import OpenTelemetry.Attributes.Key (Key (Key))"
            , "{-# ANN module (\"HLint: ignore Use camelCase\" :: String) #-}"
            ]
          , fold $ List.intersperse [""] $ Vector.toList bodies
          ]
  pure emptyHookedBuildInfo


convertMarkupFromMarkdownToHaddock :: Text -> Text
convertMarkupFromMarkdownToHaddock =
  Text.pack . conv . Text.unpack
  where
    conv [] = []
    conv ('*' : '*' : rest) = '_' : '_' : conv rest
    conv ('*' : rest) = '*' : conv rest
    conv ('`' : rest) = '@' : conv rest
    conv ('/' : rest) = '\\' : '/' : conv rest
    conv ('@' : rest) = '\\' : '@' : conv rest
    conv ('<' : rest) = '\\' : '<' : conv rest
    conv ('>' : rest) = '\\' : '>' : conv rest
    conv ('\'' : rest) = '\\' : '\'' : conv rest
    conv (c : rest) = c : conv rest


convertId :: Id -> Text
convertId =
  Text.pack . conv False . Text.unpack
  where
    conv
      :: Bool
      -- \^ make it upper? ie. next to '_'?
      -> String
      -> String
    conv _ [] = []
    conv True (c : rest) = Char.toUpper c : conv False rest
    conv False ('_' : rest) = conv True rest
    conv False ('.' : rest) = '_' : conv False rest
    conv False (c : rest) = c : conv False rest


convertType :: Type -> Text
convertType (TypeSimple t) = "Key " <> convertSimpleType t
convertType (TypeTemplate t) = "Text -> Key " <> convertSimpleType t
convertType (TypeEnum _) = "Key Text"


convertSimpleType :: SimpleType -> Text
convertSimpleType StringType = "Text"
convertSimpleType IntType = "Int64"
convertSimpleType DoubleType = "Double"
convertSimpleType BooleanType = "Bool"
convertSimpleType StringArrayType = "[Text]"
convertSimpleType IntArrayType = "[Int64]"
convertSimpleType DoubleArrayType = "[Double]"
convertSimpleType BooleanArrayType = "[Bool]"


convertIdToKey :: Type -> Id -> Text
convertIdToKey (TypeTemplate _) id = "\\k -> Key $ \"" <> id <> ".\" <> k"
convertIdToKey _ id = "Key \"" <> id <> "\""


convertStability :: Stability -> Text
convertStability Deprecated = "deprecated"
convertStability Experimental = "experimental"
convertStability Stable = "stable"


convertRequirementLevel :: RequirementLevel -> Text
convertRequirementLevel Required = "required"
convertRequirementLevel (ConditionallyRequired s) = "conditionally required: " <> convertMarkupFromMarkdownToHaddock s
convertRequirementLevel (Recommended (Just s)) = "recommended: " <> convertMarkupFromMarkdownToHaddock s
convertRequirementLevel (Recommended Nothing) = "recommended"
convertRequirementLevel OptIn = "opt-in"


comment :: Text -> Text
comment "" = "--"
comment s = Text.intercalate "\n" $ fmap ("-- " <>) $ Text.lines s


indent :: Int -> Text -> Text
indent n "" = Text.replicate n "    "
indent n s = Text.intercalate "\n" $ fmap (Text.replicate n "    " <>) $ Text.lines s


fieldLines :: Maybe a -> (a -> [Text]) -> [Text]
fieldLines a f = maybe [] (([""] <>) . f) a


fieldLine :: Maybe a -> (a -> Text) -> [Text]
fieldLine a f = maybe [] (\b -> ["", f b]) a


printLog :: String -> IO ()
printLog message = hPutStrLn stderr $ "Setup.hs: " ++ message
