# Dotfiles

A comprehensive, cross-platform dotfiles repository with modular installation scripts, supporting macOS and Linux environments. Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## 🚀 What's New

### ✨ Recent Improvements (November 2024)

- **Dynamic Path Resolution**: Eliminated all 13 hardcoded paths for true cross-platform compatibility
- **Health Check System**: Comprehensive post-installation validation with automated monitoring
- **Modular Installation**: Replaced monolithic 1030-line installer with focused, maintainable scripts
- **Starship Prompt**: Enhanced with Nerd Font icons and dynamic mode switching
- **Security Enhancements**: Removed hardcoded IPs, consolidated PATH exports, eliminated dead code
- **Performance**: Optimized shell startup with better error handling and validation

### 🛠️ New Modular Structure

```
scripts/
├── lib/utils.sh           # Shared utility functions
├── setup-packages.sh      # System package installation
├── setup-terminal.sh      # Terminal and shell setup
└── setup-dev-env          # Development environment setup
```

**Use the new modular installer**: `./install-new.sh` (recommended)
**Legacy installer preserved**: `./install.sh` (backward compatibility)

## 🖥️ Multi-Device Architecture

This dotfiles repository is designed to work seamlessly across multiple platforms and devices:

### Supported Platforms

| Platform | Architecture | Package Manager | Terminal | Status |
|----------|-------------|----------------|----------|---------|
| **macOS** | Apple Silicon (M1/M2/M3/M4) | Homebrew (`/opt/homebrew`) | Ghostty | ✅ Fully Supported |
| **macOS** | Intel x86_64 | Homebrew (`/usr/local`) | Ghostty | ✅ Fully Supported |
| **Linux** | ARM64 (Raspberry Pi) | apt/dnf/pacman | Foot | ✅ Fully Supported |
| **Linux** | x86_64 | apt/dnf/pacman | Foot | ✅ Fully Supported |

### Platform-Specific Features

- **Automatic Platform Detection** - Scripts detect OS and adapt behavior
- **Package Manager Integration** - Uses appropriate package manager for each platform
- **Conditional Configuration** - Platform-specific aliases and features load automatically
- **Cross-Platform Clipboard** - Works with pbcopy (macOS) and xclip (Linux)
- **Unified Theme** - Gruvbox Dark theme works consistently across platforms
- **Modern Terminal Emulators** - Ghostty on macOS, Foot on Linux with GPU acceleration

### Apple Silicon Optimization

Special optimizations for Mac Mini M4 and other Apple Silicon Macs:

- **Native ARM64 Support** - All tools run natively without Rosetta 2
- **Homebrew Path Management** - Automatic detection of `/opt/homebrew` vs `/usr/local`
- **macOS-Specific Aliases** - Dedicated shortcuts for macOS workflow
- **Launchd Services** - Native macOS service integration (Uniclip clipboard sharing)
- **Ghostty Integration** - Native GPU-accelerated terminal with Metal rendering

## Quick Start

### 🚀 Recommended (New Modular Installer)

```bash
# Clone the repository
git clone git@github.com:BrennonTWilliams/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Run the new modular installer (interactive)
./install-new.sh

# Or install all components at once
./install-new.sh --all
```

### 🆕 Quick Start for New Configurations

After running the main installer:

```bash
# Update your Git user information (required)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Install VS Code extensions (if using VS Code)
xargs -a vscode/extensions.txt code --install-extension

# Install essential NPM global packages
xargs -a npm/global-packages.txt npm install -g

# Add NPM global packages to PATH (add to ~/.zshrc.local)
export PATH="$HOME/.npm-global/bin:$PATH"

# Reload shell
exec zsh
```

### 📦 Legacy Installer (Preserved)

```bash
# Clone the repository
git clone git@github.com:BrennonTWilliams/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Run the legacy installation script
./install.sh
```

### 🔧 Modular Installation Options

```bash
# Install all components
./install-new.sh --all

# Install system packages only
./install-new.sh --packages

# Setup terminal and shell only
./install-new.sh --terminal

# Install dotfiles only
./install-new.sh --dotfiles

# Interactive mode (default)
./install-new.sh
```

## 🐧 Linux First-Time Setup

**For Ubuntu, Debian, Fedora, Arch, openSUSE, and other Linux distributions**

### Step 1: Install Prerequisites

