# Features Guide

Comprehensive documentation of all features included in this dotfiles repository.

---

## Table of Contents

- [Unified Gruvbox Theme](#unified-gruvbox-theme)
- [Cross-Platform Compatibility](#cross-platform-compatibility)
- [Performance Optimizations](#performance-optimizations)
- [Production-Ready Features](#production-ready-features)
- [Development Environment](#development-environment)
- [Shell Features](#shell-features)
- [Terminal Features](#terminal-features)

---

## Unified Gruvbox Theme

A consistent, warm color palette across all tools for a cohesive visual experience. Both dark and light modes are fully supported with authentic Gruvbox colors.

### What's Themed

| Component | Dark | Light |
|-----------|------|-------|
| Terminal (Ghostty) | `gruvbox-dark-custom` | `gruvbox-light-custom` |
| Starship prompt | `gruvbox-rainbow` | `gruvbox-rainbow-light` |
| Tmux status bar | Conditional via `$THEME_MODE` | Conditional via `$THEME_MODE` |
| Neovim | `vim.o.background = "dark"` | `vim.o.background = "light"` |
| Obsidian | CSS `.theme-dark` rules | CSS `.theme-light` rules |
| Git diff | Delta with Gruvbox | Delta with Gruvbox |

### Dark/Light Mode Toggle

A central `toggle-theme` shell function switches all tools at once:

```bash
toggle-theme    # flip between dark and light
```

This updates Ghostty (via `config.local`), Starship (symlink swap), tmux (config reload), and persists the choice to `~/.config/theme-mode`. Neovim has its own independent toggle via `<leader>tb`.

On shell startup, the theme mode is auto-detected from macOS system appearance if no state file exists.

See the [Usage Guide](USAGE_GUIDE.md#theme-switching) for full details.

### Color Palettes

**Dark mode:**
```
Background: #1d2021 (dark0-hard)
Foreground: #ebdbb2 (light1)
Red:        #cc241d / #fb4934
Green:      #98971a / #b8bb26
Yellow:     #d79921 / #fabd2f
Blue:       #458588 / #83a598
Purple:     #b16286 / #d3869b
Aqua:       #689d6a / #8ec07c
Orange:     #d65d0e / #fe8019
```

**Light mode:**
```
Background: #f9f5d7 (light0-hard)
Foreground: #3c3836 (dark1)
Red:        #9d0006 / #cc241d
Green:      #79740e / #98971a
Yellow:     #b57614 / #d79921
Blue:       #076678 / #458588
Purple:     #8f3f71 / #b16286
Aqua:       #427b58 / #689d6a
Orange:     #af3a03 / #d65d0e
```

### Nerd Font Icons

All configurations use Nerd Font icons for:
- File type indicators
- Git status symbols
- Prompt segments
- Directory icons

**Recommended fonts:**
- MesloLGS Nerd Font
- FiraCode Nerd Font
- JetBrainsMono Nerd Font

---

## Cross-Platform Compatibility

Works seamlessly on macOS and Linux with automatic platform detection.

### Dynamic Path Resolution

Resolves 21 platform-specific paths automatically:

| Path Type | macOS | Linux |
|-----------|-------|-------|
| `dotfiles` | `~/.dotfiles` | `~/.dotfiles` |
| `conda_root` | `~/miniforge3` | `~/miniforge3` |
| `vscode_config` | `~/Library/Application Support/Code/User` | `~/.config/Code/User` |
| `docker_completions` | `~/.docker/completions` | `~/.docker/completions` |

**Usage:**
```bash
# In shell scripts
config_path=$(resolve_platform_path "vscode_config")
```

### Platform Detection Functions

```bash
detect_os           # Returns: macos, linux, windows
detect_linux_distro # Returns: ubuntu, fedora, arch, etc.
detect_desktop_env  # Returns: sway, wayland, x11, etc.
detect_terminal     # Returns: ghostty, foot, kitty, etc.
```

### Unified Commands

Same aliases work everywhere:
- `ll` - Enhanced directory listing
- `clipboard-sync` - Cross-device clipboard
- `open` - Opens files/URLs (works on both platforms)

See [CROSS_PLATFORM_UTILITIES.md](CROSS_PLATFORM_UTILITIES.md) for details.

---

## Performance Optimizations

Shell startup optimized for speed (<50ms target).

### Lazy Loading

**Conda initialization:**
```bash
# Only loads when you first use conda/mamba
conda activate myenv  # Triggers initialization
```
Saves 100-200ms on every shell startup.

**NVM (Node Version Manager):**
```bash
# Loaded on first use of node/npm/nvm
node --version  # Triggers initialization
```

### Path Caching

Platform paths are cached in associative arrays for O(1) lookups:

```bash
# First call: resolves and caches
resolve_platform_path "vscode_config"

# Subsequent calls: instant from cache
resolve_platform_path "vscode_config"  # No subprocess
```

### VSCode Integration

Fast terminal startup in VSCode with cached detection:
- Skips redundant initialization
- Optimized PATH setup
- Minimal prompt in integrated terminal

---

## Production-Ready Features

Enterprise-grade reliability for daily use.

### Dependency Validation

Pre-flight checks before installation:

```bash
./install.sh --check-deps
```

Validates:
- Required tools (git, stow, curl)
- Package managers (Homebrew, apt, etc.)
- Disk space requirements
- Network connectivity

### Conflict Resolution

Intelligent handling of existing dotfiles:

```bash
# Interactive (default)
./install.sh --dotfiles

# Automatic strategies
./install.sh --dotfiles --auto-resolve=overwrite
./install.sh --dotfiles --auto-resolve=keep-existing
./install.sh --dotfiles --auto-resolve=backup-all
```

Features:
- Side-by-side diff viewing
- Intelligent config merging
- Automatic backups with metadata

### Preview Mode

See changes before applying:

```bash
./install.sh --preview --all
```

Shows:
- Packages to install/upgrade
- Symlinks to create
- Conflicts detected
- Resource estimates

### Health Check System

Comprehensive post-install validation:

```bash
health-check
# or
./scripts/health-check.sh
```

Checks:
- Symlink integrity
- Tool availability
- Configuration validity
- Service status

### Backup System

Automatic backups during installation:
- Timestamped backup directories
- Metadata files for each backup
- Easy restore procedures

See [BACKUP_RECOVERY.md](BACKUP_RECOVERY.md) for details.

---

## Development Environment

Complete development tooling setup.

### Git Configuration

- Portable user settings (via `.gitconfig.local`)
- Useful aliases (gs, gc, gp, etc.)
- Delta for beautiful diffs
- GPG signing support

### VS Code Integration

- Settings sync via dotfiles
- Extension list management
- Keybindings configuration

```bash
# Install extensions from list
xargs -a vscode/extensions.txt code --install-extension
```

### NPM Configuration

- Global package directory (`~/.npm-global`)
- Package list for reinstallation
- Cross-platform npmrc

### Python/Conda Support

- Lazy-loaded Conda initialization
- Miniforge/Miniconda detection
- Virtual environment helpers

### Docker Completions

- Shell completions for Docker CLI
- Cross-platform completion paths

---

## Shell Features

### Starship Prompt

Three display modes:

| Mode | Command | Description |
|------|---------|-------------|
| Compact | `starship-compact` (sc) | Minimal info, single line |
| Standard | `starship-standard` (ss) | Balanced, multi-line |
| Verbose | `starship-verbose` (sv) | Full context, all details |

Check current mode: `starship-mode` (sm)

### Abbreviations (zsh-abbr)

Expands on Space/Enter for faster typing:

```bash
gs<space>  # Expands to: git status
gp<enter>  # Expands to: git push
```

Toggle between abbreviations and traditional aliases:
```bash
# In ~/.zshenv.local
export DOTFILES_ABBR_MODE="alias"  # Use traditional aliases
```

### Shell Functions

| Function | Description |
|----------|-------------|
| `mkcd` | Create directory and cd into it |
| `qfind` | Quick file search |
| `extract` | Universal archive extraction |
| `nvim-keys` | Neovim keybinding reference |

### Safety Aliases

Protected commands with confirmation:
```bash
alias cp='cp -i'
```

---

## Terminal Features

### Ghostty (macOS)

- GPU-accelerated rendering
- Native macOS integration
- Gruvbox theme configured
- Shell integration enabled

### Foot (Linux)

- Wayland-native terminal
- Fast and lightweight
- Gruvbox theme configured
- Sixel graphics support

### Tmux Integration

- Clipboard sync across panes
- Gruvbox status bar theme
- Intuitive keybindings
- Plugin manager (TPM)

**Key bindings:**
- `Prefix + I` - Install plugins
- `Prefix + r` - Reload config
- `Prefix + |` - Vertical split
- `Prefix + -` - Horizontal split

---

## Additional Features

### Uniclip (Clipboard Sync)

Cross-device clipboard sharing:

```bash
uniclip-install   # Install service
uniclip-start     # Start service
uniclip-status    # Check status
clipboard-sync    # Manual sync
```

### Custom Logo (Opt-in)

Disabled by default. Enable in `~/.zshrc.local`:

```bash
export DOTFILES_LOGO_ENABLED=true
```

Commands:
- `logo-toggle` - Enable/disable
- `logo-show` - Display manually

### Machine-Specific Overrides

All `.local` files are gitignored:
- `~/.zshrc.local` - Shell customizations
- `~/.gitconfig.local` - Git identity
- `~/.tmux.local` - Tmux overrides

---

## Feature Comparison

| Feature | This Repo | Typical Dotfiles |
|---------|-----------|------------------|
| Cross-Platform | [+] macOS + Linux | [-] Single platform |
| Installation | Modular with rollback | Monolithic script |
| Conflict Resolution | Interactive + auto modes | Overwrites blindly |
| Preview Mode | Dry-run available | No preview |
| Health Checks | Post-install validation | No verification |
| Path Management | 21 dynamic paths | Hardcoded |
| Theme Consistency | Unified Gruvbox | Inconsistent |
| Performance | <50ms startup | Often >200ms |
| Documentation | Comprehensive | README only |
