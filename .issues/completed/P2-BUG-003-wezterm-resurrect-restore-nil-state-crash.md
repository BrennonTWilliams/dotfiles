---
id: BUG-003
title: "WezTerm resurrect restore crashes when load_state returns nil"
type: BUG
priority: P2
status: completed
discovered_date: 2026-04-02
discovered_by: capture-issue
---

# BUG-003: WezTerm resurrect restore crashes when load_state returns nil

## Summary

`resurrect.state_manager.load_state()` can return `nil` (e.g., file missing, JSON parse error), but the result is passed directly to `restore_workspace` / `restore_window` / `restore_tab` without a nil guard, causing a runtime error.

## Current Behavior

When `load_state` returns `nil` (e.g., missing session file or malformed JSON), the `nil` value is passed directly to `restore_workspace` / `restore_window` / `restore_tab`. This throws a runtime Lua error inside the WezTerm event handler, disrupting the session restore flow.

## Expected Behavior

When `load_state` returns `nil`, the restore callback should abort gracefully — either silently or with a user-facing notification — rather than propagating a runtime error.

## Steps to Reproduce

1. Have a saved WezTerm resurrect session whose state file is missing or contains malformed JSON.
2. Press `CMD+SHIFT+L` to open the fuzzy session picker.
3. Select the session with the corrupt / missing state file.
4. Observe: a runtime Lua error is thrown inside `fuzzy_loader.fuzzy_load`'s callback, logged to the WezTerm debug overlay.

## Impact

- **Priority**: P2 — Session restore is a routine operation; a crash here visibly disrupts workflow
- **Effort**: Small — Single nil guard (`if not state then return end`) at the call site
- **Risk**: Low — Purely defensive change; no behavior change when `load_state` returns a valid state
- **Breaking Change**: No

## Context

Identified from WezTerm config audit of `wezterm/.wezterm.lua`.

**Affected lines:** 491-501

```lua
local state = resurrect.state_manager.load_state(id, session_type)
if session_type == 'workspace' then
    resurrect.workspace_state.restore_workspace(state, ...)  -- state can be nil
```

If `load_state` fails for any reason (missing file, malformed JSON, plugin error), passing `nil` to the restore function will throw a runtime Lua error inside the wezterm event handler, potentially disrupting startup or session restore flows.

## Root Cause

**File:** `wezterm/.wezterm.lua:491`

No nil check between `load_state` and the restore dispatch. The resurrect plugin API does not document what it returns on failure, so a defensive guard is required at the call site.

## Proposed Fix

Add an early return guard after `load_state`:

```lua
local state = resurrect.state_manager.load_state(id, session_type)
if not state then return end
```

## Related Key Documentation

_No documents linked. Run `/ll:normalize-issues` to discover and link relevant docs._

## Labels

`bug`, `wezterm`, `resurrect`, `crash`, `captured`

---

## Resolution

**Fixed in:** `wezterm/.wezterm.lua:493`

Added nil guard after `load_state` call:

```lua
local state = resurrect.state_manager.load_state(id, session_type)
if not state then return end
```

This ensures the restore callback aborts gracefully when `load_state` returns `nil` (missing file, malformed JSON, or plugin error), rather than propagating a runtime Lua error into the restore functions.

## Status

**Completed** | Created: 2026-04-02 | Resolved: 2026-04-02 | Priority: P2

## Session Log
- `hook:posttooluse-git-mv` - 2026-04-02T22:07:41 - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/398af616-0f77-438d-b484-946a352ee5c8.jsonl`
- `/ll:manage-issue` - 2026-04-02T00:00:00Z - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/6ebe9e06-2415-44fc-a996-02e33660aa8f.jsonl`
- `/ll:ready-issue` - 2026-04-02T22:06:59 - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/6ebe9e06-2415-44fc-a996-02e33660aa8f.jsonl`
- `/ll:verify-issues` - 2026-04-02T20:39:20 - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/9775816b-44ad-40d3-9b00-80f45de24809.jsonl`
- `/ll:capture-issue` - 2026-04-02T00:00:00Z - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/0ad6fe06-8b2c-44d9-a393-bd64f9cb44fb.jsonl`