```bash
# Update package manager
sudo apt update && sudo apt upgrade -y           # Ubuntu/Debian
# sudo dnf update && sudo dnf upgrade -y         # Fedora
# sudo pacman -Syu                              # Arch/Manjaro
# sudo zypper update && sudo zypper up -y       # openSUSE

# Install essential packages
sudo apt install -y git stow zsh curl wget      # Ubuntu/Debian
# sudo dnf install -y git stow zsh curl wget    # Fedora
# sudo pacman -S git stow zsh curl wget         # Arch/Manjaro
# sudo zypper install -y git stow zsh curl wget # openSUSE
```

### Step 2: Install Dotfiles

```bash
# Clone and install
git clone git@github.com:BrennonTWilliams/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Install everything with Linux-specific packages
./install-new.sh --all

# Reload your shell
exec zsh
```

**⏱️ Total setup time: 10-20 minutes**

### Linux Distribution Support

| Distribution | Package Manager | Status | Notes |
|--------------|-----------------|---------|-------|
| **Ubuntu** | apt | ✅ Fully Supported | 20.04+ recommended |
| **Debian** | apt | ✅ Fully Supported | Debian 11+ recommended |
| **Fedora** | dnf | ✅ Fully Supported | Fedora 35+ recommended |
| **Arch** | pacman | ✅ Fully Supported | Rolling release |
| **openSUSE** | zypper | ✅ Fully Supported | Leap/Tumbleweed |
| **Manjaro** | pacman | ✅ Fully Supported | Arch-based |
| **Pop!_OS** | apt | ✅ Fully Supported | Ubuntu-based |
| **Linux Mint** | apt | ✅ Fully Supported | Ubuntu-based |

**Automatic distribution detection ensures proper package management and configuration.**

## 🍎 macOS First-Time Setup

**For Apple Silicon (M1/M2/M3/M4) and Intel Macs**

### Step 1: Install Prerequisites

```bash
# Install Xcode Command Line Tools (required for development)
xcode-select --install

# Install Homebrew (package manager)
# Apple Silicon Macs
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Intel Macs (same command - Homebrew detects architecture automatically)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Step 2: Install Dotfiles

```bash
# Clone and install
git clone git@github.com:BrennonTWilliams/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Install everything with platform-specific packages
./install-new.sh --all

