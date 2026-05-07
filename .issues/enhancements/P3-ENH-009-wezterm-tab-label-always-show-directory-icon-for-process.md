---
discovered_date: 2026-04-02
discovered_by: capture-issue
---

# ENH-009: WezTerm Tab Label Always Show Directory, Icon for Running Process

## Summary

WezTerm tab labels currently change to reflect the running process name when a process is active (e.g., `nvim`, `git`, etc.). The label should always display the current working directory. Running processes should only influence the Nerd Font glyph/icon shown in the tab, not the text label.

## Context

**Direct mode**: User description: "Currently, our wezterm tabs labels change if theres a running process, etc. These labels should always show the directory as they do currently when no process is running. Running processes etc should instead only change the Nerd Font Glyph icon shown in the tab"

The current tab formatting logic mixes process state into the label text. The desired UX separates concerns: directory = label text, process state = icon only.

## Motivation

Having the directory always visible in the tab label gives consistent spatial orientation across the tab bar. When tabs silently rename to the running process, users lose track of which directory a tab is in. The icon is a sufficient and less disruptive indicator of what is running.

## Current Behavior

- Tab label shows directory when no process is running
- Tab label changes to process name (e.g., `nvim`, `python`, `claude`) when a foreground process is active

## Expected Behavior

- Tab label always shows current working directory (no change from idle state)
- Nerd Font glyph icon in the tab changes to reflect the running process
- Directory label remains stable regardless of foreground process

## Integration Map

### Files to Modify
- `wezterm/.wezterm.lua` — single-file config; tab title logic lives in the `format-tab-title` event handler at line 741

### Dependent Files (Callers/Importers)
- None — `format-tab-title` is a WezTerm event callback, not called by other Lua code in the repo

### Similar Patterns
- `wezterm/.wezterm.lua:762–763` — the `SHELL_PROCS` branch already uses `short_path(pane.current_working_dir)` for the idle-shell case; the fix simply applies this same path to the non-shell branch

### Tests
- N/A - WezTerm Lua config has no automated test suite

### Documentation
- N/A

### Configuration
- N/A

### Codebase Research Findings

_Added by `/ll:refine-issue` — based on codebase analysis:_

- `wezterm/.wezterm.lua:622–704` — `PROC_ICONS` table already maps 40+ processes to Nerd Font glyphs (nvim, git, python, claude, docker, etc.) — no new mappings needed
- `wezterm/.wezterm.lua:705` — `DEFAULT_ICON` fallback: `\u{f489}` (nf-fa-terminal)
- `wezterm/.wezterm.lua:707` — `SHELL_PROCS` table `{ zsh, bash, fish, sh, claude }` — becomes dead code after the fix since the label will always be the directory regardless of process
- `wezterm/.wezterm.lua:710–719` — `short_path(cwd_uri)` function already exists; shortens paths to `~/a/b` form (last 2 components); used in the idle-shell case today
- `wezterm/.wezterm.lua:741–821` — `format-tab-title` event handler: full tab label rendering pipeline
- `wezterm/.wezterm.lua:746–768` — label resolution block: the bug is isolated to lines 765–767 (the `else` branch sets `label = proc` instead of `short_path(...)`)
- `wezterm/.wezterm.lua:782–799` — truncation logic: already handles `is_path = true` (clips from left with `…/dirname`) vs `is_path = false` (clips from right); setting `is_path = true` in the fix gets correct truncation behavior for free

## Implementation Steps

1. In `wezterm/.wezterm.lua` at line 765, change `label = proc` → `label = short_path(pane.current_working_dir)` and on line 766 change `is_path = false` → `is_path = true`
2. Remove (or comment out) the `SHELL_PROCS` table at line 707 and the `if SHELL_PROCS[proc] then ... else` conditional at lines 762–768, collapsing to a single assignment — both branches now have the same label logic
3. Leave the `icon = PROC_ICONS[proc] or DEFAULT_ICON` assignment at line 761 untouched — icon selection already works correctly
4. Optionally remove `claude` from `PROC_ICONS` if it was only there to make claude behave like a shell proc (it is genuinely in PROC_ICONS for its wand icon, so keep it)
5. Load WezTerm and open tabs running `nvim`, `git log`, `python3` — verify label stays as the directory while the icon changes per process

## Scope Boundaries

- **In scope**: Decoupling tab label text from running process name; routing process detection to icon/glyph selection only; mapping common foreground processes (nvim, git, python, claude) to Nerd Font glyphs
- **Out of scope**: Adding new process-to-glyph mappings beyond commonly used ones; changing tab bar layout or other visual properties; altering session resurrection or tab persistence logic

## API/Interface

N/A - No public API changes (internal WezTerm Lua config only)

## Impact

- **Priority**: P3 - Low-urgency UX improvement; reduces cognitive overhead when tracking directory context across multiple tabs
- **Effort**: Small - Localised change to tab title formatting logic in a single Lua file
- **Risk**: Low - Tab label display is isolated from session state and persistence logic
- **Breaking Change**: No

## Related Key Documentation

_No documents linked. Run `/ll:normalize-issues` to discover and link relevant docs._

## Labels

`enhancement`, `wezterm`, `captured`

---

## Status

**Open** | Created: 2026-04-02 | Priority: P3

## Session Log
- `/ll:refine-issue` - 2026-04-02T22:42:57 - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/87e55059-d7ad-48b4-a4c8-deff5ec1c337.jsonl`
- `/ll:format-issue` - 2026-04-02T22:20:58 - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/26af31df-ef62-49ac-85fc-be5aa87d9c17.jsonl`
- `/ll:capture-issue` - 2026-04-02T00:00:00Z - `~/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/4abda147-9d9a-47dc-888a-fc02a8e5726e.jsonl`
