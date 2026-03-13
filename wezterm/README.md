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
- Copy on select
- WebGPU rendering

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