# Reload your shell
exec zsh
```

**⏱️ Total setup time: 15-25 minutes**

### Apple Silicon vs Intel Mac Differences

| Feature | Apple Silicon (M1/M2/M3/M4) | Intel Macs |
|---------|----------------------------|------------|
| **Homebrew Path** | `/opt/homebrew` | `/usr/local` |
| **Architecture** | ARM64 native | x86_64 |
| **Performance** | Native ARM64 speed | Intel optimization |
| **Compatibility** | All tools ARM64-compatible | Universal binaries |
| **Rosetta 2** | Not required for these tools | N/A |

**All dotfiles work identically on both architectures - automatic detection ensures proper setup.**

## What's Inside

This repository contains configuration for:

- **Shell** - Zsh with Oh My Zsh, Bash with cross-platform support, custom aliases, and Gruvbox theme
- **Prompt** - Starship cross-shell prompt with Nerd Font icons, git and language support
- **Terminal Multiplexer** - Tmux with custom keybindings and Gruvbox theme
- **Window Manager** - Sway (i3-compatible Wayland compositor)
- **Terminal Emulators** - Ghostty (macOS) and Foot (Linux) with Gruvbox color scheme
- **Development Tools** - Git configuration, VS Code settings, NPM configuration, and CLI utilities
- **Editor Configuration** - VS Code extensions, settings, and keybindings for optimal development

**🆕 New in this version**: Added missing dotfiles from analysis - Git, VS Code, NPM, and enhanced shell configurations with security-focused template approach.

### Repository Structure

```
dotfiles/
├── install-new.sh              # 🆕 Main modular installer (recommended)
├── install.sh                  # 📦 Legacy installer (preserved)
├── scripts/
│   ├── lib/
│   │   └── utils.sh            # 🆕 Shared utility functions
│   ├── setup-packages.sh       # 🆕 System package installation
│   ├── setup-terminal.sh       # 🆕 Terminal and shell setup
│   ├── setup-new-configs.sh    # 🆕 Git, VS Code, and NPM setup
│   ├── setup-dev-env           # Development environment setup
│   └── uniclip-manager         # Clipboard management utility
├── git/
│   ├── .gitconfig              # Git configuration with templates
│   └── .gitignore              # Git ignore patterns
├── vscode/
│   ├── settings.json           # VS Code settings and preferences
│   ├── extensions.txt          # Essential extensions list
│   └── keybindings.json        # Custom keyboard shortcuts
├── npm/
│   ├── .npmrc                  # NPM configuration
│   └── global-packages.txt     # Essential global packages
├── bash/
│   ├── .bash_profile           # Bash login shell configuration
│   └── .bashrc.local           # Local bash customizations template
├── zsh/
│   ├── .zshrc                  # Zsh configuration (Starship-enabled)
│   ├── .zprofile               # Zsh login shell configuration
│   ├── .zshenv.local           # Local environment variables template
│   └── .zsh_cross_platform     # Cross-platform utilities
├── starship/
│   └── starship.toml           # Starship prompt configuration
├── tmux/
│   └── .tmux.conf              # Tmux configuration with Gruvbox theme
├── ghostty/
│   └── .config/ghostty/config  # Ghostty terminal configuration
└── docs/                       # Documentation
```

## Features

### Unified Gruvbox Theme

All components use the Gruvbox Dark color scheme for a consistent visual experience:
- Shell prompt (Zsh)
- Starship prompt
- Tmux status bar
- Terminal emulator
- Window manager

### Smart Configuration

- **🆕 Modular Installation** - Focused, maintainable installation scripts
- **🚀 Dynamic Path Resolution** - Cross-platform path handling with automatic adaptation
- **⚡ Optimized Performance** - Faster shell startup with Starship prompt
- **🔒 Enhanced Security** - Consolidated PATH exports, removed hardcoded credentials
- **Machine-specific overrides** - Use `*.local` files for machine-specific settings
- **Cross-platform clipboard** - Works with both X11 (xclip) and macOS (pbcopy)
- **Vi-mode keybindings** - Consistent navigation across tmux and shell
- **Error handling** - Comprehensive validation and backup system

### 🆕 Cross-Platform Path Resolution

The dotfiles now include a sophisticated path resolution system that automatically adapts to your platform:

```bash
# Example: Dynamic conda path resolution
if command -v resolve_platform_path >/dev/null 2>&1; then
    local conda_bin="$(resolve_platform_path "conda_bin")"
    # On macOS: /Users/username/miniforge3/bin
    # On Linux: /home/username/miniforge3/bin
else
    # Fallback to hardcoded paths
    local conda_bin="$HOME/miniforge3/bin"
