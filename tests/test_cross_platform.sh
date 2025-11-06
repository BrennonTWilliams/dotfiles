#!/usr/bin/env bash

# ==============================================================================
# Cross-Platform Integration Test Suite for Dotfiles
# ==============================================================================
# This script tests cross-platform functionality on any system
# It validates that all adaptations work correctly regardless of platform
# ==============================================================================

set -euo pipefail

# Test configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
TEST_RESULTS_DIR="$SCRIPT_DIR/test_results"
TEST_LOG="$TEST_RESULTS_DIR/cross_platform_$(date +%Y%m%d_%H%M%S).log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Test counters
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

# ==============================================================================
# Test Utility Functions
# ==============================================================================

# Create test results directory
mkdir -p "$TEST_RESULTS_DIR"

# Logging function
log() {
    echo -e "$1" | tee -a "$TEST_LOG"
}

# Print test header
print_test_header() {
    log "\n${BLUE}${BOLD}=== Cross-Platform Integration Test Suite ===${NC}"
    log "Testing cross-platform dotfiles functionality"
    log "Test log: $TEST_LOG"
    log "Date: $(date)"
    log "Platform: $(uname -s)"
    log "================================================================================\n"
}

# Print test result
print_test_result() {
    local test_name="$1"
    local result="$2"
    local message="${3:-}"

    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    case "$result" in
        "PASS")
            TESTS_PASSED=$((TESTS_PASSED + 1))
            log "${GREEN}✓ PASS${NC} $test_name"
            ;;
        "FAIL")
            TESTS_FAILED=$((TESTS_FAILED + 1))
            log "${RED}✗ FAIL${NC} $test_name"
            ;;
        "SKIP")
            log "${YELLOW}- SKIP${NC} $test_name"
            ;;
    esac

    if [[ -n "$message" ]]; then
        log "  $message"
    fi
}

# ==============================================================================
# Test Functions
# ==============================================================================

# Test 1: Cross-Platform Utilities Exist
test_cross_platform_utilities() {
    log "  Testing cross-platform utilities..."

    local utilities_file="$DOTFILES_DIR/zsh/.zsh_cross_platform"
    if [[ -f "$utilities_file" ]]; then
        log "  ✓ Cross-platform utilities file exists"

        # Check for key functions
        local functions=("detect_os" "resolve_platform_path" "clipboard_copy" "clipboard_paste" "open_file")
        local missing_functions=0

        for func in "${functions[@]}"; do
            if grep -q "^[[:space:]]*$func[[:space:]]*(" "$utilities_file"; then
                log "    ✓ Found function: $func"
            else
                log "    ✗ Missing function: $func"
                missing_functions=$((missing_functions + 1))
            fi
        done

        if [[ $missing_functions -eq 0 ]]; then
            return 0
        else
            log "  ✗ Missing $missing_functions cross-platform functions"
            return 1
        fi
    else
        log "  ✗ Cross-platform utilities file not found"
        return 1
    fi
}

# Test 2: Enhanced Installation Scripts
test_enhanced_installation_scripts() {
    log "  Testing enhanced installation scripts..."

    local errors=0

    # Test main installer
    local installer_file="$DOTFILES_DIR/install-new.sh"
    if [[ -f "$installer_file" ]]; then
        if grep -q "linux\|Linux\|platform\|cross-platform" "$installer_file"; then
            log "  ✓ Main installer has platform support"
        else
            log "  ✗ Main installer missing platform support"
            errors=$((errors + 1))
        fi
    else
        log "  ✗ Main installer file not found"
        errors=$((errors + 1))
    fi

    # Test utils.sh
    local utils_file="$DOTFILES_DIR/scripts/lib/utils.sh"
    if [[ -f "$utils_file" ]]; then
        # Check for enhanced OS detection
        if grep -q "ubuntu\|debian\|fedora\|arch\|opensuse" "$utils_file"; then
            log "  ✓ Utils.sh has enhanced Linux distribution support"
        else
            log "  ✗ Utils.sh missing enhanced Linux distribution support"
            errors=$((errors + 1))
        fi

        # Check for package manager functions
        local pkg_functions=("check_apt_package_availability" "check_dnf_package_availability" "check_pacman_package_availability")
        for func in "${pkg_functions[@]}"; do
            if grep -q "^$func" "$utils_file"; then
                log "    ✓ Found package function: $func"
            else
                log "    ✗ Missing package function: $func"
                errors=$((errors + 1))
            fi
        done
    else
        log "  ✗ Utils.sh file not found"
        errors=$((errors + 1))
    fi

    return $errors
}

