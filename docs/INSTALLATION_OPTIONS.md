# Installation Options

Comprehensive guide to all dotfiles installation modes and options.

---

## Table of Contents

- [Quick Reference](#quick-reference)
- [Installation Modes](#installation-modes)
- [Conflict Resolution](#conflict-resolution)
- [Dependency Validation](#dependency-validation)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)

---

## Quick Reference

```bash
# Interactive mode (recommended for first-time users)
./install-new.sh

# Full automatic installation
./install-new.sh --all

# Check dependencies before installing
./install-new.sh --check-deps

# Component-specific installations
./install-new.sh --packages     # System packages only
./install-new.sh --terminal     # Terminal and shell setup only
./install-new.sh --dotfiles     # Dotfiles only (symlinks)
```

---

## Installation Modes

### Interactive Mode

**Command:** `./install-new.sh`

Launches an interactive menu that lets you choose which components to install.

**When to use:**
- First-time installation
- Selective component installation
- Testing individual components
- Learning what the installer does

**What happens:**
```
1. Displays component selection menu
2. Waits for your choice
3. Installs selected components
4. Shows post-install instructions
```

---

### Full Installation

**Command:** `./install-new.sh --all`

Installs everything in one go: system packages, dotfiles, and terminal configuration.

**What happens:**
1. ✓ **Pre-flight dependency check** - Validates prerequisites
2. ✓ **Package installation** - Installs from platform-specific manifests
3. ✓ **Dotfiles installation** - Creates symlinks via GNU Stow
4. ✓ **Local configs** - Creates `.local` override files
5. ✓ **Git/VSCode/NPM setup** - Configures development tools
6. ✓ **Terminal setup** - Installs Oh My Zsh, changes shell, configures prompt
7. ✓ **Health check** - Validates installation success

**Prerequisites:**
- Internet connection
- ~2GB disk space
- sudo access (for package installation and shell change)

**Time:** 8-12 minutes (varies by internet speed)

---

### Packages Only

**Command:** `./install-new.sh --packages`

Installs only system packages from platform-specific manifests.

**What gets installed:**

**macOS** (from `packages-macos.txt`):
- Core tools: git, curl, wget, stow, zsh, starship
- Development: python3, neovim
- macOS specific: rectangle, ghostty, sketchybar
- Utilities: ripgrep, fd, fzf, tree, jq

**Linux** (from `packages-linux.txt`):
- Core tools: git, curl, wget, stow, zsh, starship
- Development: python3, python3-pip, build-essential
- Sway WM: sway, waybar, foot, wmenu, grim
- Utilities: xclip, ripgrep, fd-find, fzf, tree, jq

**Time:** 5-8 minutes

---

### Terminal Setup Only

**Command:** `./install-new.sh --terminal`

Configures terminal environment without installing packages or dotfiles.

**What happens:**
1. Changes default shell to Zsh (requires sudo password)
2. Installs Oh My Zsh framework
3. Configures Starship prompt
4. Sets up tmux plugin manager
5. Platform-specific terminal setup (Ghostty on macOS, Foot on Linux)
6. Font installation (macOS only)

**Time:** 2-3 minutes

---

### Dotfiles Only

**Command:** `./install-new.sh --dotfiles`

Creates symlinks for dotfiles using GNU Stow, without installing packages or configuring terminal.

**What happens:**
1. Scans for stowable packages (directories with `.stowrc` or dotfiles)
2. Backs up existing conflicting files
3. Creates symlinks from `~/.dotfiles/` to `$HOME/`
4. Creates `.local` override files

**Packages stowed:**
- zsh → `~/.zshrc`, `~/.zshenv`, `~/.zprofile`
- starship → `~/.config/starship/*.toml`
- tmux → `~/.tmux.conf`
- git → `~/.gitconfig`
- ghostty/foot → `~/.config/ghostty/` or `~/.config/foot/`
- vscode → `~/.vscode/settings.json`, `keybindings.json`
- neovim → `~/.config/nvim/`
- And more...

**Time:** 1-2 minutes

---

### Preview Mode (Dry-Run)

**Command:** `./install-new.sh --preview [--all|--packages|--dotfiles|--terminal]`
**Alias:** `./install-new.sh --dry-run`

Preview what changes would be made **without actually modifying your system**. Perfect for understanding what will happen before committing to installation.

**Key Features:**
- ✓ **Zero modifications** - Completely safe to run
- ✓ **Package version comparison** - Shows current vs. available versions
- ✓ **Symlink preview** - Lists all dotfiles that would be linked
- ✓ **Conflict detection** - Identifies files that would be backed up
- ✓ **Shell changes** - Shows what terminal setup would do
- ✓ **Resource estimates** - Disk space and download requirements

---

#### Preview Output Example

```bash
$ ./install-new.sh --preview --all

╔═══════════════════════════════════════════════════════════════════╗
║  INSTALLATION PREVIEW MODE                                        ║
╟───────────────────────────────────────────────────────────────────╢
║  No changes will be made to your system                           ║
╚═══════════════════════════════════════════════════════════════════╝

▶ Packages
──────────────────────────────────────────────────────────────────────

Analyzing packages from: packages-macos.txt

  ⬡ ripgrep (14.1.0) - would install
  ⬆ neovim (0.9.5 → 0.10.0) - would upgrade
  ✓ git (2.42.0) - already installed
  ⬡ fzf (0.44.1) - would install

Total: 2 to install, 1 to upgrade, 8 already installed

▶ Dotfiles & Symlinks
──────────────────────────────────────────────────────────────────────

Found 10 package(s) to stow

Package: zsh
  → Would create 4 symlink(s)

Package: git
  ⚠ Conflict: .gitconfig (would be backed up)
  → Would create 2 symlink(s)

Package: starship
  → Would create 5 symlink(s)

Total: 35 symlink(s) would be created
⚠ 1 conflict(s) detected - files would be backed up

▶ Shell & Terminal Configuration
──────────────────────────────────────────────────────────────────────

  ◆ Install Oh My Zsh
  [WOULD] curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh

  ◆ Install Starship prompt
  [WOULD] brew install starship

▶ Summary
──────────────────────────────────────────────────────────────────────

Changes Overview:

  Packages:
    ⬡ 2 to install
    ⬆ 1 to upgrade
    ✓ 8 already installed

  Dotfiles:
    → 35 symlink(s) to create
    ⚠ 1 conflict(s) requiring backup

  Shell Configuration:
    ◆ 2 change(s)

Resource Estimates:
  Disk Space: ~100MB for new packages
  Backups: 1 file(s) to backup

To proceed with installation:
  ./install-new.sh --all
```

---

#### Preview Options

**Preview everything:**
```bash
./install-new.sh --preview --all
```

**Preview packages only:**
```bash
./install-new.sh --preview --packages
```
Shows which packages would be installed, upgraded, or are already present.

**Preview dotfiles only:**
```bash
./install-new.sh --preview --dotfiles
```
Lists all symlinks that would be created and any conflicts detected.

**Preview terminal setup only:**
```bash
./install-new.sh --preview --terminal
```
Shows what shell/terminal configuration changes would be made.

**Verbose preview:**
```bash
./install-new.sh --preview --all --verbose
```
Shows detailed output including:
- Every symlink path (not just counts)
- Already-installed packages (not hidden)
- Full stow dry-run output
- Detailed file paths

---

#### Preview Use Cases

**Before First Installation:**
```bash
# See what will happen before committing
./install-new.sh --preview --all

# If satisfied, proceed with actual installation
./install-new.sh --all
```

**Check for Conflicts:**
```bash
# Preview just dotfiles to see what conflicts exist
./install-new.sh --preview --dotfiles

# Review conflicts, backup manually if needed, then install
./install-new.sh --dotfiles
```

**Verify Package Updates:**
```bash
# Check which packages would be upgraded
./install-new.sh --preview --packages

# See version changes before updating
```

**Test on New System:**
```bash
# Safe way to explore what dotfiles would do
./install-new.sh --preview --all --verbose

# Learn about your dotfiles without risk
```

**CI/CD Validation:**
```bash
# Use in automated testing to verify installation scripts
./install-new.sh --preview --all
echo "Exit code: $?"  # Should be 0 if preview succeeds
```

---

#### Preview Mode Internals

Preview mode leverages:
- **Stow's dry-run:** `stow -n -v` to simulate symlink creation
- **Package manager queries:** `brew info`, `apt-cache policy`, etc.
- **System detection:** Checks current vs. available versions
- **Conflict analysis:** Identifies files that would be overwritten

**Preview is always safe:**
- No files are created or modified
- No packages are installed
- No system state is changed
- No sudo required
- Can be run multiple times

---

## Conflict Resolution

### Overview

When installing dotfiles, conflicts can occur when a file already exists at the target location. The dotfiles installer includes an intelligent conflict resolution system with both interactive and automatic modes.

**Default Behavior:** Interactive prompts for each conflict

**Command:** `./install-new.sh --dotfiles` (interactive, default)
**Auto-resolve:** `./install-new.sh --dotfiles --auto-resolve=STRATEGY`

---

### How Conflicts Are Detected

The installer uses GNU Stow's dry-run mode to detect conflicts **before** making any changes:

```bash
# Stow dry-run checks if files already exist
stow -n -v -d ~/.dotfiles -t ~/ package_name

# If conflicts exist, you'll be prompted for resolution
```

**Common conflict scenarios:**
- Existing `.zshrc` from Oh My Zsh installation
- `.gitconfig` with your current git settings
- `.tmux.conf` from previous tmux setup
- `.bashrc` from system defaults

---

### Interactive Conflict Resolution

**Mode:** `./install-new.sh --dotfiles --interactive` (default)

When a conflict is detected, you'll see an interactive prompt with 6 options:

```bash
Found 3 conflict(s) during installation

Conflict 1/3: ~/.gitconfig
──────────────────────────────────────────────────────────────────────
  ⚠ Existing: 145 lines (modified: 2025-01-15 14:32)
  ⬡ New:      167 lines (from dotfiles)

Options:
  1 - Keep existing (skip this dotfile)
  2 - Overwrite with new (backup existing)
  3 - View diff
  4 - Merge configurations (intelligent merge)
  5 - Keep both (rename existing → .orig)
  6 - Decide later (skip for now)

Choice [1-6]:
```

---

#### Resolution Options Explained

**Option 1: Keep Existing**
- Skips installing this dotfile
- Preserves your current file unchanged
- Dotfiles symlink is **not** created
- Use when: You want to keep your current config

**Option 2: Overwrite with New**
- Backs up existing file to `~/.dotfiles_backup_TIMESTAMP/`
- Removes original
- Creates symlink to new dotfile
- Backup includes metadata (date, reason, size)
- Use when: You trust the dotfiles version

**Option 3: View Diff**
- Shows side-by-side comparison using:
  - `delta` (if installed, best)
  - `colordiff` (if available)
  - `diff` (fallback)
- Returns to options menu after viewing
- Use when: You want to see what changed before deciding

**Option 4: Merge Configurations**
- Intelligently combines both files
- Supported file types:
  - `.gitconfig` - Merges sections
  - `.zshrc`, `.bashrc` - Appends with comments
  - `.tmux.conf` - Merges settings
  - `.vimrc`, `.nvimrc` - Appends with vim comments
- Backs up original before merging
- Use when: You want to preserve both configs

**Option 5: Keep Both**
- Renames existing to `.orig` (e.g., `.gitconfig.orig`)
- Creates symlink to new dotfile
- Both files remain accessible
- Use when: You want to manually merge later

**Option 6: Decide Later**
- Skips this conflict for now
- Continue with other files
- You can handle it manually after installation
- Use when: You need time to review

---

### Automatic Resolution Strategies

For non-interactive installations (CI/CD, automation), use auto-resolve strategies:

```bash
./install-new.sh --dotfiles --auto-resolve=STRATEGY
```

---

#### Strategy: `keep-existing`

**Command:** `./install-new.sh --dotfiles --auto-resolve=keep-existing`

**Behavior:**
- Skips all conflicting dotfiles
- Keeps your existing files unchanged
- Only installs non-conflicting dotfiles

**When to use:**
- Updating only new dotfiles
- Preserving existing configs
- Conservative updates

**Example:**
```bash
$ ./install-new.sh --dotfiles --auto-resolve=keep-existing

Installing Dotfiles...
⊘ Skipped: ~/.gitconfig (keeping existing)
✓ Stowed: zsh
⊘ Skipped: ~/.tmux.conf (keeping existing)
✓ Stowed: starship

Conflict Resolution Summary:
  ✓ Resolved: 0
  ⊘ Skipped:  2
```

---

#### Strategy: `overwrite`

**Command:** `./install-new.sh --dotfiles --auto-resolve=overwrite`

**Behavior:**
- Backs up all conflicting files to `~/.dotfiles_backup_TIMESTAMP/`
- Removes originals
- Installs all new dotfiles

**When to use:**
- Fresh installation
- Trusting dotfiles completely
- Full replacement of configs

**Example:**
```bash
$ ./install-new.sh --dotfiles --auto-resolve=overwrite

Installing Dotfiles...
✓ Backed up: ~/.gitconfig → ~/.dotfiles_backup_20250123_143022/gitconfig.backup
✓ Stowed: git
✓ Backed up: ~/.tmux.conf → ~/.dotfiles_backup_20250123_143022/tmux.conf.backup
✓ Stowed: tmux

Conflict Resolution Summary:
  ✓ Resolved: 2
  ⊘ Skipped:  0

Backup Location: ~/.dotfiles_backup_20250123_143022
```

---

#### Strategy: `backup-all`

**Command:** `./install-new.sh --dotfiles --auto-resolve=backup-all`

**Behavior:**
- Renames conflicting files with `.orig` suffix
- Installs new dotfiles
- Both versions remain on system

**When to use:**
- Want to manually merge later
- Need to compare old vs new
- Quick installation with safety net

**Example:**
```bash
$ ./install-new.sh --dotfiles --auto-resolve=backup-all

Installing Dotfiles...
✓ Renamed: ~/.gitconfig → ~/.gitconfig.orig
✓ Stowed: git
✓ Renamed: ~/.tmux.conf → ~/.tmux.conf.orig
✓ Stowed: tmux

Conflict Resolution Summary:
  ✓ Resolved: 2 (renamed to .orig)
  ⊘ Skipped:  0
```

---

#### Strategy: `fail-on-conflict`

**Command:** `./install-new.sh --dotfiles --auto-resolve=fail-on-conflict`

**Behavior:**
- Aborts installation if **any** conflict is detected
- No changes are made
- Returns error exit code

**When to use:**
- CI/CD pipelines (ensure clean state)
- Validation testing
- Strict control over configs

**Example:**
```bash
$ ./install-new.sh --dotfiles --auto-resolve=fail-on-conflict

Installing Dotfiles...
[ERROR] Conflict detected: ~/.gitconfig
Installation aborted due to conflicts

Exit code: 1
```

---

### Intelligent Merge Capabilities

The installer can automatically merge certain configuration file types:

#### Git Config (`.gitconfig`)

```bash
# Your existing ~/.gitconfig
[user]
    name = John Doe
    email = john@example.com
[core]
    editor = vim

# After merge (combines both)
# Merged .gitconfig (2025-01-23)
# Original configuration:

[user]
    name = John Doe
    email = john@example.com
[core]
    editor = vim

# New dotfiles configuration:

[user]
    name = New User
    email = new@example.com
[core]
    editor = nvim
    autocrlf = input
[alias]
    st = status
    co = checkout
```

You can then manually edit to resolve duplicates.

#### Shell RC Files (`.zshrc`, `.bashrc`)

```bash
# Your existing ~/.zshrc
export PATH="$HOME/bin:$PATH"
alias ll='ls -la'

# After merge (appends new config)
export PATH="$HOME/bin:$PATH"
alias ll='ls -la'

# ==============================================================================
# Dotfiles configuration added 2025-01-23 14:30:00
# ==============================================================================

# New zsh configuration from dotfiles
export EDITOR=nvim
alias gs='git status'
```

#### Tmux Config (`.tmux.conf`)

Similar to shell RC files, appends new configuration with separator comments.

---

### Diff Viewing

When viewing diffs (Option 3), the installer uses the best available tool:

**Priority:**
1. **delta** (recommended) - Syntax highlighting, side-by-side
2. **colordiff** - Colored unified diff
3. **diff** - Standard unified diff

**Install delta for best experience:**
```bash
# macOS
brew install git-delta

# Linux
sudo apt install git-delta
```

**Example diff output:**
```diff
--- existing: ~/.gitconfig
+++ new: git/.gitconfig

@@ -1,4 +1,6 @@
 [user]
-    editor = vim
+    editor = nvim
+[alias]
+    st = status
```

---

### Backup Management

**Backup Location:** `~/.dotfiles_backup_TIMESTAMP/`

**What's Backed Up:**
- Original file contents
- Metadata file (`.meta`) with:
  - Original path
  - Backup date
  - Backup reason (overwritten, merged, etc.)
  - File size and line count

**Example backup structure:**
```
~/.dotfiles_backup_20250123_143022/
├── gitconfig.backup
├── gitconfig.backup.meta
├── zshrc.backup
├── zshrc.backup.meta
└── tmux.conf.backup
```

**Metadata file example:**
```bash
$ cat ~/.dotfiles_backup_20250123_143022/gitconfig.backup.meta

original_path=/Users/username/.gitconfig
backup_date=Wed Jan 23 14:30:22 PST 2025
backup_reason=overwritten
file_size=2847
file_lines=145
```

**Restore a backup:**
```bash
# Restore specific file
cp ~/.dotfiles_backup_20250123_143022/gitconfig.backup ~/.gitconfig

# Remove symlink first if it exists
rm ~/.gitconfig
cp ~/.dotfiles_backup_20250123_143022/gitconfig.backup ~/.gitconfig
```

---

### Conflict Resolution Examples

#### Example 1: Interactive Installation with Merge

```bash
$ ./install-new.sh --dotfiles

Installing Dotfiles...

Found 1 conflict(s) for package: git

Conflict 1/1: ~/.gitconfig
──────────────────────────────────────────────────────────────────────
  ⚠ Existing: 145 lines (modified: 2025-01-15 14:32)
  ⬡ New:      167 lines (from dotfiles)

Options:
  1 - Keep existing (skip this dotfile)
  2 - Overwrite with new (backup existing)
  3 - View diff
  4 - Merge configurations (intelligent merge)
  5 - Keep both (rename existing → .orig)
  6 - Decide later (skip for now)

Choice [1-6]: 4

[INFO] Attempting intelligent merge...
[INFO] Merging gitconfig files...
✓ Gitconfig files merged
✓ Files merged successfully
✓ Original backed up to: ~/.dotfiles_backup_20250123_143022/gitconfig.backup

Conflict Resolution Summary for git:
  ✓ Resolved: 1
  ⊘ Skipped:  0

✓ Stowed git
```

#### Example 2: Auto-Resolve with Overwrite

```bash
$ ./install-new.sh --dotfiles --auto-resolve=overwrite --verbose

Installing Dotfiles...
Available packages: zsh starship tmux git neovim

▸ Processing package: git
  Auto-resolve: Overwriting: ~/.gitconfig
  Backed up: ~/.gitconfig → ~/.dotfiles_backup_20250123_143500/gitconfig.backup
✓ Stowed git

Conflict Resolution Summary for git:
  ✓ Resolved: 1
  ⊘ Skipped:  0

✓ Dotfiles installation completed
```

#### Example 3: Preview Conflicts

```bash
$ ./install-new.sh --preview --dotfiles

╔═══════════════════════════════════════════════════════════════════╗
║  INSTALLATION PREVIEW MODE                                        ║
╟───────────────────────────────────────────────────────────────────╢
║  No changes will be made to your system                           ║
╚═══════════════════════════════════════════════════════════════════╝

▶ Dotfiles & Symlinks
──────────────────────────────────────────────────────────────────────

Found 5 package(s) to stow

Package: git
  ⚠ Conflict: ~/.gitconfig (would be backed up)
  → Would create 1 symlink(s)

Package: zsh
  ⚠ Conflict: ~/.zshrc (would be backed up)
  → Would create 3 symlink(s)

Total: 15 symlink(s) would be created
⚠ 2 conflict(s) detected - files would be backed up

[INFO] Conflict Resolution: Interactive mode (will prompt for conflicts)
```

---

### Best Practices

**1. Preview Before Installing**
```bash
# See conflicts before committing
./install-new.sh --preview --dotfiles
```

**2. Backup Important Configs**
```bash
# Manual backup of critical files
cp ~/.gitconfig ~/gitconfig.backup
cp ~/.zshrc ~/zshrc.backup

# Then install
./install-new.sh --dotfiles
```

**3. Use Merge for Config Files**
- Choose option 4 (Merge) for `.gitconfig`, `.zshrc`, etc.
- Manually edit merged file to remove duplicates
- Keep best of both configs

**4. Keep Both for Complex Configs**
- Choose option 5 (Keep Both) for complex files
- Compare `.orig` vs new manually
- Merge by hand for precision

**5. Install Delta for Better Diffs**
```bash
brew install git-delta  # macOS
sudo apt install git-delta  # Linux

# Then use option 3 (View Diff) for beautiful comparisons
```

---

## Dependency Validation

### Overview

The dependency validation system ensures all required tools are present before installation begins, preventing mid-installation failures.

**Command:** `./install-new.sh --check-deps`

---

### What Gets Checked

#### Critical Dependencies
These are **required** for installation to succeed:
- `git` - Version control
- `stow` - Symlink manager
- `curl` - Download tool

#### Package Manager
Platform-specific package managers:
- **macOS:** Homebrew (`/opt/homebrew/bin/brew` or `/usr/local/bin/brew`)
- **Linux:** apt, dnf, pacman, etc. (auto-detected)

#### Optional Dependencies
These **enhance the experience** but aren't required:
- `delta` - Better diff viewing in conflict resolution
- `fzf` - Interactive selection for future features
- `zsh` - Default shell (can be installed during setup)

#### System Requirements
- **Disk space:** At least 2GB available
- **Internet connection:** Active (for package downloads)
- **Shell:** Any POSIX-compatible shell

---

### Pre-flight Check Output

```bash
$ ./install-new.sh --check-deps

═══════════════════════════════════════════════════════════════════
PRE-FLIGHT DEPENDENCY CHECK
═══════════════════════════════════════════════════════════════════

Checking system prerequisites...

[Core Dependencies]
✓ git (2.42.0) - installed
✓ curl (8.1.2) - installed
✓ wget (1.21.3) - installed
✗ stow - NOT FOUND
✓ zsh (5.9) - installed

[Package Manager]
✓ Homebrew (4.2.5) - installed

[Optional Tools]
⬡ delta - not found (Delta diff viewer)
⬡ fzf - not found (Fuzzy finder for interactive selection)

[System Requirements]
✓ Disk space: 45 GB available (need ~2 GB)
✓ Internet connection: active
✓ Shell: /bin/zsh

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ MISSING DEPENDENCIES DETECTED

The following required dependencies are missing:
  • stow (GNU Stow symlink manager)

Would you like to install missing dependencies now?

  1. Install all missing dependencies (recommended)
  2. Install only critical dependencies
  3. Show manual installation instructions
  4. Continue anyway (not recommended - may fail)
  5. Exit

Enter choice (1-5) [default: 1]:
```

---

### Auto-Install Options

#### Option 1: Install All (Recommended)

Automatically installs all missing dependencies (critical + optional).

```bash
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
INSTALLING DEPENDENCIES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[1/3] Installing stow...
==> Downloading stow 2.3.1...
✓ stow installed successfully

[2/3] Installing delta...
==> Downloading delta 0.16.5...
✓ delta installed successfully

[3/3] Installing fzf...
==> Downloading fzf 0.44.1...
✓ fzf installed successfully

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ All dependencies installed successfully!

Re-running pre-flight check...

✓ All prerequisites satisfied. Proceeding with installation...
```

#### Option 2: Install Critical Only

Installs only the **required** dependencies, skipping optional ones.

#### Option 3: Manual Installation Instructions

Shows platform-specific installation commands for each missing dependency.

```bash
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MANUAL INSTALLATION INSTRUCTIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

To install missing dependencies manually:

▸ stow (GNU Stow symlink manager)
  Platform: macos
  Command: brew install stow

  Alternative (from source):
    curl -O https://ftp.gnu.org/gnu/stow/stow-2.3.1.tar.gz
    tar -xzf stow-2.3.1.tar.gz
    cd stow-2.3.1
    ./configure && make && sudo make install

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

After installing dependencies, re-run this script:
  ./install-new.sh --all

Or check dependencies only:
  ./install-new.sh --check-deps
```

#### Option 4: Continue Anyway

Bypasses the check and continues with installation. **Not recommended** - may result in installation failure.

#### Option 5: Exit

Exits the installer, allowing you to install dependencies manually.

---

### Automatic Pre-flight Integration

When running `./install-new.sh --all`, the pre-flight check runs **automatically** before any installation begins:

```bash
$ ./install-new.sh --all

═══ Complete Installation ═══

▸ PRE-FLIGHT DEPENDENCY CHECK
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Checking system prerequisites...

[Core Dependencies]
✓ git (2.42.0) - installed
✓ curl (8.1.2) - installed
✓ stow (2.3.1) - installed

[Package Manager]
✓ Homebrew (4.2.5) - installed

✓ All prerequisites satisfied

═══ Installing System Packages ═══
[Installation continues...]
```

If dependencies are missing, you'll be prompted to install them before proceeding.

---

## Examples

### Example 1: Fresh macOS Setup

```bash
# Clone dotfiles
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Check what's needed (Homebrew likely missing on fresh install)
./install-new.sh --check-deps

# Choose option 1 to install Homebrew and all dependencies
# Then run full installation
./install-new.sh --all
```

### Example 2: Linux Server (Minimal Install)

```bash
# Only install dotfiles and configure shell, skip GUI packages
./install-new.sh --dotfiles
./install-new.sh --terminal

# Manually install only needed packages
sudo apt install git curl stow zsh
```

### Example 3: Update Existing Installation

```bash
# Pull latest changes
cd ~/.dotfiles
git pull

# Re-stow dotfiles to update symlinks
./install-new.sh --dotfiles

# Or rebuild everything
./install-new.sh --all
```

### Example 4: Verify Installation

```bash
# Check all dependencies are present
./install-new.sh --check-deps

# Run health check
./scripts/health-check.sh
```

---

## Troubleshooting

### "stow: ERROR: cannot stow ..."

**Cause:** Existing file conflicts with symlink

**Solution:**
- Backup conflicts are created automatically in `~/.dotfiles_backup_*`
- Manually remove or move conflicting files
- Re-run installation

### "Homebrew not found" on macOS

**Cause:** Homebrew not installed or not in PATH

**Solution:**
```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add to PATH (Apple Silicon)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Re-run check
./install-new.sh --check-deps
```

### "Permission denied" during installation

**Cause:** Sudo password required for system package installation or shell change

**Solution:**
- Ensure you have sudo access
- Enter password when prompted
- Some operations require sudo (package install, `chsh`)

### "Insufficient disk space"

**Cause:** Less than 2GB available

**Solution:**
- Free up disk space
- Install only critical components (`--dotfiles` + `--terminal`)
- Skip optional packages

### Installation hangs or times out

**Cause:** Network issues or slow mirror

**Solution:**
- Check internet connection
- For macOS: `brew doctor` to check Homebrew
- For Linux: Update package cache (`sudo apt update`)
- Try again later

---

## Platform-Specific Notes

### macOS

**Homebrew Requirement:**
- Required for package management
- Auto-detected at `/opt/homebrew` (Apple Silicon) or `/usr/local` (Intel)
- Installed automatically if missing (with permission)

**Special Packages:**
- `sketchybar` requires custom tap: `FelixKratz/formulae`
- Rectangle for window management
- Ghostty terminal emulator

### Linux

**Package Manager Detection:**
- Automatically detects: apt, dnf, pacman, zypper, xbps, apk, emerge, eopkg
- Fallback to distribution file detection if `/etc/os-release` unavailable

**Window Manager:**
- Sway (Wayland) with waybar, foot terminal
- Packages optimized for Wayland but work with X11

---

## Next Steps

After installation:

1. **Reload shell:** `exec zsh` or restart terminal
2. **Install tmux plugins:** Press `Prefix + I` (Ctrl-a + Shift-i on macOS, Ctrl-b + Shift-i on Linux)
3. **Customize:** Edit `.local` files for machine-specific overrides
4. **Verify:** Run `./scripts/health-check.sh`

See [Getting Started](GETTING_STARTED.md) for detailed next steps.
