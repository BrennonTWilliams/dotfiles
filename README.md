# Dotfiles

Personal configuration files for Linux/Unix development environments, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Quick Start

```bash
# Clone the repository
git clone https://github.com/BrennonTWilliams/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Run the installation script
./install.sh
```

## What's Inside

This repository contains configuration for:

- **Shell** - Zsh with Oh My Zsh, custom aliases, and Gruvbox theme
- **Terminal Multiplexer** - Tmux with custom keybindings and Gruvbox theme
- **Window Manager** - Sway (i3-compatible Wayland compositor)
- **Terminal Emulator** - Foot with Gruvbox color scheme
- **Development Tools** - Git, NVM, and various CLI utilities

### Package Structure

```
dotfiles/
├── zsh/              # Zsh shell configuration
├── bash/             # Bash shell configuration (fallback)
├── tmux/             # Tmux configuration
├── sway/             # Sway window manager
├── foot/             # Foot terminal emulator
└── scripts/          # Installation helper scripts
```

## Features

### Unified Gruvbox Theme

All components use the Gruvbox Dark color scheme for a consistent visual experience:
- Shell prompt
- Tmux status bar
- Terminal emulator
- Window manager

### Smart Configuration

- **Machine-specific overrides** - Use `*.local` files for machine-specific settings
- **NVM lazy-loading** - Fast shell startup with on-demand Node.js loading
- **Cross-platform clipboard** - Works with both X11 (xclip) and macOS (pbcopy)
- **Vi-mode keybindings** - Consistent navigation across tmux and shell

### Security

- Comprehensive `.gitignore` to prevent credential leakage
- No secrets committed to version control
- Local override files for sensitive configuration

## Requirements

### Essential

- `git` - Version control
- `stow` - Symlink management
- `zsh` - Shell (optional, bash configs also included)
- `tmux` - Terminal multiplexer

### Optional

- `sway` - Wayland compositor
- `foot` - Terminal emulator
- `nvm` - Node.js version manager
- Oh My Zsh plugins (installed via setup script)

## Installation

### Full Installation

Install all configurations interactively:

```bash
cd ~/.dotfiles
./install.sh
```

### Selective Installation

Install specific components only:

```bash
./install.sh zsh tmux    # Install only zsh and tmux configs
./install.sh --all       # Install all non-interactively
```

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

## Troubleshooting

### Stow Conflicts

If stow reports conflicts with existing files:

```bash
# Backup the conflicting file
mv ~/.zshrc ~/.zshrc.backup

# Try stowing again
stow -R zsh
```

### Symlinks Not Working

Verify symlinks are created correctly:

```bash
ls -la ~/  | grep '\->'
```

You should see symlinks pointing to `~/.dotfiles/`.

### Shell Not Loading Config

Ensure your shell sources the configuration:

```bash
# For zsh
exec zsh

# For bash
exec bash
```

## Documentation

For detailed system setup documentation, see [SYSTEM_SETUP.md](SYSTEM_SETUP.md).

## Backup

Important: Your original dotfiles are automatically backed up during installation to:

```
~/.dotfiles_backup_YYYYMMDD_HHMMSS/
```

## Package List

The `packages.txt` file contains a manifest of all system packages used in this setup. Install them with:

```bash
# Debian/Ubuntu
xargs -a packages.txt sudo apt install -y

# Fedora/RHEL
xargs -a packages.txt sudo dnf install -y

# macOS
xargs -a packages.txt brew install
```

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
