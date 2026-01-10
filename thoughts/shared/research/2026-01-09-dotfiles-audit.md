---
date: 2026-01-10T05:47:10Z
researcher: Claude
git_commit: 187504e
branch: main
hostname: BRENNONs-Mac-mini.local
platform: Darwin
topic: "Dotfiles Comprehensive Audit"
tags: [dotfiles, sync, audit, configuration, symlinks, packages]
status: complete
last_updated: 2026-01-09
---

# Dotfiles Comprehensive Audit Report

**Date**: 2026-01-09
**Machine**: BRENNONs-Mac-mini.local
**Platform**: Darwin (macOS)
**Dotfiles Commit**: 187504e
**Dotfiles Path**: `/Users/brennon/AIProjects/ai-workspaces/dotfiles`

---

## Executive Summary

| Category | Status | Issues Found | Priority |
|----------|--------|--------------|----------|
| Symlink Integrity | 12/16 OK | 4 issues | HIGH |
| Shell Configs | Functional | 3 issues | MEDIUM |
| Git/Tmux | Functional | 0 issues | - |
| Neovim | Synced | 1 uncommitted | LOW |
| Ghostty/Starship | Mostly OK | 2 issues | MEDIUM |
| Other Configs | Mixed | VS Code drift | LOW |
| Brew Formulae | 79/92 | 13 missing | MEDIUM |
| Brew Casks | 12/12 OK | 0 issues | - |
| MAS Apps | 8/8 OK | 0 issues | - |
| VS Code Extensions | 45/45 OK | 0 issues | - |
| CLI Tools | 18/18 OK | 0 issues | - |

**Overall Status**: Mostly synced with several symlink and package gaps requiring attention.

---

## 1. Symlink Integrity

### Critical Issues (3)

| File | Current State | Expected State | Action |
|------|---------------|----------------|--------|
| `~/.zprofile` | Regular FILE | Symlink to `zsh/.zprofile` | Re-stow zsh |
| `~/.config/ghostty/config` | Regular FILE | Symlink to `ghostty/.config/ghostty/config` | Re-stow ghostty |
| `~/.config/starship/starship.toml` | STALE symlink | Should not exist | Remove |

### Warning: Mixed Path Types

Most symlinks use **relative paths**, but 3 use **absolute paths**:
- `~/.zsh_cross_platform` (absolute)
- `~/.gitignore` (absolute)
- `~/.config/nvim` (absolute)

This inconsistency is functional but could cause confusion.

### Working Symlinks (12/16)

```
~/.zshrc           -> dotfiles/zsh/.zshrc
~/.zshenv          -> dotfiles/zsh/.zshenv
~/.zsh_cross_platform -> /Users/brennon/.../zsh/.zsh_cross_platform
~/.bashrc          -> dotfiles/bash/.bashrc
~/.bash_profile    -> dotfiles/bash/.bash_profile
~/.bash_logout     -> dotfiles/bash/.bash_logout
~/.profile         -> dotfiles/bash/.profile
~/.gitconfig       -> dotfiles/git/.gitconfig
~/.gitignore       -> /Users/brennon/.../git/.gitignore
~/.tmux.conf       -> dotfiles/tmux/.tmux.conf
~/.npmrc           -> dotfiles/npm/.npmrc
~/.config/nvim     -> /Users/brennon/.../neovim/.config/nvim
~/.config/starship.toml -> .../starship/.config/starship/gruvbox-rainbow.toml
```

---

## 2. Configuration File Status

### Shell Configs (zsh/bash)

| Config | Status | Notes |
|--------|--------|-------|
| ~/.zshrc | OK | Symlinked (relative) |
| ~/.zshenv | OK | Symlinked (relative) |
| ~/.zprofile | **FILE** | Should be symlink |
| ~/.bashrc | OK | Symlinked (relative) |
| ~/.bash_profile | OK | Symlinked (relative) |
| ~/.bashrc.local | **SYMLINK** | Should be regular file |

**Issue**: `~/.bashrc.local` is symlinked when it should be a machine-specific override file.

### Local Override Files

