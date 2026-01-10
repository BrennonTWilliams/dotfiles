---
description: Compare dotfiles repo configurations against local machine to identify sync gaps
model: sonnet
---

# Dotfiles Sync Check

You are tasked with comparing the dotfiles repository configurations against the local machine's actual state to identify gaps, missing items, and drift between the two.

## Overview

This command spawns parallel subagents in waves to comprehensively compare:
- Configuration files (shell, git, tmux, etc.)
- Installed packages vs manifest
- CLI tools and binaries
- Symlink integrity

The goal is to produce a report showing what's in the repo but missing on the machine, what's on the machine but not tracked in the repo, and any configuration drift.

## Process Steps

### Step 1: Gather Context

1. **Detect the current platform**:
   ```bash
   uname -s  # Darwin for macOS, Linux for Linux
   ```

2. **List all dotfiles repo directories** to determine comparison scope:
   ```bash
   ls -d */ | grep -v -E '^\.(git|claude|github)' | grep -v '^(docs|scripts|tests|thoughts|test_results|claudedocs)/'
   ```

3. **Create a todo list** using TodoWrite to track each comparison area

### Step 2: Launch Wave 1 - Configuration File Comparisons

Spawn parallel subagents to compare each configuration area. For each directory in the repo, spawn an agent to check if the corresponding configs exist and match on the local machine.

**Spawn these agents in parallel:**

#### Agent 1.1: Shell Configurations (zsh)
```
Compare the zsh/ directory in the dotfiles repo against the local machine:
- Check if ~/.zshrc exists and is a symlink to the repo
- Check if ~/.zshenv exists and is a symlink to the repo
- Check if ~/.zsh_cross_platform exists
- Compare any zsh/functions/, zsh/aliases/, zsh/abbreviations/ contents
- Report: missing files, broken symlinks, files that exist locally but aren't symlinks to repo
```

#### Agent 1.2: Shell Configurations (bash)
```
Compare the bash/ directory in the dotfiles repo against the local machine:
- Check if ~/.bashrc exists and is a symlink to the repo
- Check if ~/.bash_profile exists and is a symlink to the repo
- Check for ~/.bash_aliases, ~/.bash_functions if they exist in repo
- Report: missing files, broken symlinks, non-symlinked files
```

#### Agent 1.3: Git Configuration
```
Compare the git/ directory in the dotfiles repo against the local machine:
- Check if ~/.gitconfig exists and is a symlink to the repo
- Check if ~/.gitignore_global exists and is a symlink
- Check for any git hooks or templates in the repo
- Report: missing configs, local-only configs not in repo
```

#### Agent 1.4: Terminal Emulators (ghostty, foot)
```
Compare terminal emulator configs:
- ghostty/: Check ~/.config/ghostty/ against repo
- foot/: Check ~/.config/foot/ against repo (Linux only)
- Report: missing configs, config drift, extra local configs
```

#### Agent 1.5: Tmux Configuration
```
Compare the tmux/ directory against local machine:
- Check if ~/.tmux.conf exists and is a symlink
- Check for ~/.tmux/ directory and plugins
- Check if tmux plugin manager (tpm) is installed
- Report: missing configs, plugin differences
```

#### Agent 1.6: Starship Configuration
```
Compare the starship/ directory against local machine:
- Check if ~/.config/starship.toml exists and is a symlink
- Compare starship config contents if not symlinked
- Report: missing config, configuration drift
```

#### Agent 1.7: Neovim Configuration
```
Compare the neovim/ directory against local machine:
- Check if ~/.config/nvim/ exists and matches repo structure
- Check for init.lua or init.vim
- Report: missing configs, extra local plugins
```

#### Agent 1.8: Other Configs (npm, obsidian, brenentech, macos, linux, sway)
```
Compare remaining config directories:
- npm/: Check ~/.npmrc against repo
- obsidian/: Check obsidian config locations
- brenentech/: Check custom brenentech configs
- macos/: Check macOS-specific settings (if on macOS)
- linux/: Check Linux-specific settings (if on Linux)
- sway/: Check ~/.config/sway/ (Linux only)
Report what exists in repo vs what's on machine
```

### Step 3: Launch Wave 2 - Package Comparisons

After Wave 1 completes, spawn agents to compare installed packages.

#### Agent 2.1: Homebrew Packages (macOS)
```
Compare packages-macos.txt against installed Homebrew packages:
- Run: brew list --formula
- Run: brew list --cask
- Parse packages-macos.txt (ignoring comments starting with #)
- Report:
  - Packages in manifest but NOT installed
  - Packages installed but NOT in manifest
  - Tap packages that may need special handling
```

#### Agent 2.2: System Packages (Linux)
```
Compare packages-linux.txt against installed packages:
- Detect package manager (apt, dnf, pacman)
- List installed packages
- Parse packages-linux.txt
- Report: missing packages, extra packages not in manifest
```

### Step 4: Launch Wave 3 - CLI Tools & Symlink Verification

