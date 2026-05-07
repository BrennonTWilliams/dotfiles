---
id: BUG-002
title: "WezTerm tab title uses UTF-8 byte length instead of display column width"
type: BUG
priority: P2
status: completed
discovered_date: 2026-04-02
discovered_by: capture-issue
resolved_date: 2026-04-02
---

# BUG-002: WezTerm tab title uses UTF-8 byte length instead of display column width

## Summary

In the `format-tab-title` event handler, `#label` is used to measure string width, but Lua's `#` operator returns UTF-8 byte count, not display column width. A single `...` (U+2026) is 3 bytes but 1 display cell, causing incorrect truncation thresholds and broken padding.

## Current Behavior

When a tab title contains non-ASCII characters (accented letters, CJK, or the ellipsis U+2026 appended during truncation), `#label` over-reports display width by the difference between byte count and column count. This causes:
- Truncation fires too early for paths containing multi-byte characters
- Padding calculation `avail - #label` can go negative after ellipsis append (3 bytes vs 1 cell), producing zero padding and misaligned tab titles

## Expected Behavior

Tab title truncation and padding should use display column width (`wezterm.column_width(label)`) so that tabs render at consistent widths regardless of character encoding.

## Steps to Reproduce

1. Open WezTerm with the dotfiles config (`wezterm/.wezterm.lua`)
2. Navigate to a directory path containing multi-byte UTF-8 characters (e.g., accented or CJK characters)
3. Open enough tabs to trigger truncation (tab label exceeds `max_width - reserved`)
4. Observe: truncated tab titles are shorter than expected and padding is inconsistent across tabs

## Context

Identified from WezTerm config audit of `wezterm/.wezterm.lua`.

**Affected lines:**
- Line 783: truncation check — `if #label > max_width - reserved then`
- Line 794-795: padding — `if #label < avail then` / `label = label .. string.rep(' ', avail - #label)`

After appending the ellipsis character during truncation, `#label` over-reports the display width by 2 bytes (3 bytes for `...` vs 1 display cell), so:
- Truncation may fire too early for paths with accented or CJK characters
- Padding calculation `avail - #label` can go negative, causing zero padding and misaligned tab titles

## Root Cause

**File:** `wezterm/.wezterm.lua:783,794`
**Anchor:** `in wezterm.on('format-tab-title', ...)` handler (line 739)

Lua's `#` operator counts raw bytes in a UTF-8 string, not rendered display columns. WezTerm provides `wezterm.column_width()` for this purpose but it is not used in the tab title handler.

## Proposed Fix

Replace all `#label` in the tab title handler with `wezterm.column_width(label)`:

```lua
-- truncation check (line 783)
if wezterm.column_width(label) > max_width - reserved then
    local avail = max_width - reserved - 1
    ...
end

-- padding (line 794)
local lw = wezterm.column_width(label)
if lw < avail then
    label = label .. string.rep(' ', avail - lw)
end
```

## Impact

- **Priority**: P2 - Visual misalignment affects usability but not functionality
- **Effort**: Small - Two `#label` references to replace with `wezterm.column_width(label)`
- **Risk**: Low - `wezterm.column_width()` is a stable WezTerm API; change is localized to tab title handler
- **Breaking Change**: No

## Related Key Documentation

_No documents linked. Run `/ll:normalize-issues` to discover and link relevant docs._

## Labels

`bug`, `wezterm`, `unicode`, `captured`

---

## Status

**Open** | Created: 2026-04-02 | Priority: P2

## Resolution

Replaced `#label` (UTF-8 byte count) with `wezterm.column_width(label)` (display column count) at two sites in the `format-tab-title` handler in `wezterm/.wezterm.lua`:

- **Line 783** (truncation check): `if #label > ...` → `if wezterm.column_width(label) > ...`
- **Lines 794-796** (padding): introduced `local lw = wezterm.column_width(label)` and replaced `#label` references with `lw`

`pane_suffix` uses `#` but is always ASCII, so no change needed there.

**Files changed:** `wezterm/.wezterm.lua`

---

## Session Log
- `/ll:ready-issue` - 2026-04-02T22:04:21 - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/a281d939-4fd3-49b4-a124-e4664eb06163.jsonl`
- `/ll:verify-issues` - 2026-04-02T20:39:20 - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/9775816b-44ad-40d3-9b00-80f45de24809.jsonl`
- `/ll:capture-issue` - 2026-04-02T00:00:00Z - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/0ad6fe06-8b2c-44d9-a393-bd64f9cb44fb.jsonl`
