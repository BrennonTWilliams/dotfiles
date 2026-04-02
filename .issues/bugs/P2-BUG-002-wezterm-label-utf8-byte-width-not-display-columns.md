---
id: BUG-002
title: "WezTerm tab title uses UTF-8 byte length instead of display column width"
type: BUG
priority: P2
status: open
discovered_date: 2026-04-02
discovered_by: capture-issue
---

# BUG-002: WezTerm tab title uses UTF-8 byte length instead of display column width

## Summary

In the `format-tab-title` event handler, `#label` is used to measure string width, but Lua's `#` operator returns UTF-8 byte count, not display column width. A single `...` (U+2026) is 3 bytes but 1 display cell, causing incorrect truncation thresholds and broken padding.

## Context

Identified from WezTerm config audit of `wezterm/.wezterm.lua`.

**Affected lines:**
- Line 778: truncation check — `if #label > max_width - reserved then`
- Line 789: padding — `label = label .. string.rep(' ', avail - #label)`

After appending the ellipsis character during truncation, `#label` over-reports the display width by 2 bytes (3 bytes for `...` vs 1 display cell), so:
- Truncation may fire too early for paths with accented or CJK characters
- Padding calculation `avail - #label` can go negative, causing zero padding and misaligned tab titles

## Root Cause

**File:** `wezterm/.wezterm.lua:778,789`

Lua's `#` operator counts raw bytes in a UTF-8 string, not rendered display columns. WezTerm provides `wezterm.column_width()` for this purpose but it is not used in the tab title handler.

## Proposed Fix

Replace all `#label` in the tab title handler with `wezterm.column_width(label)`:

```lua
-- truncation check (line 778)
if wezterm.column_width(label) > max_width - reserved then
    local avail = max_width - reserved - 1
    ...
end

-- padding (line 789)
local lw = wezterm.column_width(label)
if lw < avail then
    label = label .. string.rep(' ', avail - lw)
end
```

## Related Key Documentation

_No documents linked. Run `/ll:normalize-issues` to discover and link relevant docs._

## Labels

`bug`, `wezterm`, `unicode`, `captured`

---

## Status

**Open** | Created: 2026-04-02 | Priority: P2

## Session Log
- `/ll:capture-issue` - 2026-04-02T00:00:00Z - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/0ad6fe06-8b2c-44d9-a393-bd64f9cb44fb.jsonl`
