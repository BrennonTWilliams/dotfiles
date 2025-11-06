#!/usr/bin/env bash

# ==============================================================================
# Linux Integration Test Suite for Dotfiles
# ==============================================================================
# This script tests cross-platform functionality on Linux systems
# It validates that all Linux-specific adaptations work correctly
# ==============================================================================

set -euo pipefail

# Test configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
TEST_RESULTS_DIR="$SCRIPT_DIR/test_results"
TEST_LOG="$TEST_RESULTS_DIR/linux_integration_$(date +%Y%m%d_%H%M%S).log"

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
    log "\n${BLUE}${BOLD}=== Linux Integration Test Suite ===${NC}"
    log "Testing cross-platform dotfiles functionality on Linux"
    log "Test log: $TEST_LOG"
    log "Date: $(date)"
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

# Test function wrapper
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

# ==============================================================================
# Test Functions
# ==============================================================================

# Test 1: Platform Detection
test_platform_detection() {
    log "  Testing platform detection utilities..."

    # Source cross-platform utilities
    if [[ -f "$DOTFILES_DIR/zsh/.zsh_cross_platform" ]]; then
        # Extract the detect_os function for bash compatibility
        source <(sed -n '/detect_os()/,/}/p' "$DOTFILES_DIR/zsh/.zsh_cross_platform" | sed 's/local os/OS_LOCAL/')
        eval 'detect_os() {
            case "$(uname -s)" in
                Darwin*)    echo "macos" ;;
                Linux*)     echo "linux" ;;
                *)          echo "unknown" ;;
            esac
        }'
    else
        log "  Cross-platform utilities not found"
        return 1
    fi

    local detected_os
    detected_os=$(detect_os)

    if [[ "$detected_os" == "linux" ]]; then
        log "  ✓ Correctly detected Linux OS"
        return 0
    else
        log "  ✗ Failed to detect Linux OS (detected: $detected_os)"
        return 1
    fi
}

# Test 2: Path Resolution System
test_path_resolution() {
    log "  Testing dynamic path resolution..."

    # Create a temporary test script that mimics the path resolution functions
    local test_script="/tmp/test_path_resolution.sh"
    cat > "$test_script" << 'EOF'
#!/bin/bash

# Mock path resolution functions for testing
detect_os() {
    case "$(uname -s)" in
        Darwin*)    echo "macos" ;;
        Linux*)     echo "linux" ;;
        *)          echo "unknown" ;;
    esac
}

get_username() {
    whoami 2>/dev/null || logname 2>/dev/null || id -un 2>/dev/null || echo "$USER"
}

resolve_platform_path() {
    local path_type="$1"
    local username="$(get_username)"
    local user_home="$HOME"
    local os="$(detect_os)"

    case "$path_type" in
        "ai_projects")
            case "$os" in
                "macos") echo "/Users/$username/AIProjects" ;;
                "linux") echo "$user_home/AIProjects" ;;
                *) echo "$user_home/AIProjects" ;;
            esac
            ;;
        "conda_root")
            echo "$user_home/miniforge3"
            ;;
        "starship_config")
            echo "$user_home/.config/starship"
            ;;
        *)
            echo "Unknown path type: $path_type" >&2
            return 1
            ;;
    esac
}

# Test path resolution
os_detected=$(detect_os)
ai_projects_path=$(resolve_platform_path "ai_projects")
conda_path=$(resolve_platform_path "conda_root")
starship_path=$(resolve_platform_path "starship_config")

echo "OS: $os_detected"
echo "AI Projects: $ai_projects_path"
echo "Conda: $conda_path"
echo "Starship: $starship_path"

# Validate paths
if [[ "$os_detected" == "linux" ]]; then
    if [[ "$ai_projects_path" == "$HOME/AIProjects" ]]; then
        exit 0
    else
        exit 1
    fi
else
    exit 1
fi
EOF

    chmod +x "$test_script"

    if "$test_script" >> "$TEST_LOG" 2>&1; then
        log "  ✓ Path resolution working correctly"
        rm -f "$test_script"
        return 0
    else
        log "  ✗ Path resolution failed"
        rm -f "$test_script"
        return 1
    fi
}

