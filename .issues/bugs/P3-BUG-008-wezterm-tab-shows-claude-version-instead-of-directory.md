---
id: BUG-008
title: "WezTerm tab shows Claude Code version string instead of directory"
type: BUG
priority: P3
status: open
discovered_date: 2026-04-02
discovered_by: capture-issue
---

# BUG-008: WezTerm tab shows Claude Code version string instead of directory

## Summary

When Claude Code is the foreground process in a WezTerm pane, the tab label displays
the Claude Code version string (e.g. "2.1.90") instead of the current working directory.
The expected behavior is for the directory to remain as the tab label with the claude
Nerd Font glyph icon indicating Claude Code is active.

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
- **Location**: `PROC_ICONS` (line ~620), `SHELL_PROCS` (line ~705), `format-tab-title` handler (line ~751–761)
- **Explanation**: The Claude Code CLI process does not use "claude" as its process
  basename — it uses its version string. The existing `claude` mapping in `PROC_ICONS`
  is therefore never matched. A pattern-based match (or adding the process to
  `SHELL_PROCS` by matching against a known path prefix) is needed.

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

## Related Key Documentation

_No documents linked. Run `/ll:normalize-issues` to discover and link relevant docs._

## Labels

`bug`, `wezterm`, `tab-bar`, `captured`

---

## Session Log
- `/ll:capture-issue` - 2026-04-02T00:00:00Z - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/6ae3c0ca-163f-4128-a534-8f067ecbb3f4.jsonl`

---

## Status

**Open** | Created: 2026-04-02 | Priority: P3
