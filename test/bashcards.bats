#!/usr/bin/env bats
#
# Runs against ../bashcards by default (`bats test` inside `nix develop`); the
# Nix check sets BASHCARDS to the installed program so the packaged artifact is
# what gets tested.
#
# Set BASHCARDS_SHELL to run the script under a specific bash; for example,
# macOS' stock bash 3.2:
#
#   BASHCARDS_SHELL=/bin/bash bats test

bats_require_minimum_version 1.5.0

setup() {
  BASHCARDS="${BASHCARDS:-$BATS_TEST_DIRNAME/../bashcards}"
  DECKS="$BATS_TEST_TMPDIR/decks"
  mkdir -p "$DECKS"

  # a UTF-8 locale, so card borders are measured in characters
  export LC_ALL=C.UTF-8
}

function bashcards {
  if [ -n "${BASHCARDS_SHELL:-}" ]; then
    "$BASHCARDS_SHELL" "$BASHCARDS" "$@"
  else
    "$BASHCARDS" "$@"
  fi
}

# writes a deck file; for example: deck spanish "hola=hello" "adios=goodbye"
function deck {
  local name="$1"
  shift
  printf '%s\n' "$@" > "$DECKS/$name.bcrds"
}

# writes the input for practicing a whole deck: choose the
# first deck, then press return until the program exits
function practice_input {
  PRACTICE_INPUT="$BATS_TEST_TMPDIR/practice-input"
  { printf '1\n'; printf '\n%.0s' {1..100}; } > "$PRACTICE_INPUT"
}

# practices the first deck in a directory (default: $DECKS)
function practice {
  practice_input
  run bashcards -d "${1:-$DECKS}" < "$PRACTICE_INPUT"
}

# counts the card content lines (like `|  hola  |`) in $output,
# ignoring the blank padding lines inside each card
function card_lines {
  printf '%s\n' "$output" | grep '^|  .*  |$' | grep -vc '^| *|$' || true
}

# checks that $output has a line exactly matching $1
function has_line {
  printf '%s\n' "$output" | grep -qx -- "$1"
}

