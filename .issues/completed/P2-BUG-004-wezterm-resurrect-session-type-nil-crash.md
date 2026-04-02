---
id: BUG-004
title: "WezTerm resurrect session_type is nil when id format doesn't match"
type: BUG
priority: P2
status: completed
discovered_date: 2026-04-02
discovered_by: capture-issue
---

# BUG-004: WezTerm resurrect session_type is nil when id format doesn't match

## Summary

`session_type` is extracted via `string.match(id, '([a-z]+)/.+')`. If `id` doesn't match the expected `type/name` format, `session_type` is `nil`. This is then passed to `load_state(id, nil)` which may error, and the subsequent `if session_type == 'workspace'` dispatch chain silently falls through without restoring anything.

## Current Behavior

When the fuzzy loader presents a session `id` that does not match the `([a-z]+)/.+` pattern (e.g., a stale entry, manually edited session name, or format change from a plugin version update), `string.match` returns `nil` for `session_type`. The code then calls `resurrect.state_manager.load_state(id, nil)` with a nil type, and the `if session_type == 'workspace' ... elseif ...` dispatch chain silently falls through without restoring any session state.

## Expected Behavior

When `id` doesn't match the expected `type/name` format, the restore callback should exit early before attempting to load state, preventing the silent no-op and any potential crash inside `load_state` when called with a nil type argument.

## Steps to Reproduce

1. Open WezTerm with the resurrect plugin configured
2. Trigger the fuzzy session loader with `CMD+SHIFT+L`
3. Ensure the session list contains an entry with a malformed or unexpected ID format (e.g., a stale entry no longer matching `type/name` format)
4. Select the malformed entry
5. Observe: no session is restored; the callback silently exits without feedback, or `load_state` throws a Lua error

## Context

Identified from WezTerm config audit of `wezterm/.wezterm.lua`.

**Affected lines:** 491-492

```lua
local session_type = string.match(id, '([a-z]+)/.+')
local state = resurrect.state_manager.load_state(id, session_type)
```

If `id` comes from a fuzzy_picker selection and has an unexpected format (stale entry, manual edit, plugin version change), `session_type` is `nil` and the restore logic breaks silently or errors.

## Root Cause

**File:** `wezterm/.wezterm.lua`
**Anchor:** `function(id, _)` callback passed to `resurrect.fuzzy_loader.fuzzy_load` (line 490)

No guard between the regex match and the rest of the restore logic. An unmatched `id` produces a silent no-op at best, or a crash inside `load_state` at worst. Note: BUG-003's fix added `if not state then return end` (line 493) which guards the downstream crash, but does not guard against calling `load_state` with a nil `session_type` in the first place.

## Proposed Fix

Add an early return after the pattern match, before calling `load_state`:

```lua
local session_type = string.match(id, '([a-z]+)/.+')
if not session_type then return end
```

## Impact

- **Priority**: P2 - Silent failure on malformed session IDs; affects any user with stale or non-standard entries in the fuzzy picker
- **Effort**: Small - Single-line guard inserted after the pattern match
- **Risk**: Low - Early return is a safe no-op; does not affect the happy path where `id` is well-formed
- **Breaking Change**: No

## Related Key Documentation

_No documents linked. Run `/ll:normalize-issues` to discover and link relevant docs._

## Labels

`bug`, `wezterm`, `resurrect`, `crash`, `captured`

---

## Resolution

Added early-return guard on line 492 of `wezterm/.wezterm.lua`:

```lua
if not session_type then return end
```

Inserted between the `string.match` call and `load_state`, preventing `load_state` from being called with a nil `session_type` when the session ID has an unexpected format.

## Status

**Completed** | Created: 2026-04-02 | Resolved: 2026-04-02 | Priority: P2

## Session Log
- `/ll:ready-issue` - 2026-04-02T22:09:48 - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/376363c4-8c66-4f57-8b79-43c5d82fc842.jsonl`
- `/ll:ready-issue` - 2026-04-02T21:00:00 - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/current.jsonl`
- `/ll:verify-issues` - 2026-04-02T20:39:20 - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/9775816b-44ad-40d3-9b00-80f45de24809.jsonl`
- `/ll:capture-issue` - 2026-04-02T00:00:00Z - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/0ad6fe06-8b2c-44d9-a393-bd64f9cb44fb.jsonl`