fi
```

**Supported path types:**
- `ai_projects` - Your AI projects directory
- `conda_root` - Miniforge/Conda installation
- `starship_config` - Starship configuration directory
- `npm_global_bin` - NPM global packages bin directory
- And many more...

**All configurations automatically use the correct paths for your platform.**

### 🆕 New Development Configurations

#### Git Configuration
- **Template-based setup** - Secure `.gitconfig` with placeholder user information
- **Local overrides** - Use `~/.gitconfig.local` for personal data and credentials
- **Development aliases** - Common Git commands and shortcuts
- **Cross-platform support** - Works on macOS and Linux

#### VS Code Integration
- **Curated extensions** - Essential development extensions for web, Node.js, and Python
- **Optimized settings** - Auto-format on save, smart file nesting, theme consistency
- **Productivity keybindings** - Enhanced terminal management and navigation
- **Security focused** - Excludes workspace-specific settings and personal data

#### NPM Configuration
- **Global packages management** - Essential development tools with curated list
- **Security settings** - Audit enabled, secure registry configuration
- **Path management** - Global packages without sudo requirement
- **Local overrides** - Use `~/.npmrc.local` for sensitive configuration

#### Shell Enhancements
- **Bash support** - Complete Bash configuration alongside Zsh
- **Template paths** - Conda, pyenv, and tool paths as configurable templates
- **Local overrides** - `*.local` files for machine-specific customizations
- **SSH agent** - Automatic SSH key management for development

### Security

- Comprehensive `.gitignore` to prevent credential leakage
- No secrets committed to version control
- Local override files for sensitive configuration
- Template-based approach for personal data protection

#### 🔒 New Security Features

**Template-Based Configuration**
- Personal data (names, emails, paths) replaced with placeholders
- Setup instructions guide users to add their own information
- Templates prevent accidental commits of sensitive data

**Local Override System**
- `*.local` files for machine-specific settings (never tracked)
- Examples: `~/.gitconfig.local`, `~/.npmrc.local`, `~/.zshrc.local`
- Automatically created by installer for convenience

**Development Environment Safety**
- VS Code settings exclude workspace-specific configurations
- NPM configuration excludes authentication tokens
- Shell paths use configurable templates instead of hardcoded values

## Requirements

### Essential

- `git` - Version control
- `stow` - Symlink management
- `zsh` - Shell (optional, bash configs also included)
- `tmux` - Terminal multiplexer

### macOS Requirements

**macOS users must install these first:**

- **Xcode Command Line Tools** - Required for development tools
  ```bash
  xcode-select --install
  ```
- **Homebrew** - Package manager for macOS
  ```bash
  # Apple Silicon (M1/M2/M3/M4)
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Intel Macs
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ```

### Optional

- `sway` - Wayland compositor
- `foot` - Terminal emulator (Linux)
- `ghostty` - Terminal emulator (macOS)
- `nvm` - Node.js version manager
- `code` - VS Code editor (for extension installation)
- `npm` - Node Package Manager (for global packages)
- Oh My Zsh plugins (installed via setup script)
- `conda`/`miniforge` - Python environment management
- `pyenv` - Python version management

## Migration Guide

### 🔄 What Changed in Recent Cleanup

If you're upgrading from a previous version:

1. **Prompt System**: Now using Starship exclusively (removed custom prompt conflicts)
2. **Installation**: New modular installer (`install-new.sh`) recommended
3. **Performance**: Faster shell startup and better error handling
4. **Security**: Removed hardcoded IPs and consolidated PATH exports
5. **Code Quality**: Standardized formatting and removed dead code

### 📋 Migration Steps

```bash
# 1. Backup current configuration (automatic with new installer)
cd ~/.dotfiles

# 2. Pull latest changes
git pull

# 3. Use new modular installer
./install-new.sh --all

# 4. Restart your shell
exec zsh
```

Your existing configurations will be backed up automatically.

## Installation

### 🚀 New Modular Installation (Recommended)

```bash
cd ~/.dotfiles
./install-new.sh              # Interactive mode
./install-new.sh --all        # Install all components
```

### 📦 Legacy Full Installation

Install all configurations interactively:

```bash
cd ~/.dotfiles
./install.sh
```

### Platform-Specific Package Installation

Install system packages appropriate for your platform:

```bash
# Install platform-specific packages only
./install.sh --packages

# Full installation with packages
./install.sh --all --packages
```

### Selective Installation

Install specific components only:

```bash
./install.sh zsh tmux    # Install only zsh and tmux configs
./install.sh --all       # Install all non-interactively
```

### macOS (All Macs) Complete Setup

For Apple Silicon (M1/M2/M3/M4) and Intel Macs:

```bash
# 1. Install Xcode Command Line Tools (if not already installed)
xcode-select --install

# 2. Install Homebrew for your Mac architecture (if not already installed)
# Apple Silicon and Intel use same command - auto-detects architecture
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 3. Clone and install dotfiles
git clone git@github.com:BrennonTWilliams/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# 4. Install platform-specific packages and configurations
./install.sh --all --packages

# 5. Install macOS-specific services (optional)
./macos/install-uniclip-service.sh

# 6. Reload shell
exec zsh
```

**Total setup time: 15-25 minutes**

### Post-Installation

After running the install script, set up additional dependencies:

```bash
# Install Oh My Zsh and plugins
./scripts/setup-ohmyzsh.sh

# Install Node Version Manager
./scripts/setup-nvm.sh

# Install Nerd Fonts
./scripts/setup-fonts.sh

