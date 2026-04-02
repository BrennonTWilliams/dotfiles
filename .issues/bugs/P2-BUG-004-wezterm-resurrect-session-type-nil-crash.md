---
id: BUG-004
title: "WezTerm resurrect session_type is nil when id format doesn't match"
type: BUG
priority: P2
status: open
discovered_date: 2026-04-02
discovered_by: capture-issue
---

# BUG-004: WezTerm resurrect session_type is nil when id format doesn't match

## Summary

`session_type` is extracted via `string.match(id, '([a-z]+)/.+')`. If `id` doesn't match the expected `type/name` format, `session_type` is `nil`. This is then passed to `load_state(id, nil)` which may error, and the subsequent `if session_type == 'workspace'` dispatch chain silently falls through without restoring anything.

## Context

Identified from WezTerm config audit of `wezterm/.wezterm.lua`.

**Affected lines:** 491-492

```lua
local session_type = string.match(id, '([a-z]+)/.+')
local state = resurrect.state_manager.load_state(id, session_type)
```

If `id` comes from a fuzzy_picker selection and has an unexpected format (stale entry, manual edit, plugin version change), `session_type` is `nil` and the restore logic breaks silently or errors.

## Root Cause

**File:** `wezterm/.wezterm.lua:492`

No guard between the regex match and the rest of the restore logic. An unmatched `id` produces a silent no-op at best, or a crash inside `load_state` at worst.

## Proposed Fix

Add an early return after the pattern match:

```lua
local session_type = string.match(id, '([a-z]+)/.+')
if not session_type then return end
```

## Related Key Documentation

_No documents linked. Run `/ll:normalize-issues` to discover and link relevant docs._

## Labels

`bug`, `wezterm`, `resurrect`, `crash`, `captured`

---

## Status

**Open** | Created: 2026-04-02 | Priority: P2

## Session Log
- `/ll:verify-issues` - 2026-04-02T20:39:20 - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/9775816b-44ad-40d3-9b00-80f45de24809.jsonl`
- `/ll:capture-issue` - 2026-04-02T00:00:00Z - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/0ad6fe06-8b2c-44d9-a393-bd64f9cb44fb.jsonl`
