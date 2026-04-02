---
id: ENH-001
title: "WezTerm tab bar dynamic width with max-height constraint"
type: ENH
priority: P3
status: completed
discovered_date: 2026-04-02
discovered_by: capture-issue
---

# ENH-001: WezTerm tab bar dynamic width with max-height constraint

## Summary

Refactor `wezterm/.wezterm.lua` to make tabs dynamically size so they fill the full horizontal width of the tab bar, while capping the tab bar at a configurable maximum height. Currently tabs have a fixed `tab_max_width` of 256 chars and a fixed `window_frame.font_size` of 20.0; they do not expand to fill available horizontal space or constrain bar height.

## Current Behavior

- `config.tab_max_width = 256` sets a hard upper cap on each tab's character width but tabs never expand to share the available bar space evenly.
- `config.window_frame.font_size = 24.0` controls tab bar height but is a static value — there is no ceiling that prevents the bar from growing taller than desired.
- When many tabs are open the bar can show partially-filled or crowded tabs rather than using the full available width.

## Expected Behavior

- Tabs dynamically expand to fill the full horizontal width of the window.
- The tab bar height never exceeds a configurable maximum (e.g., capped via font size or explicit height constraint), preventing it from consuming excessive vertical screen space.
- The `format-tab-title` callback respects the available width per tab and distributes space evenly across open tabs.

## Motivation

The current fixed-width tab configuration wastes horizontal screen space when few tabs are open and crowds tabs when many are open. A dynamic layout would make the tab bar behave more like a native macOS tab bar — always filling available width — while the max-height cap prevents font size from ballooning on large displays.

## Success Metrics

- **Width utilization**: Tab bar fills 100% of available window width with any number of open tabs (1, 3, 8+)
- **Height constraint**: Tab bar height does not exceed `MAX_TAB_BAR_HEIGHT` constant (to be defined); no vertical overflow regardless of display size
- **Badge integrity**: Pane-count badge and activity indicator remain visible at the narrowest computed per-tab width
- **Cross-theme**: Layout holds in both Gruvbox dark and light themes

## Proposed Solution

TBD - requires investigation

Key areas to explore:
- `wezterm.on('format-tab-title', ...)` already receives `max_width` — compute per-tab allocation as `window_width / tab_count` and pass that as the constraint.
- `config.window_frame.font_size` controls bar height implicitly; derive it from a desired max-height constant rather than a hard-coded value.
- WezTerm does not expose a native "fill width" tab mode, so the dynamic sizing must be implemented inside `format-tab-title` using the `max_width` argument and tab count.

### Codebase Research Findings

_Added by `/ll:refine-issue` — based on codebase analysis:_

**Critical: `window` object is NOT available in `format-tab-title`.** The premise of computing `window_width / tab_count` using pixel dimensions is blocked — the `format-tab-title` callback receives `(tab, tabs, panes, cfg, hover, max_width)` only (line 737). A `window` object is only available in `update-left-status` (line 595) and `update-right-status` (line 604).

**The correct fill mechanism**: WezTerm already computes a per-tab `max_width` character budget based on `tab_max_width` (line 53) and distributes available bar space. The current handler only **truncates** when content exceeds `max_width` (lines 772-783) — it never pads when content is shorter. Adding padding to fill exactly `max_width` characters creates the visual fill effect without needing pixel dimensions.

**Dynamic width implementation approach:**
1. After the existing truncation block at lines 772-783, pad the label string with spaces to reach `max_width - reserved` chars (mirror the existing `reserved` budget already calculated at line 775).
2. `tabs` is already in scope at line 737 and never read — `#tabs` gives tab count immediately if per-tab calculations are needed.
3. `tab_max_width = 256` at line 53 is already large enough to let WezTerm distribute space generously; the key change is filling the allocated space, not computing new widths.

**Max-height constraint implementation approach:**
1. Introduce a `MAX_TAB_BAR_FONT_SIZE` constant near line 618, following the established ALLCAPS pattern (see `PROC_ICONS`, `DEFAULT_ICON`, `SHELL_PROCS` at lines 618-703).
2. Replace `font_size = 24.0` literal at line 57 with the constant.

## Integration Map

### Files to Modify
- `wezterm/.wezterm.lua` — `format-tab-title` event handler (line 737), `window_frame` config (lines 54-58), `tab_max_width` setting (line 53)

### Dependent Files (Callers/Importers)
- N/A — single-file config, no imports

