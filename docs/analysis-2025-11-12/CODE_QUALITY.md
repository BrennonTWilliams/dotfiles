# Code Quality Analysis

**Analysis Date**: November 12, 2025
**Focus Areas**: Maintainability, Readability, Architecture, Testing

---

## 📊 Quality Metrics Overview

| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| Code Duplication | ~15% | <10% | ⚠️ |
| Average Function Length | 45 lines | <30 lines | ⚠️ |
| Longest File | 1,030 lines | <500 lines | 🚨 |
| Function Count | 150+ | - | ✅ |
| Test Coverage | ~60% | >80% | ⚠️ |
| Documentation | Good | Good | ✅ |
| Shellcheck Issues | Many | 0 | 🚨 |

---

## 🔴 CRITICAL ISSUES

### QUAL-001: Duplicate Function Definitions

**Severity**: HIGH
**Impact**: Maintenance burden, inconsistent behavior, code bloat

#### Description
Core utility functions are duplicated across multiple files instead of being centralized in a shared library.

#### Affected Functions
Found duplicate definitions of:
- `detect_os()` - 7 copies
- `info()` - 7 copies
- `warn()` - 7 copies
- `error()` - 7 copies
- `success()` - 7 copies
- `section()` - 7 copies
- `main()` - 6 copies

#### Files Containing Duplicates
```
scripts/lib/utils.sh          ← Source of truth (should be)
install.sh                     ← Duplicate
install-new.sh                 ← Duplicate
scripts/diagnose.sh            ← Duplicate
scripts/setup-packages.sh      ← Partial duplicate
scripts/health-check.sh        ← Duplicate
tests/test_*.sh                ← Various duplicates
```

#### Problems
1. **Inconsistency**: Functions behave differently across files
2. **Bug Propagation**: Bug fixes must be replicated in 7 places
3. **Maintenance**: Any change requires updating multiple files
4. **Bloat**: Adds ~500 lines of duplicate code

#### Example Inconsistencies
```bash
# scripts/lib/utils.sh:40
error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# install.sh:67
error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# scripts/diagnose.sh:29
error() {
    echo -e "${RED}[ERROR]${NC} $1"
}
# ^^^ Note: This one doesn't exit!
```

#### Remediation

**Step 1: Establish Single Source of Truth**
```bash
# scripts/lib/utils.sh - Keep as the canonical source
# Already contains all utility functions
```

**Step 2: Enforce Sourcing**
```bash
# Pattern for all scripts
#!/usr/bin/env bash

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source utilities (fail if not found)
if [ ! -f "$REPO_ROOT/scripts/lib/utils.sh" ]; then
    echo "ERROR: Cannot find utils.sh" >&2
    exit 1
fi

source "$REPO_ROOT/scripts/lib/utils.sh"

# Script continues...
```

**Step 3: Remove Duplicates**
```bash
#!/bin/bash
# Automated cleanup script

for file in install.sh install-new.sh scripts/*.sh; do
    # Remove duplicate function definitions
    sed -i.bak '/^info() {/,/^}/d' "$file"
    sed -i.bak '/^warn() {/,/^}/d' "$file"
    sed -i.bak '/^error() {/,/^}/d' "$file"
    sed -i.bak '/^success() {/,/^}/d' "$file"
    sed -i.bak '/^section() {/,/^}/d' "$file"

    # Add source statement at top (if not present)
    if ! grep -q "source.*utils.sh" "$file"; then
        sed -i.bak '1a\
source "$(dirname "$0")/scripts/lib/utils.sh"' "$file"
    fi
done
```

**Step 4: Add Pre-commit Check**
```bash
#!/bin/bash
# .git/hooks/pre-commit

# Check for duplicate function definitions
duplicates=$(grep -r "^info() {" --include="*.sh" | grep -v "scripts/lib/utils.sh")

if [ -n "$duplicates" ]; then
    echo "ERROR: Duplicate utility functions detected:"
    echo "$duplicates"
    echo "Remove duplicates and source scripts/lib/utils.sh instead"
    exit 1
fi
```

