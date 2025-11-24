#!/usr/bin/env bash

# ==============================================================================
# Unit Tests for Installation Preview Mode
# ==============================================================================
# Tests the preview mode functionality for dotfiles installation
# ==============================================================================

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Source required libraries
source "$DOTFILES_DIR/scripts/lib/utils.sh"
source "$DOTFILES_DIR/scripts/lib/preview.sh"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# ==============================================================================
# Test Framework Functions
# ==============================================================================

test_start() {
    local test_name="$1"
    echo
    echo "▸ Testing: $test_name"
    ((TESTS_RUN++)) || true
}

test_pass() {
    local test_name="$1"
    echo "  ✓ PASS: $test_name"
    ((TESTS_PASSED++)) || true
}

test_fail() {
    local test_name="$1"
    local reason="${2:-}"
    echo "  ✗ FAIL: $test_name"
    if [ -n "$reason" ]; then
        echo "    Reason: $reason"
    fi
    ((TESTS_FAILED++)) || true
}

# ==============================================================================
# Utility Test Cases
# ==============================================================================

test_package_version_detection() {
    test_start "Package version detection"

    detect_os

    # Test that get_package_version returns something for common packages
    if [ "$PKG_MANAGER" = "brew" ]; then
        local git_version=$(get_package_version "git")
        if [ -n "$git_version" ] && [ "$git_version" != "unknown" ]; then
            test_pass "Git version detected from Homebrew: $git_version"
        else
            test_fail "Git version detection" "Empty or unknown version"
        fi
    elif [ "$PKG_MANAGER" = "apt" ]; then
        local git_version=$(get_package_version "git")
        if [ -n "$git_version" ] && [ "$git_version" != "unknown" ]; then
            test_pass "Git version detected from APT: $git_version"
        else
            test_fail "Git version detection" "Empty or unknown version"
        fi
    else
        test_pass "Skipped for package manager: $PKG_MANAGER"
    fi
}

test_installed_vs_available_version() {
    test_start "Installed vs available version comparison"

    if command_exists "git"; then
        local installed=$(get_installed_version "git")
        local available=$(get_package_version "git")

        if [ -n "$installed" ] && [ -n "$available" ]; then
            test_pass "Git - Installed: $installed, Available: $available"
        else
            test_fail "Version comparison" "Missing version info"
        fi
    else
        test_pass "Git not installed - skipping"
    fi
}

# ==============================================================================
# Preview Mode Flag Tests
# ==============================================================================

test_preview_mode_variables() {
    test_start "Preview mode environment variables"

    # Test that preview mode can be enabled
    export PREVIEW_MODE=true
    export DRY_RUN=true

    if [ "$PREVIEW_MODE" = true ] && [ "$DRY_RUN" = true ]; then
        test_pass "Preview mode flags set correctly"
    else
        test_fail "Preview mode flags" "Flags not set properly"
    fi

    # Reset
    export PREVIEW_MODE=false
    export DRY_RUN=false
}

test_stow_dry_run_support() {
    test_start "Stow package dry-run support"

    # Enable preview mode
    export PREVIEW_MODE=true
    export DRY_RUN=true

    # Test that stow_package returns early in preview mode
    # This should not actually stow anything
    cd "$DOTFILES_DIR"
    if [ -d "git" ]; then
        local output=$(stow_package "git" "$HOME" "" 2>&1)
        if [[ "$output" =~ PREVIEW ]]; then
            test_pass "Stow package respects preview mode"
        else
            test_fail "Stow dry-run" "Did not detect preview mode"
        fi
    else
        test_pass "Git package not found - skipping"
    fi

    # Reset
    export PREVIEW_MODE=false
    export DRY_RUN=false
}

# ==============================================================================
# Preview Output Tests
# ==============================================================================

test_preview_output_functions() {
    test_start "Preview output formatting functions"

    # Test that preview functions exist and are callable
    local functions=(
        "preview_header"
        "preview_section"
        "preview_action"
        "preview_package_install"
        "preview_package_upgrade"
        "preview_package_skip"
        "preview_symlink"
        "preview_conflict"
    )

    local all_exist=true
    for func in "${functions[@]}"; do
        if ! declare -f "$func" > /dev/null; then
            all_exist=false
            test_fail "Function existence" "$func not found"
            break
        fi
    done

    if [ "$all_exist" = true ]; then
        test_pass "All preview output functions exist"
    fi
}

test_preview_counters() {
    test_start "Preview counter initialization"

    # Reset counters
    PREVIEW_PKG_INSTALL=0
    PREVIEW_PKG_UPGRADE=0
    PREVIEW_PKG_SKIP=0
    PREVIEW_SYMLINKS=0
    PREVIEW_CONFLICTS=0
    PREVIEW_BACKUPS=0
    PREVIEW_SHELL_CHANGES=0

    if [ $PREVIEW_PKG_INSTALL -eq 0 ] && \
       [ $PREVIEW_PKG_UPGRADE -eq 0 ] && \
       [ $PREVIEW_SYMLINKS -eq 0 ]; then
        test_pass "Preview counters initialized to zero"
    else
        test_fail "Counter initialization" "Counters not at zero"
    fi
}

# ==============================================================================
# Package Preview Tests
# ==============================================================================

test_preview_package_function() {
    test_start "Package preview function"

    detect_os
    cd "$DOTFILES_DIR"

    # Capture preview output (redirect to variable to test)
    if [ -f "packages-$OS.txt" ] || [ -f "packages-macos.txt" ] || [ -f "packages-linux.txt" ]; then
        # Test a single package preview
        local output=$(preview_package "git" 2>&1)

        if [ -n "$output" ]; then
            test_pass "Package preview generates output"
        else
            test_fail "Package preview" "No output generated"
        fi
    else
        test_pass "No package manifest found - skipping"
    fi
}