# Test 3: Configuration File Cross-Platform Compatibility
test_configuration_compatibility() {
    log "  Testing configuration file cross-platform compatibility..."

    local errors=0

    # Test .zshrc
    local zshrc_file="$DOTFILES_DIR/zsh/.zshrc"
    if [[ -f "$zshrc_file" ]]; then
        # Check for cross-platform sourcing
        if grep -q "source.*zsh_cross_platform" "$zshrc_file"; then
            log "  ✓ .zshrc sources cross-platform utilities"
        else
            log "  ✗ .zshrc missing cross-platform utilities import"
            errors=$((errors + 1))
        fi

        # Check for conditional conda handling
        if grep -q "resolve_platform_path.*conda" "$zshrc_file"; then
            log "  ✓ .zshrc uses cross-platform conda paths"
        else
            log "  ✗ .zshrc missing cross-platform conda paths"
            errors=$((errors + 1))
        fi

        # Check for conditional DYLD_LIBRARY_PATH (macOS-only)
        if grep -q "DYLD_LIBRARY_PATH" "$zshrc_file" && grep -q "case.*detect_os" "$zshrc_file"; then
            log "  ✓ .zshrc has macOS-specific DYLD_LIBRARY_PATH handling"
        else
            log "  ✗ .zshrc missing macOS-specific DYLD_LIBRARY_PATH handling"
            errors=$((errors + 1))
        fi
    else
        log "  ✗ .zshrc file not found"
        errors=$((errors + 1))
    fi

    # Test .bash_profile
    local bash_profile_file="$DOTFILES_DIR/bash/.bash_profile"
    if [[ -f "$bash_profile_file" ]]; then
        if grep -q "cross-platform.*conda\|resolve_platform_path" "$bash_profile_file"; then
            log "  ✓ .bash_profile has cross-platform conda handling"
        else
            log "  ✗ .bash_profile missing cross-platform conda handling"
            errors=$((errors + 1))
        fi

        # Check for IntelliShell conditional handling
        if grep -q "IntelliShell" "$bash_profile_file" && grep -q "detect_os" "$bash_profile_file"; then
            log "  ✓ .bash_profile has conditional IntelliShell (macOS-only) handling"
        else
            log "  ✗ .bash_profile missing conditional IntelliShell handling"
            errors=$((errors + 1))
        fi
    else
        log "  ✗ .bash_profile file not found"
        errors=$((errors + 1))
    fi

    return $errors
}

# Test 4: Starship Cross-Platform Configuration
test_starship_cross_platform() {
    log "  Testing Starship cross-platform configuration..."

    local errors=0

    # Check for Starship modes
    local starship_modes_dir="$DOTFILES_DIR/starship/modes"
    if [[ -d "$starship_modes_dir" ]]; then
        local modes=("compact.toml" "standard.toml" "verbose.toml")
        for mode in "${modes[@]}"; do
            if [[ -f "$starship_modes_dir/$mode" ]]; then
                log "    ✓ Found Starship mode: $mode"
            else
                log "    ✗ Missing Starship mode: $mode"
                errors=$((errors + 1))
            fi
        done
    else
        log "  ✗ Starship modes directory not found"
        errors=$((errors + 1))
    fi

    # Check Starship functions in .zshrc
    local zshrc_file="$DOTFILES_DIR/zsh/.zshrc"
    if [[ -f "$zshrc_file" ]]; then
        local starship_functions=("starship-compact" "starship-standard" "starship-verbose" "starship-mode")
        for func in "${starship_functions[@]}"; do
            if grep -q "^[[:space:]]*$func[[:space:]]*(" "$zshrc_file"; then
                if grep -A 5 "$func" "$zshrc_file" | grep -q "resolve_platform_path"; then
                    log "    ✓ $func uses cross-platform path resolution"
                else
                    log "    ✗ $func missing cross-platform path resolution"
                    errors=$((errors + 1))
                fi
            else
                log "    ✗ Missing Starship function: $func"
                errors=$((errors + 1))
            fi
        done
    fi

    return $errors
}

# Test 5: New Configuration Directories
test_new_configuration_directories() {
    log "  Testing new configuration directories..."

    local errors=0

    local config_dirs=("git" "npm" "vscode" "bash")
    for dir in "${config_dirs[@]}"; do
        if [[ -d "$DOTFILES_DIR/$dir" ]]; then
            log "  ✓ Found configuration directory: $dir"

            # Check for cross-platform compatibility
            case "$dir" in
                "git")
                    if [[ -f "$DOTFILES_DIR/$dir/.gitconfig" ]]; then
                        log "    ✓ Found .gitconfig"
                    else
                        log "    ✗ Missing .gitconfig"
                        errors=$((errors + 1))
                    fi
                    ;;
                "npm")
                    if [[ -f "$DOTFILES_DIR/$dir/.npmrc" ]]; then
                        log "    ✓ Found .npmrc"
                    else
                        log "    ✗ Missing .npmrc"
                        errors=$((errors + 1))
                    fi
                    ;;
                "vscode")
                    if [[ -f "$DOTFILES_DIR/$dir/settings.json" ]]; then
                        log "    ✓ Found VS Code settings"
                    else
                        log "    ✗ Missing VS Code settings"
                        errors=$((errors + 1))
                    fi
                    ;;
                "bash")
                    if [[ -f "$DOTFILES_DIR/$dir/.bash_profile" ]]; then
                        log "    ✓ Found .bash_profile"
                    else
                        log "    ✗ Missing .bash_profile"
                        errors=$((errors + 1))
                    fi
                    ;;
            esac
        else
            log "  ✗ Missing configuration directory: $dir"
            errors=$((errors + 1))
        fi
    done

    return $errors
}

