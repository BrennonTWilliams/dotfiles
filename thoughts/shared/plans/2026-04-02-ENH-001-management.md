# ENH-001: WezTerm Tab Bar Dynamic Width with Max-Height Constraint

**Date**: 2026-04-02  
**Issue**: ENH-001  
**File**: `wezterm/.wezterm.lua`

## Research Summary

- `window` object is NOT available in `format-tab-title` — only `(tab, tabs, panes, cfg, hover, max_width)` args available.
- WezTerm already distributes `max_width` per-tab based on `tab_max_width`. The fill mechanism is **padding**, not pixel math.
- The existing truncation block at lines 772–783 uses `reserved = 4 + #pane_suffix + activity_chars` as chrome budget.
- Total content without padding = `reserved + #label + 1`, so `avail = max_width - reserved` is the label budget.
- Padding formula: `if #label < avail then pad label to avail chars`.

## Changes

### Change 1: MAX_TAB_BAR_FONT_SIZE constant

Before line 53 (`config.tab_max_width = 256`), add:
```lua
local MAX_TAB_BAR_FONT_SIZE = 24.0
```

Replace `font_size = 24.0` at line 57 with `font_size = MAX_TAB_BAR_FONT_SIZE`.

### Change 2: Label padding in format-tab-title

After the truncation block (after line 783 `end`), add:
```lua
  -- Pad label to fill the full max_width allocation so tabs expand to use available width
  local avail = max_width - reserved
  if #label < avail then
    label = label .. string.rep(' ', avail - #label)
  end
```

## Verification

- Manual: `wezterm.reload_configuration()` (live reload, no restart)
- Check with 1, 3, 8+ tabs: tabs should fill full bar width
- Check pane-count badge and activity dot still render correctly
- Check in both dark and light themes

## Success Criteria

- [x] `MAX_TAB_BAR_FONT_SIZE` constant defined, literal `24.0` removed from `window_frame`
- [ ] Padding logic added after truncation block in `format-tab-title`
- [ ] Visual verification passes