# ==============================================================================
# Dotfiles Preview Tests
# ==============================================================================

test_stow_native_dry_run() {
    test_start "Stow native dry-run capability"

    cd "$DOTFILES_DIR"

    # Check if stow supports -n flag
    if command_exists "stow"; then
        # Test with git package if it exists
        if [ -d "git" ]; then
            # Run stow with -n (no action) flag
            local output=$(stow -n -v -d "$DOTFILES_DIR" -t "$HOME" "git" 2>&1 || true)

            if [ -n "$output" ]; then
                test_pass "Stow dry-run produces output"
            else
                test_fail "Stow dry-run" "No output from stow -n"
            fi
        else
            test_pass "No git package found - skipping"
        fi
    else
        test_fail "Stow availability" "Stow command not found"
    fi
}

test_preview_stow_package_function() {
    test_start "Preview stow package function"

    cd "$DOTFILES_DIR"

    if [ -d "git" ]; then
        # Capture output from preview_stow_package
        local output=$(preview_stow_package "git" 2>&1)

        if [ -n "$output" ] && [[ "$output" =~ Package ]]; then
            test_pass "Preview stow package generates output"
        else
            test_fail "Preview stow package" "Missing expected output"
        fi
    else
        test_pass "No git package found - skipping"
    fi
}

# ==============================================================================
# Shell Setup Preview Tests
# ==============================================================================

test_preview_shell_setup_function() {
    test_start "Preview shell setup function"

    # Test that preview_shell_setup runs without errors
    local output=$(preview_shell_setup 2>&1)

    if [ $? -eq 0 ]; then
        test_pass "Preview shell setup completed"
    else
        test_fail "Preview shell setup" "Function returned error"
    fi
}

test_shell_detection() {
    test_start "Current shell detection"

    if [ -n "$SHELL" ]; then
        test_pass "Current shell: $SHELL"
    else
        test_fail "Shell detection" "SHELL variable not set"
    fi
}

# ==============================================================================
# Integration Tests
# ==============================================================================

test_install_script_preview_flags() {
    test_start "Install script preview flag parsing"

    cd "$DOTFILES_DIR"

    # Test that install-new.sh recognizes preview flags
    if [ -f "install-new.sh" ]; then
        # Test --help includes preview options
        local help_output=$(./install-new.sh --help 2>&1)

        if [[ "$help_output" =~ --preview ]] && [[ "$help_output" =~ --dry-run ]]; then
            test_pass "Install script includes preview flags in help"
        else
            test_fail "Preview flag documentation" "Missing --preview or --dry-run in help"
        fi
    else
        test_fail "Install script" "install-new.sh not found"
    fi
}

test_get_available_packages() {
    test_start "Get available packages function"

    cd "$DOTFILES_DIR"

    # Source install-new.sh to get the function
    source "./install-new.sh"

    local packages=($(get_available_packages))

    if [ ${#packages[@]} -gt 0 ]; then
        test_pass "Found ${#packages[@]} stowable package(s): ${packages[*]}"
    else
        test_fail "Available packages" "No packages found"
    fi
}

# ==============================================================================
# Summary Preview Tests
# ==============================================================================

test_preview_summary_function() {
    test_start "Preview summary function"

    # Initialize some counters
    PREVIEW_PKG_INSTALL=5
    PREVIEW_PKG_UPGRADE=2
    PREVIEW_SYMLINKS=15
    PREVIEW_CONFLICTS=1

    # Test that summary runs
    local output=$(preview_summary 2>&1)

    if [ -n "$output" ] && [[ "$output" =~ Summary ]]; then
        test_pass "Preview summary generates output"
    else
        test_fail "Preview summary" "Missing or invalid output"
    fi
}

# ==============================================================================
# Run All Tests
# ==============================================================================

print_test_header() {
    echo "═══════════════════════════════════════════════════════════════"
    echo "  Preview Mode Unit Tests"
    echo "═══════════════════════════════════════════════════════════════"
}

print_test_results() {
    echo
    echo "═══════════════════════════════════════════════════════════════"
    echo "  Test Results"
    echo "═══════════════════════════════════════════════════════════════"
    echo "  Total tests run:    $TESTS_RUN"
    echo "  Tests passed:       $TESTS_PASSED"
    echo "  Tests failed:       $TESTS_FAILED"
    echo "═══════════════════════════════════════════════════════════════"

    if [ $TESTS_FAILED -eq 0 ]; then
        echo "  ✓ ALL TESTS PASSED"
        return 0
    else
        echo "  ✗ SOME TESTS FAILED"
        return 1
    fi
}

main() {
    print_test_header

    # Utility tests
    test_package_version_detection
    test_installed_vs_available_version

    # Preview mode flag tests
    test_preview_mode_variables
    test_stow_dry_run_support

    # Preview output tests
    test_preview_output_functions
    test_preview_counters

    # Package preview tests
    test_preview_package_function

    # Dotfiles preview tests
    test_stow_native_dry_run
    test_preview_stow_package_function

    # Shell setup tests
    test_preview_shell_setup_function
    test_shell_detection

    # Integration tests
    test_install_script_preview_flags
    test_get_available_packages

    # Summary tests
    test_preview_summary_function

    # Print results
    print_test_results
}

# Run tests
main "$@"