| File | Exists | Status |
|------|--------|--------|
| ~/.zshrc.local | Yes | OK |
| ~/.zshenv.local | Yes | OK |
| ~/.bashrc.local | Yes | Should not be symlink |
| ~/.gitconfig.local | Yes | OK |

### Git Configuration

- `~/.gitconfig`: Symlinked (working)
- `~/.gitignore`: Symlinked (working)
- Git identity: `Brennon Williams <brennonw@gmail.com>` (valid, not placeholder)

### Tmux Configuration

- `~/.tmux.conf`: Symlinked (working)
- TPM: Installed at `~/.tmux/plugins/tpm/`
- Plugins installed: tmux-battery, tmux-continuum, tmux-cpu, tmux-resurrect, tmux-sensible, tmux-yank

### Neovim Configuration

- `~/.config/nvim`: **Directory symlink** (optimal setup)
- All plugin configs present (15 files)
- **Uncommitted change**: `lazy-lock.json` modified (markview.nvim migration)
- Residual file: `render-markdown.lua.bak` can be removed

### Ghostty Configuration

- `~/.config/ghostty/config`: **Regular file** (should be symlink)
- Content: Identical to repo (no drift)
- Themes: All 4 theme files synced
- `config.local`: Not present (optional)

### Starship Configuration

- Active preset: `gruvbox-rainbow.toml`
- `~/.config/starship.toml`: Valid symlink to preset
- **Stale symlink**: `~/.config/starship/starship.toml` points to non-existent old path

### VS Code Configuration

- `settings.json`: **Intentionally different** (machine has project-specific settings)
- `keybindings.json`: **Missing on machine** (repo has 99 lines of keybindings)
- Extensions: All 45 Brewfile extensions installed

### npm Configuration

- `~/.npmrc`: Properly symlinked
- Global packages: Only 2 of 57 documented packages installed

### brenentech Configuration

- `colors.sh`: Symlinked (working)
- `logo.sh`: Symlinked (working)

---

## 3. Package Manifest Status

### Homebrew Taps (16/16 - 100%)

All taps synced.

### Homebrew Formulae (79/92 - 86%)

**Missing from machine (13):**
```
assimp, autoconf, deno, fzf, gettext, node, pkgconf,
pyenv, python@3.11, ripgrep, rust, dav1d, zstd
```

**Untracked (installed but not in Brewfile):**
```
cocoapods, ios-deploy, libimobiledevice, mkcert,
tree-sitter, vale, xcodegen
```

### Homebrew Casks (12/12 - 100%)

All casks synced.

**Note**: `google-cloud-sdk` installed but Brewfile has `gcloud-cli` (may be alias).

### Mac App Store (8/8 - 100%)

All MAS apps synced:
- BBEdit, LottieFiles, Numbers, Perplexity, reMarkable, Showdown, Spokenly, Xcode

### VS Code Extensions (45/45 - 100%)

All extensions synced.

---

## 4. CLI Tools Status

All 18 expected CLI tools are installed:

| Category | Tools | Status |
|----------|-------|--------|
| Core | git 2.52, stow 2.4.1, curl 8.7.1, wget 1.25 | OK |
| Shell | zsh 5.9, bash 5.3.9, starship 1.24.1, zoxide 0.9.8, fzf 0.67 | OK |
| Dev | tmux 3.6a, nvim 0.11.5, rg 15.1, fd 10.3, jq 1.8.1, gh 2.83.2 | OK |
| Other | delta 0.18.2, brew 5.0.9, mas 5.0.2 | OK |

---

## 5. Recommended Actions

### High Priority

1. **Fix ~/.zprofile symlink:**
   ```bash
   cd /Users/brennon/AIProjects/ai-workspaces/dotfiles
   mv ~/.zprofile ~/.zprofile.backup
   stow zsh
   ```

2. **Fix ~/.config/ghostty/config:**
   ```bash
   mv ~/.config/ghostty/config ~/.config/ghostty/config.backup
   stow ghostty
   ```

