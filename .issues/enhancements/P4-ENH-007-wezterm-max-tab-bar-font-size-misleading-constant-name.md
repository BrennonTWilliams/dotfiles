---
id: ENH-007
title: "WezTerm MAX_TAB_BAR_FONT_SIZE constant name is misleading"
type: ENH
priority: P4
status: open
discovered_date: 2026-04-02
discovered_by: capture-issue
---

# ENH-007: WezTerm MAX_TAB_BAR_FONT_SIZE constant name is misleading

## Summary

The constant `MAX_TAB_BAR_FONT_SIZE = 36.0` is assigned directly to `window_frame.font_size`, making it the actual size, not a cap. The name implies it is a ceiling value. On Retina displays, 36.0 renders at ~72pt, producing a very tall tab bar.

## Context

Identified from WezTerm config audit of `wezterm/.wezterm.lua`.

**Affected lines:** 53-60

The name `MAX_TAB_BAR_FONT_SIZE` suggests the original intent was to express a maximum constraint, but it is used as a direct assignment with no capping logic. This is a naming clarity issue and potentially an oversized tab bar on HiDPI displays.

## Motivation

Clear constant naming prevents future confusion when the config is read or modified. If the intent is a fixed large size for a specific aesthetic, the name should reflect that. If it was meant as a cap, the value should be reduced and applied via comparison logic.

## Proposed Change

Pick one:

**Option A (rename):** Rename to `TAB_BAR_FONT_SIZE` and add a comment documenting the intentional large size:

```lua
local TAB_BAR_FONT_SIZE = 36.0  -- intentionally large; scales with DPI on Retina
```

**Option B (fix value):** Reduce to a standard size and apply directly:

```lua
local TAB_BAR_FONT_SIZE = 12.0
config.window_frame = { font_size = TAB_BAR_FONT_SIZE, ... }
```

## Related Key Documentation

_No documents linked. Run `/ll:normalize-issues` to discover and link relevant docs._

## Labels

`enhancement`, `wezterm`, `style`, `captured`

---

## Status

**Open** | Created: 2026-04-02 | Priority: P4

## Session Log
- `/ll:verify-issues` - 2026-04-02T20:39:21 - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/9775816b-44ad-40d3-9b00-80f45de24809.jsonl`
- `/ll:capture-issue` - 2026-04-02T00:00:00Z - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/0ad6fe06-8b2c-44d9-a393-bd64f9cb44fb.jsonl`