# Install Tmux Plugin Manager
./scripts/setup-tmux-plugins.sh
```

### Change Default Shell

```bash
chsh -s $(which zsh)
```

## Starship Prompt Configuration

Custom starship prompt with **Nerd Font icons** optimized for tmux and development workflows:

### Features

- **Compact Format**: Optimized for tmux panes with minimal width usage
- **Nerd Font Icons**: Professional Git status indicators with 3 switchable styles (Material Design, Font Awesome, Minimalist)
- **Smart Detection**: SSH/Tmux-aware username and hostname display
- **Git Integration**: Comprehensive branch, status, and commit hash indicators with visual icons
- **Language Support**: Python, Node.js, Rust, Go, Java version display
- **Performance**: Command execution time monitoring
- **Security**: Sudo privilege indicator with crown emoji
- **Context Awareness**: Shows Docker context when active

### Configuration Files

- **Main Config**: `starship/starship.toml` → `~/.config/starship.toml`
- **Local Overrides**: Create `~/.config/starship.toml.local` for machine-specific settings
- **Test Script**: `nerd-font-test.sh` for verifying Nerd Font icon rendering
- **Documentation**: `docs/STARSHIP_CONFIGURATION.md` for comprehensive configuration guide
- **Symlinked**: Automatically managed via GNU Stow during dotfile installation

### Key Modules

```toml
# Compact format optimized for tmux panes
format = "$sudo$username$hostname$directory$git_branch$git_status$python$nodejs$rust$golang$java$docker_context$character"

# Show sudo when enabled
[sudo]
disabled = false
symbol = "👑 "
style = "bold red"

# Git status with intuitive icons
[git_status]
stashed = "📦"
modified = "📝"
deleted = "🗑️"
ahead = "⇡$count"
behind = "⇣$count"

# Language versions (minimal display)
[python]
symbol = "🐍 "
[nodejs]
symbol = " "
[rust]
symbol = "🦀 "
[golang]
symbol = "🐹 "
[java]
symbol = "☕ "
```

### Customization Examples

Create `~/.config/starship.toml.local` for personalized settings:

```toml
# Custom time display
[time]
disabled = false
format = "[🕐 $time]($style) "

# Memory usage monitoring
[memory_usage]
disabled = false
threshold = 75
format = "[🧠 ${ram_pct}]($style) "

# Kubernetes context (if you use k8s)
[kubernetes]
symbol = "☸ "
disabled = false
```

### Verification

Test starship configuration after installation:

```bash
# Check starship version
starship --version

# Debug prompt rendering
starship explain

# Test configuration parsing
starship print-config
```

## Machine-Specific Configuration

The dotfiles support machine-specific overrides without modifying tracked files:

### Shell Configuration

Create `~/.zshrc.local` or `~/.bashrc.local`:

```bash
# Machine-specific aliases
alias vpn='connect-to-work-vpn'

# Machine-specific environment variables
export WORKSPACE="$HOME/projects"
```

### Sway Window Manager

Create `~/.config/sway/config.local`:

```bash
# Machine-specific display configuration
output HDMI-A-1 scale 2.0
output DP-1 resolution 1920x1080
```

These `*.local` files are automatically sourced but never tracked in git.

## 🔍 Health Check System

### Comprehensive Post-Installation Validation

The dotfiles include a comprehensive health check system that validates your installation and provides actionable recommendations:

```bash
# Run complete health check
health-check

# Alternative commands
dotfiles-check
system-health

# Direct script execution
./scripts/health-check.sh
```

### What Gets Checked

- **Shell Environment**: Zsh configuration and cross-platform utilities
- **Path Resolution**: Dynamic path resolution for all 21 path types
- **Core Tools**: Essential development tools (git, curl, tmux, starship)
- **Starship Configuration**: Prompt setup and mode switching
- **Platform-Specific**: macOS/Linux specific configurations
- **Symlink Structure**: Proper dotfiles symlink validation
- **Services**: Background services and system integration
- **Performance**: Shell startup time and system metrics

### Health Scoring

- **90-100%**: 🟢 EXCELLENT - Optimal configuration
- **75-89%**: 🟡 GOOD - Minor issues or optional components missing
- **50-74%**: 🟡 FAIR - Some issues that need attention
- **0-49%**: 🔴 NEEDS ATTENTION - Critical issues requiring immediate action

For detailed documentation, see [HEALTH_CHECK_SYSTEM.md](docs/HEALTH_CHECK_SYSTEM.md).

## Usage

### Shell Aliases

Common aliases configured in `.oh-my-zsh/custom/aliases.zsh`:

```bash
# Directory navigation
..          # cd ..
...         # cd ../..

# File operations
ll          # ls -alFh
la          # ls -A

# Git shortcuts
gs          # git status
ga          # git add
gc          # git commit
gp          # git push
gl          # git log --oneline --graph

# System management
update      # Update and upgrade packages
cleanup     # Remove unused packages

