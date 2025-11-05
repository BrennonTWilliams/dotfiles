# Neovim Configuration

Modern Neovim setup with lazy.nvim plugin manager and Gruvbox Dark theme.

## Features

- **Plugin Manager**: lazy.nvim (automatically bootstrapped on first run)
- **Color Scheme**: Gruvbox Dark (matching system-wide theme)
- **Cursor Effects**: smear-cursor.nvim for smooth cursor animations
- **Sensible Defaults**: Line numbers, smart indentation, clipboard integration
- **Tmux Integration**: Optimized for use with tmux

## Plugins

| Plugin | Purpose |
|--------|---------|
| gruvbox.nvim | Gruvbox Dark colorscheme |
| smear-cursor.nvim | Smooth cursor animations and effects |

## Key Bindings

### Leader Key
- Leader: `<Space>`

### Window Navigation
- `Ctrl+h/j/k/l` - Move between windows
- `Ctrl+Arrow Keys` - Resize windows

### Buffer Navigation
- `Shift+l` - Next buffer
- `Shift+h` - Previous buffer

### General
- `<Space>w` - Save file
- `<Space>q` - Quit
- `<Space>tc` - Toggle smear cursor
- `<Esc>` - Clear search highlighting

### Visual Mode
- `<` / `>` - Indent left/right (stays in visual mode)
- `J` / `K` - Move selected text up/down

## Structure

```
neovim/.config/nvim/
├── init.lua                  # Main entry point
├── lua/
│   ├── config/
│   │   ├── settings.lua     # Core Neovim settings
│   │   └── keymaps.lua      # Key mappings
│   └── plugins/
│       ├── gruvbox.lua      # Gruvbox theme config
│       └── smear-cursor.lua # Smear cursor config
```

## Installation

The configuration is managed via stow. Due to existing .config structure, manual symlink is required:

```bash
# Create symlink
ln -s ~/AIProjects/ai-workspaces/dotfiles/neovim/.config/nvim ~/.config/nvim

# Install Neovim (already included in packages-macos.txt)
brew install neovim

# Plugins will auto-install on first launch
nvim
```

## Requirements

- Neovim 0.10.2+ (currently running 0.11.5)
- Git (for plugin installation)

## Configuration

Plugins are configured in `lua/plugins/` directory. Each plugin has its own file that returns a lazy.nvim plugin specification.

To add new plugins, create a new file in `lua/plugins/` following this pattern:

```lua
return {
  "author/plugin-name",
  opts = {
    -- plugin configuration
  },
}
```

## Integration

- Works seamlessly with Ghostty terminal
- Integrated with tmux session management
- Matches Gruvbox Dark theme used system-wide
