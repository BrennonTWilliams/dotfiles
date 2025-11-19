# Architecture Analysis and Recommendations

**Analysis Date**: November 12, 2025
**Focus**: System design, module organization, and architectural patterns

---

## 📐 Current Architecture

### High-Level Structure

```
dotfiles/
├── Core Scripts
│   ├── install.sh (1,030 lines) - Monolithic installer
│   ├── install-new.sh - Alternative installer
│   └── nerd-font-styles.sh - Font testing
│
├── Configuration Packages (Stow)
│   ├── bash/ - Bash configuration
│   ├── git/ - Git configuration
│   ├── ghostty/ - Terminal configuration
│   ├── npm/ - NPM configuration
│   ├── starship/ - Prompt configuration
│   ├── tmux/ - Tmux configuration
│   ├── vim/ - Vim configuration
│   ├── vscode/ - VS Code configuration
│   └── zsh/ - Zsh configuration
│
├── Scripts Library
│   ├── scripts/
│   │   ├── lib/utils.sh - Shared utilities (partially used)
│   │   ├── setup-*.sh - Setup scripts
│   │   ├── diagnose.sh - Diagnostic tool
│   │   └── health-check.sh - Health checker
│   └── Platform-specific
│       ├── macos/ - macOS utilities
│       └── linux/ - Linux utilities
│
├── Testing
│   └── tests/
│       ├── test_*.sh - Various test suites
│       ├── run_*.sh - Test runners
│       └── quick_*.sh - Quick validation
│
└── Documentation
    ├── docs/ - Comprehensive documentation
    ├── README.md
    └── *.md files - Various guides
```

### Current Data Flow

```
User
  │
  ├─> install.sh
  │     │
  │     ├─> Detect OS/Platform
  │     ├─> Check Prerequisites
  │     ├─> Validate Packages
  │     ├─> Backup Existing Files
  │     ├─> Install Packages (package manager)
  │     ├─> Stow Configuration Files
  │     └─> Run Setup Scripts
  │           │
  │           ├─> setup-python.sh
  │           ├─> setup-ohmyzsh.sh
  │           ├─> setup-nvm.sh
  │           ├─> setup-fonts.sh
  │           └─> setup-tmux-plugins.sh
  │
  └─> Configuration Files
        │
        └─> Symlinked to ~/.config/, ~/, etc.
```

---

## 🚨 Architectural Issues

### Issue 1: Monolithic Design

**Problem**: install.sh is a 1,030-line monolith handling multiple responsibilities

**Violations**:
- Single Responsibility Principle (SRP)
- Open/Closed Principle (OCP)
- Dependency Inversion Principle (DIP)

**Impact**:
- Difficult to test individual components
- Hard to understand and modify
- Cannot reuse logic across scripts
- High coupling between concerns

### Issue 2: Code Duplication

**Problem**: Utility functions duplicated across 7+ files

