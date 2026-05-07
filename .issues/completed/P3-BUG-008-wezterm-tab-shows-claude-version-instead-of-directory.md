---
id: BUG-008
title: "WezTerm tab shows Claude Code version string instead of directory"
type: BUG
priority: P3
status: fixed
discovered_date: 2026-04-02
discovered_by: capture-issue
confidence_score: 100
outcome_confidence: 75
---

# BUG-008: WezTerm tab shows Claude Code version string instead of directory

## Summary

When Claude Code is the foreground process in a WezTerm pane, the tab label displays
the Claude Code version string (e.g. "2.1.90") instead of the current working directory.
The expected behavior is for the directory to remain as the tab label with the claude
Nerd Font glyph icon indicating Claude Code is active.

## Current Behavior

When Claude Code is the foreground process in a WezTerm pane, the tab label displays
the Claude Code version string (e.g., "2.1.90") instead of the current working directory.
The tab icon also reverts to the DEFAULT_ICON (terminal glyph) because "2.1.90" is not
matched in `PROC_ICONS` or `SHELL_PROCS`.

## Expected Behavior

The tab label should display the current working directory (CWD) — the same as when a
shell is the foreground process. The Nerd Font claude glyph icon (`\u{f0d0}`) should
appear to indicate Claude Code is the foreground process.

## Steps to Reproduce

1. Open WezTerm with a terminal pane in any directory.
2. Launch Claude Code: run `claude` in that pane.
3. Observe the WezTerm tab label.
4. **Actual**: Tab label changes to the Claude Code version string (e.g., "2.1.90").
5. **Expected**: Tab label stays as the CWD with the claude glyph icon visible.

## Context

**Direct mode**: User description: "Our wezterm tab labels change to '2.1.90' when
claude code is open. It should keep the directory as the label and instead change the
Nerd Font glyph icon when claude code is open"

The `format-tab-title` handler in `.wezterm.lua` determines labels via process name:
- Shell processes (`SHELL_PROCS`) show CWD as label
- Non-shell processes show the process name as label
- `PROC_ICONS` maps `claude` to the magic wand glyph `\u{f0d0}`

The Claude Code CLI sets its process title to its version string (e.g. "2.1.90"), so
`pane.foreground_process_name` resolves to a path whose basename is "2.1.90" rather
than "claude". Since "2.1.90" is not in `PROC_ICONS` or `SHELL_PROCS`, the tab falls
through to the default: label = process name ("2.1.90"), icon = DEFAULT_ICON (terminal).

## Root Cause

- **File**: `wezterm/.wezterm.lua`
- **Anchor**: `PROC_ICONS` (lines 620–702; `claude` entry at line 627), `SHELL_PROCS` (line 705), `format-tab-title` handler (lines 739–813; process extraction at lines 751–752, icon/label logic at lines 754–761)
- **Cause**: The Claude Code CLI process does not use "claude" as its process
  basename — it uses its version string. The existing `claude` mapping in `PROC_ICONS`
  at line 627 is therefore never reached. A path-based normalization check against
  `proc_name` (the full path, set at line 751) is needed to set `proc = "claude"`
  before the `PROC_ICONS[proc]` lookup at line 754 and the `SHELL_PROCS[proc]` CWD
  branch at line 755.

## Proposed Solution

Two complementary fixes in `wezterm/.wezterm.lua`:

1. **Detect Claude Code by path prefix** rather than basename. In the `format-tab-title`
   handler, after extracting `proc_name`, check if it contains `claude` in the full path
   (e.g. `/.claude/` or `/claude-code/`) and normalize `proc` to `"claude"` before
   looking it up in `PROC_ICONS` / `SHELL_PROCS`.

2. **Add "claude" to `SHELL_PROCS`** so that when Claude Code is detected, the tab
   shows the CWD as the label (same as an idle shell), with the claude glyph icon.

Example patch sketch:
```lua
-- Normalize Claude Code version-string process names to "claude"
if proc_name:find('/claude', 1, true) or proc_name:find('claude-code', 1, true) then
  proc = 'claude'
end
-- Then add claude to SHELL_PROCS so CWD is used as the label:
local SHELL_PROCS = { zsh = true, bash = true, fish = true, sh = true, claude = true }
```

## Implementation Steps

1. Open `wezterm/.wezterm.lua` and locate the `format-tab-title` handler (line 739).
2. After line 752 (where `proc` is extracted via `proc_name:match('([^/\\]+)$')`), insert
   path-based Claude detection before the `PROC_ICONS[proc]` lookup at line 754:
   if `proc_name` contains `claude`, normalize `proc` to `"claude"`.
3. Add `claude = true` to `SHELL_PROCS` at line 705, so CWD is used as the tab label
   when Claude Code is the foreground process.
4. Launch WezTerm, run `claude`, and verify the tab shows CWD with the claude glyph icon.

## Integration Map

### Files to Modify
- `wezterm/.wezterm.lua:705` — add `claude = true` to `SHELL_PROCS`
- `wezterm/.wezterm.lua:752` — insert Claude path-normalization logic after this line, before `PROC_ICONS` lookup at line 754

### Dependent Files (Callers/Importers)
- N/A — standalone WezTerm Lua config; no other files import it

