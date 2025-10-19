# System Setup Documentation

**Last Updated:** 2025-10-18
**User:** pi
**System:** Raspberry Pi (aarch64) - Debian GNU/Linux 13 (trixie)

---

## Table of Contents

1. [System Information](#system-information)
2. [Shell Environment](#shell-environment)
3. [Tmux Configuration](#tmux-configuration)
4. [Sway Window Manager](#sway-window-manager)
5. [Package Managers](#package-managers)
6. [Development Tools](#development-tools)
7. [Key Configuration Files](#key-configuration-files)
8. [Quick Reference](#quick-reference)

---

## System Information

- **Architecture:** aarch64 (ARM64)
- **OS:** Debian GNU/Linux 13 (trixie)
- **Kernel:** Linux 6.12.47+rpt-rpi-2712
- **Default Shell:** zsh (`/usr/bin/zsh`)

---

## Shell Environment

### Zsh

- **Version:** 5.9
- **Framework:** Oh My Zsh
- **Installation Location:** `~/.oh-my-zsh`
- **Configuration File:** `~/.zshrc`

#### Theme

- **Active Theme:** Gruvbox (`gruvbox.zsh-theme`)
- **Location:** `~/.oh-my-zsh/custom/themes/gruvbox.zsh-theme`

#### Plugins

Located in `~/.zshrc:73`:

```zsh
plugins=(git z zsh-autosuggestions zsh-syntax-highlighting tmux colored-man-pages command-not-found extract)
```

**Plugin Details:**

- `git` - Git aliases and functions (built-in)
- `z` - Jump to frequently used directories (built-in)
- `zsh-autosuggestions` - Fish-like autosuggestions (custom: `~/.oh-my-zsh/custom/plugins/zsh-autosuggestions`)
- `zsh-syntax-highlighting` - Syntax highlighting for commands (custom: `~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting`)
- `tmux` - Tmux integration (built-in)
- `colored-man-pages` - Colorized man pages (built-in)
- `command-not-found` - Suggests package installation for missing commands (built-in)
- `extract` - Universal archive extraction (built-in)

#### Custom Configuration

**History Settings** (`~/.zshrc:79-84`):
- `HISTSIZE=50000` - 50k commands in memory
- `SAVEHIST=50000` - 50k commands saved to file
- `HIST_IGNORE_ALL_DUPS` - Remove older duplicates
- `HIST_FIND_NO_DUPS` - Don't display duplicates in search
- `SHARE_HISTORY` - Share history across sessions

**Zsh Options** (`~/.zshrc:86-89`):
- `EXTENDED_GLOB` - Better globbing patterns
- `AUTO_CD` - Type directory name to cd
- `CORRECT` - Correct typos in commands
- `COMPLETION_WAITING_DOTS="true"` - Show dots while waiting for completion

**Environment Variables** (`~/.zshrc:97-98`):
- `EDITOR='vim'`
- `VISUAL='vim'`

#### Custom Aliases

**Location:** `~/.oh-my-zsh/custom/aliases.zsh`

**Directory Navigation:**
```zsh
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
```

**File Operations:**
```zsh
alias ls='ls --color=auto'
alias ll='ls -alFh'
alias la='ls -A'
alias l='ls -CF'
alias lh='ls -lh'
```

**Git Shortcuts:**
```zsh
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
```

**System Management:**
```zsh
alias update='sudo apt update && sudo apt upgrade -y'
alias cleanup='sudo apt autoremove -y && sudo apt autoclean'
alias h='history'
alias c='clear'
```

**Tmux Shortcuts:**
```zsh
alias tls='tmux ls'
alias ta='tmux attach -t'
alias tn='tmux new -s'
alias tk='tmux kill-session -t'
```

**Development:**
```zsh
alias serve='python3 -m http.server'
alias ports='netstat -tulanp'
```

**Safety Nets:**
```zsh
alias rm='rm -i'    # Confirm before delete
alias cp='cp -i'    # Confirm before overwrite
alias mv='mv -i'    # Confirm before overwrite
```

**Custom Functions:**
```zsh
mkcd() {          # Create and enter directory
  mkdir -p "$1" && cd "$1"
}

qfind() {         # Quick find
  find . -name "*$1*"
}
```

#### Oh My Zsh Update Settings

- **Update Mode:** Auto (updates automatically without asking)
- **Update Frequency:** 7 days

---

## Tmux Configuration

### Tmux

- **Version:** 3.5a
- **Configuration File:** `~/.tmux.conf`
- **Plugin Manager:** TPM (Tmux Plugin Manager)
- **Plugins Directory:** `~/.tmux/plugins/`

### General Settings

**Display & Performance** (`~/.tmux.conf:8-34`):
- 256 color support with true color
- Mouse support enabled
- Windows/panes start at index 1
- Auto-renumber windows when closed
- 50,000 line scrollback buffer
- Vi mode for copy/paste
- Zero escape time (for better vim/nvim integration)
- Focus events enabled
- Aggressive resize for multiple clients

### Key Bindings

**Prefix Key:** `Ctrl-a` (changed from default `Ctrl-b`)

**Pane Management** (`~/.tmux.conf:45-64`):
- `Prefix + |` - Split horizontally
- `Prefix + -` - Split vertically
- `Alt + Arrow Keys` - Navigate panes (no prefix needed)
- `Prefix + h/j/k/l` - Vi-style pane navigation

**Session Management:**
- `Prefix + r` - Reload config file
- `Prefix + S` - Toggle pane synchronization

**Copy Mode** (`~/.tmux.conf:67-72`):
- Vi-style keybindings
- `v` - Begin selection
- `y` - Copy selection (uses `xclip` on Linux, `pbcopy` on macOS)

### Theme

**Gruvbox Dark** (`~/.tmux.conf:78-105`):
- Status bar: Dark background (#282828) with light foreground (#ebdbb2)
- Active window: Highlighted with golden yellow (#fabd2f)
- Pane borders: Active panes have golden border
- Session name: Green badge on left
- Status bar right: System load + time + date

### Plugins

**Location:** `~/.tmux.conf:112-123`

1. **tpm** - Tmux Plugin Manager
2. **tmux-sensible** - Sensible default settings
3. **tmux-yank** - Enhanced clipboard integration
4. **tmux-resurrect** - Save/restore tmux sessions
5. **tmux-continuum** - Auto-save sessions (restore on startup enabled)

---

## Sway Window Manager

### Sway

- **Version:** 1.10.1
- **Type:** i3-compatible Wayland compositor
- **Configuration File:** `~/.config/sway/config`

### Related Packages

| Package | Version | Description |
|---------|---------|-------------|
| sway | 1.10.1-2+rpt1 | Main compositor |
| swaybg | 1.2.1-1+b1 | Wallpaper utility |
| swayidle | 1.8.0-1+b1 | Idle management daemon |
| swaylock | 1.8.2-1+rpt4 | Screen locker |
| waybar | 0.12.0-1 | Status bar |
| foot | 1.21.0-2 | Terminal emulator |
| wmenu | 0.1.9-2+b1 | Application launcher |
| grim | 1.4.0+ds-2+b2 | Screenshot utility |

### Configuration Variables

**Location:** `~/.config/sway/config:7-19`

```
$mod = Mod4              # Super/Windows key
$term = foot             # Terminal emulator
$menu = wmenu-run        # Application launcher
$left/$down/$up/$right   # Vi-style navigation (h/j/k/l)
```

### Custom Settings

**Display Configuration** (`~/.config/sway/config:242`):
- `output HDMI-A-1 scale 2.0` - 2x scaling for HiDPI display

**Window Behavior** (`~/.config/sway/config:239-240`):
- `default_border pixel 3` - 3-pixel window borders
- `focus_follows_mouse no` - Focus on click, not mouse hover

### Autostart Applications

**Location:** `~/.config/sway/config:235-237`

```
exec waybar      # Status bar (installed)
exec mako        # Notification daemon (NOT installed)
exec nm-applet   # Network manager applet (NOT installed)
```

**Note:** mako and nm-applet are configured but not currently installed on the system.

### Key Bindings

#### Window Management

| Key Combination | Action |
|----------------|--------|
| `Mod+Return` | Launch terminal (foot) |
| `Mod+Shift+q` | Kill focused window |
| `Mod+d` | Launch application menu (wmenu) |
| `Mod+Shift+c` | Reload configuration |
| `Mod+Shift+e` | Exit Sway (with confirmation) |
| `Mod+Left Mouse` | Drag floating windows |
| `Mod+Right Mouse` | Resize windows |

#### Navigation

**Focus Windows:**
- `Mod+h/j/k/l` - Vi-style navigation (left/down/up/right)
- `Mod+Arrow Keys` - Arrow key navigation

**Move Windows:**
- `Mod+Shift+h/j/k/l` - Vi-style window movement
- `Mod+Shift+Arrow Keys` - Arrow key window movement

#### Workspaces

| Key Combination | Action |
|----------------|--------|
| `Mod+1` to `Mod+0` | Switch to workspace 1-10 |
| `Mod+Shift+1` to `Mod+Shift+0` | Move window to workspace 1-10 |

#### Layouts

| Key Combination | Action |
|----------------|--------|
| `Mod+b` | Split horizontally |
| `Mod+v` | Split vertically |
| `Mod+s` | Stacking layout |
| `Mod+w` | Tabbed layout |
| `Mod+e` | Toggle split layout |
| `Mod+f` | Fullscreen |
| `Mod+Shift+Space` | Toggle floating mode |
| `Mod+Space` | Toggle focus tiling/floating |
| `Mod+a` | Focus parent container |

#### Scratchpad

| Key Combination | Action |
|----------------|--------|
| `Mod+Shift+-` | Move window to scratchpad |
| `Mod+-` | Show/hide scratchpad |

#### Resize Mode

- `Mod+r` - Enter resize mode
- In resize mode:
  - `h/j/k/l` or Arrow Keys - Resize window
  - `Return` or `Escape` - Exit resize mode

#### Media & Utility Keys

**Volume Control** (`~/.config/sway/config:205-208`):
- `XF86AudioMute` - Toggle mute
- `XF86AudioLowerVolume` - Decrease volume 5%
- `XF86AudioRaiseVolume` - Increase volume 5%
- `XF86AudioMicMute` - Toggle microphone mute

**Brightness Control** (`~/.config/sway/config:210-211`):
- `XF86MonBrightnessDown` - Decrease brightness 5%
- `XF86MonBrightnessUp` - Increase brightness 5%

**Note:** Brightness controls require `brightnessctl` (NOT currently installed).

**Screenshots** (`~/.config/sway/config:213`):
- `Print` - Take screenshot with grim

### Foot Terminal

**Configuration File:** `~/.config/foot/foot.ini`

**Theme:** Gruvbox Dark (matching shell and tmux themes)

**Settings:**
- **Font:** IosevkaTerm Nerd Font, size 11
- **Foreground:** #ebdbb2
- **Background:** #282828

**Color Scheme** (`~/.config/foot/foot.ini:6-28`):
- Full Gruvbox dark palette with 16 colors
- Regular colors (0-7) and bright colors (8-15)
- Matches the Gruvbox theme used in Zsh and Tmux

### Status Bar

**Default Configuration** (`~/.config/sway/config:219-231`):
- **Position:** Top
- **Status Command:** Date and time (`date +'%Y-%m-%d %X'`)
- **Colors:**
  - Statusline: #ffffff
  - Background: #323232
  - Inactive workspace: Transparent with gray text (#5c5c5c)

**Note:** Waybar is configured to run on startup (line 235), which may override the default Sway bar.

### System Integration

**Included Configs:**
- `/etc/sway/config-vars.d/*` - System-wide variable definitions (none currently)
- `/etc/sway/config.d/*` - System-wide configuration snippets
  - `50-systemd-user.conf` - Systemd user session integration

### Missing Utilities

The following utilities are referenced in the configuration but not currently installed:
- `mako` - Notification daemon
- `nm-applet` - Network Manager applet (part of network-manager-gnome)
- `brightnessctl` - Brightness control utility

To install missing utilities:
```bash
sudo apt install mako-notifier network-manager-gnome brightnessctl
```

---

## Package Managers

### Homebrew

- **Version:** 4.6.17
- **Installation:** `/home/linuxbrew/.linuxbrew/`
- **Binary:** `/home/linuxbrew/.linuxbrew/bin/brew`
- **Initialized in:** `~/.zshrc:151` and `~/.bashrc:148`

#### Installed Packages

```
ca-certificates 2025-09-09
libevent 2.1.12_1
ncurses 6.5
openssl@3 3.6.0
tmux 3.5a
uniclip 2.3.6
utf8proc 2.11.0
```

**Key Packages:**
- **tmux** - Terminal multiplexer
- **uniclip** - Universal clipboard utility

### NVM (Node Version Manager)

- **Version:** 0.40.3
- **Installation:** `~/.nvm`
- **Configuration:** Lazy-loaded for faster shell startup

#### Lazy Loading Implementation

Located in both `~/.zshrc:115-145` and `~/.bashrc:115-145`:

```zsh
export NVM_DIR="$HOME/.nvm"

# Lazy load nvm - only load when needed
nvm() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  nvm "$@"
}

# Similar lazy loading for node, npm, npx...
```

This approach loads NVM only when first used, significantly improving shell startup time.

---

## Development Tools

### Version Control

- **Git:** 2.47.3
- **GitHub CLI (gh):** Configuration in `~/.config/gh/`

### Programming Languages

- **Python:** 3.13.5
- **Node.js:** Managed via NVM (lazy-loaded)

### Editors

- **Default Editor:** vim (configured but not installed)
- **Note:** vim is set as default in `EDITOR` and `VISUAL` variables but binary not found in PATH

### Claude Code

- **Version:** 2.0.22
- **Configuration:** `~/.claude.json` and `~/.claude/`
- **Global npm path:** `~/.npm-global/bin` (added to PATH in `~/.zshrc:148`)

### Other Tools

- **SSH:** Key pair present in `~/.ssh/` (id_ed25519)
- **1Password CLI:** Configuration in `~/.config/op/`

---

## Key Configuration Files

### Shell Configuration

| File | Purpose | Notes |
|------|---------|-------|
| `~/.zshrc` | Primary Zsh configuration | Main shell config, sources Oh My Zsh |
| `~/.bashrc` | Bash configuration | Fallback shell, similar config to zsh |
| `~/.oh-my-zsh/custom/aliases.zsh` | Custom shell aliases | Shared across sessions |
| `~/.zsh_history` | Zsh command history | 50k entries |
| `~/.bash_history` | Bash command history | 50k/100k entries |

### Tmux

| File/Directory | Purpose |
|----------------|---------|
| `~/.tmux.conf` | Tmux configuration |
| `~/.tmux/plugins/` | Tmux plugins (TPM managed) |

### Sway & Wayland

| File/Directory | Purpose |
|----------------|---------|
| `~/.config/sway/config` | Sway window manager configuration |
| `~/.config/foot/foot.ini` | Foot terminal configuration |
| `/etc/sway/config.d/` | System-wide Sway configuration snippets |

### Development

| File/Directory | Purpose |
|----------------|---------|
| `~/.nvm/` | Node Version Manager |
| `~/.npm/` | npm cache |
| `~/.config/gh/` | GitHub CLI configuration |
| `~/.ssh/` | SSH keys and configuration |
| `~/.claude.json` | Claude Code configuration |
| `~/.claude/` | Claude Code data directory |

---

## Quick Reference

### Adding New Tools

When installing new CLI tools or making configuration changes, update this document with:

1. **Package Managers:** Add to Homebrew, apt, or npm section
2. **Configuration Files:** Note location and purpose
3. **Environment Variables:** Add to Shell Environment section
4. **Aliases/Functions:** Add to `~/.oh-my-zsh/custom/aliases.zsh`
5. **Keybindings:** Update Tmux or Shell sections as needed

### Configuration Hierarchy

**Shell Startup Order (Zsh):**
1. `~/.zshrc` sources `$ZSH/oh-my-zsh.sh`
2. Oh My Zsh loads plugins
3. Oh My Zsh loads theme
4. Custom files in `~/.oh-my-zsh/custom/` are sourced
5. Homebrew environment is initialized
6. NVM lazy-load functions are defined

**Priority for Aliases:**
- Custom aliases in `~/.oh-my-zsh/custom/aliases.zsh` override plugin aliases
- Shell aliases override system commands

### Common Tasks

**Update System:**
```bash
update      # Runs: sudo apt update && sudo apt upgrade -y
cleanup     # Runs: sudo apt autoremove -y && sudo apt autoclean
```

**Tmux Sessions:**
```bash
tls         # List sessions
tn <name>   # New session
ta <name>   # Attach to session
tk <name>   # Kill session
```

**Sway Window Manager:**
```bash
# Launch Sway
sway

# Common keybindings (Mod = Super/Windows key)
Mod+Return           # Open terminal
Mod+d                # Open application launcher
Mod+Shift+q          # Close window
Mod+Shift+c          # Reload Sway config
Mod+1..0             # Switch to workspace 1-10
Mod+Shift+1..0       # Move window to workspace
Mod+f                # Toggle fullscreen
Mod+r                # Enter resize mode
Print                # Take screenshot
```

**Reload Configurations:**
```bash
source ~/.zshrc              # Reload zsh config
tmux source ~/.tmux.conf     # Reload tmux config (or Prefix + r)
swaymsg reload               # Reload Sway config (or Mod+Shift+c)
```

### PATH Modifications

Current PATH additions (in order):
1. `~/.npm-global/bin` - Global npm packages
2. Homebrew paths - Added by `brew shellenv`
3. Standard system paths

### Backup Strategy

Important files to backup when migrating or updating:
- `~/.zshrc`
- `~/.tmux.conf`
- `~/.oh-my-zsh/custom/`
- `~/.config/sway/config`
- `~/.config/foot/foot.ini`
- `~/.ssh/`
- `~/.claude.json`
- Homebrew package list: `brew list --versions > ~/brew-packages.txt`

---

## Notes

- **Theme Consistency:** Gruvbox Dark color scheme across shell, tmux, Sway, and foot terminal
- **Performance:** NVM lazy-loading implemented for faster shell startup
- **Safety:** Interactive prompts enabled for rm, cp, mv operations
- **Clipboard:** Tmux configured with cross-platform clipboard support (xclip for Linux)
- **History:** Extensive history (50k entries) with deduplication across sessions
- **Wayland:** Running Sway compositor on Wayland instead of X11

---

*This document serves as the central reference for system configuration. Update it when adding new tools, changing configurations, or modifying the development environment.*
