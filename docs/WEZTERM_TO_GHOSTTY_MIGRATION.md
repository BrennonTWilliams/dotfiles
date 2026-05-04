# WezTerm → Ghostty Migration Plan

Translation plan for moving the tailored WezTerm setup (`wezterm/.wezterm.lua`, 867 lines) to a Ghostty-only configuration (`ghostty/.config/ghostty/config`).

## Motivation

WezTerm has stalled on the macOS `NSTextInputClient` bug that breaks Apple Dictation in the terminal (tracked in WezTerm PR #7453 / #7536). Ghostty is a native AppKit app and handles `NSTextInputClient` correctly, so Dictation works out of the box without any config.

Secondary wins:
- Native Metal renderer (no `front_end = WebGpu` toggle to manage)
- Native macOS tabs/window chrome
- Declarative config — easier to share/diff than Lua

Primary cost: WezTerm's Lua programmability is gone. Anything dynamic must move to the shell, tmux, or be dropped.

---

## Current Inventory

WezTerm config sections (line ranges from `wezterm/.wezterm.lua`):

| Section | Lines | Notes |
|---|---|---|
| Font / window / cursor / macOS basics | 14–84 | Mostly already replicated in Ghostty config |
| Terminal + kitty keyboard | 86–97 | Trivial port |
| Theme: auto dark/light via `get_appearance()` | 113–235 | Replace with Ghostty's `theme = light:..,dark:..` |
| `inactive_pane_hsb` | 237–241 | Replace with `unfocused-split-opacity` |
| Keybindings | 247–505 | ~60 lines port directly; a few need workarounds |
| Mouse bindings | 510–525 | Defaults / `copy-on-select = true` cover it |
| Bell / performance | 529–548 | Mostly N/A on Ghostty (native Metal) |
| Shell / env | 550–565 | Already in Ghostty config |
| `resurrect.wezterm` session persistence | 9, 477–504, 568–584 | **Not portable** — replace with tmux-resurrect |
| `update-left-status` / `update-right-status` | 588–619 | **Not portable** — move to tmux status or shell prompt |
| `format-tab-title` (icon map, dynamic resolution) | 621–851 | **Not portable** — partial replacement via shell-side OSC 2 |
| `window-config-reloaded` theme refresh | 857–861 | Not needed — Ghostty handles theme switching natively |

---

## Already Done in Existing Ghostty Config

These are already present in `ghostty/.config/ghostty/config`:

- Fonts (`font-family`, `font-size`, bold/italic variants)
- Window padding, initial size, decoration, close confirmation
- Tab bar auto-hide
- Cursor style + no-blink
- `macos-option-as-alt = true`
- `term = xterm-256color`, `COLORTERM=truecolor`
- `command = /bin/zsh`
- `copy-on-select = true`
- Gruvbox dark/light custom theme files

---

## Phase 1 — One-line Ports

| WezTerm | Ghostty |
|---|---|
| `enable_kitty_keyboard = true` | (default for capable apps; no flag needed) |
| `audible_bell = 'Disabled'` | `audible-bell = false` |
| `scrollback_lines = 50000` | `scrollback-limit = 10mb` (byte-based; ~50k lines headroom) |
| `get_appearance()` + manual color swap | `theme = light:gruvbox-light-custom,dark:gruvbox-dark-custom` |
| `inactive_pane_hsb = { brightness = 0.7 }` | `unfocused-split-opacity = 0.7` |

---

## Phase 2 — Keybinding Port

Port directly as `keybind = TRIGGER=ACTION` lines. Items marked **(default)** are already Ghostty defaults and only need to be set if you want to override.

### Core editing / navigation
- `shift+enter=text:\n` — Shift+Enter sends LF
- `cmd+r=reload_config`
- `cmd+enter=toggle_fullscreen` **(default)**
- `cmd+shift+w=close_window`
- `ctrl+tab=next_tab`, `ctrl+shift+tab=previous_tab` **(default)**
- `cmd+one=goto_tab:1` … `cmd+eight=goto_tab:8`, `cmd+nine=last_tab`
- `cmd+d=new_split:right`, `cmd+shift+d=new_split:down`
- `cmd+shift+z=toggle_split_zoom`
- `cmd+alt+left=goto_split:left` (and right/up/down)
- `cmd+shift+up=resize_split:up,5` (and down/left/right)
- `cmd+left=text:\x1bOH`, `cmd+right=text:\x1bOF` (line nav)
- `cmd+up=scroll_page_up`, `cmd+down=scroll_page_down`
- `alt+left=text:\x1bb`, `alt+right=text:\x1bf` (readline word nav)
- `cmd+backspace=text:\x15` (kill-line)
- `cmd+k=clear_screen`
- `cmd+equal=increase_font_size` **(default)**, `cmd+minus=decrease_font_size` **(default)**, `cmd+zero=reset_font_size` **(default)**
- `cmd+shift+p=toggle_command_palette`

### Backspace IME bypass
The WezTerm config sends `\x7f` explicitly to bypass the macOS IME composition pipeline. **Not needed in Ghostty** — the underlying IME bug is the bug we're escaping. Drop this binding.

---

## Phase 3 — Workarounds

### Tab rename (`cmd+shift+r`)
Ghostty has no built-in rename prompt. Replacement: a zsh function that emits OSC 2.

```zsh
# In zsh/aliases.zsh or similar
tab-title() { print -Pn "\e]2;$1\a" }
```

Usage: `tab-title my-task`. Optional: bind a Ghostty key to a small launcher (e.g. fzf prompt) via shell.

### Search (`cmd+f`)
Ghostty has no in-terminal search yet (open upstream issue). Acceptable replacements:
- Use tmux's `prefix + /` when inside tmux
- Pipe long output to `less` or `nvim -`

### Copy mode (`cmd+[`)
Ghostty has no copy mode. Same fallbacks as search. tmux's vi copy mode covers this when running inside tmux.

### QuickSelect (`cmd+y`)
No equivalent. Closest options:
- Built-in URL detection → click links directly
- `tmux-thumbs` inside tmux for hashes/paths

### Visual bell timing
Ghostty's visual bell is on/off; the EaseIn/EaseOut timing knobs don't exist. Accept the default.

### `selection_word_boundary`
Not exposed in Ghostty config. Default boundaries are reasonable. Accept the loss.

### Tab bar font / max width
Ghostty uses native NSWindow tabs on macOS — tab font and height follow the system. `window-frame.font_size = 22.0` and `tab_max_width = 256` have no equivalent. Cosmetic loss only.

---

## Phase 4 — Architectural Replacements

These features require moving functionality out of the terminal emulator entirely.

### Session persistence (resurrect.wezterm)

WezTerm config: auto-save every 5 minutes, fuzzy load via `cmd+shift+l`, manual save via `cmd+shift+s`, auto-restore on launch.

**Replacement: tmux + tmux-resurrect + tmux-continuum.** The dotfiles repo already has tmux configured. Steps:
1. Verify `tmux-resurrect` and `tmux-continuum` are in the tmux plugin list
2. Set `set -g @continuum-restore 'on'` for auto-restore
3. Set `set -g @continuum-save-interval '5'` to match the 5-minute cadence
4. Optionally launch tmux automatically from zsh on Ghostty start (or use Ghostty's `command = tmux new-session -A -s main`)

Ghostty's `window-save-state = always` only restores window geometry, not pane/process state — keep tmux as the source of truth.

### Status bars (`update-left-status`, `update-right-status`)

WezTerm config: workspace name on left, hostname + time on right.

**Replacement: tmux status line.** Already configured in the dotfiles tmux setup. Items to verify in `tmux/.tmux.conf`:
- `status-left` shows session name
- `status-right` shows hostname + time
- Theme matches Gruvbox dark/light

If you sometimes run without tmux, add a minimal zsh prompt segment for hostname/time as a fallback.

### Tab title formatting (`format-tab-title`)

WezTerm config (lines 621–851) is the most complex piece:
- 50+ entry per-process Nerd Font icon map
- Claude Code version-string normalization
- Python/Node/Ruby interpreter argv probing (e.g. `python3.12 running ll-loop` → ll-loop icon)
- Cwd shortening (last 2 path components, `~` substitution)
- Activity dot (any pane has unseen output)
- Pane count badge
- Theme-aware colored segments
- Left-truncate paths so directory name stays visible

Ghostty's tab title comes from one of: the running process name, OSC 2 from the shell, or a static `title` template. **Lost capabilities:** colored segments, activity dot, pane count badge.

**Replacement plan: shell-side OSC 2 from zsh `precmd`/`preexec`.**

Sketch:
```zsh
# zsh/tab-title.zsh
typeset -gA TAB_ICONS=(
  nvim   $''
  claude $'\Uf167a'
  git    $''
  # ... port from PROC_ICONS in .wezterm.lua
)
TAB_ICON_DEFAULT=$''

_tab_title_set() {
  local cmd="${1:-zsh}"
  local icon="${TAB_ICONS[$cmd]:-$TAB_ICON_DEFAULT}"
  local cwd="${PWD/#$HOME/~}"
  local short="${cwd:t}"
  print -Pn "\e]2;${icon} ${short}\a"
}

precmd_functions+=(_tab_title_idle)
preexec_functions+=(_tab_title_busy)
_tab_title_idle() { _tab_title_set zsh }
_tab_title_busy() { _tab_title_set "${${1%% *}:t}" }
```

Acceptable losses for the shell-driven approach:
- No activity-dot-on-other-tabs (would need cross-tab state)
- No pane count badge (one shell can't see Ghostty's pane structure)
- No theme-aware colors (Ghostty renders the title plain)

Acceptable retentions:
- Per-process icon
- Cwd shortening
- Idle/busy distinction
- Claude / interpreter detection (port the argv-probe logic to a zsh function called from `preexec`)

---

## Acceptance Criteria

A successful migration means:
- [ ] Apple Dictation works inside the terminal (the whole point)
- [ ] All current keybindings either work natively, are intentionally accepted as lost, or have a documented workaround
- [ ] Theme auto-switches between Gruvbox dark/light with macOS appearance
- [ ] tmux-resurrect restores sessions across restarts
- [ ] Tab titles show per-process icons + short cwd via OSC 2
- [ ] tmux status line shows session name (left) and hostname+time (right)
- [ ] No regressions in existing Ghostty config consumers (Automator quick action, finder integration)

---

## Out of Scope / Accepted Losses

Documented here so they don't resurface as bugs:

- **In-terminal search** (`cmd+f`) — use tmux or a pager
- **Copy mode** (`cmd+[`) — use tmux copy-mode
- **QuickSelect** (`cmd+y`) — use tmux-thumbs
- **Colored tab segments / activity dots / pane count badges** — Ghostty title is plain text
- **Custom selection word boundaries** — Ghostty uses defaults
- **Visual bell easing curves** — Ghostty bell is on/off
- **Tab bar font size override** — native macOS tabs

---

## Effort Estimate

| Phase | Effort |
|---|---|
| Phase 1 (one-line ports) | 15 min |
| Phase 2 (keybinding port) | 1–2 hours |
| Phase 3 (workarounds) | 1 hour |
| Phase 4a (tmux-resurrect) | 30 min if plugins already wired |
| Phase 4b (tmux status verification) | 30 min |
| Phase 4c (zsh tab-title helper) | 2–4 hours to match current fidelity |
| **Total** | **~1 day** |

---

## Rollout

1. Create a branch; make changes additively in `ghostty/.config/ghostty/config` and `zsh/`
2. Keep `wezterm/` package intact for parallel use during validation
3. Validate Dictation, key bindings, tmux session restore, theme switch
4. Once stable for ~1 week: remove `wezterm/` package, update `README.md` and `docs/GETTING_STARTED.md`
5. Archive `.wezterm.lua` in git history (don't delete the commit reference)
