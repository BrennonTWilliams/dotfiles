---
id: ENH-005
title: "WezTerm config.copy_on_select is referenced in comment but never set"
type: ENH
priority: P3
status: open
discovered_date: 2026-04-02
discovered_by: capture-issue
---

# ENH-005: WezTerm config.copy_on_select is referenced in comment but never set

## Summary

A comment at line 103 describes `copy_on_select = true` behavior matching Ghostty's default, but `config.copy_on_select = true` is never actually assigned. The mouse binding at line 514 covers primary-button selection, but keyboard-driven selection (copy mode, etc.) is not covered.

## Context

Identified from WezTerm config audit of `wezterm/.wezterm.lua`.

**Affected line:** 103 (Selection section comment)

The intent is documented but the implementation is absent. This means:
- Keyboard-driven text selection in copy mode does not auto-copy to clipboard
- Behavior diverges from the documented Ghostty parity goal

## Motivation

The comment explicitly states the intent to match Ghostty's `copy-on-select = true` behavior. The missing assignment means the config does not actually do what it says it does, creating a misleading comment and incomplete feature.

## Proposed Change

Add `config.copy_on_select = true` in the Selection section (near line 103):

```lua
-- Copy on select behavior (matches Ghostty copy-on-select = true)
config.copy_on_select = true
```

## Related Key Documentation

_No documents linked. Run `/ll:normalize-issues` to discover and link relevant docs._

## Labels

`enhancement`, `wezterm`, `selection`, `captured`

---

## Status

**Open** | Created: 2026-04-02 | Priority: P3

## Session Log
- `/ll:capture-issue` - 2026-04-02T00:00:00Z - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/0ad6fe06-8b2c-44d9-a393-bd64f9cb44fb.jsonl`
