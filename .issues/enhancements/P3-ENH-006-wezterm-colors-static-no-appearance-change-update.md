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

**Affected line:** 235

```lua
config.colors = get_colors()  -- called once at startup
```

Tab bar colors are updated dynamically via `tab_seg_colors()` inside event handlers, so they respond to appearance changes. The terminal body (background, foreground, ANSI palette) is frozen at startup value.

## Motivation

On macOS, users frequently switch between Dark and Light mode. The current behavior produces a broken state where the tab bar reflects the new theme but the terminal body still shows the old theme. A config reload (`CMD+R`) is needed to fix it, but this is not obvious.

## Proposed Change

Two options:

**Option A (simple):** Document the limitation — user must reload config (`CMD+R`) after appearance change. Add a comment near line 235.

**Option B (dynamic):** Update colors per-window in `window-config-reloaded`:

```lua
wezterm.on('window-config-reloaded', function(window, _)
    local overrides = window:get_config_overrides() or {}
    overrides.colors = get_colors()
    window:set_config_overrides(overrides)
end)
```

Option B keeps the terminal body in sync automatically.

## Related Key Documentation

_No documents linked. Run `/ll:normalize-issues` to discover and link relevant docs._

## Labels

`enhancement`, `wezterm`, `colors`, `macos`, `captured`

---

## Status

**Open** | Created: 2026-04-02 | Priority: P3

## Session Log
- `/ll:capture-issue` - 2026-04-02T00:00:00Z - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/0ad6fe06-8b2c-44d9-a393-bd64f9cb44fb.jsonl`
