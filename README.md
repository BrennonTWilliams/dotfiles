# Dotfiles

[![Test Suite](https://github.com/BrennonTWilliams/dotfiles/actions/workflows/test.yml/badge.svg)](https://github.com/BrennonTWilliams/dotfiles/actions/workflows/test.yml)
[![ShellCheck](https://github.com/BrennonTWilliams/dotfiles/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/BrennonTWilliams/dotfiles/actions/workflows/shellcheck.yml)
[![Starship Config](https://github.com/BrennonTWilliams/dotfiles/actions/workflows/starship-validation.yml/badge.svg)](https://github.com/BrennonTWilliams/dotfiles/actions/workflows/starship-validation.yml)
[![Code Quality](https://github.com/BrennonTWilliams/dotfiles/actions/workflows/lint.yml/badge.svg)](https://github.com/BrennonTWilliams/dotfiles/actions/workflows/lint.yml)

> A production-ready, cross-platform dotfiles repository with modular installation, comprehensive health checks, and unified Gruvbox theming across macOS and Linux environments.

---

## TL;DR

**Get started in 60 seconds:**

```bash
git clone git@github.com:BrennonTWilliams/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install-new.sh --all
```

**What you get:** Modern terminal (Ghostty/Foot), Starship prompt with Gruvbox theme, cross-platform shell utilities, comprehensive development environment, health monitoring, and modular configuration.

**Platforms:** macOS (Apple Silicon & Intel), Linux (Ubuntu, Fedora, Arch) with automatic platform detection.

---

## Screenshot

![Dotfiles Terminal Setup](docs/images/terminal-screenshot.png)
*Unified Gruvbox theme with Starship prompt across macOS (Ghostty) and Linux (Foot)*

---

## Why This Dotfiles?

| Feature | This Repo | Typical Dotfiles |
|---------|-----------|------------------|
| **Cross-Platform** | ✅ macOS + Linux with auto-detection | ❌ Usually single-platform |
| **Installation** | Modular installer with rollback | ⚠️ Monolithic script |
| **Conflict Resolution** | ✅ Interactive + auto-resolve modes | ❌ Overwrites blindly |
| **Preview Mode** | ✅ Dry-run before installing | ❌ No preview capability |
| **Health Checks** | Post-install validation system | ❌ No verification |
| **Path Management** | Dynamic resolution (13 paths) | ❌ Hardcoded paths |
| **Theme Consistency** | Unified Gruvbox everywhere | ⚠️ Inconsistent colors |
| **Performance** | Optimized shell startup (<50ms) | ⚠️ Often >200ms |
| **Documentation** | Comprehensive with examples | ⚠️ README only |
| **Recovery** | Automatic backups + restore | ❌ Manual process |
| **Updates** | Smart update scripts | ⚠️ Git pull only |
| **Community** | Issue templates, PR templates, CoC | ❌ Minimal |

---

## Table of Contents

- [Quick Start](#quick-start)
- [What's Inside](#whats-inside)
- [Key Features](#key-features)
- [Platform Support](#platform-support)
- [Installation](#installation)
- [First Steps After Install](#first-steps-after-install)
- [Quick Reference](#quick-reference)
- [Machine-Specific Configuration](#machine-specific-configuration)
- [Updating & Maintenance](#updating--maintenance)
- [Troubleshooting](#troubleshooting)
- [Documentation](#documentation)
- [Contributing](#contributing)
- [License](#license)

---

## Quick Start

### Prerequisites

**macOS:**
```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt update && sudo apt install -y git curl stow
```

### Installation

```bash
# 1. Clone the repository
git clone git@github.com:BrennonTWilliams/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# 2. Run the modular installer
./install-new.sh --all

# 3. Reload your shell
exec zsh
```

**Installation options:**
- `./install-new.sh` - Interactive installation (recommended for first-time)
- `./install-new.sh --all` - Install everything automatically
- `./install-new.sh --packages` - System packages only
- `./install-new.sh --terminal` - Terminal and shell only
- `./install-new.sh --dotfiles` - Dotfiles only (assumes packages installed)
- `./install-new.sh --check-deps` - Check system dependencies without installing
- `./install-new.sh --preview --all` - **Preview changes without installing** (dry-run mode)

**Preview mode** lets you see what would be installed before making changes:
```bash
./install-new.sh --preview --all          # Preview complete installation
./install-new.sh --preview --packages     # Preview package installations
./install-new.sh --preview --dotfiles     # Preview symlink creation
./install-new.sh --preview --all --verbose # Detailed preview output
```

**Conflict resolution** handles existing dotfiles intelligently:
```bash
./install-new.sh --dotfiles                          # Interactive prompts (default)
./install-new.sh --dotfiles --auto-resolve=overwrite # Auto-backup and replace
./install-new.sh --dotfiles --auto-resolve=keep-existing # Keep your files
```

See [Installation Guide](docs/GETTING_STARTED.md) for platform-specific detailed instructions.

---

## What's Inside

```
dotfiles/
├── zsh/              # Zsh configuration with cross-platform utilities
│   ├── functions/    # Shell functions (mkcd, qfind, nvim-keys, etc.)
│   ├── aliases/      # Traditional aliases (safety aliases, extras)
│   └── abbreviations/# zsh-abbr abbreviations (optional, expands on space)
├── starship/         # Starship prompt (3 display modes: compact, standard, verbose)
├── tmux/             # Tmux with clipboard integration and theme
├── nvim/             # Neovim configuration
├── git/              # Git config with portable user settings
├── ghostty/          # Ghostty terminal (macOS)
├── foot/             # Foot terminal (Linux)
├── sway/             # Sway window manager (Linux)
├── scripts/          # Installation, setup, and maintenance scripts
│   ├── lib/          # Shared utility functions
│   ├── setup-packages.sh    # System package installation
│   ├── setup-terminal.sh    # Terminal and shell setup
│   └── health-check.sh      # Post-installation validation
└── docs/             # Comprehensive documentation
```

**Managed with [GNU Stow](https://www.gnu.org/software/stow/)** - Creates symlinks from `~/.dotfiles/*` to `~/`

---

## Key Features

### 🎨 Unified Gruvbox Theme
- Consistent colors across all tools (terminal, tmux, vim, editor)
- Dark mode optimized with warm palette
- Nerd Font icons throughout

### 🔄 Cross-Platform Compatibility
- **Dynamic path resolution** - No hardcoded paths
- **Platform detection** - Automatic macOS/Linux adaptation
- **Unified commands** - Same aliases work everywhere
- **Portable configs** - Works on any machine

### ⚡ Performance Optimized
- **Shell startup** - <50ms with lazy loading
- **Conda lazy-load** - Only initializes when used (saves 100-200ms)
- **VSCode integration** - Cached for instant startup
- **Path caching** - Eliminates redundant subprocess calls

### 🛡️ Production Ready
- **Dependency validation** - Pre-flight checks with auto-fix options
- **Conflict resolution** - Interactive prompts or auto-resolve strategies
- **Intelligent merging** - Automatically merge .gitconfig, .zshrc, etc.
- **Health checks** - Automatic post-install validation
- **Backup system** - Automatic backups with metadata
- **Rollback support** - Safe to test and revert
- **Error handling** - Clear messages and recovery steps

### 🚀 Development Environment
- Git configuration with portable user settings
- VS Code integration with extension management
- NPM global package configuration
- Python/Conda environment support
- Docker completions and aliases

See [Features Guide](docs/FEATURES.md) for detailed feature descriptions.

---

## Platform Support

| Platform | Architecture | Terminal | Status |
|----------|-------------|----------|--------|
| macOS | Apple Silicon (M1/M2/M3/M4) | Ghostty | ✅ Fully Supported |
| macOS | Intel x86_64 | Ghostty | ✅ Fully Supported |
| Linux | x86_64 / ARM64 | Foot | ✅ Fully Supported |

**Tested on:**
- macOS Sequoia (15.x) - Apple Silicon
- macOS Sonoma (14.x) - Intel
- Ubuntu 22.04/24.04 LTS
- Fedora 38+
- Arch Linux

**Automatic detection for:**
- Package managers (Homebrew, apt, dnf, pacman)
- Homebrew path (`/opt/homebrew` vs `/usr/local`)
- Desktop environment (Sway, i3, X11, Wayland)
- Clipboard utilities (pbcopy, wl-copy, xclip)

See [Getting Started Guide](docs/GETTING_STARTED.md) for platform-specific setup instructions.

---

## Installation

### Option 1: Full Installation (Recommended)

```bash
./install-new.sh --all
```

Installs:
1. System packages (Homebrew/apt packages)
2. Terminal applications (Ghostty/Foot, Starship)
3. Development tools (Git, tmux, neovim, fzf, ripgrep)
4. Dotfiles (symlinks all configurations)
5. Runs health checks

### Option 2: Modular Installation

**Packages only:**
```bash
./install-new.sh --packages
```

**Terminal setup only:**
```bash
./install-new.sh --terminal
```

**Dotfiles only** (assumes packages installed):
```bash
./install-new.sh --dotfiles
```

### Option 3: Interactive Installation

```bash
./install-new.sh
```

Prompts you to select which components to install.

### What Gets Installed

See [System Requirements](docs/SYSTEM_REQUIREMENTS.md) for detailed package lists and version requirements.

---

## First Steps After Install

### 1. Configure Git User Info

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

These override the portable defaults in `git/.gitconfig`.

### 2. Set Up Machine-Specific Settings

Create `~/.zshrc.local` for machine-specific shell configuration:

```bash
# Example: Custom paths
export PATH="$HOME/my-tools/bin:$PATH"

# Example: API keys
export OPENAI_API_KEY="your-key-here"

# Example: Custom aliases
alias work='cd ~/Projects/work'
```

See [Machine-Specific Configuration](#machine-specific-configuration) for more options.

### 3. Install Optional Tools

**VS Code extensions:**
```bash
xargs -a vscode/extensions.txt code --install-extension
```

**NPM global packages:**
```bash
xargs -a npm/global-packages.txt npm install -g
```

### 4. Run Health Check

```bash
./scripts/health-check.sh
```

Verifies all installations and reports any issues.

---

## Quick Reference

### Starship Display Modes

```bash
starship-compact    # Minimal info (sc)
starship-standard   # Balanced layout (ss)
starship-verbose    # Full context (sv)
starship-mode       # Show current mode (sm)
```

### Custom Logo (Opt-in)

The logo display is **disabled by default**. To enable:

```bash
# Add to ~/.zshrc.local
export DOTFILES_LOGO_ENABLED=true
```

Commands:
```bash
logo-toggle         # Enable/disable login logo animation
logo-show           # Display logo manually
```

Logo automatically skips display in SSH sessions, tmux, and screen.
See [brenentech/README.md](brenentech/README.md) for customization.

### Development Environment

```bash
dev-setup           # Run development environment setup
dev-install         # Update all development tools
dev-minimal         # Minimal installation (core + shell + dev-tools)
dev-status          # Show environment status
```

### Health & Maintenance

```bash
health-check        # Run comprehensive health check
dotfiles-check      # Alias for health check
system-status       # Display system information
```

### Uniclip (Clipboard Sync)

```bash
uniclip-install     # Install Uniclip service
uniclip-start       # Start Uniclip service
uniclip-stop        # Stop Uniclip service
uniclip-status      # Show service status
clipboard-sync      # Sync clipboard (one-time)
```

See [Usage Guide](docs/USAGE_GUIDE.md) for complete command reference.

---

## Machine-Specific Configuration

Dotfiles supports machine-specific overrides without modifying tracked files:

### Shell Configuration

**`~/.zshrc.local`** - Sourced at the end of `.zshrc`
```bash
# Custom paths
export PATH="$HOME/bin:$PATH"

# Custom aliases
alias myproject='cd ~/Projects/myproject'

# Override defaults
export UNICLIP_SERVER="192.168.1.100:38687"
```

**`~/.zshenv.local`** - Sourced from `.zshenv`
```bash
# Enable zsh-abbr abbreviations (expands shortcuts on space/enter)
# Options: alias (default), abbr, both
export DOTFILES_ABBR_MODE="abbr"
```

**`~/.zprofile.local`** - Sourced from `.zprofile`

### Git Configuration

**`~/.gitconfig.local`** - Automatically included from `git/.gitconfig`
```ini
[user]
    name = Your Name
    email = your.email@example.com

[github]
    user = yourusername
```

### Tmux Configuration

**`~/.tmux.local`** - Sourced from `.tmux.conf`
```tmux
# Machine-specific tmux settings
set -g mouse on
```

All `*.local` files are gitignored and never tracked.

---

## Updating & Maintenance

### Update Dotfiles

```bash
cd ~/.dotfiles
git pull
stow --restow */  # Re-apply symlinks
./scripts/health-check.sh  # Verify
```

### Update System Packages

**macOS:**
```bash
brew update && brew upgrade
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt update && sudo apt upgrade
```

### Backup Before Major Changes

```bash
# Automatic backup during installation
./install-new.sh  # Creates ~/.dotfiles_backup_YYYYMMDD_HHMMSS

# Manual backup
cp -r ~/.dotfiles ~/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)
```

See [Backup & Recovery Guide](docs/BACKUP_RECOVERY.md) for restore procedures.

---

## Troubleshooting

### Installation Issues

**Stow conflicts:**
```bash
# Remove conflicting files first
rm ~/.zshrc  # or mv ~/.zshrc ~/.zshrc.backup
cd ~/.dotfiles
stow zsh
```

**Permission errors:**
```bash
# Ensure correct ownership
sudo chown -R $USER:$USER ~/.dotfiles
```

### Shell Issues

**Command not found:**
```bash
# Reload shell configuration
exec zsh
# or
source ~/.zshrc
```

**Slow startup:**
```bash
# Profile shell startup
zsh -xv 2>&1 | ts -i '%.s' | tee /tmp/zsh-startup.log
```

### Path Resolution Issues

```bash
# Test path resolution
source ~/.zsh_cross_platform
resolve_platform_path dotfiles
```

For more issues, see [Troubleshooting Guide](docs/TROUBLESHOOTING.md).

---

## Documentation

### Core Documentation
- [Getting Started Guide](docs/GETTING_STARTED.md) - Platform-specific setup instructions
- [Features Guide](docs/FEATURES.md) - Detailed feature descriptions and usage
- [Usage Guide](docs/USAGE_GUIDE.md) - Complete command and alias reference
- [System Requirements](docs/SYSTEM_REQUIREMENTS.md) - Version requirements and package lists

### Configuration Guides
- [Starship Configuration](docs/STARSHIP_CONFIGURATION.md) - Prompt customization and modes
- [Cross-Platform Utilities](docs/CROSS_PLATFORM_UTILITIES.md) - Path resolution and platform detection
- [Health Check System](docs/HEALTH_CHECK_SYSTEM.md) - Post-installation validation

### Maintenance & Development
- [Backup & Recovery](docs/BACKUP_RECOVERY.md) - Backup procedures and restore steps
- [Troubleshooting Guide](docs/TROUBLESHOOTING.md) - Common issues and solutions
- [Contributing Guidelines](CONTRIBUTING.md) - Development setup and contribution process
- [Changelog](CHANGELOG.md) - Version history and migration guides

### Additional Resources
- [Code of Conduct](CODE_OF_CONDUCT.md) - Community standards
- [Security Policy](SECURITY.md) - Vulnerability reporting
- [License](LICENSE.md) - MIT License
- [Third-Party Licenses](docs/THIRD-PARTY-LICENSES.md) - Dependency attributions

---

## Contributing

We welcome contributions! Please see:

- [Contributing Guidelines](CONTRIBUTING.md) - How to contribute
- [Code of Conduct](CODE_OF_CONDUCT.md) - Community standards
- [Issue Templates](.github/ISSUE_TEMPLATE/) - Report bugs or request features
- [Pull Request Template](.github/pull_request_template.md) - Submit changes

### Quick Contribution

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests (`./scripts/health-check.sh`)
5. Commit (`git commit -m 'Add amazing feature'`)
6. Push to branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

---

## License

This project is licensed under the MIT License - see [LICENSE.md](LICENSE.md) for details.

### Third-Party Software

This repository includes configurations for many open-source tools. See [THIRD-PARTY-LICENSES.md](docs/THIRD-PARTY-LICENSES.md) for complete attribution and license information.

---

## Acknowledgments

- **[Gruvbox](https://github.com/morhetz/gruvbox)** - Beautiful retro groove color scheme
- **[Starship](https://starship.rs/)** - The minimal, blazing-fast, and infinitely customizable prompt
- **[GNU Stow](https://www.gnu.org/software/stow/)** - Symlink farm manager
- **[Ghostty](https://mitchellh.com/ghostty)** - Fast, native, GPU-accelerated terminal (macOS)
- **[Foot](https://codeberg.org/dnkl/foot)** - Fast, lightweight Wayland terminal emulator (Linux)

---

<p align="center">
  <sub>Built with ❤️ for developers who care about their environment</sub>
</p>

<p align="center">
  <sub>⭐ Star this repo if you find it useful!</sub>
</p>
