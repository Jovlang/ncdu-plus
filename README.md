<!--
SPDX-FileCopyrightText: Yorhel <projects@yorhel.nl>
SPDX-License-Identifier: MIT
-->

# ncdu-zig (fork)

## Fork changes

- `d` — send the selected item to trash (via `gio trash`)
- `D` — delete the selected item directly (was `d` upstream)
- `e` — open the selected item with `$EDITOR`
- `f` — open the selected item with `open(1)`, falling back to `xdg-open`
- `y` — copy the selected item's path to the clipboard (via `wl-copy`, `xclip`, or `xsel`)
- `H` — show/hide hidden and excluded files (was `e` upstream)
- `i` — item info panel now shows a `file(1)` description in the Type row instead of the generic "File/Other" label
- `I` — open a scrollable `mediainfo` pager for the selected file (`j`/`k`, PgUp/PgDn to scroll; `q` or `I` to close)
- `--color modern` — a 256-color scheme using muted blues and grays instead of the default cyan/green/yellow palette

## Description

Ncdu is a disk usage analyzer with an ncurses interface. It is designed to find
space hogs on a remote server where you don't have an entire graphical setup
available, but it is a useful tool even on regular desktop systems. Ncdu aims
to be fast, simple and easy to use, and should be able to run in any minimal
POSIX-like environment with ncurses installed.

See the [ncdu 2 release announcement](https://dev.yorhel.nl/doc/ncdu2) for
information about the differences between this Zig implementation (2.x) and the
C version (1.x).

## Requirements

- Zig 0.14 or 0.15
- Some sort of POSIX-like OS
- ncurses (`libncurses-dev` on Debian/Ubuntu, `ncurses-devel` on Fedora/RHEL)
- libzstd (`libzstd-dev` on Debian/Ubuntu, `libzstd-devel` on Fedora/RHEL)

## Install

You can use the Zig build system if you're familiar with that.

There's also a handy Makefile that supports the typical targets, e.g.:

```
make
sudo make install PREFIX=/usr
```
