# The bashcards package. Same shape as nixpkgs' pkgs/by-name/ba/bashcards, so
# updating upstream is a matter of swapping `src` for `fetchFromGitHub`.
{
  lib,
  stdenv,
  bashNonInteractive,
  installShellFiles,
  testers,
}:

let
  script = ../bashcards;

  # Single source of truth: the `version="x.y.z"` line in the script itself.
  version = lib.head (builtins.match ".*\nversion=\"([^\"\n]+)\"\n.*" (builtins.readFile script));
in
stdenv.mkDerivation (finalAttrs: {
  pname = "bashcards";
  inherit version;

  # Only what the package needs; README/example/test edits don't rebuild it.
  src = lib.fileset.toSource {
    root = ../.;
    fileset = lib.fileset.unions [
      script
      ../bashcards.1
    ];
  };

  # fixupPhase's patchShebangs rewrites `#!/usr/bin/env bash` to this bash.
  # `bash` is the interactive build (readline, ncurses, ...), which the script
  # doesn't need and which makes the closure about 20 times bigger.
  buildInputs = [ bashNonInteractive ];
  nativeBuildInputs = [ installShellFiles ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 bashcards -t "$out/bin"
    installManPage bashcards.1

    runHook postInstall
  '';

  passthru.tests.version = testers.testVersion { package = finalAttrs.finalPackage; };

  meta = {
    description = "Practice flashcards in your terminal";
    homepage = "https://github.com/rpearce/bashcards";
    changelog = "https://github.com/rpearce/bashcards/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ rpearce ];
    platforms = lib.platforms.unix;
    mainProgram = "bashcards";
  };
})
