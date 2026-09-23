# default.nix
#
# Bridges non-flake tooling to the flake's default package, so there is a
# single source of truth (flake.nix's `packages.default`). `nix-build` builds
# bashcards; if you use flakes directly, prefer `nix build`.
(import (
  let
    lock = builtins.fromJSON (builtins.readFile ./flake.lock);
    compat = lock.nodes.flake-compat.locked;
  in
  fetchTarball {
    url = "https://github.com/edolstra/flake-compat/archive/${compat.rev}.tar.gz";
    sha256 = compat.narHash;
  }
) { src = ./.; }).defaultNix.default