3. **Remove stale Starship symlink:**
   ```bash
   rm ~/.config/starship/starship.toml
   rmdir ~/.config/starship 2>/dev/null
   ```

### Medium Priority

4. **Fix ~/.bashrc.local** (should not be symlinked):
   ```bash
   rm ~/.bashrc.local
   touch ~/.bashrc.local  # Create empty local override
   ```

5. **Install missing Homebrew formulae:**
   ```bash
   brew install deno fzf node pyenv python@3.11 ripgrep rust
   ```

6. **Commit Neovim lazy-lock.json:**
   ```bash
   git add neovim/.config/nvim/lazy-lock.json
   git commit -m "Update lazy-lock.json after markview.nvim migration"
   ```

### Low Priority

7. **Add untracked formulae to Brewfile** (if desired):
   ```
   brew "cocoapods"
   brew "ios-deploy"
   brew "mkcert"
   brew "vale"
   brew "xcodegen"
   ```

8. **Clean up Neovim backup:**
   ```bash
   rm neovim/.config/nvim/lua/plugins/render-markdown.lua.bak
   ```

9. **Install npm global packages** (if needed):
   ```bash
   # Review npm/global-packages.txt and install needed packages
   npm install -g <package>
   ```

---

## 6. Quick Fix Script

```bash
#!/usr/bin/env bash
# Quick fixes for high-priority issues

DOTFILES_DIR="/Users/brennon/AIProjects/ai-workspaces/dotfiles"
cd "$DOTFILES_DIR"

echo "=== Fixing symlink issues ==="

# 1. Fix zprofile
if [[ -f ~/.zprofile && ! -L ~/.zprofile ]]; then
    mv ~/.zprofile ~/.zprofile.backup.$(date +%s)
    stow zsh
    echo "Fixed: ~/.zprofile"
fi

# 2. Fix ghostty config
if [[ -f ~/.config/ghostty/config && ! -L ~/.config/ghostty/config ]]; then
    mv ~/.config/ghostty/config ~/.config/ghostty/config.backup.$(date +%s)
    stow ghostty
    echo "Fixed: ~/.config/ghostty/config"
fi

# 3. Remove stale starship symlink
if [[ -L ~/.config/starship/starship.toml ]]; then
    rm ~/.config/starship/starship.toml
    rmdir ~/.config/starship 2>/dev/null
    echo "Fixed: Removed stale starship symlink"
fi

# 4. Fix bashrc.local
if [[ -L ~/.bashrc.local ]]; then
    rm ~/.bashrc.local
    touch ~/.bashrc.local
    echo "Fixed: ~/.bashrc.local"
fi

echo "=== Done ==="
```

---

## Appendix: File Inventory

### Dotfiles Repository Structure

```
dotfiles/
  bash/           # Shell configs
  brenentech/     # Custom utilities
  foot/           # Linux terminal (skip on macOS)
  ghostty/        # macOS terminal
  git/            # Git config
  linux/          # Linux-specific (skip on macOS)
  macos/          # macOS-specific
  neovim/         # Editor config
  npm/            # npm config
  obsidian/       # Note app snippets
  starship/       # Prompt config
  sway/           # Linux WM (skip on macOS)
  tmux/           # Multiplexer config
  vscode/         # Editor settings (reference)
  zsh/            # Shell configs
```

### Key Configuration Files

| Purpose | Repo Path | Machine Path |
|---------|-----------|--------------|
| Zsh main | `zsh/.zshrc` | `~/.zshrc` |
| Bash main | `bash/.bashrc` | `~/.bashrc` |
| Git config | `git/.gitconfig` | `~/.gitconfig` |
| Tmux config | `tmux/.tmux.conf` | `~/.tmux.conf` |
| Neovim init | `neovim/.config/nvim/init.lua` | `~/.config/nvim/init.lua` |
| Starship | `starship/.config/starship/*.toml` | `~/.config/starship.toml` |
| Ghostty | `ghostty/.config/ghostty/config` | `~/.config/ghostty/config` |
| npm | `npm/.npmrc` | `~/.npmrc` |
| Brewfile | `Brewfile` | (used by `brew bundle`) |