### Similar Patterns
- `wezterm/.wezterm.lua:609` — `hostname:gsub('%..*', '')` normalizes a raw value before display; closest existing analog to the proposed `proc_name` → `proc` normalization
- `wezterm/.wezterm.lua:622–636` — duplicate-key alias pattern (`nvim`/`vim`/`vi`, `python`/`python3`) shows the alternate approach: add multiple keys to `PROC_ICONS` pointing to the same glyph (not used here since the basename is a version string, not a predictable alias)
- `wezterm/.wezterm.lua:491` — `string.match(id, '([a-z]+)/.+')` extracts a prefix from a path-like string — shows mid-string pattern matching precedent

### Codebase Research Findings

_Added by `/ll:refine-issue` — based on codebase analysis:_

- `wezterm/.wezterm.lua:620–702` — `PROC_ICONS` table; `claude` entry already present at line 627 (`'\u{f0d0}'` magic wand glyph) — no new icon entry needed
- `wezterm/.wezterm.lua:703` — `DEFAULT_ICON = '\u{f489}'` (terminal glyph fallback, assigned when `PROC_ICONS[proc]` returns nil)
- `wezterm/.wezterm.lua:705` — `SHELL_PROCS = { zsh = true, bash = true, fish = true, sh = true }` — no `claude` key currently
- `wezterm/.wezterm.lua:751–753` — `proc_name` set from `pane.foreground_process_name`; basename extracted to `proc` via `:match('([^/\\]+)$')`; line 753 fallback `if proc == '' then proc = pane.title end` does NOT fire when Claude Code is running (proc is `"2.1.90"`, not empty); fix can be inserted after line 752 or after line 753 — both are valid since `proc_name` is in scope through both
- `wezterm/.wezterm.lua:754–761` — `PROC_ICONS[proc]` lookup then `SHELL_PROCS[proc]` CWD branch; these are the two lookups that fail when `proc == "2.1.90"`
- **`find` style note**: existing `find` calls in the file use pattern mode without explicit `1, true` (e.g. `appearance:find 'Dark'` at lines 115 and 721). The proposed fix sketch uses `proc_name:find('/claude', 1, true)` (plain-text mode). Both are correct — `/` is not special in Lua patterns so the modes are equivalent here — but implementers may prefer `proc_name:find('/claude')` for style consistency with the rest of the file

### Tests
- N/A — no automated test suite for WezTerm config; manual verification required

### Documentation
- N/A — no docs reference this tab label behavior

### Configuration
- `wezterm/.wezterm.lua` (only config file being changed)

## Impact

- **Priority**: P3 — Cosmetic/UX issue; does not block workflow but causes directory confusion
- **Effort**: Small — Two targeted changes in `SHELL_PROCS` and the `format-tab-title` handler
- **Risk**: Low — Isolated to tab label rendering; no effect on shell behavior or other processes
- **Breaking Change**: No

## Related Key Documentation

- `.issues/bugs/P2-BUG-002-wezterm-label-utf8-byte-width-not-display-columns.md` — related WezTerm tab label bug; touches the same `PROC_ICONS`/`SHELL_PROCS`/`format-tab-title` code path

## Resolution

**Status**: Fixed
**Date**: 2026-04-02
**Approach**: Path-based Claude detection + SHELL_PROCS inclusion

### Changes Made
1. `wezterm/.wezterm.lua:705` -- Added `claude = true` to `SHELL_PROCS` so Claude Code tabs show CWD as label
2. `wezterm/.wezterm.lua:754-758` -- Inserted path-based detection: if `proc_name` contains `/claude` or `claude-code`, normalize `proc` to `"claude"` before `PROC_ICONS`/`SHELL_PROCS` lookups

### Verification
- Lua syntax check (`luac -p`): PASS
- Pre-existing test failures: unrelated (shell integration, tmux, macOS env)
- Manual verification required: launch `claude` in WezTerm, confirm tab shows CWD with magic wand glyph

## Labels

`bug`, `wezterm`, `tab-bar`, `captured`

---

## Session Log
- `/ll:ready-issue` - 2026-04-02T21:29:06 - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/adcb1f16-ad9f-4f3a-aad3-4d16362fbe81.jsonl`
- `/ll:refine-issue` - 2026-04-02T21:22:50 - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/af03b9cd-552d-487e-bd26-9ae2f65f1c3c.jsonl`
- `/ll:confidence-check` - 2026-04-02T22:00:00 - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/af03b9cd-552d-487e-bd26-9ae2f65f1c3c.jsonl`
- `/ll:refine-issue` - 2026-04-02T21:19:14 - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/af03b9cd-552d-487e-bd26-9ae2f65f1c3c.jsonl`
- `/ll:confidence-check` - 2026-04-02T00:00:00Z - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/af03b9cd-552d-487e-bd26-9ae2f65f1c3c.jsonl`
- `/ll:refine-issue` - 2026-04-02T21:12:46 - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/af03b9cd-552d-487e-bd26-9ae2f65f1c3c.jsonl`
- `/ll:format-issue` - 2026-04-02T21:09:21 - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/ff8d0feb-3f19-4156-9d91-925ec91a6803.jsonl`
- `/ll:capture-issue` - 2026-04-02T00:00:00Z - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/6ae3c0ca-163f-4128-a534-8f067ecbb3f4.jsonl`

---

## Status

**Open** | Created: 2026-04-02 | Priority: P3
