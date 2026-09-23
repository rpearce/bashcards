PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
MANDIR ?= $(PREFIX)/share/man/man1

.PHONY: install uninstall test check

install:
	install -d "$(DESTDIR)$(BINDIR)" "$(DESTDIR)$(MANDIR)"
	install -m 0755 bashcards "$(DESTDIR)$(BINDIR)/bashcards"
	install -m 0644 bashcards.1 "$(DESTDIR)$(MANDIR)/bashcards.1"

uninstall:
	rm -f "$(DESTDIR)$(BINDIR)/bashcards" "$(DESTDIR)$(MANDIR)/bashcards.1"

# runs the test suite (needs bats; see `nix develop`)
test:
	bats test

# everything CI checks, minus nix
check: test
	shellcheck --shell=bash bashcards install
	mandoc -T lint -W warning bashcards.1
