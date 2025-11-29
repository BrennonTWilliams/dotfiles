# Symlink Reference

Reference for the dotfiles symlink structure managed by GNU Stow.

---

## How It Works

This repository uses [GNU Stow](https://www.gnu.org/software/stow/) for symlink management:

- Each top-level directory is a "package" that can be installed independently
- Stow creates symlinks from `$HOME` (or a custom target) pointing to files in this repo
- Changes to files in the repo are immediately reflected in the linked locations

---

## Package Summary

| Package | Target | Description |
|---------|--------|-------------|
| bash | `$HOME` | Bash shell dotfiles (.bashrc, .bash_profile, etc.) |
| brenentech | `$HOME/.config/brenentech` | BRENENTECH branding utilities |
| foot | `$HOME/.config/foot` | Foot terminal emulator (Linux) |
| ghostty | `$HOME/.config/ghostty` | Ghostty terminal emulator (macOS) |
| git | `$HOME` | Git configuration (.gitconfig, .gitignore) |
| linux | `$HOME/.config/systemd/user` | Linux systemd services |
| macos | `$HOME/Library/LaunchAgents` | macOS LaunchAgent services |
| neovim | `$HOME/.config/nvim` | Neovim editor configuration |
| npm | `$HOME` | NPM configuration (.npmrc) |
| obsidian | `$HOME/obsidian` | Obsidian vault snippets |
| starship | `$HOME/.config/starship` | Starship prompt (multi-mode) |
| sway | `$HOME/.config/sway` | Sway window manager (Linux) |
| tmux | `$HOME` | Tmux multiplexer (.tmux.conf) |
| vscode | `$HOME/.vscode` | VS Code settings (custom target) |
| zsh | `$HOME` | Zsh shell + modular config (functions, aliases, abbreviations) |

---

## Zsh Modular Structure

The zsh package includes a modular configuration system:

```
zsh/
├── .zshrc                    # Main config (loads modules based on DOTFILES_ABBR_MODE)
├── .zshenv                   # Environment variables
├── .zprofile                 # Login shell config
├── functions/                # Shell functions (always loaded)
│   ├── _init.zsh             # Loader script
│   ├── navigation.zsh        # mkcd, qfind
│   ├── neovim.zsh            # nvim-keys
│   └── macos.zsh             # cpu-temp, wifi-scan, ql, airport (macOS only)
├── aliases/                  # Traditional aliases
│   ├── _init.zsh             # Loader (loads safety.zsh only)
│   ├── safety.zsh            # rm -i, cp -i, mv -i (always loaded)
│   └── extras.zsh            # Fallback aliases (loaded in alias mode only)
└── abbreviations/            # zsh-abbr abbreviations (loaded in abbr mode, the default)
    ├── _init.zsh             # Loader + zsh-abbr detection
    ├── git.zsh               # gs, ga, gc, gp, gl, gd, gco, gb
    ├── navigation.zsh        # .., ..., ....
    ├── tmux.zsh              # tls, ta, tn, tk
    └── ...
```

### Module Loading

Controlled via `DOTFILES_ABBR_MODE` environment variable:

| Mode | Functions | Safety Aliases | Extra Aliases | Abbreviations |
|------|-----------|----------------|---------------|---------------|
| `abbr` (default) | Yes | Yes | No | Yes |
| `alias` | Yes | Yes | Yes | No |

---

## Special Cases

### Custom .stowrc Targets

Some packages use `.stowrc` files to specify non-default target directories:

| Package | Target | Reason |
|---------|--------|--------|
| vscode | `$HOME/.vscode` | VS Code stores config in a subdirectory |
| git | `$HOME` | Explicit declaration (for documentation) |

---

## Verification

Run the symlink health check to verify all expected symlinks are in place:

```bash
./scripts/check-symlinks.sh
```

Or check individual files manually:

```bash
# Check if a file is a symlink
ls -la ~/.zshrc

# Should show something like:
# lrwxr-xr-x  .zshrc -> dotfiles/zsh/.zshrc
```

---

## Common Commands

```bash
# Install all packages
cd ~/path/to/dotfiles
stow */

# Install a specific package
stow zsh

# Re-apply symlinks after changes
stow --restow */

# Preview changes without applying
stow -n -v zsh

# Remove symlinks for a package
stow -D zsh
```

---

## Troubleshooting

### "Existing target is not owned by stow"

This happens when a real file exists where stow wants to create a symlink:

```bash
# Back up the existing file
mv ~/.zshrc ~/.zshrc.backup

# Then stow the package
stow zsh
```

### Symlink points to wrong location

Re-stow the package to fix:

```bash
stow --restow zsh
```