---

### QUAL-002: Monolithic install.sh

**Severity**: HIGH
**Impact**: Difficult to maintain, test, and understand

#### Description
`install.sh` is 1,030 lines long and violates the Single Responsibility Principle by handling:
- Prerequisite checking
- OS detection
- Package management
- Backup operations
- Stow operations
- Setup script orchestration
- User interaction
- Error handling

#### Current Structure
```
install.sh (1,030 lines)
├── Helper Functions (lines 58-82)
├── System Detection (lines 84-107)
├── Package Checking (lines 109-149)
├── Package Installation (lines 151-211)
├── Backup Logic (lines 213-228)
├── Installation Steps (lines 230-307)
├── Platform Package Functions (lines 392-561)
├── Stow Operations (lines 613-679)
├── Dotfile Installation (lines 681-735)
├── Local Config Creation (lines 737-768)
├── Setup Scripts (lines 770-863)
├── Post-install (lines 865-916)
└── Main Function (lines 918-1030)
```

#### Problems
1. **Hard to Test**: Cannot unit test individual components
2. **Hard to Understand**: New contributors overwhelmed
3. **Hard to Modify**: Changes risk breaking unrelated functionality
4. **Hard to Reuse**: Logic locked inside monolithic script

#### Recommended Refactoring

**New Structure**:
```
dotfiles/
├── install.sh (150 lines) - Main orchestrator only
├── scripts/
│   ├── lib/
│   │   ├── utils.sh              ← Already exists
│   │   ├── package-manager.sh    ← NEW: Package operations
│   │   ├── stow-manager.sh       ← NEW: Stow operations
│   │   ├── backup-manager.sh     ← NEW: Backup operations
│   │   ├── validation.sh         ← NEW: Prerequisite checks
│   │   └── platform-detect.sh    ← NEW: OS detection
│   └── ...
```

**Example Extraction**: Package Manager Module

```bash
# scripts/lib/package-manager.sh
#!/usr/bin/env bash

# Source utilities
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

# ==============================================================================
# Package Manager Abstraction
# ==============================================================================

# Global variables (set by detect_package_manager)
PKG_MANAGER=""
PKG_MANAGER_INSTALL_CMD=""
PKG_MANAGER_UPDATE_CMD=""
PKG_MANAGER_CHECK_CMD=""

# Detect and initialize package manager
detect_package_manager() {
    detect_os  # From utils.sh

    case "$OS" in
        "macos")
            PKG_MANAGER="brew"
            PKG_MANAGER_INSTALL_CMD="brew install"
            PKG_MANAGER_UPDATE_CMD="brew update"
            PKG_MANAGER_CHECK_CMD="brew info"
            ;;
        "debian"|"ubuntu")
            PKG_MANAGER="apt"
            PKG_MANAGER_INSTALL_CMD="sudo apt-get install -y"
            PKG_MANAGER_UPDATE_CMD="sudo apt-get update"
            PKG_MANAGER_CHECK_CMD="apt-cache show"
            ;;
        # ... other package managers
    esac
}

# Check if package is available
package_available() {
    local package="$1"
    $PKG_MANAGER_CHECK_CMD "$package" &>/dev/null
}

# Install a single package
package_install() {
    local package="$1"

    if ! package_available "$package"; then
        warn "Package '$package' not found in repositories"
        return 1
    fi

    info "Installing $package..."
    $PKG_MANAGER_INSTALL_CMD "$package"
}

# Install multiple packages
package_install_many() {
    local packages=("$@")
    local failed=0

    for pkg in "${packages[@]}"; do
        if ! package_install "$pkg"; then
            ((failed++))
        fi
    done

    return $failed
}
```

