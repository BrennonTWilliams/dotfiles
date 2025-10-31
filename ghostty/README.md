# Ghostty Terminal Configuration

## Overview

This directory contains Ghostty terminal emulator configuration optimized for macOS development with Gruvbox Dark theming and seamless integration with the dotfiles ecosystem.

## Features

### 🎨 Gruvbox Dark Theme
- Consistent theming with tmux and zsh
- Custom palette optimized for macOS displays
- True color support with 256-color compatibility

### ⚡ Performance Optimizations
- GPU acceleration using Metal on macOS
- High-performance text rendering
- Optimized for Apple Silicon (ARM64)

### 🍎 macOS Integration
- Native clipboard integration (pbcopy/pbpaste)
- CoreText font rendering optimization
- SwiftUI native interface
- Proper handling of macOS-specific features

### ⌨️ Keybinding Strategy
- **Ghostty-native keybindings** with tmux integration
- **Ctrl+C/V** for copy/paste (macOS style)
- **Ctrl+Shift+T/A/S** for tmux session management
- **Ctrl+T** for new tabs, **Ctrl+W** for close operations

### 🔧 Development Features
- IosevkaTerm Nerd Font configuration
- Shell integration with zsh and Oh My Zsh
- Working directory inheritance
- Mouse support and focus events for vim/nvim

## Configuration Structure

```
ghostty/
├── .config/
│   └── ghostty/
│       └── config      # Main configuration file
└── README.md            # This file
```

## Installation

The Ghostty configuration is installed automatically when running:

```bash
./install.sh --all --packages
```

Or install Ghostty specifically:

```bash
# Install Ghostty via Homebrew
brew install --cask ghostty

# Install dotfiles configuration
./install.sh ghostty
```

## Key Features

### Font Configuration
- **Font**: IosevkaTerm Nerd Font (14pt)
- **Ligatures**: Enabled for better code readability
- **Rendering**: LCD mode optimized for macOS

### Theme Customization
- Base theme: `gruvbox-dark`
- Custom color palette for consistency
- Optimized contrast for macOS displays

### Window Management
- **Background opacity**: 95% with blur
- **Padding**: 8px for visual comfort
- **Shadow**: Native macOS window shadow
- **Fullscreen**: Native macOS fullscreen support

### Performance Settings
- **GPU acceleration**: Metal renderer
- **VSync**: Enabled for smooth scrolling
- **Resize strategy**: Burst for responsive resizing

## Keybindings Reference

### Essential Operations
- `Ctrl+C` - Copy to clipboard
- `Ctrl+V` - Paste from clipboard
- `Ctrl+T` - New tab
- `Ctrl+W` - Close window/tab
- `Ctrl+N` - New window
- `Cmd+Enter` - Toggle fullscreen

### Tmux Integration
- `Ctrl+Shift+T` - New tmux session
- `Ctrl+Shift+A` - Attach to main tmux session
- `Ctrl+Shift+S` - Attach to any tmux session
- `Ctrl+Shift+L` - List tmux sessions
- `Ctrl+Shift+K` - Kill main tmux session

### Font & Display
- `Ctrl+Plus` - Increase font size
- `Ctrl+Minus` - Decrease font size
- `Ctrl+0` - Reset font size

### Search & Navigation
- `Ctrl+F` - Find
- `Ctrl+G` - Find next
- `Ctrl+Shift+G` - Find previous

## Customization

### Local Overrides
Create `~/.config/ghostty/config.local` for machine-specific settings:

```bash
# Example local overrides
font-size = 16
background-opacity = 0.98
```

### Theme Variants
The configuration uses Gruvbox Dark as base. For light themes, change:
```bash
theme = gruvbox-light
```

### Shell Integration
The configuration is optimized for zsh with Oh My Zsh. To use other shells:
```bash
# For fish
shell-integration = fish

# For bash
shell-integration = bash

# Or disable
shell-integration = none
```

## Integration with Dotfiles

This Ghostty configuration is designed to work seamlessly with:
- **Zsh configuration** (`.zshrc`) - Gruvbox theme, aliases
- **Tmux configuration** (`.tmux.conf`) - Matching colors, keybindings
- **macOS aliases** - Native clipboard and system integration
- **Development tools** - Git, fzf, ripgrep integration

## Troubleshooting

### Font Issues
If IosevkaTerm Nerd Font is not found:
```bash
# Install via Homebrew
brew tap homebrew/cask-fonts
brew install font-iosevka-nerd-font
```

### Performance Issues
For better performance on older Macs:
```bash
# Disable GPU acceleration
renderer = cpu

# Reduce font rendering quality
font-render-mode = ascii
```

### Clipboard Issues
If clipboard integration doesn't work:
```bash
# Ensure Ghostty has necessary permissions
# System Settings > Privacy & Security > Accessibility
# Add Ghostty to allowed applications
```

## Platform Compatibility

This configuration is specifically optimized for:
- **macOS 12+** (Monterey and later)
- **Apple Silicon** (M1/M2/M3/M4) and Intel Macs
- **Homebrew** package management

For cross-platform consistency, the Gruvbox theme matches the Linux Foot terminal configuration.

## Support

For issues with:
- **Ghostty application**: https://github.com/ghostty-org/ghostty
- **Dotfiles integration**: Check the main dotfiles README and troubleshooting guide
- **Theme customization**: Refer to Ghostty documentation for theme syntax