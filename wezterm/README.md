# WezTerm Configuration

WezTerm terminal configuration matching Ghostty setup with Gruvbox dark custom theme.

## Features

- IosevkaTerm Nerd Font at size 16
- Gruvbox dark custom color palette
- 8px window padding
- 120x40 initial window size
- Non-blinking block cursor
- Auto-hiding tab bar (single tab)
- macOS Option key as Alt
- WebGPU rendering
- Close confirmation for panes and windows
- Kitty keyboard protocol (extended key encoding for Neovim)
- Left status bar showing active workspace name
- Right status bar showing hostname and time

## Keybindings

### Window & Config

| Key | Action |
|-----|--------|
| `CMD+R` | Reload configuration |
| `CMD+SHIFT+R` | Rename current tab |
| `CMD+Enter` | Toggle fullscreen |
| `CMD+T` | New tab |
| `CMD+w` | Close pane (with confirmation) |
| `CMD+SHIFT+W` | Close window (with confirmation) |
| `CTRL+Tab` / `CTRL+SHIFT+Tab` | Next / previous tab |
| `CMD+1`–`9` | Jump to tab by number |

### Pane Management

| Key | Action |
|-----|--------|
| `CMD+d` | Split horizontally |
| `CMD+SHIFT+D` | Split vertically |
| `CMD+SHIFT+Z` | Toggle pane zoom |
| `CMD+ALT+Arrow` | Navigate to pane in direction |
| `CMD+SHIFT+Arrow` | Resize pane (5-cell increments) |

### Text Navigation

| Key | Action |
|-----|--------|
| `ALT+Left/Right` | Word back / forward (readline) |
| `CMD+Left/Right` | Line start / end |
| `CMD+Up/Down` | Scroll page up / down |
| `CMD+Backspace` | Delete to line start |
| `SHIFT+Enter` | Send newline (distinct from Enter) |

### Clipboard & Copy

| Key | Action |
|-----|--------|
| `CMD+C` | Copy to clipboard |
| `CMD+V` | Paste from clipboard |
| `CMD+[` | Enter copy mode (vi keys: v select, y copy, q quit) |
| `CMD+Y` | Quick Select — highlight URLs/hashes/paths to copy |

### Utility

| Key | Action |
|-----|--------|
| `CMD+K` | Clear scrollback and viewport |
| `CMD+F` | Search (current selection or prompt) |
| `CMD+P` | Command palette (fuzzy search tabs/panes/commands) |
| `CMD+=` / `CMD+-` / `CMD+0` | Increase / decrease / reset font size |

## Installation

```bash
# From dotfiles root
stow wezterm
```

## Configuration File

WezTerm expects the config at `~/.wezterm.lua`. This stow package places the file at the root to symlink directly.

## Reload Configuration

WezTerm auto-reloads config on save. Or press `Cmd+R` to reload manually.

## Verification

After stowing, verify:
- Font is IosevkaTerm Nerd Font at size 16
- Colors match Gruvbox dark custom theme
- Window padding is 8px
- Option key works as Alt
- Tab bar hides with single tab
- Cursor is non-blinking block
- CMD+SHIFT+Z zooms a split pane to fill the window
- CMD+Enter toggles fullscreen
- CMD+SHIFT+Arrow moves pane divider in the given direction
- CMD+SHIFT+R prompts to rename the current tab
- CMD+w shows a close confirmation dialog
- CMD+Y overlays Quick Select labels on screen content
- CMD+P opens the command palette fuzzy finder
- Left side of tab bar shows the workspace name ('default' by default)
- In Neovim: Ctrl+[ and Esc are distinguishable (kitty keyboard protocol)