# Tmux shortcuts
tls         # List tmux sessions
ta <name>   # Attach to session
tn <name>   # New session
tk <name>   # Kill session
```

### macOS-Specific Aliases

When running on macOS, additional aliases are automatically available:

```bash
# File operations
show <file>          # Open file with default app
finder                # Open current directory in Finder
textedit <file>       # Open file in TextEdit

# Homebrew management
brew-upgrade          # Update and upgrade all Homebrew packages
brew-clean           # Clean up and check Homebrew health
brew-list            # List installed formulae
brew-cask-list       # List installed casks

# System information
system-info          # Display hardware information
battery              # Show battery status
cpu-temp             # Show CPU temperature (requires sudo)
wifi-scan            # Scan available WiFi networks
ip-info              # Show local IP addresses

# macOS app shortcuts
lock                 # Lock screen
sleep                # Put Mac to sleep
screensaver          # Start screensaver
ql <file>            # Quick Look file

# Clipboard management
clipboard            # Paste from clipboard to terminal
copy <command>       # Copy command output to clipboard (pipe)

# Development tools
xcode-info           # Show Xcode path
simulators           # List iOS simulators
```

### 🆕 Development Configuration Usage

#### Git Configuration Setup

```bash
# Update your personal information (required)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Add machine-specific settings to ~/.gitconfig.local
nano ~/.gitconfig.local

# Verify configuration
git config --global user.name
git config --global user.email
```

#### VS Code Configuration

```bash
# Install all essential extensions
xargs -a ~/.dotfiles/vscode/extensions.txt code --install-extension

# Install individual extensions
code --install-extension GitHub.copilot
code --install-extension ms-vscode.vscode-eslint

# View installed extensions
code --list-extensions

# Update settings (settings.json is symlinked from dotfiles)
code --settings
```

#### NPM Global Packages

```bash
# Install essential global packages
xargs -a ~/.dotfiles/npm/global-packages.txt npm install -g

# Install specific categories
npm install -g typescript nodemon eslint prettier

# Add npm global packages to PATH (add to ~/.zshrc.local)
export PATH="$HOME/.npm-global/bin:$PATH"

# Update all global packages
npm update -g

# Check for outdated packages
npm outdated -g
```

#### Local Configuration Files

```bash
# Edit local overrides (machine-specific settings)
~/.gitconfig.local      # Git personal data and credentials
~/.npmrc.local          # NPM tokens and registry settings
~/.zshrc.local          # Custom aliases and functions
~/.zshenv.local         # Environment variables
~/.bashrc.local         # Bash-specific customizations

# Reload shell after changes
exec zsh
```

### Tmux Key Bindings

Prefix key: `Ctrl-a` (instead of default `Ctrl-b`)

```
Prefix + |        # Split horizontally
Prefix + -        # Split vertically
Prefix + h/j/k/l  # Navigate panes (Vi-style)
Alt + Arrow Keys  # Navigate panes (no prefix)
Prefix + r        # Reload configuration
Prefix + S        # Synchronize panes
```

### Sway Window Manager

Mod key: `Super/Windows` key

```
Mod + Return       # Open terminal
Mod + d            # Application launcher
Mod + Shift + q    # Close window
Mod + 1-0          # Switch workspace
Mod + Shift + 1-0  # Move to workspace
Mod + f            # Fullscreen
Mod + r            # Resize mode
Print              # Screenshot
```

## Updating

### Pull Latest Changes

```bash
cd ~/.dotfiles
git pull
```

### Re-stow Updated Packages

```bash
cd ~/.dotfiles
stow -R zsh tmux    # Restow specific packages
```

### Update Oh My Zsh

```bash
omz update
```

### Update Tmux Plugins

In tmux, press: `Prefix + U`

## Uninstallation

### Remove Specific Package

```bash
cd ~/.dotfiles
stow -D zsh    # Remove zsh symlinks
```

### Remove All Dotfiles

```bash
cd ~/.dotfiles
for pkg in */; do
    stow -D "${pkg%/}"
