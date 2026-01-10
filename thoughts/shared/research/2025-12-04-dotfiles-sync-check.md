---
date: 2025-12-05T02:12:06Z
researcher: Claude
git_commit: 460ea8a
branch: main
hostname: Mac.localdomain
platform: Darwin
topic: "Dotfiles Sync Check"
tags: [dotfiles, sync, audit, configuration]
status: complete
last_updated: 2025-12-04
---

# Dotfiles Sync Check Report

**Date**: 2025-12-05T02:12:06Z
**Machine**: Mac.localdomain
**Platform**: Darwin (macOS)
**Dotfiles Commit**: 460ea8a

## Executive Summary

> **Validated 2025-12-04**: Table updated after parallel subagent validation. Some original findings were false positives.

| Category | In Sync | Gaps Found | Action Needed | Validation Status |
|----------|---------|------------|---------------|-------------------|
| Shell Configs (zsh) | 6/6 | ~~16 subdirs~~ | No | FALSE POSITIVE - subdirs sourced from repo |
| Shell Configs (bash) | 3/5 | 2 files | Yes | CONFIRMED |
| Git Config | 0/2 | 2 files | Yes | CONFIRMED (fix modified) |
| Terminal Configs | Mixed | 1 file | Yes | CONFIRMED |
| Tmux | 1/1 | 0 | No | - |
| Starship | 2/2 | ~~1 broken symlink~~ | No | INVALID - symlink doesn't exist |
| Neovim | 18/18 | 0 | No | - |
| Other Configs | 2/7 | 4 files | Yes | CONFIRMED |
| Packages | 14/23 | 5 missing, 294 extra | Yes | CONFIRMED (fix modified) |
| CLI Tools | 12/14 | 2 missing | Yes | CONFIRMED |
| Symlinks | 11/22 | 8 issues | Yes | Reduced from 11 after validation |

**Overall Status**: Moderate gaps found - 5 valid fixes needed (3 original issues were false positives/duplicates)

## Detailed Findings

### Configuration Files

#### Shell (zsh)

**Status**: ✓ Fully Synced (validated - subdirectories work via repo-relative sourcing)

| File | Repo | Local | Status |
|------|------|-------|--------|
| ~/.zshrc | ✓ | ✓ | Symlinked ✓ |
| ~/.zshenv | ✓ | ✓ | Symlinked ✓ |
| ~/.zsh_cross_platform | ✓ | ✓ | Symlinked ✓ |
| ~/.zprofile | ✓ | ✓ | Regular file (not symlinked) |
| ~/.zshrc.local | ✓ | ✓ | Regular file (not symlinked) |
| ~/.zshenv.local | ✓ | ✓ | Regular file (not symlinked) |

~~**Missing on Machine**~~:

> **VALIDATED: FALSE POSITIVE** - These files are NOT supposed to be symlinked to `~/.zsh/`. The `.zshrc` resolves `DOTFILES_ZSH` from its own symlink path and sources these files directly from the repository via `source "$DOTFILES_ZSH/functions/_init.zsh"`. This is working as designed.

**On Machine but Not in Repo**:
- ~/.zsh_history (expected - not tracked)
- ~/.zshrc.backup.20251107 (expected - not tracked)

**Notes**: The three `.local` files are likely intentionally kept as regular files for machine-specific customization.

---

#### Shell (bash)

**Status**: ⚠ Partially Synced (3/5 files OK)

| File | Repo | Local | Status |
|------|------|-------|--------|
| .bashrc | ✓ | ✓ | Symlinked ✓ |
| .bash_logout | ✓ | ✓ | Symlinked ✓ |
| .profile | ✓ | ✓ | Symlinked ✓ |
| .bash_profile | ✓ | ✓ | Regular file (884 bytes, Oct 13) - OUT OF SYNC |
| .bashrc.local | ✓ | ✓ | Regular file (empty) - OUT OF SYNC |

**Configuration Drift**:
- .bash_profile: Local version (884 bytes, Oct 13) ≠ Repo version (2,158 bytes, Dec 4)
  - Machine has older, outdated copy
  - Repo version is more recent and comprehensive

**Notes**: .bashrc.local is empty but may be intentionally kept as a regular file for local customization.

---

#### Git

**Status**: ✗ Out of Sync