**Violations**:
- DRY (Don't Repeat Yourself)
- Single Source of Truth

**Impact**:
- Inconsistent behavior
- Bug propagation
- Maintenance burden

### Issue 3: Tight Coupling

**Problem**: Direct dependencies between components without abstractions

**Examples**:
- install.sh directly calls brew/apt/pacman
- Scripts hardcode paths to other scripts
- No interface between package managers

**Impact**:
- Difficult to swap implementations
- Hard to mock for testing
- Platform-specific code mixed with business logic

### Issue 4: Missing Abstraction Layers

**Problem**: No clear separation between:
- Business logic and infrastructure
- Platform-specific and generic code
- Configuration and code

**Impact**:
- Non-portable code
- Difficult to extend
- Hard to maintain

---

## ✅ Recommended Architecture

### Layered Architecture

```
┌─────────────────────────────────────────────┐
│         User Interface Layer                │
│  install.sh, CLI commands, interactive UI  │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│      Orchestration Layer (NEW)              │
│  Workflow coordination, state management    │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│         Business Logic Layer (NEW)          │
│  Installation logic, validation, backup     │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│    Infrastructure Abstraction Layer (NEW)   │
│  Package managers, file systems, platform   │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│       Platform/System Layer                 │
│  OS, package managers, file systems         │
└─────────────────────────────────────────────┘
```

### Proposed Module Structure

```
dotfiles/
├── install.sh (150 lines max)
│   └─> Orchestrates workflow using modules
│
├── scripts/
│   ├── lib/
│   │   ├── core/
│   │   │   ├── utils.sh           # Logging, colors, helpers
│   │   │   ├── error-handler.sh   # Error handling
│   │   │   └── validation.sh      # Input validation
│   │   │
│   │   ├── platform/
│   │   │   ├── platform-detect.sh # OS/platform detection
│   │   │   ├── package-manager.sh # Package manager abstraction
│   │   │   └── path-resolver.sh   # Platform-specific paths
│   │   │
│   │   ├── managers/
│   │   │   ├── backup-manager.sh  # Backup operations
│   │   │   ├── stow-manager.sh    # Stow operations
│   │   │   ├── config-manager.sh  # Configuration management
│   │   │   └── state-manager.sh   # Installation state
│   │   │
│   │   └── workflows/
│   │       ├── install-workflow.sh    # Installation orchestration
│   │       ├── update-workflow.sh     # Update orchestration
│   │       └── recovery-workflow.sh   # Recovery orchestration
│   │
│   ├── setup/
│   │   ├── setup-python.sh
│   │   ├── setup-ohmyzsh.sh
│   │   ├── setup-nvm.sh
│   │   ├── setup-fonts.sh
│   │   └── setup-tmux-plugins.sh
│   │
│   └── tools/
│       ├── diagnose.sh
│       ├── health-check.sh
│       ├── benchmark.sh
│       └── security-audit.sh
│
├── config/
│   ├── paths.conf.example     # Path configuration
│   ├── packages.conf.example  # Package lists
│   └── settings.conf.example  # Installation settings
│
├── [Stow packages...]
│
└── tests/
    ├── unit/       # Unit tests for individual modules
    ├── integration/  # Integration tests
    └── e2e/         # End-to-end tests
```

---

## 🏗️ Module Design Specifications

### 1. Core Modules

#### core/utils.sh
```bash
# Logging and output formatting
info()      # Informational messages
warn()      # Warning messages
error()     # Error messages (exits)
success()   # Success messages
section()   # Section headers

# Command utilities
command_exists()    # Check if command available
require_command()   # Require command or fail

# String utilities
trim()         # Trim whitespace
lowercase()    # Convert to lowercase
uppercase()    # Convert to uppercase
```

#### core/error-handler.sh
```bash
# Error handling
setup_error_handling()   # Initialize error traps
error_handler()          # Handle errors
cleanup_handler()        # Cleanup on exit

# Validation helpers
validate_not_empty()     # Validate non-empty string
validate_directory()     # Validate directory exists
validate_file()          # Validate file exists
validate_pattern()       # Validate against pattern
```

#### core/validation.sh
```bash
# Input validation
validate_package_name()  # Package name validation
validate_path()          # Path safety validation
validate_url()           # URL validation
validate_version()       # Version string validation

# System validation
validate_prerequisites()  # Check prerequisites
validate_permissions()    # Check permissions
validate_disk_space()     # Check disk space
```

### 2. Platform Modules

#### platform/platform-detect.sh
```bash
# Platform detection
detect_os()              # Detect OS type
detect_distribution()    # Detect Linux distribution
detect_architecture()    # Detect CPU architecture
detect_shell()           # Detect current shell

# Capabilities
has_systemd()           # Check systemd availability
has_launchd()           # Check launchd availability
supports_feature()      # Check feature support
```

#### platform/package-manager.sh
```bash
# Package Manager Abstraction Interface

# Initialize package manager
pm_init()

# Package operations
pm_update()                    # Update package lists
pm_install(package)            # Install single package
pm_install_many(packages...)   # Install multiple packages
pm_remove(package)             # Remove package
pm_is_installed(package)       # Check if installed
pm_is_available(package)       # Check if available

# Information
pm_list_installed()            # List installed packages
pm_search(pattern)             # Search packages
pm_info(package)              # Get package info

# Implementation detection
_detect_package_manager()
_setup_brew()
_setup_apt()
_setup_dnf()
_setup_pacman()
```

#### platform/path-resolver.sh
```bash
# Path Resolution

# Configuration-driven paths
resolve_path(key)          # Resolve path by key
resolve_paths(keys...)     # Batch resolve paths
get_default_path(key)      # Get default for key

# Platform-specific paths
get_config_dir()           # ~/.config or equivalent
get_local_bin()            # ~/.local/bin or equivalent
get_data_dir()             # Data directory
get_cache_dir()            # Cache directory

# Project paths
get_dotfiles_root()
get_scripts_dir()
get_config_dir()
```

### 3. Manager Modules

#### managers/backup-manager.sh
```bash
# Backup Management

# Initialize backup
backup_init(backup_dir)

# Backup operations
backup_file(file)
backup_directory(dir)
backup_if_exists(path)
backup_stow_conflicts()

# Restore operations
restore_backup(backup_id)
list_backups()
delete_backup(backup_id)

# State
get_backup_dir()
has_backups()
```

#### managers/stow-manager.sh
```bash
# Stow Management

# Initialize stow
stow_init(dotfiles_dir, target_dir)

# Stow operations
stow_package(package)
stow_packages(packages...)
unstow_package(package)
restow_package(package)

# Validation
validate_package(package)
check_conflicts(package)
dry_run_stow(package)

# State
list_stowed_packages()
is_stowed(package)
```

#### managers/config-manager.sh
```bash
# Configuration Management

# Load configuration
config_load(config_file)
config_get(key, default)
config_set(key, value)
config_has(key)

# Configuration files
config_create_local_files()
config_validate()
config_migrate(old_version, new_version)

# Templates
config_render_template(template, vars)
```

#### managers/state-manager.sh
```bash
# Installation State Management

# State operations
state_init()
state_load()
state_save()

# Track installation
state_mark_installed(component)
state_mark_failed(component, reason)
state_is_installed(component)

# Recovery
state_get_failed_components()
state_clear_failures()
state_rollback()
```

### 4. Workflow Modules

#### workflows/install-workflow.sh
```bash
# Installation Workflow

# Main workflow
execute_install_workflow(options)

# Phases
phase_prerequisites()
phase_backup()
phase_packages()
phase_dotfiles()
phase_setup_scripts()
phase_validation()

# Rollback
rollback_on_failure()
```

---

## 🔄 Interaction Patterns

### Pattern 1: Dependency Injection

**Before** (Tight Coupling):
```bash
install_package() {
    brew install "$1"  # Hardcoded dependency on Brew
}
```

**After** (Loose Coupling):
```bash
# Inject package manager abstraction
install_package() {
    local package="$1"
    pm_install "$package"  # Uses abstraction
}

# pm_install is implemented by package-manager.sh
```

### Pattern 2: Strategy Pattern

**Package Manager Strategy**:
```bash
# Each package manager implements the same interface
pm_install() {
    case "$PKG_MANAGER_TYPE" in
        brew)   _pm_brew_install "$@" ;;
        apt)    _pm_apt_install "$@" ;;
        dnf)    _pm_dnf_install "$@" ;;
        pacman) _pm_pacman_install "$@" ;;
        *)      error "Unknown package manager" ;;
    esac
}
```

### Pattern 3: Observer Pattern

**State Change Notifications**:
```bash
# Register observers
on_package_installed() {
    local callback="$1"
    INSTALL_OBSERVERS+=("$callback")
}

# Notify observers
notify_package_installed() {
    local package="$1"
    for observer in "${INSTALL_OBSERVERS[@]}"; do
        "$observer" "$package"
    done
}
```

### Pattern 4: Template Method

**Workflow Template**:
```bash
execute_workflow() {
    pre_workflow_hook
    validate_prerequisites
    execute_phases
    post_workflow_hook
    handle_cleanup
}

# Subclasses implement specific steps
phase_packages() {
    # Install workflow: install packages
    # Update workflow: update packages
}
```

---

## 📦 Package Organization

### Module Dependencies

```
┌─────────────────────────────────────┐
│          install.sh                 │
│         (entry point)               │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│    workflows/install-workflow.sh    │
└──────────────┬──────────────────────┘
               │
    ┌──────────┴──────────┬──────────────────────┐
    │                     │                      │
┌───▼────────┐  ┌────────▼─────────┐  ┌────────▼────────┐
│  managers  │  │     platform     │  │      core       │
│  (4 mods)  │  │     (3 mods)     │  │    (3 mods)     │
└────────────┘  └──────────────────┘  └─────────────────┘
```

### Import Strategy

**Central Import File**:
```bash
# scripts/lib/bootstrap.sh
# Source all libraries in correct order

set -euo pipefail

# Detect library directory
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Core modules (no dependencies)
source "$LIB_DIR/core/utils.sh"
source "$LIB_DIR/core/error-handler.sh"
source "$LIB_DIR/core/validation.sh"

# Platform modules (depend on core)
source "$LIB_DIR/platform/platform-detect.sh"
source "$LIB_DIR/platform/package-manager.sh"
source "$LIB_DIR/platform/path-resolver.sh"

# Managers (depend on core + platform)
source "$LIB_DIR/managers/backup-manager.sh"
source "$LIB_DIR/managers/stow-manager.sh"
source "$LIB_DIR/managers/config-manager.sh"
source "$LIB_DIR/managers/state-manager.sh"

# Workflows (depend on everything)
source "$LIB_DIR/workflows/install-workflow.sh"
```

**Usage in Scripts**:
```bash
#!/usr/bin/env bash

# Single import
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/lib/bootstrap.sh"

# Now all modules available
```

---

## 🧪 Testability Improvements

### Before (Hard to Test)
```bash
# Monolithic function with side effects
install_package() {
    # Directly modifies system
    brew install "$1"

    # Side effects: prints to stdout
    echo "Installed $1"

    # Modifies global state
    INSTALLED_PACKAGES+=("$1")
}
```

### After (Testable)
```bash
# Pure function (no side effects)
validate_package_name() {
    local package="$1"
    [[ "$package" =~ ^[a-zA-Z0-9._-]+$ ]]
}

# Dependency-injected function
install_package() {
    local package="$1"
    local pm_install_fn="${2:-pm_install}"  # Inject dependency

    validate_package_name "$package" || return 1

    "$pm_install_fn" "$package"
}

# Test with mock
test_install_package() {
    mock_pm_install() { echo "mock install $1"; }

    install_package "vim" "mock_pm_install"
    # Can verify without side effects
}
```

---

## 🔐 Security Architecture

### Security Layers

```
┌─────────────────────────────────────┐
│    Input Validation Layer           │
│  Sanitize all external input        │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│    Authorization Layer               │
│  Check permissions before actions   │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│    Execution Layer                   │
│  Execute with least privilege       │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│    Audit Layer                       │
│  Log all security-relevant actions  │
└─────────────────────────────────────┘
```

### Secure by Default

**Principle**: Operations should be secure by default

```bash
# Before: Insecure by default
download_and_execute() {
    curl "$URL" | bash  # No validation
}

# After: Secure by default
download_and_execute() {
    local url="$1"
    local expected_checksum="$2"

    # Require checksum
    if [ -z "$expected_checksum" ]; then
        error "Checksum required for download_and_execute"
    fi

    # Secure temporary file
    local temp_file=$(mktemp)
    trap 'rm -f "$temp_file"' EXIT

    # Download with timeout
    if ! curl --max-time 30 -fsSL "$url" -o "$temp_file"; then
        error "Download failed"
    fi

    # Verify checksum
    if ! echo "$expected_checksum $temp_file" | sha256sum --check; then
        error "Checksum verification failed"
    fi

    # Execute with explicit interpreter
    bash "$temp_file"
}
```

---

## 📈 Performance Architecture

### Caching Strategy

```
┌─────────────────────────────────────┐
│         Cache Layer                 │
├─────────────────────────────────────┤
│  ┌─────────────────────────────┐   │
│  │  Package Availability Cache │   │
│  │  (Associative Array)        │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │  Path Resolution Cache      │   │
│  │  (Associative Array)        │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │  Command Existence Cache    │   │
│  │  (Associative Array)        │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

### Lazy Loading Strategy

```bash
# Lazy initialization pattern
_initialized_conda=false

init_conda() {
    if [ "$_initialized_conda" = false ]; then
        # Heavy initialization here
        eval "$("$conda_bin/conda" 'shell.zsh' 'hook')"
        _initialized_conda=true
    fi
}

# Function wrapper for lazy loading
conda() {
    init_conda
    unset -f conda  # Remove wrapper
    conda "$@"      # Call real command
}
```

---

## 🎯 Migration Strategy

### Phase 1: Create New Modules (Non-Breaking)
1. Create new module structure
2. Implement modules with tests
3. Keep existing code working

### Phase 2: Gradual Migration (Low Risk)
1. Update install.sh to use new modules
2. One module at a time
3. Each change tested independently

### Phase 3: Cleanup (Final)
1. Remove duplicate code
2. Delete old implementations
3. Update documentation

### Backward Compatibility
- Maintain compatibility for external callers
- Deprecation warnings before removal
- Version-based feature flags

---

## 📚 Architectural Principles

### 1. Separation of Concerns
- Each module has single, well-defined responsibility
- Business logic separated from infrastructure
- Platform-specific code isolated

### 2. Dependency Inversion
- Depend on abstractions, not concretions
- Package manager interface, not brew/apt directly
- Inject dependencies where possible

### 3. Open/Closed Principle
- Open for extension (add new package managers)
- Closed for modification (don't change core logic)

### 4. Interface Segregation
- Small, focused interfaces
- Clients depend only on methods they use

### 5. DRY (Don't Repeat Yourself)
- Single source of truth for utilities
- Shared libraries for common operations

### 6. KISS (Keep It Simple, Stupid)
- Simple solutions preferred
- Avoid over-engineering
- Clear > clever

---

## 🔄 Future Considerations

### Extensibility Points

1. **Plugin System**: Allow third-party extensions
2. **Hook System**: Before/after hooks for major operations
3. **Custom Package Managers**: Easy addition of new package managers
4. **Alternative Workflows**: Support different installation strategies

### Scalability

1. **Configuration Management**: Support large-scale deployments
2. **Parallel Execution**: Concurrent operations where safe
3. **Incremental Updates**: Update only changed components

### Maintainability

1. **Automated Testing**: Comprehensive test coverage
2. **Documentation**: Keep architecture docs current
3. **Monitoring**: Usage analytics and error reporting

---

**Next**: See [ACTION_PLAN.md](./ACTION_PLAN.md) for implementation roadmap
