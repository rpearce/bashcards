let
sources = import ./nix/sources.nix;
pkgs = import sources.nixpkgs { };
bashcards = pkgs.callPackage ./derivation.nix { };
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    bashcards
    man
    niv
  ];
}
