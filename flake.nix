{
  description = "bashcards: practice flashcards in your terminal";

  nixConfig.bash-prompt = "[bashcards]λ ";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Used only by ./default.nix and ./shell.nix, so plain `nix-build` and
    # `nix-shell` keep working for non-flake users and tooling.
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;

      # A Bash script runs anywhere nixpkgs' bash does. x86_64-darwin is still
      # supported on nixos-26.05; drop it if the input ever moves to a branch
      # that dropped Intel macOS.
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forEachSystem = f: lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      # `nix build`, `nix run`, `nix profile install`
      packages = forEachSystem (pkgs: rec {
        bashcards = pkgs.callPackage ./nix/package.nix { };
        default = bashcards;
      });

      # `nix flake check`
      checks = forEachSystem (
        pkgs:
        let
          inherit (self.packages.${pkgs.stdenv.hostPlatform.system}) bashcards;

          # A check passes when its script does.
          check =
            name: attrs: script:
            pkgs.runCommand "bashcards-${name}" attrs ''
              ${script}
              touch "$out"
            '';
        in
        {
          build = bashcards;

          # `bashcards --version` prints the packaged version (also proves the
          # patched shebang and the installed program actually run).
          version = bashcards.tests.version;

          shellcheck = check "shellcheck" { nativeBuildInputs = [ pkgs.shellcheck ]; } ''
            cd ${self}
            shellcheck --shell=bash bashcards install
          '';

          # Fails on warnings and errors; loosen to `-W error` or tighten to
          # `-W style` as desired.
          mandoc = check "mandoc-lint" { nativeBuildInputs = [ pkgs.mandoc ]; } ''
            mandoc -T lint -W warning ${self}/bashcards.1
          '';

          # The bats suite runs against the *installed* program, so the packaged
          # artifact is what gets tested (see test/*.bats for the fallback).
          bats =
            check "bats"
              {
                nativeBuildInputs = [
                  pkgs.bats
                  pkgs.curl # the install script test downloads from a file:// mirror
                ];
                BASHCARDS = lib.getExe bashcards;
              }
              ''
                bats --print-output-on-failure ${self}/test
              '';

          nixfmt = check "nixfmt" { nativeBuildInputs = [ pkgs.nixfmt ]; } ''
            cd ${self}
            nixfmt --check flake.nix default.nix shell.nix nix/*.nix
          '';
        }
      );

      # `nix develop`, or automatically via direnv (see .envrc)
      devShells = forEachSystem (pkgs: {
        default = pkgs.mkShell {
          inputsFrom = [ self.packages.${pkgs.stdenv.hostPlatform.system}.bashcards ];
          packages = with pkgs; [
            bats
            mandoc
            shellcheck
          ];
        };
      });

      # `nix fmt` formats the Nix files with nixfmt (RFC 166 style).
      formatter = forEachSystem (pkgs: pkgs.nixfmt-tree);
    };
}
