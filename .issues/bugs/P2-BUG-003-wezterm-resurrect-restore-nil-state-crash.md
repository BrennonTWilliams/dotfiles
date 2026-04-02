---
id: BUG-003
title: "WezTerm resurrect restore crashes when load_state returns nil"
type: BUG
priority: P2
status: open
discovered_date: 2026-04-02
discovered_by: capture-issue
---

# BUG-003: WezTerm resurrect restore crashes when load_state returns nil

## Summary

`resurrect.state_manager.load_state()` can return `nil` (e.g., file missing, JSON parse error), but the result is passed directly to `restore_workspace` / `restore_window` / `restore_tab` without a nil guard, causing a runtime error.

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

## Status

**Open** | Created: 2026-04-02 | Priority: P2

## Session Log
- `/ll:capture-issue` - 2026-04-02T00:00:00Z - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/0ad6fe06-8b2c-44d9-a393-bd64f9cb44fb.jsonl`