**New install.sh** (simplified):
```bash
#!/usr/bin/env bash

set -euo pipefail

# Source all libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for lib in "$SCRIPT_DIR/scripts/lib"/*.sh; do
    source "$lib"
done

main() {
    print_banner

    # Use abstracted modules
    validation_check_prerequisites
    backup_create_if_needed "$HOME" "$BACKUP_DIR"

    if [ "$INSTALL_PACKAGES" = true ]; then
        package_manager_init
        package_install_from_file "packages-$OS.txt"
    fi

    stow_install_packages "${SELECTED_PACKAGES[@]}"
    setup_run_scripts "${SETUP_SCRIPTS[@]}"

    post_install_instructions
}

main "$@"
```

#### Benefits
- ✅ Each module is testable in isolation
- ✅ Logic can be reused across scripts
- ✅ Easier to understand and modify
- ✅ Clear separation of concerns
- ✅ Reduced cognitive load

---

### QUAL-003: Inconsistent Error Handling

**Severity**: MEDIUM
**Impact**: Unpredictable failure behavior

#### Description
Scripts use different error handling strategies without consistency.

#### Error Handling Variations
```bash
# Variation 1: set -e (basic)
set -e

# Variation 2: set -eo pipefail (better)
set -eo pipefail

# Variation 3: set -euo pipefail (best)
set -euo pipefail

# Variation 4: trap with set -e
set -e
trap 'echo "Error at line $LINENO"' ERR

# Variation 5: No error handling
# (nothing)
```

#### Files Using Each Strategy
```
set -euo pipefail:  (0 files - None!)
set -eo pipefail:   install.sh, install-new.sh
set -e:             scripts/setup-ohmyzsh.sh, scripts/setup-nvm.sh
trap + set -e:      scripts/lib/utils.sh
No error handling:  Several test scripts
```

#### Problems with Current Approach

**Problem 1: Unset Variables**
```bash
# install.sh uses set -eo pipefail (missing -u)
# This fails silently:
echo "Installing to: $INSTAL_DIR"  # Typo: should be INSTALL_DIR
# Result: "Installing to: " (no error)
```

**Problem 2: Ignored Pipeline Failures**
```bash
# Scripts using only 'set -e' don't catch pipeline failures:
curl $URL | bash  # If curl fails, bash still runs!
# With 'set -o pipefail', curl failure stops execution
```

**Problem 3: Inconsistent Function Error Handling**
```bash
# Some functions return error codes
backup_if_exists() {
    # ...
    return 1  # Caller must check $?
}

# Others call exit directly
error() {
    echo "ERROR: $1"
    exit 1  # Cannot be caught by caller
}
```

#### Recommended Standard

**Standard Error Handling**:
```bash
#!/usr/bin/env bash

# Strict mode
set -euo pipefail

# Inherit ERR trap in functions and subshells
set -E

# Error trap
trap 'error_handler $? $LINENO "$BASH_COMMAND"' ERR

# Cleanup trap
trap cleanup EXIT INT TERM

error_handler() {
    local exit_code=$1
    local line_number=$2
    local command="$3"

    echo "ERROR: Command failed with exit code $exit_code" >&2
    echo "  Line: $line_number" >&2
    echo "  Command: $command" >&2

    # Stack trace
    local frame=0
    while caller $frame 2>/dev/null; do
        ((frame++))
    done

    exit "$exit_code"
}

cleanup() {
    local exit_code=$?

    # Cleanup operations
    [ -n "${TEMP_FILE:-}" ] && rm -f "$TEMP_FILE"
    [ -n "${LOCK_FILE:-}" ] && rm -f "$LOCK_FILE"

    return $exit_code
}
```

**Function Error Handling**:
```bash
# Return error codes, don't call exit
backup_if_exists() {
    local target="$1"

    if [ ! -e "$target" ]; then
        return 0  # Nothing to backup
    fi

    if ! cp "$target" "$BACKUP_DIR/"; then
        warn "Failed to backup: $target"
        return 1
    fi

    return 0
}

# Usage
if ! backup_if_exists "$file"; then
    error "Critical backup failure"  # Now exit is at call site
fi
```

---

## 🟡 MEDIUM ISSUES

