#!/usr/bin/env bash

# ==============================================================================
# Install Script Diagnostic Tool
# ==============================================================================
# This script helps diagnose issues with the dotfiles installation process.
# ==============================================================================

set -eo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

success() {
    echo -e "${GREEN}${BOLD}✓${NC} $1"
}

section() {
    echo -e "\n${BLUE}${BOLD}===${NC} ${BOLD}$1${NC} ${BLUE}${BOLD}===${NC}\n"
}

# Test arithmetic expansion in different contexts
test_arithmetic() {
    section "Testing Arithmetic Expansion"

    info "Testing basic arithmetic expansion..."
    if bash -c 'backed_up=0; (( backed_up++ )); echo $backed_up'; then
        success "Basic arithmetic expansion works"
    else
        error "Basic arithmetic expansion failed"
        return 1
    fi

    info "Testing arithmetic in function context..."
    if bash -c '
    test_func() {
        local backed_up=0
        (( backed_up++ ))
        echo "backed_up: $backed_up"
        return 0
    }
    test_func
    '; then
        success "Arithmetic in function context works"
    else
        error "Arithmetic in function context failed"
        return 1
    fi

    info "Testing arithmetic with local variable scope..."
    if bash -c '
    backup_test() {
        local files=("/etc/hosts")
        local backed_up=0
        for file in "${files[@]}"; do
            if [ -f "$file" ]; then
                (( backed_up++ ))
            fi
        done
        echo "Final backed_up: $backed_up"
        return 0
    }
    backup_test
    '; then
        success "Arithmetic with local variable scope works"
    else
        error "Arithmetic with local variable scope failed"
        return 1
    fi
}

# Test the exact problematic function from install.sh
test_backup_function() {
    section "Testing Backup Function"

    info "Testing the exact backup function pattern from install.sh..."

    if bash -c '
    backup_existing_test() {
        local files=("$HOME/.bashrc")
        local backed_up=0

        for file in "${files[@]}"; do
            if [ -e "$file" ] && [ ! -L "$file" ]; then
                echo "Would backup: $file"
                cp "$file" "/tmp/test_backup_$(basename "$file")" 2>/dev/null || true
                (( backed_up++ ))
                echo "backed_up is now: $backed_up"
            fi
        done

        echo "Final backed_up count: $backed_up"
        return 0
    }

    backup_existing_test
    '; then
        success "Backup function pattern works"
    else
        error "Backup function pattern failed"
        return 1
    fi
}

# Test shell compatibility
test_shell_compatibility() {
    section "Testing Shell Compatibility"

    info "Current shell: $SHELL"
    info "Bash version: $(bash --version | head -1)"

    # Test if running in bash vs being sourced by other shells
    if [ "$BASH_VERSION" ]; then
        success "Running in bash (version $BASH_VERSION)"
    else
        warn "Not running in bash! Current shell: $0"
    fi

    # Test if bash has strict mode issues
    info "Testing bash strict mode behavior..."
    if bash -c 'set -e; backed_up=0; backed_up=$((backed_up + 1)); echo "Strict mode works: $backed_up"'; then
        success "Strict mode arithmetic works"
    else
        error "Strict mode arithmetic failed"
        return 1
    fi
}

# Test file system operations
test_file_operations() {
    section "Testing File Operations"

    info "Testing backup file operations..."

    local test_file="/tmp/test_dotfile_$$"
    local backup_dir="/tmp/test_backup_$$"

    # Create test file
    echo "test content" > "$test_file"

    # Test backup operation
    mkdir -p "$backup_dir"
    if cp "$test_file" "$backup_dir/"; then
        success "File copy operation works"
    else
        error "File copy operation failed"
        return 1
    fi

    # Cleanup
    rm -f "$test_file"
    rm -rf "$backup_dir"

    success "File operations test completed"
}

# Test dotfiles directory structure
test_dotfiles_structure() {
    section "Testing Dotfiles Structure"

    local dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    info "Dotfiles directory: $dotfiles_dir"

    if [ ! -d "$dotfiles_dir" ]; then
        error "Dotfiles directory not found"
        return 1
    fi

    info "Checking for package directories..."
    local package_count=0
    for dir in "$dotfiles_dir"/*/; do
        if [ -d "$dir" ]; then
            local pkg=$(basename "$dir")
            if [ "$pkg" != "scripts" ] && [ "$pkg" != ".git" ]; then
                info "Found package: $pkg"
                ((package_count++))
            fi
        fi
    done

    success "Found $package_count packages"
}

# Main diagnostic function
main() {
    section "Dotfiles Installation Diagnostic"

    info "Starting comprehensive diagnostic..."

    local failed_tests=0

    # Run all tests
    test_arithmetic || ((failed_tests++))
    test_shell_compatibility || ((failed_tests++))
    test_file_operations || ((failed_tests++))
    test_backup_function || ((failed_tests++))
    test_dotfiles_structure || ((failed_tests++))

    # Summary
    section "Diagnostic Summary"

    if [ $failed_tests -eq 0 ]; then
        success "All diagnostic tests passed!"
        info "The issue might be in the install.sh script execution context."
        info "Try running: DEBUG=1 ./install.sh --all"
        return 0
    else
        error "$failed_tests diagnostic test(s) failed"
        info "The above failures indicate the root cause of the installation issue."
        return 1
    fi
}

# Run diagnostic
main "$@"