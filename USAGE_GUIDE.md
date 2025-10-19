# Dotfiles Usage Guide

This guide provides detailed instructions for managing your dotfiles across multiple machines.

## Table of Contents

1. [First-Time Setup on New Machine](#first-time-setup-on-new-machine)
2. [Daily Workflow](#daily-workflow)
3. [Updating Configurations](#updating-configurations)
4. [Syncing Across Machines](#syncing-across-machines)
5. [Security Best Practices](#security-best-practices)
6. [Troubleshooting](#troubleshooting)

---

## First-Time Setup on New Machine

### 1. Install Prerequisites

**Debian/Ubuntu:**
```bash
sudo apt update
sudo apt install git stow zsh tmux curl
```

**macOS:**
```bash
brew install git stow zsh tmux
```

### 2. Clone the Repository

```bash
git clone https://github.com/BrennonTWilliams/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

### 3. Run Installation Script

**Interactive (recommended for first time):**
```bash
./install.sh
```

The script will:
- Detect your operating system
- Check for required dependencies
- Backup existing configuration files
- Let you choose which packages to install
- Create machine-specific local config files

**Non-interactive (install everything):**
```bash
./install.sh --all
```

### 4. Install Additional Dependencies

After the main installation, run these helper scripts:

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

### 5. Install System Packages

```bash
# Debian/Ubuntu
xargs -a packages.txt sudo apt install -y

# macOS
xargs -a packages.txt brew install
```

### 6. Set Zsh as Default Shell

```bash
chsh -s $(which zsh)
```

Log out and log back in for the change to take effect.

### 7. Configure Machine-Specific Settings

Edit the local configuration files created during installation:

**~/.zshrc.local** - Machine-specific shell settings:
```bash
# Example: Set a custom workspace directory
export WORKSPACE="$HOME/Development"

# Example: Machine-specific aliases
alias vpn='sudo openconnect vpn.company.com'
```

**~/.config/sway/config.local** - Display configuration:
```bash
# Example: Configure your specific monitor
output HDMI-A-1 scale 2.0
output DP-1 resolution 1920x1080 position 1920,0
```

---

## Daily Workflow

### Making Configuration Changes

Since your dotfiles are symlinked, you can edit them normally:

```bash
# Edit any config file
vim ~/.zshrc
vim ~/.tmux.conf
vim ~/.config/sway/config

# The changes are automatically reflected in the repo
cd ~/.dotfiles
git status    # See what changed
```

### Committing Changes

```bash
cd ~/.dotfiles

# Check what you've changed
git status
git diff

# Add and commit
git add zsh/.zshrc
git commit -m "Add new shell alias for docker"

# Push to GitHub
git push
```

### Quick Add Everything

```bash
cd ~/.dotfiles
git add -A
git commit -m "Update shell and tmux configs"
git push
```

---

## Updating Configurations

### Pull Latest Changes from GitHub

On any machine with your dotfiles:

```bash
cd ~/.dotfiles
git pull
```

Changes are automatically reflected since files are symlinked!

### Re-stow After Updates

If you pulled changes to a new package or removed files:

```bash
cd ~/.dotfiles
stow -R zsh tmux    # Restow specific packages
```

### Update Oh My Zsh

```bash
omz update
```

### Update Tmux Plugins

In tmux:
1. Press: `Ctrl-a` (prefix) + `U`
2. Select plugins to update

Or manually:
```bash
cd ~/.tmux/plugins/tpm
git pull
~/.tmux/plugins/tpm/bin/update_plugins all
```

---

## Syncing Across Machines

### Scenario: You Updated Config on Machine A

**On Machine A (where you made changes):**
```bash
cd ~/.dotfiles
git add -A
git commit -m "Update tmux keybindings"
git push
```

**On Machine B (pull the updates):**
```bash
cd ~/.dotfiles
git pull
# Changes automatically reflected via symlinks!
```

### Scenario: Different Machines Need Different Settings

Use the `*.local` files that are **NOT** tracked in git:

**On Laptop (~/.zshrc.local):**
```bash
# Laptop-specific settings
export DISPLAY=:0
alias battery='upower -i /org/freedesktop/UPower/devices/battery_BAT0'
```

**On Desktop (~/.zshrc.local):**
```bash
# Desktop-specific settings
export DISPLAY=:1
alias gaming='steam &'
```

These files are sourced automatically by the main configs but never committed.

### Using Branches for Machine-Specific Configs (Advanced)

If you need dramatically different configs per machine:

```bash
# On laptop
cd ~/.dotfiles
git checkout -b laptop
# Make laptop-specific changes
git commit -am "Laptop-specific config"
git push -u origin laptop

# On desktop
git checkout -b desktop
# Make desktop-specific changes
git commit -am "Desktop-specific config"
git push -u origin desktop

# Merge shared changes from main
git checkout laptop
git merge main
```

---

## Security Best Practices

### Never Commit These Files

The `.gitignore` is configured to prevent this, but double-check:

- SSH keys (`.ssh/`)
- API tokens (`.claude.json`, `.config/gh/hosts.yml`)
- Environment files (`.env`)
- Password stores (`.gnupg/`, `.password-store/`)
- Browser data (`.mozilla/`, etc.)

### Before Pushing, Always Check

```bash
cd ~/.dotfiles

# Verify no secrets are staged
git status

# Check actual file contents
git diff --cached

# Look for patterns that might be secrets
git diff --cached | grep -iE '(password|token|secret|api.?key|private)'
```

### If You Accidentally Commit a Secret

1. **Immediately revoke/rotate the compromised credential**
2. Remove from Git history:
   ```bash
   # Using BFG Repo-Cleaner (recommended)
   bfg --delete-files secretfile.txt
   git reflog expire --expire=now --all
   git gc --prune=now --aggressive
   git push --force
   ```

3. Consider creating a new repository if widely distributed

### Use Password Managers for Secrets

Store secrets in a password manager and reference them:

```bash
# In ~/.zshrc.local (not tracked)
export GITHUB_TOKEN=$(op read "op://Personal/GitHub/token")
export AWS_KEY=$(pass show aws/access-key)
```

---

## Troubleshooting

### Stow Conflicts

**Problem:** Stow reports conflicts with existing files

**Solution:**
```bash
# Option 1: Backup and remove conflicting files
mv ~/.zshrc ~/.zshrc.backup
cd ~/.dotfiles
stow -R zsh

# Option 2: Force stow to adopt existing files
cd ~/.dotfiles
stow --adopt zsh
git diff    # See what changed
git restore .    # Restore repo version if needed
```

### Symlinks Not Created

**Problem:** Files aren't symlinked after running stow

**Solution:**
```bash
# Verify stow is working
cd ~/.dotfiles
stow -v -R zsh    # Verbose output

# Check if symlinks exist
ls -la ~/ | grep '\->'

# Manually verify target
file ~/.zshrc
# Should show: symbolic link to .dotfiles/zsh/.zshrc
```

### Shell Not Loading New Config

**Problem:** Changes to `.zshrc` don't appear

**Solution:**
```bash
# Reload shell configuration
source ~/.zshrc

# Or restart shell
exec $SHELL

# Or open new terminal
```

### Git Push Fails with SSH Error

**Problem:** `Permission denied (publickey)` when pushing

**Solution:**
```bash
# Verify SSH key is loaded
ssh-add -l

# Add SSH key if needed
ssh-add ~/.ssh/id_ed25519

# Test GitHub connection
ssh -T git@github.com

# Should see: "Hi USERNAME! You've successfully authenticated..."
```

### Oh My Zsh Plugin Not Working

**Problem:** Plugin installed but not functioning

**Solution:**
```bash
# Verify plugin is listed in .zshrc
grep "plugins=" ~/.zshrc

# Ensure plugin directory exists
ls ~/.oh-my-zsh/custom/plugins/

# Reinstall plugin
rm -rf ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
./scripts/setup-ohmyzsh.sh

# Reload shell
exec zsh
```

### Tmux Plugins Not Installing

**Problem:** TPM plugins not loading

**Solution:**
```bash
# Ensure TPM is installed
ls ~/.tmux/plugins/tpm/

# Reinstall TPM
./scripts/setup-tmux-plugins.sh

# In tmux, reload config
tmux source ~/.tmux.conf

# Install plugins
# Press: Ctrl-a + I (capital i)
```

### Machine-Specific Config Not Loading

**Problem:** `*.local` files not being sourced

**Solution:**
```bash
# Verify local files exist
ls ~/.zshrc.local
ls ~/.config/sway/config.local

# Create if missing
touch ~/.zshrc.local

# Verify sourcing in main config
grep "zshrc.local" ~/.zshrc
# Should see: [ -f ~/.zshrc.local ] && source ~/.zshrc.local

# Test manually
source ~/.zshrc.local
```

---

## Advanced Tips

### Selective Package Installation

Install only what you need on specific machines:

```bash
# Minimal server setup (no GUI)
./install.sh zsh bash tmux

# Full desktop setup
./install.sh --all
```

### Viewing Repository Structure

```bash
cd ~/.dotfiles

# Show all files (if tree installed)
tree -L 3 -a

# List all tracked files
git ls-files

# Show what's being ignored
git status --ignored
```

### Creating New Package

To add a new tool's configuration:

```bash
cd ~/.dotfiles

# Create package directory
mkdir -p neovim/.config/nvim

# Add config files
cp -r ~/.config/nvim/* neovim/.config/nvim/

# Stow the package
stow neovim

# Commit to repo
git add neovim/
git commit -m "Add Neovim configuration"
git push
```

### Backing Up Before Major Changes

```bash
# Create backup before updating
cd ~
tar czf dotfiles-backup-$(date +%Y%m%d).tar.gz \
    .zshrc .bashrc .tmux.conf .config/sway .config/foot

# Make changes...
cd ~/.dotfiles
git pull
```

---

## Quick Reference

### Common Commands

```bash
# Install on new machine
./install.sh

# Update from GitHub
cd ~/.dotfiles && git pull

# Save changes
cd ~/.dotfiles && git add -A && git commit -m "message" && git push

# Reinstall package
cd ~/.dotfiles && stow -R zsh

# Remove package
cd ~/.dotfiles && stow -D zsh

# View what's installed
cd ~/.dotfiles && stow -L
```

### File Locations

- Main repo: `~/.dotfiles/`
- Backups: `~/.dotfiles_backup_YYYYMMDD_HHMMSS/`
- Local configs: `~/*.local` and `~/.config/*/config.local`

---

**Remember:** The beauty of this setup is that your configs are version controlled, backed up on GitHub, and easy to deploy to new machines. Keep it simple and commit often!
