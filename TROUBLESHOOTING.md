# Troubleshooting Guide

## Claude Command Not Found After Restart

**Symptom**: The `claude` command works after running `install-new.sh --all`, but stops working after restarting the Raspberry Pi.

**Root Cause**: The PATH configuration for Claude Code was only in `.zshrc`, which isn't always sourced early enough for GUI applications like Sway or when starting new terminal sessions.

**Solution**: The PATH configuration has been moved to `.zshenv`, which is sourced earlier in the Zsh initialization sequence and ensures the PATH is available to all shells and GUI applications.

### Zsh Initialization Order

Zsh reads configuration files in this order:

1. **`.zshenv`** - Always sourced (even for non-interactive shells)
   - Use for: PATH, environment variables needed by all shells
   - This is where Claude Code PATH is now configured

2. **`.zprofile`** - Sourced for login shells
   - Use for: Login-specific configuration

3. **`.zshrc`** - Sourced for interactive shells
   - Use for: Aliases, functions, prompts, shell options

4. **`.zlogin`** - Sourced for login shells (after .zshrc)
   - Use for: Commands to run after login

### How to Apply the Fix

On your Raspberry Pi 5:

```bash
# Pull the latest dotfiles changes
cd ~/dotfiles  # or wherever you cloned the dotfiles
git pull

# Reinstall with the updated configuration
./install-new.sh --all

# Restart your shell or reboot to test
exec zsh
# or
sudo reboot
```

### Verification

After applying the fix:

