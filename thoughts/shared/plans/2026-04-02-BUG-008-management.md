---
issue_id: BUG-008
issue_type: bug
action: fix
created: 2026-04-02
status: implemented
---

# BUG-008 Fix Plan: WezTerm tab shows Claude version instead of directory

## Problem

Claude Code CLI sets its process title to its version string (e.g. "2.1.90").
WezTerm's `format-tab-title` handler extracts the basename from
`pane.foreground_process_name`, yielding "2.1.90" instead of "claude". This
means:
- `PROC_ICONS["2.1.90"]` returns nil -> falls back to DEFAULT_ICON
- `SHELL_PROCS["2.1.90"]` returns nil -> shows process name as label instead of CWD

## Solution

Two targeted changes in `wezterm/.wezterm.lua`:

### Change 1: Add `claude` to `SHELL_PROCS` (line 705)

So that when Claude Code is detected, the tab shows CWD as the label (same
behavior as an idle shell).

### Change 2: Path-based Claude detection (after line 753)

After extracting `proc` from the basename, check if `proc_name` (the full path)
contains `/claude` or `claude-code`. If so, normalize `proc` to `"claude"` before
the `PROC_ICONS` and `SHELL_PROCS` lookups.

Uses `%-` to escape the `-` in the Lua pattern for `claude-code`.

## Verification

- Manual: Launch WezTerm, run `claude`, verify tab shows CWD with magic wand glyph.
- No automated tests (WezTerm Lua config has no test suite).

## Success Criteria

- [x] `SHELL_PROCS` includes `claude = true`
- [x] Path-based detection normalizes version-string proc to "claude"
- [x] Existing `PROC_ICONS["claude"]` entry (line 627) is reached
- [x] Tab label shows CWD, icon shows magic wand glyph