done
```

Your original files will remain in the backup directory created during installation.

## Customization

### Adding New Configurations

1. Create a new package directory:
   ```bash
   mkdir -p ~/.dotfiles/vim
   ```

2. Add your config files:
   ```bash
   cp ~/.vimrc ~/.dotfiles/vim/
   ```

3. Stow the package:
   ```bash
   cd ~/.dotfiles
   stow vim
   ```

4. Commit to repository:
   ```bash
   git add vim/
   git commit -m "Add vim configuration"
   git push
   ```

### Modifying Existing Configs

Since files are symlinked, just edit them normally:

```bash
vim ~/.zshrc    # Edit the symlinked file
cd ~/.dotfiles
git add zsh/.zshrc
git commit -m "Update zsh config"
git push
```

## 🆘 Troubleshooting

For comprehensive troubleshooting information:

- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - General troubleshooting guides
- **[macos-setup.md](macos-setup.md)** - Complete macOS setup and configuration
- **macOS-specific issues**: Apple Silicon, Homebrew paths, Rosetta 2, permissions

### Common Issues

#### Claude Command Not Found After Restart

If the `claude` command works but stops working after restarting your system:

```bash
# Pull latest changes
cd ~/.dotfiles
git pull

# Reinstall dotfiles
./install.sh --all

# Restart shell
exec zsh
```

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md#claude-command-not-found-after-restart) for detailed explanation.

#### Starship Not Loading

If starship prompt doesn't appear after installation:

```bash
# Verify starship is installed
starship --version

# Check if starship is initialized in shell
echo $STARSHIP_SHELL

# Test starship configuration
starship explain

# Re-stow starship configuration
cd ~/.dotfiles
stow -R starship

# Restart shell
exec zsh
```

**Common issues:**
- Starship not installed: Install via package manager (`brew install starship` or `sudo apt install starship`)
- Shell not initialized: Starship needs to be initialized in `~/.zshrc` or `~/.bashrc`
- Configuration error: Run `starship print-config` to validate configuration
- Symlink broken: Re-stow the starship package from dotfiles directory

#### Stow Conflicts

If stow reports conflicts with existing files:

```bash
# Backup the conflicting file
mv ~/.zshrc ~/.zshrc.backup

# Try stowing again
stow -R zsh
```

#### Symlinks Not Working

Verify symlinks are created correctly:

```bash
ls -la ~/  | grep '\->'
```

You should see symlinks pointing to `~/.dotfiles/`.

#### Shell Not Loading Config

Ensure your shell sources the configuration:

```bash
# For zsh
exec zsh

# For bash
exec bash
```

#### New Configuration Issues

**Git user information not set:**
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

**NPM global packages not found:**
```bash
# Add to PATH in ~/.zshrc.local
export PATH="$HOME/.npm-global/bin:$PATH"
exec zsh
```

**VS Code settings not applying:**
```bash
# Check if symlinks exist
ls -la ~/.config/Code/User/settings.json
# Reinstall with setup script
./scripts/setup-new-configs.sh
```

## Documentation

For detailed system setup documentation, see [SYSTEM_SETUP.md](SYSTEM_SETUP.md).

## Backup

Important: Your original dotfiles are automatically backed up during installation to:

```
~/.dotfiles_backup_YYYYMMDD_HHMMSS/
```

## Package List

Platform-specific package manifests are provided for optimal compatibility:

### Package Files

- `packages.txt` - Linux packages (Debian/Ubuntu/Fedora/Arch)
- `packages-macos.txt` - macOS packages (Apple Silicon and Intel)

### Installation

```bash
# Platform-specific installation (recommended)
./install.sh --packages

# Manual installation
# Linux (Debian/Ubuntu)
xargs -a packages.txt sudo apt install -y

# Linux (Fedora/RHEL)
xargs -a packages.txt sudo dnf install -y

# macOS (Apple Silicon and Intel - both use same packages)
xargs -a packages-macos.txt brew install

# Alternative: Install macOS packages manually (filtered)
brew install $(cat packages-macos.txt | grep -v '^#' | grep -v 'sketchybar')
```

**Note:** The macOS package list includes macOS-specific alternatives:
- Rectangle (window management) instead of Sway
- Ghostty (terminal) instead of Foot
- Sketchybar (status bar) instead of Waybar
- Built-in macOS tools for screenshots and notifications
- Works on both Apple Silicon and Intel Macs automatically

## Credits

Inspired by:
- [GNU Stow documentation](https://www.gnu.org/software/stow/)
- [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles)
- [thoughtbot/dotfiles](https://github.com/thoughtbot/dotfiles)
- [Gruvbox color scheme](https://github.com/morhetz/gruvbox)

## License

These are personal configuration files. Feel free to use and modify as needed.

---

**Note:** Remember to update machine-specific settings in `*.local` files after installation on new systems.
