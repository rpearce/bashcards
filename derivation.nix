{ lib, pkgs }:

pkgs.stdenv.mkDerivation {
  name = "bashcards";
  src = ./.;
  phases = "unpackPhase installPhase";
  installPhase = ''
    mkdir -p $out/bin
    cp bashcards $out/bin/
  '';
  meta = {
    description = "Practice flashcards in bash";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ rpearce ];
    platforms = lib.platforms.all;
  };
}
