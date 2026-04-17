# WezTerm Configuration

GNU Stow package for WezTerm terminal emulator configuration.

## Installation

```bash
stow wezterm --target=$HOME
```

## Features

- **Gruvbox Dark/Light Custom Themes**: Ported from Ghostty configuration
- **Automatic Theme Switching**: Follows system dark/light mode preference
- **IosevkaTerm Nerd Font**: 16pt default size
- **macOS Integration**: Option key as Alt, native window decorations
- **Steady Block Cursor**: Non-blinking cursor for visibility

## Configuration

Main config: `~/.wezterm.lua`

For machine-specific overrides, create `~/.wezterm.local.lua`:

```lua
local config = {}
config.font_size = 14  -- Smaller font for laptop
return config
```

## Key Mappings

WezTerm uses default keybindings. See `wezterm show-keys --all` for a complete list.

Common shortcuts:
- `Cmd+T`: New tab
- `Cmd+W`: Close tab
- `Cmd+Shift+[` / `]`: Previous/next tab
- `Cmd+D`: Split horizontal
- `Cmd+Shift+D`: Split vertical

## Verification

After stowing, verify:
1. `ls -la ~/.wezterm.lua` shows symlink to dotfiles
2. Launch WezTerm - Gruvbox dark theme should apply
3. Font renders as IosevkaTerm Nerd Font at 16pt
4. Block cursor is steady (no blink)
5. Option key works as Alt
