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
| zsh | `$HOME` | Zsh shell + oh-my-zsh customizations |

---

## Special Cases

### oh-my-zsh Custom Files (Manual Symlinks Required)

These files require **manual symlinks** because oh-my-zsh creates its own directory structure before stow runs, causing conflicts:

| Source (in repo) | Target |
|------------------|--------|
| `zsh/.oh-my-zsh/custom/aliases.zsh` | `~/.oh-my-zsh/custom/aliases.zsh` |
| `zsh/.oh-my-zsh/custom/themes/gruvbox.zsh-theme` | `~/.oh-my-zsh/custom/themes/gruvbox.zsh-theme` |

**To create these symlinks manually:**

```bash
# From the dotfiles directory
DOTFILES_DIR="$(pwd)"

ln -sf "$DOTFILES_DIR/zsh/.oh-my-zsh/custom/aliases.zsh" \
       ~/.oh-my-zsh/custom/aliases.zsh

ln -sf "$DOTFILES_DIR/zsh/.oh-my-zsh/custom/themes/gruvbox.zsh-theme" \
       ~/.oh-my-zsh/custom/themes/gruvbox.zsh-theme
```

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

### oh-my-zsh files not linked

These must be done manually (see Special Cases above), or run:

```bash
./scripts/check-symlinks.sh --fix
```
