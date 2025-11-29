# Dotfiles Usage Guide

This guide provides detailed instructions for managing your dotfiles across multiple machines.

## Table of Contents

1. [First-Time Setup on New Machine](#first-time-setup-on-new-machine)
2. [Daily Workflow](#daily-workflow)
3. [Shell Abbreviations (zsh-abbr)](#shell-abbreviations-zsh-abbr)
4. [Starship Prompt Customization](#starship-prompt-customization)
5. [Updating Configurations](#updating-configurations)
6. [Syncing Across Machines](#syncing-across-machines)
7. [Linux Uniclip Service](#linux-uniclip-service)
8. [Security Best Practices](#security-best-practices)
9. [Troubleshooting](#troubleshooting)

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
git clone git@github.com:BrennonTWilliams/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

### 3. Run Installation Script

**Interactive (recommended for first time):**
```bash
./install-new.sh
```

The script will:
- Detect your operating system
- Check for required dependencies
- Backup existing configuration files
- Let you choose which packages to install
- Create machine-specific local config files

**Non-interactive (install everything):**
```bash
./install-new.sh --all
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
xargs -a packages-linux.txt sudo apt install -y

# macOS
xargs -a packages-macos.txt brew install
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

## Shell Abbreviations (zsh-abbr)

The dotfiles support [zsh-abbr](https://zsh-abbr.olets.dev/) for expandable abbreviations. Unlike aliases, abbreviations expand to their full command when you press Space or Enter, showing the actual command in your history.

### Abbreviation Modes

Toggle via `DOTFILES_ABBR_MODE` environment variable in `~/.zshenv.local`:

| Mode | Behavior |
|------|----------|
| `alias` | Traditional aliases only (default, backward compatible) |
| `abbr` | zsh-abbr abbreviations only (requires zsh-abbr installed) |
| `both` | Both systems active (for transition/testing) |

### Setup

```bash
# Install zsh-abbr (optional, only needed for abbr/both modes)
brew install olets/tap/zsh-abbr

# Enable abbreviations in ~/.zshenv.local
export DOTFILES_ABBR_MODE="abbr"
```

### How It Works

**With aliases (`gs`):**
```
$ gs<Enter>
# Runs: gs (shows as 'gs' in history)
```

**With abbreviations (`gs`):**
```
$ gs<Space>
# Expands to: git status (shows as 'git status' in history)
```

### Module Structure

```
zsh/
├── functions/       # Always loaded (mkcd, qfind, nvim-keys, etc.)
├── aliases/         # Always loaded (safety: rm -i, cp -i, mv -i)
│   ├── safety.zsh   # Destructive command safeguards
│   └── extras.zsh   # Aliases for non-abbr mode fallback
└── abbreviations/   # Loaded in abbr/both modes
    ├── git.zsh      # gs, ga, gc, gp, gl, gd, gco, gb
    ├── navigation.zsh # .., ..., ....
    ├── tmux.zsh     # tls, ta, tn, tk
    └── ...
```

### Known Conflicts

Some abbreviations conflict with system commands:
- `gs` - Conflicts with Ghostscript (`/opt/homebrew/bin/gs`)
- `cc` - Conflicts with C compiler (`/usr/bin/cc`)

zsh-abbr will show warnings but these shortcuts still work in `alias` or `both` mode.

---

## Starship Prompt Customization

The Starship prompt includes customizable Nerd Font icons for Git status and multiple visual styles.

### Icon Style Switching

The configuration includes three Nerd Font icon styles:

1. **Material Design** (default) - Modern, clean icons
2. **Font Awesome** - Classic, widely recognized icons
3. **Minimalist** - Simple, subtle line art

#### Switching Between Styles

1. **Open your active Starship mode configuration:**
   ```bash
   # Edit the mode you're currently using
   vim ~/.dotfiles/starship/modes/standard.toml
   # or: compact.toml, verbose.toml, gruvbox-rainbow.toml
   ```

2. **Comment out current active style:**
   ```toml
   # [git_status]  # Material Design (current)
   # ... configuration ...
   ```

3. **Uncomment your preferred style:**
   ```toml
   [git_status]   # Font Awesome (activate)
   # ... configuration ...
   ```

4. **Reload shell:**
   ```bash
   source ~/.zshrc
   ```

### Testing Icon Rendering

Use the provided test script to verify icons display correctly:

```bash
cd ~/.dotfiles
./scripts/nerd-font-test.sh
```

This script shows all three icon styles and helps verify your terminal font supports the chosen Nerd Font icons.

### Common Icon Mappings

| Git Status | Material Design | Font Awesome | Minimalist |
|------------|-----------------|--------------|------------|
| Modified |  |  |  |
| Staged | ✓ | ✓ | ✓ |
| Untracked |  |  |  |
| Conflicted |  |  |  |

### Custom Icon Configuration

To customize individual icons, edit the active `[git_status]` section:

```toml
[git_status]
format = "([\\[$all_status$ahead_behind\\]]($style) )"
style = "bold red"
# Custom icons
conflicted = "⚠️ "
modified = "• "
untracked = "? "
staged = "✓ "
```

### Troubleshooting Icons

**Icons not displaying:**
1. Verify terminal font: `echo $TERM`
2. Test with script: `./scripts/nerd-font-test.sh`
3. Check Ghostty font configuration
4. Ensure IosevkaTerm Nerd Font is installed

**Prompt not updating:**
1. Reload shell: `source ~/.zshrc`
2. Test configuration: `starship explain`
3. Re-stow configuration: `cd ~/.dotfiles && stow -R starship`

For comprehensive Starship documentation, see `docs/STARSHIP_CONFIGURATION.md`.

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

## Linux Uniclip Service

Uniclip provides universal clipboard synchronization between your Raspberry Pi (running Linux) and Mac Mini M4. The service runs automatically on the Raspberry Pi and allows seamless copy/paste between devices.

### Overview

- **Purpose:** Universal clipboard sync between Raspberry Pi and Mac Mini M4
- **Version:** 2.3.6 (via Homebrew)
- **Service Type:** Systemd user service (auto-starts on boot)
- **Wayland Support:** Uses `wl-clipboard` utilities (wl-copy/wl-paste)

### Managing the Service

#### Check Service Status

```bash
systemctl --user status uniclip
```

This shows whether the service is running, enabled, and any recent log entries.

#### Start the Service

```bash
systemctl --user start uniclip
```

#### Stop the Service

```bash
systemctl --user stop uniclip
```

#### Restart the Service

If clipboard sync stops working or you need to refresh the connection:

```bash
systemctl --user restart uniclip
```

#### Enable/Disable Auto-Start

The service is configured to start automatically on boot. To manage this:

```bash
# Disable auto-start
systemctl --user disable uniclip

# Re-enable auto-start
systemctl --user enable uniclip
```

### Using Clipboard Sync

#### How It Works

1. **Raspberry Pi:** Uniclip runs as a systemd service and creates a clipboard server
2. **Mac Mini:** Set the `UNICLIP_SERVER` environment variable and use the `clipboard-sync` alias
3. **Sync:** Copy text on one device, paste on the other automatically
4. **Auto-start:** Pi service starts on boot; Mac uses shell alias for manual connection

#### Finding the Connection Address

The Uniclip service uses a dynamic address that may change when the service restarts. To find the current connection address:

```bash
journalctl --user -u uniclip -n 5 --no-pager | grep "Run"
```

This displays the server address (e.g., `192.168.1.x:port`) that you need to set on the Mac.

#### Connecting from Mac Mini

On your Mac Mini, set the `UNICLIP_SERVER` environment variable:

**In `~/.zshenv` (recommended):**
```bash
export UNICLIP_SERVER="192.168.1.x:port"
```

Replace `192.168.1.x:port` with the actual address from the previous command.

**Then use the clipboard-sync alias** (configured in `~/.zshrc` or `~/.bashrc`):
```bash
clipboard-sync
```

#### Testing the Sync

1. **Copy on Pi:** Copy text to clipboard on Raspberry Pi
2. **Paste on Mac:** Paste (Cmd+V) on Mac Mini - should show the Pi's clipboard content
3. **Copy on Mac:** Copy text on Mac Mini
4. **Paste on Pi:** Paste on Raspberry Pi - should show the Mac's clipboard content

### Viewing Service Logs

#### Live Log Monitoring

To watch service logs in real-time (useful for troubleshooting):

```bash
journalctl --user -u uniclip -f
```

Press `Ctrl+C` to stop following.

#### Recent Log Entries

View the last 20 log entries:

```bash
journalctl --user -u uniclip -n 20 --no-pager
```

#### Log Since Last Boot

```bash
journalctl --user -u uniclip -b
```

### Common Troubleshooting

#### Clipboard Not Syncing

**Check service is running:**
```bash
systemctl --user status uniclip
```

If not running, start it:
```bash
systemctl --user start uniclip
```

**Verify Wayland display:**
The service requires `WAYLAND_DISPLAY=wayland-1`. Check the service configuration:
```bash
systemctl --user cat uniclip
```

#### Connection Address Changed

After restarting the Uniclip service, the port may change. Update the Mac's `UNICLIP_SERVER` variable:

1. **Find new address on Pi:**
   ```bash
   journalctl --user -u uniclip -n 5 --no-pager | grep "Run"
   ```

2. **Update on Mac** in `~/.zshenv`:
   ```bash
   export UNICLIP_SERVER="192.168.1.x:new-port"
   ```

3. **Reload shell on Mac:**
   ```bash
   source ~/.zshenv
   ```

#### Service Fails to Start

**Check service logs for errors:**
```bash
journalctl --user -u uniclip -n 50 --no-pager
```

**Common issues:**
- `wl-clipboard` not installed: `brew install wl-clipboard`
- Uniclip binary not found: Verify installation at `/home/linuxbrew/.linuxbrew/bin/uniclip`
- Wayland session not available: Ensure you're running Sway or another Wayland compositor

**Restart the service after fixing issues:**
```bash
systemctl --user restart uniclip
```

#### Service Configuration Location

The service file is located at:
```
~/.config/systemd/user/uniclip.service
```

After editing the service file, reload systemd:
```bash
systemctl --user daemon-reload
systemctl --user restart uniclip
```

#### Network Connectivity Issues

If the Mac can't connect to the Pi:

1. **Verify Pi's IP address:**
   ```bash
   ip addr show
   ```

2. **Ping Pi from Mac:**
   ```bash
   ping 192.168.1.x
   ```

3. **Check firewall rules on Pi** (if applicable):
   ```bash
   sudo ufw status
   ```

4. **Ensure both devices are on the same network**

### Dependencies

The Uniclip service requires these packages:
- `uniclip` (2.3.6) - Universal clipboard sync tool
- `wl-clipboard` (2.2.1-2) - Wayland clipboard utilities

**Verify installation:**
```bash
which uniclip
which wl-copy
which wl-paste
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
./install-new.sh zsh bash tmux

# Full desktop setup
./install-new.sh --all
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
./install-new.sh

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
