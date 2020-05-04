{ lib, pkgs }:

pkgs.stdenv.mkDerivation {
  name = "bashcards";
  src = ./.;
  phases = "unpackPhase installPhase";
  installPhase = ''
    mkdir -p $out/bin $out/share/man/man8
    cp manual $out/share/man/man8/
    cp bashcards $out/bin/
  '';
  meta = {
    description = "Practice flashcards in bash";
    homepage = "https://github.com/rpearce/bashcards/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ rpearce ];
    platforms = lib.platforms.all;
  };
}
