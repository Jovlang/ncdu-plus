# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Build (release)
make
# or: zig build --release=fast -Dstrip

# Build (debug)
make debug
# or: zig build

# Run tests + lint (man page, REUSE license)
make test
# or just unit tests: zig build test

# Run after debug build
zig build run -- [args]
# or: ./zig-out/bin/ncdu [args]

# Install
sudo make install PREFIX=/usr
```

## Architecture

ncdu is a disk usage analyzer TUI written in Zig. The core pattern is **source → sink → model → browser**.

### Data flow

**Scan:** `scan.zig` (filesystem walker) → `sink.zig` (generic aggregation API, progress tracking) → `mem_sink.zig` → `model.zig` (in-memory tree of `Dir`/`File`/`Link` entries)

**Import:** `json_import.zig` or `bin_reader.zig` → `mem_src.zig` → `sink.zig` → `model.zig`

**Export:** `model.zig` → `json_export.zig` (human-readable, optional zstd) or `bin_export.zig` (CBOR-based binary)

**Display:** `model.zig` → `browser.zig` (sorting, filtering, cursor) → `ui.zig` (ncurses wrappers) → terminal

### Key files

- **main.zig** — entry point, argument parsing, config loading, state machine
- **browser.zig** — interactive TUI directory browser (sorting, selection, extended info)
- **ui.zig** — ncurses wrappers, drawing primitives, formatting (`fmtsize`, `shorten`)
- **model.zig** — core data structures; packed structs for memory efficiency; hardlink/device tracking
- **sink.zig** — generic source/sink interface used by all scan and import paths
- **scan.zig** — recursive filesystem scanner with exclude, symlink, cross-device, and thread support
- **exclude.zig** — glob/rsync-style pattern matching engine
- **delete.zig** — safe deletion with confirmation dialogs
- **c.zig** — C FFI declarations (ncurses, zstd, POSIX)

### Application state machine (main.zig)

States: `scan`, `browse`, `refresh`, `shell`, `editor`, `open_file`, `delete`

Transitions all go through `browse` as the hub state.

### This fork's changes vs upstream

Added/changed keybindings in `browser.zig`:
- `d` — send selected item to trash via `gio trash` (confirm dialog says "Confirm trash")
- `D` — delete selected item directly (was upstream's `d`; confirm dialog says "Confirm delete")
- `e` — open selected item in `$EDITOR`
- `f` — open selected item with system opener (`open` / `xdg-open`)
- `y` — copy selected item's full path to clipboard (`wl-copy` on Wayland, else `xclip -selection clipboard`, else `xsel --clipboard --input`); shows "Copied: <path>" message
- `H` — toggle hidden/excluded files (remapped from upstream's `e`)

Trash vs delete use separate "don't ask again" flags (`config.confirm_trash` / `config.confirm_delete`) so suppressing one confirmation does not affect the other. The `delete.trash_mode` bool in `delete.zig` controls which path `delete()` takes and which dialog wording is shown.

Added `--color modern` scheme (`src/ui.zig`, `src/main.zig`): a 256-color palette using muted blues and grays. Color scheme structs in `ui.zig` have an added `modern: StyleAttr` field alongside the existing `off`/`dark`/`darkbg` fields. The `config.ui_color` enum in `main.zig` has a corresponding `modern` variant.

## Notes

- Zig version: 0.14 or 0.15 (see `build.zig.zon`)
- Unit tests live inline in source files as `test` blocks
- The `make test` target also runs `mandoc -T lint` on the man page and `reuse lint` for license compliance
