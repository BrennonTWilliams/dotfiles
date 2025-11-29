# System Requirements

Detailed requirements, dependencies, and package lists for the dotfiles installation.

---

## Table of Contents

- [Supported Platforms](#supported-platforms)
- [Required Dependencies](#required-dependencies)
- [Optional Dependencies](#optional-dependencies)
- [Package Lists](#package-lists)
- [Version Requirements](#version-requirements)
- [Disk Space Requirements](#disk-space-requirements)

---

## Supported Platforms

### macOS

| Version | Architecture | Status |
|---------|-------------|--------|
| macOS 15 (Sequoia) | Apple Silicon | Fully Supported |
| macOS 14 (Sonoma) | Apple Silicon / Intel | Fully Supported |
| macOS 13 (Ventura) | Apple Silicon / Intel | Fully Supported |
| macOS 12 (Monterey) | Apple Silicon / Intel | Supported |
| macOS 11 (Big Sur) | Apple Silicon / Intel | Limited Support |

**Apple Silicon Notes:**
- Homebrew installs to `/opt/homebrew`
- Rosetta 2 not required for dotfiles
- Native ARM64 packages preferred

**Intel Notes:**
- Homebrew installs to `/usr/local`
- Full compatibility maintained

### Linux

| Distribution | Versions | Status |
|--------------|----------|--------|
| Ubuntu | 22.04 LTS, 24.04 LTS | Fully Supported |
| Debian | 11 (Bullseye), 12 (Bookworm) | Fully Supported |
| Fedora | 38, 39, 40 | Fully Supported |
| Arch Linux | Rolling | Fully Supported |
| Linux Mint | 21.x | Supported |
| Pop!_OS | 22.04 | Supported |

**Desktop Environment Support:**
- Sway (Wayland) - Optimized
- GNOME - Compatible
- KDE - Compatible
- i3 (X11) - Compatible

---

## Required Dependencies

These must be installed before running the dotfiles installer.

### Core Tools

| Tool | Purpose | macOS Install | Linux Install |
|------|---------|---------------|---------------|
| `git` | Version control | `brew install git` | `apt install git` |
| `curl` | Downloads | Pre-installed | `apt install curl` |
| `stow` | Symlink manager | `brew install stow` | `apt install stow` |

### Package Manager

**macOS:** Homebrew (required)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Linux:** System package manager (apt, dnf, pacman, etc.)

### Shell

| Shell | Minimum Version | Notes |
|-------|-----------------|-------|
| Zsh | 5.8+ | Recommended default shell |
| Bash | 4.0+ | For installation scripts |

---

## Optional Dependencies

Enhance the experience but not required for basic functionality.

### Recommended Tools

| Tool | Purpose | Install |
|------|---------|---------|
| `delta` | Beautiful git diffs | `brew install git-delta` |
| `fzf` | Fuzzy finder | `brew install fzf` |
| `ripgrep` | Fast search | `brew install ripgrep` |
| `fd` | Fast find | `brew install fd` |
| `bat` | Better cat | `brew install bat` |
| `eza` | Better ls | `brew install eza` |

### Development Tools

| Tool | Purpose | Install |
|------|---------|---------|
| `neovim` | Text editor | `brew install neovim` |
| `tmux` | Terminal multiplexer | `brew install tmux` |
| `starship` | Cross-shell prompt | `brew install starship` |
| `jq` | JSON processor | `brew install jq` |

### Terminal Emulators

| Platform | Terminal | Install |
|----------|----------|---------|
| macOS | Ghostty | `brew install --cask ghostty` |
| Linux | Foot | `apt install foot` |

---

## Package Lists

### macOS Packages (`packages-macos.txt`)

**Core Tools:**
- git, curl, wget, stow
- zsh, starship
- tmux, neovim

**Development:**
- python3, node (via nvm)
- ripgrep, fd, fzf
- jq, yq, tree

**macOS Specific:**
- ghostty (terminal)
- rectangle (window management)
- sketchybar (status bar)

**Fonts:**
- font-meslo-lg-nerd-font
- font-fira-code-nerd-font

### Linux Packages (`packages-linux.txt`)

**Core Tools:**
- git, curl, wget, stow
- zsh, starship
- tmux, neovim

**Development:**
- python3, python3-pip
- build-essential
- ripgrep, fd-find, fzf

**Sway/Wayland:**
- sway (window manager)
- waybar (status bar)
- foot (terminal)
- wmenu (launcher)
- grim, slurp (screenshots)

**Clipboard:**
- wl-clipboard (Wayland)
- xclip (X11 fallback)

---

## Version Requirements

### Minimum Versions

| Tool | Minimum | Recommended | Check Command |
|------|---------|-------------|---------------|
| Git | 2.30+ | 2.40+ | `git --version` |
| Zsh | 5.8+ | 5.9+ | `zsh --version` |
| Stow | 2.3+ | 2.3.1+ | `stow --version` |
| Tmux | 3.0+ | 3.3+ | `tmux -V` |
| Neovim | 0.8+ | 0.9+ | `nvim --version` |
| Starship | 1.0+ | 1.17+ | `starship --version` |

### Homebrew Version

```bash
brew --version  # Should be 4.0+
```

### Node.js (via NVM)

| Version | Status |
|---------|--------|
| Node 20 LTS | Recommended |
| Node 18 LTS | Supported |
| Node 16 | End of Life |

---

## Disk Space Requirements

### Minimum Requirements

| Component | Space Required |
|-----------|----------------|
| Dotfiles repository | ~50 MB |
| System packages | ~500 MB - 1 GB |
| Development tools | ~1-2 GB |
| **Total minimum** | **~2 GB** |

### Recommended Free Space

- **5 GB+** for comfortable installation
- Additional space for:
  - Node modules (~2-5 GB typical)
  - Python virtual environments
  - Docker images
  - Editor plugins

### Check Available Space

**macOS:**
```bash
df -h /
```

**Linux:**
```bash
df -h ~
```

---

## Network Requirements

### During Installation

- Active internet connection required
- Access to:
  - GitHub (repository clone)
  - Homebrew (macOS packages)
  - Distribution mirrors (Linux packages)
  - npm registry (global packages)

### Firewall Considerations

Ensure access to:
- `github.com` (port 443)
- `raw.githubusercontent.com` (port 443)
- `brew.sh` / `formulae.brew.sh` (port 443)
- `registry.npmjs.org` (port 443)

---

## Verification

### Pre-Installation Check

```bash
./install.sh --check-deps
```

### Manual Verification

```bash
# Check core tools
git --version
curl --version
which stow

# Check package manager
which brew  # macOS
which apt   # Debian/Ubuntu

# Check shell
echo $SHELL
zsh --version

# Check disk space
df -h ~
```

---

## Troubleshooting Requirements

### Missing Homebrew (macOS)

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add to PATH (Apple Silicon)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### Missing Stow

```bash
# macOS
brew install stow

# Ubuntu/Debian
sudo apt install stow

# Fedora
sudo dnf install stow

# Arch
sudo pacman -S stow
```

### Outdated Git

```bash
# macOS
brew upgrade git

# Ubuntu/Debian
sudo apt update && sudo apt upgrade git
```

### Zsh Not Default Shell

```bash
# Set Zsh as default
chsh -s $(which zsh)

# Verify
echo $SHELL
```

---

## See Also

- [GETTING_STARTED.md](GETTING_STARTED.md) - Installation guide
- [INSTALLATION_OPTIONS.md](INSTALLATION_OPTIONS.md) - Detailed installation options
- [../TROUBLESHOOTING.md](../TROUBLESHOOTING.md) - Common issues and solutions
