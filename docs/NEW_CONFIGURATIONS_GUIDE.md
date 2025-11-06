# New Configurations Guide

This guide provides comprehensive documentation for the newly added dotfiles configurations.

## 📋 Table of Contents

- [Git Configuration](#git-configuration)
- [VS Code Integration](#vs-code-integration)
- [NPM Configuration](#npm-configuration)
- [Shell Enhancements](#shell-enhancements)
- [Security Features](#security-features)
- [Installation Guide](#installation-guide)
- [Troubleshooting](#troubleshooting)

## Git Configuration

### Files Overview
- **`git/.gitconfig`** - Main Git configuration with template placeholders
- **`git/.gitignore`** - Security-focused ignore patterns
- **`git/README.md`** - Detailed setup instructions

### Initial Setup
```bash
# Stow the Git configuration
cd ~/.dotfiles
stow git

# Update your personal information (REQUIRED)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Verify configuration
git config --global user.name
git config --global user.email
```

### Local Configuration
Create `~/.gitconfig.local` for machine-specific settings:

```ini
[user]
    # Override personal information if needed
    name = Your Actual Name
    email = your.actual.email@example.com

[credential]
    # macOS keychain
    helper = osxkeypair

    # Linux (uncomment if needed)
    # helper = manager

# Company-specific settings
[github]
    user = your-work-username
```

### Features
- Development aliases for common Git commands
- Cross-platform credential helper support
- Git LFS configuration
- Safe defaults for new repositories

## VS Code Integration

### Files Overview
- **`vscode/settings.json`** - Development-optimized editor settings
- **`vscode/extensions.txt`** - Curated list of 50+ essential extensions
- **`vscode/keybindings.json`** - Productivity-enhancing shortcuts
- **`vscode/README.md`** - Installation and customization guide

### Installation
```bash
# Install all essential extensions
xargs -a ~/.dotfiles/vscode/extensions.txt code --install-extension

# Or run the automated setup
./scripts/setup-new-configs.sh
```

### Extension Categories
1. **Development Tools** - TypeScript, Python, JSON support
2. **Git & Version Control** - GitLens, GitHub integration
3. **Language Support** - ESLint, Prettier, Tailwind CSS
4. **AI & Code Assistance** - GitHub Copilot, Continue
5. **Productivity Tools** - Todo Tree, Spell Checker, Bookmarks

### Settings Highlights
- Auto-format on save with ESLint and Prettier
- Smart file nesting for related files
- Gruvbox Dark theme consistency
- Security settings with workspace trust
- Optimized search patterns excluding build artifacts

## NPM Configuration

### Files Overview
- **`npm/.npmrc`** - Development-focused NPM configuration
- **`npm/global-packages.txt`** - Essential global packages by category
- **`npm/README.md`** - Setup and maintenance instructions

### Initial Setup
```bash
# Stow the NPM configuration
cd ~/.dotfiles
stow npm

# Create global packages directory
mkdir -p ~/.npm-global

# Add to PATH (add to ~/.zshrc.local)
export PATH="$HOME/.npm-global/bin:$PATH"

# Install essential packages
xargs -a ~/.dotfiles/npm/global-packages.txt npm install -g
```

### Global Package Categories
1. **Core Development** - TypeScript, Nodemon, ESLint, Prettier
2. **Build Tools** - Webpack, Rollup, Vite, Parcel
3. **Testing** - Jest, Cypress, Playwright
4. **Documentation** - JSDoc, Mermaid CLI
5. **Deployment** - Vercel, Netlify, Surge

### Security Features
- Audit enabled by default
- No credentials in configuration
- Local override support for tokens
- Secure registry configuration

## Shell Enhancements

### Enhanced Files
- **`bash/.bash_profile`** - Login shell configuration with conda/miniforge support
- **`bash/.bashrc.local`** - Local bash customizations template
- **`zsh/.zprofile`** - Updated login configuration with pyenv and SSH agent
- **`zsh/.zshenv.local`** - Environment variables template
- **`zsh/.zshrc.local`** - Custom aliases and functions template

### Template Paths
All personal paths have been templatized for security:

```bash
# Conda/Miniforge paths (update in .bash_profile)
if [ -f "$HOME/miniforge3/bin/conda" ]; then
    # Update path to match your installation
elif [ -f "/opt/homebrew/Caskroom/miniforge/base/bin/conda" ]; then
    # macOS Homebrew path
```

### SSH Agent Management
Automatic SSH agent setup for development:

```bash
# Automatically manages SSH keys
# Creates agent if not running
# Adds keys automatically
# Works across restarts
```

### Local Override System
Each shell has corresponding `*.local` files for personal customizations:

```bash
# Example ~/.zshrc.local
# Custom aliases
alias ll='ls -alFh'
alias myproject='cd ~/projects/myproject'

# Environment variables
export WORKSPACE="$HOME/projects"
export EDITOR='code --wait'

# Custom functions
mkcd() { mkdir -p "$1" && cd "$1"; }
```

## Security Features

### Template-Based Configuration
- Personal data replaced with placeholders
- Setup instructions guide users through customization
- Prevents accidental commits of sensitive information

### Local Override Files
- `*.local` files are never tracked in git
- Automatically created by installer
- Used for machine-specific settings and credentials

### Development Environment Safety
- VS Code excludes workspace-specific settings
- NPM configuration excludes authentication tokens
- Shell paths use configurable templates
- Comprehensive `.gitignore` patterns

## Installation Guide

### Complete Installation
```bash
# Clone and install everything
git clone git@github.com:BrennonTWilliams/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install-new.sh --all
```

### New Configuration Setup
```bash
# Run the dedicated setup script
./scripts/setup-new-configs.sh

# Manual Git configuration
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Install VS Code extensions
xargs -a vscode/extensions.txt code --install-extension

# Install NPM packages
xargs -a npm/global-packages.txt npm install -g

# Add NPM to PATH
export PATH="$HOME/.npm-global/bin:$PATH"
```

### Selective Installation
```bash
# Install only Git configuration
stow git

# Install only VS Code settings
./scripts/setup-new-configs.sh  # Partial setup

# Install only NPM configuration
stow npm
```

## Troubleshooting

### Common Issues

#### Git Configuration Not Applied
```bash
# Check if configuration exists
git config --global user.name

# If not set, update manually
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

#### VS Code Extensions Not Installing
```bash
# Check VS Code is in PATH
which code

# Install manually
code --install-extension ms-vscode.vscode-typescript-next

# Check extension list
code --list-extensions
```

#### NPM Global Packages Not Found
```bash
# Check if directory exists
ls -la ~/.npm-global/bin

# Add to PATH in ~/.zshrc.local
export PATH="$HOME/.npm-global/bin:$PATH"

# Reload shell
exec zsh
```

#### Shell Configuration Not Loading
```bash
# Check if symlinks exist
ls -la ~/.bash_profile ~/.zprofile

# Restow configurations
cd ~/.dotfiles
stow -R bash zsh

# Reload shell
exec zsh
```

### Verification Commands
```bash
# Git configuration
git config --list --global

# VS Code extensions
code --list-extensions

# NPM global packages
npm list -g --depth=0

# Shell aliases
alias
```

### Getting Help
1. Check individual README files in each configuration directory
2. Review the main README.md for general instructions
3. Use verification commands to diagnose issues
4. Check local override files for custom settings

---

**Remember**: Always reload your shell after making configuration changes with `exec zsh` or `exec bash`.