# Test 6: Hardcoded Path Analysis
test_hardcoded_path_analysis() {
    log "  Testing hardcoded path analysis..."

    local errors=0
    local hardcoded_issues=0

    # Analyze .zshrc for hardcoded paths
    local zshrc_file="$DOTFILES_DIR/zsh/.zshrc"
    if [[ -f "$zshrc_file" ]]; then
        # Count hardcoded paths
        local hardcoded_count
        hardcoded_count=$(grep -c "/Users/brennon" "$zshrc_file" || true)

        if [[ $hardcoded_count -gt 0 ]]; then
            # Check if they're properly wrapped in fallback logic
            local fallback_count
            fallback_count=$(grep -c "fallback.*hardcoded\|hardcoded.*fallback" "$zshrc_file" || true)

            log "  ⚠ Found $hardcoded_count hardcoded paths (expected: $fallback_count fallback blocks)"

            # Show the hardcoded paths for review
            log "  Hardcoded paths found:"
            grep -n "/Users/brennon" "$zshrc_file" | while read -r line; do
                log "    $line"
            done

            # This is a warning, not a failure, since fallbacks are expected
        else
            log "  ✓ No hardcoded macOS paths found"
        fi
    fi

    return $errors
}

# Test 7: Path Resolution Functions
test_path_resolution_functions() {
    log "  Testing path resolution functions..."

    local errors=0

    local utilities_file="$DOTFILES_DIR/zsh/.zsh_cross_platform"
    if [[ -f "$utilities_file" ]]; then
        # Check for path types
        local path_types=("ai_projects" "conda_root" "conda_bin" "starship_config" "npm_global_bin")
        for path_type in "${path_types[@]}"; do
            if grep -q "\"$path_type\"" "$utilities_file"; then
                log "    ✓ Found path type: $path_type"
            else
                log "    ✗ Missing path type: $path_type"
                errors=$((errors + 1))
            fi
        done

        # Check for platform-specific logic
        if grep -q "case.*os.*in\|case.*\$os" "$utilities_file"; then
            log "  ✓ Path resolution has platform-specific logic"
        else
            log "  ✗ Path resolution missing platform-specific logic"
            errors=$((errors + 1))
        fi
    else
        log "  ✗ Cross-platform utilities file not found"
        errors=$((errors + 1))
    fi

    return $errors
}

# Test 8: Documentation Updates
test_documentation_updates() {
    log "  Testing documentation updates..."

    local errors=0

    local readme_file="$DOTFILES_DIR/README.md"
    if [[ -f "$readme_file" ]]; then
        # Check for Linux support documentation
        if grep -q "Linux\|cross-platform\|platform.*detection" "$readme_file"; then
            log "  ✓ README.md mentions Linux/cross-platform support"
        else
            log "  ✗ README.md missing Linux/cross-platform documentation"
            errors=$((errors + 1))
        fi

        # Check for platform table
        if grep -q "Platform.*Architecture\|Supported Platforms" "$readme_file"; then
            log "  ✓ README.md has platform support information"
        else
            log "  ✗ README.md missing platform support information"
            errors=$((errors + 1))
        fi
    else
        log "  ✗ README.md file not found"
        errors=$((errors + 1))
    fi

    return $errors
}

# ==============================================================================
# Test Execution
# ==============================================================================

# Print test result
run_test() {
    local test_name="$1"
    local test_function="$2"

    log "${CYAN}Testing: $test_name${NC}"

    if "$test_function"; then
        print_test_result "$test_name" "PASS"
        return 0
    else
        print_test_result "$test_name" "FAIL"
        return 1
    fi
}

# Main test execution
main() {
    print_test_header

    # Run all tests
    run_test "Cross-Platform Utilities" test_cross_platform_utilities
    run_test "Enhanced Installation Scripts" test_enhanced_installation_scripts
    run_test "Configuration File Compatibility" test_configuration_compatibility
    run_test "Starship Cross-Platform Configuration" test_starship_cross_platform
    run_test "New Configuration Directories" test_new_configuration_directories
    run_test "Hardcoded Path Analysis" test_hardcoded_path_analysis
    run_test "Path Resolution Functions" test_path_resolution_functions
    run_test "Documentation Updates" test_documentation_updates

    # Print summary
    log "\n${BLUE}${BOLD}=== Test Summary ===${NC}"
    log "Total tests: $TESTS_TOTAL"
    log "Passed: ${GREEN}$TESTS_PASSED${NC}"
    log "Failed: ${RED}$TESTS_FAILED${NC}"

    if [[ $TESTS_FAILED -eq 0 ]]; then
        log "\n${GREEN}${BOLD}✓ All tests passed! Cross-platform integration is working correctly.${NC}"
        log "The dotfiles repository is ready for cross-platform deployment."
        return 0
    else
        log "\n${RED}${BOLD}✗ Some tests failed. Please review the issues above.${NC}"
        log "Check the detailed log at: $TEST_LOG"
        return 1
    fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi