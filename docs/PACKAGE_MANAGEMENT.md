# Package Management

This document explains the package manifest files in this dotfiles repository and how to use them for system setup.

## Package Files Overview

| File | Platform | Purpose |
|------|----------|---------|
| `packages-linux.txt` | Linux | Core packages for Linux development environment |
| `packages-macos.txt` | macOS | Core packages for macOS development environment |
| `packages-macos-reference.txt` | macOS | Hotkey-safe packages for shared/reference Macs |

## packages-linux.txt

**Purpose:** Complete Linux development environment setup

This file lists all packages required for a full Linux development environment with Sway window manager. Use it on personal Linux workstations.

### Package Categories

- **Core System Tools** - git, curl, wget, stow, htop, tmux, zsh, starship
- **Sway Window Manager** - sway, swaybg, swayidle, swaylock, waybar, foot
- **Wayland Utilities** - wmenu, grim, mako-notifier, brightnessctl
- **Development Tools** - python3, python3-pip, build-essential
- **CLI Utilities** - xclip, ripgrep, fd-find, fzf, tree, unzip, jq

### Installation

```bash
# Debian/Ubuntu
xargs -a packages-linux.txt sudo apt install -y

# Fedora/RHEL
xargs -a packages-linux.txt sudo dnf install -y

# Arch Linux
xargs -a packages-linux.txt sudo pacman -S --noconfirm
```

## packages-macos.txt

**Purpose:** Complete macOS development environment setup

This file lists all Homebrew packages for a full macOS development environment. It provides macOS alternatives for Linux tools where applicable.

### Package Categories

- **Core System Tools** - git, curl, wget, stow, htop, tmux, zsh, starship
- **macOS Window Management** - rectangle (alternative to Sway)
- **Terminal Emulator** - ghostty (alternative to foot)
- **Status Bar** - sketchybar (alternative to Waybar)
- **Development Tools** - python3, neovim
- **CLI Utilities** - ripgrep, fd, fzf, tree, unzip, jq, mas

### Special Handling

**sketchybar** requires a custom tap:

```bash
brew tap FelixKratz/formulae
brew install sketchybar
```

### Installation

```bash
# Install all packages except sketchybar
brew install $(cat packages-macos.txt | grep -v '^#' | grep -v 'sketchybar')

# Then install sketchybar separately
brew tap FelixKratz/formulae && brew install sketchybar
```

Or use the installation script which handles this automatically:

```bash
./install-new.sh --packages
```

## packages-macos-reference.txt

**Purpose:** Hotkey-safe packages for shared or reference Mac systems

This subset of packages is designed for Macs that need to preserve system hotkeys and avoid conflicts with existing workflows. It excludes packages that:

- Register system-wide hotkeys (rectangle, sketchybar)
- Modify keyboard behavior
- May conflict with corporate or shared environment settings

### Use Cases

- Corporate or managed Macs
- Shared development machines
- Systems where you need to preserve default hotkey behavior
- Reference/demo systems

### Included Packages

- **Core Tools** - git, curl, wget, stow, htop, tmux, zsh, starship
- **Development** - python3, ghostty
- **Utilities** - ripgrep, fd, fzf, tree, unzip, jq, mas

### Excluded Packages (and Reasons)

- **rectangle** - Registers system-wide window management hotkeys
- **sketchybar** - Status bar that may conflict with default menu bar
- **neovim/vim** - May have custom keybindings (install manually if needed)

### Installation

```bash
# Use the --reference-mac flag
./install.sh --all --reference-mac
```

Or manually:

```bash
brew install $(cat packages-macos-reference.txt | grep -v '^#')
```

## Customization

### Adding Packages

1. Edit the appropriate package file
2. Add the package name on a new line
3. Include comments for optional packages using `#`

### Local Overrides

Create a local package file that won't be tracked in git:

```bash
# Create local additions file
echo "mypackage" > packages-local.txt
echo "*.local" >> .gitignore
```

## NPM Global Packages

For NPM global packages, see `npm/global-packages.txt` and the [npm/README.md](../npm/README.md).

## Best Practices

1. **Keep packages organized by category** with clear section headers
2. **Document optional packages** with comments explaining when to use them
3. **Test installations** on clean systems periodically
4. **Version pin** critical packages when stability is important
5. **Review packages** quarterly to remove unused tools

## Related Documentation

- [SYSTEM_SETUP.md](SYSTEM_SETUP.md) - Complete system setup guide
- [MACOS_SETUP.md](MACOS_SETUP.md) - macOS-specific setup instructions
- [npm/README.md](../npm/README.md) - NPM global package management