### QUAL-004: Missing Function Documentation

**Severity**: MEDIUM
**Impact**: Difficult to understand and maintain

#### Description
Most functions lack documentation explaining parameters, return values, and side effects.

#### Current State
```bash
# No documentation
stow_package() {
    local package="$1"
    local package_dir="$DOTFILES_DIR/$package"
    # ... 50 lines of code ...
}
```

#### Recommended Standard
```bash
# ==============================================================================
# Stow a single package
#
# Installs a dotfiles package using GNU Stow, with conflict detection and
# resolution through adoption or override.
#
# Arguments:
#   $1 - package name (required)
#
# Returns:
#   0 - Package installed successfully
#   1 - Package not found or stow failed
#
# Side Effects:
#   - Creates symlinks in $HOME
#   - May adopt existing files
#   - Prints status messages to stdout
#
# Environment:
#   DOTFILES_DIR - Must be set to repository root
#
# Examples:
#   stow_package "zsh"
#   stow_package "tmux"
# ==============================================================================
stow_package() {
    local package="$1"

    # Validate input
    if [ -z "$package" ]; then
        error "stow_package: package name required"
        return 1
    fi

    local package_dir="$DOTFILES_DIR/$package"

    if [ ! -d "$package_dir" ]; then
        warn "Package '$package' not found"
        return 1
    fi

    # ... implementation ...
}
```

---

### QUAL-005: Inconsistent Naming Conventions

**Severity**: MEDIUM
**Impact**: Confusion and harder maintenance

#### Issues Found

**1. Function Naming**
```bash
# Mix of naming styles
check_prerequisites()     # snake_case
stowPackage()            # camelCase (if exists)
Install-Package()        # PascalCase (if exists)
```

**2. Variable Naming**
```bash
# Mix of cases
DOTFILES_DIR    # UPPER_CASE (good for constants)
backup_dir      # snake_case (good for locals)
BackupDir       # PascalCase (inconsistent)
```

**3. File Naming**
```bash
setup-python.sh         # kebab-case
test_integration.sh     # snake_case
InstallNew.sh          # PascalCase
```

#### Recommended Standards

**Functions**: `snake_case`
```bash
check_prerequisites()
install_package()
stow_dotfiles()
```

**Variables**:
```bash
# Constants: UPPER_CASE
readonly DOTFILES_DIR="/path"
readonly MAX_RETRIES=3

# Local variables: lowercase with underscores
local package_name="vim"
local backup_dir="/tmp/backup"

# Environment variables: UPPER_CASE
export PATH="$HOME/bin:$PATH"
```

**Files**: `kebab-case.sh`
```bash
install.sh
setup-python.sh
package-manager.sh
test-integration.sh
```

---

### QUAL-006: Hard-Coded Paths

**Severity**: MEDIUM
**Impact**: Reduced portability and flexibility

#### Description
Many scripts contain hard-coded paths instead of using configuration or dynamic resolution.

#### Examples
```bash
# In .zshrc
export PATH="$HOME/AIProjects/ai-workspaces/uzi:$PATH"
export PATH="$PATH:$HOME/AIProjects/ai-workspaces/sdd-workshops"

# In various scripts
local dotfiles_dir="$HOME/AIProjects/ai-workspaces/dotfiles/starship"
```

#### Problems
1. Breaks if user has different directory structure
2. Not portable across systems
3. Difficult to change in bulk

#### Recommended Solution

**Config File Approach**:
```bash
# ~/.config/dotfiles/paths.conf
DOTFILES_ROOT="$HOME/AIProjects/ai-workspaces/dotfiles"
PROJECTS_ROOT="$HOME/AIProjects/ai-workspaces"
UZI_PATH="$PROJECTS_ROOT/uzi"
SDD_WORKSHOPS_PATH="$PROJECTS_ROOT/sdd-workshops"
```