1. Open a new terminal
2. Run: `echo $PATH` - you should see your NVM node version's bin directory in the PATH
3. Run: `which claude` - should show the path to the claude command (in NVM's bin directory)
4. Run: `claude --version` - should show the version

If you still have issues after reboot, check:

```bash
# Verify .zshenv is symlinked correctly
ls -la ~/.zshenv

# Verify NVM directory exists
ls -la ~/.nvm/versions/node/

# Check what's in the NVM bin directory
ls -la ~/.nvm/versions/node/*/bin/ | grep claude

# Check current shell
echo $SHELL

# Manually source to test
source ~/.zshenv
echo $PATH
```

### Local Overrides

If you need machine-specific environment variables, add them to `~/.zshenv.local`:

```bash
# Example: Add custom PATH entries
export PATH="$HOME/custom/bin:$PATH"

# Example: Set custom environment variables
export MY_CUSTOM_VAR="value"
```

# macOS-Specific Troubleshooting

## Apple Silicon (M1/M2/M3/M4) Issues

### Homebrew Path Problems

**Symptom**: Commands not found after installing packages, or `/usr/local` being used instead of `/opt/homebrew`.

**Root Cause**: Apple Silicon Macs use `/opt/homebrew` while Intel Macs use `/usr/local`. Mixed architecture installations can cause PATH conflicts.

#### Detection and Diagnosis

```bash
# Check your Mac architecture
uname -m
# Should show: arm64 for Apple Silicon, x86_64 for Intel

# Check current Homebrew installation paths
which brew
brew --prefix

# Check if you have conflicting Homebrew installations
ls -la /opt/homebrew 2>/dev/null && echo "ARM64 Homebrew found"
ls -la /usr/local/bin/brew 2>/dev/null && echo "x86_64 Homebrew found"

# Check your current PATH for Homebrew conflicts
echo $PATH | tr ':' '\n' | grep -E "(homebrew|local)"
```

#### Solutions

**Option 1: Use Automatic Detection (Recommended)**
```bash
# The dotfiles automatically detect Homebrew location
# Ensure your .zshenv is properly sourced:
source ~/.zshenv

# Verify the detection worked:
echo $HOMEBREW_PREFIX
```

**Option 2: Manual Cleanup for Mixed Installations**
```bash
# WARNING: This will remove your existing Homebrew installation
# Back up important packages first:
brew list > ~/brew-packages-backup.txt

# Remove x86_64 Homebrew if you have ARM64 Mac
sudo rm -rf /usr/local/Homebrew
sudo rm -rf /usr/local/Caskroom
sudo rm -rf /usr/local/bin/brew

# Reinstall Homebrew for ARM64
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Option 3: Keep Both (Advanced)**
```bash
# Add both paths to your .zshenv.local:
# ARM64 Homebrew (primary)
if [ -x "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
# x86_64 Homebrew (via Rosetta 2) - add as secondary
export PATH="/usr/local/bin:$PATH"
```

### Rosetta 2 Translation Issues

**Symptom**: Some applications refuse to run or show "architecture not supported" errors.

#### Check Rosetta 2 Status

```bash
# Check if Rosetta 2 is installed
pkgutil --pkg-info=com.apple.pkg.RosettaUpdateAuto

# Check if a binary is universal or architecture-specific
file /usr/local/bin/some-binary
lipo -info /usr/local/bin/some-binary 2>/dev/null || echo "Not a universal binary"

# Check current terminal architecture
arch
uname -m
```

#### Install Rosetta 2

```bash
# Install Rosetta 2 (if not already installed)
softwareupdate --install-rosetta --agree-to-license

# Verify installation
pkgutil --pkg-info=com.apple.pkg.RosettaUpdateAuto
```

#### Run x86_64 Applications

```bash
# Run specific command under Rosetta 2
arch -x86_64 /usr/local/bin/some-x86-app

# Run entire shell session under Rosetta 2
arch -x86_64 zsh

# Install x86_64 version of Homebrew packages
arch -x86_64 brew install some-package
```

### Terminal Architecture Problems

**Symptom**: PATH works in one terminal but not another, or commands inconsistent between terminals.

#### Diagnosis

```bash
# Check current terminal architecture
echo "Current architecture: $(uname -m)"
echo "Shell: $SHELL"
echo "PATH: $PATH"

# Check if terminal is running under Rosetta
sysctl -n sysctl.proc_translated 2>/dev/null && echo "Running under Rosetta" || echo "Native ARM64"

# Compare Homebrew prefix between sessions
echo "Homebrew prefix: $(brew --prefix 2>/dev/null || echo 'Not found')"
```

#### Solutions

```bash
# Ensure consistent shell sourcing
echo 'source ~/.zshenv' >> ~/.zshrc

# Restart shell completely
exec zsh

# For Terminal.app: Ensure "Open shells with: Default login shell" is selected
# For iTerm2: Check Profiles > Command > Login shell

# Test consistency across new terminals
# Open new terminal and run:
which brew && echo "Consistent PATH found"
```

## macOS Permissions and Security Issues

### Gatekeeper Blocking Applications

**Symptom**: "Application cannot be opened because the developer cannot be verified."

#### Solutions

**GUI Method:**
```bash
# Right-click app > Open > Click "Open" in dialog
# Or System Settings > Privacy & Security > Allow Anyway
```

**CLI Method:**
```bash
# Remove quarantine attribute from specific app
xattr -dr com.apple.quarantine /path/to/application.app

# For command-line tools:
xattr -dr com.apple.quarantine /usr/local/bin/some-tool

# List all quarantined apps in /Applications
ls -l@ /Applications | grep com.apple.quarantine
```

### Full Disk Access Permissions

**Symptom**: Terminal utilities can't access certain directories or system information.

#### Granting Permissions

1. **System Settings > Privacy & Security > Full Disk Access**
2. **Add your terminal application:**
   - For Terminal.app: `/System/Applications/Utilities/Terminal.app`
   - For iTerm2: `/Applications/iTerm.app`
3. **Restart your terminal**

#### Verification

```bash
# Test access to protected directories
ls -la ~/Library/Safari
ls -la /System/Library

# Test system information commands
system_profiler SPHardwareDataType
pmset -g batt
```

### Network Permission Issues

**Symptom**: `airport` command or network tools fail with permission errors.

#### Modern WiFi Management (airtool replacement)

```bash
# Use modern replacements instead of deprecated airport command

# Get current WiFi network
/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I
# Modern alternative:
networksetup -getairportnetwork en0

# Scan for WiFi networks
/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s
# Modern alternative:
/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s

# Get WiFi signal strength and details
/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep agrCtlRSSI
# Modern alternative:
iwconfig en0 2>/dev/null || echo "Use airport command for detailed info"
```

#### Network Diagnosis Commands

```bash
# Comprehensive network status
networksetup -listallhardwareports
networksetup -getinfo "Wi-Fi"

# Test connectivity
ping -c 4 8.8.8.8
scutil --nwi

# DNS troubleshooting
scutil --dns
nslookup google.com
```

## macOS Application Integration Issues

### Homebrew Cask Applications Not Launching

**Symptom**: Applications installed via `brew cask` don't appear in Launchpad or won't open.

#### Diagnosis and Solutions

```bash
# Check if application is installed
brew list --cask | grep -i appname

# Find application location
brew --cask info appname
ls -la "/Applications/$(brew info appname | grep -o 'App name.*' | head -1)"

# Reinstall problematic cask
brew reinstall --cask appname

# Clear Homebrew cache
brew cleanup --prune=30

# Manually create symlink if missing
ln -sf "/opt/homebrew/Caskroom/appname/latest/appname.app" "/Applications/"
```

### Launch Services Not Updated

**Symptom**: New applications don't appear in "Open With" menus.

#### Solutions

```bash
# Rebuild Launch Services database
/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -kill -r -domain local -domain system -domain user

# Kill and restart relevant services
killall Dock
killall Finder
```

## macOS Shell Configuration Issues

### Zsh Configuration Not Loading

**Symptom**: Custom aliases, functions, or PATH not working in new terminals.

#### macOS Shell Hierarchy

macOS uses different shell loading order than some Linux distributions:

1. **Login Shell**: `/etc/zprofile`, `~/.zprofile`
2. **Interactive Shell**: `/etc/zshrc`, `~/.zshrc`
3. **Always**: `/etc/zshenv`, `~/.zshenv`

#### Solutions

```bash
# Check which files are being sourced
zsh -xv 2>&1 | grep "source\|."

# Verify dotfiles are properly symlinked
ls -la ~/.zshenv ~/.zshrc ~/.zprofile

# Check for conflicting files
ls -la ~/.z* | grep -v dotfiles

# Force shell reload
exec zsh

# For Terminal.app: Check Preferences > Profiles > Shell > Run command
# Should be empty or set to: /bin/zsh

# For iTerm2: Check Profiles > General > Command
# Should be: Login shell
```

### Path Priority Issues

**Symptom**: Wrong version of command being used (system vs Homebrew).

#### Diagnosis and Resolution

```bash
# Check which version is being used
which -a git  # Show all git executables in PATH
type git     # Show which git will be executed

# Show PATH in order
echo $PATH | tr ':' '\n' | nl

# Fix Homebrew PATH priority
# Ensure .zshenv sources Homebrew before other paths
brew --prefix  # Should show /opt/homebrew for ARM64, /usr/local for Intel

# Reorder PATH if needed (add to ~/.zshenv.local)
export PATH="$(brew --prefix)/bin:$PATH"
export PATH="$(brew --prefix)/sbin:$PATH"
```

## Other Common Issues

### zsh-abbr Not Found

If abbreviations aren't working:

```bash
# Install zsh-abbr
brew install olets/tap/zsh-abbr

# Reload shell
exec zsh
```

### NVM Not Working

NVM is configured with lazy loading. The first time you use `node`, `npm`, `nvm`, or `npx`, it will automatically load NVM.

If you need to install NVM:

```bash
cd ~/dotfiles
./scripts/setup-nvm.sh
```

### Global npm Packages Not Found (Claude Code, etc.)

**Symptom**: You installed a global npm package (like `npm install -g @anthropic-ai/claude-code`), but the command isn't found.

**Root Cause**: When using NVM, global npm packages are installed to `~/.nvm/versions/node/v{version}/bin/`, not to a system-wide location. Your dotfiles now automatically detect and add this directory to your PATH.

**How it works**:
1. NVM installs Node.js to `~/.nvm/versions/node/v22.20.0/` (example)
2. Global npm packages go to `~/.nvm/versions/node/v22.20.0/bin/`
3. The dotfiles automatically detect the latest Node version and add its bin directory to PATH
4. This makes globally installed packages like `claude` immediately available

**Verification**:
```bash
# Check where npm installs global packages
npm config get prefix
# Should show: /home/pi/.nvm/versions/node/v22.20.0

# List globally installed packages
npm list -g --depth=0

# Check if the binary exists
ls -la ~/.nvm/versions/node/*/bin/claude

# Verify it's in your PATH
which claude
echo $PATH | grep nvm
```

**Important**: If you switch Node versions with `nvm use`, you may need to reinstall global packages or run `exec zsh` to refresh your PATH to the new version's bin directory.

### Sway Not Starting

Check the Sway logs:

```bash
# View Sway logs
journalctl --user -u sway

# Or run Sway with debug output
sway --debug
```

Common Sway issues:
- Missing `~/.config/sway/config.local` - created by install script
- Display configuration issues - edit `~/.config/sway/config.local` to set your display settings

### Permissions Issues

If you get permission errors:

```bash
# Fix permissions on dotfiles
chmod 644 ~/.zshenv ~/.zshrc ~/.bashrc
chmod 755 ~/dotfiles/install.sh ~/dotfiles/scripts/*.sh
```

---

## Restoring from Backup

If you need to restore your dotfiles from a previous backup (created automatically during installation), use the recovery script.

### Quick Recovery

```bash
# List all available backups
./scripts/recover.sh --list

# Restore from the latest backup (with confirmation)
./scripts/recover.sh --latest

# Interactive mode - select what to restore
./scripts/recover.sh --interactive
```

### Common Recovery Scenarios

#### Accidentally Deleted Configuration

If you accidentally deleted or broke your dotfiles:

```bash
# Restore from the most recent backup
cd ~/.dotfiles
./scripts/recover.sh --latest
```

#### Restore Specific Files Only

If you only want to restore certain files:

```bash
# Use interactive mode to select specific files
./scripts/recover.sh --interactive

# This will:
# 1. Show available backups
# 2. Let you choose a backup
# 3. Let you select specific files to restore
```

#### Verify Backup Before Restoring

If you want to check a backup before restoring:

```bash
# Verify backup integrity
./scripts/recover.sh --verify ~/.dotfiles_backup_20250115_120000

# Preview what would be restored (dry run)
./scripts/recover.sh --backup ~/.dotfiles_backup_20250115_120000 --dry-run
```

#### Restore from Specific Backup

If you have multiple backups and want to restore from a specific one:

```bash
# List all backups to find the one you want
./scripts/recover.sh --list

# Restore from specific backup
./scripts/recover.sh --backup ~/.dotfiles_backup_20250115_120000
```

### Safety Features

The recovery script includes several safety features:

- **Verification**: Checks backup integrity before restoring
- **Safety Backup**: Creates a backup of current files before overwriting
- **Confirmation Prompts**: Asks for confirmation before making changes
- **Dry Run Mode**: Preview changes without applying them
- **Selective Restore**: Choose which files to restore

### Recovery Script Options

```bash
# Show all available options
./scripts/recover.sh --help

# Common flags
--force      # Skip confirmation prompts
--dry-run    # Preview without making changes
--list       # List all available backups
--verify     # Check backup integrity
```

---

## 📚 Related Documentation

### macOS-Specific Guides
- **[macos-setup.md](macos-setup.md)** - Complete macOS development environment setup
- **[README.md](README.md)** - Main documentation with macOS platform support

### General Documentation
- **[SYSTEM_SETUP.md](SYSTEM_SETUP.md)** - System-wide configuration
- **[USAGE_GUIDE.md](USAGE_GUIDE.md)** - Daily usage and workflow guides

### Quick Links by Issue Type

#### Apple Silicon & Architecture
- [Homebrew Path Problems](#homebrew-path-problems)
- [Rosetta 2 Translation Issues](#rosetta-2-translation-issues)
- [Terminal Architecture Problems](#terminal-architecture-problems)

#### macOS Permissions & Security
- [Gatekeeper Blocking Applications](#gatekeeper-blocking-applications)
- [Full Disk Access Permissions](#full-disk-access-permissions)
- [Network Permission Issues](#network-permission-issues)

#### Application Integration
- [Homebrew Cask Applications Not Launching](#homebrew-cask-applications-not-launching)
- [Launch Services Not Updated](#launch-services-not-updated)

#### Shell Configuration
- [Zsh Configuration Not Loading](#zsh-configuration-not-loading)
- [Path Priority Issues](#path-priority-issues)

---

**Need more help?** Check the complete [macOS setup guide](macos-setup.md) for detailed configuration instructions and performance optimizations.
