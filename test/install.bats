#!/usr/bin/env bats
#
# Tests for the Makefile and the install script.

bats_require_minimum_version 1.5.0

setup() {
  REPO="$BATS_TEST_DIRNAME/.."
}

# serves the current program as release 9.9.9 from a stand-in
# for raw.githubusercontent.com/rpearce/bashcards
function mirror {
  mkdir -p "$BATS_TEST_TMPDIR/mirror/v9.9.9"
  cp "$REPO/bashcards" "$REPO/bashcards.1" "$BATS_TEST_TMPDIR/mirror/v9.9.9"

  export BASHCARDS_VERSION=9.9.9
  export BASHCARDS_RAW_URL="file://$BATS_TEST_TMPDIR/mirror"
}

@test "make install puts the program and man page under DESTDIR and PREFIX" {
  run make -s -C "$REPO" install DESTDIR="$BATS_TEST_TMPDIR/root" PREFIX=/usr
  [ "$status" -eq 0 ]
  [ -x "$BATS_TEST_TMPDIR/root/usr/bin/bashcards" ]
  [ -f "$BATS_TEST_TMPDIR/root/usr/share/man/man1/bashcards.1" ]
}

@test "make uninstall removes what make install put there" {
  make -s -C "$REPO" install DESTDIR="$BATS_TEST_TMPDIR/root" PREFIX=/usr
  run make -s -C "$REPO" uninstall DESTDIR="$BATS_TEST_TMPDIR/root" PREFIX=/usr
  [ "$status" -eq 0 ]
  [ ! -e "$BATS_TEST_TMPDIR/root/usr/bin/bashcards" ]
  [ ! -e "$BATS_TEST_TMPDIR/root/usr/share/man/man1/bashcards.1" ]
}

@test "install downloads the pinned release into PREFIX" {
  mirror
  export PREFIX="$BATS_TEST_TMPDIR/prefix"
  run bash "$REPO/install"
  [ "$status" -eq 0 ]
  [ -x "$PREFIX/bin/bashcards" ]
  [ -f "$PREFIX/share/man/man1/bashcards.1" ]
  [[ "$output" == *"$PREFIX/bin/bashcards"* ]]
}

@test "install puts it in ~/.local without PREFIX, so it needs no sudo" {
  [ "$EUID" -ne 0 ] || skip "root installs into /usr/local"
  mirror
  unset PREFIX
  export HOME="$BATS_TEST_TMPDIR/home"
  run bash "$REPO/install"
  [ "$status" -eq 0 ]
  [ -x "$HOME/.local/bin/bashcards" ]
  [ -f "$HOME/.local/share/man/man1/bashcards.1" ]
}

@test "install says how to add PREFIX/bin to PATH when it isn't there" {
  mirror
  export PREFIX="$BATS_TEST_TMPDIR/prefix"
  run bash "$REPO/install"
  [ "$status" -eq 0 ]
  [[ "$output" == *"export PATH=\"$PREFIX/bin:\$PATH\""* ]]
}

@test "install doesn't mention PATH when PREFIX/bin is already on it" {
  mirror
  export PREFIX="$BATS_TEST_TMPDIR/prefix"
  PATH="$PREFIX/bin:$PATH" run bash "$REPO/install"
  [ "$status" -eq 0 ]
  [[ "$output" != *"PATH"* ]]
}

@test "install leaves an existing program alone when the download fails" {
  mkdir -p "$BATS_TEST_TMPDIR/prefix/bin"
  printf '#!/bin/sh\necho old\n' > "$BATS_TEST_TMPDIR/prefix/bin/bashcards"
  chmod 0755 "$BATS_TEST_TMPDIR/prefix/bin/bashcards"

  export BASHCARDS_VERSION=9.9.9
  export BASHCARDS_RAW_URL="file://$BATS_TEST_TMPDIR/nowhere"
  export PREFIX="$BATS_TEST_TMPDIR/prefix"
  run bash "$REPO/install"
  [ "$status" -ne 0 ]
  [ "$("$PREFIX/bin/bashcards")" = "old" ]
}