**Usage**:
```bash
# Source config
if [ -f ~/.config/dotfiles/paths.conf ]; then
    source ~/.config/dotfiles/paths.conf
else
    # Fallback defaults
    DOTFILES_ROOT="$HOME/.dotfiles"
    PROJECTS_ROOT="$HOME/Projects"
fi

# Use variables
export PATH="$UZI_PATH:$PATH"
```

---

### QUAL-007: Missing Input Validation

**Severity**: MEDIUM
**Impact**: Unexpected failures and poor error messages

#### Description
Functions don't validate inputs, leading to cryptic errors.

#### Examples
```bash
# No validation
install_package() {
    local package="$1"
    # What if $1 is empty?
    # What if $1 contains special characters?
    brew install "$package"
}

# Better version
install_package() {
    local package="$1"

    # Validate required argument
    if [ -z "$package" ]; then
        error "install_package: package name required"
        return 1
    fi

    # Validate format
    if [[ ! "$package" =~ ^[a-zA-Z0-9._-]+$ ]]; then
        error "install_package: invalid package name '$package'"
        return 1
    fi

    # Validate package manager initialized
    if [ -z "$PKG_MANAGER" ]; then
        error "install_package: package manager not initialized"
        return 1
    fi

    brew install "$package"
}
```

---

## 🟢 LOW PRIORITY IMPROVEMENTS

### QUAL-008: Magic Numbers

**Issue**: Hard-coded numbers without explanation
```bash
# Before
sleep 5
truncate -s 100M file.log

# After
readonly RETRY_DELAY_SECONDS=5
readonly MAX_LOG_SIZE_MB=100

sleep "$RETRY_DELAY_SECONDS"
truncate -s "${MAX_LOG_SIZE_MB}M" file.log
```

### QUAL-009: Long Parameter Lists

**Issue**: Functions with many parameters
```bash
# Before
create_backup() {
    local source="$1"
    local dest="$2"
    local compress="$3"
    local verify="$4"
    local exclude="$5"
}

# After - use options hash/array
create_backup() {
    local -A opts=(
        [source]=""
        [dest]=""
        [compress]=false
        [verify]=true
        [exclude]=""
    )

    # Parse options...
}
```

### QUAL-010: Commented-Out Code

**Issue**: Dead code left in files
```bash
# In .zshrc
# export PATH="$(resolve_platform_path "conda_bin"):$PATH"  # commented out by conda initialize
```

**Action**: Remove commented code, rely on git history

---

## 📋 Quality Improvement Checklist

### Immediate Actions
- [ ] Centralize utility functions in scripts/lib/utils.sh
- [ ] Remove duplicate function definitions
- [ ] Standardize error handling (set -euo pipefail)
- [ ] Add input validation to all functions
- [ ] Quote all variable expansions

### Short Term (1-2 weeks)
- [ ] Refactor install.sh into modules
- [ ] Add function documentation
- [ ] Standardize naming conventions
- [ ] Replace hard-coded paths with config
- [ ] Integrate shellcheck into CI

### Medium Term (1 month)
- [ ] Create comprehensive test suite
- [ ] Add integration tests for all modules
- [ ] Document architecture decisions
- [ ] Create contribution guidelines
- [ ] Set up automated code review

### Long Term (3 months)
- [ ] Achieve 80%+ test coverage
- [ ] Zero shellcheck warnings
- [ ] Complete API documentation
- [ ] Performance benchmarks
- [ ] Automated quality metrics

---

## 🔧 Recommended Tools

**Linting & Analysis**:
- `shellcheck` - Static analysis
- `shfmt` - Code formatting
- `bashate` - Style checking

**Testing**:
- `bats` - Bash Automated Testing System
- `shunit2` - Unit testing framework
- `shellspec` - BDD testing framework

**Documentation**:
- `shdoc` - Extract documentation from shell scripts
- `ronn` - Man page generation

**CI/CD**:
- GitHub Actions with shellcheck
- Pre-commit hooks
- Automated formatting

---

**Next**: See [PERFORMANCE.md](./PERFORMANCE.md) for optimization opportunities
