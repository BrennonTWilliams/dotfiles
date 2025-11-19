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
- **Finder integration** - Open terminal from any folder (see [Finder Integration](#finder-integration))

### ⌨️ Keybinding Strategy
- **Ghostty-native keybindings** with proven syntax
- **Ctrl+Shift+C/V** for copy/paste (avoid shell conflicts)
- **Ctrl+Shift+N/T** for window/tab management
- **Standard tmux keybindings** (Ctrl+A) for session management

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
│       └── config           # Main configuration file
├── automator/               # Finder integration Quick Actions
│   ├── *.workflow/          # Automator workflow bundles
│   ├── install-quick-actions.sh  # Installation script
│   └── README.md            # Automator documentation
├── completions/
│   └── _ghostty             # Zsh completions
└── README.md                # This file
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
- Base theme: `Gruvbox Dark`
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
- `Ctrl+Shift+C` - Copy to clipboard
- `Ctrl+Shift+V` - Paste from clipboard
- `Ctrl+Shift+N` - New window
- `Ctrl+Shift+T` - New tab

### Font & Display
- Font size adjustments handled by system gestures
- Use Cmd+Plus/Minus for system-level font scaling

### Additional Features
- **Search**: Use Cmd+F (built-in search)
- **Fullscreen**: Use system fullscreen or Cmd+Enter
- **Tmux**: Use standard tmux keybindings (Ctrl+A) within sessions

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
theme = Gruvbox Light
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

## Finder Integration

Open Ghostty terminal windows directly from Finder with multiple integration options.

### Built-in Finder Services

Ghostty includes native macOS Services for Finder integration:

**Quick Access:**
1. Right-click on any folder in Finder
2. Navigate to **Services** → **"New Ghostty Window Here"**
3. Terminal opens at the selected location

**Keyboard Shortcuts:**
Assign shortcuts in System Settings → Keyboard → Keyboard Shortcuts → Services:
- Recommended: `⌘⌥T` for "New Ghostty Window Here"
- Alternative: `⌘⌥⇧T` for "New Ghostty Tab Here"

### Automator Quick Actions

Custom Quick Actions for enhanced workflow:

**Installation:**
```bash
# Install Quick Actions
./ghostty/automator/install-quick-actions.sh

# Verify installation
./ghostty/automator/install-quick-actions.sh --verify
```

**Features:**
- Right-click context menu integration
- Finder toolbar button support
- Customizable keyboard shortcuts
- Touch Bar support (if available)

### Third-Party Integration

**OpenInTerminal App:**
Professional Finder toolbar integration with multi-terminal support.

```bash
# Install via Homebrew
brew install --cask openinterminal

# Configure in app preferences:
# - Set Ghostty as default terminal
# - Assign global keyboard shortcut
# - Add to Finder toolbar
```

### Comprehensive Guide

For complete setup instructions, troubleshooting, and advanced configuration:

**→ See:** [**Finder Integration Guide**](../docs/GHOSTTY_FINDER_INTEGRATION.md)

This comprehensive guide includes:
- Detailed setup instructions for all integration methods
- Keyboard shortcut configuration
- Permission troubleshooting
- Custom workflow examples
- Comparison of integration options

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
# Ghostty automatically handles performance optimization
# Use minimal configuration in config.local
echo "background-blur = 0" >> ~/.config/ghostty/config.local
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