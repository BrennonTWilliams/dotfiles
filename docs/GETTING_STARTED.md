# Getting Started

Comprehensive guide to getting your dotfiles environment set up on macOS or Linux.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Platform-Specific Setup](#platform-specific-setup)
- [Installation Methods](#installation-methods)
- [Post-Installation Steps](#post-installation-steps)
- [Verification](#verification)
- [Next Steps](#next-steps)

---

## Prerequisites

### All Platforms

- **Git** - For cloning the repository
- **Internet connection** - For downloading packages
- **Administrator access** - For installing packages and changing shell

### macOS

```bash
# Install Xcode Command Line Tools (required)
xcode-select --install

# Install Homebrew (required)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to PATH (Apple Silicon)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### Linux (Ubuntu/Debian)

```bash
sudo apt update && sudo apt install -y git curl stow zsh
```

### Linux (Fedora)

```bash
sudo dnf install -y git curl stow zsh
```

### Linux (Arch)

```bash
sudo pacman -S git curl stow zsh
```

---

## Quick Start

**Get started in 60 seconds:**

```bash
# 1. Clone the repository
git clone git@github.com:BrennonTWilliams/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# 2. Run the installer
./install.sh --all

# 3. Reload your shell
exec zsh
```

That's it! Your environment is now configured with:
- Modern terminal (Ghostty on macOS, Foot on Linux)
- Starship prompt with Gruvbox theme
- Cross-platform shell utilities
- Development tools and configurations

---

## Platform-Specific Setup

### macOS Setup

For detailed macOS-specific instructions including Apple Silicon optimizations:

```bash
# Full macOS setup
./install.sh --all

# Or step by step:
./install.sh --packages    # Install Homebrew packages
./install.sh --dotfiles    # Create symlinks
./install.sh --terminal    # Configure shell and terminal
```

**macOS-specific features:**
- Ghostty terminal with Gruvbox theme
- Rectangle for window management
- Uniclip clipboard sync service
- Apple Silicon optimized packages

See [MACOS_SETUP.md](MACOS_SETUP.md) for comprehensive macOS guide.

### Linux Setup

```bash
# Full Linux setup
./install.sh --all

# Or step by step:
./install.sh --packages    # Install system packages
./install.sh --dotfiles    # Create symlinks
./install.sh --terminal    # Configure shell and terminal
```

**Linux-specific features:**
- Foot terminal (Wayland-native)
- Sway window manager configuration
- wl-copy/xclip clipboard integration
- Distro-specific package detection

See [SYSTEM_SETUP.md](SYSTEM_SETUP.md) for Linux environment setup.

---

## Installation Methods

### Full Installation (Recommended)

```bash
./install.sh --all
```

Installs everything: packages, dotfiles, and terminal configuration.

### Interactive Installation

```bash
./install.sh
```

Prompts you to select which components to install.

### Modular Installation

```bash
./install.sh --packages     # System packages only
./install.sh --dotfiles     # Dotfile symlinks only
./install.sh --terminal     # Terminal and shell setup only
```

### Preview Mode (Dry-Run)

See what would happen without making changes:

```bash
./install.sh --preview --all
./install.sh --preview --dotfiles
```

### Dependency Check

Verify prerequisites before installing:

```bash
./install.sh --check-deps
```

See [INSTALLATION_OPTIONS.md](INSTALLATION_OPTIONS.md) for complete installation reference.

---

## Post-Installation Steps

### 1. Configure Git Identity

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### 2. Create Machine-Specific Settings

Create `~/.zshrc.local` for machine-specific configurations:

```bash
# Custom paths
export PATH="$HOME/bin:$PATH"

# API keys (never commit these!)
export OPENAI_API_KEY="your-key-here"

# Custom aliases
alias work='cd ~/Projects/work'
```

### 3. Install Optional Tools

**VS Code extensions:**
```bash
xargs -a vscode/extensions.txt code --install-extension
```

**NPM global packages:**
```bash
xargs -a npm/global-packages.txt npm install -g
```

### 4. Configure Starship Mode

Choose your preferred prompt mode:

```bash
starship-compact    # Minimal (sc)
starship-standard   # Balanced (ss)
starship-verbose    # Full context (sv)
```

---

## Verification

### Run Health Check

```bash
./scripts/health-check.sh
```

Or use the alias:

```bash
health-check
```

### Verify Installations

```bash
# Check shell
echo $SHELL              # Should show zsh

# Check Starship
starship --version

# Check symlinks
ls -la ~/.zshrc          # Should be symlink to ~/.dotfiles/zsh/.zshrc

# Check platform detection
dev-status               # Shows development environment status
system-status            # Shows system information
```

### Test Key Features

```bash
# Test aliases
ll                       # Enhanced ls
gs                       # Git status (if using abbreviations)

# Test clipboard (macOS)
echo "test" | pbcopy
pbpaste

# Test clipboard (Linux)
echo "test" | wl-copy    # Wayland
wl-paste
```

---

## Next Steps

1. **Customize your environment** - Edit `~/.zshrc.local` for personal settings
2. **Learn the commands** - See [USAGE_GUIDE.md](USAGE_GUIDE.md) for all available commands
3. **Explore features** - See [FEATURES.md](FEATURES.md) for feature descriptions
4. **Troubleshoot issues** - See [../TROUBLESHOOTING.md](../TROUBLESHOOTING.md) for common problems

---

## Getting Help

- **Health check:** `health-check` or `./scripts/health-check.sh`
- **Development status:** `dev-status`
- **System info:** `system-status`
- **Documentation:** [USAGE_GUIDE.md](USAGE_GUIDE.md)
- **Issues:** [GitHub Issues](https://github.com/BrennonTWilliams/dotfiles/issues)
