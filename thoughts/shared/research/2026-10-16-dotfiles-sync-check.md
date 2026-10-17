---
date: 2026-10-17T03:49:11Z
researcher: Claude
git_commit: b16c523
branch: main
hostname: Brennons-Mac-Mini-2.local
platform: Darwin
topic: "Dotfiles Sync Check"
tags: [dotfiles, sync, audit, configuration]
status: complete
last_updated: 2026-10-16
---

# Dotfiles Sync Check Report

**Date**: 2026-10-17T03:49:11Z
**Machine**: Brennons-Mac-Mini-2.local
**Platform**: Darwin
**Dotfiles Commit**: b16c523

## Executive Summary

| Category | Status | Action Needed |
|----------|--------|---------------|
| Stow symlinks (bash, zsh, git, tmux, ghostty, wezterm, glow, neovim, brenentech) | All linked, no broken links | No |
| Starship | `~/.config/starship.toml` linked to gruvbox-rainbow | No |
| VS Code settings/keybindings | Linked to macOS path | No |
| VS Code extensions | 26 of 36 listed not installed | Yes |
| Tmux plugins (TPM) | All 11 installed | No |
| Homebrew (Brewfile) | 1 tap, 6 formulae, 1 cask, 8 MAS apps missing | Yes |
| npm global packages | 0 of ~90 listed installed | Review |
| Git pre-commit hook | `core.hooksPath` not set; hook inactive | Yes |
| `.local` override files | 6 of 7 missing | Low |
| Uniclip LaunchAgent | Binary installed, service not loaded | Optional |
| Python | pyenv 3.13.16 global (set this session) | No |

## Detailed Findings

### Stow packages
All files in stowed packages resolve to symlinks into the repo. No broken
symlinks in `~` or `~/.config`. Non-stow folders (starship build files, vscode,
npm, obsidian, macos, ghostty/automator) are handled by scripts and were checked
separately.

### Homebrew -- in Brewfile but not installed
```
tap     sst/tap
brew    lazygit, llama.cpp, pnpm, sst/tap/opencode, surrealdb/tap/surreal
cask    codelayer
mas     BBEdit, LottieFiles, Numbers, Perplexity, reMarkable, Showdown, Spokenly, Xcode
```

### VS Code extensions -- in extensions.txt but not installed
```
alefragnani.bookmarks              bradlc.vscode-tailwindcss
christian-kohler.path-intellisense dracula-theme.theme-dracula
eamodio.gitlens                    esbenp.prettier-vscode
formulahendry.auto-rename-tag      foxundermoon.shell-format
github.vscode-pull-request-github  humao.rest-client
ms-mssql.mssql                     ms-vscode.hexdump
ms-vscode.test-adapter-converter   ms-vscode.vscode-eslint
ms-vscode.vscode-html-preview      ms-vscode.vscode-json
ms-vscode.vscode-markdown          ms-vscode.vscode-typescript-next
ms-vscode.wordcount                pkief.material-icon-theme
ritwickdey.liveserver              shd101wyy.markdown-preview-enhanced
streetsidesoftware.code-spell-checker timonwong.shellcheck
vscode-icons-team.vscode-icons     wayou.vscode-todo-highlight
```
Some IDs look invalid or obsolete: `ms-vscode.vscode-eslint` (real ID is
`dbaeumer.vscode-eslint`), `ms-vscode.vscode-json`, `ms-vscode.vscode-markdown`,
`ms-vscode.vscode-html-preview` (built-in or nonexistent).

### npm globals
`npm ls -g` shows only `npm`. `npm/global-packages.txt` lists ~90 packages,
many of which are project-level tools (jest, chai, eslint plugins) or
deprecated (create-react-app, @vue/cli, angular-cli). List needs pruning
before install.

### Git hooks
`.githooks/pre-commit` (ShellCheck + Gitleaks) exists but
`git config core.hooksPath` is unset and no install script sets it.

### Local overrides
Missing: `~/.zshrc.local`, `~/.zshenv.local`, `~/.bashrc.local`,
`~/.bash_profile.local`, `~/.tmux.local`, `~/.npmrc.local`.
Present: `~/.gitconfig.local`. Shells source these only if present, so this is cosmetic.

### Other
- Uniclip: `/opt/homebrew/bin/uniclip` present; `macos/com.uniclip.plist` not in `~/Library/LaunchAgents`, not loaded.
- Ghostty "Open Ghostty Here" quick action: installed.
- Nerd Fonts: installed.
- nvm: not installed and not referenced by zsh configs; node 26 comes from Homebrew. `scripts/setup-nvm.sh` may be stale.
- pipx: not installed (`uv` is).

## Recommended Actions

### High Priority
1. Enable the pre-commit hook: `git config core.hooksPath .githooks`
2. Install missing Homebrew items: `brew bundle install --file=Brewfile`

### Medium Priority
1. Fix invalid IDs in `vscode/extensions.txt`, then install the rest.
2. Prune `npm/global-packages.txt` to tools used globally, then install.

### Low Priority / Optional
1. `touch ~/.zshrc.local ~/.zshenv.local ~/.bashrc.local ~/.bash_profile.local ~/.tmux.local ~/.npmrc.local`
2. Load uniclip service: `macos/install-uniclip-service.sh`
3. Decide whether `scripts/setup-nvm.sh` is still needed.