#### Agent 3.1: CLI Tools Verification
```
Verify expected CLI tools are installed and accessible:
- Check for: git, curl, wget, stow, htop, tmux, zsh, starship, ripgrep, fd, fzf, zoxide, jq, neovim
- For each tool: command -v <tool> and <tool> --version where applicable
- Report: missing tools, version information
```

#### Agent 3.2: Symlink Integrity Check
```
Verify all stow-managed symlinks are intact:
- For each dotfiles directory, check that expected symlinks exist in $HOME
- Verify symlinks point to the correct dotfiles repo location
- Identify broken symlinks
- Identify files that should be symlinks but are regular files
Report: broken symlinks, missing symlinks, non-symlinked files that should be managed
```

### Step 5: Synthesize and Generate Report

After ALL agents complete, synthesize findings into a comprehensive report.

1. **Gather metadata**:
   ```bash
   date -u +"%Y-%m-%dT%H:%M:%SZ"
   git rev-parse --short HEAD
   git branch --show-current
   hostname
   uname -s
   ```

2. **Write the report** to `thoughts/shared/research/YYYY-MM-DD-dotfiles-sync-check.md`:

```markdown
---
date: [ISO timestamp]
researcher: Claude
git_commit: [commit hash]
branch: [branch name]
hostname: [machine hostname]
platform: [Darwin/Linux]
topic: "Dotfiles Sync Check"
tags: [dotfiles, sync, audit, configuration]
status: complete
last_updated: [YYYY-MM-DD]
---

# Dotfiles Sync Check Report

**Date**: [timestamp]
**Machine**: [hostname]
**Platform**: [Darwin/Linux]
**Dotfiles Commit**: [hash]

## Executive Summary

| Category | In Sync | Gaps Found | Action Needed |
|----------|---------|------------|---------------|
| Shell Configs | X/Y | N | [Yes/No] |
| Git Config | X/Y | N | [Yes/No] |
| Terminal Configs | X/Y | N | [Yes/No] |
| Tmux | X/Y | N | [Yes/No] |
| Packages | X/Y | N | [Yes/No] |
| Symlinks | X/Y | N | [Yes/No] |

**Overall Status**: [All synced / Gaps found]

## Detailed Findings

### Configuration Files

#### Shell (zsh)
**Status**: [Synced/Gaps Found]

| File | Repo | Local | Status |
|------|------|-------|--------|
| ~/.zshrc | [x] | [x] | [Symlinked/Missing/Not Symlinked] |
| ... | | | |

**Missing on Machine**:
- [list]

**On Machine but Not in Repo**:
- [list]

#### Shell (bash)
[Same structure...]

#### Git
[Same structure...]

#### Terminal Emulators
[Same structure...]

#### Tmux
[Same structure...]

#### Starship
[Same structure...]

#### Neovim
[Same structure...]

#### Other Configs
[Same structure...]

### Installed Packages

#### Homebrew Packages (macOS) / System Packages (Linux)

**Manifest Packages Not Installed** (N items):
```
package1
package2
...
```

**Installed Packages Not in Manifest** (N items):
```
extra-package1
extra-package2
...
```

### CLI Tools

| Tool | Expected | Installed | Version |
|------|----------|-----------|---------|
| git | Yes | [Yes/No] | [version] |
| starship | Yes | [Yes/No] | [version] |
| ... | | | |

### Symlink Integrity

**Broken Symlinks** (N items):
```
~/.broken-link -> /path/to/missing
...
```

**Files That Should Be Symlinks** (N items):
```
~/.zshrc (regular file, should link to dotfiles/zsh/.zshrc)
...
```

**Missing Symlinks** (N items):
```
~/.missing-config (expected from dotfiles/component/.missing-config)
...
```

## Recommended Actions

### High Priority
1. [Action item with specific command to fix]
2. [Action item...]

### Medium Priority
1. [Action item...]

### Low Priority / Optional
1. [Action item...]

## Commands to Sync

```bash
# Install missing packages
brew install package1 package2 ...

# Re-stow missing symlinks
cd ~/path/to/dotfiles && stow component

# Add local configs to repo (if desired)
# [commands...]
```
```

### Step 6: Present Results

1. **Display the summary table** to the user
2. **Provide the report location**: `thoughts/shared/research/YYYY-MM-DD-dotfiles-sync-check.md`
3. **Highlight critical gaps** that need immediate attention
4. **Ask if user wants to take any immediate action**

## Important Notes

- **Read-only operation**: This command only reports differences, it does not make changes
- **Platform-aware**: Automatically detects macOS vs Linux and adjusts comparisons
- **Scope from repo**: Only compares what exists in the dotfiles repo directories
- **Local files respected**: `.local` config files (like `.zshrc.local`) are expected to exist only on the machine
- **Parallel efficiency**: Agents run in parallel waves to minimize total execution time
- **Bidirectional comparison**: Reports both "repo has but machine missing" AND "machine has but repo missing"

## Wave Execution Order

```
Wave 1 (Parallel): Config file comparisons (8 agents)
    |
    v
Wave 2 (Parallel): Package comparisons (1-2 agents based on platform)
    |
    v
Wave 3 (Parallel): CLI tools + Symlink verification (2 agents)
    |
    v
Synthesis: Combine all results into final report
```
