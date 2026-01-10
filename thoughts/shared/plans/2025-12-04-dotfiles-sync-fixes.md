# Dotfiles Sync Fixes Implementation Plan

## Overview

Implement a single script (`scripts/sync-fixes.sh`) that executes all 5 validated fixes from the 2025-12-04 sync check audit to restore full synchronization between the dotfiles repository and local machine. Includes medium-priority items: npm config sync, documentation fix, and Brewfile generation.

## Current State Analysis

Based on the sync check research at `thoughts/shared/research/2025-12-04-dotfiles-sync-check.md`:

### Validated Issues:
| Fix | Issue | Severity |
|-----|-------|----------|
| #1 | Git config is regular file, not symlink. Missing aliases, includes. | High |
| #2 | ~/.bash_profile outdated (28 lines vs 60), NOT sourcing ~/.bashrc | Critical |
| #3 | Missing packages: wget, htop, tree, mas, rectangle | High |
| #5 | Missing ghostty zsh completion file | Medium |
| #7 | ~/.npmrc missing (stow not run) | Medium |

### Key Discoveries:
- `~/.gitconfig` contains delta pager settings that must be preserved in `~/.gitconfig.local`
- Current git config: `core.pager=delta`, `interactive.diffFilter=delta --color-only`, `delta.navigate=true`, `merge.conflictStyle=zdiff3`
- Git LFS filter settings present (will be re-added by stow's .gitconfig)
- Git credentials already in shell environment (`GIT_USER_NAME`, `GIT_USER_EMAIL`)
- npm/README.md:10 incorrectly states ".npmrc not included" but `npm/.npmrc` exists

## Desired End State

After running `scripts/sync-fixes.sh`:

1. `~/.gitconfig` is a symlink to `dotfiles/git/.gitconfig`
2. `~/.gitignore` is a symlink to `dotfiles/git/.gitignore`
3. `~/.gitconfig.local` contains machine-specific settings (delta, credentials)
4. `~/.bash_profile` is a symlink to `dotfiles/bash/.bash_profile`
5. wget, htop, tree, mas, rectangle are installed
6. `~/.local/share/zsh/site-functions/_ghostty` exists (zsh completion)
7. `~/.npmrc` is a symlink to `dotfiles/npm/.npmrc`
8. npm/README.md documentation is accurate
9. Brewfile generated for comprehensive package tracking

### Verification:
```bash
# All should show symlinks
ls -la ~/.gitconfig ~/.gitignore ~/.bash_profile ~/.npmrc

# Check completion file exists
ls -la ~/.local/share/zsh/site-functions/_ghostty

# Check packages installed
command -v wget htop tree mas && echo "All CLI tools present"
brew list --cask rectangle && echo "Rectangle installed"

# Verify git config includes local
git config --get include.path  # Should show ~/.gitconfig.local
```

## What We're NOT Doing

- NOT modifying VSCode settings (intentionally project-specific)
- NOT symlinking .local files (intentionally machine-specific)
- NOT modifying macOS uniclip.plist (minor drift, low priority)
- NOT setting up Obsidian vault symlinks (vault-specific)
- NOT modifying any zsh subdirectory structure (working as designed)

## Implementation Approach

Create a single idempotent script that:
1. Checks each fix's current state before acting
2. Creates timestamped backups of modified files
3. Extracts settings from current configs before overwriting
4. Applies fixes sequentially with clear logging
5. Validates each fix after application
6. Generates summary report

---

## Phase 1: Create Sync Fixes Script

### Overview
Create `scripts/sync-fixes.sh` with all fix logic, proper error handling, and backup functionality.

### Changes Required:

#### 1.1 Create Main Script

**File**: `scripts/sync-fixes.sh`
**Changes**: New file - comprehensive sync fix script

```bash
#!/usr/bin/env bash

# ==============================================================================
# Dotfiles Sync Fixes Script
# ==============================================================================
# Executes validated fixes from sync check audit.
# Run with --dry-run to preview changes without applying them.
#
# Fixes applied:
#   #1 - Git configuration (stow + preserve delta settings)
#   #2 - Bash profile (stow)
#   #3 - Missing packages (brew install)
#   #5 - Ghostty zsh completion (stow)
#   #7 - NPM config (stow)
#
# Usage:
#   ./scripts/sync-fixes.sh           # Apply all fixes
#   ./scripts/sync-fixes.sh --dry-run # Preview changes only
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# Source utilities
source "$SCRIPT_DIR/lib/utils.sh"

# Options
DRY_RUN=false

# Counters
FIXES_APPLIED=0
FIXES_SKIPPED=0
FIXES_FAILED=0

# ==============================================================================
# Helper Functions
# ==============================================================================

backup_file() {
    local file="$1"
    if [[ -e "$file" ]] && [[ ! -L "$file" ]]; then
        mkdir -p "$BACKUP_DIR"
        cp "$file" "$BACKUP_DIR/$(basename "$file")"
        info "Backed up: $file -> $BACKUP_DIR/"
    fi
}

extract_git_local_settings() {
    # Extract settings that should go in .gitconfig.local
    local gitconfig="$HOME/.gitconfig"
    local gitconfig_local="$HOME/.gitconfig.local"

    if [[ ! -f "$gitconfig" ]] || [[ -L "$gitconfig" ]]; then
        return 0  # Nothing to extract
    fi

    # Create/update .gitconfig.local with preserved settings
    {
        echo "# Machine-specific git configuration"
        echo "# Auto-generated by sync-fixes.sh on $(date)"
        echo ""

        # User identity (from environment or current config)
        echo "[user]"
        if [[ -n "${GIT_USER_NAME:-}" ]]; then
            echo "    name = $GIT_USER_NAME"
        else
            local name
            name=$(git config --file "$gitconfig" user.name 2>/dev/null || echo "")
            [[ -n "$name" ]] && echo "    name = $name"
        fi
        if [[ -n "${GIT_USER_EMAIL:-}" ]]; then
            echo "    email = $GIT_USER_EMAIL"
        else
            local email
            email=$(git config --file "$gitconfig" user.email 2>/dev/null || echo "")
            [[ -n "$email" ]] && echo "    email = $email"
        fi
        echo ""

        # Delta pager settings
        local pager
        pager=$(git config --file "$gitconfig" core.pager 2>/dev/null || echo "")
        if [[ "$pager" == "delta" ]]; then
            echo "[core]"
            echo "    pager = delta"
            echo ""

            local diff_filter
            diff_filter=$(git config --file "$gitconfig" interactive.diffFilter 2>/dev/null || echo "")
            if [[ -n "$diff_filter" ]]; then
                echo "[interactive]"
                echo "    diffFilter = $diff_filter"
                echo ""
            fi

            local navigate
            navigate=$(git config --file "$gitconfig" delta.navigate 2>/dev/null || echo "")
            if [[ -n "$navigate" ]]; then
                echo "[delta]"
                echo "    navigate = $navigate"
                echo ""
            fi
        fi

        # Merge conflict style
        local conflict_style
        conflict_style=$(git config --file "$gitconfig" merge.conflictStyle 2>/dev/null || echo "")
        if [[ -n "$conflict_style" ]]; then
            echo "[merge]"
            echo "    conflictStyle = $conflict_style"
            echo ""
        fi

        # Credential helper (macOS keychain)
        local cred_helper
        cred_helper=$(git config --file "$gitconfig" credential.helper 2>/dev/null || echo "")
        if [[ -n "$cred_helper" ]]; then
            echo "[credential]"
            echo "    helper = $cred_helper"
            echo ""
        fi
    } > "$gitconfig_local"

    success "Extracted settings to $gitconfig_local"
}

# ==============================================================================
# Fix Functions
# ==============================================================================

fix_git_config() {
    section "Fix #1: Git Configuration"

    local gitconfig="$HOME/.gitconfig"
    local gitignore="$HOME/.gitignore"

    # Check if already a symlink
    if [[ -L "$gitconfig" ]] && [[ -L "$gitignore" ]]; then
        info "Git config already symlinked, skipping"
        ((FIXES_SKIPPED++))
        return 0
    fi

    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Would backup and replace ~/.gitconfig"
        info "[DRY-RUN] Would extract delta settings to ~/.gitconfig.local"
        info "[DRY-RUN] Would run: stow --restow git"
        return 0
    fi

    # Extract settings before we overwrite
    extract_git_local_settings

    # Backup existing files
    backup_file "$gitconfig"
    backup_file "$gitignore"

    # Remove existing regular files
    [[ -f "$gitconfig" ]] && [[ ! -L "$gitconfig" ]] && rm "$gitconfig"
    [[ -f "$gitignore" ]] && [[ ! -L "$gitignore" ]] && rm "$gitignore"

    # Apply stow
    cd "$DOTFILES_DIR"
    if stow --restow git; then
        success "Git configuration symlinked"
        ((FIXES_APPLIED++))
    else
        error "Failed to stow git package"
        ((FIXES_FAILED++))
        return 1
    fi
}

fix_bash_profile() {
    section "Fix #2: Bash Profile"

    local bash_profile="$HOME/.bash_profile"

    # Check if already a symlink
    if [[ -L "$bash_profile" ]]; then
        info "Bash profile already symlinked, skipping"
        ((FIXES_SKIPPED++))
        return 0
    fi

    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Would backup and replace ~/.bash_profile"
        info "[DRY-RUN] Would run: stow --restow bash"
        return 0
    fi

    # Backup existing file
    backup_file "$bash_profile"

    # Remove existing regular file
    [[ -f "$bash_profile" ]] && [[ ! -L "$bash_profile" ]] && rm "$bash_profile"

    # Apply stow
    cd "$DOTFILES_DIR"
    if stow --restow bash; then
        success "Bash profile symlinked"
        ((FIXES_APPLIED++))
    else
        error "Failed to stow bash package"
        ((FIXES_FAILED++))
        return 1
    fi
}

fix_missing_packages() {
    section "Fix #3: Missing Packages"

    if ! command -v brew >/dev/null 2>&1; then
        warn "Homebrew not installed, skipping package installation"
        ((FIXES_SKIPPED++))
        return 0
    fi

    local formulae=("wget" "htop" "tree" "mas")
    local casks=("rectangle")
    local installed_count=0

    # Check formulae
    for pkg in "${formulae[@]}"; do
        if brew list "$pkg" >/dev/null 2>&1; then
            info "$pkg already installed"
        else
            if [[ "$DRY_RUN" == true ]]; then
                info "[DRY-RUN] Would install: $pkg"
            else
                info "Installing $pkg..."
                if brew install "$pkg"; then
                    success "Installed $pkg"
                    ((installed_count++))
                else
                    warn "Failed to install $pkg"
                fi
            fi
        fi
    done

    # Check casks
    for pkg in "${casks[@]}"; do
        if brew list --cask "$pkg" >/dev/null 2>&1; then
            info "$pkg already installed"
        else
            if [[ "$DRY_RUN" == true ]]; then
                info "[DRY-RUN] Would install cask: $pkg"
            else
                info "Installing $pkg (cask)..."
                if brew install --cask "$pkg"; then
                    success "Installed $pkg"
                    ((installed_count++))
                else
                    warn "Failed to install $pkg"
                fi
            fi
        fi
    done

    if [[ "$DRY_RUN" != true ]]; then
        if [[ $installed_count -gt 0 ]]; then
            success "Installed $installed_count packages"
            ((FIXES_APPLIED++))
        else
            info "All packages already installed"
            ((FIXES_SKIPPED++))
        fi
    fi
}

fix_ghostty_completion() {
    section "Fix #5: Ghostty Zsh Completion"

    local completion_dir="$HOME/.local/share/zsh/site-functions"
    local completion_file="$completion_dir/_ghostty"

    # Check if already exists
    if [[ -f "$completion_file" ]] || [[ -L "$completion_file" ]]; then
        info "Ghostty completion already exists, skipping"
        ((FIXES_SKIPPED++))
        return 0
    fi

    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Would create: $completion_dir"
        info "[DRY-RUN] Would run: stow --restow ghostty"
        return 0
    fi

    # Create directory
    mkdir -p "$completion_dir"

    # Apply stow
    cd "$DOTFILES_DIR"
    if stow --restow ghostty; then
        success "Ghostty completion installed"
        ((FIXES_APPLIED++))
    else
        error "Failed to stow ghostty package"
        ((FIXES_FAILED++))
        return 1
    fi
}

fix_npm_config() {
    section "Fix #7: NPM Configuration"

    local npmrc="$HOME/.npmrc"

    # Check if already a symlink
    if [[ -L "$npmrc" ]]; then
        info "NPM config already symlinked, skipping"
        ((FIXES_SKIPPED++))
        return 0
    fi

    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Would run: stow --restow npm"
        return 0
    fi

    # Backup existing file if present
    backup_file "$npmrc"

    # Remove existing regular file
    [[ -f "$npmrc" ]] && [[ ! -L "$npmrc" ]] && rm "$npmrc"

    # Apply stow
    cd "$DOTFILES_DIR"
    if stow --restow npm; then
        success "NPM config symlinked"
        ((FIXES_APPLIED++))
    else
        error "Failed to stow npm package"
        ((FIXES_FAILED++))
        return 1
    fi
}

generate_brewfile() {
    section "Optional: Generate Brewfile"

    if ! command -v brew >/dev/null 2>&1; then
        warn "Homebrew not installed, skipping Brewfile generation"
        return 0
    fi

    local brewfile="$DOTFILES_DIR/Brewfile"

    if [[ "$DRY_RUN" == true ]]; then
        info "[DRY-RUN] Would generate: $brewfile"
        return 0
    fi

    info "Generating Brewfile..."
    if brew bundle dump --file="$brewfile" --force; then
        success "Generated $brewfile"
    else
        warn "Failed to generate Brewfile"
    fi
}

# ==============================================================================
# Summary
# ==============================================================================

print_summary() {
    section "Summary"

    echo ""
    echo "  Applied:  $FIXES_APPLIED"
    echo "  Skipped:  $FIXES_SKIPPED"
    echo "  Failed:   $FIXES_FAILED"
    echo ""

    if [[ -d "$BACKUP_DIR" ]]; then
        info "Backups saved to: $BACKUP_DIR"
    fi

    if [[ $FIXES_FAILED -gt 0 ]]; then
        error "Some fixes failed. Check output above."
        return 1
    elif [[ $FIXES_APPLIED -gt 0 ]]; then
        success "All requested fixes applied successfully."
        echo ""
        info "Recommended: Run './scripts/check-symlinks.sh' to verify"
    else
        info "Nothing to do - all configurations already in sync."
    fi
}

# ==============================================================================
# Main
# ==============================================================================

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run|--preview)
                DRY_RUN=true
                shift
                ;;
            --help|-h)
                echo "Usage: $0 [--dry-run]"
                echo ""
                echo "Options:"
                echo "  --dry-run  Preview changes without applying them"
                echo "  --help     Show this help message"
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    echo ""
    echo "======================================"
    echo "  Dotfiles Sync Fixes"
    echo "======================================"
    echo ""
    info "Dotfiles: $DOTFILES_DIR"

    if [[ "$DRY_RUN" == true ]]; then
        warn "DRY-RUN MODE - No changes will be made"
    fi

    # Apply fixes
    fix_git_config
    fix_bash_profile
    fix_missing_packages
    fix_ghostty_completion
    fix_npm_config
    generate_brewfile

    # Print summary
    print_summary
}

main "$@"
```

### Success Criteria:

#### Automated Verification:
- [ ] Script is executable: `test -x scripts/sync-fixes.sh`
- [ ] Script syntax is valid: `bash -n scripts/sync-fixes.sh`
- [ ] ShellCheck passes: `shellcheck scripts/sync-fixes.sh`
- [ ] Dry-run completes without error: `./scripts/sync-fixes.sh --dry-run`

#### Manual Verification:
- [ ] Review script logic matches intended behavior
- [ ] Confirm backup directory path looks reasonable

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation before proceeding to the next phase.

---

## Phase 2: Fix npm/README.md Documentation Bug

### Overview
Update the npm README to accurately reflect that .npmrc IS included in the package.

### Changes Required:

#### 2.1 Fix Documentation

**File**: `npm/README.md`
**Changes**: Update line 10 to reflect reality

Current (incorrect):
```markdown
**Note:** This module does not include a `.npmrc` file. NPM configuration is typically machine-specific and may contain sensitive information (registry tokens, proxy settings). Create your own `~/.npmrc` as needed.
```

Updated (correct):
```markdown
**Note:** This module includes a `.npmrc` file with safe development defaults. The file uses environment variable placeholders for author info. Create `~/.npmrc.local` for machine-specific or sensitive settings (registry tokens, proxy settings).
```

### Success Criteria:

#### Automated Verification:
- [ ] File updated: `grep -q "includes a .npmrc file" npm/README.md`

#### Manual Verification:
- [ ] Documentation accurately describes the actual file contents

---

## Phase 3: Execute Sync Fixes

### Overview
Run the sync-fixes.sh script to apply all validated fixes.

### Changes Required:

#### 3.1 Run Script

```bash
cd /Users/brennon/AIProjects/ai-workspaces/dotfiles
./scripts/sync-fixes.sh
```

### Success Criteria:

#### Automated Verification:
- [ ] Git config is symlink: `test -L ~/.gitconfig`
- [ ] Git ignore is symlink: `test -L ~/.gitignore`
- [ ] Bash profile is symlink: `test -L ~/.bash_profile`
- [ ] NPM config is symlink: `test -L ~/.npmrc`
- [ ] Ghostty completion exists: `test -f ~/.local/share/zsh/site-functions/_ghostty`
- [ ] wget installed: `command -v wget`
- [ ] htop installed: `command -v htop`
- [ ] tree installed: `command -v tree`
- [ ] mas installed: `command -v mas`
- [ ] rectangle installed: `brew list --cask rectangle`
- [ ] Git local config exists: `test -f ~/.gitconfig.local`
- [ ] Symlink check passes: `./scripts/check-symlinks.sh`

#### Manual Verification:
- [ ] Git commands work correctly (git status, git log)
- [ ] Delta pager displays colored diffs
- [ ] New bash login shell has Homebrew, Starship, Zoxide in PATH
- [ ] Rectangle app is available in Applications

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation that the shell environment works correctly before finalizing.

---

## Testing Strategy

### Unit Tests:
- Verify script handles already-symlinked files gracefully (idempotent)
- Verify dry-run mode doesn't modify any files
- Verify backup creation for regular files

### Integration Tests:
```bash
# Full validation suite
./scripts/check-symlinks.sh
./scripts/health-check.sh
```

### Manual Testing Steps:
1. Open new terminal - verify Starship prompt appears
2. Run `git status` - verify delta pager shows colored output
3. Run `git log` - verify commit history displays correctly
4. Open Rectangle from Applications - verify window management works
5. Run `bash -l` - verify login shell has correct PATH

## Performance Considerations

- Script uses stow's built-in conflict detection
- Backup only created if files are being replaced
- Brewfile generation is optional (runs last)

## Migration Notes

- Existing ~/.gitconfig.local will NOT be overwritten if it exists
- Script extracts current delta settings before overwriting
- All backups timestamped to prevent overwrite

## Rollback Procedure

If issues occur after running sync-fixes.sh:

```bash
# Restore from backup
BACKUP_DIR=$(ls -td ~/.dotfiles_backup_* | head -1)
cp "$BACKUP_DIR/.gitconfig" ~/.gitconfig
cp "$BACKUP_DIR/.bash_profile" ~/.bash_profile
# etc.

# Or unstow packages
cd /Users/brennon/AIProjects/ai-workspaces/dotfiles
stow -D git bash npm ghostty
```

## References

- Original research: `thoughts/shared/research/2025-12-04-dotfiles-sync-check.md`
- Existing check script: `scripts/check-symlinks.sh`
- Existing health check: `scripts/health-check.sh`
- Stow utility functions: `scripts/lib/utils.sh`
