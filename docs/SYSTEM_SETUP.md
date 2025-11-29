# System Setup Documentation

**Last Updated:** 2025-10-19
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
7. [Clipboard Sharing](#clipboard-sharing)
8. [Key Configuration Files](#key-configuration-files)
9. [Quick Reference](#quick-reference)

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
- **Prompt:** Starship (cross-shell prompt)
- **Abbreviations:** zsh-abbr (Fish-style abbreviations)
- **Configuration File:** `~/.zshrc`

#### Prompt (Starship)

Starship provides a fast, customizable prompt with Gruvbox theme.

- **Configuration:** `~/.config/starship/starship.toml`
- **Modes:** compact, standard, verbose (switch with `starship-compact`, `starship-standard`, `starship-verbose`)

#### Abbreviations (zsh-abbr)

Unlike aliases, abbreviations expand to their full command when you press Space or Enter.

**Location:** `zsh/abbreviations/`

| File | Contents |
|------|----------|
| `git.zsh` | gs, ga, gc, gp, gl, gd, gco, gb |
| `navigation.zsh` | .., ..., ...., ..... |
| `tmux.zsh` | tls, ta, tn, tk |
| `development.zsh` | serve, ports, cc |
| `macos.zsh` | macOS-specific abbreviations |
| `system.zsh` | General system shortcuts |

**Mode Toggle:** Set `DOTFILES_ABBR_MODE` in `~/.zshenv.local`:
- `abbr` (default) - zsh-abbr abbreviations
- `alias` - Traditional aliases (fallback)

#### Modular Structure

```
zsh/
├── .zshrc              # Main configuration
├── .zshenv             # Environment variables
├── functions/          # Shell functions (always loaded)
│   ├── navigation.zsh  # mkcd, qfind
│   ├── neovim.zsh      # nvim-keys
│   └── macos.zsh       # macOS-specific functions
├── aliases/            # Traditional aliases
│   ├── safety.zsh      # rm -i, cp -i, mv -i (always loaded)
│   └── extras.zsh      # Fallback for alias mode
└── abbreviations/      # zsh-abbr abbreviations (default)
    ├── git.zsh
    ├── navigation.zsh
    ├── tmux.zsh
    └── ...
```

#### Custom Functions

```zsh
mkcd() {          # Create and enter directory
  mkdir -p "$1" && cd "$1"
}

qfind() {         # Quick find
  find . -name "*$1*"
}
```

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

## Clipboard Sharing

### Uniclip

- **Version:** 2.3.6 (via Homebrew)
- **Purpose:** Universal clipboard sync between Raspberry Pi and Mac Mini M4
- **Service:** Systemd user service (auto-start on boot)
- **Service File:** `~/.config/systemd/user/uniclip.service`

#### Configuration

**Raspberry Pi Setup:**
- **Service Status:** Enabled and running
- **Address:** Dynamic (port may change on restart)
- **Wayland Support:** Uses `wl-clipboard` (wl-copy/wl-paste)
- **Configuration:** Set `UNICLIP_SERVER` environment variable with Pi's address (e.g., `192.168.1.x:port`)

**Mac Mini M4 Setup:**
- **Installation:** `brew install uniclip`
- **Shell Alias:** Added to Mac's `~/.zshrc` or `~/.bashrc`
- **Usage:** Run alias to connect to Pi's clipboard

#### System Integration

**Dependencies:**
- `wl-clipboard` (2.2.1-2) - Wayland clipboard utilities for Sway
- `uniclip` (2.3.6) - Universal clipboard sync tool

**Systemd Service Configuration:**
```
[Unit]
Description=Uniclip Universal Clipboard Service
After=graphical-session.target

[Service]
Type=simple
Environment="WAYLAND_DISPLAY=wayland-1"
ExecStart=/home/linuxbrew/.linuxbrew/bin/uniclip
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
```

#### Usage

**Check Service Status:**
```bash
systemctl --user status uniclip
```

**View Current Connection Address:**
```bash
journalctl --user -u uniclip -n 5 --no-pager | grep "Run"
```

**Restart Service:**
```bash
systemctl --user restart uniclip
```

**View Service Logs:**
```bash
journalctl --user -u uniclip -f
```

#### How It Works

1. **Pi:** Uniclip runs as systemd service, creates clipboard server
2. **Mac:** Set `UNICLIP_SERVER` environment variable and use `clipboard-sync` alias
3. **Sync:** Copy on one device, paste on the other automatically
4. **Auto-start:** Pi service starts on boot, Mac uses shell alias for manual connection

#### Environment Configuration

**Setting UNICLIP_SERVER:**

To avoid hardcoding the server address in configuration files, set the `UNICLIP_SERVER` environment variable:

1. **In `~/.zshenv` (recommended for all sessions):**
   ```bash
   export UNICLIP_SERVER="192.168.1.x:port"
   ```

2. **In `~/.zshrc.local` (for machine-specific config):**
   ```bash
   export UNICLIP_SERVER="192.168.1.x:port"
   ```

3. **Get current address from Pi logs:**
   ```bash
   journalctl --user -u uniclip -n 5 --no-pager | grep "Run"
   ```

The `clipboard-sync` alias will use `$UNICLIP_SERVER` if set, or fall back to `localhost:53168` if not configured.

#### Troubleshooting

**If clipboard sync stops working:**
1. Check Pi service: `systemctl --user status uniclip`
2. Get current address: `journalctl --user -u uniclip -n 5 | grep "Run"`
3. Reconnect Mac with updated address
4. Ensure both devices are on same network (192.168.1.x)

**Note:** Port number changes when uniclip service restarts. If connection fails, check logs for current address.

---

## Key Configuration Files

### Shell Configuration

| File | Purpose | Notes |
|------|---------|-------|
| `~/.zshrc` | Primary Zsh configuration | Loads Starship, zsh-abbr, modular config |
| `~/.zshenv` | Environment variables | PATH, EDITOR, etc. |
| `~/.bashrc` | Bash configuration | Fallback shell |
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

### Clipboard Sharing

| File/Directory | Purpose |
|----------------|---------|
| `~/.config/systemd/user/uniclip.service` | Uniclip systemd service configuration |

---

## Quick Reference

### Adding New Tools

When installing new CLI tools or making configuration changes, update this document with:

1. **Package Managers:** Add to Homebrew, apt, or npm section
2. **Configuration Files:** Note location and purpose
3. **Environment Variables:** Add to Shell Environment section
4. **Abbreviations:** Add to `zsh/abbreviations/*.zsh`
5. **Functions:** Add to `zsh/functions/*.zsh`
6. **Keybindings:** Update Tmux or Shell sections as needed

### Configuration Hierarchy

**Shell Startup Order (Zsh):**
1. `~/.zshenv` sets environment variables
2. `~/.zshrc` loads modular configuration:
   - Safety aliases (always)
   - Functions (always)
   - Abbreviations OR aliases (based on `DOTFILES_ABBR_MODE`)
3. Starship prompt initialized
4. Homebrew environment initialized
5. Lazy-load functions defined (conda, z, etc.)

**Priority for Shortcuts:**
- Abbreviations expand on Space/Enter (show full command in history)
- Safety aliases (rm -i, cp -i) are always loaded
- Shell shortcuts override system commands

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

**Clipboard Sharing:**
```bash
systemctl --user status uniclip                  # Check uniclip service status
systemctl --user restart uniclip                 # Restart uniclip service
journalctl --user -u uniclip -n 5 | grep "Run"   # Get current connection address
```

### PATH Modifications

Current PATH additions (in order):
1. `~/.npm-global/bin` - Global npm packages
2. Homebrew paths - Added by `brew shellenv`
3. Standard system paths

### Backup Strategy

Important files to backup when migrating or updating:
- `~/.zshrc`
- `~/.zshenv`
- `~/.tmux.conf`
- `~/.config/starship/`
- `~/.config/sway/config`
- `~/.config/foot/foot.ini`
- `~/.config/systemd/user/uniclip.service`
- `~/.ssh/`
- `~/.claude.json`
- Homebrew package list: `brew list --versions > ~/brew-packages.txt`

---

## Notes

- **Theme Consistency:** Gruvbox Dark color scheme across shell, tmux, Sway, and foot terminal
- **Performance:** NVM lazy-loading implemented for faster shell startup
- **Safety:** Interactive prompts enabled for rm, cp, mv operations
- **Clipboard:**
  - Tmux configured with cross-platform clipboard support (wl-clipboard for Wayland)
  - Uniclip provides universal clipboard sync with Mac Mini M4
- **History:** Extensive history (50k entries) with deduplication across sessions
- **Wayland:** Running Sway compositor on Wayland instead of X11

---

*This document serves as the central reference for system configuration. Update it when adding new tools, changing configurations, or modifying the development environment.*