| File | Repo | Local | Status |
|------|------|-------|--------|
| .gitconfig | ✓ | ✓ | Regular file (NOT symlinked) |
| .gitignore | ✓ | ✗ | Missing |

**Configuration Drift**:
- **~/.gitconfig**: Significant divergence detected
  - Local version dated Nov 14, missing recent repo updates
  - Local missing: init/push/pull defaults, git aliases, `[include]` directive for .gitconfig.local
  - Local has: delta pager settings, merge conflict styling, interactive diffs
  - Repo version includes `[include]` to load ~/.gitconfig.local for machine-specific settings

**On Machine but Not in Repo**:
- ~/.config/git/ignore (XDG config location, contains Claude settings rule)
- ~/.gitconfig.local (machine-specific overrides with credential helper: osxkeychain)

**Notes**: Running `stow git` would align the local machine with the repository setup and properly enable the .gitconfig.local include mechanism.

---

#### Terminal Emulators

**Ghostty**: ⚠ Files Present but Not Symlinked

| File | Repo | Local | Status |
|------|------|-------|--------|
| ~/.config/ghostty/config | ✓ | ✓ | Regular file (contents match) |
| ~/.config/ghostty/config.local.template | ✓ | ✓ | Regular file (contents match) |
| ~/.config/ghostty/themes/* (4 files) | ✓ | ✓ | Regular files (contents match) |
| ~/.local/share/zsh/site-functions/_ghostty | ✓ | ✗ | Missing (zsh completion) |

**Status**: All config files present and contents identical to repo, but managed as regular files instead of symlinks. Missing zsh completion file.

**Foot**: N/A (Linux-only terminal emulator, correctly absent on macOS)

**VSCode**: ⚠ Configuration Drift

| File | Repo | Local | Status |
|------|------|-------|--------|
| settings.json | ✓ | ✓ | Regular file - SIGNIFICANT DRIFT |
| keybindings.json | ✓ | ✗ | Missing |
| extensions.txt | ✓ | ✗ | Missing |

**Configuration Drift**:
- Local settings.json (~50 lines) contains project-specific settings:
  - roo-cline.allowedCommands (custom AI assistant config)
  - BAML-specific settings
  - Extension configs for GitHub Copilot, Playwright
  - Different auto-save and minimap behavior
- Repo settings.json (~80 lines) contains baseline settings with clean, commented configuration

**Notes**: Local VSCode settings appear intentionally customized for specific projects. The repo version serves as a baseline template.

---

#### Tmux

**Status**: ✓ Fully Synced

| File | Repo | Local | Status |
|------|------|-------|--------|
| .tmux.conf | ✓ | ✓ | Symlinked ✓ |

**Tmux Plugin Manager**: ✓ Installed at ~/.tmux/plugins/tpm with 7 plugins:
- tmux-battery
- tmux-continuum
- tmux-cpu
- tmux-resurrect
- tmux-sensible
- tmux-yank
- tpm

**Notes**: Perfect sync. No action needed.

---

#### Starship

**Status**: ✓ Fully Synced (validated - no broken symlinks found)

| File | Repo | Local | Status |
|------|------|-------|--------|
| ~/.config/starship.toml | ✓ | ✓ | Symlinked ✓ (to gruvbox-rainbow.toml) |
| ~~~/.config/starship/starship.toml~~ | - | - | **VALIDATED: Does not exist** |

~~**Broken Symlinks**~~:

> **VALIDATED: INVALID** - The reported broken symlink at `~/.config/starship/starship.toml` does not exist. The old `~/.dotfiles/` directory no longer exists, and this symlink has already been cleaned up. No action required.

**Notes**: Starship is fully synced. The main config at `~/.config/starship.toml` is working correctly with gruvbox-rainbow mode.

---

#### Neovim

**Status**: ✓ Fully Synced

| File | Repo | Local | Status |
|------|------|-------|--------|
| ~/.config/nvim | ✓ | ✓ | Symlinked ✓ |

**Details**:
- All 18 files verified identical via MD5 checksums (100% match)
- Core config: init.lua, lazy-lock.json
- Modules: lua/config/ (2 files), lua/plugins/ (14 files)
- Plugins managed by lazy.nvim

**Notes**: Perfect sync. No action needed.

---

#### Other Configs

**npm**:

| File | Repo | Local | Status |
|------|------|-------|--------|
| .npmrc | ✓ | ✗ | Missing |

**obsidian**:

| File | Repo | Local | Status |
|------|------|-------|--------|
| snippets/gruvbox-theme.css | ✓ | ? | Vault-specific (requires MC-vault/.obsidian symlink) |

**Notes**: Obsidian config is vault-specific and would need to be symlinked into a specific vault directory (~/AIProjects/MC-vault/.obsidian/snippets/), not the global Obsidian config.

**brenentech**:

| File | Repo | Local | Status |
|------|------|-------|--------|
| .config/brenentech/colors.sh | ✓ | ✓ | Symlinked ✓ |
| .config/brenentech/logo.sh | ✓ | ✓ | Symlinked ✓ |

**On Machine but Not in Repo**:
- ~/.config/brenentech/.logo_enabled (empty flag file)

**Notes**: Fully synced.

**macos**:

| File | Repo | Local | Status |
|------|------|-------|--------|
| com.uniclip.plist | ✓ | ✓ | Regular file - CONTENT DIFFERS |

**Configuration Drift**:
- Local version includes `<key>WorkingDirectory</key><string>/Users/brennon</string>`
- Repo version does not include WorkingDirectory key
- Local version lacks explanatory comments present in repo version

**linux** / **sway**: N/A (Linux-only, correctly skipped on macOS)

---

### Installed Packages

#### Homebrew Packages (macOS)

**Manifest Packages Not Installed** (9 items):
```
curl
htop
mas
python3
rectangle
tree
unzip
wget
zsh
```

**Installed Packages Not in Manifest** (294 items):

**Formulae** (281 items - key categories):

*Language/Runtime Tools*:
- bun, deno, go, node, pnpm, poetry, python@3.11, python@3.13, python@3.14, pyenv, pyenv-virtualenv, rust, uv

*Development & Build Tools*:
- autoconf, bats-core, cmake, code2prompt, git-delta, git-filter-repo, git-lfs, llvm, llama.cpp, mcp, mcp-probe, marp-cli, pandoc, repomix, shellcheck

*Development Libraries*:
- abseil, assimp, cairo, fontconfig, freetype, libarchive, imagemagick, qt (and 50+ qt* packages), protobuf, sdl2, tesseract

*Utilities & CLI Tools*:
- cloudflared, coreutils, eza, gh, glow, gron, httpie, lazygit, lz4, magic-wormhole, tlrc, watch, xclip, yt-dlp, z3

*Data & Database*:
- kuzu, postgresql@14, postgresql@15, redis, sqlite, surreal

*Multimedia*:
- ffmpeg, ghostscript, imagemagick, lame, opus, speex, theora, webp, x264, x265

*Compression & Archives*:
- brotli, lz4, snappy, unbound, xz, zstd

**Casks** (13 items):
```
agent-tars
codelayer
font-hack-nerd-font
font-iosevka-term-nerd-font
gcloud-cli
google-cloud-sdk
iina
inkscape
karabiner-elements
libreoffice
mactex
qlmarkdown
rar
```

**Properly Installed Packages**:
- **Formulae**: 13 (curl, fd, fzf, git, jq, neovim, ripgrep, sketchybar, starship, stow, tmux, zoxide, zsh-abbr)
- **Casks**: 1 (ghostty)

**Notes**:
- Missing 9 core utilities including curl, htop, tree, wget (despite curl being listed as installed via system)
- 281 formulae installed beyond manifest (mostly transitive dependencies from Qt, development tools)
- Python version strategy more sophisticated than manifest: multiple Python versions + pyenv
- Rectangle cask (window manager) missing despite being in manifest
- Cloud infrastructure tools (google-cloud-sdk, gcloud-cli) installed but not in manifest
- ML/AI development tools present: llama.cpp, whisperkit-cli, mcp, claude-squad, gemini-cli

---

### CLI Tools

| Tool | Expected | Installed | Version | Path |
|------|----------|-----------|---------|------|
| git | Yes | ✓ | 2.52.0 | /opt/homebrew/bin/git |
| curl | Yes | ✓ | 8.7.1 | /usr/bin/curl (system) |
| wget | Yes | ✗ | — | — |
| stow | Yes | ✓ | 2.4.1 | /opt/homebrew/bin/stow |
| htop | Yes | ✗ | — | — |
| tmux | Yes | ✓ | 3.6 | /opt/homebrew/bin/tmux |
| zsh | Yes | ✓ | 5.9 | /bin/zsh (system) |
| starship | Yes | ✓ | 1.24.1 | /opt/homebrew/bin/starship |
| ripgrep (rg) | Yes | ✓ | 15.1.0 | /opt/homebrew/bin/rg |
| fd | Yes | ✓ | 10.3.0 | /opt/homebrew/bin/fd |
| fzf | Yes | ✓ | 0.67.0 | /opt/homebrew/bin/fzf |
| zoxide | Yes | ✓ | 0.9.8 | /opt/homebrew/bin/zoxide |
| jq | Yes | ✓ | 1.8.1 | /opt/homebrew/bin/jq |
| neovim (nvim) | Yes | ✓ | 0.11.5 | /opt/homebrew/bin/nvim |

**Missing Tools**: wget, htop

**Notes**: All installed tools are current, up-to-date versions with ARM-optimized builds for macOS.

---

### Symlink Integrity

> **Validated 2025-12-04**: Counts updated after subagent validation.

~~**Broken Symlinks** (1 item)~~:

> **VALIDATED: INVALID** - No broken symlinks found. The reported `~/.config/starship/starship.toml` does not exist.

**Missing Symlinks** (1 item - reduced from 4):
```
~/.gitignore (exists in repo at git/.gitignore) - will be created by Fix #1
```

> **VALIDATED**: The 3 zsh subdirectory items (`~/.config/zsh/abbreviations`, `aliases`, `functions`) were FALSE POSITIVES. These are sourced directly from the repo via `$DOTFILES_ZSH` path resolution.

**Files That Should Be Symlinks** (4 items - reduced from 7):
```
~/.bash_profile (regular file, should symlink to dotfiles/bash/.bash_profile)
~/.gitconfig (regular file, should symlink to dotfiles/git/.gitconfig)
~/.npmrc (missing, should symlink to dotfiles/npm/.npmrc)
~/.local/share/zsh/site-functions/_ghostty (missing zsh completion)
```

> **VALIDATED**: The `.local` files (`.bashrc.local`, `.zprofile`, `.zshrc.local`, `.zshenv.local`) are intentionally regular files for machine-specific customization - not issues.

**Properly Configured Symlinks** (11 items):
- ~/.bash_logout -> dotfiles/bash/.bash_logout
- ~/.bashrc -> dotfiles/bash/.bashrc
- ~/.profile -> dotfiles/bash/.profile
- ~/.zshrc -> dotfiles/zsh/.zshrc
- ~/.zshenv -> dotfiles/zsh/.zshenv
- ~/.zsh_cross_platform -> dotfiles/zsh/.zsh_cross_platform
- ~/.tmux.conf -> dotfiles/tmux/.tmux.conf
- ~/.config/nvim -> dotfiles/neovim/.config/nvim
- ~/.config/ghostty -> dotfiles/ghostty/.config/ghostty
- ~/.config/foot -> dotfiles/foot/.config/foot
- ~/.config/starship.toml -> dotfiles/starship/.config/starship/gruvbox-rainbow.toml

**Summary** (validated):
- Total expected symlinks: 15 (reduced from 22 after validation)
- Actual working symlinks: 11
- Total issues: 5 (0 broken, 1 missing, 4 need symlinking via stow)

---

## Recommended Actions

### High Priority

1. **Fix git configuration sync**:

   > **Note**: Running `stow --restow git` alone will FAIL because ~/.gitconfig is a regular file, not a symlink. Stow refuses to overwrite existing files. Follow this multi-step process:

   > **VALIDATED 2025-12-04**: Must also preserve delta pager settings (core.pager, interactive.diffFilter, delta.navigate, merge.conflictStyle) in addition to user credentials.

   ```bash
   # Step 1: Backup current config (contains personal settings + delta config)
   cp ~/.gitconfig ~/.gitconfig.backup_$(date +%Y%m%d)

   # Step 2: Remove conflicting regular file
   rm ~/.gitconfig

   # Step 3: Apply stow (creates symlinks for .gitconfig AND .gitignore)
   cd /Users/brennon/AIProjects/ai-workspaces/dotfiles
   stow --restow git

   # Step 4: Restore personal settings to .gitconfig.local
   # NOTE: Uses environment variables for identity (public repo - don't commit secrets)
   cat >> ~/.gitconfig.local << EOF
   [user]
       name = ${GIT_USER_NAME:-Your Name}
       email = ${GIT_USER_EMAIL:-your.email@example.com}

   [core]
       pager = delta

   [interactive]
       diffFilter = delta --color-only

   [delta]
       navigate = true

   [merge]
       conflictStyle = zdiff3
   EOF

   # Step 5: Set environment variables in shell config (~/.zshenv.local or ~/.bashrc.local)
   # Add these lines to your local shell config:
   #   export GIT_USER_NAME="Your Name"
   #   export GIT_USER_EMAIL="your.email@example.com"
   ```

   This preserves your personal config (name, email, delta integration) while enabling the repo's aliases and settings via the `[include]` mechanism. Identity is loaded from environment variables to avoid committing secrets to the public repo.

2. **Fix bash_profile sync**:

   > **VALIDATED 2025-12-04**: Critical issue - current ~/.bash_profile is **NOT sourcing ~/.bashrc**, causing login shells to miss Homebrew paths, Starship prompt, Zoxide integration, and bash completion.

   ```bash
   rm ~/.bash_profile
   cd /Users/brennon/AIProjects/ai-workspaces/dotfiles
   stow --restow bash
   ```
   This will replace the outdated local copy (28 lines) with a symlink to the current repo version (60 lines), which properly sources ~/.bashrc and supports lazy-loaded conda initialization.

   > **Post-fix**: If IntelliShell is actively used, uncomment line 46 in the new ~/.bash_profile (currently commented out by default).

3. **Install missing core utilities**:
   ```bash
   # Formulae (CLI tools)
   brew install wget htop tree mas

   # Casks (GUI applications) - rectangle is a cask, not a formula
   brew install --cask rectangle
   ```

4. ~~**Remove broken starship symlink**~~:

   > **VALIDATED: NOT NEEDED** - The broken symlink at `~/.config/starship/starship.toml` does not exist. The old `~/.dotfiles/` directory no longer exists, and this symlink has already been cleaned up. The working starship config at `~/.config/starship.toml` is properly configured with gruvbox-rainbow mode. No action required.

5. **Install missing ghostty zsh completion**:
   ```bash
   mkdir -p ~/.local/share/zsh/site-functions
   cd /Users/brennon/AIProjects/ai-workspaces/dotfiles
   stow --restow ghostty
   ```

### Medium Priority

6. ~~**Sync zsh subdirectories**~~:

   > **VALIDATED: FALSE POSITIVE** - No action required. The zsh configuration uses a clever architecture:
   >
   > 1. `~/.zshrc` is symlinked to the repo
   > 2. `.zshrc` resolves `DOTFILES_ZSH` from its own symlink path using `readlink`
   > 3. Sources files directly from the repo: `source "$DOTFILES_ZSH/functions/_init.zsh"`
   > 4. Each `_init.zsh` uses `${0:A:h}` to find adjacent files in the same directory
   >
   > The subdirectory files are NOT supposed to be in `~/.zsh/`. They remain in the repo and are sourced via path resolution. This is working as designed.

7. **Sync npm configuration**:

   > **VALIDATED 2025-12-04**: Command confirmed working. The .npmrc file exists at `npm/.npmrc` with safe defaults (no secrets, uses env vars for sensitive config).

   ```bash
   cd /Users/brennon/AIProjects/ai-workspaces/dotfiles
   stow --restow npm
   ```

   > **Documentation Bug**: `npm/README.md:10` incorrectly states ".npmrc is not included" but the file DOES exist. Update README to reflect that .npmrc IS included with safe defaults and recommends `.npmrc.local` for sensitive config.

8. **Update packages-macos.txt manifest** to reflect actual installed packages or document that the 281 extra formulae are transitive dependencies. Consider using Homebrew Bundle for more comprehensive tracking:
   ```bash
   brew bundle dump --file=/Users/brennon/AIProjects/ai-workspaces/dotfiles/Brewfile --force
   ```

### Low Priority / Optional

9. **Review .local files strategy**: Confirm whether .bashrc.local, .zshrc.local, .zshenv.local, .zprofile should remain as regular files for local customization or be symlinked.

10. ~~**Add .gitignore to home**~~:

    > **VALIDATED: DUPLICATE** - This is automatically handled by Fix #1. When `stow --restow git` is run, it creates symlinks for ALL files in the `git/` package, including both `~/.gitconfig` and `~/.gitignore`. No separate action needed.

11. **Obsidian theme**: If using the MC-vault, symlink the Gruvbox theme:
    ```bash
    mkdir -p ~/AIProjects/MC-vault/.obsidian/snippets
    ln -sf /Users/brennon/AIProjects/ai-workspaces/dotfiles/obsidian/snippets/gruvbox-theme.css \
           ~/AIProjects/MC-vault/.obsidian/snippets/gruvbox-theme.css
    ```

12. **VSCode settings**: Decide whether to keep project-specific local settings or reset to baseline repo version. If keeping local customization, document the divergence.

13. **Review macOS uniclip.plist drift**: Decide whether to add WorkingDirectory key to repo version or symlink to current repo version.

---

## Commands to Sync (Quick Reference)

> **Validated 2025-12-04**: Commands updated after subagent validation. Invalid/duplicate fixes removed.

```bash
# Navigate to dotfiles repo
cd /Users/brennon/AIProjects/ai-workspaces/dotfiles

# === FIX #1: Git config (requires backup first!) ===
cp ~/.gitconfig ~/.gitconfig.backup_$(date +%Y%m%d)
rm ~/.gitconfig
stow --restow git
# Then add personal config to ~/.gitconfig.local using env vars (see Fix #1 above)
# Also add to ~/.zshenv.local or ~/.bashrc.local:
#   export GIT_USER_NAME="Your Name"
#   export GIT_USER_EMAIL="your.email@example.com"

# === FIX #2: Bash profile ===
rm ~/.bash_profile
stow --restow bash

# === FIX #3: Missing packages ===
brew install wget htop tree mas
brew install --cask rectangle

# === FIX #5: Ghostty completion ===
mkdir -p ~/.local/share/zsh/site-functions
stow --restow ghostty

# === FIX #7: NPM config ===
stow --restow npm

# === REMOVED (validated as not needed) ===
# Fix #4: rm ~/.config/starship/starship.toml  -- symlink doesn't exist
# Fix #6: zsh subdirs symlinking              -- working as designed
# Fix #10: ln -sf .gitignore                  -- handled by Fix #1

# Optional: Create Brewfile for comprehensive package tracking
brew bundle dump --file=/Users/brennon/AIProjects/ai-workspaces/dotfiles/Brewfile --force
```

---

## Analysis Summary

> **Validated 2025-12-04**: Original findings reviewed by parallel subagents. 3 issues were false positives.

The dotfiles repository is **partially synchronized** with the local machine. Core configurations for tmux and neovim are perfectly synced, but gaps exist in:

1. **Git configuration** - Not using stow, causing version drift (requires backup before fix)
2. **Bash configuration** - Outdated .bash_profile
3. ~~**Shell subdirectories** - Missing zsh functions, aliases, abbreviations~~ **[FALSE POSITIVE - working as designed]**
4. **Package management** - 5 core utilities missing (wget, htop, tree, mas, rectangle)
5. **Symlink management** - 8 files/directories not properly symlinked (reduced from 11 after validation)

### Validation Results

| Original Fix | Status | Notes |
|-------------|--------|-------|
| #1 Git config | VALID (modified) | Requires backup + remove before stow; preserve delta settings; use env vars for identity |
| #2 bash_profile | VALID (critical) | Current file NOT sourcing ~/.bashrc - missing Homebrew, Starship, Zoxide |
| #3 Missing packages | VALID (modified) | rectangle is a cask, not formula |
| #4 Starship symlink | INVALID | Symlink doesn't exist |
| #5 Ghostty completion | VALID | Safe to proceed |
| #6 Zsh subdirs | FALSE POSITIVE | Architecture uses repo-relative paths |
| #7 npm config | VALID | README.md:10 documentation bug - says .npmrc not included but it is |
| #10 .gitignore | DUPLICATE | Handled by Fix #1 |

The most critical issues are: (1) git configuration drift requiring backup before stow, and (2) bash_profile not sourcing ~/.bashrc which breaks login shell functionality.

The large number of extra installed packages (281 formulae) suggests heavy transitive dependencies from development tools (Qt, LLVM, etc.). Consider using Homebrew Bundle to maintain comprehensive package state.

Overall, the system is functional with **5 valid fixes** needed to restore full synchronization.
