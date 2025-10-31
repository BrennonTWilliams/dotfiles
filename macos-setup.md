# macOS Development Environment Setup Guide

**Comprehensive setup guide for macOS development with Apple Silicon optimizations and dotfiles integration.**

## 📋 Table of Contents

- [🍎 macOS Quick Start](#-macos-quick-start)
- [📋 System Requirements](#-system-requirements)
- [🔧 Step 1: System Preparation](#-step-1-system-preparation)
- [📦 Step 2: Install Homebrew](#-step-2-install-homebrew)
- [🎯 Step 3: Install Dotfiles](#-step-3-install-dotfiles)
- [🔧 Step 4: Development Tools Setup](#-step-4-development-tools-setup)
- [🖥️ Step 5: Terminal & Shell Setup](#️-step-5-terminal--shell-setup)
- [🎨 Step 6: macOS Application Setup](#-step-6-macos-application-setup)
- [🚀 Step 7: macOS Services Integration](#-step-7-macos-services-integration)
- [⚡ Step 8: Performance Optimization](#-step-8-performance-optimization)
- [🔒 Step 9: Security & Privacy Configuration](#-step-9-security--privacy-configuration)
- [🧪 Step 10: Verification & Testing](#-step-10-verification--testing)
- [🔄 Maintenance & Updates](#-maintenance--updates)
- [🆘 Troubleshooting](#-troubleshooting)
- [📚 Additional Resources](#-additional-resources)

**Quick navigation for specific needs:**
- **Apple Silicon setup**: [Step 1](#-step-1-system-preparation) → [Step 8](#-step-8-performance-optimization)
- **Development tools**: [Step 4](#-step-4-development-tools-setup) → [Step 5](#️-step-5-terminal--shell-setup)
- **Security configuration**: [Step 9](#-step-9-security--privacy-configuration)
- **Problem solving**: [Troubleshooting](#-troubleshooting) → [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

## 🍎 macOS Quick Start

**⏱️ Total setup time: 15-25 minutes**

```bash
# Clone and setup (requires SSH key access to GitHub)
git clone git@github.com:BrennonTWilliams/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh --all --packages
exec zsh
```

---

## 📋 System Requirements

### Supported macOS Versions
- **macOS 12.0+ (Monterey)** - Recommended
- **macOS 11.0+ (Big Sur)** - Supported
- **macOS 10.15+ (Catalina)** - Limited support

### Supported Hardware
| Architecture | Models | Status |
|-------------|--------|---------|
| **Apple Silicon** | M1, M2, M3, M4 Macs | ✅ Optimized |
| **Intel** | All Intel Macs (2015+) | ✅ Supported |

### Prerequisites
- **Internet connection** for downloads
- **Administrator access** for installations
- **50GB+ free disk space** for development tools
- **GitHub SSH key configured** for repository access (this is a private repository)

---

## 🔧 Step 1: System Preparation

### 1.1 Update macOS

```bash
# Check for system updates
sudo softwareupdate -l

# Install all available updates
sudo softwareupdate -i -a

# Check macOS version
sw_vers
```

### 1.2 Install Xcode Command Line Tools

**Required for all development work on macOS.**

```bash
# Install Xcode Command Line Tools
xcode-select --install

# Verify installation
xcode-select -p
# Should output: /Library/Developer/CommandLineTools

# Check installed tools
clang --version
git --version
```

**Troubleshooting:**
- If installation fails, download from: [Apple Developer Downloads](https://developer.apple.com/download/all/)
  - **Note:** Requires Apple Developer account login to access downloads
- Alternative: Install using Xcode from App Store (includes Command Line Tools)
- Search for "Command Line Tools for Xcode"

### 1.3 Configure System Preferences

#### Security & Privacy
```bash
# Allow apps from anywhere (for development)
sudo spctl --master-disable

# Enable Gatekeeper (recommended after setup)
# sudo spctl --master-enable
```

#### Developer Tools
```bash
# Accept Xcode license (automatically done by xcode-select)
sudo xcodebuild -license accept
```

---

## 📦 Step 2: Install Homebrew

### 2.1 Install Homebrew

**Apple Silicon (M1/M2/M3/M4) and Intel Macs use the same installer.**

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Follow the post-installation instructions shown
# The installer will tell you to add commands to your .zshrc
```

### 2.2 Verify Homebrew Installation

```bash
# Check Homebrew installation
which brew
brew --version
brew --prefix

# Apple Silicon should show: /opt/homebrew
# Intel Macs should show: /usr/local
```

### 2.3 Configure Homebrew

```bash
# Update Homebrew and upgrade existing packages
brew update
brew upgrade

# Install essential Homebrew packages
brew install git curl wget

# Check for issues
brew doctor
```

---

## 🎯 Step 3: Install Dotfiles

### 3.1 Clone and Install

```bash
# Clone the dotfiles repository
git clone git@github.com:BrennonTWilliams/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Install with platform-specific packages and setup
./install.sh --all --packages

# This will:
# - Install macOS-specific packages from packages-macos.txt
# - Set up shell configuration (zsh, aliases, functions)
# - Configure tmux, git, and development tools
# - Create symlinks using GNU Stow
```

### 3.2 Platform-Specific Package Installation

**The dotfiles automatically detect your Mac architecture and install appropriate packages.**

```bash
# Install macOS-specific packages manually (optional)
brew install $(cat packages-macos.txt | grep -v '^#' | grep -v 'sketchybar')

# Special handling for sketchybar (requires tap)
brew tap FelixKratz/formulae
brew install sketchybar
```

### 3.3 Shell Configuration

```bash
# Set Zsh as default shell (if not already)
chsh -s $(which zsh)

# Reload shell configuration
source ~/.zshenv
exec zsh

# Verify PATH and environment
echo $PATH | tr ':' '\n' | grep brew
which git
which node  # Should show NVM-managed version after setup
```

---

## 🔧 Step 4: Development Tools Setup

### 4.1 Node.js Development (NVM)

```bash
# Install Node Version Manager
./scripts/setup-nvm.sh

# Install latest LTS Node.js
nvm install --lts
nvm use --lts

# Set as default
nvm alias default node

# Install global packages
npm install -g @anthropic-ai/claude-code
npm install -g yarn typescript ts-node
```

### 4.2 Python Development

```bash
# Python 3 is pre-installed on macOS
python3 --version

# Install pip (if not present)
python3 -m ensurepip --upgrade

# Install development tools
pip3 install virtualenv pipenv black flake8

# Alternative: Use Homebrew Python for isolation
brew install python
```

### 4.3 Git Configuration

```bash
# Configure Git (replace with your info)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Set default branch name
git config --global init.defaultBranch main

# Configure credential helper
git config --global credential.helper osxkeychain

# Configure signing (optional but recommended)
git config --global commit.gpgsign true
```

---

## 🖥️ Step 5: Terminal & Shell Setup

### 5.1 Install iTerm2 (Recommended)

```bash
# Install iTerm2
brew install --cask iterm2

# Set iTerm2 as default terminal
# In iTerm2: iTerm2 > Make iTerm2 Default Term
```

### 5.2 Configure Terminal Theme

**Gruvbox Dark theme is included with the dotfiles.**

```bash
# iTerm2 color scheme installation
# 1. Open iTerm2 > Preferences > Profiles > Colors
# 2. Click Color Presets > Import
# 3. Import: ~/.dotfiles/iterm2/GruvboxDark.itermcolors

# Alternative: Install via command line
open ~/.dotfiles/iterm2/GruvboxDark.itermcolors
```

### 5.3 Install Terminal Fonts

```bash
# Install Nerd Fonts for terminal icons and glyphs
./scripts/setup-fonts.sh

# Or manually install:
brew install --cask font-meslo-lg-nerd-font
brew install --cask font-fira-code-nerd-font
```

### 5.4 Configure Shell Integration

```bash
# Verify shell integration is working
echo $SHELL
# Should output: /opt/homebrew/bin/zsh (ARM64) or /usr/local/bin/zsh (Intel)

# Test aliases
ll
which brew-upgrade
```

---

## 🎨 Step 6: macOS Application Setup

### 6.1 Development Applications

```bash
# Code editors
brew install --cask visual-studio-code
brew install --cask sublime-text

# Development tools
brew install --cask docker
brew install --cask postman
brew install --cask tableplus

# Communication
brew install --cask slack
brew install --cask discord
```

### 6.2 Productivity Applications

```bash
# Window management (alternative to Sway on Linux)
brew install --cask rectangle

# Note-taking
brew install --cask notion
brew install --cask obsidian

# Browser
brew install --cask google-chrome
brew install --cask firefox

# Password management
brew install --cask 1password
```

### 6.3 System Utilities

```bash
# System monitoring
brew install --cask stats
brew install --cask appcleaner

# File management
brew install --cask alfred  # Spotlight replacement
brew install --cask the-unarchiver

# Screenshot and recording (built-in alternatives)
# Cmd+Shift+3: Full screenshot
# Cmd+Shift+4: Selection screenshot
# Cmd+Shift+5: Screenshot and recording options
```

---

## 🚀 Step 7: macOS Services Integration

### 7.1 Install Uniclip Clipboard Service

**Cross-device clipboard sharing between Mac and Linux.**

```bash
# Install Uniclip service for macOS
./macos/install-uniclip-service.sh

# This will:
# - Install uniclip via Homebrew
# - Configure launchd service for auto-start
# - Set up socket paths for cross-device communication
```

### 7.2 Verify Service Integration

```bash
# Check if Uniclip service is running
launchctl list | grep uniclip

# Test clipboard sharing
echo "Test from Mac" | pbcopy
# This should be available on connected Linux devices
```

### 7.3 Configure Development Services

```bash
# Install and configure Git credential helper
git config --global credential.helper osxkeychain

# Configure SSH keys for GitHub/GitLab
ssh-keygen -t ed25519 -C "your.email@example.com"
# Add key to GitHub/GitLab settings

# Test SSH connection
ssh -T git@github.com
```

---

## ⚡ Step 8: Performance Optimization

### 8.1 Apple Silicon Optimizations

```bash
# Verify you're running native ARM64 versions
uname -m  # Should show: arm64
arch      # Should show: arm64

# Check which applications are running under Rosetta 2
ps aux | grep "arch -"

# Prefer ARM64 versions when available
brew install --cask --adopt-any app-name
```

### 8.2 System Performance Tweaks

```bash
# Increase file descriptor limits
echo 'ulimit -n 65536' >> ~/.zshrc

# Disable Dashboard (if not used)
defaults write com.apple.dashboard mcx-disabled -boolean YES

# Show hidden files in Finder
defaults write com.apple.finder AppleShowAllFiles -boolean true
killall Finder

# Speed up Mission Control animations
defaults write com.apple.dock expose-animation-duration -float 0.1
killall Dock
```

### 8.3 Memory Management

```bash
# Configure swap settings (advanced)
sudo sysctl vm.swappiness=10

# Clear inactive memory (when needed)
sudo purge
```

---

## 🔒 Step 9: Security & Privacy Configuration

### 9.1 Firewall Configuration

```bash
# Enable firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on

# Add terminal applications to firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /usr/bin/ruby
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblock /usr/bin/ruby
```

### 9.2 Application Permissions

```bash
# Grant Full Disk Access to terminal applications
# System Settings > Privacy & Security > Full Disk Access
# Add: /Applications/Utilities/Terminal.app
# Add: /Applications/iTerm.app

# Grant automation permissions for scripts
# System Settings > Privacy & Security > Accessibility
# Add your terminal application
```

### 9.3 Secure SSH Configuration

```bash
# Configure SSH client security
echo 'Host *
    StrictHostKeyChecking ask
    VerifyHostKeyDNS yes
    ForwardAgent no
    PermitLocalCommand no' >> ~/.ssh/config

# Set proper permissions
chmod 600 ~/.ssh/config
chmod 700 ~/.ssh
```

---

## 🧪 Step 10: Verification & Testing

### 10.1 Shell Environment Test

```bash
# Test basic shell functionality
echo "Shell test successful"
pwd
ls -la

# Test aliases
ll
brew-list
system-info

# Test PATH
which brew
which git
which python3
```

### 10.2 Development Tools Test

```bash
# Test Git
git --version
git status

# Test Node.js (if installed)
node --version
npm --version

# Test Python
python3 --version
pip3 --version
```

### 10.3 macOS Integration Test

```bash
# Test Homebrew
brew doctor

# Test macOS-specific commands
pbcopy <<< "Test clipboard"
pbpaste

# Test system info
system_profiler SPHardwareDataType
pmset -g batt
```

### 10.4 Dotfiles Integration Test

```bash
# Test tmux configuration
tmux new-session -d -s test
tmux send-keys -t test "ls -la" Enter
tmux kill-session -t test

# Test dotfile symlinks
ls -la ~/.zshrc ~/.tmux.conf
```

---

## 🔄 Maintenance & Updates

### Regular Maintenance

```bash
# Update Homebrew packages
brew update && brew upgrade && brew cleanup

# Update Oh My Zsh
omz update

# Update dotfiles
cd ~/.dotfiles && git pull && stow -R zsh tmux

# Update Node.js and global packages
nvm install --lts
npm update -g
```

### Health Checks

```bash
# Check system health
brew doctor
system_profiler SPHardwareDataType
diskutil list

# Monitor performance
top -o mem
htop  # if installed
```

---

## 🆘 Troubleshooting

### Common Issues

#### PATH Problems
```bash
# Reset shell environment
exec zsh

# Check dotfile symlinks
ls -la ~/.zshenv ~/.zshrc

# Verify Homebrew in PATH
echo $PATH | tr ':' '\n' | grep brew
```

#### Application Installation Issues
```bash
# Clear Homebrew cache
brew cleanup --prune=30

# Reset package installation
brew uninstall --cask app-name
brew install --cask app-name

# Remove quarantine attribute
xattr -dr com.apple.quarantine /Applications/App.app
```

#### Permission Issues
```bash
# Repair disk permissions
sudo diskutil repairPermissions /

# Reset Homebrew permissions
sudo chown -R $(whoami) /opt/homebrew  # ARM64
# sudo chown -R $(whoami) /usr/local  # Intel
```

### Getting Help

- **Main documentation**: [README.md](README.md)
- **Troubleshooting**: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **System setup**: [SYSTEM_SETUP.md](SYSTEM_SETUP.md)
- **Usage guide**: [USAGE_GUIDE.md](USAGE_GUIDE.md)

---

## 📚 Additional Resources

### Development Documentation
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [Homebrew Documentation](https://docs.brew.sh/)
- [Oh My Zsh Documentation](https://ohmyz.sh/)

### Community
- [macDev Subreddit](https://reddit.com/r/macdev)
- [Homebrew Discussions](https://github.com/Homebrew/discussions/discussions)
- [Stack Overflow macOS Tag](https://stackoverflow.com/questions/tagged/macos)

### Security Best Practices
- [macOS Security Guide](https://support.apple.com/guide/security/)
- [Apple Platform Security](https://www.apple.com/business/site/docs/Apple_Platform_Security_Guide.pdf)

---

**🎉 Your macOS development environment is now optimized and ready!**

For ongoing maintenance and updates, run the maintenance commands monthly. Enjoy your enhanced macOS development experience!