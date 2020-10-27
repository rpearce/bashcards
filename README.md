# bashcards

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

Practice flashcards in bash.

## Installation

There are a couple of different ways to use this project.

### Nix

To install via [nixpkgs](https://github.com/nixos/nixpkgs):

```bash
λ nix-env -i bashcards
```

### Install Script

```bash
λ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/rpearce/bashcards/master/install)"
```

### Clone the Repository

```bash
λ git clone https://github.com/rpearce/bashcards.git
λ cd bashcards
λ ./bashcards -d path/to/bcards/directory
```

You can also use it in `nix-shell`:

```bash
λ nix-shell --pure
[nix-shell:~/projects/bashcards]$ man bashcards
[nix-shell:~/projects/bashcards]$ bashcards -d path/to/bcards/directory
```

## Usage

```bash
λ bashcards -d path/to/bcards/directory
What would you like to practice?
1. german
2. spanish
3. swedish
> 2
Spanish

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

## Creating `.bcrds` files

To add some Spanish and Swedish bashcards, for example, all you need to do is
create two files, `spanish.bcrds` and `swedish.bcrds`, and add lines to the
files that take the form `key=value`.

```bash
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

Once your cards are in a folder somewhere, you simply tell `bashcards` where to
find them!

```bash
λ bashcards -d path/to/bcards/directory
What would you like to practice?
1. spanish
2. swedish
>
```

There are example `.bcrds` files in the [examples/](./examples) folder of this
project.
