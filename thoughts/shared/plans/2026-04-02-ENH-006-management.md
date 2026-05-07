# ENH-006 Implementation Plan: Dynamic Terminal Color Updates on macOS Appearance Change

## Issue Summary

`config.colors` is set once at startup via `get_colors()` (line 236 of `wezterm/.wezterm.lua`). When macOS appearance toggles Dark ↔ Light after WezTerm is running, the tab bar updates (via `tab_seg_colors()` in `format-tab-title`) but the terminal body colors remain frozen, creating a visible mismatch.

## Solution: Option B — Dynamic per-window override via `window-config-reloaded`

WezTerm fires `window-config-reloaded` when the config is reloaded, including when macOS appearance changes (WezTerm monitors the system appearance and triggers a config reload automatically).

Add a single event handler that updates `colors` via `window:set_config_overrides()`:

```lua
wezterm.on('window-config-reloaded', function(window, _)
  local overrides = window:get_config_overrides() or {}
  overrides.colors = get_colors()
  window:set_config_overrides(overrides)
end)
```

**Placement**: After the `close-window` handler, before `return config`.

## Change

- **File**: `wezterm/.wezterm.lua`
- **Lines affected**: Insert ~5 lines after `close-window` handler (line 826)

## Verification

- No automated test suite for WezTerm config
- Manual: toggle macOS Dark/Light mode while WezTerm is running; terminal body colors should update without `CMD+R`
- Static check: `luac -p wezterm/.wezterm.lua` (syntax validation)

## Risk

Low — isolated to color override logic; does not touch process management, session state, or tab layout.
