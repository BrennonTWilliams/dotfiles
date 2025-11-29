# Cross-Platform Utilities

Documentation for the cross-platform shell utilities that enable seamless operation across macOS and Linux.

---

## Table of Contents

- [Overview](#overview)
- [Platform Detection](#platform-detection)
- [Dynamic Path Resolution](#dynamic-path-resolution)
- [Clipboard Utilities](#clipboard-utilities)
- [Terminal Detection](#terminal-detection)
- [Usage Examples](#usage-examples)

---

## Overview

The cross-platform utilities (`zsh/.zsh_cross_platform`) provide:

- **Automatic platform detection** - Identifies OS, distribution, desktop environment
- **Dynamic path resolution** - Resolves 21 platform-specific paths
- **Unified commands** - Same aliases work on macOS and Linux
- **Performance caching** - Avoids redundant subprocess calls

**Source file:** `zsh/.zsh_cross_platform`

---

## Platform Detection

### Operating System

```bash
detect_os
# Returns: macos, linux, windows, unknown
```

**Example:**
```bash
case "$(detect_os)" in
    macos)  echo "Running on macOS" ;;
    linux)  echo "Running on Linux" ;;
esac
```

### Linux Distribution

```bash
detect_linux_distro
# Returns: ubuntu, debian, fedora, arch, centos, etc.
```

**Example:**
```bash
if [[ "$(detect_os)" == "linux" ]]; then
    distro=$(detect_linux_distro)
    echo "Distribution: $distro"
fi
```

### Desktop Environment

```bash
detect_desktop_env
# Returns: sway, wayland, x11, i3, gnome, kde, unknown
```

**Detection logic:**
- Checks `$SWAYSOCK` for Sway
- Checks `$WAYLAND_DISPLAY` for Wayland
- Checks `$DISPLAY` for X11
- Checks for specific WM commands

### Terminal Emulator

```bash
detect_terminal
# Returns: ghostty, foot, kitty, alacritty, vscode, wezterm, etc.
```

**Detection logic:**
- `$GHOSTTY_RESOURCES` - Ghostty
- `$FOOT_TERMINAL_ID` - Foot
- `$KITTY_WINDOW_ID` - Kitty
- `$TERM_PROGRAM` - Various terminals

---

## Dynamic Path Resolution

### Overview

The path resolution system handles platform-specific paths without hardcoding.

```bash
resolve_platform_path "path_type"
# Returns: Resolved absolute path
```

### Supported Paths (21 total)

| Path Type | Description | macOS | Linux |
|-----------|-------------|-------|-------|
| `dotfiles` | Dotfiles directory | `~/.dotfiles` | `~/.dotfiles` |
| `conda_root` | Conda installation | `~/miniforge3` | `~/miniforge3` |
| `conda_bin` | Conda binaries | `~/miniforge3/bin` | `~/miniforge3/bin` |
| `conda_profile` | Conda profile script | `.../conda.sh` | `.../conda.sh` |
| `docker_completions` | Docker completions | `~/.docker/completions` | `~/.docker/completions` |
| `npm_global` | NPM global dir | `~/.npm-global` | `~/.npm-global` |
| `npm_global_bin` | NPM global binaries | `~/.npm-global/bin` | `~/.npm-global/bin` |
| `local_lib` | Local libraries | `~/.local/lib` | `~/.local/lib` |
| `starship_config` | Starship config | `~/.config/starship` | `~/.config/starship` |
| `vscode_config` | VSCode settings | `~/Library/Application Support/Code/User` | `~/.config/Code/User` |
| `gitconfig` | Git config | `~/.gitconfig` | `~/.gitconfig` |
| `npmrc` | NPM config | `~/.npmrc` | `~/.npmrc` |
| `ssh_dir` | SSH directory | `~/.ssh` | `~/.ssh` |
| `tmux_local` | Tmux local config | `~/.tmux.local` | `~/.tmux.local` |
| `zshrc_local` | Zsh local config | `~/.zshrc.local` | `~/.zshrc.local` |
| `zshenv_local` | Zshenv local config | `~/.zshenv.local` | `~/.zshenv.local` |
| `zprofile_local` | Zprofile local | `~/.zprofile.local` | `~/.zprofile.local` |
| `bashrc_local` | Bashrc local | `~/.bashrc.local` | `~/.bashrc.local` |
| `bash_profile_local` | Bash profile local | `~/.bash_profile.local` | `~/.bash_profile.local` |
| `gitconfig_local` | Git local config | `~/.gitconfig.local` | `~/.gitconfig.local` |
| `npmrc_local` | NPM local config | `~/.npmrc.local` | `~/.npmrc.local` |

### Usage Examples

```bash
# Get VSCode config path
vscode_path=$(resolve_platform_path "vscode_config")
echo "VSCode settings at: $vscode_path"
# macOS: ~/Library/Application Support/Code/User
# Linux: ~/.config/Code/User

# Get conda bin directory
conda_bin=$(resolve_platform_path "conda_bin")
export PATH="$conda_bin:$PATH"

# Check if local config exists
local_zshrc=$(resolve_platform_path "zshrc_local")
[[ -f "$local_zshrc" ]] && source "$local_zshrc"
```

### Caching System

Paths are cached for performance:

```bash
# First call: resolves and caches
resolve_platform_path "vscode_config"  # ~5ms

# Subsequent calls: instant from cache
resolve_platform_path "vscode_config"  # <1ms
```

Cache is stored in `_PLATFORM_PATH_CACHE` associative array.

---

## Clipboard Utilities

### Cross-Platform Clipboard

The dotfiles provide unified clipboard access:

**macOS:**
- Uses `pbcopy` / `pbpaste` (built-in)

**Linux (Wayland):**
- Uses `wl-copy` / `wl-paste`

**Linux (X11):**
- Uses `xclip`

### Uniclip (Cross-Device Sync)

Sync clipboard between devices:

```bash
# Install Uniclip service
uniclip-install

# Start service
uniclip-start

# Check status
uniclip-status

# Stop service
uniclip-stop

# Manual sync
clipboard-sync
```

**Configuration:**
```bash
# In ~/.zshrc.local
export UNICLIP_SERVER="192.168.1.100:38687"
```

---

## Terminal Detection

### Automatic Detection

```bash
terminal=$(detect_terminal)
echo "Running in: $terminal"
```

### Terminal-Specific Configuration

```bash
case "$(detect_terminal)" in
    ghostty)
        # Ghostty-specific settings
        export GHOSTTY_SHELL_INTEGRATION=1
        ;;
    foot)
        # Foot-specific settings
        ;;
    vscode)
        # VSCode integrated terminal
        export TERM_PROGRAM="vscode"
        ;;
esac
```

---

## Usage Examples

### Script: Platform-Aware Installation

```bash
#!/bin/bash
source ~/.zsh_cross_platform

os=$(detect_os)

case "$os" in
    macos)
        brew install ripgrep
        ;;
    linux)
        distro=$(detect_linux_distro)
        case "$distro" in
            ubuntu|debian)
                sudo apt install ripgrep
                ;;
            fedora)
                sudo dnf install ripgrep
                ;;
            arch)
                sudo pacman -S ripgrep
                ;;
        esac
        ;;
esac
```

### Script: Cross-Platform Config Path

```bash
#!/bin/bash
source ~/.zsh_cross_platform

# Get platform-specific VSCode path
vscode_dir=$(resolve_platform_path "vscode_config")

# Copy settings
cp settings.json "$vscode_dir/settings.json"
```

### Alias: Platform-Aware Open

```bash
# In zsh config
if [[ "$(detect_os)" == "linux" ]]; then
    alias open='xdg-open'
fi
# macOS already has 'open' built-in
```

### Function: Cross-Platform Clipboard

```bash
clip() {
    case "$(detect_os)" in
        macos)
            pbcopy
            ;;
        linux)
            if [[ -n "$WAYLAND_DISPLAY" ]]; then
                wl-copy
            else
                xclip -selection clipboard
            fi
            ;;
    esac
}

# Usage: echo "text" | clip
```

---

## Status Commands

### Development Status

```bash
dev-status
```

Shows:
- Platform information
- Installed development tools
- Service status
- Quick fix suggestions

### System Status

```bash
system-status
```

Shows:
- OS and kernel info
- Terminal and desktop environment
- Shell configuration
- Dotfiles location

---

## Environment Variables

### Exported Variables

```bash
# Set by cross-platform utilities
export DOTFILES_DIR="$(resolve_platform_path "dotfiles")"
export CONDA_ROOT="$(resolve_platform_path "conda_root")"
export CONDA_BIN="$(resolve_platform_path "conda_bin")"
```

### Platform-Specific Variables

**macOS:**
```bash
# Homebrew path (auto-detected)
/opt/homebrew  # Apple Silicon
/usr/local     # Intel
```

**Linux:**
```bash
# Desktop environment
$SWAYSOCK          # Sway socket
$WAYLAND_DISPLAY   # Wayland display
$DISPLAY           # X11 display
```

---

## Troubleshooting

### Path Resolution Issues

```bash
# Test path resolution
source ~/.zsh_cross_platform
resolve_platform_path dotfiles
resolve_platform_path vscode_config

# Clear cache and re-resolve
unset _PLATFORM_PATH_CACHE
resolve_platform_path dotfiles
```

### Detection Issues

```bash
# Debug platform detection
echo "OS: $(detect_os)"
echo "Distro: $(detect_linux_distro)"
echo "Desktop: $(detect_desktop_env)"
echo "Terminal: $(detect_terminal)"
```

### Clipboard Not Working

```bash
# Check clipboard tools
which pbcopy       # macOS
which wl-copy      # Wayland
which xclip        # X11

# Test clipboard
echo "test" | pbcopy && pbpaste  # macOS
echo "test" | wl-copy && wl-paste  # Wayland
```

---

## See Also

- [FEATURES.md](FEATURES.md) - Feature overview
- [SYSTEM_SETUP.md](SYSTEM_SETUP.md) - Environment setup
- [../TROUBLESHOOTING.md](../TROUBLESHOOTING.md) - Common issues
