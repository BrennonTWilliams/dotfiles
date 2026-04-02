---
id: ENH-007
title: "WezTerm MAX_TAB_BAR_FONT_SIZE constant name is misleading"
type: ENH
priority: P4
status: completed
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

## Current Behavior

`MAX_TAB_BAR_FONT_SIZE = 36.0` is defined at line 53 and assigned directly to `config.window_frame.font_size` at line 59 with no capping logic. The name implies a ceiling value but it functions as a fixed size. The existing comment (`-- Maximum font size for tab bar — caps bar height regardless of display size`) reinforces the misleading framing.

## Expected Behavior

The constant name accurately reflects its role. If it is a fixed intentional size, it is renamed to `TAB_BAR_FONT_SIZE` with a comment clarifying intent. If a cap was the original intent, the value is reduced and capping logic is applied.

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

## Scope Boundaries

- Only the constant name and associated comment in `wezterm/.wezterm.lua`
- Does not include adjusting the actual font size value unless Option B is chosen
- No changes to other WezTerm configuration files or stow packages

## Impact

- **Priority**: P4 - Naming clarity only; no functional impact on runtime behavior
- **Effort**: Small - Single constant rename in one file plus optional comment update
- **Risk**: Low - Non-functional rename under Option A; no behavioral change unless Option B is chosen
- **Breaking Change**: No

## Related Key Documentation

_No documents linked. Run `/ll:normalize-issues` to discover and link relevant docs._

## Labels

`enhancement`, `wezterm`, `style`, `captured`

---

## Resolution

**Option A implemented.** Renamed `MAX_TAB_BAR_FONT_SIZE` to `TAB_BAR_FONT_SIZE` in `wezterm/.wezterm.lua`. Removed the misleading "caps bar height" comment and replaced with a two-line block clarifying that 36.0 is intentional and explains the HiDPI rendering context. Value unchanged; no behavioral change.

**Files changed:** `wezterm/.wezterm.lua` (lines 52-60)

---

## Status

**Completed** | Created: 2026-04-02 | Completed: 2026-04-02 | Priority: P4

## Session Log
- `/ll:manage-issue` - 2026-04-02T00:00:00Z - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/6c9682cc-d11c-4bc9-a938-ff814d01e412.jsonl`
- `/ll:ready-issue` - 2026-04-02T22:19:43 - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/6c9682cc-d11c-4bc9-a938-ff814d01e412.jsonl`
- `/ll:verify-issues` - 2026-04-02T20:39:21 - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/9775816b-44ad-40d3-9b00-80f45de24809.jsonl`
- `/ll:capture-issue` - 2026-04-02T00:00:00Z - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/0ad6fe06-8b2c-44d9-a393-bd64f9cb44fb.jsonl`
