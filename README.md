# bashcards

Practice flashcards in your terminal

_Note: works with bash 3.2 and newer, so macOS's stock bash is fine_

## Usage

```
λ bashcards -d path/to/bcards/directory
What would you like to practice?
1. german
2. spanish
3. swedish
> 2
spanish

–––––––––––––––
|             |
|  Te quiero  |
|             |
–––––––––––––––
(Press return to flip)

––––––––––––––––
|              |
|  I love you  |
|              |
––––––––––––––––
(Press return for next card)
```

## Installation

There are a couple of different ways to use this project.

### Nix

Run it without installing anything:

```
λ nix run github:rpearce/bashcards -- -d path/to/bcards/directory
```

Install it into your profile:

```
λ nix profile install github:rpearce/bashcards
```

It is also packaged in [nixpkgs](https://search.nixos.org/packages?query=bashcards),
which may lag behind this repository:

```
λ nix profile install nixpkgs#bashcards
```

### Install Script

The install script downloads a release and puts `bashcards` and its man page
under `/usr/local`, which usually needs `sudo`:

```
λ sudo /usr/bin/env bash -c "$(curl -fsSL https://raw.githubusercontent.com/rpearce/bashcards/main/install)"
```

To install somewhere else, set `PREFIX`:

```
λ PREFIX=~/.local /usr/bin/env bash -c "$(curl -fsSL https://raw.githubusercontent.com/rpearce/bashcards/main/install)"
```

### Clone the Repository

```
λ git clone https://github.com/rpearce/bashcards.git
λ cd bashcards
λ ./bashcards -d path/to/bcards/directory
```

You can also install it (and its man page) with `make`, which honors `PREFIX`
and `DESTDIR`:

```
λ sudo make install
λ make install PREFIX=~/.local
```

### Download a Release

[Specific releases](https://github.com/rpearce/bashcards/releases) can be
downloaded and used just like the `Clone the Repository` section above.

## Creating `.bcrds` files

To add some Spanish and Swedish bashcards, for example, all you need to do is
create two files, `spanish.bcrds` and `swedish.bcrds`, and add lines to the
files that take the form `front=back`.

```
λ mkdir /path/to/bcards/directory && cd $_
λ touch spanish.bcrds swedish.bcrds
λ cat <<EOF > spanish.bcrds
goodbye=adiós
hello=hola
I love you=Te quiero.
EOF
λ cat <<EOF > swedish.bcrds
Goodbye=Adjö
Hello=Hallå
I love you=Jag älskar dig
EOF
```

A few things to know about the format:

* one card per line; everything after the first `=` is the back of the card,
  so a back can contain `=` but a front cannot
* blank lines are ignored, and lines without an `=` are skipped with a warning
* files should be UTF-8, and `bashcards` expects a UTF-8 locale (it warns you
  otherwise, since card borders are measured in characters)
* which side of a card you see first is random, so it doesn't matter which
  side you put on the left

Once your cards are in a folder somewhere, you simply tell `bashcards` where to
find them!

```
λ bashcards -d path/to/bcards/directory
What would you like to practice?
1. spanish
2. swedish
>
```

There are example `.bcrds` files in the [examples/](./examples) folder of this
project.

## Development

[Nix](https://nixos.org) provides everything needed (`bash`, `bats`,
`shellcheck` and `mandoc`):

```
λ nix develop            # or `direnv allow`, or plain `nix-shell`
λ ./bashcards -d examples
λ man ./bashcards.1
λ bats test
λ make check             # bats, shellcheck and mandoc, without nix
λ nix fmt                # formats the nix files
λ nix flake check        # everything CI runs
```

To run the tests with the script under a specific bash, like macOS's stock
bash 3.2:

```
λ BASHCARDS_SHELL=/bin/bash bats test
```

Plain `nix-build` and `nix-shell` still work; they read `flake.nix` through
[flake-compat](https://github.com/edolstra/flake-compat).
