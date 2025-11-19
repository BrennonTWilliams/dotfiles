# Frequently Asked Questions

## Installation

### What are the system requirements?

- **macOS**: 12.0+ (Intel or Apple Silicon)
- **Linux**: Any modern distribution with bash/zsh
- **Dependencies**: Git, GNU Stow, curl

### How do I install everything?

```bash
git clone https://github.com/BrennonTWilliams/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install-new.sh --all --packages
```

### Can I install just specific components?

Yes, use GNU Stow to install individual modules:

```bash
cd ~/dotfiles
stow zsh        # Just zsh configuration
stow tmux       # Just tmux configuration
stow starship   # Just starship prompt
```

### Will this overwrite my existing dotfiles?

The installer creates backups before making changes. Your existing files are saved to `~/.dotfiles-backup/` with timestamps.

### How do I uninstall?

```bash
cd ~/dotfiles
stow -D zsh tmux git  # Remove specific modules
# Or unstow all modules
```

Your original files remain in `~/.dotfiles-backup/`.

## Compatibility

### Does this work on Linux?

Yes! The configuration supports both macOS and Linux with automatic platform detection. Linux-specific features include:

- Foot terminal (Wayland)
- Sway window manager
- xclip for clipboard

### Does this work on Windows/WSL?

Basic functionality works in WSL2, but it's not fully tested. The zsh and git configurations should work fine.

### Which shells are supported?

- **Primary**: Zsh (recommended)
- **Fallback**: Bash (for compatibility)

### Do I need Oh My Zsh?

Yes, the zsh configuration uses Oh My Zsh for plugin management. The installer will set it up automatically.

## Customization

### How do I add machine-specific settings?

Create `.local` files that won't be tracked by git:

```bash
~/.zshrc.local        # Machine-specific zsh settings
~/.gitconfig.local    # Machine-specific git settings
~/.tmux.conf.local    # Machine-specific tmux settings
```

### How do I change the color theme?

The configuration uses Gruvbox Dark. To modify colors:

1. **Starship prompt**: Edit files in `starship/modules/`
2. **Tmux**: Edit theme section in `tmux/.tmux.conf`
3. **Ghostty**: Edit `ghostty/.config/ghostty/config`
4. **Foot**: Edit `foot/.config/foot/foot.ini`

### How do I change the font?

Update the font in your terminal configuration:

- **Ghostty**: `ghostty/.config/ghostty/config` line ~10
- **Foot**: `foot/.config/foot/foot.ini`

The default is IosevkaTerm Nerd Font.

### How do I switch Starship prompt modes?

```bash
starship-compact   # Minimal single-line prompt
starship-standard  # Default multi-line prompt
starship-verbose   # Full details for debugging
```

## Troubleshooting

### Fonts/icons look wrong

Install a Nerd Font:

```bash
# macOS
brew install --cask font-iosevka-term-nerd-font

# Linux (Arch)
yay -S ttf-iosevkaterm-nerd
```

Then set it as your terminal font.

### Colors look wrong in tmux

Ensure your terminal supports true color:

```bash
# Add to .zshrc
export TERM="xterm-256color"
```

### Starship prompt is slow

Check which modules are slow:

```bash
starship timings
```

Common causes:
- Large git repositories
- Network-dependent modules
- Many language version checks

### Clipboard not working in tmux

**macOS**: Should work automatically with pbcopy/pbpaste

**Linux**: Install xclip:
```bash
sudo apt install xclip
```

### "Command not found" errors

1. Restart your shell or run `source ~/.zshrc`
2. Check PATH: `echo $PATH`
3. Verify the tool is installed

### Git shows wrong user

Set your identity:

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

Or create `~/.gitconfig.local`:

```ini
[user]
    name = Your Name
    email = your@email.com
```

## Updates & Maintenance

### How do I update my dotfiles?

```bash
cd ~/dotfiles
git pull
./install-new.sh --all  # Re-run installer if needed
```

### How do I update to a new version?

```bash
cd ~/dotfiles
git fetch --tags
git checkout v1.1.0  # Or latest version
```

### How do I contribute changes back?

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full guide. Quick version:

1. Fork the repository
2. Create a feature branch
3. Make changes and test
4. Submit a pull request

### How do I report a bug?

Open an issue using the bug report template:
https://github.com/BrennonTWilliams/dotfiles/issues/new?template=bug_report.md

Include:
- OS and version
- Steps to reproduce
- Expected vs actual behavior
- Error messages

## Features

### What's included?

- **Shell**: Zsh with Oh My Zsh, custom aliases, cross-platform utilities
- **Prompt**: Starship with Gruvbox theme and multiple modes
- **Terminal**: Ghostty (macOS), Foot (Linux)
- **Multiplexer**: Tmux with plugins and vim keybindings
- **Git**: Aliases, delta diff viewer, sensible defaults
- **Editor**: Neovim configuration (basic)

### What package managers are supported?

- **macOS**: Homebrew
- **Debian/Ubuntu**: apt
- **Fedora**: dnf
- **Arch**: pacman

### Does this include Neovim configuration?

A basic Neovim configuration is included. For a full IDE setup, consider using a Neovim distribution like LazyVim or AstroNvim.

### What about secrets management?

The `.gitignore` excludes sensitive files. For secrets:

1. Use `.local` files for machine-specific configs
2. Use environment variables
3. Consider 1Password CLI integration (documented in usage guide)

## Getting More Help

- [Troubleshooting Guide](TROUBLESHOOTING.md)
- [GitHub Discussions](https://github.com/BrennonTWilliams/dotfiles/discussions)
- [GitHub Issues](https://github.com/BrennonTWilliams/dotfiles/issues)