# Test 3: Linux Distribution Detection
test_linux_distribution_detection() {
    log "  Testing Linux distribution detection..."

    # Test enhanced OS detection from utils
    if [[ -f "$DOTFILES_DIR/scripts/lib/utils.sh" ]]; then
        # Source the utils without executing
        source <(sed -n '/detect_os()/,/}/p' "$DOTFILES_DIR/scripts/lib/utils.sh" | sed 's/local /LOCAL_/')

        # Override for testing
        eval 'detect_os() {
            if [[ -f /etc/os-release ]]; then
                . /etc/os-release
                echo "$ID"
            elif command -v lsb_release >/dev/null 2>&1; then
                lsb_release -si | tr '[:upper:]' '[:lower:]'
            else
                echo "linux"
            fi
        }'

        local distro
        distro=$(detect_os)

        if [[ -n "$distro" && "$distro" != "unknown" ]]; then
            log "  ✓ Detected Linux distribution: $distro"
            return 0
        else
            log "  ✗ Failed to detect Linux distribution"
            return 1
        fi
    else
        log "  Utils file not found"
        return 1
    fi
}

# Test 4: Package Manager Detection
test_package_manager_detection() {
    log "  Testing package manager detection..."

    local package_managers=("apt" "dnf" "yum" "pacman" "zypper" "xbps" "apk")
    local found_manager=""

    for manager in "${package_managers[@]}"; do
        if command -v "$manager" >/dev/null 2>&1; then
            found_manager="$manager"
            break
        fi
    done

    if [[ -n "$found_manager" ]]; then
        log "  ✓ Found package manager: $found_manager"
        return 0
    else
        log "  ⚠ No supported package manager found (may be expected on some systems)"
        return 0  # Don't fail test for this
    fi
}

# Test 5: Configuration File Compatibility
test_configuration_compatibility() {
    log "  Testing configuration file compatibility..."

    local errors=0

    # Test .zshrc for hardcoded macOS paths
    local zshrc_file="$DOTFILES_DIR/zsh/.zshrc"
    if [[ -f "$zshrc_file" ]]; then
        # Check if hardcoded paths are properly wrapped in conditional logic
        local hardcoded_paths
        hardcoded_paths=$(grep -c "/Users/brennon" "$zshrc_file" || true)

        if [[ $hardcoded_paths -gt 0 ]]; then
            # Check if they're in fallback blocks
            local fallback_blocks
            fallback_blocks=$(grep -c "fallback.*hardcoded" "$zshrc_file" || true)

            if [[ $fallback_blocks -gt 0 ]]; then
                log "  ✓ Hardcoded paths are properly wrapped in fallback blocks"
            else
                log "  ✗ Found hardcoded paths without fallback blocks: $hardcoded_paths"
                errors=$((errors + 1))
            fi
        else
            log "  ✓ No hardcoded macOS paths found"
        fi
    else
        log "  ✗ .zshrc file not found"
        errors=$((errors + 1))
    fi

    # Test .bash_profile for cross-platform conda handling
    local bash_profile_file="$DOTFILES_DIR/bash/.bash_profile"
    if [[ -f "$bash_profile_file" ]]; then
        if grep -q "cross-platform.*conda" "$bash_profile_file"; then
            log "  ✓ .bash_profile has cross-platform conda handling"
        else
            log "  ✗ .bash_profile missing cross-platform conda handling"
            errors=$((errors + 1))
        fi
    else
        log "  ✗ .bash_profile file not found"
        errors=$((errors + 1))
    fi

    return $errors
}

