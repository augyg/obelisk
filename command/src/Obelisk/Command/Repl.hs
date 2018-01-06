{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE LambdaCase #-}

module Obelisk.Command.Repl where

import Data.Monoid ((<>))
import System.Process
import System.Directory
import GHC.IO.Handle
import GHC.IO.Handle.Types

import Obelisk.Command.Project

--TODO: modify the nix-shell --run to recognize when the common dir's files have changed as well.
runRepl :: FilePath -> IO ()
runRepl dir = do
  findProjectRoot "." >>= \case
     Nothing -> putStrLn "'ob repl' must be used inside of an Obelisk project."
     Just pr -> do
       absPr <- makeAbsolute pr
       createProcess_ "Error: could not create terminal spawn"
          (shell $ ghcRepl absPr)
          { cwd = Just absPr} >>= \case 
             (_, _, _, ph) -> do 
                waitForProcess ph 
                return ()
             _ -> return ()
  where
    ghcRepl path = "cd " <> path <> "; nix-shell -A shells.ghc --run cd " <> dir <> "; ghcid -W -c\"cabal new-repl exe:" <> dir <> "\"" :: String