@test "--version prints the version" {
  run bashcards --version
  [ "$status" -eq 0 ]
  [[ "$output" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

@test "--help prints usage" {
  run bashcards --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: bashcards"* ]]
}

@test "no arguments prints usage to stderr and exits 1" {
  run --separate-stderr bashcards
  [ "$status" -eq 1 ]
  [ -z "$output" ]
  [[ "$stderr" == *"Usage: bashcards"* ]]
}

@test "an unknown option prints usage to stderr and exits 1" {
  run --separate-stderr bashcards --bogus
  [ "$status" -eq 1 ]
  [ -z "$output" ]
  [[ "$stderr" == *"Usage: bashcards"* ]]
}

@test "-d without a directory says so" {
  run --separate-stderr bashcards -d
  [ "$status" -eq 1 ]
  [[ "$stderr" == *"DIRECTORY"* ]]
}

@test "-d with a missing directory exits 1" {
  run --separate-stderr bashcards -d "$BATS_TEST_TMPDIR/does-not-exist"
  [ "$status" -eq 1 ]
  [[ "$stderr" == *"Directory not found"* ]]
}

@test "-d with a directory containing no decks exits 1" {
  run --separate-stderr bashcards -d "$DECKS"
  [ "$status" -eq 1 ]
  [[ "$stderr" == *"No *.bcrds files"* ]]
}

@test "lists the decks by name without the extension" {
  deck spanish "hola=hello"
  deck german "hallo=hello"
  run bashcards -d "$DECKS" < /dev/null
  has_line "1. german"
  has_line "2. spanish"
}

@test "exits cleanly at end of input" {
  deck spanish "hola=hello"
  run bashcards -d "$DECKS" < /dev/null
  [ "$status" -eq 0 ]
}

@test "re-prompts on an invalid menu choice" {
  deck spanish "hola=hello"
  run bashcards -d "$DECKS" <<< $'abc\n0\n2'
  [ "$status" -eq 0 ]
  [ "$(printf '%s\n' "$output" | grep -c 'Please select from the options')" -eq 3 ]
}

@test "an over-long menu choice does not leak a shell error" {
  deck spanish "hola=hello"
  run --separate-stderr bashcards -d "$DECKS" <<< "99999999999999999999999"
  [ "$status" -eq 0 ]
  [ -z "$stderr" ]
  [[ "$output" == *"Please select from the options"* ]]
}

@test "prints the deck name while practicing" {
  deck spanish "hola=hello"
  practice
  has_line "spanish"
}

@test "shows every card before finishing" {
  deck spanish "a=1" "b=2" "c=3" "d=4"
  practice
  [ "$status" -eq 0 ]
  [ "$(card_lines)" -eq 8 ]
  [ "$(printf '%s\n' "$output" | grep -c 'All done!')" -eq 1 ]
}

@test "shows both sides of every card" {
  deck spanish "a=1" "b=2" "c=3" "d=4"
  practice
  for side in a b c d 1 2 3 4; do
    has_line "|  $side  |"
  done
}

@test "shows a repeated front as its own card" {
  deck spanish "a=1" "a=2"
  practice
  [ "$(card_lines)" -eq 4 ]
}

@test "keeps everything after the first = as the back of the card" {
  deck maths "1+1=2" "x=y=z"
  practice
  has_line "|  1+1  |"
  has_line "|  2  |"
  has_line "|  x  |"
  has_line "|  y=z  |"
}

@test "skips blank lines in a deck" {
  deck spanish "hola=hello" "" "adios=goodbye" ""
  practice
  [ "$status" -eq 0 ]
  [ "$(card_lines)" -eq 4 ]
}

@test "reads the last line of a deck that has no trailing newline" {
  printf 'hola=hello\nadios=goodbye' > "$DECKS/spanish.bcrds"
  practice
  [ "$(card_lines)" -eq 4 ]
}

@test "ignores carriage returns in a deck" {
  printf 'hola=hello\r\nadios=goodbye\r\n' > "$DECKS/spanish.bcrds"
  practice
  has_line "|  hello  |"
  has_line "|  goodbye  |"
}

@test "warns about a line without = and skips it" {
  deck spanish "hola=hello" "oops" "adios=goodbye"
  practice_input
  run --separate-stderr bashcards -d "$DECKS" < "$PRACTICE_INPUT"
  [ "$status" -eq 0 ]
  [[ "$stderr" == *"line 2"* ]]
  [ "$(card_lines)" -eq 4 ]
}

@test "warns about a line with a blank side and skips it" {
  deck spanish "hola=hello" "=hello" "hola=" "=" " =hello" "hola= " "adios=goodbye"
  practice_input
  run --separate-stderr bashcards -d "$DECKS" < "$PRACTICE_INPUT"
  [ "$status" -eq 0 ]
  [[ "$stderr" == *"line 2"* ]]
  [[ "$stderr" == *"line 3"* ]]
  [[ "$stderr" == *"line 4"* ]]
  [[ "$stderr" == *"line 5"* ]]
  [[ "$stderr" == *"line 6"* ]]
  [ "$(card_lines)" -eq 4 ]
}

@test "returns to the menu when a deck has no cards" {
  : > "$DECKS/empty.bcrds"
  run bashcards -d "$DECKS" <<< "1"
  [ "$status" -eq 0 ]
  [[ "$output" == *"no cards"* ]]
  [ "$(printf '%s\n' "$output" | grep -c 'What would you like to practice?')" -eq 2 ]
}

@test "handles a deck directory path with spaces" {
  mkdir -p "$BATS_TEST_TMPDIR/my decks"
  printf 'hola=hello\n' > "$BATS_TEST_TMPDIR/my decks/my deck.bcrds"
  practice "$BATS_TEST_TMPDIR/my decks"
  [ "$status" -eq 0 ]
  has_line "1. my deck"
  [ "$(card_lines)" -eq 2 ]
}

@test "sizes the border to the card text in characters" {
  deck icelandic "Talar þú ensku?=Do you speak English?"
  practice
  has_line "|  Talar þú ensku?  |"
  # 15 characters + 6 = 21 dashes
  has_line "$(printf '–%.0s' {1..21})"
}

@test "does not clear the screen when stdout is not a terminal" {
  deck spanish "hola=hello"
  practice
  [[ "$output" != *$'\033'* ]]
}

@test "strips control characters from card text" {
  deck spanish $'hola=hel\033]0;pwned\alo'
  practice
  [[ "$output" != *$'\033'* ]]
  has_line "|  hel]0;pwnedlo  |"
}

@test "warns when the locale is not UTF-8" {
  deck spanish "hola=hello"
  export LC_ALL=C
  run --separate-stderr bashcards -d "$DECKS" < /dev/null
  [[ "$stderr" == *"UTF-8"* ]]
}

@test "does not warn under a UTF-8 locale" {
  deck spanish "hola=hello"
  run --separate-stderr bashcards -d "$DECKS" < /dev/null
  [ -z "$stderr" ]
}
