# SPDX-FileCopyrightText: Yorhel <projects@yorhel.nl>
# SPDX-License-Identifier: MIT

# Optional semi-standard Makefile with some handy tools.
# ncdu-plus itself can be built with just the zig build system.

ZIG ?= zig

PREFIX ?= /usr/local
BINDIR ?= ${PREFIX}/bin
MANDIR ?= ${PREFIX}/share/man/man1
ZIG_FLAGS ?= --release=fast -Dstrip

NCDU_VERSION=$(shell grep 'program_version = "' src/main.zig | sed -e 's/^.*"\(.\+\)".*$$/\1/')

.PHONY: build test
build: release

release:
	$(ZIG) build ${ZIG_FLAGS}

debug:
	$(ZIG) build

clean:
	rm -rf zig-cache zig-out

install: install-bin install-doc

install-bin: release
	mkdir -p ${BINDIR}
	install -m0755 zig-out/bin/ncdu-plus ${BINDIR}/

install-doc:
	mkdir -p ${MANDIR}
	install -m0644 ncdu-plus.1 ${MANDIR}/

uninstall: uninstall-bin uninstall-doc

# XXX: Ideally, these would also remove the directories created by 'install' if they are empty.
uninstall-bin:
	rm -f ${BINDIR}/ncdu-plus

uninstall-doc:
	rm -f ${MANDIR}/ncdu-plus.1

dist:
	rm -f ncdu-plus-${NCDU_VERSION}.tar.gz
	mkdir ncdu-plus-${NCDU_VERSION}
	for f in `git ls-files | grep -v ^\.gitignore`; do mkdir -p ncdu-plus-${NCDU_VERSION}/`dirname $$f`; ln -s "`pwd`/$$f" ncdu-plus-${NCDU_VERSION}/$$f; done
	tar -cophzf ncdu-plus-${NCDU_VERSION}.tar.gz --sort=name ncdu-plus-${NCDU_VERSION}
	rm -rf ncdu-plus-${NCDU_VERSION}

test:
	zig build test
	mandoc -T lint ncdu-plus.1
	reuse lint
