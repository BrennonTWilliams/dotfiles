# Ghostty + tmux Cheatsheet

> Prefix: `Ctrl+A`
>
> All `Cmd+*` Ghostty shortcuts send the equivalent tmux key sequence — both layers work identically.

---

## Windows / Tabs

| Action | Ghostty | tmux |
|---|---|---|
| New window | `Cmd+T` | `prefix + c` |
| Close window | `Cmd+W` | `prefix + x` |
| Next window | `Ctrl+Tab` / `Cmd+Shift+]` | `prefix + n` |
| Previous window | `Ctrl+Shift+Tab` / `Cmd+Shift+[` | `prefix + p` |
| Jump to window 1–9 | `Cmd+1–9` | `prefix + 1–9` |
| Swap window left | — | `prefix + <` (repeatable) |
| Swap window right | — | `prefix + >` (repeatable) |

---

## Panes / Splits

| Action | Ghostty | tmux |
|---|---|---|
| Split right | `Cmd+D` | `prefix + \|` |
| Split down | `Cmd+Shift+D` | `prefix + -` |
| Navigate pane | `Cmd+Opt+Arrow` | `prefix + h/j/k/l` or `Alt+Arrow` |
| Resize pane | `Cmd+Shift+Arrow` | `prefix + H/J/K/L` (repeatable) |
| Zoom / unzoom pane | `Cmd+Shift+Z` | `prefix + z` |
| Toggle pane sync | — | `prefix + S` |

---

## Copy Mode (vi-style)

> `copy-on-select = false` — mouse selection alone does not copy; use `y` or `Enter`.

| Action | Key |
|---|---|
| Enter copy mode | `prefix + [` |
| Begin selection | `v` |
| Toggle rectangle selection | `r` |
| Copy + exit | `y` or `Enter` |
| Copy (stay in mode) | `Ctrl+Y` |
| Exit copy mode | `q` or `Escape` |
| Mouse drag | Copies to clipboard (stays in mode) |
| Open URL/file under selection | `o` |
| Open selection in `$EDITOR` | `Ctrl+O` |
| Paste | `prefix + ]` |

---

## Scroll & Navigation

| Action | Key |
|---|---|
| Scroll page up / down | `Cmd+Up` / `Cmd+Down` |
| Jump to previous prompt | `Ctrl+Shift+Up` |
| Jump to next prompt | `Ctrl+Shift+Down` |
| Open scrollback in editor | `Cmd+Shift+O` |
| Word left / right (readline) | `Opt+Left` / `Opt+Right` |
| Beginning / end of line | `Cmd+Left` / `Cmd+Right` |
| Kill line (backward) | `Cmd+Backspace` |

---

## Sessions & Utility

| Action | Key |
|---|---|
| fzf session switcher | `prefix + f` |
| Floating scratch terminal | `prefix + g` |
| Clear scrollback | `Cmd+K` or `prefix + Ctrl+L` |
| Reload tmux config | `prefix + r` |
| Reload Ghostty config | `Cmd+R` |
| Rename tab (`tab-title <name>`) | `Cmd+Shift+R` then type name |
| Command palette | `Cmd+Shift+P` |
| Close Ghostty window (native) | `Cmd+Shift+W` |
| Global quick terminal (system-wide) | `Cmd+`` ` |

---

## Token / Path Picker (extrakto)

| Action | Key |
|---|---|
| fzf picker for visible tokens | `prefix + Tab` |

Grabs URLs, paths, hashes, and words from recent pane output and inserts the selection at the cursor.

---

## TPM Plugin Management

| Action | Key |
|---|---|
| Install plugins | `prefix + I` |
| Update plugins | `prefix + U` |
| Remove unlisted plugins | `prefix + Alt+U` |

---

## Status Bar Reference

```
[session · host]          [CPU% RAM% | HH:MM AM/PM DD-Mon-YY]
 ^--- left                 ^--- right

Window tab format:  [icon] index:name  (Z = zoomed)
```
