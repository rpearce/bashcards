# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-09-25

### Changed

* works with bash 3.2 and newer (it used to need bash 4), so it runs on
  macOS's stock bash
* cards are shuffled up front instead of picked one at a time
* a `.bcrds` line that repeats an earlier front is its own card now instead
  of replacing the earlier one
* errors and usage information go to stderr
* the screen is only cleared when printing to a terminal
* the man page moved from section 8 to section 1
* `install` downloads a pinned release instead of `main`, installs the man
  page, honors `PREFIX`, and no longer truncates an existing `bashcards` when
  a download fails
* `install` installs into `~/.local` by default, so it no longer needs `sudo`,
  and says how to add `~/.local/bin` to your `PATH` when it isn't there
  (running it as root still installs into `/usr/local`)
* nix: replaced niv with a flake (`nix run github:rpearce/bashcards`) and
  added `nix flake check` and GitHub Actions CI

### Fixed

* every deck ended after its first card on bash 5.2 and newer
* a blank line in a `.bcrds` file crashed the program
* the last line of a `.bcrds` file was dropped when the file had no trailing
  newline
* CRLF line endings in a `.bcrds` file corrupted the card display
* an empty `.bcrds` file crashed the program; it goes back to the menu now
* a directory without any `.bcrds` files listed a bogus `*` deck and crashed
* a menu choice with lots of digits leaked a shell error
* ctrl-d exits cleanly instead of with an error
* control characters in a `.bcrds` file could drive the terminal
* `-d` without a directory said the directory wasn't found
* warns when the locale isn't UTF-8, since card borders won't line up
* a `.bcrds` line with a blank front or back is skipped with a warning
  instead of showing an empty card
* warnings wait for return before the screen is cleared, so they can be read
* typos and duplicate cards in the example decks

### Added

* a `Makefile` with `install` and `uninstall` targets that honor `PREFIX` and
  `DESTDIR`
* a `bats` test suite (`bats test`)

## [0.1.3] - 2020-08-30

### Fixed

* shellcheck warnings

## [0.1.2] - 2020-05-09

### Fixed

* include missing version information

## [0.1.1] - 2020-05-09

### Fixed

* use `printf` instead of `clear` to clear the screen

## [0.1.0] - 2020-05-09

### Added

* all the things