### Similar Patterns
- Existing `format-tab-title` handler at `wezterm/.wezterm.lua:737` already truncates labels using `max_width`; pad logic mirrors the same `reserved` budget at line 775
- ALLCAPS constant pattern at `wezterm/.wezterm.lua:618-703` (PROC_ICONS, DEFAULT_ICON, SHELL_PROCS) — new `MAX_TAB_BAR_FONT_SIZE` constant should follow this pattern
- `tab_seg_colors()` helper at `wezterm/.wezterm.lua:718-734` shows the `local function` declaration style used for tab helpers

### Tests
- N/A — no bats tests for WezTerm config; manual visual verification

### Documentation
- N/A

### Configuration
- `config.tab_max_width` — may be replaced or supplemented by computed per-tab width
- `config.window_frame.font_size` — may become a derived value from a max-height constant

## Implementation Steps

1. Research WezTerm `format-tab-title` API to confirm available window-width metadata
2. Implement per-tab width calculation in `format-tab-title` based on `tab_count` and available bar width
3. Introduce a `MAX_TAB_BAR_HEIGHT` constant and derive `window_frame.font_size` from it
4. Verify layout visually with 1, 3, and 8+ open tabs in both dark and light themes
5. Confirm the pane-count badge and activity dot still render correctly at computed widths

### Codebase Research Findings

_Added by `/ll:refine-issue` — based on codebase analysis:_

Step 1 is resolved: `window` object is NOT available in `format-tab-title`; use the `max_width` argument instead.

Concrete steps:
1. Add `MAX_TAB_BAR_FONT_SIZE = 24.0` constant near `wezterm/.wezterm.lua:618` (ALLCAPS constant block), replacing the `24.0` literal at line 57.
2. In `format-tab-title` at line 737, after the truncation block (lines 772-783), add padding: compute `avail = max_width - reserved` and right-pad `label` with spaces to fill the full allocation. The `reserved` variable at line 775 already calculates the correct chrome budget.
3. Optionally read `#tabs` at line 737 to adjust minimum label width guarantees (badge and activity dot must remain visible — see `reserved` budget at line 775 and `pane_suffix` at line 764).
4. Verify visually: `wezterm.reload_configuration()` (live reload — no restart needed).

## Impact

- **Priority**: P3 - Quality-of-life improvement; no functional breakage
- **Effort**: Small - Contained to a single Lua config file; leverages existing `format-tab-title` callback
- **Risk**: Low - WezTerm reloads config live; rollback is instant
- **Breaking Change**: No

## Scope Boundaries

- Out of scope: changing tab bar position (already set to top), adding new tab bar widgets, or modifying color scheme
- Out of scope: cross-platform behavior differences (Linux WezTerm)

## Related Key Documentation

_No documents linked. Run `/ll:normalize-issues` to discover and link relevant docs._

## Labels

`enhancement`, `wezterm`, `ui`, `captured`

## Session Log
- `/ll:ready-issue` - 2026-04-02T05:44:21 - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/5c5169d8-c09f-4089-a670-ee8c210c6d7c.jsonl`
- `/ll:refine-issue` - 2026-04-02T05:39:36 - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/b0315865-e73d-481b-ac79-839efb10b073.jsonl`
- `/ll:format-issue` - 2026-04-02T05:33:34 - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/fb275c31-f7ba-4219-a244-dce20c695451.jsonl`

- `/ll:capture-issue` - 2026-04-02T00:00:00Z - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/7dcd24c1-5a67-4937-b9e8-89c99fc67aef.jsonl`

## Resolution

**Status**: Completed  
**Resolved**: 2026-04-02

### Changes Made

- `wezterm/.wezterm.lua`: Added `local MAX_TAB_BAR_FONT_SIZE = 24.0` constant before `config.window_frame`, replacing the hardcoded `24.0` literal — caps bar height via a named constant.
- `wezterm/.wezterm.lua`: Added label padding in `format-tab-title` after the truncation block — pads label with spaces to fill the full `max_width - reserved` allocation, making each tab expand to use its share of available bar width.

### Verification

Manual visual verification required: reload with `wezterm.reload_configuration()` and inspect with 1, 3, and 8+ tabs open in both dark and light themes.

---

- `/ll:manage-issue` implement - 2026-04-02T00:00:00Z - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/ffa0ade2-393c-4aba-aca8-cb1bef19cf42.jsonl`

---

**Completed** | Created: 2026-04-02 | Resolved: 2026-04-02 | Priority: P3
