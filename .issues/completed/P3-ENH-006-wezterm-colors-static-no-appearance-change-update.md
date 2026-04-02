---
id: ENH-006
title: "WezTerm terminal colors don't update when macOS appearance changes"
type: ENH
priority: P3
status: open
discovered_date: 2026-04-02
discovered_by: capture-issue
---

# ENH-006: WezTerm terminal colors don't update when macOS appearance changes

## Summary

`config.colors` is set once at startup via `get_colors()`. When the user toggles macOS Dark/Light mode after WezTerm is running, the tab bar colors update (they're recomputed in event handlers) but the terminal body colors do not, creating a visible mismatch.

## Context

Identified from WezTerm config audit of `wezterm/.wezterm.lua`.

**Affected line:** 236

```lua
config.colors = get_colors()
```

Tab bar colors are updated dynamically via `tab_seg_colors()` inside event handlers, so they respond to appearance changes. The terminal body (background, foreground, ANSI palette) is frozen at startup value.

## Current Behavior

`config.colors` is assigned once at startup via `get_colors()` (line 236 of `wezterm/.wezterm.lua`). Subsequent macOS appearance changes (Dark ↔ Light) do not trigger a re-evaluation of `config.colors`, leaving the terminal body background, foreground, and ANSI palette frozen at the startup-time value. The tab bar updates correctly via `tab_seg_colors()` in the `format-tab-title` event handler, producing a visible color mismatch.

## Expected Behavior

When macOS appearance changes between Dark and Light mode, the terminal body colors should update automatically to match the new theme, remaining consistent with the tab bar rendering. No manual config reload (`CMD+R`) should be required.

## Motivation

On macOS, users frequently switch between Dark and Light mode. The current behavior produces a broken state where the tab bar reflects the new theme but the terminal body still shows the old theme. A config reload (`CMD+R`) is needed to fix it, but this is not obvious.

## Proposed Solution

Two options:

**Option A (simple):** Document the limitation — user must reload config (`CMD+R`) after appearance change. Add a comment near line 236 in `get_colors()`.

**Option B (dynamic):** Update colors per-window in `window-config-reloaded`:

```lua
wezterm.on('window-config-reloaded', function(window, _)
    local overrides = window:get_config_overrides() or {}
    overrides.colors = get_colors()
    window:set_config_overrides(overrides)
end)
```

Option B keeps the terminal body in sync automatically.

## Impact

- **Priority**: P3 - Cosmetic mismatch; workaround (`CMD+R`) exists. No data loss or functional breakage.
- **Effort**: Small - Single event handler addition (Option B) or comment clarification (Option A).
- **Risk**: Low - Isolated to color override; does not affect process management, layout, or session state.
- **Breaking Change**: No

## Scope Boundaries

- Out of scope: Changes to any other appearance-driven behavior beyond terminal body colors
- Out of scope: Changes to tmux integration or cross-platform color logic
- Out of scope: Custom color scheme support; only the existing `get_colors()` dark/light toggle is in scope

## Related Key Documentation

_No documents linked. Run `/ll:normalize-issues` to discover and link relevant docs._

## Labels

`enhancement`, `wezterm`, `colors`, `macos`, `captured`

---

## Resolution

**Implemented Option B** — added a `window-config-reloaded` event handler in `wezterm/.wezterm.lua` that applies `get_colors()` as a per-window config override:

```lua
wezterm.on('window-config-reloaded', function(window, _)
  local overrides = window:get_config_overrides() or {}
  overrides.colors = get_colors()
  window:set_config_overrides(overrides)
end)
```

WezTerm fires `window-config-reloaded` automatically when macOS appearance changes, so terminal body colors now update in sync with the tab bar without requiring `CMD+R`.

**File changed**: `wezterm/.wezterm.lua` — inserted handler after `close-window` (line ~826)

---

## Status

**Completed** | Created: 2026-04-02 | Resolved: 2026-04-02 | Priority: P3

## Session Log
- `hook:posttooluse-git-mv` - 2026-04-02T22:17:48 - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/d65f7794-6bcc-4910-a54f-8fc2995c21f7.jsonl`
- `/ll:manage-issue` - 2026-04-02T00:00:00Z - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/ffa0ade2-393c-4aba-aca8-cb1bef19cf42.jsonl`
- `/ll:ready-issue` - 2026-04-02T22:16:00 - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/f00a2bee-1a1b-4a07-a2a4-a9a4cc6fed6d.jsonl`
- `/ll:verify-issues` - 2026-04-02T20:39:21 - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/9775816b-44ad-40d3-9b00-80f45de24809.jsonl`
- `/ll:capture-issue` - 2026-04-02T00:00:00Z - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/0ad6fe06-8b2c-44d9-a393-bd64f9cb44fb.jsonl`
