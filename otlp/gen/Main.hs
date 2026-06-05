{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

-- | Code generator for the OTLP protobuf modules.
--
-- Reads @.proto@ files from a directory tree and emits wireform-proto
-- Haskell modules (prefixed with @Proto@) into an output directory,
-- wiring up cross-module imports via a shared 'TypeRegistry'.
--
-- This backs @scripts/generate-modules.sh@; build it with the @codegen@
-- cabal flag enabled:
--
-- > cabal run -f codegen hs-opentelemetry-otlp-gen -- <proto-root> <src-out-dir>
module Main (main) where

import Control.Monad (forM, forM_)
import Data.List (isSuffixOf)
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import Proto.CodeGen (GenerateOpts (..), buildTypeRegistry, defaultGenerateOpts, generateModuleText, moduleNameForProto)
import Proto.IDL.Parser.Resolver (ResolvedProto (..), resolveProtoImports)
import System.Directory (createDirectoryIfMissing, doesDirectoryExist, listDirectory)
import System.Environment (getArgs)
import System.FilePath (takeDirectory, (</>))


-- | Recursively list all @.proto@ files beneath a root, returning paths
-- relative to that root (forward-slash separated, matching import paths).
findProtos :: FilePath -> IO [FilePath]
findProtos root = go ""
  where
    go prefix = do
      let dir = if null prefix then root else root </> prefix
      entries <- listDirectory dir
      fmap concat $ forM entries $ \entry -> do
        let rel = if null prefix then entry else prefix </> entry
        isDir <- doesDirectoryExist (root </> rel)
        if isDir
          then go rel
          else pure [rel | ".proto" `isSuffixOf` rel]


opts :: GenerateOpts
opts = defaultGenerateOpts {genModulePrefix = "Proto"}


main :: IO ()
main = do
  args <- getArgs
  (protoRoot, srcRoot) <- case args of
    [p, s] -> pure (p, s)
    _ -> error "usage: hs-opentelemetry-otlp-gen <proto-root> <src-out-dir>"
  exists <- doesDirectoryExist protoRoot
  if not exists then error ("proto root not found: " <> protoRoot) else pure ()
  relPaths <- findProtos protoRoot
  pairs <- forM relPaths $ \rel -> do
    let disk = protoRoot </> rel
    res <- resolveProtoImports [protoRoot, "."] disk
    case res of
      Left err -> error ("resolve error for " <> disk <> ": " <> show err)
      Right rp -> pure (rel, rp)
  let reg = buildTypeRegistry opts pairs
  forM_ pairs $ \(rel, rp) -> do
    let modName = moduleNameForProto opts rel (rpFile rp)
        outRel = T.unpack (T.replace "." "/" modName) <> ".hs"
        outPath = srcRoot </> outRel
        body = generateModuleText opts reg rel (rpFile rp)
        code = "{- HLINT ignore -}\n" <> body
    createDirectoryIfMissing True (takeDirectory outPath)
    TIO.writeFile outPath code
    putStrLn ("Generated " <> outPath <> "  (" <> T.unpack modName <> ")")
  putStrLn ("Done: " <> show (length pairs) <> " modules.")
