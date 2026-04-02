---
discovered_date: 2026-04-02
discovered_by: capture-issue
---

# ENH-009: WezTerm Tab Label Always Show Directory, Icon for Running Process

## Summary

WezTerm tab labels currently change to reflect the running process name when a process is active (e.g., `nvim`, `git`, etc.). The label should always display the current working directory. Running processes should only influence the Nerd Font glyph/icon shown in the tab, not the text label.

## Context

**Direct mode**: User description: "Currently, our wezterm tabs labels change if theres a running process, etc. These labels should always show the directory as they do currently when no process is running. Running processes etc should instead only change the Nerd Font Glyph icon shown in the tab"

The current tab formatting logic mixes process state into the label text. The desired UX separates concerns: directory = label text, process state = icon only.

## Motivation

Having the directory always visible in the tab label gives consistent spatial orientation across the tab bar. When tabs silently rename to the running process, users lose track of which directory a tab is in. The icon is a sufficient and less disruptive indicator of what is running.

## Current Behavior

- Tab label shows directory when no process is running
- Tab label changes to process name (e.g., `nvim`, `python`, `claude`) when a foreground process is active

## Expected Behavior

- Tab label always shows current working directory (no change from idle state)
- Nerd Font glyph icon in the tab changes to reflect the running process
- Directory label remains stable regardless of foreground process

## Integration Map

### Files to Modify
- `wezterm/.config/wezterm/tab.lua` or `wezterm/.config/wezterm/tabs.lua` - tab title formatting and process-to-glyph logic

### Dependent Files (Callers/Importers)
- TBD - use grep to find references: `grep -r "tab_title\|format_tab\|tab_bar" wezterm/`

### Similar Patterns
- TBD - search for existing process-to-glyph mappings: `grep -r "process_name\|foreground_process" wezterm/`

### Tests
- N/A - WezTerm Lua config has no automated test suite

### Documentation
- N/A

### Configuration
- N/A

## Implementation Steps

1. Locate the tab title formatting logic in `wezterm/.config/wezterm/` (likely in `tab.lua` or `tabs.lua`)
2. Identify where the label text is set based on process info
3. Decouple process detection from label text — label should always use the directory path
4. Route process detection to the icon/glyph selection logic only
5. Map common processes (nvim, git, python, claude, etc.) to appropriate Nerd Font glyphs
6. Test with several running processes to confirm label stays as directory and icon updates

## Scope Boundaries

- **In scope**: Decoupling tab label text from running process name; routing process detection to icon/glyph selection only; mapping common foreground processes (nvim, git, python, claude) to Nerd Font glyphs
- **Out of scope**: Adding new process-to-glyph mappings beyond commonly used ones; changing tab bar layout or other visual properties; altering session resurrection or tab persistence logic

## API/Interface

N/A - No public API changes (internal WezTerm Lua config only)

## Impact

- **Priority**: P3 - Low-urgency UX improvement; reduces cognitive overhead when tracking directory context across multiple tabs
- **Effort**: Small - Localised change to tab title formatting logic in a single Lua file
- **Risk**: Low - Tab label display is isolated from session state and persistence logic
- **Breaking Change**: No

## Related Key Documentation

_No documents linked. Run `/ll:normalize-issues` to discover and link relevant docs._

## Labels

`enhancement`, `wezterm`, `captured`

---

## Status

**Open** | Created: 2026-04-02 | Priority: P3

## Session Log
- `/ll:format-issue` - 2026-04-02T22:20:58 - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/26af31df-ef62-49ac-85fc-be5aa87d9c17.jsonl`
- `/ll:capture-issue` - 2026-04-02T00:00:00Z - `~/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/4abda147-9d9a-47dc-888a-fc02a8e5726e.jsonl`
