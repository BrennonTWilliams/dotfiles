# Glow - Markdown Renderer Theme Integration

Custom [Glow](https://github.com/charmbracelet/glow) styles and wrapper that match the Ghostty+tmux theme system. Solves the "washed-out colors in light mode" problem by shipping truecolor JSON styles that mirror the Gruvbox palette used elsewhere in this dotfiles repo.

## Why this exists

Glow's built-in `light` style mixes 256-color ANSI indices with a hardcoded dark chroma block (dark text on `#373737`), which renders muddy against the cream Gruvbox-light background. This package ships two glamour JSON styles whose hex colors come straight from the Ghostty theme files so markdown rendering always matches the active terminal palette.

## Installation

```bash
cd ~/.dotfiles
stow glow
```

This creates symlinks:

- `~/.config/glow/gruvbox-light.json`
- `~/.config/glow/gruvbox-dark.json`
- `~/.local/bin/glow` (wrapper, shadows the Homebrew binary in `$PATH`)

After stowing, prepend `~/.local/bin` to `$PATH` (already done in `zsh/.zshrc`) and `glow` will auto-route through the wrapper.

## How it works

The wrapper at `glow/.local/bin/glow` runs the real `glow` binary with `-s <style.json>`. Style selection mirrors the same precedence used by `tmux/.tmux.conf:288-289`:

1. Explicit `$THEME_MODE` (`light` or `dark`) - always wins
2. macOS `defaults read -g AppleInterfaceStyle` - `light` if absent
3. Linux defaults to `dark`

When the style directory is missing (e.g. symlink not yet stowed), the wrapper prints a warning and falls through to glow's built-in auto-detection so the command still works.

## Usage

```bash
# Auto-select style based on THEME_MODE / macOS appearance
glow README.md

# Force a specific style
THEME_MODE=dark glow notes.md
THEME_MODE=light glow notes.md

# Direct invocation (bypass wrapper)
glow -s ~/.config/glow/gruvbox-light.json notes.md
```

## Color mapping

| Element           | Light                            | Dark                              |
|-------------------|----------------------------------|-----------------------------------|
| Document text     | `#3c3836` (dark1)                | `#ebdbb2` (light1)                |
| Background        | `#f9f5d7` (light0-hard)          | `#1d2021` (dark0-hard)            |
| H1 banner         | orange `#af3a03` bg, cream fg    | orange `#fe8019` bg, dark0 fg     |
| Headings 2-6      | `#b57614` `#076678` `#427b58` `#8f3f71` `#7c6f64` | `#fabd2f` `#83a598` `#8ec07c` `#d3869b` `#a89984` |
| Link text         | `#076678`                        | `#83a598`                         |
| Inline code       | `#9d0006` on `#ebdbb2`          | `#fb4934` on `#3c3836`            |
| Code block        | `#3c3836` on `#ebdbb2`          | `#ebdbb2` on `#3c3836`            |
| Code keywords     | `#af3a03` (orange accent)        | `#fb4934` (bright red)            |
| Code functions    | `#427b58`                        | `#8ec07c`                         |
| Code literals     | `#8f3f71`                        | `#d3869b`                         |

All values match the corresponding Ghostty theme (`ghostty/.config/ghostty/themes/gruvbox-{light,dark}-custom`) and the tmux status bar palette (`tmux/.tmux.conf:285-330`), so the orange accent reads as orange everywhere.

## Dependencies

- **glow** - install via Homebrew: `brew install glow`
- **IosevkaTerm Nerd Font** (or any Nerd Font) - matches the rest of the dotfiles

## Files

```
glow/
├── .config/glow/
│   ├── gruvbox-light.json       # Light mode glamour style
│   └── gruvbox-dark.json        # Dark mode glamour style
└── .local/bin/glow              # Wrapper script (shadows Homebrew glow)
```

## Tests

Run from the repo root:

```bash
tests/test_glow_wrapper.sh
```

Validates JSON parses, shellcheck-clean wrapper, theme-mode detection (explicit and macOS fallback), and graceful degradation when the style directory is missing.

## Related Configuration

- **ghostty/** - Terminal emulator that drives the palette
- **tmux/** - Status bar uses the same hex values for cross-tool consistency
- **starship/** - Prompt prompt that uses the same orange accent