---
id: ENH-005
title: "WezTerm config.copy_on_select is referenced in comment but never set"
type: ENH
priority: P3
status: completed
discovered_date: 2026-04-02
discovered_by: capture-issue
---

# ENH-005: WezTerm config.copy_on_select is referenced in comment but never set

## Summary

A comment at line 103 describes `copy_on_select = true` behavior matching Ghostty's default, but `config.copy_on_select = true` is never actually assigned. The mouse binding at line 514 covers primary-button selection, but keyboard-driven selection (copy mode, etc.) is not covered.

## Current Behavior

The Selection section comment at `config.selection_word_boundary` reads "Copy on select behavior (matches Ghostty copy-on-select = true)", implying `copy_on_select` is active. However, `config.copy_on_select` is never assigned. The only selection-to-clipboard path is the mouse binding that fires on left-button release (`CompleteSelection 'ClipboardAndPrimarySelection'`). Keyboard-driven selection — entering copy mode, making a vi-style selection — does not auto-copy to clipboard.

## Expected Behavior

`config.copy_on_select = true` is set in the Selection section so that all selection methods (mouse and keyboard) automatically copy to clipboard, making the behavior match the documented comment and mirror Ghostty's `copy-on-select = true` default.

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

## Impact

- **Priority**: P3 - Minor behavioral gap; misleading comment understates the omission
- **Effort**: Small - One-line config addition
- **Risk**: Low - `copy_on_select` is a standard WezTerm option; no breaking changes
- **Breaking Change**: No

## Scope Boundaries

- Add `config.copy_on_select = true` to the Selection section only
- Do not modify existing mouse bindings or copy mode key bindings
- Do not change clipboard selection targets (`ClipboardAndPrimarySelection` remains unchanged)

## Related Key Documentation

_No documents linked. Run `/ll:normalize-issues` to discover and link relevant docs._

## Labels

`enhancement`, `wezterm`, `selection`, `captured`

---

## Status

**Open** | Created: 2026-04-02 | Priority: P3

## Resolution

Added `config.copy_on_select = true` in the Selection section of `wezterm/.wezterm.lua` at line 104, directly below the existing comment. All selection methods (mouse and keyboard/copy mode) now auto-copy to clipboard, matching the documented Ghostty parity goal.

**Completed**: 2026-04-02

## Session Log
- `hook:posttooluse-git-mv` - 2026-04-02T22:14:10 - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/f42bd818-62c6-4d1e-ba9b-5f427869663d.jsonl`
- `/ll:manage-issue` - 2026-04-02T00:00:00Z - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/current.jsonl`
- `/ll:ready-issue` - 2026-04-02T22:13:07 - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/4abda147-9d9a-47dc-888a-fc02a8e5726e.jsonl`
- `/ll:verify-issues` - 2026-04-02T20:39:20 - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/9775816b-44ad-40d3-9b00-80f45de24809.jsonl`
- `/ll:capture-issue` - 2026-04-02T00:00:00Z - `/Users/brennon/.claude/projects/-Users-brennon-AIProjects-ai-workspaces-dotfiles/0ad6fe06-8b2c-44d9-a393-bd64f9cb44fb.jsonl`