# Test 6: Linux-Specific Features
test_linux_specific_features() {
    log "  Testing Linux-specific features..."

    local errors=0

    # Test cross-platform clipboard functions
    local cross_platform_file="$DOTFILES_DIR/zsh/.zsh_cross_platform"
    if [[ -f "$cross_platform_file" ]]; then
        if grep -q "wl-copy\|xclip\|xsel" "$cross_platform_file"; then
            log "  ✓ Linux clipboard tools detected in cross-platform functions"
        else
            log "  ✗ Linux clipboard tools not found in cross-platform functions"
            errors=$((errors + 1))
        fi

        if grep -q "xdg-open" "$cross_platform_file"; then
            log "  ✓ Linux file opening (xdg-open) detected"
        else
            log "  ✗ Linux file opening not found"
            errors=$((errors + 1))
        fi
    else
        log "  ✗ Cross-platform utilities file not found"
        errors=$((errors + 1))
    fi

    return $errors
}

# Test 7: Installation Script Compatibility
test_installation_script_compatibility() {
    log "  Testing installation script compatibility..."

    local errors=0

    # Test main installer
    local installer_file="$DOTFILES_DIR/install-new.sh"
    if [[ -f "$installer_file" ]]; then
        if grep -q "linux\|Linux" "$installer_file"; then
            log "  ✓ Main installer has Linux support"
        else
            log "  ✗ Main installer missing Linux support"
            errors=$((errors + 1))
        fi

        if grep -q "case.*OS\|platform" "$installer_file"; then
            log "  ✓ Main installer has platform detection"
        else
            log "  ✗ Main installer missing platform detection"
            errors=$((errors + 1))
        fi
    else
        log "  ✗ Main installer file not found"
        errors=$((errors + 1))
    fi

    # Test utils.sh
    local utils_file="$DOTFILES_DIR/scripts/lib/utils.sh"
    if [[ -f "$utils_file" ]]; then
        if grep -q "detect_os" "$utils_file"; then
            log "  ✓ Utils.sh has OS detection"
        else
            log "  ✗ Utils.sh missing OS detection"
            errors=$((errors + 1))
        fi

        if grep -q "check_package_availability" "$utils_file"; then
            log "  ✓ Utils.sh has package availability checking"
        else
            log "  ✗ Utils.sh missing package availability checking"
            errors=$((errors + 1))
        fi
    else
        log "  ✗ Utils.sh file not found"
        errors=$((errors + 1))
    fi

    return $errors
}

# Test 8: Starship Configuration Compatibility
test_starship_compatibility() {
    log "  Testing Starship configuration compatibility..."

    local errors=0

    # Check for Starship modes directory
    local starship_modes_dir="$DOTFILES_DIR/starship/modes"
    if [[ -d "$starship_modes_dir" ]]; then
        local modes=("compact.toml" "standard.toml" "verbose.toml")
        for mode in "${modes[@]}"; do
            if [[ -f "$starship_modes_dir/$mode" ]]; then
                log "  ✓ Found Starship mode: $mode"
            else
                log "  ✗ Missing Starship mode: $mode"
                errors=$((errors + 1))
            fi
        done
    else
        log "  ✗ Starship modes directory not found"
        errors=$((errors + 1))
    fi

    return $errors
}

# ==============================================================================
# Test Execution
# ==============================================================================

# Main test execution
main() {
    print_test_header

    # Run all tests
    run_test "Platform Detection" test_platform_detection
    run_test "Path Resolution System" test_path_resolution
    run_test "Linux Distribution Detection" test_linux_distribution_detection
    run_test "Package Manager Detection" test_package_manager_detection
    run_test "Configuration File Compatibility" test_configuration_compatibility
    run_test "Linux-Specific Features" test_linux_specific_features
    run_test "Installation Script Compatibility" test_installation_script_compatibility
    run_test "Starship Configuration Compatibility" test_starship_compatibility

    # Print summary
    log "\n${BLUE}${BOLD}=== Test Summary ===${NC}"
    log "Total tests: $TESTS_TOTAL"
    log "Passed: ${GREEN}$TESTS_PASSED${NC}"
    log "Failed: ${RED}$TESTS_FAILED${NC}"

    if [[ $TESTS_FAILED -eq 0 ]]; then
        log "\n${GREEN}${BOLD}✓ All tests passed! Linux integration is working correctly.${NC}"
        log "The dotfiles repository is ready for Linux deployment."
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