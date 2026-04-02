---
id: ENH-001
title: "WezTerm tab bar dynamic width with max-height constraint"
type: ENH
priority: P3
status: open
discovered_date: 2026-04-02
discovered_by: capture-issue
---

# ENH-001: WezTerm tab bar dynamic width with max-height constraint

## Summary

Refactor `wezterm/.wezterm.lua` to make tabs dynamically size so they fill the full horizontal width of the tab bar, while capping the tab bar at a configurable maximum height. Currently tabs have a fixed `tab_max_width` of 256 chars and a fixed `window_frame.font_size` of 20.0; they do not expand to fill available horizontal space or constrain bar height.

## Current Behavior

- `config.tab_max_width = 256` sets a hard upper cap on each tab's character width but tabs never expand to share the available bar space evenly.
- `config.window_frame.font_size = 20.0` controls tab bar height but is a static value — there is no ceiling that prevents the bar from growing taller than desired.
- When many tabs are open the bar can show partially-filled or crowded tabs rather than using the full available width.

## Expected Behavior

- Tabs dynamically expand to fill the full horizontal width of the window.
- The tab bar height never exceeds a configurable maximum (e.g., capped via font size or explicit height constraint), preventing it from consuming excessive vertical screen space.
- The `format-tab-title` callback respects the available width per tab and distributes space evenly across open tabs.

## Motivation

The current fixed-width tab configuration wastes horizontal screen space when few tabs are open and crowds tabs when many are open. A dynamic layout would make the tab bar behave more like a native macOS tab bar — always filling available width — while the max-height cap prevents font size from ballooning on large displays.

## Proposed Solution

TBD - requires investigation

Key areas to explore:
- `wezterm.on('format-tab-title', ...)` already receives `max_width` — compute per-tab allocation as `window_width / tab_count` and pass that as the constraint.
- `config.window_frame.font_size` controls bar height implicitly; derive it from a desired max-height constant rather than a hard-coded value.
- WezTerm does not expose a native "fill width" tab mode, so the dynamic sizing must be implemented inside `format-tab-title` using the `max_width` argument and tab count.

## Integration Map

### Files to Modify
- `wezterm/.wezterm.lua` — `format-tab-title` event handler, `window_frame` config, `tab_max_width` setting

### Dependent Files (Callers/Importers)
- N/A — single-file config, no imports

### Similar Patterns
- Existing `format-tab-title` handler (line ~737) already truncates labels using `max_width`; extend this logic

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

- `/ll:capture-issue` - 2026-04-02T00:00:00Z - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/7dcd24c1-5a67-4937-b9e8-89c99fc67aef.jsonl`

---

**Open** | Created: 2026-04-02 | Priority: P3
