# Dotfiles -- Project Instructions

## Overview
GNU Stow-based dotfiles manager supporting macOS and Linux. Each top-level directory is a Stow package that symlinks into `$HOME`.

## Directory Conventions
- **Stow packages**: Each top-level dir (bash/, zsh/, git/, neovim/, tmux/, etc.) is a GNU Stow package
- **Non-packages**: `scripts/`, `tests/`, `docs/` are not Stow packages
- **Symlink method**: GNU Stow with `--target=$HOME`; `.stowrc` lives in `git/`
- **Local overrides**: Files with `.local` suffix are gitignored and machine-specific (e.g., `.zshrc.local`)

## Shell
- Zsh-primary with bash fallback
- Cross-platform utilities live in `.zsh_cross_platform`
- Platform detection uses `uname` checks

## Testing
- Framework: bats-core
- Test files: `tests/`
- Run all: `tests/run_all_tests.sh`

## Scripts
- Installation and maintenance scripts in `scripts/`
- Shared library functions in `scripts/lib/`

## Style Rules
- Never use emojis. Instead, use font glyphs, icons, ASCII/Unicode Art, or SVGs (if relevant)
